#!/usr/bin/env python3
"""Grab one frame from the webcam pointed at the Keithley 199 display.

Usage: snap.py [out.jpg] [--cam N] [--warmup FRAMES] [--avg N]

--avg N averages N frames, which smooths out the multiplexed display
(otherwise single frames may show half-lit digits).
"""
import argparse
import os
import sys
import time

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out", nargs="?", default=os.path.join(HERE, "captures", "k199.jpg"))
    ap.add_argument("--cam", type=int, default=0)
    ap.add_argument("--warmup", type=int, default=30, help="frames to let auto exposure settle")
    ap.add_argument("--avg", type=int, default=5)
    ap.add_argument("--width", type=int, default=1920)
    ap.add_argument("--height", type=int, default=1080)
    args = ap.parse_args()

    cap = cv2.VideoCapture(args.cam, cv2.CAP_AVFOUNDATION)
    if not cap.isOpened():
        sys.exit("camera not available (camera permission for the terminal app?)")
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)

    for _ in range(args.warmup):
        cap.read()
    frames = []
    for _ in range(max(1, args.avg)):
        ok, f = cap.read()
        if ok:
            frames.append(f.astype(np.float32))
        time.sleep(0.02)
    cap.release()
    if not frames:
        sys.exit("no frame captured")

    img = np.mean(frames, axis=0).astype(np.uint8)
    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    cv2.imwrite(args.out, img, [cv2.IMWRITE_JPEG_QUALITY, 90])
    print(f"saved {args.out} {img.shape[1]}x{img.shape[0]}")


if __name__ == "__main__":
    main()
