import { Interface } from 'ethers';

export interface SwapParams {
  tokenIn: string;
  tokenOut: string;
  amountIn: string;
  amountOutMin: string;
  recipient: string;
  deadline: number;
  slippage: number; // New field added
}

export class DexCalldataGenerator {
  // Uniswap V3 Router ABI (simplified)
  private uniswapV3RouterABI = [
    'function exactInputSingle((address tokenIn, address tokenOut, uint24 fee, address recipient, uint256 deadline, uint256 amountIn, uint256 amountOutMinimum, uint160 sqrtPriceLimitX96)) external payable returns (uint256 amountOut)'
  ];

  // SushiSwap Router ABI (simplified)
  private sushiswapRouterABI = [
    'function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts)'
  ];

  // Curve Pool ABI (simplified)
  private curvePoolABI = [
    'function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256)'
  ];

  // Balancer Vault ABI (simplified)
  private balancerVaultABI = [
    'function swap((bytes32 poolId, uint8 kind, address assetIn, address assetOut, uint256 amount, bytes userData), (address sender, bool fromInternalBalance, address payable recipient, bool toInternalBalance), uint256 limit, uint256 deadline) external payable returns (uint256)'
  ];

  // DEX contract addresses on Arbitrum
  private dexAddresses = {
    UNISWAP_V3_ROUTER: '0xE592427A0AEce92De3Edee1F18E0157C05861564',
    SUSHISWAP_ROUTER: '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506',
    CURVE_REGISTRY: '0x445FE580eF8d70FF569aB36e80c647af338db351',
    BALANCER_VAULT: '0xBA12222222228d8Ba445958a75a0704d566BF2C8'
  };

  async generateSwapCalldata(dex: string, params: SwapParams): Promise<string> {
    switch (dex.toLowerCase()) {
      case 'uniswap-v3':
        return this.generateUniswapV3Calldata(params);
      case 'sushiswap':
        return this.generateSushiswapCalldata(params);
      case 'curve':
        return this.generateCurveCalldata(params);
      case 'balancer':
        return this.generateBalancerCalldata(params);
      default:
        throw new Error(`Unsupported DEX: ${dex}`);
    }
  }

  private generateUniswapV3Calldata(params: SwapParams): string {
    const iface = new Interface(this.uniswapV3RouterABI);
    
    const swapParams = {
      tokenIn: params.tokenIn,
      tokenOut: params.tokenOut,
      fee: 3000, // 0.3% fee tier (most common)
      recipient: params.recipient,
      deadline: params.deadline,
      amountIn: params.amountIn,
      amountOutMinimum: params.amountOutMin,
      sqrtPriceLimitX96: 0 // No price limit
    };

    return iface.encodeFunctionData('exactInputSingle', [swapParams]);
  }

  private generateSushiswapCalldata(params: SwapParams): string {
    const iface = new Interface(this.sushiswapRouterABI);
    
    // Create path array (direct swap)
    const path = [params.tokenIn, params.tokenOut];

    const calldata = iface.encodeFunctionData('swapExactTokensForTokens', [
      params.amountIn,
      params.amountOutMin,
      path,
      params.recipient,
      params.deadline
    ]);

    return calldata;
  }

  private generateCurveCalldata(params: SwapParams): string {
    const iface = new Interface(this.curvePoolABI);
    
    // For Curve, we need to determine token indices
    // This is simplified - in production, you'd query the pool for token indices
    const tokenIndices = this.getCurveTokenIndices(params.tokenIn, params.tokenOut);

    const calldata = iface.encodeFunctionData('exchange', [
      tokenIndices.i,
      tokenIndices.j,
      params.amountIn,
      params.amountOutMin
    ]);

    // Note: This would need to be the specific Curve pool address, not the registry
    return calldata;
  }

  private generateBalancerCalldata(params: SwapParams): string {
    const iface = new Interface(this.balancerVaultABI);
    
    // Simplified Balancer swap - would need actual pool ID in production
    const singleSwap = {
      poolId: '0x0000000000000000000000000000000000000000000000000000000000000000', // Placeholder
      kind: 0, // GIVEN_IN
      assetIn: params.tokenIn,
      assetOut: params.tokenOut,
      amount: params.amountIn,
      userData: '0x'
    };

    const funds = {
      sender: params.recipient,
      fromInternalBalance: false,
      recipient: params.recipient,
      toInternalBalance: false
    };

    const calldata = iface.encodeFunctionData('swap', [
      singleSwap,
      funds,
      params.amountOutMin,
      params.deadline
    ]);

    return calldata;
  }

  private getCurveTokenIndices(tokenIn: string, tokenOut: string): { i: number; j: number } {
    // Simplified token index mapping for common Arbitrum tokens
    // In production, this would query the actual Curve pool
    const tokenIndexMap: { [address: string]: number } = {
      '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1': 0, // WETH
      '0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E': 1, // USDC
      '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9': 2, // USDT
      '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1': 3  // DAI
    };

    const i = tokenIndexMap[tokenIn] ?? 0;
    const j = tokenIndexMap[tokenOut] ?? 1;

    return { i, j };
  }

  // Utility method to get DEX addresses
  getDexAddress(dex: string): string {
    switch (dex.toLowerCase()) {
      case 'uniswap-v3':
        return this.dexAddresses.UNISWAP_V3_ROUTER;
      case 'sushiswap':
        return this.dexAddresses.SUSHISWAP_ROUTER;
      case 'curve':
        return this.dexAddresses.CURVE_REGISTRY;
      case 'balancer':
        return this.dexAddresses.BALANCER_VAULT;
      default:
        throw new Error(`Unknown DEX: ${dex}`);
    }
  }

  // Method to validate if a DEX is supported
  isSupportedDex(dex: string): boolean {
    const supportedDexes = ['uniswap-v3', 'sushiswap', 'curve', 'balancer'];
    return supportedDexes.includes(dex.toLowerCase());
  }
}
