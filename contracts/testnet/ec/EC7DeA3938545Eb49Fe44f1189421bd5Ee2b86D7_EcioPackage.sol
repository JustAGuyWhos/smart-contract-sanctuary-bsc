// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface PancakeRouter {
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint[] memory amounts);
}

contract EcioPackage is Ownable, ReentrancyGuard {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _packedIdCounter;
    CountersUpgradeable.Counter private _orderIdCounter;

    uint256 public FEE;
    address public busdToken;
    address public lkmToken;
    address public pancakeRouter;
    address[] public swapAddress;

    struct Packed {
        string name;
        string description;
        string imageURL;
        uint256 price;
        uint256 startAt;
        uint256 endAt;
        string[] partCodeItems;
        bool isExist;
    }

    mapping(uint256 => Packed) public PACKED_ITEMS;

    // event
    event createOrderPacked(address user, uint256 packedId, uint256 orderId);

    // Setup fee
    function setupFee(uint256 amount) public onlyOwner {
        FEE = amount;
    }

    function changeTokenContract(address busdAddress, address lkmAddress) public onlyOwner {
        busdToken = busdAddress;
        lkmToken = lkmAddress;
        swapAddress = [busdAddress, lkmAddress];
    }

    function changePcRouterContract(address _address) public onlyOwner {
        pancakeRouter = _address;
    }

    // Create order packed
    function createPacked(
        string memory name,
        string memory description,
        string memory imageURL,
        uint256 price,
        uint256 startAt,
        uint256 endAt,
        string[] memory partCodeItems
    ) external onlyOwner {
        _packedIdCounter.increment();
        uint256 packedId = uint256(_packedIdCounter.current());
        PACKED_ITEMS[packedId].name = name;
        PACKED_ITEMS[packedId].description = description;
        PACKED_ITEMS[packedId].imageURL = imageURL;
        PACKED_ITEMS[packedId].startAt = startAt;
        PACKED_ITEMS[packedId].endAt = endAt;
        PACKED_ITEMS[packedId].price = price;
        PACKED_ITEMS[packedId].isExist = true;
        for (uint256 i = 0; i < partCodeItems.length; i++) {
            PACKED_ITEMS[packedId].partCodeItems.push(partCodeItems[i]);
        }
    }

    // Update order packed
    function updatePacked(
        uint256 packedId,
        string memory name,
        string memory description,
        string memory imageURL,
        uint256 price,
        uint256 startAt,
        uint256 endAt,
        string[] memory partCodeItems
    ) external onlyOwner {
        require(PACKED_ITEMS[packedId].isExist, "Packed is not exist!");

        PACKED_ITEMS[packedId].name = name;
        PACKED_ITEMS[packedId].description = description;
        PACKED_ITEMS[packedId].imageURL = imageURL;
        PACKED_ITEMS[packedId].startAt = startAt;
        PACKED_ITEMS[packedId].endAt = endAt;
        PACKED_ITEMS[packedId].price = price;
        string[] memory newPartCodeItems = new string[](partCodeItems.length);
        for (uint256 i = 0; i < partCodeItems.length; i++) {
            newPartCodeItems[i] = partCodeItems[i];
        }

        PACKED_ITEMS[packedId].partCodeItems = newPartCodeItems;
    }

    // Get packed balance
    function getPackedBalance() public view returns (uint256) {
        return uint256(_packedIdCounter.current());
    }

    function getNumberOfItemsInPacked(uint256 packedId)
        public
        view
        returns (uint256)
    {
        return PACKED_ITEMS[packedId].partCodeItems.length;
    }

    function getItemsInPacked(uint256 packedId, uint256 index)
        public
        view
        returns (string memory)
    {
        return PACKED_ITEMS[packedId].partCodeItems[index];
    }

    // Order packed
    function orderPacked(uint256 packedId) external payable nonReentrant {
        require(msg.value >= FEE, "Failed to send fee");
        require(PACKED_ITEMS[packedId].isExist, "Packed is not exist!");
        require(IERC20(busdToken).balanceOf(msg.sender) >= PACKED_ITEMS[packedId].price, "Insufficent BUSD");
        IERC20(busdToken).transferFrom(
            msg.sender,
            address(this),
            PACKED_ITEMS[packedId].price
        );
        uint256 swapAmount = PACKED_ITEMS[packedId].price * 60 / 100;
        uint[] memory amountOut;
        amountOut = PancakeRouter(pancakeRouter).getAmountsOut(swapAmount, swapAddress);
        PancakeRouter(pancakeRouter).swapExactTokensForTokens(swapAmount, amountOut[1], swapAddress, address(this), block.timestamp + 5 minutes);
        _orderIdCounter.increment();
        emit createOrderPacked(msg.sender, packedId, _orderIdCounter.current());
    }

    function approveBusdForSwap(uint256 amount) public onlyOwner {
        IERC20(busdToken).approve(
            pancakeRouter,
            amount
        );
    }

    //*************************** transfer fee ***************************//

    // Transfer fee
    function transferFee(address payable _to, uint256 _amount)
        public
        onlyOwner
    {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
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

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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