import type { ServerWebSocket } from 'bun';

import type { Announcement } from './db';

export interface SocketData {
  userId: number;
  username: string;
  name: string;
  role: 'admin' | 'student';
  groupName: string | null;
}

type Socket = ServerWebSocket<SocketData>;

const connections = new Map<number, Set<Socket>>();

export function registerSocket(ws: Socket): number {
  const set = connections.get(ws.data.userId) ?? new Set<Socket>();
  set.add(ws);
  connections.set(ws.data.userId, set);
  return onlineCount();
}

export function unregisterSocket(ws: Socket): number {
  const set = connections.get(ws.data.userId);
  if (set) {
    set.delete(ws);
    if (set.size === 0) connections.delete(ws.data.userId);
  }
  return onlineCount();
}

export function onlineCount(): number {
  let count = 0;
  for (const set of connections.values()) count += set.size;
  return count;
}

export function onlineUsers(): string[] {
  const users = new Set<string>();
  for (const set of connections.values()) {
    for (const ws of set) users.add(ws.data.username);
  }
  return [...users].sort();
}

export function send(ws: Socket, payload: unknown): void {
  if (ws.readyState !== WebSocket.OPEN) return;
  try {
    ws.send(JSON.stringify(payload));
  } catch {
    // A dead socket is cleaned up by its close handler.
  }
}

function canSee(ws: Socket, announcement: Announcement): boolean {
  if (ws.data.role === 'admin') return true;
  if (announcement.audience === 'all') return true;
  if (!ws.data.groupName) return false;
  return announcement.target_groups.includes(ws.data.groupName);
}

function broadcastTargeted(announcement: Announcement, payload: unknown): void {
  for (const set of connections.values()) {
    for (const ws of set) {
      if (canSee(ws, announcement)) send(ws, payload);
    }
  }
}

export function notifyAnnouncement(announcement: Announcement): void {
  broadcastTargeted(announcement, {
    type: 'announcement:new',
    data: announcement,
  });
}

export function notifyAnnouncementUpdated(announcement: Announcement): void {
  broadcastTargeted(announcement, {
    type: 'announcement:updated',
    data: announcement,
  });
}

export function notifyAnnouncementDeleted(announcement: Announcement): void {
  broadcastTargeted(announcement, {
    type: 'announcement:deleted',
    data: { id: announcement.id },
  });
}

export function notifyReset(): void {
  for (const set of connections.values()) {
    for (const ws of set) send(ws, { type: 'demo:reset' });
  }
}
