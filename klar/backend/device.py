"""Device manager: owns the connection to the 199, the live buffer, the
recordings and the notices. Runs a reader thread; listeners (WebSocket
clients) get events through a thread-safe callback."""
import bisect
import json
import math
import os
import threading
import time
from collections import deque

from instrument import protocol as P
from instrument import transport as T

HERE = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.environ.get('KLAR_DATA') or os.path.join(os.path.dirname(HERE), 'data')
SETTINGS_FILE = os.path.join(DATA_DIR, 'settings.json')
LIVE_MAX = 400000                     # ~4 h at 25 readings/s

DEFAULT_SETTINGS = {
    'workplace': 'Arbeitsplatz 1',
    'port': 'auto',                   # 'auto' | 'sim' | '/dev/cu.…'
    'channel_names': {str(c): '' for c in range(1, 9)},
    'limits': {'enabled': False, 'low': None, 'high': None, 'func': 'DCV'},
    'theme': 'light',
}


def load_settings():
    s = json.loads(json.dumps(DEFAULT_SETTINGS))
    try:
        with open(SETTINGS_FILE) as f:
            saved = json.load(f)
        for k, v in saved.items():
            if isinstance(v, dict) and isinstance(s.get(k), dict):
                s[k].update(v)
            else:
                s[k] = v
    except (OSError, ValueError):
        pass
    return s


class Series:
    """Readings with sorted timestamps; queries by time window."""
    def __init__(self, maxlen=None):
        self.t, self.v, self.raw, self.ch, self.flags = (deque(maxlen=maxlen) for _ in range(5))
        self.func = None

    def add(self, r):
        self.t.append(r.t); self.v.append(r.value); self.raw.append(r.raw)
        self.ch.append(r.chan); self.flags.append(r.flags)

    def __len__(self):
        return len(self.t)

    def window(self, t0=None, t1=None):
        t = list(self.t)
        i0 = bisect.bisect_left(t, t0) if t0 is not None else 0
        i1 = bisect.bisect_right(t, t1) if t1 is not None else len(t)
        return i0, i1, t

    def channels(self):
        return sorted(set(self.ch))


def downsample(ts, vs, points):
    """min/max/avg per bucket (keeps spikes visible)."""
    n = len(ts)
    if n == 0:
        return {'t': [], 'min': [], 'max': [], 'avg': []}
    if n <= points:
        return {'t': list(ts), 'min': list(vs), 'max': list(vs), 'avg': list(vs)}
    t0, t1 = ts[0], ts[-1]
    width = (t1 - t0) / points or 1e-9
    out = {'t': [], 'min': [], 'max': [], 'avg': []}
    b, lo, hi, s, k = 0, math.inf, -math.inf, 0.0, 0
    for t, v in zip(ts, vs):
        nb = min(points - 1, int((t - t0) / width))
        if nb != b and k:
            out['t'].append(t0 + (b + 0.5) * width); out['min'].append(lo); out['max'].append(hi); out['avg'].append(s / k)
            lo, hi, s, k = math.inf, -math.inf, 0.0, 0
        b = nb
        lo, hi, s, k = min(lo, v), max(hi, v), s + v, k + 1
    if k:
        out['t'].append(t0 + (b + 0.5) * width); out['min'].append(lo); out['max'].append(hi); out['avg'].append(s / k)
    return out


def stats(ts, vs):
    n = len(vs)
    if n == 0:
        return {'n': 0}
    mean = sum(vs) / n
    sd = math.sqrt(sum((v - mean) ** 2 for v in vs) / (n - 1)) if n > 1 else 0.0
    lo, hi = min(vs), max(vs)
    # drift: least squares slope per minute
    drift = 0.0
    if n > 2 and ts[-1] > ts[0]:
        tm = sum(ts) / n
        den = sum((t - tm) ** 2 for t in ts)
        if den:
            drift = sum((t - tm) * (v - mean) for t, v in zip(ts, vs)) / den * 60
    k = max(1, min(10, n // 10))                       # Δ: mean of the first/last few points
    delta = sum(vs[-k:]) / k - sum(vs[:k]) / k
    bins = 16
    hist = [0] * bins
    if hi > lo:
        for v in vs:
            hist[min(bins - 1, int((v - lo) / (hi - lo) * bins))] += 1
    else:
        hist[bins // 2] = n
    return {'n': n, 'mean': mean, 'min': lo, 'max': hi, 'sd': sd, 'pp': hi - lo, 'drift_per_min': drift,
            'delta': delta, 'duration': ts[-1] - ts[0], 'hist': hist, 'hist_lo': lo, 'hist_hi': hi}


class Recording:
    def __init__(self, rid, state, ranges):
        self.id = rid
        self.start = time.time()
        self.stop = None
        self.func = state.func if state else 'DCV'
        self.unit = P.UNIT.get(self.func, '')
        self.series = Series()
        self.notes = []
        os.makedirs(DATA_DIR, exist_ok=True)
        self.path = os.path.join(DATA_DIR, time.strftime('k199_%Y%m%d_%H%M%S.csv', time.localtime(self.start)))
        self.file = open(self.path, 'w')
        self.file.write('timestamp;t_s;value;unit;raw;function;range;channel;flags\n')

    def add(self, r):
        if r.overflow:
            return
        self.series.add(r)
        self.file.write('%s.%03d;%.3f;%.9E;%s;%.9E;%s;%d;%d;%d\n' % (
            time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(r.t)), int(r.t * 1000) % 1000,
            r.t - self.start, r.value, P.UNIT.get(r.func, ''), r.raw, r.func, r.ri, r.chan, r.flags))

    def close(self):
        self.stop = time.time()
        self.file.close()

    def info(self):
        return {'id': self.id, 'start': self.start, 'stop': self.stop, 'func': self.func, 'unit': self.unit,
                'points': len(self.series), 'channels': self.series.channels(), 'file': self.path,
                'notes': self.notes}


class Device:
    def __init__(self, port_override=None):
        self.settings = load_settings()
        self.port_override = port_override     # 'sim' from the command line, not saved
        self.lock = threading.RLock()
        self.wlock = threading.Lock()
        self.transport = None
        self.port_name = ''
        self.idn = ''
        self.status = 'searching'           # searching | connected | disconnected
        self.state = None
        self.ranges = []
        self.live = Series(maxlen=LIVE_MAX)
        self.last = None
        self.recording = None
        self.recordings = []
        self.notices = []
        self.listeners = []
        self.reconnect = threading.Event()
        self.limit_state = None
        threading.Thread(target=self._run, daemon=True).start()

    # ---------------------------------------------------------------- events
    def subscribe(self, fn):
        with self.lock:
            self.listeners.append(fn)

    def unsubscribe(self, fn):
        with self.lock:
            if fn in self.listeners:
                self.listeners.remove(fn)

    def emit(self, msg):
        for fn in list(self.listeners):
            try:
                fn(msg)
            except Exception:
                pass

    def notice(self, text, level='hint'):
        n = {'id': int(time.time() * 1000), 't': time.time(), 'text': text, 'level': level}
        with self.lock:
            self.notices.append(n)
            del self.notices[:-50]
        self.emit({'t': 'notice', 'notice': n})

    # ---------------------------------------------------------------- info
    def info(self):
        return {'t': 'info', 'status': self.status, 'port': self.port_name, 'idn': self.idn,
                'build': self.idn.split(',', 3)[3] if self.idn.count(',') >= 3 else '',
                'state': self.state.to_dict() if self.state else None,
                'ranges': [{'fs': fs, 'label': P.range_label(self.state.func if self.state else 'DCV', fs)}
                           for fs in self.ranges],
                'recording': self.recording.info() if self.recording else None,
                'settings': self.settings, 'notices': self.notices[-20:],
                'last': self._reading_dict(self.last) if self.last else None}

    @staticmethod
    def _reading_dict(r):
        return {'t': r.t, 'v': r.value, 'raw': r.raw, 'func': r.func, 'ri': r.ri, 'flags': r.flags, 'ch': r.chan}

    def save_settings(self, patch):
        with self.lock:
            for k, v in patch.items():
                if k in self.settings and isinstance(self.settings[k], dict) and isinstance(v, dict):
                    self.settings[k].update(v)
                elif k in DEFAULT_SETTINGS:
                    self.settings[k] = v
            os.makedirs(DATA_DIR, exist_ok=True)
            with open(SETTINGS_FILE, 'w') as f:
                json.dump(self.settings, f, indent=1, ensure_ascii=False)
        if 'port' in patch:
            self.port_override = None
            self.reconnect.set()
        self.emit(self.info())

    # ---------------------------------------------------------------- commands
    def send(self, *cmds):
        tr = self.transport
        if tr is None:
            return False
        try:
            with self.wlock:
                for c in cmds:
                    tr.write((c.strip() + '\n').encode())
                    self.emit({'t': 'log', 'dir': 'tx', 'line': c.strip()})
        except OSError:
            return False
        return True

    def set_mode(self, mode):
        return self.send(*P.mode_commands(mode))

    def start_recording(self):
        with self.lock:
            if self.recording:
                return self.recording
            rid = time.strftime('%Y%m%d-%H%M%S')
            self.recording = Recording(rid, self.state, self.ranges)
            self.recordings.append(self.recording)
        self.emit(self.info())
        return self.recording

    def stop_recording(self):
        with self.lock:
            rec, self.recording = self.recording, None
            if rec:
                rec.close()
        self.emit(self.info())
        return rec

    def get_recording(self, rid):
        if rid == 'live':
            return None
        for r in self.recordings:
            if r.id == rid:
                return r
        raise KeyError(rid)

    # ---------------------------------------------------------------- reader
    def _open(self):
        want = self.port_override or self.settings.get('port', 'auto')
        if want == 'sim':
            return T.SimTransport(), 'Simulator', ''
        if want and want != 'auto':
            r = T.probe(want)
            return (r[0], want, r[1]) if r else (None, '', '')
        r = T.find_device()
        return (r[1], r[0], r[2]) if r else (None, '', '')

    def _run(self):
        while True:
            self.reconnect.clear()
            self.status = 'searching'
            self.emit(self.info())
            tr, name, idn = self._open()
            if tr is None:
                self.status = 'disconnected'
                self.emit(self.info())
                self.reconnect.wait(3)
                continue
            self.transport, self.port_name, self.idn = tr, name, idn
            self.status = 'connected'
            self.emit(self.info())
            self.send('*IDN?', 'STREAM 1', 'STAT?', 'RANG?')
            buf = b''
            try:
                while not self.reconnect.is_set():
                    chunk = tr.readline()
                    if not chunk:
                        continue
                    buf += chunk
                    while b'\n' in buf:
                        line, buf = buf.split(b'\n', 1)
                        self._line(line.decode('ascii', 'replace'))
            except Exception as e:                      # unplugged
                self.notice('Verbindung zum Gerät verloren (%s)' % type(e).__name__, 'warn')
            try:
                tr.close()
            except Exception:
                pass
            self.transport = None
            self.status = 'disconnected'
            self.emit(self.info())
            time.sleep(1)

    def _line(self, line):
        kind, p = P.parse_line(line, time.time())
        if kind == 'reading':
            self.last = p
            if not p.overflow:
                with self.lock:
                    if self.live.func != p.func:
                        self.live = Series(maxlen=LIVE_MAX)
                        self.live.func = p.func
                    self.live.add(p)
                    if self.recording:
                        self.recording.add(p)
                self._check_limits(p)
            self.emit({'t': 'r', 'r': self._reading_dict(p)})
        elif kind == 'state':
            old = self.state
            self.state = p
            if old is None or old.func != p.func:
                self.send('RANG?')
            self.emit({'t': 'info', **{k: v for k, v in self.info().items() if k != 't'}})
        elif kind == 'ranges':
            self.ranges = p
            self.emit(self.info())
        elif kind == 'idn':
            self.idn = p
            self.emit(self.info())
        elif kind == 'ready':
            self.notice('Gerät wurde neu gestartet', 'hint')
            self.send('*IDN?', 'STREAM 1', 'STAT?', 'RANG?')
        elif kind == 'error':
            self.emit({'t': 'log', 'dir': 'rx', 'line': 'ERR,' + p})
        elif kind in ('ok', 'other'):
            self.emit({'t': 'log', 'dir': 'rx', 'line': line.strip()})

    def _check_limits(self, r):
        lim = self.settings.get('limits') or {}
        if not lim.get('enabled') or lim.get('func') != r.func:
            self.limit_state = None
            return
        lo, hi = lim.get('low'), lim.get('high')
        inside = (lo is None or r.value >= lo) and (hi is None or r.value <= hi)
        st = 'in' if inside else ('low' if lo is not None and r.value < lo else 'high')
        if st != self.limit_state:
            if self.limit_state is not None and st != 'in':
                self.notice('Grenzwert %s: %.7g %s' % ('überschritten' if st == 'high' else 'unterschritten',
                                                        r.value, P.UNIT[r.func]), 'warn')
            self.limit_state = st
