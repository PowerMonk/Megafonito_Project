import { afterAll, beforeAll, describe, expect, test } from 'bun:test';
import { randomUUID } from 'node:crypto';
import { rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

import { createApp, type MegafonitoApp } from '../src/app';

const dbPath = join(tmpdir(), `megafonito-test-${randomUUID()}.db`);

let app: MegafonitoApp;
let base = '';

interface ApiResult {
  status: number;
  body: any;
  text: string;
}

async function api(
  path: string,
  options: {
    method?: string;
    token?: string;
    body?: Record<string, unknown>;
  } = {},
): Promise<ApiResult> {
  const headers: Record<string, string> = {};
  if (options.body) headers['Content-Type'] = 'application/json';
  if (options.token) headers.Authorization = `Bearer ${options.token}`;

  const response = await fetch(`${base}${path}`, {
    method: options.method ?? 'GET',
    headers,
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  const text = await response.text();
  let body: any = null;
  try {
    body = JSON.parse(text);
  } catch {
    body = null;
  }
  return { status: response.status, body, text };
}

async function login(username: string, password: string): Promise<string> {
  const result = await api('/api/login', {
    method: 'POST',
    body: { username, password },
  });
  expect(result.status).toBe(200);
  return result.body.token as string;
}

interface WsMessage {
  type: string;
  data?: any;
}

class WsClient {
  private readonly messages: WsMessage[] = [];
  private readonly waiters: {
    predicate: (message: WsMessage) => boolean;
    resolve: (message: WsMessage) => void;
    reject: (error: Error) => void;
    timer: ReturnType<typeof setTimeout>;
  }[] = [];

  private constructor(private readonly socket: WebSocket) {}

  static connect(token: string): Promise<WsClient> {
    return new Promise((resolve, reject) => {
      const socket = new WebSocket(
        `ws://127.0.0.1:${app.server.port}/ws?token=${token}`,
      );
      const client = new WsClient(socket);

      socket.addEventListener('message', (event) => {
        const message = JSON.parse(String(event.data)) as WsMessage;
        client.messages.push(message);
        client.flush();
      });
      socket.addEventListener('open', () => resolve(client));
      socket.addEventListener('error', () =>
        reject(new Error('WebSocket connection failed')),
      );
    });
  }

  private flush(): void {
    for (let index = this.waiters.length - 1; index >= 0; index -= 1) {
      const waiter = this.waiters[index];
      const message = this.messages.find(waiter.predicate);
      if (!message) continue;
      clearTimeout(waiter.timer);
      this.waiters.splice(index, 1);
      waiter.resolve(message);
    }
  }

  waitFor(
    predicate: (message: WsMessage) => boolean,
    timeout = 2500,
  ): Promise<WsMessage> {
    const existing = this.messages.find(predicate);
    if (existing) return Promise.resolve(existing);

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        const index = this.waiters.findIndex((item) => item.timer === timer);
        if (index >= 0) this.waiters.splice(index, 1);
        reject(new Error('Timed out waiting for WebSocket message'));
      }, timeout);
      this.waiters.push({ predicate, resolve, reject, timer });
    });
  }

  close(): void {
    this.socket.close();
  }
}

beforeAll(async () => {
  app = await createApp({ dbPath, port: 0, quiet: true });
  base = `http://127.0.0.1:${app.server.port}`;
});

afterAll(async () => {
  app.stop();
  await Bun.sleep(100);
  for (const path of [dbPath, `${dbPath}-wal`, `${dbPath}-shm`]) {
    try {
      rmSync(path, { force: true, maxRetries: 5, retryDelay: 100 });
    } catch {
      // Windows may hold the SQLite handle for a moment; temp files are harmless.
    }
  }
});

describe('Megafonito demo server', () => {
  test('health and login', async () => {
    const health = await api('/api/health');
    expect(health.status).toBe(200);
    expect(health.body.ok).toBe(true);

    const bad = await api('/api/login', {
      method: 'POST',
      body: { username: 'admin', password: 'nope' },
    });
    expect(bad.status).toBe(401);

    const good = await api('/api/login', {
      method: 'POST',
      body: { username: 'admin', password: 'admin123' },
    });
    expect(good.status).toBe(200);
    expect(good.body.user.role).toBe('admin');
    expect(typeof good.body.token).toBe('string');
  });

  test('group audience filtering keeps students isolated', async () => {
    const admin = await login('admin', 'admin123');
    const student1 = await login('student1', '1234');
    const student2 = await login('student2', '1234');

    let list1 = await api('/api/announcements', { token: student1 });
    let list2 = await api('/api/announcements', { token: student2 });
    expect(list1.body.pagination.totalItems).toBe(0);
    expect(list2.body.pagination.totalItems).toBe(0);

    const forSystems = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Solo Sistemas',
        content: 'Aviso para el grupo de Sistemas.',
        category: 'Eventos',
        audience: 'groups',
        groups: ['Ingeniería en Sistemas Computacionales'],
      },
    });
    expect(forSystems.status).toBe(201);
    expect(forSystems.body.audience_label).toBe(
      'Ingeniería en Sistemas Computacionales',
    );

    list1 = await api('/api/announcements', { token: student1 });
    list2 = await api('/api/announcements', { token: student2 });
    expect(list1.body.pagination.totalItems).toBe(1);
    expect(list1.body.data[0].title).toBe('Solo Sistemas');
    expect(list2.body.pagination.totalItems).toBe(0);

    const forMechanics = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Solo Mecánica',
        content: 'Aviso para el grupo de Mecánica.',
        category: 'Convocatorias',
        audience: 'groups',
        groups: ['Ingeniería Mecánica'],
      },
    });
    expect(forMechanics.status).toBe(201);

    list1 = await api('/api/announcements', { token: student1 });
    list2 = await api('/api/announcements', { token: student2 });
    expect(list1.body.pagination.totalItems).toBe(1);
    expect(list1.body.data[0].title).toBe('Solo Sistemas');
    expect(list2.body.pagination.totalItems).toBe(1);
    expect(list2.body.data[0].title).toBe('Solo Mecánica');

    const everyone = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Para toda la escuela',
        content: 'Aviso general.',
        category: 'General',
        audience: 'all',
        groups: [],
      },
    });
    expect(everyone.status).toBe(201);

    list1 = await api('/api/announcements', { token: student1 });
    list2 = await api('/api/announcements', { token: student2 });
    expect(list1.body.pagination.totalItems).toBe(2);
    expect(list2.body.pagination.totalItems).toBe(2);

    const all = await api('/api/announcements', { token: admin });
    expect(all.body.pagination.totalItems).toBe(3);
  });

  test('only admins can publish and groups must be valid', async () => {
    const admin = await login('admin', 'admin123');
    const student1 = await login('student1', '1234');

    const forbidden = await api('/api/announcements', {
      method: 'POST',
      token: student1,
      body: {
        title: 'No permitido',
        content: 'Un alumno no puede publicar.',
        audience: 'all',
        groups: [],
      },
    });
    expect(forbidden.status).toBe(403);

    const invalidGroup = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Grupo inexistente',
        content: 'No debería guardarse.',
        audience: 'groups',
        groups: ['Ingeniería Química'],
      },
    });
    expect(invalidGroup.status).toBe(400);
  });

  test('update, delete, and reset work', async () => {
    const admin = await login('admin', 'admin123');

    const created = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Original',
        content: 'Contenido original.',
        category: 'General',
        audience: 'all',
        groups: [],
      },
    });
    expect(created.status).toBe(201);
    const id = created.body.id as number;

    const updated = await api(`/api/announcements/${id}`, {
      method: 'PUT',
      token: admin,
      body: {
        title: 'Actualizado',
        content: 'Contenido nuevo.',
        category: 'Comunidad',
        audience: 'all',
        groups: [],
      },
    });
    expect(updated.status).toBe(200);
    expect(updated.body.title).toBe('Actualizado');

    const deleted = await api(`/api/announcements/${id}`, {
      method: 'DELETE',
      token: admin,
    });
    expect(deleted.status).toBe(200);

    const reset = await api('/api/demo/reset', { method: 'POST' });
    expect(reset.status).toBe(200);

    const list = await api('/api/announcements', { token: admin });
    expect(list.body.pagination.totalItems).toBe(0);
  });

  test('WebSocket pushes only to the matching group', async () => {
    const admin = await login('admin', 'admin123');
    const student1 = await login('student1', '1234');
    const student2 = await login('student2', '1234');

    const ws1 = await WsClient.connect(student1);
    const ws2 = await WsClient.connect(student2);

    await ws1.waitFor((message) => message.type === 'hello');
    await ws2.waitFor((message) => message.type === 'hello');

    const systems = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Tiempo real Sistemas',
        content: 'Debe llegar solo a student1.',
        category: 'Eventos',
        audience: 'groups',
        groups: ['Ingeniería en Sistemas Computacionales'],
      },
    });
    expect(systems.status).toBe(201);

    const receivedByStudent1 = await ws1.waitFor(
      (message) =>
        message.type === 'announcement:new' &&
        message.data?.title === 'Tiempo real Sistemas',
    );
    expect(receivedByStudent1.data.title).toBe('Tiempo real Sistemas');

    const receivedByStudent2 = await ws2
      .waitFor(
        (message) =>
          message.type === 'announcement:new' &&
          message.data?.title === 'Tiempo real Sistemas',
        450,
      )
      .catch(() => null);
    expect(receivedByStudent2).toBeNull();

    const mechanics = await api('/api/announcements', {
      method: 'POST',
      token: admin,
      body: {
        title: 'Tiempo real Mecánica',
        content: 'Debe llegar solo a student2.',
        category: 'Deportivos',
        audience: 'groups',
        groups: ['Ingeniería Mecánica'],
      },
    });
    expect(mechanics.status).toBe(201);

    await ws2.waitFor(
      (message) =>
        message.type === 'announcement:new' &&
        message.data?.title === 'Tiempo real Mecánica',
    );

    ws1.close();
    ws2.close();
  });
});
