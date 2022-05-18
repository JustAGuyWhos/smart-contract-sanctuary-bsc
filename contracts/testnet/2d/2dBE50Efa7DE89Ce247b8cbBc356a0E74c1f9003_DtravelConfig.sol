// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DtravelConfig is Ownable {
    uint256 public fee; // fee percentage 5% -> 500, 0.1% -> 10
    uint256 public payoutDelayTime; // payout delay time in seconds
    address public dtravelTreasury;
    address public dtravelBackend;
    mapping(address => bool) public supportedTokens;

    event UpdatedFee(uint256 oldFee, uint256 newFee);
    event UpdatedPayoutDelayTime(uint256 oldPayoutDelayTime, uint256 newPayoutDelayTime);
    event UpdatedTreasury(address oldTreasury, address newTreasury);
    event UpdatedBackend(address oldBackend, address newBackend);
    event AddedSupportedToken(address token);
    event RemovedSupportedToken(address token);

    constructor(
        uint256 _fee,
        uint256 _payoutDelayTime,
        address _treasury,
        address[] memory _tokens
    ) {
        fee = _fee;
        payoutDelayTime = _payoutDelayTime;
        dtravelTreasury = _treasury;
        dtravelBackend = msg.sender;
        for (uint256 i = 0; i < _tokens.length; i++) {
            supportedTokens[_tokens[i]] = true;
        }
    }

    function updateFee(uint256 _fee) public onlyOwner {
        require(_fee >= 0 && _fee <= 2000, "Config: Fee must be between 0 and 2000");
        uint256 oldFee = fee;
        fee = _fee;
        emit UpdatedFee(oldFee, _fee);
    }

    function updatePayoutDelayTime(uint256 _payoutDelayTime) public onlyOwner {
        uint256 oldPayoutDelayTime = payoutDelayTime;
        payoutDelayTime = _payoutDelayTime;
        emit UpdatedPayoutDelayTime(oldPayoutDelayTime, _payoutDelayTime);
    }

    function addSupportedToken(address _token) public onlyOwner {
        require(_token != address(0), "Config: token is zero address");
        supportedTokens[_token] = true;
        emit AddedSupportedToken(_token);
    }

    function removeSupportedToken(address _token) public onlyOwner {
        require(_token != address(0), "Config: token is zero address");
        supportedTokens[_token] = false;
        emit RemovedSupportedToken(_token);
    }

    function updateTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "Config: treasury is zero address");
        address oldTreasury = dtravelTreasury;
        dtravelTreasury = _treasury;
        emit UpdatedTreasury(oldTreasury, _treasury);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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