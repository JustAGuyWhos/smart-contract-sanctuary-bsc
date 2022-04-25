/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

pragma solidity ^0.8.10;

//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}  

contract airDrop{
    
    using SafeMath for uint256;  

    address payable public owner;
    IBEP20 public token;
    uint256 public fee = 0.008 ether;
    uint256 public claimAmount; 
    uint256 public startTime;
    uint256 public endTime;
    uint256 public amountRaised; 
    uint256 public claimedTokens;
    
    modifier onlyOwner(){
        require(msg.sender == owner,"not an owner");
        _;
    } 
    
    event Claimed(address _user);
    
    constructor(address payable _owner,address _token) {
        owner = _owner;
        token = IBEP20(_token);  
        claimAmount = 15000 * 1e9; 
        startTime = block.timestamp;
        endTime = block.timestamp + 30 days ;
    }
    
    receive() payable external{}
    
    function claimAirDrop() public payable {  
        require(msg.value >= fee,"fee per claim is $3"); 
        require(block.timestamp >= startTime && block.timestamp <= endTime,"time over");
        
        token.transferFrom(owner, msg.sender, claimAmount);
        
        amountRaised = amountRaised.add(msg.value);
        claimedTokens = claimedTokens.add(claimAmount);
        
        emit Claimed(msg.sender);
    }
 
    
    function setAirDrop(uint256 _startTime, uint256 _endTime, uint256 _claimAmount) external onlyOwner{
        startTime = _startTime;
        endTime = _endTime;
        claimAmount = _claimAmount; 
    }
    function setToken(address newtoken) public onlyOwner{
        token = IBEP20(newtoken);
    }
     
    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner{
        owner = _newOwner;
    }
      // change fee
    function changeFee(uint256 _fee) external onlyOwner{
        fee = _fee;
    }
    
    // to draw funds
    function transferFunds(uint256 _value) external onlyOwner{
        owner.transfer(_value);
    }
    
    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }
    
    function contractBalanceBnb() external view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() external view returns(uint256){
        return token.allowance(owner, address(this));
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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