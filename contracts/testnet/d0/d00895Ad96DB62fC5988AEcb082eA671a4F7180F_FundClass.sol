/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

//SPDX-License-Identifier: MIT
pragma solidity^0.8.4;
contract FundClass{

    address public owner;
    Student[] public arrayStudents;

    struct Student{
        address Account;
        uint Amount;
        string Content;
    }
    constructor () {
        owner = msg.sender;
    }
    modifier checkOwner (){
        require (msg.sender == owner, "Sorry you are not owner");
        _;
    }
    function withdraw() public checkOwner() {
        
        payable(owner).transfer(address(this).balance);
    }

    function sendDonate( string memory content ) public payable {
        require (msg.value>=10**15, "Sorry minimum BNB is 0.0001");
        arrayStudents.push(Student(msg.sender, msg.value, content));
    }
    function studenCounter ()  public view returns (uint) {
        return arrayStudents.length;
    }
    function get_1_student (uint ordering) public view returns (address, uint, string memory) {
        require (ordering < arrayStudents.length);
        return (arrayStudents[ordering].Account, arrayStudents[ordering].Amount, arrayStudents[ordering].Content);
    }
    
}