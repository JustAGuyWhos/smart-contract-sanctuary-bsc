/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract Darkie{
string public welcome = "hello";
uint256 result;

function add(uint256 a, uint256 b) public returns (uint256) {
    return result = a + b;
}    
function sub(uint256 a, uint256 b) public returns (uint256) {
    return result = a - b;
}

function multiply(uint256 a, uint256 b) public returns (uint256) {
    return result = a * b;
}

function divide(uint256 a, uint256 b) public returns (uint256) {
    return result = a / b;
}

function mode(uint256 a, uint256 b) public returns (uint256) {
    return result = a % b;
}

function getResult() public view returns (uint256) {
    return result;
}
}