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

## Deployment

### Environment Setup
1. Copy `.env.example` to `.env` and fill in your values:
```bash
cp .env.example .env
```

2. Edit `.env` with your deployment parameters:
- `PRIVATE_KEY`: Your deployer private key (without 0x prefix)
- `POOL_MANAGER_ADDRESS`: The Uniswap V4 PoolManager address for your target network
- `RPC_URL`: RPC endpoint for the network you're deploying to
- `CHAIN_ID`: Chain ID of the target network
- `ETHERSCAN_API_KEY`: (Optional) API key for contract verification

### Deploying to Testnet
```bash
forge script script/DeployPointsHook.s.sol \
  --rpc-url $RPC_URL \
  --chain-id $CHAIN_ID \
  --broadcast
```

### Deploying to Mainnet
```bash
forge script script/DeployPointsHook.s.sol \
  --rpc-url $RPC_URL \
  --chain-id $CHAIN_ID \
  --broadcast \
  --verify
```

### Dry Run (Simulation)
To simulate deployment without actually deploying:
```bash
forge script script/DeployPointsHook.s.sol \
  --rpc-url $RPC_URL \
  --chain-id $CHAIN_ID
```

### Network-Specific PoolManager Addresses
- Base Sepolia Testnet: `0x05E73354cFDd6745C338b50BcFDfA3Aa6fA03408`


Note: Check the official Uniswap V4 documentation for the latest PoolManager addresses.

## Deployed Contracts

### Base Sepolia Testnet
- **Contract Address**: `0xf03941828424a65c4A5fCD50B4957a1bE2228040`
- **Network**: Base Sepolia (Chain ID: 84532)
- **Transaction Hash**: `0x2fa366e774895b63275486f03ee42acbd486c93e37af4adc5724cb9793180621`
- **Block Number**: 33089427
- **Gas Used**: 1,668,461
- **Deployment Cost**: 0.000001668679568391 ETH
- **Verification**: [Verified on Basescan](https://sepolia.basescan.org/address/0xf03941828424a65c4a5fcd50b4957a1be2228040)
- **PoolManager**: `0x05E73354cFDd6745C338b50BcFDfA3Aa6fA03408`

### Deployment Command Used
```bash
forge script script/PointsHook.s.sol:PointsHookScript \
  --rpc-url https://sepolia.base.org \
  --chain-id 84532 \
  --broadcast \
  --verify
```



## License

MIT License
