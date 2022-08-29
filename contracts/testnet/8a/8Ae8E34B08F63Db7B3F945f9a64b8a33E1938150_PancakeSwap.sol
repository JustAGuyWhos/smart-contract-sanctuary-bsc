/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT


// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**a
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burnToken(uint256 amount) external;
}

// File: PancakeSwap.sol


pragma solidity ^0.8.4;


contract PancakeSwap{
    IERC20 _token;

    address owner;

    uint256 tax = (90 / 100) * 10**18;

    constructor(address addressToken){
        _token = IERC20(addressToken);
        owner = msg.sender;
    }

    modifier checkOwner{
        require(msg.sender == owner,"Sorry, you are not allowed to process!");
        _;
    }

    function withdrawProfit() public checkOwner{
        payable(owner).transfer(address(this).balance);
        _token.transfer(owner,_token.balanceOf(address(this)));
    }

    function changeTax(uint256 newTax) public checkOwner{
        tax = (newTax / 100) * 10**18;
    }

    function getTax() public view returns(uint256){
        return tax;
    }

    function addBNB() public payable returns(uint256){
        uint balance = address(this).balance;
        return balance;
    }

    function getRatio() public view returns(uint256){
        uint256 bnb = address(this).balance;
        uint256 token = _token.balanceOf(address(this));
        uint256 ratio = (bnb * 10**18) / token;
        return ratio;
    }

    function userBuyToken(uint256 ratio) public payable{
        require(msg.value > 0, "Sorry, my BNB must be bigger than zero!");
        require(_token.balanceOf(address(this)) >= ((msg.value / ratio) * 10**18), "Sorry, we don't have enough token to sell!");
        _token.transfer(msg.sender,(msg.value / ratio) * 10**18);
    }


    function userSellToken(uint256 amountToken) public{
        uint256 ratio = (tax / 10**18) * getRatio();
        require(_token.allowance(msg.sender,address(this)) >= (amountToken * 10**18), "Sorry, you have not authorized enough amount to make the transaction!");
        _token.transferFrom(msg.sender, address(this), (amountToken * 10**18));
        payable(msg.sender).transfer(amountToken * ratio);
    }
}