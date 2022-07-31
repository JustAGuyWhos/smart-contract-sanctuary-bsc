/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library EnumerableSet {
    
    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}

interface IPoolFactory {
  function increaseTotalValueLocked(uint256 value) external;
  function decreaseTotalValueLocked(uint256 value) external;
  function removePoolForToken(address token, address pool) external;
  function recordContribution(address user, address pool) external;

  event TvlChanged(uint256 totalLocked, uint256 totalRaised);
  event ContributionUpdated(uint256 totalParticipations);
  event PoolForTokenRemoved(address indexed token, address pool);
}

interface IPoolManager {
    function isPoolGenerated(address pool) external view returns (bool);
    function registerPool(address pool, address token, address owner, uint8 version) external;
    function poolForToken(address token) external view returns (address);
}

contract PairManager is Ownable, IPoolFactory, IPoolManager {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeMath for uint256;

  struct AmaPartner{
        string name;
        string username;
        address ownerAddress;
        string email;
        uint256 fees;
        string configuration;
        string profileUrl; 
        bool status;
    }
  

  EnumerableSet.AddressSet private poolFactories;
  EnumerableSet.AddressSet private amaPartnerAddress;
  

  EnumerableSet.AddressSet private _pools;
  mapping(uint8 => EnumerableSet.AddressSet) private _poolsForVersion;
  mapping(address => EnumerableSet.AddressSet) private _poolsOf;
  mapping(address => EnumerableSet.AddressSet) private _contributedPoolsOf;
  mapping(address => address) private _poolForToken;
  mapping(address => AmaPartner) public amapartner;
  uint256 public totalValueLockedInBnb;
  uint256 public totalLiquidityRaisedInBnb;
  uint256 public totalParticipants;

  event sender(address sender);
  event addAma(string id, address ownerAddress, string email, uint256 fees, bool status);

  receive() external payable{}

  modifier onlyAllowedFactory() {
    emit sender(msg.sender);
    require(poolFactories.contains(msg.sender) , "Not a whitelisted factory");
    _;
  }

  modifier onlyAmaAddress() {
    emit sender(msg.sender);
    require(amaPartnerAddress.contains(msg.sender) || owner() == msg.sender , "Not a whitelisted factory");
    _;
  }

  function addPoolFactory(address factory) public onlyAllowedFactory {
    poolFactories.add(factory);
    
  }

  function addAdminPoolFactory(address factory) public onlyOwner {
    poolFactories.add(factory);
  }

  function addPoolFactories(address[] memory factories) external onlyOwner {
    for (uint256 i = 0; i < factories.length; i++) {
      addPoolFactory(factories[i]);
    }
  }

  function removePoolFactory(address factory) external onlyOwner {
    poolFactories.remove(factory);
  }

  function isPoolGenerated(address pool) public override view returns (bool) {
    return _pools.contains(pool);
  }

  function poolForToken(address token) external override view returns (address) {
    return _poolForToken[token];
  }

  function registerAma(
      string memory _name,
      string memory _username,
      address _ownerAddress,
      string memory _email,
      uint256 _fees,
      string memory _profileUrl,
      string memory _configuration

    ) public onlyOwner{
        amapartner[_ownerAddress] =  
            AmaPartner
            (
            _name,
            _username,
            _ownerAddress,
            _email,
            _fees,
            _configuration,
            _profileUrl,
            false
         );

         amaPartnerAddress.add(_ownerAddress);

         emit addAma(_configuration, _ownerAddress, _email, _fees, false);
    }

    function updatePartnerAddress( address _address , address _oldAddress ) public onlyOwner{
        require(amaPartnerAddress.contains(_oldAddress) , "No Partner Avalible with Id");
        amapartner[_address] =  
            AmaPartner
            (
            amapartner[_oldAddress].name,
            amapartner[_oldAddress].username,
            amapartner[_oldAddress].ownerAddress,
            amapartner[_oldAddress].email,
            amapartner[_oldAddress].fees,
            amapartner[_oldAddress].configuration,
            amapartner[_oldAddress].profileUrl,
            amapartner[_oldAddress].status
         );
        amaPartnerAddress.add(_address);
        amaPartnerAddress.remove(amapartner[_oldAddress].ownerAddress);
        delete amapartner[_oldAddress];
    }

    function updatePartnerInfo( string memory _name , string memory _username ,uint256 _fees , bool _status) public onlyAmaAddress{
        AmaPartner storage ama = amapartner[msg.sender];
        require(bytes(ama.email).length != 0 , "No Partner Avalible with Id");
        amaPartnerAddress.remove(amapartner[msg.sender].ownerAddress);
        amapartner[msg.sender].ownerAddress = msg.sender;
        amaPartnerAddress.add(msg.sender);
        amapartner[msg.sender].name = _name;
        amapartner[msg.sender].username = _username;
        amapartner[msg.sender].fees = _fees;
        amapartner[msg.sender].status = _status;
    }

  function registerPool(
      address pool, 
      address token, 
      address owner, 
      uint8 version
  ) external override onlyAllowedFactory {
      _pools.add(pool);
      _poolsForVersion[version].add(pool);
      _poolsOf[owner].add(pool);
      _poolForToken[token] = pool;
  }

  function increaseTotalValueLocked(uint256 value) external override onlyAllowedFactory {
      totalValueLockedInBnb = totalValueLockedInBnb.add(value);
      totalLiquidityRaisedInBnb = totalLiquidityRaisedInBnb.add(value);
      emit TvlChanged(totalValueLockedInBnb, totalLiquidityRaisedInBnb);
  }

  function decreaseTotalValueLocked(uint256 value) external override onlyAllowedFactory {
      if (totalValueLockedInBnb < value) {
          totalValueLockedInBnb = 0;
      } else {
          totalValueLockedInBnb = totalValueLockedInBnb.sub(value);
      }
      emit TvlChanged(totalValueLockedInBnb, totalLiquidityRaisedInBnb);
  }

  function recordContribution(address user, address pool) external override onlyAllowedFactory {
      totalParticipants = totalParticipants.add(1);
      _contributedPoolsOf[user].add(pool);
      emit ContributionUpdated(totalParticipants);
  }

  function removePoolForToken(address token, address pool) external override onlyAllowedFactory {
      _poolForToken[token] = address(0);
      emit PoolForTokenRemoved(token, pool);
  }

  function getPoolsOf(address owner) public view returns (address[] memory) {
      uint256 length = _poolsOf[owner].length();
      address[] memory allPools = new address[](length);
      for (uint256 i = 0; i < length; i++) {
          allPools[i] = _poolsOf[owner].at(i);
      }
      return allPools;
  }

  function getAllPools() public view returns (address[] memory) {
      uint256 length = _pools.length();
      address[] memory allPools = new address[](length);
      for (uint256 i = 0; i < length; i++) {
          allPools[i] = _pools.at(i);
      }
      return allPools;
  }

  function getPoolAt(uint256 index) public view returns (address) {
      return _pools.at(index);
  }

  function getTotalNumberOfPools() public view returns (uint256) {
      return _pools.length();
  }

  function getTotalNumberOfContributedPools(address user) public view returns (uint256) {
      return _contributedPoolsOf[user].length();
  }

  function getAllContributedPools(address user) public view returns (address[] memory) {
      uint256 length = _contributedPoolsOf[user].length();
      address[] memory allPools = new address[](length);
      for (uint256 i = 0; i < length; i++) {
          allPools[i] = _contributedPoolsOf[user].at(i);
      }
      return allPools;
  }

  function getContributedPoolAtIndex(address user, uint256 index) public view returns (address) {
      return _contributedPoolsOf[user].at(index);
  }

  function getTotalNumberOfPools(uint8 version) public view returns (uint256) {
    return _poolsForVersion[version].length();
  }

  function getPoolAt(uint8 version, uint256 index) public view returns (address) {
    return _poolsForVersion[version].at(index);
  }
}