import { useEffect, useRef, useState } from 'react';
import { api, log, send, useStore, type RecInfo } from '../store';
import { funcInfo, fmtCount, fmtDuration, fmtTime } from '../format';

function Head({ eyebrow, title, children }: { eyebrow: string; title: string; children?: React.ReactNode }) {
  return (
    <header className="page-head">
      <div className="page-title"><span className="eyebrow">{eyebrow}</span><h1>{title}</h1></div>
      {children}
    </header>
  );
}

function Toggle({ on, label, onChange, disabled }: { on: boolean; label: string; onChange: (v: boolean) => void; disabled?: boolean }) {
  return <button type="button" role="switch" aria-checked={on} aria-label={label} className="toggle" disabled={disabled} onClick={() => onChange(!on)} />;
}

/* ------------------------------------------------------------------ Logger */
export function Logger({ now, openAnalyse }: { now: number; openAnalyse: () => void }) {
  const { info } = useStore();
  const [recs, setRecs] = useState<RecInfo[]>([]);
  useEffect(() => { api('/recordings').then((r: RecInfo[]) => setRecs(r.filter((x) => x.id !== 'live'))); }, [info.recording?.id, info.recording?.points]);
  const rec = info.recording;
  return (
    <>
      <Head eyebrow={info.settings?.workplace ?? ''} title="Logger">
        <button type="button" className="btn primary" disabled={info.status !== 'connected' && !rec}
          onClick={() => api('/record/' + (rec ? 'stop' : 'start'), 'POST')}>{rec ? 'Aufnahme stoppen' : 'Aufnahme starten'}</button>
      </Head>
      {rec && (
        <section className="dark-card">
          <span className="stat-label">Aufnahme läuft · {funcInfo(rec.func ?? 'DCV').label}</span>
          <span className="big-stat">{fmtDuration(now - (rec.start ?? now))}</span>
          <span className="stat-label">{fmtCount(rec.points)} Punkte · Datei {rec.file}</span>
        </section>
      )}
      <section className="card">
        <h2>Aufnahmen dieser Sitzung</h2>
        <div className="list">
          {recs.length === 0 && <span className="eyebrow">Noch keine Aufnahme. Jede Aufnahme wird sofort als CSV gespeichert (Semikolon, Dezimalpunkt).</span>}
          {recs.map((r) => (
            <div key={r.id} className="list-item">
              <div className="list-main">
                <span style={{ fontWeight: 600 }}>{new Date((r.start ?? 0) * 1000).toLocaleDateString('de-DE')} {fmtTime(r.start ?? 0, false)}
                  {r.stop ? ' – ' + fmtTime(r.stop, false) : ' – läuft'} · {funcInfo(r.func ?? 'DCV').label}</span>
                <span className="list-sub">{fmtCount(r.points)} Punkte · {r.channels.filter((c) => c).length ? 'Kanäle ' + r.channels.join(', ') + ' · ' : ''}{r.file}</span>
              </div>
              <button type="button" className="btn small" onClick={openAnalyse}>Analyse</button>
              <a className="btn small" style={{ display: 'flex', alignItems: 'center', textDecoration: 'none' }} href={`/api/recordings/${r.id}/csv`}>CSV</a>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}

/* ------------------------------------------------------------------ Scanner */
export function Scanner() {
  const { info } = useStore();
  const st = info.state;
  const connected = info.status === 'connected';
  const names = info.settings?.channel_names ?? {};
  const [pick, setPick] = useState<Set<number>>(new Set(st?.scan_list ?? []));
  const [nameEdit, setNameEdit] = useState<Record<string, string>>(names);
  useEffect(() => { setNameEdit(names); }, [JSON.stringify(names)]);
  const scanning = !!st?.scan;
  const startScan = () => send('SCAN ' + [...pick].sort().join(','));
  return (
    <>
      <Head eyebrow="Scannerkarte" title="Scanner-Kanäle">
        {scanning
          ? <button type="button" className="btn primary" onClick={() => send('SCAN 0')}>Scan beenden</button>
          : <button type="button" className="btn primary" disabled={!connected || pick.size === 0} onClick={startScan}>Scan starten</button>}
      </Head>
      <section className="card">
        <h2>Kanäle</h2>
        <span className="eyebrow">Ausgewählte Kanäle werden reihum gemessen. Mit Filter (Modus „Präzise“) kommt pro Kanal erst nach 100 Wandlungen ein Wert, ohne Filter jede Wandlung. Name und Auswahl bleiben gespeichert.</span>
        <div className="list">
          {[1, 2, 3, 4, 5, 6, 7, 8].map((c) => (
            <div key={c} className="list-item">
              <label className="check" style={{ minWidth: 110 }}>
                <input type="checkbox" checked={pick.has(c)} disabled={scanning}
                  onChange={() => { const p = new Set(pick); if (p.has(c)) p.delete(c); else p.add(c); setPick(p); }} />Kanal {c}</label>
              <input className="input" style={{ flex: 1 }} aria-label={`Name Kanal ${c}`} placeholder="nicht belegt" value={nameEdit[String(c)] ?? ''}
                onChange={(e) => setNameEdit({ ...nameEdit, [String(c)]: e.target.value })}
                onBlur={() => api('/settings', 'POST', { channel_names: nameEdit })} />
              {st?.chan === c && <span className="tag ok">aktiv</span>}
              <button type="button" className="btn small" disabled={!connected} onClick={() => send('CHAN ' + c)}>Nur dieser</button>
            </div>
          ))}
        </div>
        <div><button type="button" className="btn small" disabled={!connected} onClick={() => send('CHAN 0')}>Kein Kanal (Eingang vorne)</button></div>
      </section>
    </>
  );
}

/* ------------------------------------------------------------------ Settings */
export function Settings({ openConnect }: { openConnect: () => void }) {
  const { info, logVersion } = useStore();
  const st = info.state, s = info.settings;
  const connected = info.status === 'connected';
  const [cmd, setCmd] = useState('');
  const box = useRef<HTMLDivElement>(null);
  useEffect(() => { box.current?.scrollTo(0, box.current.scrollHeight); }, [logVersion]);
  const setTheme = (t: 'light' | 'dark') => api('/settings', 'POST', { theme: t });
  return (
    <>
      <Head eyebrow={s?.workplace ?? ''} title="Einstellungen" />
      <div className="row">
        <div className="side" style={{ flexBasis: 420 }}>
          <section className="card">
            <h2>Verbindung</h2>
            <dl className="kv"><dt>Anschluss</dt><dd>{info.port || '–'}</dd><dt>Status</dt><dd>{
              { connected: 'verbunden', searching: 'sucht …', disconnected: 'getrennt', offline: 'Programm nicht erreichbar' }[info.status]}</dd></dl>
            <div><button type="button" className="btn small" onClick={openConnect}>Verbindung prüfen / ändern</button></div>
          </section>
          <section className="card">
            <h2>Messung</h2>
            <div className="list">
              <div className="list-item"><div className="list-main"><span>Netzfrequenz</span><span className="list-sub">Integrationszeit eine Netzperiode (Brummunterdrückung)</span></div>
                <div className="seg">{[50, 60].map((hz) => <button key={hz} type="button" aria-pressed={st?.line === hz} disabled={!connected} onClick={() => send('LINE ' + hz)}>{hz} Hz</button>)}</div></div>
              <div className="list-item"><div className="list-main"><span>Integration</span><span className="list-sub">Schnell = ¼ Netzperiode, ca. 21 Messungen/s</span></div>
                <div className="seg">{(['FAST', 'LINE'] as const).map((sp) => <button key={sp} type="button" aria-pressed={st?.speed === sp} disabled={!connected} onClick={() => send('SPEED ' + sp)}>{sp === 'FAST' ? 'Schnell' : 'Netzperiode'}</button>)}</div></div>
              <div className="list-item"><div className="list-main"><span>Filter</span><span className="list-sub">Gleitender Mittelwert über 100 Wandlungen</span></div>
                <Toggle on={!!st?.filter} label="Filter" disabled={!connected} onChange={(v) => send('FILT ' + (v ? 1 : 0))} /></div>
              <div className="list-item"><div className="list-main"><span>Stellen</span></div>
                <div className="seg">{[4, 5, 6].map((d) => <button key={d} type="button" aria-pressed={st?.digits === d} disabled={!connected} onClick={() => send('DIG ' + d)}>{d}½</button>)}</div></div>
              <div className="list-item"><div className="list-main"><span>Trigger</span></div>
                <div className="seg">
                  <button type="button" aria-pressed={st?.trig === 'CONT'} disabled={!connected} onClick={() => send('TRIG CONT')}>Dauernd</button>
                  <button type="button" aria-pressed={st?.trig === 'ONE'} disabled={!connected} onClick={() => send('TRIG ONE')}>Einzeln</button>
                </div>
                <button type="button" className="btn small" disabled={!connected || st?.trig !== 'ONE'} onClick={() => send('*TRG')}>Auslösen</button></div>
              <div className="list-item"><div className="list-main"><span>Frontpanel sperren</span><span className="list-sub">Tasten am Keithley sind während der Fernsteuerung gesperrt</span></div>
                <Toggle on={!!st?.lock} label="Frontpanel sperren" disabled={!connected} onChange={(v) => send('LOCK ' + (v ? 1 : 0))} /></div>
            </div>
          </section>
          <section className="card">
            <h2>Anzeige</h2>
            <div className="list">
              <div className="list-item"><div className="list-main"><span>Darstellung</span></div>
                <div className="seg"><button type="button" aria-pressed={s?.theme !== 'dark'} onClick={() => setTheme('light')}>Hell</button>
                  <button type="button" aria-pressed={s?.theme === 'dark'} onClick={() => setTheme('dark')}>Dunkel</button></div></div>
              <div className="list-item"><label className="field" style={{ flex: 1 }}>Name des Arbeitsplatzes
                <input defaultValue={s?.workplace} onBlur={(e) => api('/settings', 'POST', { workplace: e.target.value })} /></label></div>
            </div>
          </section>
        </div>
        <div className="side" style={{ flexBasis: 420 }}>
          <section className="card">
            <h2>Kalibrierung</h2>
            <span style={{ fontSize: 14, color: 'var(--text-2)', lineHeight: 1.5 }}>
              Die Kalibrierung liegt als Konstanten in der Firmware (DCV und DCA gegen Keithley 2700, Stand 16.11.2026).
              Sie wird von KLAR nur angezeigt, nie geschrieben. Die Kalibrierdaten im Analogteil (EEPROM) bleiben unberührt.</span>
          </section>
          <section className="card">
            <h2>Über</h2>
            <dl className="kv"><dt>Gerät</dt><dd>Keithley 199 · Upgrade-Platine</dd><dt>Firmware</dt><dd>{info.build || '–'}</dd>
              <dt>Integration</dt><dd>{st ? `${st.int_us / 1000} ms` : '–'}</dd><dt>Software</dt><dd>KLAR 0.1</dd></dl>
          </section>
          <section className="card">
            <h2>Befehle</h2>
            <div className="console" ref={box}>
              {log.map((l, i) => <div key={i} className={l.dir === 'tx' ? 'tx' : l.line.startsWith('ERR') ? 'err' : ''}>{l.dir === 'tx' ? '> ' : ''}{l.line}</div>)}
            </div>
            <form style={{ display: 'flex', gap: 8 }} onSubmit={(e) => { e.preventDefault(); if (cmd.trim()) send(cmd.trim()); setCmd(''); }}>
              <input className="input mono" style={{ flex: 1 }} aria-label="Befehl" placeholder="z. B. STAT? oder FUNC DCA" value={cmd} onChange={(e) => setCmd(e.target.value)} />
              <button className="btn small" disabled={!connected}>Senden</button>
            </form>
          </section>
        </div>
      </div>
    </>
  );
}

/* ------------------------------------------------------------------ Notices */
export function Notices() {
  const { info } = useStore();
  const list = [...info.notices].reverse();
  return (
    <>
      <Head eyebrow="Meldungen dieser Sitzung" title="Hinweise">
        <button type="button" className="btn" disabled={!list.length} onClick={() => api('/notices', 'DELETE')}>Alle löschen</button>
      </Head>
      <section className="card">
        <div className="list">
          {list.length === 0 && <span className="eyebrow">Keine Hinweise.</span>}
          {list.map((n) => (
            <div key={n.id} className="list-item">
              <span className={'dot ' + (n.level === 'warn' ? 'warn' : 'ok')} />
              <div className="list-main"><span>{n.text}</span><span className="list-sub">{fmtTime(n.t)}</span></div>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}
