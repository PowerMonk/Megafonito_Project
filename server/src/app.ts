import type { Server } from 'bun';
import type { Database } from 'bun:sqlite';

import {
  authenticate,
  createSession,
  endSession,
  getBearerToken,
  getRequestUser,
  getSessionUser,
  isAdmin,
} from './auth';
import {
  createAnnouncement,
  deleteAnnouncement,
  initDb,
  listAnnouncements,
  listStudentGroups,
  resetDemo,
  updateAnnouncement,
  type Audience,
  type CreateAnnouncementInput,
  type User,
} from './db';
import { buildLanUrls } from './network';
import {
  notifyAnnouncement,
  notifyAnnouncementDeleted,
  notifyAnnouncementUpdated,
  notifyReset,
  onlineUsers,
  registerSocket,
  send,
  unregisterSocket,
  type SocketData,
} from './realtime';
import { DEMO_ACCOUNTS } from './seed';
import { serveWeb } from './web';
import { APP_NAME, DEFAULT_PORT } from './config';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Authorization, Content-Type',
};

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      ...CORS,
    },
  });
}

function error(message: string, status = 400): Response {
  return json({ error: message }, status);
}

async function readJson(req: Request): Promise<Record<string, unknown> | null> {
  try {
    const body = await req.json();
    if (body && typeof body === 'object' && !Array.isArray(body)) {
      return body as Record<string, unknown>;
    }
    return null;
  } catch {
    return null;
  }
}

function parseId(value: string): number | null {
  const id = Number(value);
  return Number.isInteger(id) && id > 0 ? id : null;
}

function parseAnnouncementInput(
  body: Record<string, unknown>,
  studentGroups: string[],
): { input?: CreateAnnouncementInput; error?: string } {
  const title = typeof body.title === 'string' ? body.title.trim() : '';
  const content = typeof body.content === 'string' ? body.content.trim() : '';
  const category =
    typeof body.category === 'string' && body.category.trim().length > 0
      ? body.category.trim()
      : 'General';

  if (!title) return { error: 'El título es obligatorio' };
  if (title.length > 160) return { error: 'El título es demasiado largo' };
  if (!content) return { error: 'El contenido es obligatorio' };
  if (content.length > 20000) return { error: 'El contenido es demasiado largo' };

  const audience: Audience = body.audience === 'groups' ? 'groups' : 'all';
  let groups: string[] = [];

  if (audience === 'groups') {
    if (!Array.isArray(body.groups)) {
      return { error: 'Selecciona al menos un grupo' };
    }
    groups = [
      ...new Set(
        body.groups
          .filter((group): group is string => typeof group === 'string')
          .map((group) => group.trim())
          .filter((group) => group.length > 0),
      ),
    ];
    if (groups.length === 0) {
      return { error: 'Selecciona al menos un grupo' };
    }
    const invalid = groups.filter((group) => !studentGroups.includes(group));
    if (invalid.length > 0) {
      return { error: `Grupo no válido: ${invalid.join(', ')}` };
    }
  }

  return { input: { title, content, category, audience, groups } };
}

export interface CreateAppOptions {
  dbPath: string;
  port?: number;
  quiet?: boolean;
}

export interface MegafonitoApp {
  db: Database;
  server: Server<SocketData>;
  stop: () => void;
}

export async function createApp(
  options: CreateAppOptions,
): Promise<MegafonitoApp> {
  const db = await initDb(options.dbPath);
  const quiet = options.quiet ?? false;
  const log = (...args: unknown[]) => {
    if (!quiet) console.log(...args);
  };

  const server = Bun.serve<SocketData>({
    port: options.port ?? DEFAULT_PORT,
    hostname: '0.0.0.0',
    development: false,
    async fetch(req, server) {
      if (req.method === 'OPTIONS') {
        return new Response(null, { status: 204, headers: CORS });
      }

      const url = new URL(req.url);
      const path = url.pathname;

      try {
        if (path === '/api/health') {
          return json({
            ok: true,
            app: APP_NAME,
            version: '1.0.0',
            time: new Date().toISOString(),
            online: onlineUsers(),
          });
        }

        if (path === '/api/server-info') {
          return json({
            ok: true,
            app: APP_NAME,
            version: '1.0.0',
            urls: await buildLanUrls(server.port),
            accounts: DEMO_ACCOUNTS,
            online: onlineUsers(),
          });
        }

        if (path === '/api/login' && req.method === 'POST') {
          const body = await readJson(req);
          const username =
            typeof body?.username === 'string' ? body.username : '';
          const password =
            typeof body?.password === 'string' ? body.password : '';
          if (!username || !password) {
            return error('Escribe tu usuario y contraseña');
          }

          const user = await authenticate(db, username, password);
          if (!user) return error('Usuario o contraseña incorrectos', 401);

          const token = createSession(user.id);
          log(`[login] ${user.username} (${user.role})`);
          return json({ token, user });
        }

        if (path === '/api/logout' && req.method === 'POST') {
          endSession(getBearerToken(req));
          return json({ ok: true });
        }

        if (path === '/api/me') {
          const user = getRequestUser(db, req);
          if (!user) return error('Sesión expirada', 401);
          return json({ user });
        }

        if (path === '/api/groups') {
          const user = getRequestUser(db, req);
          if (!user) return error('Sesión expirada', 401);
          return json({ groups: listStudentGroups(db) });
        }

        if (path === '/api/announcements' && req.method === 'GET') {
          const user = getRequestUser(db, req);
          if (!user) return error('Sesión expirada', 401);

          const page = Number(url.searchParams.get('page') ?? '1');
          const limit = Number(url.searchParams.get('limit') ?? '5');
          const category = url.searchParams.get('category');
          const sort = url.searchParams.get('sort');

          return json(
            listAnnouncements(db, user, { page, limit, category, sort }),
          );
        }

        if (path === '/api/announcements' && req.method === 'POST') {
          const user = getRequestUser(db, req);
          if (!user) return error('Sesión expirada', 401);
          if (!isAdmin(user)) {
            return error('Solo un administrador puede publicar anuncios', 403);
          }

          const body = await readJson(req);
          if (!body) return error('Datos inválidos');

          const parsed = parseAnnouncementInput(body, listStudentGroups(db));
          if (!parsed.input) return error(parsed.error ?? 'Datos inválidos');

          const announcement = createAnnouncement(db, user, parsed.input);
          notifyAnnouncement(announcement);
          log(
            `[announcement] #${announcement.id} "${announcement.title}" -> ${announcement.audience_label}`,
          );
          return json(announcement, 201);
        }

        if (path.startsWith('/api/announcements/')) {
          const id = parseId(path.slice('/api/announcements/'.length));
          if (!id) return error('Anuncio no válido', 400);

          const user = getRequestUser(db, req);
          if (!user) return error('Sesión expirada', 401);
          if (!isAdmin(user)) {
            return error('Solo un administrador puede modificar anuncios', 403);
          }

          if (req.method === 'PUT') {
            const body = await readJson(req);
            if (!body) return error('Datos inválidos');
            const parsed = parseAnnouncementInput(body, listStudentGroups(db));
            if (!parsed.input) return error(parsed.error ?? 'Datos inválidos');

            const updated = updateAnnouncement(db, id, parsed.input);
            if (!updated) return error('Anuncio no encontrado', 404);
            notifyAnnouncementUpdated(updated);
            log(`[announcement] #${updated.id} actualizado`);
            return json(updated);
          }

          if (req.method === 'DELETE') {
            const deleted = deleteAnnouncement(db, id);
            if (!deleted) return error('Anuncio no encontrado', 404);
            notifyAnnouncementDeleted(deleted);
            log(`[announcement] #${deleted.id} eliminado`);
            return json({ ok: true });
          }

          return error('Método no permitido', 405);
        }

        if (path === '/api/demo/reset' && req.method === 'POST') {
          resetDemo(db);
          notifyReset();
          log('[demo] anuncios eliminados; usuarios conservados');
          return json({ ok: true });
        }

        if (path === '/ws') {
          const token = url.searchParams.get('token');
          const user = getSessionUser(db, token);
          if (!user) return error('Sesión expirada', 401);

          const upgraded = server.upgrade(req, {
            data: {
              userId: user.id,
              username: user.username,
              name: user.name,
              role: user.role,
              groupName: user.group_name,
            },
          });
          if (!upgraded) return error('No se pudo abrir el canal en tiempo real', 400);
          return undefined;
        }

        if (path.startsWith('/api/')) {
          return error('Ruta no encontrada', 404);
        }

        const staticResponse = serveWeb(path);
        if (staticResponse) return staticResponse;

        return error('No encontrado', 404);
      } catch (err) {
        console.error('[server]', err);
        return error('Error interno del servidor', 500);
      }
    },
    websocket: {
      open(ws) {
        const online = registerSocket(ws);
        send(ws, {
          type: 'hello',
          data: {
            username: ws.data.username,
            name: ws.data.name,
            role: ws.data.role,
            group: ws.data.groupName,
          },
        });
        log(
          `[ws] ${ws.data.username} conectado · ${online} conexión(es) activa(s)`,
        );
      },
      message(ws, message) {
        try {
          const payload = JSON.parse(String(message)) as { type?: string };
          if (payload.type === 'ping') send(ws, { type: 'pong' });
        } catch {
          // Ignore malformed client messages.
        }
      },
      close(ws) {
        const online = unregisterSocket(ws);
        log(
          `[ws] ${ws.data.username} desconectado · ${online} conexión(es) activa(s)`,
        );
      },
    },
  });

  return {
    db,
    server,
    stop: () => {
      server.stop(true);
      db.close();
    },
  };
}
