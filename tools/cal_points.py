#!/usr/bin/env python3
"""Step the RD6018P through calibration points and photograph the K199 display.
usage: cal_points.py NAME OVP_V V1 V2 ...   -> captures/NAME.jpg + captures/NAME.csv (RD readback)
"""
import os, sys, time, urllib.request
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cv2, numpy as np
from rd6018 import RD6018

TOOLS = os.path.dirname(os.path.abspath(__file__))
name, ovp = sys.argv[1], float(sys.argv[2])
pts = [float(a) for a in sys.argv[3:]]
rd = RD6018(); rows = []; lines = []
try:
    rd._write_verified(82, round(ovp * 1000)); rd._write_verified(83, 200)
    rd.set_current(0.1); rd.set_voltage(0.0); rd.output(True); time.sleep(3)
    for v in pts:
        rd.set_voltage(v); time.sleep(3)          # settle + at least 2 readings
        m1 = rd.measure()[0]
        b = urllib.request.urlopen('http://127.0.0.1:8199/snap.jpg?avg=3', timeout=10).read()
        m2 = rd.measure()[0]
        m = (m1 + m2) / 2
        im = cv2.imdecode(np.frombuffer(b, np.uint8), 1)[460:700, 100:1340]
        im = cv2.resize(im, None, fx=0.5, fy=0.5)
        cv2.putText(im, f"RD {m:.3f}", (5, 25), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 255), 2)
        rows.append(im); lines.append(f"{v},{m:.4f}")
        print(f"soll {v:7.3f}  RD {m1:.3f}/{m2:.3f}", flush=True)
finally:
    rd.off(); print("output", "ON" if rd.status()["output"] else "off"); rd.close()
half = (len(rows) + 1) // 2
left, right = rows[:half], rows[half:]
right += [np.zeros_like(rows[0])] * (half - len(right))
cv2.imwrite(f'{TOOLS}/captures/{name}.jpg', cv2.hconcat([cv2.vconcat(left), cv2.vconcat(right)]))
open(f'{TOOLS}/captures/{name}.csv', 'w').write("set,rd\n" + "\n".join(lines) + "\n")
