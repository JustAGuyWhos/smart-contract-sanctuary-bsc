pragma solidity 0.8.4;

import "./IBEP20.sol";

contract PurchaseToken {

    address  Owner;
    IBEP20 public MyToken;
    uint256 public price;
    address tokenAddress;

    mapping(address=>uint) public balances;

    modifier onlyOwner {
        require(msg.sender == Owner);
        _;
    }
    constructor (address _tokenAddress) {
        tokenAddress = _tokenAddress;
        Owner = msg.sender;
        price = 0.1 ether;
    }

    function setPrice(uint newPrice)  public onlyOwner  { 
        // Add condition on the new price
        price = newPrice;

    } 
    function buyToken(uint amount) payable public {
        require(msg.sender.balance >= amount ,'Not enough Balance');
        uint numberOfTokens = msg.value * price;
        require(MyToken.balanceOf(Owner)>= numberOfTokens,'Not enough Balance');
        require(MyToken.allowance(Owner,address(this)) >= numberOfTokens,"need to approve token first");
        payable(address(this)).transfer(amount);
        MyToken.transferFrom(Owner, msg.sender,numberOfTokens);

    } 
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

// BEP20 Hardhat token = 0x5FbDB2315678afecb367f032d93F642f64180aa3
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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