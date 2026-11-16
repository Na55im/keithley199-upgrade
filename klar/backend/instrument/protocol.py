"""Line protocol of the Keithley 199 upgrade board (insturctions/remote-protocol.md).

Pure functions, no I/O: parse device lines, describe functions and ranges,
map the measuring modes of the KLAR design to device commands.
"""
from dataclasses import dataclass, field, asdict

FUNCS = ['DCV', 'ACV', 'DCA', 'ACA', 'OHM2', 'OHM4']
UNIT = {'DCV': 'V', 'ACV': 'V', 'DCA': 'A', 'ACA': 'A', 'OHM2': 'Ω', 'OHM4': 'Ω'}

# reading flags
F_AUTO, F_ZERO, F_FILTER, F_SETTLED, F_OVERFLOW, F_DB, F_HOLD = 1, 2, 4, 8, 16, 32, 64

# KLAR measuring modes -> commands (klar/CLAUDE.md)
MODES = {
    'fast':    {'speed': 'FAST', 'filter': 0, 'digits': 4},
    'std':     {'speed': 'LINE', 'filter': 0, 'digits': 5},
    'precise': {'speed': 'LINE', 'filter': 1, 'digits': 6},
}


def mode_commands(mode):
    m = MODES[mode]
    return ['SPEED ' + m['speed'], 'FILT %d' % m['filter'], 'DIG %d' % m['digits']]


def mode_of(state):
    """Measuring mode that matches a device state, or 'custom'."""
    for name, m in MODES.items():
        if (state.get('speed') == m['speed'] and state.get('filter') == m['filter']
                and state.get('digits') == m['digits']):
            return name
    return 'custom'


@dataclass
class Reading:
    t: float            # host time (unix s)
    ms: int             # device ms since power on
    value: float        # as displayed (filter, zero)
    raw: float          # single conversion
    func: str
    ri: int
    flags: int
    chan: int = 0

    @property
    def overflow(self):
        return bool(self.flags & F_OVERFLOW)

    @property
    def settled(self):
        return bool(self.flags & F_SETTLED)


@dataclass
class State:
    func: str = 'DCV'
    ri: int = 1
    fs: float = 3.03
    auto: int = 1
    filter: int = 1
    digits: int = 6
    zero: int = 0
    zero_val: float = 0.0
    db: int = 0
    trig: str = 'CONT'
    chan: int = 0
    stream: int = 0
    speed: str = 'LINE'
    line: int = 50
    int_us: int = 20000
    lock: int = 0
    hold: int = 0
    scan: int = 0
    extra: dict = field(default_factory=dict)

    def to_dict(self):
        d = asdict(self)
        d.pop('extra')
        d['mode'] = mode_of(d)
        d['unit'] = UNIT.get(self.func, '')
        d['scan_list'] = [c for c in range(1, 9) if self.scan & (1 << c)]
        return d


_STATE_FIELDS = [('func', str), ('ri', int), ('fs', float), ('auto', int), ('filter', int),
                 ('digits', int), ('zero', int), ('zero_val', float), ('db', int), ('trig', str),
                 ('chan', int), ('stream', int), ('speed', str), ('line', int), ('int_us', int),
                 ('lock', int), ('hold', int), ('scan', int)]


def parse_line(line, now):
    """Classify one device line.

    Returns (kind, payload):
      ('reading', Reading) | ('state', State) | ('ranges', [float]) | ('idn', str)
      ('ready', None) | ('ok', None) | ('error', str) | ('other', str) | (None, None) for empty
    """
    line = line.strip()
    if not line:
        return None, None
    f = line.split(',')
    try:
        if f[0] == 'R' and len(f) in (7, 8):
            return 'reading', Reading(now, int(f[1]), float(f[2]), float(f[3]), f[4], int(f[5]), int(f[6]),
                                      int(f[7]) if len(f) == 8 else 0)
        if f[0] == 'S' and len(f) >= 13:
            st = State()
            for (name, typ), val in zip(_STATE_FIELDS, f[1:]):
                setattr(st, name, typ(val))
            return 'state', st
    except ValueError:
        return 'other', line
    if line == 'K199 READY':
        return 'ready', None
    if line == 'OK':
        return 'ok', None
    if line.startswith('ERR,'):
        return 'error', line[4:]
    if line.startswith('KEITHLEY,'):
        return 'idn', line
    if line[0] in '0123456789' and 'E' in line:
        try:
            return 'ranges', [float(x) for x in f]
        except ValueError:
            pass
    return 'other', line


def range_label(func, fs):
    """Nominal range name from the full scale value, e.g. 3.03 -> '3 V', 30300 -> '30 kΩ'."""
    unit = UNIT.get(func, '')
    nominal = fs / 1.01
    for mult, prefix in ((1e6, 'M'), (1e3, 'k'), (1, ''), (1e-3, 'm')):
        if nominal >= mult * 0.99:
            return '%g %s%s' % (round(nominal / mult, 3), prefix, unit)
    return '%g %s' % (nominal, unit)
