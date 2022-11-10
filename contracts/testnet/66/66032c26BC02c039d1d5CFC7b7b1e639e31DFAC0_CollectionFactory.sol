// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "../interfaces/Collection/ICollection.sol";
import "../interfaces/Collection/ICollectionFactory.sol";
import "../interfaces/IMarketplaceManager.sol";
import "../Validatable.sol";
import "../lib/NFTHelper.sol";

contract CollectionFactory is ICollectionFactory, Validatable, ERC165Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 public maxCollection;
    uint256 public maxTotalSupply;
    ICollection public templateERC721;
    ICollection public templateERC1155;
    address public metaversusManager;
    address public metaDrop;

    CountersUpgradeable.Counter private _collectionCounter;

    /**
     *  @notice marketplace store the address of the marketplaceManager contract
     */
    IMarketplaceManager public marketplace;

    /**
     *  @notice This struct defining data for each item selling on the marketplace
     *
     *  @param typeNft                      Type of NFT
     *  @param salt                         Additional data to make the Collection unique
     *  @param collectionAddress            Address of the Collection
     *  @param owner                        Owner's Address of the Collection
     */
    struct CollectionInfo {
        NFTHelper.Type typeNft;
        bytes32 salt;
        address collectionAddress;
        address owner;
    }

    mapping(address => uint256) public maxCollectionOfUsers;
    mapping(uint256 => CollectionInfo) public collectionIdToCollectionInfos;
    mapping(address => EnumerableSetUpgradeable.AddressSet) private _ownerToCollectionAddress;

    event CollectionDeployed(
        NFTHelper.Type collectType,
        address collection,
        string name,
        string symbol,
        address deployer,
        address receiverRoyalty,
        uint96 feeNumerator
    );
    event SetMaxCollection(uint256 indexed oldValue, uint256 indexed newValue);
    event SetMaxTotalSuply(uint256 indexed oldValue, uint256 indexed newValue);
    event SetTemplateAddress(address indexed templateERC721, address indexed templateERC1155);
    event SetMaxCollectionOfUser(uint256 indexed oldValue, uint256 indexed newValue);
    event SetMetaversusManager(address indexed oldAddress, address indexed newAddress);
    event SetMetaDrop(address indexed oldAddress, address indexed newAddress);
    event SetMarketplace(IMarketplaceManager indexed oldMarketplace, IMarketplaceManager indexed newMarketplace);

    function initialize(
        ICollection _templateERC721,
        ICollection _templateERC1155,
        IAdmin _admin,
        address _metaversusManager,
        address _metaDrop,
        address _marketplace
    ) public initializer {
        __ERC165_init();
        __Validatable_init(_admin);

        templateERC721 = _templateERC721;
        templateERC1155 = _templateERC1155;
        metaversusManager = _metaversusManager;
        metaDrop = _metaDrop;
        marketplace = IMarketplaceManager(_marketplace);
        maxCollection = 5;
        maxTotalSupply = 100;
    }

    function create(
        NFTHelper.Type _typeNft,
        string memory _name,
        string memory _symbol,
        address _receiverRoyalty,
        uint96 _feeNumerator,
        bytes calldata rootHash
    ) external whenNotPaused {
        if (maxCollectionOfUsers[_msgSender()] == 0) {
            maxCollectionOfUsers[_msgSender()] = maxCollection;
        }

        ErrorHelper._checkExceedMaxCollection(
            _ownerToCollectionAddress[_msgSender()].length(),
            maxCollectionOfUsers[_msgSender()]
        );
        _collectionCounter.increment();
        uint256 _currentId = _collectionCounter.current();
        bytes32 salt = bytes32(_currentId);
        address _template = _typeNft == NFTHelper.Type.ERC721 ? address(templateERC721) : address(templateERC1155);
        ICollection _collection = ICollection(ClonesUpgradeable.cloneDeterministic(address(_template), salt));
        ErrorHelper._checkCloneCollection(address(_collection));
        // store
        CollectionInfo memory newInfo = CollectionInfo(_typeNft, salt, address(_collection), admin.owner());
        collectionIdToCollectionInfos[_currentId] = newInfo;

        // initialize
        _collection.initialize(admin.owner(), _name, _symbol, maxTotalSupply, _receiverRoyalty, _feeNumerator);

        // set roothash
        marketplace.setNewRootHash(address(_collection), rootHash);
        // setAdmin
        _collection.setAdminByFactory(metaDrop, true);
        _collection.setAdminByFactory(metaversusManager, true);

        _ownerToCollectionAddress[_msgSender()].add(address(_collection));

        emit CollectionDeployed(
            _typeNft,
            address(_collection),
            _name,
            _symbol,
            _msgSender(),
            _receiverRoyalty,
            _feeNumerator
        );
    }

    /**
     *  @notice Set Marketplace to change MarketplaceManager address.
     *
     *  @dev    Only owner or admin can call this function.
     */
    function setMarketplace(IMarketplaceManager _newMarketplace)
        external
        onlyAdmin
        validMarketplaceManager(_newMarketplace)
    {
        IMarketplaceManager oldMarketplace = marketplace;
        marketplace = _newMarketplace;
        emit SetMarketplace(oldMarketplace, marketplace);
    }

    /**
     *  @notice Set maxCollection value to mint
     *  @param  _newValue that set maxCollection value
     */
    function setMaxCollection(uint256 _newValue) external onlyAdmin {
        ErrorHelper._checkMaxCollection(_newValue);
        uint256 _oldValue = maxCollection;
        maxCollection = _newValue;
        emit SetMaxCollection(_oldValue, maxCollection);
    }

    /**
     *  @notice Set maxTotalSupply value to mint
     *  @param  _newValue that set maxTotalSupply value
     */
    function setMaxTotalSuply(uint256 _newValue) external onlyAdmin {
        ErrorHelper._checkMaxTotalSupply(_newValue);
        uint256 _oldValue = maxTotalSupply;
        maxTotalSupply = _newValue;
        emit SetMaxTotalSuply(_oldValue, maxTotalSupply);
    }

    /**
     *  @notice Set max collection of user
     *  @param  _newValue that set max collection of user value
     */
    function setMaxCollectionOfUser(address _user, uint256 _newValue) external onlyAdmin notZeroAddress(_user) {
        ErrorHelper._checkMaxCollectionOfUser(_newValue);
        uint256 _oldValue = maxCollectionOfUsers[_user];
        maxCollectionOfUsers[_user] = _newValue;
        emit SetMaxCollectionOfUser(_oldValue, _newValue);
    }

    /**
     *  @notice Set template dddress
     *  @param  _templateERC721 that set erc721 address
     *  @param  _templateERC1155 that set erc1155 address
     */
    function setTemplateAddress(address _templateERC721, address _templateERC1155)
        external
        notZeroAddress(_templateERC721)
        notZeroAddress(_templateERC1155)
        onlyAdmin
    {
        templateERC721 = ICollection(_templateERC721);
        templateERC1155 = ICollection(_templateERC1155);

        emit SetTemplateAddress(_templateERC721, _templateERC1155);
    }

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return interfaceId == type(ICollectionFactory).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     *  @notice Set metaversus manager dddress
     *  @param  _newAddress that set erc721 address
     */
    function setMetaversusManager(address _newAddress) external notZeroAddress(_newAddress) onlyAdmin {
        address _oldAddress = metaversusManager;
        metaversusManager = _newAddress;

        emit SetMetaversusManager(_oldAddress, _newAddress);
    }

    /**
     *  @notice Set metaDrop dddress
     *  @param  _newAddress that set metaDrop address
     */
    function setMetaDrop(address _newAddress) external notZeroAddress(_newAddress) onlyAdmin {
        address _oldAddress = metaDrop;
        metaDrop = _newAddress;

        emit SetMetaDrop(_oldAddress, _newAddress);
    }

    function checkCollectionOfUser(address _user, address _nft) external view returns (bool) {
        return _ownerToCollectionAddress[_user].contains(_nft);
    }

    function getCollectionByUser(address _user) external view returns (address[] memory) {
        return _ownerToCollectionAddress[_user].values();
    }

    function getCollectionLength() public view returns (uint256) {
        return _collectionCounter.current();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ICollection is IERC165Upgradeable {
    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        uint256 _totalSuply,
        address _receiverRoyalty,
        uint96 _feeNumerator
    ) external;

    function setAdminByFactory(address _user, bool _allow) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ICollectionFactory is IERC165Upgradeable {
    function checkCollectionOfUser(address _user, address _nft) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "../Struct.sol";

interface IMarketplaceManager is IERC165Upgradeable {
    function wasBuyer(address account) external view returns (bool);

    // Market Item
    function getMarketItemIdToMarketItem(uint256 marketItemId) external view returns (MarketItem memory);

    function setMarketItemIdToMarketItem(uint256 marketItemId, MarketItem memory value) external;

    function setIsBuyer(address newBuyer) external;

    function extCreateMarketInfo(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price,
        address _seller,
        uint256 _startTime,
        uint256 _endTime,
        IERC20Upgradeable _paymentToken
    ) external;

    function getListingFee(uint256 amount) external view returns (uint256);

    function extTransferNFTCall(
        address nftContractAddress,
        uint256 tokenId,
        uint256 amount,
        address from,
        address to
    ) external;

    function getCurrentMarketItem() external view returns (uint256);

    function getRoyaltyInfo(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address, uint256);

    function isRoyalty(address _contract) external view returns (bool);

    function verify(
        uint256 _marketItemId,
        bytes32[] memory _proof,
        address _account
    ) external view returns (bool);

    function isPrivate(uint256 _marketItemId) external view returns (bool);

    function setNewRootHash(address nftAddress, bytes calldata newRoot) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

import "./interfaces/IAdmin.sol";
import "./interfaces/ITokenMintERC721.sol";
import "./interfaces/ITokenMintERC1155.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IMarketplaceManager.sol";
import "./interfaces/Collection/ICollectionFactory.sol";
import "./interfaces/IStakingPool.sol";
import "./interfaces/IOrder.sol";
import "./interfaces/IMetaCitizen.sol";
import "./interfaces/IMetaversusManager.sol";
import "./interfaces/Collection/ITokenERC721.sol";
import "./interfaces/Collection/ITokenERC1155.sol";
import "./lib/ErrorHelper.sol";

/**
 *  @title  Dev Validatable
 *
 *  @author Metaversus Team
 *
 *  @dev This contract is using as abstract smartcontract
 *  @notice This smart contract provide the validatable methods and modifier for the inheriting contract.
 */
contract Validatable is PausableUpgradeable {
    /**
     *  @notice paymentToken IAdmin is interface of Admin contract
     */
    IAdmin public admin;

    event SetPause(bool indexed isPause);

    /*------------------Check Admins------------------*/

    modifier onlyOwner() {
        if (admin.owner() != _msgSender()) {
            revert ErrorHelper.CallerIsNotOwner();
        }
        _;
    }

    modifier onlyAdmin() {
        if (!admin.isAdmin(_msgSender())) {
            revert ErrorHelper.CallerIsNotOwnerOrAdmin();
        }
        _;
    }

    modifier validWallet(address _account) {
        if (!isWallet(_account)) {
            revert ErrorHelper.InvalidWallet(_account);
        }
        _;
    }

    /*------------------Common Checking------------------*/

    modifier notZeroAddress(address _account) {
        if (_account == address(0)) {
            revert ErrorHelper.InvalidAddress();
        }
        _;
    }

    modifier notZero(uint256 _amount) {
        if (_amount == 0) {
            revert ErrorHelper.InvalidAmount();
        }
        _;
    }

    modifier validPaymentToken(IERC20Upgradeable _paymentToken) {
        if (!admin.isPermittedPaymentToken(_paymentToken)) {
            revert ErrorHelper.PaymentTokenIsNotSupported();
        }
        _;
    }

    /*------------------Validate Contracts------------------*/

    modifier validOrder(IOrder _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(IOrder).interfaceId)) {
            revert ErrorHelper.InValidOrderContract(address(_account));
        }
        _;
    }

    modifier validMetaversusManager(IMetaversusManager _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(IMetaversusManager).interfaceId)) {
            revert ErrorHelper.InValidMetaversusManagerContract(address(_account));
        }
        _;
    }

    modifier validTokenCollectionERC721(ITokenERC721 _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(ITokenERC721).interfaceId)) {
            revert ErrorHelper.InValidTokenCollectionERC721Contract(address(_account));
        }
        _;
    }

    modifier validTokenCollectionERC1155(ITokenERC1155 _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(ITokenERC1155).interfaceId)) {
            revert ErrorHelper.InValidTokenCollectionERC1155Contract(address(_account));
        }
        _;
    }
    modifier validAdmin(IAdmin _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(IAdmin).interfaceId)) {
            revert ErrorHelper.InValidAdminContract(address(_account));
        }
        _;
    }

    modifier validTokenMintERC721(ITokenMintERC721 _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(ITokenMintERC721).interfaceId)) {
            revert ErrorHelper.InValidTokenMintERC721Contract(address(_account));
        }
        _;
    }

    modifier validTokenMintERC1155(ITokenMintERC1155 _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(ITokenMintERC1155).interfaceId)) {
            revert ErrorHelper.InValidTokenMintERC1155Contract(address(_account));
        }

        _;
    }

    modifier validTreasury(ITreasury _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(ITreasury).interfaceId)) {
            revert ErrorHelper.InValidTreasuryContract(address(_account));
        }

        _;
    }
    modifier validMarketplaceManager(IMarketplaceManager _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(IMarketplaceManager).interfaceId)) {
            revert ErrorHelper.InValidMarketplaceManagerContract(address(_account));
        }
        _;
    }

    modifier validCollectionFactory(ICollectionFactory _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(ICollectionFactory).interfaceId)) {
            revert ErrorHelper.InValidCollectionFactoryContract(address(_account));
        }
        _;
    }

    modifier validStakingPool(IStakingPool _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(IStakingPool).interfaceId)) {
            revert ErrorHelper.InValidStakingPoolContract(address(_account));
        }
        _;
    }

    modifier validMetaCitizen(IOrder _account) {
        if (!ERC165CheckerUpgradeable.supportsInterface(address(_account), type(IMetaCitizen).interfaceId)) {
            revert ErrorHelper.InValidMetaCitizenContract(address(_account));
        }
        _;
    }

    /*------------------Initializer------------------*/

    function __Validatable_init(IAdmin _admin) internal onlyInitializing validAdmin(_admin) {
        __Context_init();
        __Pausable_init();

        admin = _admin;
    }

    /*------------------Contract Interupts------------------*/

    /**
     *  @notice Set pause action
     */
    function setPause(bool isPause) public onlyOwner {
        if (isPause) _pause();
        else _unpause();

        emit SetPause(isPause);
    }

    /**
     *  @notice Check contract is paused.
     */
    function isPaused() public view returns (bool) {
        return super.paused();
    }

    /*------------------Checking Functions------------------*/

    /**
     *  @notice Check whether merkle tree proof is valid
     *
     *  @param  _proof      Proof data of leaf node
     *  @param  _root       Root data of merkle tree
     *  @param  _account    Address of an account to verify
     */
    function isValidProof(
        bytes32[] memory _proof,
        bytes32 _root,
        address _account
    ) public pure returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_account));
        return MerkleProofUpgradeable.verify(_proof, _root, leaf);
    }

    function isWallet(address _account) public view returns (bool) {
        return _account != address(0) && !AddressUpgradeable.isContract(_account) && tx.origin == _msgSender();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

library NFTHelper {
    enum Type {
        ERC721,
        ERC1155,
        NONE
    }

    /**
     *  @notice Check ERC721 contract without error when not support function supportsInterface
     */
    function isERC721(address _account) internal returns (bool) {
        (bool success, ) = _account.call(
            abi.encodeWithSignature("supportsInterface(bytes4)", type(IERC721Upgradeable).interfaceId)
        );

        return success && IERC721Upgradeable(_account).supportsInterface(type(IERC721Upgradeable).interfaceId);
    }

    /**
     *  @notice Check ERC1155 contract without error when not support function supportsInterface
     */
    function isERC1155(address _account) internal returns (bool) {
        (bool success, ) = _account.call(
            abi.encodeWithSignature("supportsInterface(bytes4)", type(IERC1155Upgradeable).interfaceId)
        );

        return success && IERC1155Upgradeable(_account).supportsInterface(type(IERC1155Upgradeable).interfaceId);
    }

    /**
     *  @notice Check royalty without error when not support function supportsInterface
     */
    function isRoyalty(address _account) internal view returns (bool) {
        return ERC165CheckerUpgradeable.supportsInterface(_account, type(IERC2981Upgradeable).interfaceId);
    }

    /**
     *  @notice Check standard of nft contract address
     */
    function getType(address _account) internal returns (Type) {
        if (isERC721(_account)) return Type.ERC721;
        if (isERC1155(_account)) return Type.ERC1155;

        return Type.NONE;
    }

    /**
     *  @notice Transfer nft call
     */
    function transferNFTCall(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount,
        address _from,
        address _to
    ) internal {
        if (getType(_nftContractAddress) == NFTHelper.Type.ERC721) {
            IERC721Upgradeable(_nftContractAddress).safeTransferFrom(_from, _to, _tokenId);
        } else {
            IERC1155Upgradeable(_nftContractAddress).safeTransferFrom(_from, _to, _tokenId, _amount, "");
        }
    }

    /**
     *  @notice Transfer nft call
     */
    function isTokenExist(address _nftContractAddress, uint256 _tokenId) internal returns (bool) {
        NFTHelper.Type nftType = getType(_nftContractAddress);
        if (nftType == NFTHelper.Type.ERC721) {
            return IERC721Upgradeable(_nftContractAddress).ownerOf(_tokenId) != address(0);
        }

        return nftType == NFTHelper.Type.ERC1155;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./lib/NFTHelper.sol";

enum NftStandard {
    ERC721,
    ERC1155,
    NONE
}
enum MarketItemStatus {
    LISTING,
    SOLD,
    CANCELED
}

/**
 *  @notice This struct defining data for each item selling on the marketplace
 *
 *  @param nftContractAddress           NFT Contract Address
 *  @param tokenId                      Token Id of NFT contract
 *  @param amount                       Amount if token is ERC1155
 *  @param price                        Price of this token
 *  @param nftType                      Type of this NFT
 *  @param seller                       The person who sell this NFT
 *  @param buyer                        The person who offer to this NFT
 *  @param status                       Status of this NFT at Marketplace
 *  @param startTime                    Time when the NFT push to Marketplace
 *  @param endTime                      Time when the NFT expire at Marketplace
 *  @param paymentToken                 Token to transfer
 */
struct MarketItem {
    address nftContractAddress;
    uint256 tokenId;
    uint256 amount;
    uint256 price;
    NFTHelper.Type nftType;
    address seller;
    address buyer;
    MarketItemStatus status;
    uint256 startTime;
    uint256 endTime;
    IERC20Upgradeable paymentToken;
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165CheckerUpgradeable {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165Upgradeable).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981Upgradeable is IERC165Upgradeable {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

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
library MerkleProofUpgradeable {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IAdmin is IERC165Upgradeable {
    function isAdmin(address _account) external view returns (bool);

    function owner() external view returns (address);

    function setPermittedPaymentToken(IERC20Upgradeable _paymentToken, bool _allow) external;

    function isPermittedPaymentToken(IERC20Upgradeable token) external view returns (bool);

    function isOwnedMetaCitizen(address account) external view returns (bool);

    function registerTreasury() external;

    function treasury() external view returns (address);

    function registerMetaCitizen() external;

    function metaCitizen() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ITokenMintERC721 is IERC165Upgradeable {
    function getTokenCounter() external view returns (uint256 tokenId);

    function mint(address receiver, string memory uri) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ITokenMintERC1155 is IERC165Upgradeable {
    function getTokenCounter() external view returns (uint256 tokenId);

    function mint(
        address receiver,
        uint256 amount,
        string memory uri
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ITreasury is IERC165Upgradeable {}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./IMarketplaceManager.sol";

import "./IAdmin.sol";

interface IStakingPool is IERC165Upgradeable {
    function initialize(
        IERC20Upgradeable _stakeToken,
        IERC20Upgradeable _rewardToken,
        IMarketplaceManager _mkpManagerAddrress,
        uint256 _rewardRate,
        uint256 _poolDuration,
        address _pancakeRouter,
        address _busdToken,
        address _aggregatorProxyBUSD_USD, // solhint-disable-line var-name-mixedcase
        IAdmin _admin
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "../interfaces/IMarketplaceManager.sol";
import "../interfaces/IAdmin.sol";

interface IOrder is IERC165Upgradeable {
    function initialize(IMarketplaceManager _marketplace, IAdmin _admin) external;

    function sellAvailableInMarketplace(
        uint256 marketItemId,
        uint256 price,
        uint256 startTime,
        uint256 endTime
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface IMetaCitizen is IERC165Upgradeable {}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface IMetaversusManager is IERC165Upgradeable {}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ITokenERC721 is IERC165Upgradeable {
    function getTokenCounter() external view returns (uint256 tokenId);

    function maxTotalSupply() external view returns (uint256);

    function maxBatch() external view returns (uint256);

    function mint(address _receiver, string memory _uri) external;

    function mintBatch(address _receiver, uint256 _times) external;

    function mintBatchWithUri(address _receiver, string[] memory _uris) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ITokenERC1155 is IERC165Upgradeable {
    function getTokenCounter() external view returns (uint256 tokenId);

    function maxTotalSupply() external view returns (uint256);

    function maxBatch() external view returns (uint256);

    function mint(
        address receiver,
        uint256 amount,
        string memory uri
    ) external;

    function mintBatch(
        address _receiver,
        uint256[] memory _amounts,
        string[] memory _uri
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "../lib/NFTHelper.sol";
import "../interfaces/IAdmin.sol";
import "../interfaces/ITokenMintERC721.sol";
import "../interfaces/ITokenMintERC1155.sol";
import "../interfaces/ITreasury.sol";
import "../interfaces/IMarketplaceManager.sol";
import "../interfaces/Collection/ICollectionFactory.sol";
import "../interfaces/IStakingPool.sol";
import "../interfaces/IOrder.sol";
import "../interfaces/IMetaCitizen.sol";
import "../interfaces/IMetaversusManager.sol";
import "../interfaces/Collection/ITokenERC721.sol";
import "../interfaces/Collection/ITokenERC1155.sol";

library ErrorHelper {
    // Validatable
    error InsufficientBalance(uint256 _available, uint256 _required);
    error InValidOrderContract(address _contract);
    error InValidMetaversusManagerContract(address _contract);
    error InValidTokenCollectionERC721Contract(address _contract);
    error InValidTokenCollectionERC1155Contract(address _contract);
    error InValidAdminContract(address _contract);
    error InValidTokenMintERC721Contract(address _contract);
    error InValidTokenMintERC1155Contract(address _contract);
    error InValidTreasuryContract(address _contract);
    error InValidMarketplaceManagerContract(address _contract);
    error InValidCollectionFactoryContract(address _contract);
    error InValidStakingPoolContract(address _contract);
    error InValidMetaCitizenContract(address _contract);
    //
    error InvalidAddress();
    error InvalidAmount();
    error PaymentTokenIsNotSupported();
    error InvalidWallet(address _contract);
    error CallerIsNotOwnerOrAdmin();
    error CallerIsNotOwner();
    // Order Manage Error
    error InvalidMarketItemId();
    error InvalidNftAddress(address _invalid);
    error InvalidOrderTime();
    error InvalidOwner(address _invalidOwner);
    error UserCanNotOffer();
    error InvalidTokenId(uint256 _invalidId);
    error CanNotUpdatePaymentToken();
    error MarketItemIsNotAvailable();
    error NotInTheOrderTime();
    error RequireOwneMetaCitizenNFT();
    error InvalidOrderId();
    error NotTheSeller(address _available, address _expected);
    error NotTheOwnerOfOrder(address _available, address _expected);
    error OrderIsNotAvailable();
    error OrderIsExpired();
    error NotExpiredYet();
    error InvalidEndTime();
    error TokenIsNotExisted(address _contract, uint256 tokenId);
    error CanNotBuyYourNFT();
    error NotEqualPrice();
    error MarketItemIsNotSelling();
    error EitherNotInWhitelistOrNotOwnMetaCitizenNFT();
    // Metaversus manager Error
    error UserDidNotCreateCollection();
    error InvalidNFTAddress(address _invalidAddress);
    // MarketPlace manager Error
    error InvalidTimeForCreate();
    error CallerIsNotOrderManager();
    error CallerIsNotOrderManagerOrMTVSManager();
    // MetaDrop Error
    error InvalidDropId();
    error ServiceFeeExceedMintFee();
    error InvalidRoot();
    error InvalidMintingSupply();
    error InvalidFundingReceiver();
    error InvalidOwnerForUpdate();
    error DropIsCanceled();
    error NotPermitToMintNow();
    error CanNotMintAnyMore();
    error NotEnoughFee();
    error NotPayBothToken();
    // Collection Error
    error ExceedMaxCollection();
    error CloneCollectionFailed();
    error InvalidMaxCollection();
    error InvalidMaxTotalSupply();
    error InvalidMaxCollectionOfUser();
    // Token721 Error
    error CallerIsNotFactory();
    error ExceedTotalSupply();
    error ExceedMaxMintBatch();
    error InvalidMaxBatch();
    error URIQueryNonExistToken();
    // Token1155 Error
    error InvalidArrayInput();
    // Pool Factory Error
    error ClonePoolFailed();
    // Staking Error
    error NotAllowToClaim();
    error NotTimeForStake();
    error AlreadyRequested();
    error OverLimit();
    error NotAllowToUnstake();
    error MustRequestFirst();
    error ExceedAmount();
    error MustStakeMoreThan500Dollar();
    error MustBuyNFTInMarketplaceFirst();
    // NFT
    error InvalidPaymentToken();
    error AlreadyHaveOne();
    error CanNotBeTransfered();
    error InvalidLength();
    error AlreadyRegister();
    error FailToSendIntoContract();
    error TransferNativeFail();
    error NotTheOwnerOfOffer();

    // Order manager Function
    function _checkValidOrderTime(uint256 _time) internal view {
        if (_time < block.timestamp) {
            revert ErrorHelper.InvalidOrderTime();
        }
    }

    function _checkUserCanOffer(address _to) internal view {
        if (_to == msg.sender) {
            revert ErrorHelper.UserCanNotOffer();
        }
    }

    function _checkValidNFTAddress(address _nftAddress) internal {
        if (_nftAddress == address(0)) {
            revert ErrorHelper.InvalidNftAddress(_nftAddress);
        }
        if (!NFTHelper.isERC721(_nftAddress) && !NFTHelper.isERC1155(_nftAddress)) {
            revert ErrorHelper.InvalidNftAddress(_nftAddress);
        }
    }

    function _checkValidOwnerOf721(
        address _nftAddress,
        uint256 _tokenId,
        address _to
    ) internal view {
        if (IERC721Upgradeable(_nftAddress).ownerOf(_tokenId) != _to) {
            revert ErrorHelper.InvalidOwner(_to);
        }
    }

    function _checkValidOwnerOf1155(
        address _nftAddress,
        uint256 _tokenId,
        address _to,
        uint256 _amount
    ) internal view {
        if (IERC1155Upgradeable(_nftAddress).balanceOf(_to, _tokenId) < _amount) {
            revert ErrorHelper.InvalidAmount();
        }
    }

    function _checkValidAmountOf721(uint256 _amount) internal pure {
        if (_amount != 1) {
            revert ErrorHelper.InvalidAmount();
        }
    }

    function _checkCanUpdatePaymentToken(address _paymentToken, address _expected) internal pure {
        if (_paymentToken != _expected) {
            revert ErrorHelper.CanNotUpdatePaymentToken();
        }
    }

    function _checkValidMarketItem(uint256 _status, uint256 _expected) internal pure {
        if (_status != _expected) {
            revert ErrorHelper.MarketItemIsNotAvailable();
        }
    }

    function _checkInOrderTime(uint256 _start, uint256 _end) internal view {
        if (!(_start <= block.timestamp && block.timestamp <= _end)) {
            revert ErrorHelper.NotInTheOrderTime();
        }
    }

    function _checkInWhiteListAndOwnNFT(
        address _admin,
        address _marketplace,
        uint256 _marketItemId,
        bytes32[] memory _proof
    ) internal view {
        if (
            !(IAdmin(_admin).isOwnedMetaCitizen(msg.sender) &&
                IMarketplaceManager(_marketplace).verify(_marketItemId, _proof, msg.sender))
        ) {
            revert ErrorHelper.EitherNotInWhitelistOrNotOwnMetaCitizenNFT();
        }
    }

    function _checkIsSeller(address _expected) internal view {
        if (_expected != msg.sender) {
            revert ErrorHelper.NotTheSeller(msg.sender, _expected);
        }
    }

    function _checkAvailableOrder(uint256 _status, uint256 _expected) internal pure {
        if (_status != _expected) {
            revert ErrorHelper.OrderIsNotAvailable();
        }
    }

    function _checkInOrderTime(uint256 _time) internal view {
        if (_time < block.timestamp) {
            revert ErrorHelper.OrderIsExpired();
        }
    }

    function _checkExpired(uint256 _time) internal view {
        if (_time >= block.timestamp) {
            revert ErrorHelper.OrderIsExpired();
        }
    }

    function _checkOwnerOfOrder(address _owner) internal view {
        if (_owner != msg.sender) {
            revert ErrorHelper.NotTheOwnerOfOrder(msg.sender, _owner);
        }
    }

    function _checkValidEndTime(uint256 _time) internal view {
        if (_time <= block.timestamp) {
            revert ErrorHelper.InvalidEndTime();
        }
    }

    function _checkExistToken(address _token, uint256 _tokenId) internal {
        if (!NFTHelper.isTokenExist(_token, _tokenId)) {
            revert ErrorHelper.TokenIsNotExisted(_token, _tokenId);
        }
    }

    function _checkMarketItemInSelling(uint256 _start, uint256 _end) internal view {
        if (!(_start <= block.timestamp && block.timestamp <= _end)) {
            revert ErrorHelper.MarketItemIsNotSelling();
        }
    }

    function _checkOwnerOfMarketItem(address _seller) internal view {
        if (_seller == msg.sender) {
            revert ErrorHelper.CanNotBuyYourNFT();
        }
    }

    function _checkEqualPrice(uint256 _price, uint256 _expectedPrice) internal pure {
        if (_price != _expectedPrice) {
            revert ErrorHelper.NotEqualPrice();
        }
    }

    // Marketpalce Manager Function
    function _checkPermittedPaymentToken(address admin, IERC20Upgradeable _paymentToken) internal view {
        if (!IAdmin(admin).isPermittedPaymentToken(_paymentToken)) {
            revert ErrorHelper.PaymentTokenIsNotSupported();
        }
    }

    function _checkValidTimeForCreate(uint256 _startTime, uint256 _endTime) internal view {
        if (!(block.timestamp <= _startTime && _startTime < _endTime)) {
            revert ErrorHelper.InvalidTimeForCreate();
        }
    }

    // Metaversus Manager Function
    function _checkUserCreateCollection(ICollectionFactory _collectionFactory, address _nftAddress) internal view {
        if (!(_collectionFactory.checkCollectionOfUser(msg.sender, _nftAddress))) {
            revert ErrorHelper.UserDidNotCreateCollection();
        }
    }

    // Drop
    function _checkValidFee(uint256 _numerator, uint256 _denominator) internal pure {
        if (_numerator > _denominator) {
            revert ErrorHelper.ServiceFeeExceedMintFee();
        }
    }

    function _checkValidRoot(bytes32 _root) internal pure {
        if (_root == 0) {
            revert ErrorHelper.InvalidRoot();
        }
    }

    function _checkValidReceiver(address _receiver) internal pure {
        if (_receiver == address(0)) {
            revert ErrorHelper.InvalidFundingReceiver();
        }
    }

    function _checkValidSupply(uint256 _supply) internal pure {
        if (_supply == 0) {
            revert ErrorHelper.InvalidMintingSupply();
        }
    }

    function _checkDropReceiver(address _expected) internal view {
        if (msg.sender != _expected) {
            revert ErrorHelper.InvalidOwnerForUpdate();
        }
    }

    function _checkDropCancel(bool _isCancel) internal pure {
        if (_isCancel) {
            revert ErrorHelper.DropIsCanceled();
        }
    }

    function _checkDropPermitMint(bool _canBuy) internal pure {
        if (!_canBuy) {
            revert ErrorHelper.NotPermitToMintNow();
        }
    }

    function _checkDropMintable(uint256 _amount, uint256 _limit) internal pure {
        if (_amount > _limit) {
            revert ErrorHelper.CanNotMintAnyMore();
        }
    }

    function _checkEnoughFee(uint256 _amount) internal view {
        if (msg.value > _amount) {
            revert ErrorHelper.NotEnoughFee();
        }
    }

    function _checkMaxCollectionOfUser(uint256 _amount) internal pure {
        if (_amount == 0) {
            revert ErrorHelper.InvalidMaxCollectionOfUser();
        }
    }

    function _checkMaxTotalSupply(uint256 _amount) internal pure {
        if (_amount == 0) {
            revert ErrorHelper.InvalidMaxTotalSupply();
        }
    }

    function _checkMaxCollection(uint256 _amount) internal pure {
        if (_amount == 0) {
            revert ErrorHelper.InvalidMaxCollection();
        }
    }

    function _checkCloneCollection(address _clone) internal pure {
        if (_clone == address(0)) {
            revert ErrorHelper.CloneCollectionFailed();
        }
    }

    function _checkExceedMaxCollection(uint256 _maxOwner, uint256 _maxOfUser) internal pure {
        if (_maxOwner >= _maxOfUser) {
            revert ErrorHelper.ExceedMaxCollection();
        }
    }

    // Token721 Function
    function _checkMaxBatch(uint256 _max) internal pure {
        if (_max == 0) {
            revert ErrorHelper.InvalidMaxBatch();
        }
    }

    function _checkExceedTotalSupply(uint256 _total, uint256 _supply) internal pure {
        if (_total > _supply) {
            revert ErrorHelper.ExceedTotalSupply();
        }
    }

    function _checkExceedMintTotalSupply(uint256 _total, uint256 _supply) internal pure {
        if (_total >= _supply) {
            revert ErrorHelper.ExceedTotalSupply();
        }
    }

    function _checkEachBatch(uint256 _times, uint256 _supply) internal pure {
        if (!(_times > 0 && _times <= _supply)) {
            revert ErrorHelper.ExceedMaxMintBatch();
        }
    }

    //Token1155 Function
    function _checkValidAmount(uint256 _amount) internal pure {
        if (_amount == 0) {
            revert ErrorHelper.InvalidAmount();
        }
    }

    // Pool Factory Function
    function _checkValidClone(address _clone) internal pure {
        if (_clone == address(0)) {
            revert ErrorHelper.ClonePoolFailed();
        }
    }

    // Staking Pool Function
    function _checkClaimTime(uint256 _start, uint256 duration) internal view {
        if (!(_start + duration > block.timestamp)) {
            revert ErrorHelper.NotAllowToClaim();
        }
    }

    function _checkIsRequested(bool _isRequested) internal pure {
        if (_isRequested) {
            revert ErrorHelper.AlreadyRequested();
        }
    }

    function _checkTimeForStake(uint256 _start, uint256 _duration) internal view {
        if (!(block.timestamp > _start && _start + _duration > block.timestamp)) {
            revert ErrorHelper.NotTimeForStake();
        }
    }

    function _checkUnstakeTime(uint256 _start, uint256 duration) internal view {
        if (!(_start + duration <= block.timestamp && _start != 0)) {
            revert ErrorHelper.NotAllowToUnstake();
        }
    }

    function _checkMustRequested(bool _isRequest, uint256 _unlockedTime) internal view {
        if (!(_isRequest && _unlockedTime <= block.timestamp)) {
            revert ErrorHelper.MustRequestFirst();
        }
    }

    function _checkAcceptRequested(bool _isRequest) internal pure {
        if (!_isRequest) {
            revert ErrorHelper.MustRequestFirst();
        }
    }

    function _checkExceed(uint256 _amount0, uint256 _amount1) internal pure {
        if (_amount0 < _amount1) {
            revert ErrorHelper.ExceedAmount();
        }
    }

    function _checkEqualLength(uint256 _amount0, uint256 _amount1) internal pure {
        if (_amount0 != _amount1) {
            revert ErrorHelper.InvalidLength();
        }
    }

    function _checkAmountOfStake(uint256 _amount) internal pure {
        if (_amount < 5e20) {
            revert ErrorHelper.MustStakeMoreThan500Dollar();
        }
    }

    function _checkAmountOfStake(IAdmin admin, IERC20Upgradeable _paymentToken) internal view {
        if (!(address(_paymentToken) != address(0) && admin.isPermittedPaymentToken(_paymentToken))) {
            revert ErrorHelper.InvalidPaymentToken();
        }
    }

    function _checkAlreadyOwn(uint256 _amount) internal pure {
        if (_amount != 0) {
            revert ErrorHelper.AlreadyHaveOne();
        }
    }

    function _checkValidAddress(address _addr) internal pure {
        if (_addr == address(0)) {
            revert ErrorHelper.InvalidAddress();
        }
    }

    function _checkRegister(address _addr) internal pure {
        if (_addr != address(0)) {
            revert ErrorHelper.AlreadyRegister();
        }
    }

    function _checkOwner(address _addr0, address _addr1) internal pure {
        if (_addr0 != _addr1) {
            revert ErrorHelper.NotTheOwnerOfOffer();
        }
    }
}