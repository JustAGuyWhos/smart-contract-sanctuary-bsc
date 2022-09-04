/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// Sources flattened with hardhat v2.8.0 https://hardhat.org

// File @openzeppelin/contracts/access/[email protected]

//
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


// File @openzeppelin/contracts/utils/[email protected]

//
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


// File @openzeppelin/contracts/utils/[email protected]

//
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


// File @openzeppelin/contracts/utils/introspection/[email protected]

//
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


// File @openzeppelin/contracts/utils/introspection/[email protected]

//
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


// File @openzeppelin/contracts/access/[email protected]

//
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


// File contracts/IUniswapV2Factory.sol

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// File contracts/IBotProtection.sol

interface IBotProtection {
    function protect(address from, address to, uint256 amount) external;
    function _token0() external returns(address);
}


// File contracts/BPManagerSupportingWLProtectionV1.sol

pragma solidity 0.8.4;



interface IBPContract {
    function manualBlackList(address addressToBlacklist) external;
    function removeFromBlackList(address addressToRemove) external;
    function setBuyCoolDown(uint256 buyCoolDown, bool updateWL) external;
    function setSellCoolDown(uint256 sellCooldown, bool updateWL) external;
    function setMaxBuyAmount (uint256 maxBuyAmount, bool updateWL)  external;
    function setMaxSellAmount(uint256 maxSellAmount, bool updateWL) external;
    function setLpPair(address lpPair) external;
    function excludeFromTransferLimitations(address addressToInclude) external;
    function includedAddressesFromTransferLimitations(address addressToExclude) external;
    function getFastestBuyers() external view returns (address[] memory);
    function isBlacklisted(address sender) external view returns (bool);
    function listingTimestamp() external view returns(uint256);
    function _fastestBuyersTimeframe() external view returns(uint256);
    function _blacklistTimeframe() external view returns(uint256);
    function _maxSellAmount() external view returns(uint256);
    function _maxBuyAmount() external view returns(uint256);
    function _sellCooldown() external view returns(uint256);
    function _buyCooldown() external view returns(uint256);
    function getPair() external view returns(address);
    function setAutoBlacklistCount(uint256 count) external;
    function setMaxFastestBuyers(uint newMaxFastestBuyers) external;
    function getDataAboutInvestor(address who) external view returns(uint256, uint256, bool);
    function setSellCoolDownFastestBuyers(uint256 sellCooldown) external;
    function setBuyCoolDownFastestBuyers(uint256 buyCoolDown) external;
    function setMaxBuyAmountFastestBuyers(uint256 maxBuyAmount)  external;
    function setMaxSellAmountFastestBuyers(uint256 maxSellAmount) external;
    function getBlacklistArray() external view returns(address[] memory);
    function configTier(
        uint256 tierNumber,
        uint256 tierDuration,
        uint256 tierStartTimeFromListing,
        address [] memory whitelist) external;
    function addWLAddressesToTier(
        uint256 tierNumber,
        address [] memory whitelist) external;
    function addAdmin(address admin_) external;
    function removeAdmin(address admin_) external;
    function isAdmin(address who_) external view returns(bool);
    function getTierByAddress(address who_) external view returns(uint256);
    function setFrontRunningEnabledStatus(bool status) external;
    function setListingTimestamp(uint256 timestamp) external;
    function setWLLockedPercentage(uint256 lockedPercentage) external;
    function setWLProtectionEnabled(bool status) external;
    function setWLLimits(
        uint256 tierNumber,
        uint256 sellCooldown_,
        uint256 sellLimit_,
        uint256 buyCooldown_,
        uint256 buyLimit_) external;
    function setTiersDuration(uint256 duration) external;
    function setMarketInitializer(address marketInitializer) external;
}

contract BPManagerSupportingWLProtectionV1 is AccessControl{
    bytes32 public constant BOT_MANAGEMENT_ROLE = keccak256("BOT_MANAGEMENT_ROLE");

    IBPContract _botProtectionContract;

    constructor (IBPContract botProtectionContract, address owner) {
        /* The owner of the contract is the manger he could add more admins */
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(BOT_MANAGEMENT_ROLE, owner);
        _botProtectionContract = botProtectionContract;

    }


    function setLpPair(address lpPair) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setLpPair(lpPair);
    }

    // these senders will not be able to sell
    function manualBlackList(address addressToBlacklist) external onlyRole(BOT_MANAGEMENT_ROLE) {
        _botProtectionContract.manualBlackList(addressToBlacklist);
    }

    function removeFromBlackList(address addressToRemove) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.removeFromBlackList(addressToRemove);
    }

    function setAutoBlacklistCount(uint256 count) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setAutoBlacklistCount(count);
    }

    function setBuyCoolDown(uint256 buyCoolDown, bool updateWL) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setBuyCoolDown(buyCoolDown, updateWL);
    }

    function setSellCoolDown(uint256 sellCooldown, bool updateWL) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setSellCoolDown(sellCooldown, updateWL);
    }

    function setMaxBuyAmount(uint256 maxBuyAmount, bool updateWL) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setMaxBuyAmount(maxBuyAmount, updateWL);

    }

    function setMaxSellAmount(uint256 maxSellAmount, bool updateWL) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setMaxSellAmount(maxSellAmount, updateWL);
    }


    function setLimitsForRegular(uint256 maxSellAmount, uint256 sellCooldown, uint256 maxBuyAmount, uint256 buyCooldown, bool updateWL) public onlyRole(BOT_MANAGEMENT_ROLE){
        setMaxBuyAmount(maxBuyAmount, updateWL);
        setMaxSellAmount(maxSellAmount,updateWL);
        setBuyCoolDown(buyCooldown, updateWL);
        setSellCoolDown(sellCooldown, updateWL);
    }


    function excludeFromTransferLimitations(address addressToExclude) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.excludeFromTransferLimitations(addressToExclude);
    }

    function multiExcludeFromTransferLimitations(address [] memory addressToExclude) public onlyRole(BOT_MANAGEMENT_ROLE){
        for(uint256 i=0; i<addressToExclude.length; i++){
            excludeFromTransferLimitations(addressToExclude[i]);
        }
    }

    function includedAddressesFromTransferLimitations (address addressToRemove) public onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.includedAddressesFromTransferLimitations(addressToRemove);
    }

    function multiBlacklist(address [] memory addressesToBlacklist) public onlyRole(BOT_MANAGEMENT_ROLE){
        for(uint256 i=0; i<addressesToBlacklist.length; i++){
            _botProtectionContract.manualBlackList(addressesToBlacklist[i]);
        }
    }

    function multiRemoveFromBlacklist(address [] memory addressesToBlacklist) public onlyRole(BOT_MANAGEMENT_ROLE){
        for(uint256 i=0; i<addressesToBlacklist.length; i++){
            _botProtectionContract.removeFromBlackList(addressesToBlacklist[i]);
        }
    }

    function getFastestBuyers() public view returns (address[] memory) {
        return _botProtectionContract.getFastestBuyers();
    }

    function getMaxSellAmount() public view returns (uint256){
        return _botProtectionContract._maxSellAmount();
    }

    function getMaxBuyAmount() public view returns (uint256){
        return _botProtectionContract._maxBuyAmount();
    }

    function getSellCooldown() public view returns (uint256){
        return _botProtectionContract._sellCooldown();
    }

    function getBuyCooldown() public view returns (uint256){
        return _botProtectionContract._buyCooldown();
    }

    function isBlacklisted(address addr) public view returns (bool){
        return _botProtectionContract.isBlacklisted(addr);
    }

    function getPair() public view returns(address){
        return _botProtectionContract.getPair();

    }

    function getBlacklistArray() public view returns(address[] memory){
        return _botProtectionContract.getBlacklistArray();
    }

    function configTier(
        uint256 tierNumber,
        uint256 tierDuration,
        uint256 tierStartTimeFromListing,
        address [] memory whitelist)
    external
    onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.configTier(
            tierNumber,
            tierDuration,
            tierStartTimeFromListing,
            whitelist
        );
    }
    function addWLAddressesToTier(
        uint256 tierNumber,
        address [] memory whitelist)
    external
    onlyRole(BOT_MANAGEMENT_ROLE) {
        _botProtectionContract.addWLAddressesToTier(tierNumber, whitelist);
    }


    function addAdmins(address [] memory admins) external onlyRole(BOT_MANAGEMENT_ROLE){
        for(uint256 i=0; i<admins.length; i++){
            _botProtectionContract.addAdmin(admins[i]);
        }
    }

    function removeAdmins(address [] memory admins) external onlyRole(BOT_MANAGEMENT_ROLE){
        for(uint256 i=0; i<admins.length; i++){
            _botProtectionContract.removeAdmin(admins[i]);
        }
    }

    function isAdmin(address who_) public view returns(bool){
        return _botProtectionContract.isAdmin(who_);
    }

    function getTierByAddress(address who_) public view returns(uint256){
        return _botProtectionContract.getTierByAddress(who_);
    }

    function setFrontRunningEnabledStatus(bool status) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setFrontRunningEnabledStatus(status);
    }

    // WL Protection management
    function setWLProtectionEnabled(bool status) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setWLProtectionEnabled(status);
    }

    function setWLLockedPercentage(uint256 lockedPercentage) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setWLLockedPercentage(lockedPercentage);
    }

    function setWLLimits(
        uint256 tierNumber,
        uint256 sellCooldown_,
        uint256 sellLimit_,
        uint256 buyCooldown_,
        uint256 buyLimit_) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setWLLimits(tierNumber, sellCooldown_, sellLimit_, buyCooldown_, buyLimit_);
    }

    function setTiersDuration(uint256 duration) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setTiersDuration(duration);
    }

    function setMarketInitializer(address marketInitializer) external onlyRole(BOT_MANAGEMENT_ROLE){
        _botProtectionContract.setMarketInitializer(marketInitializer);
    }

}