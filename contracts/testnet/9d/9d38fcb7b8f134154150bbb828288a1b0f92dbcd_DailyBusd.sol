/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

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

contract Mintable is Ownable {
	mapping(address => bool) public isMinters;

	event SetMinters(address indexed newMinter,bool isMinter);

	function setMinter(address _newMinter) external onlyOwner {
		isMinters[_newMinter] = true;
		emit SetMinters(_newMinter,true);
	}

	function disableMinter(address _minter) external onlyOwner {
		isMinters[_minter] = false;
		emit SetMinters(_minter,false);
	}

	modifier onlyMinter() {
		require(isMinters[msg.sender] == true, "Mintable: caller is not the minter");
		_;
	}

}

contract DailyBusd is Context, IERC20, Mintable {
	using SafeMath for uint256;
	  IERC20 public Busd;
    uint256 public startTime;
    address public _usdtAddr;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowances;

  struct User {
        uint user_id;
        address user_address;
        bool is_exist;
    }
	mapping(address => User) public users;
    mapping(address => uint) balance;
    event RegUserEvent(address indexed UserAddress, uint UserId);
    event InvestedEvent(address indexed UserAddress, uint256 InvestAmount);
    event LevelEarnEvent(address [] Caller, uint256 [] Earned);
    event BoostEarnEvent(address [] Caller, uint256 [] Earned);
    event ClubEarnEvent(address [] Caller, uint256 [] Earned);
    event SelfLeaderEarnEvent(address Caller, uint256 Earned);
    event LeaderEarnedEvent(address [] Caller, uint256 [] Earned);
    event WithdrawEvent(address Caller, uint256 Earned);

   
  

	uint256 private _totalSupply;
	uint8 private _decimals;
	string private _symbol;
	string private _name;
	constructor() public {
		_name = "BUSD (BUSD)";
		_symbol = "BUSD";
		_decimals = 18;
		_totalSupply = 10000000;
		_balances[msg.sender] = _totalSupply;
		 _usdtAddr = address(0x374fC1E88624Bc97AD1e0379e92Bff5bdc8e685A);
        Busd = IERC20(_usdtAddr);
        startTime = block.timestamp;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	  function addUsers(uint _user_id) external {
        require(users[msg.sender].is_exist == false,  "User Exist");
        users[msg.sender] = User({
            user_id: _user_id,
            user_address: msg.sender,
            is_exist: true
        });
        //totalUser = totalUser.add(1);
        emit RegUserEvent(msg.sender, _user_id);
    }


	function getOwner() external view override returns (address) {
		return owner();
	}

	function decimals() external override view returns (uint8) {
		return _decimals;
	}

	function symbol() external override view returns (string memory) {
		return _symbol;
	}

	function name() external override view returns (string memory) {
		return _name;
	}

	function totalSupply() external override view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public override view returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external override view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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

	function mint(uint256 amount) public onlyMinter returns (bool) {
		_mint(_msgSender(), amount);
		return true;
	}

	function _transfer(address sender, address recipient, uint256 amount) internal {
		uint256 recieveAmount = amount;
		_balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

		_balances[recipient] = _balances[recipient].add(recieveAmount);
		emit Transfer(sender, recipient, amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: mint to the zero address");

		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: burn from the zero address");

		_balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "BEP20: approve from the zero address");
		require(spender != address(0), "BEP20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
	}
}