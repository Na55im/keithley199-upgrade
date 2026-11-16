// Stroke icons from the design (24×24 grid).
const P = { fill: 'none', stroke: 'currentColor', strokeWidth: 2, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const };

export const IconLogo = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#3DDC97" strokeWidth="2.4" strokeLinecap="round" aria-hidden="true">
    <path d="M3 12h4l3-7 4 14 3-7h4" />
  </svg>
);
export const IconMeasure = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><circle cx="12" cy="13" r="8" /><path d="M12 13l4-4M12 3v2" /></svg>
);
export const IconAnalyse = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><path d="M3 3v18h18" /><path d="M7 15l4-5 3 3 5-6" /></svg>
);
export const IconLogger = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><rect x="4" y="3" width="16" height="18" rx="2" /><path d="M8 8h8M8 12h8M8 16h5" /></svg>
);
export const IconScanner = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><path d="M5 9h14M5 15h14M9 4v16M15 4v16" /></svg>
);
export const IconSettings = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6" /></svg>
);
export const IconNotice = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true">
    <path d="M12 9v4M12 17h.01" /><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z" />
  </svg>
);
export const IconMore = ({ s = 20 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><circle cx="5" cy="12" r="1" /><circle cx="12" cy="12" r="1" /><circle cx="19" cy="12" r="1" /></svg>
);
export const IconCheck = ({ s = 16 }) => (
  <svg width={s} height={s} viewBox="0 0 24 24" {...P} aria-hidden="true"><path d="M5 12l5 5 9-10" /></svg>
);
