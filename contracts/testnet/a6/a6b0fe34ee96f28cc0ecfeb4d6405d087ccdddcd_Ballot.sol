/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Ballot {

    string name;

    constructor (){
        

    }

    function setName(string memory _name)external{
        name = _name;
    }    

    function getName()external view returns(string memory){
        return name;
    }   
}