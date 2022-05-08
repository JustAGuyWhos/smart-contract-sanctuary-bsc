/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.0;

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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
/*


    Staker contract
    ===================================

    
    The basic idea is to keep an accumulating pool "share balance" (accumulatedRewardPerShare):
    Every unit of this balance represents the proportionate reward of a single wei which is staked in the contract.
    This balance is updated in updateRewards() (which is called in each deposit/withdraw/claim)
        according to the time passed from the last update and in proportion to the total tokens staked in the pool.
        Basically: accumulatedRewardPerShare = accumulatedRewardPerShare + (seconds passed from last update) * (rewards per second) / (total tokens staked)
    We also save for each user an accumulation of how much he has already claimed so far.
    And so to calculate a user's rewards, we basically just need to calculate:
    userRewards = accumulatedRewardPerShare * (user's currently staked tokens) - (user's rewards already claimed) 
    And updated the user's rewards already claimed accordingly.


*/

pragma solidity 0.8.0;
contract CATTTOStaking is Ownable {
    using SafeMath for uint256;

    struct UserInfo {
        uint256 deposited;
        uint256 rewardsAlreadyConsidered;
        uint256 TotalTimeLock;
        uint256 HistoricalDeposit;
        uint256 Fee;
        uint256 Remaing;
        uint256 Lock;
        uint256 TimeLock;
    }

    mapping (address => UserInfo) users;
    
    IERC20 public depositToken; // eg. Cattto
    IERC20 public rewardToken;  // eg. Cattto
    IERC20 public emergency;

    // We are not using depositToken.balanceOf in order to prevent DOS attacks (attacker can make the total tokens staked very large)
    // and to add a skim() functionality with which the owner can collect tokens which were transferred outside the stake mechanism.
    uint256 public totalStaked;

    uint256 public rewardPeriodEndTimestamp;
    uint256 public rewardPerSecond; // multiplied by 1e7, to make up for division by 24*60*60

    uint256 public lastRewardTimestamp;
    uint256 public accumulatedRewardPerShare; // multiplied by 1e12,

    uint256 public fee1 = 2;
    uint256 public fee2 = 4;
    uint256 public fee3 = 6;
    uint256 public FeeEmergency = 30;
    uint256 private totalfee = fee1 + fee2 + fee3;


    

    uint256 private _TotalTimeLock;

    bool Lock;



    

    event AddRewards(uint256 amount, uint256 lengthInDays);
    event ClaimReward(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Skim(uint256 amount);
    event WithdrawSOS(address indexed user, uint256 amount);
    

    constructor(address _depositToken, address _rewardToken, address _emergency) {
        depositToken = IERC20(_depositToken);
        rewardToken = IERC20(_rewardToken);
        emergency = IERC20(_emergency);
    }

    
  
    

    // Owner set Rewards and Deposit Address;

    function updateAddress(address _newdepositAddress, address _newrewardsAddress, address _newemergency) public onlyOwner {
        depositToken = IERC20(_newdepositAddress);
        rewardToken =IERC20( _newrewardsAddress);
        emergency = IERC20(_newemergency);
    }

    //For Set Rewards % for staking

    function updateGains(uint256 _fee1, uint256 _fee2, uint256 _fee3) public onlyOwner {
        fee1 = _fee1;
        fee2 = _fee2;
        fee3 = _fee3;
    }

    function updateFeeEmergency (uint256 _emergency) public onlyOwner {
        FeeEmergency = _emergency;
    }

    // Owner should have approved ERC20 before.
    function addRewards(uint256 _rewardsAmount, uint256 _lengthInDays)
    external onlyOwner {
        require(block.timestamp > rewardPeriodEndTimestamp, "Staker: can't add rewards before period finished");
        updateRewards();
        rewardPeriodEndTimestamp = block.timestamp.add(_lengthInDays.mul(24*60*60));
        rewardPerSecond = _rewardsAmount.mul(1e7).div(_lengthInDays).div(24*60*60);
        require(rewardToken.transferFrom(msg.sender, address(this), _rewardsAmount), "Staker: transfer failed");
        emit AddRewards(_rewardsAmount, _lengthInDays);
    }

    // Main function to keep a balance of the rewards.
    // Is called before each user action (stake, unstake, claim).
    // See top of file for high level description.
    function updateRewards()
    public {
        // If no staking period active, or already updated rewards after staking ended, or nobody staked anything - nothing to do
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }
        if ((totalStaked == 0) || lastRewardTimestamp > rewardPeriodEndTimestamp) {
            lastRewardTimestamp = block.timestamp;
            return;
        }

        // If staking period ended, calculate time delta based on the time the staking ended (and not after)
        uint256 endingTime;
        if (block.timestamp > rewardPeriodEndTimestamp) {
            endingTime = rewardPeriodEndTimestamp;
        } else {
            endingTime = block.timestamp;
        }
        uint256 secondsSinceLastRewardUpdate = endingTime.sub(lastRewardTimestamp);
        uint256 totalNewReward = secondsSinceLastRewardUpdate.mul(rewardPerSecond); // For everybody in the pool
        // The next line will calculate the reward for each staked token in the pool.
        //  So when a specific user will claim his rewards,
        //  we will basically multiply this var by the amount the user staked.
        accumulatedRewardPerShare = accumulatedRewardPerShare.add(totalNewReward.mul(1e12).div(totalStaked));
        lastRewardTimestamp = block.timestamp;
        if (block.timestamp > rewardPeriodEndTimestamp) {
            rewardPerSecond = 0;
        }
    }

    // Will deposit specified amount and also send rewards.
    // User should have approved ERC20 before.
    function staking(uint256 _amount, uint256 _timelock)
    external {
        UserInfo storage user = users[msg.sender];
        updateRewards();
        // Send reward for previous deposits more that 7 days
        if (user.deposited > 0 && user.TimeLock >= 7) {
            uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered).mul(user.Fee/100);
            require(rewardToken.transfer(msg.sender, pending), "Staker: transfer failed");
            emit ClaimReward(msg.sender, pending);
        
            user.deposited = user.deposited.add(_amount);
            user.Fee = fee1;
            totalStaked = totalStaked.add(_amount);
            user.TimeLock = user.TimeLock.add(_timelock);
            user.TotalTimeLock = block.timestamp + (user.TotalTimeLock.add(_timelock)*3600*24);
            
            user.HistoricalDeposit = block.timestamp;
            user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).mul(user.Fee/100);
            require(depositToken.transferFrom(msg.sender, address(this), _amount), "Staker: transferFrom failed");
            emit Deposit(msg.sender, _amount);
        }
        // Send rewards for previous deposits more that 14 days

        if (user.deposited > 0 && user.TimeLock == 14) {
            uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered).mul(user.Fee/100);
            require(rewardToken.transfer(msg.sender, pending), "Staker: transfer failed");
            emit ClaimReward(msg.sender, pending);
        
            user.deposited = user.deposited.add(_amount);
            user.Fee = fee2;
            totalStaked = totalStaked.add(_amount);
            user.TimeLock = user.deposited.add(_timelock);
            user.TotalTimeLock = block.timestamp + (user.TotalTimeLock.add(_timelock)*3600*24);
            user.TimeLock = _timelock;
            user.HistoricalDeposit = block.timestamp;
            user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).mul(user.Fee/100);
            require(depositToken.transferFrom(msg.sender, address(this), _amount), "Staker: transferFrom failed");
            emit Deposit(msg.sender, _amount);
        }

        // Send rewards for previous deposits more that 21 days

        if (user.deposited > 0 && user.TimeLock == 21) {
            uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered).mul(user.Fee/100);
            require(rewardToken.transfer(msg.sender, pending), "Staker: transfer failed");
            emit ClaimReward(msg.sender, pending);
        
            user.deposited = user.deposited.add(_amount);
            user.Fee = fee3;
            totalStaked = totalStaked.add(_amount);
            user.TimeLock = user.deposited.add(_timelock);
            user.TotalTimeLock = block.timestamp + (user.TotalTimeLock.add(_timelock)*3600*24);
            user.TimeLock = _timelock;
            user.HistoricalDeposit = block.timestamp;
            user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).mul(user.Fee/100);
            require(depositToken.transferFrom(msg.sender, address(this), _amount), "Staker: transferFrom failed");
            emit Deposit(msg.sender, _amount);
        }

    }
        
    
        // UNSTAKING
        function Unstaking (uint256 _amount) external {
        UserInfo storage user = users[msg.sender];
        require(user.deposited >= _amount, "Staker: balance not enough");
        updateRewards();
        // Send reward for previous deposits
        uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered).mul(user.Fee/100);
        require(rewardToken.transfer(msg.sender, pending), "Staker: reward transfer failed");
        emit ClaimReward(msg.sender, pending);
        user.deposited = user.deposited.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).mul(user.Fee/100);
        require(depositToken.transfer(msg.sender, _amount) && (block.timestamp >= user.TotalTimeLock), "Staker: withdrawal failed tokens yet locked");
        emit Withdraw(msg.sender, _amount);
        }

     

    // Will just send rewards.
    function claim()
    external {
        UserInfo storage user = users[msg.sender];
        if (user.deposited == 0)
            return;

        updateRewards();
        uint256 pending = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered).mul(user.Fee/100);
        require(rewardToken.transfer(msg.sender, pending), "Staker: transfer failed");
        emit ClaimReward(msg.sender, pending);
        user.rewardsAlreadyConsidered = user.deposited.mul(accumulatedRewardPerShare).div(1e12).div(1e7).mul(user.Fee/100);
        
    }

    // Will collect depositTokens (LP tokens) that were sent to the contract
    //  Outside of the staking mechanism.
    function skim()
    external onlyOwner {
        uint256 depositTokenBalance = depositToken.balanceOf(address(this));
        if (depositTokenBalance > totalStaked) {
            uint256 amount = depositTokenBalance.sub(totalStaked);
            require(depositToken.transfer(msg.sender, amount), "Staker: transfer failed");
            emit Skim(amount);
        }
    }

    /* 
        ####################################################
        ################## View functions ##################
        ####################################################

    */

    // Return the user's pending rewards.
    function pendingRewards(address _user)
    public view returns (uint256) {
        UserInfo storage user = users[_user];
        uint256 accumulated = accumulatedRewardPerShare;
        if (block.timestamp > lastRewardTimestamp && lastRewardTimestamp <= rewardPeriodEndTimestamp && totalStaked != 0) {
            uint256 endingTime;
            if (block.timestamp > rewardPeriodEndTimestamp) {
                endingTime = rewardPeriodEndTimestamp;
            } else {
                endingTime = block.timestamp;
            }
            uint256 secondsSinceLastRewardUpdate = endingTime.sub(lastRewardTimestamp);
            uint256 totalNewReward = secondsSinceLastRewardUpdate.mul(rewardPerSecond);
            accumulated = accumulated.add(totalNewReward.mul(1e12).div(totalStaked));
        }
        return user.deposited.mul(accumulated).div(1e12).div(1e7).sub(user.rewardsAlreadyConsidered).mul(user.Fee/100);
    }

    // Returns misc details for the front end.
    function getFrontendView(address _user)  
    external view returns (uint256 _rewardPerSecond, uint256 _secondsLeft, uint256 _deposited, uint256 _pending ) {
        UserInfo storage user = users[_user];
        if (block.timestamp < rewardPeriodEndTimestamp) {
            _secondsLeft = rewardPeriodEndTimestamp.sub(block.timestamp); 
            _rewardPerSecond = rewardPerSecond.div(1e7);
        } 
        _deposited = users[msg.sender].deposited;
        _pending = pendingRewards(msg.sender);
        

    }

    
    

    

 }