#!/usr/bin/env python3
"""Normal-mode rejection (Brummunterdrückung) of the 199 DCV measurement.

Source: the Mac's headphone output plays a sine (exact frequency from the
audio clock). Wiring: tip (left) -> 199 VOLTS HI, sleeve -> LO, nothing else
on the input. The amplitude is measured with the 199's ACV function (not
calibrated: a few % uncertainty, i.e. < 0.5 dB). Then DCV readings (no filter)
show how much of the sine leaks into the DC result:

    NMRR = 20 log10( Vpeak(sine) / peak error of the DC readings )

The peak error is taken against a baseline measured with the tone off.
KLAR must not run (it holds the serial port).

    nmrr.py [FREQ ...]          default 50 49 51 45 55 60 100
"""
import math
import os
import statistics as S
import subprocess
import sys
import tempfile
import time
import wave

import numpy as np
import serial

PORT = '/dev/cu.usbserial-111110'
RATE = 48000


def make_wav(freq, seconds=40.0, amp=0.9):
    t = np.arange(int(RATE * seconds)) / RATE
    y = (amp * 32767 * np.sin(2 * math.pi * freq * t)).astype('<i2')
    fd, path = tempfile.mkstemp(suffix='_%gHz.wav' % freq)
    os.close(fd)
    with wave.open(path, 'wb') as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(np.repeat(y, 2).tobytes())
    return path


class K199:
    def __init__(self):
        self.s = serial.Serial(PORT, 115200, timeout=0.5)
        self.cmd('STREAM 0')

    def cmd(self, *cs, wait=0.3):
        for c in cs:
            self.s.write((c + '\n').encode())
            time.sleep(wait)
        self.s.reset_input_buffer()

    def readings(self, n, settle=2.0):
        self.cmd('STREAM 1')
        time.sleep(settle)
        self.s.reset_input_buffer()
        vals, t0 = [], time.time()
        while len(vals) < n and time.time() - t0 < 60:
            f = self.s.readline().decode('ascii', 'replace').strip().split(',')
            if f[0] == 'R' and len(f) == 8 and not int(f[6]) & 16:
                vals.append(float(f[3]))             # raw = single conversion
        self.cmd('STREAM 0')
        return vals

    def state(self):
        self.s.reset_input_buffer()
        self.s.write(b'STAT?\n')
        t0 = time.time()
        while time.time() - t0 < 3:
            line = self.s.readline().decode().strip()
            if line.startswith('S,'):
                return line.split(',')
        return None


def dc_range_index(vpk):
    for i, fs in enumerate([0.303, 3.03, 30.3]):
        if vpk < fs * 0.95:
            return i
    return 3


def main():
    freqs = [float(x) for x in sys.argv[1:]] or [50, 49, 51, 45, 55, 60, 100]
    k = K199()
    k.cmd('FILT 0', 'DIG 6', 'LINE 50', 'TRIG CONT', 'ZERO 0', 'HOLD 0', 'CHAN 0')
    rows = []
    try:
        # baseline per speed (tone off) on the DCV range used later
        k.cmd('FUNC ACV', 'RANG AUTO', 'SPEED LINE')
        play = subprocess.Popen(['afplay', make_wav(50, 25)])
        time.sleep(1)
        vrms0 = S.mean(k.readings(15, settle=4))
        play.wait()
        vpk0 = vrms0 * math.sqrt(2)
        ri = dc_range_index(vpk0)
        print('Amplitude bei 50 Hz: %.4f Vrms = %.4f Vpk -> DCV-Bereich %d' % (vrms0, vpk0, ri), flush=True)
        if vrms0 < 0.02:
            sys.exit('Kein Signal am Eingang (Lautstärke? Verdrahtung?)')
        base = {}
        for speed in ('LINE', 'FAST'):
            k.cmd('FUNC DCV', 'RANG %d' % ri, 'SPEED ' + speed)
            b = k.readings(60)
            base[speed] = (S.mean(b), S.stdev(b))
            print('Grundlinie %-4s ohne Ton: Mittel %+.2f µV, σ %.2f µV' % (speed, b and S.mean(b) * 1e6, S.stdev(b) * 1e6), flush=True)

        for f in freqs:
            wav = make_wav(f, 60)
            play = subprocess.Popen(['afplay', wav])
            time.sleep(1)
            k.cmd('FUNC ACV', 'RANG AUTO', 'SPEED LINE')
            vrms = S.mean(k.readings(12, settle=4))
            vpk = vrms * math.sqrt(2)
            for speed in ('LINE', 'FAST'):
                k.cmd('FUNC DCV', 'RANG %d' % ri, 'SPEED ' + speed)
                d = k.readings(80)
                m0, sd0 = base[speed]
                err = [x - m0 for x in d]
                pk = max(abs(e) for e in err)
                sd = S.stdev(err)
                nmrr_pk = 20 * math.log10(vpk / pk) if pk > 0 else float('inf')
                # noise-corrected rms leak (sine leak of an unsynchronised integration is ~ rms*sqrt2)
                leak_rms = math.sqrt(max(sd ** 2 - sd0 ** 2, 0.0))
                nmrr_rms = 20 * math.log10(vrms / leak_rms) if leak_rms > 0 else float('inf')
                rows.append((f, speed, vrms, pk, sd, nmrr_pk, nmrr_rms))
                print('%6.1f Hz %-4s  Ton %.4f Vrms | DC-Fehler Spitze %8.1f µV σ %7.1f µV | NMRR Spitze %5.1f dB, rms %5.1f dB' % (
                    f, speed, vrms, pk * 1e6, sd * 1e6, nmrr_pk, nmrr_rms), flush=True)
            play.terminate()
            os.unlink(wav)
    finally:
        subprocess.run(['pkill', '-f', 'afplay .*Hz.wav'])
        k.cmd('SPEED LINE', 'FUNC DCV', 'RANG AUTO', 'FILT 1', 'DIG 6', 'STREAM 0', 'LOCAL')


if __name__ == '__main__':
    main()
