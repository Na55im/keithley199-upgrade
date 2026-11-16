import { useEffect, useState } from 'react';
import { useStore } from './store';
import { Measure } from './screens/Measure';
import { Analyse } from './screens/Analyse';
import { Connect } from './screens/Connect';
import { Logger, Notices, Scanner, Settings } from './screens/Others';
import { IconAnalyse, IconLogger, IconLogo, IconMeasure, IconMore, IconNotice, IconScanner, IconSettings } from './components/Icons';

type Page = 'measure' | 'analyse' | 'logger' | 'scanner' | 'settings' | 'notices';
const NAV: { id: Page; label: string; Icon: (p: { s?: number }) => JSX.Element }[] = [
  { id: 'measure', label: 'Messen', Icon: IconMeasure },
  { id: 'analyse', label: 'Analyse', Icon: IconAnalyse },
  { id: 'logger', label: 'Logger', Icon: IconLogger },
  { id: 'scanner', label: 'Scanner-Kanäle', Icon: IconScanner },
  { id: 'settings', label: 'Einstellungen', Icon: IconSettings },
  { id: 'notices', label: 'Hinweise', Icon: IconNotice },
];

function pageFromHash(): Page {
  const h = location.hash.slice(1) as Page;
  return NAV.some((n) => n.id === h) ? h : 'measure';
}

export default function App() {
  const { info } = useStore();
  const [page, setPageState] = useState<Page>(pageFromHash);
  const [connectOpen, setConnectOpen] = useState(false);
  const [dismissed, setDismissed] = useState(false);
  const [now, setNow] = useState(Date.now() / 1000);
  useEffect(() => { const id = setInterval(() => setNow(Date.now() / 1000), 500); return () => clearInterval(id); }, []);
  useEffect(() => { const f = () => setPageState(pageFromHash()); addEventListener('hashchange', f); return () => removeEventListener('hashchange', f); }, []);
  useEffect(() => { document.documentElement.dataset.theme = info.settings?.theme === 'dark' ? 'dark' : 'light'; }, [info.settings?.theme]);
  const setPage = (p: Page) => { location.hash = p; setPageState(p); };

  // connect dialog: on start until the device is found once, or on request
  const showConnect = connectOpen || (!dismissed && info.status !== 'connected' && info.status !== 'offline');
  const compact = page === 'analyse';
  const st = info.state;
  const ok = info.status === 'connected';
  const nNotices = info.notices.length;
  const digits = st ? `${st.digits}½ Stellen` : '';

  return (
    <div className="shell">
      <nav aria-label="Hauptnavigation" className={'nav' + (compact ? ' compact' : '')}>
        <div className="brand">
          <div className="brand-mark"><IconLogo /></div>
          {!compact && <span className="brand-name">KLAR</span>}
        </div>
        {NAV.map(({ id, label, Icon }) => (
          <button key={id} type="button" className="nav-item" aria-current={page === id ? 'page' : undefined}
            aria-label={compact ? label : undefined} title={compact ? label : undefined} onClick={() => setPage(id)}>
            <Icon s={compact ? 22 : 20} />{!compact && label}
            {!compact && id === 'notices' && nNotices > 0 && <span className="badge">{nNotices}</span>}
          </button>
        ))}
        {!compact && (
          <button type="button" className="devcard" onClick={() => setConnectOpen(true)}>
            <span className="devcard-title"><span className={'dot ' + (ok ? 'ok' : 'off')} />Keithley 199</span>
            <span className="devcard-sub">
              {ok ? (info.port === 'Simulator' ? 'Simulator' : 'USB-Seriell · ' + info.port.replace('/dev/', '')) : info.status === 'searching' ? 'sucht …' : 'nicht verbunden'}
              <br />{info.build ? 'Firmware ' + info.build : ''}{digits ? ' · ' + digits : ''}
            </span>
          </button>
        )}
      </nav>

      <main className="page">
        {info.status === 'offline' && <div className="tag warn" style={{ alignSelf: 'flex-start' }}>KLAR-Programm nicht erreichbar – wird neu verbunden …</div>}
        {page === 'measure' && <Measure now={now} />}
        {page === 'analyse' && <Analyse />}
        {page === 'logger' && <Logger now={now} openAnalyse={() => setPage('analyse')} />}
        {page === 'scanner' && <Scanner />}
        {page === 'settings' && <Settings openConnect={() => setConnectOpen(true)} />}
        {page === 'notices' && <Notices />}
      </main>

      <nav aria-label="Navigation" className="bottomnav">
        {([['measure', 'Messen', IconMeasure], ['analyse', 'Analyse', IconAnalyse], ['logger', 'Logger', IconLogger], ['settings', 'Mehr', IconMore]] as const).map(([id, label, Icon]) => (
          <button key={id} type="button" aria-current={page === id || (id === 'settings' && ['scanner', 'notices'].includes(page)) ? 'page' : undefined}
            onClick={() => setPage(id as Page)}><Icon s={22} />{label}</button>
        ))}
      </nav>

      {showConnect && <Connect onClose={() => { setConnectOpen(false); setDismissed(true); }} />}
    </div>
  );
}
