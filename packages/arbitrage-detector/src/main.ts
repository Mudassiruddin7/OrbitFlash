import { PriceFeedManager, PriceData } from './services/priceFeed.js';
import { ProfitCalculator, PriceInput } from './services/profitCalculator.js';
import { CacheService } from './services/cache.js';
import { ArbitrageOpportunity } from '@orbitflash/shared-types';
import { Redis } from 'ioredis';

export class ArbitrageDetectorService {
  private redis: Redis;
  private priceFeedManager: PriceFeedManager;
  private profitCalculator: ProfitCalculator;
  private cacheService: CacheService;
  private isRunning = false;
  private priceDataBuffer: Map<string, PriceData[]> = new Map();

  constructor() {
    this.priceFeedManager = new PriceFeedManager();
    this.profitCalculator = new ProfitCalculator();
    this.cacheService = new CacheService();
    this.redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
    
    this.setupEventListeners();
  }

  private setupEventListeners(): void {
    // Listen for price updates from the price feed manager
    this.redis.on('message', async (_channel: string, message: string) => {
      await this.handlePriceUpdate(JSON.parse(message));
    });

    // Listen for Chainlink validation data
    this.priceFeedManager.on('chainlinkValidation', async (validationData: any) => {
      await this.handleChainlinkValidation(validationData);
    });
  }

  async start(): Promise<void> {
    if (this.isRunning) return;

    console.log('Starting ArbitrageDetectorService...');
    this.isRunning = true;

    // Start price feed manager
    await this.priceFeedManager.start();

    // Start opportunity detection loop
    this.startOpportunityDetection();

    console.log('ArbitrageDetectorService started successfully');
  }

  async stop(): Promise<void> {
    this.isRunning = false;
    await this.priceFeedManager.stop();
    await this.cacheService.disconnect();
    console.log('ArbitrageDetectorService stopped');
  }

  private async handlePriceUpdate(priceData: PriceData): Promise<void> {
    try {
      // Cache the price data
      const cacheKey = `${priceData.tokenA}-${priceData.tokenB}-${priceData.dex}`;
      await this.cacheService.setPriceFeedData(cacheKey, priceData);

      // Add to buffer for cross-DEX comparison
      const pairKey = this.getPairKey(priceData.tokenA, priceData.tokenB);
      
      if (!this.priceDataBuffer.has(pairKey)) {
        this.priceDataBuffer.set(pairKey, []);
      }
      
      const buffer = this.priceDataBuffer.get(pairKey)!;
      buffer.push(priceData);

      // Keep only recent data (last 10 updates per pair)
      if (buffer.length > 10) {
        buffer.shift();
      }

      // Trigger opportunity detection for this pair
      await this.detectOpportunitiesForPair(pairKey);

    } catch (error) {
      console.error('Error handling price update:', error);
    }
  }

  private async handleChainlinkValidation(validationData: any): Promise<void> {
    try {
      // Cache Chainlink validation data
      await this.cacheService.set(`chainlink:${validationData.pair}`, validationData, 30);
      
      console.log(`Chainlink validation for ${validationData.pair}: $${validationData.price}`);
    } catch (error) {
      console.error('Error handling Chainlink validation:', error);
    }
  }

  private async detectOpportunitiesForPair(pairKey: string): Promise<void> {
    try {
      const buffer = this.priceDataBuffer.get(pairKey);
      if (!buffer || buffer.length < 2) return;

      // Group by DEX to find cross-DEX opportunities
      const dexGroups = new Map<string, PriceData>();
      
      // Get the latest price from each DEX
      for (const priceData of buffer) {
        const existing = dexGroups.get(priceData.dex);
        if (!existing || priceData.timestamp > existing.timestamp) {
          dexGroups.set(priceData.dex, priceData);
        }
      }

      const dexPrices = Array.from(dexGroups.values());
      
      // Compare prices between different DEXs
      for (let i = 0; i < dexPrices.length; i++) {
        for (let j = i + 1; j < dexPrices.length; j++) {
          const priceA = dexPrices[i];
          const priceB = dexPrices[j];
          
          // Check cache for fresh data
          const cacheKeyA = `${priceA.tokenA}-${priceA.tokenB}-${priceA.dex}`;
          const cacheKeyB = `${priceB.tokenA}-${priceB.tokenB}-${priceB.dex}`;
          
          const [cachedA, cachedB] = await Promise.all([
            this.cacheService.getPriceFeedData(cacheKeyA),
            this.cacheService.getPriceFeedData(cacheKeyB)
          ]);

          if (!cachedA || !cachedB) continue;

          // Create price input for profit calculation
          const priceInput: PriceInput = {
            tokenAddress: priceA.tokenA,
            tokenA: priceA.tokenA,
            tokenB: priceA.tokenB,
            priceA: priceA.price,
            priceB: priceB.price,
            dexA: priceA.dex,
            dexB: priceB.dex,
            liquidityA: '1000000', // Placeholder - would get from pool state
            liquidityB: '1000000',  // Placeholder - would get from pool state
            price: parseFloat(priceA.price),
            liquidity: 1000000
          };

          // Calculate arbitrage opportunity
          const opportunity = this.profitCalculator.calculateArbitrageOpportunity(priceInput);
          
          if (opportunity) {
            await this.publishOpportunity(opportunity);
          }
        }
      }
    } catch (error) {
      console.error('Error detecting opportunities for pair:', error);
    }
  }

  private async publishOpportunity(opportunity: ArbitrageOpportunity): Promise<void> {
    try {
      console.log(`🚀 New arbitrage opportunity found: ${opportunity.id}`);
      console.log(`   Tokens: ${opportunity.tokenIn} -> ${opportunity.tokenOut}`);
      console.log(`   Expected Profit: ${opportunity.expectedProfit.toString()} wei`);
      console.log(`   Urgency: ${opportunity.urgency}`);
      console.log(`   Confidence: ${opportunity.confidence}`);

      // Publish to Redis Pub/Sub channel
      await this.cacheService.publish('opportunity-new', opportunity);

      // Cache the opportunity for tracking
      await this.cacheService.set(`opportunity:${opportunity.id}`, opportunity, 300); // 5 minutes TTL

    } catch (error) {
      console.error('Error publishing opportunity:', error);
    }
  }

  private startOpportunityDetection(): void {
    // Periodic cleanup and optimization
    setInterval(() => {
      if (!this.isRunning) return;
      
      // Clean old data from buffer
      for (const [pairKey, buffer] of this.priceDataBuffer.entries()) {
        const cutoffTime = Date.now() - 60000; // 1 minute
        const filteredBuffer = buffer.filter(data => data.timestamp > cutoffTime);
        
        if (filteredBuffer.length === 0) {
          this.priceDataBuffer.delete(pairKey);
        } else {
          this.priceDataBuffer.set(pairKey, filteredBuffer);
        }
      }
    }, 30000); // Run every 30 seconds
  }

  private getPairKey(tokenA: string, tokenB: string): string {
    // Normalize pair key (always put tokens in alphabetical order)
    return [tokenA, tokenB].sort().join('-');
  }

  // Public methods for external control
  async updateCalculatorConfig(config: any): Promise<void> {
    this.profitCalculator.updateConfig(config);
  }

  getCalculatorConfig(): any {
    return this.profitCalculator.getConfig();
  }

  getBufferStatus(): { [pairKey: string]: number } {
    const status: { [pairKey: string]: number } = {};
    for (const [pairKey, buffer] of this.priceDataBuffer.entries()) {
      status[pairKey] = buffer.length;
    }
    return status;
  }
}
