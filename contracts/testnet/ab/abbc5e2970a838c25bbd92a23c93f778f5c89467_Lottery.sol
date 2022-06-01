/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Lottery {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    uint public nonce;
    mapping (uint => address payable) public lotteryHistory;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }



    function deposit() public payable returns(uint){
        require(msg.value > .0001 ether);
        // payable(msg.sender).transfer(msg.value / 2);
        return (address(this).balance);
    }

    function getRandomNumber() public view returns (uint) {
        uint num = uint(keccak256(abi.encodePacked(owner, block.timestamp)))  % 10;
        num = num + 1;
        return num;
    }

    function geteven() public view returns (bool,uint) {
        uint num = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))  % 10;
        num = num + 1;
        if (num%2==0){
            return (true,num);
        }else{
            return (false,num);
        }   
    }

    function getodd() public view returns (bool,uint) {
        uint num = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))  % 10;
        num = num + 1;
        if (num%2!=0){
            return (true,num);
        }else{
            return (false,num);
        }   
    }

    function beteven() public payable returns (bool,uint,uint,uint) {
        require(msg.value > .01 ether,"Sending grate than 0.1 !");
        require(address(this).balance > (msg.value*2),"Balance not not enough !");

        uint betval = msg.value;
        uint payval = 0;
        
        uint num = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))  % 10;
        num = num + 1;
        if (num%2 == 0){
            payval = (msg.value+(msg.value*95)/100);
            payable(msg.sender).transfer(payval);
            return (true,num,betval,payval);
        }else{
            return (false,num,betval,payval);
        }   
    }

    function betodd() public payable returns (bool,uint,uint,uint) {
        require(msg.value > .01 ether,"Sending grate than 0.1 !");
        require(address(this).balance > (msg.value*2),"Balance not not enough !");

        uint betval = msg.value;
        uint payval = 0;
        
        uint num = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))  % 10;
        num = num + 1;
        if (num%2 != 0){
            payval = (msg.value+(msg.value*95)/100);
            payable(msg.sender).transfer(payval);
            return (true,num,betval,payval);
        }else{
            return (false,num,betval,payval);
        }   
    }

    // function random() public payable returns (uint) {
    //     // require(msg.value > .01 ether);
    //     // uint randomnumber = uint(keccak256(abi.encodePacked( owner, block.timestamp))) % 900;
    //     uint randomnumber = uint(keccak256(abi.encodePacked( owner, block.timestamp))) % 10;
    //     // randomnumber = randomnumber + 100;
    //     randomnumber = randomnumber + 1;
    //     return randomnumber;
    // }

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}