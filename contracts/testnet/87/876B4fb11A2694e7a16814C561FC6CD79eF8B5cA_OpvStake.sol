// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <=0.8.0;
pragma abicoder v2;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./ReentrancyGuard.sol";

contract OpvStake is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    event Newbie(address user, uint256 registerTime);
    event NewDeposit(
        address indexed user,
        uint8 poolId,
        uint8 plan,
        uint256 apr,
        uint256 amount,
        uint256 start,
        uint256 finish,
        uint256 fee
    );
    event UnStake(
        address indexed user,
        uint256 start,
        uint256 amount,
        uint256 profit
    );
    event Withdrawn(address indexed user, uint256 start, uint256 poolId, uint256 plan, uint256 profit);
    event FeePayed(address indexed user, uint256 totalAmount);

    uint256 public PROJECT_FEE = 0 ether;
    uint256 public UNLOCK_FEE = 0 ether;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public TIME_STEP = 1 days;
    uint256 public TIME_STAKE = 0 minutes;
    IERC20 public stakingToken;

    uint256 public totalStakedAmount;

    struct Plan {
        uint256 time;
        uint256 apr;
        uint256 totalStakedAmount;
    }

    struct Pool {
        address rewardAddress;
        address lpAddress;
    }

    struct Deposit {
        uint8 poolId;
        uint8 plan;
        uint256 apr;
        uint256 amount;
        uint256 start;
        uint256 finish;
        address userAddress;
        uint256 fee;
        bool isUnStake;
        uint256 checkpoint;
    }

    struct User {
        Deposit[] deposits;
        address owner;
        uint256 registerTime;
        uint256 lastStake;
    }

    mapping(address => User) users;
    mapping(uint256 => mapping(uint256 => Plan)) public poolPlans;
    mapping(uint256 => Pool) public pools;
    address payable public commissionWallet;

    mapping(address => bool) public whiteList;

    modifier onlySafe() {
        require(whiteList[msg.sender], "require Safe Address.");
        _;
    }

    /**
     * @dev Constructor function
     */
    constructor(address payable wallet) public {
        commissionWallet = wallet;
        pools[1] = Pool(
            0x93C4A5d89D3a5DCc3b17395F0C730E9e0cA0763D,
            0x93C4A5d89D3a5DCc3b17395F0C730E9e0cA0763D
        );
        poolPlans[1][1] = Plan(30, 37037037000, 0);
        poolPlans[1][2] = Plan(60, 20833333300, 0);
        poolPlans[1][3] = Plan(90, 15432098800, 0);
        poolPlans[1][5] = Plan(180, 9259259260, 0);
        poolPlans[1][6] = Plan(360, 5015432100, 0);
        poolPlans[1][7] = Plan(720, 27006172800, 0);
        poolPlans[1][8] = Plan(1080, 1929012350, 0);
    }

    function invest(
        uint8 poolId,
        uint8 plan,
        uint256 _amount
    ) public payable nonReentrant whenNotPaused {
        require(
            IERC20(pools[poolId].lpAddress).allowance(
                msg.sender,
                address(this)
            ) >= _amount,
            "Token allowance too low"
        );
        _invest(poolId, plan, msg.sender, _amount);
        if (PROJECT_FEE > 0) {
            commissionWallet.transfer(PROJECT_FEE);
            emit FeePayed(msg.sender, PROJECT_FEE);
        }
    }

    function _invest(
        uint8 poolId,
        uint8 plan,
        address userAddress,
        uint256 _amount
    ) internal {
        User storage user = users[userAddress];
        Plan storage planStore = poolPlans[poolId][plan];
        uint256 currentTime = block.timestamp;
        require(
            user.lastStake.add(TIME_STAKE) <= currentTime,
            "Required: Must be take time to stake"
        );
        _safeTransferFrom(poolId, userAddress, address(this), _amount);
        user.lastStake = currentTime;
        user.owner = userAddress;

        if (user.deposits.length == 0) {
            user.registerTime = currentTime;
            emit Newbie(userAddress, currentTime);
        }

        (uint256 apr, uint256 finish) = getResult(poolId, plan);
        user.deposits.push(
            Deposit(
                poolId,
                plan,
                apr,
                _amount,
                currentTime,
                finish,
                userAddress,
                PROJECT_FEE,
                false,
                currentTime
            )
        );
        totalStakedAmount = totalStakedAmount.add(_amount);
        planStore.totalStakedAmount = planStore.totalStakedAmount.add(_amount);
        emit NewDeposit(
            userAddress,
            poolId,
            plan,
            apr,
            _amount,
            currentTime,
            finish,
            PROJECT_FEE
        );
    }

    function _safeTransferFrom(
        uint256 poolId,
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        bool sent = IERC20(pools[poolId].lpAddress).transferFrom(
            _sender,
            _recipient,
            _amount
        );
        require(sent, "Token transfer failed");
    }

    function unStake(uint256 start)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(msg.value == UNLOCK_FEE, "Required: Pay fee for unlock stake");
        User storage user = users[_msgSender()];
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].start == start &&
                user.deposits[i].isUnStake == false &&
                block.timestamp >= user.deposits[i].finish
            ) {
                uint256 profit = calculateDivedend(start, _msgSender());
                user.deposits[i].isUnStake = true;
                IERC20(pools[user.deposits[i].poolId].rewardAddress).transfer(
                    _msgSender(),
                    profit
                );
                IERC20(pools[user.deposits[i].poolId].lpAddress).transfer(
                    _msgSender(),
                    user.deposits[i].amount
                );
                user.deposits[i].checkpoint = block.timestamp <
                    user.deposits[i].finish
                    ? block.timestamp
                    : user.deposits[i].finish;
                emit UnStake(
                    msg.sender,
                    start,
                    user.deposits[i].amount,
                    profit
                );
                if (UNLOCK_FEE > 0) {
                    commissionWallet.transfer(UNLOCK_FEE);
                    emit FeePayed(msg.sender, UNLOCK_FEE);
                }
            }
        }
    }

    function calculateDivedend(uint256 start, address userAddress) public view returns (uint256) {
        User memory user = users[userAddress];
        uint256 currentDividends = 0;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].start == start &&
                user.deposits[i].isUnStake == false
            ) {
                uint256 fromTime = user.deposits[i].checkpoint;
                uint256 toTime = user.deposits[i].finish > block.timestamp
                    ? block.timestamp
                    : user.deposits[i].finish;
                currentDividends = user
                    .deposits[i]
                    .amount
                    .mul(toTime.sub(fromTime))
                    .mul(user.deposits[i].apr);
            }
        }
        return currentDividends.div(10**18);
    }

    function setFeeSystem(uint256 _fee) external onlyOwner {
        PROJECT_FEE = _fee;
    }

    function setUnlockFeeSystem(uint256 _fee) external onlyOwner {
        UNLOCK_FEE = _fee;
    }

    function setTime_Step(uint256 _timeStep) external onlyOwner {
        TIME_STEP = _timeStep;
    }

    function setTime_Stake(uint256 _timeStake) external onlyOwner {
        TIME_STAKE = _timeStake;
    }

    function setCommissionsWallet(address payable _addr) external onlyOwner {
        commissionWallet = _addr;
    }

    function updatePlan(
        uint256 poolId,
        uint256 planId,
        Plan memory plan
    ) external onlySafe {
        poolPlans[poolId][planId] = plan;
    }

    function updatePool(uint256 poolId, Pool memory pool) external onlySafe {
        pools[poolId] = pool;
    }

    function handleForfeitedBalance(
        address coinAddress,
        uint256 value,
        address payable to
    ) external onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    function getResult(uint8 poolId, uint8 plan)
        public
        view
        returns (uint256 apr, uint256 finish)
    {
        apr = poolPlans[poolId][plan].apr;

        finish = block.timestamp.add(
            poolPlans[poolId][plan].time.mul(TIME_STEP)
        );
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (User memory userInfo)
    {
        userInfo = users[userAddress];
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getPlanInfo(uint8 poolId, uint8 planId)
        public
        view
        returns (Plan memory plan)
    {
        plan = poolPlans[poolId][planId];
    }

    function isUnStake(address userAddress, uint256 start)
        public
        view
        returns (bool _isUnStake)
    {
        User storage user = users[userAddress];
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].start == start) {
                _isUnStake = user.deposits[i].isUnStake;
            }
        }
    }

    function modifyWhiteList(
        address[] memory newAddr,
        address[] memory removedAddr
    ) public onlyOwner {
        for (uint256 index; index < newAddr.length; index++) {
            whiteList[newAddr[index]] = true;
        }
        for (uint256 index; index < removedAddr.length; index++) {
            whiteList[removedAddr[index]] = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Context.sol";
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
    constructor () internal {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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