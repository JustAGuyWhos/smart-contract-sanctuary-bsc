/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: none

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract MOVENS_SeedVesting {
    
    address private owner;
    address private updater;
    IERC20 public token;
    
    struct Claim{
        uint[] amounts;
        uint[] times;
        bool[] withdrawn;
    }
    
    mapping(address => Claim) claim;
    
    event Claimed(address user,uint amount, uint time);
    event Received(address, uint);
    
    constructor() {
        owner = msg.sender;
    }
     
    function setTokenAddress(address _token) public {
        require(msg.sender == owner, "Only owner");
        token = IERC20(_token);
    }
    
    function updateClaims(address addr, uint[] memory _amounts, uint[] memory _times) public {
        Claim storage clm = claim[addr];
        require(msg.sender == owner || msg.sender == updater, "Permission error");
        require(_amounts.length == _times.length, "Array length error");
        uint len = _amounts.length;
        for(uint i = 0; i < len; i++){
            clm.amounts.push(_amounts[i]);
            clm.times.push(_times[i]);
            clm.withdrawn.push(false);
        }
    }
    
    function updateClaimWithSingleEntry(address[] memory addr, uint[] memory amt, uint[] memory at) public {
        require(msg.sender == owner || msg.sender == updater, "Permission error");
        require(addr.length == amt.length && addr.length == at.length, "Array length error");
        uint len = addr.length;
        for(uint i = 0; i < len; i++){
            claim[addr[i]].amounts.push(amt[i]);
            claim[addr[i]].times.push(at[i]);
            claim[addr[i]].withdrawn.push(false);
        }
    }
    
    function indexValueUpdate(address addr, uint index, uint amount, uint time) public {
        require(msg.sender == owner || msg.sender == updater, "Permission error");
        claim[addr].amounts[index] = amount;
        claim[addr].times[index] = time;
        claim[addr].withdrawn[index] = false;
    }
    
    function setUpdaterAddress(address to) public {
        require(msg.sender == owner, "Only owner");
        updater = to;
    }

    function claimFunction(uint index,address addr) public {
        require(msg.sender == owner, "Permission error");
        uint amt = claim[addr].amounts[index];
        uint time = claim[addr].times[index];
        require(block.timestamp > time, "Time not reached");
        require(token.balanceOf(address(this)) >= amt, "Insufficient amount on contract");
        require(claim[addr].withdrawn[index]==false, "Not bought or already claimed");
        token.transfer(addr, amt);
        claim[addr].withdrawn[index] = true;
        emit Claimed(addr,amt, block.timestamp);
    }
    
    function claimAll() public {
        address addr = msg.sender;
        uint len = claim[addr].amounts.length;
        uint amt = 0;
        for(uint i = 0; i < len; i++){
            if(block.timestamp > claim[addr].times[i] && claim[addr].withdrawn[i]==false) {
                amt += claim[addr].amounts[i];
            }
        }
        require(token.balanceOf(address(this)) >= amt, "Insufficient amount on contract");
        require(amt != 0, "Not bought or already claimed");
        token.transfer(addr, amt);
        for(uint i = 0; i < len; i++){
            if(block.timestamp > claim[addr].times[i]) {
               claim[addr].withdrawn[i] = true;
            }
        }
       
        emit Claimed(addr,amt, block.timestamp);
    }
    
    function userDetails(address addr) public view returns (uint[] memory amounts, uint[] memory times, bool[] memory withdrawn) {
        uint len = claim[addr].amounts.length;
        amounts = new uint[](len);
        times = new uint[](len);
        withdrawn = new bool[](len);
        for(uint i = 0; i < len; i++){
            amounts[i] = claim[addr].amounts[i];
            times[i] = claim[addr].times[i];
            withdrawn[i] = claim[addr].withdrawn[i];
        }
        return (amounts, times, withdrawn);
    }
    
    function userDetailsAll(address addr) public view returns (uint,uint,uint) {
        uint len = claim[addr].amounts.length;
        uint totalAmount = 0;
        uint available = 0;
        uint withdrawn = 0;
        for(uint i = 0; i < len; i++){
            totalAmount += claim[addr].amounts[i];
            if(block.timestamp > claim[addr].times[i] && claim[addr].withdrawn[i]==false){
                available += claim[addr].amounts[i];
            }
            if(claim[addr].withdrawn[i]==true){
                withdrawn += claim[addr].amounts[i];
            }
        }
        return (totalAmount,available,withdrawn);
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    function getUpdater() public view returns (address) {
        return updater;
    }
    
    function claimManually(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        IERC20 token_ = IERC20(tokenAddress);
        token_.transfer(to, amount);
        return true;
    }
    
    function withdrawBNB(address payable to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
        return true;
    }
    
    function ownershipTransfer(address to) public {
        require(to != address(0), "Cannot set to zero address");
        require(msg.sender == owner, "Only owner");
        owner = to;
    }
    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
}