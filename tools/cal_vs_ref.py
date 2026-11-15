#!/usr/bin/env python3
"""Calibration run of the K199 against a reference DMM (Keithley 2700) read by camera.

The RD6018P drives both meters in parallel. For one 199 range the firmware is
built with AUTORANGE 0 / MEAS_RANGE <range>, flashed, then the Riden steps
through the points; after SETTLE seconds both displays are photographed.
Output: captures/<name>.jpg (tile: 2700 | 199 per point) and <name>.csv
(Riden readback). The numbers are read from the tile and fitted separately.

usage: cal_vs_ref.py NAME RANGE OVP_V SETTLE_S V1 V2 ...
       RANGE = ADC_RANGE_300m | ADC_RANGE_3 | ADC_RANGE_30 | ADC_RANGE_300
"""
import os, re, subprocess, sys, time, urllib.request
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import cv2, numpy as np
from rd6018 import RD6018

PROJ = os.path.dirname(HERE)
IPE = '/Applications/microchip/mplabx/v6.05/mplab_platform/mplab_ipe/bin/ipecmd.sh'
CAM = 'http://127.0.0.1:8199/snap.jpg?avg=3'
CROP_2700 = (395, 465, 560, 880)    # y0, y1, x0, x1 in the full camera frame
CROP_199 = (765, 885, 410, 1050)

name, rng, ovp, settle = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4])
pts = [float(a) for a in sys.argv[5:]]


def set_firmware(autorange, rng):
    p = f'{PROJ}/src/tasks/main.c'
    s = open(p).read()
    s, a = re.subn(r'(#define AUTORANGE\s+)\d', rf'\g<1>{autorange}', s)
    s, b = re.subn(r'(#define MEAS_RANGE\s+)ADC_RANGE_\w+', rf'\g<1>{rng}', s)
    assert a == 1 and b == 1
    open(p, 'w').write(s)
    r = subprocess.run(['make', '-f', 'nbproject/Makefile-default.mk', 'CONF=default', 'build'],
                       cwd=PROJ, capture_output=True, text=True)
    if r.returncode:
        sys.exit('BUILD FAILED\n' + r.stdout[-1500:])
    hexf = f'{PROJ}/dist/default/production/keithley_199-master.production.hex'
    for _ in range(4):
        r = subprocess.run(['perl', '-e', 'alarm 240; exec @ARGV', 'sh', IPE, '-P32MX350F256L', '-TPPK3',
                            f'-F{hexf}', '-M', '-Y', '-OL'], stdin=subprocess.DEVNULL, capture_output=True, text=True)
        if 'Verify Succeeded' in r.stdout:
            return
    sys.exit('FLASH FAILED')


def grab():
    b = urllib.request.urlopen(CAM, timeout=10).read()
    im = cv2.imdecode(np.frombuffer(b, np.uint8), 1)
    a = im[CROP_2700[0]:CROP_2700[1], CROP_2700[2]:CROP_2700[3]]
    k = cv2.resize(im[CROP_199[0]:CROP_199[1], CROP_199[2]:CROP_199[3]], None, fx=0.55, fy=0.55)
    h = max(a.shape[0], k.shape[0])
    a = cv2.copyMakeBorder(a, 0, h - a.shape[0], 0, 0, cv2.BORDER_CONSTANT)
    k = cv2.copyMakeBorder(k, 0, h - k.shape[0], 0, 0, cv2.BORDER_CONSTANT)
    return cv2.hconcat([a, k])


if __name__ == '__main__':
    if rng != 'none':
        set_firmware(0, rng)
        print('flashed', rng, flush=True)
    rd = RD6018()
    rows, lines = [], []
    try:
        rd._write_verified(82, round(ovp * 1000)); rd._write_verified(83, 200)
        rd.set_current(0.1); rd.set_voltage(pts[0]); rd.output(True)
        for v in pts:
            rd.set_voltage(v)
            time.sleep(settle)
            s = rd.status()
            if s['mode'] == 'CC' or s['protect'] != 'ok' or s['i_out'] > 0.005:
                raise SystemExit(f'ABORT at {v} V: {s}')
            im = grab()
            cv2.putText(im, f'{v:g}V', (3, 16), 0, 0.5, (0, 255, 255), 1)
            rows.append(im); lines.append(f'{v},{s["v_out"]:.3f}')
            print(f'{v:7.3f} V  RD {s["v_out"]:.3f}', flush=True)
    finally:
        rd.off(); print('output', 'ON' if rd.status()['output'] else 'off'); rd.close()
    cv2.imwrite(f'{HERE}/captures/{name}.jpg', cv2.vconcat(rows))
    open(f'{HERE}/captures/{name}.csv', 'w').write('set,rd\n' + '\n'.join(lines) + '\n')
