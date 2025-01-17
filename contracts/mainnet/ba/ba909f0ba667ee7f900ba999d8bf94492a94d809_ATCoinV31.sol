/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// SPDX-License-Identifier: MIT
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


interface IUniswapV2Pair {
    
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {

    // events
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

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
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
        
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
        
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
        
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

interface IAtcToken is IERC20Metadata {

    function getTopPrice() external view returns(uint256);

    function isExcludedFromFees(address acc_) external view returns(bool);
    function isExcludedFromDividends(address acc_) external view returns(bool);

    function excludeFromFees(address acc_, bool bVal_) external;
    function excludeMultipleAccountsFromFees(address[] calldata accounts_, bool bVal_) external;
    function excludeFromDividends(address acc_, bool bVal_) external;

    function setAmmPair(address pair_, bool hasPair_) external;
    
    function getTos() external view returns(address);
    function setTos(address newAddr_) external;

    function burn(uint256 amount_) external;
    function burnFrom(address from_, uint256 amount_) external;

}

interface IAvatarTos {
    function donate2Eco(address acc_, uint256 amtATC_, uint256 amtTransferATC_, uint256 direction_) external;
    function pullup(address acc_) external;
    function setLP(address acc_) external; 
    function getAddr(uint256 type_) external view returns(address);
}

// Avatar Token Coin V31
contract ATCoinV31 is Ownable, IAtcToken {
    
    using SafeMath for uint256;

    //////////////////////////////////////////////////////////////////////////////////////

    uint256 constant MAX_UINT256 = ~uint256(0);
    
    // Token Unit
    uint256 constant TOKEN_UNIT = 10**18;

    uint256 public constant MAX_SUPPLY = 10**9 * TOKEN_UNIT;            // totalsuppy: 1 billion!

    // Direction
    uint256 constant DIRECTION_BUY = 0;
    uint256 constant DIRECTION_SELL = 1;
    uint256 constant DIRECTION_BOTH = 2;

    ////////////////////////////////////////////
    // Fees

    uint256 constant FEES_BUY = 15;
    uint256 constant FEES_SELL = 20;

    //////////////////////////////////////////////////////////////////////////////////////

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "Avatar Token Coin V31";
    string private _symbol = "ATC";   
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isDividendExempt;
    address private _fromAddr;
    address private _toAddr;

    IUniswapV2Router02 public immutable uniswapV2Router;            // Pancakeswap Router
    address public immutable uniswapV2Pair;                         // ATC/USDT Pair
    mapping(address => bool) public ammPairs;                       // stored all pair address in DEX for diff PublicChain
    IERC20 public usdtToken;                                        // USDT

    uint256 private _topPrice;                                      // top price
    IAvatarTos private _tos;

    address private _initPoolAddr;                                  // The address used to initialize the pool

    /////////////////////////////////////////

    constructor() {

        _initPoolAddr = 0xDE83aE709c2A37295C949c92D97D79F85506bFe5;
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        IUniswapV2Router02 uniswapV2Router_ = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        ////////////////////////////

        uniswapV2Router = uniswapV2Router_;
        address uniswapV2Pair_ = IUniswapV2Factory(uniswapV2Router_.factory()).createPair(address(this), address(usdtToken));
        uniswapV2Pair = uniswapV2Pair_;
        ammPairs[uniswapV2Pair_] = true;

        //////////////////////////////////////////////////

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_initPoolAddr] = true;

        _isDividendExempt[address(this)] = true;
        _isDividendExempt[address(0)] = true;
        _isDividendExempt[address(0xdead)] = true;
        _isDividendExempt[owner()] = true;
        _isDividendExempt[address(uniswapV2Pair_)] = true;
        _isDividendExempt[_initPoolAddr] = true;

        ///////////////////////////////////////////////////
        
        _topPrice = 96853761997954602;   // from Avatar Token CoinV3

        _mint(owner(), MAX_SUPPLY);
    }

    receive() external payable {}

    ////////////////////////////

    function getTopPrice() external view override returns(uint) {
        return _topPrice;
    }

    //////////////////////////////

    function isExcludedFromFees(address acc_) public override view returns(bool) {
        return _isExcludedFromFees[acc_];
    }

    function isExcludedFromDividends(address acc_) external override view returns(bool) {
        return _isDividendExempt[acc_];
    }

    function excludeFromFees(address acc_, bool bVal_) public override onlyOwner {
        if ( _isExcludedFromFees[acc_] != bVal_ ) {
            _isExcludedFromFees[acc_] = bVal_;
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts_, bool bVal_) external override onlyOwner {
        for(uint i = 0; i < accounts_.length; i++) {
            _isExcludedFromFees[accounts_[i]] = bVal_;
        }
    }

    function excludeFromDividends(address acc_, bool bVal_) external override onlyOwner {
        if ( _isDividendExempt[acc_] != bVal_ ) {
            _isDividendExempt[acc_] = bVal_;
        }
    }

    function setAmmPair(address pair_, bool hasPair_) public override onlyOwner{
        ammPairs[pair_] = hasPair_;
    }

    function getTos() public override view returns(address) {
        return address(_tos);
    }

    function setTos(address newAddr_) public override onlyOwner{
        _tos = IAvatarTos(newAddr_);
        _isExcludedFromFees[address(_tos)] = true;
        _isExcludedFromFees[_tos.getAddr(1001)] = true;
        _isExcludedFromFees[_tos.getAddr(1002)] = true;
        _isDividendExempt[address(_tos)] = true;
    }

    /////////////////////

    struct Param {
        uint tTransferAmount;               // receiving amount for to_
        uint direction;                     // 0 - buy; 1 - sell
        uint amtFees;                       // 15% for buy, or 20% for sell
        address user;
    }

    function _transfer(address from_, address to_, uint256 amount_) private {

        require( from_ != address(0), "ATT01" );
        require( to_ != address(0), "ATT02" );
        require( amount_ > 0, "ATT03" );
        
        bool bSwap_;
 
        // precheck swap
        {
            if ( ammPairs[from_] ) { // buy
                bSwap_ = true;
            }
            else if ( ammPairs[to_] ) { // sell
                if ( IERC20(to_).totalSupply() == 0 ) {
                    require(from_ == _initPoolAddr, "ATT04" );
                    bSwap_ = false;
                }
                else {
                    bSwap_ = true;
                }
            }
        }

        // setting dividends account
        if ( _fromAddr != address(0) && !_isDividendExempt[_fromAddr] ) { _tos.setLP(_fromAddr); _fromAddr = address(0); }
        if ( _toAddr != address(0) && !_isDividendExempt[_toAddr] ) { _tos.setLP(_toAddr); _toAddr = address(0); }
        if (bSwap_) {
            _fromAddr = from_;
            _toAddr = to_;
        }

        // transfer amount
        {
            Param memory param_;
            param_.tTransferAmount = amount_;
            if ( !_isExcludedFromFees[from_] && !_isExcludedFromFees[to_] ) {
                if ( bSwap_ ) {
                    _takeAllFee(from_, to_, amount_, param_);
                }
                else {
                    _tos.pullup(from_);
                }
            }
            _tokenTransfer(from_, to_, amount_, param_);
            // Update top price
            _updateTopPrice();
        }
    }

    function _take(address from_, address to_, uint256 tValue_) private {
        _tOwned[to_] = _tOwned[to_].add(tValue_);
        emit Transfer(from_, to_, tValue_);
    }

    //
    function _takeAllFee(address from_, address to_, uint256 amount_, Param memory param_) private {

        if ( ammPairs[from_] ) { // buy
            param_.amtFees = amount_.mul(FEES_BUY).div(100);
            param_.user = to_;
        }
        else { // sell
            param_.amtFees = amount_.mul(FEES_SELL).div(100);
            param_.user = from_;
            param_.direction = 1;
        }

        // transfer amount
        param_.tTransferAmount = amount_.sub(param_.amtFees);

        // Fees distribution
        if ( param_.amtFees > 0 ) {
            _take(from_, address(_tos), param_.amtFees);
            _tos.donate2Eco(param_.user, param_.amtFees, amount_, param_.direction);
        }
    }

    function _tokenTransfer(address from_, address to_, uint256 amount_, Param memory param_) private {
        _tOwned[from_] = _tOwned[from_].sub(amount_, "ATTT01");
        _tOwned[to_] = _tOwned[to_].add(param_.tTransferAmount);
        emit Transfer(from_, to_, param_.tTransferAmount);
    }

    ////////////////////////////////////////////////////////////////

    function _updateTopPrice() private {
        uint price_ = _getPrice();
        if ( _topPrice < price_ ) {
            _topPrice = price_;
        }
    }

    function _getPrice() private view returns(uint price_) {
        if ( IUniswapV2Pair(uniswapV2Pair).totalSupply() == 0 ) {
            return 0;
        }
        address tA_ = address(usdtToken);
        address tB_ = address(this);
        (address t0_,) = tA_ < tB_ ? (tA_, tB_) : (tB_, tA_);
        (uint rA_, uint rB_,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        (uint r0_, uint r1_) = t0_ == tA_ ? (rA_, rB_) : (rB_, rA_);
        if ( r1_ > 0 ) {
            price_ = r0_.mul(TOKEN_UNIT).div(r1_);
        }
    }

    ////////////////////////////////////////////////////////////////
    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address acc_) public view override returns (uint256) {
        return _tOwned[acc_];
    }

    function transfer(address to_, uint256 amount_) public override returns (bool) {
        _transfer(_msgSender(), to_, amount_);
        return true;
    }

    function allowance(address owner_, address spender_) public view override returns (uint256) {
        return _allowances[owner_][spender_];
    }

    function approve(address spender_, uint256 amount_) public override returns (bool) {
        _approve(_msgSender(), spender_, amount_);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount_) public override returns (bool) {
        _transfer(sender, recipient, amount_);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount_, "ATTF01"));
        return true;
    }

    function increaseAllowance(address spender_, uint256 addedValue_) public virtual returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].add(addedValue_));
        return true;
    }

    function decreaseAllowance(address spender_, uint256 subtractedValue_) public virtual returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].sub(subtractedValue_, "ATDA01"));
        return true;
    }

    function burn(uint amount_) public override {
        _burn(_msgSender(), amount_);
    }

    function burnFrom(address from_, uint amount_) public override {
        _approve(from_, _msgSender(), _allowances[from_][_msgSender()].sub(amount_, "ATBF01"));
        _burn(from_, amount_);
    }

    function _approve(address owner_, address spender_, uint256 amount_) private {
        require(owner_ != address(0), "ATAPV01");
        require(spender_ != address(0), "ATAPV02");
        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

   function _mint(address to_, uint amount_) private {
        _totalSupply = _totalSupply.add(amount_);
        _tOwned[to_] = _tOwned[to_].add(amount_);
        emit Transfer(address(0), to_, amount_);
    }

    function _burn(address from_, uint amount_) private {
        _tOwned[from_] = _tOwned[from_].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(from_, address(0), amount_);
    }
}