/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/**
LICENSING RIGHTS: 

COPYRIGHT © 2022, HODL PROTOCOL and © 2022 MIT 

ALL RIGHTS RESERVED BY HODL PROTOCOL. THIS INTELLIGENT CONTRACT COMBINES SOFTWARE CODE WRITTEN BY HODL PROTOCOL (THE “HODL SOFTWARE CODE”) AND SOFTWARE CODE WRITTEN AND PROVIDED BY MIT (THE “MIT SOFTWARE CODE”).  

THIS INTELLIGENT CONTRACT COMBINES THE HODL SOFTWARE CODE AS A “NO LICENSE” (SPDX-LICENSE/DEFINITION) AND THE MIT SOFTWARE CODE AS AN OPEN-SOURCE SIMPLE PERMISSIVE LICENSE WITH CONDITIONS ONLY REQUIRING THE PRESERVATION OF COPYRIGHT AND LICENSE NOTICES.   (SPDX-LICENSE-IDENTIFIER: MIT - PRAGMA SOLIDITY 0.8.4).  

HODL SOFTWARE CODE:

THIS HODL SOFTWARE CODE IS CLASSIFIED AS A “NO LICENSE” COPYRIGHT USE, AND IT IS EXCLUSIVELY COPYRIGHTED BY DEFAULT AND IS PROPRIETARY TO HODL PROTOCOL.  THE HODL SOFTWARE CODE IS NOT AVAILABLE FOR LICENSING OR ANY USE WITHOUT PERMISSION FROM THE HODL-DAO, WHICH REQUIRES 1) A SUBMITTAL TO HODL-DAO, 2) DISCUSSION, AND 3) A MINIMUM OF A 67% VOTE TO ALLOW LICENSING WITH TERMS AND CONDITIONS OF THIRD-PARTY USE OF THE HODL SOFTWARE CODE.  THE HODL SOFTWARE CODE, INCLUDING ANY AMENDMENTS IN THE FUTURE, IS CONSIDERED CREATIVE WORK, AND ITS USES ARE STRICTLY PROHIBITED BY ALL THIRD PARTIES. YOU ARE NOT PERMITTED TO COPY, DISTRIBUTE, OR MODIFY WITHOUT BEING AT RISK OF TAKE-DOWNS, SHAKE-DOWNS, AND LITIGATION. FOR CLARIFICATION PURPOSES, THE HODL SOFTWARE CODE IS NOT OPEN SOURCE. 

USE OF THIS SMART CONTRACT:

THE DISCLAIMER SYNOPSIS IS PROVIDED BELOW AT THE BOTTOM OF THE CODE IN THIS SMART CONTRACT.  ITS IMPORTANT FOR YOU TO READ THIS PRIOR TO USE OF THIS SMART CONTRACT.  THE DISCLAIMER SYNOPSIS IS A CONDITIONAL ACCEPTANCE AGREEMENT, AGREED UPON BY YOU BASED ON YOUR DECISION TO USE THIS SMART CONTRACT.

IMPORTANT STATEMENTS:

Political Statement: Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.   

Religious statement: And then many will fall away and betray one another and hate one another. And many false prophets will arise and lead many astray. And because lawlessness will be increased, the love of many will grow cold. But the one who endures to the end will be saved. And this gospel of the kingdom will be proclaimed throughout the whole world as a testimony to all nations, and then the end will come. (Matthew 24:10-20).  

Privacy Clause: “The right of the people to be secure in their persons, houses, papers, and effects, against unreasonable searches and seizures, shall not be violated, and no Warrants shall issue, but upon probable cause, supported by Oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized.”
**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
                /// @solidity memory-safe-assembly
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

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be proved to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and the sibling nodes in `proof`,
     * consuming from one or the other at each step according to the instructions given by
     * `proofFlags`.
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
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
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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

        _afterTokenTransfer(address(0), to, tokenId);
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

        _afterTokenTransfer(owner, address(0), tokenId);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 */
contract PaymentSplitter is Context {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);

    uint256 private _totalReleased;

    address private _HODLAddress = 0x77A34A0745fAA7E445a324b277228BC78BB9f092;
    address private _ArtOwnerAddress = 0x6A863EDbB161c935cf70dbE26a0162159118F7a9;

    // Share percents for HODL, ArtOwner and Founders
    uint256 private _shareHODL = 890; // 89%
    uint256 private _shareArtOwner = 80; // 8%
    uint256 private _shareFounder = 30; // 3%

    uint256 private _totalHODLReleased;
    uint256 private _totalArtOwnerReleased;

    uint256 private _totalFounderShares;

    mapping(address => uint256) private _founderShares;
    mapping(address => uint256) private _founderReleased;
    address[] private _founderPayees;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _founderShares[account];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function releaseToHODL(address payable account) public virtual {
        require(account == _HODLAddress, "PaymentSplitter: No HODL Address");

        uint256 totalReceived = address(this).balance + _totalReleased; // Amount received total including HODL, Art Owner and Founders
        uint256 totalHODLReceived = (totalReceived * _shareHODL) / 1000; // Amount received for only HODL;

        uint256 payment = totalHODLReceived - _totalHODLReleased;

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _totalHODLReleased = _totalHODLReleased + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function releaseToArtOwner(address payable account) public virtual {
        require(account == _ArtOwnerAddress, "PaymentSplitter: No Art Owner Address");

        uint256 totalReceived = address(this).balance + _totalReleased; // Amount received total including HODL, Art Owner and Founders
        uint256 totalArtOwnerReceived = (totalReceived * _shareArtOwner) / 1000; // Amount received for only art owner;

        uint256 payment = totalArtOwnerReceived - _totalArtOwnerReleased;

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _totalArtOwnerReleased = _totalArtOwnerReleased + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function releaseFounders(address payable account) public virtual {
        require(_founderShares[account] > 0, "PaymentSplitter: account is not a founder");

        uint256 totalReceived = address(this).balance + _totalReleased; // Amount received total including HODL, Art Owner and Founders
        uint256 totalFoundReceived = (totalReceived * _shareFounder) / 1000; // Amount received for only founders;

        uint256 payment = (totalFoundReceived * _founderShares[account]) / _totalFounderShares - _founderReleased[account];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _founderReleased[account] = _founderReleased[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function releasableAmount(address account) public view returns(uint256) {
        if (account == _HODLAddress) {
            uint256 totalReceived = address(this).balance + _totalReleased; // Amount received total including HODL, Art Owner and Founders
            uint256 totalHODLReceived = (totalReceived * _shareHODL) / 1000; // Amount received for only HODL;
            uint256 payment = totalHODLReceived - _totalHODLReleased;

            return payment;
        }
        else if (account == _ArtOwnerAddress) {
            uint256 totalReceived = address(this).balance + _totalReleased; // Amount received total including HODL, Art Owner and Founders
            uint256 totalArtOwnerReceived = (totalReceived * _shareArtOwner) / 1000; // Amount received for only art owner;
            uint256 payment = totalArtOwnerReceived - _totalArtOwnerReleased;

            return payment;
        }
        else {
            require(_founderShares[account] > 0, "PaymentSplitter: account has no shares");

            uint256 totalReceived = address(this).balance + _totalReleased; // Amount received total including HODL, Art Owner and Founders
            uint256 totalFoundReceived = (totalReceived * _shareFounder) / 1000; // Amount received for only founders;
            uint256 payment = (totalFoundReceived * _founderShares[account]) / _totalFounderShares - _founderReleased[account];

            return payment;
        }
    }

    function _setHODLAddress(address account) internal {
        _HODLAddress = account;
    }

    function _setArtOwnerAddress(address account) internal {
        _ArtOwnerAddress = account;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_founderShares[account] == 0, "PaymentSplitter: account already has shares");

        _founderPayees.push(account);
        _founderShares[account] = shares_;
        _totalFounderShares = _totalFounderShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}


contract WerthanPayRollCheckPlatinum is ERC721, Ownable, PaymentSplitter {
    using Strings for uint256;

    uint256 public MAX_TOTAL_SUPPLY = 12;
    uint256 private _tokenId;

    // token infos: tokenId => serial number
    mapping (uint256 => uint256) public tokenSerialNumber;
    // token ID of already minted with serial number and level: serial number => tokenId
    mapping (uint256 => uint256) public isMintedToken;
    mapping (uint256 => bool) public revealed;

    // Prices
    uint256 public tokenPrice = 0.1 ether;
    uint256 public tokenPriceLocked = 0.1 ether;

    // Default Base URI 
    string public baseURI = "ipfs://QmQvkgiPsKP2NG3nhLuJSuLbADU3TCfeg7dMjf1sBiRbEo/";
    string private baseURIRevealed = "ipfs://QmQvkgiPsKP2NG3nhLuJSuLbADU3TCfeg7dMjf1sBiRbEo/";

    // Protection
    bool public mintable = false;
    bool public tradable = true;

    // Lock tokens
    mapping (uint256 => bool) public lockedToken;
    uint256 public lockedUntil = 1656633600; // 2023/07/01 00:00:00

    // valid serial number using MerkleTree
    bytes32 private serialNumbersMerkleRoot = 0xa0bbb34bc64c46a0d2970eaa7ee155479ece5ded60ea81e927dc5131e35b9349; // for initial 12 nfts only

    constructor (
        address[] memory payees,
        uint256[] memory shares_
    ) ERC721("Werthan Pay Roll Checks - Platinum(TEST)", "W-PRC-P(TEST)") PaymentSplitter(payees, shares_)  {
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() 
        public 
        view 
        returns (uint256) 
    {
        return _tokenId;
    }

    function _baseURI() 
        internal 
        view
        override 
        returns (string memory) 
    {
        return baseURI;
    }

    function _baseURIRevealed() 
        internal 
        view
        returns (string memory) 
    {
        return baseURIRevealed;
    }

    function setBaseURI(string memory newBaseURI) 
        external 
        onlyOwner 
    {
        baseURI = newBaseURI;
    }

    function setBaseURIRevealed(string memory newBaseURI) 
        external 
        onlyOwner 
    {
        baseURIRevealed = newBaseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory baseUri = _baseURI();        
        if (revealed[tokenId]) {
            baseUri = _baseURIRevealed();
        }
     
        uint256 serialNumber = tokenSerialNumber[tokenId];
        return bytes(baseUri).length != 0 ? string(abi.encodePacked(baseUri, serialNumber.toString(), "p.json")) : '';
    }

    function reveal(uint256[] memory tokenIds)
        external
        onlyOwner
    {
        require(tokenIds.length > 0, "Undefined Token ID");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] <= totalSupply(), "Unminted Token ID");

            revealed[tokenIds[i]] = true;
        }
    }

    function setMerkleRoot(bytes32 merkleRoot)
        external
        onlyOwner 
    {
        serialNumbersMerkleRoot = merkleRoot;
    }

    function setMaxTotalSupply(uint256 supply) 
        external 
        onlyOwner 
    {
        MAX_TOTAL_SUPPLY = supply;
    }

    function setMintable(bool value) 
        external 
        onlyOwner 
    {
        require(mintable != value, "Already set the value");

        mintable = value;
    }

    function setTradable(bool value) 
        external 
        onlyOwner 
    {
        require(tradable != value, "Already set the value");

        tradable = value;
    }

    function setPrice(uint256 price) 
        external
        onlyOwner
    {
        tokenPrice = price;
    }

    function setPriceLocked(uint256 price)
        external
        onlyOwner
    {
        tokenPriceLocked = price;
    }

    function setLockTime(uint256 time)
        external
        onlyOwner
    {
        lockedUntil = time;
    }

    function mint(uint256 serialNumber, bytes32[] calldata merkleProof, bool locked)
        external 
        payable
    {
        require(tx.origin == msg.sender, "The caller is another contract");

        // Check mintable status
        require(mintable, "Mint is not allowed yet.");

        // Verify Serial Number
        bytes32 leaf = keccak256(abi.encodePacked(serialNumber.toString()));
        require(MerkleProof.verify(merkleProof, serialNumbersMerkleRoot, leaf), "No valid serial number.");

        // Check minted token
        require(isMintedToken[serialNumber] == 0, "This level serial number was already minted.");

        // Check total supply
        require(totalSupply() < MAX_TOTAL_SUPPLY, "MAX_TOTAL_SUPPLY: No more token left");

        // Check token price
        uint256 _tokenPrice = tokenPrice;
        if (locked) {
            _tokenPrice = tokenPriceLocked;
        }
        require(msg.value >= _tokenPrice, "Wrong price");

        _tokenId++;
        tokenSerialNumber[_tokenId] = serialNumber;
        isMintedToken[serialNumber] = _tokenId;
        lockedToken[_tokenId] = locked;

        _mint(msg.sender, _tokenId);
    }

    function airdrop(address to, uint256 serialNumber, bool locked)
        external
        onlyOwner
    {
        // Check total supply
        require(totalSupply() < MAX_TOTAL_SUPPLY, "MAX_TOTAL_SUPPLY: No more token left");

        // Check minted token
        require(isMintedToken[serialNumber] == 0, "This level serial number was already minted.");

        _tokenId++;
        tokenSerialNumber[_tokenId] = serialNumber;
        isMintedToken[serialNumber] = _tokenId;
        lockedToken[_tokenId] = locked;

        _mint(to, _tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override
    {
        // Check tradable
        require(tradable, "No allow to transfer this token");
        // Check lock
        require(!lockedToken[tokenId] || block.timestamp > lockedUntil, "This token is locked until July 1 2023.");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     *
     * @param account the payee to release funds for
     */
    function releaseToHODL(address payable account) public override {
        require(msg.sender == account || msg.sender == owner(), "Release: no permission");

        super.releaseToHODL(account);
    }

    /**
     * @notice Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     *
     * @param account the payee to release funds for
     */
    function releaseToArtOwner(address payable account) public override {
        require(msg.sender == account || msg.sender == owner(), "Release: no permission");

        super.releaseToArtOwner(account);
    }

    /**
     * @notice Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     *
     * @param account the payee to release funds for
     */
    function releaseFounders(address payable account) public override {
        require(msg.sender == account || msg.sender == owner(), "Release: no permission");

        super.releaseFounders(account);
    }

    function setHODLAddress(address account) public onlyOwner {
        _setHODLAddress(account);
    }

    function setArtOwnerAddress(address account) public onlyOwner {
        _setArtOwnerAddress(account);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "No enough balance");

        (bool success, ) = owner().call{value: address(this).balance}("");

        require(success, "Unable to send eth");
    }
}

/**
DISCLAIMER SYNOPSIS:

THE PERSON OR ENTITY USING THIS INTELLIGENT CONTRACT AFFIRMS IT HAS READ THE COMPLETE AND FULL DISCLAIMER TITLED “DISCLAIMER AND CONDITIONAL ACCEPTANCE AGREEMENT, DEFINITIONS, HODLNOMICS, WEBSITE TERMS, AND CONDITIONS & PRIVACY AGREEMENT” (THE “FULL AND COMPLETE DISCLAIMER”). THE COMPLETE AND FULL DISCLAIMER FULL DISCLAIMER CAN BE FOUND ON THE WEBSITE CONTAINING THE MINT MACHINE OF THE HODL PROTOCOL: HTTP://NFT.WERTHANARTCOLLECTION.COM/DISCLAIMER.  THIS IS A LIVING INTELLIGENT CONTRACT AND IS SUBJECT TO CHANGE ANYTIME AND WITHOUT NOTICE. THIS MATERIAL, CODING, AND SCRIPT HAVE BEEN PREPARED FOR INFORMATIONAL PURPOSES AND ARE NOT INTENDED TO PROVIDE, AND SHOULD NOT BE RELIED ON FOR, INVESTMENT, TAX, LEGAL, OR ACCOUNTING ADVICE. YOU SHOULD CONSULT YOUR TAX, LEGAL, AND ACCOUNTING ADVISORS BEFORE ENGAGING IN ANY TRANSACTION, SUCH AS BLOCKCHAIN, FUNGIBLE TOKENS, NON-FUNGIBLE TOKENS, AND SMART CONTRACTS (INTELLIGENT CONTRACTS).  NO PROMISES OF INCOME FROM INVESTMENT ARE MADE OR IMPLIED.  YOU SHOULD HAVE NO REASONABLE EXPECTATION OF A PROFIT; YOU ARE NOT BEING OFFERED AN EXPECTATION OF A PROFIT.  THERE IS NO CHARGE FOR THE DIGITAL ASSETS; THERE IS A CHARGE FOR THE MINTING FEE FOR THE CREATION OF THE INTELLIGENT CONTRACT YOU PRODUCE.  YOUR PRICE FOR THE DIGITAL ASSET IS ZERO ON THE INITIAL MINTING PROCESS, SO THERE IS NO “COST BASIS” FOR DERIVING A PROFIT.  YOU MAY DONATE TO HELP IN THE PROCESSING OF MORE ART ASSETS.  THE HODLER OF HODL TOKENS AND DIGITAL ASSETS SHALL EXPECT ABSOLUTELY NO RETURNS OF PROFIT OVER THE FREE COST OF THE DIGITAL ASSETS OR THE DONATION, WHICH IS VOLUNTARILY PAID.  HODLER OF HODL TOKENS AND DIGITAL ASSETS SHALL EXPECT ABSOLUTELY NO POSITIVE INTEREST OR ROI (RATE OF INTEREST OR RETURN ON PRINCIPLE).  YOU KNOW, AGREE, AND ARE AWARE THAT THE DIGITAL ASSETS MAY NOT BE CAPABLE OF BEING SOLD, TRADED, OR EXCHANGED TO OR FROM ANY OTHER PERSON OR ENTITY.  THIS MEANS YOU MAY OWN IT AND NOT BE ABLE TO EXTRACT FUNDS BY SALE, TRADE, OR EXCHANGE.  SHOULD YOU PAY THE MINT FEE OR DONATE AND USE CRYPTO OR FIAT MONEY (THE “DEBT PAPER”) IT IS RISKY AND CAN AND WILL BE LOST.  DISCLAIMER AND CONDITIONAL ACCEPTANCE AGREEMENT DEFINITIONS, HODLNOMICS, WEBSITE TERMS, CONDITIONS & PRIVACY AGREEMENT. HODL PROTOCOL DOES OFFER MEMBERSHIP TO UNRESTRICTED PERSONS (SEE DEFINITION BELOW) WITH FREEDOM OF RIGHTS, THE RIGHT OF FREE SPEECH, THE RIGHT TO VOTE, AND THE RIGHT TO BE A MEMBER WITH BENEFITS.  HODL PROTOCOL DOES NOT OFFER AN INVESTMENT CONTRACT, STOCKS, BONDS, DERIVATIVES, AND TRANSFERRABLE SHARES BECAUSE HODL PROTOCOL DOES NOT OFFER A RATE OF RETURN OR A PROFIT OTHER THAN DIRECT OWNERSHIP OF HODL TOKEN AND DIGITAL ASSETS.  HODL PROTOCOL DOES OFFER MEMBERSHIP TO UNRESTRICTED PERSONS (SEE DEFINITION BELOW) WITH FREEDOM OF RIGHTS, THE RIGHT OF FREE SPEECH, THE RIGHT TO VOTE, AND THE RIGHT TO BE A MEMBER WITH BENEFITS.  HODL PROTOCOL DOES NOT OFFER AN INVESTMENT CONTRACT, STOCKS, BONDS, DERIVATIVES, AND TRANSFERRABLE SHARES BECAUSE HODL PROTOCOL DOES NOT OFFER A RATE OF RETURN OR A PROFIT OTHER THAN DIRECT OWNERSHIP OF HODL TOKEN AND DIGITAL ASSETS.  HODL PROTOCOL IS NOT OFFERING TO MARKET THE DIGITAL ASSETS FOR YOU; HODL PROTOCOL IS NOT MANAGING THEM FOR YOU.  THE HOLDLERS OF THE HODL TOKEN MANAGE THE HODL PROTOCOL. HODL PROTOCOL DOES NOT OFFER MANAGERIAL EXPERTISE OR ESSENTIAL MANAGERIAL EFFORTS THAT AFFECT THE SUCCESS OF DIGITAL ASSETS; HODL PROTOCOL IS NOT OFFERED TO SELL OR RESALE, OR DISTRIBUTE DIGITAL ASSETS; HODL PROTOCOL DOES NOT HAVE HIDDEN, ABSENT, UNDISCLOSED PROCESSES OF SIGNIFICANT INFORMATION ASYMMETRIES BETWEEN THE MANAGERS AND PROMOTERS (AGAIN THERE ARE NOT ANY MANAGERS AND PROMOTERS), HODL PROTOCOL PROMISES NONE.  HODL PROTOCOL OFFERS NO INVESTORS AND PROSPECTIVE INVESTORS.  ALL PARTICIPANTS ARE FULLY DISCLOSED IN THE BLOCKCHAIN AS ITS FUNCTION, WHICH IS 100% HONEST, TRACKABLE, AND RELIABLE.  IT'S OPEN FOR EVERYONE TO SEE.  I AGREE I AM NOT AN INDIVIDUAL(S), ENTITY(S), CITIZEN(S), RESIDENT, OR RESIDENT NATIONAL(S), HEREAFTER REFERRED TO AS A “DIGITAL ASSETS CREATOR/PRODUCER,” LIVING OR LOCATED WITHIN THE COUNTRY BORDERS OF UNITED STATES OF AMERICA (USA), CANADA, MALAYSIA, SINGAPORE, MALTA, CUBA, IRAN, NORTH KOREA, SUDAN, SYRIA, VENEZUELA, CRIMEA REGION, BANGLADESH, BOLIVIA, ECUADOR, KYRGYZSTAN, HONG KONG, CHINA, UNITED KINGDOM (RETAIL USERS ONLY), NETHERLANDS, GERMANY, FRANCE, LITHUANIA, ITALY, JAPAN, AND BRAZIL (COLLECTIVELY THE “RESTRICTED COUNTRIES”).   AN INDIVIDUAL(S), ENTITY(S), CITIZEN(S), RESIDENT, OR RESIDENT NATIONAL(S) LIVING IN A RESTRICTED COUNTRIES IS A RESTRICTED AND SHALL BE KNOWN AS A RESTRICTED PERSON (THE “RESTRICTED PERSON(S)”). AS A RESTRICTED PERSON LIVING WITHIN A RESTRICTED COUNTRIES, YOU SHALL REFRAIN FROM MINTING DIGITAL ASSETS.   A DIGITAL ASSETS CREATOR/PRODUCER LIVING OR RESIDING OUTSIDE THE BORDERS OF THE RESTRICTED COUNTRIES IS AN UNRESTRICTED PERSON (THE “UNRESTRICTED PERSON(S)”).  HODL PROTOCOL DOES NOT SUPPORT OR CONDONE THE CREATION, BUYING, OR SELLING OF DIGITAL ASSETS (S) AS A MEANS OF INVESTMENT.  BLOCKCHAINS, SMART CONTRACTS, FUNGIBLE TOKENS, NON-FUNGIBLE TOKENS, AND CRYPTOCURRENCIES, IN GENERAL, ARE ALL CUTTING-EDGE TECHNOLOGIES, AND AS SUCH, THERE IS A SIGNIFICANT RISK OF TOTAL FAILURE. COMPUTERS ARE COMPLEX, AND DISTRIBUTED LEDGERS, SOFTWARE, PROGRAMS, AND CODING ARE COMPLEX. HODL PROTOCOL PROVIDES A GATEWAY AND INTERFACES TO INTERACT WITH ART ASSETS IN THE FORM OF INTELLIGENT CONTRACTS DECENTRALIZED AND DEPLOYED ON THE ETHEREUM MAINNET FROM UNRESTRICTED COUNTRIES ACCESSIBLE TO ANYONE WITH ACCESS TO THE ETHEREUM BLOCKCHAIN.  ADDITIONALLY, AS MENTIONED BEFORE, THIRD-PARTY APPLICATIONS AND SERVERS ARE LOCATED IN AN UNRESTRICTED COUNTRY.    HODL PROTOCOL DOES NOT PROVIDE OR CONTROL LIQUIDITY OTHER THAN THE PORTION ALLOCATED WHEN THE HODL PROTOCOL WAS CREATED. HODL PROTOCOL CAUTIONS ALL USERS AND HODLERS TO EXERCISE CAUTION WHEN PURCHASING HODL TOKENS AS LIQUIDITY MAY FLUCTUATE OR BE NON-EXISTENT AND WHEN MINTING DIGITAL ASSETS BECAUSE THERE MAY NOT BE A MARKET FOR THEM AT ALL.   WHEN YOU CREATE, MINT, BUY, SELL, OR TRANSFER ANY DIGITAL ASSETS, YOU ARE RESPONSIBLE FOR YOUR TRANSACTION DECISIONS.  HODL PROTOCOL DOES NOT CENTRALLY STORE, HOST, DISTRIBUTE, AGGREGATE, SELL, CUSTODY, OR MANAGE YOUR DIGITAL ASSETS.  THE HODL PROTOCOL DOES NOT STORE THE METADATA FOR YOU OR CREATE LIQUIDITY POOLS AT THIS TIME AND MAY NEVER. THE HODL PROTOCOL DOES NOT HAVE AUTOMATED MARKET MAKERS OR TRADING MARKETS FOR DIGITAL ASSETS.   CAUTION: ALL OPINIONS AND INFORMATION SHARED ON SOCIAL MEDIA PLATFORMS THAT HODL PROTOCOL DOES NOT DIRECTLY CONTROL ARE THOSE RESPECTIVE INDIVIDUALS ALONE, AND COMMENTS BY OTHERS SHOULD NOT BE RELIED UPON TO MAKE YOUR DECISION TO MINT DIGITAL ASSETS THROUGH THE HODL PROTOCOL.  YOU SHOULD NOT RELY ON ANY ADVICE FROM ANYONE TO GET INVOLVED WITH THE HODL PROTOCOL AND ITS DIGITAL ASSETS; YOU WILL MORE THAN LIKELY LOSE ALL YOUR MONEY.  DO NOT RELY UPON HODL PROTOCOL FOR FINANCIAL, INVESTMENT, TAX, OR LEGAL ADVICE.  DO NOT RELY UPON ANY THIRD-PARTY DISCUSSING HODL PROTOCOL FOR FINANCIAL, INVESTMENT, TAX, OR LEGAL ADVICE.   ADDITIONALLY, HODL PROTOCOL CAN CONTROL WHAT IT PROMISES BASED ON THE TIMELINE AND PHASES, BUT IT DOES NOT CONTROL, GOVERN, OR MAINTAIN RESPONSIBILITY FOR THE FOLLOWING:
 
WHO CAN PARTICIPATE AND PRODUCE DIGITAL ASSETS,

WHICH DIGITAL ASSETS ARE MINTED USING THE HODL PROTOCOL,

THE DONATION VALUE YOU PLACE ON THE DIGITAL ASSETS,

THE FUTURE VALUE OF DIGITAL ASSETS,

THE INTERMEDIARY PLATFORMS, OR NETWORKS, THROUGH WHICH THE BLOCKCHAIN
FUNCTIONS INCLUDE HOW THE DIGITAL ASSETS ARE TO BE TRANSFERRED, PURCHASED, OR SOLD.  THIS WILL BE ACCOMPLISHED THROUGH THIRD-PARTY WEBSITES AND MARKETPLACES AND USING YOUR WALLET, 

THE METHODS AND MANNER IN WHICH THE HODLERS TRANSFER OR MANAGE THEIR DIGITAL ASSETS, 

THE OUTCOMES RESULTING FROM ANY OF THE ACTIVITIES AND DECISIONS LISTED ABOVE,

IF THE USERS OR HODLERS ARE LOCATED IN RESTRICTED COUNTRIES AND UNRESTRICTED COUNTRIES,
 
BY PARTICIPATING AND MINTING YOUR DIGITAL ASSETS, YOU ACKNOWLEDGE, AGREE, AND ACCEPT ALL CONDITIONAL AGREEMENTS IN THIS DISCLAIMER AND ADDITIONALLY THE FOLLOWING: 

YOU MUST NOT EXPECT A PROFIT FROM THE WORK OF OTHERS; THIS IS NOT A JOINT OR COMMON ENTERPRISE,

DIGITAL ASSETS MAY FLUCTUATE IN VALUE IN UNPREDICTABLE WAYS,

THE DIGITAL ASSETS SUPPLIES MAY GO UP OR DOWN IN VALUE IF THEY HAVE ANY VALUE AT ALL, AND YOU ARE NOT GUARANTEED, NOR SHOULD YOU EXPECT, ANY NET VALUE APPRECIATION OF THE UNDERLYING DIGITAL ASSETS AS A COLLECTIBLE OR BUSINESS MODEL, AND THERE ARE NO PROTECTIONS AGAINST LOSS IN VALUE,

THE PAST PRICE AND PURCHASING ACTIVITY TRENDS ARE NOT INDICATIVE OF FUTURE TRENDS AND ARE NOT A PROXY FOR THE HISTORICAL OR PROJECTED FUTURE VALUE OF ANY SPECIFIC DIGITAL ASSETS,

AS A USER, YOU GENERATE YOUR KEYS AND HOLD YOUR WALLET,

YOU MINT YOUR INTELLIGENT CONTRACT AS A DIGITAL ASSET; THE HODL PROTOCOL IS JUST PROVIDING YOU A MECHANISM, AS A SERVICE, TO ASSIST YOU IN DOING SO, AND THIS IS WHAT THE MINT FEE IS FOR.  THE MORE COMPLEX THE INTELLIGENT CONTRACT, THE MORE IT COSTS,

THERE IS NO INVESTMENT OF MONEY,

THERE IS NO ORDINARY OR COMMON ENTERPRISE,

ANY AIRDROPS DISBURSED TO HODLERS FOR THEIR MEMBERSHIP LEVEL ARE ACCESSIBLE.
 
DIGITAL ASSETS ARE NOT:

CURRENCY, LEGAL TENDER, OR MONEY, 

AN INVESTMENT (WHETHER SECURED OR UNSECURED), EQUITY INTEREST, PROPRIETARY INTEREST, OR ECONOMIC RIGHT,

EQUITY, DEBT OR HYBRID INSTRUMENT, SECURITY COLLECTIVE INVESTMENT SCHEME, 

A MANAGED FUND, FINANCIAL DERIVATIVE, FUTURES CONTRACT, DEPOSIT, COMMERCIAL PAPER, NEGOTIABLE INSTRUMENT, INVESTMENT CONTRACT, SHARES, NOTE, BOND, WARRANT, CERTIFICATE, OR INSTRUMENT ENTITLING THE HODLER TO INTEREST WHATSOEVER, DIVIDENDS OR ANY RETURN, NOR ANY OTHER FINANCIAL DEVICE OR SECURITY,

DIGITAL ASSETS ARE NOT GUARANTEED OR SECURED BY ANY PERSON, ASSET, OR ENTITY. YOU MUST HAVE NO EXPECTATION OF PROFIT FROM THE WORK OF OTHERS; THERE IS NO JOINT EFFORT OR COMMON ENTERPRISE CREATED TO CREATE A PAYMENT, RENT, OR PROFIT.  THIS MEANS THERE IS NO TYPICAL JOINT OR COMMON ENTERPRISE; THERE SHALL BE NO EXPECTATION OF EFFORTS OF A PROMOTER OR THIRD PARTY FOR YOU TO MAKE ANY FORM OF FINANCIAL GAIN FROM HODL PROTOCOL AND ITS HODL TOKEN,

HODL PROTOCOL IS UNDER NO OBLIGATION TO ISSUE DIGITAL ASSETS AS A REPLACEMENT FOR ANY THAT MAY BE LOST, STOLEN, DESTROYED, OR OTHERWISE INACCESSIBLE FOR ANY REASON.
 
TO RECAP A CRITICAL POINT, YOU UNDERSTAND AND ACCEPT THAT HODL PROTOCOL IS NOT OFFERING A REASONABLE EXPECTATION OF PROFITS TO YOU OR OTHERS AND THE DERIVED EFFORTS OF OTHERS, WHETHER THE PUBLIC, HODLERS OF DIGITAL ASSETS, OR HODLERS OF HODL TOKENS.   ALSO, INFORMATION THAT MAY BE PUBLIC AND UNRELATED TO THE HODL PROTOCOL DOES NOT CONTROL THE EXPECTATION OF PROFITS.  HODL PROTOCOL DOES NOT PREVENT THE PUBLIC AND THEIR EXPECTATIONS OF THE HODL TOKEN OR DIGITAL ASSETS.   HODL PROTOCOL IS NOT OFFERING THE SALE OF ANYTHING; YOU ARE CREATING YOUR DIGITAL ASSETS LIKE CREATING THE SEED, PLANTING IT IN THE GROUND, WATERING IT, AND WATCHING IT GROW – YOU CAN KEEP IT FOR YOURSELF, OR YOU CAN CONVEY IT USING THE BLOCKCHAIN (SEE DEFINITION “BIRTH” ABOVE).  HODL PROTOCOL IS NOT MANAGING OR PROMOTING ANYTHING OR OFFERING THE EXPECTATION OF PROFITS BASED ON OUR ACTIONS, YOUR ACTIONS, OR OTHERS.  YOU BIRTH THE DIGITAL ASSETS, CREATE THEM, AND OWN THEM UNTIL YOU CONVEY IT.  AGAIN, THE HODL PROTOCOL IS NOT SELLING A DIGITAL ASSET BECAUSE THE DIGITAL SUPPORT IS NOT PURCHASABLE.  YOU COMPLETE IT BY PAYING A MINT FEE FOR OUR SERVICE; THIS SERVICE ASSISTS YOU IN WRITING THE INTELLIGENT CONTRACT TO CREATE THE DIGITAL ASSETS.  AS YOU BIRTH THE DIGITAL ASSETS, YOU OWN A PIECE OF THE ART OBJECT AS A FORM OF A CERTIFICATE OF TITLE OWNERSHIP AS AN FTO INTELLIGENT CONTRACT(S) (SEE DEFINITIONS), AND YOU RECEIVE PART OF THE ROYALTY IF YOU CREATE A CTO INTELLIGENT CONTRACT(S) (SEE DEFINITIONS).  HODL PROTOCOL CHARGES A MINT FEE FOR HELPING YOU MINT YOUR DIGITAL ASSETS, AND HODL PROTOCOL GIVES YOU BENEFITS THAT ARE EQUAL TO AND GREATER THAN THE VALUE OF THE COST OF THE MINT FEE (SEE BENEFITS).  ADDITIONALLY, YOU CAN PURCHASE DIGITAL IMAGES IN THE FORM OF A REGULAR NON-FUNGIBLE TOKEN SHOULD YOU PREFER TO DO THAT; THESE HAVE NO BENEFITS.    HODL PROTOCOL DOES NOT CENTRALLY STORE, HOST, DISTRIBUTE, AGGREGATE, SELL, CUSTODY, OR MANAGE YOUR DIGITAL ASSETS.  THE HODL PROTOCOL DOES NOT STORE THE METADATA FOR YOU OR CREATE LIQUIDITY POOLS AT THIS TIME AND MAY NEVER. THE HODL PROTOCOL DOES NOT HAVE AUTOMATED MARKET MAKERS OR TRADING MARKETS FOR DIGITAL ASSETS.   CAUTION: ALL OPINIONS AND INFORMATION SHARED ON SOCIAL MEDIA PLATFORMS THAT HODL PROTOCOL DOES NOT DIRECTLY CONTROL ARE THOSE RESPECTIVE INDIVIDUALS ALONE, AND COMMENTS BY OTHERS SHOULD NOT BE RELIED UPON TO MAKE YOUR DECISION TO MINT DIGITAL ASSETS THROUGH THE HODL PROTOCOL.  YOU SHOULD NOT RELY ON ANY ADVICE FROM ANYONE TO GET INVOLVED WITH THE HODL PROTOCOL AND ITS DIGITAL ASSETS; YOU WILL MORE THAN LIKELY LOSE ALL YOUR MONEY.  DO NOT RELY UPON HODL PROTOCOL FOR FINANCIAL, INVESTMENT, TAX, OR LEGAL ADVICE.  DO NOT RELY UPON ANY THIRD-PARTY DISCUSSING HODL PROTOCOL FOR FINANCIAL, INVESTMENT, TAX, OR LEGAL ADVICE.   ADDITIONALLY, HODL PROTOCOL CAN CONTROL WHAT IT PROMISES BASED ON THE TIMELINE AND PHASES, BUT IT DOES NOT CONTROL, GOVERN, OR MAINTAIN RESPONSIBILITY FOR THE FOLLOWING:


COMMON LAW TRADEMARK AND COPYRIGHT - 2022, HODL PROTOCOL: 
HODLNOMICS, HODLER, HODLING, HODLINGS, HODLER, DIGITAL GIFT CARD, DIGITAL ASSET, STAKEHODLERS, HODL PROTOCOL, HODL TOKENS, HODLFLATION, HODLER, AND HODL-DAO, MINT MACHINE, FRACTIONAL TITLE OWNERSHIP, CERTIFICATE OF TITLE OWNERSHIP, FTO, CTO ARE ALL COPYRIGHTED AND TRADEMARKED NAMES.  THESE NAMES ARE STRICTLY PROHIBITED WITHOUT PERMISSION AND VOTE OF THE HODL PROTOCOL DAO. 

LICENSING RIGHTS: COPYRIGHT © 2022, HODL PROTOCOL and © 2022 MIT 

ALL RIGHTS RESERVED BY HODL PROTOCOL. THIS INTELLIGENT CONTRACT COMBINES SOFTWARE CODE WRITTEN BY HODL PROTOCOL (THE “HODL SOFTWARE CODE”) AND SOFTWARE CODE WRITTEN AND PROVIDED BY MIT (THE “MIT SOFTWARE CODE”).  

THIS INTELLIGENT CONTRACT COMBINES THE HODL SOFTWARE CODE AS A “NO LICENSE” (SPDX-LICENSE/DEFINITION) AND THE MIT SOFTWARE CODE AS AN OPEN-SOURCE SIMPLE PERMISSIVE LICENSE WITH CONDITIONS ONLY REQUIRING THE PRESERVATION OF COPYRIGHT AND LICENSE NOTICES.   (SPDX-LICENSE-IDENTIFIER: MIT - PRAGMA SOLIDITY 0.8.4).  

THE HODL SOFTWARE CODE AND THE MIT SOFTWARE CODE ARE COLLECTIVELY REFERRED TO AS “SOFTWARE CODE.” 

HODL SOFTWARE CODE:

HODL PROTOCOL’S HODL SOFTWARE CODE IS CLASSIFIED AS A “NO LICENSE” COPYRIGHT USE, AND IT IS EXCLUSIVELY COPYRIGHTED BY DEFAULT AND IS PROPRIETARY TO HODL PROTOCOL.  THE HODL SOFTWARE CODE IS NOT AVAILABLE FOR LICENSING OR ANY USE WITHOUT PERMISSION FROM THE HODL-DAO, WHICH REQUIRES 1) A SUBMITTAL TO HODL-DAO, 2) DISCUSSION, AND 3) A MINIMUM OF A 67% VOTE TO ALLOW LICENSING WITH TERMS AND CONDITIONS OF THIRD-PARTY USE OF THE HODL SOFTWARE CODE.  THE HODL SOFTWARE CODE, INCLUDING ANY AMENDMENTS IN THE FUTURE, IS CONSIDERED CREATIVE WORK, AND ITS USES ARE STRICTLY PROHIBITED BY ALL THIRD PARTIES. YOU ARE NOT PERMITTED TO COPY, DISTRIBUTE, OR MODIFY WITHOUT BEING AT RISK OF TAKE-DOWNS, SHAKE-DOWNS, AND LITIGATION. FOR CLARIFICATION PURPOSES, THE HODL SOFTWARE CODE IS NOT OPEN SOURCE. 

MIT SOFTWARE CODE:
MIT LICENSE COPYRIGHT © 2022, MIT (THE “MIT OPEN-SOURCE LICENSE”).   THE MIT OPEN-SOURCE LICENSE IS A SHORT AND SIMPLE PERMISSIVE LICENSE WITH CONDITIONS ONLY REQUIRING THE PRESERVATION OF COPYRIGHT AND LICENSE NOTICES, WHICH ARE CONTAINED WITHIN ITS MIT SOFTWARE CODE. THE MIT SOFTWARE CODE IS AVAILABLE FOR LICENSING AND CAN BE LICENSED FOR WORKS, MODIFICATIONS, AND LARGER WORKS, AND IT MAY BE DISTRIBUTED UNDER DIFFERENT TERMS AND WITHOUT SOURCE CODE.  THE MIT OPEN-SOURCE LICENSE IS A PERMISSION-BASED GRANTING, FREE OF CHARGE, TO ANY PERSON OBTAINING A COPY OF ITS PORTION (SPECIFICALLY THE MIT SOFTWARE CODE PORTION) OF THE SOFTWARE CODE WITHOUT RESTRICTION, INCLUDING WITHOUT LIMITATION THE RIGHTS TO USE, COPY, MODIFY, MERGE, PUBLISH, DISTRIBUTE, SUBLICENSE, AND SELL COPIES OF THE MIT SOFTWARE CODE, AND TO PERMIT PERSONS WHOM THE MIT SOFTWARE CODE IS FURNISHED, AS PART OF THE PERMISSIVE LICENSE REQUIREMENTS AND ARE SUBJECT TO THE FOLLOWING CONDITIONS: 1) INCLUDE MIT COPYRIGHT NOTICE, AS SEEN ABOVE; 2) THIS COPYRIGHT NOTICE SHALL BE INCLUDED IN ALL COPIES OR SUBSTANTIAL PORTIONS OF THE SOFTWARE CODE AND 3) THE MIT LIABILITY PROVISION (SEE “LIABILITY PROVISION” BELOW).

THE PARTS AND SECTIONS OF THE SOFTWARE CODE WRITTEN BY MIT ARE OPEN-SOURCE AND GRANTED LICENSES. THIS PORTION AND ONLY THIS PORTION BY MIT MAY BE COPIED AND USED PER THE MIT LICENSING AGREEMENT AND TERMS OF USE NOTICED BY MIT IN ITS ORIGINAL LICENSE OF THIS SOFTWARE CODE. THE PARTS AND SECTIONS OF THE SOFTWARE CODE WRITTEN BY HODL PROTOCOL ARE NOT AVAILABLE FOR LICENSING WITHOUT PERMISSION FROM THE HODL-DAO, AS MENTIONED ABOVE. 
 
LIABILITY PROVISION:

THIS SOFTWARE CODE AND INTELLIGENT CONTRACT IS PROVIDED BY THE COPYRIGHT HOLDERS (HODL PROTOCOL AND MIT) AND CONTRIBUTORS “AS IS,” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, ARE   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE CODE OR INTELLIGENT CONTRACT EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/