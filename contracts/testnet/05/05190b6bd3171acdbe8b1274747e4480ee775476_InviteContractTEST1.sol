/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactionInfos the account sending and
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
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract InviteContractTEST1 is Ownable {

    mapping(address => address) public referrals;
    // 用户的邀请数量
    mapping(address => uint256) public referrCount; 

    event Invite(address indexed _inviter);

    function bind(address _inviter) public {
        require(_inviter != address(0),"input address is a zero address");
        require(referrals[msg.sender] == address(0),"This account has been bound to an inviter");
        referrals[msg.sender] = _inviter;
        referrCount[_inviter]++;
        emit Invite(_inviter);
    }

    function resetReferrals(address _invitee, address _newInviter) public onlyOwner {
        require(_invitee != address(0) && _newInviter != address(0),"invitee address and inviter address is a zero address");
        referrCount[referrals[_invitee]]--;
        referrals[_invitee] = _newInviter;
        referrCount[_newInviter]++;
        emit Invite(_newInviter);
    }

    function getInviter(address user) public view returns(address) {
        return referrals[user];
    }

    function getMyReferrCount(address user) public view returns(uint256) {
        return referrCount[user];
    }
}