/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}

library EnumerableMap {
    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;
        mapping(bytes32 => uint256) _indexes;
    }

    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) {
            // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({_key: key, _value: value}));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) {
            // Equivalent to contains(map, key)
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;
            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key)
        private
        view
        returns (bool)
    {
        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._entries.length;
    }

    function _at(Map storage map, uint256 index)
        private
        view
        returns (bytes32, bytes32)
    {
        require(
            map._entries.length > index,
            "EnumerableMap: index out of bounds"
        );

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key)
        private
        view
        returns (bool, bytes32)
    {
        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    struct UintToAddressMap {
        Map _inner;
    }

    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key)
        internal
        returns (bool)
    {
        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (bool)
    {
        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map)
        internal
        view
        returns (uint256)
    {
        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index)
        internal
        view
        returns (uint256, address)
    {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (bool, address)
    {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return
            address(
                uint160(uint256(_get(map._inner, bytes32(key), errorMessage)))
            );
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

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

interface IERC1155 is IERC165 {
    struct UserAllNFT {
        uint256 balance;
        uint256 tokenId;
        string uri;
        address owner;
        address creator;
        uint256 royaltyFee;
        uint256 merchantFee;
        address merchant;
    }
     struct tokenHolders {
        uint256 balance;
        address userAddress;
    }
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event URI(string value, uint256 indexed id);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function royaltyFee(uint256 tokenId) external view returns (uint256);

    function getMerchant(uint256 tokenId) external view returns (address);
    function merchantFee(uint256 tokenId) external view returns (uint256);

    function getCreator(uint256 tokenId) external view returns (address);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
      function fetchUsersNft(address userAddress) external view returns (UserAllNFT[] memory );
      function getHoldersbyToken(uint256 tokenId) external view returns (tokenHolders[] memory );
      function getHolders(uint256 tokenId) external view returns (uint256[] memory,address[] memory );
}

interface IERC1155MetadataURI is IERC1155 {}

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        virtual
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
    /**
     * @dev Adds two numbers, throws on overflow.
     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    /**
     * @dev Integer modulo of two numbers, truncating the remainder.
     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

contract ERC1155 is ERC165, Context, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    // Mapping from token ID to account balances
    mapping(uint256 => address) private creators;
    mapping(uint256 => uint256) private _royaltyFee;
    mapping(uint256 => address) private merchant;
    mapping(uint256 => uint256) private _merchantFee;
    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(uint256 => address[]) private tokenIdHolders;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    string public tokenURIPrefix;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    string private _name;
    uint256 newItemId = 1;
    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC1155);
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */

    function _setTokenURI(uint256 tokenId, string memory uri) public {
        _tokenURIs[tokenId] = uri;
    }

    /**
        @notice Get the royalty associated with tokenID.
        @param tokenId     ID of the Token.
        @return        royaltyFee of given ID.
     */

    function royaltyFee(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return _royaltyFee[tokenId];
    }

    /**
        @notice Get the creator of given tokenID.
        @param tokenId     ID of the Token.
        @return        creator of given ID.
     */

    function getCreator(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        return creators[tokenId];
    }
/**
        @notice Get the merchant fee associated with tokenID.
        @param tokenId     ID of the Token.
        @return        merchantFee of given ID.
     */

    function merchantFee(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return _merchantFee[tokenId];
    }

    /**
        @notice Get the creator of given tokenID.
        @param tokenId     ID of the Token.
        @return        creator of given ID.
     */

    function getMerchant(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        return merchant[tokenId];
    }
    /**
     * @dev Internal function to set the token URI for all the tokens.
     * @param _tokenURIPrefix string memory _tokenURIPrefix of the tokens.
     */

    function _setTokenURIPrefix(string memory _tokenURIPrefix) public {
        tokenURIPrefix = _tokenURIPrefix;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC1155Metadata: URI query for nonexistent token"
        );
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = tokenURIPrefix;

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    /**
        @notice Get the balance of an account's Tokens.
        @param account  The address of the token holder
        @param tokenId     ID of the Token
        @return        The owner's balance of the Token type requested
     */

    function balanceOf(address account, uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        require(
            _exists(tokenId),
            "ERC1155Metadata: balance query for nonexistent token"
        );
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _balances[tokenId][account];
    }

    /**
        @notice Get the balance of multiple account/token pairs
        @param accounts The addresses of the token holders
        @param ids    ID of the Tokens
        @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
     */

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(
                accounts[i] != address(0),
                "ERC1155: batch balance query for the zero address"
            );
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param operator  Address to add to the set of authorized operators
        @param approved  True if the operator is approved, false to revoke approval
    */

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(
            _msgSender() != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param account     The owner of the Tokens
        @param operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */

    function isApprovedForAll(address account, address operator)
        public
        view
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param from    Source address
        @param to      Target address
        @param tokenId      ID of the token type
        @param amount   Transfer amount
        @param data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(tokenId),
            _asSingletonArray(amount),
            data
        );

        _balances[tokenId][from] = _balances[tokenId][from].sub(
            amount,
            "ERC1155: insufficient balance for transfer"
        );
        _balances[tokenId][to] = _balances[tokenId][to].add(amount);
         PushAddress(tokenId,to);
        emit TransferSingle(operator, from, to, tokenId, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            from,
            to,
            tokenId,
            amount,
            data
        );
    }

    /**
        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if length of `_ids` is not the same as length of `_values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
        MUST revert on any other error.
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param from    Source address
        @param to      Target address
        @param tokenIds     IDs of each token type (order and length must match _values array)
        @param amounts  Transfer amounts per token type (order and length must match _ids array)
        @param data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`
    */

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            tokenIds.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, tokenIds, amounts, data);

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 tokenId = tokenIds[i];
            uint256 amount = amounts[i];

            _balances[tokenId][from] = _balances[tokenId][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[tokenId][to] = _balances[tokenId][to].add(amount);
        }

        emit TransferBatch(operator, from, to, tokenIds, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            tokenIds,
            amounts,
            data
        );
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param tokenId uint256 ID of the token to be minted
     * @param _supply uint256 supply of the token to be minted
     * @param _uri string memory URI of the token to be minted
     * @param _fee uint256 royalty of the token to be minted
     */

    function _mint(
        uint256 tokenId,
        uint256 _supply,
        string memory _uri,
        uint256 _fee,
        uint256 _merchantFees,
        address _merchant
    ) internal {
        require(!_exists(tokenId), "ERC1155: token already minted");
        require(_supply != 0, "Supply should be positive");
        require(bytes(_uri).length > 0, "uri should be set");

        creators[tokenId] = msg.sender;
        _tokenOwners.set(tokenId, msg.sender);
        _royaltyFee[tokenId] = _fee;
        _balances[tokenId][msg.sender] = _supply;
        _setTokenURI(tokenId, _uri);
        _merchantFee[tokenId] = _merchantFees;
         merchant[tokenId] = _merchant;
         PushAddress(tokenId,msg.sender);
        emit TransferSingle(
            msg.sender,
            address(0x0),
            msg.sender,
            tokenId,
            _supply
        );
        emit URI(_uri, tokenId);
    }

    /**
     * @dev version of {_mint}.
     *
     * Requirements:
     *
     * - `tokenIds` and `amounts` must have the same length.
     */

    function _mintBatch(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            tokenIds.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, tokenIds, amounts, data);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _balances[tokenIds[i]][to] = amounts[i].add(
                _balances[tokenIds[i]][to]
            );
             PushAddress(i,msg.sender);
        }

        emit TransferBatch(operator, address(0), to, tokenIds, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            tokenIds,
            amounts,
            data
        );
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use {ERC721-_burn} instead.
     * @param account owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     * @param amount uint256 amount of supply being burned
     */

    function _burn(
        address account,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(
            _exists(tokenId),
            "ERC1155Metadata: burn query for nonexistent token"
        );
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            _asSingletonArray(tokenId),
            _asSingletonArray(amount),
            ""
        );

        _balances[tokenId][account] = _balances[tokenId][account].sub(
            amount,
            "ERC_holderTokens1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), tokenId, amount);
    }

    /**
     * @dev version of {_burn}.
     * Requirements:
     * - `ids` and `amounts` must have the same length.
     */

    function _burnBatch(
        address account,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(
            tokenIds.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            tokenIds,
            amounts,
            ""
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _balances[tokenIds[i]][account] = _balances[tokenIds[i]][account]
                .sub(amounts[i], "ERC1155: burn amount exceeds balance");
        }

        emit TransferBatch(operator, account, address(0), tokenIds, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    tokenId,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver(to).onERC1155Received.selector
                ) {
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
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    tokenIds,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155Receiver(to).onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
       function fetchUsersNft(address userAddress) public override view returns (UserAllNFT[] memory) 
    {
        uint256 totalNft=newItemId;
        uint256 totalUserNFT;
           for (uint256 i = 0; i < totalNft; i++) 
            {
                uint256 supply=_balances[i][userAddress];
                if(supply>0){
                   totalUserNFT++; 
                }

            }
       UserAllNFT[] memory items = new UserAllNFT[](totalUserNFT);
        uint256 currentIndex = 0;
            for (uint256 i = 0; i < totalNft; i++) 
            {
                uint256 balance=_balances[i][userAddress];
                    if (balance>0) {
                        items[currentIndex].balance=balance;
                        items[currentIndex].tokenId=i;
                        items[currentIndex].uri=tokenURI(i);
                        items[currentIndex].creator=getCreator(i);
                        items[currentIndex].royaltyFee=royaltyFee(i);
                        items[currentIndex].merchantFee=merchantFee(i);
                        items[currentIndex].merchant=getMerchant(i);
                        items[currentIndex].owner = userAddress;
                        currentIndex += 1;
                    }
           }
       return items;


    }
       function PushAddress(uint256 tokenId,address user) public {
        address[] memory _addr = tokenIdHolders[tokenId];
         bool isexist=false;
        for (uint256 i=0; i<_addr.length; i++){
            if(user == _addr[i]){
                isexist=true;
                break;
            }
        }
        if(!isexist)
            tokenIdHolders[tokenId].push(user);
    }
     function getHoldersbyToken(uint256 tokenId)  public override view returns (tokenHolders[] memory ) {
        address[] memory _addr = tokenIdHolders[tokenId];
        tokenHolders [] memory items = new tokenHolders[](_addr.length);
           uint256 currentIndex = 0;
        for (uint256 i=0; i<_addr.length; i++){
            items[currentIndex].balance=_balances[tokenId][_addr[i]];
             items[currentIndex].userAddress=_addr[i];
              currentIndex += 1;
        }
       return items;
    }

    function getHolders(uint256 tokenId)  public override view returns (uint256[] memory,address[] memory ) {
        address[] memory _addr = tokenIdHolders[tokenId];
        uint256[] memory _balance;
        address[] memory _address;
        uint256 currentIndex = 0;

        for (uint256 i=0; i<_addr.length; i++){
            if(_balances[tokenId][_addr[i]] > 0){
                _balance[currentIndex] = _balances[tokenId][_addr[i]];
                _address[currentIndex] = _addr[i];
                currentIndex += 1;
            }
        }        
       return (_balance,_address);
    }
    
}

contract LoudNft is ERC1155 {
   
    address public owner;

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory tokenURIPrefix
    ) ERC1155(name, symbol) {
        owner = msg.sender;
        _setTokenURIPrefix(tokenURIPrefix);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /** @dev change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */

    function ownerTransfership(address newOwner)
        public
        onlyOwner
        returns (bool)
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        owner = newOwner;
        return true;
    }

    function setBaseURIPrefix(string memory tokenURIPrefix) public onlyOwner {
        _setTokenURIPrefix(tokenURIPrefix);
    }

    function mint(
        string memory uri,
        uint256 supply,
        uint256 fee,
        uint256 merchantFees,
        address merchants
    ) public {
        _mint(newItemId, supply, uri, fee,merchantFees,merchants);
        newItemId = newItemId + 1;
    }

    function burn(uint256 tokenId, uint256 supply) public {
        _burn(msg.sender, tokenId, supply);
    }

    function burnBatch(
        address account,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) public {
        _burnBatch(account, tokenIds, amounts);
    }
}

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]

// OpenZeppelin Contracts v4.4.0 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

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

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract NFTBuySell is ERC1155Holder, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public _itemIds;
    Counters.Counter public _itemsSold;

    ERC1155 public nftContract;
    IERC20 public tokenContract;

    ERC1155 public nftBatchContract;
    
    address payable owner;

    uint256 public fee;
    address payable marketingWallet;
    
    constructor(address _nftContract, address _tokenContract, uint256 _fee, address _marketingWallet) {
        owner = payable(msg.sender);
        tokenContract = IERC20(_tokenContract);
        nftContract = ERC1155(_nftContract);
        nftBatchContract = ERC1155(_nftContract);
        fee = _fee;
        marketingWallet = payable(_marketingWallet);
    }

 struct nftHolders {
         uint256 balance;
         address userAddress;
         bool inMarket;
    }

    struct MarketItem {
        address nftAddress;
        uint256 itemId;
        uint256 tokenId;
        uint256 totalSupply;
        uint256 soldSupply;
        address seller;
        address owner;
        uint256 price;
        uint256 fee;
        uint256 feeAmount;
        uint256 totalPrice;
        bool sold;
    }
    struct ReturnMarketItem {
        address nftAddress;
        uint256 itemId;
        uint256 tokenId;
        uint256 totalSupply;
        uint256 soldSupply;
        address seller;
        address owner;
        uint256 price;
        uint256 fee;
        uint256 feeAmount;
        uint256 totalPrice;
        bool sold;
        address creator;
        uint256 royaltyFee;
        uint256 merchantFee;
        address merchant;
       uint256 totalMinted;
    }
    struct MarketItemDetails {
        uint256 totalMinted;
    }
    struct UserNFT {
        address nftAddress;        
        uint256 tokenId;
        string uri;
        uint256 quantity;
    }

    

    mapping(uint256 => MarketItem) public idToMarketItem;
    mapping(uint256 => MarketItemDetails) public idToMarketItemDetails;
    event MarketItemCreated(
        address nftAddress,
        uint256 indexed itemId,
        uint256 indexed tokenId,
        uint256 totalSupply,
        uint256 soldSupply,
        address seller,
        address owner,
        uint256 price,
        uint256 fee,
        uint256 feeAmount,
        uint256 totalPrice,
        bool sold
    );
    
    function SetMarketingFee(uint256 _fee) public  {
        require(msg.sender == owner, "Only owner can update fee");
        fee = _fee;
    } 

    function SetMarketingWallet(address _marketingWallet) public  {
        require(msg.sender == owner, "Only owner can update wallet");
        marketingWallet = payable(_marketingWallet);
    } 

    function SetnftBatchContract(address _nftBatchContract) public  {
        require(msg.sender == owner, "Only owner can update wallet");
        nftBatchContract = ERC1155(_nftBatchContract);
    } 

    /* Places an item for sale on the marketplace */
    function createMarketItem(uint256 tokenId, uint256 price, uint256 totalSupply, address _nftContract,uint256 totalMinted) public nonReentrant {
        require(price > 0, "Price must be cannot be zero");
        require(totalSupply > 0, "Price must be cannot be zero");

        nftContract = ERC1155(_nftContract);        

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        uint256 calFee = (price * fee) / 100;
        uint256 totalPrice = price + calFee;

        uint256 soldSupply = 0;

        idToMarketItem[itemId] = MarketItem(
            _nftContract,
            itemId,
            tokenId,
            totalSupply,
            soldSupply,
            msg.sender,
            address(0),
            price,
            fee,
            calFee,
            totalPrice,
            false
        );
        idToMarketItemDetails[itemId]=MarketItemDetails(totalMinted);

        nftContract.safeTransferFrom(msg.sender, address(this), tokenId, totalSupply, "");

        emit MarketItemCreated(
            _nftContract,
            itemId,
            tokenId,
            totalSupply,
            soldSupply,
            msg.sender,
            address(0),
            price,
            fee,
            calFee,
            totalPrice,
            false
        );
    }

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 itemId, uint256 purchaseQty) public nonReentrant {
        uint256 totalPrice = idToMarketItem[itemId].totalPrice * purchaseQty;
        uint256 price = idToMarketItem[itemId].price * purchaseQty;
        uint256 totalSupply = idToMarketItem[itemId].totalSupply;
        uint256 soldSupply = idToMarketItem[itemId].soldSupply;
       
        require(
            tokenContract.balanceOf(msg.sender) >= totalPrice,
            "Token Balance is low"
        );

         require(
            purchaseQty <= (totalSupply - soldSupply),
            "Purchase quantity is grater then remaining quantity"
        );

        nftContract = ERC1155(idToMarketItem[itemId].nftAddress);

        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;
        //uint256 royaltyFee = nftContract.royaltyFee(tokenId);
        uint256 royaltyFeeAmount = (price / 100) * nftContract.royaltyFee(tokenId);
        uint256 feeAmount = idToMarketItem[itemId].feeAmount * purchaseQty;
        uint256 merchantFeeAmount =(price / 100) * nftContract.merchantFee(tokenId);        
        
        giveRoyalty(tokenId, royaltyFeeAmount);
        giveMerchantRoyalty(tokenId, merchantFeeAmount);
        tokenContract.transferFrom(msg.sender, marketingWallet, feeAmount); 

        uint256 actualPrice = totalPrice - royaltyFeeAmount - feeAmount - merchantFeeAmount;
        
        tokenContract.transferFrom(msg.sender, seller, actualPrice);

         nftContract.safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            purchaseQty,
            ""
        );        
        
        if(totalSupply == soldSupply + purchaseQty){
            idToMarketItem[itemId].sold = true;
            idToMarketItem[itemId].owner = address(this);
            _itemsSold.increment();
        }

        idToMarketItem[itemId].soldSupply += purchaseQty;
        
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (ReturnMarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;
      string memory _error;
         bytes memory _reason;
        ReturnMarketItem[] memory items = new ReturnMarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                 ERC1155  _nftContract = ERC1155(idToMarketItem[currentId].nftAddress);
                try _nftContract.royaltyFee(idToMarketItem[currentId].tokenId) returns ( uint256 royaltyFee) {
                items[currentIndex].royaltyFee=royaltyFee;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
             try _nftContract.getCreator(idToMarketItem[currentId].tokenId) returns ( address creator) {
                items[currentIndex].creator=creator;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
              try _nftContract.merchantFee(idToMarketItem[currentId].tokenId) returns ( uint256 merchantFee) {
                items[currentIndex].merchantFee=merchantFee;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
             try _nftContract.getMerchant(idToMarketItem[currentId].tokenId) returns ( address merchant) {
                items[currentIndex].merchant=merchant;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }  
                 items[currentIndex].nftAddress=idToMarketItem[currentId].nftAddress;
                 items[currentIndex].itemId=idToMarketItem[currentId].itemId;
                 items[currentIndex].tokenId=idToMarketItem[currentId].tokenId;
                 items[currentIndex].totalSupply=idToMarketItem[currentId].totalSupply;
                 items[currentIndex].soldSupply=idToMarketItem[currentId].soldSupply;
                 items[currentIndex].seller=idToMarketItem[currentId].seller;
                 items[currentIndex].owner=idToMarketItem[currentId].owner;   
                 items[currentIndex].price=idToMarketItem[currentId].price;
                 items[currentIndex].fee=idToMarketItem[currentId].fee;
                 items[currentIndex].feeAmount=idToMarketItem[currentId].feeAmount;
                 items[currentIndex].totalPrice=idToMarketItem[currentId].totalPrice;
                 items[currentIndex].sold=idToMarketItem[currentId].sold;
                items[currentIndex].totalMinted=idToMarketItemDetails[currentId].totalMinted; 
                 currentIndex += 1;
                 
            }
        }
        return items;
    }

     /* Returns all market items */
    function fetchAllMarketItems() public view returns (ReturnMarketItem[] memory) {
        uint256 itemCount = _itemIds.current();        
        uint256 currentIndex = 0;
        string memory _error;
         bytes memory _reason;
        ReturnMarketItem[] memory items=new ReturnMarketItem[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {            
            uint256 currentId = i + 1;      
            ERC1155  _nftContract = ERC1155(idToMarketItem[currentId].nftAddress);
                      
            try _nftContract.royaltyFee(idToMarketItem[currentId].tokenId) returns ( uint256 royaltyFee) {
                items[currentIndex].royaltyFee=royaltyFee;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
             try _nftContract.getCreator(idToMarketItem[currentId].tokenId) returns ( address creator) {
                items[currentIndex].creator=creator;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
              try _nftContract.merchantFee(idToMarketItem[currentId].tokenId) returns ( uint256 merchantFee) {
                items[currentIndex].merchantFee=merchantFee;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
             try _nftContract.getMerchant(idToMarketItem[currentId].tokenId) returns ( address merchant) {
                items[currentIndex].merchant=merchant;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }            
          
            items[currentIndex].nftAddress=idToMarketItem[currentId].nftAddress;
            items[currentIndex].itemId=idToMarketItem[currentId].itemId;
            items[currentIndex].tokenId=idToMarketItem[currentId].tokenId;
            items[currentIndex].totalSupply=idToMarketItem[currentId].totalSupply;
            items[currentIndex].soldSupply=idToMarketItem[currentId].soldSupply;
            items[currentIndex].seller=idToMarketItem[currentId].seller;
            items[currentIndex].owner=idToMarketItem[currentId].owner;   
            items[currentIndex].price=idToMarketItem[currentId].price;
            items[currentIndex].fee=idToMarketItem[currentId].fee;
            items[currentIndex].feeAmount=idToMarketItem[currentId].feeAmount;
            items[currentIndex].totalPrice=idToMarketItem[currentId].totalPrice;
            items[currentIndex].sold=idToMarketItem[currentId].sold;
            items[currentIndex].totalMinted=idToMarketItemDetails[currentId].totalMinted;                
            currentIndex += 1;            
        }
        return items;
    }

    /* Returns onlyl items that a user has purchased */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Returns only items a user has created */
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
       uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
    
    function CancelMarketSale(uint256 itemId) public nonReentrant {
           require(
            idToMarketItem[itemId].seller == msg.sender || msg.sender==owner,
            "Caller not an owner of the market item"
        );
        require(idToMarketItem[itemId].sold == false, "NFT already sold.");        
        
        uint256 totalSupply = idToMarketItem[itemId].totalSupply;
        uint256 soldSupply = idToMarketItem[itemId].soldSupply;
       
        uint256 purchaseQty = (totalSupply - soldSupply);

        nftContract = ERC1155(idToMarketItem[itemId].nftAddress);

        uint256 tokenId = idToMarketItem[itemId].tokenId;
        address seller = idToMarketItem[itemId].seller;        

        nftContract.safeTransferFrom(
            address(this),
            seller,
            tokenId,
            purchaseQty,
            ""
        );        
        
        idToMarketItem[itemId].soldSupply += purchaseQty;
        idToMarketItem[itemId].sold = true;
        idToMarketItem[itemId].owner = address(this);
        _itemsSold.increment();
        
    }

    function fetchUserNFTs(address userAddress, uint256 tokenId) public view returns (UserNFT[] memory) {
        uint256 itemCount = nftBatchContract.balanceOf(userAddress,tokenId);

        UserNFT[] memory items = new UserNFT[](1);
                    
        items[0].nftAddress = address(nftBatchContract);        
        items[0].tokenId = tokenId;
        items[0].uri = nftBatchContract.tokenURI(tokenId);
        items[0].quantity = itemCount;

        return items;
    }
  
    function giveRoyalty(uint256 _id, uint256 _amount) internal returns (bool) {
        address creator = nftContract.getCreator(_id);
        tokenContract.transferFrom(msg.sender, creator, _amount);
        return true;
    }
     function giveMerchantRoyalty(uint256 _id, uint256 _amount) internal returns (bool) {
        address merchant = nftContract.getMerchant(_id);
        tokenContract.transferFrom(msg.sender, merchant, _amount);
        return true;
    }
     function fetchUserAllNFTs(address userAddress) public view returns (ReturnMarketItem[] memory) {
         uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
         string memory _error;
         bytes memory _reason;
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == userAddress) {
                itemCount += 1;
            }
        }

        ReturnMarketItem[] memory items = new ReturnMarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == userAddress) {
                uint256 currentId = i + 1;
            ERC1155  _nftContract = ERC1155(idToMarketItem[currentId].nftAddress);
             try _nftContract.royaltyFee(idToMarketItem[currentId].tokenId) returns ( uint256 royaltyFee) {
                items[currentIndex].royaltyFee=royaltyFee;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
             try _nftContract.getCreator(idToMarketItem[currentId].tokenId) returns ( address creator) {
                items[currentIndex].creator=creator;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
              try _nftContract.merchantFee(idToMarketItem[currentId].tokenId) returns ( uint256 merchantFee) {
                items[currentIndex].merchantFee=merchantFee;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
             try _nftContract.getMerchant(idToMarketItem[currentId].tokenId) returns ( address merchant) {
                items[currentIndex].merchant=merchant;
                
            }
            catch Error(string memory reason) {
                _error=reason;
            } 
            catch (bytes memory reason) {
                _reason=reason;
            }
        
            items[currentIndex].nftAddress=idToMarketItem[currentId].nftAddress;
            items[currentIndex].itemId=idToMarketItem[currentId].itemId;
            items[currentIndex].tokenId=idToMarketItem[currentId].tokenId;
            items[currentIndex].totalSupply=idToMarketItem[currentId].totalSupply;
            items[currentIndex].soldSupply=idToMarketItem[currentId].soldSupply;
            items[currentIndex].seller=idToMarketItem[currentId].seller;
            items[currentIndex].owner=idToMarketItem[currentId].owner;   
            items[currentIndex].price=idToMarketItem[currentId].price;
            items[currentIndex].fee=idToMarketItem[currentId].fee;
            items[currentIndex].feeAmount=idToMarketItem[currentId].feeAmount;
            items[currentIndex].totalPrice=idToMarketItem[currentId].totalPrice;
            items[currentIndex].sold=idToMarketItem[currentId].sold;
            items[currentIndex].totalMinted=idToMarketItemDetails[currentId].totalMinted;  
                currentIndex += 1;
            }
        }
        return (items);
    }
     function fetchTokenHolders(uint256 tokenId) public view returns (nftHolders[] memory) {
        uint256[] memory _balance;
        address[] memory _address;
        (_balance,_address) = nftContract.getHolders(tokenId);
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount=_address.length;
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].tokenId == tokenId && !idToMarketItem[i + 1].sold) {
              ++itemCount;
            }
        }
        uint256 currentIndex = 0;        
        nftHolders[] memory items=new nftHolders[](itemCount);
        for (uint256 i = 0; i < _address.length; i++) {
            items[currentIndex].userAddress = _address[i];
            items[currentIndex].balance = _balance[i];
            items[currentIndex].inMarket=false;
            ++currentIndex; 
        }

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].tokenId == tokenId && !idToMarketItem[i + 1].sold) {
                items[currentIndex].userAddress = idToMarketItem[i + 1].seller;
                items[currentIndex].balance = idToMarketItem[i + 1].totalSupply- idToMarketItem[i + 1].soldSupply;
                items[currentIndex].inMarket=true;
                ++currentIndex;
            }
        }
       
        return (items);
    }
  
}