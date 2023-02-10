// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface MID {

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner_);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner_);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver_);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl_);

    // Logged when an operator is added or removed.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner_, address resolver_, uint64 ttl_) external;
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner_, address resolver_, uint64 ttl_) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner_) external returns(bytes32);
    function setResolver(bytes32 node, address resolver_) external;
    function setOwner(bytes32 node, address owner_) external;
    function setTTL(bytes32 node, uint64 ttl_) external;
    function setApprovalForAll(address operator, bool approved) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);
    function isApprovedForAll(address owner_, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "../registry/MID.sol";
import "./profiles/ABIResolver.sol";
import "./profiles/AddrResolver.sol";
import "./profiles/ContentHashResolver.sol";
import "./profiles/InterfaceResolver.sol";
import "./profiles/NameResolver.sol";
import "./profiles/PubkeyResolver.sol";
import "./profiles/TextResolver.sol";

interface INameWrapper {
    function ownerOf(uint256 id) external view returns (address);
}

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract PublicResolver is ABIResolver, AddrResolver, ContentHashResolver, InterfaceResolver, NameResolver, PubkeyResolver, TextResolver {
    MID mid;
    INameWrapper nameWrapper;
    address immutable trustedETHController;
    address immutable trustedReverseRegistrar;

    /**
     * A mapping of operators. An address that is authorised for an address
     * may make any changes to the name that the owner could, but may not update
     * the set of authorisations.
     * (owner, operator) => approved
     */
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Logged when an operator is added or removed.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(
        MID _mid, 
        INameWrapper wrapperAddress,
        address _trustedETHController,
        address _trustedReverseRegistrar
    ) {
        mid = _mid;
        nameWrapper = wrapperAddress;
        trustedETHController = _trustedETHController;
        trustedReverseRegistrar = _trustedReverseRegistrar;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external{
        require(
            msg.sender != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isAuthorised(bytes32 node) internal override view returns(bool) {
        if (
            msg.sender == trustedETHController ||
            msg.sender == trustedReverseRegistrar
        ) {
            return true;
        }
        address owner = mid.owner(node);
        if(owner == address(nameWrapper) ){
            owner = nameWrapper.ownerOf(uint256(node));
        }
        return owner == msg.sender || isApprovedForAll(owner, msg.sender);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view returns (bool){
        return _operatorApprovals[account][operator];
    }

    function multicall(bytes[] calldata data) external returns(bytes[] memory results) {
        results = new bytes[](data.length);
        for(uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, "delegatecall failed");
            results[i] = result;
        }
        return results;
    }

    function supportsInterface(bytes4 interfaceID) virtual override(ABIResolver, AddrResolver, ContentHashResolver, InterfaceResolver, NameResolver, PubkeyResolver, TextResolver) public pure returns(bool) {
        return super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
abstract contract ResolverBase {
    bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;

    function supportsInterface(bytes4 interfaceID) virtual public pure returns(bool) {
        return interfaceID == INTERFACE_META_ID;
    }

    function isAuthorised(bytes32 node) internal virtual view returns(bool);

    modifier authorised(bytes32 node) {
        require(isAuthorised(node), "not authorised");
        _;
    }

    function bytesToAddress(bytes memory b) internal pure returns(address payable a) {
        require(b.length == 20, "bytes length must be 20");
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns(bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";

abstract contract ABIResolver is ResolverBase {
    bytes4 constant private ABI_INTERFACE_ID = 0x2203ab56;

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    mapping(bytes32=>mapping(uint256=>bytes)) abis;

    /**
     * Sets the ABI associated with an MID node.
     * Nodes may have one ABI of each content type. To remove an ABI, set it to
     * the empty string.
     * @param node The node to update.
     * @param contentType The content type of the ABI
     * @param data The ABI data.
     */
    function setABI(bytes32 node, uint256 contentType, bytes calldata data) external authorised(node) {
        // Content types must be powers of 2
        require(((contentType - 1) & contentType) == 0);

        abis[node][contentType] = data;
        emit ABIChanged(node, contentType);
    }

    /**
     * Returns the ABI associated with an MID node.
     * Defined in EIP205.
     * @param node The MID node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) {
        mapping(uint256=>bytes) storage abiset = abis[node];

        for (uint256 contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && abiset[contentType].length > 0) {
                return (contentType, abiset[contentType]);
            }
        }

        return (0, bytes(""));
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == ABI_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";

abstract contract AddrResolver is ResolverBase {
    bytes4 constant private ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant private ADDRESS_INTERFACE_ID = 0xf1cb7e06;
    uint constant private COIN_TYPE_ETH = 60;

    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);

    mapping(bytes32=>mapping(uint=>bytes)) _addresses;

    /**
     * Sets the address associated with an MID node.
     * May only be called by the owner of that node in the MID registry.
     * @param node The node to update.
     * @param a The address to set.
     */
    function setAddr(bytes32 node, address a) external authorised(node) {
        setAddr(node, COIN_TYPE_ETH, addressToBytes(a));
    }

    /**
     * Returns the address associated with an MID node.
     * @param node The MID node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) public view returns (address payable) {
        bytes memory a = addr(node, COIN_TYPE_ETH);
        if(a.length == 0) {
            return payable(0);
        }
        return bytesToAddress(a);
    }

    function setAddr(bytes32 node, uint coinType, bytes memory a) public authorised(node) {
        emit AddressChanged(node, coinType, a);
        if(coinType == COIN_TYPE_ETH) {
            emit AddrChanged(node, bytesToAddress(a));
        }
        _addresses[node][coinType] = a;
    }

    function addr(bytes32 node, uint coinType) public view returns(bytes memory) {
        return _addresses[node][coinType];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == ADDR_INTERFACE_ID || interfaceID == ADDRESS_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";

abstract contract ContentHashResolver is ResolverBase {
    bytes4 constant private CONTENT_HASH_INTERFACE_ID = 0xbc1c58d1;

    event ContenthashChanged(bytes32 indexed node, bytes hash);

    mapping(bytes32=>bytes) hashes;

    /**
     * Sets the contenthash associated with an MID node.
     * May only be called by the owner of that node in the MID registry.
     * @param node The node to update.
     * @param hash The contenthash to set
     */
    function setContenthash(bytes32 node, bytes calldata hash) external authorised(node) {
        hashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Returns the contenthash associated with an MID node.
     * @param node The MID node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) external view returns (bytes memory) {
        return hashes[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == CONTENT_HASH_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";
import "./AddrResolver.sol";

abstract contract InterfaceResolver is ResolverBase, AddrResolver {
    bytes4 constant private INTERFACE_INTERFACE_ID = bytes4(keccak256("interfaceImplementer(bytes32,bytes4)"));
    bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;

    event InterfaceChanged(bytes32 indexed node, bytes4 indexed interfaceID, address implementer);

    mapping(bytes32=>mapping(bytes4=>address)) interfaces;

    /**
     * Sets an interface associated with a name.
     * Setting the address to 0 restores the default behaviour of querying the contract at `addr()` for interface support.
     * @param node The node to update.
     * @param interfaceID The EIP 165 interface ID.
     * @param implementer The address of a contract that implements this interface for this node.
     */
    function setInterface(bytes32 node, bytes4 interfaceID, address implementer) external authorised(node) {
        interfaces[node][interfaceID] = implementer;
        emit InterfaceChanged(node, interfaceID, implementer);
    }

    /**
     * Returns the address of a contract that implements the specified interface for this name.
     * If an implementer has not been set for this interfaceID and name, the resolver will query
     * the contract at `addr()`. If `addr()` is set, a contract exists at that address, and that
     * contract implements EIP165 and returns `true` for the specified interfaceID, its address
     * will be returned.
     * @param node The MID node to query.
     * @param interfaceID The EIP 165 interface ID to check for.
     * @return The address that implements this interface, or 0 if the interface is unsupported.
     */
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address) {
        address implementer = interfaces[node][interfaceID];
        if(implementer != address(0)) {
            return implementer;
        }

        address a = addr(node);
        if(a == address(0)) {
            return address(0);
        }

        (bool success, bytes memory returnData) = a.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)", INTERFACE_META_ID));
        if(!success || returnData.length < 32 || returnData[31] == 0) {
            // EIP 165 not supported by target
            return address(0);
        }

        (success, returnData) = a.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)", interfaceID));
        if(!success || returnData.length < 32 || returnData[31] == 0) {
            // Specified interface not supported by target
            return address(0);
        }

        return a;
    }

    function supportsInterface(bytes4 interfaceID) virtual override(AddrResolver, ResolverBase) public pure returns(bool) {
        return interfaceID == INTERFACE_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";

abstract contract NameResolver is ResolverBase {
    bytes4 constant private NAME_INTERFACE_ID = 0x691f3431;

    event NameChanged(bytes32 indexed node, string name);

    mapping(bytes32=>string) names;

    /**
     * Sets the name associated with an MID node, for reverse records.
     * May only be called by the owner of that node in the MID registry.
     * @param node The node to update.
     * @param name_ The name to set.
     */
    function setName(bytes32 node, string calldata name_) external authorised(node) {
        names[node] = name_;
        emit NameChanged(node, name_);
    }

    /**
     * Returns the name associated with an MID node, for reverse records.
     * Defined in EIP181.
     * @param node The MID node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory) {
        return names[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == NAME_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";

abstract contract PubkeyResolver is ResolverBase {
    bytes4 constant private PUBKEY_INTERFACE_ID = 0xc8690233;

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    mapping(bytes32=>PublicKey) pubkeys;

    /**
     * Sets the SECP256k1 public key associated with an MID node.
     * @param node The MID node to query
     * @param x the X coordinate of the curve point for the public key.
     * @param y the Y coordinate of the curve point for the public key.
     */
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external authorised(node) {
        pubkeys[node] = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    /**
     * Returns the SECP256k1 public key associated with an MID node.
     * Defined in EIP 619.
     * @param node The MID node to query
     * @return x The X coordinate of the curve point for the public key.
     * @return y The Y coordinate of the curve point for the public key.
     */
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y) {
        return (pubkeys[node].x, pubkeys[node].y);
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == PUBKEY_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "../ResolverBase.sol";

abstract contract TextResolver is ResolverBase {
    bytes4 constant private TEXT_INTERFACE_ID = 0x59d1d43c;

    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);

    mapping(bytes32=>mapping(string=>string)) texts;

    /**
     * Sets the text data associated with an MID node and key.
     * May only be called by the owner of that node in the MID registry.
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function setText(bytes32 node, string calldata key, string calldata value) external authorised(node) {
        texts[node][key] = value;
        emit TextChanged(node, key, key);
    }

    /**
     * Returns the text data associated with an MID node and key.
     * @param node The MID node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return texts[node][key];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == TEXT_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}