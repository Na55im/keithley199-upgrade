#!/usr/bin/env python3
"""Keep the webcam on the Keithley 199 open and serve frames on localhost.

Run this in macOS Terminal.app (which can get camera permission), not from
Claude's shell. Then fetch a frame with:

  curl -s -o k199.jpg 'http://127.0.0.1:8199/snap.jpg?avg=5'

avg = number of frames averaged (smooths the multiplexed display).
"""
import argparse
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

import cv2
import numpy as np

lock = threading.Lock()
latest = []          # ring of recent frames
MAX_KEEP = 30


last_ok = [0.0]      # time of the newest frame
STALE_S = 2.0        # frames older than this are never served
REOPEN_S = 4.0       # no frame for this long -> reopen the camera


def open_cam(args):
    cap = cv2.VideoCapture(args.cam, cv2.CAP_AVFOUNDATION)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)
    return cap


def grabber(cap, args):
    """Read frames forever; reopen the camera when it stops delivering
    (e.g. after the USB hub dropped out) instead of serving old frames."""
    while True:
        ok, f = cap.read()
        if ok:
            with lock:
                latest.append(f)
                del latest[:-MAX_KEEP]
                last_ok[0] = time.time()
        else:
            time.sleep(0.05)
            if time.time() - last_ok[0] > REOPEN_S:
                print("no frames - reopening camera", flush=True)
                with lock:
                    latest.clear()
                cap.release()
                time.sleep(1)
                cap = open_cam(args)
                last_ok[0] = time.time()   # give the new capture time to start


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        u = urlparse(self.path)
        if u.path != "/snap.jpg":
            self.send_error(404)
            return
        avg = int(parse_qs(u.query).get("avg", ["5"])[0])
        avg = max(1, min(avg, MAX_KEEP))
        time.sleep(avg / 30)  # make sure frames are fresh, not from before the request
        with lock:
            fresh = time.time() - last_ok[0] < STALE_S
            frames = [f.astype(np.float32) for f in latest[-avg:]] if fresh else []
        if not frames:
            self.send_error(503, "no fresh frame")
            return
        img = np.mean(frames, axis=0).astype(np.uint8)
        ok, buf = cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 90])
        self.send_response(200)
        self.send_header("Content-Type", "image/jpeg")
        self.send_header("Content-Length", str(len(buf)))
        self.end_headers()
        self.wfile.write(buf.tobytes())

    def log_message(self, *a):
        pass


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cam", type=int, default=0)
    ap.add_argument("--port", type=int, default=8199)
    ap.add_argument("--width", type=int, default=1920)
    ap.add_argument("--height", type=int, default=1080)
    args = ap.parse_args()

    cap = cv2.VideoCapture(args.cam, cv2.CAP_AVFOUNDATION)
    for _ in range(20):          # first open may only trigger the permission prompt
        if cap.isOpened():
            break
        time.sleep(1)
        cap = cv2.VideoCapture(args.cam, cv2.CAP_AVFOUNDATION)
    if not cap.isOpened():
        raise SystemExit("camera not available - allow camera for Terminal in System Settings")
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)
    threading.Thread(target=grabber, args=(cap, args), daemon=True).start()
    print(f"camera {args.cam} open, serving http://127.0.0.1:{args.port}/snap.jpg  (Ctrl+C to stop)")
    ThreadingHTTPServer(("127.0.0.1", args.port), Handler).serve_forever()


if __name__ == "__main__":
    main()
