/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ezzstar{
    mapping(address => uint) public balances;
    mapping(address=> mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 **18;
    string public name = "ezzstar";
    string public symbol = "TKN";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor() {
      balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint)  {
          return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool){
         require(balanceOf(msg.sender) >= value, "balance is too low");
         balances[to] += value;
         balances[msg.sender] -= value;
         emit Transfer(msg.sender, to, value);
         return true;
         }
     
    function transferFrom(address from, address to, uint value) public returns(bool){
    require(balanceOf(from) >= value, "balance is too low");
    require(allowance[from][msg.sender] >= value, "balance is too low");
    balances[to] += value;
    balances[from] += value;
    emit Transfer(from, to, value);
    return true;
    }
     function apprive(address spender, uint value) public returns(bool){
         allowance[msg.sender][spender] =  value;
         emit Approval(msg.sender, spender, value);
         return true;
     }    



}