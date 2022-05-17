/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// File: MinerTycoon1.sol



pragma solidity ^0.8.0;




contract MinerTycoon is Ownable {

    using SafeMath for uint256;

    struct User {

        uint8 mineNum;

        uint256[6] mineIds;

        address welMember;

        uint256 myGold;

        uint256 receiveEth;

        uint256 receiveGold;

        uint256 redirectTotal;

        uint256 indirectTotal;

        uint256 threeTotal;

        uint[] redirectIds;

        uint[] indirectIds;

        uint[] threeIds;

        uint redirectNum;

        uint indirectNum;

        uint threeNum;

        string nickName;
    }


    struct Mine {

        uint8 types;  

        uint256 price;

        uint16 gold;

        uint256 everyDay;

        uint16 reward;

    }

    struct Commission {

        address addr;

        uint256 mineType;

        uint256 reward;

    }

    struct MyMine {

        uint types;

        uint256 buyDays;

        uint256 checkTime;

        uint256 release;

        uint8 color;

        uint256 total;
    }

    struct GoldShop {

        uint256 goldNum;

        uint256 busdtNum;

    }

    uint256 ids;

    uint256 yIds;

    ERC20 EMC20;

    ERC20 ETH20;

    address myaddress;

    address depositAddress;

    address withDrawAddress;

    uint256[3] goldMine = [1e17, 5e16, 5e16];

    uint256[3] silverMine = [1e16, 5e15, 5e15];

    mapping(address => User) public users;

    mapping(uint256 => MyMine) public myMines;

    mapping(uint256 => Mine) public mines;

    mapping(uint256 => Commission) public redirectReward;

    mapping(uint256 => Commission) public indirectReward;

    mapping(uint256 => Commission) public threeReward;

    mapping(uint8 => GoldShop) public goldShops;

    mapping(address => bool) contractUsers;

    event PaymentReceived(address from, uint256 amount);

    event BuyMines(address addr, uint types, uint8 colors);

    event BindWelMember(address addr, address welMember, bool result);

    event GetMineYesterday(address addr, uint total);  

    event GetGold(uint num);

    event GetEth(uint num);

    constructor () {

        myaddress = msg.sender;

        EMC20 = ERC20(0x7Ff30b2C9d6b221664265724DBD85DB964912603);

        ETH20 = ERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);

        withDrawAddress = 0xc7BA57407C9708210C8776b04E7c1c0Ea5b40642;

        depositAddress = 0x720588D6Df3e7Fe46E19De44cFD10EC849f9B351;

        contractUsers[0x3599173d1fDD8107CCa104614F9f01fbB533A2A1] = true;

        mines[1] = Mine(1, 1e18, 50,  uint256(1e18).div(uint256(90)), 600);

        mines[2] = Mine(2, 1e17, 5, uint(1e17).div(90), 60);

        goldShops[1] = GoldShop(50, 80e18);

        goldShops[2] = GoldShop(100, 160 * 1e18);

        goldShops[3] = GoldShop(200, 320 * 1e18);

    }

    receive() external payable virtual {

        emit PaymentReceived(_msgSender(), msg.value);

    }

    function buyMine(uint mid, uint8 colors) public {

        require(users[msg.sender].welMember != address(0), "welMember can not ");

        require(users[msg.sender].mineNum < 6, "you can buy most six mine");

        require(mid == 1 || mid == 2, "you can buy most six mine");

        // transferbalanceEth(msg.sender, mines[mid].price);

        users[msg.sender].mineNum += 1;

        ids += 1;

        myMines[ids] = MyMine(mid, block.timestamp, block.timestamp + 1 days, mines[mid].everyDay, colors, 0);

        uint256 index = _findIndex(0);

        require(index < 6);

        users[msg.sender].mineIds[index] = ids;

        address welMember = users[msg.sender].welMember;

        contractUsers[msg.sender] = true;

        for (uint8 j = 0; j < 3; j++) {

            if (welMember == address(0) || welMember == msg.sender) break;

            uint256 money = mid == 1 ? goldMine[j] : silverMine[j];

            users[welMember].receiveEth += money;

            yIds++;

            if (j == 0) {

                users[welMember].receiveGold += mines[mid].reward;

                redirectReward[yIds] = Commission(msg.sender, mid, money);

                users[welMember].redirectIds.push(yIds);
            }

            if (j == 1) {

                indirectReward[yIds] = Commission(msg.sender, mid, money);

                users[welMember].indirectIds.push(yIds);
            }

            if (j == 2) {

                threeReward[yIds] = Commission(msg.sender, mid, money);

                users[welMember].threeIds.push(yIds);
            }

            welMember = users[welMember].welMember;

        }

        emit BuyMines(msg.sender, mid, colors);
    }

    function bindUserWelMember(address adds) public {

        require(users[msg.sender].welMember ==  address(0), "you must have no welMember" );

        require(contractUsers[adds], "this address no use in this contract");

        users[msg.sender].welMember = adds;

        users[adds].redirectNum += 1;

        address welAdd = users[adds].welMember;

        if (welAdd != address(0) && welAdd != myaddress) {

                users[welAdd].indirectNum += 1;

                welAdd = users[welAdd].welMember;
        }

        if (welAdd != address(0) && welAdd != myaddress) 
                users[welAdd].threeNum += 1;

        emit BindWelMember(msg.sender, adds, true);
    }

    function _findIndex(uint256 val) internal view returns (uint256 index) {

        uint[6] memory arr = users[msg.sender].mineIds;

        for (uint8 i = 0; i < 6; i++) {

            if (arr[i] == val) {
                return i;
            }
        }
        return 999999999;

    }

    function signMine(uint id) public checkMine(id){

        require(myMines[id].checkTime < block.timestamp, "the mine can no to check ");

         uint ds = (block.timestamp - myMines[id].buyDays).div(1 days);

         if (ds > 180) {

             if (myMines[id].release > 0) {
                getMineYesterday(id);
             }

            delete users[msg.sender].mineIds[_findIndex(id)];

            delete myMines[id];
            
            users[msg.sender].mineNum -= 1;

        } else {

            require(users[msg.sender].myGold >= mines[myMines[id].types].gold, "You don't have enough gold coins ");

            users[msg.sender].myGold -= mines[myMines[id].types].gold;

            myMines[id].checkTime = block.timestamp + 1 days;

            myMines[id].release += mines[myMines[id].types].everyDay ;

        }

    }

    function getMineYesterday(uint id) public checkMine(id) {

        uint much;

        if (myMines[id].checkTime < block.timestamp) {

             require(myMines[id].release > 0, "no money can draw or Available tomorrow");

             much = myMines[id].release;

             myMines[id].release = 0;

        } else {

             require(myMines[id].release > mines[myMines[id].types].everyDay, "no money can draw or Available tomorrow");

             much = myMines[id].release - mines[myMines[id].types].everyDay;

             myMines[id].release = mines[myMines[id].types].everyDay;

        }

        myMines[id].total += much;

        ETH20.transferFrom(withDrawAddress, msg.sender, much);

        emit GetMineYesterday(msg.sender, much);
    }


    modifier checkMine(uint id) {

         require(id > 0, "id maybe > 0");

         uint256 index = _findIndex(id);

         require(index < 6);

         _;

    }

    function setRewardRulers(uint8 types, uint[3] memory arr) public onlyOwner {
        if (types == 1) {
            goldMine = arr;
        } else {
            silverMine = arr;
        }

    }

    function setPrice(uint8 types, uint price) public onlyOwner {
        mines[types].price = price;

    }

    function setGold(uint8 types, uint16 gold) public onlyOwner {
        mines[types].gold = gold;

    }

    function ownerWithdrew (uint256 amount) public onlyOwner{
    
        amount = amount * 10 **18;
        
        uint256 dexBalance = EMC20.balanceOf(address(this));
        
        require(amount > 0, "You need to send some ether");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        EMC20.transfer(msg.sender, amount);
    }
    
    function ownerDeposit( uint256 amount ) public onlyOwner {
        
        amount = amount * 10 **18;

        uint256 dexBalance = EMC20.balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some ether");
        
        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        EMC20.transferFrom(msg.sender, address(this), amount);
    }

    function setDepositAddress (address addr) public onlyOwner {
        depositAddress = addr;
    }

    function setWithDrawAddress (address addr) public onlyOwner {
        withDrawAddress = addr;
    }

    function transferbalance(address adds, uint amount) public {

        uint256 allowance = EMC20.allowance(adds, address(this));

    	uint256 dexBalance = EMC20.balanceOf(adds);

        require(allowance >= amount , "Check the token allowance");

        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        EMC20.transferFrom(adds, depositAddress, amount);
    }

    function transferbalanceEth(address adds, uint amount) public {

        uint256 allowance = ETH20.allowance(adds, address(this));

    	uint256 dexBalance = ETH20.balanceOf(adds);

        require(allowance >= amount , "Check the token allowance");

        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        ETH20.transferFrom(adds, depositAddress, amount);
    }

    function buyGold(uint8 indexs) public {

        GoldShop storage gold = goldShops[indexs];

        transferbalance(msg.sender, gold.busdtNum);

        users[msg.sender].myGold += gold.goldNum;
    }

    function getEth() public {

        require(users[msg.sender].receiveEth > 0);

        ETH20.transferFrom(withDrawAddress, msg.sender, users[msg.sender].receiveEth);

        users[msg.sender].receiveEth = 0;

        emit GetEth(users[msg.sender].receiveEth);

    }

    function getGold() public {

        require(users[msg.sender].receiveGold > 0);

        users[msg.sender].myGold += users[msg.sender].receiveGold;

        users[msg.sender].receiveGold = 0;

        emit GetGold(users[msg.sender].receiveGold);
    }

    function getMinesIndex(address addr) public view returns(uint[6] memory) {

        return users[addr].mineIds;

    }

    function getRewardIndex(uint8 types, address addr) public view returns(uint[] memory) {

        if (types == 1) return users[addr].redirectIds;


        if (types == 2) return users[addr].indirectIds;

        return users[addr].threeIds;
    }

    function minesCanCheck(uint minesId) public view returns(bool) {
        return myMines[minesId].checkTime < block.timestamp;
    }

    function getTodayTime() public view returns(uint) {
        return block.timestamp;
    }

    function setNickName(string memory name) public returns(bool) {
        users[msg.sender].nickName = name;
        return true;
    }

}
// File: MinerTycoon2.sol



pragma solidity ^0.8.0;


contract MinerTycoon2 is Ownable {
    
    using SafeMath for uint256;
    
    MinerTycoon MT;

    struct User {

        uint8 mineNum;

        uint256[6] mineIds;

        address welMember;

        uint256 myGold;

        uint256 receiveEth;

        uint256 receiveGold;

        uint256 redirectTotal;

        uint256 indirectTotal;

        uint256 threeTotal;

        uint[] redirectIds;

        uint[] indirectIds;

        uint[] threeIds;

        uint redirectNum;

        uint indirectNum;

        uint threeNum;

        string nickName;
    }

    struct Mine {

        uint8 types;  

        uint256 price;

        uint16 gold;

        uint256 everyDay;

        uint16 reward;

    }

    struct Commission {

        address addr;

        uint256 mineType;

        uint256 reward;

    }

    struct MyMine {

        uint types;

        uint256 buyDays;

        uint256 checkTime;

        uint256 release;

        uint8 color;

        uint256 total;
    }

    struct GoldShop {

        uint256 goldNum;

        uint256 busdtNum;

    }

    uint256 public ids;

    uint256 public yIds;

    ERC20 EMC20;

    ERC20 ETH20;

    address myaddress;

    address depositAddress;

    address withDrawAddress;

    uint256 public lifeCycleOfMine = 1090;

    uint256[3] goldMine = [1e17, 5e16, 5e16];

    uint256[3] silverMine = [1e16, 5e15, 5e15];

    address[] public userAddrs;

    mapping(address => User) public users;

    mapping(uint256 => MyMine) public myMines;

    mapping(uint256 => Mine) public mines;

    mapping(address => uint256[]) public myMineIds;

    mapping(uint256 => Commission) public redirectReward;

    mapping(uint256 => Commission) public indirectReward;

    mapping(uint256 => Commission) public threeReward;

    mapping(uint8 => GoldShop) public goldShops;

    mapping(address => bool) public contractUsers;

    event PaymentReceived(address from, uint256 amount);

    event BuyMines(address addr, uint types, uint8 colors);

    event BindWelMember(address addr, address welMember, bool result);

    event GetMineYesterday(address addr, uint total);  

    event GetGold(uint num);

    event GetEth(uint num);

    event SynchData(uint num);

    constructor () {

        MT = MinerTycoon(payable(0x24795AfA3CFfB4Ca2172f2301a7C39fE1988bC70));

        myaddress = msg.sender;

        EMC20 = ERC20(0x7Ff30b2C9d6b221664265724DBD85DB964912603);

        ETH20 = ERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);

        withDrawAddress = 0x04550FE3A233cBdf165c18D2e300eF7cDb8742A4;

        depositAddress = 0x8198E9Ea957507Bc991736b244A902FD6D9cda43;

        contractUsers[0x3599173d1fDD8107CCa104614F9f01fbB533A2A1] = true;

        mines[1] = Mine(1, 1e18, 50, 2750 * 10 ** 12, 600);

        mines[2] = Mine(2, 1e17, 5, 275 * 10 ** 12, 60);

        goldShops[1] = GoldShop(50, 80e18);

        goldShops[2] = GoldShop(100, 160 * 1e18);

        goldShops[3] = GoldShop(200, 320 * 1e18);

    }

    receive() external payable virtual {

        emit PaymentReceived(_msgSender(), msg.value);

    }

    function buyMine(uint mid, uint8 colors) public {

        require(users[msg.sender].welMember != address(0), "welMember can not ");

        require(users[msg.sender].mineNum < 6, "you can buy most six mine");

        require(mid == 1 || mid == 2, "you can buy most six mine");

        transferbalanceEth(msg.sender, mines[mid].price);

        users[msg.sender].mineNum += 1;

        ids += 1;

        myMines[ids] = MyMine(mid, block.timestamp, block.timestamp + 1 days, mines[mid].everyDay, colors, 0);

        uint256 index = _findIndex(msg.sender, 0);

        require(index < 6);

        users[msg.sender].mineIds[index] = ids;

        myMineIds[msg.sender].push(ids);

        address welMember = users[msg.sender].welMember;

        if(!contractUsers[msg.sender]){
            contractUsers[msg.sender] = true;
            userAddrs.push(msg.sender);
        }

        for (uint8 j = 0; j < 3; j++) {

            if (welMember == address(0) || welMember == msg.sender) break;

            uint256 money = mid == 1 ? goldMine[j] : silverMine[j];

            users[welMember].receiveEth += money;

            yIds++;

            if (j == 0) {

                users[welMember].receiveGold += mines[mid].reward;

                redirectReward[yIds] = Commission(msg.sender, mid, money);

                users[welMember].redirectIds.push(yIds);
            }

            if (j == 1) {

                indirectReward[yIds] = Commission(msg.sender, mid, money);

                users[welMember].indirectIds.push(yIds);
            }

            if (j == 2) {

                threeReward[yIds] = Commission(msg.sender, mid, money);

                users[welMember].threeIds.push(yIds);
            }

            welMember = users[welMember].welMember;

        }

        emit BuyMines(msg.sender, mid, colors);
    }

    function bindUserWelMember(address adds) public {

        require(users[msg.sender].welMember ==  address(0), "you must have no welMember" );

        require(contractUsers[adds], "this address no use in this contract");

        users[msg.sender].welMember = adds;

        users[adds].redirectNum += 1;

        address welAdd = users[adds].welMember;

        if (welAdd != address(0) && welAdd != myaddress) {

                users[welAdd].indirectNum += 1;

                welAdd = users[welAdd].welMember;
        }

        if (welAdd != address(0) && welAdd != myaddress) 
                users[welAdd].threeNum += 1;

        emit BindWelMember(msg.sender, adds, true);
    }

    function _findIndex(address user, uint256 val) internal view returns (uint256 index) {

        uint[6] memory arr = users[user].mineIds;

        for (uint8 i = 0; i < 6; i++) {

            if (arr[i] == val) {
                return i;
            }
        }
        return 999999999;

    }

    function signMine(uint id) public checkMine(id){

        require(myMines[id].checkTime < block.timestamp, "the mine can no to check ");

         uint ds = (block.timestamp - myMines[id].buyDays).div(1 days);

         if (ds > lifeCycleOfMine) {

             if (myMines[id].release > 0) {
                getMineYesterday(id);
             }

            delete users[msg.sender].mineIds[_findIndex(msg.sender, id)];

            delete myMines[id];
            
            users[msg.sender].mineNum -= 1;

        } else {

            require(users[msg.sender].myGold >= mines[myMines[id].types].gold, "You don't have enough gold coins ");

            users[msg.sender].myGold -= mines[myMines[id].types].gold;

            myMines[id].checkTime = block.timestamp + 1 days;

            myMines[id].release += mines[myMines[id].types].everyDay ;

        }

    }

    function getMineYesterday(uint id) public checkMine(id) {

        uint much;

        if (myMines[id].checkTime < block.timestamp) {

             require(myMines[id].release > 0, "no money can draw or Available tomorrow");

             much = myMines[id].release;

             myMines[id].release = 0;

        } else {

             require(myMines[id].release > mines[myMines[id].types].everyDay, "no money can draw or Available tomorrow");

             much = myMines[id].release - mines[myMines[id].types].everyDay;

             myMines[id].release = mines[myMines[id].types].everyDay;

        }

        myMines[id].total += much;

        ETH20.transferFrom(withDrawAddress, msg.sender, much);

        emit GetMineYesterday(msg.sender, much);
    }


    modifier checkMine(uint id) {

         require(id > 0, "id maybe > 0");

         uint256 index = _findIndex(msg.sender, id);

         require(index < 6);

         _;

    }

    function setRewardRulers(uint8 types, uint[3] memory arr) public onlyOwner {
        if (types == 1) {
            goldMine = arr;
        } else {
            silverMine = arr;
        }

    }

    function setPrice(uint8 types, uint price) public onlyOwner {
        mines[types].price = price;

    }

    function setGold(uint8 types, uint16 gold) public onlyOwner {
        mines[types].gold = gold;
    }

    function setDayMine(uint index, uint dayMine) public onlyOwner {
        mines[index].everyDay = dayMine;
    }

    function setlifeCycleOfMine(uint dayNum) public onlyOwner {
        lifeCycleOfMine = dayNum;
    }

    function setMT(address MTAddr) public onlyOwner {
        MT = MinerTycoon(payable(MTAddr));
    }

    function setIds(uint256 index) public onlyOwner {
        ids = index;
    }

    function setYIds(uint256 index) public onlyOwner {
        yIds = index;
    }

    function setDepositAddress (address addr) public onlyOwner {
        depositAddress = addr;
    }

    function setWithDrawAddress (address addr) public onlyOwner {
        withDrawAddress = addr;
    }
    
    function setNickName(string memory name) public returns(bool) {
        users[msg.sender].nickName = name;
        return true;
    }

    function ownerWithdrew (uint256 amount) public onlyOwner{
    
        amount = amount * 10 **18;
        
        uint256 dexBalance = EMC20.balanceOf(address(this));
        
        require(amount > 0, "You need to send some ether");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        EMC20.transfer(msg.sender, amount);
    }
    
    function ownerDeposit( uint256 amount ) public onlyOwner {
        
        amount = amount * 10 **18;

        uint256 dexBalance = EMC20.balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some ether");
        
        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        EMC20.transferFrom(msg.sender, address(this), amount);
    }

    
    function transferbalance(address adds, uint amount) public {

        uint256 allowance = EMC20.allowance(adds, address(this));

    	uint256 dexBalance = EMC20.balanceOf(adds);

        require(allowance >= amount , "Check the token allowance");

        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        EMC20.transferFrom(adds, depositAddress, amount);
    }

    function transferbalanceEth(address adds, uint amount) public {

        uint256 allowance = ETH20.allowance(adds, address(this));

    	uint256 dexBalance = ETH20.balanceOf(adds);

        require(allowance >= amount , "Check the token allowance");

        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        ETH20.transferFrom(adds, depositAddress, amount);
    }

    function buyGold(uint8 indexs) public {

        GoldShop storage gold = goldShops[indexs];

        transferbalance(msg.sender, gold.busdtNum);

        users[msg.sender].myGold += gold.goldNum;
    }

    function getEth() public {

        require(users[msg.sender].receiveEth > 0);

        ETH20.transferFrom(withDrawAddress, msg.sender, users[msg.sender].receiveEth);

        users[msg.sender].receiveEth = 0;

        emit GetEth(users[msg.sender].receiveEth);

    }

    function getGold() public {

        require(users[msg.sender].receiveGold > 0);

        users[msg.sender].myGold += users[msg.sender].receiveGold;

        users[msg.sender].receiveGold = 0;

        emit GetGold(users[msg.sender].receiveGold);
    }

    function getMinesIndex(address addr) public view returns(uint[6] memory) {

        return users[addr].mineIds;

    }

    function getRewardIndex(uint8 types, address addr) public view returns(uint[] memory) {

        if (types == 1) return users[addr].redirectIds;


        if (types == 2) return users[addr].indirectIds;

        return users[addr].threeIds;
    }

    function minesCanCheck(uint minesId) public view returns(bool) {
        return myMines[minesId].checkTime < block.timestamp;
    }

    function getTodayTime() public view returns(uint) {
        return block.timestamp;
    }

    function getUserAddrs() public view returns(address[] memory addrs) {
        addrs = userAddrs;
        return addrs;
    }

    function getUserAmount() public view returns(uint amount) {
        amount = userAddrs.length;
        return amount;
    }

    function getMineAmount() public view returns(uint amount) {
        amount = ids;
        return amount;
    }

    function synchDataOfMyMines(uint start, uint end) public onlyOwner {

        uint count;

        for(uint i = start; i < end; i++){

            (uint types,uint256 buyDays,uint256 checkTime,uint256 release,uint8 color,uint256 total) = MT.myMines(i);

            if(buyDays > 0){
                myMines[i] = MyMine(types, buyDays, checkTime, release, color, total);

                count++;
            }
        }

        emit SynchData(count);
    }

    function synchDataOfUsersMineIds(address[] memory useraddrs) public onlyOwner {

        uint count;

        for(uint i = 0; i < useraddrs.length; i++){

            users[useraddrs[i]].mineIds = MT.getMinesIndex(useraddrs[i]);

            count++;
        }

        emit SynchData(count);
    }

    function synchDataOfRedirectReward(uint start, uint end) public onlyOwner {

        uint count;

        for(uint i = start; i < end; i++){

            (address addr,uint256 mineType,uint256 reward) = MT.redirectReward(i);

            if(mineType > 0){
                redirectReward[i] = Commission(addr, mineType, reward);

                count++;
            }
        }

        emit SynchData(count);
    }

    function synchDataOfIndirectReward(uint start, uint end) public onlyOwner {

        uint count;

        for(uint i = start; i < end; i++){

            (address addr,uint256 mineType,uint256 reward) = MT.indirectReward(i);

            if(mineType > 0){
                indirectReward[i] = Commission(addr, mineType, reward);

                count++;
            }
        }

        emit SynchData(count);
    }

    function synchDataOfThreeReward(uint start, uint end) public onlyOwner {

        uint count;

        for(uint i = start; i < end; i++){

            (address addr,uint256 mineType,uint256 reward) = MT.threeReward(i);

            if(mineType > 0){
                threeReward[i] = Commission(addr, mineType, reward);

                count++;
            }
        }

        emit SynchData(count);
    }

    function synchDataOfUserReward(address[] memory useraddrs) public onlyOwner {

        address useraddr;

        uint count;

        for(uint i = 0; i < useraddrs.length; i++){

            useraddr = useraddrs[i];

            users[useraddr].redirectIds = MT.getRewardIndex(1, useraddr);

            users[useraddr].indirectIds = MT.getRewardIndex(2, useraddr);

            users[useraddr].threeIds = MT.getRewardIndex(3, useraddr);

           count++;
        }

        emit SynchData(count);
    }

    function synchAllDataOfUser(address useraddr, uint8  mineNum, address welMembers, 
    uint256  myGold, uint256  receiveEth, uint256  receiveGold, uint8  redirectNum, 
    uint256  indirectNum, uint256  threeNum, string memory nickName) public onlyOwner {

        uint count;

        users[useraddr].mineNum = mineNum;

        if(mineNum > 0 && !contractUsers[useraddr]){
            contractUsers[useraddr] = true;
            userAddrs.push(useraddr);
        }

        users[useraddr].welMember = welMembers;

        users[useraddr].myGold = myGold;

        users[useraddr].receiveEth = receiveEth;

        users[useraddr].receiveGold = receiveGold;

        users[useraddr].redirectNum = redirectNum;

        users[useraddr].indirectNum = indirectNum;

        users[useraddr].threeNum = threeNum;

        users[useraddr].nickName = nickName;

        count++;

        emit SynchData(count);
    }

    function synchAllDataOfUsers(address[] memory useraddrs, uint8[] memory mineNum, address[] memory welMembers, 
    uint256[] memory myGold, uint256[] memory receiveEth, uint256[] memory receiveGold, uint8[] memory redirectNum, 
    uint256[] memory indirectNum, uint256[] memory threeNum, string[] memory nickName) public onlyOwner {

        uint256 num = useraddrs.length;

        require(num == mineNum.length && num == welMembers.length && num == myGold.length && num == receiveEth.length && num == receiveGold.length
        && num == redirectNum.length && num == indirectNum.length && num == threeNum.length && num == nickName.length,"wrong data");

        address useraddr;

        uint count;

        for(uint i = 0; i < useraddrs.length; i++){

            useraddr = useraddrs[i];

            users[useraddr].mineNum = mineNum[i];

            if(mineNum[i] > 0 && !contractUsers[useraddr]){
                contractUsers[useraddr] = true;
                userAddrs.push(useraddr);
            }

            users[useraddr].welMember = welMembers[i];

            users[useraddr].myGold = myGold[i];

            users[useraddr].receiveEth = receiveEth[i];

            users[useraddr].receiveGold = receiveGold[i];

            users[useraddr].redirectNum = redirectNum[i];

            users[useraddr].indirectNum = indirectNum[i];

            users[useraddr].threeNum = threeNum[i];

            users[useraddr].nickName = nickName[i];

            count++;
        }

        emit SynchData(count);
    }
    
}