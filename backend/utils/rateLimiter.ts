import { Middleware } from "@oak/oak";

interface ClientData {
  count: number;
  resetTime: number;
}

export class AtomicRateLimiter {
  private rateLimitMap: Map<string, ClientData> = new Map();
  private locks: Map<string, boolean> = new Map();
  private lockQueue: Map<string, (() => void)[]> = new Map();

  private readonly windowMs = 15 * 60 * 1000; // 15 minutes
  private readonly limit = 100;

  public rateLimiter: Middleware = async (ctx, next) => {
    const ip = ctx.request.ip;
    const currentTime = Date.now();

    await this.acquireLock(ip);

    try {
      const clientData = this.processRateLimit(ip, currentTime);

      if (clientData.count > this.limit) {
        ctx.response.status = 429;
        ctx.response.body = "Rate limit exceeded";
        return;
      }

      await next();
    } finally {
      this.releaseLock(ip);
    }
  };

  private acquireLock(key: string): Promise<void> {
    return new Promise((resolve) => {
      const queue = this.lockQueue.get(key); // Get the queue or undefined
      if (!this.locks.get(key)) {
        this.locks.set(key, true);
        resolve();
      } else {
        // Check if queue exists
        if (!queue) {
          this.lockQueue.set(key, []);
        }
        this.lockQueue.get(key)!.push(resolve); // Now safe to use !
      }
    });
  }

  private releaseLock(key: string): void {
    const queue = this.lockQueue.get(key); // Get the queue or undefined
    if (queue && queue.length > 0) {
      //Check if the queue exists and is not empty
      const nextResolve = queue.shift();
      if (nextResolve) {
        // Check if nextResolve is not undefined
        nextResolve();
      }
    } else {
      this.locks.delete(key);
    }
  }

  private processRateLimit(ip: string, currentTime: number): ClientData {
    let clientData = this.rateLimitMap.get(ip);

    if (!clientData || currentTime > clientData.resetTime) {
      clientData = {
        count: 0,
        resetTime: currentTime + this.windowMs,
      };
    }

    clientData.count++;
    this.rateLimitMap.set(ip, clientData);

    return clientData;
  }
}

// Usage
const atomicRateLimiter = new AtomicRateLimiter();
export const rateLimiter = atomicRateLimiter.rateLimiter;
