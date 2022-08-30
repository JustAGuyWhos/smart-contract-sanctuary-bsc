/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: UNLICENSED

// File contracts/TransferHelper.sol

// SPDX: GPL-2.0-or-later
pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

}


// File contracts/FullMath.sol

// SPDX: MIT
pragma solidity ^0.8.0;

// Sourced from https://gist.github.com/paulrberg/439ebe860cd2f9893852e2cab5655b65, credits to Paulrberg for porting to solidity v0.8
/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a├ùb├Àdenominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        unchecked {
            uint256 twos = (type(uint256).max - denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }
}



// SPDX: UNLICENSED

pragma solidity ^0.8.0;
interface PCondition {
    function isAllowed() external view returns (bool);
}

library VestingMathLibrary {

  // gets the withdrawable amount from a lock
  function getWithdrawableAmount (uint256 startDate, uint256 endDate, uint256 amount, uint256 timeStamp, address condition) internal view returns (uint256) {
    // It is possible in some cases IUnlockCondition(condition).unlockTokens() will fail (func changes state or does not return a bool)
    // for this reason we implemented revokeCondition per lock so funds are never stuck in the contract.
    
    // Prematurely release the lock if the condition is met
    if (condition != address(0) && PCondition(condition).isAllowed()) {
      return amount;
    }
    // Lock type 1 logic block (Normal Unlock on due date)
    if (startDate == 0 || startDate == endDate) {
        return endDate < timeStamp ? amount : 0;
    }
    // Lock type 2 logic block (Linear scaling lock)
    uint256 timeClamp = timeStamp;
    if (timeClamp > endDate) {
        timeClamp = endDate;
    }
    if (timeClamp < startDate) {
        timeClamp = startDate;
    }
    uint256 elapsed = timeClamp - startDate;
    uint256 fullPeriod = endDate - startDate;
    return FullMath.mulDiv(amount, elapsed, fullPeriod); // fullPeriod cannot equal zero due to earlier checks and restraints when locking tokens (startEmission < endEmission)
  }
}


// File @openzeppelin/contracts/utils/structs/[email protected]

// SPDX: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


// File @openzeppelin/contracts/utils/[email protected]

// SPDX: MIT

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/access/[email protected]

// SPDX: MIT

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
    constructor () {
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


// File @openzeppelin/contracts/security/[email protected]

// SPDX: MIT

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

    constructor () {
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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX: MIT

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// File contracts/TokenVesting.sol

// SPDX: UNLICENSED
// ALL RIGHTS RESERVED
// Unicrypt by SDDTech reserves all rights on this code. You may NOT copy these contracts.

// This contract locks ERC20 tokens. This can be used for:
// - Token developers to prove they have locked tokens
// - Presale projects or investors to lock a portion of tokens for a vesting period
// - Farming platforms to lock a percentage of the farmed rewards for a period of time
// - To lock tokens until a specific unlock date.
// - To send tokens to someone under a time lock.

// This contract is for ERC20 tokens, and supports high deflationary and rebasing tokens by using a pooling and share issuing mechanism.
// This is NOT for AMM LP tokens (such as UNIV2), Please use our liquidity lockers for this.
// Locking LP tokens in this contract will not show in the Unicrypt browser.

// *** LOCK TYPES ***
// Lock Type 1: when startEmission == 0 the lock is considered lockType 1. This is a normal lock
// whereby tokens can be withdrawn on the due date (endEmission).

// Lock Type 2: when startEmission != 0. Lock tokens over a period, with an amount withdrawable every block. 
// This scales linearly over time from startEmission -> endEmission. 
// e.g. If the lock period is 100 seconds, 50 seconds after the startEmission you can withdraw 50% of the lock.
// Instead of making 10 locks for 10 months to withdraw tokens at the end of each month, you can now make 1 linear scaling lock with a period
// of 10 months and withdraw the relative share every block.

// *** CUSTOM PREMATURE UNLOCKING CONDITIONS ***
// All locks support premature unlocking conditions. A premature unlock condition can be anything that implements the IUnlockCondition interface
// If IUnlockCondition(address).unlockTokens() returns true, the lock withdraw date is overriden and the entire lock value can be withdrawn.
// The key here is this is for premature unlocks, locks always fall back to the endEmission date 
// even if unlockTokens() returns false, and are therefore always withdrawble in full by the unlockDate.
// Example use cases, Imagine a presale is 1 week long. Marketers tokens are locked for 1 week to prevent them initiating
// markets and setting initial prices on an AMM. The presale concludes within 5 minuites. Marketers now need to wait 1 week,
// to access their tokens. With conditional unlocks a condition can be set to return true once a presale has concluded
// and override the 1 week lock making their tokens instantly withdrawble post presale. 
// Another use case could be to allow token developers or investors to prematurely unlock their tokens
// if the price reaches a specified target, or for governance to vote for developers to unlock tokens prematurely 
// for development purposes met or raodmap goals met.
// Get creative!

// Please be aware if you are locking tokens to prove to your community you have locked tokens for long term you should not use a premature unlocking condition 
// as these types of locks will be shown differently in the browser to a normal lock with no unlocking condition.
// Unlocking conditions can always be revoked by the lock owner to give more credibility to the lock.
interface PMigrator {
    function migrate(address token, uint256 tokensDeposited, uint256 tokensWithdrawn, uint256 startDate, uint256 endDate, uint256 lockID, address owner, address condition, uint256 amount) external returns (bool);
}

pragma solidity ^0.8.0;

contract PsVesting is Ownable, ReentrancyGuard {
  using EnumerableSet for EnumerableSet.AddressSet;
  

  struct UserInfo {
    EnumerableSet.AddressSet lockedTokens; // tokens address of locked tokens of user
    mapping(address => uint256[]) locksForToken; // mapping of erc20 address to lock
  }

  struct TokenLock {
    address tokenAddress; 
    uint256 tokensDeposited; 
    uint256 tokensWithdrawn; 
    uint256 startDate; 
    uint256 endDate; 
    uint256 lockID; 
    address owner; 
    address condition;
  }
  
    
  struct LockParams {
    address payable owner; 
    uint256 amount; 
    uint256 startDate; 
    uint256 endDate; 
    address condition; 
  }
  EnumerableSet.AddressSet private TOKENS; 

    mapping(uint256 => TokenLock) public LOCK;

    uint256 public NONCE = 1;
    uint256 public MINIMUM_DEPOSIT = 10000;

    mapping(address => uint256[]) private TOKEN_LOCKS;
    mapping(address => UserInfo) private USERS;
    EnumerableSet.AddressSet private ZERO_FEE_WHITELIST; 
    EnumerableSet.AddressSet private TOKEN_WHITELISTERS;

   struct FeeStruct {
    uint256 tokenFee;
    uint256 freeLockingFee;
    address payable feeAddress;
    address freeLockingToken; 
  }
    FeeStruct public FEES;

    PMigrator public Migrator;
    
    mapping(address=>bool) public BlackListed;
  event Locked(uint256 lockID, address token, address owner, uint256 amount, uint256 startDate, uint256 endDate);
  event Withdraw(uint256 lockId, address token, uint256 amount);
  event onRelock(uint256 lockID, uint256 unlockDate);
  event LockTransferred(uint256 lockIDFrom, uint256 lockIDto, address oldOwner, address newOwner);
  event LockSplitted(uint256 fromLockID, uint256 toLockID, uint256 amountInTokens);
  event Migrated(uint256 lockID, uint256 amountInTokens);


  constructor () {
    FEES.tokenFee = 35;
    FEES.feeAddress = payable(0xAA3d85aD9D128DFECb55424085754F6dFa643eb1);
    FEES.freeLockingFee = 10e18;
  }

   function setMigrator(PMigrator migrator_) external onlyOwner {
    Migrator = migrator_;
    }
  
  function setBlacklistContract(address token, bool decision) external onlyOwner {
      BlackListed[token] = decision;
  }
function setFees(uint256 _tokenFee, uint256 _freeLockingFee, address payable _feeAddress, address _freeLockingToken) external onlyOwner {
    FEES.tokenFee = _tokenFee;
    FEES.freeLockingFee = _freeLockingFee;
    FEES.feeAddress = _feeAddress;
    FEES.freeLockingToken = _freeLockingToken;
  }
 function setWhitelister(address wallet, bool decision) external onlyOwner {
    if (decision) {
      TOKEN_WHITELISTERS.add(wallet);
    } else {
      TOKEN_WHITELISTERS.remove(wallet);
    }
  }

  function payFreeTokenFees (address token_) external payable {
      require(!ZERO_FEE_WHITELIST.contains(token_), "Already Paid");
      // charge Fee
      if (FEES.freeLockingToken == address(0)) {
          require(msg.value == FEES.freeLockingFee, "Send Proper Fees");
          FEES.feeAddress.transfer(FEES.freeLockingFee);
      } else {
          TransferHelper.safeTransferFrom(address(FEES.freeLockingToken), address(msg.sender), FEES.feeAddress, FEES.freeLockingFee);
      }
      ZERO_FEE_WHITELIST.add(token_);
  }
    function editZeroFeeWhitelist (address token_, bool decision) external {
    require(TOKEN_WHITELISTERS.contains(msg.sender), "You are not Admin");
    if (decision) {
      ZERO_FEE_WHITELIST.add(token_);
    } else {
      ZERO_FEE_WHITELIST.remove(token_);
    }
  }

   function lock(address token_, LockParams[] calldata lock_params) external nonReentrant {
    require(lock_params.length > 0, 'NO PARAMS');

    require(!BlackListed[token_], "Token Blacklisted");

    uint256 totalAmount = 0;
    for (uint256 i = 0; i < lock_params.length; i++) {
        totalAmount += lock_params[i].amount;
    }

    uint256 balanceBefore = IERC20(token_).balanceOf(address(this));
    TransferHelper.safeTransferFrom(token_, address(msg.sender), address(this), totalAmount);
    uint256 amountIn = IERC20(token_).balanceOf(address(this)) - balanceBefore;

    if (!ZERO_FEE_WHITELIST.contains(token_)) {
      uint256 lockFee = FullMath.mulDiv(amountIn, FEES.tokenFee, 10000);
      TransferHelper.safeTransfer(token_, FEES.feeAddress, lockFee);
      amountIn -= lockFee;
    }
    
    for (uint256 i = 0; i < lock_params.length; i++) {
        LockParams memory lock_param = lock_params[i];
        require(lock_param.startDate < lock_param.endDate, "Wrong Period");
        require(lock_param.endDate < 1e10, "Send proper timestamp"); 
        require(lock_param.amount >= MINIMUM_DEPOSIT, "Deposit should be more");
        uint256 amountInTokens = FullMath.mulDiv(lock_param.amount, amountIn, totalAmount);
        balanceBefore += amountInTokens;

        TokenLock memory token_lock;
        token_lock.tokenAddress = token_;
        token_lock.tokensDeposited = amountInTokens;
        token_lock.startDate = lock_param.startDate;
        token_lock.endDate = lock_param.endDate;
        token_lock.lockID = NONCE;
        token_lock.owner = lock_param.owner;
        if (lock_param.condition != address(0)) {
            PCondition(lock_param.condition).isAllowed();
            token_lock.condition = lock_param.condition;
        }
    
        LOCK[NONCE] = token_lock;
        TOKENS.add(token_);
        TOKEN_LOCKS[token_].push(NONCE);
    
        UserInfo storage user = USERS[lock_param.owner];
        user.lockedTokens.add(token_);
        user.locksForToken[token_].push(NONCE);
        
        NONCE ++;
        emit Locked(token_lock.lockID, token_, token_lock.owner, amountInTokens, token_lock.startDate, token_lock.endDate);
    }
  }
  
  function withdraw (uint256 lockID, uint256 amount) external nonReentrant {
    TokenLock storage userLock = LOCK[lockID];
    require(userLock.owner == msg.sender, "You are not Owner");

    uint256 withdrawableTokens = getWithdrawableTokens(userLock.lockID);
    require(amount <= withdrawableTokens, "You are asking more");
    userLock.tokensWithdrawn += withdrawableTokens;
    require(userLock.tokensWithdrawn<=userLock.tokensDeposited, "You can't withdraw this much");
    TransferHelper.safeTransfer(userLock.tokenAddress, msg.sender, amount);
    emit Withdraw(lockID, userLock.tokenAddress, amount);
  }

  function getWithdrawableTokens (uint256 lockID) public view returns (uint256) {
    TokenLock storage userLock = LOCK[lockID];
    uint8 lockType = userLock.startDate == 0 ? 1 : 2;
    uint256 amount = lockType == 1 ? userLock.tokensDeposited - userLock.tokensWithdrawn : userLock.tokensDeposited;
    uint256 withdrawable;
    withdrawable = VestingMathLibrary.getWithdrawableAmount (
      userLock.startDate, 
      userLock.endDate, 
      amount, 
      block.timestamp, 
      userLock.condition
    );
    if (lockType == 2) {
      withdrawable -= userLock.tokensWithdrawn;
    }
    return withdrawable;
  }

    function getLock (uint256 lockID) external view returns (TokenLock memory) {
      TokenLock memory tokenLock = LOCK[lockID];     
        return tokenLock;
    }

      function getNumLockedTokens () external view returns (uint256) {
    return TOKENS.length();
  }

    
  function getTokenAtIndex (uint256 index) external view returns (address) {
    return TOKENS.at(index);
  }
    function getTokenLocksLength (address token_) external view returns (uint256) {
    return TOKEN_LOCKS[token_].length;
  }
    function getTokenLockIDAtIndex (address token_, uint256 index) external view returns (uint256) {
    return TOKEN_LOCKS[token_][index];
  }
    // user functions
  function getLockedTokensLengthofUser (address user) external view returns (uint256) {
    return USERS[user].lockedTokens.length();
  }
    function getLockedTokenAtIndexofUser (address user, uint256 index) external view returns (address) {
    return USERS[user].lockedTokens.at(index);
  }
  
  function getLocksForTokenLengthofUser (address user, address _token) external view returns (uint256) {
    return USERS[user].locksForToken[_token].length;
  }
  
  function getUserLockIDForTokenAtIndex (address _user, address _token, uint256 _index) external view returns (uint256) {
    return USERS[_user].locksForToken[_token][_index];
  }

  // no Fee Tokens
  function getZeroFeeTokensLength () external view returns (uint256) {
    return ZERO_FEE_WHITELIST.length();
  }
  
  function getZeroFeeTokenAtIndex (uint256 _index) external view returns (address) {
    return ZERO_FEE_WHITELIST.at(_index);
  }
  
  function tokenOnZeroFeeWhitelist (address _token) external view returns (bool) {
    return ZERO_FEE_WHITELIST.contains(_token);
  }
  
  // whitelist
  function getTokenWhitelisterLength () external view returns (uint256) {
    return TOKEN_WHITELISTERS.length();
  }
  
  function getTokenWhitelisterAtIndex (uint256 _index) external view returns (address) {
    return TOKEN_WHITELISTERS.at(_index);
  }
  
  function getTokenWhitelisterStatus (address _user) external view returns (bool) {
    return TOKEN_WHITELISTERS.contains(_user);
  }
  
}