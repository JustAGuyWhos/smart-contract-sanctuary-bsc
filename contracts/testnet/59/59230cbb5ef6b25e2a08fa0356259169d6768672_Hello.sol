/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

pragma solidity ^0.4.24;
contract Hello {
   string public name;
   constructor() public {
       name = "我是一個智能合約！";
   }

   function setName(string _name) public {
       name = _name;
   }
}