/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contract {

    address public manager;         // manager
    IERC20 public lpToken;          // token contract

    uint256 _stakeOperate = 1;
    uint256 _unstakeOperate = 2;
    struct Record { uint256 o; uint256 n; uint t; }
    mapping (address => Record[]) _stakes;

    constructor(IERC20 _lpToken) {
        lpToken = IERC20(_lpToken);
        manager = msg.sender;
    }

    /*
     * batch erc20 transfer
     */
    function batchErc20Transfer(address[] memory tos, uint256[] memory amounts) public onlyManagerCanCall {
        require(tos.length > 0, "the addresses is empty !!");
        require(amounts.length > 0, "the amount is empty !!");
        require(tos.length == amounts.length, "the max need greater min !!");

        for( uint i = 0; i < tos.length; i++ ) {
            lpToken.transferFrom(msg.sender, tos[i], amounts[i]);
        }
    }

    // ------------------------------------------------------------------------------------------------------

    /*
     * stake
     */
    function stake(uint256 _amount) public {
        require(lpToken.balanceOf(msg.sender) > _amount, "the balanceOf address is not enough !!");

        lpToken.transferFrom(msg.sender, address(this), _amount);
        _stakes[msg.sender].push(Record(_stakeOperate, _amount, block.timestamp));
    }

    /*
     * unStake
     */
    function unstake(uint256 _amount) public {

        uint256 _total = 0;
        Record[] memory records = _stakes[msg.sender];
        for( uint i = 0; i < records.length; i++ ) {
            Record memory r = records[i];
            if (r.o == _stakeOperate) {
                _total = _total + r.n;
            } else if (r.o == _unstakeOperate ) {
                _total = _total - r.n;
            } 
        }

        require(_total >= _amount, "the stake amount is not enough !!");
        require(lpToken.balanceOf(address(this)) > 0, "the balanceOf contract is not enough !!");

        lpToken.transfer(msg.sender, _amount);
        _stakes[msg.sender].push(Record(_unstakeOperate, _amount, block.timestamp));
    }

    /*
     * amount of stake
     */
    function stakeOf(address account) external view returns (Record[] memory) {
        return _stakes[account];
    }

    // ------------------------------------------------------------------------------------------------------

    /*
     * deposit
     */
    function deposit(uint256 amount) public onlyManagerCanCall {
        require(lpToken.balanceOf(msg.sender) > amount, "the balanceOf address is not enough !!");

        lpToken.transferFrom(msg.sender, address(this), amount);
    }

    /*
     * send
     */
    function send(address to, uint256 amount) public onlyManagerCanCall {
        require(lpToken.balanceOf(address(this)) > 0, "the balanceOf contract is not enough !!");

        lpToken.transfer(to, amount);
    }

    // ------------------------------------------------------------------------------------------------------

    /*
     * only manager
     */
    modifier onlyManagerCanCall() {
        require(msg.sender == manager);
        _;
    }
    
    /*
     * random
     */
    function random(uint256 _length) internal view returns(uint256) {
        uint256 r = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return r % _length;
    }

}