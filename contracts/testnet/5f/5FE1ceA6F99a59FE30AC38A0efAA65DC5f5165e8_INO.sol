// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/utils/Context.sol';

contract INO is Ownable, Pausable {
    address public _token;
    uint16 public _levelOneRefRate;
    uint16 public _levelTwoRefRate;
    Stage public _stage;

    address[] private _users;
    mapping(address => uint16) private _allocated;
    mapping(address => uint16) private _remainingAllocation;
    mapping(address => mapping(BoxLevel => uint16)) private _bought;
    mapping(BoxLevel => Box) private _boxes;

    enum Stage {
        WHITELISTED,
        PUBLIC
    }
    enum BoxLevel {
        SILVER,
        GOLD,
        DIAMOND
    }

    struct Box {
        uint256 price;
        uint16 totalSupply;
        uint16 stock;
    }

    event Bought(
        address indexed user,
        BoxLevel level,
        uint16 amount
    );

    constructor(
        address token,
        Box memory silverBox,
        Box memory goldBox,
        Box memory diamondBox,
        uint16 levelOneRefRate,
        uint16 levelTwoRefRate
    ) {
        _token = token;
        _boxes[BoxLevel.SILVER] = silverBox;
        _boxes[BoxLevel.GOLD] = goldBox;
        _boxes[BoxLevel.DIAMOND] = diamondBox;
        _levelOneRefRate = levelOneRefRate;
        _levelTwoRefRate = levelTwoRefRate;
        _stage = Stage.WHITELISTED;

        _pause();
    }

    function setAllocations(
        address[] calldata users,
        uint16[] calldata allocations
    ) external onlyOwner {
        require(users.length > 0, "Wrong parameters");
        require(users.length == allocations.length, "Wrong parameters");

        for (uint16 i = 0; i < users.length; i++) {
            _allocated[users[i]] = allocations[i];
            _remainingAllocation[users[i]] = allocations[i];
        }
    }

    function buy(
        BoxLevel level,
        uint16 amount,
        address[] calldata refs
    ) external whenNotPaused {
        require(amount > 0, 'Amount must be greater than zero');
        require(amount <= _boxes[level].stock, 'Not enough stock');

        if (_stage == Stage.WHITELISTED) {
            require(
                amount <= _remainingAllocation[_msgSender()],
                'Amount exceeds remaining allocation'
            );
            _remainingAllocation[_msgSender()] -= amount;
        }

            uint256 totalPrice = _boxes[level].price * amount;
            IERC20 t = IERC20(_token);

            t.transferFrom(_msgSender(), address(this), totalPrice);
            // (uint256 startTokenId, uint256 toTokenId) = ITOP721(_top721Token)
            //     .mintTo(_msgSender(), amount);
            _boxes[level].stock -= amount;
            _bought[_msgSender()][level] += amount;
            _users.push(_msgSender());
        if (refs.length == 2) {
            require(_msgSender() != refs[0] && _msgSender() != refs[1] && refs[0] != refs[1], 'Wrong referral rules');
            t.transfer(refs[0], (totalPrice * _levelOneRefRate) / 10000);
            t.transfer(refs[1], (totalPrice * _levelTwoRefRate) / 10000);
        } else if (refs.length == 1) {
            require(_msgSender() != refs[0], 'Wrong referral rules');
            t.transfer(refs[0], (totalPrice * _levelOneRefRate) / 10000);
        }

        emit Bought(_msgSender(), level, amount);
    }

    function changeStage(Stage stage) external onlyOwner {
        _stage = stage;
    }

    function changeToken(address token) external onlyOwner {
        _token = token;
    }

    /* For FE
        0: token address
        1: stage
            0: WHITELISTED
            1: PUBLIC
        2: silver box
        3: gold box
        4: diamond box
    */
    function info()
        public
        view
        returns (
            address,
            Stage,
            Box memory,
            Box memory,
            Box memory
        )
    {
        return (
            _token,
            _stage,
            _boxes[BoxLevel.SILVER],
            _boxes[BoxLevel.GOLD],
            _boxes[BoxLevel.DIAMOND]
        );
    }
    function getAllUsers()
        public
        view
        returns(address[] memory users)
        {
            users = _users;
        }
    /* For FE
        0: allocated
        1: remaining allocation
        2: bought silver boxes
        3: bought gold boxes
        4: bought diamond boxes
    */
    function infoWallet(address user)
        public
        view
        returns (
            uint16,
            uint16,
            uint16,
            uint16,
            uint16
        )
    {
        return (
            _allocated[user],
            _remainingAllocation[user],
            _bought[user][BoxLevel.SILVER],
            _bought[user][BoxLevel.GOLD],
            _bought[user][BoxLevel.DIAMOND]
        );
    }

    function pause() external whenNotPaused {
        _pause();
    }

    function unpause() external whenPaused {
        _unpause();
    }

    function transferToken(
        address token,
        uint256 amount,
        address to
    ) external onlyOwner {
        IERC20 t = IERC20(token);

        require(
            t.balanceOf(address(this)) >= amount,
            'Insufficent token balance to transfer amount'
        );
        t.transfer(to, amount);
    }

    // function transferNativeToken(uint256 amount, address payable to)
    //     external
    //     onlyOwner
    // {
    //     require(
    //         address(this).balance >= amount,
    //         'Insufficent native token balance to transfer amount'
    //     );
    //     to.transfer(amount);
    // }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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