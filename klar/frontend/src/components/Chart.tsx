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

export function axisStyle() {
  return {
    stroke: cssVar('--text-muted'),
    grid: { stroke: cssVar('--grid-line'), width: 1 },
    ticks: { show: false },
    font: '11px "JetBrains Mono", monospace',
  };
}
