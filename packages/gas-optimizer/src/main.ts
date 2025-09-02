import { ethers, JsonRpcProvider } from 'ethers';
import { Redis } from 'ioredis';
import { ArbitrageOpportunity, GasStrategy } from '@orbitflash/shared-types';
import { GasOptimizer } from './services/gasOptimizer.js';
import { DexCalldataGenerator } from './services/dexCalldata.js';

export interface TransactionPayload {
  opportunity: ArbitrageOpportunity;
  gasStrategy: GasStrategy;
  contractAddress: string;
  arbitrageParams: ArbitrageParams;
  estimatedProfit: string;
  timestamp: number;
}

export interface ArbitrageParams {
  tokenIn: string;
  tokenOut: string;
  amountIn: string;
  minProfit: string;
  dexAddresses: string[];
  swapCalldata: string[];
}

export class GasOptimizerService {
  private redis: Redis;
  private subscriber: Redis;
  private provider: JsonRpcProvider;
  private gasOptimizer: GasOptimizer;
  private calldataGenerator: DexCalldataGenerator;
  private isRunning = false;

  // OrbitFlashArbitrage contract ABI (simplified)
  private contractABI = [
    'function executeArbitrage((address tokenIn, address tokenOut, uint256 amountIn, uint256 minProfit, address[] dexAddresses, bytes[] swapCalldata)) external',
    'function owner() external view returns (address)',
    'function getTokenBalance(address token) external view returns (uint256)'
  ];

  private contractAddress: string;

  constructor(redisUrl?: string, rpcUrl?: string, contractAddress?: string) {
    this.redis = new Redis(redisUrl || process.env.REDIS_URL || 'redis://localhost:6379');
    this.subscriber = new Redis(redisUrl || process.env.REDIS_URL || 'redis://localhost:6379');
    this.provider = new JsonRpcProvider(rpcUrl || process.env.ARBITRUM_RPC_URL || 'https://arb1.arbitrum.io/rpc');
    this.gasOptimizer = new GasOptimizer(rpcUrl);
    this.calldataGenerator = new DexCalldataGenerator();
    this.contractAddress = contractAddress || process.env.ORBIT_FLASH_CONTRACT_ADDRESS || '';
  }

  async start(): Promise<void> {
    if (this.isRunning) return;

    console.log('Starting GasOptimizerService...');
    this.isRunning = true;

    // Validate contract address
    if (!this.contractAddress) {
      throw new Error('OrbitFlashArbitrage contract address not provided');
    }

    // Subscribe to opportunity-execute channel
    await this.subscriber.subscribe('opportunity-execute');
    
    // Set up message handler
    this.subscriber.on('message', async (channel: string, message: string) => {
      if (channel === 'opportunity-execute') {
        await this.handleExecuteOpportunity(message);
      }
    });

    console.log('GasOptimizerService started successfully');
    console.log('📥 Subscribed to opportunity-execute channel');
    console.log(`📋 Using contract address: ${this.contractAddress}`);
  }

  async stop(): Promise<void> {
    this.isRunning = false;
    
    await this.subscriber.unsubscribe('opportunity-execute');
    await this.subscriber.disconnect();
    await this.redis.disconnect();
    
    console.log('GasOptimizerService stopped');
  }

  private async handleExecuteOpportunity(message: string): Promise<void> {
    try {
      // Parse the opportunity message
      const executionData = JSON.parse(message);
      const opportunity: ArbitrageOpportunity = executionData.opportunity;
      
      console.log(`📨 Received execution opportunity: ${opportunity.id}`);
      console.log(`   Expected Profit: ${opportunity.expectedProfit.toString()} wei`);
      console.log(`   Urgency: ${opportunity.urgency}`);

      // Optimize gas strategy
      const gasStrategy = await this.gasOptimizer.optimizeGasStrategy(opportunity);
      
      console.log(`⛽ Gas strategy optimized:`);
      console.log(`   Gas Price: ${ethers.formatUnits(gasStrategy.gasPrice, 'gwei')} gwei`);
      console.log(`   Gas Limit: ${gasStrategy.gasLimit.toString()}`);
      console.log(`   Priority Fee: ${ethers.formatUnits(gasStrategy.priorityFee, 'gwei')} gwei`);

      // Prepare arbitrage parameters
      const arbitrageParams = await this.prepareArbitrageParams(opportunity);
      
      // Estimate gas for the actual transaction
      const estimatedGas = await this.estimateTransactionGas(arbitrageParams, gasStrategy);
      
      // Update gas strategy with actual estimate
      const finalGasStrategy: GasStrategy = {
        ...gasStrategy,
        gasLimit: estimatedGas
      };

      // Create transaction payload
      const transactionPayload: TransactionPayload = {
        opportunity,
        gasStrategy: finalGasStrategy,
        contractAddress: this.contractAddress,
        arbitrageParams,
        estimatedProfit: opportunity.expectedProfit.toString(),
        timestamp: Date.now()
      };

      // Publish to transaction-ready channel
      await this.publishTransactionReady(transactionPayload);

    } catch (error) {
      console.error('Error handling execute opportunity:', error);
    }
  }

  private async prepareArbitrageParams(opportunity: ArbitrageOpportunity): Promise<ArbitrageParams> {
    try {
      const swapCalldata: string[] = [];

      // Calculate deadline (5 minutes from now)
      const _deadline = Math.floor(Date.now() / 1000) + 300;

      for (let i = 0; i < opportunity.dexes.length; i++) {
        const dex = opportunity.dexes[i];
        const tokenIn = i === 0 ? opportunity.tokenIn : opportunity.path[i];
        const tokenOut = i === opportunity.path.length - 1 ? opportunity.tokenOut : opportunity.path[i + 1];
        
        const swapParams = {
          tokenIn,
          tokenOut,
          amountIn: opportunity.amountIn.toString(),
          amountOutMin: '0', // Will be calculated by calldata generator
          recipient: process.env.ORBITFLASH_CONTRACT_ADDRESS!,
          deadline: _deadline,
          slippage: opportunity.slippageTolerance
        };
        
        const calldata = await this.calldataGenerator.generateSwapCalldata(dex, swapParams);
        swapCalldata.push(calldata);
      }
      
      const arbitrageParams: ArbitrageParams = {
        tokenIn: opportunity.tokenIn,
        tokenOut: opportunity.tokenOut,
        amountIn: opportunity.amountIn.toString(),
        minProfit: this.calculateMinOutput(opportunity.expectedProfit.toString(), 0.05), // 5% slippage on profit
        dexAddresses: opportunity.dexes,
        swapCalldata
      };
      
      return arbitrageParams;
    } catch (error) {
      console.error('Error preparing arbitrage params:', error);
      throw error;
    }
  }

  private calculateMinOutput(amountIn: string, slippageTolerance: number): string {
    try {
      const amount = ethers.parseUnits(amountIn, 18);
      const slippageMultiplier = Math.floor((1 - slippageTolerance) * 10000);
      const minOutput = amount * BigInt(slippageMultiplier) / 10000n;
      return minOutput.toString();
    } catch (error) {
      console.error('Error calculating min output:', error);
      return '0';
    }
  }

  private async estimateTransactionGas(
    arbitrageParams: ArbitrageParams, 
    gasStrategy: GasStrategy
  ): Promise<bigint> {
    try {
      // Create contract instance
      const contract = new ethers.Contract(this.contractAddress, this.contractABI, this.provider);

      // Estimate gas for the executeArbitrage call
      const estimatedGas = await contract.executeArbitrage.estimateGas(arbitrageParams, {
        gasPrice: gasStrategy.gasPrice
      });

      // Add buffer to the estimate
      const gasBuffer = estimatedGas * 120n / 100n; // 20% buffer
      
      console.log(`📊 Gas estimation:`);
      console.log(`   Estimated: ${estimatedGas.toString()}`);
      console.log(`   With buffer: ${gasBuffer.toString()}`);

      return gasBuffer;

    } catch (error) {
      console.error('Error estimating transaction gas:', error);
      
      // Return the original gas limit from strategy as fallback
      return BigInt(gasStrategy.gasLimit.toString());
    }
  }

  private async publishTransactionReady(payload: TransactionPayload): Promise<void> {
    try {
      await this.redis.publish('transaction-ready', JSON.stringify(payload));
      
      console.log(`📤 Published transaction-ready for opportunity ${payload.opportunity.id}`);
      console.log(`   Contract: ${payload.contractAddress}`);
      console.log(`   Gas Limit: ${payload.gasStrategy.gasLimit.toString()}`);
      console.log(`   Gas Price: ${ethers.formatUnits(payload.gasStrategy.gasPrice, 'gwei')} gwei`);

    } catch (error) {
      console.error('Error publishing transaction-ready:', error);
      throw error;
    }
  }

  // Public methods for monitoring and control
  async getCurrentGasInfo() {
    return this.gasOptimizer.getCurrentGasInfo();
  }

  async getGasPriceRecommendations() {
    return this.gasOptimizer.getGasPriceRecommendations();
  }

  updateGasConfig(config: any): void {
    this.gasOptimizer.updateConfig(config);
    console.log('Gas optimizer configuration updated');
  }

  getGasConfig(): any {
    return this.gasOptimizer.getConfig();
  }

  setContractAddress(address: string): void {
    this.contractAddress = address;
    console.log(`Contract address updated to: ${address}`);
  }

  getContractAddress(): string {
    return this.contractAddress;
  }

  // Health check method
  getHealthStatus() {
    return {
      isRunning: this.isRunning,
      contractAddress: this.contractAddress,
      redisConnected: this.redis.status === 'ready',
      subscriberConnected: this.subscriber.status === 'ready',
      providerConnected: !!this.provider
    };
  }

  // Method to test gas optimization for a given opportunity
  async testGasOptimization(opportunity: ArbitrageOpportunity) {
    try {
      const gasStrategy = await this.gasOptimizer.optimizeGasStrategy(opportunity);
      const arbitrageParams = await this.prepareArbitrageParams(opportunity);
      const estimatedGas = await this.estimateTransactionGas(arbitrageParams, gasStrategy);

      return {
        gasStrategy: {
          ...gasStrategy,
          gasLimit: estimatedGas
        },
        arbitrageParams,
        estimatedCost: (BigInt(gasStrategy.gasPrice.toString()) * estimatedGas).toString()
      };
    } catch (error) {
      console.error('Error in test gas optimization:', error);
      throw error;
    }
  }
}
