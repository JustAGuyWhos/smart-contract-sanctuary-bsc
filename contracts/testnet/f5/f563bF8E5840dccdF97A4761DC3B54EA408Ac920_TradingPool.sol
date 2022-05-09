// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IMinter {
    function transfer(address, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IOracle {
    function consult() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
    function onReward(uint256 pid, address user, address recipient, uint256 rewardAmount, uint256 newLpAmount) external;
    function pendingTokens(uint256 pid, address user, uint256 rewardAmount) external view returns (IERC20[] memory, uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface ISwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeToRate() external view returns (uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeToRate(uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface ISwapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function price(address token, uint256 baseDecimal) external view returns (uint256);

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IUserLevel {
    function getUserLevel(address _user) external view returns(uint);
    function configBaseLevel(uint _baseLevel) external;
    function getBonus(address _user, address _contract) external view returns(uint256, uint256);
    function configBonus(address _contract, uint[] memory _bonus) external;
    function updateUserExp(uint _exp, bytes memory _signature) external;
    function addValidator(address _validator) external;
    function removeValidator(address _validator) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
// a library for performing overflow-safe math, updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math)
library BoringMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {require((c = a - b) <= a, "BoringMath: Underflow");}
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {require(b == 0 || (c = a * b)/b == a, "BoringMath: Mul Overflow");}
    function to128(uint256 a) internal pure returns (uint128 c) {
        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }
    function to64(uint256 a) internal pure returns (uint64 c) {
        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }
    function to32(uint256 a) internal pure returns (uint32 c) {
        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}
    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a - b) <= a, "BoringMath: Underflow");}
}

library BoringMath64 {
    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}
    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {require((c = a - b) <= a, "BoringMath: Underflow");}
}

library BoringMath32 {
    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {require((c = a + b) >= b, "BoringMath: Add Overflow");}
    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {require((c = a - b) <= a, "BoringMath: Underflow");}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
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
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }

    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ISwapPair.sol";

library SwapLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "SwapLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "SwapLibrary: ZERamountInWithFeeO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"b4952bca370415fee7f85612fc5ea949ab7adc38363b2c3cbbaf1eb3665eef92" // init code hash
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = ISwapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "SwapLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "SwapLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "SwapLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "SwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "SwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "SwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "SwapLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "SwapLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../libraries/SignedSafeMath.sol";
import "../libraries/BoringMath.sol";
import "../libraries/SwapLibrary.sol";

import "../interfaces/IRewarder.sol";
import "../interfaces/IMinter.sol";
import "../interfaces/ISwapFactory.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IUserLevel.sol";

contract TradingPool is Ownable {
    using BoringMath for uint256;
    using SignedSafeMath for int256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 hashRate;
        int256 rewardDebt;
        uint256 lastRebased;
    }

    struct PoolInfo {
        uint256 accPANPerHashRate;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalHashRate;
        uint256 lastRebased;
    }

    IMinter public minter;
    ISwapFactory public factory;
    IUserLevel public userLevel;

    mapping (address => PoolInfo) public poolInfo;
    mapping (address => address) public oracles;

    mapping (address => mapping (address => UserInfo)) public userInfo;
    mapping (address => mapping (uint256 => uint256)) public accPANPerHashRateData;
    mapping (address => bool) public addedPairs;
    address[] public pairs;

    address public swapRouter;
    uint256 public totalAllocPoint;
    uint256 public rewardPerBlock;
    uint256 public rebaseDuration = 28800; // 1 days
    uint256 public rebaseSpeed = 9000;
    uint256 private constant MAX_REBASE = 20;
    uint256 private constant ONE_HUNDRED_PERCENT = 10000;

    uint256 private constant ACC_PAN_PRECISION = 1e12;
    uint256 private constant ORACLE_PRECISION = 1e6;

    event Deposit(address account, address indexed pair, uint256 amount);
    event Harvest(address indexed user, address indexed pair, uint256 amount);
    event LogUpdatePool(address indexed pair, uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event PoolAdded(address pair, uint256 allocPoint);
    event PoolUpdated(address pair, uint256 oldAllocPoint, uint256 newAllocPoint);
    event RewardPerBlockChanged(uint256 oldRewardPerBlock, uint256 newRewardPerBlock);
    event RebaseSpeedChanged(uint256 oldRebaseSpeed, uint256 newRebaseSpeed);
    event FactoryChanged(address indexed oldFactory, address indexed newFactory);
    event SwapRouterChanged(address indexed oldSwapRouter, address indexed newSwapFactory);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);
    event OracleChanged(address indexed token, address indexed oldOracle, address indexed newOracle);
    event UserLevelChanged(address indexed userLevel);

    constructor(address _minter, address _router, address _factory) public {
        minter = IMinter(_minter);
        factory = ISwapFactory(_factory);
        swapRouter = _router;
    }

    modifier onlySwapRouter() {
        require(swapRouter == msg.sender, "TradingPool: caller is not the swap router");
        _;
    }

    function getCurrentHashRate(uint256 _totalHashRate, uint256 _lastRebased) internal view returns (uint256) {
        uint256 res = _totalHashRate;
        if (block.number - _lastRebased >= rebaseDuration && _totalHashRate > 0) {
            uint256 _rebaseTime = block.number / rebaseDuration - _lastRebased / rebaseDuration;
            if (_rebaseTime > 20) {
                return 0;
            }
            for (uint256 i = 0; i < _rebaseTime; i++) {
                res = res.mul(rebaseSpeed) / ONE_HUNDRED_PERCENT;
            }
        }
        return res;
    }

    function getBonus(address _account, uint256 _value) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(_account, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    function totalHashRate(address _pair) external view returns(uint256 _totalHashRate){
        PoolInfo memory _pool = poolInfo[_pair];
        _totalHashRate = getCurrentHashRate(_pool.totalHashRate, _pool.lastRebased) * _pool.allocPoint / totalAllocPoint;
    }

    function userHashRate(address _pair, address _account) external view returns(uint256 _userHashRate) {
        UserInfo memory _user = userInfo[_pair][_account];
        PoolInfo memory _pool = poolInfo[_pair];
        _userHashRate = getCurrentHashRate(_user.hashRate, _user.lastRebased) * _pool.allocPoint / totalAllocPoint;
    }

    function add(address _pair, uint256 _allocPoint) public onlyOwner {
        require(addedPairs[address(_pair)] == false, "Pair already added");
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pairs.push(_pair);
        poolInfo[_pair] = PoolInfo({
            allocPoint: _allocPoint,
            lastRewardBlock: block.number,
            totalHashRate : 0,
            lastRebased : rebaseDuration * (block.number / rebaseDuration),
            accPANPerHashRate: 0
        });
        addedPairs[address(_pair)] = true;
        emit PoolAdded(_pair, _allocPoint);
    }

    function setOracle(address _token, address _oracle) public onlyOwner {
        address _oldOracle = oracles[_token];
        oracles[_token] = _oracle;
        emit OracleChanged(_token, _oldOracle, _oracle);
    }

    function set(address _pair, uint256 _allocPoint) public onlyOwner {
        updatePool(_pair);
        uint256 oldAllocPoint = poolInfo[_pair].allocPoint;
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pair].allocPoint).add(_allocPoint);
        poolInfo[_pair].allocPoint = _allocPoint;
        emit PoolUpdated(_pair, oldAllocPoint, _allocPoint);
    }

    function changeMinter(address _newMinter) external onlyOwner {
        address oldMinter = address(minter);
        minter = IMinter(_newMinter);
        emit MinterChanged(oldMinter, _newMinter);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock, address[] calldata _pairs) public onlyOwner {
        massUpdatePools(_pairs);
        uint256 oldRewardPerBlock = rewardPerBlock;
        rewardPerBlock = _rewardPerBlock;
        emit RewardPerBlockChanged(oldRewardPerBlock, _rewardPerBlock);
    }

    function rebase(address _pair) public {
        if (addedPairs[_pair] == true) {
            PoolInfo storage _pool = poolInfo[_pair];
            if (_pool.totalHashRate > 0) {
                uint256 _hashRate = _pool.totalHashRate;
                if (block.number - _pool.lastRebased >= rebaseDuration) {
                    for (uint256 i = _pool.lastRebased / rebaseDuration + 1; i <= block.number / rebaseDuration; i++) {
                        uint256 _delta = rebaseDuration;
                        if (rebaseDuration.mul(i - 1) < _pool.lastRewardBlock && _pool.lastRewardBlock < rebaseDuration.mul(i)) {
                            _delta = rebaseDuration.mul(i).sub(_pool.lastRewardBlock);
                        }
                        uint256 _reward = _delta.mul(rewardPerBlock).mul(_pool.allocPoint) / totalAllocPoint;
                        _pool.accPANPerHashRate = _pool.accPANPerHashRate.add(_reward.mul(ACC_PAN_PRECISION) / _hashRate);
                        accPANPerHashRateData[_pair][i] = _pool.accPANPerHashRate;
                        _hashRate = _hashRate.mul(rebaseSpeed) / ONE_HUNDRED_PERCENT;
                    }
                    _pool.totalHashRate = _hashRate;
                    _pool.lastRebased = rebaseDuration.mul(block.number / rebaseDuration);
                    _pool.lastRewardBlock = rebaseDuration.mul(block.number / rebaseDuration);
                }
            } else {
                _pool.lastRebased = rebaseDuration.mul(block.number / rebaseDuration);
            }
        }
    }

    function pendingReward(address _pair, address _account) external view returns (uint256 _pending) {
        PoolInfo memory _pool = poolInfo[_pair];
        UserInfo memory _user = userInfo[_pair][_account];
        uint256[] memory _accReward = new uint[](21);
        uint256 _totalHashRate = _pool.totalHashRate;
        uint256 _userHashRate = _user.hashRate;
        uint256 _startIndex = _pool.lastRebased / rebaseDuration + 1;
        _pending = 0;
        if (_userHashRate > 0) {
            if (block.number - _pool.lastRebased >= rebaseDuration) {
                uint256 _nRebase = block.number / rebaseDuration;
                for (uint256 i = _pool.lastRebased / rebaseDuration + 1; i <= _nRebase; i++) {
                    uint256 _delta = rebaseDuration;
                    if (rebaseDuration.mul(i - 1) < _pool.lastRewardBlock && _pool.lastRewardBlock < rebaseDuration.mul(i)) {
                        _delta = rebaseDuration.mul(i).sub(_pool.lastRewardBlock);
                    }
                    uint256 _reward = _delta.mul(rewardPerBlock).mul(_pool.allocPoint) / totalAllocPoint;
                    _pool.accPANPerHashRate = _pool.accPANPerHashRate.add(_reward.mul(ACC_PAN_PRECISION) / _totalHashRate);
                    _accReward[i - _startIndex] = _pool.accPANPerHashRate;
                    _totalHashRate = _totalHashRate.mul(rebaseSpeed) / ONE_HUNDRED_PERCENT;
                }
                _pool.totalHashRate = _totalHashRate;
                _pool.lastRebased = rebaseDuration.mul(block.number / rebaseDuration);
                _pool.lastRewardBlock = rebaseDuration.mul(block.number / rebaseDuration);
            }

            if (block.number > _pool.lastRewardBlock && _pool.totalHashRate > 0) {
                uint256 _blocks = block.number.sub(_pool.lastRewardBlock);
                uint256 _reward = _blocks.mul(rewardPerBlock).mul(_pool.allocPoint) / totalAllocPoint;
                _pool.accPANPerHashRate = _pool.accPANPerHashRate.add(_reward.mul(ACC_PAN_PRECISION) / _pool.totalHashRate);
            }

            if (_user.lastRebased > 0) {
                if (block.number - _user.lastRebased >= rebaseDuration) {
                    uint256 _nRebase = block.number / rebaseDuration;
                    if (_nRebase > MAX_REBASE + _user.lastRebased / rebaseDuration + 1) {
                        _nRebase = MAX_REBASE + _user.lastRebased / rebaseDuration + 1;
                    }
                    for (uint256 i = _user.lastRebased / rebaseDuration + 1; i <= _nRebase; i++) {
                        uint256 _decAmount = _userHashRate.mul(ONE_HUNDRED_PERCENT - rebaseSpeed) / ONE_HUNDRED_PERCENT;
                        uint256 _acc = accPANPerHashRateData[_pair][i];
                        if (i >= _startIndex) {
                            _acc = _accReward[i - _startIndex];
                        }
                        _user.rewardDebt = _user.rewardDebt.sub(int256(_decAmount.mul(_acc) / ACC_PAN_PRECISION));
                        _userHashRate = _userHashRate.mul(rebaseSpeed) / ONE_HUNDRED_PERCENT;
                    }
                    if (block.number / rebaseDuration > MAX_REBASE + _user.lastRebased / rebaseDuration + 1) {
                        uint256 _acc = accPANPerHashRateData[_pair][_nRebase + 1];
                        if (_nRebase + 1 >= _startIndex) {
                            _acc = _accReward[_nRebase + 1 - _startIndex];
                        }
                        _user.rewardDebt = _user.rewardDebt.sub(int256(_userHashRate.mul(_acc) / ACC_PAN_PRECISION));
                        _userHashRate = 0;
                    }
                }
            }
            _pending = int256(_userHashRate.mul(_pool.accPANPerHashRate) / ACC_PAN_PRECISION).sub(_user.rewardDebt).toUInt256();
        }
    }

    function massUpdatePools(address[] calldata _pairs) public {
        uint256 len = _pairs.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(_pairs[i]);
        }
    }

    function updatePool(address _pair) public {
        PoolInfo storage _pool = poolInfo[_pair];
        if (block.number > _pool.lastRewardBlock) {
            rebase(_pair);
            uint256 _supply = _pool.totalHashRate;
            if (_supply > 0) {
                uint256 _blocks = block.number.sub(_pool.lastRewardBlock);
                uint256 _reward = _blocks.mul(rewardPerBlock).mul(_pool.allocPoint) / totalAllocPoint;
                _pool.accPANPerHashRate = _pool.accPANPerHashRate.add(_reward.mul(ACC_PAN_PRECISION) / _supply);
            }
            _pool.lastRewardBlock = block.number;
            emit LogUpdatePool(_pair, _pool.lastRewardBlock, _supply, _pool.accPANPerHashRate);
        }
    }

    function estimationHashRate(uint256 _amountIn, address[] memory _path) external view returns(uint256[] memory) {
        uint256[] memory _hashRate = new uint256[](_path.length - 1);
        uint256[] memory _amounts = SwapLibrary.getAmountsOut(address(factory), _amountIn, _path);
        for (uint256 i = 0; i < _amounts.length - 1; i++) {
            address _pair = SwapLibrary.pairFor(address(factory), _path[i], _path[i + 1]);
            if (addedPairs[_pair]) {
                uint256 _amount = 0;
                if (oracles[_path[i + 1]] != address(0)) {
                    _amount = IOracle(oracles[_path[i + 1]]).consult().mul(_amounts[i + 1]);
                }
                _hashRate[i] = _amount.mul(poolInfo[_pair].allocPoint) / totalAllocPoint;
            }
        }
        return _hashRate;
    }

    function enter(address _account, address _input, address _output, uint256 _amount) public onlySwapRouter returns(bool) {
        require(_account != address(0), "TradingPool: swap account is zero address");
        require(_input != address(0), "TradingPool: swap input is zero address");
        require(_output != address(0), "TradingPool: swap output is zero address");
        address _pair = SwapLibrary.pairFor(address(factory), _input, _output);
        _amount += getBonus(_account, _amount);
        if (addedPairs[_pair]) {
            UserInfo storage _user = userInfo[_pair][_account];
            PoolInfo storage _pool = poolInfo[_pair];
            updatePool(_pair);
            if (oracles[_output] != address(0)) {
                _amount = IOracle(oracles[_output]).consult().mul(_amount) / ORACLE_PRECISION;
            } else {
                _amount = 0;
            }
            if (_amount > 0) {
                uint256 _userHashRate = _user.hashRate;
                if (_user.lastRebased > 0) {
                    if (block.number - _user.lastRebased >= rebaseDuration) {
                        uint256 _nRebase = block.number / rebaseDuration;
                        uint256 _t = MAX_REBASE + _user.lastRebased / rebaseDuration + 1;
                        if (_nRebase > _t) {
                            _nRebase = _t;
                        }
                        for (uint256 i = _user.lastRebased / rebaseDuration + 1; i <= _nRebase; i++) {
                            uint256 _decAmount = _userHashRate.mul(ONE_HUNDRED_PERCENT - rebaseSpeed) / ONE_HUNDRED_PERCENT;
                            _user.rewardDebt = _user.rewardDebt.sub(int256(_decAmount.mul(accPANPerHashRateData[_pair][i]) / ACC_PAN_PRECISION));
                            _userHashRate = _userHashRate.mul(rebaseSpeed) / ONE_HUNDRED_PERCENT;
                        }
                        if (block.number / rebaseDuration > _nRebase) {
                            _user.rewardDebt = _user.rewardDebt.sub(int256(_userHashRate.mul(accPANPerHashRateData[_pair][_nRebase + 1]) / ACC_PAN_PRECISION));
                            _userHashRate = 0;
                        }
                    }
                }

                _user.hashRate = _userHashRate.add(_amount);
                _user.lastRebased = rebaseDuration.mul(block.number / rebaseDuration);
                _user.rewardDebt = _user.rewardDebt.add(int256(_amount.mul(_pool.accPANPerHashRate) / ACC_PAN_PRECISION));
                _pool.totalHashRate = _pool.totalHashRate.add(_amount);
            }
            emit Deposit(_account, _pair, _amount.mul(_pool.allocPoint) / totalAllocPoint);
            return true;
        }
        return false;
    }

    function harvest(address _pair, address _to) public {
        if (addedPairs[_pair]) {
            updatePool(_pair);
            UserInfo storage _user = userInfo[_pair][msg.sender];
            PoolInfo storage _pool = poolInfo[_pair];

            uint256 _userHashRate = _user.hashRate;
            if (_userHashRate > 0) {
                if (block.number - _user.lastRebased >= rebaseDuration) {
                    uint256 _nRebase = block.number / rebaseDuration;
                    if (_nRebase > MAX_REBASE + _user.lastRebased / rebaseDuration + 1) {
                        _nRebase = MAX_REBASE + _user.lastRebased / rebaseDuration + 1;
                    }
                    for (uint256 i = _user.lastRebased / rebaseDuration + 1; i <= _nRebase; i++) {
                        uint256 _decAmount = _userHashRate.mul(ONE_HUNDRED_PERCENT - rebaseSpeed) / ONE_HUNDRED_PERCENT;
                        _user.rewardDebt = _user.rewardDebt.sub(int256(_decAmount.mul(accPANPerHashRateData[_pair][i]) / ACC_PAN_PRECISION));
                        _userHashRate = _userHashRate.mul(rebaseSpeed) / ONE_HUNDRED_PERCENT;
                    }
                    if (block.number / rebaseDuration > _nRebase) {
                        _user.rewardDebt = _user.rewardDebt.sub(int256(_userHashRate.mul(accPANPerHashRateData[_pair][_nRebase + 1]) / ACC_PAN_PRECISION));
                        _userHashRate = 0;
                    }
                }

                uint256 _pending = int256(_userHashRate.mul(_pool.accPANPerHashRate) / ACC_PAN_PRECISION).sub(_user.rewardDebt).toUInt256();

                _pool.totalHashRate = _pool.totalHashRate.sub(_userHashRate);
                _user.hashRate = 0;
                _user.rewardDebt = 0;
                _user.lastRebased = 0;

                // Interactions
                if (_pending != 0) {
                    minter.transfer(_to, _pending);
                }
                emit Harvest(msg.sender, _pair, _pending);
            }
        }
    }

    function harvestAll(address _to) public {
        for (uint256 i = 0; i < pairs.length; i++) {
            harvest(pairs[i], _to);
        }
    }

    function setSwapAddress(address _router, address _factory) external onlyOwner{
        address oldRouter = swapRouter;
        address oldFactory = address(factory);
        factory = ISwapFactory(_factory);
        swapRouter = _router;
        emit FactoryChanged(oldFactory, _factory);
        emit SwapRouterChanged(oldRouter, _router);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    function setRebaseSpeed(uint256 _newSpeed) external onlyOwner {
        uint256 oldRebaseSpeed = rebaseSpeed;
        rebaseSpeed = _newSpeed;
        emit RebaseSpeedChanged( oldRebaseSpeed,_newSpeed);
    }
}