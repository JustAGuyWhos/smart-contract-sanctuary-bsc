/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


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
    address private _previousOwner;
    uint256 private _lockTime;

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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Ownable, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    using SafeMath for uint256;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    struct unlock {
      uint256 reNumber;
      uint256 unNumber;
      uint256 unCount;
    }
    
    mapping(address => unlock) public unlocks;
    mapping(address => bool) private whitelist;

    address private _deadAddress =
        address(0x000000000000000000000000000000000000dEaD);

    uint256 private _public = 10;
    uint256 public unLockcount = 0;
    uint256 public ethBurn = 3 * 10 ** 15;
    uint256 public rate = 0;

    address public TradeAddress;

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        uint256 currentAllowance = allowance(from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(from, spender, currentAllowance - amount);
            }
        }

        _transfer(from, to, amount);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 receiveAmount = amount.mul(100 - rate).div(100);

        if(whitelist[from] == true){
            unchecked {
                _balances[from] = fromBalance - amount;
            }
            _balances[to] += receiveAmount;

            unlocks[to].unNumber += receiveAmount;

            emit Transfer(from, to, receiveAmount);
            _afterTokenTransfer(from, to, receiveAmount);

            if( rate > 0 ){
                uint256 dealAmount = amount - receiveAmount;
                _balances[_deadAddress] += dealAmount;
                emit Transfer(from, _deadAddress, dealAmount);
                _afterTokenTransfer(from, to, dealAmount);
            }
        } else {
            require(unlocks[from].unNumber >= amount, "ERC20: transfer amount exceeds unbalance");
            
            unchecked {
                _balances[from] = fromBalance - amount;
            }
            _balances[to] += receiveAmount;

            unlocks[from].unNumber -= amount;
            unlocks[to].unNumber += receiveAmount;

            emit Transfer(from, to, receiveAmount);
            _afterTokenTransfer(from, to, receiveAmount);

            if( rate > 0 ){
                uint256 dealAmount = amount - receiveAmount;
                _balances[_deadAddress] += dealAmount;
                emit Transfer(from, _deadAddress, dealAmount);
                _afterTokenTransfer(from, to, dealAmount);
            }
        }

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

    function balanceRelease()
        public payable
    {
        uint256 accountBalance = _balances[msg.sender];

        require(accountBalance >= 1, "ERC20: burn amount exceeds balance");
        require(unLockcount != 0, "ERC20: The token is not unlocked");
        require(unLockcount != unlocks[msg.sender].unCount, "ERC20: No need to unlock");
        require(unlocks[msg.sender].unCount <= 9, "ERC20: token is unlocked.");

        require(msg.value >= ethBurn);
        payable(TradeAddress).transfer(msg.value);
 
        if(unlocks[msg.sender].unCount == 0 && unlocks[msg.sender].unNumber == 0){
            unlocks[msg.sender].unNumber = unlocks[msg.sender].reNumber.mul(_public * unLockcount).div(100);
            unlocks[msg.sender].unCount += 1;
        } else if (unlocks[msg.sender].unCount == 0 && unlocks[msg.sender].unNumber > 0){
            unlocks[msg.sender].unNumber = unlocks[msg.sender].unNumber + unlocks[msg.sender].reNumber.mul(_public * unLockcount).div(100);
            unlocks[msg.sender].unCount += (unLockcount - unlocks[msg.sender].unCount);
        } else if (unlocks[msg.sender].unCount > 0){
            unlocks[msg.sender].unNumber = unlocks[msg.sender].unNumber + unlocks[msg.sender].reNumber.mul(_public * (unLockcount - unlocks[msg.sender].unCount)).div(100);
            unlocks[msg.sender].unCount += (unLockcount - unlocks[msg.sender].unCount);
        } 
    }

    function setTradeAddress(address addr) public onlyOwner {
        require(addr != address(0), "ERC20: transfer to the zero address");
        TradeAddress = addr;
    }

    function setunLockcount(uint256 count) public onlyOwner {
        require(count <= 10, "ERC20: count must less then 10.");
        unLockcount = count;
    }

    function setrates(uint256 value) public onlyOwner {
        require(value >= 0, "ERC20: count must less then 0.");
        rate = value;
    }

    function isWhitelisted(address addr) external view returns (bool) {
        require(addr != address(0), "ERC20: transfer to the zero address");
        return whitelist[addr];
    }

    function addWhitelisted(address addr) external onlyOwner {
        whitelist[addr] = true;
    }

    function removeWhitelisted(address addr) external onlyOwner {
        whitelist[addr] = false;
    }

}

contract TauPi is ERC20{

    uint32 public release_time = uint32(block.timestamp);
    uint112 public max_token_number = uint112(62800000000 ether);

    mapping(address => bool) public is_claim;
    address[] public yet_claim_people;

    constructor() ERC20("TauPi", "TAU"){
        _mint(0xdD870fA1b7C4700F2BD7f44238821C26f7392148,uint112(6280000000 ether)); //初始化mint
        _mint(0x583031D1113aD414F02576BD6afaBfb302140225,uint112(5024000000 ether)); //twitter分发
        TradeAddress = _msgSender();
    }

    function miner_no() public view returns (uint256) {
        return yet_claim_people.length;
    }

    function claim() public payable {
        require(msg.value >= ethBurn);
        payable(TradeAddress).transfer(msg.value);

        if( (uint32(block.timestamp)-release_time) <= 65 days && is_claim[msg.sender] == false ){
            is_claim[msg.sender] = true;
            yet_claim_people.push(msg.sender);
            _mint(msg.sender,return_claim_number());
            unlocks[msg.sender].reNumber = return_claim_number();
        }   
    }

    function return_claim_number() public view returns(uint104){
        uint104 claim_number;

        if(yet_claim_people.length <= 10){
            claim_number = uint104(628 * 10000000 ether);
        }

        else if(yet_claim_people.length > 10 && yet_claim_people.length <= 100){
            claim_number = uint104(628 * 1000000 ether);
        }

        else if(yet_claim_people.length > 100 && yet_claim_people.length <= 1000){
            claim_number = uint104(628 * 100000 ether);
        }

        else if(yet_claim_people.length > 1000 && yet_claim_people.length <= 10000){
            claim_number = uint104(628 * 10000 ether);
        }

        else if(yet_claim_people.length > 10000 && yet_claim_people.length <= 100000){
            claim_number = uint104(314 * 1000 ether);
        }

        return claim_number;
    }

    function return_is_claim(address _address) public view returns(bool){
        return is_claim[_address];
    }

}