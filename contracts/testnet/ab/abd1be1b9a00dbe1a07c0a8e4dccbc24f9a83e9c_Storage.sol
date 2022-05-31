/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Storage {

    uint256 number;

   
    function store(uint256 num) public {
        number = num;
    }

    
    function retrieve() public view returns (uint256){
        return number;
    }
}