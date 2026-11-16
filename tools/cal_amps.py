#!/usr/bin/env python3
"""DC-amps calibration run of the K199 against a Keithley 2700 in series.

Wiring: RD6018P + -> 2700 AMPS -> 2700 LO -> 199 AMPS -> 199 LO -> RD6018P -.
The Riden works as current source (CC mode, voltage limit V_LIM). For one 199
DCA range the firmware is built with autorange off (or on: RANGE = auto) and
that range as power-on state, flashed, then the Riden steps through the
points; after SETTLE seconds both displays are photographed. A point of 0
means output off (zero current).

Points: "12" = CC mode at 12 mA (Riden CC regulation is noisy at small
currents!), "v0.16" = CV mode at 0.16 V: the current follows from the loop
resistance (both shunts) and is much more stable; the current limit ILIM_mA
then only protects (point aborts if the Riden falls into CC).
Output: captures/<name>.jpg (tile 2700 | 199 per point) and <name>.csv.

usage: cal_amps.py NAME RANGE SETTLE_S ILIM_mA P1 P2 ...
       RANGE = 30m | 3 | auto | none (none = keep the flashed firmware)
"""
import os, re, subprocess, sys, time
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import cv2
from rd6018 import RD6018
from cal_vs_ref import grab, flash, PROJ

V_LIM = 3.0          # compliance voltage of the current source (3 A x ~0.8 ohm loop)
OVP_V = 4.0
OCP_A = 3.1

name, rng, settle, ilim = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
pts = sys.argv[5:]


def set_firmware(rng):
    ri, auto = {'30m': (0, 0), '3': (1, 0), 'auto': (0, 1)}[rng]
    p = f'{PROJ}/src/tasks/app_dmm.c'
    s = open(p).read()
    s, a = re.subn(r'\.func = F_\w+, \.ri = \d, \.autorange = \d',
                   f'.func = F_DCA, .ri = {ri}, .autorange = {auto}', s)
    assert a == 1
    open(p, 'w').write(s)
    os.utime(f'{PROJ}/src/tasks/main.c')
    flash()


if __name__ == '__main__':
    assert ilim <= 3000, 'Riden limit 3 A (199 / 2700 3 A ranges)'
    if rng != 'none':
        set_firmware(rng)
        print('flashed DCA', rng, flush=True)
    rd = RD6018()
    rows, lines = [], []
    try:
        rd._write_verified(82, round(OVP_V * 1000)); rd._write_verified(83, round(OCP_A * 1000))
        rd.set_voltage(V_LIM); rd.set_current(0.001)
        for p in pts:
            cv_mode = p.startswith('v')
            val = float(p[1:] if cv_mode else p)
            if val <= 0:
                rd.off()
            elif cv_mode:
                assert val <= V_LIM
                rd.set_current(ilim / 1000); rd.set_voltage(val); rd.output(True)
            else:
                assert val <= ilim
                rd.set_voltage(V_LIM); rd.set_current(val / 1000); rd.output(True)
            time.sleep(settle)
            s = rd.status()
            bad = s['protect'] != 'ok'
            if val > 0:
                bad |= (s['mode'] != 'CV') if cv_mode else (s['mode'] != 'CC' or s['v_out'] > V_LIM - 0.2)
            if bad:
                raise SystemExit(f'ABORT at {p} (loop open, current limit or protection): {s}')
            im = grab()
            cv2.putText(im, p, (3, 16), 0, 0.5, (0, 255, 255), 1)
            rows.append(im); lines.append(f'{p},{s["i_out"]:.4f},{s["v_out"]:.3f}')
            print(f'{p:>7}  RD {s["i_out"]*1000:.1f} mA  {s["v_out"]:.3f} V', flush=True)
    finally:
        rd.off(); print('output', 'ON' if rd.status()['output'] else 'off'); rd.close()
        if rows:
            cv2.imwrite(f'{HERE}/captures/{name}.jpg', cv2.vconcat(rows))
            open(f'{HERE}/captures/{name}.csv', 'w').write('set_mA,rd_A,rd_V\n' + '\n'.join(lines) + '\n')
