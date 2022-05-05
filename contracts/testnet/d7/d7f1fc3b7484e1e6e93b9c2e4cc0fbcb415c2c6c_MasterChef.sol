/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

// MasterChef is the master of TALLY. He can make TALLY and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once TALLY is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.




library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}


interface IMigratorChef {
    function migrate(IERC20 token) external returns (IERC20);
}

// MasterChef is the master of TALLY. He can make TALLY and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once TALLY is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.



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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


/**
 **
 **    Total tax - 12.5% / 14.5%
 **
 **    5% - Reflections for Selling: to be distributed equally amongst all holders of Tally.
 **
 **    3% - Reflections for buying: to be distributed equally amongst all holders of Tally.
 **
 **    2% - Burned: sent directly to the burn address as Tally.
 **
 **    3.66% - Marketing: this will be sent straight to the marketing wallet as BNB.
 **
 **    0.34% - Charity: this will be sent to a charity wallet as Tally.
 **
 **    3% - Liquidity pool: this will be sent directly to the liquidity pool as Tally/BNB.
 **
 **    0.5% - BuyBack: this will be sent straight to the buyback wallet as BNB.
 **
 **    5% - Raffle: this will be sent straight to the marketing wallet as BNB.
 **
 **    1% - pool: this will be sent to another charity wallet as Tally.
 **/



interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

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

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
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
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
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
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
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
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
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
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

contract TALLYToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] public _excluded;

    address private _marketingWallet;
    address private _charityWallet;
    address private _buyBackWallet;

    address private _raffleWallet;
    address private _poolWallet;
    address private _poolCharityWallet;

    uint256 private constant MAX = ~uint256(0); //~uint256(0) = 2**256-1
    uint256 private _tTotal = 1000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    using EnumerableSet for EnumerableSet.AddressSet;
    //EnumerableSet.AddressSet private _minters;

    string private _name = "Tally Token";
    string private _symbol = "TALLY";
    uint8 private _decimals = 9;

    uint8 private constant TX_BUY = 0;
    uint8 private constant TX_SELL = 1;
    uint8 private constant TX_NORMAL = 2;

    uint8 private _txKind;

    uint256 public _taxFee = 500; // 500 -> 5%, 10000 -> 100%
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _taxSellFee = 500;
    uint256 private _previousSellTaxFee = _taxSellFee;

    uint256 public _taxBuyFee = 300;
    uint256 private _previousBuyTaxFee = _taxBuyFee;

    uint256 public _liquidityFee = 300;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _burnFee = 200;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _marketingFee = 366;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _charityFee = 34;
    uint256 private _previousCharityFee = _charityFee;

    uint256 public _buyBackFee = 50;
    uint256 private _previousBuyBackFee = _buyBackFee;

    uint256 public _raffleFee = 500;
    uint256 private _previousRaffleFee = _raffleFee;

    uint256 public _poolFee = 100;
    uint256 private _previousPoolFee = _poolFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxTxAmountPercent = 20; // 0.2%
    uint256 public _maxTxAmount;
    uint256 private numTokensSellToAddToLiquidity = 500000 * 10**6 * 10**9;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SendBNBToWallet(uint256 tokens, address account);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        // bsc mainnet
        //      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);

        // bsc testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x71E1330a2C8a209efb6e3c09a4a6966dcEc7af7f
            // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _marketingWallet = 0xec17A9fFb69B08E08Af8E67f486bdAE77a9Ad13b;
        _charityWallet = 0xdE325236C3dd71fdbf8304f6D74E9b8f4359F84c;
        _buyBackWallet = 0xaDB1336bca299Ebd2CB5A6942EcC683a085a175B;

        _raffleWallet = 0x1D48ab973612a23CeB33D8294c351bAbD6a04925;
        _poolWallet = 0x887e60316fC48534C1773081dec32c9542d14b16;
        _poolCharityWallet = 0x182205C74D92D345B789d978b71876dd058453FB;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromFee[_marketingWallet] = true;
        _isExcludedFromFee[_charityWallet] = true;
        _isExcludedFromFee[_buyBackWallet] = true;

        _isExcludedFromFee[_raffleWallet] = true;
        _isExcludedFromFee[_poolWallet] = true;
        _isExcludedFromFee[_poolCharityWallet] = true;

        //exclude marketing and charity wallet from reflection
        //      _isExcluded[_marketingWallet] = true;
        _isExcluded[_charityWallet] = true;

        _isExcluded[_raffleWallet] = true;
        _isExcluded[_poolWallet] = true;
        _isExcluded[_poolCharityWallet] = true;

        // set the max amount of tx
        _maxTxAmount = _tTotal.mul(_maxTxAmountPercent).div(10**4);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }


    function initializeMasterChefFund(uint _systemPercent, address _masterChef) external onlyOwner{

        if(_isExcludedFromFee[_masterChef]==false){

            _isExcludedFromFee[_masterChef] = true;
        }
        
        require(_systemPercent>0 && _systemPercent<=80,"invalid rate");
        require(_masterChef!=address(0));
        uint msFund= _tTotal.mul(_systemPercent).div(100);
        transfer(_masterChef,msFund);


    }




    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );

        uint256[12] memory values = _getValues(tAmount, TX_NORMAL);
        uint256 rAmount = values[0];

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee,
        uint8 txKind
    ) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");

        if (!deductTransferFee) {
            uint256[12] memory values = _getValues(tAmount, txKind);
            uint256 rAmount = values[0];
            return rAmount;
        } else {
            uint256[12] memory values = _getValues(tAmount, txKind);
            uint256 rTransferAmount = values[1];
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        uint8 txKind
    ) private {
        uint256[12] memory values = _getValues(tAmount, txKind);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(values[0]);
        _tOwned[recipient] = _tOwned[recipient].add(values[3]);
        _rOwned[recipient] = _rOwned[recipient].add(values[1]);

        _takeLiquidity(values[5]);
        _takeBurn(values[6]);
        _takeMarketing(values[7]);
        _takeCharity(values[8]);
        _takeBuyBack(values[9]);

        _takeRaffle(values[10]);
        _takePool(values[11]);

        _reflectFee(values[2], values[4]);
        emit Transfer(sender, recipient, values[3]);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function getTaxFee(uint8 txKind) public view returns (uint256) {
        if (txKind == TX_SELL) {
            return _taxSellFee;
        } else if (txKind == TX_BUY) {
            return _taxBuyFee;
        } else {
            return _taxFee;
        }
    }

    function setSellTaxFeePercent(uint256 sellTaxFee) external onlyOwner {
        _taxSellFee = sellTaxFee;
    }

    function setBuyTaxFeePercent(uint256 buyTaxFee) external onlyOwner {
        _taxBuyFee = buyTaxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        _liquidityFee = liquidityFee;
    }

    function setBurnFeePercent(uint256 burnFee) external onlyOwner {
        _burnFee = burnFee;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner {
        _marketingFee = marketingFee;
    }

    function setCharityFeePercent(uint256 charityFee) external onlyOwner {
        _charityFee = charityFee;
    }

    function setBuyBackFeePercent(uint256 buyBackFee) external onlyOwner {
        _buyBackFee = buyBackFee;
    }

    function setRaffleFeePercent(uint256 raffleFee) external onlyOwner {
        _raffleFee = raffleFee;
    }

    function setPoolFeePercent(uint256 poolFee) external onlyOwner {
        _poolFee = poolFee;
    }

    function setMarketingWallet(address account) external onlyOwner {
        _marketingWallet = account;
    }

    function setCharityWallet(address account) external onlyOwner {
        _charityWallet = account;
    }

    function setBuyBackWallet(address account) external onlyOwner {
        _buyBackWallet = account;
    }

    function setRaffleWallet(address account) external onlyOwner {
        _raffleWallet = account;
    }

    function setPoolWallet(address account) external onlyOwner {
        _poolWallet = account;
    }

    function setPoolCharityWallet(address account) external onlyOwner {
        _poolCharityWallet = account;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxAmountPercent = maxTxPercent;
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**4);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, uint8 txKind)
        private
        view
        returns (uint256[12] memory values)
    {
        uint256[9] memory tValues = _getTValues(tAmount, txKind);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tValues,
            _getRate()
        );
        return [
            rAmount,
            rTransferAmount,
            rFee,
            tValues[0],
            tValues[1],
            tValues[2],
            tValues[3],
            tValues[4],
            tValues[5],
            tValues[6],
            tValues[7],
            tValues[8]
        ];
    }

    function _getTValues(uint256 tAmount, uint8 txKind)
        private
        view
        returns (uint256[9] memory tValues)
    {
        uint256 tFee = calculateTaxFee(tAmount, txKind);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);

        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tCharity = calculateCharityFee(tAmount);
        uint256 tBuyBack = calculateBuyBackFee(tAmount);

        uint256 tRaffle = calculateRaffleFee(tAmount);
        uint256 tPool = calculatePoolFee(tAmount);

        uint256 tempTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        uint256 tTransferAmount = tempTransferAmount
            .sub(tBurn)
            .sub(tMarketing)
            .sub(tCharity)
            .sub(tBuyBack);
        tTransferAmount = tTransferAmount.sub(tRaffle).sub(tPool);

        return [
            tTransferAmount,
            tFee,
            tLiquidity,
            tBurn,
            tMarketing,
            tCharity,
            tBuyBack,
            tRaffle,
            tPool
        ];
    }

    function _getRValues(
        uint256 tAmount,
        uint256[9] memory tValues,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tValues[1].mul(currentRate);
        uint256 rLiquidity = tValues[2].mul(currentRate);
        uint256 rBurn = tValues[3].mul(currentRate);
        uint256 rMarketing = tValues[4].mul(currentRate);
        uint256 rCharity = tValues[5].mul(currentRate);
        uint256 rBuyBack = tValues[6].mul(currentRate);
        uint256 rRaffle = tValues[7].mul(currentRate);
        uint256 rPool = tValues[8].mul(currentRate);

        uint256 tempTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        uint256 rTransferAmount = tempTransferAmount
            .sub(rBurn)
            .sub(rMarketing)
            .sub(rCharity)
            .sub(rBuyBack);
        rTransferAmount = rTransferAmount.sub(rRaffle).sub(rPool);

        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeBurn(uint256 tBurn) private {
        uint256 currentRate = _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[address(0)] = _rOwned[address(0)].add(rBurn);

        if (_isExcluded[address(0)])
            _tOwned[address(0)] = _tOwned[address(0)].add(tBurn);
    }

    function _takeMarketing(uint256 tMarketing) private {
        if (tMarketing == 0) return;

        swapAndSendToWallet(tMarketing, _marketingWallet);
    }

    function _takeCharity(uint256 tCharity) private {
        if (tCharity == 0) return;
        _transfer(_msgSender(), _charityWallet, tCharity);
    }

    function _takeBuyBack(uint256 tBuyBack) private {
        if (tBuyBack == 0) return;

        swapAndSendToWallet(tBuyBack, _buyBackWallet);
    }

    function _takeRaffle(uint256 tRaffle) private {
        if (tRaffle == 0) return;
        _transfer(_msgSender(), _charityWallet, tRaffle);
    }

    function _takePool(uint256 tPool) private {
        if (tPool == 0) return;

        _transfer(_msgSender(), _poolCharityWallet, tPool);
    }

    function calculateTaxFee(uint256 _amount, uint8 txKind)
        private
        view
        returns (uint256)
    {
        uint256 taxFee = getTaxFee(txKind);
        return _amount.mul(taxFee).div(10**4);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_liquidityFee).div(10**4);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(10**4);
    }

    function calculateMarketingFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_marketingFee).div(10**4);
    }

    function calculateCharityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_charityFee).div(10**4);
    }

    function calculateBuyBackFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_buyBackFee).div(10**4);
    }

    function calculateRaffleFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_raffleFee).div(10**4);
    }

    function calculatePoolFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_poolFee).div(10**4);
    }

    function removeMainFee() private {
        if (
            _taxFee == 0 &&
            _taxSellFee == 0 &&
            _taxBuyFee == 0 &&
            _liquidityFee == 0
        ) return;

        _previousTaxFee = _taxFee;
        _previousSellTaxFee = _taxSellFee;
        _previousBuyTaxFee = _taxBuyFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _taxSellFee = 0;
        _taxBuyFee = 0;
        _liquidityFee = 0;
    }

    function removeDirectWalletFee() private {
        if (
            _burnFee == 0 &&
            _marketingFee == 0 &&
            _charityFee == 0 &&
            _buyBackFee == 0
        ) return;

        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;
        _previousCharityFee = _charityFee;
        _previousBuyBackFee = _buyBackFee;

        _burnFee = 0;
        _marketingFee = 0;
        _charityFee = 0;
        _buyBackFee = 0;
    }

    function removeRaffleFee() private {
        if (_raffleFee == 0) return;
        _previousRaffleFee = _raffleFee;

        _raffleFee = 0;
    }

    function removePoolFee() private {
        if (_poolFee == 0) return;
        _previousPoolFee = _poolFee;

        _poolFee = 0;
    }

    function restoreMainFee() private {
        _taxFee = _previousTaxFee;
        _taxSellFee = _previousSellTaxFee;
        _taxBuyFee = _previousBuyTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function restoreDirectWalletFee() private {
        _burnFee = _previousBurnFee;
        _marketingFee = _previousMarketingFee;
        _charityFee = _previousCharityFee;
        _buyBackFee = _previousBuyBackFee;
    }

    function restoreRaffleFee() private {
        _raffleFee = _previousRaffleFee;
    }

    function restorePoolFee() private {
        _poolFee = _previousPoolFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAndSendToWallet(uint256 tokens, address account) private {
        uint256 initialBNBBalance = address(this).balance;
        swapTokensForEth(tokens);

        uint256 dividends = (address(this).balance).sub(initialBNBBalance);

        (bool success, ) = address(account).call{value: dividends}("");

        if (success) {
            emit SendBNBToWallet(tokens, account);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        bool buySellFee = false;
        bool businessRaffleFee = false;
        bool businessPoolFee = false;

        if (sender == uniswapV2Pair || recipient == uniswapV2Pair) {
            _txKind = recipient == uniswapV2Pair ? TX_SELL : TX_BUY;
        } else {
            _txKind = TX_NORMAL;
        }

        if (!takeFee) {
            removeMainFee();

            // When transfer from and to RaffleWallet or PoolWallet, takeFee is always false
            // because these two wallets are NO FEE wallets.
            if (_txKind == TX_NORMAL) {
                if (recipient == _raffleWallet) {
                    businessRaffleFee = true;
                }

                if (recipient == _poolWallet || sender == _poolWallet) {
                    businessPoolFee = true;
                }
            }
        } else {
            if (_txKind == TX_SELL || _txKind == TX_BUY) {
                buySellFee = true;
            }
        }

        if (!buySellFee) removeDirectWalletFee();

        if (!businessRaffleFee) removeRaffleFee();

        if (!businessPoolFee) removePoolFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, _txKind);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, _txKind);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, _txKind);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, _txKind);
        } else {
            _transferStandard(sender, recipient, amount, _txKind);
        }

        if (!takeFee) restoreMainFee();

        if (!buySellFee) restoreDirectWalletFee();

        if (!businessRaffleFee) restoreRaffleFee();

        if (!businessPoolFee) restorePoolFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount,
        uint8 txKind
    ) private {
        uint256[12] memory values = _getValues(tAmount, txKind);

        _rOwned[sender] = _rOwned[sender].sub(values[0]);
        _rOwned[recipient] = _rOwned[recipient].add(values[1]);

        _takeLiquidity(values[5]);
        _takeBurn(values[6]);
        _takeMarketing(values[7]);
        _takeCharity(values[8]);
        _takeBuyBack(values[9]);

        _takeRaffle(values[10]);
        _takePool(values[11]);

        _reflectFee(values[2], values[4]);

        emit Transfer(sender, recipient, values[3]);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        uint8 txKind
    ) private {
        uint256[12] memory values = _getValues(tAmount, txKind);

        _rOwned[sender] = _rOwned[sender].sub(values[0]);
        _tOwned[recipient] = _tOwned[recipient].add(values[3]);
        _rOwned[recipient] = _rOwned[recipient].add(values[1]);

        _takeLiquidity(values[5]);
        _takeBurn(values[6]);
        _takeMarketing(values[7]);
        _takeCharity(values[8]);
        _takeBuyBack(values[9]);

        _takeRaffle(values[10]);
        _takePool(values[11]);

        _reflectFee(values[2], values[4]);
        emit Transfer(sender, recipient, values[3]);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount,
        uint8 txKind
    ) private {
        uint256[12] memory values = _getValues(tAmount, txKind);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(values[0]);
        _rOwned[recipient] = _rOwned[recipient].add(values[1]);

        _takeLiquidity(values[5]);
        _takeBurn(values[6]);
        _takeMarketing(values[7]);
        _takeCharity(values[8]);
        _takeBuyBack(values[9]);

        _takeRaffle(values[10]);
        _takePool(values[11]);

        _reflectFee(values[2], values[4]);
        emit Transfer(sender, recipient, values[3]);
    }
}



contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of TALLYs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTALLYPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTALLYPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. TALLYs to distribute per block.
        uint256 lastRewardBlock; // Last block number that TALLYs distribution occurs.
        uint256 accTALLYPerShare; // Accumulated TALLYs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
        uint16 withdrawFeeBP;      // Deposit fee in basis points
    }
    // The TALLY TOKEN!
    TALLYToken public TALLY;
    //Pools, Farms, Dev, Refs percent decimals
    uint256 public percentDec = 1000000;
    //Pools and Farms percent from token per block 40%
    uint256 public stakingPercent = 400000;

    // Marketing Reserve address 0xFD69EB55Fed425b1694168206a41C332082f6bf1
    address public reservAddr = 0x887e60316fC48534C1773081dec32c9542d14b16;
    // Platform Maintenance & Security address 0x5cE77628d3E1c66c82f801c9dE0315E6d7F43D27
    address public platformMaintenanceSecurityAddr =
        0x182205C74D92D345B789d978b71876dd058453FB;
    // BUY BACK RESERVES address 0xF14F21f409859fcEa0193981016070FfEEBD4f7C
    address public buyBackReservesAddr =
        0x466AF25e6FC077D4ac09d879D2B0f2894d1E763f;
    // Operation Manager address 0x9eCa53cf9F2F540daADf9B1B890455bdc43f3804
    address public operationManagerAddr =
        0xf0723376038B5aE42909B2d70c876b70EC5CA0A4;
    // Marketing Reserve percent 0.15%
    uint256 public reservPercent = 150000;
    // Platform Maintenance & Security percent 0.008%
    uint256 public maintenanceSecurityPercent = 8000;
    // BUY BACK RESERVES percent 0.1%
    uint256 public buyBackReservesPercent = 100000;
    // Operation Manager percent 0.142%
    uint256 public operationManagerPercent = 142000;

    // Last block then develeper withdraw dev and ref fee
    uint256 public lastBlockDevWithdraw;
    // TALLY tokens created per block.
    uint256 public TALLYPerBlock = 30000000000;
    // Bonus muliplier for early TALLY makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when TALLY mining starts.
    uint256 public startBlock = 8626338;
    // Deposited amount TALLY in MasterChef
    uint256 public depositedTALLY;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(TALLYToken _TALLY) {
        TALLY = _TALLY;

        // staking pool
        poolInfo.push(
            PoolInfo({
                lpToken: _TALLY,
                allocPoint: 1000,
                lastRewardBlock: startBlock,
                accTALLYPerShare: 0,
                depositFeeBP:0, // default fee 0
                withdrawFeeBP:0 // default fee 0
            })
        );

        totalAllocPoint = 1000;
        lastBlockDevWithdraw= block.number;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function withdrawDevAndRefFee() public {
        require(lastBlockDevWithdraw < block.number, "wait for new block");
        uint256 multiplier = getMultiplier(lastBlockDevWithdraw, block.number);
        uint256 TALLYReward = multiplier.mul(TALLYPerBlock);
        TALLY.transfer(reservAddr, TALLYReward.mul(reservPercent).div(percentDec));
        TALLY.transfer(
            platformMaintenanceSecurityAddr,
            TALLYReward.mul(buyBackReservesPercent).div(percentDec)
        );
        TALLY.transfer(
            buyBackReservesAddr,
            TALLYReward.mul(maintenanceSecurityPercent).div(percentDec)
        );
        TALLY.transfer(
            operationManagerAddr,
            TALLYReward.mul(operationManagerPercent).div(percentDec)
        );
        lastBlockDevWithdraw = block.number;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        uint16 _depositFeeBP,
        uint16 _withdrawFeeBP
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTALLYPerShare: 0,
                depositFeeBP:_depositFeeBP,
                withdrawFeeBP:_withdrawFeeBP
            })
        );
    }

    // Update the given pool's TALLY allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint16 _depositFeeBP,
        uint16 _withdrawFeeBP
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].withdrawFeeBP = _withdrawFeeBP;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending TALLYs on frontend.
    function pendingTALLY(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTALLYPerShare = pool.accTALLYPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (_pid == 0) {
            lpSupply = depositedTALLY;
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 TALLYReward = multiplier
                .mul(TALLYPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint)
                .mul(stakingPercent)
                .div(percentDec);
            accTALLYPerShare = accTALLYPerShare.add(
                TALLYReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accTALLYPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (_pid == 0) {
            lpSupply = depositedTALLY;
        }
        if (lpSupply <= 0) {
            pool.lastRewardBlock = block.number;
            return;
        }



        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 TALLYReward = multiplier
            .mul(TALLYPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint)
            .mul(stakingPercent)
            .div(percentDec);
        //TALLY.mint(address(this), TALLYReward);
        pool.accTALLYPerShare = pool.accTALLYPerShare.add(
            TALLYReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for TALLY allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "deposit TALLY by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTALLYPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            safeTALLYTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        if (pool.depositFeeBP > 0) {
            uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
            pool.lpToken.safeTransfer(operationManagerAddr, depositFee);
            user.amount = user.amount.add(_amount).sub(depositFee);
        } else {

            user.amount = user.amount.add(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "withdraw TALLY by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTALLYPerShare).div(1e12).sub(
            user.rewardDebt
        );
        safeTALLYTransfer(msg.sender, pending);

        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        if (pool.withdrawFeeBP>0){

            uint256 withdrawFee = _amount.mul(pool.withdrawFeeBP).div(10000);
            pool.lpToken.safeTransfer(operationManagerAddr, withdrawFee);
            uint256 transAmount = _amount.sub(withdrawFee);

            pool.lpToken.safeTransfer(address(msg.sender), transAmount);
        }else{

                 pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake TALLY tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTALLYPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                safeTALLYTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            depositedTALLY = depositedTALLY.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw TALLY tokens from STAKING.
    function leaveStaking(uint256 _amount ) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
            uint pending = user.amount.mul(pool.accTALLYPerShare).div(1e12).sub(
            user.rewardDebt
        );

        if (pending > 0) {
            safeTALLYTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            depositedTALLY = depositedTALLY.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe TALLY transfer function, just in case if rounding error causes pool to not have enough TALLYs.
    function safeTALLYTransfer(address _to, uint256 _amount) internal {
        uint256 TALLYBal = TALLY.balanceOf(address(this));
        if (_amount > TALLYBal) {
            TALLY.transfer(_to, TALLYBal);
        } else {
            TALLY.transfer(_to, _amount);
        }
    }

    function setReservAddress(address _reservAddr) public onlyOwner {
        reservAddr = _reservAddr;
    }

    function setBuyBackReservesAddress(address _buyBackReservesAddr)
        public
        onlyOwner
    {
        buyBackReservesAddr = _buyBackReservesAddr;
    }

    function setPlatformMaintenanceSecurityAddress(
        address _platformMaintenanceSecurityAddr
    ) public onlyOwner {
        platformMaintenanceSecurityAddr = _platformMaintenanceSecurityAddr;
    }

    function setOperationManagerAddress(address _operationManagerAddr)
        public
        onlyOwner
    {
        operationManagerAddr = _operationManagerAddr;
    }

    function updateTALLYPerBlock(uint256 newAmount) public onlyOwner {
        require(newAmount <= 30 * 1e9, "Max per block 30 TALLY");
        require(newAmount >= 1 * 1e9, "Min per block 1 TALLY");
        TALLYPerBlock = newAmount;
    }

    function setStakingPercent(uint256 _stakingPercent) public onlyOwner {
        stakingPercent = _stakingPercent;
    }

    function setReservPercent(uint256 _reservPercent) public onlyOwner {
        reservPercent = _reservPercent;
    }

    function setMaintenanceSecurityPercent(uint256 _maintenanceSecurityPercent)
        public
        onlyOwner
    {
        maintenanceSecurityPercent = _maintenanceSecurityPercent;
    }

    function setBuyBackReservesPercent(uint256 _buyBackReservesPercent)
        public
        onlyOwner
    {
        buyBackReservesPercent = _buyBackReservesPercent;
    }

    function setOperationManagerPercent(uint256 _operationManagerPercent)
        public
        onlyOwner
    {
        operationManagerPercent = _operationManagerPercent;
    }
}