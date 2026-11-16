import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type uPlot from 'uplot';
import { api, useStore, type RecInfo } from '../store';
import { funcInfo, rangeFmt, fmtVal, fmtEng, fmtSigned, fmtTime, fmtCount } from '../format';
import { Chart, axisStyle, cssVar } from '../components/Chart';

type Series = Record<string, { t: number[]; min: number[]; max: number[]; avg: number[] }>;
interface Stats { n: number; mean?: number; min?: number; max?: number; sd?: number; pp?: number; drift_per_min?: number;
  delta?: number; duration?: number; hist?: number[]; hist_lo?: number; hist_hi?: number }

const CH_COLORS = ['--accent', '--warn', '--text-2', '--accent-live', '--text-muted', '--accent-strong', '--warn-text', '--border-strong'];

export function Analyse() {
  const { info } = useStore();
  const [recs, setRecs] = useState<RecInfo[]>([]);
  const [rid, setRid] = useState<string>('');
  const [series, setSeries] = useState<Series>({});
  const [zoom, setZoom] = useState<[number, number] | null>(null);
  const [sel, setSel] = useState<[number, number] | null>(null);
  const [selChan, setSelChan] = useState<number>(0);
  const [hidden, setHidden] = useState<Set<number>>(new Set());
  const [stats, setStats] = useState<Stats | null>(null);
  const [notes, setNotes] = useState<{ t: number; text: string }[]>([]);
  const plotRef = useRef<uPlot | null>(null);
  const [, force] = useState(0);

  const loadRecs = useCallback(async () => {
    const r: RecInfo[] = await api('/recordings');
    setRecs(r);
    setRid((cur) => cur && r.some((x) => x.id === cur) ? cur : (r[0]?.id ?? 'live'));
  }, []);
  useEffect(() => { loadRecs(); }, [loadRecs, info.recording?.id]);

  const rec = recs.find((r) => r.id === rid);
  const func = rec?.func ?? info.state?.func ?? 'DCV';
  const chans = Object.keys(series).map(Number).sort((a, b) => a - b);

  // data for the main chart
  const load = useCallback(async () => {
    if (!rid) return;
    const q = zoom ? `?t0=${zoom[0]}&t1=${zoom[1]}&points=1500` : '?points=1500';
    const d = await api(`/recordings/${rid}/series${q}`);
    setSeries(d.channels);
    if (d.info) setNotes(d.info.notes);
    else setNotes([]);
  }, [rid, zoom]);
  useEffect(() => { load(); }, [load]);
  // live data and running recordings refresh every 2 s
  useEffect(() => {
    if (!(rid === 'live' || (rec && !rec.stop))) return;
    const id = setInterval(load, 2000);
    return () => clearInterval(id);
  }, [rid, rec, load]);

  useEffect(() => { if (chans.length && !chans.includes(selChan)) setSelChan(chans[0]); }, [chans.join(','), selChan]);

  // statistics of the selection (or of the visible range)
  useEffect(() => {
    if (!rid) return;
    const r = sel ?? zoom;
    const q = new URLSearchParams();
    if (r) { q.set('t0', String(r[0])); q.set('t1', String(r[1])); }
    if (chans.length) q.set('chan', String(selChan));
    api(`/recordings/${rid}/stats?${q}`).then(setStats).catch(() => setStats(null));
  }, [rid, sel, zoom, selChan, series]);

  // scale for formatting: largest magnitude in data
  const fmt = useMemo(() => {
    let m = 0;
    for (const c of Object.values(series)) for (const v of c.avg) m = Math.max(m, Math.abs(v));
    const fs = [0.303, 3.03, 30.3, 303, 3030, 30300, 303000, 3.03e6].find((x) => m < x) ?? 3.03e6;
    const isA = func.endsWith('A');
    return rangeFmt(func, isA ? Math.max(fs, 0.0303) : fs, 6);
  }, [series, func]);
  const u1 = fmt.unit.slice(-1);

  // align channels on one time axis (uPlot needs a shared x)
  const data = useMemo<uPlot.AlignedData>(() => {
    const all = new Set<number>();
    chans.forEach((c) => series[c].t.forEach((t) => all.add(t)));
    const xs = [...all].sort((a, b) => a - b);
    const idx = new Map(xs.map((t, i) => [t, i]));
    const ys = chans.map((c) => {
      const arr: (number | null)[] = new Array(xs.length).fill(null);
      series[c].t.forEach((t, i) => { arr[idx.get(t)!] = series[c].avg[i]; });
      return arr;
    });
    return [xs, ...ys] as uPlot.AlignedData;
  }, [series]);

  const makeOpts = (w: number, h: number): uPlot.Options => ({
    width: w, height: h, legend: { show: false },
    cursor: { drag: { x: true, y: false, setScale: false }, points: { show: false } },
    select: { show: true, left: 0, top: 0, width: 0, height: 0 },
    scales: { x: { time: true } },
    axes: [
      { ...axisStyle(), values: (_u, ticks) => ticks.map((t) => fmtTime(t, ticks.length > 1 && ticks[1] - ticks[0] < 60)) },
      { ...axisStyle(), size: 84, values: (_u, ticks) => ticks.map((t) => fmtVal(t, fmt)) },
    ],
    series: [{}, ...chans.map((c, i) => ({
      label: 'Kanal ' + c, stroke: cssVar(CH_COLORS[i % CH_COLORS.length]), width: i ? 1.6 : 2,
      spanGaps: true, show: !hidden.has(c), points: { show: false },
    }))],
    hooks: {
      setSelect: [(u) => {
        if (u.select.width < 3) return;
        const a = u.posToVal(u.select.left, 'x'), b = u.posToVal(u.select.left + u.select.width, 'x');
        setSel([a, b]);
        u.setSelect({ left: 0, top: 0, width: 0, height: 0 }, false);
      }],
      draw: [() => force((x) => x + 1)],
    },
  });

  const onReady = (u: uPlot) => {
    plotRef.current = u;
    u.over.addEventListener('wheel', (e) => {
      e.preventDefault();
      const x = u.posToVal(e.offsetX, 'x');
      const { min, max } = u.scales.x as { min: number; max: number };
      const k = e.deltaY > 0 ? 1.25 : 0.8;
      setZoom([x - (x - min) * k, x + (max - x) * k]);
    }, { passive: false });
    u.over.addEventListener('dblclick', () => { setZoom(null); setSel(null); });
  };

  const pos = (t: number) => {
    const u = plotRef.current;
    if (!u || !u.scales.x || u.scales.x.min === undefined) return null;
    const p = u.valToPos(t, 'x');
    return p < 0 || p > u.over.clientWidth ? null : p + u.over.offsetLeft;
  };

  const addNote = async () => {
    const text = window.prompt('Notiz am ' + (sel ? 'Beginn der Auswahl' : 'Ende der Daten') + ':');
    if (!text || !rec || rid === 'live') return;
    const t = sel ? sel[0] : (data[0][data[0].length - 1] as number);
    const r = await api(`/recordings/${rid}/notes`, 'POST', { t, text });
    setNotes(r.notes);
  };
  const exportCsv = () => {
    const q = sel ? `?t0=${sel[0]}&t1=${sel[1]}` : '';
    location.href = `/api/recordings/${rid}/csv${q}`;
  };
  const exportPng = () => {
    const u = plotRef.current;
    if (!u) return;
    const c = document.createElement('canvas');
    c.width = u.ctx.canvas.width; c.height = u.ctx.canvas.height;
    const g = c.getContext('2d')!;
    g.fillStyle = cssVar('--chart-bg'); g.fillRect(0, 0, c.width, c.height);
    g.drawImage(u.ctx.canvas, 0, 0);
    const a = document.createElement('a');
    a.href = c.toDataURL('image/png'); a.download = `klar_${rid}.png`; a.click();
  };

  const sub = rec?.start
    ? `${rid === 'live' ? 'Live-Puffer' : 'Aufnahme'} · ${new Date(rec.start * 1000).toLocaleDateString('de-DE')} ${fmtTime(rec.start, false)}${rec.stop ? ' – ' + fmtTime(rec.stop, false) : ' – läuft'} · ${funcInfo(func).label}`
    : 'Keine Daten';
  const histMax = Math.max(1, ...(stats?.hist ?? [1]));
  const names = info.settings?.channel_names ?? {};
  const chName = (c: number) => c === 0 ? 'Eingang' : `Kanal ${c}` + (names[String(c)] ? ' · ' + names[String(c)] : '');
  const dur = stats?.duration ?? 0;

  return (
    <>
      <header className="page-head">
        <div className="page-title"><span className="eyebrow">{sub}</span><h1>Analyse</h1></div>
        <select className="input" aria-label="Aufnahme wählen" value={rid} onChange={(e) => { setRid(e.target.value); setZoom(null); setSel(null); }}>
          {recs.map((r) => (
            <option key={r.id} value={r.id}>{r.id === 'live' ? 'Live-Puffer' : 'Aufnahme ' + r.id} ({fmtCount(r.points)} Punkte)</option>
          ))}
        </select>
        <button type="button" className="btn" disabled={rid === 'live'} onClick={addNote}>Notiz setzen</button>
        <button type="button" className="btn" onClick={exportPng}>PNG</button>
        <button type="button" className="btn primary" onClick={exportCsv}>Als CSV exportieren</button>
      </header>

      <div className="row" style={{ flex: 1 }}>
        <section aria-label="Diagramm" className="card grow" style={{ padding: '20px 24px', gap: 14 }}>
          <div className="legend">
            {chans.map((c, i) => (
              <span key={c} style={{ color: hidden.has(c) ? 'var(--text-muted)' : undefined }}>
                <i style={{ background: `var(${CH_COLORS[i % CH_COLORS.length]})` }} />{chName(c)} · {funcInfo(func).sym}</span>
            ))}
            <span style={{ marginLeft: 'auto', fontSize: 12, fontWeight: 400, color: 'var(--text-muted)' }}>
              Ziehen = Bereich wählen · Mausrad = Zoom · Doppelklick = alles</span>
          </div>
          <Chart data={data} makeOpts={makeOpts} height={420} deps={[chans.join(','), [...hidden].join(','), fmt.unit, fmt.dec]} onReady={onReady}>
            {data[0].length < 2 && <div className="chart-empty">Keine Messwerte in dieser Auswahl</div>}
            {sel && [0, 1].map((k) => {
              const p = pos(sel[k]);
              return p === null ? null : (
                <div key={k}><div className="vline" style={{ left: p }} />
                  <div className="marker-flag" style={{ left: p }}>{k ? 'B' : 'A'} · {fmtTime(sel[k])}</div></div>);
            })}
            {sel && (() => {
              const a = pos(sel[0]), b = pos(sel[1]);
              return a !== null && b !== null ? <div style={{ position: 'absolute', top: 0, bottom: 0, left: a, width: b - a, background: 'var(--accent-live)', opacity: 0.1, pointerEvents: 'none' }} /> : null;
            })()}
            {notes.map((n, i) => {
              const p = pos(n.t);
              return p === null ? null : (
                <div key={i}><div className="vline note" style={{ left: p }} /><div className="note-flag" style={{ left: p }}>Notiz: {n.text}</div></div>);
            })}
          </Chart>
          {(zoom || sel) && (
            <div style={{ display: 'flex', gap: 8 }}>
              {zoom && <button type="button" className="btn small" onClick={() => setZoom(null)}>Ganze Aufnahme</button>}
              {sel && <button type="button" className="btn small" onClick={() => { setZoom(sel); setSel(null); }}>Auf Auswahl zoomen</button>}
              {sel && <button type="button" className="btn small" onClick={() => setSel(null)}>Auswahl aufheben</button>}
            </div>
          )}
        </section>

        <aside aria-label="Auswahl-Statistik" className="side" style={{ flexBasis: 300 }}>
          <section className="dark-card">
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
              <span className="stat-label">{sel ? 'Auswahl A → B' : zoom ? 'Sichtbarer Bereich' : 'Gesamte Aufnahme'} · {Math.floor(dur / 60)} min {Math.round(dur % 60)} s · {fmtCount(stats?.n ?? 0)} Punkte</span>
              <span style={{ fontSize: 15, fontWeight: 600 }}>{chName(selChan)}</span>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <span className="stat-label">Mittelwert</span>
              <span className="big-stat">{fmtVal(stats?.mean, fmt, 1)} <span style={{ fontSize: 20, color: 'var(--display-muted)' }}>{fmt.unit}</span></span>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, minmax(0, 1fr))', gap: '14px 16px' }}>
              <div className="stat"><span className="stat-label">Min</span><span className="stat-val" style={{ fontSize: 16 }}>{fmtVal(stats?.min, fmt)}</span></div>
              <div className="stat"><span className="stat-label">Max</span><span className="stat-val" style={{ fontSize: 16 }}>{fmtVal(stats?.max, fmt)}</span></div>
              <div className="stat"><span className="stat-label">σ</span><span className="stat-val" style={{ fontSize: 16 }}>{fmtEng(stats?.sd, u1)}</span></div>
              <div className="stat"><span className="stat-label">Δ (B − A)</span><span className="stat-val" style={{ fontSize: 16 }}>{fmtSigned(stats?.delta, fmt)}</span></div>
              <div className="stat"><span className="stat-label">Drift</span><span className="stat-val" style={{ fontSize: 16 }}>{stats?.drift_per_min !== undefined ? (stats.drift_per_min >= 0 ? '+' : '') + fmtEng(stats.drift_per_min, u1) + '/min' : '–'}</span></div>
              <div className="stat"><span className="stat-label">Rauschen p-p</span><span className="stat-val" style={{ fontSize: 16 }}>{fmtEng(stats?.pp, u1)}</span></div>
            </div>
          </section>
          <section className="card">
            <h2>Verteilung</h2>
            <div className="hist" aria-hidden="true">
              {(stats?.hist ?? []).map((v, i, a) => (
                <div key={i} className={Math.abs(i - (a.length - 1) / 2) <= 2 ? 'mid' : ''} style={{ height: (v / histMax) * 96 }} />
              ))}
            </div>
            <div className="axis">
              <span>{fmtVal(stats?.hist_lo, fmt)}</span>
              <span>{stats?.hist_lo !== undefined ? fmtVal((stats.hist_lo + stats.hist_hi!) / 2, fmt) : ''}</span>
              <span>{fmtVal(stats?.hist_hi, fmt)}</span>
            </div>
          </section>
          <section className="card" style={{ gap: 4 }}>
            <h2 style={{ marginBottom: 6 }}>Kanäle</h2>
            {chans.length === 0 && <span className="eyebrow">Keine Daten</span>}
            {chans.map((c) => (
              <div key={c} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <label className="check" style={{ marginRight: 'auto' }}>
                  <input type="checkbox" checked={!hidden.has(c)} onChange={() => {
                    const h = new Set(hidden); if (h.has(c)) h.delete(c); else h.add(c); setHidden(h);
                  }} />{chName(c)}</label>
                {chans.length > 1 && <button type="button" className={'btn small' + (selChan === c ? ' on' : '')} onClick={() => setSelChan(c)}>Statistik</button>}
              </div>
            ))}
          </section>
        </aside>
      </div>
    </>
  );
}
