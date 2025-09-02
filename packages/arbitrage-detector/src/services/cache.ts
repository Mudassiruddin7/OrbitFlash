import { Redis } from 'ioredis';

export class CacheService {
  private redis: Redis;

  constructor(redisUrl?: string) {
    this.redis = new Redis(redisUrl || 'redis://localhost:6379');
  }

  // Price feed cache: 100ms TTL
  async setPriceFeedData(key: string, data: any): Promise<void> {
    await this.redis.setex(`price:${key}`, 0.1, JSON.stringify(data));
  }

  async getPriceFeedData(key: string): Promise<any | null> {
    const data = await this.redis.get(`price:${key}`);
    return data ? JSON.parse(data) : null;
  }

  // Liquidity pool state cache: 500ms TTL
  async setPoolState(key: string, data: any): Promise<void> {
    await this.redis.setex(`pool:${key}`, 0.5, JSON.stringify(data));
  }

  async getPoolState(key: string): Promise<any | null> {
    const data = await this.redis.get(`pool:${key}`);
    return data ? JSON.parse(data) : null;
  }

  // Gas price estimates: 1-second TTL
  async setGasPrice(key: string, data: any): Promise<void> {
    await this.redis.setex(`gas:${key}`, 1, JSON.stringify(data));
  }

  async getGasPrice(key: string): Promise<any | null> {
    const data = await this.redis.get(`gas:${key}`);
    return data ? JSON.parse(data) : null;
  }

  // Generic cache methods
  async set(key: string, data: any, ttlSeconds: number): Promise<void> {
    await this.redis.setex(key, ttlSeconds, JSON.stringify(data));
  }

  async get(key: string): Promise<any | null> {
    const data = await this.redis.get(key);
    return data ? JSON.parse(data) : null;
  }

  async del(key: string): Promise<void> {
    await this.redis.del(key);
  }

  // Pub/Sub methods
  async publish(channel: string, message: any): Promise<void> {
    await this.redis.publish(channel, JSON.stringify(message));
  }

  async subscribe(channel: string, callback: (message: any) => void): Promise<void> {
    const subscriber = new Redis(this.redis.options);
    await subscriber.subscribe(channel);
    subscriber.on('message', (receivedChannel: string, message: string) => {
      if (receivedChannel === channel) {
        try {
          const parsedMessage = JSON.parse(message);
          callback(parsedMessage);
        } catch (error) {
          console.error('Error parsing Redis message:', error);
        }
      }
    });
  }

  async disconnect(): Promise<void> {
    await this.redis.disconnect();
  }
}
