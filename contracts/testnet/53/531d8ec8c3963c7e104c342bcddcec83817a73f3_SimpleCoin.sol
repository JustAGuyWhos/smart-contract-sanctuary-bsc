/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract SimpleCoin {

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    address public owner;

    string public name = "Token";
    string public symbol = "TK";
    uint8 public decimals = 8;

    mapping(address => mapping(address => uint)) public allowance;

    //name, symbol, decimals, totalSupply
    //transfer, transferFrom, approve, allowance
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

// Modifier é como se fosse um filtro que vai ser executado para uma função antes do resto da função ou depois.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

// Constructor é uma função especial, ela é executada assim que realizamos o deploy para a BlockChain
    constructor() {

        owner = msg.sender;
        totalSupply = 1_000_000_000 * 10 ** decimals;
        balanceOf[owner]  = totalSupply;

    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(_to != address(0));
        require(_from != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Approval(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        //require(balanceOf[msg.sender] >= _value);
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        
        owner = _newOwner;
    }

    function transfer(address _to,uint256 _value) public returns (bool success){

        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0)); //Não é obrigatorio. 
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

}