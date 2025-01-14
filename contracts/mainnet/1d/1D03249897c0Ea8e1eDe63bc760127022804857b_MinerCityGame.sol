// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IPool {
    function deposit(uint256 _amount, address _account) external;
    function withdraw(uint256 _amount, address _account) external;
}

contract MinerCityGame is Ownable, Pausable {

    uint256 public rigsId = 0;
    uint256 public devicesId = 0;
    uint256 public genfee = 5000000000000000;

    IERC20 token;

    struct Device {
        string model;
        uint256 speed;
        uint256 price;
        uint256 ecost;
        uint256 amount;
    }

    struct Rig {
        string model;
        uint256 price;
        uint256 slot;
        uint256 amount;
    }

    struct Machine {
        uint256 id;
        uint256 amount;
    }

    struct UserData {
        uint256 energy;
        uint256 generator;
        mapping(uint256 => uint256) rigs;
        mapping(uint256 => uint256) devices;
    }

    struct PoolData {
        uint256 energy;
        uint256 speed;
        mapping(uint256 => uint256) rigs;
        mapping(uint256 => uint256) devices;
    }

    mapping(address => bool) private _privilage;
    mapping(uint256 => Device) public Devices;
    mapping(address => address) public rf;
    mapping(address => bool) private _gift;
    mapping(uint256 => Rig) public Rigs;
    mapping(address => UserData) public userData;
    mapping(address => mapping(address => PoolData)) private poolData;
    mapping(address => uint256[]) public has_rigs;
    mapping(address => uint256[]) public has_devices;
    mapping(address => mapping(address => uint256[])) private pool_rigs;
    mapping(address => mapping(address => uint256[])) private pool_devices;

    function Setup(address token_addr) external onlyOwner {
        token = IERC20(token_addr);
    }

    function addRigs(
        string memory _model,
        uint256 _price,
        uint256 _amount,
        uint256 _slot
    ) external onlyOwner {
        Rig storage rig = Rigs[rigsId];
        rig.model = _model;
        rig.price = _price;
        rig.slot = _slot;
        rig.amount = _amount;
        rigsId += 1;
    }

    function updateRigs(
        uint256 _id,
        string memory _model,
        uint256 _price,
        uint256 _amount
    ) external onlyOwner {
        Rig storage rig = Rigs[_id];
        rig.model = _model;
        rig.price = _price;
        rig.amount = _amount;
    }

    function addDevice(
        string memory _model,
        uint256 _speed,
        uint256 _ecost,
        uint256 _amount,
        uint256 _price
    ) external onlyOwner {
        Device storage device = Devices[devicesId];
        device.model = _model;
        device.speed = _speed;
        device.price = _price;
        device.ecost = _ecost;
        device.amount = _amount;
        devicesId += 1;
    }

    function updateDevice(
        uint256 _id,
        string memory _model,
        uint256 _speed,
        uint256 _ecost,
        uint256 _amount,
        uint256 _price
    ) external onlyOwner {
        Device storage device = Devices[_id];
        device.model = _model;
        device.speed = _speed;
        device.price = _price;
        device.ecost = _ecost;
        device.amount = _amount;
    }

    function buyGenerator() external payable {
        UserData storage user = userData[msg.sender];
        uint256 _coefficient = (2**user.generator);
        uint256 _fee = genfee * _coefficient;
        require(msg.value >= _fee, "I");
        user.generator += 1;
        user.energy += 100 * _coefficient;
    }

    function buyRig(
        uint256 _id,
        uint256 _amount,
        address _r
    ) external {
        Rig storage rig = Rigs[_id];
        UserData storage user = userData[msg.sender];

        require(rig.amount >= _amount, "N");
        uint256 totalprice = rig.price * _amount;
        uint256 refincome = (totalprice * 10) / 100;
        token.transferFrom(msg.sender, address(this), totalprice);
        
        if (
            _r != address(0x0) &&
            _r != msg.sender &&
            rf[msg.sender] == address(0x0)
        ) {
            rf[msg.sender] = _r;
        }
        
        if (rf[msg.sender] != address(0x0)) {
            token.transferFrom(msg.sender, rf[msg.sender], refincome);
            token.burn(totalprice - refincome);
        } else {
            token.burn(totalprice);
        }

        if (_gift[msg.sender] == false) {
            user.energy = 100;
            _gift[msg.sender] = true;
        }

        _addUserRigs(msg.sender, _id);

        user.rigs[_id] += _amount;
        rig.amount -= _amount;
    }

    function buyDevice(uint256 _id, uint256 _am, address _r) external {
        Device storage device = Devices[_id];
        UserData storage user = userData[msg.sender];

        require(device.amount >= _am, "N");
        uint256 totalprice = device.price * _am;
        uint256 refincome = (totalprice * 10) / 100;
        token.transferFrom(msg.sender, address(this), totalprice);
        
        if (_r != address(0x0) && _r != msg.sender && rf[msg.sender] == address(0x0)) { rf[msg.sender] = _r;}

        if (rf[msg.sender] != address(0x0)) {
            token.transferFrom(msg.sender, rf[msg.sender], refincome);
            token.burn(totalprice - refincome);
        } else {
            token.burn(totalprice);
        }

        user.devices[_id] += _am;

        _addUserdevices(msg.sender, _id);

        device.amount -= _am;
    }

    function reduceUserRig(address _acc, uint256 _id, uint256 _a)
        external
        hasPrivilage
    {
        UserData storage user = userData[_acc];
        (bool blnIsUserRig, ) = _isUserRigs(_acc, _id);
        require(blnIsUserRig && user.rigs[_id] >= _a, "N");
        user.rigs[_id] -= _a;
    }

    function increaseUserRig(address _acc, uint256 _id, uint256 _a)
        external
        hasPrivilage
    {
        (bool blnIsUserRig, ) = _isUserRigs(_acc, _id);
        require(blnIsUserRig, "N");
        userData[_acc].rigs[_id] += _a;
    }

    function reduceUserDevice(address _acc, uint256 _id, uint256 _a)
        external
        hasPrivilage
    {
        UserData storage user = userData[_acc];
        (bool blnIsUserDevice, ) = _isUserDevices(_acc, _id);
        require(blnIsUserDevice && user.devices[_id] >= _a, "N");
        user.devices[_id] -= _a;
    }

    function increaseUserDevice(address _acc, uint256 _id, uint256 _a)
        external
        hasPrivilage
    {
        (bool blnIsUserDevice, ) = _isUserDevices(_acc, _id);
        require(blnIsUserDevice, "N");
        userData[_acc].devices[_id] += _a;
    }

    function getUserData(address _acc)
        public
        view
        returns (
            uint256 _en,
            uint256 _gen,
            uint256[] memory rids,
            uint256[] memory rigs,
            uint256[] memory dids,
            uint256[] memory devices
        )
    {
        UserData storage user = userData[_acc];
        _en = user.energy;
        _gen = user.generator;

        rigs = new uint256[](has_rigs[_acc].length);
        rids = new uint256[](has_rigs[_acc].length);

        for (uint256 i; i < has_rigs[_acc].length; i++) {
            rigs[i] = userData[_acc].rigs[has_rigs[_acc][i]];
            rids[i] = has_rigs[_acc][i];
        }

        devices = new uint256[](has_devices[_acc].length);
        dids = new uint256[](has_devices[_acc].length);

        for (uint256 i; i < has_devices[_acc].length; i++) {
            devices[i] = userData[_acc].devices[has_devices[_acc][i]];
            dids[i] = has_devices[_acc][i];
        }
    }

    function getPoolData(address _pool, address _acc)
        public
        view
        returns (
            uint256[] memory rids,
            uint256[] memory rigs,
            uint256[] memory dids,
            uint256[] memory devices,
            uint256 energy,
            uint256 speed
        )
    {
        rigs = new uint256[](pool_rigs[_pool][_acc].length);
        rids = new uint256[](pool_rigs[_pool][_acc].length);

        for (uint256 i; i < pool_rigs[_pool][_acc].length; i++) {
            rigs[i] = poolData[_pool][_acc].rigs[
                pool_rigs[_pool][_acc][i]
            ];
            rids[i] = pool_rigs[_pool][_acc][i];
        }

        devices = new uint256[](pool_devices[_pool][_acc].length);
        dids = new uint256[](pool_devices[_pool][_acc].length);
        for (uint256 i; i < pool_devices[_pool][_acc].length; i++) {
            devices[i] = poolData[_pool][_acc].devices[
                pool_devices[_pool][_acc][i]
            ];
            dids[i] = pool_devices[_pool][_acc][i];
        }

        energy = poolData[_pool][_acc].energy;
        speed = poolData[_pool][_acc].speed;
    }

    function startMining(
        address _padd,
        uint256[] memory _rids,
        uint256[] memory _ramo,
        uint256[] memory _dids,
        uint256[] memory _damo
    ) external {
        require(_rids.length > 0 && _rids.length == _ramo.length && _dids.length > 0 && _dids.length == _damo.length, "MBR");

        UserData storage user = userData[msg.sender];
        PoolData storage pool = poolData[_padd][msg.sender];

        uint256 _en = user.energy;
        uint256 _ecost = 0;
        uint256 _speed = 0;
        uint256 _have_slots = 0;
        uint256 _need_slots = 0;

        for (uint256 i; i < _rids.length; i++) {
            (bool blnIsUserRig, ) = _isUserRigs(msg.sender, _rids[i]);
            require(user.rigs[_rids[i]] >= _ramo[i] && blnIsUserRig, "N");
            _have_slots += (Rigs[_rids[i]].slot * _ramo[i]);

            pool.rigs[_rids[i]] += _ramo[i];
            user.rigs[_rids[i]] -= _ramo[i];
            _addPoolRig(_padd, msg.sender, _rids[i]);
        }

        for (uint256 i; i < _dids.length; i++) {
            (bool blnIsUserDevice, ) = _isUserDevices(msg.sender, _dids[i]);
            require(
                user.devices[_dids[i]] >= _damo[i] && blnIsUserDevice,
                "ND"
            );
            _need_slots += _damo[i];
            _ecost += Devices[_dids[i]].ecost * _damo[i];
            _speed += Devices[_dids[i]].speed * _damo[i];

            pool.devices[_dids[i]] += _damo[i];
            user.devices[_dids[i]] -= _damo[i];
            _addPoolDevice(_padd, msg.sender, _dids[i]);
        }

        require(_en >= _ecost && _have_slots >= _need_slots, "N");

        IPool _ipool = IPool(_padd);

        _ipool.deposit(_speed * (10**18), msg.sender);

        user.energy -= _ecost;
        pool.energy += _ecost;
        pool.speed += _speed;
    }

    function stopMining(address _pool) external {
        UserData storage user = userData[msg.sender];
        PoolData storage pool = poolData[_pool][msg.sender];

        for (uint256 i; i < pool_rigs[_pool][msg.sender].length; i++) {
            uint256 _r = pool.rigs[pool_rigs[_pool][msg.sender][i]];
            pool.rigs[pool_rigs[_pool][msg.sender][i]] -= _r;
            user.rigs[pool_rigs[_pool][msg.sender][i]] += _r;
        }

        for (uint256 i; i < pool_devices[_pool][msg.sender].length; i++) {
            uint256 _d = pool.devices[pool_devices[_pool][msg.sender][i]];
            pool.devices[pool_devices[_pool][msg.sender][i]] -= _d;
            user.devices[pool_devices[_pool][msg.sender][i]] += _d;
        }
        uint256 _e = pool.energy;
        uint256 _s = pool.speed;

        IPool _ipool = IPool(_pool);
        _ipool.withdraw(_s * (10**18), msg.sender);

        pool.energy -= _e;
        user.energy += _e;
        pool.speed -= _s;
    }

    function claimReward(address _pool) external {
        IPool _ipool = IPool(_pool);
        _ipool.withdraw(0, msg.sender);
    }

    // Helper

    function _addPoolRig(
        address _pool,
        address _account,
        uint256 _id
    ) private {
        (bool blnIsPoolRig, ) = _isPoolRigs(_pool, _account, _id);
        if (!blnIsPoolRig) pool_rigs[_pool][_account].push(_id);
    }

    function _isPoolRigs(
        address _pool,
        address _account,
        uint256 _id
    ) public view returns (bool, uint256) {
        for (uint256 s = 0; s < pool_rigs[_pool][_account].length; s += 1) {
            if (_id == pool_rigs[_pool][_account][s]) return (true, s);
        }
        return (false, 0);
    }

    function _addPoolDevice(
        address _pool,
        address _account,
        uint256 _id
    ) private {
        (bool blnIsPoolDevice, ) = _isPoolDevices(_pool, _account, _id);
        if (!blnIsPoolDevice) pool_devices[_pool][_account].push(_id);
    }

    function _isPoolDevices(
        address _pool,
        address _account,
        uint256 _id
    ) public view returns (bool, uint256) {
        for (uint256 s = 0; s < pool_devices[_pool][_account].length; s += 1) {
            if (_id == pool_devices[_pool][_account][s]) return (true, s);
        }
        return (false, 0);
    }

    function _isUserRigs(address _account, uint256 _id)
        public
        view
        returns (bool, uint256)
    {
        for (uint256 s = 0; s < has_rigs[_account].length; s += 1) {
            if (_id == has_rigs[_account][s]) return (true, s);
        }
        return (false, 0);
    }

    function _addUserRigs(address _account, uint256 _id) private {
        (bool blnIsUserRig, ) = _isUserRigs(_account, _id);
        if (!blnIsUserRig) has_rigs[_account].push(_id);
    }

    function _isUserDevices(address _account, uint256 _id)
        public
        view
        returns (bool, uint256)
    {
        for (uint256 s = 0; s < has_devices[_account].length; s += 1) {
            if (_id == has_devices[_account][s]) return (true, s);
        }
        return (false, 0);
    }

    function _addUserdevices(address _account, uint256 _id) private {
        (bool blnIsUserDevice, ) = _isUserDevices(_account, _id);
        if (!blnIsUserDevice) has_devices[_account].push(_id);
    }

    function withdrawBnb() external onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }

    modifier hasPrivilage() {
        require(_privilage[_msgSender()] == true, "N");
        _;
    }

    function addPrivilage(address _converter, bool _value)
        external
        onlyOwner
    {
        _privilage[_converter] = _value;
    }
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
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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

    function burn(uint256 amount) external;

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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}