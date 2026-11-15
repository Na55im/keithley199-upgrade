#!/usr/bin/env python3
"""Riden RD6018P control over USB (Modbus RTU) with hard safety limits.

Intended as the reference source for automated Keithley 199 tests.

Safety rules enforced here (not configurable from the command line):
  * set voltage / current limit can never exceed MAX_VOLTAGE / MAX_CURRENT
  * every write is read back and verified; mismatch -> output off + error
  * the output is only switched on if the setpoints currently stored in the
    device (which may have been changed on the front panel) are within limits
  * any error while the output is on -> output is switched off
  * unknown model id -> refuse to connect

To change the limits, edit the constants below deliberately.

Usage:
  rd6018.py status
  rd6018.py set --v 1.0 --i 0.1
  rd6018.py on | off
  rd6018.py watch [--interval 0.5]
"""

import argparse
import sys
import time

import minimalmodbus
from serial.tools import list_ports

# --------------------------------------------------------------------------
# HARD LIMITS - Keithley 199: 3 A current range, keep well below.
MAX_VOLTAGE = 60.0   # V  raised from 30 V on explicit user request (2026-11-15); RD6018P max ~59.62 V
MAX_CURRENT = 0.5    # A
# --------------------------------------------------------------------------

KNOWN_MODELS = {60185: "RD6018P", 60181: "RD6018"}

# Register map (RD60xx family)
REG_MODEL, REG_SN_H, REG_SN_L, REG_FW = 0, 1, 2, 3
REG_TEMP_SIGN, REG_TEMP = 4, 5
REG_V_SET, REG_I_SET = 8, 9
REG_V_OUT, REG_I_OUT = 10, 11
REG_P_OUT_H, REG_P_OUT_L = 12, 13
REG_V_IN = 14
REG_LOCK = 15
REG_PROTECT = 16    # 0 ok, 1 OVP, 2 OCP
REG_CV_CC = 17      # 0 CV, 1 CC
REG_OUTPUT = 18

# Scaling, checked against the RD6018P front panel (fw 1.48):
#   set/out voltage /1000: raw 100 -> panel 0.100 V (fits OVP 62000 = 62 V)
#   set/out current /1000: raw 10  -> panel 0.010 A (fits OCP 18200 = 18.2 A)
#   input voltage   /100 : raw 6054 -> 60.54 V on a 60 V supply
V_SCALE = 1000
I_SCALE = 1000
V_IN_SCALE = 100

CH340_VID, CH340_PID = 0x1A86, 0x7523


class LimitError(ValueError):
    pass


def find_port():
    ports = [p.device for p in list_ports.comports()
             if p.vid == CH340_VID and p.pid == CH340_PID]
    ports = [p for p in ports if "/cu." in p] or ports
    if len(ports) != 1:
        raise RuntimeError(f"expected exactly one CH340 port, found {ports}; use --port")
    return ports[0]


class RD6018:
    def __init__(self, port=None, address=1, baudrate=115200):
        self.dev = minimalmodbus.Instrument(port or find_port(), address)
        self.dev.serial.baudrate = baudrate
        self.dev.serial.timeout = 0.5
        self.dev.clear_buffers_before_each_transaction = True
        model = self._read(REG_MODEL)
        if model not in KNOWN_MODELS:
            self.dev.serial.close()
            raise RuntimeError(f"unknown model id {model}, refusing to continue")
        self.model = KNOWN_MODELS[model]

    # -- low level ---------------------------------------------------------
    def _read(self, reg, n=1):
        for attempt in range(3):
            try:
                return (self.dev.read_register(reg) if n == 1
                        else self.dev.read_registers(reg, n))
            except (minimalmodbus.ModbusException, OSError):
                if attempt == 2:
                    raise
                time.sleep(0.05)

    def _write_verified(self, reg, value):
        self.dev.write_register(reg, value)
        back = self._read(reg)
        if back != value:
            self._emergency_off()
            raise RuntimeError(f"register {reg}: wrote {value}, read back {back}; output switched off")

    def _emergency_off(self):
        try:
            self.dev.write_register(REG_OUTPUT, 0)
        except Exception:
            pass

    # -- checks --------------------------------------------------------------
    @staticmethod
    def check_voltage(v):
        if not (0.0 <= v <= MAX_VOLTAGE):
            raise LimitError(f"voltage {v} V outside 0..{MAX_VOLTAGE} V")

    @staticmethod
    def check_current(i):
        if not (0.0 <= i <= MAX_CURRENT):
            raise LimitError(f"current {i} A outside 0..{MAX_CURRENT} A")

    # -- API -----------------------------------------------------------------
    def status(self):
        r = self._read(0, 19)
        return {
            "model": self.model,
            "serial": (r[REG_SN_H] << 16) | r[REG_SN_L],
            "firmware": r[REG_FW] / 100,
            "temp_c": -r[REG_TEMP] if r[REG_TEMP_SIGN] else r[REG_TEMP],
            "v_set": r[REG_V_SET] / V_SCALE,
            "i_set": r[REG_I_SET] / I_SCALE,
            "v_out": r[REG_V_OUT] / V_SCALE,
            "i_out": r[REG_I_OUT] / I_SCALE,
            "v_in": r[REG_V_IN] / V_IN_SCALE,
            "protect": {0: "ok", 1: "OVP", 2: "OCP"}.get(r[REG_PROTECT], r[REG_PROTECT]),
            "mode": "CC" if r[REG_CV_CC] else "CV",
            "output": bool(r[REG_OUTPUT]),
            "keys_locked": bool(r[REG_LOCK]),
        }

    def set_voltage(self, v):
        self.check_voltage(v)
        self._write_verified(REG_V_SET, round(v * V_SCALE))

    def set_current(self, i):
        self.check_current(i)
        self._write_verified(REG_I_SET, round(i * I_SCALE))

    def output(self, on):
        if not on:
            self._write_verified(REG_OUTPUT, 0)
            return
        # Front panel may have changed setpoints: re-check what is in the device.
        v_set = self._read(REG_V_SET) / V_SCALE
        i_set = self._read(REG_I_SET) / I_SCALE
        self.check_voltage(v_set)
        self.check_current(i_set)
        self._write_verified(REG_OUTPUT, 1)

    def off(self):
        self.output(False)

    def measure(self):
        v, i = self._read(REG_V_OUT, 2)
        return v / V_SCALE, i / I_SCALE

    def close(self):
        self.dev.serial.close()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--port", help="serial port (default: auto-detect CH340)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    p = sub.add_parser("set")
    p.add_argument("--v", type=float, help="voltage setpoint [V]")
    p.add_argument("--i", type=float, help="current limit [A]")
    sub.add_parser("on")
    sub.add_parser("off")
    w = sub.add_parser("watch")
    w.add_argument("--interval", type=float, default=0.5)
    args = ap.parse_args()

    rd = RD6018(args.port)
    try:
        if args.cmd == "status":
            for k, v in rd.status().items():
                print(f"{k:12} {v}")
        elif args.cmd == "set":
            if args.v is None and args.i is None:
                ap.error("set needs --v and/or --i")
            # validate both before writing either
            if args.v is not None:
                rd.check_voltage(args.v)
            if args.i is not None:
                rd.check_current(args.i)
            if args.i is not None:
                rd.set_current(args.i)
            if args.v is not None:
                rd.set_voltage(args.v)
            s = rd.status()
            print(f"v_set {s['v_set']} V  i_set {s['i_set']} A  output {'ON' if s['output'] else 'off'}")
        elif args.cmd == "on":
            rd.output(True)
            print("output ON")
        elif args.cmd == "off":
            rd.off()
            print("output off")
        elif args.cmd == "watch":
            while True:
                v, i = rd.measure()
                print(f"{time.strftime('%H:%M:%S')}  {v:7.2f} V  {i:6.2f} A", flush=True)
                time.sleep(args.interval)
    except LimitError as e:
        print(f"LIMIT: {e}", file=sys.stderr)
        sys.exit(2)
    except KeyboardInterrupt:
        pass
    except Exception:
        if args.cmd in ("on", "set", "watch"):
            rd._emergency_off()
        raise
    finally:
        rd.close()


if __name__ == "__main__":
    main()
