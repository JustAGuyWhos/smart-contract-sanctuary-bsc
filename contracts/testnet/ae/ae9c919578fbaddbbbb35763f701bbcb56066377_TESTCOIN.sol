/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.5.17;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/

contract TESTCOIN {
    using SafeMath for uint256;
    
    string public constant name                         = "TESTCOIN";                   	// Name of the token
    string public constant symbol                       = "TC";                            	// Symbol of token
    uint256 public constant decimals                    = 18;                               // Decimal of token
    uint256 public _totalsupply                      	= 500000000 * 10 ** decimals;       // 500 Million Total supply
    uint256 public _distribution                        = 400000000 * 10 ** decimals;       // 400 Million Distribution
    uint256 public _developer                           = 50000000 * 10 ** decimals;        // 50 Million for Developer
    uint256 public _ownership                           = 50000000 * 10 ** decimals;        // 50 Million for Owner
    address public owner                                = msg.sender;                       // Owner of smart contract
   
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint)) public _allowances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed _owner, address indexed spender, uint value);
    

    // Only owner can access the function
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    
    constructor(address ownership, address distributor) public {
        
        // Ownership Transfer
        balances[ownership]            = _ownership;
        emit Transfer(address(this), ownership, _ownership);
         
		// DISTRIBUTION Transfer
        balances[distributor]             = _distribution;
        emit Transfer(address(this), distributor, _distribution);
		
		// DEVELOPER Transfer
        balances[msg.sender]             = _developer;
        emit Transfer(address(this), msg.sender, _developer);
        
	}    
    
    // Show token balance of address owner
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    } 
        
    // Token transfer function
    // Token amount should be in 18 decimals (eg. 199 * 10 ** 18)
    function transfer(address _to, uint256 _amount )external returns (bool) {
        require(balances[msg.sender] >= _amount && _amount >= 0);
        
        balances[msg.sender]            = balances[msg.sender].sub(_amount);
        balances[_to]                   = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    // Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns (bool success) {
        require( _to != 0x0000000000000000000000000000000000000000);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = balances[address(this)].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(this), _to, _amount);
        return true;
    }
    
    function allowance(address _owner, address spender) public view returns (uint) {
        return _allowances[_owner][spender];
    }
    
    function approve(address spender, uint amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        require(balances[sender] >= amount && amount >= 0);
        balances[sender]                = balances[sender].sub(amount);
        balances[recipient]             = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function _approve(address _owner, address spender, uint amount) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    
    function totalSupply() public view returns (uint256 total_Supply) {
        total_Supply = _totalsupply;
    }
         
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
  
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return (value*_quotient/1000000000000000000);
    }
}