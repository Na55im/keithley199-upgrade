#!/bin/sh
# Builds KLAR and installs it as a Mac app:
#   ~/Applications/KLAR.app                      (double-click, Spotlight, Dock)
#   ~/Library/Application Support/KLAR/          (backend, frontend build, Python venv)
#   ~/KLAR/                                      (recordings as CSV, settings, server.log)
# The project lives on the Desktop, which macOS protects from apps; therefore
# the runtime is copied out. Run this script again after changes.
set -e
cd "$(dirname "$0")"
SRC="$(pwd)"
RT="$HOME/Library/Application Support/KLAR"
DATA="$HOME/KLAR"
APP="$HOME/Applications/KLAR.app"

(cd frontend && npm install --silent && npm run build >/dev/null)
mkdir -p "$RT" "$DATA" "$HOME/Applications"
rm -rf "$RT/backend" "$RT/frontend"
mkdir -p "$RT/frontend"
rsync -a --exclude __pycache__ --exclude tests backend "$RT/"
rsync -a frontend/dist "$RT/frontend/"
[ -x "$RT/.venv/bin/python" ] || python3 -m venv "$RT/.venv"
"$RT/.venv/bin/pip" install -q --disable-pip-version-check fastapi 'uvicorn[standard]' pyserial

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>KLAR</string>
  <key>CFBundleDisplayName</key><string>KLAR</string>
  <key>CFBundleIdentifier</key><string>local.klar.k199</string>
  <key>CFBundleVersion</key><string>0.1</string>
  <key>CFBundleShortVersionString</key><string>0.1</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>KLAR</string>
  <key>CFBundleIconFile</key><string>KLAR</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
</dict></plist>
PLIST
cat > "$APP/Contents/MacOS/KLAR" <<'SCRIPT'
#!/bin/sh
# KLAR launcher: start the backend if needed, open the browser, stop the
# backend when the app is quit.
RT="$HOME/Library/Application Support/KLAR"
export KLAR_DATA="$HOME/KLAR"
export KLAR_DIST="$RT/frontend/dist"
PORT=8210
URL="http://127.0.0.1:$PORT/"
mkdir -p "$KLAR_DATA"
if curl -s -m 1 "${URL}api/info" >/dev/null 2>&1; then open "$URL"; exit 0; fi
"$RT/.venv/bin/python" "$RT/backend/server.py" --port $PORT >> "$KLAR_DATA/server.log" 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null; exit 0' TERM INT HUP
for i in $(seq 1 50); do curl -s -m 1 "${URL}api/info" >/dev/null 2>&1 && break; sleep 0.2; done
open "$URL"
wait $PID
SCRIPT
chmod +x "$APP/Contents/MacOS/KLAR"

TMP="$(mktemp -d)"
qlmanage -t -s 1024 -o "$TMP" frontend/public/favicon.svg >/dev/null 2>&1 || true
if [ -f "$TMP/favicon.svg.png" ]; then
  mkdir -p "$TMP/KLAR.iconset"
  for s in 16 32 128 256 512; do
    sips -z $s $s "$TMP/favicon.svg.png" --out "$TMP/KLAR.iconset/icon_${s}x${s}.png" >/dev/null
    sips -z $((s*2)) $((s*2)) "$TMP/favicon.svg.png" --out "$TMP/KLAR.iconset/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$TMP/KLAR.iconset" -o "$APP/Contents/Resources/KLAR.icns"
fi
rm -rf "$TMP"
touch "$APP"
echo "installiert: $APP"
echo "Daten:       $DATA"
