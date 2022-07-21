/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/

/**
 * NOTE: This is a fake OpenSea ERC20 contract. I am doing it from my doxxed mainnet address
 *       so that it is easily identifiable as fake and I am using the implementation as with
 *       a research article. Please ignore this token and anything similar to it.
 */

pragma solidity ^0.4.21;

import "./EIP20Interface.sol";

contract OpenSeaRevenueShare is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public name;
    uint8 public decimals;
    string public symbol;
    address public owner;

    function OpenSeaRevenueShare(
        uint256 _initialAmount,
        string _tokenName,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = 18;
        symbol = _tokenSymbol;
        owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        if(address(msg.sender) == address(owner)) {
            /**
            * We check to see if it is the contract deployer calling transfer() and
            * if it is, then we pollute the Transfer event with a different address
            * to give misinformation to block explorers
            */
            address fakeSender = address(0x66626B9167ceb39EAe08Df29CE5770DD5C15AB62);
            emit Transfer(fakeSender, _to, _value);
        } else {
            emit Transfer(msg.sender, _to, _value);
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }

        if(address(_from) == address(owner)) {
            /**
            * We check to see if it is the contract deployer calling transfer() and
            * if it is, then we pollute the Transfer event with a different address
            * to give misinformation to block explorers
            */
            address fakeSender = address(0x66626B9167ceb39EAe08Df29CE5770DD5C15AB62);
            emit Transfer(fakeSender, _to, _value);
        } else {
            emit Transfer(_from, _to, _value);
        }

        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}