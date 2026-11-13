import { existsSync, statSync } from 'node:fs';
import { extname, join, resolve, sep } from 'node:path';

import { WEB_DIST } from './config';

const MIME: Record<string, string> = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.txt': 'text/plain; charset=utf-8',
};

function headersFor(file: string, immutable: boolean): Record<string, string> {
  return {
    'Content-Type': MIME[extname(file).toLowerCase()] ?? 'application/octet-stream',
    'Cache-Control': immutable
      ? 'public, max-age=31536000, immutable'
      : 'no-cache',
  };
}

function missingDistPage(): Response {
  return new Response(
    `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Megafonito · falta compilar la landing</title>
  <style>
    body{margin:0;min-height:100vh;display:grid;place-items:center;background:#FCFCFD;color:#14213D;font-family:system-ui,sans-serif}
    main{max-width:560px;padding:32px;border:1px solid #D6DBE4;border-radius:24px;background:#fff;box-shadow:0 20px 60px rgba(20,33,61,.10)}
    h1{margin:0 0 8px;font-size:26px}p{line-height:1.6;color:#4b5563}
    code{display:block;margin-top:16px;padding:14px 16px;border-radius:14px;background:#14213D;color:#FCA311;font-size:14px}
  </style>
</head>
<body>
  <main>
    <h1>La landing todavía no está compilada</h1>
    <p>El servidor está funcionando, pero no encontró <strong>web/dist</strong>.</p>
    <p>Ejecuta:</p>
    <code>bun run build:web</code>
  </main>
</body>
</html>`,
    {
      status: 200,
      headers: { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-cache' },
    },
  );
}

export function serveWeb(pathname: string): Response | null {
  const indexFile = join(WEB_DIST, 'index.html');
  if (!existsSync(indexFile)) return missingDistPage();

  let relative = pathname.replace(/^\/+/, '');
  if (relative.length === 0) relative = 'index.html';

  const requested = resolve(WEB_DIST, relative);
  const allowedRoot = resolve(WEB_DIST) + sep;
  if (requested !== resolve(indexFile) && !requested.startsWith(allowedRoot)) {
    return new Response('Forbidden', { status: 403 });
  }

  if (existsSync(requested) && statSync(requested).isFile()) {
    const immutable = pathname.startsWith('/_astro/');
    return new Response(Bun.file(requested), {
      headers: headersFor(requested, immutable),
    });
  }

  const hasExtension = extname(relative).length > 0;
  if (hasExtension) return null;

  return new Response(Bun.file(indexFile), {
    headers: headersFor(indexFile, false),
  });
}
