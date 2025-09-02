import { ethers } from 'ethers';
import { ArbitrageOpportunity } from '@orbitflash/shared-types';

export interface RiskConfig {
  minProfitThreshold: bigint;
  maxSlippageThreshold: number;
  maxPositionSizes: { [token: string]: bigint };
  defaultMaxPositionSize: bigint;
  maxGasPrice: bigint;
  blacklistedTokens: string[];
  blacklistedDexes: string[];
}

export interface RiskCheckResult {
  passed: boolean;
  failureReason: string;
  riskLevel: 'low' | 'medium' | 'high';
}

export class RiskManager {
  // private _rpcProvider: JsonRpcProvider; // Unused but kept for future use
  private config: RiskConfig;

  constructor(_rpcUrl?: string, config?: Partial<RiskConfig>) {
    // this._rpcProvider = new JsonRpcProvider(rpcUrl || process.env.ARBITRUM_RPC_URL || 'https://arb1.arbitrum.io/rpc');
    this.config = {
      minProfitThreshold: ethers.parseEther('0.01'), // 0.01 ETH minimum
      maxSlippageThreshold: 0.02, // 2% maximum slippage
      maxPositionSizes: {
        // Arbitrum token addresses with their max position sizes
        '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1': ethers.parseEther('50'), // WETH: 50 ETH
        '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E': ethers.parseUnits('100000', 6), // USDC: 100,000 USDC (6 decimals)
        '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9': ethers.parseUnits('100000', 6), // USDT: 100,000 USDT (6 decimals)
      },
      defaultMaxPositionSize: ethers.parseEther('10'), // 10 ETH equivalent
      maxGasPrice: ethers.parseUnits('50', 'gwei'), // 50 gwei
      blacklistedTokens: [],
      blacklistedDexes: [],
      ...config
    };
  }

  async checkOpportunity(opportunity: ArbitrageOpportunity): Promise<RiskCheckResult> {
    try {
      // Run all risk checks
      const checks = await Promise.all([
        this.checkProfitThreshold(BigInt(opportunity.expectedProfit.toString())),
        this.checkMaxPositionSize(BigInt(opportunity.amountIn.toString()), opportunity.tokenIn),
        this.checkSlippage(opportunity.slippageTolerance),
        this.checkGasPrice(BigInt(opportunity.gasEstimate.toString())),
        this.checkTokenBlacklist(opportunity),
        this.checkDexBlacklist(opportunity),
        this.checkLiquidityDepth(opportunity)
      ]);

      // Find any failed checks
      const failedCheck = checks.find(check => !check.passed);
      
      if (failedCheck) {
        return failedCheck;
      }

      // Determine overall risk level
      const riskLevel = this.calculateOverallRiskLevel(opportunity);

      return {
        passed: true,
        failureReason: '',
        riskLevel
      };

    } catch (error) {
      console.error('Error in risk check:', error);
      return {
        passed: false,
        failureReason: 'Risk check system error',
        riskLevel: 'high'
      };
    }
  }

  checkProfitThreshold(profit: bigint): RiskCheckResult {
    const passed = profit >= this.config.minProfitThreshold;
    
    return {
      passed,
      failureReason: passed ? '' : `Profit ${ethers.formatEther(profit)} ETH below minimum threshold ${ethers.formatEther(this.config.minProfitThreshold)} ETH`,
      riskLevel: passed ? 'low' : 'high'
    };
  }

  async checkMaxPositionSize(amountIn: bigint, tokenIn: string): Promise<RiskCheckResult> {
    try {
      // Get max position size for this token
      const maxSize = this.config.maxPositionSizes[tokenIn] || this.config.defaultMaxPositionSize;
      
      // For non-ETH tokens, we need to convert to ETH equivalent for comparison
      let effectiveAmount = amountIn;
      
      if (tokenIn !== '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1') { // Not WETH
        // Simplified: assume 1:1 ratio for stablecoins, get price for others
        effectiveAmount = await this.convertToETHEquivalent(amountIn, tokenIn);
      }
      
      const passed = effectiveAmount <= maxSize;
      
      return {
        passed,
        failureReason: passed ? '' : `Position size ${ethers.formatEther(effectiveAmount)} ETH exceeds maximum ${ethers.formatEther(maxSize)} ETH for token ${tokenIn}`,
        riskLevel: passed ? 'low' : 'high'
      };
      
    } catch (error) {
      console.error('Error checking position size:', error);
      return {
        passed: false,
        failureReason: 'Failed to validate position size',
        riskLevel: 'high'
      };
    }
  }

  checkSlippage(slippage: number): RiskCheckResult {
    const passed = slippage <= this.config.maxSlippageThreshold;
    
    return {
      passed,
      failureReason: passed ? '' : `Slippage ${(slippage * 100).toFixed(2)}% exceeds maximum ${(this.config.maxSlippageThreshold * 100).toFixed(2)}%`,
      riskLevel: slippage > this.config.maxSlippageThreshold * 1.5 ? 'high' : 'medium'
    };
  }

  checkGasPrice(gasEstimate: bigint): RiskCheckResult {
    // Extract gas price from gas estimate (simplified)
    // In practice, you'd need to separate gas price from gas limit
    const estimatedGasPrice = gasEstimate / 500000n; // Assume 500k gas limit
    const passed = estimatedGasPrice <= this.config.maxGasPrice;
    
    return {
      passed,
      failureReason: passed ? '' : `Gas price ${ethers.formatUnits(estimatedGasPrice, 'gwei')} gwei exceeds maximum ${ethers.formatUnits(this.config.maxGasPrice, 'gwei')} gwei`,
      riskLevel: passed ? 'low' : 'medium'
    };
  }

  checkTokenBlacklist(opportunity: ArbitrageOpportunity): RiskCheckResult {
    const blacklistedToken = this.config.blacklistedTokens.find(token => 
      token === opportunity.tokenIn || token === opportunity.tokenOut
    );
    
    const passed = !blacklistedToken;
    
    return {
      passed,
      failureReason: passed ? '' : `Token ${blacklistedToken} is blacklisted`,
      riskLevel: passed ? 'low' : 'high'
    };
  }

  checkDexBlacklist(opportunity: ArbitrageOpportunity): RiskCheckResult {
    const blacklistedDex = opportunity.dexes.find(dex => 
      this.config.blacklistedDexes.includes(dex)
    );
    
    const passed = !blacklistedDex;
    
    return {
      passed,
      failureReason: passed ? '' : `DEX ${blacklistedDex} is blacklisted`,
      riskLevel: passed ? 'low' : 'high'
    };
  }

  async checkLiquidityDepth(opportunity: ArbitrageOpportunity): Promise<RiskCheckResult> {
    try {
      // Simplified liquidity check
      // In production, this would query actual pool reserves
      
      const amountInEth = parseFloat(ethers.formatEther(opportunity.amountIn));
      
      // Basic heuristic: if trade size is more than 10% of typical pool size, it's risky
      const estimatedPoolSize = this.estimatePoolSize(opportunity.tokenIn, opportunity.tokenOut);
      const tradeRatio = amountInEth / estimatedPoolSize;
      
      const passed = tradeRatio <= 0.1; // Max 10% of pool
      
      return {
        passed,
        failureReason: passed ? '' : `Trade size ${amountInEth.toFixed(4)} ETH is too large relative to estimated pool liquidity`,
        riskLevel: tradeRatio > 0.2 ? 'high' : tradeRatio > 0.1 ? 'medium' : 'low'
      };
      
    } catch (error) {
      console.error('Error checking liquidity depth:', error);
      return {
        passed: true, // Default to pass if we can't check
        failureReason: '',
        riskLevel: 'medium'
      };
    }
  }

  private async convertToETHEquivalent(amount: bigint, token: string): Promise<bigint> {
    // Simplified conversion - in production, this would use actual price feeds
    const stablecoins = [
      '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E', // USDC
      '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9', // USDT
      '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1'  // DAI
    ];
    
    if (stablecoins.includes(token)) {
      // Assume 1 ETH = $2000 for stablecoins
      const ethPrice = 2000;
      const tokenAmount = parseFloat(ethers.formatUnits(amount, 6)); // Most stablecoins use 6 decimals
      const ethEquivalent = tokenAmount / ethPrice;
      return ethers.parseEther(ethEquivalent.toString());
    }
    
    // For other tokens, assume 1:1 with ETH (simplified)
    return amount;
  }

  private estimatePoolSize(tokenA: string, tokenB: string): number {
    // Simplified pool size estimation
    // In production, this would query actual pool data
    
    const majorTokens = [
      '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1', // WETH
      '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E', // USDC
      '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9', // USDT
    ];
    
    const isMajorPair = majorTokens.includes(tokenA) && majorTokens.includes(tokenB);
    
    if (isMajorPair) {
      return 1000; // Assume 1000 ETH equivalent liquidity for major pairs
    } else if (majorTokens.includes(tokenA) || majorTokens.includes(tokenB)) {
      return 100; // 100 ETH for pairs with one major token
    } else {
      return 10; // 10 ETH for minor pairs
    }
  }

  private calculateOverallRiskLevel(opportunity: ArbitrageOpportunity): 'low' | 'medium' | 'high' {
    let riskScore = 0;
    
    // Confidence factor
    if (opportunity.confidence < 0.5) riskScore += 2;
    else if (opportunity.confidence < 0.8) riskScore += 1;
    
    // Slippage factor
    if (opportunity.slippageTolerance > 0.015) riskScore += 2;
    else if (opportunity.slippageTolerance > 0.01) riskScore += 1;
    
    // Urgency factor (higher urgency = higher risk due to competition)
    if (opportunity.urgency === 'high') riskScore += 1;
    
    // Amount factor
    const amountInEth = parseFloat(ethers.formatEther(opportunity.amountIn));
    if (amountInEth > 20) riskScore += 2;
    else if (amountInEth > 5) riskScore += 1;
    
    if (riskScore >= 4) return 'high';
    if (riskScore >= 2) return 'medium';
    return 'low';
  }

  updateConfig(newConfig: Partial<RiskConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }

  getConfig(): RiskConfig {
    return { ...this.config };
  }

  addBlacklistedToken(token: string): void {
    if (!this.config.blacklistedTokens.includes(token)) {
      this.config.blacklistedTokens.push(token);
    }
  }

  removeBlacklistedToken(token: string): void {
    this.config.blacklistedTokens = this.config.blacklistedTokens.filter(t => t !== token);
  }

  addBlacklistedDex(dex: string): void {
    if (!this.config.blacklistedDexes.includes(dex)) {
      this.config.blacklistedDexes.push(dex);
    }
  }

  removeBlacklistedDex(dex: string): void {
    this.config.blacklistedDexes = this.config.blacklistedDexes.filter(d => d !== dex);
  }
}
