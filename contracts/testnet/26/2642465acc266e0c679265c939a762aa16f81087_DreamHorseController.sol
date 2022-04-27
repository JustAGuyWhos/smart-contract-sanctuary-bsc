/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;


/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
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

// File: DreamHorseNFT.sol



pragma solidity ^0.8.0;





contract DreamHorseNFT is ERC721URIStorage, Ownable {

    using SafeMath for uint256;

    event GetNFT(address indexed user, uint256 tokenId, uint256 types, uint256 iamgeId);

    event OpenBlindBox(address indexed user, uint256 cost, uint256 tokenId);

	uint256 public counter;

    uint256 private randNum = 0;

    mapping(uint256 => uint256) public NFTIDs;//tokenId

    mapping(uint256 => uint256) public NFTIDToIndex;

    mapping(uint256 => uint256) public NFTIDToTypes;

    mapping(uint256 => uint256) public NFTIDToImageId;

    mapping(address => uint256[]) public userNFTIDs;

    mapping(address => mapping(uint256 => uint256)) public userNFTTypeNumber;

    uint256[4][3] public boxRates;

    uint256[3] public boxsPrices;

    uint256[3] public boxMaxTimes;

    uint256[6] public imageNumber;

    mapping(address => bool) public isUser;

    mapping(address => address) public recommenders;

    mapping(address => uint256) public recommendUserNumber;

    mapping(address => address[]) public recommendUsers;

    mapping(address => uint256) public recommendReward;

    uint256 public recommendRewardRateForNFT = 8;

    uint256 public recommendRewardRateForBattle = 5;

    uint256 public recommendRewardRateForPledge = 5;

    uint256 public bindRebate = 98;

    uint256 public presaleStartTime = 1650542400;
    uint256 public presaleEndTime = 1652544000;

    // address USDT = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address USDT = 0xD973d8D9Bc9A3d03c9558509B67942D7eB92cd93;

    address recipientAddress = 0xa139513555804702D3B5D8c00F1d121d27592b1B;

    address private controllerAddress;

	constructor() ERC721("DreamHorseNFT", "DHN"){
		counter = 0;

        boxRates[0] = [60,95,100,100];
        boxRates[1] = [0,70,97,100];
        boxRates[2] = [0,0,80,98];

        boxsPrices = [99,199,299];

        boxMaxTimes = [5000,3000,1000];

        imageNumber = [20,20,20,20,20,22];
	}

    function setController(address controllerAddr) public onlyOwner {
        controllerAddress = controllerAddr;
    }

    modifier onlyController {
         require(controllerAddress == msg.sender,"Must be controller");
         _;
    }

    function setBoxsRate(uint256 boxId, uint256 A, uint256 N, uint256 R, uint256 SR, uint256 SSR) public onlyOwner {

        if(A + N + R + SR + SSR == 100){
            boxRates[boxId - 1][0] = A;
            boxRates[boxId - 1][1] = A + N;
            boxRates[boxId - 1][2] = A + N + R;
            boxRates[boxId - 1][3] = A + N + R + SR;
        }
    }

    function setBoxsPrice(uint256 boxId, uint256 price) public onlyOwner {
        boxMaxTimes[boxId - 1] = price;  
    }

    function setBoxMaxTimes(uint256 index, uint256 num) public onlyOwner {
        boxMaxTimes[index - 1] = num;
    }
    
    function setStartTime(uint256 startTime) public onlyOwner {
        presaleStartTime = startTime;
    }
    
    function setEndTime(uint256 endTime) public onlyOwner {
        presaleEndTime = endTime;
    }

    function setImageNumber(uint256 index, uint256 num) public onlyOwner {
        imageNumber[index - 1] = num;
    }

    function setRecommendRewardRateForNFT(uint256 rate) public onlyOwner {
        recommendRewardRateForNFT = rate;
    }

    function setRecommendRewardRateForBattle(uint256 rate) public onlyOwner {
        recommendRewardRateForBattle = rate;
    }

    function setRecommendRewardRateForPledge(uint256 rate) public onlyOwner {
        recommendRewardRateForPledge = rate;
    }

    function setBindRebate(uint256 rebate) public onlyOwner {
        bindRebate = rebate;
    }

    function setRecipientAddress(address recipient) public onlyOwner {
        recipientAddress = recipient;   
    }

    function setUSDTAddress(address usdt) public onlyOwner {
        USDT = usdt;   
    }

    function bindRecommender(address recommender) public {

        require(recommender != address(0) && recommender != msg.sender, "Please enter the correct address");

        require(recommenders[msg.sender] == address(0), "This user has bound a recommender");

        require(recommenders[recommender] != msg.sender, "Users cannot bind to each other");

        require(isUser[recommender], "recommender must be user");
        
        recommenders[msg.sender] = recommender;

        recommendUserNumber[recommender] ++;

        recommendUsers[recommender].push(msg.sender);
    }

    function openBlindBox(uint256 boxId) public returns (uint256){

        require(presaleStartTime < block.timestamp && block.timestamp < presaleEndTime,"Presale is not open yet");

        require(boxMaxTimes[boxId - 1] >= 1,"Blind box is sold out");

        boxMaxTimes[boxId - 1] -= 1;

        uint256 decimals = ERC20(USDT).decimals();

        uint256 price = boxsPrices[boxId - 1] * 10 ** decimals;

        address recommender = recommenders[msg.sender];

        if(recommender != address(0)){

            price = price.mul(bindRebate).div(100);

            uint256 reward = price.mul(recommendRewardRateForNFT).div(100);

            price = price.sub(reward);

            ERC20(USDT).transferFrom(msg.sender, recommender, reward);

            recommendReward[recommender] += reward.mul(100).div(10 ** decimals);
        }

        ERC20(USDT).transferFrom(msg.sender, recipientAddress, price);

        uint256 types = _getNFTType(boxId);

        uint256 tokenId = _createNFT(msg.sender, types);

        if(!isUser[msg.sender]){
            isUser[msg.sender] = true;
        }

        emit OpenBlindBox(msg.sender, price, tokenId);
        
        return tokenId;
    }

	function createNFTByOwner(address user) public onlyOwner returns (uint256){
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(user, tokenId);

        NFTIDs[counter] = tokenId;

        NFTIDToIndex[tokenId] = userNFTIDs[user].length;

        NFTIDToTypes[tokenId] = 5;

        userNFTIDs[user].push(tokenId);

        userNFTTypeNumber[user][5] ++;

        uint256 number =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender)))) % imageNumber[5] + 1;

        NFTIDToImageId[tokenId] = 5 * 10000 + 20 + number;

        emit GetNFT(user, tokenId, 5, NFTIDToImageId[tokenId]);

        return tokenId;
	} 

	function createNFT(address user, uint256 NFTType) public onlyController returns (uint256){
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(user, tokenId);

        NFTIDs[counter] = tokenId;

        NFTIDToIndex[tokenId] = userNFTIDs[user].length;

        NFTIDToTypes[tokenId] = NFTType;

        userNFTIDs[user].push(tokenId);

        userNFTTypeNumber[user][NFTType] ++;

        uint256 number =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender)))) % imageNumber[NFTType - 1] + 1;

        NFTIDToImageId[tokenId] = NFTType * 10000 + number;

        emit GetNFT(user, tokenId, NFTType, NFTIDToImageId[tokenId]);

        return tokenId;
	} 

	function _createNFT(address user, uint256 NFTType) private returns (uint256){
        counter ++;

        uint256 tokenId = _rand();

        _safeMint(user, tokenId);

        NFTIDs[counter] = tokenId;

        NFTIDToIndex[tokenId] = userNFTIDs[user].length;

        NFTIDToTypes[tokenId] = NFTType;

        userNFTIDs[user].push(tokenId);

        userNFTTypeNumber[user][NFTType] ++;

        uint256 number =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender)))) % imageNumber[NFTType - 1] + 1;

        NFTIDToImageId[tokenId] = NFTType * 10000 + number;

        emit GetNFT(user, tokenId, NFTType, NFTIDToImageId[tokenId]);

        return tokenId;
	} 

	function burn(uint256 tokenId) public virtual {
		require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: you are not the owner nor approved!");	
		super._burn(tokenId);
	}

    function approveToController(address ownerAddr, uint256 tokenId) public onlyController {
        address owner = ownerOf(tokenId);

        require(ownerAddr == owner, "ERC721: this user does not own this tokenId");

        _approve(controllerAddress, tokenId);
    }

    function _getNFTType(uint256 boxId) internal virtual returns (uint256) {  
        uint256 number =  (uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender)))) % 100 ;

        if(number >= boxRates[boxId - 1][3]){
            return 5;
        }
        if(number >= boxRates[boxId - 1][2]){
            return 4;
        }
        if(number >= boxRates[boxId - 1][1]){
            return 3;
        }
        if(number >= boxRates[boxId - 1][0]){
            return 2;
        }

        return 1;
    }

    function _rand() internal virtual returns(uint256) {
        
        uint256 number1 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum ++) * block.number, msg.sender))) % (4 * 10 ** 9) + 1968769868;

        uint256 number2 =  uint256(keccak256(abi.encodePacked(block.timestamp, (randNum + 2) * block.number, msg.sender))) % (2 * 10 ** 9) + 1936586796;
        
        return number1 + number2 + counter * 10 ** 10;
    }

    function getPresaleTime() public view returns(uint256[2] memory presaleTime) {
        presaleTime = [presaleStartTime, presaleEndTime];
        return presaleTime;
    }

    function getBoxPrices() public view returns(uint256[3] memory prices) {
        prices = boxsPrices;
        return prices;
    }

    function getBoxMaxTimes() public view returns(uint256[3] memory times) {
        times = boxMaxTimes;
        return times;
    }

    function getUserNFTIDs(address user) public view returns(uint256[] memory tokenIds) {
        tokenIds = userNFTIDs[user];
        return tokenIds;
    }

    function getBalance(address user) public view returns(uint256 balance) {

        uint256 decimals = ERC20(USDT).decimals();

        balance = (ERC20(USDT).balanceOf(user)).mul(100).div(10 ** decimals);

        return balance;
    }

    function getUserImageIdsByPageNumber(address user, uint256 pageNumber) public view returns(uint256[10] memory imageIds) {

        uint256 num = userNFTIDs[user].length;

        if(num > 0){

            uint256[] memory allImageIds = new uint256[](uint256(num));

            uint256 count;

            for(uint256 i = 0; i < num; i++){
                
                if(userNFTIDs[user][i] == 0){
                    count++;
                    continue;
                }else{
                    allImageIds[i - count] = NFTIDToImageId[userNFTIDs[user][i]];
                }
            }

            uint256 start = (pageNumber - 1) * 10;

            uint256 end = start + 10;

            for(uint256 j = start; j < end; j++){
                if(j < num && allImageIds[j] != 0){
                    uint256 k = j - start;
                    imageIds[k] = allImageIds[j];
                }
            }

            return imageIds;
        }

    }

    function checkUserRecommender(address user) public view returns(bool bind) {
        if(recommenders[user] != address(0)){
            return true;
        }
        return false;
    }

    function getUserImageIds(address user) public view returns(uint256[] memory imageIds) {

        uint256 num = userNFTIDs[user].length;

        imageIds = new uint256[](uint256(num));

        uint256 count;

        for(uint256 i = 0; i < num; i++){
                
            if(userNFTIDs[user][i] == 0){
                count++;
                continue;
            }else{
                imageIds[i - count] = NFTIDToImageId[userNFTIDs[user][i]];
            }
        }

        return imageIds;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {

        uint256 index = NFTIDToIndex[tokenId];

        userNFTIDs[from][index] = 0;

        userNFTIDs[to].push(tokenId);

        NFTIDToIndex[tokenId] = userNFTIDs[to].length;

        userNFTTypeNumber[from][NFTIDToTypes[tokenId]] -= 1;

        userNFTTypeNumber[to][NFTIDToTypes[tokenId]] += 1;
        
        return super._transfer(from, to, tokenId);
    }
   
}
// File: DreamHorseController.sol



pragma solidity ^0.8.0;




contract DreamHorseController is Ownable {
    
    using SafeMath for uint256;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event SelectBox(address indexed player, uint256 indexed boxid, uint256 indexed price, uint256  heroNum);
    
    event PaymentReceived(address from, uint256 amount);

    event InPool(address from,uint256 tokenId,uint256 types,uint256 BNBAmount,uint256 BUSDAmount);

    event OutPool(address from,uint256 poolid,uint256 BNBAmount,uint256 BUSDAmount,uint256 BNBReward,uint256 BUSDReward);
    
    event SelectMonster(uint256 monsterID,uint256 userHeroId,bool playResult,uint256 profit,uint256 thisPoint);

    event BuyHeroCards(address indexed seller, address indexed buyer, uint256 sellId, uint256 price);

    event NFTToHeros(address indexed user, uint256 count);

    event OpenBlindBox(address indexed user, uint256 cost, uint256 tokenId);
    
    ERC20 AMT;

    ERC20 BUSD;

    // ERC20 BUSD;

    DreamHorseNFT DHN;

    //用户
    // struct User{
        
    //     uint256 heroIds;//用户英雄数量
        
    //     uint256 poolIds;//用户质押池数量
    // }
    
    //英雄
    struct Hero{

        uint256 tokenId;//NFTTokenID

        uint256 id;//英雄等级

        uint256 imageId;//图片编号
        
        // uint256 myPoolId;//用户英雄质押池ID
        
        uint256 totalTimes;//英雄总对战次数
        
        uint256 usedTimes;//英雄已使用对战次数
        
        uint256 lastUsedTime;//英雄上次对战时间
        
        uint256 playTimes;//英雄对战总次数
        
        uint256 victoryTimes;//英雄对战胜利
        
        uint256 poolBNBReward;//英雄质押收益

        uint256 poolBUSDReward;//英雄质押收益
        
        uint256 monsterProfit;//英雄对战收益
        
        uint256 point;//英雄对战积分
        
        bool isPooled;//英雄是否质押

        bool isOnsell;//英雄是否在售
    }
    
    //怪兽
    struct Monster{
        
        uint256 id;//怪物等级
        
        uint256 number;//对战怪物胜率
        
        uint256 reward;//对战怪物收益
                 
        uint256 successPoint;//对战怪物积分基础值

        uint256 stepSuccessPoint;//对战怪物积分最大值与基础值的差值
        
        uint256 losePoint;//对战怪物失败时积分基础值
        
        uint256 stepLosePoint;//对战怪物失败时积分最大值与基础值的差值
    }
    
    //质押池
    struct Pool{

        uint256 tokenId;//用户英雄质押池ID
        
        uint256 id;//质押池类型

        uint256 BNBAmount;//质押数量

        uint256 BUSDAmount;//质押数量

        uint256 BNBReward;//收益

        uint256 BUSDReward;//收益

        uint256 circleTime;//质押周期

        uint256 joinTime;//质押开始时间

        uint256 rate;//月收益率
    }

    //NFT商城
    struct Sell{

        address onwerAddr;//英雄所有者地址

        uint256 tokenId;//用户英雄ID

        uint256 price;//出售价额

        bool sold;//是否售出
    }

    //NFT商城
    struct MonsterProfit{

        address onwerAddr;//英雄所有者地址

        uint256 tokenId;//用户英雄ID

        uint256 fightTime;//出售价额

        uint256 fightProfit;//出售价额

        bool isDraw;//出售价额
    }

    // mapping(address => User) public users;

    mapping(uint256 => Pool) public pools;//不同类型质押池
    
    mapping(uint256 => Hero) public heros;//不同等级英雄
    
    mapping(uint256 => Monster) public monsters;//不同等级怪物

    // mapping(address => uint256[]) public myHeroTokenIds;

    // mapping(uint256 => uint256) public tokenIdToIndex;

    mapping(uint256 => Hero) public tokenIdToHeros;
    
    mapping(uint256 => Pool) public tokenIdToPools;//用户质押池

    mapping(uint256 => Sell) public tokenIdToSells;//商城上架英雄

    // mapping(uint256 => MonsterProfit) public monsterProfits;//商城上架英雄

    mapping(uint256 => MonsterProfit[]) public tokenIdToMonsterProfits;//商城上架英雄

    // mapping(address => uint256[]) public mySellTokenIds;//用户上架英雄

    mapping(uint256 => uint256) public heroSource;//用户英雄来源:1 == 开卡, 2 == NFT商城购买,
    
    uint256 public totalSell;//商城总上架英雄数

    uint256 public totalSold;//商城总上架英雄数

    // mapping(uint256 => uint256) public sellIndexTotokenIds;//商城上架英雄

    mapping(uint256 => bool) private _isActivated;//NFT是否激活英雄

    bool[5] public poolClose = [false,false,false,false,false];//是否关闭

    // uint256[5][4] public poolRate;//质押月收益率

    mapping(address => mapping(uint256 => uint256)) public userPoolRewardTotal;//用户累计质押收益
    mapping(address => mapping(uint256 => uint256)) public userPoolRewardTime;//用户上次提取质押收益时间

    // uint256[3] public boxPrices = [99,199,299];//英雄盲盒价格

    uint256 public recoveryTime = 6 hours;//英雄对战次数恢复时间

    //后台统计数据
    uint256 public todayBurn = 0;
    uint256 public totalBurn = 0;
    uint256 public todayBox1Sales = 0;
    uint256 public totalBox1Sales = 0;
    uint256 public todayBox2Sales = 0;
    uint256 public totalBox2Sales = 0;
    uint256 public todayBox3Sales = 0;
    uint256 public totalBox3Sales = 0;
    uint256 public todayBoxSales = 0;
    uint256 public totalBoxSales = 0;
    uint256 public lastSaleTime = block.timestamp;
    uint256 public maxTokenForBattle = 18500000 * 10 **6;
    uint256 public maxTokenForFarming = 15000000 * 10 **6;
    uint256 public maxTokenForTraining = 115000000 * 10 **6;
    uint256 public tokenForBattle = 0;
    uint256 public totalPoolBNBReward = 0;
    uint256 public totalPoolBUSDReward = 0;
    uint256 public tokenForTraining = 0;
    uint256 private randNum = 0;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    constructor() {
        
        // BMV = ERC20(0x50D63F1509E783060F229281fdEE86Cc1FC17500);
        AMT = ERC20(0xD973d8D9Bc9A3d03c9558509B67942D7eB92cd93);

        // BUSD = ERC20(0x67a53859a586A0A8e1b05B1A87a2c574358B3c69);
        BUSD = ERC20(0xD973d8D9Bc9A3d03c9558509B67942D7eB92cd93);

        // DHN = WarcraftUniverseNFT(0xeeCC4D69640e9BA4E663FEfcC2a746B2465CD72E);
        DHN = DreamHorseNFT(0x8F67d9aedD798D5C297C6E164e5Da48D03121193);
        
        monsters[1] = Monster(1,72,126,15,6,1,1);
        monsters[2] = Monster(2,52,138,18,7,3,1);
        monsters[3] = Monster(3,43,168,23,8,5,2);
        monsters[4] = Monster(4,25,208,28,11,8,3);
        monsters[5] = Monster(5,11,258,35,13,12,5);
      
        heros[1] = Hero(0,1,0,2,0,0,0,0,0,0,0,0,false,false);
        heros[2] = Hero(0,2,0,3,0,0,0,0,0,0,0,0,false,false);
        heros[3] = Hero(0,3,0,4,0,0,0,0,0,0,0,0,false,false);
        heros[4] = Hero(0,4,0,5,0,0,0,0,0,0,0,0,false,false);
        heros[5] = Hero(0,5,0,6,0,0,0,0,0,0,0,0,false,false);
              
        pools[1] = Pool(0,1,0,0,0,0,0,0,15);
        pools[2] = Pool(0,2,0,0,0,0,7  days,0,25);
        pools[3] = Pool(0,3,0,0,0,0,14 days,0,35);
        pools[4] = Pool(0,4,0,0,0,0,30 days,0,40);
        pools[5] = Pool(0,1,0,0,0,0,90 days,0,50);

        // boxMaxTimes = [5000,3000,1000];
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }
    
    //管理员充币
    function ownerWithdrew(uint256 amount) public onlyOwner{
        
        amount = amount * 10 **6;
        
        uint256 dexBalance = AMT.balanceOf(address(this));
        
        require(amount > 0, "You need to send some token");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        AMT.transfer(msg.sender, amount);
    }
    
    //管理员提币
    function ownerDeposit(uint256 amount) public onlyOwner {
        
        amount = amount * 10 **6;

        uint256 dexBalance = AMT.balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some token");
        
        require(amount <= dexBalance, "Dont hava enough token");
        
        AMT.transferFrom(msg.sender, address(this), amount);
    }

    function setAMT(address AMTAddress) public onlyOwner {
        AMT = ERC20(AMTAddress);
    }

    function setBUSD(address BUSDAddress) public onlyOwner {
        BUSD = ERC20(BUSDAddress);
    }

    function setDHN(address DHNAddress) public onlyOwner {
        DHN = DreamHorseNFT(DHNAddress);      
    }

    function setMonsterReward(uint256 index, uint256 reward) public onlyOwner { 
        monsters[index].reward = reward;
    }

    function setMonsterRate(uint256 index, uint256 rate) public onlyOwner { 
        monsters[index].number = rate;
    }

    function setMaxTokenForBattle(uint256 num) public onlyOwner {      
        maxTokenForBattle = num;       
    }
    
    function setMaxTokenForFarming(uint256 num) public onlyOwner {      
        maxTokenForFarming = num;       
    }

    function setMaxTokenForTraining(uint256 num) public onlyOwner {      
        maxTokenForTraining = num;       
    }
    
    function setPoolClose(uint256 poolId, bool close) public onlyOwner {
        poolClose[poolId - 1] = close;
    }

    function setPoolCircleTime(uint256 poolId, uint256 circleTime) public onlyOwner {
        pools[poolId].circleTime = circleTime * 1 days;
    }

    function setPoolRate(uint256 poolId, uint256 rate) public onlyOwner {
        pools[poolId].rate = rate;
    }

    // function setBoxPrice(uint256 boxId, uint256 price) public onlyOwner {
    //     boxPrices[boxId - 1] = price;
    // }

    function setRecoveryTime(uint256 time) public onlyOwner {
        recoveryTime = 1 hours * time;
    }

    //上架英雄卡
    function sellHeroCard(uint256 tokenId, uint256 price) public {

        require(DHN.ownerOf(tokenId) == msg.sender, "You are not the owner");

        if(tokenIdToHeros[tokenId].tokenId == 0){
            _activateHero(tokenId);
        }

        Hero memory userHero = tokenIdToHeros[tokenId];
        
        require(userHero.id != 0 && !userHero.isPooled && !userHero.isOnsell && price > 0,"This user dont hava a hero ");
        
        if(tokenIdToSells[tokenId].tokenId == 0){

            totalSell++;

            // sellIndexTotokenIds[totalSell] = tokenId;

            tokenIdToSells[tokenId].tokenId = tokenId;
        }
        
        if(tokenIdToSells[tokenId].onwerAddr != msg.sender){
            tokenIdToSells[tokenId].onwerAddr = msg.sender;
        }

        tokenIdToSells[tokenId].price = price * 10 **6;

        if(tokenIdToSells[tokenId].sold != false){
            tokenIdToSells[tokenId].sold = false;
        }

        tokenIdToHeros[tokenId].isOnsell = true;
    }

    //取消上架英雄卡
    function cancelSellHeroCard(uint256 tokenId) public {

        require(DHN.ownerOf(tokenId) == msg.sender, "You are not the owner");

        Hero memory userHero = tokenIdToHeros[tokenId];
        
        require(userHero.id != 0 && !userHero.isPooled && userHero.isOnsell && tokenIdToSells[tokenId].price > 0,"This user dont hava a hero ");

        tokenIdToSells[tokenId].price = 0;

        tokenIdToHeros[tokenId].isOnsell = false;

        totalSell -= 1;
    }

    //NFT商城购买游戏卡
    function buyHeroCard(uint256 tokenId) public {

        address ownerAddress = tokenIdToSells[tokenId].onwerAddr;

        require(ownerAddress != msg.sender,"This buyer is owner");

        // if(tokenIdToHeros[tokenId].tokenId == 0){
        //     _activateHero(tokenId);
        // }

        Hero memory userHero = tokenIdToHeros[tokenId];

        require(userHero.id != 0 && !userHero.isPooled && userHero.isOnsell && tokenIdToSells[tokenId].price > 0,"This user dont hava a hero ");

        uint256 price = tokenIdToSells[tokenId].price;

        BUSD.transferFrom(msg.sender, ownerAddress, price);

        // users[msg.sender].heroIds += 1;

        // userHero.myHeroId = users[msg.sender].heroIds;

        userHero.isOnsell = false;

        DHN.approveToController(ownerAddress, tokenId);

        DHN.transferFrom(ownerAddress, msg.sender, tokenId);

        // delete userHeros[ownerAddress][sells[sellId].myHeroId];

        // delete userHeros[ownerAddress][sells[sellId].myHeroId];

        // delete sellIds[ownerAddress][sells[sellId].myHeroId];

        // delete heroSource[ownerAddress][sells[sellId].myHeroId];

        // tokenIdToSells[tokenId].onwerAddr = msg.sender;

        tokenIdToSells[tokenId].sold = true;

        heroSource[tokenId] = 2;

        totalSell -= 1;

        totalSold += 1;

        emit BuyHeroCards(ownerAddress, msg.sender, tokenId, price);
    }
    
    //入池
    function inPool(uint256 tokenId, uint256 poolType, uint256 BUSDAmount) public payable {

        require(DHN.ownerOf(tokenId) == msg.sender, "You are not the owner");

        if(tokenIdToHeros[tokenId].tokenId == 0){
            _activateHero(tokenId);
        }
        
        Hero memory userHero = tokenIdToHeros[tokenId];
        
        require(userHero.id != 0 && !userHero.isPooled && !userHero.isOnsell,"This user dont hava a hero ");

        require(!poolClose[poolType - 1],"This pool is close");

        // uint256 BNBAmount = msg.value;

        if(msg.value > 0){
            payable(address(this)).transfer(msg.value);
        }

        if(BUSDAmount > 0){
            uint256 BUSDDecimals = BUSD.decimals();
            BUSD.transferFrom(msg.sender,address(this),BUSDAmount * 10 ** BUSDDecimals / 100);
        }
        
        // users[msg.sender].poolIds = users[msg.sender].poolIds + 1;
        
        // userHeros[msg.sender][heroId].myPoolId = users[msg.sender].poolIds;

        if(poolType == 1){
            tokenIdToPools[tokenId] = Pool(
                                    tokenId,
                                    pools[poolType].id,
                                    msg.value.div(10 ** 16),
                                    BUSDAmount,
                                    0,
                                    0,
                                    pools[poolType].circleTime,
                                    block.timestamp,
                                    pools[poolType].rate
                                );
        }else{
            tokenIdToPools[tokenId] = Pool(
                                tokenId,
                                pools[poolType].id,
                                msg.value.div(10 ** 16),
                                BUSDAmount,
                                msg.value.mul(pools[poolType].rate).mul(pools[poolType].circleTime).div(30 * 10 ** 16),
                                BUSDAmount.mul(pools[poolType].rate).mul(pools[poolType].circleTime).div(30),
                                pools[poolType].circleTime,
                                block.timestamp,
                                pools[poolType].rate
                            );
        }

        tokenIdToHeros[tokenId].isPooled = true;
        
        emit InPool(msg.sender, tokenId, poolType, msg.value.div(10 ** 16), BUSDAmount);
    }
    
    //出池
    function outPool(uint256 tokenId) public {

        require(DHN.ownerOf(tokenId) == msg.sender, "You are not the owner");

        Pool memory myPool = tokenIdToPools[tokenId];
        
        require(myPool.BNBAmount > 0 || myPool.BUSDAmount > 0 ,"The hero has no pledge");

        Hero memory userHero = tokenIdToHeros[tokenId];
        
        require(userHero.id != 0 && userHero.isPooled && !userHero.isOnsell,"This user dont hava a hero ");

        if(myPool.id == 1){
            uint256 intervalDays = (block.timestamp - myPool.joinTime).div(24 hours);

            uint256 BNBReward = myPool.BNBAmount.mul(pools[1].rate).mul(intervalDays).div(30);

            uint256 BUSDReward = myPool.BUSDAmount.mul(pools[1].rate).mul(intervalDays).div(30);

            if(myPool.BNBAmount > 0){
                payable(msg.sender).transfer((myPool.BNBAmount + BNBReward) * 10 ** 16);
            }

            if(myPool.BUSDAmount > 0){
                uint256 BUSDDecimals = BUSD.decimals();
                BUSD.transfer(msg.sender, (myPool.BUSDAmount + BUSDReward) * 10 ** BUSDDecimals / 100);
            }

            totalPoolBNBReward += BUSDReward;

            totalPoolBUSDReward += BUSDReward;
        
            tokenIdToHeros[tokenId].poolBNBReward += BNBReward;

            tokenIdToHeros[tokenId].poolBUSDReward += BUSDReward;
                    
            tokenIdToHeros[tokenId].isPooled = false;

            tokenIdToHeros[tokenId] = userHero;
            
            emit OutPool(msg.sender, tokenId, myPool.BNBAmount, myPool.BUSDAmount, BUSDReward, BUSDReward);
            
            delete tokenIdToPools[tokenId];

        }else{

            uint256 time = myPool.joinTime + myPool.circleTime;

            require(time <= block.timestamp, "Time has not expired");

            uint256 BNBReward = myPool.BNBReward;

            uint256 BUSDReward = myPool.BUSDReward;

            // tokenForFarming += reward;

            // if(maxTokenForFarming - tokenForFarming < 0){
            //     reward = reward - (tokenForFarming - maxTokenForFarming);
            // }

            if(myPool.BNBAmount > 0){
                payable(msg.sender).transfer(myPool.BNBAmount + BNBReward);
            }

            if(myPool.BUSDAmount > 0){
                BUSD.transfer(msg.sender, myPool.BUSDAmount + BUSDReward);
            }

            totalPoolBNBReward += BUSDReward;

            totalPoolBUSDReward += BUSDReward;
        
            tokenIdToHeros[tokenId].poolBNBReward += BNBReward;

            tokenIdToHeros[tokenId].poolBUSDReward += BUSDReward;
                    
            tokenIdToHeros[tokenId].isPooled = false;

            tokenIdToHeros[tokenId] = userHero;
            
            emit OutPool(msg.sender, tokenId, myPool.BNBAmount, myPool.BUSDAmount, BUSDReward, BUSDReward);
            
            delete tokenIdToPools[tokenId];
        }
        
    }

    address USDT = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // address recipientAddress = 0xa139513555804702D3B5D8c00F1d121d27592b1B;

    // mapping(address => uint256) public recommendReward;

    // mapping(address => bool) public isUser;

    // mapping(address => address) public recommenders;

    // uint256[3] public boxMaxTimes;

    function setUSDTAddress(address usdtAddress) public onlyOwner {
        USDT = usdtAddress;   
    }

    function selectMonster(uint256 monsterID,uint256 tokenId) public {

        require(DHN.ownerOf(tokenId) == msg.sender, "You are not the owner");

        if(tokenIdToHeros[tokenId].tokenId == 0){
            _activateHero(tokenId);
        }
                
        require(maxTokenForBattle - tokenForBattle >= 0,"Exceed limit");
        
        Hero memory userHero = tokenIdToHeros[tokenId];

        require(userHero.id != 0 && !userHero.isPooled && !userHero.isOnsell,"This hero is unavailable");

        if(userHero.usedTimes > 0 && userHero.usedTimes == userHero.totalTimes && userHero.lastUsedTime + recoveryTime < block.timestamp){
            userHero.usedTimes = 0;
        }

        require(userHero.usedTimes < userHero.totalTimes, "The number of battles has been used up");
        
        userHero.usedTimes = userHero.usedTimes + 1;
        
        userHero.lastUsedTime = block.timestamp;

        Monster memory userSelectMonster = monsters[monsterID];
        
        uint256 point = 0;
        uint256 profit = 0;
        
        bool playResult = _betMonster(userSelectMonster.number);
        
        if(playResult){
            
            profit =  userSelectMonster.reward;
            
            profit =  profit * 10 ** 2;
            
            point =  userSelectMonster.successPoint + _getMonsteRadom(userSelectMonster.stepSuccessPoint + 1);
            
            userHero.victoryTimes = userHero.victoryTimes + 1;

        }else{
            point = userSelectMonster.losePoint + _getMonsteRadom(userSelectMonster.stepLosePoint);
        }
        
        tokenForBattle += profit;
        
        // if(maxTokenForFarming - tokenForFarming < 0){
        //     profit = profit - (tokenForFarming - maxTokenForFarming);
        // }
        
        userHero.playTimes = userHero.playTimes + 1;
        
        userHero.point = userHero.point + point;
        
        userHero.monsterProfit = userHero.monsterProfit + profit;
        
        tokenIdToHeros[tokenId] = userHero;

        MonsterProfit memory monsterProfit = MonsterProfit(msg.sender, tokenId, block.timestamp, profit, false);

        tokenIdToMonsterProfits[tokenId].push(monsterProfit); 
        
        // AMT.transfer(msg.sender, profit);
        
        emit SelectMonster(monsterID,tokenId,playResult,profit,point);  
    }

    function userDrawMonsterProfit(uint256 tokenId) public {

        require(DHN.ownerOf(tokenId) == msg.sender, "You are not the owner");

        if(tokenIdToHeros[tokenId].tokenId == 0){
            _activateHero(tokenId);
        }

        MonsterProfit[] memory profits = tokenIdToMonsterProfits[tokenId];

        uint256 profit;

        uint256 drawTime = block.timestamp;

        uint256 intervalDays;

        uint256 drawRatio = 50;

        if(profits.length > 0){
            for(uint256 i = 0; i < DHN.counter(); i++){
                if(profits[i].fightProfit > 0 && !profits[i].isDraw){

                    intervalDays = drawTime.div(24 hours) - profits[i].fightTime.div(24 hours);

                    drawRatio += 5 * intervalDays;

                    if(drawRatio > 100){
                        drawRatio = 100;
                    }

                    profit += profits[i].fightProfit.mul(drawRatio).div(100);

                    profits[i].isDraw = true;
                }
            }
        }

    }

    //给用户添加游戏卡
    function _activateHero(uint256 tokenId) internal virtual{
    
        uint256 heroLevel = DHN.NFTIDToTypes(tokenId);
        
        Hero memory newHero = heros[heroLevel];
                
        newHero.tokenId = tokenId;

        newHero.imageId = DHN.NFTIDToImageId(tokenId);
        
        tokenIdToHeros[tokenId] = newHero;

        heroSource[tokenId] = 1;
    }
    
    //对战怪物结果
    function _betMonster(uint256 monsterNumber ) internal virtual returns (bool) {
    
        uint256 number =  uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 100;

        if( number < monsterNumber ){
            return true;
        }
        
        return false;
    }
    
    //获取随机数
    function _getMonsteRadom( uint256 number) internal virtual returns (uint256) {
        uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % number;
        return num;
    }

    function getPoolCircleTime() public view returns(uint256[5] memory circleTimes) {

        for(uint256 i = 0; i < 5; i++){
            circleTimes[i] = pools[i + 1].circleTime;
        }
        
        return circleTimes;
    }

    function getSellTokenIds() public view returns(uint256[] memory tokenIds) {

        uint256 tokenId;

        uint256 counter;

        tokenIds = new uint256[](uint256(totalSell));

        for(uint256 i = 0; i < DHN.counter(); i++){
            tokenId = DHN.NFTIDs(i);
            if(tokenIdToHeros[tokenId].isOnsell){
                counter++;
                tokenIds[counter] = (tokenId);
            }
        }
        
        return tokenIds;
    }

    function getSells() public view returns(Sell[] memory sells) {

        uint256 tokenId;

        uint256 counter;

        sells = new Sell[](uint256(totalSell));

        for(uint256 i = 0; i < DHN.counter(); i++){
            tokenId = DHN.NFTIDs(i);
            if(tokenIdToHeros[tokenId].isOnsell){
                sells[counter] = tokenIdToSells[tokenId];
                counter++;
            }
        }
        
        return sells;
    }

    function getSoldTokenIds() public view returns(uint256[] memory tokenIds) {

        uint256 tokenId;

        uint256 counter;

        tokenIds = new uint256[](uint256(totalSold));

        for(uint256 i = 0; i < DHN.counter(); i++){
            tokenId = DHN.NFTIDs(i);
            if(tokenIdToSells[tokenId].sold){
                counter++;
                tokenIds[counter] = (tokenId);
            }
        }
        
        return tokenIds;
    }

    function getSolds() public view returns(Sell[] memory solds) {

        uint256 tokenId;

        uint256 counter;

        solds = new Sell[](uint256(totalSold));

        for(uint256 i = 0; i < DHN.counter(); i++){
            tokenId = DHN.NFTIDs(i);
            if(tokenIdToSells[tokenId].sold){
                solds[counter] = tokenIdToSells[tokenId];
                counter++;
            }
        }
        
        return solds;
    }

    function getUserPublishTokenIds(address user) public view returns(uint256[] memory tokenIds) {

        uint256[] memory userTokenIds = DHN.getUserNFTIDs(user);

        uint256 tokenId;

        uint256 counter;

        uint256[] memory tokenIds0 = new uint256[](uint256(userTokenIds.length));

        for(uint256 i = 0; i < userTokenIds.length; i++){
            tokenId = userTokenIds[i];
            if(tokenId != 0 && heroSource[tokenId] == 2){
                tokenIds0[counter] = tokenId;
                counter++;
            }
        }
        
        tokenIds = new uint256[](uint256(counter));

        for(uint256 i = 0; i < counter; i++){
            tokenIds[i] = tokenIds0[i];
        }
        
        return tokenIds;
    }

    function getUserPublishHeros(address user) public view returns(Hero[] memory publishHeros) {

        uint256[] memory userTokenIds = DHN.getUserNFTIDs(user);

        uint256 tokenId;

        uint256 counter;

        Hero[] memory userHeros = new Hero[](uint256(userTokenIds.length));

        for(uint256 i = 0; i < userTokenIds.length; i++){
            tokenId = userTokenIds[i];
            if(tokenId != 0 && heroSource[tokenId] == 2){
                userHeros[counter] = tokenIdToHeros[tokenId];
                counter++;
            }
        }
        
        publishHeros = new Hero[](uint256(counter));

        for(uint256 i = 0; i < counter; i++){
            publishHeros[i] = tokenIdToHeros[i];
        }
        
        return publishHeros;
    }

    function getUserBuyTokenIds(address user) public view returns(uint256[] memory tokenIds) {

        uint256[] memory userTokenIds = DHN.getUserNFTIDs(user);

        uint256 tokenId;

        uint256 counter;

        uint256[] memory tokenIds0 = new uint256[](uint256(userTokenIds.length));

        for(uint256 i = 0; i < userTokenIds.length; i++){
            tokenId = userTokenIds[i];
            if(tokenId != 0 && heroSource[tokenId] == 2){
                tokenIds0[counter] = tokenId;
                counter++;
            }
        }

        tokenIds = new uint256[](uint256(counter));

        for(uint256 i = 0; i < counter; i++){
            tokenIds[i] = tokenIds0[i];
        }
        
        return tokenIds;
    }

    function getUserHeros(address user) public view returns(Hero[] memory userHeros) {
        uint256[] memory userTokenIds = DHN.getUserNFTIDs(user);

        Hero[] memory myHeros = new Hero[](uint256(userTokenIds.length));

        uint256 tokenId;

        uint256 counter;

        for(uint256 i = 0; i < userTokenIds.length; i++){
            tokenId = userTokenIds[i];

            if(tokenId != 0){
                myHeros[counter] = getHero(tokenId);
                counter++;
            }
        }

        userHeros = new Hero[](uint256(counter));

        for(uint256 i = 0; i < counter; i++){
            userHeros[i] = myHeros[i];
        }

        return userHeros;
    }

    function getHero(uint256 tokenId) public view returns(Hero memory hero) {

        if(tokenIdToHeros[tokenId].tokenId == 0){

            hero = heros[DHN.NFTIDToTypes(tokenId)];

            hero.tokenId = tokenId;

            hero.imageId = DHN.NFTIDToImageId(tokenId);
        }else{
            hero = tokenIdToHeros[tokenId];
        }

        return hero;
    }

    // function getPledgeTokenIds(address user) public view returns(uint256[] memory tokenIds) {

    //     uint256[] memory userTokenIds = DHN.getUserNFTIDs(user);

    //     uint256 tokenId;

    //     uint256 counter;

    //     tokenIds = new uint256[](uint256(totalSell));

    //     for(uint256 i = 0; i < DHN.counter(); i++){
    //         tokenId = DHN.NFTIDs(i);
    //         if(tokenIdToHeros[tokenId].isPooled){
    //             counter++;
    //             tokenIds[counter] = (tokenId);
    //         }
    //     }
        
    //     return tokenIds;
    // }


    
}