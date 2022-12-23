/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT
// File: WithoutCond/IERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20Metadata {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 is IERC20Metadata {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: WithoutCond/PoolWC.sol


pragma solidity ^0.8.0;


contract PoolBet{

    address immutable admin;
    IERC20 public immutable token;

    constructor(){
        admin = payable(msg.sender);
        token = IERC20(0x11d1149202fbb7eeeA118BCEb85db1D7eAA3084A);
    }
    

    
    mapping(address => mapping(uint => uint)) public betidToStake;
    mapping(uint => uint) public betIdtoTotal;
    mapping(uint => uint) public betCount;

    uint public adminTotaFee;


    receive() external payable{}
    

    function Stake(uint betid, uint stakeAmount, address staker) public{
            require(msg.sender == staker, "Not Reciever");
            betCount[betid] ++;

             token.transferFrom(staker, address(this), stakeAmount);
             
             betidToStake[staker][betid] += stakeAmount;
             betIdtoTotal[betid] += stakeAmount;
        
    }




    function finalise(uint betid, uint amount, address reciever, uint fee) external{
        require(msg.sender == reciever, "Not Reciever");

         uint stake = betidToStake[reciever][betid];
        uint totalStake = betIdtoTotal[betid];

        require(amount <= totalStake, "IA");//Insufficient amount
        require(stake > 0, "DNS");//DId not stake

    //    payable(reciever).transfer(amount);


        
        delete betidToStake[reciever][betid];
        betIdtoTotal[betid] -= stake;


        token.transfer(reciever, amount);

        // (bool sent,) = payable(reciever).call{value: amount}("");
        // require(sent, "FtsE");

        adminTotaFee += fee;

    }
            
     function adminWithdrawal(uint amount) external{
        require(msg.sender == admin, "Not Admin");
        require(amount <= adminTotaFee, "Insufficient Amount in Balance");

        adminTotaFee -= amount;

        token.transfer(admin, amount);

        
    }
}