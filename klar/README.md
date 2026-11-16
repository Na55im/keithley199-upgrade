# KLAR – Oberfläche für das Keithley 199 (Upgrade-Platine)

**Starten:** `KLAR` im Programme-Ordner des Benutzers (`~/Applications/KLAR.app`),
per Doppelklick, Spotlight oder Dock. Die App startet den Server und öffnet
http://127.0.0.1:8210 im Browser. Beenden: im Dock „KLAR → Beenden“.

**Installieren / nach Änderungen neu bauen:**

    klar/make_app.sh

Das Skript baut das Frontend und kopiert Backend, Frontend und eine eigene
Python-Umgebung nach `~/Library/Application Support/KLAR` (der Schreibtisch ist
für Apps von macOS gesperrt). Aufnahmen (CSV), Einstellungen und `server.log`
liegen in `~/KLAR/`.

**Entwickeln ohne Gerät:**

    klar/.venv/bin/python klar/backend/server.py --sim      # Backend mit Simulator, Port 8210
    cd klar/frontend && npm run dev                          # Vite mit Proxy auf 8210

Im LAN (Tablet/Handy): `server.py --host 0.0.0.0`.

**Tests:** `klar/.venv/bin/python -m unittest discover klar/backend/tests`

Aufbau, Designregeln und Protokoll-Zuordnung: `klar/CLAUDE.md`.
Geräteprotokoll: `insturctions/remote-protocol.md`.
