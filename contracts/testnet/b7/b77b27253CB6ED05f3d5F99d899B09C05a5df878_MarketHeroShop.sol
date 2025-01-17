/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// File: contracts-upgradeable/access/IAccessControlUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
     * bearer except when using {AccessControl-_setupRole}.
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
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

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
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

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
    function renounceRole(bytes32 role, address account) external;
}

// File: openzeppelin-contracts/utils/Strings.sol



pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
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
        uint256 index = digits;
        temp = value;
        while (temp != 0) {
            buffer[--index] = bytes1(uint8(48 + uint256(temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}

// File: base64-sol/base64.sol



pragma solidity >=0.6.0;

/// @title Base64
/// @author Brecht Devos - <[email protected]>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

// File: contracts/interfaces/IMarketHeroAnimal.sol



interface IMarketHeroAnimal{
    // Info about certain hero

    enum AnimalType{
        Hamster,
        Bull,
        Bear,
        Whale
    }
    struct Hero{
        AnimalType animal;
        uint16[8] color_and_effects;
        uint8 speed; 
        uint8 lifesteal;
        uint8 endurence;
        uint8 fund;
        uint8 level;
        uint256 gamesPlayed;
        uint256 gamesWon;
    }

    function gameWon(uint256 _tokenID) external ;

    function gameLostOrTied(uint256 _tokenID) external;
}
// File: contracts-upgradeable/utils/math/MathUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File: contracts-upgradeable/utils/StringsUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;


/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

// File: contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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

// File: contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol


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
interface IERC165Upgradeable {
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

// File: contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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

// File: contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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

// File: contracts/interfaces/IToken.sol

interface IToken {
    function decimals() external view returns(uint8);
}
// File: contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// File: contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol


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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: contracts-upgradeable/utils/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: contracts-upgradeable/access/AccessControlUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;






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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
     *
     * May emit a {RoleGranted} event.
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
     *
     * May emit a {RoleRevoked} event.
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
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
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
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;









/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

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
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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
        address owner = _ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
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
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
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
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721Upgradeable.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// File: contracts-upgradeable/security/PausableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: contracts/MarketHeroTools.sol

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;





contract MarketHeroTools is Initializable, OwnableUpgradeable {
    address public admin;

    address public marketHeroAnimalAddress;
    // address public marketHeroShopAddress;

    function initialize(
        address _admin
    ) public initializer{
        __Ownable_init_unchained();
        transferOwnership(_admin);
        admin = _admin;
    }

    function setMarketHeroAnimalContract(address _marketHeroAnimalAddress) public onlyOwner{
        marketHeroAnimalAddress = _marketHeroAnimalAddress;
    }
    /** 
     * @notice Function converts parameters of hero into string value
        */
    function convert(string memory _name, uint8 animal, uint8 speed, uint8 vampirism, uint8 endurence, uint32 fund) external view returns(string memory){
        require(msg.sender == marketHeroAnimalAddress, "MarketHeroTools: sender is not the MarketHeroAnimal" );
        string memory _link = getHeroPhoto(animal);
        string memory _animal = Strings.toString(animal);
        string memory _speed = Strings.toString(speed);
        string memory _vampirism = Strings.toString(vampirism);
        string memory _endurence = Strings.toString(endurence);
        string memory _fund = Strings.toString(fund);
        bytes memory _result;
        if (animal==0){
            _result = bytes(abi.encodePacked(
                        '{"name":"',
                                _name,
                                '","description": "Hero for Market Hero ',  

                                '", "image": "',
                                _link,
                                
                                '", "attributes": [ ',
                                    '{ "trait_type": "Type","value": "',
                                    _animal,
                                    '"},',
                                    '{ "trait_type": "Speed",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _speed,
                                    '"},',
                                    '{ "trait_type": "Vampirism",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _vampirism,
                                    '"},',
                                    '{ "trait_type": "Endurence",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _endurence,
                                    '"},',
                                    '{ "trait_type": "Fund",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _fund,
                                    '"} ]',
                                '}'));
        }else if((animal == 1)||(animal ==2 )){
            _result = bytes(abi.encodePacked(
                        '{"name":"',
                                _name,
                                '","description": "Hero for Market Hero ',  

                                '", "image": "',
                                _link,
                                
                                '", "attributes": [ ',
                                    '{ "trait_type": "Type","value": "',
                                    _animal,
                                    '"},',
                                    '{ "trait_type": "Speed",',
                                    '"max_value" : "15"',
                                    '"value": "',
                                    _speed,
                                    '"},',
                                    '{ "trait_type": "Vampirism",',
                                    '"max_value" : "15"',
                                    '"value": "',
                                    _vampirism,
                                    '"},',
                                    '{ "trait_type": "Endurence",',
                                    '"max_value" : "15"',
                                    '"value": "',
                                    _endurence,
                                    '"},',
                                    '{ "trait_type": "Fund",',
                                    '"max_value" : "15"',
                                    '"value": "',
                                    _fund,
                                    '"} ]',
                                '}'));
        }else if(animal ==3){
            _result = bytes(abi.encodePacked(
                        '{"name":"',
                                _name,
                                '","description": "Hero for Market Hero ',  

                                '", "image": "',
                                _link,
                                
                                '", "attributes": [ ',
                                    '{ "trait_type": "Type","value": "',
                                    _animal,
                                    '"},',
                                    '{ "trait_type": "Speed",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _speed,
                                    '"},',
                                    '{ "trait_type": "Vampirism",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _vampirism,
                                    '"},',
                                    '{ "trait_type": "Endurence",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _endurence,
                                    '"},',
                                    '{ "trait_type": "Fund",',
                                    '"max_value" : "10"',
                                    '"value": "',
                                    _fund,
                                    '"} ]',
                                '}'));
        }

        return string(abi.encodePacked("data:application/json;base64, ", Base64.encode(_result)));
            // string(
            //     abi.encodePacked(
            //         "data:application/json;base64, ",
            //         Base64.encode(
            //             bytes(
            //                 abi.encodePacked(
            //                     '{"name":"',
            //                     __name,
            //                     '","description": "Hero for Market Hero ',  

            //                     '", "image": "',
            //                     _link,
                                
            //                     '", "attributes": [ ',
            //                         '{ "trait_type": "Type","value": "',
            //                         _name,
            //                         '"},',
            //                         '{ "trait_type": "Speed",',
            //                         '"max_value" : "4"',
            //                         '"value": "',
            //                         _speed,
            //                         '"},',
            //                         '{ "trait_type": "Vampirism",',
            //                         '"max_value" : "4"',
            //                         '"value": "',
            //                         _vampirism,
            //                         '"},',
            //                         '{ "trait_type": "Endurence",',
            //                         '"max_value" : "4"',
            //                         '"value": "',
            //                         _endurence,
            //                         '"},',
            //                         '{ "trait_type": "Fund",',
            //                         '"max_value" : "4"',
            //                         '"value": "',
            //                         _fund,
            //                         '"} ]',
            //                     '}'
            //                 )
            //             )
            //         )   
            //     )
            // );
 
 
    }

    /** 
     * @notice Function returns photo by type of animal
        */
    function getHeroPhoto(uint8 _animalType) public pure returns (string memory){
        string memory _link ="";
        if(_animalType==0){
            _link = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Pearl_Winter_White_Russian_Dwarf_Hamster_-_Front.jpg/1920px-Pearl_Winter_White_Russian_Dwarf_Hamster_-_Front.jpg";
        } else 
        if(_animalType==1){
            _link = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Alas_Purwo_banteng_close_up.jpg/550px-Alas_Purwo_banteng_close_up.jpg";
        } else 
        if(_animalType==2){
            _link = "https://xakep.ru/wp-content/uploads/2017/12/147134/bear.jpg";
        } else 
        if(_animalType==3){
            _link = "https://images.immediate.co.uk/production/volatile/sites/23/2019/10/GettyImages-1164887104_Craig-Lambert-2faf563.jpg?quality=90&resize=620%2C413";
        }
        return _link;
    }

    /** 
     * @dev Function returns random number in  boundaries of _min and _max (seed must be unique string)
        */
    function random(uint256 _min, uint256 _max, string memory seed) public view returns(uint256){
        require (_min < _max, "Random: invalid params");
        uint256 base =  uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.coinbase, seed)));
        return _min + base % (_max - _min);
    }

    /** 
     * @notice Function distribute randomly basic points of traits by animal type
        */
    function multipleCase(uint8 _animalType) public view returns(uint8,uint8,uint8,uint8, uint8){
        uint8 _freeLevelUp;
        if (_animalType == 0){
            _freeLevelUp = uint8(random(0,2,"freeLevelUp"));
        } else if((_animalType == 1)||(_animalType == 2)){
            _freeLevelUp = uint8(random(0,4,"freeLevelUp"));
        } else if(_animalType == 3){
            _freeLevelUp = uint8(random(0,5,"freeLevelUp"));
        }
        uint8 _randomTrait;
        uint8 _speed = 0;
        uint8 _vampirism = 0;
        uint8 _endurence = 0;
        uint8 _fund = 0;

        while(_freeLevelUp>0){
            if(_randomTrait == 0){
                _speed += 1;
            } else
            if(_randomTrait == 0){
                _vampirism += 1;
            } else 
            if(_randomTrait == 0){
                _endurence += 1;
            } else 
            if(_randomTrait == 0){
                _fund += 1;
            }
            _freeLevelUp -= 1;
        }
        return (_speed, _vampirism, _endurence, _fund, (_speed+ _vampirism+ _endurence+ _fund));
    }

}




// File: contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/MarketHeroGame.sol


pragma solidity ^ 0.8.0;










contract MarketHeroGame is Initializable, AccessControlUpgradeable, PausableUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant BACKEND_ROLE = keccak256("BACKEND_ROLE");
    // address of MarketHeroToken
    address public tokenMHT;
    // address of MarketHeroTools Contract
    address public marketHeroToolsAddress;
    // Id of last game started
    uint256 public lastGameID;
    // address of MarketHeroAnimal contract
    address public marketHeroAnimalAddress;

    // Enumeration of cities to play
    enum Location{
        Dubai,
        Bali,
        London,
        NewYork,
        Sydney
    }
    // Enumeration of game statuses
    enum Result{
        Started,
        Hero1Won,
        Hero2Won,
        Draw
    }

    // Game info
    struct Game{
        uint256 hero1;
        uint256 hero2;
        Location city;
        Result gameStatus;
    }

    // prices of entering location 
    mapping(uint8 => uint256) entryFee;
    // game ids
    mapping(uint256 => Game) games;

    //  Emitted when game started
    event GameStarted(uint256 gameID, uint256 hero1, uint256 hero2, uint8 city);
    //  Emitted when game finished
    event GameFinished(uint256 gameID, uint8 result);

    function initialize (
        address _admin,
        address _tokenMHT,
        address _marketHeroTools
    ) public initializer{
        __AccessControl_init();
        __Pausable_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(BACKEND_ROLE, _admin);
        tokenMHT = _tokenMHT;
        marketHeroToolsAddress = _marketHeroTools;

        // Default Configuration
        setEntryFee(0, 5);  // Dubai
        setEntryFee(1, 10); // Bali
        setEntryFee(2, 25); // London
        setEntryFee(3, 50); // NewYork
        setEntryFee(4, 100);// Sydney
    }

    /**
     * @dev Modifier to make a function callable only when the sender has BackEnd role.
     */
    modifier onlyBackEnd() {
        require(hasRole(BACKEND_ROLE, msg.sender), "MarketHeroAnimal: sender is not the Backender");
        _;
    }
    function grandBackEndRole(address _user) public onlyAdmin{
        _setupRole(BACKEND_ROLE, _user);
    }
    /** 
     * @notice function sets prices of enterin location 
     * @param _location city (enumeration) 
     * @param _entryFee price in MHT Token
      */
    function setEntryFee(
        uint8 _location,
        uint256 _entryFee
    ) public onlyAdmin{
        uint8 _decimals = uint8(IToken(tokenMHT).decimals());
        entryFee[_location] = _entryFee * (10 ** _decimals);
    }

    /** 
     * @notice function sets address of MArketHeroAnimal Contract 
      */
    function setMarketHeroAnimalContract(address _marketHeroAnimalAddress) public onlyAdmin{
        marketHeroAnimalAddress = _marketHeroAnimalAddress;
    }  

    /**
    * @dev Throws if called by any account other than the one with the Admin role granted.
    */
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "MarketHeroGame: Caller is not the Admin");
        _;
    }

    


    /** 
     * @notice function starts searching opponent for game 
      */
    function startSearchingGame(uint8 _location) public {
        require(IERC20Upgradeable(tokenMHT).balanceOf(msg.sender)>=entryFee[_location], "player do not have enough money to enter this location");
        IERC20Upgradeable(tokenMHT).approve(address(this),entryFee[_location]);
    }
    


    /** 
     * @notice function starts game and returns random value for start position of players
        also emits "gamestarted" event 
     * @param _tokenID1 token id of hero1
     * @param _tokenID2 token id of hero2
     * @param _city game location (enumeration) 
      */
    function startGame(
        uint256 _tokenID1,
        uint256 _tokenID2,
        uint8 _city) public onlyBackEnd returns(uint8){
        
        // require(IERC20Upgradeable(tokenMHT).balanceOf(player1)>=entryFee[_location], "player1 do not have enough money to enter this location");
        // require(IERC20Upgradeable(tokenMHT).balanceOf(player2)>=entryFee[_location], "player2 do not have enough money to enter this location");

        IERC20Upgradeable(tokenMHT).safeTransferFrom(IERC721Upgradeable(marketHeroAnimalAddress).ownerOf(_tokenID1), address(this), entryFee[_city]);
        IERC20Upgradeable(tokenMHT).safeTransferFrom(IERC721Upgradeable(marketHeroAnimalAddress).ownerOf(_tokenID2), address(this), entryFee[_city]);
        uint256 _gameID = ++lastGameID;
        uint8 _startPosition = uint8(MarketHeroTools(marketHeroToolsAddress).random(0,1,'Start_position'));
        
        games[_gameID].hero1 = _tokenID1;
        games[_gameID].hero2 = _tokenID2;
        games[_gameID].city = Location(_city);
        games[_gameID].gameStatus = Result.Started;

        emit GameStarted(_gameID, _tokenID1, _tokenID2, _city);
        return _startPosition;
    }

    /** 
     * @notice function finishes game with draw and updates heroes games` statistics
        also emits "gamefinished" event 
     * @param _gameID id of finished game
      */
    function endGameWithDraw(uint256 _gameID) public onlyBackEnd{
        require(games[_gameID].gameStatus == Result.Started, "MarketHeroGame: This game is already over" );
        games[_gameID].gameStatus = Result.Draw;
        IMarketHeroAnimal(marketHeroAnimalAddress).gameLostOrTied(games[_gameID].hero1);
        IMarketHeroAnimal(marketHeroAnimalAddress).gameLostOrTied(games[_gameID].hero2);
        emit GameFinished(_gameID, uint8(games[_gameID].gameStatus));
    }

    /** 
     * @notice function finishes game with victory of entered player 
        updates heroes games` statistics
        also emits "gamefinished" event 
     * @param _gameID id of finished game
      */
    function endGameWithWinner(uint256 _gameID, uint256 _tokenID) public onlyBackEnd {
        require(games[_gameID].gameStatus == Result.Started, "MarketHeroGame: This game is already over" );
        
        if (_tokenID == games[_gameID].hero1){
            games[_gameID].gameStatus = Result.Hero1Won;
            IMarketHeroAnimal(marketHeroAnimalAddress).gameWon(_tokenID);
            IMarketHeroAnimal(marketHeroAnimalAddress).gameLostOrTied(games[_gameID].hero2);
        }else if (_tokenID == games[_gameID].hero2){
            games[_gameID].gameStatus = Result.Hero2Won;
            IMarketHeroAnimal(marketHeroAnimalAddress).gameWon(_tokenID);
            IMarketHeroAnimal(marketHeroAnimalAddress).gameLostOrTied(games[_gameID].hero1);
        }

        emit GameFinished(_gameID, uint8(games[_gameID].gameStatus));
    }
    
}
 
// File: contracts/MarketHeroAnimal.sol


pragma solidity ^0.8.0;







contract MarketHeroAnimal is Initializable, ERC721Upgradeable, OwnableUpgradeable, IMarketHeroAnimal {
    // address of MarketHeroShop Contract
    address public marketHeroShopAddress; 
    // address of MarketHeroTools Contract
    address public marketHeroToolsAddress;
    // address of MarketHeroGame Contract
    address public marketHeroGameAddress;
    // Template for token 
    Hero public templateHero; 
    // Id of last minted token
    uint256 public lastMintedTokenID;
    // info about pause status
    bool private _paused;

    // Limits for all types of heroes
    mapping(uint8 => uint256) public animalMaxAmount;
    // Number of already minted tokens divided by animals` types
    mapping(uint8 => uint256) public animalMintedAmount;
    // NFT Tokens
    mapping(uint256 => Hero) public heroes;


    // Emitted when the pause is triggered by `account`.
    event Paused(address account);
    // Emitted when the pause is lifted by `account`.
    event Unpaused(address account);
    // Emitted when Token was minted
    event Minted(address indexed to, uint256 indexed tokenID);
    // Emitted when Token was burnt
    event Burnt(address indexed from, uint256 indexed tokenID);

    
    function initialize(
        address _admin,
        address _marketHeroTools,
        address _marketHeroShop,
        address _marketHeroGame
    ) public initializer{
        __ERC721_init("MarketHero","MKH");
        __Ownable_init_unchained();
        // __Ownable_init();
        transferOwnership(_admin);
        _paused = false;
        marketHeroShopAddress = _marketHeroShop;
        marketHeroToolsAddress = _marketHeroTools;
        marketHeroGameAddress = _marketHeroGame;

        // Default Configuration
        setDefaultHeroParameters();
        setMaxHeroesAmount(0,0); //Hamster
        setMaxHeroesAmount(3,1000); //Whale
        setMaxHeroesAmount(1,5000); //Bull
        setMaxHeroesAmount(2,5000); //Bear
    }

//  ***************MODIFIERS*********************************************
    /**
     * @dev Modifier to make a function callable only when the sender is MarketHeroShop contract.
     */
    modifier onlyShop() {
        require(_msgSender() == marketHeroShopAddress, "MarketHeroAnimal: call from outside the shop");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the sender is MarketHeroGame contract.
     */
    modifier onlyGame() {
        require(_msgSender() == marketHeroGameAddress, "MarketHeroAnimal: call from outside the game");
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
        require(paused(), "MarketHeroAnimal: not paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "MarketHeroAnimal: paused");
        _;
    }

//  ***************OWNER FUNCTIONS*********************************************
    function pause() public onlyOwner {
        _paused = true;
        emit Paused(_msgSender());
    }
    function unpause() public onlyOwner {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @notice Function Sets number of max heroes for definite animal type
     * @param _animalType type of hero
     * @param _maxAmount number of max amount
     */ 
    function setMaxHeroesAmount(
        uint8 _animalType,
        uint256 _maxAmount
    ) public onlyOwner{
        animalMaxAmount[_animalType] = _maxAmount;
    }
//  ***************PRIVATE FUNCTIONS*********************************************
    /**
    * @dev setting default meanings for hero parameters 
     */
    function setDefaultHeroParameters() private {
        
        templateHero.speed = 0;
        templateHero.lifesteal = 0;
        templateHero.endurence = 0;
        templateHero.fund = 0;
        templateHero.level = 0;

    }
//  ***************GAME FUNCTIONS*********************************************
    /**
     * @notice Function update statistics of specific hero when he won
     */ 
    function gameWon(uint256 _tokenID) external onlyGame{
        heroes[_tokenID].gamesPlayed +=1;
        heroes[_tokenID].gamesWon +=1;
    }

    /**
     * @notice Function update statistics of specific hero when he lost or tied
     */  
    function gameLostOrTied(uint256 _tokenID) external onlyGame{
        heroes[_tokenID].gamesPlayed +=1;
    }
//  ***************SHOP FUNCTIONS*********************************************
    /**
    * @dev Function allows to renew traits of specific Hero, may be used only by shop contract
        for upgrading traits and during minting(for basic random distribution)
    * @param _tokenID ID of an hero
    * @param _animalType 1 of 4 type of Hero (Hamster,Bull,Bear,Whale)
    * @param _speed 1 of 4 basic traits which affect result of the game
    * @param _lifesteal 1 of 4 basic traits which affect result of the game
    * @param _fund 1 of 4 basic traits which affect result of the game
    * @param _level summarizes points of above traits
     */
    function renewHeroParameters(
        uint256 _tokenID,
        uint8 _animalType,
        uint8 _speed,
        uint8 _lifesteal,
        uint8 _endurence,
        uint8 _fund,
        uint8 _level
        )external onlyShop{
            heroes[_tokenID].animal = AnimalType(_animalType);
            heroes[_tokenID].speed = _speed;
            heroes[_tokenID].lifesteal = _lifesteal;
            heroes[_tokenID].endurence = _endurence;
            heroes[_tokenID].fund = _fund;
            heroes[_tokenID].level = _level;
        }

    /**
     * @notice Function to mint Tokens, may be used only by shop contract
     * @dev emits "Minted" event
     * @param _animalType 1 of 4 types of animals
     * @param _to receiver address
     */
    function createHero(uint8 _animalType, address _to) external onlyShop{
        require(animalMaxAmount[_animalType] == 0 || animalMaxAmount[_animalType] >= animalMintedAmount[_animalType] + 1, "MarketHeroAnimal: Can't mint that much of animals");
        uint256 _tokenID = ++lastMintedTokenID;
        _safeMint(_to, _tokenID);
        heroes[_tokenID].animal = AnimalType(_animalType);
        heroes[_tokenID].speed = templateHero.speed;
        heroes[_tokenID].lifesteal = templateHero.lifesteal;
        heroes[_tokenID].endurence = templateHero.endurence;
        heroes[_tokenID].fund = templateHero.fund;
        heroes[_tokenID].level = templateHero.level;

        animalMintedAmount[_animalType]++;
        emit Minted(_to,_tokenID);
    }


    /** 
     * @notice functionfor users to burn their tokens (can be used only by owner)
     * @dev emits "Burnt" event
     * @param _tokenID NFT id 
     */
    function burn(uint256 _tokenID) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), _tokenID), "MarketHeroAnimal: caller is not owner nor approved");
        _burn(_tokenID);
        emit Burnt(_msgSender(),_tokenID);
    }
//  ***************VIEW FUNCTIONS*********************************************
    /**
     * @notice Function returns status of bool variable
     */ 
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @notice Function returns number of max amount of definite type of animal(Hero)
     */ 
    function getMaxHeroesAmount(uint8 _animalType) public view returns(uint256){
        return animalMaxAmount[_animalType];
    }
    /**
     * @notice Function returns number of minted amount of definite type of animal(Hero)
     */ 
    function getMintedHeroesAmount(uint8 _animalType) public view returns(uint256){
        return animalMintedAmount[_animalType];
    }
    function getHeroIds(address _wallet,uint256 _from,uint256 _to) public view returns(uint256 [] memory){
            uint256[] memory ids = new uint256[](balanceOf(_wallet));
            uint256 counter = 0;
            for (uint256 i =_from; i<=_to; i++ ){
                if (_wallet == ERC721Upgradeable.ownerOf(i))
                {
                    ids[counter++] = i;
                }
            }
            return ids;
    }

        function getHeroes(uint256[] memory _ids) public view returns(Hero [] memory){
            Hero[] memory arr = new Hero[](_ids.length);

            for (uint256 i = 0; i < arr.length; i++ ){
                    arr[i] = heroes[_ids[i]];
            }
            return arr;
    }



    /**
     * @notice Function Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */ 
    function tokenURI(uint256 _tokenID) public view virtual override returns(string memory){
        require(_exists(_tokenID),"MarketHeroAnimal: That hero doesn`t exist");
        string memory _line = MarketHeroTools(marketHeroToolsAddress).convert( 
            name(),  
            uint8(heroes[_tokenID].animal),
            heroes[_tokenID].speed,
            heroes[_tokenID].lifesteal,
            heroes[_tokenID].endurence,
            heroes[_tokenID].fund
        ); 
        return _line;
    }

    /**
    * @notice function returns 6 basic characteristics 
        (Animal Type, 4 traits that affect result of the game, level of hero)
    * @param _tokenID ID of an hero 
     */
    function getHeroParameters(uint256 _tokenID) public view returns(
        uint8, uint8, uint8, uint8, uint8, uint8) {
        return(
            uint8(heroes[_tokenID].animal),
            heroes[_tokenID].speed,
            heroes[_tokenID].lifesteal,
            heroes[_tokenID].endurence,
            heroes[_tokenID].fund,
            heroes[_tokenID].level
        );
    }

}














// File: contracts/MarketHeroShop.sol


pragma solidity ^0.8.0;









contract MarketHeroShop is Initializable, OwnableUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    // Info about upgrades` prices
    struct Upgrade{
        uint256 level1Price; // price of first upgrade
        uint256 interval; // gap between levels` prices
    }
    struct HeroOrder{
        uint256 tokenId; 
        uint256 price; 
    }

    // The token MarketHeroToken
    address public tokenMHT;
    // address of NFT Contract MarketHeroAnimal
    address public marketHeroAnimalContract;
    // address of Contract MarketHeroTools
    address public marketHeroToolsAddress;
    // address of an admin
    address public admin;

    // List of heroes for sale
    mapping(uint256 => uint256) public heroOrders;
    // List of hero prices
    mapping(uint8 => uint256) public heroPrices;
    // List of upgrade prices
    mapping(uint8 => Upgrade) public heroSkillUpgradePrices;
    // List of number of hamsters to be burned for trade
    mapping(uint8 => mapping(uint8 => uint16)) public animalBurnAmount;

        // Emitted when sale hero
    event HeroSold(address indexed from,address indexed to, uint256 indexed tokenID,uint256 amount);

    function initialize(
        address _admin,
        address _tokenMHT,
        address _marketHeroToolsAddress
        )public initializer{
        __Ownable_init_unchained();
        transferOwnership(_admin);
        __Pausable_init_unchained();
        marketHeroToolsAddress = _marketHeroToolsAddress;
        tokenMHT = _tokenMHT;

        // Default Price Configuration
        setHeroPrice(0,20000000000000000);// hamster
        setHeroPrice(1,500000000000000000);// bull
        setHeroPrice(2,500000000000000000);// bear
        setHeroPrice(3,1000000000000000000);// whale
        setUpgradePrices(0,50000,50000);     // Hamster
        setUpgradePrices(1,60000,60000); // Bull
        setUpgradePrices(2,60000,60000); // Bear
        setUpgradePrices(3,70000,70000);// Whale
        setBurnAmount(0,1,50); // burn amount Hamster for Bull
        setBurnAmount(0,2,50); // burn amount Hamster for Bear
        setBurnAmount(0,3,100); // burn amount Hamster for Whale
        setBurnAmount(1,3,3); // burn amount Bull for Whale
        setBurnAmount(2,3,3); // burn amount Bear for Whale
    }

//  ************* OWNER FUNCTIONS ********************************

    /**
     * @notice Function sets contract address of MarketHeroToken
      */
    function setTokenMHT(address _tokenMHT) public onlyOwner{
        tokenMHT = _tokenMHT;
    }
    /**
     * @notice Function sets price for definite type of animal(hero)
     * @param _animalType type of hero
     * @param _priceHero  price in MHT tokens
      */
    function setHeroPrice(
        uint8 _animalType,
        uint256 _priceHero
    ) public onlyOwner{
        heroPrices[_animalType] = _priceHero;
    }

    /**
     * @notice Function sets upgrade price for definite type of animal(hero)
     * @param _animalType type of hero
     * @param _level1Price price for first upgrade
     * @param _interval static difference of prices between levels.
        Example 3 --> 4  = _level1Price + (4-1)*_interval
      */
    function setUpgradePrices(
        uint8 _animalType,
        uint256 _level1Price, // price of first upgrade
        uint256 _interval // gap between levels` prices
    ) public onlyOwner{
        uint8 _decimals = uint8(IToken(tokenMHT).decimals());
        heroSkillUpgradePrices[_animalType].level1Price = _level1Price*(10**_decimals);
        heroSkillUpgradePrices[_animalType].interval = _interval*(10**_decimals);
    }

    /**
     * @notice Function sets number of heroes to burn for trading
     * @param _animalTypeBurn type of animal(hero) to burn  
     * @param _animalTypeClaim type of animal(hero) to receive  
     * @param _amount number of heroes to burn
      */
    function setBurnAmount(
        uint8 _animalTypeBurn,
        uint8 _animalTypeClaim,
        uint16 _amount
    ) public onlyOwner{
        animalBurnAmount[_animalTypeBurn][_animalTypeClaim] = _amount;
    }

    /**
     * @notice Function sets contract address of MarketHeroAnimal contract
      */
    function setMarketHeroAnimalContract(address _marketHeroAnimalContract) public onlyOwner {
        marketHeroAnimalContract = _marketHeroAnimalContract;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Function mints tokens of definite type of animal(hero) for free(only by owner)
     * @param _animalType type of Hero
     * @param _amount number of tokens to create
      */
    function createHeroes(uint8 _animalType, uint256 _amount) public onlyOwner{
        _createHeroes(_animalType, _amount);
    }

//  ************* PRIVATE FUNCTIONS ********************************
    /**
     * @notice Function mints tokens of definite type of animal(hero) for free(private)
     * @param _animalType type of Hero
     * @param _amount number of tokens to create
      */
    function _createHeroes(uint8 _animalType, uint256 _amount) private {
        for (uint256 i =0; i<_amount; i++ ){
            MarketHeroAnimal(marketHeroAnimalContract).createHero(_animalType, _msgSender());

            (uint8 _speed,
             uint8 _lifesteal,
             uint8 _endurence,
             uint8 _fund,
             uint8 _level) = MarketHeroTools(marketHeroToolsAddress).multipleCase(_animalType);

            uint256 lastMintedTokenId = MarketHeroAnimal(marketHeroAnimalContract).lastMintedTokenID();
            MarketHeroAnimal(marketHeroAnimalContract).renewHeroParameters(
                lastMintedTokenId,
                _animalType,
                _speed,
                _lifesteal,
                _endurence,
                _fund,
                _level);
            offerHeroForSale(lastMintedTokenId,heroPrices[_animalType]+ ((heroPrices[0]+heroPrices[_animalType/250])*_level));
        }
    }



//  ************* USER FUNCTIONS ********************************
    /**
     * @notice Function trades definite number of tokens of specific animal(hero) type for another better type of hero 
     * @param heroes array of similar tokens
     * @param _animalTypeBurn type of tokens to burn
     * @param _animalTypeClaim type of token to receive
      */

    function burnHeroesForReward(uint256[] memory heroes,uint8 _animalTypeBurn, uint8 _animalTypeClaim) public{
        require(animalBurnAmount[_animalTypeBurn][_animalTypeClaim]> 1,"MarketHeroShop: You can`t trade this type of hero");
        require(MarketHeroAnimal(marketHeroAnimalContract).getMaxHeroesAmount(_animalTypeClaim) == 0 || MarketHeroAnimal(marketHeroAnimalContract).getMaxHeroesAmount(_animalTypeClaim) >= MarketHeroAnimal(marketHeroAnimalContract).getMintedHeroesAmount(_animalTypeClaim) + 1, "MarketHeroShop: Can't mint that much of animals");
        require(animalBurnAmount[_animalTypeBurn][_animalTypeClaim]<heroes.length,"MarketHeroShop: too much tokens selected");
        require(animalBurnAmount[_animalTypeBurn][_animalTypeClaim]<heroes.length,"MarketHeroShop: not enough tokens");
        for (uint256 id = 0;id<heroes.length;id++){
            (uint8 _animalType,,,,,) = MarketHeroAnimal(marketHeroAnimalContract).getHeroParameters(heroes[id]);
            require(_animalType==_animalTypeBurn,"MarketHeroShop: animal type to burn doesn`t match for this trade"); 
        }

        for (uint256 id =0;id<heroes.length;id++){
            MarketHeroAnimal(marketHeroAnimalContract).burn(heroes[id]);
        }
        _createHeroes(_animalTypeClaim, 1);

    }


    /**
     * @notice Function to set hero price in BNB for sale
     * @param _tokenID id of the hero
     * @param _amount price of the hero
      */
    function offerHeroForSale(uint256 _tokenID,uint _amount) public{
         require(msg.sender == MarketHeroAnimal(marketHeroAnimalContract).ownerOf(_tokenID),"not an owner");
         heroOrders[_tokenID] = _amount;
    }
 fallback() external payable {
     
    }

    receive() external payable {
       
    }
    /**
     * @notice Function to buy created hero
     * @param _tokenID id of the hero
      */
    function buyHero(uint256 _tokenID) public payable{
        require(address(0) != MarketHeroAnimal(marketHeroAnimalContract).ownerOf(_tokenID),"Doesn't exist");
        require(heroOrders[_tokenID] > 0,"Not for sale");
        require(msg.value >= heroOrders[_tokenID],"Not enought money");
        address oldOwner = MarketHeroAnimal(marketHeroAnimalContract).ownerOf(_tokenID);
        MarketHeroAnimal(marketHeroAnimalContract).safeTransferFrom(MarketHeroAnimal(marketHeroAnimalContract).ownerOf(_tokenID),msg.sender,_tokenID);
        delete heroOrders[_tokenID];

        (bool success, ) = oldOwner.call{value:msg.value}("");
        require(success);
        emit HeroSold(oldOwner, msg.sender, _tokenID, msg.value);
    }


    function getHeroOrders(uint256 _from,uint256 _to) public view returns(HeroOrder [] memory){
        uint256 count;
        for (uint256 i =_from; i<=_to; i++ ){
            if (heroOrders[i] != 0){
                count++;
            }
        }
        HeroOrder[] memory result = new HeroOrder[](count);
        uint256 counter = 0;
        for (uint256 i =_from; i<=_to; i++ ){
            if (heroOrders[i] != 0){

                HeroOrder memory order = HeroOrder(
                i,
                heroOrders[i]
            );
                result[counter++] = order;
            }
        }
        return result;
    }


    function updateTraits(uint256 _tokenID,uint8 _speed, uint8 _lifesteal, uint8 _endurence, uint8 _fund) public {
        for (uint256 i =0; i<_speed; i++ ){
            upgradeSpecificTrait(_tokenID,0);
        }
        for (uint256 i =0; i<_lifesteal; i++ ){
            upgradeSpecificTrait(_tokenID,1);
        }
        for (uint256 i =0; i<_endurence; i++ ){
            upgradeSpecificTrait(_tokenID,2);
        }
        for (uint256 i =0; i<_fund; i++ ){
            upgradeSpecificTrait(_tokenID,3);
        }
    }
    /**
     * @notice Function Upgrades parameters of hero
     * @param _tokenID ID of HEro
     * @param _trait characteristic to upgrade
      */
    function upgradeSpecificTrait(uint256 _tokenID, uint8 _trait) public {
        // require((_msgSender()== ),"");
        uint8 _traitLevel = 0;
        uint8 _heroMaxLevel;
        (
            uint8 _animalType,
            uint8 _speed,
            uint8 _lifesteal,
            uint8 _endurence,
            uint8 _fund,
            uint8 _level
        ) = MarketHeroAnimal(marketHeroAnimalContract).getHeroParameters(_tokenID);
        
        if (_animalType == 0){ //Case when type of animal is Hamster
            _heroMaxLevel = 10;
        } else if ((_animalType == 1)||(_animalType == 2)){ 
            // Case when type of animal is Bull or Bear
            _heroMaxLevel = 15;
        } else if (_animalType == 3){
            // Case when type of animal is Whale
            _heroMaxLevel = 20;
        }
        require(_level<_heroMaxLevel, "MarketHeroShop: Hero is MAX level");
        // Calculating level of trait
        // Speed
        if (_trait==0){
            _traitLevel = _speed;
        } else
        // lifesteal
        if (_trait==1){
            _traitLevel = _lifesteal;
        } else
        // Endurence
        if (_trait==2){
            _traitLevel = _endurence;
        } else
        // Fund
        if (_trait==3){
            _traitLevel = _fund;
        } 

        require (((_traitLevel>=0)&&(_traitLevel<10)),"MarketHeroShop: level is not in boundaries");
        require ((IERC20Upgradeable(tokenMHT).balanceOf(msg.sender)>=(heroSkillUpgradePrices[_animalType].level1Price + (_level)* heroSkillUpgradePrices[_animalType].interval)),"not enough money for upgrade this trait");
        IERC20Upgradeable(tokenMHT).safeTransferFrom(msg.sender, address(this),(heroSkillUpgradePrices[_animalType].level1Price + (_level)*heroSkillUpgradePrices[_animalType].interval));
        // Upgrading trait
        // Speed
        if (_trait==0){
            MarketHeroAnimal(marketHeroAnimalContract).renewHeroParameters(
                _tokenID,
                _animalType,
                _speed += 1,
                _lifesteal,
                _endurence,
                _fund,
                _level +=1
            );
        } else
        // lifesteal 
        if (_trait==1){
            MarketHeroAnimal(marketHeroAnimalContract).renewHeroParameters(
                _tokenID,
                _animalType,
                _speed,
                _lifesteal += 1,
                _endurence,
                _fund,
                _level +=1
            );
        } else
        // Endurence
        if (_trait==2){
            MarketHeroAnimal(marketHeroAnimalContract).renewHeroParameters(
                _tokenID,
                _animalType,
                _speed,
                _lifesteal,
                _endurence += 1,
                _fund,
                _level +=1
            );
        } else
        // Fund
        if (_trait==3){
            MarketHeroAnimal(marketHeroAnimalContract).renewHeroParameters(
                _tokenID,
                _animalType,
                _speed,
                _lifesteal,
                _endurence,
                _fund += 1,
                _level +=1
            );
        } 
        
    }

}