import { ethers } from 'ethers';
import { ArbitrageOpportunity, OpportunityScore } from '@orbitflash/shared-types';

export interface ScoringConfig {
  profitWeight: number;
  riskWeight: number;
  competitionWeight: number;
  minProfitThreshold: bigint;
  maxSlippageThreshold: number;
}

export class OpportunityScorer {
  // private _rpcProvider: JsonRpcProvider; // Unused but kept for future use
  private config: ScoringConfig;

  constructor(_rpcUrl?: string, config?: Partial<ScoringConfig>) {
    // this._rpcProvider = new JsonRpcProvider(rpcUrl || process.env.ARBITRUM_RPC_URL || 'https://arb1.arbitrum.io/rpc');
    this.config = {
      profitWeight: 0.5,
      riskWeight: 0.3,
      competitionWeight: 0.2,
      minProfitThreshold: ethers.parseEther('10'), // 10 ETH
      maxSlippageThreshold: 0.02, // 2%
      ...config
    };
  }

  async evaluateOpportunity(opportunity: ArbitrageOpportunity): Promise<OpportunityScore> {
    try {
      // Calculate individual scores
      const profitScore = this.calculateProfitScore(BigInt(opportunity.expectedProfit.toString()));
      const riskScore = await this.assessRisk(opportunity);
      const competitionScore = await this.analyzeMEVCompetition(opportunity);

      // Calculate weighted total score
      const totalScore = (profitScore * this.config.profitWeight) + 
                        (riskScore * this.config.riskWeight) + 
                        (competitionScore * this.config.competitionWeight);

      // Calculate priority based on urgency and total score
      const urgencyMultiplier = this.getUrgencyMultiplier(opportunity.urgency);
      const priority = Math.floor(totalScore * urgencyMultiplier * 100);

      return {
        totalScore: Math.round(totalScore * 100) / 100, // Round to 2 decimal places
        priority
      };

    } catch (error) {
      console.error('Error evaluating opportunity:', error);
      return {
        totalScore: 0,
        priority: 0
      };
    }
  }

  calculateProfitScore(expectedProfit: bigint): number {
    try {
      // Convert to ETH for easier calculation
      const profitInEth = parseFloat(ethers.formatEther(expectedProfit));
      
      // Normalize profit to a score between 0-100
      // Using logarithmic scale to handle wide range of profits
      if (profitInEth <= 0) return 0;
      
      // Base score calculation: log scale with minimum threshold
      const minProfit = parseFloat(ethers.formatEther(this.config.minProfitThreshold));
      
      if (profitInEth < minProfit) return 0;
      
      // Logarithmic scoring: higher profits get diminishing returns
      const logProfit = Math.log10(profitInEth / minProfit + 1);
      const maxLogProfit = Math.log10(100 + 1); // Assume max reasonable profit is 100x minimum
      
      const score = Math.min(100, (logProfit / maxLogProfit) * 100);
      
      return Math.max(0, score);
      
    } catch (error) {
      console.error('Error calculating profit score:', error);
      return 0;
    }
  }

  async assessRisk(opportunity: ArbitrageOpportunity): Promise<number> {
    try {
      let riskScore = 100; // Start with perfect score, deduct for risks
      
      // 1. Slippage risk assessment
      const slippageRisk = this.assessSlippageRisk(opportunity.slippageTolerance);
      riskScore -= slippageRisk;
      
      // 2. Liquidity depth risk
      const liquidityRisk = await this.assessLiquidityRisk(opportunity);
      riskScore -= liquidityRisk;
      
      // 3. Token volatility risk
      const volatilityRisk = await this.assessVolatilityRisk(opportunity);
      riskScore -= volatilityRisk;
      
      // 4. Confidence factor
      const confidenceBonus = (opportunity.confidence - 0.5) * 20; // -10 to +10 points
      riskScore += confidenceBonus;
      
      return Math.max(0, Math.min(100, riskScore));
      
    } catch (error) {
      console.error('Error assessing risk:', error);
      return 50; // Default moderate risk score
    }
  }

  private assessSlippageRisk(slippageTolerance: number): number {
    // Higher slippage = higher risk = more points deducted
    if (slippageTolerance > this.config.maxSlippageThreshold) {
      return 50; // High penalty for excessive slippage
    }
    
    // Linear penalty: 0% slippage = 0 penalty, 2% slippage = 20 penalty
    return (slippageTolerance / this.config.maxSlippageThreshold) * 20;
  }

  private async assessLiquidityRisk(opportunity: ArbitrageOpportunity): Promise<number> {
    try {
      // Simplified liquidity assessment
      // In production, this would query actual pool reserves
      
      const amountInEth = parseFloat(ethers.formatEther(opportunity.amountIn));
      
      // Assume risk increases with trade size
      // Small trades (< 1 ETH) = low risk
      // Large trades (> 10 ETH) = high risk
      
      if (amountInEth < 1) return 0;
      if (amountInEth > 10) return 30;
      
      // Linear scaling between 1-10 ETH
      return ((amountInEth - 1) / 9) * 30;
      
    } catch (error) {
      console.error('Error assessing liquidity risk:', error);
      return 15; // Default moderate liquidity risk
    }
  }

  private async assessVolatilityRisk(opportunity: ArbitrageOpportunity): Promise<number> {
    try {
      // Simplified volatility assessment
      // In production, this would analyze historical price data
      
      // Check if tokens are stablecoins (lower volatility)
      const stablecoins = [
        '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E', // USDC on Arbitrum
        '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9', // USDT on Arbitrum
        '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1'  // DAI on Arbitrum
      ];
      
      const isStablePair = stablecoins.includes(opportunity.tokenIn) && 
                          stablecoins.includes(opportunity.tokenOut);
      
      if (isStablePair) return 0; // Low volatility risk for stablecoin pairs
      
      // Check if one token is ETH (moderate volatility)
      const WETH = '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1';
      const hasETH = opportunity.tokenIn === WETH || opportunity.tokenOut === WETH;
      
      if (hasETH) return 10; // Moderate volatility risk
      
      return 20; // Higher volatility risk for other token pairs
      
    } catch (error) {
      console.error('Error assessing volatility risk:', error);
      return 15; // Default moderate volatility risk
    }
  }

  async analyzeMEVCompetition(opportunity: ArbitrageOpportunity): Promise<number> {
    try {
      // Placeholder implementation for MEV competition analysis
      // In production, this would analyze:
      // - Current mempool activity
      // - Number of competing bots
      // - Historical success rates for similar opportunities
      // - Gas price competition
      
      // For now, return a score based on urgency and expected profit
      const profitInEth = parseFloat(ethers.formatEther(opportunity.expectedProfit));
      
      // Higher profit opportunities likely have more competition
      let competitionScore = 100;
      
      if (profitInEth > 5) {
        competitionScore -= 30; // High profit = high competition
      } else if (profitInEth > 1) {
        competitionScore -= 15; // Medium profit = medium competition
      }
      
      // Urgency affects competition
      switch (opportunity.urgency) {
        case 'high':
          competitionScore -= 20; // High urgency = more bots competing
          break;
        case 'medium':
          competitionScore -= 10;
          break;
        case 'low':
          // No additional penalty
          break;
      }
      
      return Math.max(0, Math.min(100, competitionScore));
      
    } catch (error) {
      console.error('Error analyzing MEV competition:', error);
      return 70; // Default moderate competition score
    }
  }

  private getUrgencyMultiplier(urgency: 'low' | 'medium' | 'high'): number {
    switch (urgency) {
      case 'high': return 1.5;
      case 'medium': return 1.2;
      case 'low': return 1.0;
      default: return 1.0;
    }
  }

  updateConfig(newConfig: Partial<ScoringConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }

  getConfig(): ScoringConfig {
    return { ...this.config };
  }
}
