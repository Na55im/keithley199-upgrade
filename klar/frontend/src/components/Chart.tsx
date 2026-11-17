// Thin uPlot wrapper: resizes with its box, colours from CSS tokens.
import { useEffect, useRef } from 'react';
import uPlot from 'uplot';
import 'uplot/dist/uPlot.min.css';

export function cssVar(name: string) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

interface Props {
  data: uPlot.AlignedData;
  makeOpts: (width: number, height: number) => uPlot.Options;
  height: number;
  deps?: unknown[];            // rebuild the plot when these change (series count, formatting)
  onReady?: (u: uPlot) => void;
  children?: React.ReactNode;  // overlays
}

export function Chart({ data, makeOpts, height, deps = [], onReady, children }: Props) {
  const box = useRef<HTMLDivElement>(null);
  const plot = useRef<uPlot | null>(null);

  useEffect(() => {
    const el = box.current!;
    const u = new uPlot(makeOpts(el.clientWidth || 600, height), data, el);
    plot.current = u;
    onReady?.(u);
    const ro = new ResizeObserver(() => u.setSize({ width: el.clientWidth, height }));
    ro.observe(el);
    return () => { ro.disconnect(); u.destroy(); plot.current = null; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [height, ...deps]);

  useEffect(() => { plot.current?.setData(data); }, [data]);

  return (
    <div className="chart-box" style={{ height }}>
      <div ref={box} />
      {children}
    </div>
  );
}

/** Break the line where readings are missing (Mac asleep, device off):
 *  a gap is longer than 10x the typical spacing of that series, at least minGap s. */
export function timeGaps(minGap = 5): uPlot.Series.GapsRefiner {
  return (u, sidx, idx0, idx1, nullGaps) => {
    const xs = u.data[0] as number[], ys = u.data[sidx] as (number | null)[];
    const pts: number[] = [];
    for (let i = idx0; i <= idx1; i++) if (ys[i] !== null && ys[i] !== undefined) pts.push(i);
    if (pts.length < 3) return nullGaps;
    const d: number[] = [];
    for (let k = 1; k < pts.length; k += Math.max(1, Math.floor(pts.length / 500))) d.push(xs[pts[k]] - xs[pts[k - 1]]);
    d.sort((a, b) => a - b);
    const thr = Math.max(minGap, 10 * d[Math.floor(d.length / 2)]);
    const gaps: [number, number][] = [...nullGaps];
    for (let k = 1; k < pts.length; k++) {
      const a = xs[pts[k - 1]], b = xs[pts[k]];
      if (b - a > thr) gaps.push([Math.round(u.valToPos(a, 'x', true)) + 1, Math.round(u.valToPos(b, 'x', true))]);
    }
    return gaps;
  };
}

export function axisStyle() {
  return {
    stroke: cssVar('--text-muted'),
    grid: { stroke: cssVar('--grid-line'), width: 1 },
    ticks: { show: false },
    font: '11px "JetBrains Mono", monospace',
  };
}
