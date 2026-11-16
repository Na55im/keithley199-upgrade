import os, sys, unittest
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from instrument import protocol as P
from instrument.transport import SimTransport
import device as D


class ParseTest(unittest.TestCase):
    def test_reading_with_channel(self):
        k, r = P.parse_line('R,5220,-9.659042883E-01,-9.659042883E-01,DCV,1,5,3', 1.0)
        self.assertEqual(k, 'reading')
        self.assertAlmostEqual(r.value, -0.9659042883)
        self.assertEqual((r.func, r.ri, r.flags, r.chan), ('DCV', 1, 5, 3))
        self.assertFalse(r.overflow)

    def test_reading_old_format(self):
        k, r = P.parse_line('R,1,1.0E+00,1.0E+00,DCA,0,8', 0)
        self.assertEqual((k, r.chan, r.settled), ('reading', 0, True))

    def test_overflow(self):
        k, r = P.parse_line('R,21146,9.900000000E+37,9.900000000E+37,OHM2,1,16,0', 0)
        self.assertTrue(r.overflow)

    def test_state(self):
        k, s = P.parse_line('S,DCA,1,3.030000000E+00,0,0,5,1,1.269714589E-03,0,ONE,0,1,FAST,60,4166,1,0,14', 0)
        self.assertEqual(k, 'state')
        self.assertEqual((s.func, s.ri, s.digits, s.zero, s.trig, s.speed, s.line, s.lock, s.scan),
                         ('DCA', 1, 5, 1, 'ONE', 'FAST', 60, 1, 14))
        d = s.to_dict()
        self.assertEqual(d['scan_list'], [1, 2, 3])
        self.assertEqual(d['unit'], 'A')

    def test_state_old_format(self):
        k, s = P.parse_line('S,DCV,1,3.030000000E+00,1,1,6,0,0.000000000E+00,0,CONT,0,0', 0)
        self.assertEqual((k, s.speed), ('state', 'LINE'))

    def test_misc(self):
        self.assertEqual(P.parse_line('K199 READY', 0), ('ready', None))
        self.assertEqual(P.parse_line('OK\r', 0), ('ok', None))
        self.assertEqual(P.parse_line('ERR,ARG', 0), ('error', 'ARG'))
        self.assertEqual(P.parse_line('KEITHLEY,199-UPGRADE,0,Nov 16 2026', 0)[0], 'idn')
        self.assertEqual(P.parse_line('3.030000000E-01,3.030000000E+00', 0), ('ranges', [0.303, 3.03]))
        self.assertEqual(P.parse_line('R,garbage', 0)[0], 'other')
        self.assertEqual(P.parse_line('', 0), (None, None))

    def test_modes(self):
        self.assertEqual(P.mode_commands('precise'), ['SPEED LINE', 'FILT 1', 'DIG 6'])
        self.assertEqual(P.mode_of({'speed': 'FAST', 'filter': 0, 'digits': 4}), 'fast')
        self.assertEqual(P.mode_of({'speed': 'FAST', 'filter': 1, 'digits': 4}), 'custom')

    def test_range_label(self):
        self.assertEqual(P.range_label('DCV', 0.303), '300 mV')
        self.assertEqual(P.range_label('DCV', 3.03), '3 V')
        self.assertEqual(P.range_label('OHM2', 30300), '30 kΩ')
        self.assertEqual(P.range_label('OHM4', 3.03e6), '3 MΩ')
        self.assertEqual(P.range_label('DCA', 0.0303), '30 mA')


class StatsTest(unittest.TestCase):
    def test_stats_and_downsample(self):
        ts = [i * 1.0 for i in range(600)]
        vs = [1.0 + 1e-3 * t / 60 for t in ts]        # 1 mV/min drift
        s = D.stats(ts, vs)
        self.assertAlmostEqual(s['drift_per_min'], 1e-3, places=9)
        self.assertEqual(s['n'], 600)
        d = D.downsample(ts, vs, 100)
        self.assertEqual(len(d['t']), 100)
        self.assertLessEqual(d['min'][0], d['max'][0])


class SimTest(unittest.TestCase):
    def test_sim_answers(self):
        s = SimTransport()
        s.write(b'*IDN?\nFUNC XYZ\nSCAN 2,5\n')
        lines = []
        for _ in range(6):
            l = s.readline()
            if l:
                lines.append(l.decode().strip())
        s.close()
        self.assertIn('K199 READY', lines)
        self.assertTrue(any(l.startswith('KEITHLEY,') for l in lines))
        self.assertIn('ERR,ARG', lines)


if __name__ == '__main__':
    unittest.main()
