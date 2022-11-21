/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

    }

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
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
    function renounceOwnership() external virtual onlyOwner {
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

interface IUniswapV2Router02  {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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

contract PongToken is ERC20, Ownable {

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant deadAddress = address(0xdead);

    bool private swapping;

    address public marketingAddress;
    address public devAddress;
    address public TeamAddress1;
    address public TeamAddress2;
    address public TeamAddress3;
    address public TeamAddress4;
    address public CommunityEventsAddress;
    address public SpeacialEventsAddress;
    
    uint256 public maxWalletAmount;
    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    
    bool private gasLimitActive = true;
    uint256 private constant gasPriceLimit = 70 * 1 gwei; // do not allow over x gwei for launch
    
     // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;

    uint256 public buyTotalFees;
    uint256 public buyMarketingFee;
    uint256 public buyLiquidityFee;
    uint256 public buyTeam4Fee;
    uint256 public buyDevFee;
    uint256 public buyTeam1Fee;
    uint256 public buyTeamFee2;
    uint256 public buyTeamFee3;
    uint256 public buyCommunityEventsFee;
    uint256 public buySpeacialEventsFee;
    
    uint256 public sellTotalFees;
    uint256 public sellMarketingFee;
    uint256 public sellLiquidityFee;
    uint256 public sellTeam1Fee;
    uint256 public sellDevFee;
    uint256 public sellTeam2Fee;
    uint256 public sellTeam3Fee;
    uint256 public sellTeam4Fee;
    uint256 public sellCommunityEventsFee;
    uint256 public sellSpeacialEventsFee;
    
    uint256 public tokensForMarketing;
    uint256 public tokensForLiquidity;
    uint256 public tokensForTeam1;
    uint256 public tokensForDev;
    uint256 public tokensForTeam2;
    uint256 public tokensForTeam3;
    uint256 public tokensForTeam4;
    uint256 public tokensForSpeacialEvents;
    uint256 public tokensForCommunityEvents;
    
    bool public SpeacialEventsEnabled = false;

    // exclude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;
    mapping (address => bool) public _isExcludedMaxWalletAmount;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    
    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event marketingAddressUpdated(address indexed newWallet, address indexed oldWallet);
  
    event devAddressUpdated(address indexed newWallet, address indexed oldWallet);

    event TeamAddress4Updated(address indexed newWallet, address indexed oldWallet);

    event TeamAddress2Updated(address indexed newWallet, address indexed oldWallet);

    event TeamAddress3Updated(address indexed newWallet, address indexed oldWallet);

    event CommunityEventsAddressUpdated(address indexed newWallet, address indexed oldWallet);

    event TeamAddress1Updated(address indexed newWallet, address indexed oldWallet);

    event SpeacialEventsAddressUpdated(address indexed newWallet, address indexed oldWallet);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event SpeacialEvents(bool enabled);

    constructor() ERC20("Pong ", "Token") {
        address newOwner = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 totalSupply = 1 * 1e12 * 1e18;
        maxWalletAmount = totalSupply * 3 / 100; // 3.0% maxWallet
        maxTransactionAmount = totalSupply * 5 / 1000; // 0.5% maxTransactionAmountTxn
        swapTokensAtAmount = totalSupply * 5 / 10000; // 0.05% swap wallet

        buyMarketingFee = 2;
        buyLiquidityFee = 0;
        buyTeam4Fee = 0;
        buyDevFee = 0;
        buyTeam1Fee = 0;
        buyTeamFee2 = 0;
        buyTeamFee3 = 0;
        buyCommunityEventsFee = 0;
        buySpeacialEventsFee = 0;
        buyTotalFees = buyMarketingFee + buyLiquidityFee + buyTeam4Fee + buyDevFee + buyTeam1Fee + buyTeamFee2 + buyTeamFee3 + buyCommunityEventsFee + buySpeacialEventsFee;
        
        sellMarketingFee = 0;
        sellLiquidityFee = 2;
        sellTeam1Fee = 2;
        sellDevFee = 0;
        sellTeam2Fee = 2;
        sellTeam3Fee = 2;
        sellTeam4Fee = 2;
        sellCommunityEventsFee = 0;
        sellSpeacialEventsFee = 0;
        sellTotalFees = sellMarketingFee + sellLiquidityFee + sellTeam1Fee + sellDevFee + sellTeam2Fee + sellTeam3Fee + sellTeam4Fee + sellCommunityEventsFee + sellSpeacialEventsFee;
        
    	marketingAddress = address(0xE755b5E187C95d96Ab68e28B62F1737A125972d8); // set as marketing wallet
    	devAddress = address(0xE755b5E187C95d96Ab68e28B62F1737A125972d8); // set as dev wallet
        TeamAddress1 = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;
        TeamAddress2 = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;
        TeamAddress3 = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;
        TeamAddress4 = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;
        CommunityEventsAddress = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;
        SpeacialEventsAddress = 0xE755b5E187C95d96Ab68e28B62F1737A125972d8;

        // exclude from paying fees or having max transaction amount
        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        
        excludeFromMaxTransaction(newOwner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);

        excludeFromMaxWallet (newOwner, true);
        excludeFromMaxWallet(address(this), true);
        excludeFromMaxWallet(address(0xdead), true);
        
        /*
            _createInitialSupply is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _createInitialSupply(newOwner, totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {
  	}

    // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }
    
    // remove limits after token is stable
    function removeLimits() external onlyOwner returns (bool){
        limitsInEffect = false;
        gasLimitActive = false;
        transferDelayEnabled = false;
        return true;
    }
    
    // disable Transfer delay - cannot be reenabled
    function disableTransferDelay() external onlyOwner returns (bool){
        transferDelayEnabled = false;
        return true;
    }
    
    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amounts) external onlyOwner returns (bool){
        require(!tradingActive, "Trading is already active, cannot airdrop after launch.");
        require(airdropWallets.length == amounts.length, "arrays must be the same length");
        require(airdropWallets.length < 200, "Can only airdrop 200 wallets per txn due to gas limits"); // allows for airdrop + launch at the same exact time, reducing delays and reducing sniper input.
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 amount = amounts[i];
            _transfer(msg.sender, wallet, amount);
        }
        return true;
    }
    
     // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool){
  	    require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
  	    require(newAmount <= totalSupply() * 5 / 1000, "Swap amount cannot be higher than 0.5% total supply.");
  	    swapTokensAtAmount = newAmount;
  	    return true;
  	}
    
    function updateMaxAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 5 / 1000)/1e18, "Cannot set maxTransactionAmount lower than 0.5%");
        maxTransactionAmount = newNum * (10**18);
    }
    
    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 100)/1e18, "Cannot set maxWalletAmount lower than 1%");
        maxWalletAmount = newNum * (10**18);
    }
     function excludeFromMaxWallet(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxWalletAmount[updAds] = isEx;
   
     }
    // only use to disable contract sales if absolutely necessary (emergency use only)
    function updateSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }
    
    function updateBuyFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _team4Fee, uint256 _devFee, uint256 _communityeventsFee, uint256 _speacialeventsFee, uint256 _team1Fee, uint256 _team2Fee, uint256 _team3Fee) external onlyOwner {
        buyMarketingFee = _marketingFee;
        buyLiquidityFee = _liquidityFee;
        buyTeam4Fee = _team4Fee;
        buyDevFee = _devFee;
        buyCommunityEventsFee = _communityeventsFee;
        buySpeacialEventsFee = _speacialeventsFee;
        buyTeam1Fee = _team1Fee;
        buyTeamFee2 = _team2Fee;
        buyTeamFee3 = _team3Fee;
        buyTotalFees = buyMarketingFee + buyLiquidityFee + buyTeam4Fee + buyDevFee + buyCommunityEventsFee + buySpeacialEventsFee + buyTeam1Fee + buyTeamFee2 + buyTeamFee3;
        require(buyTotalFees <= 10, "Must keep fees at 10% or less");
    }
    
    function updateSellFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _team4Fee, uint256 _devFee, uint256 _communityeventsFee, uint256 _speacialeventsFee, uint256 _team1Fee, uint256 _team2Fee, uint256 _team3Fee) external onlyOwner {
        sellMarketingFee = _marketingFee;
        sellLiquidityFee = _liquidityFee;
        sellTeam1Fee = _team4Fee;
        sellDevFee = _devFee;
        sellCommunityEventsFee = _communityeventsFee;
        sellSpeacialEventsFee = _speacialeventsFee;
        sellTeam2Fee = _team1Fee;
        sellTeam3Fee = _team2Fee;
        sellTeam4Fee = _team3Fee;
        sellTotalFees = sellMarketingFee + sellLiquidityFee + sellTeam1Fee + sellDevFee + sellCommunityEventsFee + sellSpeacialEventsFee + sellTeam2Fee + sellTeam3Fee + sellTeam4Fee;
        require(sellTotalFees <= 10, "Must keep fees at 10% or less");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateMarketingWallet(address newMarketingWallet) external onlyOwner {
        emit marketingAddressUpdated(newMarketingWallet, marketingAddress);
        marketingAddress = newMarketingWallet;
    }
    
    function updateDevWallet(address newWallet) external onlyOwner {
        emit devAddressUpdated(newWallet, devAddress);
        devAddress = newWallet;
    }

    function updateSpeacialEventsWallet(address newWallet) external onlyOwner {
        emit SpeacialEventsAddressUpdated(newWallet, SpeacialEventsAddress);
        SpeacialEventsAddress = newWallet;
    }

    function updateTeamAddress1Wallet(address newWallet) external onlyOwner {
        emit TeamAddress4Updated(newWallet, TeamAddress4);
        TeamAddress4 = newWallet;
    }

    function updateCommunityEventsWallet(address newWallet) external onlyOwner {
        emit CommunityEventsAddressUpdated(newWallet, CommunityEventsAddress);
        CommunityEventsAddress = newWallet;
    }

    function updateTeam1Wallet(address newWallet) external onlyOwner {
        emit TeamAddress1Updated(newWallet, TeamAddress1);
        TeamAddress1 = newWallet;
    }

    function Team2Wallet(address newWallet) external onlyOwner {
        emit TeamAddress2Updated(newWallet, TeamAddress2);
        TeamAddress2 = newWallet;
    }

    function updateTeam3Wallet(address newWallet) external onlyOwner {
        emit TeamAddress3Updated(newWallet, TeamAddress3);
        TeamAddress3 = newWallet;
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
         if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }
        
        if(limitsInEffect){
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ){

                // only use to prevent sniper buys in the first blocks.
                if (gasLimitActive && automatedMarketMakerPairs[from]) {
                    require(tx.gasprice <= gasPriceLimit, "Gas price exceeds limit.");
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.  
                if (transferDelayEnabled){
                    if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)){
                        require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }
                 
                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                        require(amount <= maxTransactionAmount, "Buy transfer amount exceeds the maxTransactionAmount.");
                }               
                
               if (automatedMarketMakerPairs[from] && !_isExcludedMaxWalletAmount[to]) {
                uint256 heldTokens = balanceOf(to);
                require((heldTokens + amount) <= maxWalletAmount,"Over wallet limit.");
               }
                //when sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                        require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
                }
            }
        }
        
		uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( 
            canSwap &&
            swapEnabled &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;
            
            swapBack();

            swapping = false;
        }
        
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if(takeFee){
            // on sell
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees /100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensForTeam1 += fees * sellTeam1Fee / sellTotalFees;
                tokensForDev += fees * sellDevFee / sellTotalFees;
                tokensForMarketing += fees * sellMarketingFee / sellTotalFees;
                tokensForTeam2 += fees * sellTeam2Fee / sellTotalFees;
                tokensForTeam3 += fees * sellTeam3Fee / sellTotalFees;
                tokensForTeam4 += fees * sellTeam4Fee / sellTotalFees;
                tokensForSpeacialEvents += fees * sellCommunityEventsFee / sellTotalFees;
                tokensForCommunityEvents += fees * sellSpeacialEventsFee / sellTotalFees;
            }
            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensForTeam1 += fees * buyTeam4Fee / buyTotalFees;
                tokensForDev += fees * buyDevFee / buyTotalFees;
                tokensForMarketing += fees * buyMarketingFee / buyTotalFees;
                tokensForTeam2 += fees * buyTeam1Fee / buyTotalFees;
                tokensForTeam3 += fees * buyTeamFee2 / buyTotalFees;
                tokensForTeam4 += fees * buyTeamFee3 / buyTotalFees;
                tokensForSpeacialEvents += fees * buyCommunityEventsFee / buyTotalFees;
                tokensForCommunityEvents += fees * buySpeacialEventsFee / buyTotalFees;
            }
            
            if(fees > 0){    
                super._transfer(from, address(this), fees);
            }
        	
        	amount -= fees;
        }

        super._transfer(from, to, amount);
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
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            deadAddress,
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForTeam1 + tokensForDev + 
            tokensForCommunityEvents + tokensForSpeacialEvents + tokensForTeam2 + tokensForTeam3 + tokensForTeam4;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        bool success;
        
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;
        
        swapTokensForEth(contractBalance - liquidityTokens); 
        
        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;  
        uint256 ethForMarketing = ethBalance * tokensForMarketing / totalTokensToSwap;
        uint256 ethForDev = ethBalance * tokensForDev / totalTokensToSwap;
        uint256 ethForTeam4 = ethBalance * tokensForTeam1 / totalTokensToSwap;
        uint256 ethForSpeacialEvents = ethBalance * tokensForCommunityEvents / totalTokensToSwap;
        uint256 ethForCommunityEvents = ethBalance * tokensForSpeacialEvents / totalTokensToSwap;

        ethForLiquidity -= ethForMarketing + ethForDev + ethForTeam4 + ethForSpeacialEvents + ethForCommunityEvents;

        uint256 ethForTeam = ethBalance * tokensForTeam2 / totalTokensToSwap;
        (success,) = address(TeamAddress1).call{value: ethForTeam}("");
        ethForLiquidity -= ethForTeam;

        ethForTeam = ethBalance * tokensForTeam3 / totalTokensToSwap;
        (success,) = address(TeamAddress2).call{value: ethForTeam}("");
        ethForLiquidity -= ethForTeam;
        
        ethForTeam = ethBalance * tokensForTeam4 / totalTokensToSwap;
        (success,) = address(TeamAddress3).call{value: ethForTeam}("");
        ethForLiquidity -= ethForTeam;
            
        tokensForLiquidity = 0;
        tokensForMarketing = 0;
        tokensForTeam1 = 0;
        tokensForDev = 0;
        tokensForCommunityEvents = 0;
        tokensForSpeacialEvents = 0;
        tokensForTeam2 = 0;
        tokensForTeam3 = 0;
        tokensForTeam4 = 0;
        
        (success,) = address(devAddress).call{value: ethForDev}("");
        (success,) = address(TeamAddress4).call{value: ethForTeam4}("");
        (success,) = address(SpeacialEventsAddress).call{value: ethForSpeacialEvents}("");
        (success,) = address(CommunityEventsAddress).call{value: ethForCommunityEvents}("");
        
        if(liquidityTokens > 0 && ethForLiquidity > 0){
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success,) = address(marketingAddress).call{value: address(this).balance}("");
    }

    function SpeacialEventsToggle(bool enable) external onlyOwner {
        
        require(SpeacialEventsEnabled != enable, "Already set to this setting.");
        
        // uses hardcoded values to set Speacial Events on or off
        
        if(enable){
            SpeacialEventsEnabled = true;
            buyMarketingFee = 2;
            buyLiquidityFee = 0;
            buyTeam4Fee = 0;
            buyDevFee = 0;
            buyTeam1Fee = 0;
            buyTeamFee2 = 0;
            buyTeamFee3 = 0;
            buyCommunityEventsFee = 2;
            buySpeacialEventsFee = 2;
            buyTotalFees = buyMarketingFee + buyLiquidityFee + buyTeam4Fee + buyDevFee + buyTeam1Fee + buyTeamFee2 + buyTeamFee3 + buyCommunityEventsFee + buySpeacialEventsFee; 
        }
        // set back to normal taxes
        else if(!enable){
            SpeacialEventsEnabled = false;
            buyMarketingFee = 2;
            buyLiquidityFee = 0;
            buyTeam4Fee = 0;
            buyDevFee = 0;
            buyTeam1Fee = 0;
            buyTeamFee2 = 0;
            buyTeamFee3 = 0;
            buyCommunityEventsFee = 0;
            buySpeacialEventsFee = 0;
            buyTotalFees = buyMarketingFee + buyLiquidityFee + buyTeam4Fee + buyDevFee + buyTeam1Fee + buyTeamFee2 + buyTeamFee3 + buyCommunityEventsFee + buySpeacialEventsFee;     
        }
        
        emit SpeacialEvents(enable);
    }
}