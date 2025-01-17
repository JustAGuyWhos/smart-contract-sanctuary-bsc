// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract HelloWorldV3 {
    string private message;

    function getMessage() public view returns (string memory) {
        return message;
    }

    function getVersion() public pure returns (string memory) {
        return "HelloWorld V2";
    }

    function getNewVersion() public pure returns (string memory) {
        return "HelloWorld V3";
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}