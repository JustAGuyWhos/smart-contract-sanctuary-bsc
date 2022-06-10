//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/IPresale.sol";
import "../interfaces/IStaking.sol";
import "../interfaces/IPresaleFactory.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../pancake-swap/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PresaleFactoryTest is Ownable, IStructs, IPresaleFactory {
    uint256 private constant DENOMINATOR = 100;
    uint256 private constant LINK_FEE = 0.1 ether;

    address private immutable LINK;
    address private immutable APPROVER;

    address public immutable STAKING;

    address public publicMaster;
    address public privateMaster;
    address public inqubatorMaster;

    address private backend;
    address private feeReceiver;
    uint256 private feePercent;

    mapping(address => address[]) public userPresales;

    enum PresaleTypes {
        PUBLIC,
        PRIVATE,
        INQUBATOR
    }

    event PresaleCreated(
        PresaleTypes pType,
        address creator,
        address presaleAddress,
        address tokenAddress
    );

    constructor(
        address link,
        address staking,
        address approver,
        address back
    ) {
        require(
            link != address(0) &&
                staking != address(0) &&
                approver != address(0) &&
                back != address(0),
            "Address 0x00..."
        );
        LINK = link;
        STAKING = staking;
        APPROVER = approver;
        backend = back;
    }

    /** @dev Function to set public+private+inqubator master contract's addresses
     * @notice Only owner
     * @param _public public presale master contract address
     * @param _private private presale master contract address
     * @param _inqubator inqubator presale master contract address
     */
    function setMasterAddresses(
        address _public,
        address _private,
        address _inqubator
    ) external onlyOwner {
        require(
            publicMaster == address(0) &&
                privateMaster == address(0) &&
                inqubatorMaster == address(0) &&
                _public != address(0) &&
                _private != address(0) &&
                _inqubator != address(0),
            "Wrong addresses"
        );

        publicMaster = _public;
        privateMaster = _private;
        inqubatorMaster = _inqubator;
    }

    function setFeeParams(address receiver, uint256 perc) external onlyOwner {
        require(receiver != address(0) && perc < DENOMINATOR, "WRONG PARAMS");
        feeReceiver = receiver;
        feePercent = perc;
    }

    function changeBackendAddress(address back) external onlyOwner {
        require(back != address(0), "Address 0x00...");
        backend = back;
    }

    function createPresalePublic(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo
    ) external {
        require(
            _info.openTime >= block.timestamp + 30 minutes &&
                _info.openTime + 25 minutes <=
                _info.closeTime &&
                _info.closeTime < _dexInfo.liquidityAllocationTime,
            "TIME"
        );
        require(
            _info.softCap <= _info.hardCap &&
                _info.hardCap >= _info.tokenPrice &&
                _dexInfo.listingPrice > 0 &&
                _info.tokenPrice > 0 &&
                _dexInfo.lpTokensLockDurationInDays > 0 &&
                _dexInfo.liquidityPercentageAllocation > 0 &&
                _vestInfo.vestingPerc1 + _vestInfo.vestingPerc2 <=
                DENOMINATOR &&
                _vestInfo.vestingPeriod > 0,
            "AMOUNTS"
        );
        if (_vestInfo.vestingPerc1 < DENOMINATOR)
            require(_vestInfo.vestingPerc2 > 0, "VESTING");
        require(
            _info.creator != address(0) &&
                _info.unsoldTokenToAddress != address(0) &&
                _info.tokenAddress != address(0),
            "ADDRESSES"
        );

        uint256 decimals = IERC20Metadata(_info.tokenAddress).decimals();
        uint256 amountForSale = (_info.hardCap * 10**decimals) /
            _info.tokenPrice;
        uint256 amountForLiquidity = (((_info.hardCap *
            _dexInfo.liquidityPercentageAllocation) / DENOMINATOR) *
            10**decimals) / _dexInfo.listingPrice;

        require(amountForLiquidity > 0 && amountForSale > 0);

        address presaleAddress = Clones.clone(publicMaster);
        IPresalePublic(presaleAddress).initialize(_info, _dexInfo, _vestInfo);
        address sender = _msgSender();
        userPresales[sender].push(presaleAddress);

        IStaking(STAKING).addPresale(presaleAddress);

        TransferHelper.safeTransferFrom(
            _info.tokenAddress,
            sender,
            presaleAddress,
            amountForLiquidity + amountForSale
        );
        TransferHelper.safeTransferFrom(LINK, sender, presaleAddress, LINK_FEE);

        emit PresaleCreated(
            PresaleTypes.PUBLIC,
            sender,
            presaleAddress,
            _info.tokenAddress
        );
    }

    function createPresalePrivate(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo,
        address[] memory _whitelist
    ) external {
        require(
            _info.openTime >= block.timestamp &&
                _info.openTime < _info.closeTime &&
                _info.closeTime < _dexInfo.liquidityAllocationTime,
            "TIME"
        );
        require(
            _info.softCap <= _info.hardCap &&
                _info.hardCap >= _info.tokenPrice &&
                _dexInfo.listingPrice > 0 &&
                _info.tokenPrice > 0 &&
                _dexInfo.lpTokensLockDurationInDays > 0 &&
                _dexInfo.liquidityPercentageAllocation > 0 &&
                _vestInfo.vestingPerc1 + _vestInfo.vestingPerc2 <=
                DENOMINATOR &&
                _vestInfo.vestingPeriod > 0,
            "AMOUNTS"
        );
        if (_vestInfo.vestingPerc1 < DENOMINATOR)
            require(_vestInfo.vestingPerc2 > 0, "VESTING");
        require(
            _info.creator != address(0) &&
                _info.unsoldTokenToAddress != address(0) &&
                _info.tokenAddress != address(0),
            "ADDRESSES"
        );

        uint256 decimals = IERC20Metadata(_info.tokenAddress).decimals();
        uint256 amountForSale = (_info.hardCap * 10**decimals) /
            _info.tokenPrice;
        uint256 amountForLiquidity = (((_info.hardCap *
            _dexInfo.liquidityPercentageAllocation) / DENOMINATOR) *
            10**decimals) / _dexInfo.listingPrice;

        require(amountForLiquidity > 0 && amountForSale > 0);

        address presaleAddress = Clones.clone(privateMaster);
        IPresalePrivate(presaleAddress).initialize(
            _info,
            _dexInfo,
            _vestInfo,
            _whitelist
        );
        address sender = _msgSender();
        userPresales[sender].push(presaleAddress);

        TransferHelper.safeTransferFrom(
            _info.tokenAddress,
            sender,
            presaleAddress,
            amountForLiquidity + amountForSale
        );

        emit PresaleCreated(
            PresaleTypes.PRIVATE,
            sender,
            presaleAddress,
            _info.tokenAddress
        );
    }

    function createPresaleInqubator(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo
    ) external {
        require(
            _info.openTime >= block.timestamp + 30 minutes &&
                _info.openTime + 25 minutes <=
                _info.closeTime &&
                _info.closeTime < _dexInfo.liquidityAllocationTime,
            "TIME"
        );
        require(
            _info.softCap <= _info.hardCap &&
                _info.hardCap >= _info.tokenPrice &&
                _dexInfo.listingPrice > 0 &&
                _info.tokenPrice > 0 &&
                _dexInfo.lpTokensLockDurationInDays > 0 &&
                _dexInfo.liquidityPercentageAllocation > 0 &&
                _vestInfo.vestingPerc1 + _vestInfo.vestingPerc2 <=
                DENOMINATOR &&
                _vestInfo.vestingPeriod > 0,
            "AMOUNTS"
        );
        if (_vestInfo.vestingPerc1 < DENOMINATOR)
            require(_vestInfo.vestingPerc2 > 0, "VESTING");
        require(
            _info.creator != address(0) &&
                _info.unsoldTokenToAddress != address(0) &&
                _info.tokenAddress != address(0),
            "ADDRESSES"
        );

        uint256 decimals = IERC20Metadata(_info.tokenAddress).decimals();
        uint256 amountForSale = (_info.hardCap * 10**decimals) /
            _info.tokenPrice;
        uint256 amountForLiquidity = (((_info.hardCap *
            _dexInfo.liquidityPercentageAllocation) / DENOMINATOR) *
            10**decimals) / _dexInfo.listingPrice;

        require(amountForLiquidity > 0 && amountForSale > 0);

        address presaleAddress = Clones.clone(inqubatorMaster);
        IPresalePublic(presaleAddress).initialize(_info, _dexInfo, _vestInfo);
        address sender = _msgSender();
        userPresales[sender].push(presaleAddress);

        IStaking(STAKING).addPresale(presaleAddress);

        TransferHelper.safeTransferFrom(
            _info.tokenAddress,
            sender,
            presaleAddress,
            amountForLiquidity + amountForSale
        );
        TransferHelper.safeTransferFrom(LINK, sender, presaleAddress, LINK_FEE);

        emit PresaleCreated(
            PresaleTypes.INQUBATOR,
            sender,
            presaleAddress,
            _info.tokenAddress
        );
    }

    function getUserPresales(address user)
        external
        view
        returns (address[] memory)
    {
        return userPresales[user];
    }

    function getFeeParams() external view override returns (address, uint256) {
        if (feeReceiver == address(0)) return (owner(), feePercent);
        else return (feeReceiver, feePercent);
    }

    function isApprover(address sender) external view override returns (bool) {
        if (sender == APPROVER) return true;
        else return false;
    }

    function isBackend(address sender) external view override returns (bool) {
        if (sender == backend) return true;
        else return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IStructs {
    struct PresaleInfo {
        address creator;
        address tokenAddress;
        uint256 tokenPrice;
        uint256 hardCap;
        uint256 softCap;
        uint256 openTime;
        uint256 closeTime;
        address unsoldTokenToAddress;
    }

    struct PresaleDexInfo {
        uint256 listingPrice;
        uint256 lpTokensLockDurationInDays;
        uint8 liquidityPercentageAllocation;
        uint256 liquidityAllocationTime;
    }

    struct VestingInfo {
        uint8 vestingPerc1;
        uint8 vestingPerc2;
        uint256 vestingPeriod;
    }
}

interface IPresalePublic is IStructs {
    function initialize(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo
    ) external;
}

interface IPresalePrivate is IStructs {
    function initialize(
        PresaleInfo memory _info,
        PresaleDexInfo memory _dexInfo,
        VestingInfo memory _vestInfo,
        address[] memory _whitelist
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;


interface IStaking{
    
    
    function stakeForUser(address user, uint256 lockUp) external view
        returns (
            uint256 level,
            uint256 totalStakedForUser,
            bool first_lock,
            bool second_lock,
            bool third_lock,
            bool fourth_lock,
            uint256 amountLock,
            uint256 rewardTaken,
            uint256 enteredAt
        );

    function addPresale(address presale) external;

    function addReLock(address user) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IPresaleFactory {
    function isApprover(address sender) external view returns (bool);
    function getFeeParams() external view returns (address, uint256);
    function isBackend(address sender) external view returns (bool);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}