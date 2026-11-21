#!/usr/bin/env python3
"""Measure the 199's CPU clock error against the Mac clock.

The device timestamps every reading with its FreeRTOS tick (derived from the
CPU clock); comparing the device time with the host time over a few minutes
gives the clock error in ppm (USB latency is removed by taking the minimum
offset at both ends).

    clockcheck.py [SECONDS] [--tune N ...]     e.g. clockcheck.py 120 --tune 0 -4 -8
KLAR must not be running (it holds the serial port).
"""
import sys
import time

import serial

PORT = '/dev/cu.usbserial-111110'


def measure(s, seconds):
    s.write(b'STREAM 1\n')
    time.sleep(1.5)
    s.reset_input_buffer()
    pts, end = [], time.time() + seconds
    while time.time() < end:
        line = s.readline()
        now = time.time()
        f = line.decode('ascii', 'replace').strip().split(',')
        if f[0] == 'R' and len(f) == 8:
            pts.append((now, int(f[1]) / 1000))
    a, b = pts[:150], pts[-150:]
    off_a = min(h - d for h, d in a)
    off_b = min(h - d for h, d in b)
    span = b[-1][1] - a[0][1]
    return -(off_b - off_a) / span * 1e6, len(pts)


def main():
    args = sys.argv[1:]
    seconds = float(args[0]) if args and not args[0].startswith('--') else 120
    tunes = [int(x) for x in args[args.index('--tune') + 1:]] if '--tune' in args else [None]
    s = serial.Serial(PORT, 115200, timeout=0.5)
    try:
        for t in tunes:
            if t is not None:
                s.write(b'OSCTUN %d\n' % t)
                time.sleep(1)
            ppm, n = measure(s, seconds)
            print('OSCTUN %-4s  clock error %+7.0f ppm  (%d readings)' % ('' if t is None else t, ppm, n), flush=True)
    finally:
        s.write(b'STREAM 0\nLOCAL\n')
        s.close()


if __name__ == '__main__':
    main()
