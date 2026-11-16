import { useEffect, useState } from 'react';
import { api, useStore } from '../store';
import { stFmt, fmtReading } from '../format';
import { IconCheck } from '../components/Icons';

/** Dialog "Gerät gefunden" (Connect.reference.html), adapted to the serial link. */
export function Connect({ onClose }: { onClose: () => void }) {
  const { info } = useStore();
  const [advanced, setAdvanced] = useState(false);
  const [ports, setPorts] = useState<string[]>([]);
  const [port, setPort] = useState(info.settings?.port ?? 'auto');
  useEffect(() => { api('/ports').then((p) => setPorts(p.ports)); }, [advanced]);

  const st = info.state, last = info.last, f = stFmt(st);
  const ok = info.status === 'connected';
  const test = last && !(last.flags & 16) ? fmtReading(last.v, f, st?.func.startsWith('DC') ?? true) + ' ' + f.unit : null;
  const step = ok ? 2 : 1;

  return (
    <div className="overlay" role="dialog" aria-modal="true" aria-labelledby="connect-title">
      <div className="dialog">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          <span className="eyebrow">Schritt {step} von 3</span>
          <h1 id="connect-title">{ok ? 'Gerät gefunden' : info.status === 'searching' ? 'Suche Gerät …' : 'Kein Gerät gefunden'}</h1>
          <span style={{ color: 'var(--text-2)', fontSize: 14, lineHeight: 1.5 }}>
            {ok ? 'KLAR hat die seriellen USB-Anschlüsse durchsucht und das Keithley 199 an seiner Antwort erkannt.'
              : 'KLAR fragt alle seriellen USB-Anschlüsse mit „*IDN?“ ab. Wandler an P8/P9 und USB-Kabel prüfen.'}
          </span>
        </div>
        {ok ? (
          <div className="devtile">
            <div className="devtile-logo">199</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4, minWidth: 0, marginRight: 'auto' }}>
              <span style={{ fontWeight: 600, fontSize: 15 }}>Keithley 199 System DMM/Scanner</span>
              <span style={{ fontSize: 12, color: 'var(--text-muted)' }}>Upgrade-Platine · erkannt an Antwort „KEITHLEY,199-UPGRADE“</span>
            </div>
            <span className="tag ok">bereit</span>
          </div>
        ) : (
          <div style={{ display: 'flex', justifyContent: 'center', padding: 12 }}>
            {info.status === 'searching' || info.status === 'offline' ? <div className="spinner" aria-label="Suche läuft" /> : <span className="tag warn">nicht gefunden</span>}
          </div>
        )}
        <dl className="kv">
          <dt>Anschluss</dt><dd>{info.port || '–'}</dd>
          <dt>Kennung</dt><dd>{info.idn || '–'}</dd>
          <dt>Testmessung</dt>
          <dd style={{ display: 'flex', alignItems: 'center', gap: 6 }}>{test ?? '–'}{test && <span style={{ color: 'var(--accent)' }}><IconCheck /></span>}</dd>
        </dl>
        <details open={advanced} onToggle={(e) => setAdvanced((e.target as HTMLDetailsElement).open)}>
          <summary style={{ cursor: 'pointer', fontSize: 13, color: 'var(--text-2)', minHeight: 32 }}>Erweitert: Anschluss manuell wählen</summary>
          <div style={{ display: 'flex', gap: 8, marginTop: 10, flexWrap: 'wrap', alignItems: 'flex-end' }}>
            <label className="field" style={{ flex: 1 }}>Anschluss
              <select value={port} onChange={(e) => setPort(e.target.value)}>
                <option value="auto">Automatisch suchen</option>
                {ports.map((p) => <option key={p} value={p}>{p}</option>)}
                <option value="sim">Simulator (ohne Gerät)</option>
              </select>
            </label>
            <button type="button" className="btn small" onClick={() => api('/settings', 'POST', { port })}>Übernehmen</button>
          </div>
        </details>
        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', flexWrap: 'wrap' }}>
          <button type="button" className="btn" onClick={() => api('/reconnect', 'POST')}>Erneut suchen</button>
          <button type="button" className="btn primary" onClick={onClose}>{ok ? 'Verbinden & messen' : 'Schließen'}</button>
        </div>
      </div>
    </div>
  );
}
