/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

pragma solidity 0.8.17;
contract Metapolis {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public decimals = 18;
    string public symbol = "TMC";
    string public name = "Terminus Token";
    uint public totalSupply = 500000000* 10 ** 18;
 constructor() {
        balances[msg.sender] = totalSupply;
    }
 
    event TransferValue(address indexed from, address indexed to, uint value);
    event Approval(address indexed reciever, address indexed spender, uint value);
 
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