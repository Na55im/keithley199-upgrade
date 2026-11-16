#!/usr/bin/env python3
"""Keithley 199 remote panel: serial link to the 199 (UART3 on P8/P9, 115200 8N1)
plus a local web page with live reading, trend chart, statistics and control.

    k199_app.py                 find the 199 on a USB serial port, open http://127.0.0.1:8200
    k199_app.py --port /dev/cu.usbserial-XXXX
    k199_app.py --sim           no hardware: built-in simulated 199 (for trying the page)

Protocol: insturctions/remote-protocol.md. Only the Python standard library and pyserial.
"""
import argparse, json, math, os, queue, random, threading, time, webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HERE = os.path.dirname(os.path.abspath(__file__))
HISTORY = 200000                # readings kept in memory
FUNCS = ['DCV', 'ACV', 'DCA', 'ACA', 'OHM2', 'OHM4']
STATE_KEYS = ['func', 'ri', 'fs', 'auto', 'filter', 'digits', 'zero', 'zero_val', 'db', 'trig', 'chan', 'stream',
              'speed', 'line', 'int_us', 'lock', 'hold', 'scan']


# --------------------------------------------------------------------------
class SimPort:
    """Simulated 199 speaking the remote protocol (same interface as the serial port)."""
    RANGES = {'DCV': [0.3, 3, 30, 300], 'ACV': [0.3, 3, 30, 300], 'DCA': [0.03, 3], 'ACA': [0.03, 3],
              'OHM2': [300, 3e3, 30e3, 300e3, 3e6], 'OHM4': [300, 3e3, 30e3, 300e3, 3e6]}
    TRUE = {'DCV': 1.2345678, 'ACV': 0.7071, 'DCA': 0.0123456, 'ACA': 0.005, 'OHM2': 10012.3, 'OHM4': 10000.4}

    def __init__(self):
        self.out = queue.Queue()
        self.buf = b''
        self.s = dict(func='DCV', ri=1, auto=1, filter=1, digits=6, zero=0, zero_val=0.0, db=0,
                      trig='CONT', chan=0, stream=0, speed='LINE', line=50, lock=0, hold=0)
        self.t0 = time.time()
        self.filt = []
        self.last = 0.0
        self.alive = True
        self.out.put(b'K199 READY\n')
        threading.Thread(target=self._run, daemon=True).start()

    def _fs(self):
        return self.RANGES[self.s['func']][self.s['ri']] * 1.01

    def _state(self):
        s = self.s
        return 'S,%s,%d,%.9E,%d,%d,%d,%d,%.9E,%d,%s,%d,%d,%s,%d,%d,%d,%d,%d\n' % (
            s['func'], s['ri'], self._fs(), s['auto'], s['filter'], s['digits'], s['zero'],
            s['zero_val'] if s['zero'] else 0, s['db'], s['trig'], s['chan'], s['stream'],
            s['speed'], s['line'], (5000 if s['speed'] == 'FAST' else 20000) * 50 // s['line'], s['lock'], s['hold'], 0)

    def _run(self):
        while self.alive:
            time.sleep(0.35)
            s = self.s
            t = time.time() - self.t0
            true = self.TRUE[s['func']] * (1 + 2e-5 * math.sin(t / 20))
            fs = self.RANGES[s['func']][s['ri']]
            n = len(self.RANGES[s['func']])
            if s['auto']:
                ri = s['ri']
                while ri < n - 1 and true > self.RANGES[s['func']][ri]: ri += 1
                while ri > 0 and true < 0.9 * self.RANGES[s['func']][ri - 1]: ri -= 1
                if ri != s['ri']:
                    s['ri'] = ri; self.filt = []; self.out.put(self._state().encode()); continue
            ms = int(t * 1000)
            if true > fs:
                if s['stream']:
                    self.out.put(('R,%d,9.900000000E+37,9.900000000E+37,%s,%d,%d,%d\n' % (ms, s['func'], s['ri'], 16 | self._fl(), s['chan'])).encode())
                continue
            raw = true + random.gauss(0, fs * 3e-6)
            if s['filter']:
                self.filt = (self.filt + [raw])[-100:]
                v = sum(self.filt) / len(self.filt)
                settled = len(self.filt) == 100
            else:
                v, settled = raw, True
            self.last = v
            if s['zero']: v -= s['zero_val']
            if s['stream']:
                self.out.put(('R,%d,%.9E,%.9E,%s,%d,%d,%d\n' % (ms, v, raw, s['func'], s['ri'], self._fl() | (8 if settled else 0), s['chan'])).encode())

    def _fl(self):
        s = self.s
        return s['auto'] | s['zero'] << 1 | s['filter'] << 2 | (32 if s['db'] and s['func'] in ('ACV', 'ACA') else 0) | s['hold'] << 6

    def write(self, data):
        self.buf += data
        while b'\n' in self.buf:
            line, self.buf = self.buf.split(b'\n', 1)
            self._exec(line.decode().strip().upper())

    def _exec(self, line):
        if not line: return
        cmd, _, arg = line.partition(' ')
        s, ok = self.s, 'OK\n'
        onoff = {'1': 1, 'ON': 1, '0': 0, 'OFF': 0}
        n = len(self.RANGES[s['func']])
        if cmd == '*IDN?': ok = 'KEITHLEY,199-UPGRADE,0,SIMULATOR\n'
        elif cmd == 'STAT?': ok = self._state()
        elif cmd == 'STREAM' and arg in onoff: s['stream'] = onoff[arg]
        elif cmd == 'FUNC' and arg in FUNCS:
            if s['func'] != arg: s.update(func=arg, ri=0 if arg in ('DCA', 'ACA') else 1, zero=0, db=0)
            self.filt = []
        elif cmd == 'RANG' and arg == 'AUTO': s['auto'] = 1
        elif cmd == 'RANG' and arg == 'UP': s.update(auto=0, ri=min(n - 1, s['ri'] + 1)); self.filt = []
        elif cmd == 'RANG' and arg == 'DOWN': s.update(auto=0, ri=max(0, s['ri'] - 1)); self.filt = []
        elif cmd == 'RANG' and arg.isdigit() and int(arg) < n: s.update(auto=0, ri=int(arg)); self.filt = []
        elif cmd == 'RANG?': ok = ','.join('%.9E' % (r * 1.01) for r in self.RANGES[s['func']]) + '\n'
        elif cmd == 'FILT' and arg in onoff: s['filter'] = onoff[arg]; self.filt = []
        elif cmd == 'DIG' and arg in ('4', '5', '6'): s['digits'] = int(arg)
        elif cmd == 'ZERO' and arg in onoff: s.update(zero=onoff[arg], zero_val=self.last)
        elif cmd == 'DB' and arg in onoff: s['db'] = onoff[arg]
        elif cmd == 'TRIG' and arg in ('CONT', 'ONE'): s['trig'] = arg
        elif cmd == '*TRG': pass
        elif cmd == 'CHAN' and arg.isdigit() and int(arg) <= 8: s['chan'] = int(arg)
        elif cmd == '*RST': s.update(func='DCV', ri=1, auto=1, filter=1, digits=6, zero=0, db=0, trig='CONT', chan=0)
        elif cmd == 'SPEED' and arg in ('FAST', 'LINE'): s['speed'] = arg
        elif cmd == 'LINE' and arg in ('50', '60'): s['line'] = int(arg)
        elif cmd in ('LOCK', 'HOLD') and arg in onoff: s[cmd.lower()] = onoff[arg]
        elif cmd == 'LOCAL': s.update(stream=0, lock=0, hold=0)
        elif cmd == 'KEY': pass
        else: ok = 'ERR,CMD\n' if cmd not in ('FUNC', 'RANG', 'FILT', 'DIG', 'ZERO', 'DB', 'TRIG', 'CHAN', 'STREAM', 'SPEED', 'LINE', 'LOCK', 'HOLD') else 'ERR,ARG\n'
        self.out.put(ok.encode())
        if ok == 'OK\n': self.out.put(self._state().encode())

    def readline(self):
        try:
            return self.out.get(timeout=0.5)
        except queue.Empty:
            return b''

    def close(self):
        self.alive = False


# --------------------------------------------------------------------------
def find_port():
    """Probe all USB serial ports with *IDN? (a Riden on the same hub does not answer)."""
    import serial
    from serial.tools import list_ports
    for p in list_ports.comports():
        if '/cu.' not in p.device or p.vid is None:
            continue
        try:
            s = serial.Serial(p.device, 115200, timeout=0.4)
            time.sleep(0.1); s.reset_input_buffer()
            s.write(b'\n*IDN?\n')
            t = time.time()
            while time.time() - t < 2.0:
                if b'199' in s.readline():
                    return s
            s.close()
        except (OSError, serial.SerialException):
            pass
    return None


class Link:
    """Owns the serial port, parses device lines, keeps history, feeds the web clients."""
    def __init__(self, args):
        self.args = args
        self.port = None
        self.port_name = ''
        self.idn = ''
        self.state = {}
        self.ranges = []
        self.readings = []              # [wall_s, device_ms, value, raw, func, ri, flags]
        self.clients = []
        self.lock = threading.Lock()
        self.wlock = threading.Lock()
        self.logfile = None
        self.logname = ''
        threading.Thread(target=self._run, daemon=True).start()

    # -- web side --
    def subscribe(self):
        q = queue.Queue(maxsize=5000)
        with self.lock:
            self.clients.append(q)
        return q

    def unsubscribe(self, q):
        with self.lock:
            if q in self.clients: self.clients.remove(q)

    def publish(self, msg):
        with self.lock:
            for q in self.clients:
                try: q.put_nowait(msg)
                except queue.Full: pass

    def info(self):
        return dict(t='conn', connected=self.port is not None, port=self.port_name, idn=self.idn,
                    state=self.state, ranges=self.ranges, log=self.logname)

    def send(self, cmd):
        cmd = cmd.strip()
        if not cmd or self.port is None:
            return False
        try:
            with self.wlock:
                self.port.write((cmd + '\n').encode())
        except OSError:
            return False
        self.publish(dict(t='log', dir='tx', line=cmd))
        return True

    def set_log(self, on):
        with self.lock:
            if self.logfile:
                self.logfile.close(); self.logfile = None; self.logname = ''
            if on:
                os.makedirs(os.path.join(HERE, 'logs'), exist_ok=True)
                self.logname = os.path.join(HERE, 'logs', time.strftime('k199_%Y%m%d_%H%M%S.csv'))
                self.logfile = open(self.logname, 'w')
                self.logfile.write('time_iso,unix_s,device_ms,value,raw,function,range,flags,channel\n')
        self.publish(self.info())

    # -- device side --
    def _open(self):
        if self.args.sim:
            self.port_name = 'Simulator'
            return SimPort()
        import serial
        if self.args.port:
            try:
                s = serial.Serial(self.args.port, 115200, timeout=0.4)
            except (OSError, serial.SerialException):
                return None
        else:
            s = find_port()
        if s:
            self.port_name = s.port
        return s

    def _run(self):
        while True:
            port = self._open()
            if port is None:
                time.sleep(2); continue
            self.port = port
            self.publish(self.info())
            for c in ('*IDN?', 'STREAM 1', 'STAT?', 'RANG?'):
                self.send(c)
            buf = b''
            try:
                while True:
                    chunk = port.readline()
                    if not chunk:
                        continue
                    buf += chunk
                    while b'\n' in buf:
                        line, buf = buf.split(b'\n', 1)
                        self._line(line.decode('ascii', 'replace').strip())
            except Exception as e:           # port unplugged
                print('link lost:', e)
            try: port.close()
            except Exception: pass
            self.port = None
            self.publish(self.info())
            time.sleep(1)

    def _line(self, line):
        if not line:
            return
        f = line.split(',')
        try:
            if f[0] == 'R' and len(f) in (7, 8):
                now = time.time()
                r = [now, int(f[1]), float(f[2]), float(f[3]), f[4], int(f[5]), int(f[6]),
                     int(f[7]) if len(f) == 8 else 0]
                with self.lock:
                    self.readings.append(r)
                    if len(self.readings) > HISTORY:
                        del self.readings[:HISTORY // 10]
                    if self.logfile:
                        self.logfile.write('%s.%03d,%.3f,%d,%.9E,%.9E,%s,%d,%d,%d\n' % (
                            time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(now)), int(now * 1000) % 1000,
                            now, *r[1:]))
                        self.logfile.flush()
                self.publish(dict(t='r', r=r))
                return
            if f[0] == 'S' and len(f) >= 13:
                vals = f[1:]
                st = dict(zip(STATE_KEYS, vals))
                for k in ('ri', 'auto', 'filter', 'digits', 'zero', 'db', 'chan', 'stream', 'line', 'int_us', 'lock', 'hold', 'scan'):
                    if k in st:
                        st[k] = int(st[k])
                st['fs'] = float(st['fs']); st['zero_val'] = float(st['zero_val'])
                func_changed = st['func'] != self.state.get('func')
                self.state = st
                self.publish(dict(t='s', state=st))
                if func_changed:
                    self.send('RANG?')
                return
        except ValueError:
            pass
        if line == 'K199 READY':                 # device was reset: switch the stream on again
            for c in ('*IDN?', 'STREAM 1', 'STAT?', 'RANG?'):
                self.send(c)
        elif line.startswith('KEITHLEY,'):
            self.idn = line
            self.publish(self.info())
        elif line[0] in '0123456789' and 'E' in line:    # RANG? answer
            try:
                self.ranges = [float(x) for x in f]
                self.publish(self.info())
            except ValueError:
                pass
        self.publish(dict(t='log', dir='rx', line=line))


# --------------------------------------------------------------------------
class Handler(BaseHTTPRequestHandler):
    link = None
    protocol_version = 'HTTP/1.1'

    def log_message(self, *a):
        pass

    def _send(self, code, ctype, body, extra=None):
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        for k, v in (extra or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split('?')[0]
        if path == '/':
            self._send(200, 'text/html; charset=utf-8', open(os.path.join(HERE, 'k199_app.html'), 'rb').read())
        elif path == '/history':
            with self.link.lock:
                rows = self.link.readings[-20000:]
            self._send(200, 'application/json', json.dumps(dict(info=self.link.info(), readings=rows)).encode())
        elif path == '/csv':
            with self.link.lock:
                rows = list(self.link.readings)
            out = ['time_iso,unix_s,device_ms,value,raw,function,range,flags,channel']
            for r in rows:
                out.append('%s.%03d,%.3f,%d,%.9E,%.9E,%s,%d,%d,%d' % (
                    time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(r[0])), int(r[0] * 1000) % 1000, *r))
            self._send(200, 'text/csv', ('\n'.join(out) + '\n').encode(),
                       {'Content-Disposition': time.strftime('attachment; filename="k199_%Y%m%d_%H%M%S.csv"')})
        elif path == '/events':
            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream')
            self.send_header('Cache-Control', 'no-store')
            self.send_header('Connection', 'close')
            self.end_headers()
            q = self.link.subscribe()
            try:
                self.wfile.write(('data: %s\n\n' % json.dumps(self.link.info())).encode()); self.wfile.flush()
                while True:
                    try:
                        msgs = [q.get(timeout=10)]
                        while not q.empty() and len(msgs) < 500:
                            msgs.append(q.get_nowait())
                        self.wfile.write(''.join('data: %s\n\n' % json.dumps(m) for m in msgs).encode())
                    except queue.Empty:
                        self.wfile.write(b': keepalive\n\n')
                    self.wfile.flush()
            except OSError:
                pass
            finally:
                self.link.unsubscribe(q)
        else:
            self._send(404, 'text/plain', b'not found')

    def do_POST(self):
        if self.headers.get('Origin') not in (None, 'http://127.0.0.1:%d' % self.server.server_port,
                                             'http://localhost:%d' % self.server.server_port):
            return self._send(403, 'text/plain', b'forbidden')
        body = self.rfile.read(int(self.headers.get('Content-Length', 0))).decode('utf-8', 'replace')
        if self.path == '/cmd':
            ok = all(self.link.send(c) for c in body.split('\n') if c.strip())
            self._send(200 if ok else 503, 'text/plain', b'ok' if ok else b'not connected')
        elif self.path == '/clear':
            with self.link.lock:
                self.link.readings.clear()
            self._send(200, 'text/plain', b'ok')
        elif self.path == '/log':
            self.link.set_log(body.strip() == '1')
            self._send(200, 'text/plain', b'ok')
        else:
            self._send(404, 'text/plain', b'not found')


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--port', help='serial port of the 199 (default: search)')
    ap.add_argument('--sim', action='store_true', help='simulated device')
    ap.add_argument('--http', type=int, default=8200, help='HTTP port (default 8200)')
    ap.add_argument('--no-browser', action='store_true')
    args = ap.parse_args()
    Handler.link = Link(args)
    srv = ThreadingHTTPServer(('127.0.0.1', args.http), Handler)
    srv.daemon_threads = True
    url = 'http://127.0.0.1:%d/' % args.http
    print('Keithley 199 panel:', url, '(Ctrl-C to stop)')
    if not args.no_browser:
        threading.Timer(0.5, webbrowser.open, [url]).start()
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
