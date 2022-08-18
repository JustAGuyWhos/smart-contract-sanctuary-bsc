/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.0;

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
                /// @solidity memory-safe-assembly
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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/SmartBank.sol

//SPDX-License-Identifier: MIT







pragma solidity 0.8.16;

///@title Compound Ether - CToken which wraps Ether
///@notice interface for SmartBank contract to interact with Compound
///@dev refer to https://github.com/compound-finance/compound-protocol/blob/master/contracts/CEther.sol for further details
interface cETH {
    
    // define functions of COMPOUND to use
    function mint() external payable; // to deposit to compound
    function mint(uint mintAmount) external payable returns (uint);
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    
    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}

///@title Uniswap V2 Router01
///@notice Uniswap interface to enable SnartBank contract to interact and swap tokens
///@dev refer to https://github.com/Uniswap/v2-periphery/blob/master/contracts/UniswapV2Router01.sol for further details

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
}



///@title SmartBank
///@notice the contract allows users to deposit and withdraw in ETH and ERC20 tokens and earn interests
///@author Francis_ldn
///@dev inherits ReentrancyGuard which is deployed in withdraw() and withdrawInERC20() functions to safeguard from reentrancy
///@dev uses SafeMath library to prevent overflow operations
///@dev uses Address library to check if an address is a valid contract address (for ERC20 token)
contract SmartBank is ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;

    IUniswapV2Router02 uniswap;
    cETH ceth;
    address weth;
    
    constructor(address _uniswap, address _comp, address _weth) {
        uniswap = IUniswapV2Router02(_uniswap);
        ceth = cETH(_comp);
        weth = _weth;
    }

    uint256 private totalContractBalance;

    mapping(address => uint) balances;
    
    event depositETH(address indexed _from, uint256 amountDeposited);
    event depositERC20Token(address indexed depositor, string symbol, uint256 amountDeposited);
    event withdrawETH(address indexed depositor, uint256 amountWithdrawn);
    event withdrawERC20Token(address indexed _to, string symbol, uint256 amountWithdrawn);

    ///@notice for user to deposit ETH to this contract and earn interest from Compound
    ///@return true upon successful deposit of ETH
    ///@dev due to the gas fee incurred, it is possible that the value of deposit could be slightly less than the amount deposited initially
    function addBalance() external payable returns (bool){
        // to keep track of user's ETH balance
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        // to keep track of the contract's ETH balance
        totalContractBalance = totalContractBalance.add(msg.value);
        
        //send ethers to mint()
        ceth.mint{value: msg.value}();
        emit depositETH(msg.sender, msg.value);
        return true;
    }
    
    ///@notice to get the total amount deposited (in Wei) to this contract by various users
    ///@notice ERC20 tokens deposited to this contract will be converted to ETH and added to the contract balance
    function getContractBalance() public view returns(uint256){
        return totalContractBalance;
    }
    
    ///@notice to get the total amount deposited to Compound from this contract converted to wei
    ///@return total amount of CEth held by this account converted to Wei - for internal use only
    function getCompoundBalance() internal view returns(uint256) {
        return (ceth.balanceOf(address(this)).mul(ceth.exchangeRateStored())).div(1e18);
    }
    
    ///@notice to get total amount of CEth held by this contract
    function getTotalCethAmount() internal view returns(uint256){
        return ceth.balanceOf(address(this));
    }
    
    /// @notice to calculate the conversion rate between the amount deposited to this contract and amount available at Compound
    /// @dev decimal handling - 1e18 has to be placed in the numerator before dividing by getContractBalance
    function conversionRateCompToContract() internal view returns (uint256)  {
        return (getCompoundBalance().mul(1e18)).div(getContractBalance());
    }
    
    ///@notice to calculate the conversion rate between total ETH and CETH by dividing total contract balance (in Wei) by the total CETH amount
    function conversionRateContractToCeth() internal view returns (uint256) {
        return getContractBalance().div(getTotalCethAmount());
    }
    
    
    ///@notice allows user to deposit ERC20 tokens to this contract
    ///@dev This contract consists of 3 internal functions - addTokens, swapExactTokensforETH and depositToCompound
    ///@dev Upon receiving the ERC20 token, the function will swap the token into ETH on Uniswap
    ///@dev Then, the ETH will be deposited to Compound to earn interest
    ///@dev Due to the conversion from ERC20 token to ETH, it is possible that the value of amount in ETH could initially be slightly less than the original ERC20 token amount deposited
    function addBalanceERC20(address erc20TokenAddress, uint256 amountToDeposit) external payable returns (bool){
        require(erc20TokenAddress.isContract() && erc20TokenAddress != address(0),"not a valid contract address");
        require(ERC20(erc20TokenAddress).balanceOf(msg.sender)>= amountToDeposit, "insufficient amount");
        require(ERC20(erc20TokenAddress).allowance(msg.sender,address(this))>= amountToDeposit, "insufficient allowance");
        require(amountToDeposit > 0, 'Amount must be greater than zero');
        
        // get approval from the token contract first before depositing tokens, otherwise this function will revert due to insufficient allowance
        addTokens(erc20TokenAddress, amountToDeposit);
        
        // swap ERC20 token to ETH via Uniswap
        uint256 depositTokens = amountToDeposit;
        uint256 depositAmountInETH = swapExactTokensforETH(erc20TokenAddress, depositTokens);
        require(depositAmountInETH > 0, "failed to swap tokens");
        
        // keep track of the user balance and contract balance
        balances[msg.sender] = balances[msg.sender].add(depositAmountInETH);
        totalContractBalance = totalContractBalance.add(depositAmountInETH);
        
        // deposit ETH amount to Compound
        depositToCompound(depositAmountInETH);

        emit depositERC20Token(msg.sender, ERC20(erc20TokenAddress).symbol(), amountToDeposit);
        return true;
    }
    
    ///@notice this function deposits ETH available in this contract to Compound and then receive CETH in return
    function depositToCompound(uint256 amountInETH) private {
        uint256 cethBalanceBefore = ceth.balanceOf(address(this));
        ceth.mint{value: amountInETH}();
        uint256 cethBalanceAfter = ceth.balanceOf(address(this));
        uint256 depositAmountInCeth = cethBalanceAfter.sub(cethBalanceBefore); 
    }

    
    ///@notice this function enables user to deposit erc20 tokens to this contract after user has approved the amount
    function addTokens (address erc20TokenAddress, uint256 amountToDeposit) private {
        // user will have to approve the ERC20 token amount first outside of the smart contract
        uint256 depositTokens = amountToDeposit;
        // to check the return value of ERC20 transferFrom function before proceeding
        bool success = ERC20(erc20TokenAddress).transferFrom(msg.sender, address(this), depositTokens);
        require(success, "ERC20 token deposit fails");
    }
    
    ///@notice to check the amount of ERC20 token that has been approved by user
    ///@dev once amount is approved, user can start depositing ERC20 token
    function getAllowanceERC20(address erc20TokenAddress) external view returns (uint256) {
        return ERC20(erc20TokenAddress).allowance(msg.sender, address(this));
    }
    
    ///@notice this function enables the contract to convert ERC20 tokens into ETH via Uniswap router
    function swapExactTokensforETH(address erc20TokenAddress, uint swapAmount) internal returns (uint256) {
        require(erc20TokenAddress.isContract() && erc20TokenAddress != address(0), "not a valid contract address");
        require(ERC20(erc20TokenAddress).balanceOf(address(this))>0, "insufficient tokens to swap");
        
        ERC20(erc20TokenAddress).approve(address(uniswap),swapAmount);
        uint256 allowedAmount = ERC20(erc20TokenAddress).allowance(address(this), address(uniswap));
        
        // generate the uniswap pair path of token -> WETH
        // WETH address is set in the constructor - varies depending on the network
        address[] memory path = new address[](2);
        path[0] = erc20TokenAddress;
        path[1] = weth;
        
        // get the amount of ETH held in this contract before swap
        uint256 ETHBalanceBeforeSwap = address(this).balance;
        // make the swap
        
        // catch error if unable to swap (due to non-existence of liquidity pool)
         try  uniswap.swapExactTokensForETH(
                allowedAmount,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            ) 
            { 
                // get the amount of ETH held in this contract after swap
                uint256 ETHBalanceAfterSwap = address(this).balance;

                // calculate the difference to get the amount of ETH deposited
                uint256 depositAmountInETH = ETHBalanceAfterSwap.sub(ETHBalanceBeforeSwap);
                
                return depositAmountInETH;
            }
            catch {
                return 0;
            }
        
    }
    
    ///@notice this function enables the contract to convert ETH into an ERC20 token through uniswap router
    function swapExactETHForTokens(address erc20TokenAddress, uint256 swapAmountInWei) internal returns (uint256) {
        require(erc20TokenAddress.isContract() && erc20TokenAddress != address(0), "not a valid contract address");
        
        
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = erc20TokenAddress;
        
        // get the ERC20 token balance held by this contract before swap
        uint256 erc20TokenBeforeSwap = ERC20(erc20TokenAddress).balanceOf(address(this));
        
        // catch error if unable to swap (due to non-existence of liquidity pool)
        try uniswap.swapExactETHForTokens{value: swapAmountInWei}(
            0, // accept any amount of token
            path,
            address(this),
            block.timestamp
        ) {
        
        // get the balance of ERC20 token balance held by this contract after swap
        uint256 erc20TokenAfterSwap = ERC20(erc20TokenAddress).balanceOf(address(this));

        // calculate the difference to derive the amount of tokens deposited
        uint256 erc20TokenAmount = erc20TokenAfterSwap.sub(erc20TokenBeforeSwap);
        return erc20TokenAmount;
        
        } catch {
            return 0;
        }
    }
    

    ///@notice for user to check their ETH balance (in Wei)
    ///@dev the amount of (user deposit + interest earned) is allocated to a user proportionally to the user's initial deposit
    ///@dev if the totalContractBalance is 0 or user balance is 0, the function will return 0
    function getBalanceInWei(address userAddress) public view returns (uint256) {
        if(totalContractBalance == 0 || balances[userAddress]==0) {
            return 0;
        } else {
        return (getCethBalanceInWei().mul(balances[userAddress])).div(totalContractBalance);
        }
    }
    
    ///@notice to get all the CETH balance held by this contract and convert into ETH
    function getCethBalanceInWei () internal view returns (uint256) {
        return (ceth.balanceOf(address(this)).mul(ceth.exchangeRateStored())).div(1e18);
    }

    ///@notice for user to withdraw their account balance in ETH
    function withdraw(uint256 _withdrawAmountInWei) external payable nonReentrant returns(bool) {
        // check that the withdraw amount is less than the user balance including interest earned
        require(_withdrawAmountInWei <= getBalanceInWei(msg.sender), "overdrawn");
        
        // convert withdrawal amount(Wei) to Ceth so that this contract can redeem from Compound
        uint256 amountToRedeemInCeth = ((_withdrawAmountInWei.mul(1e18)).div(conversionRateCompToContract())).div(conversionRateContractToCeth());

        // record the contract ETH balance before redeem
        uint256 contractBalanceBeforeRedeem = address(this).balance;
        
        ceth.redeem(amountToRedeemInCeth);
        
        // record the contract ETH balance after redeem
        uint256 contractBalanceAfterRedeem = address(this).balance;
        
        // calculate the total amount redeemed in ETH terms (Wei) then check if transaction is successful (>0 means tx successful)
        uint256 redeemed = contractBalanceAfterRedeem.sub(contractBalanceBeforeRedeem);
        require(redeemed>0, "ceth not redeemed");
        // if redeemed amount is greater than the user's initial deposit (due to interest earned), then user balance = 0 (assume full amount withdrawn)
        if(redeemed> balances[msg.sender]) {
            balances[msg.sender] =0;
        } else {
            balances[msg.sender]= balances[msg.sender].sub(redeemed);
        }
        
        // if redeemed amount is greater than total contract balance (due to interest earned), then contract balance = 0 (assume full amount withdrawn)
        if(redeemed > totalContractBalance) {
            totalContractBalance =0;
        } else {
            totalContractBalance = totalContractBalance.sub(redeemed);
        }

        // check for return value from a low-level call        
        (bool sent,) = payable(msg.sender).call{value: redeemed}("");
        require(sent, "failed to send ether");

        emit withdrawETH(msg.sender, redeemed);
        return true;
    }
    
    ///@notice allows user to withdraw balance in a chosen ERC20 token
    ///@dev the function checks to ensure that ERC20 token address is a contract address and it isn't 0x0
    function withdrawInERC20 (uint _withdrawAmountInWei, address erc20TokenAddress) external payable nonReentrant returns (bool){
        require(erc20TokenAddress.isContract() && erc20TokenAddress != address(0), "not a valid contract address");
        require(_withdrawAmountInWei <= getBalanceInWei(msg.sender), "overdrawn");
        
        // convert amount to Ceth so that the contract can redeem from Compound
        uint256 amountToRedeemInCeth = ((_withdrawAmountInWei.mul(1e18)).div(conversionRateCompToContract())).div(conversionRateContractToCeth());

        // record the contract balance of ERC20 token amount before redeeming ETH from Compound
        uint256 contractBalanceBeforeRedeem = address(this).balance;
        
        ceth.redeem(amountToRedeemInCeth);
        
        // record the amount after redeem
        uint256 contractBalanceAfterRedeem = address(this).balance;
        
        // get amount of ETH redeemed
        uint256 redeemed = contractBalanceAfterRedeem.sub(contractBalanceBeforeRedeem);
        require(redeemed >0, "ceth not redeemed");
        // convert the amount of ETH redeemed to ERC20 token, and then check if transaction is successful (>0 means tx is successful)
        uint256 erc20TokenRedeemed = swapExactETHForTokens(erc20TokenAddress,redeemed);
        require(erc20TokenRedeemed >0, "failed to swap tokens");
        
        // if redeemed amount is greater than total user balance (due to interest earned), then set user balance = 0 (assume full amount withdrawn) 
        if(redeemed > balances[msg.sender]) {
            balances[msg.sender] = 0;
        } else {
            balances[msg.sender]= balances[msg.sender].sub(redeemed);
        }

        // if redeemed amount is greater than the total contract balance (due to interest earned), then contract balance = 0 (assume full amount withdrawn)
        if(redeemed > totalContractBalance) {
            totalContractBalance =0;
        } else {
            totalContractBalance = totalContractBalance.sub(redeemed);
        }
        
        // check return value - ERC20 token transfer function will return true if transfer is successful 
        bool sent = ERC20(erc20TokenAddress).transfer(msg.sender, erc20TokenRedeemed);
        require(sent, "transfer failed");
        emit withdrawERC20Token(msg.sender, ERC20(erc20TokenAddress).symbol(), erc20TokenRedeemed);
        return true;
    }
    
    ///@dev receive() and fallback() functions to allow the contract to receive ETH and data  
    receive() external payable {
    }

    fallback() external payable {
    }
    
}