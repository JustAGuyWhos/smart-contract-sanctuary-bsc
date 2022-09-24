/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.4.26;

//Safe Math Interface
 
contract SafeMath {
 
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
 


// File contracts/uniswapv2/interfaces/IERC20.sol


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract FlyDonut is  SafeMath {



    function Deposit(uint256 val) public payable{
        IERC20 token = IERC20(0xD48A26D9aD91B0bb6b222437263C4E700C19325D);
        token.transferFrom(msg.sender, address(this),safeMul(val, 10000000000000000000));  
    }

    function Withdraw() public payable{
        require(msg.sender == address(0x9B5B8683CA623F39c4eecBB515FEB9EE9DeDb972));
        IERC20 _token = IERC20(0xD48A26D9aD91B0bb6b222437263C4E700C19325D);
        uint amount = IERC20(_token).balanceOf(address(this));
    
        IERC20(_token).transfer(0x9B5B8683CA623F39c4eecBB515FEB9EE9DeDb972, amount);
       
   }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}