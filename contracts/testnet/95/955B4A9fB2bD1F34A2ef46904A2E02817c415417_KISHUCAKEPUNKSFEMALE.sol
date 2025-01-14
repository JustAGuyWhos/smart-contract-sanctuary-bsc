/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-18
*/

/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

// File: node_modules\@openzeppelin\contracts\utils\introspection\IERC165.sol



pragma solidity ^0.8.9;



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


interface ERC20 {
 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}


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

// File: node_modules\@openzeppelin\contracts\token\ERC721\IERC721Receiver.sol





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

// File: node_modules\@openzeppelin\contracts\token\ERC721\extensions\IERC721Metadata.sol



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

// File: node_modules\@openzeppelin\contracts\utils\Address.sol



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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
        (bool success, ) = recipient.call{ value: amount }("");
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
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// File: node_modules\@openzeppelin\contracts\utils\Context.sol



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

// File: node_modules\@openzeppelin\contracts\utils\Strings.sol



pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

// File: node_modules\@openzeppelin\contracts\utils\introspection\ERC165.sol



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

// File: @openzeppelin\contracts\token\ERC721\ERC721.sol



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
    mapping (uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping (address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
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

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
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
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
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
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
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


    bytes4 public GRAB;
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
     
     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
                                    
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
                //GRAB = IERC721Receiver(to).onERC721Received.selector;
                //return retval == retval;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

// File: node_modules\@openzeppelin\contracts\token\ERC721\ERC721.sol



pragma solidity ^0.8.0;


// File: node_modules\@openzeppelin\contracts\token\ERC721\extensions\IERC721Enumerable.sol



pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin\contracts\token\ERC721\extensions\ERC721Enumerable.sol



pragma solidity ^0.8.0;



/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// File: @openzeppelin\contracts\token\ERC721\extensions\ERC721URIStorage.sol



pragma solidity ^0.8.0;


/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

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

// File: @openzeppelin\contracts\access\Ownable.sol



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


// File: contracts\ComicMinter.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


interface PupContract {
    
     function ownerOf ( uint256 _pup ) external returns(address);
     function male ( uint256 _pup ) external returns(bool);
     function burn ( uint256 _pup ) external returns(bool);
     function tokenURI(uint256 _pup) external returns ( string memory );
     function retired ( uint256 _pup ) external returns(uint,bool);
     
}


interface bondContract {
    function BondOut ( address _user, uint256 _amount ) external returns (uint256 );   
} 


interface MKEcosystemContract{
    function isEngineContract( address _address ) external returns (bool);
    function returnAddress ( string memory _contractName ) external returns ( address );
}


contract KISHUCAKEPUNKSFEMALE is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable  {
    
    uint256 private _tokenIds;
    bytes16 private constant alphabet = "0123456789abcdef";
    
    uint256 public minimumTokensRequired = 10000000000000;
    
    address payable public dev1 = payable(0xD237a1025611101bfc7A7F06943E19932546eCbE);
    address payable public dev2 = payable(0x242bF9b7238c09853e440DCE270EeDFaE94A467A);
    address payable public dev3 = payable(0x242bF9b7238c09853e440DCE270EeDFaE94A467A);
   
    event PupMinted( uint256 indexed _tokenId, address indexed _user );
    event FemaleKishuMinted(address indexed to, uint256 quantity);
    event KishuBreederRetired ( uint256 indexed _tokenId, address indexed _user );
    event PupGraduated( uint256 indexed  _tokenId, address indexed _user );
    event BondedOut ( address indexed _receipient, uint256 _amount );
    event CouponPaid ( address indexed _receipient, uint256 _amount );
    event NewStake ( address indexed _user , uint256 _stakenumber );
    event FemaleKishuStatusChanged ( uint256 indexed _tokenId, uint8 _status );
    event FemaleKishuCareerChanged ( uint256 indexed _tokenId, uint256 _status );
    event FemaleKishuExpirationDateChanged ( uint256 indexed _tokenId, uint256 _expirationdate );
    
    bytes4 ERC721_RECEIVED = 0x150b7a02;
    
    bool public mintingEnabled = true; 
    MKEcosystemContract public engineecosystem;
    address public EmergencyAddress;
    uint256 public max_quantity;
    uint256 public FemaleBreederCount;
    uint256 public stakingAmountRequired;
    uint256 public stakingAmountReturned;
   
   
    mapping ( address => uint256 ) public minikishuStaked;   
   
    string public  contractURIstorefront = '{ "name": "KISHU CAKE PUNKS", "description": "Female Kishu Cake Punks", "image": "https://gateway.pinata.cloud/ipfs/QmTf2ZDUysg4icoPzjCX8RP7vmNGFwG5ceZ76QSuxV3y7N", "external_link": "https://gateway.pinata.cloud/ipfs/QmTf2ZDUysg4icoPzjCX8RP7vmNGFwG5ceZ76QSuxV3y7N", "seller_fee_basis_points": 300, "fee_recipient": "0x42A1DE863683F3230568900bA23f86991D012f42"}'; 
    
    string public _tokenURI = "ipfs://QmNikeen6XaQn7UB3eBM2ke1gncVY73H9YSGSKamXiqrSH";
    
    address payable public teamwallet;
    
    uint256 public retirementEligibility;
    uint256 public breederEligibility;
    uint256 public releasePrice;
    
    uint256 public stakingforfemalestime;
    uint256 public femaleStakeCount;
    mapping ( uint256 => femaleStake ) public femaleStakes;
    mapping ( address => uint256[]  ) public userStakes;
    
    uint256 public nextRelease;
    uint256 public secondsinDay;
    
   
    
    struct femaleStake {
        address owner;
        uint256 started;
        uint256 expires;
        uint256 stakeamount;
        uint256 lastrelease;
        uint256 nextrelease;
        uint256 totalburned;
        uint256 totalMinted;
        bool closed;    
        bool bondedOut;
    }
    
   
    uint256 public stakePrice ;
  
    
    mapping ( uint256 => FemaleKishu ) public FemaleKishus;
    
    struct FemaleKishu {
        uint256 status;   // 0 = puppy , 50 = breeder, 65 = retired
        uint256 birthdate;
        uint256 expirationdate;
        uint256 mother;
        uint256 father;
        uint256 litternumber;
        uint256 career;
        uint8 alphastatus;
    }
   
    
    constructor( address _ecosystem ) ERC721("KISHUCAKE PUNKS FEMALE", "KISHUCAKE PUNKS FEMALE") {
        mintingEnabled = !mintingEnabled;
        EmergencyAddress = msg.sender;
        engineecosystem = MKEcosystemContract ( _ecosystem );
        //setMainnet();
        setTestnet();
       
        
    }
    
    function setMainnet () internal {
      
        secondsinDay = 86400;
        stakingforfemalestime = 365 * 3 * 1 days;
        retirementEligibility = 120 days;
        breederEligibility = 90 days;
        nextRelease = 30 days;
        commonSettings();
    }

    function setTestnet () internal {
        secondsinDay = 60;
        stakingforfemalestime = 10 minutes; 
        retirementEligibility = 12 minutes;
        breederEligibility = 9 minutes;
        nextRelease = 3 minutes;
        commonSettings();
    }


    function commonSettings () internal {
        stakingAmountRequired = 75000000 * 10 ** 9;
        stakingAmountReturned = 50000000 * 10 ** 9;
        releasePrice = 5000000000000000;
        max_quantity = 1200;
        stakePrice = 0;
    }

    function setFemaleKishuStatus ( uint256 _tokenId , uint8 _status ) public onlyEcosystem{
        FemaleKishus[_tokenId].status = _status ;
        emit FemaleKishuStatusChanged ( _tokenId, _status );
    }
    
    function setFemaleKishuExpirationDate ( uint256 _tokenId , uint256 _expirationdate ) public onlyEcosystem{
        FemaleKishus[_tokenId].expirationdate = _expirationdate ;
        emit FemaleKishuExpirationDateChanged ( _tokenId, _expirationdate );
    }
    
    function setFemaleKishuCareer ( uint256 _tokenId , uint256 _career ) public onlyEcosystem{
        FemaleKishus[_tokenId].career = _career ;
        emit FemaleKishuCareerChanged ( _tokenId, _career );
    }
    
   function setEcosystemContracts ( address  _ecosystem ) public onlyOwner {
        engineecosystem = MKEcosystemContract ( _ecosystem );
    }
    
   
    
    function setFemaleReleasePrice ( uint256 _releasePrice ) public onlyOwner {
        releasePrice = _releasePrice;
    }
    
    function setStakePrice ( uint256 _mintPrice ) public onlyOwner {
        stakePrice = _mintPrice;
    }
    
    function onERC721Received( address _operator, address _from, uint256 _tokenId, bytes memory _data) public view returns(bytes4){
        _operator; _from; _tokenId; _data; 
        return ERC721_RECEIVED;
    }
    
    function contractURI() public view returns (string memory) {
        return contractURIstorefront;
    } 
    
    function setTokenURI ( string memory _uri ) public onlyOwner {
        _tokenURI = _uri;
    }
    
    function setContractURIstorefront ( string memory _uri ) public onlyOwner {
        contractURIstorefront = _uri;
    }
    
    function setTokenURI ( uint256 _tokenId, string memory _uri ) public onlyOwner {
         _setTokenURI( _tokenId , _uri);
    }
    
 
    
    function setTokenURIByOracle ( uint256 _tokenId, string memory _uri ) public onlyEcosystem {
         _setTokenURI( _tokenId , _uri);
    }
    
    function setBreederEligibility ( uint256 _days ) public onlyOwner {
        breederEligibility = _days *  1 days;
    }
    
    function setRetirementEligibility ( uint256 _days ) public onlyOwner {
        retirementEligibility = _days *  1 days; 
    }
    
    function setTokenIdandStakes ( uint256 _tokenid , uint256 _stakes) public onlyOwner {
        _tokenIds = _tokenid;
        femaleStakeCount = _stakes;
        
    }

    function migrateFemale ( uint256 _female, uint256 _status, uint256 _birthdate, uint256 _expirationdate ) public onlyEcosystem {
        require (  FemaleKishus[_female].status == 0 );
        FemaleKishus[_female].status = _status;   
        FemaleKishus[_female].birthdate = _birthdate;
        FemaleKishus[_female].expirationdate = _expirationdate;
    }

    function migrateFemaleStake ( uint256 _stakenumber,  address _owner, uint256 _started, uint256 _expires, uint256 _stakeamount, uint256 _lastrelease,  uint256 _nextrelease, uint256 _totalburned, uint256 _totalMinted,  bool _closed, bool _bondedOut )  public  onlyEcosystem{
        require ( femaleStakes[_stakenumber].owner == address( 0 ));
        femaleStakes[_stakenumber].owner = _owner;
        femaleStakes[_stakenumber].started = _started;
        femaleStakes[_stakenumber].expires = _expires;
        femaleStakes[_stakenumber].stakeamount = _stakeamount;
        femaleStakes[_stakenumber].lastrelease = _lastrelease;
        femaleStakes[_stakenumber].nextrelease = _nextrelease;
        femaleStakes[_stakenumber].totalburned = _totalburned;
        femaleStakes[_stakenumber].totalMinted = _totalMinted;
        femaleStakes[_stakenumber].closed = _closed;    
        femaleStakes[_stakenumber].bondedOut =_bondedOut;
        
    }
    

    function stakeForFemales() public payable returns(uint256)  {
          require ( msg.value == stakePrice, "Mint price not met");
          ERC20 _minikishu = ERC20 ( engineecosystem.returnAddress("RhythmGold") );
          
          _minikishu.transferFrom ( msg.sender, address(this), stakingAmountRequired );
          femaleStakeCount++;
          femaleStakes[femaleStakeCount].owner = msg.sender;
          femaleStakes[femaleStakeCount].started = block.timestamp;
          femaleStakes[femaleStakeCount].expires = block.timestamp + stakingforfemalestime;
          femaleStakes[femaleStakeCount].stakeamount = stakingAmountReturned;
          femaleStakes[femaleStakeCount].lastrelease = block.timestamp;
          femaleStakes[femaleStakeCount].nextrelease = block.timestamp + nextRelease;
          minikishuStaked[msg.sender] += stakingAmountReturned;
          userStakes[msg.sender].push( femaleStakeCount );
          _minikishu.transfer ( engineecosystem.returnAddress("KishuReserve"), stakingAmountRequired - stakingAmountReturned );   
          emit NewStake ( msg.sender, femaleStakeCount );
          return femaleStakeCount;
    }
    
    function closeMyStake ( uint256 _stakenumber ) public {
        require ( femaleStakes[_stakenumber].owner == msg.sender, "Not your stake");
        require ( !femaleStakes[_stakenumber].closed, "Stake closed already");
        require ( !femaleStakes[_stakenumber].bondedOut, "Bonded Out Already");
        require ( isExpired(femaleStakes[_stakenumber].expires), "Stake not expired yet");
        
        femaleStakes[_stakenumber].closed = true;
        minikishuStaked[msg.sender] -= stakingAmountReturned;
        
        uint256 _amount = femaleStakes[_stakenumber].stakeamount;
        femaleStakes[_stakenumber].stakeamount = 0;
        ERC20 _minikishu = ERC20 ( engineecosystem.returnAddress("RhythmGold") );
        
        _minikishu.transfer( msg.sender, _amount);
            
        
    }
    
    function bondOut ( uint256 _stakenumber ) public {
        require ( femaleStakes[_stakenumber].owner == msg.sender, "Not your stake");
        require ( !femaleStakes[_stakenumber].closed, "Stake closed already");
        require ( !femaleStakes[_stakenumber].bondedOut, "Bonded Out Already");
        require ( femaleStakes[_stakenumber].totalMinted == 0, "Bonding Out Not possible");
        bondContract _bondcontract = bondContract ( engineecosystem.returnAddress("FemaleBond") );
        _bondcontract.BondOut ( msg.sender, stakingAmountReturned );
        
        uint256 _amount = femaleStakes[_stakenumber].stakeamount;
        femaleStakes[_stakenumber].stakeamount = 0;
        
         ERC20 _minikishu = ERC20 ( engineecosystem.returnAddress("RhythmGold") );
        _minikishu.transfer( engineecosystem.returnAddress("FemaleBond"), _amount);
         minikishuStaked[msg.sender] -= _amount;
        femaleStakes[_stakenumber].bondedOut = true;
        femaleStakes[_stakenumber].closed = true;
    
    }
    
   
    function mintMyFemale(uint256 _stakenumber ) public   {
        require ( msg.sender == femaleStakes[_stakenumber].owner , "Not Owner of Stake");   
        require ( !femaleStakes[_stakenumber].closed , "Stake no longer exists");
        require ( mintingEnabled , "Minting Disabled");
        require ( FemaleBreederCount < max_quantity, "Max Breeders hit" ); 
        uint256 _releaseCost = releaseCost(_stakenumber) ;
        
        ERC20 _minikishu = ERC20 ( engineecosystem.returnAddress("RhythmGold") );
        _minikishu.transferFrom ( msg.sender, address(this), _releaseCost );  
        _minikishu.transfer ( engineecosystem.returnAddress("KishuReserve"), _releaseCost );   
        
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _safeMint( msg.sender , newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        
        FemaleKishus[newTokenId].expirationdate = block.timestamp + 610 days;  // change to days;
        FemaleKishus[newTokenId].birthdate = block.timestamp - 90 days;
        femaleStakes[_stakenumber].lastrelease = block.timestamp; 
        femaleStakes[_stakenumber].nextrelease = block.timestamp + nextRelease; // change to days
        femaleStakes[_stakenumber].totalMinted++;
        
        FemaleBreederCount++;
        FemaleKishus[ newTokenId ].status = 50;
       
        
        emit FemaleKishuMinted ( msg.sender, newTokenId);
       
    }
    
    function withdrawBNB () public OnlyEmergency {
       uint256 _total = address(this).balance;
       payable(msg.sender).transfer( _total );
    }

   
    
    function releaseCost( uint256 _stakenumber ) public view  returns(uint256){
        if ( block.timestamp > femaleStakes[_stakenumber].nextrelease ) return releasePrice;
        uint256 _timeleft = femaleStakes[_stakenumber].nextrelease - block.timestamp;
      
        uint256 _multiple = _timeleft / secondsinDay; // delete line only for testing
        return (_multiple * _multiple) * releasePrice;
    }
    
  
    
    function retireFemaleBreeder( uint256 _tokenId ) public {
        
        require ( block.timestamp > FemaleKishus[ _tokenId ].birthdate + retirementEligibility , "Not Eligible for Retirement"); // new line
        require ( ownerOf ( _tokenId) == msg.sender, "Not owner of breeder");
        require ( FemaleKishus[ _tokenId ].status == 50 , "Not a Female Breeder"); // new line
        FemaleKishus[ _tokenId ].status = 65;
        FemaleBreederCount --;
        ERC20 _femaleslotbreedertoken = ERC20 ( engineecosystem.returnAddress("FemaleSlot") );
        _femaleslotbreedertoken.transfer ( msg.sender, 1 );
       
        emit KishuBreederRetired ( _tokenId, msg.sender );
        
    }
    
    function pupMint (  address _owner, uint256 _birthdate , uint256 mother, uint256 father, uint256 litternumber , string memory _tokenuri) public onlyEcosystem returns(uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        _safeMint( _owner , newTokenId);
        _setTokenURI(newTokenId, _tokenuri );
        FemaleKishus[ newTokenId ].status = 0;
        FemaleKishus[ newTokenId ].birthdate = _birthdate;
        FemaleKishus[ newTokenId ].expirationdate = _birthdate + 730 days;
        FemaleKishus[ newTokenId ].mother = mother;
        FemaleKishus[ newTokenId ].father = father;
        FemaleKishus[ newTokenId ].litternumber = litternumber;
        
        emit PupMinted ( newTokenId, _owner );

        return newTokenId;
    }
    
    function getFemaleAlphaStatus( uint256 _female ) public pure returns ( uint8 ){
        if ( _female == 1  ) return 4;  // +4  Alpha Queen
        if ( _female > 1 && _female <= 5  ) return 3; //+3  Alpha Royal
        if ( _female > 5 && _female <= 12  ) return 2; //+ 2 Alpha Premium
        if ( _female > 12 && _female <= 25  ) return 1; //+ 1 Alpha Standard
        return 0; // +0 Common Pedigree
    }

     

    function isBreeder (  uint256 _tokenId ) public view returns ( bool ){
        if (  FemaleKishus[_tokenId].status == 50 ) return true;
        return false;
    }
    
    function isBreederOld (  uint256 _tokenId ) public view returns ( bool ){
        if (  block.timestamp > FemaleKishus[_tokenId].expirationdate ) return true;
        return false;
    }
    
    function graduatePupToFemaleBreeder( uint256 _tokenId ) public {
         require ( ownerOf(_tokenId) == msg.sender , "Pup isnt yours" );
         require ( block.timestamp > FemaleKishus[ _tokenId ]. birthdate + breederEligibility  , " Pup not old enough" );
         require ( FemaleKishus[ _tokenId ].status == 0 , "Not a minikishu puppy"); // new line
         require ( FemaleBreederCount < max_quantity, "Max Breeders hit" );

         ERC20 _femaleslotbreedertoken = ERC20 ( engineecosystem.returnAddress("FemaleSlot") );
         _femaleslotbreedertoken.transferFrom ( msg.sender, address(this), 1 );
         FemaleKishus[ _tokenId ].status = 50;
         FemaleBreederCount++;
         emit PupGraduated ( _tokenId, msg.sender );
     }
    
    function withdrawETH () public OnlyEmergency {
        teamwallet.transfer (  address(this).balance );
    }
    
    function isExpired ( uint256 _time ) public view returns(bool) {
        return ( block.timestamp > _time );
    }
   
    function toggleMintingEnabled() public onlyOwner {
        mintingEnabled = !mintingEnabled;
    }
    
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function burn(uint256 tokenId) public  {
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }
    
    function buildURI(uint256 _tokenId ) public view returns(string memory) {
        string memory _num = toString(_tokenId);
        string memory _build =  _tokenURI;
        _build = concat(_build, _num );
        return _build;
    }
    
    
    function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
    
    
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
     * @dev Converts a `address` to its ASCII `string` decimal representation.
     */
    function toString(address account) public pure returns(string memory) {
        return toString(abi.encodePacked(account));
    }
    
    /**
     * @dev Converts a `bytes` to its ASCII `string` decimal representation.
     */
    function toString(bytes memory data) public pure returns(string memory) {
        //bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
    
    
    modifier onlyEcosystem() {
       
        require ( engineecosystem.isEngineContract(msg.sender), "Not an Engine Contract");
         _;
    }
    
    
    modifier OnlyEmergency() {
        require( msg.sender == EmergencyAddress, " Emergency Only");
        _;
    }
}