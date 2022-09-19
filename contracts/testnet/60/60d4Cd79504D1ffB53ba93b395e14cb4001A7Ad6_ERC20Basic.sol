/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity^0.8.7;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC20Basic is IERC20 {
    
    string public constant name = "ERC20Basic";
    string public constant symbol = "ERC";
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 public totalSupply_=10**40;
    address public _owner;
    uint8 public _decimals = 5;
    constructor( ){
    _owner = msg.sender;    
    balances[msg.sender]=totalSupply_;
    }
    function decimals() public override view returns(uint256){
        return _decimals;
    }
    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }
    function balanceOf(address tokenOwner) external override view returns (uint256) {
        return balances[tokenOwner];
    }
  
    function transfer(address receiver, uint256 numTokens) external override returns (bool) {
        require(numTokens <= balances[msg.sender],"Not enough ethers ");
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    function approve(address spender, uint256 numTokens) external override returns (bool) {
       //require( _owner == msg.sender,"only owner can approve the spender ");
        allowed[msg.sender][spender] = numTokens;
        emit Approval(msg.sender, spender, numTokens);
        return true;
    }
    function allowance(address owner, address spender) external override view returns (uint) {
        return allowed[owner][spender];
    }                  
    function transferFrom(address owner, address buyer, uint256 numTokens) external override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}