pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";

import './DeployersInterfaces.sol';
import './SimpleERC721.sol';

contract SimpleERC721Deployer is AccessControl, ISimpleERC721Deployer{

    address public creator;
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 internal constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    event CreatorSet(address);

    /*
     * Params
     * address _NFTcreator - address of proxy - NFT-Creator, that will send request for contracts deployment
     */
    constructor(
        address _NFTcreator
    ){
        creator = _NFTcreator;
        _setupRole(CREATOR_ROLE, _NFTcreator);
        _setupRole(OWNER_ROLE, msg.sender);
    }


    /*
     * Params
     * address owner_ - Address that will become contract owner
     * string memory name_ - Token name
     * string memory symbol_ - Token Symbol
     * string memory uri_ - Base token URI
     * uint256 royalty_ - Base royaly in basis points (1000 = 10%)
     *
     * Function deploys token contract and assigns owner
     */
    function deployToken(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint256 royalty_
    )
    external onlyRole(CREATOR_ROLE)
    override
    returns(address)
    {
        return address(new SimpleERC721(
                owner_,
                decryptMarketplaceAddress_,
                name_,
                symbol_,
                uri_,
                royalty_
            ));
    }


    /*
     * Params
     * address _creator - Address of the contract that will be able to deploy NFT contracts
     * Should be proxy-NFT-creator address
     *
     * Function sets role for proxy-NFT-creator that allows to deploy contracts
     */
    function setCreator(address _creator) external onlyRole(OWNER_ROLE){
        require (_creator != address(0), 'Cant accept 0 address');
        creator = _creator;
        grantRole(CREATOR_ROLE, _creator);

        emit CreatorSet(_creator);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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

pragma solidity 0.8.17;

interface ISimpleERC721Deployer {
    function deployToken(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint256 royalty_
    ) external returns(address);
}

interface IExtendedERC721Deployer {
    function deployToken(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint256 royalty_,
        address preSalePaymentToken_
    ) external returns(address);
}

interface ISimpleERC1155Deployer {
    function deployToken(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory uri_,
        uint256 royalty_
    ) external returns(address);
}

interface IExtendedERC1155Deployer {
    function deployToken(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory uri_,
        uint256 royalty_,
        address preSalePaymentToken_
    ) external returns(address);
}

pragma solidity 0.8.17;

import "./CustomERC721.sol";

contract SimpleERC721 is CustomERC721 {

    /*
     * Params
     * address owner_ - Address that will become contract owner
     * address decryptMarketplaceAddress_ - Decrypt Marketplace proxy address
     * string memory name_ - Token name
     * string memory symbol_ - Token Symbol
     * string memory uri_ - Base token URI
     * uint256 royalty_ - Base royaly in basis points (1000 = 10%)
     */
    constructor(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint256 royalty_
    )
    CustomERC721(
        owner_,
        decryptMarketplaceAddress_,
        name_,
        symbol_,
        uri_,
        royalty_
    )
    {}

}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT

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

pragma solidity 0.8.17;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

import "./RoyaltyDistribution.sol";
import "./PreSale1155.sol";
import "./I_NFT.sol";
import "./IRoyaltyDistribution.sol";

abstract contract CustomERC721 is RoyaltyDistribution, ERC721{
    using Strings for uint256;

    event UpdatedURI(
        string _uri
    );

    string private _uri;

    address public decryptMarketplaceAddress;

    bool private isForbiddenToTradeOnOtherMarketplaces = false;

    modifier onlyDecrypt {
        require(msg.sender == decryptMarketplaceAddress, 'Unauthorized');
        _;
    }


    /*
     * Params
     * address owner_ - Address that will become contract owner
     * address decryptMarketplaceAddress_ - Decrypt Marketplace proxy address
     * string memory name_ - Token name
     * string memory symbol_ - Token Symbol
     * string memory uri_ - Base token URI
     * uint256 royalty_ - Base royalty in basis points (1000 = 10%)
     */
    constructor(
        address owner_,
        address decryptMarketplaceAddress_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        uint256 royalty_
    )
        ERC721(name_, symbol_)
    {
        _uri = uri_;
        globalRoyalty = royalty_;
        transferOwnership(owner_);
        royaltyReceiver = owner_;
        decryptMarketplaceAddress = decryptMarketplaceAddress_;
    }


    /*
     * Returns NTF base token URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _uri;
    }



    /*
     * Returns NTF base token URI. External function
     */
    function baseURI() external view returns (string memory) {
        return _baseURI();
    }


    /*
     * Params
     * string memory uri_ - new base token URI
     *
     * Function sets new base token URI
     */
    function setURI(string memory uri_) external onlyOwner {
        _uri = uri_;

        emit UpdatedURI(
            uri_
        );
    }


    /*
     * Params
     * address to - Who will be the owner of this token?
     * uint256 tokenId - ID index of the token you want to mint
     *
     * Mints token with specific ID and sets specific address as its owner
     */
    function mint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }


    /*
     * Params
     * address to - Who will be the owner of this token?
     * uint256 tokenId - ID index of the token you want to mint
     *
     * Allows Decrypt marketplace to mint tokens
     */
    function lazyMint(address to, uint256 tokenId) external onlyDecrypt {
        _safeMint(to, tokenId);
    }


    /*
     * Params
     * uint256 tokenId - ID index of the token
     *
     * Function checks if token exists
     */
    function exists(uint256 tokenId) public view returns (bool){
        return _exists(tokenId);
    }


    /*
     * Overwritten Openzeppelin function without require of token to exist
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }


    /*
     * Params
     * bytes4 interfaceId - interface ID
     *
     * Called to determine interface support
     * Called by marketplace to determine if contract supports IERC2981, that allows royalty calculation.
     * Also called by marketplace to determine if contract supports lazy mint and royalty distribution.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
        return
        interfaceId == type(IERC2981).interfaceId ||
        interfaceId == type(ILazyMint721).interfaceId ||
        interfaceId == type(IRoyaltyDistribution).interfaceId ||
        super.supportsInterface(interfaceId);
    }


    /*
     * Params
     * address from - Address sender
     * address to - Address receiver
     * uint256 tokenId - Token index ID
     *
     * Transfers from sender to receiver token with specific ID.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        bool allowed = !isForbiddenToTradeOnOtherMarketplaces
            || msg.sender == tx.origin ||  msg.sender == decryptMarketplaceAddress;
        require(allowed, "Restricted to Decrypt marketplace only!");
    }


    /*
     * Params
     * bool _forbidden - Do you want to forbid?
     *** true - forbid, false - allow
     *
     * Forbids/allows trading this contract tokens on other marketplaces.
     */
    function forbidToTradeOnOtherMarketplaces(bool _forbidden) external onlyDecrypt {
        require(isForbiddenToTradeOnOtherMarketplaces != _forbidden, "Already set");
        isForbiddenToTradeOnOtherMarketplaces = _forbidden;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

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

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC2981.sol";



abstract contract RoyaltyDistribution is Ownable, IERC2981{

    struct RoyaltyShare {
        address collaborator;
        uint256 share;
    }

    bool public globalRoyaltyEnabled = true;

    // if royaltyDistributionEnabled == (false) - all royalties go to royaltyReceiver
    // if royaltyDistributionEnabled == (true) - all royalties
    // are divided between collaborators according to specified shares and rest goes to royaltyReceiver
    // Royalties distribution is not supported by IERC2981 standard and will only work on Decrypt marketplace
    bool public royaltyDistributionEnabled = true;

    //royalty percent in basis points (1000 = 10%)
    uint256 public globalRoyalty;
    //personal token royalty amount - in basis points.
    mapping(uint256 => uint256) public tokenRoyalty;

    //List of collaborators, who will receive the share of royalty. Empty by default
    RoyaltyShare[] private defaultCollaboratorsRoyaltyShare;
    //tokenId => royalty distribution for this token
    mapping(uint256 => RoyaltyShare[]) private tokenCollaboratorsRoyaltyShare;

    address public royaltyReceiver;

    event NewGlobalRoyalty(uint256);
    event NewTokenRoyalty(uint256 royalty, uint256 tokenId);
    event NewRoyaltyReceiver(address);


    /*
    * Params
    * uint256 _tokenId - the NFT asset queried for royalty information
    * uint256 _salePrice - the sale price of the NFT asset specified by _tokenId
    *
    * Called with the sale price by marketplace to determine the amount of royalty
    * needed to be paid to a wallet for specific tokenId.
    */
    function royaltyInfo
    (
        uint256 _tokenId,
        uint256 _salePrice
    )
    external
    view
    override
    returns (
        address receiver,
        uint256 royaltyAmount
    ){
        uint256 royaltyAmount;
        if(globalRoyaltyEnabled){
            if(tokenRoyalty[_tokenId] == 0){
                royaltyAmount = _salePrice * globalRoyalty / 10000;
            }else{
                royaltyAmount = _salePrice * tokenRoyalty[_tokenId] / 10000;
            }
        }else{
            royaltyAmount = 0;
        }
        return (royaltyReceiver, royaltyAmount);
    }


    /*
     * Params
     * address newRoyaltyReceiver - address of wallet/contract who will receive royalty by default
     *
     * Sets new address of royalty receiver.
     * If royalty distributes among collaborators,
     * this address will receive the rest of the royalty after substraction
     */
    function setRoyaltyReceiver (address newRoyaltyReceiver) external onlyOwner {
        require(newRoyaltyReceiver != address(0), 'Cant set 0 address');
        require(newRoyaltyReceiver != royaltyReceiver, 'This address is already a receiver');
        royaltyReceiver = newRoyaltyReceiver;

        emit NewRoyaltyReceiver(newRoyaltyReceiver);
    }


    /*
     * Params
     * uint256 _royalty - Royalty amount in basis points (10% = 1000)
     *
     * Sets default royalty amount
     * This amount will be sent to royalty receiver or/and distributed among collaborators
     */
    function setGlobalRoyalty (uint256 _royalty) external onlyOwner {
        require(_royalty <= 9000,'Royalty is over 90%');
        globalRoyalty = _royalty;

        emit NewGlobalRoyalty(_royalty);
    }


    /*
     * Params
     * uint256 _royalty - Royalty amount in basis points (10% = 1000)
     *
     * Sets individual token royalty amount
     * If it's 0 - global royalty amount will be used instead
     * This amount will be sent to royalty receiver or/and distributed among collaborators
     */
    function setTokenRoyalty (uint256 _royalty, uint256 _tokenId) external onlyOwner {
        require(_royalty <= 9000,'Royalty is over 90%');
        tokenRoyalty[_tokenId] = _royalty;

        emit NewTokenRoyalty(_royalty, _tokenId);
    }


    /*
     * Disables any royalty for all NFT contract
     */
    function disableRoyalty() external onlyOwner {
        globalRoyaltyEnabled = false;
    }


    /*
     * Enables royalty for all NFT contract
     */
    function enableRoyalty() external onlyOwner {
        globalRoyaltyEnabled = true;
    }


    /*
     * Disables distribution of any royalty. All royalties go straight to royaltyReceiver
     */
    function disableRoyaltyDistribution() external onlyOwner {
        royaltyDistributionEnabled = false;
    }


    /*
     * Disables distribution of any royalty. All royalties go straight to royaltyReceiver
     */
    function enableRoyaltyDistribution() external onlyOwner {
        royaltyDistributionEnabled = true;
    }


    /*
     * Params
     * address[] calldata collaborators - array of addresses to receive royalty share
     * uint256[] calldata shares - array of shares in basis points  for collaborators (basis points).
     * Example: 1000 = 10% of royalty
     *
     * Function sets default royalty distribution
     * Royalty distribution is not supported by IERC2981 standard and will only work on Decrypt marketplace
     */
    function setDefaultRoyaltyDistribution(
        address[] calldata collaborators,
        uint256[] calldata shares
    ) external onlyOwner {
        require(collaborators.length == shares.length, 'Arrays dont match');

        uint256 totalShares = 0;
        for (uint i=0; i<shares.length; i++){
            totalShares += shares[i];
        }
        require(totalShares <= 10000, 'Total shares > 10000');


        delete defaultCollaboratorsRoyaltyShare;
        for (uint i=0; i<collaborators.length; i++){
            defaultCollaboratorsRoyaltyShare.push(RoyaltyShare({
            collaborator: collaborators[i],
            share: shares[i]
            }));
        }
    }


    /*
     * Function returns array of default royalties distribution
     * Royalties distribution is not supported by IERC2981 standard and will only work on Decrypt marketplace
     */
    function getDefaultRoyaltyDistribution()
    public
    view
    returns(RoyaltyShare[] memory)
    {
        return defaultCollaboratorsRoyaltyShare;
    }


    /*
     * Params
     * address[] calldata collaborators - array of addresses to receive royalty share
     * uint256[] calldata shares - array of shares in basis points  for collaborators (basis points).
     * Example: 1000 = 10% of royalty
     * uint256 tokenId - Token index ID
     *
     * Function sets default royalty distribution
     * Royalty distribution is not supported by IERC2981 standard and will only work on Decrypt marketplace
     */
    function setTokenRoyaltyDistribution(
        address[] calldata collaborators,
        uint256[] calldata shares,
        uint256 tokenId
    ) external onlyOwner {
        require(collaborators.length == shares.length, 'Arrays dont match');

        uint256 totalShares = 0;
        for (uint i=0; i<shares.length; i++){
            totalShares += shares[i];
        }
        require(totalShares <= 10000, 'Total shares > 10000');


        delete tokenCollaboratorsRoyaltyShare[tokenId];

        for (uint i=0; i<collaborators.length; i++){
            tokenCollaboratorsRoyaltyShare[tokenId].push(RoyaltyShare({
            collaborator: collaborators[i],
            share: shares[i]
            }));
        }
    }


    /*
     * Params
     * uint256 tokenId - ID index of token
     *
     * Function returns array of royalties distribution specified for this token
     * If it's empty, default royalty distribution will be used instead
     * Royalties distribution is not supported by IERC2981 standard and will only work on Decrypt marketplace
     */
    function getTokenRoyaltyDistribution(uint256 tokenId)
    public
    view
    returns(RoyaltyShare[] memory)
    {
        return tokenCollaboratorsRoyaltyShare[tokenId];
    }

}

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract PreSale1155 is Ownable{

    event NewPreSale(
        uint256 _eventId,
        uint256 _maxTokensPerWallet,
        uint256 _maxTokensOfSameIdPerWallet,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxTokensForTier,
        uint256 _price,
        bool _whiteList
    );

    event UpdatedPreSale(
        uint256 _eventId,
        uint256 _maxTokensPerWallet,
        uint256 _maxTokensOfSameIdPerWallet,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxTokensForTier,
        uint256 _price,
        bool _whiteList
    );

    event Whitelisted(uint256 eventId, address buyer);
    event SpecialPrice(
        uint256 eventId,
        uint256 tokenId,
        uint256 price
    );
    event NewPreSalePaymentToken(address);


    struct PreSaleEventInfo {
        uint256 maxTokensPerWallet;
        uint256 maxTokensOfSameIdPerWallet;
        uint256 startTime;
        uint256 endTime;
        uint256 maxTokensForEvent;
        uint256 tokensSold;
        uint256 price;
        bool whiteList;
    }

    // eventId => tokenId => token price
    mapping(uint256 => mapping(uint256 => uint256)) public specialPrice;
    // eventId => user address => quantity
    mapping(uint256 => mapping(address => uint256)) private tokensBoughtDuringEvent;
    // eventId => token ID => user address => quantity
    mapping (uint256 => mapping(uint256 => mapping(address => uint256))) private tokensOfSameIdBoughtDuringEvent;
    // user address => eventId => whitelisted
    mapping(address => mapping(uint256 => bool)) public isAddressWhitelisted;
    // eventId => PreSaleEventInfo
    // Contains all Event information. Should be called on Front End to receive up-to-date information
    PreSaleEventInfo[] public preSaleEventInfo;
    //address(0) for ETH, anything else - for ERC20
    address public preSalePaymentToken;


    /*
     * Params
     * address buyer - Buyer address
     * uint256 tokenId - ID index of tokens, user wants to buy
     * uint256 quantity - Quantity of tokens, user wants to buy
     * uint256 eventId - Event ID index
     *
     * Function returns price of single token for specific buyer, event ID and quantity
     * and decides if user can buy these tokens
     * {availableForBuyer} return param decides if buyer can purchase right now
     * This function should be called on Front End before any pre purchase transaction
     */
    function getTokenInfo
    (
        address buyer,
        uint256 tokenId,
        uint256 quantity,
        uint256 eventId
    )
        external
        view
        returns (uint256 tokenPrice, address paymentToken, bool availableForBuyer)
    {
        uint256 tokenPrice = preSaleEventInfo[eventId].price;
        bool availableForBuyer = true;

        //Special price check
        if(specialPrice[eventId][tokenId] != 0){
            tokenPrice = specialPrice[eventId][tokenId];
        }


        if((    //Whitelist check
            preSaleEventInfo[eventId].whiteList
            && isAddressWhitelisted[buyer][eventId] == false
            )||( //Time check
            block.timestamp < preSaleEventInfo[eventId].startTime
            || block.timestamp > preSaleEventInfo[eventId].endTime
            )||( //Maximum tokens for event check
            preSaleEventInfo[eventId].maxTokensForEvent != 0 &&
            (preSaleEventInfo[eventId].tokensSold + quantity) > preSaleEventInfo[eventId].maxTokensForEvent
            )||( //Maximum tokens per wallet
            preSaleEventInfo[eventId].maxTokensPerWallet != 0
            && tokensBoughtDuringEvent[eventId][buyer] + quantity > preSaleEventInfo[eventId].maxTokensPerWallet
            )||( //Maximum tokens of same ID per wallet
            preSaleEventInfo[eventId].maxTokensPerWallet != 0
            && tokensOfSameIdBoughtDuringEvent[eventId][tokenId][buyer] + quantity > preSaleEventInfo[eventId].maxTokensOfSameIdPerWallet
        ))
        {
            availableForBuyer = false;
        }

        return (tokenPrice, preSalePaymentToken, availableForBuyer);
    }

    /*
     * Params
     * uint256 _maxTokensPerWallet - How many tokens in total a wallet can buy?
     * uint256 _maxTokensOfSameIdPerWallet - How many tokens of same ID in total a wallet can buy?
     * uint256 _startTime - When does the sale for this event start?
     * uint256 _startTime - When does the sale for this event end?
     * uint256 _maxTokensForEvent - What is the total amount of tokens sold in this Event?
     * uint256 _price - What is the price per one token?
     * bool _whiteList - Will event allow to participate only whitelisted addresses?
     *
     * Adds new presale event to the list (array)
     */
    function createPreSaleEvent(
        uint256 _maxTokensPerWallet,
        uint256 _maxTokensOfSameIdPerWallet,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxTokensForEvent,
        uint256 _price,
        bool _whiteList
    )
        external
        onlyOwner
    {
        require(_startTime < _endTime, 'Wrong timeline');

        preSaleEventInfo.push(
            PreSaleEventInfo({
                maxTokensPerWallet: _maxTokensPerWallet,
                maxTokensOfSameIdPerWallet: _maxTokensOfSameIdPerWallet,
                startTime: _startTime,
                endTime: _endTime,
                maxTokensForEvent: _maxTokensForEvent,
                tokensSold: 0,
                price: _price,
                whiteList: _whiteList
            })
        );

        emit NewPreSale(
            (preSaleEventInfo.length - 1),
            _maxTokensPerWallet,
            _maxTokensOfSameIdPerWallet,
            _startTime,
            _endTime,
            _maxTokensForEvent,
            _price,
            _whiteList
        );
    }


    /*
     * Params
     * uint256 _eventId - ID index of event
     * uint256 _maxTokensPerWallet - How many tokens in total a wallet can buy?
     * uint256 _maxTokensOfSameIdPerWallet - How many tokens of same ID in total a wallet can buy?
     * uint256 _startTime - When does the sale for this event start?
     * uint256 _startTime - When does the sale for this event end?
     * uint256 _maxTokensForEvent - What is the total amount of tokens sold in this Event?
     * uint256 _price - What is the price per one token?
     * bool _whiteList - Will event allow to participate only whitelisted addresses?
     *
     * Updates presale event in the list (array)
     */
    function updatePreSaleEvent(
        uint256 _eventId,
        uint256 _maxTokensPerWallet,
        uint256 _maxTokensOfSameIdPerWallet,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxTokensForEvent,
        uint256 _price,
        bool _whiteList
    )
        external
        onlyOwner
    {
        require(_startTime < _endTime, 'Wrong timeline');
        require(preSaleEventInfo[_eventId].startTime > block.timestamp, 'Event is already in progress');

        preSaleEventInfo[_eventId].maxTokensPerWallet = _maxTokensPerWallet;
        preSaleEventInfo[_eventId].maxTokensOfSameIdPerWallet = _maxTokensOfSameIdPerWallet;
        preSaleEventInfo[_eventId].startTime = _startTime;
        preSaleEventInfo[_eventId].endTime = _endTime;
        preSaleEventInfo[_eventId].maxTokensForEvent = _maxTokensForEvent;
        preSaleEventInfo[_eventId].price = _price;
        preSaleEventInfo[_eventId].whiteList = _whiteList;

        emit UpdatedPreSale(
            _eventId,
            _maxTokensPerWallet,
            _maxTokensOfSameIdPerWallet,
            _startTime,
            _endTime,
            _maxTokensForEvent,
            _price,
            _whiteList
        );
    }


    /*
     * Params
     * uint256 eventId - Event ID index
     * address buyer - User that should be whitelisted
     *
     * Function add user to whitelist of private event
     */
    function addToWhitelist(
        uint256 eventId,
        address buyer
    ) external onlyOwner {
        require(preSaleEventInfo[eventId].whiteList, 'Event is not private');
        isAddressWhitelisted[buyer][eventId] = true;

        emit Whitelisted(eventId, buyer);
    }


    /*
     * Params
     * uint256 eventId - Event ID index
     * uint256 tokenId - Index ID of token, that should have special price
     * uint256 price - Price for this token ID during this event
     *
     * Function sets special price for a token of specific ID for a specific event
     */
    function setSpecialPriceForToken(
        uint256 eventId,
        uint256 tokenId,
        uint256 price
    ) external onlyOwner{
        specialPrice[eventId][tokenId] = price;

        emit SpecialPrice(eventId, tokenId, price);
    }


    /*
     * Params
     * address buyer - User address, who bought the tokens
     * uint256 tokenId - Index ID of token sold
     * uint256 amount - Amount of tokens sold
     * uint256 eventId - Event ID index
     *
     * Function counts tokens bought for different counters
     */
    function _countTokensBought(
        address buyer,
        uint256 tokenId,
        uint256 amount,
        uint256 eventId
    ) internal {
        if(preSaleEventInfo[eventId].maxTokensPerWallet != 0){
            tokensBoughtDuringEvent[eventId][buyer] += amount;

            if(preSaleEventInfo[eventId].maxTokensOfSameIdPerWallet != 0){
                tokensOfSameIdBoughtDuringEvent[eventId][tokenId][buyer] += amount;
            }
        }
        preSaleEventInfo[eventId].tokensSold += amount;
    }


    /*
     * Params
     * address _preSalePaymentToken - ERC20 address for payment token/ 0 address for ETH
     *
     * Function sets payment token address for pre sale transactions
     */
    function setPreSalePaymentToken (address _preSalePaymentToken) external onlyOwner{
        preSalePaymentToken = _preSalePaymentToken;

        emit NewPreSalePaymentToken(_preSalePaymentToken);
    }
}

pragma solidity 0.8.17;

interface ICreator {
    function deployedTokenContract(address) external view returns(bool);
}

interface ILazyMint721 {
    function exists(uint256 tokenId) external view returns (bool);
    function owner() external view returns (address);
    function lazyMint(address to, uint256 tokenId) external;
}

interface ILazyMint1155 {
    function owner() external view returns (address);
    function lazyMint(address to, uint256 tokenId, uint256 amount) external;
}

interface IPreSale721 {
    function getTokenInfo (address buyer, uint256 tokenId, uint256 eventId)
        external view returns (uint256 tokenPrice, address paymentToken, bool availableForBuyer);
    function countTokensBought(uint256 eventId, address buyer) external;
}

interface IPreSale1155 {
    function getTokenInfo(address buyer, uint256 tokenId, uint256 quantity, uint256 eventId)
        external view returns (uint256 tokenPrice, address paymentToken, bool availableForBuyer);
    function countTokensBought(address buyer, uint256 tokenId, uint256 amount, uint256 eventId) external;
}

interface CustomToken {
    function forbidToTradeOnOtherMarketplaces(bool _forbidden) external;
}

pragma solidity 0.8.17;

interface IRoyaltyDistribution {
    function globalRoyaltyEnabled() external returns(bool);
    function royaltyDistributionEnabled() external returns(bool);
    function defaultCollaboratorsRoyaltyShare() external returns(RoyaltyShare[] memory);


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );

    function getDefaultRoyaltyDistribution() external view returns(RoyaltyShare[] memory);

    function getTokenRoyaltyDistribution(uint256 tokenId) external view returns(RoyaltyShare[] memory);

}

struct RoyaltyShare {
    address collaborator;
    uint256 share;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity 0.8.17;
import "@openzeppelin/contracts/interfaces/IERC165.sol";

///
/// @dev Interface for the NFT Royalty Standard
///
interface IERC2981 is IERC165 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}

//interface IERC165 {
//    /// @notice Query if a contract implements an interface
//    /// @param interfaceID The interface identifier, as specified in ERC-165
//    /// @dev Interface identification is specified in ERC-165. This function
//    ///  uses less than 30,000 gas.
//    /// @return `true` if the contract implements `interfaceID` and
//    ///  `interfaceID` is not 0xffffffff, `false` otherwise
//    function supportsInterface(bytes4 interfaceID) external view returns (bool);
//}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";