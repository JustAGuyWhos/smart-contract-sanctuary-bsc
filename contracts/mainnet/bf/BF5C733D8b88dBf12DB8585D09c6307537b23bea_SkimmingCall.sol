// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../strategies/IBonfireStrategicCalls.sol";
import "../swap/IBonfireFactory.sol";
import "../swap/IBonfirePair.sol";
import "../swap/ISwapFactoryRegistry.sol";
import "../swap/BonfireSwapHelper.sol";

contract SkimmingCall is IBonfireStrategicCalls, Ownable {
    address public constant factoryRegistry =
        address(0xBF57511A971278FCb1f8D376D68078762Ae957C4);

    address public override token;
    address[] public pools;

    event Skim(uint256 totalAmountOut, address to);

    event PoolUpdate(address indexed pool, bool enabled);

    error BadValues(uint256 location, address a1, address a2);

    constructor(address gainToken, address admin) Ownable() {
        transferOwnership(admin);
        token = gainToken;
    }

    function sortPools() external {
        pools = _sortPools(pools);
    }

    function skimOnly(address to) external {
        for (uint256 i = 0; i < pools.length; i++) {
            IBonfirePair(pools[i]).skim(to);
        }
    }

    function execute(uint256 threshold, address to)
        external
        override
        returns (uint256 amountOut)
    {
        for (uint256 i = 0; i < pools.length; i++) {
            uint256 gains = _skim(pools[i], to, threshold);
            if (gains > 0) {
                amountOut += gains;
                emit Skim(amountOut, to);
            }
        }
    }

    function quote() external view override returns (uint256 amountOut) {
        for (uint256 i = 0; i < pools.length; i++) {
            (uint256 reserveA, uint256 reserveB, ) = IBonfirePair(pools[i])
                .getReserves();
            (reserveA, reserveB) = IBonfirePair(pools[i]).token1() == token
                ? (reserveA, reserveB)
                : (reserveB, reserveA);
            amountOut += IERC20(token).balanceOf(pools[i]) - reserveB;
        }
    }

    function addPool(address pool) external {
        address factory = IBonfirePair(pool).factory();
        address otherToken = IBonfirePair(pool).token0();
        if (otherToken == token) {
            otherToken = IBonfirePair(pool).token1();
        } else {
            if (IBonfirePair(pool).token1() != token) {
                revert BadValues(0, pool, token); //bad pool
            }
        }
        SkimmingCall(this).addPoolViaFactory(otherToken, factory);
    }

    function addPoolViaFactory(address otherToken, address uniswapFactory)
        external
    {
        bool included = false;
        if (!ISwapFactoryRegistry(factoryRegistry).enabled(uniswapFactory)) {
            revert BadValues(1, factoryRegistry, uniswapFactory); //factory not allowed
        }
        address pool = IBonfireFactory(uniswapFactory).getPair(
            otherToken,
            token
        );
        if (pool == address(0)) {
            revert BadValues(2, token, otherToken); //pool not found
        }
        included = false;
        for (uint256 i = 0; i < pools.length; i++) {
            if (pools[i] == pool) {
                included = true;
                break;
            }
        }
        if (included) {
            revert BadValues(3, pool, token); //pool already present
        }
        pools.push(pool);
        SkimmingCall(this).sortPools();
        emit PoolUpdate(pool, true);
    }

    function _sortPools(address[] memory tokenPools)
        internal
        view
        returns (address[] memory _pools)
    {
        if (tokenPools.length <= 1) return tokenPools;
        _pools = new address[](tokenPools.length);
        uint256[] memory balances = new uint256[](tokenPools.length);
        _pools[0] = tokenPools[0];
        balances[0] = IERC20(token).balanceOf(_pools[0]);
        for (uint256 i = 1; i < _pools.length; i++) {
            address pool = tokenPools[i];
            uint256 balance = IERC20(token).balanceOf(pool);
            uint256 index;
            for (index = i; index > 0; index--) {
                if (balances[index - 1] > balance) {
                    balances[index] = balances[index - 1];
                    _pools[index] = _pools[index - 1];
                } else {
                    break;
                }
            }
            _pools[index] = pool;
            balances[index] = balance;
        }
        return _pools;
    }

    function _skim(
        address pool,
        address to,
        uint256 threshold
    ) internal returns (uint256) {
        (uint256 reserveA, uint256 reserveB, ) = IBonfirePair(pool)
            .getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token1() == token
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        uint256 balance = IERC20(token).balanceOf(pool);
        uint256 surplus = balance - reserveB;
        if (surplus < threshold) {
            return 0;
        }
        uint256 amount = (surplus *
            ISwapFactoryRegistry(factoryRegistry).factoryRemainder(
                IBonfirePair(pool).factory()
            )) /
            ISwapFactoryRegistry(factoryRegistry).factoryDenominator(
                IBonfirePair(pool).factory()
            );
        if (amount < threshold) {
            return 0;
        }
        if (amount > reserveB) {
            IBonfirePair(pool).skim(to);
            return amount;
        }
        amount = BonfireSwapHelper.reflectionAdjustment(
            token,
            pool,
            amount,
            balance - amount
        );
        if (IBonfirePair(pool).token1() == token) {
            IBonfirePair(pool).swap(uint256(0), amount, to, new bytes(0));
        } else {
            IBonfirePair(pool).swap(amount, uint256(0), to, new bytes(0));
        }
        return amount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategicCalls {
    function token() external view returns (address token);

    function quote() external view returns (uint256 expectedGains);

    function execute(uint256 threshold, address to)
        external
        returns (uint256 gains);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfirePair {
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blickTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface ISwapFactoryRegistry {
    function getWETHEquivalent(address token, uint256 wethAmount)
        external
        view
        returns (uint256 tokenAmount);

    function getBiggestWETHPool(address token)
        external
        view
        returns (address pool);

    function getUniswapFactories()
        external
        view
        returns (address[] memory factories);

    function factoryDescription(address factory)
        external
        view
        returns (bytes32 description);

    function factoryFee(address factory) external view returns (uint256 feeP);

    function factoryRemainder(address factory)
        external
        view
        returns (uint256 remainderP);

    function factoryDenominator(address factory)
        external
        view
        returns (uint256 denominator);

    function enabled(address factory) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../swap/IBonfirePair.sol";
import "../swap/ISwapFactoryRegistry.sol";
import "../token/IBonfireTokenTracker.sol";

library BonfireSwapHelper {
    using ERC165Checker for address;

    address public constant tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);
    address public constant factoryRegistry =
        address(0xBF57511A971278FCb1f8D376D68078762Ae957C4);

    bytes4 public constant WRAPPER_INTERFACE_ID = 0x5d674982; //type(IBonfireTokenWrapper).interfaceId;
    bytes4 public constant PROXYTOKEN_INTERFACE_ID = 0xb4718ac4; //type(IBonfireTokenWrapper).interfaceId;

    function isWrapper(address pool) external view returns (bool) {
        return pool.supportsInterface(WRAPPER_INTERFACE_ID);
    }

    function isProxy(address token) external view returns (bool) {
        return token.supportsInterface(PROXYTOKEN_INTERFACE_ID);
    }

    function getAmountOutFromPool(
        uint256 amountIn,
        address tokenB,
        address pool
    )
        external
        view
        returns (
            uint256 amountOut,
            uint256 reserveB,
            uint256 projectedBalanceB
        )
    {
        uint256 remainderP;
        uint256 remainderQ;
        {
            address factory = IBonfirePair(pool).factory();
            remainderP = ISwapFactoryRegistry(factoryRegistry).factoryRemainder(
                    factory
                );
            remainderQ = ISwapFactoryRegistry(factoryRegistry)
                .factoryDenominator(factory);
        }
        uint256 reserveA;
        (reserveA, reserveB, ) = IBonfirePair(pool).getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token1() == tokenB
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        uint256 balanceB = IERC20(tokenB).balanceOf(pool);
        amountOut = getAmountOut(
            amountIn,
            reserveA,
            reserveB,
            remainderP,
            remainderQ
        );
        amountOut = balanceB > reserveB
            ? amountOut + (((balanceB - reserveB) * remainderP) / remainderQ)
            : amountOut;
        projectedBalanceB = balanceB - amountOut;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveA,
        uint256 reserveB,
        uint256 remainderP,
        uint256 remainderQ
    ) public pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * remainderP;
        uint256 numerator = amountInWithFee * reserveB;
        uint256 denominator = (reserveA * remainderQ) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function computeAdjustment(
        uint256 amount,
        uint256 projectedBalance,
        uint256 supply,
        uint256 reflectionP,
        uint256 reflectionQ,
        uint256 feeP,
        uint256 feeQ
    ) public pure returns (uint256 adjustedAmount) {
        adjustedAmount =
            amount +
            ((((((amount * reflectionP) / reflectionQ) * projectedBalance) /
                (supply - ((amount * reflectionP) / reflectionQ))) *
                (feeQ - feeP)) / feeQ);
    }

    function reflectionAdjustment(
        address token,
        address pool,
        uint256 amount,
        uint256 projectedBalance
    ) external view returns (uint256 adjustedAmount) {
        address factory = IBonfirePair(pool).factory();
        adjustedAmount = computeAdjustment(
            amount,
            projectedBalance,
            IBonfireTokenTracker(tracker).includedSupply(token),
            IBonfireTokenTracker(tracker).getReflectionTaxP(token),
            IBonfireTokenTracker(tracker).getTaxQ(token),
            ISwapFactoryRegistry(factoryRegistry).factoryFee(factory),
            ISwapFactoryRegistry(factoryRegistry).factoryDenominator(factory)
        );
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
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireTokenTracker {
    function getObserver(address token) external view returns (address o);

    function getTotalTaxP(address token) external view returns (uint256 p);

    function getReflectionTaxP(address token) external view returns (uint256 p);

    function getTaxQ(address token) external view returns (uint256 q);

    function reflectingSupply(address token, uint256 transferAmount)
        external
        view
        returns (uint256 amount);

    function includedSupply(address token)
        external
        view
        returns (uint256 amount);

    function excludedSupply(address token)
        external
        view
        returns (uint256 amount);

    function storeTokenReference(address token, uint256 chainid) external;

    function tokenid(address token, uint256 chainid)
        external
        pure
        returns (uint256);

    function getURI(uint256 _tokenid) external view returns (string memory);

    function getProperties(address token)
        external
        view
        returns (string memory properties);

    function registerToken(address proxy) external;

    function registeredTokens(uint256 index)
        external
        view
        returns (uint256 tokenid);

    function registeredProxyTokens(uint256 sourceTokenid, uint256 index)
        external
        view
        returns (address);
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