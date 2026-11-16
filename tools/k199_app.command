#!/bin/sh
# Double-click: start the Keithley 199 panel (http://127.0.0.1:8200)
cd "$(dirname "$0")"
exec /Users/nagre/Downloads/keithley_199/tools/.venv/bin/python k199_app.py "$@"
