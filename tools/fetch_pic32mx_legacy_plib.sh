#!/usr/bin/env bash
# Re-download chipKIT-derived legacy PLIB headers + libmchp_peripheral (default: PIC32MX350F256L).
# Override part: PIC32_MX_PART=32MX350F128L ./tools/fetch_pic32mx_legacy_plib.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="https://raw.githubusercontent.com/biomurph/chipKIT-core-prebuilt/master/windows/chipkit-core/pic32/compiler/pic32-tools/pic32mx"
PIC32_MX_PART="${PIC32_MX_PART:-32MX350F256L}"
INC="$ROOT/third_party/pic32mx-legacy-plib/include"
LIB="$ROOT/third_party/pic32mx-legacy-plib/lib"
mkdir -p "$INC/peripheral/legacy" "$LIB"
curl -fsSL --retry 3 --retry-delay 2 -o "$INC/plib.h" "$BASE/include/plib.h"
curl -fsSL --retry 3 --retry-delay 2 -o "$INC/GenericTypeDefs.h" "$BASE/include/GenericTypeDefs.h"
curl -fsSL --retry 3 --retry-delay 2 -o "$LIB/libmchp_peripheral_${PIC32_MX_PART}.a" "$BASE/lib/libmchp_peripheral_${PIC32_MX_PART}.a"
export PIC32_PLIB_ROOT="$INC"
python3 - <<'PY'
import json, os, pathlib, urllib.request
inc = pathlib.Path(os.environ["PIC32_PLIB_ROOT"])
peri = inc / "peripheral"
leg = peri / "legacy"

def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "keithley199-fetch"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return r.read()

def sync(api_url: str, dest: pathlib.Path) -> None:
    data = json.loads(fetch(api_url).decode())
    for ent in data:
        if ent.get("type") != "file" or not ent.get("download_url"):
            continue
        p = dest / ent["name"]
        p.write_bytes(fetch(ent["download_url"]))
        print(p, p.stat().st_size)

sync(
    "https://api.github.com/repos/biomurph/chipKIT-core-prebuilt/contents/windows/chipkit-core/pic32/compiler/pic32-tools/pic32mx/include/peripheral?ref=master",
    peri,
)
sync(
    "https://api.github.com/repos/biomurph/chipKIT-core-prebuilt/contents/windows/chipkit-core/pic32/compiler/pic32-tools/pic32mx/include/peripheral/legacy?ref=master",
    leg,
)
PY
echo "Done. Re-apply header patches in-repo (extern inline / extern __inline__) if upstream changes."
