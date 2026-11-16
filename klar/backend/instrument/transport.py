"""Transports to the 199: USB serial (pyserial) or a built-in simulator.

Both offer write(bytes), readline() -> bytes (b'' on timeout) and close().
"""
import math
import queue
import random
import threading
import time

BAUD = 115200


def list_serial_ports():
    from serial.tools import list_ports
    return [p.device for p in list_ports.comports()
            if p.vid is not None and ('/cu.' in p.device or not p.device.startswith('/dev/tty.'))]


def probe(port, timeout=2.0):
    """Open port, ask *IDN?; returns (serial, idn) if a 199 answers, else None."""
    import serial
    try:
        s = serial.Serial(port, BAUD, timeout=0.3)
    except (OSError, serial.SerialException):
        return None
    try:
        time.sleep(0.1)
        s.reset_input_buffer()
        s.write(b'\n*IDN?\n')
        t = time.time()
        while time.time() - t < timeout:
            line = s.readline().decode('ascii', 'replace').strip()
            if line.startswith('KEITHLEY,') and '199' in line:
                return s, line
    except (OSError, serial.SerialException):
        pass
    s.close()
    return None


def find_device(ports=None):
    """Try all USB serial ports (a Riden on the same hub does not answer *IDN?)."""
    for p in ports or list_serial_ports():
        r = probe(p)
        if r:
            return p, r[0], r[1]
    return None


class SimTransport:
    """Simulated 199 speaking the same line protocol (for UI work without hardware)."""
    RANGES = {'DCV': [0.3, 3, 30, 300], 'ACV': [0.3, 3, 30, 300], 'DCA': [0.03, 3], 'ACA': [0.03, 3],
              'OHM2': [300, 3e3, 30e3, 300e3, 3e6], 'OHM4': [300, 3e3, 30e3, 300e3, 3e6]}
    TRUE = {'DCV': 1.024381, 'ACV': 0.70712, 'DCA': 0.0124839, 'ACA': 0.0048215, 'OHM2': 10002.47, 'OHM4': 10000.41}
    name = 'Simulator'

    def __init__(self):
        self.out = queue.Queue()
        self.buf = b''
        self.s = dict(func='DCV', ri=1, auto=1, filter=1, digits=6, zero=0, zero_val=0.0, db=0,
                      trig='CONT', chan=0, stream=0, speed='LINE', line=50, lock=0, hold=0, scan=0)
        self.t0 = time.time()
        self.filt = []
        self.last = 0.0
        self.trg = 0
        self.alive = True
        self.out.put(b'K199 READY\n')
        threading.Thread(target=self._run, daemon=True).start()

    def _fs(self):
        return self.RANGES[self.s['func']][self.s['ri']] * 1.01

    def _int_us(self):
        line = 20000 if self.s['line'] == 50 else 16667
        return line // 4 if self.s['speed'] == 'FAST' else line

    def _state(self):
        s = self.s
        return 'S,%s,%d,%.9E,%d,%d,%d,%d,%.9E,%d,%s,%d,%d,%s,%d,%d,%d,%d,%d\n' % (
            s['func'], s['ri'], self._fs(), s['auto'], s['filter'], s['digits'], s['zero'],
            s['zero_val'] if s['zero'] else 0, s['db'], s['trig'], s['chan'], s['stream'],
            s['speed'], s['line'], self._int_us(), s['lock'], s['hold'], s['scan'])

    def _flags(self):
        s = self.s
        return (s['auto'] | s['zero'] << 1 | s['filter'] << 2 |
                (32 if s['db'] and s['func'] in ('ACV', 'ACA') else 0) | s['hold'] << 6)

    def _true(self, t):
        s = self.s
        base = self.TRUE[s['func']] * (1 + 0.004 * (s['chan'] - 1) if s['chan'] else 1)
        drift = 1 + 3e-5 * math.sin(t / 40) + 1e-5 * math.sin(t / 7)
        return base * drift

    def _run(self):
        while self.alive:
            s = self.s
            time.sleep(0.048 if s['speed'] == 'FAST' else 0.108)
            if s['trig'] == 'ONE' and not self.trg:
                continue
            t = time.time() - self.t0
            true = self._true(t)
            rng = self.RANGES[s['func']]
            if s['auto']:
                ri = s['ri']
                while ri < len(rng) - 1 and true > rng[ri]:
                    ri += 1
                while ri > 0 and true < 0.9 * rng[ri - 1]:
                    ri -= 1
                if ri != s['ri']:
                    s['ri'] = ri
                    self.filt = []
                    self.out.put(self._state().encode())
                    continue
            ms = int(t * 1000)
            fs = rng[s['ri']]
            if true > fs * 1.01:
                if s['stream']:
                    self.out.put(('R,%d,9.900000000E+37,9.900000000E+37,%s,%d,%d,%d\n' % (
                        ms, s['func'], s['ri'], 16 | self._flags(), s['chan'])).encode())
                continue
            noise = fs * (6e-6 if s['speed'] == 'FAST' else 3e-6)
            raw = true + random.gauss(0, noise)
            if s['filter']:
                self.filt = (self.filt + [raw])[-100:]
                v = sum(self.filt) / len(self.filt)
                settled = len(self.filt) == 100
            else:
                v, settled = raw, True
            if s['trig'] == 'ONE' and s['filter'] and not settled:
                continue
            self.trg = 0
            self.last = v
            if s['zero']:
                v -= s['zero_val']
            if s['stream'] and not (s['scan'] and s['filter'] and not settled):
                self.out.put(('R,%d,%.9E,%.9E,%s,%d,%d,%d\n' % (
                    ms, v, raw, s['func'], s['ri'], self._flags() | (8 if settled else 0), s['chan'])).encode())
            if s['scan'] and (settled or not s['filter']):
                chans = [c for c in range(1, 9) if s['scan'] & (1 << c)]
                s['chan'] = chans[(chans.index(s['chan']) + 1) % len(chans)] if s['chan'] in chans else chans[0]
                self.filt = []

    def write(self, data):
        self.buf += data
        while b'\n' in self.buf:
            line, self.buf = self.buf.split(b'\n', 1)
            self._exec(line.decode().strip().upper())

    def _exec(self, line):
        if not line:
            return
        cmd, _, arg = line.partition(' ')
        s, ans = self.s, 'OK\n'
        onoff = {'1': 1, 'ON': 1, '0': 0, 'OFF': 0}
        n = len(self.RANGES[s['func']])
        if cmd == '*IDN?': ans = 'KEITHLEY,199-UPGRADE,0,SIMULATOR\n'
        elif cmd == 'STAT?': ans = self._state()
        elif cmd == 'RANG?': ans = ','.join('%.9E' % (r * 1.01) for r in self.RANGES[s['func']]) + '\n'
        elif cmd == 'READ?':
            ans = 'R,%d,%.9E,%.9E,%s,%d,%d,%d\n' % (int((time.time() - self.t0) * 1000), self.last, self.last,
                                                   s['func'], s['ri'], self._flags(), s['chan'])
        elif cmd == 'STREAM' and arg in onoff: s['stream'] = onoff[arg]
        elif cmd == 'FUNC' and arg in self.RANGES:
            if s['func'] != arg:
                s.update(func=arg, ri=0 if arg in ('DCA', 'ACA') else 1, zero=0, db=0)
            self.filt = []
        elif cmd == 'RANG' and arg == 'AUTO': s['auto'] = 1
        elif cmd == 'RANG' and arg == 'UP': s.update(auto=0, ri=min(n - 1, s['ri'] + 1)); self.filt = []
        elif cmd == 'RANG' and arg == 'DOWN': s.update(auto=0, ri=max(0, s['ri'] - 1)); self.filt = []
        elif cmd == 'RANG' and arg.isdigit() and int(arg) < n: s.update(auto=0, ri=int(arg)); self.filt = []
        elif cmd == 'FILT' and arg in onoff: s['filter'] = onoff[arg]; self.filt = []
        elif cmd == 'DIG' and arg in ('4', '5', '6'): s['digits'] = int(arg)
        elif cmd == 'ZERO' and arg in onoff: s.update(zero=onoff[arg], zero_val=self.last)
        elif cmd == 'DB' and arg in onoff: s['db'] = onoff[arg]
        elif cmd == 'TRIG' and arg in ('CONT', 'ONE'): s['trig'] = arg
        elif cmd == '*TRG': self.trg = 1; self.filt = [] if s['filter'] else self.filt
        elif cmd == 'CHAN' and arg.isdigit() and int(arg) <= 8: s.update(chan=int(arg), scan=0)
        elif cmd == 'SCAN' and arg in ('0', 'OFF'): s.update(scan=0, chan=0)
        elif cmd == 'SCAN' and self._chanlist(arg):
            m = self._chanlist(arg); s['scan'] = m
            s['chan'] = min(c for c in range(1, 9) if m & (1 << c))
        elif cmd == 'SPEED' and arg in ('FAST', 'LINE'): s['speed'] = arg; self.filt = []
        elif cmd == 'LINE' and arg in ('50', '60'): s['line'] = int(arg)
        elif cmd in ('LOCK', 'HOLD') and arg in onoff: s[cmd.lower()] = onoff[arg]
        elif cmd == '*RST':
            s.update(func='DCV', ri=1, auto=1, filter=1, digits=6, zero=0, db=0, trig='CONT', chan=0,
                     hold=0, scan=0, speed='LINE')
        elif cmd == 'LOCAL': s.update(stream=0, lock=0, hold=0)
        elif cmd == 'KEY': pass
        elif cmd in ('FUNC', 'RANG', 'FILT', 'DIG', 'ZERO', 'DB', 'TRIG', 'CHAN', 'SCAN', 'STREAM',
                     'SPEED', 'LINE', 'LOCK', 'HOLD'):
            ans = 'ERR,ARG\n'
        else:
            ans = 'ERR,CMD\n'
        self.out.put(ans.encode())
        if ans == 'OK\n' and cmd not in ('*TRG', 'KEY'):
            self.out.put(self._state().encode())

    @staticmethod
    def _chanlist(a):
        m = 0
        for part in a.split(','):
            lo, _, hi = part.partition('-')
            if not lo.isdigit() or (hi and not hi.isdigit()):
                return 0
            lo, hi = int(lo), int(hi or lo)
            if not 1 <= lo <= hi <= 8:
                return 0
            for c in range(lo, hi + 1):
                m |= 1 << c
        return m

    def readline(self):
        try:
            return self.out.get(timeout=0.5)
        except queue.Empty:
            return b''

    def close(self):
        self.alive = False
