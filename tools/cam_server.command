#!/bin/zsh
# Double-click (opens in Terminal.app): webcam server for the K199 test loop.
cd "$(dirname "$0")"
exec ./.venv/bin/python cam_server.py "$@"
