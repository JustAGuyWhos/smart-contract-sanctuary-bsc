// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "Ownable.sol";

contract CoinTossGame is Ownable {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;
    enum GAME_STATE {
        OPEN,
        START,
        CLOSED,
        CALCULATING_WINNER
    }
    GAME_STATE public game_state;

    event Status(string _msg, address user, uint256 amount, bool winner);

    function fundTheTreasury() public payable onlyOwner {
        // require(address(this).balance == 0, "Balance is not zero");
        game_state = GAME_STATE.OPEN;
    }

    function playGame() public payable {
        require(game_state == GAME_STATE.OPEN, "The game is not opened yet!");
        //checking game rules
        require(msg.value >= 0, "Entry value should be more than zero!");
        require(
            msg.value < address(this).balance,
            "Entry value should be lower than the contract treasury."
        );
        players.push(msg.sender);
        game_state = GAME_STATE.START;
        calculateWinner(msg.value, msg.sender);
    }

    function calculateWinner(uint256 amount, address sender) internal {
        uint256 prize = amount * 2;
        //if random number is even it will be H
        if (
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) %
                2 ==
            0
        ) {
            players[0].transfer(prize);
            emit Status(
                "Congratulations, you win! twice of your deposited amount is sent to user wallet!",
                sender,
                prize,
                true
            );
        } else {
            emit Status(
                "Unfortunately, you lost! try your chance again",
                sender,
                prize,
                false
            );
        }
        game_state = GAME_STATE.CLOSED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}