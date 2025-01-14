/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

//░██████╗██╗░░░██╗███╗░░██╗███╗░░░███╗██╗███╗░░██╗███████╗
//██╔════╝██║░░░██║████╗░██║████╗░████║██║████╗░██║██╔════╝
//╚█████╗░██║░░░██║██╔██╗██║██╔████╔██║██║██╔██╗██║█████╗░░
//░╚═══██╗██║░░░██║██║╚████║██║╚██╔╝██║██║██║╚████║██╔══╝░░
//██████╔╝╚██████╔╝██║░╚███║██║░╚═╝░██║██║██║░╚███║███████╗
//╚═════╝░░╚═════╝░╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝╚══════╝
//SOLAR MINING FOR A GREENER PLANET
//http://sunmine.io/
//https://t.me/Sunmine_offcial

// Sources flattened with hardhat v2.8.3 https://hardhat.org
// File @openzeppelin/contracts/utils/[email protected]
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


// File @openzeppelin/contracts/access/[email protected]
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


// File @openzeppelin/contracts/token/ERC20/[email protected]
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


// File @uniswap/v2-core/contracts/interfaces/[email protected]

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// File @uniswap/v2-core/contracts/interfaces/[email protected]

pragma solidity >=0.5.0;

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


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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


// File contracts/SUMI.sol

pragma solidity ^0.8.2;



// (Uni|Pancake)Swap libs are interchangeable




/*
    For lines that are marked ERC20 Token Standard, learn more at https://eips.ethereum.org/EIPS/eip-20. 
*/
contract ExtendedReflections is Context, IERC20, Ownable {

    // Keeps track of balances for address that are included in receiving reward.
    mapping (address => uint256) private _reflectionBalances;

    // Keeps track of balances for address that are excluded from receiving reward.
    mapping (address => uint256) private _tokenBalances;

    // Keeps track of which address are excluded from fee.
    mapping (address => bool) private _isExcludedFromFee;

    // Keeps track of which address are excluded from reward.
    mapping (address => bool) private _isExcludedFromReward;
    
    // An array of addresses that are excluded from reward.
    address[] private _excludedFromReward;

    // ERC20 Token Standard
    mapping (address => mapping (address => uint256)) private _allowances;

    // Liquidity pool provider router
    IUniswapV2Router02 internal _uniswapV2Router;

    // This Token and WETH pair contract address.
    address internal _uniswapV2Pair;

    // Where burnt tokens are sent to. This is an address that no one can have accesses to.
    address private constant burnAccount = 0x000000000000000000000000000000000000dEaD;

    address public marketingAddress;
    address public buyBackAddress;
    address public projectAddress;
    address public devAddress;
    
    /*
        Tax rate = (_taxXXX / 10**_tax_XXXDecimals) percent.
        For example: if _taxBurn is 1 and _taxBurnDecimals is 2.
        Tax rate = 0.01%

        If you want tax rate for burn to be 5% for example,
        set _taxBurn to 5 and _taxBurnDecimals to 0.
        5 * (10 ** 0) = 5
    */

    // Decimals of taxReward. Used for have tax less than 1%.
    uint32 private _taxRewardDecimals;

    // Decimals of taxLiquify. Used for have tax less than 1%.
    uint32 private _taxLiquifyDecimals;

    uint32 private _taxMarketingDecimals;
    uint32 private _taxBuyBackDecimals;
    uint32 private _taxProjectDecimals;
    uint32 private _taxDevDecimals;

    // This percent of a transaction will be redistribute to all holders.
    uint32[] public taxReward = [0, 0, 0];

    // This percent of a transaction will be added to the liquidity pool.
    uint32[] public taxLiquify = [0, 0, 0];

    uint32[] public taxMarketing = [0, 0, 0]; 
    uint32[] public taxBuyBack = [0, 0, 0]; 
    uint32[] public taxProject = [0, 0, 0]; 
    uint32[] public taxDev = [0, 0, 0];

    uint256 private taxMarketingPending;
    uint256 private taxBuyBackPending;
    uint256 private taxProjectPending;
    uint256 private taxDevPending;

    // ERC20 Token Standard
    uint32 private _decimals;

    // ERC20 Token Standard
    uint256 private _totalSupply;

    // Current supply:= total supply - burnt tokens
    uint256 private _currentSupply;

    // A number that helps distributing fees to all holders respectively.
    uint256 private _reflectionTotal;

    // Total amount of tokens rewarded / distributing. 
    uint256 private _totalRewarded;

    // Total amount of tokens burnt.
    uint256 private _totalBurnt;

    // Total amount of tokens locked in the LP (this token and WETH pair).
    uint256 private _totalTokensLockedInLiquidity;

    // Total amount of ETH locked in the LP (this token and WETH pair).
    uint256 private _totalETHLockedInLiquidity;

    // A threshold for swap and liquify.
    uint256 private _TokensminBeforeSwap;

    // ERC20 Token Standard
    string private _name;
    // ERC20 Token Standard
    string private _symbol;

    // Whether a previous call of SwapAndLiquify process is still in process.
    bool private _inSwapAndLiquify;

    bool private _autoSwapAndLiquifyEnabled;
    bool private _rewardEnabled;
    bool private _marketingRewardEnabled;
    bool private _buyBackRewardEnabled;
    bool private _projectRewardEnabled;
    bool private _devRewardEnabled;

    bool public tradingEnabled;
    
    // Prevent reentrancy.
    modifier lockTheSwap {
        require(!_inSwapAndLiquify, "Currently in swap and liquify.");
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    // Return values of _getValues function.
    struct ValuesFromAmount {
        // Amount of tokens for to transfer.
        uint256 amount;
        // Amount tokens charged to reward.
        uint256 tRewardFee;
        // Amount tokens charged to add to liquidity.
        uint256 tLiquifyFee;

        uint256 tMarketingFee;
        uint256 tBuyBackFee;
        uint256 tProjectFee;
        uint256 tDevFee;
        // Amount tokens after fees.
        uint256 tTransferAmount;

        // Reflection of amount.
        uint256 rAmount;
        // Reflection of reward fee.
        uint256 rRewardFee;
        // Reflection of liquify fee.
        uint256 rLiquifyFee;

        uint256 rMarketingFee;
        uint256 rBuyBackFee;
        uint256 rProjectFee;
        uint256 rDevFee;
        // Reflection of transfer amount.
        uint256 rTransferAmount;
    }

    /*
        Events
    */

    event Burn(address from, uint256 amount);
    event TokensminBeforeSwapUpdated(uint256 previous, uint256 current);
    event MarketingAddressUpdated(address previous, address current);
    event BuyBackAddressUpdated(address previous, address current);
    event ProjectAddressUpdated(address previous, address current);
    event DevAddressUpdated(address previous, address current);
    event AMMPairUpdated(address pair, bool value);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensAddedToLiquidity
    );
    event ExcludeAccountFromReward(address account);
    event IncludeAccountInReward(address account);
    event ExcludeAccountFromFee(address account);
    event IncludeAccountInFee(address account);
    event EnabledReward();
    event EnabledAutoSwapAndLiquify();
    event EnabledMarketingReward();
    event EnabledBuyBackReward();
    event EnabledProjectReward();
    event EnabledDevReward();
    event DisabledReward();
    event DisabledAutoSwapAndLiquify();
    event DisabledMarketingReward();
    event DisabledBuyBackReward();
    event DisabledProjectReward();
    event DisabledDevReward();
    event Airdrop(uint256 amount);
    
    constructor (string memory name_, string memory symbol_, uint32 decimals_, uint256 tokenSupply_) {
        // Sets the values for `name`, `symbol`, `totalSupply`, `currentSupply`, and `rTotal`.
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = tokenSupply_ * (10 ** decimals_);
        _currentSupply = _totalSupply;
        _reflectionTotal = (~uint256(0) - (~uint256(0) % _totalSupply));

        // Mint
        _reflectionBalances[_msgSender()] = _reflectionTotal;

        // exclude owner and this contract from fee.
        excludeAccountFromFee(owner());
        excludeAccountFromFee(address(this));

        // exclude owner, burnAccount, and this contract from receiving rewards.
        excludeAccountFromReward(owner());
        excludeAccountFromReward(burnAccount);
        excludeAccountFromReward(address(this));

        excludeAccountFromLimits(owner());
        excludeAccountFromLimits(address(this));
        excludeAccountFromLimits(burnAccount);
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // allow the contract to receive ETH
    receive() external payable {}

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
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint32) {
        return _decimals;
    }

    /**
     * @dev Returns the address of this token and WETH pair.
     */
    function uniswapV2Pair() public view virtual returns (address) {
        return _uniswapV2Pair;
    }

    /**
     * @dev Returns the current reward tax decimals.
     */
    function taxRewardDecimals() public view virtual returns (uint32) {
        return _taxRewardDecimals;
    }

    /**
     * @dev Returns the current liquify tax decimals.
     */
    function taxLiquifyDecimals() public view virtual returns (uint32) {
        return _taxLiquifyDecimals;
    }

    function taxMarketingDecimals() public view virtual returns (uint32) {
        return _taxMarketingDecimals;
    }

    function taxBuyBackDecimals() public view virtual returns (uint32) {
        return _taxBuyBackDecimals;
    }

    function taxProjectDecimals() public view virtual returns (uint32) {
        return _taxProjectDecimals;
    }

    function taxDevDecimals() public view virtual returns (uint32) {
        return _taxDevDecimals;
    }

    /**
     * @dev Returns true if reward feature is enabled.
     */
    function rewardEnabled() public view virtual returns (bool) {
        return _rewardEnabled;
    }

    /**
     * @dev Returns true if auto swap and liquify feature is enabled.
     */
    function autoSwapAndLiquifyEnabled() public view virtual returns (bool) {
        return _autoSwapAndLiquifyEnabled;
    }


    function marketingRewardEnabled() public view virtual returns (bool) {
        return _marketingRewardEnabled;
    }

    function buyBackRewardEnabled() public view virtual returns (bool) {
        return _buyBackRewardEnabled;
    }

    function projectRewardEnabled() public view virtual returns (bool) {
        return _projectRewardEnabled;
    }

    function devRewardEnabled() public view virtual returns (bool) {
        return _devRewardEnabled;
    }

    /**
     * @dev Returns the threshold before swap and liquify.
     */
    function TokensminBeforeSwap() external view virtual returns (uint256) {
        return _TokensminBeforeSwap;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns current supply of the token. 
     * (currentSupply := totalSupply - totalBurnt)
     */
    function currentSupply() external view virtual returns (uint256) {
        return _currentSupply;
    }

    /**
     * @dev Returns the total number of tokens burnt. 
     */
    function totalBurnt() external view virtual returns (uint256) {
        return _totalBurnt;
    }

    /**
     * @dev Returns the total number of tokens locked in the LP.
     */
    function totalTokensLockedInLiquidity() external view virtual returns (uint256) {
        return _totalTokensLockedInLiquidity;
    }

    /**
     * @dev Returns the total number of ETH locked in the LP.
     */
    function totalETHLockedInLiquidity() external view virtual returns (uint256) {
        return _totalETHLockedInLiquidity;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        if (_isExcludedFromReward[account]) return _tokenBalances[account];
        return tokenFromReflection(_reflectionBalances[account]);
    }

    /**
     * @dev Returns whether an account is excluded from reward. 
     */
    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromReward[account];
    }

    /**
     * @dev Returns whether an account is excluded from fee. 
     */
    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
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
        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Burn} event indicating the amount burnt.
     * Emits a {Transfer} event with `to` set to the burn address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != burnAccount, "ERC20: burn from the burn address");

        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        uint256 rAmount = _getRAmount(amount);

        // Transfer from account to the burnAccount
        if (_isExcludedFromReward[account]) {
            _tokenBalances[account] -= amount;
        } 
        _reflectionBalances[account] -= rAmount;

        _tokenBalances[burnAccount] += amount;
        _reflectionBalances[burnAccount] += rAmount;

        _currentSupply -= amount;

        _totalBurnt += amount;

        emit Burn(account, amount);
        emit Transfer(account, burnAccount, amount);
    }
    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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

    function enableTrading(bool enabled) external onlyOwner {
        tradingEnabled = enabled;
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
        require(balanceOf(sender) >= amount, "ERC20: transfer amount exceeds balance");

        if (sender != owner() && recipient != owner() && (AMMPairs[recipient] || AMMPairs[sender]))
            require(tradingEnabled, "Trading is not yet enabled");

        if (sender != owner() && recipient != owner())
            _beforeTokenTransfer(sender);

        bool buying = false;

        if (AMMPairs[sender]) {
            buying = true;
        }

        bool selling = false;

        if (AMMPairs[recipient]) {
            selling = true;
        }

        ValuesFromAmount memory values = _getValues(amount, !(!_isExcludedFromFee[sender] || (buying && !_isExcludedFromFee[recipient])), selling, buying);

        if (!isExcludedFromLimits[sender] && selling) {
            require(values.tTransferAmount <= maxTxAmount, "Anti-whale: Sell amount exceeds max limit");
        }
        if (!isExcludedFromLimits[recipient]) {
            require(balanceOf(recipient) + values.tTransferAmount <= maxWalletAmount, "Anti-whale: Wallet amount exceeds max limit");
        }

        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, values);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, values);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient, values);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, values);
        } else {
            _transferStandard(sender, recipient, values);
        }

        emit Transfer(sender, recipient, values.tTransferAmount);

        if (!_isExcludedFromFee[sender] || (buying && !_isExcludedFromFee[recipient])) {
            _afterTokenTransfer(values);
        }
    }

    function _beforeTokenTransfer(address sender) internal virtual {
        uint256 contractBalance = _tokenBalances[address(this)];

        // whether the current contract balances makes the threshold to swap.
        bool overTokensminBeforeSwap = contractBalance >= _TokensminBeforeSwap;

        if (overTokensminBeforeSwap && !AMMPairs[sender]) {
            if ((_marketingRewardEnabled || _buyBackRewardEnabled || _projectRewardEnabled || _devRewardEnabled) && !_inSwapAndLiquify) {
                uint256 totalToSend = taxMarketingPending + taxBuyBackPending + taxProjectPending + taxDevPending;
                swapTokensForEth(totalToSend);
                uint256 ethBalance = address(this).balance;
                bool success;

                if (taxMarketingPending > 0) {
                    uint256 toSend = ethBalance * taxMarketingPending / totalToSend;
                    (success,) = payable(marketingAddress).call{value: toSend}("");
                }
                if (taxBuyBackPending > 0) {
                    uint256 toSend = ethBalance * taxBuyBackPending / totalToSend;
                    (success,) = payable(buyBackAddress).call{value: toSend}("");
                }
                if (taxProjectPending > 0) {
                    uint256 toSend = ethBalance * taxProjectPending / totalToSend;
                    (success,) = payable(projectAddress).call{value: toSend}("");
                }
                if (taxDevPending > 0) {
                    uint256 toSend = ethBalance * taxDevPending / totalToSend;
                    (success,) = payable(devAddress).call{value: toSend}("");
                }

                taxMarketingPending = 0;
                taxBuyBackPending = 0;
                taxProjectPending = 0;
                taxDevPending = 0;
            }
            if (_autoSwapAndLiquifyEnabled && !_inSwapAndLiquify) {
                swapAndLiquify(_tokenBalances[address(this)]);
            }
        }
    }

    /**
      * @dev Performs all the functionalities that are enabled.
      */
    function _afterTokenTransfer(ValuesFromAmount memory values) internal virtual {
        // Reflect
        if (_rewardEnabled) {
            _distributeFee(values.rRewardFee, values.tRewardFee);
        }

        if (_marketingRewardEnabled) {
            _tokenBalances[address(this)] += values.tMarketingFee;
            _reflectionBalances[address(this)] += values.rMarketingFee;

            taxMarketingPending += values.tMarketingFee;
        }
        if (_buyBackRewardEnabled) {
            _tokenBalances[address(this)] += values.tBuyBackFee;
            _reflectionBalances[address(this)] += values.rBuyBackFee;

            taxBuyBackPending += values.tBuyBackFee;
        }
        if (_projectRewardEnabled) {
            _tokenBalances[address(this)] += values.tProjectFee;
            _reflectionBalances[address(this)] += values.rProjectFee;

            taxProjectPending += values.tProjectFee;
        }
        if (_devRewardEnabled) {
            _tokenBalances[address(this)] += values.tDevFee;
            _reflectionBalances[address(this)] += values.rDevFee;

            taxDevPending += values.tDevFee;
        }
        
        // Add to liquidity pool
        if (_autoSwapAndLiquifyEnabled) {
            // add liquidity fee to this contract.
            _tokenBalances[address(this)] += values.tLiquifyFee;
            _reflectionBalances[address(this)] += values.rLiquifyFee;
        }
    }

    /**
     * @dev Performs transfer between two accounts that are both included in receiving reward.
     */
    function _transferStandard(address sender, address recipient, ValuesFromAmount memory values) private {
        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }

    /**
     * @dev Performs transfer from an included account to an excluded account.
     * (included and excluded from receiving reward.)
     */
    function _transferToExcluded(address sender, address recipient, ValuesFromAmount memory values) private {
        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _tokenBalances[recipient] = _tokenBalances[recipient] + values.tTransferAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }

    /**
     * @dev Performs transfer from an excluded account to an included account.
     * (included and excluded from receiving reward.)
     */
    function _transferFromExcluded(address sender, address recipient, ValuesFromAmount memory values) private {
        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }

    /**
     * @dev Performs transfer between two accounts that are both excluded in receiving reward.
     */
    function _transferBothExcluded(address sender, address recipient, ValuesFromAmount memory values) private {
        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _tokenBalances[recipient] = _tokenBalances[recipient] + values.tTransferAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }
    
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
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
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }

    /**
      * @dev Excludes an account from receiving reward.
      *
      * Emits a {ExcludeAccountFromReward} event.
      *
      * Requirements:
      *
      * - `account` is included in receiving reward.
      */
    function excludeAccountFromReward(address account) public onlyOwner {
        require(!_isExcludedFromReward[account], "Account already excluded from reward");
        if(_reflectionBalances[account] > 0) {
            _tokenBalances[account] = tokenFromReflection(_reflectionBalances[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);
        
        emit ExcludeAccountFromReward(account);
    }

    /**
      * @dev Includes an account from receiving reward.
      *
      * Emits a {IncludeAccountInReward} event.
      *
      * Requirements:
      *
      * - `account` is excluded in receiving reward.
      */
    function includeAccountInReward(address account) public onlyOwner {
        require(_isExcludedFromReward[account], "Account is already included.");

        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_excludedFromReward[i] == account) {
                _excludedFromReward[i] = _excludedFromReward[_excludedFromReward.length - 1];
                _tokenBalances[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromReward.pop();
                break;
            }
        }

        emit IncludeAccountInReward(account);
    }

     /**
      * @dev Excludes an account from fee.
      *
      * Emits a {ExcludeAccountFromFee} event.
      *
      * Requirements:
      *
      * - `account` is included in fee.
      */
    function excludeAccountFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;

        emit ExcludeAccountFromFee(account);
    }

    /**
      * @dev Includes an account from fee.
      *
      * Emits a {IncludeAccountFromFee} event.
      *
      * Requirements:
      *
      * - `account` is excluded in fee.
      */
    function includeAccountInFee(address account) public onlyOwner {
        require(_isExcludedFromFee[account], "Account is already included.");

        _isExcludedFromFee[account] = false;
        
        emit IncludeAccountInFee(account);
    }

    /**
     * @dev Airdrop tokens to all holders that are included from reward. 
     *  Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function airdrop(uint256 amount) public {
        address sender = _msgSender();
        //require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
        require(balanceOf(sender) >= amount, "The caller must have balance >= amount.");
        ValuesFromAmount memory values = _getValues(amount, false, false, false);
        if (_isExcludedFromReward[sender]) {
            _tokenBalances[sender] -= values.amount;
        }
        _reflectionBalances[sender] -= values.rAmount;
        
        _reflectionTotal = _reflectionTotal - values.rAmount;
        _totalRewarded += amount;
        emit Airdrop(amount);
    }

    /**
     * @dev Returns the reflected amount of a token.
     *  Requirements:
     * - `amount` must be less than total supply.
     */
    function reflectionFromToken(uint256 amount, bool deductTransferFee, bool selling, bool buying) internal view returns(uint256) {
        require(amount <= _totalSupply, "Amount must be less than supply");
        ValuesFromAmount memory values = _getValues(amount, deductTransferFee, selling, buying);
        return values.rTransferAmount;
    }

    /**
     * @dev Used to figure out the balance after reflection.
     * Requirements:
     * - `rAmount` must be less than reflectTotal.
     */
    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {
        require(rAmount <= _reflectionTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    /**
     * @dev Swap half of contract's token balance for ETH,
     * and pair it up with the other half to add to the
     * liquidity pool.
     *
     * Emits {SwapAndLiquify} event indicating the amount of tokens swapped to eth,
     * the amount of ETH added to the LP, and the amount of tokens added to the LP.
     */
    function swapAndLiquify(uint256 contractBalance) private {
        // Split the contract balance into two halves.
        uint256 tokensToSwap = contractBalance / 2;
        uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

        // Contract's current ETH balance.
        uint256 initialBalance = address(this).balance;

        // Swap half of the tokens to ETH.
        swapTokensForEth(tokensToSwap);

        // Figure out the exact amount of tokens received from swapping.
        uint256 ethAddToLiquify = address(this).balance - initialBalance;

        // Add to the LP of this token and WETH pair (half ETH and half this token).
        addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

        _totalETHLockedInLiquidity += address(this).balance - initialBalance;
        _totalTokensLockedInLiquidity += contractBalance - balanceOf(address(this));

        emit SwapAndLiquify(tokensToSwap, ethAddToLiquify, tokensAddToLiquidity);
    }


    /**
     * @dev Swap `amount` tokens for ETH.
     *
     * Emits {Transfer} event. From this contract to the token and WETH Pair.
     */
    function swapTokensForEth(uint256 amount) private lockTheSwap {
        // Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), amount);


        // Swap tokens to ETH
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount, 
            0, 
            path, 
            address(this),  // this contract will receive the eth that were swapped from the token
            block.timestamp + 60 * 1000
            );
    }
    
    /**
     * @dev Add `ethAmount` of ETH and `tokenAmount` of tokens to the LP.
     * Depends on the current rate for the pair between this token and WETH,
     * `ethAmount` and `tokenAmount` might not match perfectly. 
     * Dust(leftover) ETH or token will be refunded to this contract
     * (usually very small quantity).
     *
     * Emits {Transfer} event. From this contract to the token and WETH Pai.
     */
    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private lockTheSwap {
        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        // Add the ETH and token to LP.
        // The LP tokens will be sent to burnAccount.
        // No one will have access to them, so the liquidity will be locked forever.
        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this), 
            tokenAmount, 
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            burnAccount, // the LP is sent to burnAccount. 
            block.timestamp + 60 * 1000
        );
    }

    /**
     * @dev Distribute the `tRewardFee` tokens to all holders that are included in receiving reward.
     * amount received is based on how many token one owns.  
     */
    function _distributeFee(uint256 rRewardFee, uint256 tRewardFee) private {
        // This would decrease rate, thus increase amount reward receive based on one's balance.
        _reflectionTotal = _reflectionTotal - rRewardFee;
        _totalRewarded += tRewardFee;
    }
    
    /**
     * @dev Returns fees and transfer amount in both tokens and reflections.
     * tXXXX stands for tokenXXXX
     * rXXXX stands for reflectionXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getValues(uint256 amount, bool deductTransferFee, bool selling, bool buying) private view returns (ValuesFromAmount memory) {
        ValuesFromAmount memory values;
        values.amount = amount;
        _getTValues(values, deductTransferFee, selling, buying);
        _getRValues(values, deductTransferFee);
        return values;
    }

    /**
     * @dev Adds fees and transfer amount in tokens to `values`.
     * tXXXX stands for tokenXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getTValues(ValuesFromAmount memory values, bool deductTransferFee, bool selling, bool buying) view private {
        
        if (deductTransferFee) {
            values.tTransferAmount = values.amount;
        } else {
            // calculate fee
            uint256 index;
            if (buying) index = 0;
            else if (selling) index = 1;
            else index = 2;

            values.tMarketingFee = _calculateTax(values.amount, taxMarketing[index], _taxMarketingDecimals);
            values.tBuyBackFee = _calculateTax(values.amount, taxBuyBack[index], _taxBuyBackDecimals);
            values.tProjectFee = _calculateTax(values.amount, taxProject[index], _taxProjectDecimals);
            values.tDevFee = _calculateTax(values.amount, taxDev[index], _taxDevDecimals);
            values.tRewardFee = _calculateTax(values.amount, taxReward[index], _taxRewardDecimals);
            values.tLiquifyFee = _calculateTax(values.amount, taxLiquify[index], _taxLiquifyDecimals);
            
            // amount after fee
            values.tTransferAmount = values.amount - values.tRewardFee - values.tLiquifyFee - values.tMarketingFee - values.tBuyBackFee - values.tProjectFee - values.tDevFee;
        }
        
    }

    /**
     * @dev Adds fees and transfer amount in reflection to `values`.
     * rXXXX stands for reflectionXXXX
     * More details can be found at comments for ValuesForAmount Struct.
     */
    function _getRValues(ValuesFromAmount memory values, bool deductTransferFee) view private {
        uint256 currentRate = _getRate();

        values.rAmount = values.amount * currentRate;

        if (deductTransferFee) {
            values.rTransferAmount = values.rAmount;
        } else {
            values.rAmount = values.amount * currentRate;

            values.rMarketingFee = values.tMarketingFee * currentRate;
            values.rBuyBackFee = values.tBuyBackFee * currentRate;
            values.rProjectFee = values.tProjectFee * currentRate;
            values.rDevFee = values.tDevFee * currentRate;
            values.rRewardFee = values.tRewardFee * currentRate;
            values.rLiquifyFee = values.tLiquifyFee * currentRate;

            values.rTransferAmount = values.rAmount - values.rRewardFee - values.rLiquifyFee - values.rMarketingFee - values.rBuyBackFee - values.rProjectFee - values.rDevFee;
        }
        
    }

    /**
     * @dev Returns `amount` in reflection.
     */
    function _getRAmount(uint256 amount) private view returns (uint256) {
        uint256 currentRate = _getRate();
        return amount * currentRate;
    }

    /**
     * @dev Returns the current reflection rate.
     */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    /**
     * @dev Returns the current reflection supply and token supply.
     */
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _reflectionTotal;
        uint256 tSupply = _totalSupply;      
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_reflectionBalances[_excludedFromReward[i]] > rSupply || _tokenBalances[_excludedFromReward[i]] > tSupply) return (_reflectionTotal, _totalSupply);
            rSupply = rSupply - _reflectionBalances[_excludedFromReward[i]];
            tSupply = tSupply - _tokenBalances[_excludedFromReward[i]];
        }
        if (rSupply < _reflectionTotal / _totalSupply) return (_reflectionTotal, _totalSupply);
        return (rSupply, tSupply);
    }

    /**
     * @dev Returns fee based on `amount` and `taxRate`
     */
    function _calculateTax(uint256 amount, uint32 tax, uint32 taxDecimals_) private pure returns (uint256) {
        return amount * tax / (10 ** taxDecimals_) / (10 ** 2);
    }

    /*
        Owner functions
    */

    /**
     * @dev Enables the reward feature.
     * Distribute transaction amount * `taxReward_` amount of tokens each transaction when enabled.
     *
     * Emits a {EnabledReward} event.
     *
     * Requirements:
     *
     * - reward feature mush be disabled.
     * - tax must be greater than 0.
     * - tax decimals + 2 must be less than token decimals. 
     * (because tax rate is in percentage)
    */
    function enableReward(uint32 taxRewardBuy_, uint32 taxRewardSell_, uint32 taxRewardTransfer_, uint32 taxRewardDecimals_) public onlyOwner {
        require(!_rewardEnabled, "Reward feature is already enabled.");
        require(taxRewardBuy_ > 0 || taxRewardSell_ > 0 || taxRewardTransfer_ > 0, "Tax rates must be greater than 0.");
        require(taxRewardDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _rewardEnabled = true;
        setTaxReward(taxRewardBuy_, taxRewardSell_, taxRewardTransfer_, taxRewardDecimals_);

        emit EnabledReward();
    }

    /**
      * @dev Enables the auto swap and liquify feature.
      * Swaps half of transaction amount * `taxLiquify_` amount of tokens 
      * to ETH and pair with the other half of tokens to the LP each transaction when enabled.
      *
      * Emits a {EnabledAutoSwapAndLiquify} event.
      *
      * Requirements:
      *
      * - auto swap and liquify feature mush be disabled.
      * - tax must be greater than 0.
      * - tax decimals + 2 must be less than token decimals. 
      * (because tax rate is in percentage)
      */
    function enableAutoSwapAndLiquify(uint32 taxLiquifyBuy_, uint32 taxLiquifySell_, uint32 taxLiquifyTransfer_, uint32 taxLiquifyDecimals_, address routerAddress, uint256 TokensminBeforeSwap_) public onlyOwner {
        require(!_autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already enabled.");
        require(taxLiquifyBuy_ > 0 || taxLiquifySell_ > 0 || taxLiquifyTransfer_ > 0, "Tax rates must be greater than 0.");
        require(taxLiquifyDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _TokensminBeforeSwap = TokensminBeforeSwap_;

        initSwap(routerAddress);

        // enable
        _autoSwapAndLiquifyEnabled = true;
        setTaxLiquify(taxLiquifyBuy_, taxLiquifySell_, taxLiquifyTransfer_, taxLiquifyDecimals_);
        
        emit EnabledAutoSwapAndLiquify();
    }

    function initSwap(address routerAddress) public onlyOwner {
        // init Router
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(routerAddress);

        _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());

        if (_uniswapV2Pair == address(0)) {
            _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        }
        
        _uniswapV2Router = uniswapV2Router;

        _setAMMPair(_uniswapV2Pair, true);

        excludeAccountFromLimits(address(uniswapV2Router));
        if (!_isExcludedFromReward[address(uniswapV2Router)])
            excludeAccountFromReward(address(uniswapV2Router));
        excludeAccountFromFee(address(uniswapV2Router));
    }

    function enableMarketingTax(uint32 taxMarketingBuy_, uint32 taxMarketingSell_, uint32 taxMarketingTransfer_, uint32 taxMarketingDecimals_, address marketingAddress_) public onlyOwner {
        require(!_marketingRewardEnabled, "Marketing tax feature is already enabled.");
        require(taxMarketingBuy_ > 0 || taxMarketingSell_ > 0 || taxMarketingTransfer_ > 0, "Tax rates must be greater than 0.");
        require(taxMarketingDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _marketingRewardEnabled = true;
        setMarketingTax(taxMarketingBuy_, taxMarketingSell_, taxMarketingTransfer_, taxMarketingDecimals_);
        setMarketingAddress(marketingAddress_);

        emit EnabledMarketingReward();
    }

    function enableBuyBackTax(uint32 taxBuyBackBuy_, uint32 taxBuyBackSell_, uint32 taxBuyBackTransfer_, uint32 taxBuyBackDecimals_, address buyBackAddress_) public onlyOwner {
        require(!_buyBackRewardEnabled, "BuyBack tax feature is already enabled.");
        require(taxBuyBackBuy_ > 0 || taxBuyBackSell_ > 0 || taxBuyBackTransfer_ > 0, "Tax rates must be greater than 0.");
        require(taxBuyBackDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _buyBackRewardEnabled = true;
        setBuyBackTax(taxBuyBackBuy_, taxBuyBackSell_, taxBuyBackTransfer_, taxBuyBackDecimals_);
        setBuyBackAddress(buyBackAddress_);

        emit EnabledBuyBackReward();
    }

    function enableProjectTax(uint32 taxProjectBuy_, uint32 taxProjectSell_, uint32 taxProjectTransfer_, uint32 taxProjectDecimals_, address projectAddress_) public onlyOwner {
        require(!_projectRewardEnabled, "Project tax feature is already enabled.");
        require(taxProjectBuy_ > 0 || taxProjectSell_ > 0 || taxProjectTransfer_ > 0, "Tax rates must be greater than 0.");
        require(taxProjectDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _projectRewardEnabled = true;
        setProjectTax(taxProjectBuy_, taxProjectSell_, taxProjectTransfer_, taxProjectDecimals_);
        setProjectAddress(projectAddress_);

        emit EnabledProjectReward();
    }

    function enableDevTax(uint32 taxDevBuy_, uint32 taxDevSell_, uint32 taxDevTransfer_, uint32 taxDevDecimals_, address devAddress_) public onlyOwner {
        require(!_devRewardEnabled, "Dev tax feature is already enabled.");
        require(taxDevBuy_ > 0 || taxDevSell_ > 0 || taxDevTransfer_ > 0, "Tax rates must be greater than 0.");
        require(taxDevDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _devRewardEnabled = true;
        setDevTax(taxDevBuy_, taxDevSell_, taxDevTransfer_, taxDevDecimals_);
        setDevAddress(devAddress_);

        emit EnabledDevReward();
    }


    /**
      * @dev Disables the reward feature.
      *
      * Emits a {DisabledReward} event.
      *
      * Requirements:
      *
      * - reward feature mush be enabled.
      */
    function disableReward() public onlyOwner {
        require(_rewardEnabled, "Reward feature is already disabled.");

        setTaxReward(0, 0, 0, 0);
        _rewardEnabled = false;
        
        emit DisabledReward();
    }

    /**
      * @dev Disables the auto swap and liquify feature.
      *
      * Emits a {DisabledAutoSwapAndLiquify} event.
      *
      * Requirements:
      *
      * - auto swap and liquify feature mush be enabled.
      */
    function disableAutoSwapAndLiquify() public onlyOwner {
        require(_autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already disabled.");

        setTaxLiquify(0, 0, 0, 0);
        _autoSwapAndLiquifyEnabled = false;
         
        emit DisabledAutoSwapAndLiquify();
    }


    function disableMarketingTax() public onlyOwner {
        require(_marketingRewardEnabled, "Marketing reward feature is already disabled.");

        setMarketingTax(0, 0, 0, 0);
        setMarketingAddress(address(0x0));
        _marketingRewardEnabled = false;
        
        emit DisabledMarketingReward();
    }

    function disableBuyBackTax() public onlyOwner {
        require(_buyBackRewardEnabled, "BuyBack reward feature is already disabled.");

        setBuyBackTax(0, 0, 0, 0);
        setBuyBackAddress(address(0x0));
        _buyBackRewardEnabled = false;
        
        emit DisabledBuyBackReward();
    }

    function disableProjectTax() public onlyOwner {
        require(_projectRewardEnabled, "Project reward feature is already disabled.");

        setProjectTax(0, 0, 0, 0);
        setProjectAddress(address(0x0));
        _projectRewardEnabled = false;
        
        emit DisabledProjectReward();
    }

    function disableDevTax() public onlyOwner {
        require(_devRewardEnabled, "Dev reward feature is already disabled.");

        setDevTax(0, 0, 0, 0);
        setDevAddress(address(0x0));
        _devRewardEnabled = false;
        
        emit DisabledDevReward();
    }

     /**
      * @dev Updates `_TokensminBeforeSwap`
      *
      * Emits a {TokensminBeforeSwap} event.
      *
      * Requirements:
      *
      * - `TokensminBeforeSwap_` must be less than _currentSupply.
      */
    function setTokensminBeforeSwap(uint256 TokensminBeforeSwap_) public onlyOwner {
        require(TokensminBeforeSwap_ < _currentSupply, "TokensminBeforeSwap must be lower than current supply.");

        uint256 previous = _TokensminBeforeSwap;
        _TokensminBeforeSwap = TokensminBeforeSwap_;

        emit TokensminBeforeSwapUpdated(previous, _TokensminBeforeSwap);
    }

    /**
      * @dev Updates taxReward
      *
      * Emits a {TaxRewardUpdate} event.
      *
      * Requirements:
      *
      * - reward feature must be enabled.
      * - total tax rate must be less than 100%.
      */
    function setTaxReward(uint32 taxRewardBuy_, uint32 taxRewardSell_, uint32 taxRewardTransfer_, uint32 taxRewardDecimals_) public onlyOwner {
        require(_rewardEnabled, "Reward feature must be enabled. Try the EnableReward function.");

        taxReward = [taxRewardBuy_, taxRewardSell_, taxRewardTransfer_];
        _taxRewardDecimals = taxRewardDecimals_;
    }

    /**
      * @dev Updates taxLiquify
      *
      * Emits a {TaxLiquifyUpdate} event.
      *
      * Requirements:
      *
      * - auto swap and liquify feature must be enabled.
      * - total tax rate must be less than 100%.
      */
    function setTaxLiquify(uint32 taxLiquifyBuy_, uint32 taxLiquifySell_, uint32 taxLiquifyTransfer_, uint32 taxLiquifyDecimals_) public onlyOwner {
        require(_autoSwapAndLiquifyEnabled, "Auto swap and liquify feature must be enabled. Try the EnableAutoSwapAndLiquify function.");

        taxLiquify = [taxLiquifyBuy_, taxLiquifySell_, taxLiquifyTransfer_];
        _taxLiquifyDecimals = taxLiquifyDecimals_;
    }

    function setMarketingTax(uint32 taxMarketingBuy_, uint32 taxMarketingSell_, uint32 taxMarketingTransfer_, uint32 taxMarketingDecimals_) public onlyOwner {
        require(_marketingRewardEnabled, "Marketing reward feature must be enabled. Try the enableMarketingTax function.");

        taxMarketing = [taxMarketingBuy_, taxMarketingSell_, taxMarketingTransfer_];
        _taxMarketingDecimals = taxMarketingDecimals_;
    }

    function setBuyBackTax(uint32 taxBuyBackBuy_, uint32 taxBuyBackSell_, uint32 taxBuyBackTransfer_, uint32 taxBuyBackDecimals_) public onlyOwner {
        require(_buyBackRewardEnabled, "BuyBack reward feature must be enabled. Try the enableBuyBackTax function.");

        taxBuyBack = [taxBuyBackBuy_, taxBuyBackSell_, taxBuyBackTransfer_];
        _taxBuyBackDecimals = taxBuyBackDecimals_;
    }

    function setProjectTax(uint32 taxProjectBuy_, uint32 taxProjectSell_, uint32 taxProjectTransfer_, uint32 taxProjectDecimals_) public onlyOwner {
        require(_projectRewardEnabled, "Project reward feature must be enabled. Try the enableProjectTax function.");

        taxProject = [taxProjectBuy_, taxProjectSell_, taxProjectTransfer_];
        _taxProjectDecimals = taxProjectDecimals_;
    }

    function setDevTax(uint32 taxDevBuy_, uint32 taxDevSell_, uint32 taxDevTransfer_, uint32 taxDevDecimals_) public onlyOwner {
        require(_devRewardEnabled, "Dev reward feature must be enabled. Try the enableDevTax function.");

        taxDev = [taxDevBuy_, taxDevSell_, taxDevTransfer_];
        _taxDevDecimals = taxDevDecimals_;
    }

    function setMarketingAddress(address marketingAddress_) public onlyOwner {
        address previous = marketingAddress;
        marketingAddress = marketingAddress_;

        if (!_isExcludedFromReward[marketingAddress])
            excludeAccountFromReward(marketingAddress);
        excludeAccountFromLimits(marketingAddress);
        excludeAccountFromFee(marketingAddress);

        emit MarketingAddressUpdated(previous, marketingAddress_);
    }

    function setBuyBackAddress(address buyBackAddress_) public onlyOwner {
        address previous = buyBackAddress;
        buyBackAddress = buyBackAddress_;

        if (!_isExcludedFromReward[buyBackAddress])
            excludeAccountFromReward(buyBackAddress);
        excludeAccountFromLimits(buyBackAddress);
        excludeAccountFromFee(buyBackAddress);

        emit BuyBackAddressUpdated(previous, buyBackAddress_);
    }

    function setProjectAddress(address projectAddress_) public onlyOwner {
        address previous = projectAddress;
        projectAddress = projectAddress_;

        if (!_isExcludedFromReward[projectAddress])
            excludeAccountFromReward(projectAddress);
        excludeAccountFromLimits(projectAddress);
        excludeAccountFromFee(projectAddress);

        emit ProjectAddressUpdated(previous, projectAddress_);
    }

    function setDevAddress(address devAddress_) public onlyOwner {
        address previous = devAddress;
        devAddress = devAddress_;

        if (!_isExcludedFromReward[devAddress])
            excludeAccountFromReward(devAddress);
        excludeAccountFromLimits(devAddress);
        excludeAccountFromFee(devAddress);

        emit DevAddressUpdated(previous, devAddress_);
    }

    // ##############
    // Features added
    // ##############

    uint256 public maxTxAmount;
    uint256 public maxWalletAmount;

    mapping (address => bool) public isExcludedFromLimits;

    mapping (address => bool) public AMMPairs;

    function setAMMPair(address pair, bool value) public onlyOwner {
        require(pair != _uniswapV2Pair, "The main pair cannot be removed from AMMPairs.");

        _setAMMPair(pair, value);
    }

    function _setAMMPair(address pair, bool value) private {
        AMMPairs[pair] = value;

        if(value) {
            if (!_isExcludedFromReward[pair])
                excludeAccountFromReward(pair);

            excludeAccountFromLimits(pair);
            excludeAccountFromFee(pair);
        }

        emit AMMPairUpdated(pair, value);
    }

    function excludeAccountFromLimits(address account) public onlyOwner {
        isExcludedFromLimits[account] = true;
    }

    function includeAccountInLimits(address account) public onlyOwner {
        isExcludedFromLimits[account] = false;
    }

    function changeMaxTxAmount(uint256 amount) public onlyOwner {
        maxTxAmount = amount;
    }

    function changeMaxWalletAmount(uint256 amount) public onlyOwner {
        maxWalletAmount = amount;
    }
}

contract SUMI is ExtendedReflections {

    uint256 private _tokenSupply = 800_000_000;

    uint32 private _taxRewardBuy = 0;
    uint32 private _taxRewardSell = 0;
    uint32 private _taxRewardTransfer = 1;

    uint32 private _taxLiquifyBuy = 4;
    uint32 private _taxLiquifySell = 3;
    uint32 private _taxLiquifyTransfer = 0;

    uint32 private _taxMarketingBuy = 3;
    uint32 private _taxMarketingSell = 4;
    uint32 private _taxMarketingTransfer = 0;

    uint32 private _taxBuyBackBuy = 0;
    uint32 private _taxBuyBackSell = 0;
    uint32 private _taxBuyBackTransfer = 1;

    uint32 private _taxProjectBuy = 0;
    uint32 private _taxProjectSell = 0;
    uint32 private _taxProjectTransfer = 1;

    uint32 private _taxDevBuy = 1;
    uint32 private _taxDevSell = 1;
    uint32 private _taxDevTransfer = 5;

    uint32 private _taxDecimals = 0;
    uint32 private _decimals = 9;

    uint256 private _maxTxAmount = 400_000 * (10 ** _decimals); // 0.1%
    uint256 private _maxWalletAmount = 8_000_000 * (10 ** _decimals); // 2%

    uint256 private _TokensminBeforeSwap = 80_000 * (10 ** _decimals); // 0.01%

    /**
     * @dev Choose proper router address according to your network:
     * Ethereum mainnet: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D (Uniswap)
     * BSC mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E (PancakeSwap)
     * BSC testnet: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
     */
    address private _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private _teamAddress = 0xB9351f280279963a9df424D58109604dE3227AA2;

    constructor () ExtendedReflections("SUNMINE", "SUMI", _decimals, _tokenSupply) {
        enableReward(_taxRewardBuy, _taxRewardSell, _taxRewardTransfer, _taxDecimals);
        enableMarketingTax(_taxMarketingBuy, _taxMarketingSell, _taxMarketingTransfer, _taxDecimals, _teamAddress);
        enableBuyBackTax(_taxBuyBackBuy, _taxBuyBackSell, _taxBuyBackTransfer, _taxDecimals, _teamAddress);
        enableProjectTax(_taxProjectBuy, _taxProjectSell, _taxProjectTransfer, _taxDecimals, _teamAddress);
        enableDevTax(_taxDevBuy, _taxDevSell, _taxDevTransfer, _taxDecimals, _teamAddress);
        enableAutoSwapAndLiquify(_taxLiquifyBuy, _taxLiquifySell, _taxLiquifyTransfer, _taxDecimals, _routerAddress, _TokensminBeforeSwap);
        changeMaxTxAmount(_maxTxAmount);
        changeMaxWalletAmount(_maxWalletAmount);
    }
}