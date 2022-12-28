// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IGovernance {
   function distributeFee(uint256 amount) external;
}

interface IPancakeSwapV2Router {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

interface IReferrals {
    function addMember(address member, address parent) external;
    function getSponsor(address account) external view returns (address);
}

contract INFLIVFarm is Initializable, OwnableUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;
	
	address[2] public stakedToken;
	address public rewardToken;
	address public pancakeSwapV2Router;
	address public USDT;
	
	uint256[21] public referrerBonus;
	IReferrals public Referrals;
	
	struct UserInfo {
	   uint256 farm; 
	   uint256 amount; 
	   uint256 rewardDebt;
	   uint256 startTime;
	   uint256 endTime;
	   mapping(uint256 => DepositDetails[]) deposit;
    }
	
	struct DepositDetails{
	  uint256 startTime;
	  uint256 endTime;
	  uint256 amount;
      uint256 locked;	   
	}
	
	uint256 public totalStaked;
	uint256 public accTokenPerShare;
	uint256 public governanceFeeonHarvest;
	uint256 public governanceFeeOnActivation;
	uint256 public precisionFactor;
	
	uint256[7] public activationFee;
	uint256[7] public maxStakingToken;
	
	mapping(address => mapping(uint256 => UserInfo)) public mapUserInfo;
	mapping(address => uint256) public stakingCount;
	mapping(address => uint256) public lastActiveTime;
	mapping(address => uint256) public referralEarning;
	
    event MigrateTokens(address tokenRecovered, address receiver, uint256 amount);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
	event NewMaxStakingToken(uint256 P1MaxStaking, uint256 P2MaxStaking, uint256 P3MaxStaking, uint256 P4MaxStaking, uint256 P5MaxStaking, uint256 P6MaxStaking, uint256 P7MaxStaking);
	event NewRewardTokenUpdated(address tokenAddress);
	event NewStakingTokenUpdated(address BNBIFV, address USDTIFV);
	event NewGovernanceFeeUpdated(uint256 newFee);
	event PoolUpdated(uint256 amount);	
	event buyFarm(address user, uint256 package);
	
    function initialize() public initializer {
		__Ownable_init();
		
		governanceFeeonHarvest = 300;
		governanceFeeOnActivation = 3000;
		
		activationFee[0] = 0;
		activationFee[1] = 50 * 10**18;
		activationFee[2] = 100 * 10**18;
		activationFee[3] = 200 * 10**18;
		activationFee[4] = 500 * 10**18;
		activationFee[5] = 1000 * 10**18;
		activationFee[6] = 2000 * 10**18;
		
		maxStakingToken[0] = 30 * 10**18;
		maxStakingToken[1] = 80 * 10**18;
		maxStakingToken[2] = 200 * 10**18;
		maxStakingToken[3] = 500 * 10**18;
		maxStakingToken[4] = 1500 * 10**18;
		maxStakingToken[5] = 3500 * 10**18;
		maxStakingToken[6] = 9000 * 10**18;
		
		referrerBonus[0]  = 2000;
		referrerBonus[1]  = 700;
		referrerBonus[2]  = 300;
		referrerBonus[3]  = 300;
		referrerBonus[4]  = 700;
		referrerBonus[5]  = 100;
		referrerBonus[6]  = 100;
		referrerBonus[7]  = 100;
		referrerBonus[8]  = 100;
		referrerBonus[9]  = 600;
		referrerBonus[10] = 100;
		referrerBonus[11] = 100;
		referrerBonus[12] = 100;
		referrerBonus[13] = 100;
		referrerBonus[14] = 600;
		referrerBonus[15] = 100;
		referrerBonus[16] = 100;
		referrerBonus[17] = 100;
		referrerBonus[18] = 100;
		referrerBonus[19] = 100;
		referrerBonus[20] = 500;
		
		precisionFactor = 10**18;
		
		pancakeSwapV2Router = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
		Referrals = IReferrals(0x3Dca67B7B115Ade083AE04e6A38d1A714fE0284C);
		USDT = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    }
	
	function getQuotes(uint256 amountIn) public view returns (uint256){
	   address[] memory path = new address[](2);
       path[0] = address(USDT);
	   path[1] = address(rewardToken);
	   
	   uint256[] memory INFLIVRequired = IPancakeSwapV2Router(pancakeSwapV2Router).getAmountsOut(amountIn, path);
	   return INFLIVRequired[1];
    }
	
	function activePackage(uint256 package, address sponsor) external{
		require(package < activationFee.length && package > 0, "Farm Plan not found");
		require(sponsor != address(0), 'zero address');
		require(sponsor != msg.sender, "ERR: referrer different required");
		
		lastActiveTime[msg.sender] = block.timestamp; 
		stakingCount[msg.sender] += 1;
		
		uint256 tokenRequired = getQuotes(activationFee[package]);
		uint256 stakingID = stakingCount[msg.sender];
		
		require(IERC20Upgradeable(rewardToken).balanceOf(msg.sender) >= tokenRequired, "balance not available for activation");
		
		mapUserInfo[msg.sender][stakingID].startTime = block.timestamp;
		mapUserInfo[msg.sender][stakingID].endTime = block.timestamp + 365 days;
		mapUserInfo[msg.sender][stakingID].farm = package;
		
		IERC20Upgradeable(rewardToken).safeTransferFrom(address(msg.sender), address(this), tokenRequired);
		
		uint256 governanceTax = tokenRequired * governanceFeeOnActivation / 10000;
		uint256 referralReward = tokenRequired - governanceTax;
		        governanceTax += referralReward * 1500 / 10000;
		
		IGovernance(rewardToken).distributeFee(governanceTax);
		if(Referrals.getSponsor(msg.sender) == address(0)) 
		{
		    Referrals.addMember(msg.sender, sponsor);
		}
		if(stakingCount[msg.sender]==1)
		{
		    lastActiveTime[Referrals.getSponsor(msg.sender)] = block.timestamp;
		}
		referralUpdate(msg.sender, referralReward);
		emit buyFarm(msg.sender, package);
    }
	
	function referralUpdate(address sponsor, uint256 amount) private {
		address nextReferrer = Referrals.getSponsor(sponsor);
		
		uint256 i;
		uint256 level;
		uint256 governanceTax;
		uint256 amountUsed;
		for(i=0; i < 256; i++) 
		{
			if(nextReferrer != address(0) && nextReferrer != address(rewardToken)) 
			{   
                if(lastActiveTime[nextReferrer] + 30 days >= block.timestamp && 21 > level)
				{
				    uint256 reward = amount * referrerBonus[level] / 10000;
				    IERC20Upgradeable(rewardToken).safeTransfer(address(nextReferrer), reward);
				    amountUsed += reward;
					referralEarning[address(nextReferrer)] += reward;
				    level++;
				}
				else if(level >= 21)
				{
				   break;     
				}
			}
			else 
			{
		        break;
			}
		    nextReferrer = Referrals.getSponsor(nextReferrer);
		}
		governanceTax = amount > amountUsed ? amount - amountUsed : 0;
	    if(governanceTax > 0) 
		{
		   IGovernance(rewardToken).distributeFee(governanceTax);
	    }
    }
	
	function createTeam(address sponsor) external {
		require(sponsor != address(0), "zero address");
		require(sponsor != msg.sender, "ERR: referrer different required");
		require(Referrals.getSponsor(msg.sender) == address(0), "sponsor already exits");
		
		Referrals.addMember(msg.sender, sponsor);
    }
	
	function deposit(uint256 amount, uint256 stakingID) external{
	    require(maxStakingToken[mapUserInfo[msg.sender][stakingID].farm] >= mapUserInfo[msg.sender][stakingID].amount + amount, "amount is more than max staking amount");
		
		if(stakingID == 0)
		{
			if(mapUserInfo[msg.sender][stakingID].amount > 0) 
			{
			   uint256 pending = pendingReward(msg.sender, stakingID);
			   if(pending > 0) 
			   {
			       uint256 governanceTax = pending * governanceFeeonHarvest / 10000;
				   IGovernance(rewardToken).distributeFee(governanceTax);
				   IERC20Upgradeable(rewardToken).safeTransfer(address(msg.sender), pending - governanceTax);
			   }
			}
			else
			{
				mapUserInfo[msg.sender][stakingID].startTime = block.timestamp;
			}
			mapUserInfo[msg.sender][stakingID].amount += amount;
			mapUserInfo[msg.sender][stakingID].rewardDebt = (mapUserInfo[msg.sender][stakingID].amount * accTokenPerShare) / precisionFactor;
			totalStaked += amount;
			IERC20Upgradeable(stakedToken[0]).safeTransferFrom(address(msg.sender), address(this), amount);
		} 
		else 
		{
		    require(mapUserInfo[msg.sender][stakingID].endTime >= block.timestamp, "Farm filling time is already completed");
			
			if(mapUserInfo[msg.sender][stakingID].amount > 0) 
			{
			   uint256 pending = pendingReward(msg.sender, stakingID);
			   if(pending > 0) 
			   {
			       uint256 governanceTax = pending * governanceFeeonHarvest / 10000;
				   IGovernance(rewardToken).distributeFee(governanceTax);
				   IERC20Upgradeable(rewardToken).safeTransfer(address(msg.sender), pending - governanceTax);
			   }
			}
			mapUserInfo[msg.sender][stakingID].amount += amount;
			mapUserInfo[msg.sender][stakingID].rewardDebt = (mapUserInfo[msg.sender][stakingID].amount * accTokenPerShare) / precisionFactor;
			mapUserInfo[msg.sender][stakingID].deposit[stakingID].push(DepositDetails(block.timestamp, block.timestamp + 365 days, amount, 1));
			totalStaked += amount;
			
			if(mapUserInfo[msg.sender][stakingID].farm == 1)
			{
			    IERC20Upgradeable(stakedToken[0]).safeTransferFrom(address(msg.sender), address(this), amount);
			}
			else
			{
			    IERC20Upgradeable(stakedToken[1]).safeTransferFrom(address(msg.sender), address(this), amount);
			}
		}
        emit Deposit(msg.sender, amount);
    }
	
	function getDepositDetails(address user, uint256 stakingID) external view returns(DepositDetails[] memory _deposit) {
        DepositDetails[] storage deposits = mapUserInfo[user][stakingID].deposit[stakingID];
        return deposits;
    }
	
	function withdrawReward(uint256 stakingID) external{
		if(mapUserInfo[msg.sender][stakingID].amount > 0) 
		{
			uint256 pending = pendingReward(msg.sender, stakingID);
			if (pending > 0) 
			{
			   uint256 governanceTax = pending * governanceFeeonHarvest / 10000;
			   IGovernance(rewardToken).distributeFee(governanceTax);
			   
			   IERC20Upgradeable(rewardToken).safeTransfer(address(msg.sender), pending - governanceTax);
			   mapUserInfo[msg.sender][stakingID].rewardDebt += pending;
			   emit Withdraw(msg.sender, pending);
			}
		} 
    }
	
	function withdraw(uint256 stakingID, uint256[] calldata ids) external{
	    if(mapUserInfo[msg.sender][stakingID].amount > 0) 
		{
			uint256 pending = pendingReward(msg.sender, stakingID);
			uint256 amount;
			if(pending > 0) 
			{
			   uint256 governanceTax = pending * governanceFeeonHarvest / 10000;
			   IGovernance(rewardToken).distributeFee(governanceTax);
			   
			   IERC20Upgradeable(rewardToken).safeTransfer(address(msg.sender), pending - governanceTax);
			   if(stakingID == 0)
			   {   
			       totalStaked -= mapUserInfo[msg.sender][stakingID].amount;
					
			       IERC20Upgradeable(stakedToken[0]).safeTransfer(address(msg.sender), mapUserInfo[msg.sender][stakingID].amount);
			       mapUserInfo[msg.sender][stakingID].amount = 0;
			       mapUserInfo[msg.sender][stakingID].rewardDebt = 0;
				   amount = mapUserInfo[msg.sender][stakingID].amount;
			   }
			   else
			   {
			       require(ids.length > 0, "No deposit id found");
				   for(uint i=0; i < ids.length; i++)
				   {
				       if(mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].locked == 1 && mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].endTime <= block.timestamp)
					   {
					      totalStaked -= mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].amount;
					      mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].locked = 0;
					      mapUserInfo[msg.sender][stakingID].amount -= mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].amount;
					      mapUserInfo[msg.sender][stakingID].rewardDebt = (mapUserInfo[msg.sender][stakingID].amount * accTokenPerShare) / precisionFactor;
						  if(mapUserInfo[msg.sender][stakingID].farm == 1)
						  {
						      IERC20Upgradeable(stakedToken[0]).safeTransfer(address(msg.sender), mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].amount);
						  }
						  else
						  {
						      IERC20Upgradeable(stakedToken[1]).safeTransfer(address(msg.sender), mapUserInfo[msg.sender][stakingID].deposit[stakingID][ids[i]].amount);
						  }
					   }
				   }
			   }
			}
			emit Withdraw(msg.sender, amount);
        }
    }
	
	function updatePool(uint256 amount) external{
		require(address(msg.sender) == address(rewardToken), "Request source is not valid");
		if(totalStaked > 0)
		{
		   accTokenPerShare = accTokenPerShare + (amount * precisionFactor / totalStaked);
		}
		emit PoolUpdated(amount);
    }
	
	function pendingReward(address user, uint256 stakingID) public view returns (uint256) {
		if(mapUserInfo[user][stakingID].amount > 0) 
		{
            uint256 pending = ((mapUserInfo[user][stakingID].amount * accTokenPerShare) / precisionFactor) - mapUserInfo[user][stakingID].rewardDebt;
			return pending;
        } 
		else 
		{
		   return 0;
		}
    }
	
	function migrateTokens(address tokenAddress, address receiver, uint256 tokenAmount) external onlyOwner{
       require(tokenAddress != address(0), "Zero address");
	   require(receiver != address(0), "Zero address");
	   require(IERC20Upgradeable(tokenAddress).balanceOf(address(this)) >= tokenAmount, "Insufficient balance on contract");
	   
	   IERC20Upgradeable(tokenAddress).safeTransfer(address(receiver), tokenAmount);
       emit MigrateTokens(tokenAddress, receiver, tokenAmount);
    }
	
	function setRewardToken(address tokenAddress) external onlyOwner{
       require(tokenAddress != address(0), "Zero address");
	   rewardToken = tokenAddress;
	   
	   IERC20Upgradeable(rewardToken).approve(address(rewardToken), type(uint256).max);
	   emit NewRewardTokenUpdated(rewardToken);
    }
	
	function setStakingToken(address BNBIFV, address USDTIFV) external onlyOwner{
       require(BNBIFV != address(0), "Zero address");
	   require(USDTIFV != address(0), "Zero address");
	   
	   stakedToken[0] = BNBIFV;
	   stakedToken[1] = USDTIFV;
	   emit NewStakingTokenUpdated(BNBIFV, USDTIFV);
    }
	
	function SetMaxStakingToken(uint256 P1MaxStaking, uint256 P2MaxStaking, uint256 P3MaxStaking, uint256 P4MaxStaking, uint256 P5MaxStaking, uint256 P6MaxStaking, uint256 P7MaxStaking) external onlyOwner {
	    require(P1MaxStaking > 0, "Incorrect `P1 Max Staking` value");
		require(P2MaxStaking > 0, "Incorrect `P2 Max Staking` value");
		require(P3MaxStaking > 0, "Incorrect `P3 Max Staking` value");
		require(P4MaxStaking > 0, "Incorrect `P4 Max Staking` value");
		require(P5MaxStaking > 0, "Incorrect `P5 Max Staking` value");
		require(P6MaxStaking > 0, "Incorrect `P6 Max Staking` value");
		require(P7MaxStaking > 0, "Incorrect `P7 Max Staking` value");
		
	    maxStakingToken[0] = P1MaxStaking;
        maxStakingToken[1] = P2MaxStaking;
        maxStakingToken[2] = P3MaxStaking;
		maxStakingToken[3] = P4MaxStaking;
		maxStakingToken[4] = P5MaxStaking;
		maxStakingToken[5] = P6MaxStaking;
		maxStakingToken[6] = P7MaxStaking;
		
		emit NewMaxStakingToken(P1MaxStaking, P2MaxStaking, P3MaxStaking, P4MaxStaking, P5MaxStaking, P6MaxStaking, P7MaxStaking);
    }
	
	function isActive(address user) external view returns(bool)
	{
	   if((lastActiveTime[user] + 30 days) >= block.timestamp)
	   {
	       return true;
	   }
	   else
	   {
	       return false;
	   }
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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