/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

//
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

//
/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
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

//
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

//
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = _msgSender();
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract MultiPoolStakingContract is Ownable {
    using SafeMath for uint256;
    address public stakingTokenAddress;
    address public rewardTokenAddress;

    struct Statistics {
        uint256 totalStaked;
        uint256 totalBalance;
        uint256 totalPayout;
        uint256 totalUsers;
    }

    struct PoolInfo {
        address rewardToken;
        uint256 rewardTokenPerDay;
        uint256 minimumStakingAmount;
        uint256 totalStaked;
        uint256 lockTime;
        bool sell;
    }

    struct StakingInfo {
        uint256 stakingAmount;
        uint256 stakingTime;
        uint256 rewardClaimed;
        bool withdrawn;
    }

    mapping(uint256 => mapping(address => StakingInfo[])) public userInfos;
    mapping(address => bool) public isUserExist;

    PoolInfo[] public poolInfos;

    Statistics private statistics;

    event Stake(uint256 pid, address indexed user, uint256 amount);
    event Unstake(uint256 pid, address indexed user, uint256 amount);
    event Claim(uint256 pid, address indexed user, uint256 amount);
    event StakingToken(address indexed stakingTokenAddress);
    event RewardToken(
        uint256 indexed pid,
        address indexed rewardTokenAddress
    );

    constructor(address _stakingTokenAddress, address _rewardTokenAddress) {
        stakingTokenAddress = _stakingTokenAddress;
        rewardTokenAddress = _rewardTokenAddress;
        add (
            _rewardTokenAddress,
            86400,
            500_000 * 10**18,
            86400,
            false
        );
        add (
            _rewardTokenAddress,
            86400,
            1_000_000 * 10**18,
            86400,
            false
        );
        add (
            _rewardTokenAddress,
            86400,
            5_000_000 * 10**18,
            86400,
            false
        );
        add (
            _rewardTokenAddress,
            86400,
            10_000_000 * 10**18,
            86400,
            false
        );
    }

    function add(
        address _rewardTokenAddress,
        uint256 _rewardTokenPerDay,
        uint256 _minimumStakingAmount,
        uint256 _lockTime,
        bool _sellable
    ) public onlyOwner {
        PoolInfo memory pool;
        pool.rewardToken = _rewardTokenAddress;
        pool.rewardTokenPerDay = _rewardTokenPerDay;
        pool.minimumStakingAmount = _minimumStakingAmount;
        pool.lockTime = _lockTime;
        pool.sell = _sellable;
        poolInfos.push(pool);
    }

    function changeRewardTokenAddress(uint256 _pid, address _rewardTokenAddress)
        public
        onlyOwner
    {
        PoolInfo storage pool = poolInfos[_pid];
        pool.rewardToken = _rewardTokenAddress;
    }

    function changeRewardTokenPerDay(uint256 _pid, uint256 _rewardTokenPerDay)
        public
        onlyOwner
    {
        PoolInfo storage pool = poolInfos[_pid];
        pool.rewardTokenPerDay = _rewardTokenPerDay;
    }

    /*
     * @dev Sets the lock time for the pool. The staker must wait for the lock time to withdraw the staked amount.
     * @param _pid Pool id to update
     * @param _minimumStakingAmount Minimum staking amount
     */
    function changeLockTime(uint256 _pid, uint256 _lockTime) public onlyOwner {
        require(
            _lockTime >= 1 days,
            "Error: Lock time must be greater than 1 day"
        );
        require(
            _lockTime <= 30 days,
            "Error: Lock time must not exceed 30 days"
        );
        PoolInfo storage pool = poolInfos[_pid];
        pool.lockTime = _lockTime;
    }

    function changePoolInfoSell(uint256 _pid, bool _sell) public onlyOwner {
        PoolInfo storage pool = poolInfos[_pid];
        pool.sell = _sell;
    }

    function changeMinimumStakingAmount(
        uint256 _pid,
        uint256 _minimumStakingAmount
    ) public onlyOwner {
        PoolInfo storage pool = poolInfos[_pid];
        pool.minimumStakingAmount = _minimumStakingAmount;
    }

    function changeStakingTokenAddress(address _stakingTokenAddress)
        public
        onlyOwner
    {
        stakingTokenAddress = _stakingTokenAddress;
    }

    /*
     * @dev Return the total amount of tokens that the user may earn from the pool currently.
     * @param _pid Pool id
     * @param _user User address
     * @param _sid Staking id
     */

    function pendingReward(
        uint256 _pid,
        address _user,
        uint256 _sid
    ) public view returns (uint256) {
        require(_pid < poolInfos.length, "Error: Pool does not exist");
        require(_user != address(0), "Error: User address is invalid");
        require(
            _sid < userInfos[_pid][_user].length,
            "Error: Staking does not exist"
        );
        require(
            userInfos[_pid][_user][_sid].withdrawn == false,
            "Error: Staking already withdrawn"
        );
        require(
            block.timestamp >=
                userInfos[_pid][_user][_sid].stakingTime.add(
                    poolInfos[_pid].lockTime
                ),
            "Error: Staking is locked"
        );
        require(
            poolInfos[_pid].totalStaked > 0,
            "Error: No staking in the pool"
        );

        PoolInfo storage pool = poolInfos[_pid];
        uint256 rewardAmount = 0;
        StakingInfo[] storage stakingInfos = userInfos[_pid][_user];
        StakingInfo storage stakingInfo = stakingInfos[_sid];
        uint256 totalStaked = pool.totalStaked;
        uint256 stakingAmount = stakingInfo.stakingAmount;
        uint256 timePassed = block.timestamp.sub(stakingInfo.stakingTime);
        uint256 rewardTokenPerDay = pool.rewardTokenPerDay;
        uint256 rewardTokenPerSecond = rewardTokenPerDay.div(86400);
        uint256 rewardTokenPerStakedToken = rewardTokenPerSecond
            .mul(timePassed)
            .mul(stakingAmount)
            .div(totalStaked);
        rewardAmount = rewardAmount.add(rewardTokenPerStakedToken);

        return rewardAmount;
    }

    function getUserActiveStakes(uint256 _pid, address _user)
        public
        view
        returns (StakingInfo[] memory)
    {
        require(_pid < poolInfos.length, "Error: Pool does not exist");
        require(_user != address(0), "Error: User address is invalid");
        StakingInfo[] storage stakingInfos = userInfos[_pid][_user];
        uint256 activeStakes = 0;
        for (uint256 i = 0; i < stakingInfos.length; i++) {
            if (stakingInfos[i].withdrawn == false) {
                activeStakes = activeStakes.add(1);
            }
        }
        StakingInfo[] memory activeStakingInfos = new StakingInfo[](
            activeStakes
        );
        uint256 j = 0;
        for (uint256 i = 0; i < stakingInfos.length; i++) {
            if (stakingInfos[i].withdrawn == false) {
                activeStakingInfos[j] = stakingInfos[i];
                j = j.add(1);
            }
        }
        return activeStakingInfos;
    }

    function getUserInactiveStakes(uint256 _pid, address _user)
        public
        view
        returns (StakingInfo[] memory)
    {
        require(_pid < poolInfos.length, "Error: Pool does not exist");
        require(_user != address(0), "Error: User address is invalid");
        StakingInfo[] storage stakingInfos = userInfos[_pid][_user];
        uint256 inactiveStakes = 0;
        for (uint256 i = 0; i < stakingInfos.length; i++) {
            if (stakingInfos[i].withdrawn == true) {
                inactiveStakes = inactiveStakes.add(1);
            }
        }
        StakingInfo[] memory inactiveStakingInfos = new StakingInfo[](
            inactiveStakes
        );
        uint256 j = 0;
        for (uint256 i = 0; i < stakingInfos.length; i++) {
            if (stakingInfos[i].withdrawn == true) {
                inactiveStakingInfos[j] = stakingInfos[i];
                j = j.add(1);
            }
        }
        return inactiveStakingInfos;
    }

    function pendingTotalPoolReward(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        require(_pid < poolInfos.length, "Error: Pool does not exist");
        require(_user != address(0), "Error: User address is invalid");
        require(
            poolInfos[_pid].totalStaked > 0,
            "Error: No staking in the pool"
        );

        PoolInfo storage pool = poolInfos[_pid];
        uint256 rewardAmount = 0;
        StakingInfo[] storage stakingInfos = userInfos[_pid][_user];
        for (uint256 i = 0; i < stakingInfos.length; i++) {
            if (stakingInfos[i].withdrawn == false) {
                uint256 stakingTime = block.timestamp.sub(
                    stakingInfos[i].stakingTime
                );
                uint256 totalStaked = pool.totalStaked;
                uint256 stakingAmount = stakingInfos[i].stakingAmount;
                uint256 rewardTokenPerDay = pool.rewardTokenPerDay;
                uint256 rewardTokenPerSecond = rewardTokenPerDay.div(86400);
                uint256 rewardTokenPerStakedToken = rewardTokenPerSecond
                    .mul(stakingTime)
                    .mul(stakingAmount)
                    .div(totalStaked);
                rewardAmount = rewardAmount.add(rewardTokenPerStakedToken);
            }
        }
        return rewardAmount;
    }

    function stake(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfos[_pid];
        require(
            pool.minimumStakingAmount <= _amount,
            "Error: Minimum staking amount not met"
        );
        // require that the user does not have more than 1 active stake
        require(
            getUserActiveStakes(_pid, msg.sender).length < 1,
            "Error: User already has an active stake"
        );
        require(
            pool.rewardTokenPerDay > 0,
            "Error: Pool reward token per day not set"
        );
        require(pool.sell == false, "Error: Pool is not accepting new stakes");
        require(
            IERC20(stakingTokenAddress).balanceOf(msg.sender) >= _amount,
            "Error: Insufficient balance"
        );
        require(
            IERC20(stakingTokenAddress).allowance(msg.sender, address(this)) >=
                _amount,
            "Error: Insufficient allowance"
        );

        IERC20(stakingTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        pool.totalStaked = pool.totalStaked.add(_amount);

        StakingInfo memory staking;
        staking.stakingAmount = _amount;
        staking.stakingTime = block.timestamp;
        userInfos[_pid][msg.sender].push(staking);

        statistics.totalStaked = statistics.totalStaked.add(_amount);
        if(isUserExist[msg.sender] == false) {
            statistics.totalUsers = statistics.totalUsers.add(1);
            isUserExist[msg.sender] = true;
        }
    
        emit Stake(_pid, msg.sender, _amount);
    }

    // Unstakes all tokens staked by the user in a particular pool for a particular staking id.
    // The staking duration must be greater than the lock time.
    function unstake(uint256 _pid, uint256 _sid) public {
        PoolInfo storage pool = poolInfos[_pid];
        require(
            _sid < userInfos[_pid][msg.sender].length,
            "Error: Staking does not exist"
        );
        require(
            userInfos[_pid][msg.sender][_sid].withdrawn == false,
            "Error: Staking already withdrawn"
        );
        require(
            block.timestamp >=
                userInfos[_pid][msg.sender][_sid].stakingTime.add(
                    pool.lockTime
                ),
            "Error: Staking is locked"
        );

        uint256 stakingAmount = userInfos[_pid][msg.sender][_sid].stakingAmount;
        IERC20(stakingTokenAddress).transfer(msg.sender, stakingAmount);
        pool.totalStaked = pool.totalStaked.sub(stakingAmount);
        userInfos[_pid][msg.sender][_sid].withdrawn = true;

        statistics.totalStaked = statistics.totalStaked.sub(stakingAmount);

        emit Unstake(_pid, msg.sender, stakingAmount);
    }

    function getStakingItemInfo(
        uint256 _pid,
        address _user,
        uint256 _sid
    ) public view returns (StakingInfo memory) {
        require(_pid < poolInfos.length, "Error: Pool does not exist");
        require(_user != address(0), "Error: User address is invalid");
        require(
            _sid < userInfos[_pid][_user].length,
            "Error: Staking does not exist"
        );
        return userInfos[_pid][_user][_sid];
    }

    function getUserInfo(uint256 _pid, address _user)
        public
        view
        returns (StakingInfo[] memory)
    {
        uint256 _itemCount = userInfos[_pid][_user].length;
        StakingInfo[] memory _stakingInfo = new StakingInfo[](_itemCount);
        for (uint256 i = 0; i < _itemCount; i++) {
            _stakingInfo[i] = userInfos[_pid][_user][i];
        }
        return _stakingInfo;
    }

    function getPoolInfo(uint256 _pid) public view returns (PoolInfo memory) {
        return poolInfos[_pid];
    }

    // Allows the owner to claim the reward tokens from the pool for a particular staking id.
    // The staking duration must be greater than the lock time.
    function claim(uint256 _pid, uint256 _sid) public {
        require(_pid < poolInfos.length, "Error: Pool does not exist");
        require(
            _sid < userInfos[_pid][msg.sender].length,
            "Error: Staking does not exist"
        );
        require(
            userInfos[_pid][msg.sender][_sid].withdrawn == false,
            "Error: Staking already withdrawn"
        );
        require(
            block.timestamp >=
                userInfos[_pid][msg.sender][_sid].stakingTime.add(
                    poolInfos[_pid].lockTime
                ),
            "Error: Staking is locked"
        );

        uint256 rewardAmount = pendingReward(_pid, msg.sender, _sid);
        IERC20(poolInfos[_pid].rewardToken).transfer(msg.sender, rewardAmount);
        userInfos[_pid][msg.sender][_sid].rewardClaimed = userInfos[_pid][
            msg.sender
        ][_sid].rewardClaimed.add(rewardAmount);

        statistics.totalPayout = statistics.totalPayout.add(
            rewardAmount
        );

        emit Claim(_pid, msg.sender, rewardAmount);
    }

    function getStatistics() public view returns (Statistics memory) {
        Statistics memory poolStatistics;
        poolStatistics.totalStaked = statistics.totalStaked;
        poolStatistics.totalUsers = statistics.totalUsers;
        poolStatistics.totalPayout = statistics.totalPayout;
        poolStatistics.totalBalance = IERC20(rewardTokenAddress).balanceOf(
            address(this)
        );
        return poolStatistics;
    }

    receive() external payable {}

    function emergencyWithdraw(uint256 _pid, uint256 _amount)
        external
        onlyOwner
    {
        PoolInfo memory pool = poolInfos[_pid];
        IERC20(pool.rewardToken).transfer(msg.sender, _amount);
    }
}