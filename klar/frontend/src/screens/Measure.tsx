import { useMemo, useState } from 'react';
import type uPlot from 'uplot';
import { api, live, send, useStore, F_HOLD, F_OVERFLOW, F_SETTLED } from '../store';
import { FUNCS, MODES, funcInfo, stFmt, fmtReading, fmtVal, fmtEng, fmtDuration, fmtCount } from '../format';
import { Chart, axisStyle, cssVar, timeGaps } from '../components/Chart';

const WINDOWS = [{ s: 60, label: '1 min' }, { s: 300, label: '5 min' }, { s: 3600, label: '1 h' }, { s: 0, label: 'Alles' }];

export function Measure({ now }: { now: number }) {
  const { info, rate, liveVersion } = useStore();
  const st = info.state;
  const f = stFmt(st);
  const fi = funcInfo(st?.func ?? 'DCV');
  const connected = info.status === 'connected';
  const [win, setWin] = useState(300);
  const [held, setHeld] = useState<number | null>(null);
  const rec = info.recording;

  // window of the live buffer
  const view = useMemo(() => {
    const n = live.t.length;
    let i0 = 0;
    if (win && n) { const t0 = live.t[n - 1] - win; while (i0 < n && live.t[i0] < t0) i0++; }
    return { t: live.t.slice(i0), v: live.v.slice(i0) };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [liveVersion, win]);

  const stats = useMemo(() => {
    const v = view.v;
    if (!v.length) return null;
    let mn = Infinity, mx = -Infinity, s = 0;
    for (const x of v) { if (x < mn) mn = x; if (x > mx) mx = x; s += x; }
    const mean = s / v.length;
    let q = 0; for (const x of v) q += (x - mean) ** 2;
    return { min: mn, max: mx, mean, sd: v.length > 1 ? Math.sqrt(q / (v.length - 1)) : 0, n: v.length };
  }, [view]);

  const last = info.last;
  const hold = !!st?.hold;
  const shown = hold ? held : last && !(last.flags & F_OVERFLOW) ? last.v : null;
  const overflow = !hold && last && (last.flags & F_OVERFLOW);
  const stale = !last || now - last.t > 3;
  const dbOn = !!(st?.db && st.func.startsWith('AC'));

  let readingText = fmtReading(shown, f, st?.func.startsWith('DC') ?? true);
  let unitText = f.unit;
  if (overflow) { readingText = (last!.v < 0 ? '−' : '') + 'OVERFLOW'; unitText = ''; }
  else if (dbOn && shown !== null) {
    const ref = st!.func === 'ACA' ? 1e-3 : 1;
    readingText = Math.abs(shown) < 1e-12 ? '−∞' : (20 * Math.log10(Math.abs(shown) / ref)).toFixed(3);
    unitText = st!.func === 'ACA' ? 'dBmA' : 'dBV';
  }

  const rangeLabel = st ? (info.ranges[st.ri]?.label ?? '') : '';
  const mode = MODES.find((m) => m.id === st?.mode);

  const toggleHold = () => { if (!hold) setHeld(last?.v ?? null); send('HOLD ' + (hold ? 0 : 1)); };
  const toggleRec = () => api('/record/' + (rec ? 'stop' : 'start'), 'POST');

  const data = useMemo<uPlot.AlignedData>(() => [view.t, view.v], [view]);
  const makeOpts = (w: number, h: number): uPlot.Options => ({
    width: w, height: h, legend: { show: false },
    cursor: { drag: { x: false, y: false }, points: { size: 10, fill: cssVar('--surface'), stroke: cssVar('--accent'), width: 2 } },
    scales: { x: { time: true } },
    axes: [
      { ...axisStyle(), values: (_u, ticks) => ticks.map((t) => new Date(t * 1000).toLocaleTimeString('de-DE', win > 300 || !win ? { hour: '2-digit', minute: '2-digit' } : {})) },
      { ...axisStyle(), size: 84, values: (_u, ticks) => ticks.map((t) => fmtVal(t, f, 1)) },
    ],
    series: [{}, { stroke: cssVar('--accent'), width: 2, fill: cssVar('--accent-live') + '14', points: { show: false }, gaps: timeGaps() }],
  });
  const [tip, setTip] = useState<{ left: number; ago: string; val: string } | null>(null);
  const onReady = (u: uPlot) => {
    u.over.addEventListener('mousemove', () => {
      const i = u.cursor.idx;
      if (i === null || i === undefined || !u.data[0].length) { setTip(null); return; }
      const t = u.data[0][i] as number, v = u.data[1][i] as number;
      const ago = Math.max(0, (u.data[0][u.data[0].length - 1] as number) - t);
      setTip({ left: u.valToPos(t, 'x') + u.over.offsetLeft, ago: `vor ${Math.floor(ago / 60)}:${String(Math.floor(ago % 60)).padStart(2, '0')} min`, val: fmtVal(v, f, 1) + ' ' + f.unit });
    });
    u.over.addEventListener('mouseleave', () => setTip(null));
  };

  return (
    <>
      <header className="page-head">
        <div className="page-title">
          <span className="eyebrow">{info.settings?.workplace ?? 'Arbeitsplatz 1'}</span>
          <h1>Messen</h1>
        </div>
        {rec && (
          <span className="pill"><span className="dot rec" />Aufnahme <span className="mono" style={{ color: 'var(--text-2)' }}>{fmtDuration(now - (rec.start ?? now))}</span></span>
        )}
        <button type="button" className={'btn' + (hold ? ' on' : '')} aria-pressed={hold} disabled={!connected} onClick={toggleHold}>Hold</button>
        <button type="button" className={'btn' + (st?.zero ? ' on' : '')} aria-pressed={!!st?.zero} disabled={!connected}
          onClick={() => send('ZERO ' + (st?.zero ? 0 : 1))}>Nullen (REL)</button>
        <button type="button" className="btn primary" disabled={!connected && !rec} onClick={toggleRec}>{rec ? 'Aufnahme stoppen' : 'Aufnahme starten'}</button>
      </header>

      <div role="group" aria-label="Messfunktion" className="funcs">
        {FUNCS.map((fn) => (
          <button key={fn.id} type="button" className="func" aria-pressed={st?.func === fn.id} disabled={!connected}
            onClick={() => send('FUNC ' + fn.id)}>
            <span className="func-sym">{fn.sym}</span><span className="func-short">{fn.short}</span>
          </button>
        ))}
      </div>

      <section aria-label="Aktueller Messwert" className="display">
        <div className="display-main">
          <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: 10 }}>
            <span style={{ fontSize: 15, fontWeight: 600 }}>{fi.label}</span>
            <span className="chip">Bereich {st ? (st.auto ? 'Auto · ' : '') + rangeLabel : '–'}</span>
            <span className="chip">{mode ? `${mode.name} · ${mode.tag}` : 'Benutzerdefiniert'}</span>
            {st?.zero ? <span className="chip on">REL</span> : null}
            {hold && <span className="chip on">Hold</span>}
            {st && st.chan > 0 && <span className="chip">Kanal {st.chan}</span>}
            {st?.lock ? <span className="chip">Tasten gesperrt</span> : null}
            <span className={'live' + (stale ? ' stale' : '')}><span className="dot" />
              {connected ? (stale ? 'keine Messwerte' : `live · ${rate.toFixed(rate < 10 ? 1 : 0).replace('.', ',')} Messungen/s`) : 'nicht verbunden'}</span>
          </div>
          <div className="reading-row">
            <span className={'reading-xl' + (hold ? ' held' : '')} aria-live="off">{readingText}</span>
            <span className="reading-unit">{unitText}</span>
          </div>
          <div className="ranges">
            <span className="ranges-label">Bereich</span>
            <button type="button" className="range" aria-pressed={!!st?.auto} disabled={!connected} onClick={() => send('RANG AUTO')}>Auto</button>
            {info.ranges.map((r, i) => (
              <button key={r.fs} type="button" className="range" aria-pressed={!!st && !st.auto && st.ri === i} disabled={!connected}
                onClick={() => send('RANG ' + i)}>{r.label}</button>
            ))}
            {st?.func.startsWith('AC') && (
              <button type="button" className="range" aria-pressed={!!st?.db} style={{ marginLeft: 'auto' }} onClick={() => send('DB ' + (st?.db ? 0 : 1))}>dB</button>
            )}
          </div>
        </div>
        <div className="display-side">
          <div className="stat"><span className="stat-label">Minimum</span><span className="stat-val">{fmtVal(stats?.min, f)}</span></div>
          <div className="stat"><span className="stat-label">Maximum</span><span className="stat-val">{fmtVal(stats?.max, f)}</span></div>
          <div className="stat"><span className="stat-label">Mittelwert</span><span className="stat-val">{fmtVal(stats?.mean, f)}</span></div>
          <div className="stat"><span className="stat-label">Std.-Abw. σ</span><span className="stat-val">{fmtEng(stats?.sd, f.unit.slice(-1), 3)}</span></div>
          <div className="stat"><span className="stat-label">Spanne</span><span className="stat-val">{stats ? fmtEng(stats.max - stats.min, f.unit.slice(-1), 3) : '–'}</span></div>
          <div className="stat"><span className="stat-label">Messungen</span><span className="stat-val">{stats ? fmtCount(stats.n) : '0'}</span></div>
        </div>
      </section>

      <div className="row">
        <section aria-label="Verlauf" className="card grow" style={{ padding: '20px 24px', gap: 14 }}>
          <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: 12 }}>
            <h2 style={{ marginRight: 'auto' }}>Verlauf</h2>
            <div role="group" aria-label="Zeitfenster" className="seg">
              {WINDOWS.map((w) => <button key={w.s} type="button" aria-pressed={win === w.s} onClick={() => setWin(w.s)}>{w.label}</button>)}
            </div>
          </div>
          <Chart data={data} makeOpts={makeOpts} height={260} deps={[f.unit, f.dec, win, st?.func]} onReady={onReady}>
            {view.t.length < 2 && <div className="chart-empty">{connected ? 'Warte auf Messwerte …' : 'Keine Verbindung zum Gerät'}</div>}
            {tip && <div className="tip" style={{ left: tip.left, transform: 'translateX(-108%)' }}><small>{tip.ago}</small><b>{tip.val}</b></div>}
          </Chart>
        </section>

        <div className="side">
          <section aria-label="Messmodus" className="card" style={{ gap: 10 }}>
            <h2 style={{ marginBottom: 4 }}>Messmodus</h2>
            {MODES.map((m) => (
              <button key={m.id} type="button" className="mode" aria-pressed={st?.mode === m.id} disabled={!connected}
                onClick={() => api('/mode/' + m.id, 'POST')}>
                <span style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                  <span className="mode-name">{m.name}</span><span className="mode-desc">{m.desc}</span>
                </span>
                <span className="mode-tag">{m.tag}</span>
              </button>
            ))}
            {st && st.filter && !(last && last.flags & F_SETTLED) && !(last && last.flags & F_HOLD) ? (
              <span className="eyebrow">Filter füllt sich (100 Wandlungen)</span>) : null}
          </section>
          <MinMaxCard f={f} />
          <Limits f={f} />
        </div>
      </div>
    </>
  );
}

function MinMaxCard({ f }: { f: ReturnType<typeof stFmt> }) {
  const { info } = useStore();
  const mm = info.minmax;
  const ok = mm && info.state && mm.func === info.state.func;
  const at = (t: number) => new Date(t * 1000).toLocaleTimeString('de-DE');
  return (
    <section aria-label="Min/Max" className="card" style={{ gap: 10 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
        <h2>Min / Max</h2>
        <button type="button" className="btn small" onClick={() => api('/minmax/reset', 'POST')}>Zurücksetzen</button>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, minmax(0, 1fr))', gap: '12px 16px' }}>
        <div className="stat"><span className="stat-label">Minimum{ok ? ' · ' + at(mm!.t_min) : ''}</span><span className="stat-val">{ok ? fmtVal(mm!.min, f) + ' ' + f.unit : '–'}</span></div>
        <div className="stat"><span className="stat-label">Maximum{ok ? ' · ' + at(mm!.t_max) : ''}</span><span className="stat-val">{ok ? fmtVal(mm!.max, f) + ' ' + f.unit : '–'}</span></div>
        <div className="stat"><span className="stat-label">Mittelwert</span><span className="stat-val">{ok ? fmtVal(mm!.mean, f) + ' ' + f.unit : '–'}</span></div>
        <div className="stat"><span className="stat-label">Spanne</span><span className="stat-val">{ok ? fmtEng(mm!.max - mm!.min, f.unit.slice(-1)) : '–'}</span></div>
      </div>
      <span className="eyebrow">{ok ? `seit ${at(mm!.since)} · ${fmtCount(mm!.n)} Messungen` : 'Startet mit der nächsten Messung'}{info.state?.filter ? ' · nur gefüllter Filter' : ''}</span>
    </section>
  );
}

function Limits({ f }: { f: ReturnType<typeof stFmt> }) {
  const { info } = useStore();
  const st = info.state, lim = info.settings?.limits, last = info.last;
  const [edit, setEdit] = useState(false);
  const [lo, setLo] = useState(''); const [hi, setHi] = useState('');
  const active = !!(lim?.enabled && st && lim.func === st.func);
  const inside = !active || !last ? true : (lim!.low === null || last.v >= lim!.low) && (lim!.high === null || last.v <= lim!.high);
  // position of the reading on the bar: band = [low, high] spans 20 %…80 %
  let markPct = 50;
  if (active && last && lim!.low !== null && lim!.high !== null && lim!.high > lim!.low) {
    markPct = Math.min(98, Math.max(2, 20 + (last.v - lim!.low) / (lim!.high - lim!.low) * 60));
  }
  const save = () => {
    const p = (s: string) => (s.trim() === '' ? null : Number(s.replace(',', '.').replace('−', '-')) / f.scale);
    api('/settings', 'POST', { limits: { enabled: true, low: p(lo), high: p(hi), func: st?.func ?? 'DCV' } });
    setEdit(false);
  };
  return (
    <section aria-label="Grenzwerte" className="card" style={{ gap: 10 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <h2>Grenzwerte</h2>
        {active ? <span className={'tag ' + (inside ? 'ok' : 'warn')}>{inside ? 'innerhalb' : 'außerhalb'}</span> : <span className="tag off">aus</span>}
      </div>
      <div className="limitbar">
        <div className="band" style={{ left: '20%', right: '20%' }} />
        {active && <div className={'mark' + (inside ? '' : ' out')} style={{ left: markPct + '%' }} />}
      </div>
      <div className="axis" style={{ fontSize: 12 }}>
        <span>{active && lim!.low !== null ? fmtVal(lim!.low, f) + ' ' + f.unit : 'untere Grenze'}</span>
        <span>{active && lim!.high !== null ? fmtVal(lim!.high, f) + ' ' + f.unit : 'obere Grenze'}</span>
      </div>
      {edit ? (
        <div style={{ display: 'flex', gap: 8, alignItems: 'flex-end', flexWrap: 'wrap' }}>
          <label className="field" style={{ flex: 1 }}>Unten ({f.unit})<input className="mono" inputMode="decimal" value={lo} onChange={(e) => setLo(e.target.value)} /></label>
          <label className="field" style={{ flex: 1 }}>Oben ({f.unit})<input className="mono" inputMode="decimal" value={hi} onChange={(e) => setHi(e.target.value)} /></label>
          <button type="button" className="btn small primary" onClick={save}>Setzen</button>
        </div>
      ) : (
        <div style={{ display: 'flex', gap: 8 }}>
          <button type="button" className="btn small" disabled={!st} onClick={() => {
            setLo(active && lim!.low !== null ? fmtVal(lim!.low, f) : ''); setHi(active && lim!.high !== null ? fmtVal(lim!.high, f) : ''); setEdit(true);
          }}>Bearbeiten</button>
          {active && <button type="button" className="btn small" onClick={() => api('/settings', 'POST', { limits: { enabled: false } })}>Aus</button>}
        </div>
      )}
    </section>
  );
}
