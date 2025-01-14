/**
 *Submitted for verification at BscScan.com on 2022-10-07
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

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: contracts/Farm.sol


pragma solidity ^0.8.2;





interface MintableToken is IERC20 {
    function mint(address _to, uint256 _amount) external;
}

contract KETFarming is AccessControl, ReentrancyGuard {
    using SafeMath for uint256;
    bytes32 public constant MEMBER = keccak256("MEMBER");
    MintableToken public ketToken;
    IERC20 public pancakePair;
    address public owner;
    address public devAddress;
    uint256 public flexibleRate = 5;
    uint256 public locked6Rate = 10;
    uint256 public lockedRate = 15;
    uint256 public lockedTime = 360 * 24 * 60 * 60;
    uint256 public locked6Time = 180 * 24 * 60 * 60;
    uint256 public minActive = 100 * 1e18;
    uint256 public minClaim = 10 * 1e18;
    uint256 public fee = 0;
    uint256 public devFee = 2;
    uint256[6] public matchingInterest = [50, 40, 20, 10, 10, 10];
    uint256[6] public activeCondition = [
        500 * 1e18,
        1000 * 1e18,
        3000 * 1e18,
        10000 * 1e18,
        30000 * 1e18,
        50000 * 1e18
    ];
    struct LockedPackage {
        uint256 amount;
        uint256 timestamp;
    }
    struct TeamPacakge {
        uint256 flexible;
        uint256 locked;
        uint256 locked6;
        bool active;
    }
    struct User {
        address sponsor;
        uint256 flexible;
        uint256 flexibleKET;
        uint256 locked;
        uint256 lockedKET;
        uint256 locked6;
        uint256 locked6KET;
        uint256 lastUpdate;
        uint256 totalInterest;
        uint256 claimedLockPackage;
        uint256 claimedLock6Package;
        TeamPacakge[6] teamPacakge;
        LockedPackage[] lockedPackage;
        LockedPackage[] locked6Package;
    }
    mapping(address => User) public users;

    constructor(
        address _ketToken,
        address _pancakePair,
        address _devAddress
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MEMBER, msg.sender);
        ketToken = MintableToken(_ketToken);
        pancakePair = IERC20(_pancakePair);
        owner = msg.sender;
        devAddress = _devAddress;
    }

    function deposit(
        uint256 _amountLP,
        uint256 _type,
        address _sponsor
    ) public nonReentrant {
        pancakePair.transferFrom(msg.sender, address(this), _amountLP);
        uint256 _amountKET = getLPToKet(_amountLP);
        User storage user = users[msg.sender];
        if (user.sponsor == address(0x0) && msg.sender != owner) {
            require(
                users[_sponsor].sponsor != address(0x0) || _sponsor == owner,
                "Sponsor must valid"
            );
            user.sponsor = _sponsor;
        }
        user.totalInterest = getInterest(msg.sender);
        user.lastUpdate = block.timestamp;
        if (_type == 0) {
            user.flexible = user.flexible.add(_amountLP);
            user.flexibleKET = user.flexibleKET.add(_amountKET);
        } else if(_type == 1){
            user.locked = user.locked.add(_amountLP);
            user.lockedKET = user.lockedKET.add(_amountKET);
            user.lockedPackage.push(LockedPackage(_amountLP, block.timestamp));
        } else {
            user.locked6 = user.locked6.add(_amountLP);
            user.locked6KET = user.locked6KET.add(_amountKET);
            user.locked6Package.push(LockedPackage(_amountLP, block.timestamp));
        }

        address currentSponsor = user.sponsor;
        for (uint256 i = 0; i < 6; i++) {
            if (currentSponsor == address(0x0)) break;
            users[currentSponsor].totalInterest = getInterest(currentSponsor);
            users[currentSponsor].lastUpdate = block.timestamp;
            if (_type == 0) {
                users[currentSponsor].teamPacakge[i].flexible = users[
                    currentSponsor
                ].teamPacakge[i].flexible.add(_amountKET);
            } else if(_type == 1){
                users[currentSponsor].teamPacakge[i].locked = users[
                    currentSponsor
                ].teamPacakge[i].locked.add(_amountKET);
            } else {
                users[currentSponsor].teamPacakge[i].locked6 = users[
                    currentSponsor
                ].teamPacakge[i].locked6.add(_amountKET);
            }
            if (i == 0) {
                activeTeamPackage(currentSponsor);
            }
            currentSponsor = users[currentSponsor].sponsor;
        }
    }

    function withdraw(uint256 _amountLP, uint256 _type) public nonReentrant {
        uint256 claimable = getInterest(msg.sender);
        require(claimable >= minClaim, "Claimable < min claim");
        uint256 devFeeAmount = (claimable * devFee) / 100;
        ketToken.mint(devAddress, devFeeAmount);
        ketToken.mint(msg.sender, claimable.mul(100 - fee).div(100));
        User storage user = users[msg.sender];
        user.lastUpdate = block.timestamp;
        user.totalInterest = 0;
        if (_type == 1) {
            uint256 claimAmount = 0;
            uint256 i = user.claimedLockPackage;
            for (; i < user.lockedPackage.length; i++) {
                if (
                    user.lockedPackage[i].timestamp + lockedTime <=
                    block.timestamp
                ) {
                    claimAmount = claimAmount.add(user.lockedPackage[i].amount);
                    user.claimedLockPackage = i + 1;
                } else {
                    break;
                }
            }
            if (claimAmount > 0) {
                uint256 _amountKET = claimAmount.mul(user.lockedKET).div(
                    user.locked
                );
                user.locked = user.locked.sub(claimAmount);
                user.lockedKET = user.lockedKET.sub(_amountKET);
                address currentSponsor = user.sponsor;
                for (uint256 j = 0; j < 6; j++) {
                    if (currentSponsor == address(0x0)) break;
                    users[currentSponsor].totalInterest = getInterest(
                        currentSponsor
                    );
                    users[currentSponsor].lastUpdate = block.timestamp;
                    users[currentSponsor].teamPacakge[j].locked = users[
                        currentSponsor
                    ].teamPacakge[j].locked.sub(_amountKET);
                    if (i == 0) {
                        activeTeamPackage(currentSponsor);
                    }
                    currentSponsor = users[currentSponsor].sponsor;
                }
                pancakePair.transfer(msg.sender, claimAmount);
            }
        } else if (_type == 2){
            uint256 claimAmount = 0;
            uint256 i = user.claimedLock6Package;
            for (; i < user.locked6Package.length; i++) {
                if (
                    user.locked6Package[i].timestamp + locked6Time <=
                    block.timestamp
                ) {
                    claimAmount = claimAmount.add(user.locked6Package[i].amount);
                    user.claimedLock6Package = i + 1;
                } else {
                    break;
                }
            }
            if (claimAmount > 0) {
                uint256 _amountKET = claimAmount.mul(user.locked6KET).div(
                    user.locked6
                );
                user.locked6 = user.locked6.sub(claimAmount);
                user.locked6KET = user.locked6KET.sub(_amountKET);
                address currentSponsor = user.sponsor;
                for (uint256 j = 0; j < 6; j++) {
                    if (currentSponsor == address(0x0)) break;
                    users[currentSponsor].totalInterest = getInterest(
                        currentSponsor
                    );
                    users[currentSponsor].lastUpdate = block.timestamp;
                    users[currentSponsor].teamPacakge[j].locked6 = users[
                        currentSponsor
                    ].teamPacakge[j].locked6.sub(_amountKET);
                    if (i == 0) {
                        activeTeamPackage(currentSponsor);
                    }
                    currentSponsor = users[currentSponsor].sponsor;
                }
                pancakePair.transfer(msg.sender, claimAmount);
            }
        } else{
            if (_amountLP > 0) {
                require(_amountLP <= user.flexible, "Wrong amount");
                uint256 _amountKET = _amountLP.mul(user.flexibleKET).div(
                    user.flexible
                );
                user.flexible = user.flexible.sub(_amountLP);
                user.flexibleKET = user.flexibleKET.sub(_amountKET);
                address currentSponsor = user.sponsor;
                for (uint256 i = 0; i < 6; i++) {
                    if (currentSponsor == address(0x0)) break;
                    users[currentSponsor].totalInterest = getInterest(
                        currentSponsor
                    );
                    users[currentSponsor].lastUpdate = block.timestamp;
                    users[currentSponsor].teamPacakge[i].flexible = users[
                        currentSponsor
                    ].teamPacakge[i].flexible.sub(_amountKET);
                    if (i == 0) {
                        activeTeamPackage(currentSponsor);
                    }
                    currentSponsor = users[currentSponsor].sponsor;
                }
                pancakePair.transfer(msg.sender, _amountLP);
            }
        }
    }

    function activeTeamPackage(address _user) internal {
        User storage user = users[_user];
        uint256 userF1 = user.teamPacakge[0].flexible.add(
            user.teamPacakge[0].locked
        ).add(
            user.teamPacakge[0].locked6
        );
        for (uint256 i = 0; i < 6; i++) {
            bool activePackage = userF1 >= activeCondition[i];
            if (activePackage != user.teamPacakge[i].active) {
                user.teamPacakge[i].active = activePackage;
            }
        }
    }

    function getLPToKet(uint256 _amount) public view returns (uint256) {
        return
            ketToken.balanceOf(address(pancakePair)).mul(_amount).mul(2).div(
                pancakePair.totalSupply()
            );
    }

    function getInterestPerDay(address _user) public view returns (uint256) {
        User memory user = users[_user];
        uint256 current = 0;
        uint256 times = 24 * 60 * 60;
        if (user.lastUpdate == 0) return current;
        current = current.add(
            times
                .mul(
                    (user.flexibleKET.mul(flexibleRate)).add(
                        user.lockedKET.mul(lockedRate)
                    ).add(
                        user.locked6KET.mul(locked6Rate)
                    )
                )
                .div(259200000)
        );
        if (totalPackage(_user) < minActive) return current;
        for (uint256 i = 0; i < 6; i++) {
            if (!user.teamPacakge[i].active) break;
            current = current.add(
                times
                    .mul(matchingInterest[i])
                    .mul(
                        (user.teamPacakge[i].flexible.mul(flexibleRate)).add(
                            user.teamPacakge[i].locked.mul(lockedRate)
                        ).add(
                            user.teamPacakge[i].locked6.mul(locked6Rate)
                        )
                    )
                    .div(25920000000)
            );
        }
        return current;
    }

    function getInterest(address _user) public view returns (uint256) {
        User memory user = users[_user];
        uint256 current = user.totalInterest;
        uint256 times = block.timestamp.sub(user.lastUpdate);
        if (user.lastUpdate == 0) return current;
        current = current.add(
            times
                .mul(
                    (user.flexibleKET.mul(flexibleRate)).add(
                        user.lockedKET.mul(lockedRate)
                    ).add(
                        user.locked6KET.mul(locked6Rate)
                    )
                )
                .div(259200000)
        );
        if (totalPackage(_user) < minActive) return current;
        for (uint256 i = 0; i < 6; i++) {
            if (!user.teamPacakge[i].active) break;
            current = current.add(
                times
                    .mul(matchingInterest[i])
                    .mul(
                        (user.teamPacakge[i].flexible.mul(flexibleRate)).add(
                            user.teamPacakge[i].locked.mul(lockedRate)
                        ).add(
                            user.teamPacakge[i].locked6.mul(locked6Rate)
                        )
                    )
                    .div(25920000000)
            );
        }
        return current;
    }


    function getAvaiableLockedClaim(address _user)
        public
        view
        returns (uint256 claimAmount)
    {
        User memory user = users[_user];
        for (
            uint256 i = user.claimedLockPackage;
            i < user.lockedPackage.length;
            i++
        ) {
            if (
                user.lockedPackage[i].timestamp + lockedTime <= block.timestamp
            ) {
                claimAmount = claimAmount.add(user.lockedPackage[i].amount);
            } else {
                break;
            }
        }
    }

    function getAvaiableLocked6Claim(address _user)
        public
        view
        returns (uint256 claimAmount)
    {
        User memory user = users[_user];
        for (
            uint256 i = user.claimedLock6Package;
            i < user.locked6Package.length;
            i++
        ) {
            if (
                user.locked6Package[i].timestamp + lockedTime <= block.timestamp
            ) {
                claimAmount = claimAmount.add(user.locked6Package[i].amount);
            } else {
                break;
            }
        }
    }

    function getLocked6Package(address _user)
        public
        view
        returns (LockedPackage[] memory)
    {
        User memory user = users[_user];
        return user.locked6Package;
    }

    function getLockedPackage(address _user)
        public
        view
        returns (LockedPackage[] memory)
    {
        User memory user = users[_user];
        return user.lockedPackage;
    }

    function getLockedPackageByIndex(address _user, uint256 _index)
        public
        view
        returns (LockedPackage memory)
    {
        User memory user = users[_user];
        return user.lockedPackage[_index];
    }

    function getLocked6PackageByIndex(address _user, uint256 _index)
        public
        view
        returns (LockedPackage memory)
    {
        User memory user = users[_user];
        return user.locked6Package[_index];
    }

    function getTeamPackage(address _user)
        public
        view
        returns (TeamPacakge[6] memory)
    {
        User memory user = users[_user];
        return user.teamPacakge;
    }

    function getSponsor(address _user) public view returns (address) {
        User memory user = users[_user];
        return user.sponsor;
    }

    function getTeam(address _user)
        public
        view
        returns (address[6] memory team)
    {
        address currentSponsor = users[_user].sponsor;
        for (uint256 i = 0; i < 6; i++) {
            if (currentSponsor == address(0x0)) break;
            team[i] = currentSponsor;
            currentSponsor = users[currentSponsor].sponsor;
        }
    }

    function setSponsor(address _user, address _sponsor)
        public
        onlyRole(MEMBER)
        returns (bool)
    {
        User storage user = users[_user];
        if (user.sponsor == address(0x0) && _user != owner) {
            require(
                users[_sponsor].sponsor != address(0x0) || _sponsor == owner,
                "Sponsor must valid"
            );
            user.sponsor = _sponsor;
            return true;
        } else {
            return false;
        }
    }

    function totalPackage(address _user) public view returns (uint256) {
        User memory user = users[_user];
        return user.flexibleKET.add(user.lockedKET).add(user.locked6KET);
    }

    function editFee(uint256 _newFee) public {
        require(msg.sender == owner, "Must be owner");
        require(_newFee <= 5, "Fee should not exceed 5%");
        fee = _newFee;
    }
}