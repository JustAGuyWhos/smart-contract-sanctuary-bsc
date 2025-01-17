// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Tokens {
    function swapExactTokenForToken(
        address[2] memory path_,
        uint amountIn,
        uint amountOutMin,
        address to_,
        uint total_
    ) external returns (uint amountOut);
}

interface IPartner {
    function isPartner(address addr) external view returns (bool);
}

contract KNS_Deposit is OwnableUpgradeable {
    IERC20 public U;
    IERC20 public KNS;
    IPartner public partner;
    uint public id;
    uint public totalDeposit;
    address public banker;

    struct UserInfo {
        uint totalStake;
        uint totalClaimed;
        uint[] userSlot;
        uint stageClaimed;
        uint directTotal;
        uint secondTotal;
        bool isRenew;
    }

    mapping(address => UserInfo) public userInfo;

    struct SlotInfo {
        uint amount;
        uint depositTime;
        address owner;
        uint claimed;
        bool isRenew;
        uint startTime;
        uint endTime;
        uint claimTime;
        uint toClaim;
    }


    mapping(uint => SlotInfo) public slotInfo;
    mapping(address => bool) public isPartner;
    uint public round;
    mapping(uint => uint) public roundPrice;
    mapping(uint => uint) public roundLeft;
    uint public startTime;

    struct InvitorInfo {
        bool isBond;
        uint invitor;
    }

    mapping(address => InvitorInfo) public invitorInfo;

    event Deposit(address indexed player, uint indexed slot, uint indexed amount);
    event Claim(address indexed player, uint indexed amount);
    event UnDeposit(address indexed player, uint indexed slot, uint indexed amount);
    event ChangeRenew(address indexed player, bool indexed isRenew);
    event ClaimStage(address indexed player, uint indexed amount);
    event ClaimDirect(address indexed player, uint indexed amount);
    event ClaimSecond(address indexed player, uint indexed amount);
    event Bond(address indexed player, uint indexed invitor);

    function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        id = 1;
        round = 1;
        roundPrice[1] = 10000 ether;
        roundPrice[2] = 12000 ether;
        roundPrice[3] = 15000 ether;
        roundLeft[1] = 1;
        roundLeft[2] = 30;
        roundLeft[3] = 50;
    }

    modifier onlyEOA{
        require(msg.sender == tx.origin, 'only eoa');
        _;
    }

    function testEvent() external onlyOwner {
        emit Deposit(msg.sender, 1, 1 ether);
        emit Claim(msg.sender, 1 ether);
        emit UnDeposit(msg.sender, 1, 1 ether);
        emit ChangeRenew(msg.sender, true);
        emit ClaimStage(msg.sender, 2 ether);
        emit ClaimDirect(msg.sender, 4 ether);
        emit ClaimSecond(msg.sender, 5 ether);
        emit Bond(msg.sender, 123123);
    }

    function setPartner(address addr) external onlyOwner {
        partner = IPartner(addr);
    }

    function changeBanker(address addr) external onlyOwner {
        banker = addr;
    }

    function setToken(address u_, address kns_) external onlyOwner {
        U = IERC20(u_);
        KNS = IERC20(kns_);
    }

    function setStartTime(uint time_) external onlyOwner {
        startTime = time_;
    }


    function bond(uint invitor, bytes32 r, bytes32 s, uint8 v) external onlyEOA {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, invitor));
        address a = ecrecover(hash, v, r, s);
        require(a == banker, 'not banker');
        require(!invitorInfo[msg.sender].isBond, 'have intitor');
        invitorInfo[msg.sender].invitor = invitor;
        emit Bond(msg.sender, invitor);
    }

    function deposit(uint amount) external onlyEOA {
        require(block.timestamp > startTime, 'not start yet');
        require(amount > 0, 'amount must > 0');
        require(amount % 100e18 == 0, 'must be 100 multiple');
        UserInfo storage user = userInfo[msg.sender];
        bool _isRenew = user.isRenew;
        U.transferFrom(msg.sender, address(this), amount);
        user.totalStake += amount;
        SlotInfo storage slot = slotInfo[id];
        slot.amount = amount;
        slot.depositTime = block.timestamp;
        slot.owner = msg.sender;
        slot.startTime = getTime();
        slot.endTime = getTime() + 7 days;
        slot.isRenew = _isRenew;
        slot.claimTime = block.timestamp;
        user.userSlot.push(id);
        emit Deposit(msg.sender, id, amount);
        id++;
        totalDeposit += amount;
    }

    function getTime() public view returns (uint){
        uint time = block.timestamp;
        uint out = time - (time - 16 * 3600) % 86400;
        return out;
    }


    function _calculate(uint slotId) public view returns (uint){
        SlotInfo storage slot = slotInfo[slotId];
        uint toClaim;
        {
            uint amount = slot.amount;
            uint endTime = slot.endTime;
            uint claimTime = slot.claimTime;
            toClaim = slot.toClaim;
            uint time = block.timestamp;
            uint claimed = slot.claimed;
            bool renew = slot.isRenew;
            uint times = (time - claimTime) / 86400;
            uint left = (time - claimTime) % 86400;
            uint tempAmount = amount / 100;
            uint rate = tempAmount / 86400;
            if (renew) {
                for (uint i = 0; i < times; i++) {
                    if (toClaim + claimed >= amount) {
                        toClaim += (times - i) * tempAmount;
                        break;
                    }
                    toClaim += tempAmount;
                    toClaim += toClaim * 15 / 1000;
                }
                toClaim += rate * left;
            } else {
                if (claimTime < endTime) {
                    if (block.timestamp > endTime) {
                        time = endTime;
                        times = (time - claimTime) / 86400;
                        left = (time - claimTime) % 86400;
                    }

                    toClaim += times * tempAmount;
                }
            }
        }
        return toClaim;
    }

    function calculateReward(address addr) external view returns (uint){
        UserInfo storage user = userInfo[addr];
        uint[] memory lists = user.userSlot;
        uint rew;
        for (uint i = 0; i < lists.length; i++) {
            rew += _calculate(lists[i]);
        }
        return rew;
    }

    function claimAll() external onlyEOA {
        UserInfo storage user = userInfo[msg.sender];
        uint[] memory lists = user.userSlot;
        uint rew;
        for (uint i = 0; i < lists.length; i++) {
            SlotInfo storage slot = slotInfo[lists[i]];
            uint temp = _calculate(lists[i]);
            slot.claimed += temp;
            rew += temp;
            slot.claimTime = block.timestamp;
        }
        user.totalClaimed += rew;
        emit Claim(msg.sender, rew);
        U.transfer(msg.sender, rew * 95 / 100);
        swapBack(rew * 5 / 100);

    }

    function swapBack(uint amount) internal {
        U.approve(address(KNS), amount);
        address[2] memory path;
        path[0] = address(U);
        path[1] = address(KNS);
        Tokens(address(KNS)).swapExactTokenForToken(path, amount, 0, address(this), block.timestamp + 1000);
    }

    function claimSlot(uint slotId) external onlyEOA {
        SlotInfo storage slot = slotInfo[slotId];
        require(slot.owner == msg.sender, 'not owner');
        uint temp = _calculate(slotId);
        slot.claimed += temp;
        slot.claimTime = block.timestamp;
        userInfo[msg.sender].totalClaimed += temp;
        U.transfer(msg.sender, temp * 95 / 100);
        emit Claim(msg.sender, temp);
        swapBack(temp * 5 / 100);
    }

    function unDeposit(uint slotId) external onlyEOA {
        SlotInfo storage slot = slotInfo[slotId];
        require(slot.owner == msg.sender, 'not owner');
        require(block.timestamp > slot.endTime, 'not end');
        uint temp = _calculate(slotId);
        U.transfer(msg.sender, slot.amount + temp);
        userInfo[msg.sender].totalClaimed += temp;
        UserInfo storage user = userInfo[msg.sender];
        uint[] memory lists = user.userSlot;
        user.totalStake -= slot.amount;
        totalDeposit -= slot.amount;
        for (uint i = 0; i < lists.length; i++) {
            if (lists[i] == slotId) {
                user.userSlot[i] = user.userSlot[lists.length - 1];
                user.userSlot.pop();
                break;
            }
        }
        emit UnDeposit(msg.sender, slotId, slot.amount + temp);
        delete slotInfo[slotId];
    }

    function changeRenew(bool isRenew) external onlyEOA {
        require(isRenew != userInfo[msg.sender].isRenew, 'same');
        userInfo[msg.sender].isRenew = isRenew;
        uint[] memory list = userInfo[msg.sender].userSlot;
        for (uint i = 0; i < list.length; i++) {
            _changeRenew(list[i], isRenew);
        }
        emit ChangeRenew(msg.sender, isRenew);
    }

    function _changeRenew(uint slotId, bool isRenew) internal {
        SlotInfo storage slot = slotInfo[slotId];
        require(slot.owner == msg.sender, 'not owner');
        slot.isRenew = isRenew;
        uint temp = _calculate(slotId);
        slot.toClaim += temp;
        slot.claimTime = block.timestamp;
        if (!isRenew) {
            uint start = slot.startTime;
            uint diff = block.timestamp - start;
            slot.endTime = slot.endTime + (diff / 7 days) * 7 days;
        }

    }


    function withdraw() external onlyOwner {
        U.transfer(msg.sender, U.balanceOf(address(this)));
    }

    function checkUserInfo(address addr) external view returns (uint value, bool isPartners){
        isPartners = partner.isPartner(addr);
        uint[] memory lists = userInfo[addr].userSlot;
        value = 0;

        for (uint i = 0; i < lists.length; i++) {
            SlotInfo storage slot = slotInfo[lists[i]];
            if (slot.isRenew) {
                value += slot.amount;
            } else {
                if (block.timestamp < slot.endTime) {
                    value += slot.amount;
                }
            }
        }
    }

    function stageShare(uint reward, uint totalReward, bytes32 r, bytes32 s, uint8 v) external onlyEOA {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, reward, totalReward));
        address a = ecrecover(hash, v, r, s);
        require(a == banker, 'not banker');
        require(userInfo[msg.sender].stageClaimed + reward <= totalReward, 'out of limit');
        U.transfer(msg.sender, reward);
        userInfo[msg.sender].stageClaimed += reward;
        emit ClaimStage(msg.sender, reward);
    }

    function claimDynamic(
        uint directReward,
        uint totalDirectReward,
        uint secondReward,
        uint totalSecondReward,
        bytes32 r,
        bytes32 s,
        uint8 v) external onlyEOA {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, directReward, totalDirectReward, secondReward, totalSecondReward));
        address a = ecrecover(hash, v, r, s);
        require(a == banker, 'not banker');
        require(userInfo[msg.sender].directTotal + directReward <= totalDirectReward, 'out of limit');
        require(userInfo[msg.sender].secondTotal + secondReward <= totalSecondReward, 'out of limit');
        uint rew = directReward + secondReward;
        U.transfer(msg.sender, rew * 95 / 100);
        swapBack(rew * 5 / 100);
        userInfo[msg.sender].secondTotal += secondReward;
        userInfo[msg.sender].directTotal += directReward;
        emit ClaimDirect(msg.sender, directReward);
        emit ClaimSecond(msg.sender, secondReward);
    }

    function checkUserSlot(address addr) public view returns (uint[] memory, SlotInfo[] memory){
        uint[] memory lists = userInfo[addr].userSlot;
        SlotInfo[] memory slots = new SlotInfo[](lists.length);
        for (uint i = 0; i < lists.length; i++) {
            slots[i] = slotInfo[lists[i]];
        }
        return (lists, slots);
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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