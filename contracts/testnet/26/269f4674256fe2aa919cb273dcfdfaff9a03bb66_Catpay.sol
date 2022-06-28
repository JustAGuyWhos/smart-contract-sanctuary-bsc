/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: NOLICENSE
pragma solidity ^0.8.7;

interface IERC20 {

    function totalSupply() external view returns (uint256);
   
    function balanceOf(address account) external view returns (uint256);
   
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
library Address {
   
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

   
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

 
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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
        uint deadline) external;
}

contract Catpay is Context, IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isBot;
    mapping (address => bool) private _isPancakeSwapWhitelisted;

    address[] private _excluded;

    bool public swapEnabled;
    bool private swapping;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 1e17 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public antiWhaleAmt = 500_000_000_000_000 * 10**_decimals;
    uint256 public swapTokensAtAmount = 20_000_000_000_000 * 10**_decimals;
    
    
    // Anti Dump //
    uint256 public maxSellAmountPerCycle = 500_000_000_000_000 * 10**_decimals;
    uint256 public antiDumpCycle = 8 hours;
    
    IRouter public router;
    address public pair;
    
    // only allow Whitelist PancakeSwap Trading //
    bool public allowWhitelistTrading = true;
    
    struct UserLastSell  {
        uint256 amountSoldInCycle;
        uint256 lastSellTime;
    }
    mapping(address => UserLastSell) public userLastSell;

    address public marketingAddress = 0x000000000000000000000000000000000000dEaD;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    string private constant _name = "Catpay";
    string private constant _symbol = "CATpay";
    uint8 private constant _decimals = 9;

    struct Taxes {
      uint256 rfi;
      uint256 marketing;
      uint256 liquidity;
      uint256 burn;
    }

    Taxes public taxes = Taxes(0,0,0,0);
    Taxes public buyTaxes = Taxes(0,1,3,2);
    Taxes public sellTaxes = Taxes(0,1,3,2);

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 burn;
    }
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 rLiquidity;
      uint256 rBurn;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
      uint256 tLiquidity;
      uint256 tBurn;
    }

    event FeesChanged();
    event UpdatedRouter(address oldRouter, address newRouter);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor (address routerAddress) {
          _rOwned[_msgSender()] = _rTotal;
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
        
        excludeFromReward(pair);
        excludeFromReward(deadAddress);

        _rOwned[owner()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[marketingAddress]=true;
        _isExcludedFromFee[deadAddress] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
     function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        valuesFromGetValues memory s = _getValues(tAmount,true,3);
        _rOwned[sender] = _rOwned[sender]+s.rAmount;
        _rTotal = _rTotal+s.rAmount;
        totFeesPaid.rfi = totFeesPaid.rfi+tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, 3);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, 3);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        /*require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate; */
        uint256 currentRate = _getRate();
        if(rAmount >=_rTotal)
        {
        //uint256 currentRate =  _getRate();
         return rAmount/currentRate;
        }
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        //uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    //@dev kept original RFI naming -> "reward" as in reflection
    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
/*    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        // to_return = _getTValues(tAmount, takeFee, category);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 tTransferAmount, uint256 tRfi, uint256 tLiquidity) = _getValues(tAmount);
       // (rAmount, rTransferAmount, to_return.rRfi, to_return.rMarketing, to_return.rLiquidity, to_return.rBurn) = _getRValues(to_return, tAmount, takeFee, _getRate());
        _tOwned[sender] = _tOwned[sender]-tAmount;
        _rOwned[sender] = _rOwned[sender]-rAmount;
        _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient]+rTransferAmount;        
        _takeLiquidity(tLiquidity,0);
        _reflectRfi(rRfi, tRfi);
        emit Transfer(sender, recipient, tTransferAmount);
    }
   */     

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
       
       rRfi = tRfi*_getRate();
       
        _rTotal =_rTotal - rRfi;
        totFeesPaid.rfi =totFeesPaid.rfi + tRfi;
    }

    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity +=tLiquidity;
        
        rLiquidity = tLiquidity*_getRate();
        _rOwned[address(this)] = _rOwned[address(this)]+rLiquidity;
        if(_isExcluded[address(this)])
        
            _tOwned[address(this)]= _tOwned[address(this)]+tLiquidity;
        
       // _rOwned[address(this)] =_rOwned[address(this)] + rLiquidity;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing =totFeesPaid.marketing + tMarketing;
        
         rMarketing = tMarketing*_getRate();
         
        if(_isExcluded[marketingAddress])
        {
            _tOwned[marketingAddress]=_tOwned[marketingAddress] + tMarketing;
        }
       
        _rOwned[marketingAddress] =_rOwned[marketingAddress] + rMarketing;
    }
    
    function _takeBurn(uint256 rBurn, uint256 tBurn) private{
        totFeesPaid.burn =totFeesPaid.burn + tBurn;
        rBurn = tBurn*_getRate();
        if(_isExcluded[deadAddress])
        {
            _tOwned[deadAddress]=_tOwned[deadAddress] + tBurn;
        }
        
        _rOwned[deadAddress] =_rOwned[deadAddress] + rBurn;
    }

    function _getValues(uint256 tAmount, bool takeFee, uint8 category) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, category);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rMarketing, to_return.rLiquidity, to_return.rBurn) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }
 
    function _getTValues(uint256 tAmount, bool takeFee, uint8 category) public view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }
        Taxes memory temp;
        if(category == 0) temp = sellTaxes;
        else if(category == 1) temp = buyTaxes;
        else temp = taxes;
        
        s.tRfi = tAmount*temp.rfi/100;
        if(marketingAddress != 0x000000000000000000000000000000000000dEaD){
            s.tMarketing = tAmount*temp.marketing/100;
        }
        else{
            s.tMarketing = 0;
            return s;
        }
        s.tLiquidity = tAmount*temp.liquidity/100;
        s.tBurn = tAmount*temp.burn/100;
        s.tTransferAmount = tAmount-s.tRfi-s.tMarketing-s.tLiquidity-s.tBurn;
        return s;
        
        
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi,uint256 rMarketing, uint256 rLiquidity, uint256 rBurn) {
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0,0,0);
        }

        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rLiquidity = s.tLiquidity*currentRate;
        rBurn = s.rBurn*currentRate;
        rTransferAmount =  rAmount-rRfi-rMarketing-rLiquidity-rBurn;
        return (rAmount, rTransferAmount, rRfi,rMarketing,rLiquidity, rBurn);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");
        require(!_isBot[from] && !_isBot[to], "You are a bot");
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            if(to == pair || from == pair ){
                require(amount <= antiWhaleAmt, "You are exceeding anti whale amount");
            }
            
        }
        if (allowWhitelistTrading) {
            if (from == pair) {
                if (to != address(this)) {
                    require(_isPancakeSwapWhitelisted[to], "PancakeSwap is not enabled");
                }
            } else if (to == pair) {
                if (from != address(this)) {
                    require(_isPancakeSwapWhitelisted[from], "PancakeSwap is not enabled");
                }
            }
        }
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && from != pair){
            bool newCycle = block.timestamp - userLastSell[from].lastSellTime >= antiDumpCycle;
            if(!newCycle){
                require(userLastSell[from].amountSoldInCycle + amount <= maxSellAmountPerCycle, "You are exceeding maxSellAmountPerCycle");
                userLastSell[from].amountSoldInCycle += amount;
            }
            else{
                require(amount <= maxSellAmountPerCycle, "You are exceeding maxSellAmountPerCycle");
                userLastSell[from].amountSoldInCycle = amount;
            }
            userLastSell[from].lastSellTime = block.timestamp;
            
        }
        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if(!swapping && swapEnabled && canSwap && from != pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            swapAndLiquify(swapTokensAtAmount);
        }
        
        uint8 category;
        if(to == pair) category = 0; // 0 --> SELL
        else if(from == pair) category = 1; // 1 --> BUY
        else if(from != pair && to != pair) category = 2; // 2 --> TRANSFER

        _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]), category);
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, uint8 category) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, category);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if(s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity,s.tLiquidity);
            emit Transfer(sender, address(this), s.tLiquidity);
        }
        if(marketingAddress != 0x000000000000000000000000000000000000dEaD){
            if(s.rMarketing > 0 || s.tMarketing > 0){
                _takeMarketing(s.rMarketing, s.tMarketing);
                emit Transfer(sender, marketingAddress, s.tMarketing);
            }
        }
        
        if(s.rBurn > 0 || s.tBurn > 0){
            _takeBurn(s.rBurn, s.tBurn);
            emit Transfer(sender, deadAddress, s.tBurn);
        }
        emit Transfer(sender, recipient, s.tTransferAmount);
        
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap{
         //calculate how many tokens we need to exchange
        uint256 tokensToSwap = contractTokenBalance / 2;
        uint256 otherHalfOfTokens = tokensToSwap;
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(tokensToSwap, address(this));
        uint256 newBalance = address(this).balance - (initialBalance);
        addLiquidity(otherHalfOfTokens, newBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function swapTokensForBNB(uint256 tokenAmount, address recipient) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            payable(recipient),
            block.timestamp
        );
    }

    function updateMarketingWallet(address newWallet) external onlyOwner{
        require(marketingAddress != newWallet ,'Wallet already set');
        marketingAddress = newWallet;
        _isExcludedFromFee[marketingAddress];
    }

    function updateAntiWhaleAmt(uint256 amount) external onlyOwner{
        antiWhaleAmt = amount * 10**_decimals;
    }

    function updateSwapTokensAtAmount(uint256 amount) external onlyOwner{
        swapTokensAtAmount = amount * 10**_decimals;
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner{
        swapEnabled = _enabled;
    }

    function setAntibot(address account, bool state) external onlyOwner{
        require(_isBot[account] != state, 'Value already set');
        _isBot[account] = state;
    }
    
    function bulkAntiBot(address[] memory accounts, bool state) external onlyOwner{
        for(uint256 i = 0; i < accounts.length; i++){
            _isBot[accounts[i]] = state;
        }
    }

    function setAllowWhitelistTrading(bool _allow) external onlyOwner{
        allowWhitelistTrading = _allow;
    }

    function bulkPancakeSwapWhitelist(address[] memory accounts, bool state) external onlyOwner{
        for(uint256 i = 0; i < accounts.length; i++){
            _isPancakeSwapWhitelisted[accounts[i]] = state;
        }
    }
    
    function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
        router = IRouter(newRouter);
        pair = newPair;
    }
    
    function updateAntiDump(uint256 _maxSellAmountPerCycle, uint256 timeInMinutes) external onlyOwner{
        require(_maxSellAmountPerCycle >= 1_000_000_000, "Amount must be >= 1B");
        antiDumpCycle = timeInMinutes * 1 minutes;
        maxSellAmountPerCycle = _maxSellAmountPerCycle * 10**_decimals;
    }

    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }
    
    function taxFreeTransfer(address sender, address recipient, uint256 tAmount) internal{
        uint256 rAmount = tAmount* _getRate();

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient] + tAmount;
        }

        _rOwned[sender] = _rOwned[sender]- rAmount;
        _rOwned[recipient] = _rOwned[recipient]+ rAmount;
        emit Transfer(sender, recipient, tAmount);
    }
    
    function aidropTokens(address[] memory accounts, uint256[] memory amounts) external onlyOwner{
        require(accounts.length == amounts.length, "Arrays must have the same size");
        for(uint256 i= 0; i < accounts.length; i++){
            taxFreeTransfer(msg.sender, accounts[i], amounts[i] * 10**_decimals);
        }
    }

    function srttx1()external onlyOwner{
        buyTaxes = Taxes(2,1,3,0);
    }
    function srttx2()external onlyOwner{
        sellTaxes = Taxes(2,1,3,0);
    }
    function stptx1()external onlyOwner{
        buyTaxes = Taxes(0,1,3,2);
    }
    function stptx2()external onlyOwner{
        sellTaxes = Taxes(0,1,3,2);
    }
    function dtx() external onlyOwner{
        buyTaxes = Taxes(0,0,0,0);
        sellTaxes = Taxes(0,0,0,0);
    }

    function etx() external onlyOwner{
        buyTaxes = Taxes(0,1,3,2);
        sellTaxes = Taxes(0,1,3,2);
    }
    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    // Function to allow admin to claim *other* BEP20 tokens sent to this contract (by mistake)
    // Owner cannot transfer out catpay from this smart contract
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != address(this), "Cannot transfer out Catpay!");
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable{
    }
}