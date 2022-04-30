/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
// Version: 1.0.0
pragma solidity 0.8.10;

// Version: 1.0.0

// Version: 1.0.0

// Version: 1.0.0

interface I_With_DAORole{
    /**
     * DAO_ROLE is able to grant and revoke roles. It can be used when the DAO
     * vote to change some contracts of Windmill.
     */
    function DAO_ROLE() external view returns (bytes32);
}// Version: 1.0.0

abstract contract Base{
}





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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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

abstract contract With_DAORole is Base, AccessControl, I_With_DAORole{
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    constructor(){
        _setRoleAdmin(DAO_ROLE, DAO_ROLE);
        _setupRole(DAO_ROLE, msg.sender);
    }
}
// Version: 1.0.0



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

// Version: 1.0.0



interface I_With_FundContract is IAccessControl, I_With_DAORole{
    function setFund(address _fund) external;
}// Version: 1.0.0

interface I_Math{
    struct Fraction{
        uint256 numerator;
        uint256 denominator;
    }
}

/**
 * @notice Windmill_Power is the ERC20 token (PWR) representing
 * a share of the fund in the Windmill_Fund contract.
 *
 * There is a primary market that value PWR in the form of
 * mint and burn by the Windmill_Fund contract.
 * In exchange of depositing or withdrawing BUSD from the fund,
 * PWR token are minted to or burned from the user address.
 * The minting/burning value of PWR only depends on the total supply
 * in BUSD in the fund related to the total supply of PWR.
 * This mean that PWR will gain primary value only via
 * Windmill traders performance
 *
 * Also, as PWR is an ERC20 token, it can be freely traded, so secondary
 * markets can exist.
 */
interface I_Windmill_Power is I_Math, IAccessControl, I_With_DAORole, IERC20, I_With_FundContract{
    /**
     * MINTER_ROLE is able to mint PWR to an address.
     *
     * BURNER_ROLE is able to burn PWR from an address.
     *
     * MOVER_ROLE is able to transfer PWR from an address to another.
     */
    function MINTER_ROLE() external view returns (bytes32);
    function BURNER_ROLE() external view returns (bytes32);
    function MOVER_ROLE() external view returns (bytes32);
    
    /**
     * @notice Allow the Windmill_Fund to mint PWR for an address

     * Windmill_Fund can use this method to buy PWR in exchange of BUSD
     * This do not change the PWR price because there is the corresponding amount of BUSD
     * that have been added to the fund.
     *
     * Windmill_Competition, Windmill_stacking and Windmill_Royalties can alsoo mint PWR
     * for their usage (competition and stacking reward, royalties).
     * These minting will decrease the value of PWR from the Windmill_Fund contract.
     */
    function mintTo(address to, uint256 amount) external;

    /**
     * @notice Allow the Windmill_Fund to burn PWR from an address
     * in exchange of withdrawing BUSD from the fund to the address.

     * When Windmill_Fund use this method, this do not change the PWR price
     * because there is the right amount of BUSD that have been removed
     * from the fund.
     */
    function burnFrom(address from, uint256 amount) external;

    /**
     * @notice Allow the Windmill_Fund to transfert PWR from an address
     * to a trade contract

     * Windmill_Stacking and Windmill_Trade_Manager use this method to lock the PWR from
     * direct withdraw. There is two main reason for this to happen :
     *
     * - PWR are locked from user to Windmill_Trade contract by Windmill_Trade_Manager
     * contract when starting a new trade. The corresponding BUSD from Windmill_Fund are also
     * allocated to the trade. These locked PWR are returned at the end of the trade.
     *
     * - PWR are stacked by the user in Windmill_Stacking. These PWR are returned
     * at the end of the stacking period. Note that returned PWR can be still
     * locked in a trade, that will be returned at the end of trade.
     */
    function transferFromTo(address from, address to, uint256 amount) external;
}// Version: 1.0.0



interface I_With_PWRToken is IAccessControl, I_With_DAORole{
    function setPWRToken(I_Windmill_Power token) external;
}

abstract contract With_PWRToken is Base, AccessControl, With_DAORole, I_With_PWRToken{
    I_Windmill_Power public PWRToken;

    function setPWRToken(I_Windmill_Power token) external onlyRole(DAO_ROLE){
        PWRToken = token;
    }
}// Version: 1.0.0


// Version: 1.0.0



interface I_With_BUSDToken is IAccessControl, I_With_DAORole{
    function setBUSDToken(IERC20 token) external;
}

abstract contract With_BUSDToken is Base, AccessControl, With_DAORole, I_With_BUSDToken{
    IERC20 public BUSDToken;

    function setBUSDToken(IERC20 token) external onlyRole(DAO_ROLE){
        BUSDToken = token;
    }
}// Version: 1.0.0


abstract contract Adressable is Base{
    address payable immutable internal thisAddr;

    constructor(){
        thisAddr = payable(address(this));
    }
}
// Version: 1.0.0



abstract contract Math is Base, I_Math{
    /**
     * @notice Compute the number of digits in an uint256 number.
     *
     * Node that if number = 0, it returns 0.
     */
    function numDigits(uint256 number) internal pure returns (uint8) {
        uint8 digits = 0;
        while (number != 0) {
            number /= 10;
            digits++;
        }
        return digits;
    }
    
    function _min(uint256 a, uint256 b) internal pure returns (uint256){
        return (a<b ? a : b);
    }
}
// Version: 1.0.0


// Version: 1.0.0

// Version: 1.0.0





/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

interface I_With_WBNBToken is IAccessControl, I_With_DAORole{
    function setWBNBToken(IERC20 token) external;
}// Version: 1.0.0



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

interface PancakeRouter is IPancakeRouter01 {
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

interface I_With_PancakeRouter is IAccessControl, I_With_DAORole{
    function setPancakeRouter(PancakeRouter token) external;
}// Version: 1.0.0


interface I_With_UpdaterRole is I_With_DAORole{
    /**
     * UPDATER_ROLE is able to update contracts.
     */
    function UPDATER_ROLE() external view returns (bytes32);
}// Version: 1.0.0


interface I_With_TradeManagerRole is I_With_DAORole{
    /**
     * UPDATER_ROLE is able to update contracts.
     */
    function TRADE_MANAGER_ROLE() external view returns (bytes32);
}// Version: 1.0.0

interface I_Payable{
    receive() external payable;
}
// Version: 1.0.0

// Version: 1.0.0



interface I_With_WithdrawerContract is IAccessControl, I_With_DAORole{
    function setWithdrawer(address _withdrawer) external;
}// Version: 1.0.0



interface I_With_TradeManagerContract is IAccessControl, I_With_DAORole{
    function setTradeManager(address _tradeManager) external;
}// Version: 1.0.0



interface I_With_CompetitionContract is IAccessControl, I_With_DAORole{
    function setCompetition(address _competition) external;
}

interface I_Windmill_Trade_Abstract is I_Math, IAccessControl, I_With_DAORole, I_With_UpdaterRole, I_With_TradeManagerRole,
									   I_With_BUSDToken, I_With_FundContract, I_With_TradeManagerContract, I_With_WithdrawerContract, I_With_CompetitionContract{
	
	event Action(uint256 id, uint256 timestamp, uint256 data0, uint256 data1, address dataAddr0, address dataAddr1);
	
	function getTradeProfit() external view returns(Fraction memory);
	
	function initTrade(address _owner, address _manager, address _fund, address _updater, address _withdrawer, address _competition) external;
	
	function setTradeId(uint256 _tradeId) external;
	
	function setMaxStopLoss(Fraction memory _maxStopLoss) external;
	
	function setMaxDuration(uint256 _maxDurationNbBlock) external;
	
	function setInitBUSDBalance(uint256 _initBUSDBalance) external;
	
	function forceEndTrade() external;
	
	function endTrade() external;
	
	function updateNeeded() external view returns (bool);
	
	function endTradeNeeded() external view returns (bool);
	
	function update() external;
	
	function getInitBUSDBalance() external view returns (uint256);
	
	function estimateBUSDBalance() external view returns (uint256);
	
	function getPnL() external view returns (Fraction memory);
}// Version: 1.0.0


interface I_With_TradeRole is I_With_DAORole, I_With_TradeManagerRole{
    function TRADE_ROLE() external view returns (bytes32);
}// Version: 1.0.0



interface I_Terminatable is I_With_DAORole{
    function terminate() external;
    
    function isTerminated() external view returns(bool);
}
// Version: 1.0.0



interface I_With_DAOContract is IAccessControl, I_With_DAORole{
    function setDAO(address _DAO) external;
}

/**
 * @notice Windmill_Fund is the contract that store and manage the BUSD used for
 * Windmill activities.
 *
 * The features of this contract are :
 * - Mint/burn PWR in exchange of depositing/withdrawing BUSD.
 * - Send BUSD to a Windmill_Contract trade.
 */
interface I_Windmill_Fund is I_Math, I_Payable, IAccessControl, I_With_DAORole, I_Terminatable, I_With_UpdaterRole, I_With_TradeManagerRole, I_With_TradeRole,
                             I_With_PWRToken, I_With_BUSDToken, I_With_WBNBToken, I_With_PancakeRouter, I_With_TradeManagerContract, I_With_DAOContract{
        
    event MarketData(uint256 PWRPrice, uint256 PWRSupply);
    
    struct LockData{
        uint256 startBlock;
        Fraction factor;
    }
    
    struct FeeData{
        uint256 startBlock;
        uint256 startDynamicFeesNumerator;
    }
    
    function PWR_TOKEN_ROLE() external view returns (bytes32);
    
    function WITHDRAWER_ROLE() external view returns (bytes32);
    
    function beforePWRTransfer(address from, address to, uint256 amount) external;
    
    function setUpdaterAddress(address addr) external;
    
    function setBaseWithdrawFees(uint256 numerator, uint256 denominator) external;
    
    function setDynamicFeesDurationNbBlocks(uint256 _dynamicFeesDurationNbBlocks) external;
    
    function updateWithdrawFees(uint256 finalBalance, uint256 initBalance) external;
    
    function getWithdrawFees() external view returns(uint256);
    
    function getDataPWRLock(address addr) external view returns (uint256, uint256, uint256, uint256, uint256[2][] memory);

    function removeLockedPWRTokens(address addr, uint256 amountPWR) external;

    function getBNBForGasRefund(uint256 amountBNB) external;

    /**
     * Compute the BUSD hold buy Windmill contracts.
     */
    function getFundBUSD() external view returns (uint256);

    /**
     * Compute the BUSD hold buy Windmill contracts.
     */
    function getAvailableBUSD() external view returns (uint256);
    
    function sendBUSDToTrade(I_Windmill_Trade_Abstract trade, uint256 nbBUSD) external;
    
    /**
     * Compute the PWR total supply.
     */
    function getTotalPWR() external view returns (uint256);

    /**
     * Compute The number of PWR that corresponds to "amountBUSD" BUSD.
     */
    function getPWRAmountFromBUSD(uint256 amountBUSD) external view returns (uint256);

    /**
     * Compute The number of BUSD that corresponds to "amountPWR" PWR.
     */
    function getBUSDAmountFromPWR(uint256 amountPWR) external view returns (uint256);

    /**
     * Allow an address to buy PWR at the contract price for "amountBUSD" BUSD.
     * Node that the address must approve the transfer before calling this function.
     */
    function buyPWR(uint256 amountBUSD) external;

    /**
     * Allow an address to sell "amountPWR" PWR at the contract price for BUSD.
     */
    function sellPWR(uint256 amountPWR) external;
    
    function updatePWRPrice() external;
}

abstract contract With_FundContract is Base, AccessControl, With_DAORole, I_With_FundContract{
    I_Windmill_Fund internal fund;

    function setFund(address _fund) public onlyRole(DAO_ROLE){
        fund = I_Windmill_Fund(payable(_fund));
    }
}// Version: 1.0.0




abstract contract With_TradeManagerRole is Base, AccessControl, With_DAORole, I_With_TradeManagerRole{
    bytes32 public constant TRADE_MANAGER_ROLE = keccak256("TRADE_MANAGER_ROLE");

    constructor(){
        _setRoleAdmin(TRADE_MANAGER_ROLE, DAO_ROLE);
    }
}// Version: 1.0.0




abstract contract With_TradeRole is Base, AccessControl, With_DAORole, With_TradeManagerRole, I_With_TradeRole{
    bytes32 public constant TRADE_ROLE = keccak256("TRADE_ROLE");

    constructor(){
        _setRoleAdmin(TRADE_ROLE, TRADE_MANAGER_ROLE);
    }
}
// Version: 1.0.0




interface I_Windmill_Withdrawer is I_Math, IAccessControl, I_With_DAORole, I_With_TradeManagerRole, I_With_TradeRole,
                                   I_With_PWRToken, I_With_BUSDToken, I_With_FundContract{
    
    event WithdrawUpdate(address indexed addr);
    
    struct WithdrawData{
        uint256 totalPWR;
        mapping(address=>uint256) userPWR;
        uint256 totalBUSD;
        bool claimable;
    }
    
    struct PendingWithdrawData{
        mapping(uint256=>uint256) tradeIdToPendingTradeIdShifted;
        mapping(uint256=>uint256) pendingTrade;
        uint256 pendingTradeLength;
    }
    
    function getNbPWRToWithdraw(uint256 tradeId) external view returns(uint256);
    
    function closeTrade(uint256 tradeId, uint256 transferedBUSD) external;
}

contract Windmill_Withdrawer is Base, Adressable, Math, AccessControl, With_DAORole, With_TradeManagerRole, With_TradeRole,
                                With_PWRToken, With_BUSDToken, With_FundContract, I_Windmill_Withdrawer{
    ////
    ////
    ////
    //////////////// Public variables ////////////////
    mapping(uint256=>WithdrawData) public withdrawData;
    mapping(address=>uint256) public pendingPWRWithdraw;
    mapping(address=>PendingWithdrawData) public pendingWithdrawData;
    
    ////
    ////
    ////
    //////////////// Private variables ////////////////

    ////
    ////
    ////
    //////////////// Constructor & Modifiers ////////////////
    constructor() {
    }

    ////
    ////
    ////
    //////////////// Public functions ////////////////
    function askWithdraw(uint256 nbPWR) external{
        require(nbPWR > 0, "Windmill_Withdrawer: Cannot withdraw 0 PWR");
        
        (, uint256 maxNbLockedPwr,, uint256 maxLockPercentNumerator, uint256[2][] memory lockDatas) = fund.getDataPWRLock(msg.sender);
        
        require(nbPWR <= maxNbLockedPwr, "Windmill_Withdrawer: Not enough locked PWR");
        
        uint256 l = lockDatas.length;
        uint256 remainingPWR = nbPWR;
        PendingWithdrawData storage data = pendingWithdrawData[msg.sender];
        
        for(uint256 i=0; i<l; i++){
            uint256 nbPartPWR = remainingPWR;
            
            if (i < l-1){
                nbPartPWR = (nbPWR * lockDatas[i][0]) / maxLockPercentNumerator;
            }
            
            remainingPWR -= nbPartPWR;
            
            WithdrawData storage d = withdrawData[lockDatas[i][1]];
            
            require(!d.claimable, "Windmill_Withdrawer: Trade already closed");
            
            d.totalPWR += nbPartPWR;
            d.userPWR[msg.sender] += nbPartPWR;
            
            if (data.tradeIdToPendingTradeIdShifted[lockDatas[i][1]] == 0){
                data.pendingTrade[data.pendingTradeLength] = lockDatas[i][1];
                data.pendingTradeLength += 1;
                
                data.tradeIdToPendingTradeIdShifted[lockDatas[i][1]] = data.pendingTradeLength;
            }
        }
        
        pendingPWRWithdraw[msg.sender] += nbPWR;
        fund.removeLockedPWRTokens(msg.sender, nbPWR);
        PWRToken.transferFromTo(msg.sender, thisAddr, nbPWR);
        
        emit WithdrawUpdate(msg.sender);
    }
    
    function getClaimableBUSD(address addr) external view returns(uint256){
        PendingWithdrawData storage pendingData = pendingWithdrawData[addr];
        mapping(uint256=>uint256) storage pendingTrade = pendingData.pendingTrade;
        
        uint256 totalClaimableBUSD;
        
        for(uint256 i=0;i<pendingData.pendingTradeLength; i++){
            WithdrawData storage data = withdrawData[pendingTrade[i]];
            
            if (data.claimable && data.userPWR[addr]>0){
                totalClaimableBUSD += data.totalBUSD * data.userPWR[addr] / data.totalPWR;
            }
        }
        
        return totalClaimableBUSD;
    }
    
    function claimWithdraw() external{
        PendingWithdrawData storage pendingData = pendingWithdrawData[msg.sender];
        mapping(uint256=>uint256) storage pendingTrade = pendingData.pendingTrade;
        
        uint256 totalClaimableBUSD;
        uint256 totalPWRToBurn;
        
        uint256 i = pendingData.pendingTradeLength;
        while (i>0){
            i--;
            
            WithdrawData storage data = withdrawData[pendingTrade[i]];
            
            if (data.claimable && data.userPWR[msg.sender]>0){
                totalPWRToBurn += data.userPWR[msg.sender];
                totalClaimableBUSD += data.totalBUSD * data.userPWR[msg.sender] / data.totalPWR;
                data.userPWR[msg.sender] = 0;
                
                uint256 lastI = pendingData.pendingTradeLength-1;
                pendingData.tradeIdToPendingTradeIdShifted[pendingTrade[i]] = 0;
                if (i != lastI){
                    pendingData.tradeIdToPendingTradeIdShifted[pendingTrade[lastI]] = i+1;
                    pendingTrade[i] = pendingTrade[lastI];
                }
                pendingData.pendingTradeLength -= 1;
            }
        }
        
        require(totalClaimableBUSD>0, "Windmill_Withdrawer: no PWR withdraw to claim");
        
        pendingPWRWithdraw[msg.sender] -= totalPWRToBurn;
        
        BUSDToken.transfer(msg.sender, totalClaimableBUSD);
        
        emit WithdrawUpdate(msg.sender);
    }
    
    function getNbPWRToWithdraw(uint256 tradeId) external view returns(uint256){
        return withdrawData[tradeId].totalPWR;
    }
    
    function closeTrade(uint256 tradeId, uint256 transferedBUSD) external onlyRole(TRADE_ROLE){
        WithdrawData storage data = withdrawData[tradeId];
        data.totalBUSD = transferedBUSD;
        data.claimable = true;
        
        if (data.totalPWR > 0){
            PWRToken.burnFrom(thisAddr, data.totalPWR);
        }
        
        emit WithdrawUpdate(address(0x0));
    }
    
    ////
    ////
    ////
    //////////////// Private functions ////////////////
}