// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import "hardhat/console.sol";

contract CryptoWorldSorteios is Ownable, ReentrancyGuard{
    address cryptoWorldContract;

    struct Account 
    {
        address accountAddress;
        uint256 totalReceivable;
        bool exist;
    }

    address[] players;

    uint256 valueTransferContract;
    uint256 premiumAmount;

    uint256 entryValue;
    uint256 participantsLimit;

    mapping(address => Account) accMapping;

    constructor(address _cryptoWorldContract) ReentrancyGuard()
    {
        cryptoWorldContract = _cryptoWorldContract;

        entryValue = 0.001 ether;
        participantsLimit = 50;
    }


    function goodLuck() external payable
    {
        address msgSender = _msgSender();
        require(msg.value == entryValue, "Incorrect input value");

        players.push(msgSender);

        premiumAmount += (entryValue / 100) * 30;
        valueTransferContract += (entryValue / 100) * 50;
        _distributeCommissionsToExistingAddress(msgSender);

        if(participantsLimit == players.length)
        {
            address winner = players[_randomTest() % players.length];

            _sendMoney(winner, premiumAmount);

            players = new address[](0);
            premiumAmount = 0;

            ICryptoWorldSorteios(cryptoWorldContract).donation{value: valueTransferContract}();
            valueTransferContract = 0;
        }
    }

    function _randomTest() private view returns(uint256 randomValue)
    {
        randomValue = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.difficulty,
            players
        )));
    }

    function _distributeCommissionsToExistingAddress(address msgSender) private
    {
        address _address = address(0);

        _address = _getAccountCryptoWorld(msgSender);

        if(_address != address(0))
        {
            if(!accMapping[_address].exist)
            {
                _addAccount(_address);
            }
            accMapping[_address].totalReceivable += (entryValue / 100) * 9;

            for (uint16 i = 0; i < 11; i++)
            {
                _address = _getAccountCryptoWorld(_address);

                if(!accMapping[_address].exist)
                {
                    _addAccount(_address);
                }

                accMapping[_address].totalReceivable += entryValue / 100;
            }
        }
    }

    function _addAccount(address _address) private {
        Account memory acc = Account({
            accountAddress: _address,
            totalReceivable: 0,
            exist: true
        });

        accMapping[_address] = acc;
    }

    function withdraw() external nonReentrant
    {
        _withdraw();
    }
    
    function _withdraw() private
    {
        address msgSender = _msgSender();

        require(accMapping[msgSender].exist, "Restricted to Crypto World participants");

        uint256 value = accMapping[msgSender].totalReceivable;
        accMapping[msgSender].totalReceivable = 0;
        payable(msgSender).transfer(value);
    }

    function _sendMoney(address to, uint256 value) private {
        address payable receiver = payable(to);
        receiver.transfer(value);
    }

    function _getAccountCryptoWorld(address _address) private view returns (address account)
    {
        account = ICryptoWorldSorteios(cryptoWorldContract).getAccount(_address);
    }

    function GetEntryValue() public view returns (uint256)
    {
        return entryValue;
    }

    function setEntryValue(uint256 newEntryValue) public onlyOwner
    {
        entryValue = newEntryValue;
    }

    function GetParticipantsLimit() public view returns (uint256)
    {
        return participantsLimit;
    }

    function setParticipantsLimit(uint256 newParticipantsLimit) public onlyOwner
    {
        participantsLimit = newParticipantsLimit;
    }

    function GetValueTransferContract() public view returns (uint256)
    {
        return valueTransferContract;
    }

    function GetPremiumAmount() public view returns (uint256)
    {
        return premiumAmount;
    }

    function GetPlayers() public view returns (address[] memory playersInGame)
    {
        playersInGame = players;
    }

    function renounceOwnership() public virtual override onlyOwner
    {
        revert("RenounceOwnership: property cannot be surrendered");
    }
}

interface ICryptoWorldSorteios
{
    function getAccount(address _address) external view returns (address referrerAccount);
    function donation() external payable;
}

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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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