/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.4.22<0.8;

contract Cal{
    int private result;

    function add(int a,int b) public returns(int c){
        result=a+b;
        c=result;
    }

    function min(int a,int b) public returns(int){
        result=a-b;
        return result;
    }

    function mul(int a,int b) public returns(int){
        result=a*b;
        return result;
    }

    function div(int a,int b) public returns(int){
        result=a/b;
        return result;
    }

    function getResult() public view returns(int){
        return result;
    }
}