/**
 *Submitted for verification at BscScan.com on 2021-04-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// File: @openzeppelin/contracts/utils/Context.sol

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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

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

// File: @openzeppelin/contracts/math/SafeMath.sol

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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

// File: @openzeppelin/contracts/utils/Address.sol

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
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    //    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    //        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    //    }
    //
    //    /**
    //     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
    //     * but performing a delegate call.
    //     *
    //     * _Available since v3.4._
    //     */
    //    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    //        require(isContract(target), "Address: delegate call to non-contract");
    //
    //        // solhint-disable-next-line avoid-low-level-calls
    //        (bool success, bytes memory returndata) = target.delegatecall(data);
    //        return _verifyCallResult(success, returndata, errorMessage);
    //    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/introspection/IERC165.sol

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}


// File: contracts/NFTMaster.sol

// This contract is owned by Timelock.
contract OpenGateNFTMasterV2 is Ownable, IERC721Receiver {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event CreateCollection(address _who, uint256 _collectionId);
    event PublishCollection(address _who, uint256 _collectionId);
    event UnpublishCollection(address _who, uint256 _collectionId);
    event NFTDeposit(address _who, address _tokenAddress, uint256 _tokenId);
    event NFTWithdraw(address _who, address _tokenAddress, uint256 _tokenId);
    event NFTClaim(address _who, address _tokenAddress, uint256 _tokenId);

    //    IERC20 public wETH; // 0x0000000000000000000000000000000000000000
    //    IERC20 public linkToken; // 0x0000000000000000000000000000000000000000

    //    uint256 public linkCost = 1e17;  // 0.1 LINK (100000000000000000)
    //    ILinkAccessor public linkAccessor;  // 0x0000000000000000000000000000000000000000

    // Platform fee.
    uint256 constant FEE_BASE = 10000;  // 汇率基数
    uint256 public feeRate = 500;  // 5% = (feeRate/FEE_BASE)

    address payable public feeTo;

    // Collection creating fee.
    uint256 public creatingFee = 0;  // By default, 0
    address public createFeeCoin = address(0);

    //    IUniswapV2Router02 public router;

    uint256 public nextNFTId;
    uint256 public nextCollectionId;

    struct NFT {
        uint256 id;
        address tokenAddress;
        uint256 tokenId;
        address payable owner;
        uint256 price;  // 定价价格
        uint256 paid;   // 本合约已支付给艺术品原创作者金额
        uint256 collectionId;
        uint256 indexInCollection;  // 在集合中的索引
        uint256 claimAt; // NFT作为盲盒被打开领取时间
    }

    struct OrderInfo {
        uint256 id;
        uint256 collectionId;
        address payable owner;
        uint256 buyAt;
        uint256 claimAt;
    }

    // nftId => NFT
    mapping(uint256 => NFT) public allNFTs;

    // owner => nftId[]
    mapping(address => uint256[]) public nftsByOwner;

    // tokenAddress => tokenId => nftId
    mapping(address => mapping(uint256 => uint256)) public nftIdMap;

    struct Collection {
        uint256 id;
        address payable owner;
        string name;
        uint256 size;
        uint256 commissionRate;  // for curator (owner)

        address coin;   // 交易币

        string[] detail;   // 集合信息
        // The following are runtime variables before publish
        uint256 totalPrice;
        uint256 averagePrice;
        uint256 fee;
        uint256 commission;

        // The following are runtime variables after publish
        uint256 publishedAt;  // time that published.
        uint256 timesToCall;
        uint256 soldCount;
    }

    struct Collaborator {
        uint256 collectionId;
        address[] users;
    }

    // collectionId => Collection
    mapping(uint256 => Collection) public allCollections;

    // owner => collectionId[]
    mapping(address => uint256[]) public collectionsByOwner;

    // collectionId => who => true/false
    mapping(uint256 => mapping(address => bool)) public isCollaborator;

    // collectionId => collaborators
    mapping(uint256 => address[]) public collaborators;



    // collectionId => nftId[]
    mapping(uint256 => uint256[]) public nftsByCollectionId;

    struct RequestInfo {
        uint256 collectionId;
        uint256 index;
    }

    mapping(bytes32 => RequestInfo) public requestInfoMap;

    // 用户购买盲盒记录
    struct Slot {
        uint256 collectionId;
        address payable owner;
        uint256 size;
        //        uint256 claimAt; // 盲盒打开时间
    }

    struct SlotCollection {
        uint256 collectionId;
        Slot[] slots;
    }

    // collectionId => Slot[]
    mapping(uint256 => Slot[]) public slotMap;

    // user => SlotCollection
    mapping(address => Slot[]) public userSlotMap;

    // collectionId => orderInfo List
    mapping(uint256 => OrderInfo[]) public orderInfoMap;
    // collectionId => userAddress => orderId List
    mapping(uint256 => mapping(address => uint256[])) public userOrderInfoMap;

    // collectionId => randomnessIndex => r
    mapping(uint256 => mapping(uint256 => uint256)) public nftMapping;

    uint256 public nftPriceFloor = 1e17;  // 0.1 USDC（1000000000000000000）
    uint256 public nftPriceCeil = 1e24;  // 1M USDC (1000000000000000000000000)
    uint256 public minimumCollectionSize = 3;  // 3 blind boxes
    uint256 public maximumDuration = 2 seconds;  // Refund if not sold out in 14 days.
    //    uint256 public maximumDuration = 14 days;  // Refund if not sold out in 14 days.

    constructor() public {}

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setFeeRate(uint256 feeRate_) external onlyOwner {
        feeRate = feeRate_;
    }

    function setFeeTo(address payable feeTo_) external onlyOwner {
        feeTo = feeTo_;
    }

    function setCreatingFee(uint256 creatingFee_) external onlyOwner {
        creatingFee = creatingFee_;
    }

    function setCreatingFeeCoin(address createFeeCoin_) external onlyOwner {
        createFeeCoin = createFeeCoin_;
    }


    function setNFTPriceFloor(uint256 value_) external onlyOwner {
        require(value_ < nftPriceCeil, "should be higher than floor");
        nftPriceFloor = value_;
    }

    function setNFTPriceCeil(uint256 value_) external onlyOwner {
        require(value_ > nftPriceFloor, "should be higher than floor");
        nftPriceCeil = value_;
    }

    function setMinimumCollectionSize(uint256 size_) external onlyOwner {
        minimumCollectionSize = size_;
    }

    function setMaximumDuration(uint256 maximumDuration_) external onlyOwner {
        maximumDuration = maximumDuration_;
    }

    function _generateNextNFTId() private returns (uint256) {
        return ++nextNFTId;
    }

    function _generateNextCollectionId() private returns (uint256) {
        return ++nextCollectionId;
    }


    function slotByOwner(address owner) public view returns (Slot[] memory){
        return userSlotMap[owner];
    }

    function slotsById(uint256 id) public view returns (Slot[] memory){
        return slotMap[id];
    }

    function orderList(uint256 collectionId_) public view returns (OrderInfo[] memory){
        return orderInfoMap[collectionId_];
    }

    function winners(uint256 collectionId_) public view returns (address[] memory){
        OrderInfo[] memory orderInfos = orderList(collectionId_);
        address[] memory winners = new address[](orderInfos.length);
        for (uint256 i = 0; i < orderInfos.length; i++) {
            winners[i] = address(orderInfos[i].owner);
        }
        return winners;
    }

    function orderListByUser(uint256 collectionId_, address user_) public view returns (OrderInfo[] memory){
        uint256[] memory ids = userOrderInfoMap[collectionId_][user_];
        if (ids.length == 0) {
            return new OrderInfo[](0);
        }
        OrderInfo[] memory oi = orderInfoMap[collectionId_];
        OrderInfo[] memory oiForUser = new OrderInfo[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            oiForUser[i] = oi[ids[i]];
        }
        return oiForUser;
    }

    function orderListByUserPending(uint256 collectionId_, address user_) public view returns (OrderInfo[] memory){
        uint256[] memory ids = userOrderInfoMap[collectionId_][user_];
        if (ids.length == 0) {
            return new OrderInfo[](0);
        }
        OrderInfo[] memory oi = orderInfoMap[collectionId_];
        OrderInfo[] memory oiForUser = new OrderInfo[](ids.length);
        uint256 j = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            if (oi[ids[i]].claimAt == 0) {
                oiForUser[j] = oi[ids[i]];
                j++;
            }
        }

        OrderInfo[] memory oiForUser2 = new OrderInfo[](j);
        uint256 l = 0;
        for (uint256 k = 0; k < oiForUser.length; k++) {
            if (oiForUser[k].id != 0) {
                oiForUser2[l] = oiForUser[k];
                l++;
            }
        }
        return oiForUser2;
    }

    function createOrder(uint256 collectionId_, address payable owner_, uint256 times_) private {
        require(times_ > 0 && times_ <= allCollections[collectionId_].size, 'times error');
        uint256 id_ = orderInfoMap[collectionId_].length;
        for (uint256 i = 0; i < times_; i++) {
            OrderInfo memory oi;
            oi.id = id_ + i;
            oi.collectionId = collectionId_;
            oi.owner = owner_;
            oi.buyAt = block.timestamp;

            userOrderInfoMap[collectionId_][owner_].push(oi.id);
            orderInfoMap[collectionId_].push(oi);
        }
    }

    //    function allCollaborators() public view returns (Collaborator[] memory){
    //        Collaborator[] memory cs = new Collaborator[](nextCollectionId);
    //        for (uint256 i = 0; i < nextCollectionId - 1; i++) {
    //            // 0的id是没有数据的
    //            uint256 collectionId = (i + 1);
    //            cs[collectionId] = Collaborator({collectionId : collectionId, users : collaborators[collectionId]});
    //        }
    //        return cs;
    //    }

    function collaboratorsById(uint256 id) public view returns (address[] memory){
        return collaborators[id];
    }

    function allCollectionList() public view returns (Collection[] memory){
        Collection[] memory cList = new Collection[](nextCollectionId);
        for (uint256 i = 0; i < nextCollectionId; i++) {
            cList[i] = allCollections[i + 1];
        }
        return cList;
    }


    function allCollectionByOwner(address owner) public view returns (Collection[] memory){
        uint256[] memory idList = collectionsByOwner[owner];
        Collection[] memory cList = new Collection[](idList.length);
        for (uint256 i = 0; i < idList.length; i++) {
            cList[i] = allCollections[idList[i]];
        }
        return cList;
    }

    function allNFTByCollection(uint256 collectionId) public view returns (NFT[] memory){
        NFT[] memory nfts = new NFT[](nftsByCollectionId[collectionId].length);
        for (uint256 i = 0; i < nftsByCollectionId[collectionId].length; i++) {
            nfts[i] = allNFTs[nftsByCollectionId[collectionId][i]];
        }
        return nfts;
    }




    // 上传NFT至本市场
    function _depositNFT(address tokenAddress_, uint256 tokenId_) private returns (uint256) {
        IERC721(tokenAddress_).safeTransferFrom(_msgSender(), address(this), tokenId_);

        NFT memory nft;
        nft.tokenAddress = tokenAddress_;
        nft.tokenId = tokenId_;
        nft.owner = _msgSender();
        nft.collectionId = 0;
        nft.indexInCollection = 0;

        uint256 nftId;

        if (nftIdMap[tokenAddress_][tokenId_] > 0) {
            nftId = nftIdMap[tokenAddress_][tokenId_];
        } else {
            nftId = _generateNextNFTId();
            nftIdMap[tokenAddress_][tokenId_] = nftId;
        }

        nft.id = nftId;
        allNFTs[nftId] = nft;
        nftsByOwner[_msgSender()].push(nftId);

        emit NFTDeposit(_msgSender(), tokenAddress_, tokenId_);
        return nftId;
    }

    // （private）撤回NFT / 索取已购买成功的盲盒 （NFT所有权取回） -- 用于 claimNFT() 和 removeNFTFromCollection()
    function _withdrawNFT(address who_, uint256 nftId_, bool isClaim_) private {
        allNFTs[nftId_].owner = address(0);
        allNFTs[nftId_].collectionId = 0;

        address tokenAddress = allNFTs[nftId_].tokenAddress;
        uint256 tokenId = allNFTs[nftId_].tokenId;

        IERC721(tokenAddress).safeTransferFrom(address(this), who_, tokenId);

        if (isClaim_) {
            allNFTs[nftId_].claimAt = block.timestamp;
            emit NFTClaim(who_, tokenAddress, tokenId);
        } else {
            emit NFTWithdraw(who_, tokenAddress, tokenId);
        }
    }

    //    function claimMyNFT(uint256 collectionId_) public {
    //        address[] memory winners_ = winners(collectionId_);
    //        for (uint256 i = 0; i < winners_.length; i++) {
    //            if (winners_[i] == _msgSender()) {
    //                claimNFT(collectionId_, i);
    //            }
    //        }
    //    }

    function claimUserNFT(uint256 collectionId_, address user, uint256 times_) public returns (NFT[] memory) {
        require(owner() == address(_msgSender()) || address(user) == address(_msgSender()), 'forbidden!');

        OrderInfo[] memory orders = orderListByUserPending(collectionId_, user);
        require(times_ <= orders.length, 'times error');
        if (times_ == 0) {
            times_ = orders.length;
        }
        NFT[] memory nftList_ = new NFT[](times_);
        for (uint256 i = 0; i < times_; i++) {
            nftList_[i] = allNFTs[claimNFT(collectionId_, address(_msgSender()))];
            orderInfoMap[collectionId_][orders[i].id].claimAt = block.timestamp;
        }
        return nftList_;
    }

    // 拿取回（打开）用户购买的盲盒：NFT所有权转移至购买者、本合约将购买所得费用扣除手续费及佣金后转移至 【NFT原所有者】（如果未索取收益）
    function claimNFT(uint256 collectionId_, address user) private returns (uint256){
        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount == collection.size, "Not finished");

        address winner = user;
        NFT memory nft_ = randomNft(collectionId_);
        uint256 nftId = nft_.id;

        //        require(allNFTs[nftId].collectionId == collectionId_, string(abi.encodePacked("Already claimed", uint2str(nftId))));
        require(allNFTs[nftId].collectionId == collectionId_, "Already claimed");

        if (allNFTs[nftId].paid == 0) {
            allNFTs[nftId].paid = allNFTs[nftId].price.mul(
                FEE_BASE.sub(feeRate).sub(collection.commissionRate)).div(FEE_BASE);

            if (collection.coin == address(0)) {
                allNFTs[nftId].owner.transfer(allNFTs[nftId].paid);
            } else {
                IERC20(collection.coin).transfer(allNFTs[nftId].owner, allNFTs[nftId].paid);
            }

        }

        _withdrawNFT(_msgSender(), nftId, true);
        return nftId;
    }

    //    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    //        if (_i == 0) {
    //            return "0";
    //        }
    //        uint j = _i;
    //        uint len;
    //        while (j != 0) {
    //            len++;
    //            j /= 10;
    //        }
    //        bytes memory bstr = new bytes(len);
    //        uint k = len;
    //        while (_i != 0) {
    //            k = k - 1;
    //            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
    //            bytes1 b1 = bytes1(temp);
    //            bstr[k] = b1;
    //            _i /= 10;
    //        }
    //        return string(bstr);
    //    }
    // nft pending in collection
    function nftsPending(uint256 collectionId_) public view returns (uint256[] memory){
        uint256[] memory nftIds_ = nftsByCollectionId[collectionId_];
        uint256[] memory nftsPending_ = new uint256[](nftIds_.length);
        uint256 j = 0;
        for (uint256 i = 0; i < nftIds_.length; i++) {
            if (allNFTs[nftIds_[i]].claimAt == 0) {
                nftsPending_[j] = nftIds_[i];
                j++;
            }
        }
        uint256[] memory nftsPending2_ = new uint256[](j);
        uint256 l = 0;
        for (uint256 k = 0; k < nftsPending_.length; k++) {
            if (nftsPending_[k] != 0) {
                nftsPending2_[l] = nftsPending_[k];
                l++;
            }
        }

        return nftsPending2_;
    }
    // random nft pending in collection
    function randomNft(uint256 collectionId_) public view returns (NFT memory){
        uint256[] memory nftsPending_ = nftsPending(collectionId_);
        uint256 l = nftsPending_.length;
        uint256 r = psuedoRandomness() % l;
        return allNFTs[nftsPending_[r]];
    }


    //    // 获取收益（NFT原所有者（创作者））
    //    function claimRevenue(uint256 collectionId_, uint256 nftId) private {
    //        Collection storage collection = allCollections[collectionId_];
    //
    //        require(collection.soldCount == collection.size, "Not finished");
    //
    //        //        uint256 nftId = nftsByCollectionId[collectionId_][index_];
    //
    //        //        require(allNFTs[nftId].owner == _msgSender() && allNFTs[nftId].collectionId > 0, "NFT not claimed");
    //
    //        if (allNFTs[nftId].paid == 0) {
    //            allNFTs[nftId].paid = allNFTs[nftId].price.mul(
    //                FEE_BASE.sub(feeRate).sub(collection.commissionRate)).div(FEE_BASE);
    //
    //            if (collection.coin == address(0)) {
    //                // BNB
    //                allNFTs[nftId].owner.transfer(allNFTs[nftId].paid);
    //            } else {
    //
    //                IERC20(collection.coin).safeTransfer(allNFTs[nftId].owner, allNFTs[nftId].paid);
    //            }
    //        }
    //    }

    // 索取佣金（管理员，系列集合发起者curator）
    function claimCommission(uint256 collectionId_) external {
        Collection storage collection = allCollections[collectionId_];

        require(_msgSender() == collection.owner, "Only curator can claim");
        require(collection.soldCount == collection.size, "Not finished");

        if (collection.coin == address(0)) {
            // BNB
            collection.owner.transfer(collection.commission);
        } else {
            IERC20(collection.coin).safeTransfer(collection.owner, collection.commission);
        }

        // Mark it claimed.
        collection.commission = 0;
    }

    // 索取手续费收益（平台收取 feeTo）
    function claimFee(uint256 collectionId_) external {
        require(feeTo != address(0), "Please set feeTo first");

        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount == collection.size, "Not finished");
        if (collection.coin == address(0)) {
            feeTo.transfer(collection.fee);
        } else {
            IERC20(collection.coin).safeTransfer(feeTo, collection.fee);
        }

        // Mark it claimed.
        collection.fee = 0;
    }

    // 创建系列集合（集合名、可容纳NFT数、佣金比例、生态币、支持创作者列表）
    function createCollection(
        string calldata name_,
        uint256 size_,
        uint256 commissionRate_,
        address coin_,
    //        bool willAcceptBLES_,
        address[] calldata collaborators_
    ) public payable returns (Collection memory){
        return createCollectionV2(name_, size_, commissionRate_, coin_, collaborators_, '', '', '');
    }

    function createCollectionV2(
        string calldata name_,
        uint256 size_,
        uint256 commissionRate_,
        address coin_,
    //        bool willAcceptBLES_,
        address[] calldata collaborators_,
        string memory cover_,
        string memory title_,
        string memory introduction_
    ) public payable returns (Collection memory){
        require(size_ >= minimumCollectionSize, "Size too small");
        require(commissionRate_.add(feeRate) < FEE_BASE, "Too much commission");

        if (creatingFee > 0) {
            // 创建集合手续费.
            if (createFeeCoin == address(0)) {
                // BNB
                require(creatingFee == msg.value, 'createFee error');
                feeTo.transfer(creatingFee);
            } else {
                IERC20(createFeeCoin).safeTransferFrom(_msgSender(), feeTo, creatingFee);
            }
        }

        Collection memory collection = createCollection(name_, size_, commissionRate_, coin_, collaborators_, cover_, title_, introduction_);

        emit CreateCollection(_msgSender(), collection.id);
        return collection;
    }

    function createCollection(
        string calldata name_,
        uint256 size_,
        uint256 commissionRate_,
        address coin_,
    //        bool willAcceptBLES_,
        address[] calldata collaborators_,
        string memory cover_,
        string memory title_,
        string memory introduction_
    ) private returns (Collection memory){
        Collection memory collection;
        collection.owner = _msgSender();
        collection.name = name_;
        collection.size = size_;
        collection.commissionRate = commissionRate_;
        collection.totalPrice = 0;
        collection.averagePrice = 0;
        collection.coin = coin_;
        collection.publishedAt = 0;

        string[] memory detail = new string[](3);
        detail[0] = cover_;
        detail[1] = title_;
        detail[2] = introduction_;

        collection.detail = detail;

        //        collection.cover = cover_;
        //        collection.title = title_;
        //        collection.introduction = introduction_;

        uint256 collectionId = _generateNextCollectionId();
        collection.id = collectionId;

        allCollections[collectionId] = collection;
        collectionsByOwner[_msgSender()].push(collectionId);
        collaborators[collectionId] = collaborators_;

        for (uint256 i = 0; i < collaborators_.length; ++i) {
            //            isCollaborator[collectionId][collaborators_[i]] = true;
            updateCollaborator(collectionId, collaborators_[i], true);
        }
        return collection;
    }

    function updateCollaborator(uint256 _collectionId, address user, bool status) public {
        require(allCollections[_collectionId].owner == _msgSender() || owner() == _msgSender(), "owner only");
        isCollaborator[_collectionId][user] = status;
    }

    function updateCollectionDetail(
        uint256 collectionId,
        string memory cover_,
        string memory title_,
        string memory introduction_
    ) public {
        require(allCollections[collectionId].owner == _msgSender() || owner() == _msgSender(), "owner only");
        string[] memory detail = new string[](3);
        detail[0] = cover_;
        detail[1] = title_;
        detail[2] = introduction_;
        allCollections[collectionId].detail = detail;
    }

    // 查询集合是否已发布
    function isPublished(uint256 collectionId_) public view returns (bool) {
        return allCollections[collectionId_].publishedAt > 0;
    }

    // 添加NFT到集合中（需先将NFT上架本市场）
    function _addNFTToCollection(uint256 nftId_, uint256 collectionId_, uint256 price_) private {
        Collection storage collection = allCollections[collectionId_];

        require(allNFTs[nftId_].owner == _msgSender(), "Only NFT owner can add");

        require(price_ >= nftPriceFloor && price_ <= nftPriceCeil, "Price not in range");
        //        require(price_ >= nftPriceFloor && price_ <= nftPriceCeil, string(abi.encodePacked("Price not in range", uint2str(price_))));

        require(allNFTs[nftId_].collectionId == 0, "Already added");
        require(!isPublished(collectionId_), "Collection already published");
        require(nftsByCollectionId[collectionId_].length < collection.size, "collection full");

        allNFTs[nftId_].price = price_;
        allNFTs[nftId_].collectionId = collectionId_;
        allNFTs[nftId_].indexInCollection = nftsByCollectionId[collectionId_].length;

        // Push to nftsByCollectionId.
        nftsByCollectionId[collectionId_].push(nftId_);

        collection.totalPrice = collection.totalPrice.add(price_);

        //        if (!collection.willAcceptBLES) {
        collection.fee = collection.fee.add(price_.mul(feeRate).div(FEE_BASE));
        //        }

        collection.commission = collection.commission.add(price_.mul(collection.commissionRate).div(FEE_BASE));
    }

    //    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    //        if (_i == 0) {
    //            return "0";
    //        }
    //        uint j = _i;
    //        uint len;
    //        while (j != 0) {
    //            len++;
    //            j /= 10;
    //        }
    //        bytes memory bstr = new bytes(len);
    //        uint k = len;
    //        while (_i != 0) {
    //            k = k - 1;
    //            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
    //            bytes1 b1 = bytes1(temp);
    //            bstr[k] = b1;
    //            _i /= 10;
    //        }
    //        return string(bstr);
    //    }
    // 直接添加NFT到集合中
    function addNFTToCollection(address tokenAddress_, uint256 tokenId_, uint256 collectionId_, uint256 price_) external {

        require(allCollections[collectionId_].owner == _msgSender() ||
            isCollaborator[collectionId_][_msgSender()], "Needs collection owner or collaborator");

        uint256 nftId = _depositNFT(tokenAddress_, tokenId_);
        _addNFTToCollection(nftId, collectionId_, price_);
    }

    // 更新集合中NFT的报价（未发布的集合才可更新报价）
    //    function editNFTInCollection(uint256 nftId_, uint256 collectionId_, uint256 price_) external {
    //        Collection storage collection = allCollections[collectionId_];
    //
    //        require(collection.owner == _msgSender() ||
    //            allNFTs[nftId_].owner == _msgSender(), "Needs collection owner or NFT owner");
    //
    //        require(price_ >= nftPriceFloor && price_ <= nftPriceCeil, "Price not in range");
    //
    //        require(allNFTs[nftId_].collectionId == collectionId_, "NFT not in collection");
    //        require(!isPublished(collectionId_), "Collection already published");
    //
    //        collection.totalPrice = collection.totalPrice.add(price_).sub(allNFTs[nftId_].price);
    //
    //        collection.fee = collection.fee.add(
    //            price_.mul(feeRate).div(FEE_BASE)).sub(
    //            allNFTs[nftId_].price.mul(feeRate).div(FEE_BASE));
    //
    //        // 更新集合的佣金金额
    //        collection.commission = collection.commission.add(
    //            price_.mul(collection.commissionRate).div(FEE_BASE)).sub(
    //            allNFTs[nftId_].price.mul(collection.commissionRate).div(FEE_BASE));
    //
    //        allNFTs[nftId_].price = price_;
    //        // Change price.
    //    }

    // 从集合中移除NFT
    function _removeNFTFromCollection(uint256 nftId_, uint256 collectionId_) private {
        Collection storage collection = allCollections[collectionId_];

        require(allNFTs[nftId_].owner == _msgSender() ||
            collection.owner == _msgSender(),
            "Only NFT owner or collection owner can remove");
        require(allNFTs[nftId_].collectionId == collectionId_, "NFT not in collection");
        require(!isPublished(collectionId_), "Collection already published");

        collection.totalPrice = collection.totalPrice.sub(allNFTs[nftId_].price);

        collection.fee = collection.fee.sub(
            allNFTs[nftId_].price.mul(feeRate).div(FEE_BASE));

        collection.commission = collection.commission.sub(
            allNFTs[nftId_].price.mul(collection.commissionRate).div(FEE_BASE));


        allNFTs[nftId_].collectionId = 0;

        // Removes from nftsByCollectionId
        uint256 index = allNFTs[nftId_].indexInCollection;
        uint256 lastNFTId = nftsByCollectionId[collectionId_][nftsByCollectionId[collectionId_].length - 1];

        nftsByCollectionId[collectionId_][index] = lastNFTId;
        allNFTs[lastNFTId].indexInCollection = index;
        nftsByCollectionId[collectionId_].pop();
    }

    // 从集合中移除NFT，并收回NFT所有权
    function removeNFTFromCollection(uint256 nftId_, uint256 collectionId_) external {
        address nftOwner = allNFTs[nftId_].owner;
        _removeNFTFromCollection(nftId_, collectionId_);
        _withdrawNFT(nftOwner, nftId_, false);
    }


    // 发布集合：打包盲盒、分配价格、设置发布时间、
    function publishCollection(uint256 collectionId_, address[] calldata path, uint256 amountInMax_, uint256 deadline_) external {
        Collection storage collection = allCollections[collectionId_];

        require(collection.owner == _msgSender(), "Only owner can publish");

        uint256 actualSize = nftsByCollectionId[collectionId_].length;
        require(actualSize >= minimumCollectionSize, "Not enough boxes");

        collection.size = actualSize;

        // Math.ceil(totalPrice / actualSize);
        collection.averagePrice = collection.totalPrice.add(actualSize.sub(1)).div(actualSize);
        collection.publishedAt = now;


        emit PublishCollection(_msgSender(), collectionId_);
    }

    // 下架还未售空的集合，同时将已购买的金额退回购买者
    function unpublishCollection(uint256 collectionId_) external {
        // Anyone can call.

        Collection storage collection = allCollections[collectionId_];

        // Only if the boxes not sold out in maximumDuration, can we unpublish.
        require(now > collection.publishedAt + maximumDuration, "Not expired yet");
        require(collection.soldCount < collection.size, "Sold out");

        collection.publishedAt = 0;
        collection.soldCount = 0;

        // Now refund to the buyers.
        uint256 length = slotMap[collectionId_].length;
        for (uint256 i = 0; i < length; ++i) {
            Slot memory slot = slotMap[collectionId_][length.sub(i + 1)];
            slotMap[collectionId_].pop();
            _removeUserSlot(slot);

            // 退款
            if (collection.coin == address(0)) {
                slot.owner.transfer(collection.averagePrice.mul(slot.size));
            } else {
                IERC20(collection.coin).transfer(slot.owner, collection.averagePrice.mul(slot.size));
            }
        }

        emit UnpublishCollection(_msgSender(), collectionId_);
    }


    // 提取（购买）盲盒：可一次性购买多次盲盒
    function drawBoxes(uint256 collectionId_, uint256 times_) public payable {
        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount.add(times_) <= collection.size, "Not enough left");

        uint256 cost = collection.averagePrice.mul(times_);


        if (collection.coin == address(0)) {
            require(msg.value == cost, 'not enough token');

        } else {
            require(IERC20(collection.coin).allowance(_msgSender(), address(this)) >= cost, 'not enough erc20 token');
            IERC20(collection.coin).safeTransferFrom(_msgSender(), address(this), cost);
        }

        Slot memory slot;
        slot.collectionId = collectionId_;
        slot.owner = _msgSender();
        slot.size = times_;
        //        slot.claimAt = 0;
        slotMap[collectionId_].push(slot);
        userSlotMap[slot.owner].push(slot);

        createOrder(slot.collectionId, slot.owner, times_);

        collection.soldCount = collection.soldCount.add(times_);

    }


    function _removeUserSlot(Slot memory slot) private {
        for (uint256 i = 0; i < userSlotMap[slot.owner].length; i++) {
            if (userSlotMap[slot.owner][i].collectionId == slot.collectionId) {
                userSlotMap[slot.owner][i] = userSlotMap[slot.owner][userSlotMap[slot.owner].length.sub(1)];
                userSlotMap[slot.owner].pop();
            }
        }
    }


    // 伪随机数
    function psuedoRandomness() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
                block.timestamp + block.difficulty +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
                block.gaslimit +
                ((uint256(keccak256(abi.encodePacked(_msgSender())))) / (now)) +
                block.number
            )));
    }

}