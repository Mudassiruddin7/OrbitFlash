import { ethers, WebSocketProvider, JsonRpcProvider } from 'ethers';
import { EventEmitter } from 'eventemitter3';
// import WebSocket from 'ws'; // Unused import

export interface PriceData {
  tokenA: string;
  tokenB: string;
  price: string;
  dex: string;
  timestamp: number;
  blockNumber: number;
}

export interface PoolState {
  address: string;
  token0: string;
  token1: string;
  reserve0: string;
  reserve1: string;
  fee: number;
  dex: string;
}

export class PriceFeedManager extends EventEmitter {
  private wsProvider: WebSocketProvider;
  private rpcProvider: JsonRpcProvider;
  private chainlinkFeeds: Map<string, string> = new Map();
  private isRunning = false;

  // Arbitrum network configuration
  private readonly ARBITRUM_RPC = process.env.ARBITRUM_RPC_URL || 'https://arb1.arbitrum.io/rpc';
  private readonly ARBITRUM_WS = process.env.ARBITRUM_WS_URL || 'wss://arb1.arbitrum.io/ws';

  // DEX contract addresses on Arbitrum
  private readonly DEX_CONTRACTS = {
    UNISWAP_V3_FACTORY: '0x1F98431c8aD98523631AE4a59f267346ea31F984',
    SUSHISWAP_FACTORY: '0xc35DADB65012eC5796536bD9864eD8773aBc74C4',
    CURVE_REGISTRY: '0x445FE580eF8d70FF569aB36e80c647af338db351',
    BALANCER_VAULT: '0xBA12222222228d8Ba445958a75a0704d566BF2C8'
  };

  constructor() {
    super();
    this.wsProvider = new WebSocketProvider(this.ARBITRUM_WS);
    this.rpcProvider = new JsonRpcProvider(this.ARBITRUM_RPC);
    this.initializeChainlinkFeeds();
  }

  private initializeChainlinkFeeds(): void {
    // Arbitrum Chainlink price feeds
    this.chainlinkFeeds.set('ETH/USD', '0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612');
    this.chainlinkFeeds.set('BTC/USD', '0x6ce185860a4963106506C203335A2910413708e9');
    this.chainlinkFeeds.set('USDC/USD', '0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3');
    this.chainlinkFeeds.set('USDT/USD', '0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7');
  }

  async start(): Promise<void> {
    if (this.isRunning) return;
    
    this.isRunning = true;
    console.log('Starting PriceFeedManager...');

    // Listen for new blocks
    this.wsProvider.on('block', async (blockNumber: number) => {
      await this.handleNewBlock(blockNumber);
    });

    // Start Chainlink price validation polling
    this.startChainlinkPolling();

    console.log('PriceFeedManager started successfully');
  }

  async stop(): Promise<void> {
    this.isRunning = false;
    await this.wsProvider.destroy();
    console.log('PriceFeedManager stopped');
  }

  private async handleNewBlock(blockNumber: number): Promise<void> {
    try {
      // Query liquidity pool states for major DEXs
      await Promise.all([
        this.queryUniswapV3Pools(blockNumber),
        this.querySushiswapPools(blockNumber),
        this.queryCurvePools(blockNumber),
        this.queryBalancerPools(blockNumber)
      ]);
    } catch (error) {
      console.error('Error handling new block:', error);
    }
  }

  private async queryUniswapV3Pools(blockNumber: number): Promise<void> {
    try {
      // Simplified Uniswap V3 pool query
      const factoryAbi = [
        'function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool)'
      ];
      
      const poolAbi = [
        'function slot0() external view returns (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked)',
        'function token0() external view returns (address)',
        'function token1() external view returns (address)',
        'function fee() external view returns (uint24)'
      ];

      const factory = new ethers.Contract(this.DEX_CONTRACTS.UNISWAP_V3_FACTORY, factoryAbi, this.rpcProvider);
      
      // Example: ETH/USDC pool with 0.3% fee
      const WETH = '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1';
      const USDC = '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E';
      
      const poolAddress = await factory.getPool(WETH, USDC, 3000);
      
      if (poolAddress !== ethers.ZeroAddress) {
        const pool = new ethers.Contract(poolAddress, poolAbi, this.rpcProvider);
        const [slot0, token0, token1] = await Promise.all([
          pool.slot0(),
          pool.token0(),
          pool.token1()
        ]);

        const priceData: PriceData = {
          tokenA: token0,
          tokenB: token1,
          price: this.calculatePriceFromSqrtPriceX96(slot0.sqrtPriceX96),
          dex: 'uniswap-v3',
          timestamp: Date.now(),
          blockNumber
        };

        this.emit('priceUpdate', priceData);
      }
    } catch (error) {
      console.error('Error querying Uniswap V3 pools:', error);
    }
  }

  private async querySushiswapPools(blockNumber: number): Promise<void> {
    try {
      // Simplified Sushiswap pool query
      const factoryAbi = [
        'function getPair(address tokenA, address tokenB) external view returns (address pair)'
      ];
      
      const pairAbi = [
        'function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)',
        'function token0() external view returns (address)',
        'function token1() external view returns (address)'
      ];

      const factory = new ethers.Contract(this.DEX_CONTRACTS.SUSHISWAP_FACTORY, factoryAbi, this.rpcProvider);
      
      const WETH = '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1';
      const USDC = '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E';
      
      const pairAddress = await factory.getPair(WETH, USDC);
      
      if (pairAddress !== ethers.ZeroAddress) {
        const pair = new ethers.Contract(pairAddress, pairAbi, this.rpcProvider);
        const [reserves, token0, token1] = await Promise.all([
          pair.getReserves(),
          pair.token0(),
          pair.token1()
        ]);

        const price = (Number(reserves.reserve1) / Number(reserves.reserve0)).toString();

        const priceData: PriceData = {
          tokenA: token0,
          tokenB: token1,
          price,
          dex: 'sushiswap',
          timestamp: Date.now(),
          blockNumber
        };

        this.emit('priceUpdate', priceData);
      }
    } catch (error) {
      console.error('Error querying Sushiswap pools:', error);
    }
  }

  private async queryCurvePools(blockNumber: number): Promise<void> {
    // Simplified Curve pool implementation
    // In production, this would query specific Curve pools
    console.log(`Querying Curve pools for block ${blockNumber}`);
  }

  private async queryBalancerPools(blockNumber: number): Promise<void> {
    // Simplified Balancer pool implementation
    // In production, this would query Balancer vault for pool states
    console.log(`Querying Balancer pools for block ${blockNumber}`);
  }

  private calculatePriceFromSqrtPriceX96(sqrtPriceX96: bigint): string {
    // Convert Uniswap V3 sqrtPriceX96 to readable price
    const Q96 = 2n ** 96n;
    const price = (sqrtPriceX96 * sqrtPriceX96) / (Q96 * Q96);
    return price.toString();
  }

  private startChainlinkPolling(): void {
    const pollInterval = 5000; // 5 seconds
    
    setInterval(async () => {
      if (!this.isRunning) return;
      
      try {
        await this.validateWithChainlink();
      } catch (error) {
        console.error('Error in Chainlink validation:', error);
      }
    }, pollInterval);
  }

  private async validateWithChainlink(): Promise<void> {
    const aggregatorAbi = [
      'function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)'
    ];

    for (const [pair, feedAddress] of this.chainlinkFeeds.entries()) {
      try {
        const aggregator = new ethers.Contract(feedAddress, aggregatorAbi, this.rpcProvider);
        const roundData = await aggregator.latestRoundData();
        
        const validationData = {
          pair,
          price: ethers.formatUnits(roundData.answer, 8), // Chainlink uses 8 decimals
          timestamp: Number(roundData.updatedAt) * 1000,
          source: 'chainlink'
        };

        this.emit('chainlinkValidation', validationData);
      } catch (error) {
        console.error(`Error validating ${pair} with Chainlink:`, error);
      }
    }
  }
}
