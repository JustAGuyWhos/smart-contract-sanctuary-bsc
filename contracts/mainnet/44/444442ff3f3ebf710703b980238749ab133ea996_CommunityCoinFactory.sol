/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// File: contracts/interfaces/ICommunityRolesManagement.sol


pragma solidity ^0.8.11;

interface ICommunityRolesManagement {
    struct CommunitySettings {
        address addr;
        string adminRole;
        string redeemRole;
        string circulationRole;
    }

    function initialize(
        CommunitySettings calldata communitySettings,
        address admin
    ) external;   

    function getRedeemRole() external view returns(bytes32);
    
    function checkRedeemRole(address account) external view;
    function checkCirculationRole(address account) external view;

    
}

// File: contracts/interfaces/ICommunityCoin.sol


pragma solidity ^0.8.0;

interface ICommunityCoin {
    
    function initialize(
        address poolImpl,
        address poolErc20Impl,
        address hook,
        address instancesImpl,
        uint256 discountSensitivity,
        address rolesManagementClone,
        address reserveToken,
        address tradedToken
    ) external;

    event InstanceCreated(address indexed tokenA, address indexed tokenB, address instance);
    event InstanceErc20Created(address indexed erc20token, address instance);

    function issueWalletTokens(address account, uint256 amount, uint256 priceBeforeStake) external;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/proxy/Clones.sol


// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

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
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
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

// File: contracts/CommunityCoinFactory.sol


pragma solidity 0.8.11;





contract CommunityCoinFactory is Ownable {
    using Clones for address;

    /**
    * @custom:shortd CommunityCoin implementation address
    * @notice CommunityCoin implementation address
    */
    address public immutable communityCoinImplementation;
    
    /**
    * @custom:shortd CommunityStakingPoolFactory implementation address
    * @notice CommunityStakingPoolFactory implementation address
    */
    address public immutable communityStakingPoolFactoryImplementation;
    
    /**
    * @custom:shortd StakingPool implementation address
    * @notice StakingPool implementation address
    */
    address public immutable stakingPoolImplementation;
    address public immutable stakingPoolErc20Implementation;

    /**
    * @custom:shortd RolesManagement implementation address
    * @notice RolesManagement implementation address
    */
    address public immutable rolesManagementImplementation;

    address[] public instances;
    
    event InstanceCreated(address instance, uint instancesCount);

    /**
    * @param communityCoinImpl address of CommunityCoin implementation
    * @param communityStakingPoolFactoryImpl address of CommunityStakingPoolFactory implementation
    * @param stakingPoolImpl address of StakingPool implementation
    * @param stakingPoolImplErc20 address of StakingPoolErc20 implementation
    * @param rolesManagementImpl address of RolesManagement implementation
    */
    constructor(
        address communityCoinImpl,
        address communityStakingPoolFactoryImpl,
        address stakingPoolImpl,
        address stakingPoolImplErc20,
        address rolesManagementImpl
    ) 
    {
        communityCoinImplementation = communityCoinImpl;
        communityStakingPoolFactoryImplementation = communityStakingPoolFactoryImpl;
        stakingPoolImplementation = stakingPoolImpl;
        stakingPoolErc20Implementation = stakingPoolImplErc20;
        rolesManagementImplementation = rolesManagementImpl;

    }

    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @dev view amount of created instances
    * @return amount amount instances
    * @custom:shortd view amount of created instances
    */
    function instancesCount()
        external 
        view 
        returns (uint256 amount) 
    {
        amount = instances.length;
    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @param reserveToken address of reserve token. like a WETH, USDT,USDC, etc.
    * @param tradedToken address of traded token. usual it intercoin investor token
    * @param hook address of contract implemented IHook interface and used to calculation bonus tokens amount
    * @param discountSensitivity discountSensitivity value that manage amount tokens in redeem process. multiplied by `FRACTION`(10**5 by default)
    * @param communitySettings tuple of community settings (address of contract and roles(admin,redeem,circulate))
    * @return instance address of created instance pool `CommunityCoin`
    * @custom:shortd creation instance
    */
    function produce(
        address reserveToken,
        address tradedToken,
        address hook,
        uint256 discountSensitivity,
        ICommunityRolesManagement.CommunitySettings memory communitySettings
    ) 
        public 
        onlyOwner()
        returns (address instance) 
    {
        
        instance = communityCoinImplementation.clone();
        address coinInstancesClone = communityStakingPoolFactoryImplementation.clone();

        require(instance != address(0), "CommunityCoinFactory: INSTANCE_CREATION_FAILED");

        instances.push(instance);
        
        emit InstanceCreated(instance, instances.length);

        address rolesManagementClone = rolesManagementImplementation.clone();

        ICommunityRolesManagement(rolesManagementClone).initialize(communitySettings, instance);

        ICommunityCoin(instance).initialize(stakingPoolImplementation, stakingPoolErc20Implementation, hook, coinInstancesClone, discountSensitivity, rolesManagementClone, reserveToken, tradedToken);
        
        Ownable(instance).transferOwnership(_msgSender());
        
    }

    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    
}