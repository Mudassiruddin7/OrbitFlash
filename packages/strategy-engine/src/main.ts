import { Redis } from 'ioredis';
import { ArbitrageOpportunity } from '@orbitflash/shared-types';
import { OpportunityScorer } from './services/scorer.js';
import { RiskManager } from './services/riskManager.js';
import { OpportunityQueue, ScoredOpportunity } from './services/queue.js';

export class StrategyEngineService {
  private redis: Redis;
  private subscriber: Redis;
  private scorer: OpportunityScorer;
  private riskManager: RiskManager;
  private queue: OpportunityQueue;
  private isRunning = false;
  private processingInterval: NodeJS.Timeout | null = null;

  constructor(redisUrl?: string) {
    this.redis = new Redis(redisUrl || process.env.REDIS_URL || 'redis://localhost:6379');
    this.subscriber = new Redis(redisUrl || process.env.REDIS_URL || 'redis://localhost:6379');
    this.scorer = new OpportunityScorer();
    this.riskManager = new RiskManager();
    this.queue = new OpportunityQueue();
  }

  async start(): Promise<void> {
    if (this.isRunning) return;

    console.log('Starting StrategyEngineService...');
    this.isRunning = true;

    // Subscribe to opportunity-new channel
    await this.subscriber.subscribe('opportunity-new');
    
    // Set up message handler
    this.subscriber.on('message', async (channel: string, message: string) => {
      if (channel === 'opportunity-new') {
        await this.handleNewOpportunity(message);
      }
    });

    // Start opportunity processing loop
    this.startProcessingLoop();

    // Start cleanup interval
    this.startCleanupInterval();

    console.log('StrategyEngineService started successfully');
    console.log('📥 Subscribed to opportunity-new channel');
    console.log('🔄 Processing loop started');
  }

  async stop(): Promise<void> {
    this.isRunning = false;
    
    if (this.processingInterval) {
      clearInterval(this.processingInterval);
      this.processingInterval = null;
    }

    await this.subscriber.unsubscribe('opportunity-new');
    await this.subscriber.disconnect();
    await this.redis.disconnect();
    
    console.log('StrategyEngineService stopped');
  }

  private async handleNewOpportunity(message: string): Promise<void> {
    try {
      // Decode the ArbitrageOpportunity
      const opportunity: ArbitrageOpportunity = JSON.parse(message);
      
      console.log(`📨 Received new opportunity: ${opportunity.id}`);
      console.log(`   Expected Profit: ${opportunity.expectedProfit.toString()} wei`);
      console.log(`   Urgency: ${opportunity.urgency}`);

      // Pass to RiskManager for validation
      const riskResult = await this.riskManager.checkOpportunity(opportunity);
      
      if (!riskResult.passed) {
        console.log(`❌ Opportunity ${opportunity.id} failed risk check: ${riskResult.failureReason}`);
        return;
      }

      console.log(`✅ Opportunity ${opportunity.id} passed risk checks (Risk Level: ${riskResult.riskLevel})`);

      // Pass to OpportunityScorer to get score
      const score = await this.scorer.evaluateOpportunity(opportunity);
      
      console.log(`📊 Opportunity ${opportunity.id} scored: ${score.totalScore} (Priority: ${score.priority})`);

      // Push to priority queue
      const added = this.queue.push(opportunity, score);
      
      if (added) {
        console.log(`📋 Added opportunity ${opportunity.id} to execution queue`);
      }

    } catch (error) {
      console.error('Error handling new opportunity:', error);
    }
  }

  private startProcessingLoop(): void {
    // Process opportunities every 100ms
    this.processingInterval = setInterval(async () => {
      if (!this.isRunning) return;

      try {
        await this.processNextOpportunity();
      } catch (error) {
        console.error('Error in processing loop:', error);
      }
    }, 100);
  }

  private async processNextOpportunity(): Promise<void> {
    // Pull highest-priority opportunity from queue
    const scoredOpportunity = this.queue.pop();
    
    if (!scoredOpportunity) {
      return; // No opportunities in queue
    }

    try {
      console.log(`🚀 Processing opportunity ${scoredOpportunity.opportunity.id} (Priority: ${scoredOpportunity.score.priority})`);

      // Publish to opportunity-execute channel
      await this.publishForExecution(scoredOpportunity);

      // Mark as processed
      this.queue.markProcessed(scoredOpportunity.opportunity.id);

    } catch (error) {
      console.error(`Error processing opportunity ${scoredOpportunity.opportunity.id}:`, error);
      
      // Requeue for retry if possible
      const requeued = this.queue.requeue(scoredOpportunity);
      
      if (!requeued) {
        console.log(`❌ Failed to requeue opportunity ${scoredOpportunity.opportunity.id}, discarding`);
      }
    }
  }

  private async publishForExecution(scoredOpportunity: ScoredOpportunity): Promise<void> {
    const executionPayload = {
      opportunity: scoredOpportunity.opportunity,
      score: scoredOpportunity.score,
      timestamp: Date.now(),
      retryCount: scoredOpportunity.retryCount
    };

    await this.redis.publish('opportunity-execute', JSON.stringify(executionPayload));
    
    console.log(`📤 Published opportunity ${scoredOpportunity.opportunity.id} to opportunity-execute channel`);
  }

  private startCleanupInterval(): void {
    // Clean up expired opportunities every 30 seconds
    setInterval(() => {
      if (!this.isRunning) return;
      
      const removedCount = this.queue.cleanup();
      
      if (removedCount > 0) {
        console.log(`🧹 Cleaned up ${removedCount} expired opportunities`);
      }
    }, 30000);
  }

  // Public methods for monitoring and control
  getQueueStats() {
    return this.queue.getStats();
  }

  getQueueSize(): number {
    return this.queue.size();
  }

  clearQueue(): void {
    this.queue.clear();
    console.log('Queue manually cleared');
  }

  async updateScorerConfig(config: any): Promise<void> {
    this.scorer.updateConfig(config);
    console.log('Scorer configuration updated');
  }

  getScorerConfig(): any {
    return this.scorer.getConfig();
  }

  async updateRiskConfig(config: any): Promise<void> {
    this.riskManager.updateConfig(config);
    console.log('Risk manager configuration updated');
  }

  getRiskConfig(): any {
    return this.riskManager.getConfig();
  }

  addBlacklistedToken(token: string): void {
    this.riskManager.addBlacklistedToken(token);
    console.log(`Added token ${token} to blacklist`);
  }

  removeBlacklistedToken(token: string): void {
    this.riskManager.removeBlacklistedToken(token);
    console.log(`Removed token ${token} from blacklist`);
  }

  addBlacklistedDex(dex: string): void {
    this.riskManager.addBlacklistedDex(dex);
    console.log(`Added DEX ${dex} to blacklist`);
  }

  removeBlacklistedDex(dex: string): void {
    this.riskManager.removeBlacklistedDex(dex);
    console.log(`Removed DEX ${dex} from blacklist`);
  }

  getOpportunitiesByUrgency(urgency: 'low' | 'medium' | 'high') {
    return this.queue.getOpportunitiesByUrgency(urgency);
  }

  hasOpportunity(opportunityId: string): boolean {
    return this.queue.hasOpportunity(opportunityId);
  }

  // Health check method
  getHealthStatus() {
    return {
      isRunning: this.isRunning,
      queueSize: this.queue.size(),
      queueStats: this.queue.getStats(),
      redisConnected: this.redis.status === 'ready',
      subscriberConnected: this.subscriber.status === 'ready'
    };
  }
}
