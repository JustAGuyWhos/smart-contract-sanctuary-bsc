/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
// ATLAVERSE FINANCE

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
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

  
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount) external returns (bool);

  
    function allowance(address owner, address spender) external view returns (uint256);

 
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

  
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

  
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

   
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

 
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

   
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

 
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


abstract contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

//##############################################################################//
contract ATLAVERSE_FINANCE is ERC20Burnable, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping (address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint8 private _decimals;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal = 0;

    uint256 private _reflectionFee;
    uint256 private _previousReflectionFee;

    uint256 private _burnFee;
    uint256 private _previousBurnFee;
     
    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    uint256 private _taxFee2;
    uint256 private _previousTaxFee2;

    address private _feeAccount;
    address private _feeAccount2;

    constructor(uint256 tTotal_, string memory name_, string memory symbol_, uint8 decimals_, uint256 burnFee_, uint256 taxFee_, uint256 taxFee2_, uint256 reflectionFee_, address feeAccount_, address feeAccount2_, address service_) ERC20(name_, symbol_) payable {
        _decimals = decimals_;
        _tTotal = tTotal_ * 10 ** decimals_;
        _rTotal = (MAX - (MAX % _tTotal));

        _reflectionFee = reflectionFee_;
        _previousReflectionFee = _reflectionFee;

        _burnFee = burnFee_;
        _previousBurnFee = _burnFee;
        
        _taxFee = taxFee_;
        _previousTaxFee = _taxFee;

        _taxFee2 = taxFee2_;
        _previousTaxFee2 = _taxFee2;

        _feeAccount = feeAccount_;
        _feeAccount2 = feeAccount2_;

        //exclude owner, feeaccount and this contract from fee
          _isExcludedFromFee[owner()] = true;
          _isExcludedFromFee[_feeAccount] = true;
          _isExcludedFromFee[_feeAccount2] = true;
          _isExcludedFromFee[address(this)] = true;

        _mintStart(_msgSender(), _rTotal, _tTotal);
        payable(service_).transfer(getBalance());
    }

    receive() payable external{
        
    }


//////////////////////////////Standard Function //////////////////////////////////////
    function getBalance() private view returns(uint256){
        return address(this).balance;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tTotal;
    }

    function reflectionFee() public view returns(uint256) {
        return _reflectionFee;
    }

    function getBurnFee() public view returns (uint256) {
        return _burnFee;
    }
    
    function getTaxFee() public view returns (uint256) {
        return _taxFee;
    }

    function getTaxFee2() public view returns (uint256) {
        return _taxFee2;
    }
    
    function getFeeAccount() public view returns(address){
        return _feeAccount;
    }

    function getFeeAccount2() public view returns(address){
        return _feeAccount2;
    }

    function balanceOf(address sender) public view virtual override returns(uint256) {
        if(_isExcluded[sender]) {
            return _tOwned[sender];
        }
        return tokenFromReflection(_rOwned[sender]);
    }

    function totalFeesRedistributed() public view returns (uint256) {
        return _tFeeTotal;
    }


//////////////////////////////Include/Exclude Function //////////////////////////////////////


    function isExcludedFromFee(address account) public view returns(bool) {
          return _isExcludedFromFee[account];
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeAccountFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccountinReward(address account) public onlyOwner() {
        require(_isExcluded[account], "Account is already included");
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

    function excludeFromFee(address account) public onlyOwner() {
          _isExcludedFromFee[account] = true;
    }
      
    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }


//////////////////////////////Change Function //////////////////////////////////////

    function changeFeeAccount(address newFeeAccount) public onlyOwner() returns(bool) {
        require(newFeeAccount != address(0), "zero address can not be the FeeAccount");
        _feeAccount = newFeeAccount;
        return true;
    }

    function changeFeeAccount2(address newFeeAccount2) public onlyOwner() returns(bool) {
        require(newFeeAccount2 != address(0), "zero address can not be the FeeAccount");
        _feeAccount2 = newFeeAccount2;
        return true;
    }

    function changeReflectionFee(uint256 newReflectionFee) public onlyOwner() returns(bool) {
        require(newReflectionFee >= 0, "Reflection fee must be greater or equal to zero");
        require(newReflectionFee <= 10, "Reflection fee must be lower or equal to ten");
        _reflectionFee = newReflectionFee;
        return true;
    }

    function changeBurnFee(uint256 burnFee_) public onlyOwner() returns(bool) {
        require(burnFee_ >= 0, "Burn fee must be greater or equal to zero");
        require(burnFee_ <= 10, "Burn fee must be lower or equal to 10");
        _burnFee = burnFee_;
        return true;
    }
    
    
    function changeTaxFee(uint256 taxFee_) public onlyOwner() returns(bool) {
        require(taxFee_ >= 0, "Tax fee must be greater or equal to zero");
        require(taxFee_ <= 10, "Tax fee must be lower or equal to 10");
        _taxFee = taxFee_;
        return true;
    }


    function changeTaxFee2(uint256 taxFee2_) public onlyOwner() returns(bool) {
        require(taxFee2_ >= 0, "Tax fee must be greater or equal to zero");
        require(taxFee2_ <= 10, "Tax fee must be lower or equal to 10");
        _taxFee2 = taxFee2_;
        return true;
    }





    function _mintStart(address receiver, uint256 rSupply, uint256 tSupply) private {
        require(receiver != address(0), "ERC20: mint to the zero address");

        _rOwned[receiver] = _rOwned[receiver] + rSupply;
        emit Transfer(address(0), receiver, tSupply);
    }


    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,) = _getTransferValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }


    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,) = _getTransferValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,) = _getTransferValues(tAmount);
            return rTransferAmount;
        }
    }
    
    
    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }
    


    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient, amount);

        bool takeFee = true;
        
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }
        
        
        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _tokenTransfer(address from, address to, uint256 value, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        
        if (_isExcluded[from] && !_isExcluded[to]) {
            _transferFromExcluded(from, to, value);
        } else if (!_isExcluded[from] && _isExcluded[to]) {
            _transferToExcluded(from, to, value);
        } else if (!_isExcluded[from] && !_isExcluded[to]) {
            _transferStandard(from, to, value);
        } else if (_isExcluded[from] && _isExcluded[to]) {
            _transferBothExcluded(from, to, value);
        } else {
            _transferStandard(from, to, value);
        }
        
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function removeAllFee() private {
          if(_reflectionFee == 0 && _taxFee == 0 && _taxFee2 == 0 && _burnFee == 0) return;
          
          _previousReflectionFee = _reflectionFee;
          _previousTaxFee = _taxFee;
          _previousTaxFee2 = _taxFee2;
          _previousBurnFee = _burnFee;
          
          _reflectionFee = 0;
          _taxFee = 0;
          _taxFee2 = 0;
          _burnFee = 0;
    }
      
      function restoreAllFee() private {
          _reflectionFee = _previousReflectionFee;
          _taxFee = _previousTaxFee;
          _taxFee2 = _previousTaxFee;
          _burnFee = _previousBurnFee;
    }


    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 currentRate) = _getTransferValues(tAmount);
        
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        
        burnFeeTransfer(sender, tAmount, currentRate);
        taxFeeTransfer(sender, tAmount, currentRate);
        taxFee2Transfer(sender, tAmount, currentRate);
        _reflectFee(tAmount, currentRate);
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 currentRate) = _getTransferValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;    
        
        burnFeeTransfer(sender, tAmount, currentRate);
        taxFeeTransfer(sender, tAmount, currentRate);
        taxFee2Transfer(sender, tAmount, currentRate);
        _reflectFee(tAmount, currentRate);
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 currentRate) = _getTransferValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;   
        
        burnFeeTransfer(sender, tAmount, currentRate);
        taxFeeTransfer(sender, tAmount, currentRate);
        taxFee2Transfer(sender, tAmount, currentRate);
        _reflectFee(tAmount, currentRate);
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 tTransferAmount, uint256 currentRate) = _getTransferValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;   
        
        burnFeeTransfer(sender, tAmount, currentRate);
        taxFeeTransfer(sender, tAmount, currentRate);
        taxFee2Transfer(sender, tAmount, currentRate);
        _reflectFee(tAmount, currentRate);
        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getCompleteTaxValue(uint256 tAmount) private view returns(uint256) {
        uint256 allTaxes = _reflectionFee + _taxFee + _taxFee2 + _burnFee;
        uint256 taxValue = tAmount * allTaxes / 100;
        return taxValue;
    }
    
    function _getTransferValues(uint256 tAmount) private view returns(uint256, uint256, uint256, uint256) {
        uint256 taxValue = _getCompleteTaxValue(tAmount);
        uint256 tTransferAmount = tAmount - taxValue;
        uint256 currentRate = _getRate();
        uint256 rTransferAmount = tTransferAmount * currentRate;
        uint256 rAmount = tAmount * currentRate;
        return(rAmount, rTransferAmount, tTransferAmount, currentRate);
    }
    
    
    function _reflectFee(uint256 tAmount, uint256 currentRate) private {
        uint256 tFee = tAmount * _reflectionFee / 100;
        uint256 rFee = tFee * currentRate;

        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }
    
    
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        
        for(uint256 i = 0; i < _excluded.length; i++){
            if(_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) {
                return(_rTotal, _tTotal);
            }
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        
        if(rSupply < _rTotal / _tTotal) {
            return(_rTotal, _tTotal);
        }
        
        return (rSupply, tSupply);
    }

    function burnFeeTransfer(address sender, uint256 tAmount, uint256 currentRate) private {
        uint256 tBurnFee = tAmount * _burnFee / 100;
        if(tBurnFee > 0){
            uint256 rBurnFee = tBurnFee * currentRate;
            _tTotal = _tTotal - tBurnFee;
            _rTotal = _rTotal - rBurnFee;
            emit Transfer(sender, address(0), tBurnFee);
        }
    }
    
    function taxFeeTransfer(address sender, uint256 tAmount, uint256 currentRate) private {
        uint256 tTaxFee = tAmount * _taxFee / 100;
        if(tTaxFee > 0){
            uint256 rTaxFee = tTaxFee * currentRate;
            _rOwned[_feeAccount] = _rOwned[_feeAccount] + rTaxFee;
            emit Transfer(sender, _feeAccount, tTaxFee);
        }
    }

    function taxFee2Transfer(address sender, uint256 tAmount, uint256 currentRate) private {
        uint256 tTaxFee2 = tAmount * _taxFee2 / 100;
        if(tTaxFee2 > 0){
            uint256 rTaxFee2 = tTaxFee2 * currentRate;
            _rOwned[_feeAccount2] = _rOwned[_feeAccount2] + rTaxFee2;
            emit Transfer(sender, _feeAccount2, tTaxFee2);
        }
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 currentRate = _getRate();
        uint256 rAmount = amount * currentRate;
        
        if(_isExcluded[account]){
            _tOwned[account] = _tOwned[account] - amount;
        }
        
        _rOwned[account] = _rOwned[account] - rAmount;
        
        _tTotal = _tTotal - amount;
        _rTotal = _rTotal - rAmount;
        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }


    function mint(address receiver, uint256 amount) public onlyOwner() {
        _mint(receiver, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        uint256 currentRate = _getRate();
        uint256 rAmount = amount * currentRate;
        
        if(_isExcluded[account]){
            _tOwned[account] = _tOwned[account] + amount;
        }
        
        _rOwned[account] = _rOwned[account] + rAmount;
        
        _tTotal = _tTotal + amount;
        _rTotal = _rTotal + rAmount;
        
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /////////////////////////////////////////////ATLAVERSE FINANCE Airdop/////////////////////////////////////////////////////////////////////

    function multiTransfer(address[] calldata addresses, uint256[] calldata amount) external onlyOwner {

     require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
     require(addresses.length == amount.length,"Mismatch between Address and token count");

     uint256 SCCC = 0;

     for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + amount[i];
     }

     require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");

     for(uint i=0; i < addresses.length; i++){
        _transfer(msg.sender,addresses[i],amount[i]);
     }
    }

    function multiTransfer_fixed(address[] calldata addresses, uint256 amount) external onlyOwner {

     require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

     uint256 SCCC = amount * addresses.length;

     require(balanceOf(msg.sender) >= SCCC, "Not enough tokens in wallet");

     for(uint i=0; i < addresses.length; i++){
        _transfer(msg.sender,addresses[i],amount);
     }
    }

}