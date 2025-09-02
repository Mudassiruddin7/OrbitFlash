import { ethers } from 'ethers';
import { ArbitrageOpportunity } from '@orbitflash/shared-types';

export interface PriceInput {
  tokenAddress: string;
  tokenA: string;
  tokenB: string;
  priceA: string;
  priceB: string;
  liquidityA: string;
  liquidityB: string;
  dexA: string;
  dexB: string;
  price: number; // Price in USD
  liquidity: number; // Available liquidity in USD
}

export interface FlashLoanFees {
  aaveV3Fee: number; // 0.0009 (0.09%)
  compoundFee: number; // 0.0005 (0.05%)
  makerFee: number; // 0.0001 (0.01%)
}

export interface GasCosts {
  baseFee: bigint;
  priorityFee: bigint;
  gasLimit: bigint;
  flashLoanGas: bigint; // Default: 0.0009 (0.09%)
  dexFees: { [dex: string]: number }; // DEX trading fees
  gasPrice: bigint;
  slippageTolerance: number; // Default: 0.005 (0.5%)
  minProfitThreshold: bigint;
}

export interface CalculationConfig {
  flashLoanFee: number;
  dexFees: { [dex: string]: number };
  gasPrice: bigint;
  gasLimit: bigint;
  slippageTolerance: number;
  minProfitThreshold: bigint;
}

export class ProfitCalculator {
  private config: CalculationConfig;

  constructor(config?: Partial<CalculationConfig>) {
    this.config = {
      flashLoanFee: 0.0009, // 0.09% Aave flash loan fee
      dexFees: {
        'uniswap-v3': 0.003, // 0.3%
        'sushiswap': 0.003,  // 0.3%
        'curve': 0.0004,     // 0.04%
        'balancer': 0.0025   // 0.25%
      },
      gasPrice: ethers.parseUnits('20', 'gwei'), // 20 gwei
      gasLimit: 500000n,      // 500k gas
      slippageTolerance: 0.005, // 0.5%
      minProfitThreshold: ethers.parseEther('1'), // 1 ETH
      ...config
    };
  }

  calculateArbitrageOpportunity(priceInput: PriceInput): ArbitrageOpportunity | null {
    try {
      const priceA = parseFloat(priceInput.priceA);
      const priceB = parseFloat(priceInput.priceB);
      
      // Determine arbitrage direction
      const buyLowSellHigh = priceA < priceB;
      const priceDifference = Math.abs(priceB - priceA);
      const lowerPrice = Math.min(priceA, priceB);
      
      // Calculate percentage difference
      const priceDifferencePercent = priceDifference / lowerPrice;
      
      // Get DEX fees
      const dexAFee = this.config.dexFees[priceInput.dexA] || 0.003;
      const dexBFee = this.config.dexFees[priceInput.dexB] || 0.003;
      
      // Calculate total fees
      const totalFees = this.config.flashLoanFee + dexAFee + dexBFee;
      
      // Check if price difference covers fees + slippage
      const requiredSpread = totalFees + this.config.slippageTolerance;
      
      if (priceDifferencePercent <= requiredSpread) {
        return null; // Not profitable
      }
      
      // Calculate optimal trade amount based on liquidity
      const liquidityA = parseFloat(priceInput.liquidityA);
      const liquidityB = parseFloat(priceInput.liquidityB);
      const maxTradeAmount = Math.min(liquidityA, liquidityB) * 0.1; // Use 10% of available liquidity
      
      // Calculate amounts
      const amountIn = ethers.parseEther(maxTradeAmount.toString());
      
      // Calculate expected profit
      const grossProfit = priceDifferencePercent * maxTradeAmount;
      const totalCosts = totalFees * maxTradeAmount;
      const gasCost = this.config.gasPrice * this.config.gasLimit;
      const gasCostInEth = parseFloat(gasCost.toString()) / 1e18;
      
      const netProfit = grossProfit - totalCosts - gasCostInEth;
      
      if (netProfit <= 0) {
        return null; // Not profitable after costs
      }
      
      const expectedProfit = ethers.parseEther(netProfit.toString());
      
      // Check minimum profit threshold
      if (expectedProfit < this.config.minProfitThreshold) {
        return null;
      }
      
      // Calculate confidence score based on liquidity and price stability
      const confidence = this.calculateConfidence(liquidityA, liquidityB, priceDifferencePercent);
      
      // Determine urgency based on profit margin
      const profitMargin = netProfit / maxTradeAmount;
      let urgency: 'low' | 'medium' | 'high' = 'low';
      
      if (profitMargin > 0.05) urgency = 'high';
      else if (profitMargin > 0.02) urgency = 'medium';
      
      // Create trade path
      const path = buyLowSellHigh 
        ? [priceInput.tokenA, priceInput.tokenB]
        : [priceInput.tokenB, priceInput.tokenA];
      
      const dexes = buyLowSellHigh
        ? [priceInput.dexA, priceInput.dexB]
        : [priceInput.dexB, priceInput.dexA];
      
      const opportunity: ArbitrageOpportunity = {
        id: this.generateOpportunityId(priceInput),
        tokenIn: buyLowSellHigh ? priceInput.tokenA : priceInput.tokenB,
        tokenOut: buyLowSellHigh ? priceInput.tokenB : priceInput.tokenA,
        amountIn,
        expectedProfit,
        gasEstimate: gasCost,
        slippageTolerance: this.config.slippageTolerance,
        confidence,
        path,
        dexes,
        urgency
      };
      
      return opportunity;
      
    } catch (error) {
      console.error('Error calculating arbitrage opportunity:', error);
      return null;
    }
  }
  
  private calculateConfidence(liquidityA: number, liquidityB: number, priceDifference: number): number {
    // Base confidence on liquidity depth
    const minLiquidity = Math.min(liquidityA, liquidityB);
    const liquidityScore = Math.min(minLiquidity / 1000000, 1); // Normalize to 1M liquidity
    
    // Adjust for price difference (higher difference = lower confidence due to potential stale data)
    const priceStabilityScore = Math.max(0, 1 - (priceDifference * 10));
    
    // Combined confidence score
    const confidence = (liquidityScore * 0.7) + (priceStabilityScore * 0.3);
    
    return Math.max(0.1, Math.min(1, confidence));
  }
  
  private generateOpportunityId(priceInput: PriceInput): string {
    const timestamp = Date.now();
    const tokens = [priceInput.tokenA, priceInput.tokenB].sort().join('-');
    const dexes = [priceInput.dexA, priceInput.dexB].sort().join('-');
    
    return `arb-${tokens}-${dexes}-${timestamp}`;
  }
  
  updateConfig(newConfig: Partial<CalculationConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }
  
  getConfig(): CalculationConfig {
    return { ...this.config };
  }
  
  // Utility method to estimate gas costs for different transaction types
  estimateGasCosts(transactionType: 'simple' | 'flash-loan' | 'multi-dex'): bigint {
    const gasEstimates = {
      'simple': 150000n,
      'flash-loan': 500000n,
      'multi-dex': 800000n
    };
    
    return this.config.gasPrice * gasEstimates[transactionType];
  }
}
