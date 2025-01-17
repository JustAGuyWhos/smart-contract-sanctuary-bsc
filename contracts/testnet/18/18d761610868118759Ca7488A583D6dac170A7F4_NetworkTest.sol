// SPDX-License-Identifier: Unlicensed
pragma solidity  ^0.8.16;

import "./Token.sol";





contract NetworkTest {
    string public name = "Network Miner";
    Token public testToken;
    address public owner;

    

    event AddUser(uint256 id, address indexed user, uint256 indexed amount,uint256 box);

    constructor(Token _testToken)  payable {
        testToken = _testToken;

        //assigning owner on deployment
        owner = msg.sender;
    }

       modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }





    
  
  
  
//    function Deposit(uint256 _amount) public {
//         require(_amount > 0, "amount cannot be 0");
//         testToken.transferFrom(msg.sender, address(this), _amount);
//         // Box1[msg.sender]. +    Box1[msg.sender] + _amount;
//     }


    function test() public {
        uint256 id = 0;
        address user = 0x30412AC7f7F4D4E6D3fdBBF0890461039B32fBC8;
        uint256 amount = 100;
        emit AddUser(id,user,amount,1);
    }


    
}