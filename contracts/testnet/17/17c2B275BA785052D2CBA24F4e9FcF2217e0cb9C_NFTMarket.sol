/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// File: @openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: IPancakeRouter01.sol


pragma solidity ^0.8.4;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// File: IPancakeRouter02.sol


pragma solidity ^0.8.4;


interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
// File: Marketplace.sol


pragma solidity ^0.8.4;











contract NFTMarket is ReentrancyGuard, Ownable, ERC1155Holder {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    Counters.Counter private _itemsCanceled;

    mapping(address => uint[]) myCreatedSale;

    IERC1155 private _nftContract;
    IERC20 private _tokenContract; // busd address

    // discount changes - start
    IERC20 private _oCoinContract;
    address private _wbnbContract;
    IPancakeRouter02 private _pancakeRouter;
    address[] public path;

    uint oCoinPriceInDollar ;
    uint public maxOCoinUsedQTY = 200000000000000000000000;
    uint public maxOCoinUsedPrcnt = 200;

    // discount changes -- end


    uint256 private _basePlatformFees = 200;
    uint256 private _variableFees = 150;
    uint256 private _denominator = 10000;

    uint256 private _buyerPercentFees = 5000;
    uint256 private _sellerPercentFees = 5000;

    address payable private wallet;

    struct MarketItem {
        uint itemId;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        uint256 amount;
        bool sold;
        bool isBNB;
        bool isCanceled;
        }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated (
    uint itemId,
    uint256 indexed tokenId,
    address indexed seller,
    address indexed owner,
    uint256 price,
    uint256 amount,
    bool sold,
    bool isBNB
  );

    event MarketItemCancelled (
    uint itemId,
    uint256 indexed tokenId,
    address indexed seller,
    address indexed owner,
    uint256 price,
    uint256 amount,
    bool sold,
    bool isBNB
  );

    event ItemBUY (
    uint itemId,
    uint256 indexed tokenId,
    address indexed seller,
    address indexed owner,
    uint256 price,
    uint256 amount
    // bool sold,
    // bool isBNB
  );

  constructor(address _nftAddress, address _busdAddress, address _oCoinAddress,uint _price, address _wbnbAddress, address _walletAddress, address _pancakeRouterAddress){
        _nftContract =  IERC1155(_nftAddress);
        _tokenContract = IERC20(_busdAddress);
        _oCoinContract = IERC20(_oCoinAddress);
        _wbnbContract = _wbnbAddress;
        wallet = payable(_walletAddress);
        _pancakeRouter = IPancakeRouter02(_pancakeRouterAddress);
        oCoinPriceInDollar = _price;
      //  path = [_wbnbAddress, _busdAddress];
      path = [_wbnbAddress, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7];
    }

    function BNB_in_BUSD(uint _bnbQuant) public view returns(uint){

     uint256 bnbPrice = _pancakeRouter.getAmountsOut(_bnbQuant, path)[path.length - 1];

     return bnbPrice ;
}

function oCoin_in_BNB(uint _ocoinQuant) public view returns(uint){
    address[] memory revPath = new address[](2);
    revPath[0] = path[1];
    revPath[1] = path[0];

     uint256 bnbPrice = _pancakeRouter.getAmountsOut(_ocoinQuant, revPath)[revPath.length - 1];

     return bnbPrice ;
}


    function ListNFT(
    uint256 tokenId,
    uint256 price,
    uint256 amount,
    bool isBNB
  ) public nonReentrant returns(uint256){

      require(price > 0, "Price must be at least 1 wei");
      require(amount > 0,'you must sell atleast 1 NFT');
      require(amount <= _nftContract.balanceOf(msg.sender, tokenId), 'you do not hold these NFT');

       _itemIds.increment();
        uint256 itemId = _itemIds.current();

            idToMarketItem[itemId] =  MarketItem(
                itemId,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                price,
                amount,
                false,
                isBNB,
                false
             );
            _nftContract.safeTransferFrom(
                msg.sender,
                address(this),
                tokenId,
                amount,
                "0x00"
            );

            myCreatedSale[msg.sender].push(itemId);

            emit MarketItemCreated(
                itemId,
                tokenId,
                payable(msg.sender),
                payable(address(0)),
                price,
                amount,
                false,
                isBNB
             );
             return itemId;


  }

  function calculatePrices(
    uint256 itemId,
    uint256 _amount,
    uint _ocoinAmount
  ) public view returns(uint256[] memory){

    uint price = idToMarketItem[itemId].price * _amount;
    bool isBnb = idToMarketItem[itemId].isBNB;
    uint finalPriceforBuyer = price + (price * (_basePlatformFees + _variableFees) * _buyerPercentFees)/(_denominator * _denominator);
    uint payingToSeller = price - (price * (_basePlatformFees + _variableFees) * _sellerPercentFees)/(_denominator * _denominator);
    uint mUsed=0;
    if(_ocoinAmount >0){
    if(isBnb){
      uint max_ocoin_quant_in_bnb = oCoin_in_BNB((maxOCoinUsedQTY * oCoinPriceInDollar)/1e18);
        uint price_after_max_discount_per = finalPriceforBuyer - price;
        
        uint low_max_eligible_discount = max_ocoin_quant_in_bnb < price_after_max_discount_per ? max_ocoin_quant_in_bnb : price_after_max_discount_per;
        uint buyer_desired_discount = oCoin_in_BNB((_ocoinAmount * oCoinPriceInDollar)/1e18);

        require(buyer_desired_discount <= low_max_eligible_discount,'you can not avail this much discount');

        finalPriceforBuyer = finalPriceforBuyer - buyer_desired_discount;
        uint a = BNB_in_BUSD(low_max_eligible_discount);
        mUsed = a/oCoinPriceInDollar;


    }else {

      uint max_ocoin_quant_in_busd = ((maxOCoinUsedQTY * oCoinPriceInDollar)/1e18);
      uint price_after_max_discount_per = finalPriceforBuyer-price;

      uint low_max_eligible_discount = max_ocoin_quant_in_busd < price_after_max_discount_per ? max_ocoin_quant_in_busd : price_after_max_discount_per;
      uint buyer_desired_discount = (_ocoinAmount * oCoinPriceInDollar)/1e18;

      require(buyer_desired_discount <= low_max_eligible_discount,'you can not avail this much discount');

      finalPriceforBuyer = finalPriceforBuyer - buyer_desired_discount;
        mUsed = low_max_eligible_discount/oCoinPriceInDollar;

    }
    }

    uint[] memory values = new uint[](3);
    values[0] = finalPriceforBuyer;
    values[1] = payingToSeller;
    values[2] = mUsed;
    return(values);
  }

  function buyWithBNB(
    uint256 itemId,
    uint256 _amount,
    uint256 _ocoinAmount
    ) public payable nonReentrant {
    require(!idToMarketItem[itemId].sold,'NFT sold out.');
    require(idToMarketItem[itemId].isBNB,'NFT is not available for sale with BNB.');
    require(idToMarketItem[itemId].amount >= _amount, 'The requested amount of NFT is greater than the NFT available for sale.');
    require(!(idToMarketItem[itemId].amount - _amount < 0), 'Can not buy this NFT');
    require(!(idToMarketItem[itemId].isCanceled), 'NFT removed from sale');

    require(_ocoinAmount <= maxOCoinUsedQTY, 'ocoin amount exceed max allowed quantity');
    require(_ocoinAmount <= _oCoinContract.balanceOf(msg.sender),'ocoin speicified amount exceed balance');

    uint price = idToMarketItem[itemId].price * _amount;
    uint finalPrice = price + (price * (_basePlatformFees + _variableFees) * _buyerPercentFees)/(_denominator * _denominator);

     if(_ocoinAmount>0){

        uint max_ocoin_quant_in_bnb = oCoin_in_BNB((maxOCoinUsedQTY * oCoinPriceInDollar)/1e18);
        uint price_after_max_discount_per = finalPrice - price;
        
        uint low_max_eligible_discount = max_ocoin_quant_in_bnb < price_after_max_discount_per ? max_ocoin_quant_in_bnb : price_after_max_discount_per;
        uint buyer_desired_discount = oCoin_in_BNB((_ocoinAmount * oCoinPriceInDollar)/1e18);

        require(buyer_desired_discount <= low_max_eligible_discount,'you can not avail this much discount');

        finalPrice = finalPrice - buyer_desired_discount;

        SafeERC20.safeTransferFrom(_oCoinContract, msg.sender, address(this), _ocoinAmount);


     }
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(msg.value >= finalPrice, "Please submit the asking price in order to complete the purchase");

    uint payingToSeller = price - (price * (_basePlatformFees + _variableFees) * _sellerPercentFees)/(_denominator * _denominator);
    idToMarketItem[itemId].seller.transfer(payingToSeller);

    internalTransfer( tokenId, itemId, _amount );

    emit ItemBUY (
     itemId,
    idToMarketItem[itemId].tokenId,
    idToMarketItem[itemId].seller,
    msg.sender,
    msg.value,
    _amount
    //idToMarketItem[itemId].sold,
    //true
    );
    

  }

  function removeItem(uint256 itemId) public nonReentrant{

    require(!idToMarketItem[itemId].sold,'Sold NFTs can not be removed');
    require(idToMarketItem[itemId].seller == msg.sender,'Only owner can remove NFT ');
    
    _nftContract.safeTransferFrom(
                address(this),
                idToMarketItem[itemId].seller,
                idToMarketItem[itemId].tokenId,
                idToMarketItem[itemId].amount,
                "0x00"
            );
    idToMarketItem[itemId].isCanceled = true;
    _itemsCanceled.increment();

    emit MarketItemCancelled (
    itemId,
    idToMarketItem[itemId].tokenId,
   idToMarketItem[itemId].seller,
    idToMarketItem[itemId].owner,
    idToMarketItem[itemId].amount*idToMarketItem[itemId].price,
    idToMarketItem[itemId].amount,
    false,
     idToMarketItem[itemId].isBNB
  );


  }

  function buyWithToken(
    uint256 itemId,
    uint256 _amount,
    uint _payableAmount,
    uint _ocoinAmount
    ) public nonReentrant {
    require(!idToMarketItem[itemId].sold,'NFT sold out.');
    require(!idToMarketItem[itemId].isBNB,'NFT is not available for sale with this coin.');
    require(idToMarketItem[itemId].amount >= _amount, 'The requested amount of NFT is greater than the NFT available for sale.');
    require(!(idToMarketItem[itemId].amount - _amount < 0), 'Can not buy this NFT');
    require(!(idToMarketItem[itemId].isCanceled), 'NFT removed from sale');

      require(_ocoinAmount <= maxOCoinUsedQTY, 'ocoin amount exceed max allowed quantity');
      require(_ocoinAmount <= _oCoinContract.balanceOf(msg.sender),'ocoin speicified amount exceed balance');

    uint price = idToMarketItem[itemId].price * _amount;
    uint finalPrice = price + (price * (_basePlatformFees + _variableFees) * _buyerPercentFees)/(_denominator * _denominator);

    if(_ocoinAmount>0){
      uint max_ocoin_quant_in_busd = ((maxOCoinUsedQTY * oCoinPriceInDollar)/1e18);
      uint price_after_max_discount_per = finalPrice-price;

      uint low_max_eligible_discount = max_ocoin_quant_in_busd < price_after_max_discount_per ? max_ocoin_quant_in_busd : price_after_max_discount_per;
      uint buyer_desired_discount = (_ocoinAmount * oCoinPriceInDollar)/1e18;

      require(buyer_desired_discount <= low_max_eligible_discount,'you can not avail this much discount');

      finalPrice = finalPrice - buyer_desired_discount;
      SafeERC20.safeTransferFrom(_oCoinContract, msg.sender, address(this), _ocoinAmount);


    }
   
    uint tokenId = idToMarketItem[itemId].tokenId;
    require(_tokenContract.allowance(msg.sender, address(this)) >= finalPrice, "Provide allowance for the token to Market to purchase the NFTs");

    uint payingToSeller = price - (price * (_basePlatformFees + _variableFees) * _sellerPercentFees)/(_denominator * _denominator);

      require(finalPrice <= _payableAmount, 'final payable amount is greater than payableAmount passed');
    //idToMarketItem[itemId].seller.transfer(payingToSeller);
    SafeERC20.safeTransferFrom(
      _tokenContract,
      msg.sender,
      address(this),
      finalPrice
    );

      SafeERC20.safeTransfer(
      _tokenContract,
      idToMarketItem[itemId].seller,
      payingToSeller
    );

    internalTransfer( tokenId, itemId, _amount );

    emit ItemBUY (
     itemId,
    idToMarketItem[itemId].tokenId,
    idToMarketItem[itemId].seller,
    msg.sender,
    finalPrice,
    _amount
    // idToMarketItem[itemId].sold,
    // false
    );
   

  }

  function internalTransfer(uint tokenId, uint itemId, uint _amount ) internal {

    _nftContract.safeTransferFrom(
                address(this),
                msg.sender,
                tokenId,
                _amount,
                "0x00"
            );

    if(idToMarketItem[itemId].amount - _amount == 0){
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        idToMarketItem[itemId].amount -= _amount;
         _itemsSold.increment();

    } else {

        idToMarketItem[itemId].amount -= _amount;

    }

  }


  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unsoldItemCount = _itemIds.current() - _itemsSold.current() - _itemsCanceled.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unsoldItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToMarketItem[i + 1].owner == address(0) && !idToMarketItem[i + 1].isCanceled) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

 

   /* Returns only items a user has created */
  function fetchItemsCreated() public view returns (MarketItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToMarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }







    // Getter and Setter Functions 
    function saleInfoWithID(uint[] memory _ids) external view returns(MarketItem[] memory){
      MarketItem[] memory items = new MarketItem[](_ids.length);

      for (uint i = 0; i < _ids.length; i++) {
      
        MarketItem storage currentItem = idToMarketItem[_ids[i]];
        items[i] = currentItem;
      
    }

      return items;
    }

    function PlatformFee() external view returns(uint256 basefee, uint variablefee, uint totalfee){
        return (_basePlatformFees, _variableFees, (_basePlatformFees + _variableFees));
    }

     function setPlatformFee(uint256 _basefee, uint256 _varFee) external onlyOwner{
        _basePlatformFees = _basefee;
        _variableFees = _varFee;
    
    }



    function setStakeholdersFees(uint256 _bFee, uint256 _sFee) external onlyOwner{
        _buyerPercentFees = _bFee;
        _sellerPercentFees = _sFee;
    }

    function stakeholdersFees() external view returns(uint256 buyersFee, uint sellersFee){
        return( _buyerPercentFees, _sellerPercentFees);

    }


    function setWalletAddress(address payable _wallet) external onlyOwner{
        wallet = _wallet;
    }

    function feeReceiverWallet() external view returns(address){
        return wallet;
    }

    function setNftAddress(address _nft) external onlyOwner{
        _nftContract = IERC1155(_nft);
    }

    function nftAddress() external view returns(address){
        return address(_nftContract);
    }

    function totalNFTListed() external view returns(uint){
        return _itemIds.current();
    }

    function myCreatedSaleID(address _creator) public view returns(uint[] memory){
      return myCreatedSale[_creator];
    }

    function setTokensAddress(address _busdT, address _ocoinT) external onlyOwner{
      path[1]=_busdT;
        _tokenContract = IERC20(_busdT);
         _oCoinContract = IERC20(_ocoinT);
    } 
    function setRouterAddress(address _router) public onlyOwner{
      _pancakeRouter = IPancakeRouter02(_router);
    }

    function getRouterAddress() public view returns(address){
      return address(_pancakeRouter);
    }
    function tokensAddress() external view returns(address busd, address ocoin){
        return (address(_tokenContract), address(_oCoinContract));
    }

    // withdraw function
    function withdrawBNB() external onlyOwner {
      wallet.transfer(address(this).balance);
    }

    function withdrawBUSD() external onlyOwner {
      SafeERC20.safeTransfer(
        _tokenContract,
        wallet,
        _tokenContract.balanceOf(address(this))
      );

    }

    // check balances
    function feeReceived() external view returns(uint bnb, uint busd, uint ocoin) {
     return (address(this).balance, _tokenContract.balanceOf(address(this)), _oCoinContract.balanceOf(address(this)));
    }


    function setMAXoCoin(uint _max) external onlyOwner{
        maxOCoinUsedQTY = _max;
    }

    function getOcoinPrice() external view returns(uint, uint){
      
        return(oCoinPriceInDollar,oCoin_in_BNB(oCoinPriceInDollar));
    }

  function setoCoinPrice(uint _price) external onlyOwner{
        oCoinPriceInDollar = _price;
    }
    
    function withdrawoCoin() external onlyOwner {
      SafeERC20.safeTransfer(
        _oCoinContract,
        wallet,
        _oCoinContract.balanceOf(address(this))
      );

    }

    function feeReceivedOCoin() external view returns(uint) {
     return _oCoinContract.balanceOf(address(this));
    }

  // discount changes -- end
}

// update path when update address
// 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 - router
// 0xae13d989dac2f0debff460ac112a837c89baa7cd - wbnb
// 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 - busd
// busd address in constructor