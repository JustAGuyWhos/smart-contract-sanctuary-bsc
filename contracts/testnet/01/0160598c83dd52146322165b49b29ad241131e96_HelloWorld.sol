/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract HelloWorld {

    string name = "nico";

    function getName() public view returns(string memory) {
        return name;
    }

    function f() public pure returns(string memory) {
        return "lili";
    }

    function setName() public {
        name = "dave";
    }
}