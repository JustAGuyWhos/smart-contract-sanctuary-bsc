/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// Sources flattened with hardhat v2.4.3 https://hardhat.org
// SPDX-License-Identifier: MIT

// File @chainlink/contracts/src/v0.8/interfaces/[email protected]

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/token/ERC1155/[email protected]


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


// File @openzeppelin/contracts/token/ERC721/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


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


// File @openzeppelin/contracts/utils/math/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// File @openzeppelin/contracts/token/ERC721/[email protected]


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


// File @openzeppelin/contracts/token/ERC721/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File @openzeppelin/contracts/token/ERC1155/[email protected]


pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]


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


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]


pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]


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
        return msg.data;
    }
}


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File @openzeppelin/contracts/utils/structs/[email protected]


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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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


// File @openzeppelin/contracts/security/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File contracts/interfaces/IChainlinkPriceFeeds.sol

pragma solidity ^0.8.0;

interface IChainlinkPriceFeeds {

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) external view returns (uint256);
}


// File contracts/libraries/MediaEyeOrders.sol

pragma solidity ^0.8.0;

library MediaEyeOrders {
    enum NftTokenType {
        ERC1155,
        ERC721
    }

    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct SubscriptionSignature {
        bool isValid;
        UserSubscription userSubscription;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct UserSubscription {
        address userAddress;
        MediaEyeOrders.SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Listing {
        uint256 listingId;
        Nft[] nfts;
        address payable seller;
        uint256 timestamp;
        Split split;
    }

    struct Chainlink {
        address tokenAddress;
        uint256 tokenDecimals;
        address nativeAddress;
        uint256 nativeDecimals;
        IChainlinkPriceFeeds priceFeed;
        bool invertedAggregator;
    }

    struct AuctionConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
        address _mediaEyeCharities;
        Chainlink _chainlink;
    }

    struct OfferConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
    }

    struct AuctionAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        address _newCharityContract;
        MediaEyeOrders.Chainlink _chainlink;
        uint256 _basisPointFee;
        bool _check;
        address _newInfoContract;
    }

    struct OfferAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        uint256 _basisPointFee;
        address _newInfoContract;
    }

    struct AuctionInput {
        MediaEyeOrders.Nft[] nfts;
        MediaEyeOrders.AuctionPayment[] auctionPayments;
        MediaEyeOrders.PaymentChainlink chainlinkPayment;
        uint8 setRoyalty;
        uint256 royalty;
        MediaEyeOrders.Split split;
        AuctionTime auctionTime;
        MediaEyeOrders.SubscriptionSignature subscriptionSignature;
        MediaEyeOrders.Feature feature;
        string data;
    }

    struct AuctionTime {
        uint256 startTime;
        uint256 endTime;
    }

    struct Auction {
        uint256 auctionId;
        Nft[] nfts;
        address seller;
        uint256 startTime;
        uint256 endTime;
        Split split;
    }

    struct Royalty {
        address payable artist;
        uint256 royaltyBasisPoint;
    }

    struct Split {
        address payable recipient;
        uint256 splitBasisPoint;
        address payable charity;
        uint256 charityBasisPoint;
    }

    struct ListingPayment {
        address paymentMethod;
        uint256 price;
    }

    struct PaymentChainlink {
        bool isValid;
        address quoteAddress;
    }

    struct Feature {
        bool feature;
        address paymentMethod;
        uint256 numDays;
        uint256 id;
        address[] tokenAddresses;
        uint256[] tokenIds;
        uint256 price;
    }

    struct AuctionPayment {
        address paymentMethod;
        uint256 initialPrice;
        uint256 buyItNowPrice;
    }

    struct AuctionSignature {
        uint256 auctionId;
        uint256 price;
        address bidder;
        address paymentMethod;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct OfferSignature {
        Nft nft;
        uint256 price;
        address offerer;
        address paymentMethod;
        uint256 expiry;
        address charityAddress;
        uint256 charityBasisPoint;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Nft {
        NftTokenType nftTokenType;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 nftNumTokens;
    }
}


// File contracts/interfaces/ISubscriptionTier.sol

pragma solidity ^0.8.0;

interface ISubscriptionTier {
    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct UserSubscription {
        address userAddress;
        SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Featured {
        uint256 startTime;
        uint256 numDays;
        uint256 featureType;
        address contractAddress;
        uint256 listingId;
        uint256 auctionId;
        uint256 id;
        address featuredBy;
        uint256 price;
    }

    function getUserSubscription(address account)
        external
        view
        returns (UserSubscription memory);

    function checkUserSubscription(address _user)
        external
        view
        returns (uint256);

    function checkUserSubscriptionBySig(
        MediaEyeOrders.UserSubscription memory _userSubscription,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint256);

    function payFeatureFee(
        address _paymentMethod,
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        Featured memory _featured
    ) external payable;
}


// File contracts/interfaces/IMinter.sol

pragma solidity ^0.8.0;

interface IMinter {
    function getCreator(uint256 _tokenId)
        external
        view
        returns (address);
}


// File contracts/interfaces/IMarketplaceInfo.sol

pragma solidity ^0.8.0;

interface IMarketplaceInfo {
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool);

    function getRoyalty(address _nftTokenAddress, uint256 _nftTokenId)
        external
        view
        returns (MediaEyeOrders.Royalty memory);

    function getSoldStatus(address _nftTokenAddress, uint256 _nftTokenId)
        external
        view
        returns (bool);

    function setRoyalty(
        address _nftTokenAddress,
        uint256 _nftTokenId,
        uint256 _royalty,
        address _caller
    ) external;

    function setSoldStatus(address _nftTokenAddress, uint256 _nftTokenId)
        external;
}


// File contracts/MediaEyeMarketplaceListings.sol

pragma solidity ^0.8.0;
















contract MediaEyeMarketplaceListing is
    ERC721Holder,
    ERC1155Holder,
    AccessControl,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using SafeCast for int256;
    using Counters for Counters.Counter;
    using MediaEyeOrders for MediaEyeOrders.NftTokenType;
    using MediaEyeOrders for MediaEyeOrders.Listing;
    using MediaEyeOrders for MediaEyeOrders.Royalty;
    using MediaEyeOrders for MediaEyeOrders.Split;
    using MediaEyeOrders for MediaEyeOrders.ListingPayment;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using MediaEyeOrders for MediaEyeOrders.Nft;
    using MediaEyeOrders for MediaEyeOrders.PaymentChainlink;
    using MediaEyeOrders for MediaEyeOrders.Feature;

    Counters.Counter private _listingIds;

    struct Chainlink {
        address tokenAddress;
        uint256 tokenDecimals;
        address nativeAddress;
        uint256 nativeDecimals;
        AggregatorV3Interface priceFeed;
        bool invertedAggregator;
    }
    Chainlink internal chainlink;

    struct ListingInput {
        MediaEyeOrders.Nft[] nfts;
        MediaEyeOrders.ListingPayment[] listingPayments;
        MediaEyeOrders.PaymentChainlink chainlinkPayment;
        uint8 setRoyalty;
        uint256 royalty;
        MediaEyeOrders.Split split;
        MediaEyeOrders.SubscriptionSignature subscriptionSignature;
        MediaEyeOrders.Feature feature;
        string data;
    }

    // listingId => chainlinkQuoteAddress
    mapping(uint256 => MediaEyeOrders.PaymentChainlink)
        public saleChainlinkAddresses;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address payable public treasuryWallet;
    IMarketplaceInfo public mediaEyeMarketplaceInfo;
    address public mediaEyeCharities;
    address public feeContract;
    uint256 public basisPointFee;
    bool public subscriptionCheckActive;

    // listingId => paymentMethod = priceAmount
    mapping(uint256 => mapping(address => uint256)) public salePaymentAmounts;

    mapping(uint256 => MediaEyeOrders.Listing) public listings;
    EnumerableSet.UintSet private listingIds;

    event ListingCreated(
        MediaEyeOrders.Listing listing,
        MediaEyeOrders.ListingPayment[] listingPayments,
        MediaEyeOrders.PaymentChainlink chainlinkPayment,
        string data
    );
    event ListingFinished(uint256 listingId);
    event ListingCancelled(uint256 listingId);
    event ListingUpdated(
        uint256 listingId,
        MediaEyeOrders.ListingPayment[] listingPayments,
        MediaEyeOrders.PaymentChainlink chainlinkPayment
    );
    event Sale(
        uint256 listingId,
        address buyer,
        address seller,
        uint256 saleAmount,
        uint256 pricePer,
        uint256 totalPrice,
        address paymentMethod
    );

    /**
     * @dev Constructor
     *
     * Params:
     * _owner: address of the owner
     * _admins: addresses of initial admins
     * _treasuryWallet: address of treasury wallet
     * _basisPointFee: initial basis point fee
     * _feeContract: contract of MediaEyeFee
     * _mediaEyeMarketplaceInfo: address of info
     * _mediaEyeCharities: address of charities
     * _chainlink: chainlink info
     */
    constructor(
        address _owner,
        address[] memory _admins,
        address payable _treasuryWallet,
        uint256 _basisPointFee,
        address _feeContract,
        address _mediaEyeMarketplaceInfo,
        address _mediaEyeCharities,
        Chainlink memory _chainlink
    ) {
        require(_treasuryWallet != address(0));
        require(_basisPointFee <= 500, "Max fee");

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }

        treasuryWallet = _treasuryWallet;
        feeContract = _feeContract;

        basisPointFee = _basisPointFee;
        mediaEyeMarketplaceInfo = IMarketplaceInfo(_mediaEyeMarketplaceInfo);
        mediaEyeCharities = _mediaEyeCharities;

        chainlink = _chainlink;
        subscriptionCheckActive = true;
    }

    /********************** Price Feed ********************************/

    function getRoundData() public view returns (uint256) {
        (, int256 price, , , ) = chainlink.priceFeed.latestRoundData();

        return price.toUint256();
    }

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) public view returns (uint256) {
        require(_baseDecimals > 0 && _baseDecimals <= 18, "Invalid _decimals");
        require(
            _queryDecimals > 0 && _queryDecimals <= 18,
            "Invalid _decimals"
        );

        uint256 roundData = getRoundData();
        uint256 roundDataDecimals = chainlink.priceFeed.decimals();
        uint256 query = 0;

        if (_convertToNative) {
            if (_invertedAggregator) {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            } else {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            }
        } else {
            if (_invertedAggregator) {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            } else {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            }
        }

        if (_baseDecimals > _queryDecimals) {
            uint256 decimals = _baseDecimals - _queryDecimals;
            query = query / (10**decimals);
        } else if (_baseDecimals < _queryDecimals) {
            uint256 decimals = _queryDecimals - _baseDecimals;
            query = query * (10**decimals);
        }
        return query;
    }

    /********************** Owner Functions ********************************/

    /**
     * @dev Update constants/contracts. enter 0 address if you dont want to change a param
     *
     * Params:
     * _newTreasuryWallet: new treasury wallet
     * _newCharityContract: new MediaEyeCharity contract
     */
    function updateConstantsByOwner(
        address payable _newTreasuryWallet,
        address _newCharityContract
    ) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "owner");
        if (_newTreasuryWallet != address(0)) {
            treasuryWallet = _newTreasuryWallet;
        }
        if (_newCharityContract != address(0)) {
            mediaEyeCharities = _newCharityContract;
        }
    }

    /********************** Admin Functions ********************************/

    /**
     * @dev Update price feed aggregator address
     *
     */
    function setChainlink(Chainlink memory _chainlink) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        chainlink = _chainlink;
    }

    /**
     * @dev Update fee contract address
     *
     */
    function setFeeContract(address _feeContract) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        feeContract = _feeContract;
    }

    /**
     * @dev updates the basis point fee
     *
     * Params:
     * _basisPointFee: basis point fee, fee must be less than 500 (5%)
     */
    function updateBasisPointFee(uint256 _basisPointFee) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        require(_basisPointFee <= 500, "Max fee");
        basisPointFee = _basisPointFee;
    }

    function updateSubscriptionCheck(bool _check) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        subscriptionCheckActive = _check;
    }

    /**
     * @dev updates the marketplace info
     *
     * Params:
     * _newInfoContract: new info contract
     */
    function updateMarketplaceInfo(address _newInfoContract) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        if (_newInfoContract != address(0)) {
            mediaEyeMarketplaceInfo = IMarketplaceInfo(_newInfoContract);
        }
    }

    /********************** Get Functions ********************************/

    // Get number of listings
    function getNumListings() external view returns (uint256) {
        return listingIds.length();
    }

    /**
     * @dev Get listing ID at index
     *
     * Params:
     * index: index of ID
     */
    function getListingIds(uint256 index) external view returns (uint256) {
        return listingIds.at(index);
    }

    /**
     * @dev Get listing correlated to index
     *
     * Params:
     * index: index of ID
     */
    function getListingAtIndex(uint256 index)
        external
        view
        returns (MediaEyeOrders.Listing memory)
    {
        return listings[listingIds.at(index)];
    }

    /********************MARKETPLACE***********************/

    /**
     * @dev Create a new listing
     *
     * Params:
     * _listingInput.nfts: nfts to list
     * _listingInput.listingPayments: price accepted for accepted payment methods
     * _listingInput.chainlinkPayment: addresses for base and quote currencies (optional)
     * _listingInput.setRoyalty: if we set royalty (creator only)
     * _listingInput.royalty: royalty amount to either set or confirm
     * _listingInput.split: how to split revenue if any
     * _listingInput.subscriptionSignature: signature of subscription (optional)
     * _listingInput.feature: if we feature the listing (optional)
     */
    function createListing(ListingInput memory _listingInput)
        external
        payable
        nonReentrant
    {
        require(
            _listingInput.listingPayments.length > 0 &&
                _listingInput.nfts.length > 0,
            "length"
        );

        require(
            _listingInput.split.splitBasisPoint +
                _listingInput.split.charityBasisPoint <=
                10000,
            "total payout over 100%"
        );

        if (_listingInput.nfts.length > 1 && subscriptionCheckActive) {
            uint256 tier = 0;
            if (_listingInput.subscriptionSignature.isValid) {
                require(
                    msg.sender ==
                        _listingInput
                            .subscriptionSignature
                            .userSubscription
                            .userAddress,
                    "subscription info must be of sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _listingInput.subscriptionSignature.userSubscription,
                        _listingInput.subscriptionSignature.v,
                        _listingInput.subscriptionSignature.r,
                        _listingInput.subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    msg.sender
                );
            }
            require(tier > 0, "subscription");
        }

        uint256 listingId = _listingIds.current();

        // save payment methods
        for (uint256 i = 0; i < _listingInput.listingPayments.length; i++) {
            require(
                mediaEyeMarketplaceInfo.isPaymentMethod(
                    _listingInput.listingPayments[i].paymentMethod
                ),
                "payment"
            );
            require(
                _listingInput.listingPayments[i].price > 0 ||
                    _listingInput.listingPayments[i].paymentMethod ==
                    _listingInput.chainlinkPayment.quoteAddress,
                "invalid price"
            );
            salePaymentAmounts[listingId][
                _listingInput.listingPayments[i].paymentMethod
            ] = _listingInput.listingPayments[i].price;
        }

        // save chainlink payment
        if (_listingInput.chainlinkPayment.isValid) {
            // check if the opposite address is a payment method
            if (
                _listingInput.chainlinkPayment.quoteAddress ==
                chainlink.nativeAddress
            ) {
                require(
                    salePaymentAmounts[listingId][chainlink.tokenAddress] > 0,
                    "chainlink payment"
                );
            } else {
                require(
                    _listingInput.chainlinkPayment.quoteAddress ==
                        chainlink.tokenAddress,
                    "impossible chainlink payment"
                );
                require(
                    salePaymentAmounts[listingId][chainlink.nativeAddress] > 0,
                    "chainlink payment"
                );
            }
            saleChainlinkAddresses[listingId] = _listingInput.chainlinkPayment;
        }

        address compareRoyaltyRecipient;

        if (_listingInput.setRoyalty == 0) {
            compareRoyaltyRecipient = mediaEyeMarketplaceInfo
                .getRoyalty(
                    _listingInput.nfts[0].nftTokenAddress,
                    _listingInput.nfts[0].nftTokenId
                )
                .artist;
        }

        MediaEyeOrders.Listing storage listing = listings[listingId];

        for (uint256 i = 0; i < _listingInput.nfts.length; i++) {
            if (_listingInput.setRoyalty != 0) {
                mediaEyeMarketplaceInfo.setRoyalty(
                    _listingInput.nfts[i].nftTokenAddress,
                    _listingInput.nfts[i].nftTokenId,
                    _listingInput.royalty,
                    msg.sender
                );
            } else {
                // check if royalty payments and royalty creators are the same for all in bundle
                require(
                    _listingInput.royalty ==
                        mediaEyeMarketplaceInfo
                            .getRoyalty(
                                _listingInput.nfts[i].nftTokenAddress,
                                _listingInput.nfts[i].nftTokenId
                            )
                            .royaltyBasisPoint &&
                        compareRoyaltyRecipient ==
                        mediaEyeMarketplaceInfo
                            .getRoyalty(
                                _listingInput.nfts[i].nftTokenAddress,
                                _listingInput.nfts[i].nftTokenId
                            )
                            .artist,
                    "royalties unmatched"
                );
            }

            if (
                _listingInput.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                require(
                    _listingInput.nfts[i].nftNumTokens == 1,
                    "ERC721 Amount"
                );
                IERC721(_listingInput.nfts[i].nftTokenAddress).safeTransferFrom(
                        msg.sender,
                        address(this),
                        _listingInput.nfts[i].nftTokenId
                    );
            } else if (
                _listingInput.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC1155
            ) {
                IERC1155(_listingInput.nfts[i].nftTokenAddress)
                    .safeTransferFrom(
                        msg.sender,
                        address(this),
                        _listingInput.nfts[i].nftTokenId,
                        _listingInput.nfts[i].nftNumTokens,
                        ""
                    );
            }
            listing.nfts.push(_listingInput.nfts[i]);
        }

        listing.listingId = listingId;
        listing.seller = payable(msg.sender);
        listing.timestamp = block.timestamp;
        listing.split = _listingInput.split;

        if (_listingInput.feature.feature) {
            if (_listingInput.feature.paymentMethod != address(0)) {
                IERC20(_listingInput.feature.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _listingInput.feature.price
                );
            }
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _listingInput.feature.paymentMethod,
                _listingInput.feature.tokenAddresses,
                _listingInput.feature.tokenIds,
                ISubscriptionTier.Featured(
                    0,
                    _listingInput.feature.numDays,
                    4,
                    address(0),
                    listingId,
                    0,
                    _listingInput.feature.id,
                    msg.sender,
                    _listingInput.feature.price
                )
            );
        }

        listingIds.add(listingId);
        _listingIds.increment();

        emit ListingCreated(
            listings[listingId],
            _listingInput.listingPayments,
            _listingInput.chainlinkPayment,
            _listingInput.data
        );
    }

    /**
     * @dev Remove a listing
     *
     * Params:
     * _listingId: listing ID
     */
    function cancelListing(uint256 _listingId) external nonReentrant {
        require(listingIds.contains(_listingId), "nonexistent listing.");
        MediaEyeOrders.Listing memory listing = listings[_listingId];
        require(msg.sender == listing.seller, "owner listing");

        for (uint256 i = 0; i < listing.nfts.length; i++) {
            if (
                listing.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    listing.seller,
                    listing.nfts[i].nftTokenId
                );
            } else if (
                listing.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC1155
            ) {
                IERC1155(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    listing.seller,
                    listing.nfts[i].nftTokenId,
                    listing.nfts[i].nftNumTokens,
                    ""
                );
            }
        }
        listingIds.remove(_listingId);

        emit ListingCancelled(_listingId);
    }

    /**
     * @dev Update a listing prce
     *
     * Params:
     * _listingId: listing ID
     */
    function updateListing(
        uint256 _listingId,
        MediaEyeOrders.ListingPayment[] memory _listingPayments,
        MediaEyeOrders.PaymentChainlink memory _chainlinkPayment
    ) external nonReentrant {
        require(listingIds.contains(_listingId), "nonexistent listing.");
        MediaEyeOrders.Listing memory listing = listings[_listingId];
        require(msg.sender == listing.seller, "owner listing");

        // save payment methods, set price to 0 to remove payment method
        for (uint256 i = 0; i < _listingPayments.length; i++) {
            require(
                mediaEyeMarketplaceInfo.isPaymentMethod(
                    _listingPayments[i].paymentMethod
                ),
                "payment"
            );
            salePaymentAmounts[_listingId][
                _listingPayments[i].paymentMethod
            ] = _listingPayments[i].price;
        }

        // save chainlink payment
        if (_chainlinkPayment.isValid) {
            // if valid
            // check if the opposite address is a payment method
            if (_chainlinkPayment.quoteAddress == chainlink.nativeAddress) {
                require(
                    salePaymentAmounts[_listingId][chainlink.tokenAddress] > 0,
                    "chainlink payment"
                );
            } else {
                require(
                    _chainlinkPayment.quoteAddress == chainlink.tokenAddress,
                    "impossible chainlink payment"
                );
                require(
                    salePaymentAmounts[_listingId][chainlink.nativeAddress] > 0,
                    "chainlink payment"
                );
            }
        }
        // set chainlink payment
        saleChainlinkAddresses[_listingId] = _chainlinkPayment;

        emit ListingUpdated(_listingId, _listingPayments, _chainlinkPayment);
    }

    /**
     * @dev Buy a token
     *
     * Params:
     * _listingId: listing ID
     * _amount: amount tokens to buy (amount = 1 for any bundles)
     * _paymentMethod: method of payment and total price
     */
    function buyTokens(
        uint256 _listingId,
        uint256 _amount,
        MediaEyeOrders.ListingPayment memory _paymentMethod
    ) external payable nonReentrant {
        require(listingIds.contains(_listingId), "nonexistent listing");
        require(_amount > 0, "amount");
        if (_paymentMethod.paymentMethod == address(0)) {
            require(msg.value == _paymentMethod.price, "native msgvalue");
        } else {
            require(msg.value == 0, "msgvalue");
        }

        uint256 price = 0;
        uint256 convertedPrice = 0;

        // check if chainlink
        if (
            saleChainlinkAddresses[_listingId].isValid &&
            _paymentMethod.paymentMethod ==
            saleChainlinkAddresses[_listingId].quoteAddress
        ) {
            // calculate price
            if (_paymentMethod.paymentMethod == address(0)) {
                price = salePaymentAmounts[_listingId][chainlink.tokenAddress];
                require(price > 0, "chainlink payment");
                convertedPrice = convertPrice(
                    price * _amount,
                    chainlink.tokenDecimals,
                    chainlink.nativeDecimals,
                    chainlink.invertedAggregator,
                    true
                );
                // check tolerance
                require(
                    msg.value >= convertedPrice,
                    "native payment not enough"
                );
                if (msg.value > convertedPrice) {
                    (bool diffSent, ) = msg.sender.call{
                        value: msg.value - convertedPrice
                    }("");
                    require(diffSent, "return transfer fail.");
                }
            } else {
                require(
                    _paymentMethod.paymentMethod == chainlink.tokenAddress,
                    "impossible chainlink payment"
                );
                price = salePaymentAmounts[_listingId][chainlink.nativeAddress];
                require(price > 0, "chainlink payment");
                convertedPrice = convertPrice(
                    price * _amount,
                    chainlink.nativeDecimals,
                    chainlink.tokenDecimals,
                    chainlink.invertedAggregator,
                    false
                );
                // check tolerance
                require(
                    _paymentMethod.price >= convertedPrice,
                    "chainlink payment not enough"
                );
            }
        } else {
            price = salePaymentAmounts[_listingId][
                _paymentMethod.paymentMethod
            ];
            require(
                price > 0 && _paymentMethod.price == price * _amount,
                "payment"
            );
            convertedPrice = _paymentMethod.price;
        }

        MediaEyeOrders.Listing storage listing = listings[_listingId];

        // if not a bundle, can buy any amount
        if (listing.nfts.length == 1) {
            require(listing.nfts[0].nftNumTokens >= _amount, "soldout");
        } else if (listing.nfts.length > 1) {
            require(_amount == 1, "bundles amount");
        }

        _sendPayments(
            listing.nfts[0].nftTokenAddress,
            listing.nfts[0].nftTokenId,
            listing.seller,
            _paymentMethod.paymentMethod,
            convertedPrice,
            listing.split,
            msg.sender
        );

        if (listing.nfts.length == 1) {
            listing.nfts[0].nftNumTokens -= _amount;
            if (
                listing.nfts[0].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(listing.nfts[0].nftTokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    listing.nfts[0].nftTokenId,
                    ""
                );
            } else {
                IERC1155(listing.nfts[0].nftTokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    listing.nfts[0].nftTokenId,
                    _amount,
                    ""
                );
            }
            if (listing.nfts[0].nftNumTokens == 0) {
                listingIds.remove(_listingId);
                emit ListingFinished(_listingId);
            }
            if (
                !mediaEyeMarketplaceInfo.getSoldStatus(
                    listing.nfts[0].nftTokenAddress,
                    listing.nfts[0].nftTokenId
                )
            ) {
                mediaEyeMarketplaceInfo.setSoldStatus(
                    listing.nfts[0].nftTokenAddress,
                    listing.nfts[0].nftTokenId
                );
            }
        } else if (listing.nfts.length > 1) {
            for (uint256 i = 0; i < listing.nfts.length; i++) {
                if (
                    listing.nfts[i].nftTokenType ==
                    MediaEyeOrders.NftTokenType.ERC721
                ) {
                    IERC721(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                        address(this),
                        msg.sender,
                        listing.nfts[i].nftTokenId,
                        ""
                    );
                } else {
                    IERC1155(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                        address(this),
                        msg.sender,
                        listing.nfts[i].nftTokenId,
                        listing.nfts[i].nftNumTokens,
                        ""
                    );
                }
                if (
                    !mediaEyeMarketplaceInfo.getSoldStatus(
                        listing.nfts[i].nftTokenAddress,
                        listing.nfts[i].nftTokenId
                    )
                ) {
                    mediaEyeMarketplaceInfo.setSoldStatus(
                        listing.nfts[i].nftTokenAddress,
                        listing.nfts[i].nftTokenId
                    );
                }
            }
            listingIds.remove(_listingId);
            emit ListingFinished(_listingId);
        }

        emit Sale(
            _listingId,
            msg.sender,
            listing.seller,
            _amount,
            convertedPrice / _amount,
            convertedPrice,
            _paymentMethod.paymentMethod
        );
    }

    function _sendPayments(
        address _tokenAddress,
        uint256 _tokenId,
        address payable _sellerAddress,
        address paymentMethod,
        uint256 price,
        MediaEyeOrders.Split memory _split,
        address _payer
    ) internal {
        // royalties are the same for each in the bundle
        MediaEyeOrders.Royalty memory royalty = mediaEyeMarketplaceInfo
            .getRoyalty(_tokenAddress, _tokenId);
        uint256 payoutToTreasury = (price * basisPointFee) / 10000;
        uint256 payoutToCreator = 0;
        uint256 payoutToCharity = 0;
        uint256 payoutToSecondarySeller = 0;
        if (royalty.royaltyBasisPoint > 0) {
            payoutToCreator = (price * royalty.royaltyBasisPoint) / 10000;
        }

        // payout to Charity/sellers
        uint256 remainingPayout = (price *
            (10000 - basisPointFee - royalty.royaltyBasisPoint)) / 10000;
        if (_split.charityBasisPoint > 0 && _split.charity != address(0)) {
            payoutToCharity =
                (remainingPayout * _split.charityBasisPoint) /
                10000;
        }
        if (_split.splitBasisPoint > 0 && _split.recipient != address(0)) {
            payoutToSecondarySeller =
                (remainingPayout * _split.splitBasisPoint) /
                10000;
        }

        uint256 payoutToSeller = (remainingPayout *
            (10000 - _split.charityBasisPoint - _split.splitBasisPoint)) /
            10000;

        if (paymentMethod == address(0)) {
            (bool treasurySent, ) = treasuryWallet.call{
                value: payoutToTreasury
            }("");
            require(treasurySent, "treasury.");
            if (payoutToCreator > 0) {
                (bool royaltySent, ) = royalty.artist.call{
                    value: payoutToCreator
                }("");
                require(royaltySent, "royalty");
            }
            if (payoutToCharity > 0) {
                (bool charitySent, ) = _split.charity.call{
                    value: payoutToCharity
                }("");
                require(charitySent, "charity");
            }
            if (payoutToSecondarySeller > 0) {
                (bool secondarySellerSent, ) = _split.recipient.call{
                    value: payoutToSecondarySeller
                }("");
                require(secondarySellerSent, "seller2");
            }
            if (payoutToSeller > 0) {
                (bool sellerSent, ) = _sellerAddress.call{
                    value: payoutToSeller
                }("");
                require(sellerSent, "seller");
            }
        } else {
            IERC20(paymentMethod).transferFrom(
                _payer,
                treasuryWallet,
                payoutToTreasury
            );
            if (payoutToCreator > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    royalty.artist,
                    payoutToCreator
                );
            }
            if (payoutToCharity > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _split.charity,
                    payoutToCharity
                );
            }
            if (payoutToSecondarySeller > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _split.recipient,
                    payoutToSecondarySeller
                );
            }
            if (payoutToSeller > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _sellerAddress,
                    payoutToSeller
                );
            }
        }
    }

    // override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}