// Additional type definitions for OrbitFlash
export interface DEXInfo {
  name: string;
  address: string;
  chainId: number;
  fee: number;
}

export interface TokenPair {
  tokenA: string;
  tokenB: string;
  decimalsA: number;
  decimalsB: number;
}

export interface ChainConfig {
  chainId: number;
  name: string;
  rpcUrl: string;
  blockTime: number;
  gasToken: string;
}

export interface FlashLoanProvider {
  name: string;
  address: string;
  fee: number;
  maxAmount: string;
}
