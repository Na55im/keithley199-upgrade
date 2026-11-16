"""KLAR backend: FastAPI + WebSocket around the device manager.

    python server.py [--host 127.0.0.1] [--port 8199x] [--sim]

Serves the built frontend (frontend/dist) at /, the WebSocket at /ws and the
REST API under /api. Only the 199 is controlled; no calibration commands exist.
"""
import argparse
import asyncio
import io
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from fastapi import FastAPI, HTTPException, Request, WebSocket, WebSocketDisconnect
from fastapi.responses import FileResponse, JSONResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles

import device as D
from instrument import protocol as P
from instrument import transport as T

DIST = os.environ.get('KLAR_DIST') or os.path.join(os.path.dirname(HERE), 'frontend', 'dist')

app = FastAPI(title='KLAR')
dev: D.Device = None


def _same_origin(request: Request):
    """Reject state-changing requests from other web pages (CSRF)."""
    origin = request.headers.get('origin')
    if origin and origin.split('://', 1)[-1] != request.headers.get('host'):
        raise HTTPException(403, 'foreign origin')


# ------------------------------------------------------------------ websocket
@app.websocket('/ws')
async def ws(sock: WebSocket):
    origin = sock.headers.get('origin')
    if origin and origin.split('://', 1)[-1] != sock.headers.get('host'):
        await sock.close(code=4403)
        return
    await sock.accept()
    loop = asyncio.get_running_loop()
    q: asyncio.Queue = asyncio.Queue(maxsize=5000)

    def push(msg):
        def put():
            if not q.full():
                q.put_nowait(msg)
        loop.call_soon_threadsafe(put)

    dev.subscribe(push)
    try:
        await sock.send_json(dev.info())

        async def sender():
            while True:
                batch = [await q.get()]
                await asyncio.sleep(0.05)              # batch readings: max 20 frames/s
                while not q.empty() and len(batch) < 1000:
                    batch.append(q.get_nowait())
                await sock.send_json({'t': 'batch', 'msgs': batch})

        async def receiver():
            while True:
                msg = await sock.receive_json()
                if msg.get('cmd'):
                    dev.send(*[c for c in str(msg['cmd']).split('\n') if c.strip()])

        await asyncio.gather(sender(), receiver())
    except (WebSocketDisconnect, RuntimeError):
        pass
    finally:
        dev.unsubscribe(push)


# ------------------------------------------------------------------ api
@app.get('/api/info')
def api_info():
    return dev.info()


@app.post('/api/cmd')
async def api_cmd(request: Request):
    _same_origin(request)
    body = await request.json()
    cmds = [c for c in str(body.get('cmd', '')).split('\n') if c.strip()]
    if not dev.send(*cmds):
        raise HTTPException(503, 'nicht verbunden')
    return {'ok': True}


@app.post('/api/mode/{mode}')
def api_mode(mode: str, request: Request):
    _same_origin(request)
    if mode not in P.MODES:
        raise HTTPException(400, 'unknown mode')
    if not dev.set_mode(mode):
        raise HTTPException(503, 'nicht verbunden')
    return {'ok': True}


@app.post('/api/record/{action}')
def api_record(action: str, request: Request):
    _same_origin(request)
    if action == 'start':
        return dev.start_recording().info()
    if action == 'stop':
        r = dev.stop_recording()
        return r.info() if r else {}
    raise HTTPException(400, 'start|stop')


@app.post('/api/settings')
async def api_settings(request: Request):
    _same_origin(request)
    dev.save_settings(await request.json())
    return dev.settings


@app.get('/api/ports')
def api_ports():
    return {'ports': T.list_serial_ports(), 'current': dev.port_name, 'setting': dev.settings.get('port')}


@app.post('/api/reconnect')
def api_reconnect(request: Request):
    _same_origin(request)
    dev.reconnect.set()
    return {'ok': True}


@app.delete('/api/notices')
def api_notices_clear(request: Request):
    _same_origin(request)
    dev.notices.clear()
    dev.emit(dev.info())
    return {'ok': True}


@app.get('/api/recordings')
def api_recordings():
    out = [r.info() for r in reversed(dev.recordings)]
    live = dev.live
    out.append({'id': 'live', 'start': live.t[0] if len(live) else None, 'stop': None,
                'func': live.func, 'unit': P.UNIT.get(live.func or 'DCV', ''), 'points': len(live),
                'channels': live.channels(), 'file': None, 'notes': []})
    return out


def _series(rid):
    try:
        rec = dev.get_recording(rid)
    except KeyError:
        raise HTTPException(404, 'unknown recording')
    return (rec.series if rec else dev.live), rec


def _chan_data(series, t0, t1, chan, field='v'):
    with dev.lock:
        i0, i1, ts = series.window(t0, t1)
        vals = list(getattr(series, field))[i0:i1]
        chs = list(series.ch)[i0:i1]
        ts = ts[i0:i1]
    if chan is None:
        return ts, vals
    sel = [i for i, c in enumerate(chs) if c == chan]
    return [ts[i] for i in sel], [vals[i] for i in sel]


@app.get('/api/recordings/{rid}/series')
def api_series(rid: str, t0: float = None, t1: float = None, points: int = 1500, raw: int = 0):
    series, rec = _series(rid)
    field = 'raw' if raw else 'v'
    out = {}
    for c in series.channels() or [0]:
        ts, vs = _chan_data(series, t0, t1, c, field)
        out[str(c)] = D.downsample(ts, vs, max(10, min(points, 5000)))
    return {'channels': out, 'info': rec.info() if rec else None}


@app.get('/api/recordings/{rid}/stats')
def api_stats(rid: str, t0: float = None, t1: float = None, chan: int = None, raw: int = 0):
    series, _ = _series(rid)
    ts, vs = _chan_data(series, t0, t1, chan, 'raw' if raw else 'v')
    return D.stats(ts, vs)


@app.post('/api/recordings/{rid}/notes')
async def api_note(rid: str, request: Request):
    _same_origin(request)
    _, rec = _series(rid)
    if rec is None:
        raise HTTPException(400, 'Notizen nur in Aufnahmen')
    body = await request.json()
    rec.notes.append({'t': float(body.get('t', time.time())), 'text': str(body.get('text', ''))[:200]})
    return rec.info()


@app.get('/api/recordings/{rid}/csv')
def api_csv(rid: str, t0: float = None, t1: float = None):
    series, rec = _series(rid)
    with dev.lock:
        i0, i1, ts = series.window(t0, t1)
        rows = list(zip(ts[i0:i1], list(series.v)[i0:i1], list(series.raw)[i0:i1],
                        list(series.ch)[i0:i1], list(series.flags)[i0:i1]))
    func = (rec.func if rec else series.func) or 'DCV'
    unit = P.UNIT.get(func, '')
    start = rows[0][0] if rows else time.time()
    buf = io.StringIO()
    buf.write('timestamp;t_s;value;unit;raw;function;range;channel;flags\n')
    for t, v, r, c, fl in rows:
        buf.write('%s.%03d;%.3f;%.9E;%s;%.9E;%s;;%d;%d\n' % (
            time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(t)), int(t * 1000) % 1000, t - start, v, unit, r,
            func, c, fl))
    name = time.strftime('k199_%Y%m%d_%H%M%S.csv', time.localtime(start))
    return StreamingResponse(iter([buf.getvalue()]), media_type='text/csv',
                             headers={'Content-Disposition': 'attachment; filename="%s"' % name})


# ------------------------------------------------------------------ frontend
if os.path.isdir(DIST):
    app.mount('/assets', StaticFiles(directory=os.path.join(DIST, 'assets')), name='assets')

    @app.get('/{path:path}')
    def spa(path: str):
        f = os.path.join(DIST, path)
        if path and os.path.isfile(f) and os.path.realpath(f).startswith(os.path.realpath(DIST)):
            return FileResponse(f)
        return FileResponse(os.path.join(DIST, 'index.html'))
else:
    @app.get('/')
    def no_frontend():
        return JSONResponse({'error': 'frontend not built: cd klar/frontend && npm run build'})


def main():
    global dev
    ap = argparse.ArgumentParser(description='KLAR backend')
    ap.add_argument('--host', default='127.0.0.1', help='0.0.0.0 = im LAN erreichbar (Tablet/Handy)')
    ap.add_argument('--port', type=int, default=8210)
    ap.add_argument('--sim', action='store_true', help='Simulator statt Gerät')
    a = ap.parse_args()
    dev = D.Device('sim' if a.sim else None)
    import uvicorn
    uvicorn.run(app, host=a.host, port=a.port, log_level='warning')


if __name__ == '__main__':
    main()
