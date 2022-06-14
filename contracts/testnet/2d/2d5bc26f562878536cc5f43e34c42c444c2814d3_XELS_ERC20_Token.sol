// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";

contract XELS_ERC20_Token is ERC20 {
    constructor(uint256 initialSupply) ERC20("BEP-20 Token", "BEPTEST") {
        _maxTokenCountSet(initialSupply);
        _mint(msg.sender, initialSupply);

    }

    function BurnToken(address account, uint256 amount) public virtual returns (bool) {
        _burn(account, amount);
        return true;
    }
}