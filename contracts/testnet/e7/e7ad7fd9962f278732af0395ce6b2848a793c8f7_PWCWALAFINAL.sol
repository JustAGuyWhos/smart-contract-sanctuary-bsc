/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface AntiSnipe {
    function checkUser(address from, address to, uint256 amt) external returns (bool);
    function setLaunch(address _initialLpPair, uint32 _liqAddBlock, uint64 _liqAddStamp, uint8 dec) external;
    function setLpPair(address pair, bool enabled) external;
    function setProtections(bool _as,  bool _ab) external;
    function removeBlacklisted(address account) external;
    function isBlacklisted(address account) external view returns (bool);
    function getTax() external returns (uint256);
}

interface Cashier {
    function setReflectionCriteria(uint256 _minPeriod, uint256 _minReflection) external;
    function tally(address shareholder, uint256 amount) external;
    function load() external payable;
    function cashout(uint256 gas) external;
    function giveMeWelfarePlease(address hobo) external;
    function getTotalDistributed() external view returns(uint256);
    function getShareholderInfo(address shareholder) external view returns(string memory, string memory, string memory, string memory);
    function getShareholderRealized(address shareholder) external view returns (uint256);
    function getPendingRewards(address shareholder) external view returns (uint256);
    function initialize() external;
}

contract PWCWALAFINAL is IERC20 {
    // Ownership moved to in-contract for customizability.
    address private _owner;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromDividends;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping (address => bool) private presaleAddresses;
    bool private allowedPresaleExclusion = true;
    mapping (address => bool) private _liquidityHolders;

    uint256 constant private startingSupply = 2_000_000_000;

    string constant private _name = "PWCWALAFINAL";
    string constant private _symbol = "PWCWALAFINAL";
    uint8 constant private _decimals = 9;

    uint256 constant private _tTotal = startingSupply * 10**_decimals;
    uint256 constant private MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    struct Fees {
        uint16 reflect;
        uint16 rewards;
        uint16 liquidity;
        uint16 marketing;
        uint16 burn;
        uint16 totalSwap;
    }

    struct Ratios {
        uint16 rewards;
        uint16 liquidity;
        uint16 marketing;
        uint16 burn;
        uint16 total;
    }

    Fees public _buyTaxes = Fees({
        reflect: 100,
        rewards: 0,
        liquidity: 0,
        marketing: 500,
        burn: 400,
        totalSwap: 900
        });

    Fees public _sellTaxes = Fees({
        reflect: 100,
        rewards: 0,
        liquidity: 0,
        marketing: 1500,
        burn: 400,
        totalSwap: 1900
        });

    Fees public _transferTaxes = Fees({
        reflect: 100,
        rewards: 0,
        liquidity: 0,
        marketing: 500,
        burn: 400,
        totalSwap: 900
        });

    Ratios public _ratios = Ratios({
        rewards: 0,
        liquidity: 0,
        marketing: 20,
        burn: 8,
        total: 28
        });

    uint256 constant public maxBuyTaxes = 2500;
    uint256 constant public maxSellTaxes = 2500;
    uint256 constant public maxTransferTaxes = 2500;
    uint256 constant masterTaxDivisor = 10000;

    IRouter02 public dexRouter;
    address public lpPair;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    struct TaxWallets {
        address payable marketing;
        address payable burn;
    }

    TaxWallets public _taxWallets = TaxWallets({
        marketing: payable(0xA15F98329dC03CE9730B7a954d905a91Ad0E1b29),
        burn: payable(0x000000000000000000000000000000000000dEaD)
        });
    
    bool inSwap;
    bool public contractSwapEnabled = false;
    uint256 public contractSwapTimer = 0 seconds;
    uint256 private lastSwap;
    uint256 public swapThreshold;
    uint256 public swapAmount;
    bool public processReflect = false;

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    AntiSnipe antiSnipe;

    Cashier reflector;
    uint256 reflectorGas = 300000;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountCurrency, uint256 amountTokens);
    
    modifier swapping {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }
    
    constructor () payable {
        _rOwned[msg.sender] = _rTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        // Set the owner.
        _owner = msg.sender;

        if (block.chainid == 56) {
            dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            dexRouter = IRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 43114) {
            dexRouter = IRouter02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
        } else if (block.chainid == 250) {
            dexRouter = IRouter02(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
        } else {
            revert();
        }

        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;

        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

        _isExcludedFromFees[_owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromDividends[_owner] = true;
        _isExcludedFromDividends[lpPair] = true;
        _isExcludedFromDividends[address(this)] = true;
        _isExcludedFromDividends[DEAD] = true;
        _liquidityHolders[_owner] = true;
    }

    receive() external payable {}

//===============================================================================================================
//===============================================================================================================
//===============================================================================================================
    // Ownable removed as a lib and added here to allow for custom transfers and renouncements.
    // This allows for removal of ownership privileges from the owner once renounced or transferred.
    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        _isExcludedFromFees[_owner] = false;
        _isExcludedFromDividends[_owner] = false;
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromDividends[newOwner] = true;
        
        if(_tOwned[_owner] > 0) {
            _transfer(_owner, newOwner, _tOwned[_owner]);
        }
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
        
    }

    function renounceOwnership() public virtual onlyOwner {
        _isExcludedFromFees[_owner] = false;
        _isExcludedFromDividends[_owner] = false;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
//===============================================================================================================
//===============================================================================================================
//===============================================================================================================

    function totalSupply() external pure override returns (uint256) { if (_tTotal == 0) { revert(); } return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function setNewRouter(address newRouter) public onlyOwner {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
        if (enabled == false) {
            lpPairs[pair] = false;
            antiSnipe.setLpPair(pair, false);
        } else {
            if (timeSinceLastPair != 0) {
                require(block.timestamp - timeSinceLastPair > 3 days, "3 Day cooldown.!");
            }
            lpPairs[pair] = true;
            timeSinceLastPair = block.timestamp;
            antiSnipe.setLpPair(pair, true);
        }
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function setExcludedFromReward(address account, bool enabled) public onlyOwner {
        if (enabled) {
            require(!_isExcluded[account], "Account is already excluded.");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            if(account != lpPair){
                _excluded.push(account);
            }
        } else if (!enabled) {
            require(_isExcluded[account], "Account is already included.");
            if (account == lpPair) {
                _rOwned[account] = _tOwned[account] * _getRate();
                _tOwned[account] = 0;
                _isExcluded[account] = false;
            } else if(_excluded.length == 1) {
                _rOwned[account] = _tOwned[account] * _getRate();
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
            } else {
                for (uint256 i = 0; i < _excluded.length; i++) {
                    if (_excluded[i] == account) {
                        _excluded[i] = _excluded[_excluded.length - 1];
                        _tOwned[account] = 0;
                        _rOwned[account] = _tOwned[account] * _getRate();
                        _isExcluded[account] = false;
                        _excluded.pop();
                        break;
                    }
                }
            }
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function setInitializers(address aInitializer, address cInitializer) external onlyOwner {
        require(!_hasLiqBeenAdded);
        require(cInitializer != address(this) && aInitializer != address(this) && cInitializer != aInitializer);
        reflector = Cashier(cInitializer);
        antiSnipe = AntiSnipe(aInitializer);
    }

    function removeBlacklisted(address account) external onlyOwner {
        antiSnipe.removeBlacklisted(account);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return antiSnipe.isBlacklisted(account);
    }

    function setProtectionSettings(bool _antiSnipe, bool _antiBlock) external onlyOwner {
        antiSnipe.setProtections(_antiSnipe, _antiBlock);
    }
    
    function setTaxesBuy(uint16 reflect, uint16 rewards, uint16 liquidity, uint16 marketing, uint16 burn) external onlyOwner {
        uint16 check = reflect + rewards + liquidity + marketing + burn;
        require(check <= maxBuyTaxes);
        _buyTaxes.reflect = reflect;
        _buyTaxes.rewards = rewards;
        _buyTaxes.liquidity = liquidity;
        _buyTaxes.marketing = marketing;
        _buyTaxes.burn = burn;
        _buyTaxes.totalSwap = check - reflect;
    }

    function setTaxesSell(uint16 reflect, uint16 rewards, uint16 liquidity, uint16 marketing, uint16 burn) external onlyOwner {
        uint16 check = reflect + rewards + liquidity + marketing + burn;
        require(check <= maxSellTaxes);
        _sellTaxes.reflect = reflect;
        _sellTaxes.rewards = rewards;
        _sellTaxes.liquidity = liquidity;
        _sellTaxes.marketing = marketing;
        _sellTaxes.burn = burn;
        _sellTaxes.totalSwap = check - reflect;
    }

    function setTaxesTransfer(uint16 reflect, uint16 rewards, uint16 liquidity, uint16 marketing, uint16 burn) external onlyOwner {
        uint16 check = reflect + rewards + liquidity + marketing + burn;
        require(check <= maxTransferTaxes);
        _transferTaxes.reflect = reflect;
        _transferTaxes.rewards = rewards;
        _transferTaxes.liquidity = liquidity;
        _transferTaxes.marketing = marketing;
        _transferTaxes.burn = burn;
        _transferTaxes.totalSwap = check - reflect;
    }

    function setRatios(uint16 rewards, uint16 liquidity, uint16 marketing, uint16 burn) external onlyOwner {
        _ratios.rewards = rewards;
        _ratios.liquidity = liquidity;
        _ratios.marketing = marketing;
        _ratios.burn = burn;
        _ratios.total = rewards + liquidity + marketing + burn;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function isExcludedFromDividends(address account) public view returns(bool) {
        return _isExcludedFromDividends[account];
    }

    function setDividendExcluded(address holder, bool enabled) public onlyOwner {
        require(holder != address(this) && holder != lpPair);
        _isExcludedFromDividends[holder] = enabled;
        if (enabled) {
            reflector.tally(holder, 0);
        } else {
            reflector.tally(holder, _tOwned[holder]);
        }
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor, uint256 time) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
        contractSwapTimer = time;
    }

    function setWallets(address payable marketing, address payable burn) external onlyOwner {
        _taxWallets.marketing = payable(marketing);
        _taxWallets.burn = payable(burn);
    }

    function setContractSwapEnabled(bool enabled) external onlyOwner {
        contractSwapEnabled = enabled;
        emit ContractSwapEnabledUpdated(enabled);
    }

    function setReflectionCriteria(uint256 _minPeriod, uint256 _minReflection, uint256 minReflectionMultiplier) external onlyOwner {
        _minReflection = _minReflection * 10**minReflectionMultiplier;
        reflector.setReflectionCriteria(_minPeriod, _minReflection);
    }

    function setReflectorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        reflectorGas = gas;
    }

    function giveMeWelfarePlease() external {
        reflector.giveMeWelfarePlease(msg.sender);
    }

    function getTotalReflected() external view returns (uint256) {
        return reflector.getTotalDistributed();
    }

    function getUserInfo(address shareholder) external view returns (string memory, string memory, string memory, string memory) {
        return reflector.getShareholderInfo(shareholder);
    }

    function getUserRealizedGains(address shareholder) external view returns (uint256) {
        return reflector.getShareholderRealized(shareholder);
    }

    function getUserUnpaidEarnings(address shareholder) external view returns (uint256) {
        return reflector.getPendingRewards(shareholder);
    }

    function excludePresaleAddresses(address router, address presale) external onlyOwner {
        require(allowedPresaleExclusion);
        if (router == presale) {
            _liquidityHolders[presale] = true;
            presaleAddresses[presale] = true;
            setExcludedFromFees(presale, true);
            setExcludedFromReward(presale, true);
            setDividendExcluded(presale, true);
        } else {
            _liquidityHolders[router] = true;
            _liquidityHolders[presale] = true;
            presaleAddresses[router] = true;
            presaleAddresses[presale] = true;
            setExcludedFromFees(router, true);
            setExcludedFromFees(presale, true);
            setExcludedFromReward(router, true);
            setExcludedFromReward(presale, true);
            setDividendExcluded(router, true);
            setDividendExcluded(presale, true);
        }
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != _owner
            && to != _owner
            && tx.origin != _owner
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (lpPairs[from]) {
            buy = true;
        } else if (lpPairs[to]) {
            sell = true;
        } else {
            other = true;
        }
        if(_hasLimits(from, to)) {
            if(!tradingEnabled) {
                revert("Trading not yet enabled!");
            }
        }

        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        if (sell) {
            if (!inSwap
                && contractSwapEnabled
                && !presaleAddresses[to]
                && !presaleAddresses[from]
            ) {
                if (lastSwap + contractSwapTimer < block.timestamp) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= swapThreshold) {
                        if(contractTokenBalance >= swapAmount) { contractTokenBalance = swapAmount; }
                        contractSwap(contractTokenBalance);
                        lastSwap = block.timestamp;
                    }
                }
            }      
        } 
        return _finalizeTransfer(from, to, amount, takeFee, buy, sell, other);
    }

    function contractSwap(uint256 contractTokenBalance) internal swapping {
        Ratios memory ratios = _ratios;
        if (ratios.total == 0) {
            return;
        }
        
        if(_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        uint256 toLiquify = ((contractTokenBalance * ratios.liquidity) / (ratios.total)) / 2;
        uint256 swapAmt = contractTokenBalance - toLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapAmt,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amtBalance = address(this).balance;
        uint256 liquidityBalance = (amtBalance * toLiquify) / swapAmt;

        if (toLiquify > 0) {
            dexRouter.addLiquidityETH{value: liquidityBalance}(
                address(this),
                toLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
            emit AutoLiquify(liquidityBalance, toLiquify);
        }

        amtBalance -= liquidityBalance;
        ratios.total -= ratios.liquidity;
        uint256 rewardsBalance = (amtBalance * ratios.rewards) / ratios.total;
        uint256 burnBalance = (amtBalance * ratios.burn) / ratios.total;
        uint256 marketingBalance = amtBalance - (rewardsBalance + burnBalance);

        if (ratios.rewards > 0) {
            try reflector.load{value: rewardsBalance}() {} catch {}
        }

        if(ratios.burn > 0){
            _taxWallets.burn.transfer(burnBalance);
        }

        if(ratios.marketing > 0){
            _taxWallets.marketing.transfer(marketingBalance);
        }
    }

    function processTokenReflect(address from, address to, uint256 rate) internal {
        uint256 owned;
        if (!_isExcludedFromDividends[from]) {
            owned = _rOwned[from] / rate;
            try reflector.tally(from, owned) {} catch {}
        }
        if (!_isExcludedFromDividends[to]) {
            owned = _rOwned[to] / rate;
            try reflector.tally(to, owned) {} catch {}
        }
        if (processReflect) {
            try reflector.cashout(reflectorGas) {} catch {}
        }
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            if(address(antiSnipe) == address(0)){
                antiSnipe = AntiSnipe(address(this));
            }
            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        if(address(antiSnipe) == address(0)){
            antiSnipe = AntiSnipe(address(this));
        }
        try antiSnipe.setLaunch(lpPair, uint32(block.number), uint64(block.timestamp), _decimals) {} catch {}
        try reflector.initialize() {} catch {}
        tradingEnabled = true;
        processReflect = true;
        allowedPresaleExclusion = false;
        swapThreshold = (balanceOf(lpPair) * 5) / 10000;
        swapAmount = (balanceOf(lpPair) * 1) / 1000;
    }


    function multiSendTokens(address[] memory accounts, uint256[] memory amounts) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i]*10**_decimals);
        }
    }

    function manualDeposit() external onlyOwner {
        try reflector.load{value: address(this).balance}() {} catch {}
    }

    struct ExtraValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tSwap;

        uint256 rTransferAmount;
        uint256 rAmount;
        uint256 rFee;

        uint256 currentRate;
    }

    function _finalizeTransfer(address from, address to, uint256 tAmount, bool takeFee, bool buy, bool sell, bool other) private returns (bool) {
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (!_hasLiqBeenAdded && _hasLimits(from, to)) {
                revert("Only owner can transfer at this time.");
            }
        }

        ExtraValues memory values = _getValues(from, to, tAmount, takeFee, buy, sell, other);

        _rOwned[from] -= values.rAmount;
        _rOwned[to] += values.rTransferAmount;

        if (_isExcluded[from]) {
            _tOwned[from] = _tOwned[from] - tAmount;
        }
        if (_isExcluded[to]) {
            _tOwned[to] = _tOwned[to] + values.tTransferAmount;
        }

        if (values.rFee > 0 || values.tFee > 0) {
            _rTotal -= values.rFee;
        }

        processTokenReflect(from, to, values.currentRate);

        emit Transfer(from, to, values.tTransferAmount);
        return true;
    }

    function _getValues(address from, address to, uint256 tAmount, bool takeFee, bool buy, bool sell, bool other) private returns (ExtraValues memory) {
        ExtraValues memory values;
        values.currentRate = _getRate();

        values.rAmount = tAmount * values.currentRate;

        if (_hasLimits(from, to)) {
            bool checked;
            try antiSnipe.checkUser(from, to, tAmount) returns (bool check) {
                checked = check;
            } catch {
                revert();
            }

            if(!checked) {
                revert();
            }
        }

        if(takeFee) {
            uint256 currentReflect;
            uint256 currentSwap = antiSnipe.getTax();
            uint256 divisor = masterTaxDivisor;

            if (currentSwap == 0) {
                if (sell) {
                    currentReflect = _sellTaxes.reflect;
                    currentSwap = _sellTaxes.totalSwap;
                } else if (buy) {
                    currentReflect = _buyTaxes.reflect;
                    currentSwap = _buyTaxes.totalSwap;
                } else {
                    currentReflect = _transferTaxes.reflect;
                    currentSwap = _transferTaxes.totalSwap;
                }
            }

            values.tFee = (tAmount * currentReflect) / divisor;
            values.tSwap = (tAmount * currentSwap) / divisor;
            values.tTransferAmount = tAmount - (values.tFee + values.tSwap);

            values.rFee = values.tFee * values.currentRate;
        } else {
            values.tFee = 0;
            values.tSwap = 0;
            values.tTransferAmount = tAmount;

            values.rFee = 0;
        }

        if (values.tSwap > 0) {
            _rOwned[address(this)] += values.tSwap * values.currentRate;
            if(_isExcluded[address(this)]) {
                _tOwned[address(this)] += values.tSwap;
            }
            emit Transfer(from, address(this), values.tSwap);
        }

        values.rTransferAmount = values.rAmount - (values.rFee + (values.tSwap * values.currentRate));
        return values;
    }

    function _getRate() internal view returns(uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if(_isExcluded[lpPair]) {
            if (_rOwned[lpPair] > rSupply || _tOwned[lpPair] > tSupply) return _rTotal / _tTotal;
            rSupply -= _rOwned[lpPair];
            tSupply -= _tOwned[lpPair];
        }
        if(_excluded.length > 0) {
            for (uint8 i = 0; i < _excluded.length; i++) {
                if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return _rTotal / _tTotal;
                rSupply = rSupply - _rOwned[_excluded[i]];
                tSupply = tSupply - _tOwned[_excluded[i]];
            }
        }
        if (rSupply < _rTotal / _tTotal) return _rTotal / _tTotal;
        return rSupply / tSupply;
    }
}