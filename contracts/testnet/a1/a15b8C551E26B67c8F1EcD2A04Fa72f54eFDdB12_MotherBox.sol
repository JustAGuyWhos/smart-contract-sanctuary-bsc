/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

pragma solidity 0.6.12;

library ECDSA {
  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature`. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   *
   * Documentation for signature generation:
   * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
   * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
   */
  function recover(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address)
  {
    // Check the signature length
    // - case 65: r,s,v signature (standard)
    // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
    if (signature.length == 65) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      // ecrecover takes the signature parameters, and the only way to get them
      // currently is to use assembly.
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
      return recover(hash, v, r, s);
    } else if (signature.length == 64) {
      bytes32 r;
      bytes32 vs;
      // ecrecover takes the signature parameters, and the only way to get them
      // currently is to use assembly.
      assembly {
        r := mload(add(signature, 0x20))
        vs := mload(add(signature, 0x40))
      }
      return recover(hash, r, vs);
    } else {
      revert("ECDSA: invalid signature length");
    }
  }

  /**
   * @dev Overload of {ECDSA-recover} that receives the `r` and `vs` short-signature fields separately.
   *
   * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
   *
   * _Available since v4.2._
   */
  function recover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address) {
    bytes32 s;
    uint8 v;
    assembly {
      s := and(
        vs,
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
      )
      v := add(shr(255, vs), 27)
    }
    return recover(hash, v, r, s);
  }

  /**
   * @dev Overload of {ECDSA-recover} that receives the `v`, `r` and `s` signature fields separately.
   */
  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
    // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
    // signatures from current libraries generate a unique signature with an s-value in the lower half order.
    //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
    // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
    // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
    // these malleable signatures as well.
    require(
      uint256(s) <=
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
      "ECDSA: invalid signature 's' value"
    );
    require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

    // If the signature is valid (and not malleable), return the signer address
    address signer = ecrecover(hash, v, r, s);
    require(signer != address(0), "ECDSA: invalid signature");

    return signer;
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from a `hash`. This
   * produces hash corresponding to the one signed with the
   * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
   * JSON-RPC method as part of EIP-191.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return
      keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

  /**
   * @dev Returns an Ethereum Signed Typed Data, created from a
   * `domainSeparator` and a `structHash`. This produces hash corresponding
   * to the one signed with the
   * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
   * JSON-RPC method as part of EIP-712.
   *
   * See {recover}.
   */
  function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
    internal
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
      uint256 toDeleteIndex = keyIndex - 1;
      uint256 lastIndex = map._entries.length - 1;
      MapEntry storage lastEntry = map._entries[lastIndex];
      map._entries[toDeleteIndex] = lastEntry;
      map._indexes[lastEntry._key] = toDeleteIndex + 1;
      map._entries.pop();
      delete map._indexes[key];
      return true;
    } else {
      return false;
    }
  }

  function _contains(Map storage map, bytes32 key) private view returns (bool) {
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
    require(map._entries.length > index, "EnumerableMap: index out of bounds");

    MapEntry storage entry = map._entries[index];
    return (entry._key, entry._value);
  }

  function _tryGet(Map storage map, bytes32 key)
    private
    view
    returns (bool, bytes32)
  {
    uint256 keyIndex = map._indexes[key];
    if (keyIndex == 0) return (false, 0);
    return (true, map._entries[keyIndex - 1]._value);
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
    require(keyIndex != 0, errorMessage);
    return map._entries[keyIndex - 1]._value;
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
      address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
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
      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;
      bytes32 lastvalue = set._values[lastIndex];
      set._values[toDeleteIndex] = lastvalue;
      set._indexes[lastvalue] = toDeleteIndex + 1;
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

  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    require(set._values.length > index, "EnumerableSet: index out of bounds");
    return set._values[index];
  }

  struct Bytes32Set {
    Set _inner;
  }

  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
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

  function add(AddressSet storage set, address value) internal returns (bool) {
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

  function remove(UintSet storage set, uint256 value) internal returns (bool) {
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

library Address {
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
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
    return functionCallWithValue(target, data, 0, errorMessage);
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
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, "Address: low-level static call failed");
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return
      functionDelegateCall(
        target,
        data,
        "Address: low-level delegate call failed"
      );
  }

  function functionDelegateCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
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

library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }

  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }

  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }

  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }

  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC165 is IERC165 {
  bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
  mapping(bytes4 => bool) private _supportedInterfaces;

  constructor() internal {
    _registerInterface(_INTERFACE_ID_ERC165);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _supportedInterfaces[interfaceId];
  }

  function _registerInterface(bytes4 interfaceId) internal virtual {
    require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
    _supportedInterfaces[interfaceId] = true;
  }
}

interface IERC721 is IERC165 {
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );
  event Approval(
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenId
  );
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  function balanceOf(address owner) external view returns (uint256 balance);

  function ownerOf(uint256 tokenId) external view returns (address owner);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function approve(address to, uint256 tokenId) external;

  function getApproved(uint256 tokenId)
    external
    view
    returns (address operator);

  function setApprovalForAll(address operator, bool _approved) external;

  function isApprovedForAll(address owner, address operator)
    external
    view
    returns (bool);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;
}

interface IERC721Enumerable is IERC721 {
  function totalSupply() external view returns (uint256);

  function tokenOfOwnerByIndex(address owner, uint256 index)
    external
    view
    returns (uint256 tokenId);

  function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Metadata is IERC721 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

abstract contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() internal {
    _status = _NOT_ENTERED;
  }

  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    return msg.data;
  }
}

abstract contract Auth {
  address public owner;
  mapping(address => bool) internal authorizations;

  constructor(address _owner) public {
    owner = _owner;
    authorizations[_owner] = true;
  }

  modifier onlyOwner() {
    require(isOwner(msg.sender), "!OWNER");
    _;
  }

  modifier authorized() {
    require(isAuthorized(msg.sender), "!AUTHORIZED");
    _;
  }

  function authorize(address adr) public onlyOwner {
    authorizations[adr] = true;
  }

  function unauthorize(address adr) public onlyOwner {
    authorizations[adr] = false;
  }

  function isOwner(address account) public view returns (bool) {
    return account == owner;
  }

  function isAuthorized(address adr) public view returns (bool) {
    return authorizations[adr];
  }

  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;
    emit OwnershipTransferred(adr);
  }

  event OwnershipTransferred(address owner);
}

contract ERC721 is
  Context,
  ERC165,
  IERC721,
  IERC721Metadata,
  IERC721Enumerable,
  Auth,
  ReentrancyGuard
{
  using SafeMath for uint256;
  using Address for address;
  using EnumerableSet for EnumerableSet.UintSet;
  using EnumerableMap for EnumerableMap.UintToAddressMap;
  // using Strings for uint256;
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
  mapping(address => EnumerableSet.UintSet) private _holderTokens;
  EnumerableMap.UintToAddressMap private _tokenOwners;
  mapping(uint256 => address) private _tokenApprovals;
  mapping(address => mapping(address => bool)) private _operatorApprovals;
  string private _name;
  string private _symbol;
  mapping(uint256 => string) private _tokenURIs;
  string private _baseURI;
  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
  bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

  constructor(string memory name_, string memory symbol_)
    public
    Auth(msg.sender)
  {
    _name = name_;
    _symbol = symbol_;
    _registerInterface(_INTERFACE_ID_ERC721);
    _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
  }

  function balanceOf(address owner)
    public
    view
    virtual
    override
    returns (uint256)
  {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _holderTokens[owner].length();
  }

  function ownerOf(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
  {
    return
      _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory _tokenURI = _tokenURIs[tokenId];
    string memory base = baseURI();
    if (bytes(base).length == 0) {
      return _tokenURI;
    }
    if (bytes(_tokenURI).length > 0) {
      return string(abi.encodePacked(base, _tokenURI));
    }
    return string(abi.encodePacked(base, tokenId));
  }

  function baseURI() public view virtual returns (string memory) {
    return _baseURI;
  }

  function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _holderTokens[owner].at(index);
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _tokenOwners.length();
  }

  function tokenByIndex(uint256 index)
    public
    view
    virtual
    override
    returns (uint256)
  {
    (uint256 tokenId, ) = _tokenOwners.at(index);
    return tokenId;
  }

  function approve(address to, uint256 tokenId) public virtual override {
    address owner = ERC721.ownerOf(tokenId);
    require(to != owner, "ERC721: approval to current owner");

    require(
      _msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
      "ERC721: approve caller is not owner nor approved for all"
    );

    _approve(to, tokenId);
  }

  function getApproved(uint256 tokenId)
    public
    view
    virtual
    override
    returns (address)
  {
    require(_exists(tokenId), "ERC721: approved query for nonexistent token");

    return _tokenApprovals[tokenId];
  }

  function setApprovalForAll(address operator, bool approved)
    public
    virtual
    override
  {
    require(operator != _msgSender(), "ERC721: approve to caller");

    _operatorApprovals[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }

  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );

    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {
    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    _safeTransfer(from, to, tokenId, _data);
  }

  function _safeTransfer(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) internal virtual {
    _transfer(from, to, tokenId);
    require(
      _checkOnERC721Received(from, to, tokenId, _data),
      "ERC721: transfer to non ERC721Receiver implementer"
    );
  }

  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return _tokenOwners.contains(tokenId);
  }

  function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    virtual
    returns (bool)
  {
    require(_exists(tokenId), "ERC721: operator query for nonexistent token");
    address owner = ERC721.ownerOf(tokenId);
    return (spender == owner ||
      getApproved(tokenId) == spender ||
      ERC721.isApprovedForAll(owner, spender));
  }

  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

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

  function _mint(address to, uint256 tokenId) internal virtual {
    require(to != address(0), "ERC721: mint to the zero address");
    require(!_exists(tokenId), "ERC721: token already minted");

    _beforeTokenTransfer(address(0), to, tokenId);

    _holderTokens[to].add(tokenId);

    _tokenOwners.set(tokenId, to);

    emit Transfer(address(0), to, tokenId);
  }

  function holderTokensAdd(address to, uint256 tokenId) internal {
    _holderTokens[to].add(tokenId);
  }

  function holderTokensRemove(address to, uint256 tokenId) internal {
    _holderTokens[to].remove(tokenId);
  }

  function _burn(uint256 tokenId) internal virtual {
    address owner = ERC721.ownerOf(tokenId);

    _beforeTokenTransfer(owner, address(0), tokenId);
    _approve(address(0), tokenId);
    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }

    _holderTokens[owner].remove(tokenId);

    _tokenOwners.remove(tokenId);

    emit Transfer(owner, address(0), tokenId);
  }

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {
    require(
      ERC721.ownerOf(tokenId) == from,
      "ERC721: transfer of token that is not own"
    );
    require(to != address(0), "ERC721: transfer to the zero address");

    _beforeTokenTransfer(from, to, tokenId);
    _approve(address(0), tokenId);

    _holderTokens[from].remove(tokenId);
    _holderTokens[to].add(tokenId);

    _tokenOwners.set(tokenId, to);

    emit Transfer(from, to, tokenId);
  }

  function setTokenOwners(uint256 _tokenId, address _owner) internal {
    _tokenOwners.set(_tokenId, _owner);
  }

  function _setTokenURI(uint256 tokenId, string memory _tokenURI)
    internal
    virtual
  {
    require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }

  function mySetTokenURI(uint256 tokenId, string memory _tokenURI)
    public
    virtual
    authorized
  {
    require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }

  function _setBaseURI(string memory baseURI_) internal virtual {
    _baseURI = baseURI_;
  }

  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) private returns (bool) {
    if (!to.isContract()) {
      return true;
    }

    bytes memory returndata =
      to.functionCall(
        abi.encodeWithSelector(
          IERC721Receiver(to).onERC721Received.selector,
          _msgSender(),
          from,
          tokenId,
          _data
        ),
        "ERC721: transfer to non ERC721Receiver implementer"
      );
    bytes4 retval = abi.decode(returndata, (bytes4));
    return (retval == _ERC721_RECEIVED);
  }

  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

  receive() external payable {}

  function rescueWrongTokens(address payable _recipient) public onlyOwner {
    _recipient.transfer(address(this).balance);
  }

  function rescueWrongERC20(address erc20Address) public onlyOwner {
    IERC20(erc20Address).transfer(
      msg.sender,
      IERC20(erc20Address).balanceOf(address(this))
    );
  }

  function get_holderTokens(
    address _owner,
    uint256 index,
    uint256 size
  ) public view returns (uint256[] memory) {
    uint256 length = _holderTokens[_owner].length();
    require(length.add(size).sub(size.mul(index)) >= 0, "forbidden");
    uint256 limit = length < size.mul(index) ? length : size.mul(index);
    uint256 arraySize =
      length < size.mul(index) ? length.add(size).sub(size.mul(index)) : size;
    uint256[] memory a = new uint256[](arraySize);
    for (uint256 i = 0; i < limit.sub(size.mul(index.sub(1))); i++) {
      uint256 tokenId = _holderTokens[_owner].at(size.mul(index.sub(1)).add(i));
      a[i] = tokenId;
    }
    return a;
  }
}

contract BaseERC721BlindBox is ERC721 {
  // uint256 public level;
  // bool private _blindBoxOpened = false;
  mapping(uint256 => bool) public _blindBoxOpened;
  mapping(string => mapping(uint256 => uint256)) public properties;
  mapping(address => EnumerableSet.UintSet) private _blindboxholderTokens;

  // address public manager;
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );
  event setBlindBoxOpenedEvent(uint256 tokenId, bool _status, address owner);
  event BatchSetBlindBoxOpened(uint256[] tokenIds, bool _status, address owner);

  constructor(
    string memory name,
    string memory symbol,
    address payable manager
  ) public ERC721(name, symbol) {
    transferOwnership(manager);
  }

  function blindboxbalanceOf(address owner) public view returns (uint256) {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _blindboxholderTokens[owner].length();
  }

  function getBlindBoxOpened(uint256 _tokenId) public view returns (bool) {
    return _blindBoxOpened[_tokenId];
  }

  function blindboxtokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    returns (uint256)
  {
    return _blindboxholderTokens[owner].at(index);
  }

  function getBlindBoxHolderTokens(
    address _owner,
    uint256 index,
    uint256 size
  ) public view returns (uint256[] memory) {
    uint256 length = _blindboxholderTokens[_owner].length();
    require(length.add(size).sub(size.mul(index)) >= 0, "forbidden");
    uint256 limit = length < size.mul(index) ? length : size.mul(index);
    uint256 arraySize =
      length < size.mul(index) ? length.add(size).sub(size.mul(index)) : size;
    uint256[] memory a = new uint256[](arraySize);
    for (uint256 i = 0; i < limit.sub(size.mul(index.sub(1))); i++) {
      uint256 tokenId =
        _blindboxholderTokens[_owner].at(size.mul(index.sub(1)).add(i));
      a[i] = tokenId;
    }
    return a;
  }

  function setProperty(
    string memory key,
    uint256 tokenId,
    uint256 value
  ) public authorized returns (bool) {
    properties[key][tokenId] = value;
    return true;
  }

  function getProperty(string memory key, uint256 tokenId)
    public
    view
    authorized
    returns (uint256)
  {
    return properties[key][tokenId];
  }

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    if (getBlindBoxOpened(tokenId)) {
      super._transfer(from, to, tokenId);
    } else {
      require(
        ERC721.ownerOf(tokenId) == from,
        "ERC721: transfer of token that is not own"
      );
      require(to != address(0), "ERC721: transfer to the zero address");
      _beforeTokenTransfer(from, to, tokenId);
      _approve(address(0), tokenId);
      _blindboxholderTokens[from].remove(tokenId);
      _blindboxholderTokens[to].add(tokenId);
      setTokenOwners(tokenId, to);
      emit Transfer(from, to, tokenId);
    }
  }

  function mint(address to, uint256 tokenId) public authorized {
    if (getBlindBoxOpened(tokenId)) {
      super._mint(to, tokenId);
    } else {
      require(to != address(0), "ERC721: mint to the zero address");
      require(!_exists(tokenId), "ERC721: token already minted");

      _beforeTokenTransfer(address(0), to, tokenId);
      _blindboxholderTokens[to].add(tokenId);
      setTokenOwners(tokenId, to);
      emit Transfer(address(0), to, tokenId);
    }
  }

  function setBlindBoxOpened(uint256 tokenId, bool _status) public {
    require(
      ownerOf(tokenId) == msg.sender || isAuthorized(msg.sender),
      "BaseERC721BlindBox: only owner can do this action"
    );
    require(_blindBoxOpened[tokenId] == false, "already opened");
    _blindBoxOpened[tokenId] = _status;
    if (_status) {
      _blindboxholderTokens[msg.sender].remove(tokenId);
      holderTokensAdd(msg.sender, tokenId);
      emit setBlindBoxOpenedEvent(tokenId, _status, msg.sender);
    }
  }

  function batchSetBlindBoxOpened(uint256[] memory tokenIds, bool _status)
    public
  {
    for (uint256 i = 0; i < tokenIds.length; i++) {
      require(
        ownerOf(tokenIds[i]) == msg.sender || isAuthorized(msg.sender),
        "BaseERC721BlindBox: only owner can do this action"
      );
      require(_blindBoxOpened[tokenIds[i]] == false, "already opened");
      _blindBoxOpened[tokenIds[i]] = _status;
      if (_status) {
        _blindboxholderTokens[msg.sender].remove(tokenIds[i]);
        holderTokensAdd(msg.sender, tokenIds[i]);
      }
    }
    emit BatchSetBlindBoxOpened(tokenIds, _status, msg.sender);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    if (_blindBoxOpened[tokenId]) {
      return super.tokenURI(tokenId);
    } else {
      return "ipfs://QmexqcLDvoP6HCTtSGumG3yzhZdH8guvV3z3kReCvf2QKn";
    }
  }

  function mySetTokenURI(uint256 tokenId, string memory _tokenURI)
    public
    virtual
    override
    authorized
  {
    require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
    _setTokenURI(tokenId, _tokenURI);
  }

  function burn(uint256 tokenId) public returns (bool) {
    require(_isApprovedOrOwner(msg.sender, tokenId), "forbidden");
    super._burn(tokenId);
    return true;
  }
}

contract MotherBox is ERC721 {
  uint256 public id = 100000;
  uint256 public priceByBnb = 1e15;
  uint256[] public blindboxTokenIds;
  address payable bnbAddress;
  BaseERC721BlindBox public blindbox;
  address public canBuyCoin = 0x9bA3363253Ff27EDEed2F28d82A0C6BfBad434f3;
  uint256 public priceByGflokiV2 = 1e4;
  uint256 public max = 1002500000;
  uint256 public buyLimit = 100;
  mapping(address => uint256) private nonce;

  // uint256 public nonce;
  constructor(string memory name, string memory symbol)
    public
    ERC721(name, symbol)
  {
    blindbox = new BaseERC721BlindBox(name, symbol, msg.sender);
  }

  event CreateTreasureBox(
    address sender,
    address nft,
    uint256 tokenId,
    uint256 n,
    uint256 msgnonce
  );
  event BatchBlindBoxCreated(
    address sender,
    address nft,
    uint256 tokenId,
    uint256 n,
    bool opened
  );

  function getNonce(address _address) public view returns (uint256) {
    return nonce[_address];
  }

  function getRemain() public view returns (uint256) {
    uint256 _id = id;
    uint256 _max = max;
    return _max - _id;
  }

  function setCanBuyCoin(address coin, uint256 _priceByGflokiV2)
    public
    onlyOwner
    returns (bool)
  {
    canBuyCoin = coin;
    priceByGflokiV2 = _priceByGflokiV2;
    return true;
  }

  function setBnbReceiveAddress(address payable _bnbAddress)
    public
    onlyOwner
    returns (bool)
  {
    bnbAddress = _bnbAddress;
    return true;
  }

  function setPriceBlindBox(
    uint256 _priceByBnb,
    uint256 _priceByGflokiV2,
    uint256 _buyLimit,
    uint256 _releaseCount
  ) public authorized returns (bool) {
    if (_priceByBnb > 0) priceByBnb = _priceByBnb;
    if (_priceByGflokiV2 > 0) priceByGflokiV2 = _priceByGflokiV2;
    if (_buyLimit > 0) buyLimit = _buyLimit;
    if (_releaseCount > 0) max = _releaseCount + id;
    return true;
  }

  function setMax(uint256 releaseCount) public onlyOwner returns (bool) {
    max = releaseCount + id;
    return true;
  }

  function createNewBlindBox()
    public
    authorized
    nonReentrant
    returns (address, uint256)
  {
    uint256 tokenId = ++id;
    BaseERC721BlindBox box = blindbox;
    box.mint(msg.sender, tokenId);
    blindboxTokenIds.push(tokenId);
    emit BatchBlindBoxCreated(msg.sender, address(box), tokenId, 1, false);
    return (address(box), tokenId);
  }

  function _batchCreateNewBlindBox_(uint256 n)
    public
    nonReentrant
    returns (
      address,
      uint256,
      uint256
    )
  {
    require(id + n <= max, "exceed max");
    require(n > 0 && n <= buyLimit, "n must between 1 and 10 int");
    uint256 tokenId = id;
    id = id + n;
    BaseERC721BlindBox box = blindbox;
    for (uint256 i = 0; i < n; i++) {
      box.mint(msg.sender, tokenId + 1 + i);
      blindboxTokenIds.push(tokenId + 1 + i);
    }
    IERC20(canBuyCoin).transferFrom(
      msg.sender,
      address(this),
      priceByGflokiV2.mul(n)
    );
    emit BatchBlindBoxCreated(msg.sender, address(box), tokenId + 1, n, false);
    return (address(box), tokenId + 1, n);
  }

  function _batchCreateNewBlindBox_(address owner, uint256 n)
    public
    authorized
    nonReentrant
    returns (
      address,
      uint256,
      uint256
    )
  {
    require(id + n <= max, "exceed max");
    require(n > 0 && n <= buyLimit, "n must between 1 and 10 int");
    uint256 tokenId = id;
    id = id + n;
    BaseERC721BlindBox box = blindbox;
    for (uint256 i = 0; i < n; i++) {
      box.mint(owner, tokenId + 1 + i);
      blindboxTokenIds.push(tokenId + 1 + i);
    }
    IERC20(canBuyCoin).transferFrom(
      msg.sender,
      address(this),
      priceByGflokiV2.mul(n)
    );
    emit BatchBlindBoxCreated(owner, address(box), tokenId + 1, n, false);
    return (address(box), tokenId + 1, n);
  }

  function batchCreateNewBlindBox_(uint256 n)
    public
    payable
    nonReentrant
    returns (
      address,
      uint256,
      uint256
    )
  {
    require(id + n <= max, "exceed max");
    require(n > 0 && n <= buyLimit, "n must between 1 and 10 int");
    require(msg.value >= priceByBnb.mul(n), "not enouth");
    // if (bnbAddress != address(0)) bnbAddress.transfer(address(this).balance);
    uint256 tokenId = id;
    id = id + n;
    if (bnbAddress != address(0)) bnbAddress.transfer(address(this).balance);
    BaseERC721BlindBox box = blindbox;
    for (uint256 i = 0; i < n; i++) {
      box.mint(msg.sender, tokenId + 1 + i);
      blindboxTokenIds.push(tokenId + 1 + i);
    }
    emit BatchBlindBoxCreated(msg.sender, address(box), tokenId + 1, n, false);
    return (address(box), tokenId + 1, n);
  }

  function batchCreateNewNFT(
    uint256 n,
    uint8 v,
    bytes32 r,
    bytes32 s
  )
    public
    nonReentrant
    returns (
      address,
      uint256,
      uint256
    )
  {
    require(id + n <= max, "exceed max");
    require(n > 0 && n <= buyLimit, "n must between 1 and max int");
    uint256 msgnonce = nonce[msg.sender]++;
    bytes32 payloadHash = keccak256(abi.encode(msg.sender, n, msgnonce));
    bytes32 digest =
      keccak256(abi.encode("\x19Ethereum Signed Message:\n32", payloadHash));

    address signer = ecrecover(digest, v, r, s);
    require(owner == signer, "invalid signature");
    // require(msg.value >= priceByBnb.mul(n), "not enouth");
    // if (bnbAddress != address(0)) bnbAddress.transfer(address(this).balance);
    uint256 tokenId = id;
    id = id + n;
    if (bnbAddress != address(0) && address(this).balance > 0)
      bnbAddress.transfer(address(this).balance);
    BaseERC721BlindBox box = blindbox;
    for (uint256 i = 0; i < n; i++) {
      box.mint(msg.sender, tokenId + 1 + i);
      box.setBlindBoxOpened(tokenId + 1 + i, true);
      blindboxTokenIds.push(tokenId + 1 + i);
    }
    return (address(box), tokenId + 1, n);
  }

  function getBoxesLength() public view returns (uint256) {
    return blindboxTokenIds.length;
  }
}