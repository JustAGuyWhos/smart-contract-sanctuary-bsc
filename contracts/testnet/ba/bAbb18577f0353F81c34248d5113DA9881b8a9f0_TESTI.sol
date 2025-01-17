/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

// Just the basic IERC20 interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// We use the Auth contract mainly to have two devs able to interacet with the contract
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract TESTI is IERC20, Auth {
   
    // Constant addresses 
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    IDEXRouter public constant router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    // Immutable vars
    address public immutable pair; // After we set the pair we don't have to change it again

    // Token info is constant
    string constant _name = "TESTOi";
    string constant _symbol = "TST";
    uint8 constant _decimals = 18;

    // Total supply is 1 billion
    uint256 _totalSupply = 1 * (10**9) * (10 ** _decimals);

    // The tax divisor is also constant (and hence immutable)
    uint256 constant taxDivisor = 1_000;
    
    // 10 / 1000 = 0.01 = 1%
    uint256 public _maxTxAmount = _totalSupply * 10 / taxDivisor; 
    uint256 public _maxWalletToken =  _totalSupply * 10 / taxDivisor; 

    // Keep track of wallet balances and approvals (allowance)
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Mapping to keep track of what wallets/contracts are exempt
    // from fees
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    // Also, to keep it organized, a seperate mapping to exclude the presale
    // and locker
    mapping (address => bool) presaleOrlock;

    //fees are mulitplied by 10 to allow decimals, and therefore dividied by 1000 (see takefee)
    uint256 marketingBuyFee = 60;
    uint256 liquidityBuyFee = 10;
    uint256 teamBuyFee = 10;
    uint256 public totalBuyFee = marketingBuyFee + liquidityBuyFee + teamBuyFee;

    uint256 marketingSellFee = 60;
    uint256 liquiditySellFee = 10;
    uint256 teamSellFee = 10;
    uint256 public totalSellFee = marketingSellFee + liquiditySellFee + teamSellFee;

    // In case anything would go wrong with fees we can just disable them
    bool feesEnabled = true;

    // Whether tx limits should apply or not 
    bool limits = true;

    // To keep track of the tokens collected to swap
    uint256 private tokensForMarketing;
    uint256 private tokensForLiquidity;
    uint256 private tokensForDev;

    // Wallets used to send the fees to
    address public liquidityWallet;
    address public marketingWallet;
    address public teamWallet;

    //one time trade lock
    bool tradeBlock = true;
    bool lockUsed = false;

    //contract cant be tricked into spam selling exploit
    uint256 lastSellTime;
    
    // When to swap contract tokens, and how many to swap
    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 100_000;
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

    // This will just check if the transferf is called from within 
    // the token -> ETH swap when processing the fees (and adding LP)
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () Auth(msg.sender) {
        // Create the lp pair
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));

        // Exclude the contract
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[address(this)] = true;

        // Exclude the owner
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        
        // Exclude the pair
        isTxLimitExempt[address(pair)] = true; 

        // Exclude the router 
        isTxLimitExempt[address(router)] = true;

        // Set fee receivers
        liquidityWallet = msg.sender;
        marketingWallet = msg.sender;
        teamWallet = msg.sender;

        // Approve this contract to interact with the 
        // router and pair contract (for swapping)
        _approve(address(this), address(router), _totalSupply);
        _approve(msg.sender, address(pair),_totalSupply);

        // Mint the tokens
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function getPair() external view returns (address){return pair;}

    // Internal approve 
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Regular approve the contract
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    // We actually only need to exempt any locks or presale addresses
    // we could use a feeexempt or authorize it, but this is a bit cleaner
    function excludeLockorPresale(address add) external authorized {
        // Exclude from fees
        isFeeExempt[add] = true;
        isTxLimitExempt[add] = true;
        // We want to allow transfers to locks and from the presale
        // address when trading is not yet enabled. 
        presaleOrlock[add] = true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 senderBalance = _balances[sender];
        // Check if the sender has sufficient balance
        require(senderBalance >= amount, "Insufficient Balance");
        // Update balances
        _balances[sender] = _balances[sender] - amount; 
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Set the buy fees, this can not exceed 15%, 150 / 1000 = 0.15 = 15%
    function setBuyFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _teamFee) external authorized{
        require(_marketingFee + _liquidityFee + _teamFee <= 150); // max 15%
        marketingBuyFee = _marketingFee;
        liquidityBuyFee = _liquidityFee;
        teamBuyFee = _teamFee;
        totalBuyFee = _marketingFee + _liquidityFee + _teamFee;
    }
    
    // Set the sell fees, this can not exceed 15%, 150 / 1000 = 0.15 = 15%
    function setSellFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _teamFee) external authorized{
        require(_marketingFee + _liquidityFee + _teamFee <= 150); // max 15%
        marketingSellFee = _marketingFee;
        liquiditySellFee = _liquidityFee;
        teamSellFee = _teamFee;
        totalSellFee = _marketingFee + _liquidityFee + _teamFee;
    }

    // To change the tax receiving wallets
    function setWallets(address _marketingWallet, address _liquidityWallet, address _teamWallet) external authorized {
        marketingWallet = _marketingWallet;
        liquidityWallet = _liquidityWallet;
        teamWallet = _teamWallet;
    }

    // To limit the number of tokens a wallet can buy, especially relevant at launch
    function setMaxWallet(uint256 percent) external authorized {
        require(percent >= 10); //should be at least 1% of the total supply (note divisor is 1000)
        _maxWalletToken = ( _totalSupply * percent ) / taxDivisor;
    }

    // To limit the number of tokens per transactions
    function setTxLimit(uint256 percent) external authorized {
        require(percent >= 10); //should be at least 1% of the total supply (note divisor is 1000)
        _maxTxAmount = ( _totalSupply * percent ) / taxDivisor;
    }
    
    function checkLimits(address sender,address recipient, uint256 amount) internal view {
        // If both sender and recipient are excluded we don't have to limit 
        if (isTxLimitExempt[sender] && isTxLimitExempt[recipient]){return;}

        // In any other case we will check whether this is a buy or sell
        // to determine the tx limit
        
        // buy
        if (sender == pair && isTxLimitExempt[recipient]) {  
            require(amount <= _maxTxAmount, "Max tx limit");

        // sell
        } else if(recipient == pair && isTxLimitExempt[sender] ) { 
            require(amount <= _maxTxAmount, "Max tx limit");
        }

        // Also check max wallet 
        if (!isTxLimitExempt[recipient]) {
            require(amount + balanceOf(recipient) <= _maxWalletToken, "Max wallet");
        }

    }

    // We will lift the transaction limits just after launch
    function liftLimits() external authorized {
        limits = false;
    }

    // This would make the token fee-less, this cannot be reverted
    // and should only be used if something in fee taking goes wrong
    function liftFees() external authorized {
        feesEnabled = false;
    }

    // Enable trading - this can only be called once (by just the owner)
    function startTrading() external onlyOwner {
        require(lockUsed == false);
        tradeBlock = false;
        lockUsed = true;
    }
    
    // When and if to swap the tokens in the contract
    function setTokenSwapSettings(bool _enabled, uint256 _threshold) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _threshold * (10 ** _decimals); 
    }
    
    // Check if the contract should swap tokens
    function shouldTokenSwap(address recipient) internal view returns (bool) {
        return recipient == pair
        && lastSellTime + 1 < block.timestamp // block contract spam sells
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function takeFee(address from, address to, uint256 amount) internal returns (uint256) {

        // If the sender or receiver is exempt from fees, skip fees
        if (isFeeExempt[from] || isFeeExempt[to]) {
            return amount;
        }

        // This does not charge for wallet-wallet transfers
        uint256 fees;

        // on sell
        if (to == pair && totalSellFee > 0) {
            fees = amount * totalSellFee / taxDivisor;
            tokensForLiquidity += (fees * liquiditySellFee) / totalSellFee;
            tokensForDev += (fees * teamSellFee) / totalSellFee;
            tokensForMarketing += (fees * marketingSellFee) / totalSellFee;
        }

        // on buy
        else if (from == pair && totalBuyFee > 0) {
            fees = (amount * totalBuyFee) / taxDivisor;
            tokensForLiquidity += (fees * liquidityBuyFee) / totalBuyFee ;
            tokensForDev += (fees * teamBuyFee) / totalBuyFee;
            tokensForMarketing += (fees * marketingBuyFee) / totalBuyFee;
        }

        // If we collected fees, send them to the contract
        if (fees > 0) {
            _basicTransfer(from, address(this), fees);
            emit Transfer(from, address(this), fees);
        }

        // Return the taxed amount
        return amount -= fees;
    }

    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // Add liquidity from the contract. Now the LP tokens get sent to the lP
        // wallet, but we could also change the LP receiver to the burn address
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            liquidityWallet,
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForDev;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {return;}
  
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * tokensForLiquidity) / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance - liquidityTokens;

        uint256 initialETHBalance = address(this).balance;

        // Swap the tokens for ETH
        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - initialETHBalance;
        uint256 ethForMarketing = (ethBalance * tokensForMarketing) / totalTokensToSwap;
        uint256 ethForDev = (ethBalance * tokensForDev) / totalTokensToSwap;
        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForDev;

        // Reset token fee counts
        tokensForLiquidity = 0;
        tokensForMarketing = 0;
        tokensForDev = 0;

        // Send Dev fees
        (success, ) = address(teamWallet).call{value: ethForDev}("");

        // Add liquidty
        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity, tokensForLiquidity);
        }

        // Whatever remains (this should be ~ethForMarketing) send to the marketing wallet
        (success, ) = address(marketingWallet).call{value: address(this).balance}("");

        lastSellTime = block.timestamp;
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (owner == msg.sender){
            return _basicTransfer(msg.sender, recipient, amount);
        }
        else {
            return _transferFrom(msg.sender, recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_allowances[sender][msg.sender] != _totalSupply){
            // Get the current allowance
            uint256 curAllowance =  _allowances[sender][msg.sender];
            require(curAllowance >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // These transfers are always feeless and limitless
        // We could also use the fee and max tx check for presale or lock, but this is a bit cleaner
        if ( authorizations[sender] || authorizations[recipient] || presaleOrlock[sender] || inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        // In any other case, check if trading is open already
        require(tradeBlock == false,"Trading not open yet");
            
        // If limits are enabled we check the max wallet and max tx.
        if (limits){checkLimits(sender, recipient, amount);}

        // Check how much fees are accumulated in the contract, if > threshold, swap
        if(shouldTokenSwap(recipient)){ swapBack();}

        // Charge transaction fees (only swaps) when enabled
        if(feesEnabled){
             amount = (recipient == pair || sender == pair) ? takeFee(sender, recipient, amount) : amount;
        } 

        // Send the remaining tokens, after fee
        _basicTransfer(sender, recipient, amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // In case anyone would send ETH to the contract directly
    // or when, for some reason, autoswap would fail. We 
    // send the contact ETH to the marketing wallet
    function clearStuckWETH(uint256 perc) external authorized {
        uint256 amountWETH = address(this).balance;
        payable(marketingWallet).transfer(amountWETH * perc / 100);
    }

}