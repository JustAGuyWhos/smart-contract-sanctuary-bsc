/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

pragma solidity ^0.8.13;
// SPDX-License-Identifier: MIT

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
}


contract Deployer {
    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
    }
  
    function deploy(bytes memory data) public returns(address contractAddress) {
         assembly {
            contractAddress := create(0, add(data, 32), mload(data))
        }
    }

    function chiDeploy(bytes memory data) public discountCHI returns(address contractAddress) {
        assembly {
            contractAddress := create(0, add(data, 32), mload(data))
        }
    }

    function chiDeploy2(uint256 salt, bytes memory data) public discountCHI returns(address contractAddress) {
        assembly {
            contractAddress := create2(0, add(data, 32), mload(data), salt)
        }
    }
}