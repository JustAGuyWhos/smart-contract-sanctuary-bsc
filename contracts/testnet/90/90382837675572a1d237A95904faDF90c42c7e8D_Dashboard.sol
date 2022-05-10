// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../libraries/SafeDecimal.sol";
import "../interfaces/IMasterChef.sol";
import "../interfaces/IEvmoSwapPair.sol";
import "../interfaces/IEvmoSwapFactory.sol";

contract Dashboard {
    using SafeMath for uint;
    using SafeDecimal for uint;

    uint256 private constant SEC_PER_YEAR = 86400 * 365;

    address private _owner;

    // WETH WFTM WBNB
    IERC20 public weth;
    IERC20 public usdc;
    IMasterChef public master;
    IEvmoSwapFactory public factory;
    IERC20 public reward; 

    mapping(address => address) public pairAddresses;

    constructor(address _weth, address _usdc, address _reward, address _master, address _factory) public {
        weth = IERC20(_weth);
        usdc = IERC20(_usdc);
        reward = IERC20(_reward);
        master = IMasterChef(_master);
        factory = IEvmoSwapFactory(_factory);
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /* ========== Restricted Operation ========== */

    function setPairAddress(address asset, address pair) external onlyOwner {
        pairAddresses[asset] = pair;
    }

    /* ========== Value Calculation ========== */

    function ethPriceInUSD() view public returns (uint) {
        address usdcEthPair = factory.getPair(address(usdc), address(weth));
        uint _decimals = ERC20(address(usdc)).decimals();
        uint _usdcValue = usdc.balanceOf(usdcEthPair).mul(10 ** (18 - uint256(_decimals)));
        return _usdcValue.mul(1e18).div(weth.balanceOf(usdcEthPair));
    }

    function rewardPriceInUSD() view public returns (uint) {
        (, uint _rewardPriceInUSD) = valueOfAsset(address(reward), 1e18);
        return _rewardPriceInUSD;
    }

    function rewardPerYearOfPool(uint pid) view public returns (uint) {
        uint256 multiplier = master.startTime() <= block.timestamp ? 1 : 0;
        (,,,uint allocPoint,,,) = master.poolInfo(pid);
        return master.emoPerSecond().mul(multiplier).mul(SEC_PER_YEAR).mul(allocPoint).div(master.totalAllocPoint());
    }

    function valueOfAsset(address asset, uint amount) public view returns (uint valueInETH, uint valueInUSD) {
        if (asset == address(0) || asset == address(weth)) {
            valueInETH = amount;
            valueInUSD = amount.mul(ethPriceInUSD()).div(1e18);
        } else if (keccak256(abi.encodePacked(IEvmoSwapPair(asset).symbol())) == keccak256("EMO-LP")) {
            if (IEvmoSwapPair(asset).token0() == address(weth) || IEvmoSwapPair(asset).token1() == address(weth)) {
                valueInETH = amount.mul(weth.balanceOf(address(asset))).mul(2).div(IEvmoSwapPair(asset).totalSupply());
                valueInUSD = valueInETH.mul(ethPriceInUSD()).div(1e18);
            } else {
                uint balanceToken0 = IERC20(IEvmoSwapPair(asset).token0()).balanceOf(asset);
                (uint token0PriceInETH,) = valueOfAsset(IEvmoSwapPair(asset).token0(), 1e18);

                valueInETH = amount.mul(balanceToken0).mul(2).mul(token0PriceInETH).div(1e18).div(IEvmoSwapPair(asset).totalSupply());
                valueInUSD = valueInETH.mul(ethPriceInUSD()).div(1e18);
            }
        } else {
            address pairAddress = pairAddresses[asset];
            if (pairAddress == address(0)) {
                pairAddress = address(weth);
            }

            address pair = factory.getPair(asset, pairAddress);
            if (pair == address(0) || IERC20(asset).balanceOf(pair) == 0) {
                valueInETH = 0;
            } else {
                valueInETH = IERC20(pairAddress).balanceOf(pair).mul(amount).div(IERC20(asset).balanceOf(pair));
                if (pairAddress != address(weth)) {
                    (uint pairValueInETH,) = valueOfAsset(pairAddress, 1e18);
                    valueInETH = valueInETH.mul(pairValueInETH).div(1e18);
                }
            }
            valueInUSD = valueInETH.mul(ethPriceInUSD()).div(1e18);
        }
    }

    /* ========== APY Calculation ========== */

    function apyOfPool(uint256 pid) public view returns (uint apyPool) {
        (address token,uint256 workingSupply,,,,,) = master.poolInfo(pid);
        (uint valueInETH,) = valueOfAsset(token, workingSupply);

        (uint rewardPriceInETH,) = valueOfAsset(address(reward), 1e18);
        uint _rewardPerYearOfPool = rewardPerYearOfPool(pid);
        if (_rewardPerYearOfPool == 0) {
            return 0;
        } else if (valueInETH == 0) {
            return 10000 * (10 ** 18);
        } else {
            // 40%
            return (master.TOKENLESS_PRODUCTION()).mul(rewardPriceInETH).mul(_rewardPerYearOfPool).div(valueInETH).div(100);
        }
    }

    function apyOfPools(uint256[] memory pids) public view returns (uint[] memory apyPool) {
        apyPool = new uint[](pids.length);
        for (uint256 i = 0; i < pids.length; i++) {
            apyPool[i] = apyOfPool(pids[i]);
        }
    }

    function boostApyOfPool(uint256 pid, address user) public view returns (uint apyPool) {
        (address token,uint256 workingSupply,,,,,) = master.poolInfo(pid);
        (uint256 amount, uint256 workingAmount,) = master.userInfo(pid, user);
        if (workingAmount == 0) {
            return apyOfPool(pid);
        }

        (uint valueInETH,) = valueOfAsset(token, amount);
        (uint rewardPriceInETH,) = valueOfAsset(address(reward), 1e18);
        uint _rewardPerYearOfPool = rewardPerYearOfPool(pid).mul(workingAmount).div(workingSupply);
        if (_rewardPerYearOfPool == 0) {
            return 0;
        } else if (valueInETH == 0) {
            return 10000 * (10 ** 18);
        } else {
            return rewardPriceInETH.mul(_rewardPerYearOfPool).div(valueInETH);
        }
    }

    function boostApyOfPools(uint256[] memory pids) public view returns (uint[] memory apyPool) {
        apyPool = new uint[](pids.length);
        for (uint256 i = 0; i < pids.length; i++) {
            apyPool[i] = apyOfPool(pids[i]);
        }
    }

    /* ========== TVL Calculation ========== */
    function tvlOfPool(uint256 pid) public view returns (uint256 allocPoint, uint tvl, uint tvlInUSD) {
        (address token,,,uint256 _allocPoint,,,) = master.poolInfo(pid);
        allocPoint = _allocPoint;
        tvl = IERC20(token).balanceOf(address(master));
        (, tvlInUSD) = valueOfAsset(token, tvl);
    }

    function tvlOfPools(uint256[] memory pids) public view returns (uint totalTvl, uint totalTvlInUSD, uint256[] memory allocPoint, uint[] memory tvl, uint[] memory tvlInUSD) {
        totalTvl = 0;
        totalTvlInUSD = 0;
        allocPoint = new uint256[](pids.length);
        tvl = new uint[](pids.length);
        tvlInUSD = new uint[](pids.length);
        for (uint256 i = 0; i < pids.length; i++) {
            (allocPoint[i], tvl[i], tvlInUSD[i]) = tvlOfPool(pids[i]);
            totalTvl = totalTvl.add(tvl[i]);
            totalTvlInUSD = totalTvlInUSD.add(tvlInUSD[i]);
        }
    }

    function infoOfPools(uint256[] memory pids) public view returns (uint tokenPrice, uint totalTvl, uint totalTvlInUSD, uint256[] memory allocPoint, uint[] memory apy, uint[] memory tvl, uint[] memory tvlInUSD) {
        totalTvl = 0;
        totalTvlInUSD = 0;
        allocPoint = new uint256[](pids.length);
        apy = new uint[](pids.length);
        tvl = new uint[](pids.length);
        tvlInUSD = new uint[](pids.length);
        tokenPrice = rewardPriceInUSD();
        for (uint256 i = 0; i < pids.length; i++) {
            apy[i] = apyOfPool(pids[i]);
            (allocPoint[i], tvl[i], tvlInUSD[i]) = tvlOfPool(pids[i]);
            totalTvl = totalTvl.add(tvl[i]);
            totalTvlInUSD = totalTvlInUSD.add(tvlInUSD[i]);
        }
    }

    function boostInfoOfPools(uint256[] memory pids, address user) public view returns (uint tokenPrice, uint totalTvl, uint totalTvlInUSD, uint256[] memory allocPoint, uint[] memory apy, uint[] memory boostApy, uint[] memory tvl, uint[] memory tvlInUSD) {
        totalTvl = 0;
        totalTvlInUSD = 0;
        allocPoint = new uint256[](pids.length);
        apy = new uint[](pids.length);
        boostApy = new uint[](pids.length);
        tvl = new uint[](pids.length);
        tvlInUSD = new uint[](pids.length);
        tokenPrice = rewardPriceInUSD();
        for (uint256 i = 0; i < pids.length; i++) {
            apy[i] = apyOfPool(pids[i]);
            boostApy[i] = boostApyOfPool(pids[i], user);
            (allocPoint[i], tvl[i], tvlInUSD[i]) = tvlOfPool(pids[i]);
            totalTvl = totalTvl.add(tvl[i]);
            totalTvlInUSD = totalTvlInUSD.add(tvlInUSD[i]);
        }
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

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/math/SafeMath.sol";

library SafeDecimal {
    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint public constant UNIT = 10 ** uint(decimals);

    function unit() external pure returns (uint) {
        return UNIT;
    }

    function multiply(uint x, uint y) internal pure returns (uint) {
        return x.mul(y).div(UNIT);
    }

    // https://mpark.github.io/programming/2014/08/18/exponentiation-by-squaring/
    function power(uint x, uint n) internal pure returns (uint) {
        uint result = UNIT;
        while (n > 0) {
            if (n % 2 != 0) {
                result = multiply(result, x);
            }
            x = multiply(x, x);
            n /= 2;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IOnwardIncentivesController.sol";

interface IMasterChef {
    function owner() external view returns (address);

    function emo() external view returns (address);

    function startTime() external view returns (uint256);

    function emoPerSecond() external view returns (uint256);

    function poolLength() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function TOKENLESS_PRODUCTION() external view returns (uint256);

    function poolInfo(uint _pid) external view returns (
        address lpToken,
        uint256 workingSupply,
        bool boost,
        uint256 allocPoint,
        uint256 lastRewardTime,
        uint256 accEmoPerShare,
        address incentivesController);

    function userInfo(uint _pid, address _user) external view returns (
        uint256 amount,
        uint256 workingAmount,
        uint256 rewardDebt);

    // emo + bonus reward
    function pendingTokens(uint256 _pid, address _user) external view returns (address[] memory tokens, uint[] memory amounts);

    // Transfers ownership of the contract to a new account (`newOwner`)
    function transferOwnership(address newOwner) external;

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, uint256 _depositFeePercent, IERC20 _lpToken, IOnwardIncentivesController _incentivesController, bool _boost, bool _withUpdate) external;

    // Update the given pool's EMO allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint256 _depositFeePercent, IOnwardIncentivesController _incentivesController, bool _withUpdate) external;

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) external;

    // Stake EMO tokens to MasterChef
    function enterStaking(uint256 _amount) external;

    // Withdraw EMO tokens from STAKING.
    function leaveStaking(uint256 _amount) external;

    // Deposit LP tokens to MasterChef for EMO allocation.
    function depositFor(address _user, uint256 _pid, uint256 _amount) external;

    // Deposit LP tokens to MasterChef for EMO allocation.
    function deposit(uint _pid, uint _amount) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint _pid, uint _amount) external;

    function harvestAllRewards(address _user) external;

    function emergencyWithdraw(uint256 _pid) external;

    function setEmoPerSecond(uint256 _emoPerSecond) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IEvmoSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function pairFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setPairFee(uint32) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IEvmoSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setPairFee(address pair, uint32 pairFee) external;
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOnwardIncentivesController {
    function onReward(address user, uint256 newLpAmount) external;

    function pendingTokens(address user) external view returns (uint256 pending);

    function rewardToken() external view returns (IERC20);

    function getNextIncentivesController() external view returns (address);
}