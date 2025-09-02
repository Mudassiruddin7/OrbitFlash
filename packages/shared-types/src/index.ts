// Core types for OrbitFlash system
import { BigNumberish } from 'ethers';
 // ✅ Works in ethers v6-compatible setups

export interface ArbitrageOpportunity {
  id: string; // Unique identifier for the opportunity
  tokenIn: string; // Address
  tokenOut: string; // Address
  amountIn: BigNumberish;
  expectedProfit: BigNumberish;
  gasEstimate: BigNumberish;
  slippageTolerance: number; // e.g., 0.005 for 0.5%
  confidence: number; // 0 to 1
  path: string[]; // Array of token addresses for the trade path
  dexes: string[]; // Array of DEX names or identifiers
  urgency: 'low' | 'medium' | 'high';
}

export interface OpportunityScore {
  totalScore: number;
  priority: number;
}

export interface GasStrategy {
  gasPrice: BigNumberish;
  gasLimit: BigNumberish;
  priorityFee: BigNumberish;
}

export interface ExecutionResult {
  success: boolean;
  error?: string;
}

export interface CompetitorSnapshot {
  activeBots: number;
  competingGasPrice: BigNumberish;
}

export interface AuditLog {
  timestamp: Date;
  transactionHash: string | null;
  opportunityId: string;
  opportunity: ArbitrageOpportunity;
  executionResult: ExecutionResult;
  gasUsed: BigNumberish;
  profitRealized: BigNumberish;
  competitorActivity: CompetitorSnapshot;
}

// Legacy interfaces for backward compatibility
export interface ExecutionStrategy {
  id: string;
  type: 'flash-loan' | 'direct' | 'cross-chain';
  priority: number;
  minProfitThreshold: string;
  maxGasPrice: string;
}

export interface GasOptimization {
  gasPrice: string;
  gasLimit: string;
  priorityFee: string;
  estimatedCost: string;
}

export interface MonitoringAlert {
  level: 'info' | 'warning' | 'error' | 'critical';
  message: string;
  timestamp: number;
  service: string;
}

export * from './types/index.js';
