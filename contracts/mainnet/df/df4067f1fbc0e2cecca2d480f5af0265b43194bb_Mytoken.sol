/**
 *Submitted for verification at BscScan.com on 2022-10-24
*/

pragma solidity 0.8.17;

contract Mytoken {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public decimals = 18;
    string public symbol = "AntiA";
    string public Name = "AntiA Token";
    uint public totalSubply = 1500000* 10 ** 18;

    constructor() {
        balances[msg.sender] = totalSubply;
    }  
    event TransferValue(address indexed from, address indexed to, uint value);
    event Approval(address indexed from, address indexed to, uint value);
 
    function balanceOf(address reciever) public view returns(uint){
        return balances[reciever];
    }
 
    function transfer(address sendto, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value,'balance too low');
        balances[sendto] += value;
        balances[msg.sender] -= value;
        emit TransferValue(msg.sender, sendto, value);    
        return true;
    }
    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender,value);
        return true;
    }
    function transferFrom (address sender, address reciever, uint value) public returns(bool){
        require(balanceOf(sender) >= value, 'blance too low');
        require(allowance[sender][msg.sender] >= value, 'allowance to low');
        balances[reciever] += value;
        balances[sender] -= value;
        emit TransferValue(sender, reciever, value);
        return true;
    }
}