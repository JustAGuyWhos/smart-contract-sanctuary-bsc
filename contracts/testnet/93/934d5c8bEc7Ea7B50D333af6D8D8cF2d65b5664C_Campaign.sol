/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

pragma solidity ^0.8.0;


// 
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

// 
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

// 
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

// 
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// 
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

// 
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

// 
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

// 
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// 
/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 
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

// 
/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// 
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

// 
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

// 
/**
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

// 
interface IMysteryBoxNFT is IERC1155 {
    function mintMysteryBox(
        address _account,
        uint256 _tokenId,
        uint256 _amount
    ) external returns (uint256);

    function burnMysteryBox(address account, uint256 id, uint256 amount) external;
}

// 
contract Campaign is Ownable, Initializable, Pausable, ERC1155Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct MysteryBox {
        uint256 price;
        uint256 quantity;
        uint256 total;
    }

    struct ComboInfo {
        uint256 price;
        uint256[] boxIds;
        uint256[] boxQuantities;
        uint256 quantity;
        uint256 total;
        uint256 quoteTokenKey;
        bool active;
    }


    struct CampaignInfo {
        mapping(uint256 => MysteryBox) mysteryBoxInfo;
        mapping(uint256 => bool) exist;
        uint256[] mysteryBoxIds;
        uint256[] mysteryBoxPrices;
        uint256[] mysteryBoxTotals;
        uint256 quoteTokenKey;
        bool active;
        mapping(address => mapping(uint256 => uint256)) boughtBoxes; // user => boxId => quantity
    }

    struct CampaignReturnInfo {
        uint256[] mysteryBoxIds;
        uint256[] mysteryBoxPrices;
        uint256[] mysteryBoxTotals;
        uint256[] mysteryBoxQuantities;
        uint256 quoteTokenKey;
        bool active;

        uint256 mysteryBoxId;
        uint256 mysteryBoxPrice;
        uint256 mysteryBoxQuantity;
        uint256 mysteryBoxTotal;
    }

    IMysteryBoxNFT public mysteryBoxNFT;


    address payable public feeAddress;
    address public signer;

    CampaignInfo public campaign;
    mapping(uint256 => ComboInfo) public comboInfo;
    mapping(address => bool) public whiteListUsers;
    mapping(uint256 => address) public mappingQuoteErc20s; // 0 - BNB, 1 - QuoteERC20Token

    mapping(address => uint256) public mappingBoughtNth; //number discounted of user
    mapping(uint256 => bool) public mappingClaimed; //receipt => claimed

    uint256 public discountPercent = 500;

    uint256 public ZOOM = 10000;

    uint256 public numberDiscounted = 1;



    uint256[] private combo_1_ids = [1, 2, 3];
    uint256[] private combo_2_ids = [1, 2, 3];
    uint256[] private combo_3_ids = [1, 2, 3];
    uint256[] private combo_4_ids = [1, 2, 3];
    uint256[] private combo_5_ids = [2, 3];

    uint256[] private combo_1_quantities = [5, 3, 2];
    uint256[] private combo_2_quantities = [3, 5, 2];
    uint256[] private combo_3_quantities = [2, 4, 4];
    uint256[] private combo_4_quantities = [2, 3, 5];
    uint256[] private combo_5_quantities = [5, 5];

    uint256 private combo_1_price = (10799) * (10 ** 18);
    uint256 private combo_2_price = (11599) * (10 ** 18);
    uint256 private combo_3_price = (12799) * (10 ** 18);
    uint256 private combo_4_price = (13199) * (10 ** 18);
    uint256 private combo_5_price = (13999) * (10 ** 18);


    event OpenCampaign(address indexed creator, uint256[] mysteryBoxIds);
    event SetCombo(address indexed creator, uint256[] mysteryBoxIds, uint256[] mysteryBoxQuantities, uint256 price);
    event BuyMysteryBox(address indexed buyer, uint256 indexed mysteryBoxId, uint256 indexed quantity);
    event BuyComBoBox(address indexed buyer, uint256 indexed comboId, uint256 indexed quantity);
    event ClaimReward(address indexed account, uint256 indexed receiptId, uint256 indexed quantity);
    event WithdrawCampaign(address indexed sender, uint256 campaignId, uint256[] withdrawIds, uint256[] withdrawQuantities);
    event Active(address indexed sender, bool status);
    event UpdateQuoteTokenKey(address indexed sender, uint256 quoteTokenKey);
    event UpdateCampaignPrice(address indexed sender, uint256 mysteryBoxId, uint256 price);
    event EmergencyWithdraw(address indexed sender, address tokenAddress, uint256 amount);

    modifier onlyWhiteListUser() {
        require(whiteListUsers[msg.sender], "Only-white-list-can-execute");
        _;
    }

    constructor() {
        whiteListUsers[msg.sender] = true;
    }

    function adminWhiteListUsers(address _user, bool _whiteList) public onlyOwner {
        whiteListUsers[_user] = _whiteList;
    }

    function setAdmin(address _newSigner) public onlyOwner {
        require(_newSigner != address(0) && _newSigner != address(this), 'Invalid Admin Address');
        require(_newSigner != signer, "No Need To Update");
        signer = _newSigner;
    }

    function setFeeAddress(address payable _feeAddress) public onlyOwner {
        require(address(_feeAddress) != address(0) && address(_feeAddress) != address(this), "invalid Fee Address");
        require(address(feeAddress) != address(_feeAddress), "No Need To Update");
        feeAddress = _feeAddress;
    }


    function setMysteryBoxNFT(address _mysteryBoxNFT) external onlyOwner {
        require(address(_mysteryBoxNFT) != address(0) && address(_mysteryBoxNFT) != address(this), "Invalid Box Address");
        require(address(_mysteryBoxNFT) != address(mysteryBoxNFT), "No Need To Update");
        mysteryBoxNFT = IMysteryBoxNFT(_mysteryBoxNFT);
    }


    function setDisCountPercent(uint256 _discountPercent) external onlyOwner {
        require(_discountPercent >= 0, "Invalid Discount Percent");
        require(_discountPercent != discountPercent, "No Need To Update");
        discountPercent = _discountPercent;
    }

    function setNumberDiscounted(uint256 _numberDiscounted) external onlyOwner {
        require(_numberDiscounted >= 0, "Invalid Discount Percent");
        require(_numberDiscounted != numberDiscounted, "No Need To Update");
        numberDiscounted = _numberDiscounted;
    }


    function setQuoteErc20(uint256 _quoteErc20Key, address _quoteErc20Address) public onlyOwner {
        if (_quoteErc20Key > 0) {
            require(_quoteErc20Address != address(0), "Invalid Address");
            mappingQuoteErc20s[_quoteErc20Key] = _quoteErc20Address;
        }
    }


    function initialize(
        address _mysteryBoxNFT,
        address payable _feeAddress,
        uint256 _quoteErc20Key, // 1
        address _quoteErc20Address, // GAE token
        address _signer
    ) external initializer {
        require(_mysteryBoxNFT != address(0) && _mysteryBoxNFT != address(this), "Invalid Mystery Box Address!");
        require(address(_feeAddress) != address(0) && address(_feeAddress) != address(this), "Invalid Fee Address");
        require(_signer != address(0) && _signer != address(this), "Invalid Admin Address");
        if (_quoteErc20Key > 0) {
            require(_quoteErc20Address != address(0), "Invalid Erc20 Token Address");
            mappingQuoteErc20s[_quoteErc20Key] = _quoteErc20Address;
        }

        mysteryBoxNFT = IMysteryBoxNFT(_mysteryBoxNFT);
        feeAddress = _feeAddress;
        signer = _signer;

        ComboInfo memory combo1 = ComboInfo(combo_1_price, combo_1_ids, combo_1_quantities, 300, 300, 1, true);
        ComboInfo memory combo2 = ComboInfo(combo_2_price, combo_2_ids, combo_2_quantities, 300, 300, 1, true);
        ComboInfo memory combo3 = ComboInfo(combo_3_price, combo_3_ids, combo_3_quantities, 300, 300, 1, true);
        ComboInfo memory combo4 = ComboInfo(combo_4_price, combo_4_ids, combo_4_quantities, 300, 300, 1, true);
        ComboInfo memory combo5 = ComboInfo(combo_5_price, combo_5_ids, combo_5_quantities, 300, 300, 1, true);
        comboInfo[1] = combo1;
        comboInfo[2] = combo2;
        comboInfo[3] = combo3;
        comboInfo[4] = combo4;
        comboInfo[5] = combo5;
    }


    function setCombo(
        uint256 _comboNumber,
        uint256[] memory _mysteryBoxIds,
        uint256[] memory _mysteryBoxQuantities,
        uint256 _comboAmount,
        uint256 _price,
        uint256 _quoteErc20Key
    ) public onlyWhiteListUser {
        require(_mysteryBoxIds.length == _mysteryBoxQuantities.length, 'Invalid Quantities');
        require(_price > 0, 'Invalid Price');
        require(_quoteErc20Key == 0 || (mappingQuoteErc20s[_quoteErc20Key] != address(0)), 'Invalid Quote Token');

        delete comboInfo[_comboNumber];
        ComboInfo memory combo = ComboInfo(_price, _mysteryBoxIds, _mysteryBoxQuantities, _comboAmount, _comboAmount, _quoteErc20Key, true);
        comboInfo[_comboNumber] = combo;
        emit SetCombo(_msgSender(), _mysteryBoxIds, _mysteryBoxQuantities, _price);
    }


    function openCampaign(
        uint256[] memory _mysteryBoxIds,
        uint256[] memory _mysteryBoxPrices,
        uint256[] memory _mysteryBoxQuantities,
        uint256 _quoteErc20Key
    ) public onlyWhiteListUser {
        require(_mysteryBoxIds.length == _mysteryBoxPrices.length, 'Invalid Input');
        require(_mysteryBoxPrices.length == _mysteryBoxQuantities.length, 'Invalid Input');
        require(_quoteErc20Key == 0 || (mappingQuoteErc20s[_quoteErc20Key] != address(0)), 'Invalid Quote Token');


        campaign.quoteTokenKey = _quoteErc20Key;
        campaign.active = true;

        for (uint256 i = 0; i < _mysteryBoxIds.length; i++) {

            require(_mysteryBoxPrices[i] > 0, 'Invalid Price');
            require(_mysteryBoxQuantities[i] > 0, 'Invalid Quantity');
            require(!campaign.exist[_mysteryBoxIds[i]], 'Invalid mysteryBoxIds');
            campaign.exist[_mysteryBoxIds[i]] = true;

            campaign.mysteryBoxInfo[_mysteryBoxIds[i]].price = _mysteryBoxPrices[i];
            campaign.mysteryBoxInfo[_mysteryBoxIds[i]].quantity = _mysteryBoxQuantities[i];
            campaign.mysteryBoxInfo[_mysteryBoxIds[i]].total = _mysteryBoxQuantities[i];

            campaign.mysteryBoxIds.push(_mysteryBoxIds[i]);
            campaign.mysteryBoxPrices.push(_mysteryBoxPrices[i]);
            campaign.mysteryBoxTotals.push(_mysteryBoxQuantities[i]);
        }
        emit OpenCampaign(_msgSender(), _mysteryBoxIds);
    }


    function buyMysteryBox(
        uint256 _mysteryBoxId,
        uint256 _quantity,
        bytes calldata sig
    ) external payable whenNotPaused {
        require(feeAddress != address(0), 'Invalid Deposit');
        require(_quantity > 0, 'Invalid Amount!');
        require(campaign.active == true, 'Inactive Campaign!');
        require(campaign.mysteryBoxInfo[_mysteryBoxId].quantity >= _quantity, 'Out Of Stock!');
        bool isDiscounted = false;
        bytes32 message = prefixed(keccak256(abi.encodePacked(_msgSender(), true, address(this))));
        if (recoverSigner(message, sig) == signer && mappingBoughtNth[_msgSender()] < numberDiscounted) {
            isDiscounted = true;
        }

        uint256 totalToken = campaign.mysteryBoxInfo[_mysteryBoxId].price.mul(_quantity);
        uint256 discount = _quantity.mul(campaign.mysteryBoxInfo[_mysteryBoxId].price).mul(discountPercent).div(ZOOM);
        if (isDiscounted) {
            totalToken = totalToken.sub(discount);
            mappingBoughtNth[_msgSender()] = mappingBoughtNth[_msgSender()].add(1);
        }
        campaign.boughtBoxes[_msgSender()][_mysteryBoxId] = campaign.boughtBoxes[_msgSender()][_mysteryBoxId].add(_quantity);
        campaign.mysteryBoxInfo[_mysteryBoxId].quantity = campaign.mysteryBoxInfo[_mysteryBoxId].quantity.sub(_quantity);

        if (campaign.quoteTokenKey == 0) {
            require(msg.value >= totalToken.add(discount), 'Not Enough BNB To Buy!');
            if (discount > 0) {
                payable(_msgSender()).transfer(discount);
            }
            if (totalToken > 0) {
                payable(feeAddress).transfer(totalToken);
            }
        } else {
            require(mappingQuoteErc20s[campaign.quoteTokenKey] != address(0), 'Invalid Quote Token');
            IERC20 quoteErc20 = IERC20(mappingQuoteErc20s[campaign.quoteTokenKey]);
            require(quoteErc20.balanceOf(_msgSender()) >= totalToken, 'Not Enough ERC20 To Buy');
            require(quoteErc20.allowance(_msgSender(), address(this)) >= totalToken, 'Insufficient Allowance');
            quoteErc20.safeTransferFrom(_msgSender(), address(feeAddress), totalToken);
        }
        mysteryBoxNFT.mintMysteryBox(_msgSender(), _mysteryBoxId, _quantity);
        emit BuyMysteryBox(_msgSender(), _mysteryBoxId, _quantity);
    }

    function buyComboBox(
        uint256 _comboId,
        uint256 _quantity
    ) external payable whenNotPaused {
        require(feeAddress != address(0), 'Invalid Deposit');
        require(_quantity > 0, 'Invalid Amount!');

        ComboInfo storage combo = comboInfo[_comboId];
        require(combo.quantity >= _quantity, 'Out Of Stock!');
        require(combo.active == true, 'Inactive Combo!');

        combo.quantity = combo.quantity.sub(_quantity);

        for (uint256 i = 0; i < combo.boxIds.length; i++) {
            mysteryBoxNFT.mintMysteryBox(_msgSender(), combo.boxIds[i], combo.boxQuantities[i].mul(_quantity));
        }

        uint256 totalToken = combo.price.mul(_quantity);
        if (campaign.quoteTokenKey == 0) {
            require(msg.value >= totalToken, 'Not Enough BNB To Buy!');
            if (totalToken > 0) {
                payable(feeAddress).transfer(totalToken);
            }
        } else {
            require(mappingQuoteErc20s[combo.quoteTokenKey] != address(0), 'Invalid Quote Token');
            IERC20 quoteErc20 = IERC20(mappingQuoteErc20s[combo.quoteTokenKey]);
            require(quoteErc20.balanceOf(_msgSender()) >= totalToken, 'Not Enough ERC20 To Buy');
            require(quoteErc20.allowance(_msgSender(), address(this)) >= totalToken, 'Insufficient Allowance');
            quoteErc20.safeTransferFrom(_msgSender(), address(feeAddress), totalToken);
        }

        emit BuyComBoBox(_msgSender(), _comboId, _quantity);
    }


    function claimReward(uint256 _receiptId, uint256 _boxRefId, uint256 _amount, bytes calldata sig) external whenNotPaused {
        require(_amount > 0, 'Invalid Amount');
        require(mappingClaimed[_receiptId] == false, 'Already Claimed');
        bytes32 message = prefixed(keccak256(abi.encodePacked(_msgSender(), _receiptId, _boxRefId, _amount, address(this))));
        require(recoverSigner(message, sig) == signer, 'wrong signature');
        mappingClaimed[_receiptId] = true;
        mysteryBoxNFT.mintMysteryBox(_msgSender(), _boxRefId, _amount);
        emit ClaimReward(_msgSender(), _receiptId, _amount);
    }


    function updateCampaignPrice(uint256 _mysteryBoxId, uint256 _price) public onlyWhiteListUser {
        require(_price > 0, 'Invalid Price');
        require(campaign.mysteryBoxInfo[_mysteryBoxId].price != 0, 'invalid Box Id');
        require(campaign.mysteryBoxInfo[_mysteryBoxId].price != _price, 'No Need To Update');
        campaign.mysteryBoxInfo[_mysteryBoxId].price = _price;

        for (uint256 i = 0; i < campaign.mysteryBoxIds.length; i++) {
            if (campaign.mysteryBoxIds[i] == _mysteryBoxId) {
                campaign.mysteryBoxPrices[i] = _price;
            }
        }
        emit UpdateCampaignPrice(_msgSender(), _mysteryBoxId, _price);
    }

    function updateComboPrice(uint256 _comboId, uint256 _price) public onlyWhiteListUser {
        require(_price > 0, 'Invalid Price');
        ComboInfo storage combo = comboInfo[_comboId];
        require(combo.price != _price, 'No Need To Update');
        combo.price = _price;
    }

    function updateComboQuantity(uint256 _comboId, uint256 _quantity) public onlyWhiteListUser {
        require(_quantity > 0, 'Invalid Price');
        ComboInfo storage combo = comboInfo[_comboId];
        require(combo.quantity != _quantity, 'No Need To Update');
        combo.quantity = _quantity;
    }

    function activeCampaign() public onlyWhiteListUser {
        require(campaign.active == false, "No Need To Update!");
        campaign.active = true;
        emit Active(_msgSender(), true);
    }

    function inactiveCampaign() public onlyWhiteListUser {
        require(campaign.active == true, "No Need To Update!");
        campaign.active = false;
        emit Active(_msgSender(), false);
    }

    function activeCombo(uint256 _comboId) public onlyWhiteListUser {
        ComboInfo storage combo = comboInfo[_comboId];
        require(combo.active == false, "No Need To Update!");
        combo.active = true;
    }

    function inactiveCombo(uint256 _comboId) public onlyWhiteListUser {
        ComboInfo storage combo = comboInfo[_comboId];
        require(combo.active == true, "No Need To Update!");
        combo.active = false;
    }


    function updateQuoteTokenKey(uint256 quoteTokenKey) public onlyWhiteListUser {
        require(quoteTokenKey == 0 || (mappingQuoteErc20s[quoteTokenKey] != address(0)), 'Invalid Quote Token');
        require(campaign.quoteTokenKey != quoteTokenKey, "No Need To Update!");
        campaign.quoteTokenKey = quoteTokenKey;
        emit UpdateQuoteTokenKey(_msgSender(), quoteTokenKey);
    }

    function emergencyWithdraw(address tokenAddress, uint256 amount) public onlyWhiteListUser {
        IERC20 erc20 = IERC20(tokenAddress);
        require(erc20.balanceOf(address(this)) >= amount, 'Not Enough ERC20');
        erc20.safeTransfer(_msgSender(), amount);
        emit EmergencyWithdraw(_msgSender(), tokenAddress, amount);
    }


    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', hash));
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {

        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {

        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
        // second 32 bytes
            s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }


    function getBoughtBoxes(address buyer, uint256 _mysteryBoxId) public view returns (uint256) {
        return campaign.boughtBoxes[buyer][_mysteryBoxId];
    }


    function getCampaignInfo() public view returns (CampaignReturnInfo memory) {
        CampaignReturnInfo memory result;
        result.active = campaign.active;
        result.quoteTokenKey = campaign.quoteTokenKey;
        result.mysteryBoxIds = campaign.mysteryBoxIds;
        result.mysteryBoxPrices = campaign.mysteryBoxPrices;
        result.mysteryBoxTotals = campaign.mysteryBoxTotals;

        uint256[] memory mysteryBoxQuantities = new uint256[](campaign.mysteryBoxIds.length);
        for (uint256 i = 0; i < campaign.mysteryBoxIds.length; i++) {
            mysteryBoxQuantities[i] = campaign.mysteryBoxInfo[campaign.mysteryBoxIds[i]].quantity;
        }
        result.mysteryBoxQuantities = mysteryBoxQuantities;
        return result;
    }

    function getCampaignBoxInfo(uint256 _mysteryBoxId) public view returns (CampaignReturnInfo memory) {
        CampaignReturnInfo memory result;
        result.active = campaign.active;
        result.quoteTokenKey = campaign.quoteTokenKey;

        result.mysteryBoxId = _mysteryBoxId;
        result.mysteryBoxPrice = campaign.mysteryBoxInfo[_mysteryBoxId].price;
        result.mysteryBoxQuantity = campaign.mysteryBoxInfo[_mysteryBoxId].quantity;
        result.mysteryBoxTotal = campaign.mysteryBoxInfo[_mysteryBoxId].total;

        return result;
    }

    function getSoldBox(uint256 _mysteryBoxId) public view returns (uint256, uint256) {
        return (campaign.mysteryBoxInfo[_mysteryBoxId].quantity, campaign.mysteryBoxInfo[_mysteryBoxId].total);
    }

    function getComBoBoxIds(uint256 comboId) public view returns (uint256[] memory) {
        return comboInfo[comboId].boxIds;
    }

    function getComBoBoxQuantities(uint256 comboId) public view returns (uint256[] memory) {
        return comboInfo[comboId].boxQuantities;
    }


    function pause() public onlyOwner whenNotPaused {
        _pause();
    }


    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

}