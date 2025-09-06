# OrbitFlash Smart Contracts

This directory contains the smart contracts for the OrbitFlash arbitrage system.

## Overview

The main contract is `OrbitFlashArbitrage.sol`, which enables flash loan arbitrage using Aave V3 on Arbitrum. It allows anyone to execute arbitrage trades across multiple DEXs in a single transaction, with profit sharing and robust security features.

## Features

- **Aave V3 Flash Loan Integration**: Capital-efficient arbitrage using flash loans.
- **Multi-DEX Arbitrage**: Execute swaps across multiple DEXs atomically.
- **Profit Sharing**: Net profit is split between the contract owner (default 2% fee, up to 5%) and the arbitrage initiator.
- **Permissionless Execution**: Anyone can call `executeArbitrage`.
- **Security**: Includes reentrancy protection, owner-only emergency withdrawals, and strict input validation.
- **Emergency Withdrawals**: Owner can withdraw any tokens in case of stuck funds.

## Contract Details

### OrbitFlashArbitrage.sol

#### Key Functions

- `executeArbitrage(ArbitrageParams calldata params)`: Initiates a flash loan and executes arbitrage trades. Tracks the initiator for profit sharing.
- `executeOperation(...)`: Aave flash loan callback. Executes trades, calculates profit, repays loan, and distributes profit.
- `updateOwnerFee(uint256 newFeeBasisPoints)`: Owner can update the fee (max 5%).
- `emergencyWithdraw(address token, uint256 amount)`: Owner-only withdrawal of specific token and amount.
- `emergencyWithdrawAll(address token)`: Owner-only withdrawal of all of a specific token.
- `getTokenBalance(address token)`: View token balance held by contract.
- `canExecuteFlashLoan(address asset, uint256 amount)`: Checks if a flash loan can be executed for a given asset/amount.

#### ArbitrageParams Struct

```solidity
struct ArbitrageParams {
   address tokenIn;        // Input token address
   address tokenOut;       // Output token address
   uint256 amountIn;       // Amount to borrow via flash loan
   uint256 minProfit;      // Minimum profit threshold
   address[] dexAddresses; // Array of DEX contract addresses
   bytes[] swapCalldata;   // Array of encoded swap function calls
   address initiator;      // Arbitrage initiator (set automatically)
}
```

#### Events

- `ArbitrageExecuted`: Emitted on successful arbitrage with details.
- `ArbitrageFailed`: Emitted if a DEX call fails or profit is insufficient.
- `OwnerFeeUpdated`: Emitted when owner fee is changed.

#### Security

- **ReentrancyGuard**: Protects against reentrancy attacks.
- **Ownable**: Owner-only functions for fee updates and emergency withdrawals.
- **Input Validation**: Checks for valid tokens, amounts, and DEX calldata.
- **No Ether Acceptance**: Contract rejects direct Ether transfers.

## Usage

1. Deploy the contract with the Aave PoolAddressesProvider address.
2. Call `executeArbitrage` with the required parameters to initiate a flash loan and arbitrage.
3. Owner can update fee and withdraw stuck tokens if needed.

## Example

```solidity
OrbitFlashArbitrage.executeArbitrage(
   ArbitrageParams({
      tokenIn: 0x...,         // Token to borrow
      tokenOut: 0x...,        // Token to receive
      amountIn: 1000e18,      // Amount to borrow
      minProfit: 10e18,       // Minimum profit required
      dexAddresses: [dex1, dex2],
      swapCalldata: [calldata1, calldata2],
      initiator: address(0)   // Will be set automatically
   })
);
```

## Notes

- The contract is designed for use with Aave V3 and ERC20 tokens.
- Owner fee is configurable up to 5%.
- All arbitrage logic is atomic; if any trade fails, the transaction reverts.

---

For more details, see the contract source: `contracts/OrbitFlashArbitrage.sol`

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
