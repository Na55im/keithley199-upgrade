// Connection to the KLAR backend: one WebSocket, a small external store.
import { useSyncExternalStore } from 'react';

export type Func = 'DCV' | 'ACV' | 'DCA' | 'ACA' | 'OHM2' | 'OHM4';
export type Mode = 'fast' | 'std' | 'precise' | 'custom';

export interface DevState {
  func: Func; ri: number; fs: number; auto: number; filter: number; digits: number;
  zero: number; zero_val: number; db: number; trig: 'CONT' | 'ONE'; chan: number; stream: number;
  speed: 'FAST' | 'LINE'; line: number; int_us: number; lock: number; hold: number; scan: number;
  mode: Mode; unit: string; scan_list: number[];
}
export interface Reading { t: number; v: number; raw: number; func: Func; ri: number; flags: number; ch: number }
export interface Notice { id: number; t: number; text: string; level: 'hint' | 'warn' }
export interface RecInfo {
  id: string; start: number | null; stop: number | null; func: Func | null; unit: string;
  points: number; channels: number[]; file: string | null; notes: { t: number; text: string }[];
}
export interface Settings {
  workplace: string; port: string; theme: 'light' | 'dark';
  channel_names: Record<string, string>;
  limits: { enabled: boolean; low: number | null; high: number | null; func: Func };
}
export interface Info {
  status: 'searching' | 'connected' | 'disconnected' | 'offline';
  port: string; idn: string; build: string; state: DevState | null;
  ranges: { fs: number; label: string }[]; recording: RecInfo | null;
  settings: Settings | null; notices: Notice[]; last: Reading | null;
}

export const F_OVERFLOW = 16, F_SETTLED = 8, F_HOLD = 64;
const LIVE_MAX = 120000;

// live buffer (outside React state: grows fast)
export const live = { t: [] as number[], v: [] as number[], ch: [] as number[], func: '' as string, version: 0 };
export const log: { dir: string; line: string }[] = [];

let info: Info = { status: 'offline', port: '', idn: '', build: '', state: null, ranges: [], recording: null,
  settings: null, notices: [], last: null };
let rate = 0;
const stamps: number[] = [];
const subs = new Set<() => void>();
let snapshot = { info, rate, liveVersion: 0, logVersion: 0 };

function publish() {
  snapshot = { info, rate, liveVersion: live.version, logVersion: log.length };
  subs.forEach((f) => f());
}

function onReading(r: Reading) {
  info = { ...info, last: r };
  if (r.flags & F_OVERFLOW) return;
  if (live.func !== r.func) { live.t = []; live.v = []; live.ch = []; live.func = r.func; }
  live.t.push(r.t); live.v.push(r.v); live.ch.push(r.ch);
  if (live.t.length > LIVE_MAX) { const k = LIVE_MAX / 10; live.t.splice(0, k); live.v.splice(0, k); live.ch.splice(0, k); }
  live.version++;
  stamps.push(r.t);
  while (stamps.length && stamps[0] < r.t - 5) stamps.shift();
  rate = stamps.length > 1 ? (stamps.length - 1) / (stamps[stamps.length - 1] - stamps[0] || 1) : 0;
}

function onMsg(m: any) {
  if (m.t === 'batch') { m.msgs.forEach(onMsgOne); publish(); return; }
  onMsgOne(m); publish();
}
function onMsgOne(m: any) {
  if (m.t === 'r') onReading(m.r);
  else if (m.t === 'info') { const { t: _t, ...rest } = m; info = { ...info, ...rest }; }
  else if (m.t === 'notice') info = { ...info, notices: [...info.notices, m.notice].slice(-20) };
  else if (m.t === 'log') { log.push({ dir: m.dir, line: m.line }); if (log.length > 300) log.splice(0, 100); }
}

let ws: WebSocket | null = null;
function connect() {
  const proto = location.protocol === 'https:' ? 'wss' : 'ws';
  ws = new WebSocket(`${proto}://${location.host}/ws`);
  ws.onmessage = (e) => onMsg(JSON.parse(e.data));
  ws.onclose = () => { info = { ...info, status: 'offline' }; publish(); setTimeout(connect, 1500); };
}
connect();

export function send(cmd: string | string[]) {
  const c = Array.isArray(cmd) ? cmd.join('\n') : cmd;
  if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify({ cmd: c }));
}

export async function api(path: string, method = 'GET', body?: unknown) {
  const r = await fetch('/api' + path, {
    method, headers: body !== undefined ? { 'Content-Type': 'application/json' } : undefined,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}

export function useStore() {
  return useSyncExternalStore((f) => { subs.add(f); return () => { subs.delete(f); }; }, () => snapshot);
}
