// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

contract UpgradesTest {
    uint256 private value;

    event ValueChanged(uint256 newValue);

    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}