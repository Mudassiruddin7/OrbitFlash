# OrbitFlash Smart Contracts

This directory contains the smart contracts for the OrbitFlash arbitrage system.

## Overview

The main contract is `OrbitFlashArbitrage.sol`, which implements flash loan arbitrage using Aave V3 on Arbitrum One.

## Features

- **Flash Loan Integration**: Uses Aave V3 flash loans for capital-efficient arbitrage
- **Multi-DEX Support**: Execute trades across multiple DEXs in a single transaction
- **Security Features**: Owner-only access, reentrancy protection, emergency withdrawals
- **Gas Optimization**: Unchecked loop increments and efficient storage usage

## Contract Structure

### OrbitFlashArbitrage.sol

Main arbitrage contract with the following key functions:

- `executeArbitrage()`: Initiates flash loan arbitrage
- `executeOperation()`: Aave callback function that executes the arbitrage logic
- `_executeArbitrageTrades()`: Private function that executes trades across DEXs

### ArbitrageParams Struct

```solidity
struct ArbitrageParams {
    address tokenIn;        // Input token address
    address tokenOut;       // Output token address
    uint256 amountIn;       // Amount to borrow via flash loan
    uint256 minProfit;      // Minimum profit threshold
    address[] dexAddresses; // Array of DEX contract addresses
    bytes[] swapCalldata;   // Array of encoded swap function calls
}
```

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy environment file:
   ```bash
   cp .env.example .env
   ```

3. Configure your environment variables in `.env`

## Usage

### Compile Contracts

```bash
npm run build
```

### Run Tests

```bash
npm test
```

### Deploy to Arbitrum

```bash
npm run deploy
```

## Security Features

- **Owner Access Control**: Only contract owner can execute arbitrage
- **Reentrancy Protection**: Uses OpenZeppelin's ReentrancyGuard
- **Input Validation**: Comprehensive parameter validation
- **Emergency Functions**: Owner can withdraw stuck tokens
- **Ether Rejection**: Contract rejects direct Ether transfers

## Arbitrum Integration

The contract is specifically designed for Arbitrum One and uses:

- Aave V3 Pool Addresses Provider: `0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb`
- Optimized for Arbitrum's lower gas costs
- Compatible with major Arbitrum DEXs (Uniswap V3, SushiSwap, etc.)

## Testing

The test suite covers:

- Contract deployment and initialization
- Access control mechanisms
- Parameter validation
- Emergency functions
- Error handling

Run tests with:
```bash
npx hardhat test
```

## Gas Optimization

The contract includes several gas optimizations:

- Unchecked loop increments
- Immutable variables for addresses
- Efficient error handling
- Minimal storage usage
