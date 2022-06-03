/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: UNLICENSED
/**
 * @copyright M.A.D. Computer Consulting LLC 2022 ALL RIGHTS RESERVED
 * @author Michael Dennis (@dreamingrainbow)
 * @description A Decentralized for profit trust, Winston Holdings And Trust is part of the Winston network
 * of services designed to bring education around blockchain technology and crypto currency to the common person.
 */

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}


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

// File: @openzeppelin/contracts/utils/Arrays.sol


// OpenZeppelin Contracts v4.4.1 (utils/Arrays.sol)

pragma solidity ^0.8.0;


/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Snapshot.sol)

pragma solidity ^0.8.0;


/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * NOTE: Snapshot policy can be customized by overriding the {_getCurrentSnapshotId} method. For example, having it
 * return `block.number` will trigger the creation of snapshot at the begining of each new block. When overridding this
 * function, be careful about the monotonicity of its result. Non-monotonic snapshot ids will break the contract.
 *
 * Implementing snapshots for every block using this method will incur significant gas costs. For a gas-efficient
 * alternative consider {ERC20Votes}.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */

abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // burn
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

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

abstract contract WinstonTokenListings is Ownable {
    event Listed(address token);
    event Unlisted(address token);
    mapping(address => bool) private _tokenListing;
    function listToken(address token) external onlyOwner {
        _tokenListing[token] = true;
        emit Listed(token);
    }
    
    function unlistToken(address token) external onlyOwner {
        _tokenListing[token] = false;
        emit Unlisted(token);
    }

    function isListed(address token) public view returns (bool) {
        return _tokenListing[token];
    }
}

abstract contract WinstonExchange is ERC20, WinstonTokenListings, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    event PairCreated(address user,uint256, address, address, uint256, uint256);
    event PairUpdated(address user,uint256, address, address, uint256, uint256);
    event PairWithdraw(address user,uint256, address, address, uint256, uint256);
    event Swap(address user, address from, address to, uint256 amount0, uint256 amount1);
    struct Pair {
        uint256 id;
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        address owner;
    }
    Counters.Counter private _currentPairId;
    uint256 _mTV = 1 * 10 ** decimals();
    uint256 _minToBuy = 100000;
    uint256 _tradeMultiplier = 10000;
    uint256 _sellFee = 1;
    uint256 _listingFee = 100; //1%
    bool _sellSplitIsDivisor = false;
    Pair[] private _pairs;
    function sellSplitIsDivisor() public view returns (bool) {
        return _sellSplitIsDivisor;
    }
    function setSellSplitIsDivisor(bool isDivisor) public returns (bool) {
        _sellSplitIsDivisor = isDivisor;
        return _sellSplitIsDivisor;
    }
    function setMinToBuy(uint256 amount) external returns (uint256 minToBuy) {
        _minToBuy = amount;
        return _minToBuy;
    }
    
    function setTradeMultiplier(uint256 amount) external returns (uint256 minToBuy) {
        _tradeMultiplier = amount;
        return _tradeMultiplier;
    }

    function getMinToBuy() public view returns (uint256 minToBuy) {
        return _minToBuy;
    }
    
    function getTradeMultiplier() public view returns (uint256 minToBuy) {
        return _tradeMultiplier;
    }

    function _getCurrentPairId() internal view virtual returns (uint256) {
        return _currentPairId.current();
    }

    function addPair(address token0, address token1, uint256 amount0, uint256 amount1) external returns (uint256, address, address, uint256, uint256) {
        require(token0 != token1, "Cannot create this pair.");
        require(isListed(token0), "Winston Error: token0 Not listed.");
        require(isListed(token1), "Winston Error: token1 Not listed.");
        (bool listed, ) = getPair(token0, token1);
        require(!listed, "Winston Error: Pair already listed.");
        require(amount0 <= 0, "Insufficient amount0");
        require(amount1 <= 0, "Insufficient amount1");
        require((IERC20(token0).balanceOf(_msgSender()) >= amount0), "Winston Error: Insufficient balance.");
        require((IERC20(token0).allowance(_msgSender(), address(this)) >= amount0), "Winston Error: Insufficient allowance.");
        require((IERC20(token1).balanceOf(_msgSender()) >= amount1), "Winston Error: Insufficient balance.");
        require((IERC20(token1).allowance(_msgSender(), address(this)) >= amount1), "Winston Error: Insufficient allowance.");
        IERC20(token0).safeTransferFrom(_msgSender(), address(this), amount0);
        IERC20(token1).safeTransferFrom(_msgSender(), address(this), amount1);
        _currentPairId.increment();
        uint256 currentId = _getCurrentPairId();
        Pair memory _new;
        _new.id = currentId;
        _new.token0 = token0;
        _new.token1 = token1;
        _new.reserve0 = (amount0 - (amount0 / 100));
        _new.reserve1 = (amount1 - (amount1 / 100));
        _new.owner = _msgSender();
        _pairs.push(_new);
        emit PairCreated(_msgSender(), currentId, token0, token1, amount0, amount1);
        return (currentId, token0, token1, amount0, amount1);
    }

    function getPair(address token0, address token1) public view returns (bool listed, Pair memory pair) {
        bool success = false;
        for (uint256 i = 0; i < _pairs.length; i++) {
            if((_pairs[i].token0 == token0 && _pairs[i].token1 == token1) || (_pairs[i].token1 == token0 && _pairs[i].token0 == token1 )) {
                success = true;
                return (success, _pairs[i]);
            }
        }
        Pair memory _empty;
        return(success, _empty);
    }

    function updatePair(address token0, address token1, uint256 amount0, uint256 amount1) public {
        require(token0 != token1, "Cannot update this pair.");
        (bool listed, Pair memory pair) = getPair(token0, token1);
        require(listed, "Winston Error: Pair not listed.");
        require(_msgSender() != pair.owner, "Winston Error: Not pair Owner.");
        require(amount0 >= 100, "Insufficient amount0");
        require(amount1 >= 100, "Insufficient amount1");
        uint256 updateR0 = (amount0 - (amount0 / 100));
        uint256 updateR1 = (amount1 - (amount1 / 100));
        require(updateR0 >= 0, "Insufficient amount0 for fee");
        require(updateR1 >= 0, "Insufficient amount1 for fee");
        require(updateR1 == (updateR0 * pair.reserve1)/pair.reserve0, "Winston Error: Incorrect ratio for pool.");
        IERC20(token0).safeTransfer(_msgSender(), updateR0);
        IERC20(token1).safeTransfer(_msgSender(), updateR1);
        pair.reserve0 += updateR0;
        pair.reserve1 += updateR1;
        emit PairUpdated(_msgSender(), pair.id, token0, token1, updateR0, updateR1);
    }

    function withdrawPair(address token0, address token1, uint256 amount0, uint256 amount1) public returns (bool) {
        require(token0 == token1, "Cannot update this pair.");
        (bool listed, Pair memory pair) = getPair(token0, token1);
        require(!listed, "Winston Error: Pair not listed.");
        require(_msgSender() == pair.owner, "Winston Error: Not pair Owner.");
        require(pair.reserve0 >= amount0, "Winston Error: Insufficient token0 reserve.");
        require(pair.reserve1 >= amount1, "Winston Error: Insufficient token1 reserve.");
        //fees ??
        IERC20(token0).safeTransferFrom(_msgSender(), address(this), amount0);
        IERC20(token1).safeTransferFrom(_msgSender(), address(this), amount1);        
        pair.reserve0 -= amount0;
        pair.reserve1 -= amount1;
        emit PairWithdraw(_msgSender(), pair.id, token0, token1, pair.reserve0, pair.reserve1);
        return listed && _msgSender() == pair.owner;
    }

    function getPairs() public view returns (Pair[] memory){
        return _pairs;
    }
    
    function swap(address from, address to, uint256 amount) public nonReentrant {
        require(from == to, "Winston Error: Cannot Swap the same assets.");
        require(IERC20(from).balanceOf(_msgSender()) >= amount, "Winston Error: Insufficient balance.");
        (bool listed, Pair memory existingPair) = getPair(from, to);
        require(listed, "This pair is not listed.");
        uint256 dexBalance = IERC20(address(this)).balanceOf(to);
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        uint256 x = amount;
        if(existingPair.reserve0 > existingPair.reserve1) {
            x = amount * (existingPair.reserve0 / existingPair.reserve1);
        } else if(existingPair.reserve1 < existingPair.reserve0){
            x = amount * (existingPair.reserve1 / existingPair.reserve0);
        }
        require(_listingFee >= x, "Winston Error: Insufficient trade amount to cover fee.");
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).transfer(existingPair.owner, _listingFee);
        IERC20(to).transfer(msg.sender, x - _listingFee);
        if(from == existingPair.token0) {
            existingPair.reserve0 += amount;
            existingPair.reserve1 -= x;
        } else {
            existingPair.reserve0 -= amount;
            existingPair.reserve1 += x;
        }
        emit Swap(_msgSender(), from, to, amount, x);
    }
}

// File: contracts/Winston.sol
pragma solidity ^0.8.4;


/// @custom:security-contact [email protected]ces
contract WinstonHoldingsAndTrust is ERC20, ERC20Snapshot, WinstonExchange {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    event Bought(address user, uint256 paid, uint256 received);
    event Sold(address user, uint256 paid, uint256 received);
    event Drip(address user, uint256 amount);
    event Staked(address token, uint256 amount);
    event UnStake(address token, uint256 amount, uint256 reward);
    event Reward(address token, uint256 usersPaid, uint256 amountPaid);
    event NewlyMinted(uint256 amount);

    struct Account {
        uint256 stake;
        uint256 stakingRewards;
        uint256 claimed;
    }

    struct Proposal {
        uint256 id;
        uint256 s; //start
        uint256 e; //end
        string u; //url
    }

    address[] _users;
    address[] _claiments;
    Proposal[] _proposals;

    uint256 private _startSupply = 110 * 10 ** decimals();
    address private _voterToken;
    uint256 private _maxTotalSupply = 1000000000 * 10 ** decimals();
    //Proposal Id => User => Vote
    mapping(uint256 => bool[]) private _voters;
    //voter has voted?
    mapping(address => bool) private _votes;
    //token => amount
    mapping(address => uint256) private rewards;
    //account management user token account
    mapping(address => mapping(address => Account)) private _accounts;
    mapping(address => uint256) private _faucetBalances;
    mapping(address => uint256) private _bridgeBalances;

    constructor() ERC20("Winston Holdings And Trust", "WHAT") payable {
        _mint(address(this), _startSupply);
    }

    receive() external payable {}

    function withdraw(uint256 amount) public onlyOwner nonReentrant {
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    function maxTotalSupply() public view returns (uint256) {
        return _maxTotalSupply;
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function updateVoterToken(address token) external onlyOwner {
        _voterToken = token;
    }

    function getVoterToken() public view returns (address) {
        return _voterToken;
    }

    function newProposal(uint256 start, uint256 end, string calldata url ) external {
        require((IERC20(_voterToken).balanceOf(_msgSender()) >= _mTV) == true, "Winston Error: Insufficient Voter Tokens.");
        
        uint256 _id = _proposals.length + 1;
        Proposal memory _new;
        _new.id = _id;
        _new.s = start;
        _new.e = end;
        _new.u = url;
        _proposals.push(_new);
    }

    function vote(uint256 id, bool v) external {
        require((IERC20(_voterToken).balanceOf(_msgSender()) >= _mTV), "Winston Error: Insufficient Voting Rights.");
        
        require((_proposals.length < id), "Winston Error: Invalid proposal id.");
        require((_votes[_msgSender()]), "Winston Error: You have already voted.");
        // get current block timestamp
        uint256 cT = block.timestamp;
        require((cT < _proposals[id].s), "Winston Error: Proposal has not started.");
        require((cT >= _proposals[id].e), "Winston Error: Proposal has ended.");
        //see of id exists in proposals;
        _votes[_msgSender()] = true;
        //cast the vote
        _voters[id].push(v);
    }

    function getVotes(uint256 id) public view returns (bool[] memory){
        return _voters[id];
    }

    function setMinToVote(uint256 amount) external onlyOwner {
        _mTV = amount;
    }

    function getMinToVote() public view returns (uint256) {
        return _mTV;
    }

    function quote(uint256 amount) public view returns (uint256) {
        uint256 amountTobuy = amount;
        require(amountTobuy > _minToBuy, "You need to send at least 0.000000000001 eth");
        if (_sellSplitIsDivisor) {
            amountTobuy = amount / _tradeMultiplier;
        } else {
            amountTobuy = amount * _tradeMultiplier;
        }
        return amountTobuy;
    }

    function buy() payable public nonReentrant {
        uint256 amountTobuy = msg.value;
        require(amountTobuy > _minToBuy, "You need to send at least 0.000000000001 eth");

        if (_sellSplitIsDivisor) {
            amountTobuy = msg.value / _tradeMultiplier;
        } else {
            amountTobuy = msg.value * _tradeMultiplier;
        }

        if(IERC20(address(this)).balanceOf(address(this)) <= amountTobuy) {
            if((IERC20(address(this)).balanceOf(address(this)) + amountTobuy) <= maxTotalSupply()) {
                uint256 amountToMint = amountTobuy - IERC20(address(this)).balanceOf(address(this));
                _mint(address(this), amountToMint + _mTV);
                emit NewlyMinted(amountToMint + _mTV);
            }
        }

        uint256 dexBalance = IERC20(address(this)).balanceOf(address(this));
        require(amountTobuy <= dexBalance,  "Insufficient Liquidity.");
        
        IERC20(address(this)).safeTransfer(msg.sender, amountTobuy);
        emit Bought(_msgSender(), msg.value, amountTobuy);
    }
    
    function sell(uint256 amount) public nonReentrant returns (uint256) {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = IERC20(address(this)).allowance(msg.sender, address(this));
        require(amount >= allowance, "Check the token allowance");

        uint256 amountPaid;
        if (_sellSplitIsDivisor) {
            require(address(this).balance >= ((amount * _tradeMultiplier) - _sellFee), "Insufficient Liquidity.");
            amountPaid = (amount * _tradeMultiplier) - _sellFee;
        } else {
            require(address(this).balance >= ((amount /_tradeMultiplier)  - _sellFee), "Insufficient Liquidity.");
            amountPaid = (amount /_tradeMultiplier)  - _sellFee;
        }
        require(IERC20(address(this)).balanceOf(_msgSender()) >= amount, "Winston Error: Insufficient balance.");
        IERC20(address(this)).transferFrom(msg.sender, address(this), amount);
        if ((IERC20(address(this)).balanceOf(address(this)) + amount) > _startSupply) {
            _burn(address(this), amount);
        }
        (bool success, ) = payable(msg.sender).call{value: amountPaid}("");
        emit Sold(_msgSender(), amount, amountPaid);
        require(success);
        return amountPaid;
    }

    function resetClaiments() external onlyOwner {
        delete _claiments;
    }

    function fund(address token, uint256 amount) public nonReentrant returns (uint256) {
        require(!isListed(token), "Winston Error: Token not listed.");
        require(IERC20(token).balanceOf(_msgSender()) >= amount, "Winston Error: Insufficient balance.");
        require((IERC20(token).allowance(_msgSender(), address(this)) >= amount), "Winston Error: Insufficient allowance.");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        _faucetBalances[token] += amount;
        return amount;
    }

    function claimed(address user) public view returns (bool) {
        return _is(user, "claim");
    }

    function _is(address user, string memory flag) internal view returns (bool) {
        address[] storage x;
        if(keccak256(abi.encodePacked(flag)) == keccak256(abi.encodePacked("claim"))) {
            x = _claiments;
        } else {
            x = _users;
        }
        for (uint i = 0; i < x.length; i++) {
            if (x[i] == user) {
                return true;
            }
        }
        return false;
    }

    function faucet(address token) external nonReentrant {
        require(!isListed(token), "Winston Error: Token not listed.");
        require(!_is(_msgSender(), "claim"), "Winston Error: Faucet Claimed.");
        require((_faucetBalances[token] >= 365) == true, "Winston Error: Faucet Dry.");
        uint256 amount = _faucetBalances[token] / 365;
        require((_faucetBalances[token] >= amount) == true, "Winston Error: Faucet Dry.");
        _claiments.push(_msgSender());
        _faucetBalances[token] -= amount;
        _accounts[_msgSender()][token].claimed += amount;
        IERC20(token).safeTransfer(_msgSender(), amount);
        emit Drip(_msgSender(), amount);
    }

    function faucetBalance(address token) public view returns (uint256) {
        return _faucetBalances[token];
    }

    function payRewards(address token, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(recipients.length == amounts.length, "Winston Error: Invalid Input");
        require(checkAmounts(token, amounts) == true, "Winston Error: Insufficient balance.");
        uint256 bal = 0;
        for(uint256 i = 0; i < recipients.length; i++) {
            bal += amounts[i];
            _accounts[recipients[i]][token].stakingRewards += amounts[i];
        }
        emit Reward(token, recipients.length, bal);
    } 

    function payNetRewards(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(recipients.length == amounts.length, "Winston Error: Invalid Input");
        bool s = false;
        uint256 bal = 0;
        for(uint256 i = 0; i < recipients.length; i++) {
            bal += amounts[i];
        }
        require(address(this).balance >= bal, "Winston Error: Insufficient Net Balance.");
        for(uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = payable(msg.sender).call{value: amounts[i]}("");
            if(!s && success) {
                s = true;
            }
            if(!success) {
                s = false;
            }
        }
        require(s);
    } 

    function getRewards(address token) external view returns (uint256) {
        return rewards[token];
    }
    
    function stake(address payable token, uint256 amount) external nonReentrant {
        require(!isListed(token), "Winston Error: Token not listed.");
        require((IERC20(token).balanceOf(_msgSender()) >= amount), "Winston Error: Insufficient balance.");
        require((IERC20(token).allowance(_msgSender(), address(this)) >= amount), "Winston Error: Insufficient allowance.");
        IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
        if(!_is(_msgSender(), 'user')) {
            _users.push(_msgSender());
        }
        _accounts[_msgSender()][token].stake += amount;
        emit Staked(token, amount);
    }

    function unstake(address token, uint256 amount) external nonReentrant {
        uint256 currentRewards = _accounts[_msgSender()][token].stakingRewards;
        _accounts[_msgSender()][token].stakingRewards = 0;
        require(amount >= _accounts[_msgSender()][token].stake, "Winston Error: Insufficient balance.");
        _accounts[_msgSender()][token].stake -= amount;
        uint256 withdrawAmountFee = amount / _tradeMultiplier;
        rewards[token] += withdrawAmountFee;
        uint256 withdrawAmount = amount - withdrawAmountFee;
        uint256 withdrawRewardFee = currentRewards / _tradeMultiplier;
        rewards[token] += withdrawRewardFee;
        currentRewards -= withdrawRewardFee;  
        if(withdrawAmount >= 0) {
            IERC20(token).safeTransfer(_msgSender(), withdrawAmount);
        }
        if(currentRewards >= 0) {
            IERC20(token).safeTransfer(_msgSender(), currentRewards);
        }
        emit UnStake(token, withdrawAmount, currentRewards);
    }

    function stakingBalance(address token, address user) external view returns (uint256) {
        return _accounts[user][token].stake;
    }

    function stakingReward(address token, address user) external view returns (uint256) {
        return _accounts[user][token].stakingRewards;
    }

    function claimedRewards(address token, address user) external view returns (uint256) {
        return _accounts[user][token].claimed;
    }

    function airdropTokens(address token, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(recipients.length == amounts.length, "Winston Error: Array lengths do not match");
        require(checkAmounts(token, amounts) == true, "Winston Error: Contract balance not enough to perform operation");

        for(uint256 i = 0; i < recipients.length; i++) {
            IERC20(token).safeTransfer(recipients[i], amounts[i]);
        }
    }

    function checkAmounts(address token, uint256[] calldata amounts) internal view returns (bool) {
        uint256 check;

        for(uint256 i = 0; i < amounts.length; i++) {
            check += amounts[i];
        }

        return IERC20(token).balanceOf(address(this)) >= check;
    }

    function getBridgeTokenBalance(address token) public view returns (uint256) {
        return _bridgeBalances[token];
    }

    function depositBridgedToken(address token, uint256 amount) public nonReentrant returns (uint256) {
        require((IERC20(token).balanceOf(_msgSender()) >= amount), "Winston Error: Insufficient balance.");
        require((IERC20(token).allowance(_msgSender(), address(this)) >= amount), "Winston Error: Insufficient allowance.");
        IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
        _bridgeBalances[token] += amount;
        return _bridgeBalances[token];
    }
    
    function withdrawBridgedToken(address token, uint256 amount, address to) public onlyOwner nonReentrant returns (uint256) {
        require((IERC20(token).balanceOf(address(this)) >= amount), "Winston Error: Insufficient balance.");
        IERC20(token).safeTransfer(to, amount);
        _bridgeBalances[token] -= amount;
        return _bridgeBalances[token];
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        if(amount > _mTV) {
            uint256 _transferFee = amount / 1000000;
            rewards[address(this)] += _transferFee;
            uint256 _amount = amount - _transferFee;
            super._beforeTokenTransfer(from, address(this), _transferFee);
            super._beforeTokenTransfer(from, to, _amount);
        } else {
            super._beforeTokenTransfer(from, to, amount);
        }
    }
}