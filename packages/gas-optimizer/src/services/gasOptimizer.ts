import { ethers, JsonRpcProvider, Contract } from 'ethers';
import { ArbitrageOpportunity, GasStrategy } from '@orbitflash/shared-types';

export interface GasConfig {
  baseFeePremiumMultiplier: number; // Multiplier for base fee (e.g., 1.1 = 110%)
  urgencyMultipliers: {
    low: number;
    medium: number;
    high: number;
  };
  maxGasPrice: bigint;
  minGasPrice: bigint;
  gasLimitBuffer: number; // Buffer percentage for gas limit (e.g., 0.2 = 20%)
}

export interface ArbitrumGasInfo {
  baseFee: bigint;
  l1BaseFee: bigint;
  priorityFee: bigint;
  gasPrice: bigint;
}

export class GasOptimizer {
  private provider: JsonRpcProvider;
  private config: GasConfig;
  private arbGasInfoAddress = '0x000000000000000000000000000000000000006C'; // ArbGasInfo precompile

  // ArbGasInfo ABI for getting gas information
  private arbGasInfoABI = [
    'function getL1BaseFeeEstimate() external view returns (uint256)',
    'function getCurrentTxL1GasFees() external view returns (uint256)',
    'function getGasAccountingParams() external view returns (uint256, uint256, uint256)',
    'function getPricesInWei() external view returns (uint256, uint256, uint256, uint256, uint256, uint256)'
  ];

  constructor(rpcUrl?: string, config?: Partial<GasConfig>) {
    this.provider = new JsonRpcProvider(rpcUrl || process.env.ARBITRUM_RPC_URL || 'https://arb1.arbitrum.io/rpc');
    this.config = {
      baseFeePremiumMultiplier: 1.1, // 10% above base fee
      urgencyMultipliers: {
        low: 1.0,    // No premium for low urgency
        medium: 1.5, // 50% premium for medium urgency
        high: 2.0    // 100% premium for high urgency
      },
      maxGasPrice: ethers.parseUnits('100', 'gwei'), // 100 gwei max
      minGasPrice: ethers.parseUnits('0.1', 'gwei'),    // 0.1 gwei min
      gasLimitBuffer: 0.2, // 20% buffer
      ...config
    };
  }

  async optimizeGasStrategy(opportunity: ArbitrageOpportunity): Promise<GasStrategy> {
    try {
      // Get current Arbitrum gas information
      const gasInfo = await this.getArbitrumGasInfo();
      
      // Calculate optimal priority fee based on urgency
      const priorityFee = this.calculatePriorityFee(gasInfo, opportunity.urgency);
      
      // Calculate gas price (base fee + priority fee)
      const gasPrice = gasInfo.baseFee + priorityFee;
      
      // Ensure gas price is within bounds
      const boundedGasPrice = this.boundGasPrice(gasPrice);
      
      // Estimate gas limit for the transaction
      const gasLimit = await this.estimateGasLimit(opportunity);
      
      return {
        gasPrice: boundedGasPrice,
        gasLimit,
        priorityFee
      };
      
    } catch (error) {
      console.error('Error optimizing gas strategy:', error);
      
      // Return fallback gas strategy
      return this.getFallbackGasStrategy();
    }
  }

  private async getArbitrumGasInfo(): Promise<ArbitrumGasInfo> {
    try {
      const arbGasInfo = new Contract(this.arbGasInfoAddress, this.arbGasInfoABI, this.provider);
      
      // Get current gas prices from ArbGasInfo precompile
      const result = await arbGasInfo.getPricesInWei();
      const [
        _perL2TxFee,
        _perL1CalldataFee,
        _perArbGasBase,
        _perArbGasCongestion,
        _perArbGasTotal,
        _baseFeeL1
      ] = result;
      
      // Get L1 base fee estimate
      const l1BaseFee = await arbGasInfo.getL1BaseFeeEstimate();
      
      // Get current block to extract base fee
      const block = await this.provider.getBlock('latest');
      const baseFee = block?.baseFeePerGas || ethers.parseUnits('0.1', 'gwei'); // Fallback to 0.1 gwei
      
      // Calculate a reasonable priority fee based on network conditions
      const priorityFee = this.calculateBasePriorityFee(baseFee);
      
      return {
        baseFee,
        l1BaseFee,
        priorityFee,
        gasPrice: baseFee + priorityFee
      };
      
    } catch (error) {
      console.error('Error fetching Arbitrum gas info:', error);
      
      // Fallback to standard RPC methods
      return this.getFallbackGasInfo();
    }
  }

  private async getFallbackGasInfo(): Promise<ArbitrumGasInfo> {
    try {
      const [feeData, block] = await Promise.all([
        this.provider.getFeeData(),
        this.provider.getBlock('latest')
      ]);
      
      const gasPrice = feeData.gasPrice || ethers.parseUnits('2', 'gwei');
      const baseFee = block?.baseFeePerGas || (gasPrice * 9n / 10n); // Estimate base fee as 90% of gas price
      const priorityFee = gasPrice - baseFee;
      
      return {
        baseFee,
        l1BaseFee: ethers.parseUnits('10', 'gwei'), // 10 gwei fallback
        priorityFee,
        gasPrice
      };
      
    } catch (error) {
      console.error('Error in fallback gas info:', error);
      
      // Ultimate fallback
      const fallbackGasPrice = ethers.parseUnits('2', 'gwei'); // 2 gwei
      return {
        baseFee: fallbackGasPrice * 9n / 10n,
        l1BaseFee: ethers.parseUnits('10', 'gwei'),
        priorityFee: fallbackGasPrice / 10n,
        gasPrice: fallbackGasPrice
      };
    }
  }

  private calculateBasePriorityFee(baseFee: bigint): bigint {
    // Calculate a base priority fee as a percentage of base fee
    // This helps ensure transactions are included in blocks
    const minPriorityFee = ethers.parseUnits('1', 'gwei'); // 1 gwei minimum
    const calculatedFee = baseFee * 10n / 100n; // 10% of base fee
    
    return calculatedFee > minPriorityFee ? calculatedFee : minPriorityFee;
  }

  private calculatePriorityFee(gasInfo: ArbitrumGasInfo, urgency: 'low' | 'medium' | 'high'): bigint {
    const baseFeePremium = gasInfo.baseFee * 
      BigInt(Math.floor((this.config.baseFeePremiumMultiplier - 1) * 100)) / 100n;
    
    const urgencyMultiplier = this.config.urgencyMultipliers[urgency];
    const urgencyPremium = gasInfo.priorityFee * BigInt(Math.floor(urgencyMultiplier * 100)) / 100n;
    
    // Combine base fee premium and urgency premium
    const totalPriorityFee = baseFeePremium + urgencyPremium;
    
    // Ensure minimum priority fee for transaction inclusion
    const minPriorityFee = ethers.parseUnits('1', 'gwei'); // 1 gwei
    
    return totalPriorityFee > minPriorityFee ? totalPriorityFee : minPriorityFee;
  }

  private boundGasPrice(gasPrice: bigint): bigint {
    if (gasPrice > this.config.maxGasPrice) {
      return this.config.maxGasPrice;
    }
    
    if (gasPrice < this.config.minGasPrice) {
      return this.config.minGasPrice;
    }
    
    return gasPrice;
  }

  private async estimateGasLimit(opportunity: ArbitrageOpportunity): Promise<bigint> {
    try {
      // This is a simplified estimation
      // In a real implementation, you would simulate the actual contract call
      
      // Base gas costs for different operations
      const baseGas = 21000n; // Base transaction cost
      const flashLoanGas = 200000n; // Flash loan overhead
      const swapGasPerDex = 150000n; // Gas per DEX swap
      
      // Calculate total gas based on number of DEX interactions
      const dexCount = BigInt(opportunity.dexes.length);
      const swapGas = swapGasPerDex * dexCount;
      
      // Add complexity factor based on token types
      const complexityGas = this.getComplexityGas(opportunity);
      
      const estimatedGas = baseGas + flashLoanGas + swapGas + complexityGas;
      
      // Apply buffer to ensure transaction doesn't run out of gas
      const buffer = BigInt(Math.floor(this.config.gasLimitBuffer * 100));
      const gasWithBuffer = estimatedGas * (100n + buffer) / 100n;
      
      // Cap at reasonable maximum
      const maxGasLimit = 2000000n; // 2M gas max
      
      return gasWithBuffer > maxGasLimit ? maxGasLimit : gasWithBuffer;
      
    } catch (error) {
      console.error('Error estimating gas limit:', error);
      
      // Fallback gas limit
      return 800000n; // 800k gas fallback
    }
  }

  private getComplexityGas(opportunity: ArbitrageOpportunity): bigint {
    let complexityGas = 0n;
    
    // Add gas for high-value transactions (more validation)
    const amountInEth = parseFloat(ethers.formatEther(opportunity.amountIn));
    if (amountInEth > 10) {
      complexityGas += 50000n;
    }
    
    // Add gas for high urgency (might need more priority)
    if (opportunity.urgency === 'high') {
      complexityGas += 25000n;
    }
    
    // Add gas for low confidence (might need more checks)
    if (opportunity.confidence < 0.7) {
      complexityGas += 30000n;
    }
    
    return complexityGas;
  }

  private getFallbackGasStrategy(): GasStrategy {
    return {
      gasPrice: ethers.parseUnits('2', 'gwei'), // 2 gwei
      gasLimit: 800000n,     // 800k gas
      priorityFee: ethers.parseUnits('1', 'gwei') // 1 gwei
    };
  }

  // Utility methods for monitoring and configuration
  async getCurrentGasInfo(): Promise<ArbitrumGasInfo> {
    return this.getArbitrumGasInfo();
  }

  updateConfig(newConfig: Partial<GasConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }

  getConfig(): GasConfig {
    return { ...this.config };
  }

  // Method to get gas price recommendations for different urgency levels
  async getGasPriceRecommendations(): Promise<{ [key: string]: bigint }> {
    try {
      const gasInfo = await this.getArbitrumGasInfo();
      
      return {
        low: gasInfo.baseFee + this.calculatePriorityFee(gasInfo, 'low'),
        medium: gasInfo.baseFee + this.calculatePriorityFee(gasInfo, 'medium'),
        high: gasInfo.baseFee + this.calculatePriorityFee(gasInfo, 'high')
      };
    } catch (error) {
      console.error('Error getting gas price recommendations:', error);
      
      const fallback = ethers.parseUnits('2', 'gwei');
      return {
        low: fallback,
        medium: fallback * 15n / 10n,
        high: fallback * 2n
      };
    }
  }
}
