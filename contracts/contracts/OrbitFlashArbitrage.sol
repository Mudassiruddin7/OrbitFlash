// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/interfaces/IFlashLoanSimpleReceiver.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OrbitFlashArbitrage
 * @dev Flash loan arbitrage contract for OrbitFlash system
 */
contract OrbitFlashArbitrage is IFlashLoanSimpleReceiver, ReentrancyGuard, Ownable {
    struct ArbitrageParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minProfit;
        address[] dexAddresses;
        bytes[] swapCalldata;
    }

    IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    IPool public immutable POOL;

    event ArbitrageExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 profit
    );

    event ArbitrageFailed(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        string reason
    );

    constructor(address _addressProvider) Ownable(msg.sender) {
        ADDRESSES_PROVIDER = IPoolAddressesProvider(_addressProvider);
        POOL = IPool(IPoolAddressesProvider(_addressProvider).getPool());
    }

    /**
     * @dev Execute arbitrage using flash loan
     * @param params ArbitrageParams struct containing trade details
     */
    function executeArbitrage(ArbitrageParams calldata params) external onlyOwner {
        require(params.tokenIn != address(0), "Invalid tokenIn");
        require(params.tokenOut != address(0), "Invalid tokenOut");
        require(params.amountIn > 0, "Invalid amountIn");
        require(params.dexAddresses.length > 0, "No DEX addresses");
        require(params.dexAddresses.length == params.swapCalldata.length, "Mismatched arrays");

        bytes memory encodedParams = abi.encode(params);

        POOL.flashLoanSimple(
            address(this),
            params.tokenIn,
            params.amountIn,
            encodedParams,
            0 // referralCode
        );
    }

    /**
     * @dev Aave flash loan callback function
     * @param asset The address of the flash-borrowed asset
     * @param amount The amount of the flash-borrowed asset
     * @param premium The fee of the flash-borrowed asset
     * @param initiator The address of the flashloan initiator
     * @param params The byte-encoded params passed when initiating the flashloan
     * @return True if the execution of the operation succeeds, false otherwise
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override nonReentrant returns (bool) {
        require(msg.sender == address(POOL), "Caller must be POOL");
        require(initiator == address(this), "Initiator must be this contract");

        // Decode the arbitrage parameters
        ArbitrageParams memory arbitrageParams = abi.decode(params, (ArbitrageParams));

        require(asset == arbitrageParams.tokenIn, "Asset mismatch");
        require(amount == arbitrageParams.amountIn, "Amount mismatch");

        // Execute the arbitrage trades
        uint256 profit = _executeArbitrageTrades(arbitrageParams);

        // Calculate total amount to repay (principal + premium)
        uint256 totalDebt = amount + premium;

        // Verify minimum profit requirement
        require(profit >= arbitrageParams.minProfit, "Insufficient profit");
        require(profit >= totalDebt, "Insufficient funds to repay loan");

        // Approve the pool to pull the funds for repayment
        IERC20(asset).approve(address(POOL), totalDebt);

        // Calculate net profit after repaying the loan
        uint256 netProfit = profit - totalDebt;

        emit ArbitrageExecuted(
            arbitrageParams.tokenIn,
            arbitrageParams.tokenOut,
            arbitrageParams.amountIn,
            netProfit
        );

        return true;
    }

    /**
     * @dev Execute arbitrage trades across multiple DEXs
     * @param params ArbitrageParams containing trade details
     * @return profit The total profit from the arbitrage
     */
    function _executeArbitrageTrades(ArbitrageParams memory params) private returns (uint256 profit) {
        // Record initial balance of tokenOut
        uint256 initialBalance = IERC20(params.tokenOut).balanceOf(address(this));

        // Execute trades on each DEX
        for (uint256 i = 0; i < params.dexAddresses.length;) {
            address dexAddress = params.dexAddresses[i];
            bytes memory calldata_ = params.swapCalldata[i];

            require(dexAddress != address(0), "Invalid DEX address");
            require(calldata_.length > 0, "Empty calldata");

            // Execute the swap using low-level call
            (bool success, bytes memory returnData) = dexAddress.call(calldata_);
            
            if (!success) {
                // If call failed, revert with the error message
                if (returnData.length > 0) {
                    assembly {
                        let returnDataSize := mload(returnData)
                        revert(add(32, returnData), returnDataSize)
                    }
                } else {
                    revert("DEX call failed");
                }
            }

            unchecked {
                ++i;
            }
        }

        // Calculate profit as the difference in tokenOut balance
        uint256 finalBalance = IERC20(params.tokenOut).balanceOf(address(this));
        
        require(finalBalance > initialBalance, "No profit generated");
        
        profit = finalBalance - initialBalance;
    }

    /**
     * @dev Emergency function to withdraw tokens
     * @param token Token address to withdraw
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= amount, "Insufficient balance");
        
        IERC20(token).transfer(owner(), amount);
    }

    /**
     * @dev Emergency function to withdraw all tokens
     * @param token Token address to withdraw
     */
    function emergencyWithdrawAll(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(owner(), balance);
        }
    }

    /**
     * @dev Get the balance of a token held by this contract
     * @param token Token address
     * @return balance Token balance
     */
    function getTokenBalance(address token) external view returns (uint256 balance) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @dev Check if the contract can execute a flash loan for the given amount
     * @param asset Asset address
     * @param amount Amount to borrow
     * @return canExecute Whether the flash loan can be executed
     */
    function canExecuteFlashLoan(address asset, uint256 amount) external view returns (bool canExecute) {
        try POOL.getReserveData(asset) returns (
            uint256 configuration,
            uint128 liquidityIndex,
            uint128 currentLiquidityRate,
            uint128 variableBorrowIndex,
            uint128 currentVariableBorrowRate,
            uint128 currentStableBorrowRate,
            uint40 lastUpdateTimestamp,
            uint16 id,
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress,
            address interestRateStrategyAddress,
            uint128 accruedToTreasury,
            uint128 unbacked,
            uint128 isolationModeTotalDebt
        ) {
            // Check if the asset is active and borrowing is enabled
            // This is a simplified check - in production you'd decode the configuration bitmap
            return aTokenAddress != address(0) && amount > 0;
        } catch {
            return false;
        }
    }

    /**
     * @dev Fallback function to reject direct Ether transfers
     */
    receive() external payable {
        revert("Contract does not accept Ether");
    }
}
