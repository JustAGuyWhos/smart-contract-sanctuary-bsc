// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

// Uncomment if needed.
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../multicall.sol";
import "../libraries/Math.sol";

import "../base/BaseTimestamp.sol";


/// @title iZiSwap Liquidity Mining Main Contract
contract FixRangeTimestamp is BaseTimestamp, IERC721Receiver {
    using Math for int24;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    /// @dev Contract of the uniV3 Nonfungible Position Manager.
    address iZiSwapLiquidityManager;

    /// @dev The reward range of this mining contract.
    int24 rewardUpperTick;
    int24 rewardLowerTick;

    /// @dev Record the status for a certain token for the last touched time.
    struct TokenStatus {
        uint256 vLiquidity;
        uint256 validVLiquidity;
        uint256 nIZI;
        uint256 lastTouchTime;
        uint256 lastRemainTokenX;
        uint256 lastRemainTokenY;
        uint256[] lastTouchAccRewardPerShare;
    }

    mapping(uint256 => TokenStatus) public tokenStatus;

    function tokenStatusLastTouchAccRewardPerShare(uint256 tokenId) public view returns(uint256[] memory lastTouchAccRewardPerShare) {
        if (rewardInfosLen > 0) {
            lastTouchAccRewardPerShare = new uint256[](rewardInfosLen);
            TokenStatus memory ts = tokenStatus[tokenId];
            for (uint256 i = 0; i < rewardInfosLen; i ++) {
                lastTouchAccRewardPerShare[i] = ts.lastTouchAccRewardPerShare[i];
            }
        }
    }

    // override for mining base
    function getBaseTokenStatus(uint256 tokenId) internal override view returns(BaseTokenStatus memory t) {
        TokenStatus memory ts = tokenStatus[tokenId];
        t = BaseTokenStatus({
            vLiquidity: ts.vLiquidity,
            validVLiquidity: ts.validVLiquidity,
            nIZI: ts.nIZI,
            lastTouchAccRewardPerShare: ts.lastTouchAccRewardPerShare
        });
    }
    struct PoolParams {
        address iZiSwapLiquidityManager;
        address tokenX;
        address tokenY;
        uint24 fee;
    }

    receive() external payable {}

    constructor(
        PoolParams memory poolParams,
        RewardInfo[] memory _rewardInfos,
        address iziTokenAddr,
        int24 _rewardUpperTick,
        int24 _rewardLowerTick,
        uint256 _startTime,
        uint256 _endTime,
        uint24 _feeChargePercent,
        address _chargeReceiver
    ) BaseTimestamp (_feeChargePercent, poolParams.iZiSwapLiquidityManager, poolParams.tokenX, poolParams.tokenY, poolParams.fee, _chargeReceiver, "FixRangeTimestamp") {
        iZiSwapLiquidityManager = poolParams.iZiSwapLiquidityManager;

        require(_rewardLowerTick < _rewardUpperTick, "L<U");
        require(poolParams.tokenX < poolParams.tokenY, "TOKEN0 < TOKEN1 NOT MATCH");

        rewardInfosLen = _rewardInfos.length;
        require(rewardInfosLen > 0, "NO REWARD");
        require(rewardInfosLen < 3, "AT MOST 2 REWARDS");

        for (uint256 i = 0; i < rewardInfosLen; i++) {
            rewardInfos[i] = _rewardInfos[i];
            rewardInfos[i].accRewardPerShare = 0;
        }

        // iziTokenAddr == 0 means not boost
        iziToken = IERC20(iziTokenAddr);

        rewardUpperTick = _rewardUpperTick;
        rewardLowerTick = _rewardLowerTick;

        startTime = _startTime;
        endTime = _endTime;

        lastTouchTime = startTime;

        totalVLiquidity = 0;
        totalNIZI = 0;

    }

    /// @notice Used for ERC721 safeTransferFrom
    function onERC721Received(address, address, uint256, bytes memory) 
        public 
        virtual 
        override 
        returns (bytes4) 
    {
        return this.onERC721Received.selector;
    }

    /// @notice Get the overall info for the mining contract.
    function getMiningContractInfo()
        external
        view
        returns (
            address tokenX_,
            address tokenY_,
            uint24 fee_,
            RewardInfo[] memory rewardInfos_,
            address iziTokenAddr_,
            int24 rewardUpperTick_,
            int24 rewardLowerTick_,
            uint256 lastTouchTime_,
            uint256 totalVLiquidity_,
            uint256 startTime_,
            uint256 endTime_
        )
    {
        rewardInfos_ = new RewardInfo[](rewardInfosLen);
        for (uint256 i = 0; i < rewardInfosLen; i++) {
            rewardInfos_[i] = rewardInfos[i];
        }
        return (
            rewardPool.tokenX,
            rewardPool.tokenY,
            rewardPool.fee,
            rewardInfos_,
            address(iziToken),
            rewardUpperTick,
            rewardLowerTick,
            lastTouchTime,
            totalVLiquidity,
            startTime,
            endTime
        );
    }

    /// @notice Compute the virtual liquidity from a liquidity's parameters.
    /// @param tickLower The lower tick of a liquidity.
    /// @param tickUpper The upper tick of a liquidity.
    /// @param liquidity The liquidity of a a liquidity.
    /// @dev vLiquidity = liquidity * validRange^2 / 1e6, where the validRange is the tick amount of the
    /// intersection between the liquidity and the reward range.
    /// We divided it by 1e6 to keep vLiquidity smaller than Q128 in most cases. This is safe since liqudity is usually a large number.
    function _getVLiquidityForNFT(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    ) internal view returns (uint256 vLiquidity) {
        // liquidity is roughly equals to sqrt(amountX*amountY)
        require(liquidity >= 1e6, "LIQUIDITY TOO SMALL");
        uint256 validRange = uint24(
            Math.max(
                Math.min(rewardUpperTick, tickUpper) - Math.max(rewardLowerTick, tickLower),
                0
            )
        );
        vLiquidity = (validRange * validRange * uint256(liquidity)) / 1e6;
        return vLiquidity;
    }

    /// @notice new a token status when touched.
    function _newTokenStatus(
        uint256 tokenId,
        uint256 vLiquidity,
        uint256 validVLiquidity,
        uint256 nIZI,
        uint256 lastRemainTokenX,
        uint256 lastRemainTokenY
    ) internal {
        TokenStatus storage t = tokenStatus[tokenId];

        t.vLiquidity = vLiquidity;
        t.validVLiquidity = validVLiquidity;
        t.nIZI = nIZI;

        t.lastTouchTime = lastTouchTime;
        t.lastTouchAccRewardPerShare = new uint256[](rewardInfosLen);
        t.lastRemainTokenX = lastRemainTokenX;
        t.lastRemainTokenY = lastRemainTokenY;
        for (uint256 i = 0; i < rewardInfosLen; i++) {
            t.lastTouchAccRewardPerShare[i] = rewardInfos[i].accRewardPerShare;
        }
    }

    /// @notice update a token status when touched
    function _updateTokenStatus(
        uint256 tokenId,
        uint256 validVLiquidity,
        uint256 nIZI
    ) internal override {
        TokenStatus storage t = tokenStatus[tokenId];

        // when not boost, validVL == vL
        t.validVLiquidity = validVLiquidity;
        t.nIZI = nIZI;

        t.lastTouchTime = lastTouchTime;
        for (uint256 i = 0; i < rewardInfosLen; i++) {
            t.lastTouchAccRewardPerShare[i] = rewardInfos[i].accRewardPerShare;
        }
    }

    function _computeValidVLiquidity(uint256 vLiquidity, uint256 nIZI)
        internal override
        view
        returns (uint256)
    {
        if (totalNIZI == 0) {
            return vLiquidity;
        }
        uint256 iziVLiquidity = (vLiquidity * 4 + (totalVLiquidity * nIZI * 6) / totalNIZI) / 10;
        return Math.min(iziVLiquidity, vLiquidity);
    }

    /// @notice Deposit a single liquidity.
    /// @param tokenId The related liquidity id.
    /// @param nIZI the amount of izi to lock
    function deposit(uint256 tokenId, uint256 nIZI)
        external
        returns (uint256 vLiquidity)
    {
        address owner = IiZiSwapLiquidityManager(iZiSwapLiquidityManager).ownerOf(tokenId);
        require(owner == msg.sender, "NOT OWNER");
        IiZiSwapLiquidityManager.Liquidity memory liquidity;

        (
            liquidity.leftPt,
            liquidity.rightPt,
            liquidity.liquidity,
            liquidity.lastFeeScaleX_128,
            liquidity.lastFeeScaleY_128,
            liquidity.remainTokenX,
            liquidity.remainTokenY,
            liquidity.poolId
        ) = IiZiSwapLiquidityManager(iZiSwapLiquidityManager).liquidities(tokenId);

        IiZiSwapLiquidityManager.PoolMeta memory poolMeta;

        (
            poolMeta.tokenX,
            poolMeta.tokenY,
            poolMeta.fee
        ) = IiZiSwapLiquidityManager(iZiSwapLiquidityManager).poolMetas(liquidity.poolId);

        // alternatively we can compute the pool address with tokens and fee and compare the address directly
        require(poolMeta.tokenX == rewardPool.tokenX, "TOEKN0 NOT MATCH");
        require(poolMeta.tokenY == rewardPool.tokenY, "TOKEN1 NOT MATCH");
        require(poolMeta.fee == rewardPool.fee, "FEE NOT MATCH");

        // require the NFT token has interaction with [rewardLowerTick, rewardUpperTick]
        vLiquidity = _getVLiquidityForNFT(liquidity.leftPt, liquidity.rightPt, liquidity.liquidity);
        require(vLiquidity > 0, "INVALID TOKEN");

        IiZiSwapLiquidityManager(iZiSwapLiquidityManager).safeTransferFrom(msg.sender, address(this), tokenId);
        owners[tokenId] = msg.sender;
        bool res = tokenIds[msg.sender].add(tokenId);
        require(res);

        // the execution order for the next three lines is crutial
        _updateGlobalStatus();
        _updateVLiquidity(vLiquidity, true);
        if (address(iziToken) == address(0)) {
            // boost is not enabled
            nIZI = 0;
        }
        _updateNIZI(nIZI, true);
        uint256 validVLiquidity = _computeValidVLiquidity(vLiquidity, nIZI);
        require(nIZI < FixedPoints.Q128 / 6, "NIZI O");
        _newTokenStatus(tokenId, vLiquidity, validVLiquidity, nIZI, uint256(liquidity.remainTokenX), uint256(liquidity.remainTokenY));
        if (nIZI > 0) {
            // lock izi in this contract
            iziToken.safeTransferFrom(msg.sender, address(this), nIZI);
        }

        emit Deposit(msg.sender, tokenId, nIZI);
        return vLiquidity;
    }

    /// @notice withdraw a single liquidity.
    /// @param tokenId The related liquidity id.
    /// @param noReward true if donot collect reward
    function withdraw(uint256 tokenId, bool noReward) external nonReentrant {
        require(owners[tokenId] == msg.sender, "NOT OWNER OR NOT EXIST");

        if (noReward) {
            _updateGlobalStatus();
        } else {
            _collectReward(tokenId);
        }
        uint256 vLiquidity = tokenStatus[tokenId].vLiquidity;
        _updateVLiquidity(vLiquidity, false);
        uint256 nIZI = tokenStatus[tokenId].nIZI;
        if (nIZI > 0) {
            _updateNIZI(nIZI, false);
            // refund iZi to user
            iziToken.safeTransfer(msg.sender, nIZI);
        }

        // charge and refund remain fee to user

        uint256 amountX;
        uint256 amountY;

        try
            IiZiSwapLiquidityManager(
                iZiSwapLiquidityManager
            ).collect(
                address(this),
                tokenId,
                type(uint128).max,
                type(uint128).max
            ) returns(uint256 ax, uint256 ay)
        {
            amountX = ax;
            amountY = ay;
        } catch (bytes memory) {
            // if revert, 
            amountX = 0;
            amountY = 0;
        }

        uint256 lastRemainTokenX = Math.min(tokenStatus[tokenId].lastRemainTokenX, amountX);
        uint256 lastRemainTokenY = Math.min(tokenStatus[tokenId].lastRemainTokenY, amountY);

        uint256 refundAmountX = lastRemainTokenX + (amountX - lastRemainTokenX) * feeRemainPercent / 100;
        uint256 refundAmountY = lastRemainTokenY + (amountY - lastRemainTokenY) * feeRemainPercent / 100;
        _safeTransferToken(rewardPool.tokenX, msg.sender, refundAmountX);
        _safeTransferToken(rewardPool.tokenY, msg.sender, refundAmountY);
        totalFeeChargedX += amountX - refundAmountX;
        totalFeeChargedY += amountY - refundAmountY;

        IiZiSwapLiquidityManager(iZiSwapLiquidityManager).safeTransferFrom(address(this), msg.sender, tokenId);
        owners[tokenId] = address(0);
        bool res = tokenIds[msg.sender].remove(tokenId);
        require(res);

        emit Withdraw(msg.sender, tokenId);
    }

    /// @notice Collect pending reward for a single liquidity.
    /// @param tokenId The related liquidity id.
    function collectReward(uint256 tokenId) external nonReentrant {
        require(owners[tokenId] == msg.sender, "NOT OWNER OR NOT EXIST");
        _collectReward(tokenId);
    }

    /// @notice Collect all pending rewards.
    function collectRewards() external nonReentrant {
        EnumerableSet.UintSet storage ids = tokenIds[msg.sender];
        for (uint256 i = 0; i < ids.length(); i++) {
            require(owners[ids.at(i)] == msg.sender, "NOT OWNER");
            _collectReward(ids.at(i));
        }
    }

    // Control fuctions for the contract owner and operators.

    /// @notice If something goes wrong, we can send back user's nft and locked iZi
    /// @param tokenId The related liquidity id.
    function emergenceWithdraw(uint256 tokenId) external override onlyOwner {
        address owner = owners[tokenId];
        require(owner != address(0));
        IiZiSwapLiquidityManager(iZiSwapLiquidityManager).safeTransferFrom(
            address(this),
            owners[tokenId],
            tokenId
        );
        uint256 nIZI = tokenStatus[tokenId].nIZI;
        if (nIZI > 0) {
            // we should ensure nft refund to user
            // omit the case when transfer() returns false unexpectedly
            iziToken.transfer(owner, nIZI);
        }
        // make sure user cannot withdraw/depositIZI or collect reward on this nft
        owners[tokenId] = address(0);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

//  SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall {
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @title Simple math library for Max and Min.
library Math {
    function max(int24 a, int24 b) internal pure returns (int24) {
        return a >= b ? a : b;
    }

    function min(int24 a, int24 b) internal pure returns (int24) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function tickFloor(int24 tick, int24 tickSpacing)
        internal
        pure
        returns (int24)
    {
        int24 c = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) {
            c = c - 1;
        }
        c = c * tickSpacing;
        return c;
    }

    function tickUpper(int24 tick, int24 tickSpacing)
        internal
        pure
        returns (int24)
    {
        int24 c = tick / tickSpacing;
        if (tick > 0 && tick % tickSpacing != 0) {
            c = c + 1;
        }
        c = c * tickSpacing;
        return c;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

// Uncomment if needed.
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../libraries/FixedPoints.sol";
import "../libraries/Math.sol";

import "../iZiSwap/interfaces.sol";

import "../multicall.sol";

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

abstract contract BaseTimestamp is Ownable, Multicall, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    /// @dev Last second timestamp that the accRewardRerShare is touched.
    uint256 public lastTouchTime;

    /// @dev The second timestamp when NFT mining rewards starts/ends.
    uint256 public startTime;
    uint256 public endTime;
    struct RewardInfo {
        /// @dev Contract of the reward erc20 token.
        address rewardToken;
        /// @dev who provides reward
        address provider;
        /// @dev Accumulated Reward Tokens per share, times Q128.
        uint256 accRewardPerShare;
        /// @dev Reward amount for each second.
        uint256 rewardPerSecond;
    }

    mapping(uint256 => RewardInfo) public rewardInfos;
    uint256 public rewardInfosLen;

    /// @dev Store the owner of the NFT token
    mapping(uint256 => address) public owners;
    /// @dev The inverse mapping of owners.
    mapping(address => EnumerableSet.UintSet) internal tokenIds;

    /// @dev token to lock, 0 for not boost
    IERC20 public iziToken;
    /// @dev current total nIZI.
    uint256 public totalNIZI;

    /// @notice Current total virtual liquidity.
    uint256 public totalVLiquidity;

    /// @notice (1 - feeRemainPercent/100) is charging rate of iZiSwap fee
    uint24 public feeRemainPercent;

    uint256 public totalFeeChargedX;
    uint256 public totalFeeChargedY;


    struct PoolInfo {
        address tokenX;
        address tokenY;
        uint24 fee;
    }

    PoolInfo public rewardPool;

    address public weth;

    address public chargeReceiver;

    string public contractType;

    /// @notice emit if user successfully deposit
    /// @param user user
    /// @param tokenId id of mining (same as iZiSwap nft token id)
    /// @param nIZI amount of boosted iZi
    event Deposit(address indexed user, uint256 tokenId, uint256 nIZI);
    /// @notice emit if user successfully withdraw
    /// @param user user
    /// @param tokenId id of mining (same as iZiSwap nft token id)
    event Withdraw(address indexed user, uint256 tokenId);
    /// @notice emit if user successfully collect reward
    /// @param user user
    /// @param tokenId id of mining (same as iZiSwap nft token id)
    /// @param token address of reward erc-20 token
    /// @param amount amount of erc-20 token user received 
    event CollectReward(address indexed user, uint256 tokenId, address token, uint256 amount);
    /// @notice emit if contract owner successfully calls modifyEndTime(...)
    /// @param endTime end time stamp
    event ModifyEndTime(uint256 endTime);
    /// @notice emit if contract owner successfully calls modifyRewardPerSecond(...)
    /// @param rewardToken address of reward erc20-token
    /// @param rewardPerSecond new reward per second of 'rewardToken'
    event ModifyRewardPerSecond(address indexed rewardToken, uint256 rewardPerSecond);
    /// @notice emit if contract owner successfully calls modifyProvider(...)
    /// @param rewardToken address of reward erc20-token
    /// @param provider New provider
    event ModifyProvider(address indexed rewardToken, address provider);

    function _setRewardPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal {
        (rewardPool.tokenX, rewardPool.tokenY) = (tokenA < tokenB)? (tokenA, tokenB) : (tokenB, tokenA);
        rewardPool.fee = fee;
        totalFeeChargedX = 0;
        totalFeeChargedY = 0;
    }

    constructor(
        uint24 _feeChargePercent, 
        address _iZiSwapLiquidityManager, 
        address tokenA, 
        address tokenB, 
        uint24 fee, 
        address _chargeReceiver,
        string memory _contractType
    ) {
        require(_feeChargePercent <= 100, "charge percent <= 100");
        feeRemainPercent = 100 - _feeChargePercent;
        // mark weth erc token
        weth = IiZiSwapLiquidityManager(_iZiSwapLiquidityManager).WETH9();
        // receiver to receive charged iZiSwap fee
        chargeReceiver = _chargeReceiver;
        _setRewardPool(tokenA, tokenB, fee);
        contractType = _contractType;
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }

    function _safeTransferToken(address token, address to, uint256 value) internal {
        if (value > 0) {
            if (token == address(weth)) {
                IWETH9(token).withdraw(value);
                _safeTransferETH(to, value);
            } else {
                IERC20(token).safeTransfer(to, value);
            }
        }
    }

    /// @notice Update reward variables to be up-to-date.
    /// @param vLiquidity vLiquidity to add or minus
    /// @param isAdd add or minus
    function _updateVLiquidity(uint256 vLiquidity, bool isAdd) internal {
        if (isAdd) {
            totalVLiquidity = totalVLiquidity + vLiquidity;
        } else {
            totalVLiquidity = totalVLiquidity - vLiquidity;
        }

        // max lockBoostMultiplier is 3
        require(totalVLiquidity <= FixedPoints.Q128 * 3, "TOO MUCH LIQUIDITY STAKED");
    }

    /// @notice Update reward variables to be up-to-date.
    /// @param nIZI amount of boosted iZi to add or minus
    /// @param isAdd add or minus
    function _updateNIZI(uint256 nIZI, bool isAdd) internal {
        if (isAdd) {
            totalNIZI = totalNIZI + nIZI;
        } else {
            totalNIZI = totalNIZI - nIZI;
        }
    }

    /// @notice Update the global status.
    function _updateGlobalStatus() internal {
        if (block.timestamp <= lastTouchTime) {
            return;
        }
        if (lastTouchTime >= endTime) {
            return;
        }
        uint256 currTime = Math.min(block.timestamp, endTime);
        if (totalVLiquidity == 0) {
            lastTouchTime = currTime;
            return;
        }

        for (uint256 i = 0; i < rewardInfosLen; i++) {
            // tokenReward < 2^25 * 2^64 * 2^10, 15 years, 1000 r/second
            uint256 tokenReward = (currTime - lastTouchTime) * rewardInfos[i].rewardPerSecond;
            // tokenReward * Q128 < 2^(25 + 64 + 10 + 128)
            rewardInfos[i].accRewardPerShare = rewardInfos[i].accRewardPerShare + ((tokenReward * FixedPoints.Q128) / totalVLiquidity);
        }
        lastTouchTime = currTime;
    }

    /// @notice compute validVLiquidity
    /// @param vLiquidity origin vLiquidity
    /// @param nIZI amount of boosted iZi
    function _computeValidVLiquidity(uint256 vLiquidity, uint256 nIZI)
        internal virtual
        view
        returns (uint256);

    /// @notice update a token status when touched
    /// @param tokenId id of TokenStatus obj in sub-contracts (same with iZiSwap nft id)
    /// @param validVLiquidity validVLiquidity, can be acquired by _computeValidVLiquidity(...)
    /// @param nIZI latest amount of iZi boost
    function _updateTokenStatus(
        uint256 tokenId,
        uint256 validVLiquidity,
        uint256 nIZI
    ) internal virtual;


    struct BaseTokenStatus {
        uint256 vLiquidity;
        uint256 validVLiquidity;
        uint256 nIZI;
        uint256[] lastTouchAccRewardPerShare;
    }

    /// @notice get base infomation from token status in sub-contracts
    /// @param tokenId id of TokenStatus obj in sub-contracts
    /// @return t contains base infomation (uint256 vLiquidity, uint256 validVLiquidity, uint256 nIZI, uint256[] lastTouchAccRewardPerShare)
    function getBaseTokenStatus(uint256 tokenId) internal virtual view returns(BaseTokenStatus memory t);

    /// @notice deposit iZi to an nft token
    /// @param tokenId nft already deposited
    /// @param deltaNIZI amount of izi to deposit
    function depositIZI(uint256 tokenId, uint256 deltaNIZI)
        external
        nonReentrant
    {
        require(owners[tokenId] == msg.sender, "NOT OWNER or NOT EXIST");
        require(address(iziToken) != address(0), "NOT BOOST");
        require(deltaNIZI > 0, "DEPOSIT IZI MUST BE POSITIVE");
        _collectReward(tokenId);
        BaseTokenStatus memory t = getBaseTokenStatus(tokenId);
        _updateNIZI(deltaNIZI, true);
        uint256 nIZI = t.nIZI + deltaNIZI;
        // update validVLiquidity
        uint256 validVLiquidity = _computeValidVLiquidity(t.vLiquidity, nIZI);
        _updateTokenStatus(tokenId, validVLiquidity, nIZI);

        // transfer iZi from user
        iziToken.safeTransferFrom(msg.sender, address(this), deltaNIZI);
    }

    /// @notice Collect pending reward for a single position. can be called by sub-contracts
    /// @param tokenId The related position id.
    function _collectReward(uint256 tokenId) internal {
        BaseTokenStatus memory t = getBaseTokenStatus(tokenId);

        _updateGlobalStatus();
        for (uint256 i = 0; i < rewardInfosLen; i++) {
            // multiplied by Q128 before
            uint256 _reward = (t.validVLiquidity * (rewardInfos[i].accRewardPerShare - t.lastTouchAccRewardPerShare[i])) / FixedPoints.Q128;
            if (_reward > 0) {
                IERC20(rewardInfos[i].rewardToken).safeTransferFrom(
                    rewardInfos[i].provider,
                    msg.sender,
                    _reward
                );
            }
            emit CollectReward(
                msg.sender,
                tokenId,
                rewardInfos[i].rewardToken,
                _reward
            );
        }

        // update validVLiquidity
        uint256 validVLiquidity = _computeValidVLiquidity(t.vLiquidity, t.nIZI);
        _updateTokenStatus(tokenId, validVLiquidity, t.nIZI);
    }

    /// @notice View function to get position ids staked here for an user.
    /// @param _user The related address.
    /// @return list of tokenId
    function getTokenIds(address _user)
        external
        view
        returns (uint256[] memory)
    {
        EnumerableSet.UintSet storage ids = tokenIds[_user];
        // push could not be used in memory array
        // we set the tokenIdList into a fixed-length array rather than dynamic
        uint256[] memory tokenIdList = new uint256[](ids.length());
        for (uint256 i = 0; i < ids.length(); i++) {
            tokenIdList[i] = ids.at(i);
        }
        return tokenIdList;
    }
    
    /// @notice Return reward time over the given _from to _to timestamp.
    /// @param _from The start timestamp.
    /// @param _to The end timestamp.
    function _getRewardTime(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_from > _to) {
            return 0;
        }
        if (_to <= endTime) {
            return _to - _from;
        } else if (_from >= endTime) {
            return 0;
        } else {
            return endTime - _from;
        }
    }

    /// @notice View function to see pending Reward for a single position.
    /// @param tokenId The related position id.
    /// @return list of pending reward amount for each reward ERC20-token of tokenId
    function pendingReward(uint256 tokenId)
        public
        view
        returns (uint256[] memory)
    {
        BaseTokenStatus memory t = getBaseTokenStatus(tokenId);
        uint256[] memory _reward = new uint256[](rewardInfosLen);
        for (uint256 i = 0; i < rewardInfosLen; i++) {
            uint256 tokenReward = _getRewardTime(
                lastTouchTime,
                block.timestamp
            ) * rewardInfos[i].rewardPerSecond;
            uint256 rewardPerShare = rewardInfos[i].accRewardPerShare + (tokenReward * FixedPoints.Q128) / totalVLiquidity;
            // l * (currentAcc - lastAcc)
            _reward[i] = (t.validVLiquidity * (rewardPerShare - t.lastTouchAccRewardPerShare[i])) / FixedPoints.Q128;
        }
        return _reward;
    }

    /// @notice View function to see pending Rewards for an address.
    /// @param _user The related address.
    /// @return list of pending reward amount for each reward ERC20-token of this user
    function pendingRewards(address _user)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory _reward = new uint256[](rewardInfosLen);
        for (uint256 j = 0; j < rewardInfosLen; j++) {
            _reward[j] = 0;
        }

        for (uint256 i = 0; i < tokenIds[_user].length(); i++) {
            uint256[] memory r = pendingReward(tokenIds[_user].at(i));
            for (uint256 j = 0; j < rewardInfosLen; j++) {
                _reward[j] += r[j];
            }
        }
        return _reward;
    }

    // Control fuctions for the contract owner and operators.

    /// @notice If something goes wrong, we can send back user's nft and locked assets
    /// @param tokenId The related position id.
    function emergenceWithdraw(uint256 tokenId) external virtual;

    /// @notice Set new reward end second.
    /// @param _endTime New end second.
    function modifyEndTime(uint256 _endTime) external onlyOwner {
        require(_endTime > block.timestamp, "OUT OF DATE");
        _updateGlobalStatus();
        // jump if origin endTime < block.timestamp
        lastTouchTime = block.timestamp;
        endTime = _endTime;
        emit ModifyEndTime(endTime);
    }

    /// @notice Set new reward per second.
    /// @param rewardIdx which rewardInfo to modify
    /// @param _rewardPerSecond new reward per second
    function modifyRewardPerSecond(uint256 rewardIdx, uint256 _rewardPerSecond)
        external
        onlyOwner
    {
        require(rewardIdx < rewardInfosLen, "OUT OF REWARD INFO RANGE");
        _updateGlobalStatus();
        rewardInfos[rewardIdx].rewardPerSecond = _rewardPerSecond;
        emit ModifyRewardPerSecond(
            rewardInfos[rewardIdx].rewardToken,
            _rewardPerSecond
        );
    }

    function modifyStartTime(uint256 _startTime) external onlyOwner {
        require(startTime > block.timestamp, 'has started!');
        require(_startTime > block.timestamp, 'Too Early!');
        require(_startTime < endTime, 'Too Late!');
        startTime = _startTime;
        lastTouchTime = _startTime;
    }


    /// @notice Set new reward provider.
    /// @param rewardIdx which rewardInfo to modify
    /// @param provider New provider
    function modifyProvider(uint256 rewardIdx, address provider)
        external
        onlyOwner
    {
        require(rewardIdx < rewardInfosLen, "OUT OF REWARD INFO RANGE");
        rewardInfos[rewardIdx].provider = provider;
        emit ModifyProvider(rewardInfos[rewardIdx].rewardToken, provider);
    }

    function modifyChargeReceiver(address _chargeReceiver) external onlyOwner {
        chargeReceiver = _chargeReceiver;
    }

    function collectFeeCharged() external nonReentrant {
        require(msg.sender == chargeReceiver, "NOT RECEIVER");
        _safeTransferToken(rewardPool.tokenX, chargeReceiver, totalFeeChargedX);
        _safeTransferToken(rewardPool.tokenY, chargeReceiver, totalFeeChargedY);
        totalFeeChargedX = 0;
        totalFeeChargedY = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library FixedPoints {
    uint256 constant Q32 = (1 << 32);
    uint256 constant Q64 = (1 << 64);
    uint256 constant Q96 = (1 << 96);
    uint256 constant Q128 = (1 << 128);
    uint256 constant Q160 = (1 << 160);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IiZiSwapPool {

    function state() external view
    returns(
        uint160 sqrtPrice_96,
        int24 currentPoint,
        uint16 observationCurrentIndex,
        uint16 observationQueueLen,
        uint16 observationNextQueueLen,
        bool locked,
        uint128 liquidity,
        uint128 liquidityX
    );
    
    function observations(uint256 index)
        external
        view
        returns (
            uint32 timestamp,
            int56 accPoint,
            bool init
        );

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory accPoints);
}

interface IiZiSwapFactory {

    function fee2pointDelta(uint24 fee) external view returns (int24 pointDelta);

    function pool(
        address tokenX,
        address tokenY,
        uint24 fee
    ) external view returns(address);

}

interface IiZiSwapLiquidityManager {

    /// @return Returns the address of the Uniswap V3 factory
    function factory() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
    
    // infomation of liquidity provided by miner
    struct Liquidity {
        // left point of liquidity-token, the range is [leftPt, rightPt)
        int24 leftPt;
        // right point of liquidity-token, the range is [leftPt, rightPt)
        int24 rightPt;
        // amount of liquidity on each point in [leftPt, rightPt)
        uint128 liquidity;
        // a 128-fixpoint number, as integral of { fee(pt, t)/L(pt, t) }. 
        // here fee(pt, t) denotes fee generated on point pt at time t
        // L(pt, t) denotes liquidity on point pt at time t
        // pt varies in [leftPt, rightPt)
        // t moves from pool created until miner last modify this liquidity-token (mint/addLiquidity/decreaseLiquidity/create)
        uint256 lastFeeScaleX_128;
        uint256 lastFeeScaleY_128;
        // remained tokenX miner can collect, including fee and withdrawed token
        uint256 remainTokenX;
        uint256 remainTokenY;
        // id of pool in which this liquidity is added
        uint128 poolId;
    }

    function liquidities(uint256 tokenId)
        external
        view
        returns (
            int24 leftPt,
            int24 rightPt,
            uint128 liquidity,
            uint256 lastFeeScaleX_128,
            uint256 lastFeeScaleY_128,
            uint256 remainTokenX,
            uint256 remainTokenY,
            uint128 poolId
        );
    
    struct PoolMeta {
        address tokenX;
        address tokenY;
        uint24 fee;
    }

    function poolMetas(uint128 poolId)
        external
        view
        returns (
            address tokenX,
            address tokenY,
            uint24 fee
        );

    struct MintParam {
        // miner address
        address miner;
        // tokenX of swap pool
        address tokenX;
        // tokenY of swap pool
        address tokenY;
        // fee amount of swap pool
        uint24 fee;
        // left point of added liquidity
        int24 pl;
        // right point of added liquidity
        int24 pr;
        // amount limit of tokenX miner willing to deposit
        uint128 xLim;
        // amount limit tokenY miner willing to deposit
        uint128 yLim;
        // minimum amount of tokenX miner willing to deposit
        uint128 amountXMin;
        // minimum amount of tokenY miner willing to deposit
        uint128 amountYMin;

        uint256 deadline;
    }
    
    /// @notice Refunds any ETH balance held by this contract to the `msg.sender`
    /// @dev Useful for bundling with mint or increase liquidity that uses ether, or exact output swaps
    /// that use ether for the input amount
    function refundETH() external payable;

    function mint(MintParam calldata params)
        external
        payable
        returns (
            uint256 lid,
            uint128 liquidity,
            uint256 amountX,
            uint256 amountY
        );
    
    function decLiquidity(
        uint256 lid,
        uint128 liquidDelta,
        uint256 amountXMin,
        uint256 amountYMin,
        uint256 deadline
    ) external returns (
        uint256 amountX,
        uint256 amountY
    );

    function collect(
        address recipient,
        uint256 lid,
        uint128 amountXLim,
        uint128 amountYLim
    ) external payable returns (
        uint256 amountX,
        uint256 amountY
    );

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}