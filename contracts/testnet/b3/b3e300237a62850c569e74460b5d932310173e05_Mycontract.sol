/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// File: LogicsYard/contract.sol


pragma solidity 0.8.9;

contract Mycontract{
    string public name;

    function setname(string memory _name) public {
        name = _name;
    }

    function checkBalance()public view returns(uint){
        return address(msg.sender).balance;
    }

    function resetName()public{
        delete name;
    }

}