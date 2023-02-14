// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Presale is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public transactionCount;
    Counters.Counter public buyers;
    uint256 public totalTokenPurchased;
    uint256 totalAmountSent;
    address payable reciever;
    uint256 public deadline;
    uint256 public startTime;

    struct Buyer {
        address buyer;
        uint256 tokensPurchased;
        uint256 counter;
    }

    mapping(address => Buyer) public userAccounts;
    mapping(uint256 => address) public buyersCount;

    event purchaseStarted(uint256, uint256, uint256, string);
    event TransactionHandler(address, uint256);

    modifier _notExpired() {
        require(block.timestamp < deadline, "Purchase timing has expired");
        _;
    }

    function startPurchase(uint256 _duration) public onlyOwner {
        require(_duration > 0, "Duration must be greater than zero");
        startTime = block.timestamp;
        deadline = startTime + _duration * 1 minutes;
        emit purchaseStarted(
            startTime,
            deadline,
            _duration,
            "Election has been started by the admin"
        );
    }

    function hasElapsed() public view returns (bool) {
        return deadline > block.timestamp;
    }

    constructor() {
        reciever = payable(msg.sender);
    }

    function _setReciever(address payable _reciever) public onlyOwner {
        reciever = _reciever;
    }

    function sendBNB(uint256 _amountOfTokens) public payable _notExpired {
        require(
            _amountOfTokens > 0,
            "Token to purchase must be greater than zero"
        );
        require(msg.value > 0, "Amount deposited must be greater than zero");
        (bool sent, bytes memory data) = reciever.call{value: msg.value}("");
        require(sent, "Failed to send BNB");
        totalTokenPurchased += _amountOfTokens;
        totalAmountSent += msg.value;
        transactionCount.increment();

        if (userAccounts[msg.sender].tokensPurchased == 0) {
            buyers.increment();
            uint256 count = buyers.current();
            buyersCount[count] = msg.sender;
        }

        userAccounts[msg.sender].tokensPurchased += _amountOfTokens;
        userAccounts[msg.sender].counter++;
        userAccounts[msg.sender].buyer = msg.sender;

        emit TransactionHandler(msg.sender, _amountOfTokens);
    }

    // get all transaction list

    function getAllTransactions() public view returns (Buyer[] memory) {
        uint256 _count = buyers.current();
        Buyer[] memory allBuyers = new Buyer[](_count);
        for (uint256 i = 0; i < _count; i++) {
            Buyer storage _buyer = userAccounts[buyersCount[i + 1]];
            allBuyers[i] = _buyer;
        }

        return allBuyers;
    }
}