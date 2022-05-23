/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: MIT

// class

pragma solidity ^0.6.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// class

pragma solidity ^0.6.12;
contract Ownable is Context {
    address private  _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// class

pragma solidity ^0.6.12;

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

// class

pragma solidity ^0.6.12;

contract Airdropper is Ownable {

    function AirTokenTransfer(address[] memory _recipients, uint[] memory _values, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0, "recipients len should big than 0");
        require(_values.length > 0, "_values len should big than 0");
        require(_recipients.length == _values.length, "recipients len should equal to values len");

        IERC20 token = IERC20(_tokenAddress);

        uint256 decimals = 1 * (10**18);

        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values[j]*decimals);
        }

        return true;
    }

    // _values[j] is the real transfer bnb amount * 1000
    function AirBNBTransfer(address [] memory _recipients, uint[] memory _values) onlyOwner public returns (bool) {
        require(_recipients.length > 0, "recipients len should big than 0");
        require(_values.length > 0, "_values len should big than 0");
        require(_recipients.length == _values.length, "recipients len should equal to values len");

        uint256 decimals = 1 * (10**15);

        for(uint j = 0; j < _recipients.length; j++){
            uint256 BNBAmount = address(this).balance;
            uint256 transferAmt = _values[j]*decimals;
            if (BNBAmount >= transferAmt) {
                payable(_recipients[j]).transfer(transferAmt);
            }
        }

        return true;
    }

    function withdrawalToken(address _tokenAddress, address payable _recipient) onlyOwner public { 
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenAmt = token.balanceOf(address(this));
        token.transfer(_recipient, tokenAmt);
    }

    function withdrawalBNB(address payable _recipient) onlyOwner public { 
        uint256 BNBAmount = address(this).balance;
        _recipient.transfer(BNBAmount);
    }

}