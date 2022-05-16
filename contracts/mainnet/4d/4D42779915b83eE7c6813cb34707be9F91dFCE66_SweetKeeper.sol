/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface ILegacyVault {
    function earn() external;
}

interface ISweetVault {
    function earn(uint, uint, uint, uint) external;

    function getExpectedOutputs() external view returns (uint, uint, uint, uint);

    function totalStake() external view returns (uint);
}

interface ISweetVaultV2 {
    function earn(uint, uint) external;

    function getExpectedOutputs() external view returns (uint, uint);

    function totalStake() external view returns (uint);
}

interface KeeperCompatibleInterface {
    function checkUpkeep(
        bytes calldata checkData
    ) external view returns (
        bool upkeepNeeded,
        bytes memory performData
    );

    function performUpkeep(
        bytes calldata performData
    ) external;
}

contract SweetKeeper is OwnableUpgradeable, KeeperCompatibleInterface {
    using SafeMath for uint;

    enum VaultType {
        LEGACY,
        SWEET,
        SWEET_V2
    }

    struct VaultInfo {
        VaultType vaultType;
        uint lastCompound;
        bool enabled;
    }

    // @Deprecated CompoundInfo
    struct CompoundInfo {
        VaultType vaultType;
        address[] vaults;
        uint[] minPlatformOutputs;
        uint[] minKeeperOutputs;
        uint[] minBurnOutputs;
        uint[] minPacocaOutputs;
    }

    mapping(VaultType => address[]) public vaults;
    mapping(address => VaultInfo) public vaultInfos;

    mapping(address => bool) public keepers;
    address public moderator;

    uint public maxDelay;
    uint public minKeeperFee;
    uint public slippageFactor;

    // @Deprecated maxVaults
    uint16 public maxVaults;
    // @Deprecated keeper
    address public keeper;

    event Compound(address indexed vault, uint timestamp);

    function initialize(
        address _moderator,
        address _owner
    ) public initializer {
        moderator = _moderator;

        __Ownable_init();
        transferOwnership(_owner);

        maxDelay = 1 days;
        minKeeperFee = 10000000000000000;
        slippageFactor = 9500;
        maxVaults = 2;
    }

    modifier onlyKeeper() {
        require(keepers[msg.sender], "SweetKeeper::onlyKeeper: Not keeper");
        _;
    }

    modifier onlyModerator() {
        require(msg.sender == moderator, "SweetKeeper::onlyModerator: Not moderator");
        _;
    }

    function checkUpkeep(
        bytes calldata
    ) external override view returns (
        bool upkeepNeeded,
        bytes memory performData
    ) {
        (upkeepNeeded, performData) = checkLegacyCompound();

        if (upkeepNeeded) {
            return (upkeepNeeded, performData);
        }

        (upkeepNeeded, performData) = checkSweetCompound();

        if (upkeepNeeded) {
            return (upkeepNeeded, performData);
        }

        (upkeepNeeded, performData) = checkSweetV2Compound();

        if (upkeepNeeded) {
            return (upkeepNeeded, performData);
        }

        return (false, "");
    }

    function checkCompound(
        address _vault
    ) public view returns (
        bool compoundNeeded,
        uint platformOutput,
        uint keeperOutput,
        uint burnOutput,
        uint pacocaOutput
    ) {
        compoundNeeded = false;
        platformOutput = 0;
        keeperOutput = 0;
        burnOutput = 0;
        pacocaOutput = 0;

        VaultInfo memory vaultInfo = vaultInfos[_vault];

        if (!vaultInfo.enabled)
            return (compoundNeeded, platformOutput, keeperOutput, burnOutput, pacocaOutput);

        if (vaultInfo.vaultType == VaultType.SWEET || vaultInfo.vaultType == VaultType.SWEET_V2)
            if (ISweetVault(_vault).totalStake() == 0)
                return (compoundNeeded, platformOutput, keeperOutput, burnOutput, pacocaOutput);

        compoundNeeded = block.timestamp >= vaultInfo.lastCompound + maxDelay;

        if (vaultInfo.vaultType == VaultType.LEGACY)
            return (compoundNeeded, platformOutput, keeperOutput, burnOutput, pacocaOutput);

        if (vaultInfo.vaultType == VaultType.SWEET) {
            (platformOutput, keeperOutput, burnOutput, pacocaOutput) = _getExpectedOutputs(
                VaultType.SWEET,
                _vault
            );

            if (keeperOutput >= minKeeperFee)
                compoundNeeded = true;

            return (compoundNeeded, platformOutput, keeperOutput, burnOutput, pacocaOutput);
        }

        if (vaultInfo.vaultType == VaultType.SWEET_V2) {
            (platformOutput, , , pacocaOutput) = _getExpectedOutputs(
                VaultType.SWEET_V2,
                _vault
            );

            keeperOutput = platformOutput.div(11);

            if (keeperOutput >= minKeeperFee)
                compoundNeeded = true;

            return (compoundNeeded, platformOutput, keeperOutput, burnOutput, pacocaOutput);
        }
    }

    function checkLegacyCompound() public view returns (
        bool upkeepNeeded,
        bytes memory performData
    ) {
        uint totalLength = legacyVaultsLength();

        for (uint16 index = 0; index < totalLength; ++index) {
            address vault = vaults[VaultType.LEGACY][index];

            (bool compoundNeeded, , , ,) = checkCompound(vault);

            if (compoundNeeded) {
                uint zero = uint(0);

                return (true, abi.encode(
                    VaultType.LEGACY,
                    vault,
                    zero,
                    zero,
                    zero,
                    zero
                ));
            }
        }

        return (false, "");
    }

    function checkSweetCompound() public view returns (
        bool upkeepNeeded,
        bytes memory performData
    ) {
        uint totalLength = sweetVaultsLength();

        for (uint16 index = 0; index < totalLength; ++index) {
            address vault = vaults[VaultType.SWEET][index];

            (bool compoundNeeded, uint platformOutput, uint keeperOutput, uint burnOutput, uint pacocaOutput) = checkCompound(vault);

            if (compoundNeeded && pacocaOutput > 0) {
                return (true, abi.encode(
                    VaultType.SWEET,
                    vault,
                    platformOutput.mul(slippageFactor).div(10000),
                    keeperOutput.mul(slippageFactor).div(10000),
                    burnOutput.mul(slippageFactor).div(10000),
                    pacocaOutput.mul(slippageFactor).div(10000)
                ));
            }
        }

        return (false, "");
    }

    function checkSweetV2Compound() public view returns (
        bool upkeepNeeded,
        bytes memory performData
    ) {
        uint totalLength = sweetVaultsV2Length();

        for (uint16 index = 0; index < totalLength; ++index) {
            address vault = vaults[VaultType.SWEET_V2][index];

            (bool compoundNeeded, uint platformOutput, , , uint pacocaOutput) = checkCompound(vault);

            if (compoundNeeded && pacocaOutput > 0) {
                uint zero = uint(0);

                return (true, abi.encode(
                    VaultType.SWEET_V2,
                    vault,
                    platformOutput.mul(slippageFactor).div(10000),
                    zero,
                    zero,
                    pacocaOutput.mul(slippageFactor).div(10000)
                ));
            }
        }

        return (false, "");
    }

    function performUpkeep(
        bytes calldata performData
    ) external override onlyKeeper {
        (
        VaultType _type,
        address _vault,
        uint _minPlatformOutput,
        uint _minKeeperOutput,
        uint _minBurnOutput,
        uint _minPacocaOutput
        ) = abi.decode(
            performData,
            (VaultType, address, uint, uint, uint, uint)
        );

        _earn(
            _type,
            _vault,
            _minPlatformOutput,
            _minKeeperOutput,
            _minBurnOutput,
            _minPacocaOutput
        );
    }

    function compound(address _vault) public {
        VaultInfo memory vaultInfo = vaultInfos[_vault];
        uint timestamp = block.timestamp;

        require(
            vaultInfo.lastCompound < timestamp - 12 hours,
            "SweetKeeper::compound: Too soon"
        );

        if (vaultInfo.vaultType == VaultType.LEGACY) {
            return _compoundLegacyVault(_vault, timestamp);
        }

        if (vaultInfo.vaultType == VaultType.SWEET) {
            return _compoundSweetVault(_vault, 0, 0, 0, 0, timestamp);
        }

        if (vaultInfo.vaultType == VaultType.SWEET_V2) {
            return _compoundSweetVaultV2(_vault, 0, 0, timestamp);
        }
    }

    function _compoundLegacyVault(address _vault, uint timestamp) private {
        ILegacyVault(_vault).earn();

        vaultInfos[_vault].lastCompound = timestamp;

        emit Compound(_vault, timestamp);
    }

    function _compoundSweetVault(
        address _vault,
        uint _minPlatformOutput,
        uint _minKeeperOutput,
        uint _minBurnOutput,
        uint _minPacocaOutput,
        uint timestamp
    ) private {
        ISweetVault(_vault).earn(
            _minPlatformOutput,
            _minKeeperOutput,
            _minBurnOutput,
            _minPacocaOutput
        );

        vaultInfos[_vault].lastCompound = timestamp;

        emit Compound(_vault, timestamp);
    }

    function _compoundSweetVaultV2(
        address _vault,
        uint _minPlatformOutput,
        uint _minPacocaOutput,
        uint timestamp
    ) private {
        ISweetVaultV2(_vault).earn(
            _minPlatformOutput,
            _minPacocaOutput
        );

        vaultInfos[_vault].lastCompound = timestamp;

        emit Compound(_vault, timestamp);
    }

    function _earn(
        VaultType _type,
        address _vault,
        uint _minPlatformOutput,
        uint _minKeeperOutput,
        uint _minBurnOutput,
        uint _minPacocaOutput
    ) private {
        uint timestamp = block.timestamp;

        if (_type == VaultType.LEGACY) {
            _compoundLegacyVault(
                _vault,
                timestamp
            );

            return;
        }

        if (_type == VaultType.SWEET) {
            _compoundSweetVault(
                _vault,
                _minPlatformOutput,
                _minKeeperOutput,
                _minBurnOutput,
                _minPacocaOutput,
                timestamp
            );

            return;
        }

        if (_type == VaultType.SWEET_V2) {
            _compoundSweetVaultV2(
                _vault,
                _minPlatformOutput,
                _minPacocaOutput,
                timestamp
            );
        }
    }

    function _getExpectedOutputs(
        VaultType _type,
        address _vault
    ) private view returns (
        uint, uint, uint, uint
    ) {
        if (_type == VaultType.SWEET) {
            try ISweetVault(_vault).getExpectedOutputs() returns (
                uint platformOutput,
                uint keeperOutput,
                uint burnOutput,
                uint pacocaOutput
            ) {
                return (platformOutput, keeperOutput, burnOutput, pacocaOutput);
            }
            catch (bytes memory) {
            }
        }
        else if (_type == VaultType.SWEET_V2) {
            try ISweetVaultV2(_vault).getExpectedOutputs() returns (
                uint platformOutput,
                uint pacocaOutput
            ) {
                return (platformOutput, 0, 0, pacocaOutput);
            }
            catch (bytes memory) {
            }
        }

        return (0, 0, 0, 0);
    }

    function compoundInfo(
        address _vault
    ) external view returns (
        uint lastCompound,
        uint keeperFee
    ) {
        VaultInfo memory vaultInfo = vaultInfos[_vault];
        bool isSweet = vaultInfo.vaultType == VaultType.SWEET;
        bool isSweetV2 = vaultInfo.vaultType == VaultType.SWEET_V2;

        lastCompound = vaultInfo.lastCompound;
        keeperFee = 0;

        if ((isSweet || isSweetV2) && ISweetVault(_vault).totalStake() == 0) {
            return (lastCompound, keeperFee);
        }

        if (isSweet) {
            (, keeperFee,,) = _getExpectedOutputs(
                VaultType.SWEET,
                _vault
            );
        }
        else if (isSweetV2) {
            (uint platformOutput,,,) = _getExpectedOutputs(
                VaultType.SWEET_V2,
                _vault
            );

            keeperFee = platformOutput.div(11);
        }
    }

    function legacyVaultsLength() public view returns (uint) {
        return vaults[VaultType.LEGACY].length;
    }

    function sweetVaultsLength() public view returns (uint) {
        return vaults[VaultType.SWEET].length;
    }

    function sweetVaultsV2Length() public view returns (uint) {
        return vaults[VaultType.SWEET_V2].length;
    }

    function addVault(VaultType _type, address _vault) public onlyModerator {
        require(
            vaultInfos[_vault].lastCompound == 0,
            "SweetKeeper::addVault: Vault already exists"
        );

        vaultInfos[_vault] = VaultInfo(
            _type,
            block.timestamp,
            true
        );

        vaults[_type].push(_vault);
    }

    function addVaults(
        VaultType _type,
        address[] memory _vaults
    ) public onlyModerator {
        for (uint index = 0; index < _vaults.length; ++index) {
            addVault(_type, _vaults[index]);
        }
    }

    function enableVault(address _vault) external onlyModerator {
        vaultInfos[_vault].enabled = true;
    }

    function disableVault(address _vault) external onlyModerator {
        vaultInfos[_vault].enabled = false;
    }

    function enableKeeper(address _keeper) public onlyOwner {
        keepers[_keeper] = true;
    }

    function disableKeeper(address _keeper) public onlyOwner {
        keepers[_keeper] = false;
    }

    function setModerator(address _moderator) public onlyOwner {
        moderator = _moderator;
    }

    function setMaxDelay(uint _maxDelay) public onlyOwner {
        maxDelay = _maxDelay;
    }

    function setMinKeeperFee(uint _minKeeperFee) public onlyOwner {
        minKeeperFee = _minKeeperFee;
    }

    function setSlippageFactor(uint _slippageFactor) public onlyOwner {
        slippageFactor = _slippageFactor;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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