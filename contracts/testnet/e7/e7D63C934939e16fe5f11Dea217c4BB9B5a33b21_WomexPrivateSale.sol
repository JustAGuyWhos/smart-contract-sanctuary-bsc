/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// File: @openzeppelin\contracts\utils\Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts\WomexPrivateSale.sol


pragma solidity ^0.8.0;
contract WomexPrivateSale is Ownable {
    event PurchaseCompleted(
        address account,
        uint256 womexAmount,
        uint256 bnbAmount
    );

    mapping(address => uint256) private accountBalances;
    address[] private allAccounts;
    uint256 private unitBnbAmountAsWomex = 85000;
    uint256 private minBnbAmount = 10000000000000000; //0.01
    bool isSaleActive = true;

    function setSaleActive(bool isActive) public onlyOwner {
        isSaleActive = isActive;
    }

    function setUnitBnbAmount(uint256 amount) public onlyOwner {
        unitBnbAmountAsWomex = amount;
    }

    function setMinBnbAmount(uint256 bnbAmount) public onlyOwner {
        minBnbAmount = bnbAmount;
    }

    function buyWomex() public payable {
        require(isSaleActive == true, "Sale is not active currently");
        require(
            msg.value >= minBnbAmount,
            "The value payable must be greater than the minimum value"
        );

        uint256 womexAmount = unitBnbAmountAsWomex * msg.value;
        accountBalances[msg.sender] += womexAmount;
        allAccounts.push(msg.sender);
        
        emit PurchaseCompleted(msg.sender, womexAmount, msg.value);
    }

    function getAccountList() public view onlyOwner returns (address[] memory) {
        return allAccounts;
    }

    function getAccountByIndex(uint256 index) public view onlyOwner returns (address) {
        return allAccounts[index];
    }

    function getAccountListLength() public view onlyOwner returns (uint256) {
        return allAccounts.length;
    }

    function getUnitBnbAmountAsWomex() public view returns (uint256) {
        return unitBnbAmountAsWomex;
    }
    

    function getMinBnbAmount() public view returns (uint256) {
        return minBnbAmount;
    }

    function getAccountBalance(address account)
        public
        view
        returns (uint256)
    {
        return accountBalances[account];
    }

    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}