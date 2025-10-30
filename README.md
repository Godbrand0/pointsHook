# PointsHook

A Uniswap V4 hook that awards loyalty points to users and tracks pool-specific analytics.

## Overview

PointsHook is a smart contract that integrates with Uniswap V4 to create a loyalty points system. It automatically awards points to users when they swap ETH for tokens in participating pools.

## Core Features

### Points Awarding System
- **Automatic Point Distribution**: Users receive points automatically when swapping ETH for tokens
- **Point Calculation**: Points are calculated as 20% of the ETH spent in a swap
- **ERC1155 Tokens**: Points are issued as ERC1155 tokens, with the pool ID serving as the token ID
- **User Identification**: User addresses are passed through the `hookData` parameter during swaps

### Pool Analytics (New Feature)
- **Per-Pool Tracking**: Each pool maintains a separate counter for total points awarded
- **Engagement Metrics**: Enables analytics on pool-specific user engagement
- **Easy Access**: Total points per pool can be retrieved via the `getTotalPointsByPool()` function

## How It Works

1. **Swap Execution**: A user performs a swap in an ETH-TOKEN pool with the PointsHook attached
2. **Hook Trigger**: The `afterSwap` hook function is triggered after the swap completes
3. **Point Calculation**: The contract calculates points as 20% of the ETH spent
4. **Point Minting**: ERC1155 tokens are minted to the user's address
5. **Analytics Update**: The pool's total points counter is incremented

## Usage Examples

### Basic Point Awarding
```solidity
// When performing a swap, include the user's address in hookData
bytes memory hookData = abi.encode(userAddress);
// Points are automatically awarded to the user
```

### Pool Analytics
```solidity
// Get total points awarded in a specific pool
PoolId poolId = key.toId();
uint256 totalPoints = pointsHook.getTotalPointsByPool(poolId);
console.log("Pool has awarded", totalPoints, "points in total");
```

## Technical Details

### Hook Configuration
- **Hook Used**: `afterSwap`
- **Pool Type**: ETH-TOKEN pools where ETH is currency0
- **Swap Direction**: Only awards points for ETH → Token swaps (zeroForOne)

### Storage Structure
```solidity
// Tracks total points awarded per pool
mapping(PoolId => uint256) public totalPointsByPool;
```

### Key Functions
- `_assignPoints()`: Internal function that mints points and updates pool totals
- `getTotalPointsByPool()`: Public function to retrieve pool-specific analytics
- `_afterSwap()`: Hook implementation that processes swaps and awards points

## Development

### Prerequisites
- Foundry framework
- Solidity 0.8.26

### Building
```bash
forge build
```

### Testing
```bash
forge test
```



## License

MIT License
