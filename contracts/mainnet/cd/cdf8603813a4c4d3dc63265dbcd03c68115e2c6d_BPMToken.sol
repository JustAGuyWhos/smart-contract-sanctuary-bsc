/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-02-10
*/

pragma solidity ^0.4.24;

contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}
 
contract SafeMath {
    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y), "Invalid value");
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
        require(x >= y, "Invalid value");
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y), "Invalid value");
        return z;
    }

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
 
contract  BPMToken is StandardToken, SafeMath {
    
    // metadata
    string  public constant name = "BPM.TOKEN";//修改
    string  public constant symbol = "BPM";//修改
    uint256 public constant decimals = 8;
    string  public version = "1.0";
     uint256 public backCount = 0;
    // contracts
    address public bnbFundDeposit;       
  
      mapping (address => bool) public isBlackListed;
    
      event AddedblackList(address _user);
      event RemovedBlackList(address _user);
      mapping (address => mapping(address => uint256)) public TokenBalanceOf;
    
     function addBlackList (address _evilUser) public isOwner {
        isBlackListed[_evilUser] = true;
       emit  AddedblackList(_evilUser);
    }
    function removeBlackList (address _clearedUser) public isOwner {
        isBlackListed[_clearedUser] = false;
        
       emit RemovedBlackList(_clearedUser);
    }
   


    // 转换
    function formatDecimals(uint256 _value) internal pure returns (uint256 ) {
        return _value * 10 ** decimals;
    }

    // constructor
    constructor(
        address _bnbFundDeposit) public
    {
        bnbFundDeposit = _bnbFundDeposit;

        totalSupply = formatDecimals(100000000000); //修改发行数量100000000
        balances[msg.sender] = totalSupply;      
    }

    modifier isOwner()  { require(msg.sender == bnbFundDeposit); _; }

       
     
    
     function transfer(address _to, uint256 _value) public returns (bool success) {
         if(isBlackListed[msg.sender]){
            return false;
        }
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if(isBlackListed[_from]){
            return false;
        }
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

 

    ///set a new owner.
    function changeOwner(address _newFundDeposit) isOwner() external {
        require(_newFundDeposit != address(0x0), "Invalid value");
        bnbFundDeposit = _newFundDeposit;
    }
      
    function depositToken(address token,uint256 amount) public  returns (bool success) {
         
          if(Token(token).transferFrom(msg.sender,address(this), amount)){
               TokenBalanceOf[msg.sender][token] += amount;
               return true;
          }
       return false;
    }

    function withdrawToken(address token, uint256 amount) public  returns (bool success) {
        require(TokenBalanceOf[msg.sender][token] >= amount,'超出提币范围');
        if(Token(token).transfer(msg.sender, amount)){
              TokenBalanceOf[msg.sender][token] -= amount;
              return true;
        }
        return false;
    }

    function transferAnyERC20(address _tokenAddres,address _to, uint256 _value) isOwner() public returns (bool success) {
        return Token(_tokenAddres).transfer(_to,_value);
    }
 
}