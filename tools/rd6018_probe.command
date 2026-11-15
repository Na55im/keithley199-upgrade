#!/bin/bash
cd "$(dirname "$0")/.."
python3 -c "import serial" 2>/dev/null || python3 -m pip install --user pyserial
python3 tools/rd6018_probe.py
echo; read -n 1 -s -r -p "Fertig. Beliebige Taste zum Schliessen."
