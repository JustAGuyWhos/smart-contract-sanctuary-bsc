/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

contract EventEmitter {
    // event Deposit(uint datetime, address contractaddress, uint rate, uint depositAmount, uint shares);
    event _Withdraw(uint datetime, address contractaddress, uint rate, uint avrCost, uint withdrawAmount, uint shares);
    event FundActivity(string _type, address contractaddress,uint rate, uint avrCost, uint amount, uint shares);

    uint256 rate = 1201687294958178480; // 1.2

    constructor () {
    }

  function newFundActivity(uint256 amount) public {
        uint256 shares = rate * amount / 1e18;
        uint cost = 0;
       emit FundActivity('deposit', address(this), rate, cost, amount, shares);
    }


    // function makeDeposit(uint256 amount) public {
    //     uint256 mintQty = rate * amount / 1e18;
    //     emit Deposit(block.timestamp, address(this), rate, amount, mintQty);
    // }

    function makeWithdraw(uint256 amount) public {
        uint256 averagePrice = 0; // cause user doesnt pay anything to deposit
        uint256 finalSwapOutput = amount;
        emit _Withdraw(block.timestamp, address(this), rate, averagePrice, finalSwapOutput, amount);
    }


    function setRate(uint256 _rate) public {
        rate = _rate;
    }

}