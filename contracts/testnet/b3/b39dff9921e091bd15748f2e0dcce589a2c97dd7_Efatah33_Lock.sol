/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b; 
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    } 
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 *  dex interface
 */
 
interface IDexRouter {
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
    ) external payable  returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function pairFor(address tokenA, address tokenB) external view returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface InterfaceLP {
    function sync() external;
}
 
contract Efatah33_Lock is IERC20 {
    using SafeMath for uint256; 
   
    string private _name = "EFATAH33_US";
    string private _symbol =  "EFALOCK_us";
    uint8 private _decimals = 8;  
    uint256 public _totalSupply = 7777700000000; // 77,777 * 10**8;   
    uint256 public _pcent100 = 100; //100%

    address DEAD = 0x000000000000000000000000000000000000dEaD; 
    address public marketingReceiver = 0x167395322efA5A9938BA84aC1aA092dE86b7087e; 
    address public liquidityReceiver = 0x7B797C2a37d70C36c2925708961052F0cE59bC08;
    address public projectReceiver = 0x2355205C9aE00672fF3243C91c44dA128324Df80; 
    address public epifReceiver = 0xD4Cd573eC16D21e3790f23D3ed399ED4b6057F84; 
    address public devReceiver = 0x73d4a3972f305F2F8b498aD29bd433eBcadd0CC2; 
    address public teamReceiver = 0x1bc4DDB70Ea30e90F633822fE569d0A4B24B64F5;  
     
    uint256 public liquidityFee = 1;
    uint256 public devFee = 2;
    uint256 public teamFee = 1;
    uint256 public epifFee = 6;

    uint256 public buyMarketingFee = 3; 
    uint256 public buyProjectFee = 1;  
    uint256 public buyTotalFee =
        buyMarketingFee.add(liquidityFee).add(buyProjectFee).add(devFee).add(teamFee).add(epifFee);

    uint256 public sellMarketingFee = 4; 
    uint256 public sellProjectFee = 2;  
    uint256 public sellTotalFee =
        sellMarketingFee.add(liquidityFee).add(sellProjectFee).add(devFee).add(teamFee).add(epifFee);
 
    uint256 public maxDailyWalletTransferPercent = 100;// 100%
    uint256 public maxTransferTimeSecs = 86400; //24hrs  
    uint256 public maxSellTransactionAmount = _totalSupply;
    
    struct userTxn {  uint256 txnTimeSecs; uint256 txnAmount; }
    mapping(address => userTxn) public _accountDailyTxn;
      
    mapping(address => bool) _isAccountExempt;
    mapping(address => uint256) private _balances; 
    mapping(address => bool) public _blacklistBot; 
    mapping (address => mapping (address => uint256)) private _allowances;

 
    mapping (address => uint256) _lastShareClaims; 
    uint256 public _totalShareTokens; 
    uint256 public _countShares; 

    modifier validRecipient(address to) {
        require(to != address(0x0)); _;
    }

    address private _owner;
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }
 
    event eventTransferFees(address addr, uint256 amount, uint256 _pcent100, uint256 fee_amount, uint is_buy);  
     
    constructor(address ownerWallet) {
        _owner = ownerWallet; 
        //TODO: revove or reformat on production
        maxDailyWalletTransferPercent = 100;  //TODO: change 1% to 100%
        _swapThresholdAmt = 2;
        //>>>>>>>>>>>
         
        _isAccountExempt[_owner] = true;
        _isAccountExempt[address(this)] = true; 
        _isAccountExempt[DEAD] = true; 
        _isAccountExempt[marketingReceiver] = true; 
        _isAccountExempt[liquidityReceiver] = true; 
        _isAccountExempt[projectReceiver] = true; 
        _isAccountExempt[epifReceiver] = true; 
        _isAccountExempt[devReceiver] = true; 
        _isAccountExempt[teamReceiver] = true; 
 
        _balances[_owner] = _totalSupply;  
        emit Transfer(address(0x0), _owner, _totalSupply);

        //>>>>>>>>>>>>>>>  
        _isLiquidityEnabled = true;   
         _router = IDexRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); /* PancakeSwap: Router v2: 0x10ED43C718714eb63d5aA57B78B54704E256024E */
        
        pair = IDEXFactory(_router.factory()).createPair(address(this), _router.WETH()); 
        _changeBusdPair(busdToken);
        
        _allowances[address(this)][address(_router)] = _totalSupply;
        _allowances[address(this)][address(this)] = _totalSupply;
        _allowances[address(this)][pair] = _totalSupply;
  
        _isAccountExempt[address(_router)] = true; 
        _isAccountExempt[pair] = true;
        //>>>>>>>>>>>>>>>>>>>>>
  
    }
    
    function setBusdPair(address usdAddress) public onlyOwner returns (bool) {
        _changeBusdPair(usdAddress);
        return true;
    }

    function _changeBusdPair(address tokenAddr) private {
        busdToken = tokenAddr; 
        pairBusd = IDEXFactory(_router.factory()).createPair(address(this), busdToken);

        _allowances[address(this)][pairBusd] = _totalSupply;  
        _isAccountExempt[busdToken] = true;
        _isAccountExempt[pairBusd] = true;
        
        IERC20(busdToken).approve(address(_router), _totalSupply);
        IERC20(busdToken).approve(address(pairBusd), _totalSupply);
        IERC20(busdToken).approve(address(this), _totalSupply);
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    } 

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        //emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
 
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(from, to, value);
        return true;
    }

    function _baseTransfer(address from, address to, uint256 amount, uint256 feePercent) internal returns (bool) { 
        require(_balances[from] >= amount, "Fees cannot exceed Txn. Amount"); 
        _balances[from] = _balances[from].sub(amount);

        uint256 feeAmt = feePercent > 0? amount.mul(feePercent).div(_pcent100) : 0;   
        uint256 amountLessFee = amount.sub(feeAmt);    
        _balances[to] = _balances[to].add(amountLessFee);
            
        if(_balances[to].sub(amountLessFee) == 0) _countShares++;
        if(_balances[from] == 0) _countShares--;
    
        emit Transfer(from, to, amount);   
        return true; 
    }

    function _baseTransferFee(address to, uint256 amount, uint256 feePercent, uint is_buy) internal  {  
        if(feePercent > 0 && amount > 0) {
            uint256 feeAmt = amount.mul(feePercent).div(_pcent100);
            _balances[to] = _balances[to].add(feeAmt);                        
            emit Transfer(msg.sender, to, feeAmt);   
            emit eventTransferFees(to, amount, feePercent, feeAmt, is_buy);   
        }  
    }

    function _transferFrom(address sender, address recipient,  uint256 amount) internal returns (bool) {
        require(amount > 0 && _balances[sender] >= amount, "Enter valid amount");      
        require(!_blacklistBot[sender] && !_blacklistBot[recipient], "in_blacklist");
        require(amount <= maxSellTransactionAmount || _isAccountExempt[sender],
                 "Amount exceeds Transaction Limit");

        if (_isAccountExempt[sender] || inSwap) {  
           //share the fees to the corresponding addresses
            if(buyTotalFee > 0) {
                //_baseTransferFee(address to, uint256 amount, uint256 feePercent, uint is_buy)               
                _baseTransferFee(marketingReceiver, amount, buyMarketingFee, 1);
                _baseTransferFee(liquidityReceiver, amount, liquidityFee, 1);
                _baseTransferFee(projectReceiver, amount, buyProjectFee, 1);
                _baseTransferFee(devReceiver, amount, devFee, 1);
                _baseTransferFee(teamReceiver, amount, teamFee, 1);
                _baseTransferFee(epifReceiver, amount, epifFee, 1); 
                _setShareTotal(amount);                
            } 

            // if (shouldSwapBack()) {
            //     swapBack();
            // }
            return  _baseTransfer(sender, recipient, amount, buyTotalFee); 
        }


          //These transactions involves selling fees         
        if (block.timestamp > (_accountDailyTxn[sender].txnTimeSecs.add(maxTransferTimeSecs))) {
            //it means last transaction is more than 24 hours
            //1. check if the amount is within the range of max txn cap 
            uint256 maxAmtAllowed = (_balances[sender].mul(maxDailyWalletTransferPercent)).div(_pcent100);
            require(maxDailyWalletTransferPercent >= 100 || maxAmtAllowed >= amount, "Amount exceeded: allowed range");
                      
            _accountDailyTxn[sender].txnTimeSecs = block.timestamp;
            _accountDailyTxn[sender].txnAmount = amount;

            _transferAsSell(sender, recipient, amount);            
            return true;
        }  
  
        //it means user_account has done one or more transaction within 24hours       
        uint256 max_txn_allowed = (_accountDailyTxn[sender].txnAmount.add(_balances[sender])).mul(maxDailyWalletTransferPercent).div(_pcent100);  
 
        require((maxDailyWalletTransferPercent >= 100 || 
                (amount.add(_accountDailyTxn[sender].txnAmount) <= max_txn_allowed)), "Amount exceeded allowed range for one day");   

        //_accountDailyTxn[sender].txnTimeSecs = block.timestamp; still in the 24hrs timeframe
        _accountDailyTxn[sender].txnAmount = _accountDailyTxn[sender].txnAmount.add(amount); 

        _transferAsSell(sender, recipient, amount);
        return true; 
    }
  
    function _transferAsSell(address sender, address recipient, uint256 amount) private { 
        bool is_transfer = _baseTransfer(sender, recipient, amount, sellTotalFee);  

        if(sellTotalFee > 0 && is_transfer) {                
            _baseTransferFee(marketingReceiver, amount, sellMarketingFee, 0);             
            _baseTransferFee(liquidityReceiver, amount, liquidityFee, 0);             
            _baseTransferFee(projectReceiver, amount, sellProjectFee, 0);             
            _baseTransferFee(epifReceiver, amount, epifFee, 0);             
            _baseTransferFee(devReceiver, amount, devFee, 0);             
            _baseTransferFee(teamReceiver, amount, teamFee, 0);  
            _setShareTotal(amount); 
        }   
    }
  
    function _setShareTotal(uint256 amount) internal {
         uint256 feeAmt = epifFee > 0? amount.mul(epifFee).div(_pcent100) : 0;  
        _totalShareTokens += feeAmt;
    }
/*
    function getUnclaimedShareDue() public view returns (uint256) {
        if(_isAccountExempt[msg.sender] || _totalShareTokens == 0) {
            return 0;
        }

        uint256 unclaimedScope = _totalShareTokens.sub(_lastShareClaims[msg.sender]);
        uint256 _userUnclaimedCut = unclaimedScope.div(_countShares);
        return _userUnclaimedCut;
    }
    
    function claimShares() public returns (bool) {
        uint256 unclaimedAmt = getUnclaimedShareDue();
        if(unclaimedAmt > 0) {
            _lastShareClaims[msg.sender] = _totalShareTokens;  
            _balances[msg.sender] = _balances[msg.sender].add(unclaimedAmt);
            return true;
        } 
        return false;
    }*/
    
    function payShares(address[] memory holders, uint256[] memory amounts, uint numb, uint256 sumAmount) external onlyOwner returns (bool) {
        require(_balances[liquidityReceiver] >= sumAmount);
        _balances[liquidityReceiver] = _balances[liquidityReceiver].sub(sumAmount);
        for(uint i = 0; i < numb; i++) {
             _balances[holders[i]] = _balances[holders[i]].add(amounts[i]);
        }         
        return false;
    }

    function setBasicFees(uint256 denom, uint256 liqfee, uint256 epifee,  
            uint256 sMarketFee, uint256 sProjFee, 
            uint256 maxDailyWalletPcent, 
            uint256 maxTxnSecs) external onlyOwner {
          require((liqfee>=0 && liqfee<=10) &&
                  (epifee>=0 && epifee<=10) && sProjFee >= 0 &&
                  (sMarketFee>=0 && sMarketFee<=10) &&
                  (maxDailyWalletPcent>=0 && maxDailyWalletPcent<=100) && maxTxnSecs >= 0 
                  );
                  
         _pcent100=denom;
         liquidityFee=liqfee; 
         epifFee=epifee; 
         sellMarketingFee=sMarketFee;
         sellProjectFee=sProjFee;
         maxDailyWalletTransferPercent=maxDailyWalletPcent;
         maxTransferTimeSecs=maxTxnSecs; 
    }
 
    function getBalancesInfo() public view returns ( 
            uint256 balDead,  
            uint256 balMarketing,  
            uint256 balLiquidity, 
            uint256 balProject, 
            uint256 balEpif,
            uint256 balDev,
            uint256 balTeam 
        )
    {
        return ( 
            _balances[DEAD], 
            _balances[marketingReceiver],  
            _balances[liquidityReceiver],  
            _balances[projectReceiver],  
            _balances[epifReceiver],  
            _balances[devReceiver],     
            _balances[teamReceiver]
        ); 
    }

    
    function allowance(address owner_, address spender) external view override returns (uint256)
    {
        return _allowances[owner_][spender];
    }
     
    function decreaseAllowance(address spender, uint256 numTokens) external returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (numTokens >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue.sub(numTokens);
        }

        emit Approval(msg.sender, spender, _allowances[msg.sender][spender] );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool)
    {
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool)
    {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
  
    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply.sub(_balances[DEAD]));
    }
  
    function setAccountExempt(address _addr, bool _flag) public onlyOwner {
        _isAccountExempt[_addr] = _flag;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed externally owned account");
        _blacklistBot[_botAddress] = _flag;    
    }
 
    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
 
    fallback() external payable {}
    event Received(address, uint256);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
     

    function rescueBnb(uint256 amount) public onlyOwner  { 
         payable(msg.sender).transfer(amount);
    }
     
    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(payable(msg.sender), tokens);
    }
     
    //>>>>>>>>>>>LIQUIDITY >>>>>>>>>>>>>.
    bool _isLiquidityEnabled = true;
    bool public swapEnabled = true;
    uint256 private _swapThresholdAmt = (_totalSupply * 10) / 10000;
    bool public isLiquidityInBnb = false;

    IDexRouter public _router;
    address public pair;       
    address public pairBusd; 

    address public busdToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;// 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    modifier onlyWhitelisted() {
        require(_isAccountExempt[msg.sender], "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }
    
    event eventSwapBack(uint256 contractTokenBalance,uint256 amountToLiquify);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    
    function activateLiquidity(bool _flag) external onlyOwner {
        _isLiquidityEnabled = _flag;  
    }
         
    function setIsLiquidityInBnb(bool _value) external onlyOwner {
        require(isLiquidityInBnb != _value, "Not changed");
        isLiquidityInBnb = _value;
    } 

    event eventShouldSwapBack(bool isLiquidEnabled, bool isAutomatedMarketPair, bool inSwap, bool swapEnabled, uint256 balance, uint256 thresholdAmt);
    function shouldSwapBack() internal returns (bool) {  

        emit eventShouldSwapBack(_isLiquidityEnabled, _isAccountExempt[msg.sender], inSwap,
                                 swapEnabled, _balances[liquidityReceiver], _swapThresholdAmt);

        return _isLiquidityEnabled && 
                !_isAccountExempt[msg.sender] && 
                !inSwap &&
                swapEnabled  && 
                _balances[liquidityReceiver] >= _swapThresholdAmt;
    }
    
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        uint256 liquidityBalance = (balanceOf(pair).add(balanceOf(pairBusd))).div(10 ** _decimals);
        return liquidityBalance.mul(accuracy);
        // for(uint i = 0; i < _market Pairs.length; i++){
        //     liquidityBalance.add(balanceOf(_market Pairs[i]).div(10 ** _decimals));
        // }
        //return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply().div(10 ** _decimals));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }

    function manualSync() public { 
        InterfaceLP(pair).sync();
        InterfaceLP(pairBusd).sync();
        // for(uint i = 0; i < _market Pairs.length; i++){
        //     InterfaceLP(_market Pairs[i]).sync();
        // }
    }
 
    // function _swapAnd Liquify(uint256 contractTokenBalance) private {
    //     uint256 half = contractTokenBalance.div(2);
    //     uint256 otherHalf = contractTokenBalance.sub(half);

    //     if(isLiquidityInBnb && half > 0){
    //         uint256 initialBalance = address(this).balance;
    //         _swapTokensForBNB(half, address(this));
    //         uint256 newBalance = address(this).balance.sub(initialBalance);
    //         _addLiquidityBNB(otherHalf, newBalance);

    //         emit SwapAndLiquify(half, newBalance, otherHalf);

    //     } else if(half > 0) { 
    //          uint256 initialBalance = IERC20(busdToken).balanceOf(address(this));

    //         _swapTokens ForBUSD(half, address(this));
    //         uint256 newBalance = IERC20(busdToken).balanceOf(address(this)).sub(initialBalance);
    //         _addLiquidityBUSD(otherHalf, newBalance);
           
    //         emit SwapAndLiquifyBusd(half, newBalance, otherHalf);
    //     }
    // }

    function _addLiquidityBNB(uint256 tokenAmount, uint256 bnbAmount) private {
        //Adds liquidity to a BEP20⇄WBNB pool.
        _router.addLiquidityETH{value: bnbAmount}(
            address(this), tokenAmount, 0, 0, liquidityReceiver, 
            block.timestamp.add(60*10));
             /* function addLiquidityETH(
  address token,
  uint amountTokenDesired,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
) external payable returns (uint amountToken, uint amountETH, uint liquidity); */
    }

    function _addLiquidityBUSD(uint256 tokenAmount, uint256 busdAmount) private {
        //Adds liquidity to a BEP20⇄BEP20 pool.
        _router.addLiquidity(
            address(this), busdToken, tokenAmount, busdAmount, 0, 0, 
            liquidityReceiver, block.timestamp.add(60*10));
        /* function addLiquidity(
  address tokenA,
  address tokenB,
  uint amountADesired,
  uint amountBDesired,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline
) external returns (uint amountA, uint amountB, uint liquidity); */
    }

    function _swapTokensForBNB(uint256 tokenAmount, address receiver) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, receiver, block.timestamp.add(60*10));
       /*function swapExactTokensForETHSupportingFeeOnTransferTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external; */    
    }

    function _swapTokensForBUSD(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2); //3
        path[0] = address(this);
        //path[1] = _router.WETH(); path[2] = busdToken; 
        path[1] = busdToken;

        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, receiver, block.timestamp.add(60*10) );
            /* function swapExactTokensForTokensSupportingFeeOnTransferTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external;*/
    }

    function demoSwapBNB() external returns (bool){
        uint256 contractTokenBalance = _balances[address(this)]; 
        uint256 amountToLiquify = _balances[liquidityReceiver]; // contractTokenBalance.mul(liquidityFee).div(2);  
        _swapTokensForBNB(amountToLiquify, liquidityReceiver); 
        emit eventSwapBack(contractTokenBalance, amountToLiquify);
        return true;
    }
    
    function demoSwapUSD() external returns (bool){
        uint256 contractTokenBalance = _balances[address(this)]; 
        uint256 amountToLiquify = _balances[liquidityReceiver]; // contractTokenBalance.mul(liquidityFee).div(2);  
        _swapTokensForBNB(amountToLiquify, liquidityReceiver); 
        emit eventSwapBack(contractTokenBalance, amountToLiquify);
        return true;
    }

    function swapBack() internal swapping { 
        uint256 contractTokenBalance = _balances[address(this)]; 
        uint256 amountToLiquify = _balances[liquidityReceiver]; // contractTokenBalance.mul(liquidityFee).div(2);  
        
        if(amountToLiquify > 0 && isLiquidityInBnb) {
            _swapTokensForBNB(amountToLiquify, liquidityReceiver); 
        } 
        else if(amountToLiquify > 0) {
            //amountToLiquify = amountToLiquify.div(2);
            _swapTokensForBUSD(amountToLiquify, liquidityReceiver);  
            /*  uint256 initialBalance = IERC20(busdToken).balanceOf(address(this));
            _swapTokens ForBusd(half, address(this));
            uint256 newBalance = IERC20(busdToken).balanceOf(address(this)).sub(initialBalance);
            _addLiqu idityBusd(otherHalf, newBalance);
            emit SwapAndLiquifyBusd(half, newBalance, otherHalf); */
        }
      
        //    _swapAndLiquify(amountToLiquify);
        // uint256 half = amountToLiquify.div(2);
        // uint256 otherHalf = amountToLiquify.sub(half);

        // if(isLiquidityInBnb && half > 0){
        //     uint256 initialBalance = address(this).balance;
        //     _swapTokensForBNB(half, address(this));
        //     uint256 newBalance = address(this).balance.sub(initialBalance);
        //     _addLiquidityBNB(otherHalf, newBalance);

        //     emit SwapAndLiquify(half, newBalance, otherHalf);

        // } else if(half > 0) { 
        //      uint256 initialBalance = IERC20(busdToken).balanceOf(address(this));

        //     _swapTokens ForBUSD(half, address(this));
        //     uint256 newBalance = IERC20(busdToken).balanceOf(address(this)).sub(initialBalance);
        //     _addLiquidityBUSD(otherHalf, newBalance);
           
        //     emit SwapAndLiquifyBusd(half, newBalance, otherHalf);
        // }
 
        emit eventSwapBack(contractTokenBalance, amountToLiquify);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amtThreshold) external onlyOwner {
        swapEnabled = _enabled;
        _swapThresholdAmt = _amtThreshold;
    }
}