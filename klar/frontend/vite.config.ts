import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// dev: npm run dev (proxy to the backend on 8210); prod: npm run build -> dist/ served by backend/server.py
export default defineConfig({
  plugins: [react()],
  server: { proxy: { '/api': 'http://127.0.0.1:8210', '/ws': { target: 'ws://127.0.0.1:8210', ws: true } } },
});
