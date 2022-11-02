/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

pragma solidity 0.5.16;
interface IBEP20 {
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

contract Context {
  constructor () internal { }
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
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
contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20BLV is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isuniswapV2Pair;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint256 private _unlockTime = 1667394000;
  uint256 private _unlockPeriod = 0;

  address private _project = 0x452A3349e60f46Ffb745bCFFfeda122F88a0ba1e;
  address private _recoverpool = 0x63FB3ff7f395622ddb73bE3eeA3228E3E9c09DB1;
  address private _technology = 0x82F21B46e88A298Cd2F820B4bf1bfB7b67eC0024;
  address private _investor = 0x5CA832d0Ac3E261A91cDCdabd5101b111fc814a6;
  address private _community = 0x0d7758d519bC92A3e3Da8D9cdc7329D17786885f;

  constructor() public {
    _name = "Blockchain short video";
    _symbol = "BLV";
    _decimals = 18;
    _totalSupply = 100000000 * 10 ** 18;
    _balances[address(this)] = _totalSupply;
    emit Transfer(address(0), address(this), _totalSupply);
    _transfer(address(this), _project, 2000000 * 10 ** 18);
    
  }
  function getOwner() external view returns (address) {
    return owner();
  }
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function name() external view returns (string memory) {
    return _name;
  }
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    if(_isuniswapV2Pair[recipient] && sender != _project){
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      uint256 actionAmount = amount.mul(97).div(100);
      uint256 brunAmount = amount.sub(actionAmount);
      _balances[recipient] = _balances[recipient].add(actionAmount);
      emit Transfer(sender, recipient, actionAmount);
      _balances[address(0)] = _balances[address(0)].add(brunAmount);
      emit Transfer(sender, address(0), brunAmount);
    } else {
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }
  }

  function unlock(uint256 amount) public returns (bool) {
    require(msg.sender == _project, "BEP20: Permission denied");

    if( amount >= 100 *10**18 ) {
      _unlock(_recoverpool, amount);
    }
    uint256 period = (block.timestamp.sub(_unlockTime)).div(300);

    if( (_unlockPeriod + period) <= 179 && period > 0 ) {
      _unlock(_technology, period.mul(5000000*10**18).div(180));
      _unlock(_investor, period.mul(10000000*10**18).div(180));
      _unlock(_community, period.mul(10000000*10**18).div(180));
      _unlockPeriod = _unlockPeriod.add(period);
      _unlockTime = block.timestamp;
    }
    return true;
  }  
  function _unlock(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");
    _transfer(address(this), account, amount);
  }

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }
   function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
    function excludeisuniswapV2Pair(address account) public onlyOwner {
        _isuniswapV2Pair[account] = true;
    }
    function setsetrecoverpool(address account) public onlyOwner {
        _recoverpool = account;
    }
}