// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
 
import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {ERC1155} from "solmate/src/tokens/ERC1155.sol";
 
import {Currency} from "v4-core/types/Currency.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId} from "v4-core/types/PoolId.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
 
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
 
import {Hooks} from "v4-core/libraries/Hooks.sol";
 
/**
 * @title PointsHook
 * @notice Uniswap V4 hook that awards loyalty points for swaps
 *
 * Features:
 * - Awards ERC1155 points to users who swap ETH for tokens
 * - Tracks total points awarded per pool for analytics
 * - Points are calculated as 20% of ETH spent in swaps
 *
 * Pool Points Tracking:
 * - Each pool maintains a separate counter for total points awarded
 * - This enables analytics on pool-specific engagement
 * - Data can be accessed via getTotalPointsByPool() function
 */
contract PointsHook is BaseHook, ERC1155 {
    // Mapping to track total points awarded per pool
    // Key: PoolId - Unique identifier for each Uniswap V4 pool
    // Value: uint256 - Cumulative points awarded in this pool
    mapping(PoolId => uint256) public totalPointsByPool;

    constructor(
        IPoolManager _manager
    ) BaseHook(_manager) {}
 
	// Set up hook permissions to return `true`
	// for the two hook functions we are using
    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterAddLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: false,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }
 
    // Implement the ERC1155 `uri` function
    function uri(uint256) public view virtual override returns (string memory) {
        return "https://api.example.com/token/{id}";
    }

    /**
     * @dev Assigns points to a user and tracks pool totals
     *
     * This function:
     * 1. Validates the hookData contains a valid user address
     * 2. Mints ERC1155 points to the user (poolId is used as tokenId)
     * 3. Updates the pool's total points counter
     *
     * @param poolId The ID of the pool where the swap occurred
     * @param hookData Calldata containing the user address (abi-encoded)
     * @param points The amount of points to award
     */
    function _assignPoints(
    PoolId poolId,
    bytes calldata hookData,
    uint256 points
) internal {
    // If no hookData is passed in, no points will be assigned to anyone
    if (hookData.length == 0) return;
 
    // Extract user address from hookData
    address user = abi.decode(hookData, (address));
 
    // If there is hookData but not in the format we're expecting and user address is zero
    // nobody gets any points
    if (user == address(0)) return;
 
    // Mint points to the user
    uint256 poolIdUint = uint256(PoolId.unwrap(poolId));
    _mint(user, poolIdUint, points, "");
    
    // Update pool analytics: increment total points awarded for this pool
    totalPointsByPool[poolId] += points;
}

    /**
     * @notice Gets the total points awarded for a specific pool
     * @dev This is useful for analytics and understanding pool engagement
     *
     * Example:
     *   PoolId poolId = key.toId();
     *   uint256 totalPoints = pointsHook.getTotalPointsByPool(poolId);
     *   console.log("Pool has awarded", totalPoints, "points in total");
     *
     * @param poolId The ID of the pool to query
     * @return totalPoints The total points awarded in this pool since deployment
     */
    function getTotalPointsByPool(PoolId poolId) external view returns (uint256 totalPoints) {
        return totalPointsByPool[poolId];
    }
 
	function _afterSwap(
    address,
    PoolKey calldata key,
    SwapParams calldata swapParams,
    BalanceDelta delta,
    bytes calldata hookData
) internal override returns (bytes4, int128) {
    // If this is not an ETH-TOKEN pool with this hook attached, ignore
    if (!key.currency0.isAddressZero()) return (this.afterSwap.selector, 0);
 
    // We only mint points if user is buying TOKEN with ETH
    if (!swapParams.zeroForOne) return (this.afterSwap.selector, 0);
 
    // Mint points equal to 20% of the amount of ETH they spent
    // Since it's a zeroForOne swap:
    // if amountSpecified < 0:
    //      this is an "exact input for output" swap
    //      amount of ETH they spent is equal to |amountSpecified|
    // if amountSpecified > 0:
    //      this is an "exact output for input" swap
    //      amount of ETH they spent is equal to BalanceDelta.amount0()
 
    uint256 ethSpendAmount = uint256(int256(-delta.amount0()));
    uint256 pointsForSwap = ethSpendAmount / 5;
 
    // Mint the points
    _assignPoints(key.toId(), hookData, pointsForSwap);
 
    return (this.afterSwap.selector, 0);
}

    
}