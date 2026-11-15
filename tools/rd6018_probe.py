#!/usr/bin/env python3
"""Rein lesender Verbindungstest fuer Riden RD6018(P) per Modbus-RTU (USB-Seriell).
Sendet NUR Funktionscode 0x03 (Register lesen). Schaltet nichts, setzt nichts.
Aufruf:  python3 tools/rd6018_probe.py            (alle Ports durchprobieren)
         python3 tools/rd6018_probe.py /dev/cu.usbserial-XXXX
Ergebnis:  tools/rd6018_probe_result.json  (wird auch auf dem Bildschirm gezeigt)
"""
import glob, json, struct, sys, time, os
try:
    import serial
except ImportError:
    sys.exit("pyserial fehlt:  python3 -m pip install pyserial")

def crc16(b):
    c = 0xFFFF
    for x in b:
        c ^= x
        for _ in range(8):
            c = (c >> 1) ^ 0xA001 if c & 1 else c >> 1
    return struct.pack("<H", c)

def read_regs(ser, addr, start, count):
    req = struct.pack(">BBHH", addr, 0x03, start, count)
    ser.reset_input_buffer()
    ser.write(req + crc16(req))
    exp = 5 + 2 * count
    resp = ser.read(exp)
    if len(resp) != exp or resp[0] != addr or resp[1] != 0x03:
        return None
    if crc16(resp[:-2]) != resp[-2:]:
        return None
    return list(struct.unpack(">" + "H" * count, resp[3:-2]))

def probe(port, baud):
    try:
        ser = serial.Serial(port, baud, timeout=0.5)
    except Exception as e:
        return {"error": str(e)}
    try:
        for addr in (1, 2, 3):
            r = read_regs(ser, addr, 0, 4)
            if r:
                model, ser_hi, ser_lo, fw = r
                info = {"port": port, "baud": baud, "slave": addr,
                        "model_id": model, "serial": (ser_hi << 16) | ser_lo,
                        "firmware_raw": fw}
                live = read_regs(ser, addr, 8, 11)  # 8..18
                if live:
                    info["raw_regs_8_18"] = live
                    info["v_set_raw"], info["i_set_raw"] = live[0], live[1]
                    info["v_out_raw"], info["i_out_raw"] = live[2], live[3]
                    info["output_on_raw"] = live[10]
                return info
        return None
    finally:
        ser.close()

ports = sys.argv[1:] or sorted(set(
    glob.glob("/dev/cu.usbserial*") + glob.glob("/dev/cu.wchusbserial*") +
    glob.glob("/dev/cu.usbmodem*") + glob.glob("/dev/cu.SLAB*")))
out = {"time": time.strftime("%Y-%m-%d %H:%M:%S"), "ports_found": ports, "result": None, "tried": []}
for p in ports:
    for baud in (115200, 9600, 19200, 38400, 57600):
        r = probe(p, baud)
        out["tried"].append({"port": p, "baud": baud, "ok": bool(r and "model_id" in r)})
        if r and "model_id" in r:
            out["result"] = r
            break
    if out["result"]:
        break
if not ports:
    out["hinweis"] = "Kein USB-Seriell-Port gefunden. Kabel/Treiber (CH340/CP210x) pruefen."
elif not out["result"]:
    out["hinweis"] = "Port da, aber keine Modbus-Antwort. Am RD6018P: Einstellungen > Comm auf 'USB' (nicht WiFi) und Baudrate pruefen."
path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rd6018_probe_result.json")
json.dump(out, open(path, "w"), indent=2)
print(json.dumps(out, indent=2))
