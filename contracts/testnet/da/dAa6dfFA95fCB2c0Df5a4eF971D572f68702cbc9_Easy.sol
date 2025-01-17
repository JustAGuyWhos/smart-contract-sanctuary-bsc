/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

contract Easy {
    
    
    uint public b;
    
    address public tokenAddress;
    address public owner;
    address public manager;

    
    
    constructor(address tokenAddress_, address manager_){
        owner = msg.sender;
        manager = manager_;
        b = 1e18;
        tokenAddress=tokenAddress_;
    }
    
    // Define onlyOwner modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not admin");
        _;
    }

    // Define onlyOwnerOrManager modifier
    modifier onlyOwnerOrManager() {
        require(msg.sender == owner || msg.sender == manager, "You are not admin or manager");
        _;
    }

    function transferManager(address newManger) public onlyOwner {
        require(newManger != address(0), "manager cannot be null");
        manager = newManger;
    }
    
    function setb(uint b_) public onlyOwnerOrManager {
        b = b_;
    }
    
    function settoken(address tokenAddress_) public onlyOwnerOrManager {
        tokenAddress=tokenAddress_;
    }
    
    function payOut(address[] memory winner, uint total) public onlyOwnerOrManager {
        IERC20 token = IERC20(tokenAddress);
        for (uint i=0; i<total; i++) {
            require(token.transfer(winner[i], b), "Token transfer failed");
        } 
        
    }
     
    function payOutDifferentAmount(address[] memory winner,uint[] memory amount_, uint total) public onlyOwnerOrManager {
        IERC20 token = IERC20(tokenAddress);
        for (uint i=0; i<total; i++) {
            require(token.transfer(winner[i], amount_[i]*b), "Token transfer failed");
        } 
        
     }
    
 }