/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// File: contracts/core/random/Random.sol


pragma solidity ^0.8.0;

library Random {
    
    /**
     * @dev Create a random number.
     */
    function createRandom(uint256 min, uint256 max, uint256 seed) internal pure returns (uint8)
    { 
         // inclusive,inclusive (don't use absolute min and max values of uint256)
        // deterministic based on seed provided
        uint diff = max - min + 1;
        uint randomVar = uint(keccak256(abi.encodePacked(seed))) % diff;
        randomVar = randomVar + min;
        return uint8(randomVar);
    }

    /**
     * @dev Create a random number.
     */
    function createRandom(uint256 min, uint256 max, uint256 seed1, uint256 seed2) internal pure returns (uint8)
    { 
        return createRandom(min, max, combineSeeds(seed1, seed2));
    }

    /**
     * @dev combine and refresh seed.
     */
    function combineSeeds(uint seed1, uint seed2) internal pure returns (uint) {
        return uint(keccak256(abi.encodePacked(seed1, seed2)));
    }

    function combineSeeds(uint[] memory seeds) internal pure returns (uint) {
        return uint(keccak256(abi.encodePacked(seeds)));
    }
}

// File: contracts/lib/StringsUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

// File: contracts/core/access/IAccessControlUpgradeable.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol



pragma solidity ^0.8.0;

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

// File: contracts/lib/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: contracts/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// File: contracts/lib/ContextUpgradeable.sol


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

// File: contracts/erc/erc165/IERC165Upgradeable.sol


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

// File: contracts/erc/erc165/ERC165Upgradeable.sol


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

// File: contracts/core/access/AccessControlUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

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
                        StringsUpgradeable.toHexString(uint160(account), 20),
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
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
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
// File: contracts/erc/erc1155/IERC1155ReceiverUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
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

// File: contracts/erc/erc1155/IERC1155Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
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

// File: contracts/erc/erc1155/IERC1155MetadataURIUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// File: contracts/erc/erc1155/ERC1155Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
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
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// File: contracts/core/interface/ISandwichesERC1155.sol



pragma solidity ^0.8.0;

/**
 * @dev 
 */
interface ISandwichesERC1155 {

    /**
     * @dev Create new sandwich heroes by ingredients, tablecloths, and equipments.
     *
     * The length of ingredient Tokens required for merging must be 4,
     * The length of equipment Tokens required for merging must be greater than 3 and less than 4.
     *
     * CHI coins must be paid as a handling fee when merging, 
     * and CHI coins will be equally distributed to the holders of the tablecloth shares.
     */
    function merge(
        uint256 chiAmount,
        uint256[] memory ingredients,
        uint256[] memory equipments, 
        uint128 tableclothType,
        string memory _name,
        string memory _describe
    ) external;


    /**
     *  @dev Get sandwich details by token id.
     */
    function getSandwich(uint256 _id) external view returns (
        uint id,
        string memory name,
        string memory describe,
        uint256 aggressivity,
        uint256 defensive,
        uint256 healthPoint,
        bool[5] memory attributes,
        uint256 created,
        uint16 attrnum
    );

    /**
     *  @dev Get sandwich parts by token id.
     */
    function getSandwichParts(uint256 _id) external view returns (
        uint256[] memory ingredients,
        uint256[] memory equipments
    );

}
// File: contracts/core/interface/ITableclothAwardsPool.sol



pragma solidity ^0.8.0;

/**
 * @dev This is the interface about acclocation of chitoken to tablecloth holders
 */
interface ITableclothAwardsPool {

    event AddAwards(uint128 indexed awardsType, uint128 indexed tableclothType, uint256 chiAmount);
    event Withdraw(uint256 indexed tableclothId, address indexed to, uint256 chiAmount);

    function AWARDS_TYPE_BATTLE() external view returns(uint128);
    function AWARDS_TYPE_MERGE() external view returns(uint128);

    /**
     * @dev Add awards in pool.
     * only permit sandwith or qualifying role
     */
    function addAwards(
        address sender,
        uint128 awardsType,
        uint128 tableclothType,
        uint256 chiAmount
    ) external;

    /**
     * @dev Add awards in pool.
     * only permit sandwith or qualifying role
     */
    function addAwards(
        address sender,
        uint128 awardsType,
        uint128[] memory tableclothTypes,
        uint256 chiAmount
    ) external;

    /**
     * @dev Get the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you get
     */
    function getUnaccalimedAmount(uint256 tableclothId) external view returns(uint256);

    function getUnaccalimedAmountByType(uint128 tableclothType) external view returns(uint256 amounts);

    /**
     * @dev Get the pool's historical total awards amount in pool.
     */
    function getPoolTotalAmount(uint128 tableclothType) external view returns(uint256);


    /**
     * @dev Withdraw the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you withdraw
     */
    function withdraw(uint256 tableclothId) external;

    /**
     * @dev Withdraw the token's unaccalimed awards amount in pool.
     * only amount in pool of tokentype can you withdraw
     * This funtion will withdraw all awards of table cloth you hold which typeid = tableclothType
     */
    function withdrawByType(uint128 tableclothType) external;

}
// File: contracts/core/interface/ITableclothERC1155.sol


pragma solidity ^0.8.0;

interface ITableclothERC1155 {

    /**
     * @dev Return details of Tablecloth 
     *
     * Requirements:
     * - tokenId
     */
    function getTablecloth(uint256 _id) external view returns (
        uint id,
        uint256 maximum,
        uint256 soldQuantity,
        uint256 price,
        bool[5] memory _attr,
        uint128 created,
        uint128 typeId,
        string memory tableclothName,
        string memory tableclothDescribe
    );

    /**
     * @dev Return tablecloth type of token 
     *
     * Requirements:
     * - tokenId
     */
    function getTableclothType(uint256 _id) external view returns(uint128);


    /**
     *  @dev Get tablecloth type details by type id
     */
    function getTypeDetails(uint128 typeId) external view returns (
        string memory tableclothName,
        string memory tableclothDescribe,
        uint256 tableclothPrice,
        uint256 maximum,
        uint256 soldQuantity,
        bool[5] memory attr,
        uint16 attrnum,
        uint256 totalAwards
    );

    /**
     * @dev Get the enemy of attributes
     *
     * Requirements:
     * - attr >= 1 and <= 5
     */
    function getAttributesEnemy(uint16 attr) external view returns(uint16);

    /**
     * @dev Get the token id list of holder
     *
     */
    function getHoldArray(uint128 typeId, address holder) external view returns(uint256[] memory);
}

// File: contracts/core/interface/IEquipmentERC1155.sol


pragma solidity ^0.8.0;

interface IEquipmentERC1155 {
    function createEquipment(address recipient, uint256 boxId, uint8 childType, string memory _name, string memory _describe, uint256 seed) external;

    function getEquipment(uint256 _id) external view returns (
        uint256 id,
        uint32[3] memory adh,
        uint64 created,
        string memory equipmentName,
        string memory equipmentDescribe,
        uint8 childType,
        bool used
    );

    function useEquipment(uint256 id) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);
}
// File: contracts/core/interface/IIngredientERC1155.sol


pragma solidity ^0.8.0;

interface IIngredientERC1155 {
    function createIngredient(address recipient, uint256 boxId, uint8 childType, string memory _name, string memory _describe, uint256 seed) external;

    function getIngredient(uint256 _id) external view returns (
        uint256 id,
        uint32[3] memory attr,
        uint64 created,
        string memory ingredientName,
        string memory ingredientDescribe,
        uint8 childType,
        bool used
    );

    function useIngredients(uint256 id) external;

    function balanceOf(address account, uint256 id) external view returns (uint256);
}

// File: contracts/core/interface/IERC20Token.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Token {
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
// File: contracts/core/TableclothERC1155.sol


pragma solidity ^0.8.0;






contract TableclothERC1155 is ERC1155Upgradeable, AccessControlUpgradeable, ITableclothERC1155 {

    uint256 private idIndex;

    bytes32 public constant TYPE_MANAGER_ROLE = keccak256("TYPE_MANAGER_ROLE");

    struct TableclothType {
        string tableclothName;
        string tableclothDescribe;
        uint256 tableclothPrice;
        uint256 maximum;
        uint256 soldQuantity;
        bool[5] attr;
        uint16 attrnum;
    }

    struct Tablecloth {
        uint128 typeId;
        uint128 created;
    }

    struct HoldInfo{
        uint256 number;
        uint256[] tokenIds;
    }
    
    mapping(uint128 => TableclothType) public types;

    mapping(uint256 => Tablecloth) public tokenTypeMapping;
    

    // This is an array on behalf of [Gold, Wood, Water, Fire, Earth] attributes
    uint16[5] private attributes;
    // This is an array on behalf of attributes' enemy [Fire, Gold, Earth, Water, Wood]
    uint16[5] private attributesEnemy;

    IERC20Token public cswCoin;
    ITableclothAwardsPool public tableclothAwardsPool;

    event TableclothPurchase(uint256 indexed id, address indexed owner, uint128 created);

    event ConfigTableclothType(uint256 indexed id, uint256 price, uint256 maximum);

    // The max holds of each type for an address.
    uint256 public maxHolds;
    // This mapping will record user tokens of every tablecloth type
    mapping(uint128 => mapping(address => HoldInfo)) private userHolds;


    /**
     * @dev Initialization constructor related parameters
     *
     * Requirements:
     * - `_attr` set gold, wood, water, fire and earth, five attributes values
     */
    function initialize(address cswAddress) initializer public {
        __ERC1155_init("https://cryptosandwiches.com/api/metadata/tablecloths/");
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        attributes = [1, 2, 3, 4, 5];
        attributesEnemy = [4, 1, 5, 3, 2];
        cswCoin = IERC20Token(cswAddress);
        maxHolds = 10;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function setTableclothAwardsPool(address _address) onlyRole(DEFAULT_ADMIN_ROLE) external{
        tableclothAwardsPool = ITableclothAwardsPool(_address);
    }

    function setMaxHolds(uint256 _maxHolds) onlyRole(DEFAULT_ADMIN_ROLE) external{
        maxHolds = _maxHolds;
    }

    /**
     * @dev Get the enemy of attributes
     *
     * Requirements:
     * - attr >= 1 and <= 5
     */
    function getAttributesEnemy(uint16 attr) public view override returns(uint16){
        return attributesEnemy[attr - 1];
    }

    function configTableclothType(
        uint128 id,
        string memory _name,
        string memory _describe,
        uint256 tableclothPrice,
        bool[5] memory _attr,
        uint256 _maximum
    ) onlyRole(TYPE_MANAGER_ROLE) external {
        require(id != 0, "Zero type id didn't support");
        types[id].tableclothName = _name;
        types[id].tableclothDescribe = _describe;
        types[id].tableclothPrice = tableclothPrice;
        types[id].attr = _attr;
        for(uint i = 0; i < 5; i++){
            if(_attr[i]){
                types[id].attrnum = attributes[i];
                break;
            }
        }
        types[id].maximum = _maximum;
        emit ConfigTableclothType(id, tableclothPrice, _maximum );
    }

    
     /**
     *  @dev Buy a tablecloth
     *
     *  Emits a {tableclothPurchase} event.
     */
    function buyTablecloth(
        uint256 cswAmount,
        uint128 typeId
    )  external {
        require(types[typeId].tableclothPrice == cswAmount, "CSW value sent is not correct");
        require(types[typeId].soldQuantity + 1 <= types[typeId].maximum, "Quantity sold exceeds limit");
        nextTableclothId();

        _addHold(typeId, _msgSender(), idIndex);
        
        cswCoin.transferFrom(_msgSender(), address(this), cswAmount);

        _mint(_msgSender(), idIndex, 1, "");
        tokenTypeMapping[idIndex].typeId = typeId;
        tokenTypeMapping[idIndex].created = uint128(block.timestamp);
        emit TableclothPurchase(idIndex, _msgSender(), tokenTypeMapping[idIndex].created);

        types[typeId].soldQuantity ++;
    }


    /**
     * @dev Get the token id list of holder
     *
     */
    function getHoldArray(uint128 typeId, address holder) external view override returns(uint256[] memory ids){
        return userHolds[typeId][holder].tokenIds;
    }

    function _addHold(uint128 typeId, address holder, uint256 tokenId) internal{
        HoldInfo storage holdInfo = userHolds[typeId][holder];
        require(++holdInfo.number <= maxHolds, "Exceed the purchase quantity limit");
        if(holdInfo.tokenIds.length < maxHolds)
            holdInfo.tokenIds.push(tokenId);
        else
            for(uint i = 0; i < maxHolds; i++){
                if(holdInfo.tokenIds[i] == 0){
                    holdInfo.tokenIds[i] = tokenId;
                    break;
                }
            }
    }

    function _reduceHold(uint128 typeId, address holder, uint256 tokenId) internal{
        HoldInfo storage holdInfo = userHolds[typeId][holder];
        holdInfo.number--;
        for(uint i = 0; i < holdInfo.tokenIds.length; i++)
            if(holdInfo.tokenIds[i] == tokenId){
                holdInfo.tokenIds[i] = 0;
                break;
            }
    }


    /**
     *  @dev Get tablecloth details by token id
     */
    function getTablecloth(uint256 _id) public view override returns (
        uint id,
        uint256 maximum,
        uint256 soldQuantity,
        uint256 price,
        bool[5] memory _attr,
        uint128 created,
        uint128 typeId,
        string memory tableclothName,
        string memory tableclothDescribe
       
    ) {
        typeId = tokenTypeMapping[_id].typeId;
        TableclothType storage tableclothType = types[typeId];
        created = tokenTypeMapping[_id].created;
        _attr = tableclothType.attr;
        maximum = tableclothType.maximum;
        soldQuantity = tableclothType.soldQuantity;
        price = tableclothType.tableclothPrice;
        tableclothName = tableclothType.tableclothName;
        tableclothDescribe = tableclothType.tableclothDescribe;
        id = _id;
    }

    /**
     *  @dev Get tablecloth type by token id
     */
    function getTableclothType(uint256 _id) public view override returns (
        uint128 typeId
    ) {
        typeId = tokenTypeMapping[_id].typeId;
    }

    /**
     *  @dev Get tablecloth type details by type id
     */
    function getTypeDetails(uint128 typeId) public view override returns (
        string memory tableclothName,
        string memory tableclothDescribe,
        uint256 tableclothPrice,
        uint256 maximum,
        uint256 soldQuantity,
        bool[5] memory attr,
        uint16 attrnum,
        uint256 totalAwards
    ) {
        tableclothName = types[typeId].tableclothName;
        tableclothDescribe = types[typeId].tableclothDescribe;
        tableclothPrice = types[typeId].tableclothPrice;
        maximum = types[typeId].maximum;
        soldQuantity = types[typeId].soldQuantity;
        attr = types[typeId].attr;
        attrnum = types[typeId].attrnum;
        totalAwards = tableclothAwardsPool.getPoolTotalAmount(typeId);
    }

    /**
     *  @dev Get tablecloth type sales
     */
    function getTypeSales(uint128 typeId) public view returns (
        uint256 soldQuantity
    ) {
        soldQuantity = types[typeId].soldQuantity;
    }

    function setPrice(uint128 typeId, uint256 price) onlyRole(TYPE_MANAGER_ROLE) external {
        types[typeId].tableclothPrice = price;

        emit ConfigTableclothType(typeId, price, types[typeId].maximum);
    }

    function getPrice(uint128 typeId) external view returns (uint256) {
        return types[typeId].tableclothPrice;
    }

    function name() external pure returns (string memory) {
        return "cryptoSandwichwiches tablecloths"; 
    }

    function symbol() external pure returns (string memory) {
        return "csw tablecloths";
    }

    function nextTableclothId() private {
         idIndex ++;
    }

    /**
     * @dev returns the metadata uri for a given id
     */
    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(_id), StringsUpgradeable.toString(_id)));
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        uint128 typeId = tokenTypeMapping[id].typeId;
        _addHold(typeId, to, id);
        _reduceHold(typeId, from, id);
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        for(uint i = 0; i < ids.length; i++){
            uint128 typeId = tokenTypeMapping[ids[i]].typeId;
            _addHold(typeId, to, ids[i]);
           _reduceHold(typeId, from, ids[i]);
        }
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

}


// File: contracts/core/SandwichesERC1155.sol


pragma solidity ^0.8.0;











contract SandwichesERC1155 is ERC1155Upgradeable,ISandwichesERC1155, AccessControlUpgradeable  {
    using SafeMath for uint256; 

    IERC20Token public chiCoin;
    
    IIngredientERC1155 public ingredientERC1155;
    IEquipmentERC1155 public equipmentERC1155;
    ITableclothERC1155 public tableclothERC1155;
    ITableclothAwardsPool public tableclothAwardsPool;

    uint256 private mergePrice;
    uint256 private totalSandwiches;

    // Mapping from token ID to owner address
    mapping (uint256 => address) public _owners;
    mapping(uint256 => Sandwich) internal sandwiches;

    struct Sandwich {
        uint id;
        string name;
        string describe;
        uint32 aggressivity;
        uint32 defensive;
        uint32 healthPoint;
        bool[5] attributes;
        // The timestamp from the block when this cat came into existence.
        uint64 created;
        uint16 attrnum;
    }

    mapping(address => uint[]) internal userSandwiches;

    struct Part {
        uint256[] ingredients;
        uint256[] equipments;
    }

    mapping(uint256 => Part) internal sandwicheParts;

    event SandwichesCreated(uint256 indexed id, address indexed owner,  uint256 created);

    /**
     * @dev Initialization constructor related parameters
     */
    function initialize(address _ingredientERC1155Address, address _equipmentERC1155Address, address _tableclothERC1155Address, address chiAddress) initializer public {
        __ERC1155_init("https://cryptosandwiches.com/api/metadata/sandwiches/");
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        chiCoin = IERC20Token(chiAddress);
        ingredientERC1155 = IIngredientERC1155(_ingredientERC1155Address);
        equipmentERC1155 = IEquipmentERC1155(_equipmentERC1155Address);
        tableclothERC1155 = ITableclothERC1155(_tableclothERC1155Address);
        mergePrice = 20000000000000000000000; // 20000 CHI
    }

    function setTableclothAwardsPool(address _address) onlyRole(DEFAULT_ADMIN_ROLE) external{
        tableclothAwardsPool = ITableclothAwardsPool(_address);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Create new sandwich heroes by ingredients, tablecloths, and equipments.
     *
     * The length of ingredient Tokens required for merging must be 4,
     * The length of equipment Tokens required for merging must be 3.
     *
     * CHI coins must be paid as a handling fee when merging, 
     * and CHI coins will be equally distributed to the holders of the tablecloth shares.
     */
    function merge(
        uint256 chiAmount,
        uint256[] memory ingredients,
        uint256[] memory equipments, 
        uint128 tableclothType,
        string memory _name,
        string memory _describe
    ) public override{
        require(mergePrice == chiAmount, "CHI value sent is not correct");
        require(
            ingredients.length == 4 && equipments.length == 3,
            "Incorrect number of tokens required for merge"
        );
        require(tableclothType !=0, "Invalid tablecloth type");

        address recipient = _msgSender();
        //@ msgsender need approve(address(tableclothAwardsPool), chiAmount);

        tableclothAwardsPool.addAwards(_msgSender(), tableclothAwardsPool.AWARDS_TYPE_MERGE(), tableclothType, chiAmount);

        verifyOwnerAndType(ingredients, equipments);

        (uint256 _aggressivity, uint256 _defensive,
        uint256 _healthPoint, bool[5] memory _attributes, uint16 attrnum) = 
        calculate(ingredients, equipments, tableclothType);
        
        Sandwich memory _sandwich = Sandwich({
            id: totalSandwiches,
            name: _name,
            describe: _describe,
            aggressivity: uint32(_aggressivity),
            defensive: uint32(_defensive),
            healthPoint: uint32(_healthPoint),
            attributes: _attributes,
            attrnum: attrnum,
            created: uint64(block.timestamp)
        });
        
        sandwiches[totalSandwiches] = _sandwich;
        _mint(recipient, totalSandwiches, 1, "");
        
        emit SandwichesCreated(totalSandwiches, recipient, _sandwich.created);
        usedIngredientsAndEquipments(ingredients, equipments);
        sandwicheParts[totalSandwiches].equipments = equipments;
        sandwicheParts[totalSandwiches].ingredients = ingredients;
        totalSandwiches ++;
    }

    /**
     *  @dev Get sandwich parts by token id.
     */
    function getSandwichParts(uint256 _id) external view override returns (
        uint256[] memory ingredients,
        uint256[] memory equipments
    ){
        ingredients = sandwicheParts[_id].ingredients;
        equipments = sandwicheParts[_id].equipments;
    }

    //TODO test fuction
    function testCreate(uint128 tableclothType, string memory _name,
        string memory _describe) public{
        
        require(tableclothType !=0, "Invalid tablecloth type");

        address recipient = _msgSender();

        tableclothAwardsPool.addAwards(_msgSender(), tableclothAwardsPool.AWARDS_TYPE_MERGE(), tableclothType, 20000 ether);

        (uint256 _aggressivity, uint256 _defensive,
        uint256 _healthPoint, bool[5] memory _attributes, uint16 attrnum) = 
        calculate(tableclothType);
        
        Sandwich memory _sandwich = Sandwich({
            id: totalSandwiches,
            name: _name,
            describe: _describe,
            aggressivity: uint32(_aggressivity),
            defensive: uint32(_defensive),
            healthPoint: uint32(_healthPoint),
            attributes: _attributes,
            attrnum: attrnum,
            created: uint64(block.timestamp)
        });
        
        sandwiches[totalSandwiches] = _sandwich;
        _mint(recipient, totalSandwiches, 1, "");
        
        emit SandwichesCreated(totalSandwiches, recipient, _sandwich.created);
        totalSandwiches ++;
    }

    /**
     * @dev Calculate the attribute value when the sandwich is generated.
     */
    function calculate(uint128 tableclothType) private view returns (
        uint256 aggressivity,
        uint256 defensive,
        uint256 healthPoint,
        bool[5] memory _attributes,
        uint16 attrnum
    )  {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, _msgSender())));
        uint256 f_calories = Random.createRandom(80, 160, seed, 0);
        uint256 f_scent = Random.createRandom(80, 160, seed, f_calories);
        uint256 f_freshness = Random.createRandom(80, 160, seed, f_scent);
        
        uint256 e_aggressivity = Random.createRandom(3, 18, seed, f_freshness);
        uint256 e_defensive = Random.createRandom(3, 18, seed, e_aggressivity);
        uint256 e_healthPoint = Random.createRandom(3, 18, seed, e_defensive);
     
        // A =（C + S）/ 2 + S;
        // D =（C + S）/ 2 + C;
        // H = F;
        // Because Equipment uses 100 as the initial attribute value calculation, 100 is subtracted here
        aggressivity = (f_calories + f_scent) / 2 + f_scent + e_aggressivity - 100;
        defensive = (f_calories + f_scent) / 2 + f_calories + e_defensive - 100;
        healthPoint = f_freshness + e_healthPoint - 100;

        (, , , , , _attributes, attrnum,) = tableclothERC1155.getTypeDetails(tableclothType);
    }

    /**
     *  @dev Get sandwich details by token id.
     */
    function getSandwich(uint256 _id) public view override returns (
        uint id,
        string memory name,
        string memory describe,
        uint256 aggressivity,
        uint256 defensive,
        uint256 healthPoint,
        bool[5] memory attributes,
        uint256 created,
        uint16 attrnum
    ) {
        Sandwich storage sandwich = sandwiches[_id];
        created = uint256(sandwich.created);
        aggressivity = sandwich.aggressivity;
        defensive = sandwich.defensive;
        healthPoint = sandwich.healthPoint;
        name = sandwich.name;
        describe = sandwich.describe;
        attributes = sandwich.attributes;
        attrnum = sandwich.attrnum;
        id = _id;
    }

    /**
     * @dev Calculate the attribute value when the sandwich is generated.
     */
    function calculate( uint256[] memory ingredients, uint256[] memory equipments, uint128 tableclothType) private view returns (
        uint256 aggressivity,
        uint256 defensive,
        uint256 healthPoint,
        bool[5] memory _attributes,
        uint16 attrnum
    )  {
        uint256 f_calories;
        uint256 f_scent;
        uint256 f_freshness;
        (f_calories, f_scent, f_freshness) = getIngredientsAttr(ingredients);
        
        uint256 e_aggressivity;
        uint256 e_defensive;
        uint256 e_healthPoint;
        (e_aggressivity, e_defensive, e_healthPoint) = getEquipmentsAttr(equipments);
     
        // A =（C + S）/ 2 + S;
        // D =（C + S）/ 2 + C;
        // H = F;
        // Because Equipment uses 100 as the initial attribute value calculation, 100 is subtracted here
        aggressivity = (f_calories + f_scent) / 2 + f_scent + e_aggressivity - 100;
        defensive = (f_calories + f_scent) / 2 + f_calories + e_defensive - 100;
        healthPoint = f_freshness + e_healthPoint - 100;

        (, , , , , _attributes, attrnum,) = tableclothERC1155.getTypeDetails(tableclothType);
    }

    /**
     * @dev Call ingredientERC1155 contract for details.
     */
    function getIngredientsAttr(uint256[] memory ingredients) private view returns(
        uint256 f_calories,
        uint256 f_scent,
        uint256 f_freshness
    ){
        for (uint i = 0; i < ingredients.length; i++){
            uint _id;
            uint32[3] memory attr;
            uint256 _time;
            string memory _name;
            string memory _describe;
            uint8 childType;
            bool used;
            
            (_id, attr, _time, _name, _describe, childType, used) = ingredientERC1155.getIngredient(ingredients[i]);
            require(!used, "Token has expired");
            
            f_calories += attr[0];
            f_scent += attr[1];
            f_freshness += attr[2];
        }
    }

    /**
     * @dev Call equipmentERC1155 contract for details.
     */
    function getEquipmentsAttr(uint256[] memory _equipments) private view returns(
        uint256 e_aggressivity,
        uint256 e_defensive,
        uint256 e_healthPoint
    ){
        //The initial value of 100 is used to calculate negative numbers
        e_aggressivity = 100;
        e_defensive = 100;
        e_healthPoint = 100;
        
        for (uint i = 0; i < _equipments.length; i++){
            uint32[3] memory adh;
            uint _id;
            uint256 _time;
            string memory _name;
            string memory _describe;
            uint8 childType;
            bool _used;
            (_id, adh, _time, _name, _describe, childType, _used) = equipmentERC1155.getEquipment(_equipments[i]);
            require(!_used, "Token has expired");

            uint64 v = 3;
            if (adh[0] <= v) {
                e_aggressivity -= adh[0];
            } else {
                e_aggressivity += adh[0] - v;
            }
            if (adh[1] <= v) {
                e_defensive -= adh[1];
            } else {
                e_defensive += adh[1] - v;
            }
            if (adh[2] <= v) {
                e_healthPoint -= adh[2];
            } else {
                e_healthPoint += adh[2] - v;
            }
        }
    }

    /**
     * @dev Verify whether it is the owner of the Token.
     */
    function verifyOwnerAndType(uint256[] memory _ingredients, uint256[] memory _equipments) private view {
        // TODO need to verifying token types in main network
        //bool[7] memory flags;
        for (uint i = 0; i < _ingredients.length; i++){
            require(ingredientERC1155.balanceOf(_msgSender(), _ingredients[i]) > 0,  "Insufficient token balance");
            // (,,,,,uint8 childType,) = ingredientERC1155.getIngredient(_ingredients[i]);
            // // ingredientERC1155 type enums: 1 meat, 2 veg, 3 fruit, 4 sauce
            // flags[childType - 1] = true;
        }
        for (uint i = 0; i < _equipments.length; i++){
            require(equipmentERC1155.balanceOf(_msgSender(), _equipments[i]) > 0,  "Insufficient token balance");
            // (,,,,,uint8 childType,) = equipmentERC1155.getEquipment(_equipments[i]);
            // // equipmentERC1155 type enums: // 11 hat, 12 hand, 13 foot
            // flags[childType - 7] = true;
        }
        // // require 7 type of tokens
        // for (uint i = 0; i < 7; i++){
        //     require(flags[i], "Incorrect type of tokens required for merge");
        // }
        
    }

    /**
     * @dev Call Tablecloth ERC1155 ,equipment ERC1155 contract Modify status.
     */
    function usedIngredientsAndEquipments(uint256[] memory _ingredients, uint256[] memory _equipments) private {
        for(uint i = 0; i < _ingredients.length; i++){ 
            ingredientERC1155.useIngredients(_ingredients[i]); 
        }
        for(uint i = 0; i < _equipments.length; i++){
            equipmentERC1155.useEquipment(_equipments[i]); 
        }
    }

    /**
     * @dev Set the number of CHI Tokens required for merge.
     */
    function setMergePricePrice(uint256 amount) onlyRole(DEFAULT_ADMIN_ROLE) external {
        mergePrice = amount;
    }

    /**
     * @dev Get the number of CHI Tokens required for merge.
     */
    function getMergePrice() external view returns (uint256) {
        return mergePrice;
    }

    function getTotalSandwiches() external view returns (uint256) {
        return totalSandwiches;
    }

    /**
     * @dev returns the metadata uri for a given id
     */
    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(_id), StringsUpgradeable.toString(_id)));
    }
}
// File: contracts/test/UnitTest.sol


pragma solidity ^0.8.0;






contract UnitTest{
    TableclothERC1155 private tablecloth;
    SandwichesERC1155 private sandwich;
    ITableclothAwardsPool private pool;
    IERC20Token private chiCoin;
    IERC20Token private cswToken;

    address public _owner;

    constructor(){
        _owner = msg.sender;
        tablecloth = TableclothERC1155(address(0xdeb3327323FD30d95597aC6e36a233239ACB3AAe));
        sandwich = SandwichesERC1155(address(0x9FF899642b17d443EDF8fFC43835A62669A39841));
        pool = ITableclothAwardsPool(address(0xBA4AC325969F4BC101735C5C1504A5f756Fae1E7));
        chiCoin = IERC20Token(address(0x00f31ceaa87be2123c60396083c583b3ec436ec5ec));
        cswToken = IERC20Token(address(0x000bbdd301bb85000c68f3d3928274d877f10a1c8c));
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setAddress(address _tablecloth, address _sandwich, address _pool, address _chiCoin, address _cswToken) external onlyOwner{
        tablecloth = TableclothERC1155(_tablecloth);
        sandwich = SandwichesERC1155(_sandwich);
        pool = ITableclothAwardsPool(_pool);
        chiCoin = IERC20Token(_chiCoin);
        cswToken = IERC20Token(_cswToken);
    }

    function buyTablecloth(uint128 typeId) external onlyOwner{
        (,,uint256 price,,,,,) = tablecloth.getTypeDetails(typeId);
        if(price > 0){
            cswToken.approve(address(tablecloth), price);
            tablecloth.buyTablecloth(price, typeId);
        }
    }

    function createSandwich(uint128 typeId, string memory _name, string memory _describe) external onlyOwner{
        chiCoin.approve(address(pool), 20000 ether);
        sandwich.testCreate(typeId, _name, _describe);
    }

    function getUnaccalimedAmountByType(uint128 tableclothType) external view returns(uint256 amounts){
        return pool.getUnaccalimedAmountByType(tableclothType);
    }

    function withdrawByType(uint128 tableclothType) external onlyOwner{
        pool.withdrawByType(tableclothType);
     }

    function withdrawChiAndCsw() external onlyOwner{
        cswToken.transfer(msg.sender, cswToken.balanceOf(address(this)));
        chiCoin.transfer(msg.sender, chiCoin.balanceOf(address(this)));
    }

    function withdrawTableCloth(uint256 id) external onlyOwner{
        IERC1155Upgradeable(address(tablecloth)).safeTransferFrom(address(this), msg.sender, id, 1, "");
    }

    function withdrawSandwich(uint256 id) external onlyOwner{
        IERC1155Upgradeable(address(sandwich)).safeTransferFrom(address(this), msg.sender, id, 1, "");
    }

}