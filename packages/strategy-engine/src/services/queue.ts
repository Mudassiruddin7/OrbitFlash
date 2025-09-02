import PriorityQueue from 'priorityqueuejs';
import { ArbitrageOpportunity, OpportunityScore } from '@orbitflash/shared-types';

export interface ScoredOpportunity {
  opportunity: ArbitrageOpportunity;
  score: OpportunityScore;
  timestamp: number;
  retryCount: number;
}

export interface QueueStats {
  totalItems: number;
  highPriorityItems: number;
  mediumPriorityItems: number;
  lowPriorityItems: number;
  oldestItemAge: number;
  averageScore: number;
}

export class OpportunityQueue {
  private queue: PriorityQueue<ScoredOpportunity>;
  private processedItems: Set<string> = new Set();
  private maxRetries: number;
  private maxAge: number; // Maximum age in milliseconds before opportunity expires

  constructor(maxRetries: number = 3, maxAge: number = 30000) { // 30 seconds default max age
    this.maxRetries = maxRetries;
    this.maxAge = maxAge;
    
    // Initialize priority queue with custom comparator
    // Higher priority values come first (priorityqueuejs uses max-heap by default)
    this.queue = new PriorityQueue<ScoredOpportunity>((a, b) => {
      // Primary sort: by priority (higher first)
      if (a.score.priority !== b.score.priority) {
        return a.score.priority - b.score.priority; // Reversed for max-heap
      }
      
      // Secondary sort: by total score (higher first)
      if (a.score.totalScore !== b.score.totalScore) {
        return a.score.totalScore - b.score.totalScore; // Reversed for max-heap
      }
      
      // Tertiary sort: by timestamp (newer first)
      return a.timestamp - b.timestamp; // Reversed for max-heap
    });
  }

  push(opportunity: ArbitrageOpportunity, score: OpportunityScore): boolean {
    // Check if opportunity already processed
    if (this.processedItems.has(opportunity.id)) {
      console.log(`Opportunity ${opportunity.id} already processed, skipping`);
      return false;
    }

    // Check if opportunity is too old
    const now = Date.now();
    const opportunityAge = now - (opportunity as any).timestamp || 0;
    
    if (opportunityAge > this.maxAge) {
      console.log(`Opportunity ${opportunity.id} is too old (${opportunityAge}ms), skipping`);
      return false;
    }

    const scoredOpportunity: ScoredOpportunity = {
      opportunity,
      score,
      timestamp: now,
      retryCount: 0
    };

    this.queue.enq(scoredOpportunity);
    
    console.log(`Added opportunity ${opportunity.id} to queue with priority ${score.priority} and score ${score.totalScore}`);
    return true;
  }

  pop(): ScoredOpportunity | null {
    if (this.queue.size() === 0) {
      return null;
    }

    const item = this.queue.deq();
    if (!item) return null;

    // Check if item is still valid (not too old)
    const now = Date.now();
    const age = now - item.timestamp;
    
    if (age > this.maxAge) {
      console.log(`Popped opportunity ${item.opportunity.id} is expired (${age}ms old), discarding`);
      return this.pop(); // Recursively try next item
    }

    return item;
  }

  peek(): ScoredOpportunity | null {
    if (this.queue.size() === 0) {
      return null;
    }

    return this.queue.peek() || null;
  }

  requeue(item: ScoredOpportunity): boolean {
    if (item.retryCount >= this.maxRetries) {
      console.log(`Opportunity ${item.opportunity.id} exceeded max retries (${this.maxRetries}), discarding`);
      this.processedItems.add(item.opportunity.id);
      return false;
    }

    // Increment retry count and reduce priority slightly
    item.retryCount++;
    item.score.priority = Math.max(1, item.score.priority - 10); // Reduce priority by 10
    item.timestamp = Date.now(); // Update timestamp

    this.queue.enq(item);
    
    console.log(`Requeued opportunity ${item.opportunity.id} (retry ${item.retryCount}/${this.maxRetries})`);
    return true;
  }

  markProcessed(opportunityId: string): void {
    this.processedItems.add(opportunityId);
    console.log(`Marked opportunity ${opportunityId} as processed`);
  }

  size(): number {
    return this.queue.size();
  }

  isEmpty(): boolean {
    return this.queue.size() === 0;
  }

  clear(): void {
    while (this.queue.size() > 0) {
      this.queue.deq();
    }
    this.processedItems.clear();
    console.log('Queue cleared');
  }

  getStats(): QueueStats {
    const items = this.getAllItems();
    const now = Date.now();
    
    let highPriorityItems = 0;
    let mediumPriorityItems = 0;
    let lowPriorityItems = 0;
    let totalScore = 0;
    let oldestAge = 0;

    for (const item of items) {
      const age = now - item.timestamp;
      oldestAge = Math.max(oldestAge, age);
      totalScore += item.score.totalScore;

      if (item.score.priority >= 80) {
        highPriorityItems++;
      } else if (item.score.priority >= 50) {
        mediumPriorityItems++;
      } else {
        lowPriorityItems++;
      }
    }

    return {
      totalItems: items.length,
      highPriorityItems,
      mediumPriorityItems,
      lowPriorityItems,
      oldestItemAge: oldestAge,
      averageScore: items.length > 0 ? totalScore / items.length : 0
    };
  }

  private getAllItems(): ScoredOpportunity[] {
    // Get all items without removing them (for stats)
    const items: ScoredOpportunity[] = [];
    const tempQueue = new PriorityQueue<ScoredOpportunity>((a, b) => {
      // Same comparator as main queue
      if (a.score.priority !== b.score.priority) {
        return a.score.priority - b.score.priority;
      }
      if (a.score.totalScore !== b.score.totalScore) {
        return a.score.totalScore - b.score.totalScore;
      }
      return a.timestamp - b.timestamp;
    });
    
    // Move all items to temp queue and collect them
    while (this.queue.size() > 0) {
      const item = this.queue.deq();
      if (item) {
        items.push(item);
        tempQueue.enq(item);
      }
    }
    
    // Restore original queue
    while (tempQueue.size() > 0) {
      const item = tempQueue.deq();
      if (item) {
        this.queue.enq(item);
      }
    }
    
    return items;
  }

  // Clean up expired opportunities
  cleanup(): number {
    const now = Date.now();
    let removedCount = 0;
    const validItems: ScoredOpportunity[] = [];
    
    // Extract all items
    while (this.queue.size() > 0) {
      const item = this.queue.deq();
      if (item) {
        const age = now - item.timestamp;
        if (age <= this.maxAge) {
          validItems.push(item);
        } else {
          removedCount++;
          console.log(`Removed expired opportunity ${item.opportunity.id} (${age}ms old)`);
        }
      }
    }
    
    // Re-add valid items
    for (const item of validItems) {
      this.queue.enq(item);
    }
    
    if (removedCount > 0) {
      console.log(`Cleaned up ${removedCount} expired opportunities`);
    }
    
    return removedCount;
  }

  // Get opportunities by urgency level
  getOpportunitiesByUrgency(urgency: 'low' | 'medium' | 'high'): ScoredOpportunity[] {
    return this.getAllItems().filter(item => item.opportunity.urgency === urgency);
  }

  // Check if a specific opportunity exists in queue
  hasOpportunity(opportunityId: string): boolean {
    return this.getAllItems().some(item => item.opportunity.id === opportunityId);
  }
}
