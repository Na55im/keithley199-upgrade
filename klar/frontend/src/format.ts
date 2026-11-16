// Number formatting like the 199 display: range decides prefix and decimals.
import type { DevState, Func } from './store';

export const FUNCS: { id: Func; sym: string; short: string; label: string }[] = [
  { id: 'DCV', sym: 'V⎓', short: 'Gleichsp.', label: 'Gleichspannung' },
  { id: 'ACV', sym: 'V∼', short: 'Wechselsp.', label: 'Wechselspannung' },
  { id: 'OHM2', sym: 'Ω', short: 'Widerstand', label: 'Widerstand 2-Leiter' },
  { id: 'DCA', sym: 'A⎓', short: 'Gleichstrom', label: 'Gleichstrom' },
  { id: 'ACA', sym: 'A∼', short: 'Wechselstr.', label: 'Wechselstrom' },
  { id: 'OHM4', sym: 'Ω4', short: '4-Leiter', label: 'Widerstand 4-Leiter' },
];
export const funcInfo = (f: string) => FUNCS.find((x) => x.id === f) ?? FUNCS[0];

export const MODES = [
  { id: 'fast', name: 'Schnell', desc: '4½ Stellen, ideal zum Abgleichen', tag: '¼ NPLC' },
  { id: 'std', name: 'Standard', desc: '5½ Stellen, Netzperioden-Integration', tag: '1 NPLC' },
  { id: 'precise', name: 'Präzise', desc: '6½ Stellen + digitaler Filter', tag: 'Filter' },
] as const;

export function baseUnit(func: string) { return func.endsWith('V') ? 'V' : func.endsWith('A') ? 'A' : 'Ω'; }

export interface Fmt { scale: number; unit: string; dec: number }
export function rangeFmt(func: string, fs: number, digits: number): Fmt {
  let scale = 1, prefix = '';
  if (func.startsWith('OHM')) { if (fs >= 1e6) { scale = 1e-6; prefix = 'M'; } else if (fs >= 1e3) { scale = 1e-3; prefix = 'k'; } }
  else if (fs < 1) { scale = 1e3; prefix = 'm'; }
  const intdig = Math.floor(Math.log10(fs * scale) + 1e-9) + 1;
  return { scale, unit: prefix + baseUnit(func), dec: Math.max(0, digits + 1 - intdig) };
}
export function stFmt(st: DevState | null): Fmt {
  return st ? rangeFmt(st.func, st.fs, st.digits) : { scale: 1, unit: 'V', dec: 6 };
}

/** fixed-width reading: sign + digits, "−" as real minus */
export function fmtReading(v: number | null | undefined, f: Fmt, signed = true) {
  if (v === null || v === undefined || !isFinite(v)) return '–';
  const x = v * f.scale;
  const s = Math.abs(x).toFixed(f.dec);
  return (x < 0 && Number(s) !== 0 ? '−' : signed ? '+' : '') + s;
}
export function fmtVal(v: number | null | undefined, f: Fmt, extra = 0) {
  if (v === null || v === undefined || !isFinite(v)) return '–';
  const x = v * f.scale;
  return (x < 0 ? '−' : '') + Math.abs(x).toFixed(Math.min(9, f.dec + extra));
}
/** small quantities (σ, drift): engineering prefix */
export function fmtEng(v: number | null | undefined, unit: string, digits = 3) {
  if (v === null || v === undefined || !isFinite(v)) return '–';
  const a = Math.abs(v);
  const steps: [number, string][] = [[1e6, 'M'], [1e3, 'k'], [1, ''], [1e-3, 'm'], [1e-6, 'µ'], [1e-9, 'n']];
  if (a === 0) return '0 ' + unit;
  for (const [m, p] of steps) if (a >= m) return (v < 0 ? '−' : '') + (a / m).toPrecision(digits) + ' ' + p + unit;
  return (v < 0 ? '−' : '') + (a / 1e-9).toPrecision(digits) + ' n' + unit;
}
export function fmtSigned(v: number | null | undefined, f: Fmt) {
  if (v === null || v === undefined || !isFinite(v)) return '–';
  return (v >= 0 ? '+' : '−') + Math.abs(v * f.scale).toFixed(f.dec);
}
export function fmtDuration(s: number) {
  s = Math.max(0, Math.floor(s));
  const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60;
  return [h, m, sec].map((x) => String(x).padStart(2, '0')).join(':');
}
export function fmtCount(n: number) { return n.toLocaleString('de-DE').replace(/\./g, ' '); }
export function fmtTime(t: number, sec = true) {
  return new Date(t * 1000).toLocaleTimeString('de-DE', sec ? {} : { hour: '2-digit', minute: '2-digit' });
}
