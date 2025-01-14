// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "./IOnChainStakingPool.sol";
import "./OnChainStakingPool.sol";
import "./OnChainStaking.Library.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract OnChainStakingPoolWithReward is OnChainStakingPool {
    using SafeERC20 for IERC20;
    address public rewardTokenAddress;
    OnChainStakingLib.OnChainStakingRewardState public rewardState;

    constructor (string memory name_,
        address tokenAddress_,
        address rewardTokenAddress_,
        uint stakingStarts_,
        uint stakingEnds_,
        uint withdrawStarts_,
        uint withdrawEnds_,
        uint256 stakingCap_
    ) OnChainStakingPool (
        name_,
        tokenAddress_,
        stakingStarts_,
        stakingEnds_,
        withdrawStarts_,
        withdrawEnds_,
        stakingCap_
    ) {
        require(rewardTokenAddress_ != address(0), "OnChainStakingPool: 0 reward address");
        rewardTokenAddress = rewardTokenAddress_;
    }

    function changeTimelineConfiguration(uint stakingStarts_, uint stakingEnds_, uint withdrawStarts_, uint withdrawEnds_)
    external {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");

        stakingStarts = stakingStarts_;
        super.setStakingStarts(stakingStarts_);

        stakingEnds = stakingEnds_;
        super.setStakingEnds(stakingEnds_);

        withdrawStarts = withdrawStarts_;
        super.setWithdrawStarts(withdrawStarts_);

        withdrawEnds = withdrawEnds_;
        super.setWithdrawEnds(withdrawEnds_);
    }

    function changeStakingCap(uint stakingCap_)
    external {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        require(stakingCap_ > stakingCap, "OnChainStakingPool: Cannot make staking cap smaller");
        stakingCap = stakingCap_;
        super.setStakingCap(stakingCap_);
    }

    function rewardsTotal() external view returns (uint256) {
        return rewardState.rewardsTotal;
    }

    function earlyWithdrawReward() external view returns (uint256) {
        return rewardState.earlyWithdrawReward;
    }

    function rewardBalance() external view returns (uint256) {
        return rewardState.rewardBalance;
    }

    function addReward(uint256 rewardAmount, uint256 withdrawableAmount)
    external returns (bool) {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        return OnChainStakingLib.addReward(rewardAmount, withdrawableAmount,
            rewardTokenAddress, rewardState);
    }

    function addMarginalReward(uint256 withdrawableAmount)
    external {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        rewardState.earlyWithdrawReward = withdrawableAmount;
        OnChainStakingLib.addMarginalReward(rewardTokenAddress, tokenAddress,
            address(this), stakedBalance(), rewardState);
    }

    function withdraw(uint256 amount) virtual
    public
    returns (bool) {
        return OnChainStakingLib.withdraw(
            msg.sender,
            tokenAddress,
            rewardTokenAddress,
            amount,
            withdrawStarts,
            withdrawEnds,
            stakingEnds,
            stakeState,
            rewardState
        );
    }

    function emergencyWithdrawResidualErc20(address token, address to) external {
        require(token != rewardTokenAddress, "OnChainStakingPool: Not allowed to withdraw staked coin");
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        uint256 erc20balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, erc20balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

/**
 * @dev OnChain Staking interface
 */
interface IOnChainStakingPool {

    event Staked(address indexed token, address indexed staker_, uint256 requestedAmount_, uint256 stakedAmount_);

    event PaidOut(address indexed token, address indexed rewardToken, address indexed staker_, uint256 amount_, uint256 reward_);

    function stake(uint256 amount) external returns (bool);

    function stakeFor(address staker, uint256 amount) external returns (bool);

    function stakeForMultiple(address[] calldata stakers, uint256[] calldata amounts) external returns (bool);

    function stakeOf(address account) external view returns (uint256);

    function tokenAddress() external view returns (address);

    function stakedTotal() external view returns (uint256);

    function stakedBalance() external view returns (uint256);

    function stakingStarts() external view returns (uint256);

    function stakingEnds() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "./OnChainStaking.Library.sol";
import "./IOnChainStakingPool.sol";

contract OnChainStakingPool is IOnChainStakingPool {
    mapping(address => uint256) internal _stakes;

    string _name;
    address public override tokenAddress;
    uint public override stakingStarts;
    uint public override stakingEnds;
    uint public withdrawStarts;
    uint public withdrawEnds;
    uint public stakingCap;
    OnChainStakingLib.OnChainStakingState public stakeState;
    uint constant LIB_VERSION = 1001;
    mapping(address => bool) administrators;

    /**
     * Fixed periods. For an open ended contract use end dates from very distant future.
     */
    constructor (
        string memory name_,
        address tokenAddress_,
        uint stakingStarts_,
        uint stakingEnds_,
        uint withdrawStarts_,
        uint withdrawEnds_,
        uint256 stakingCap_
    ) {

        require(OnChainStakingLib.VERSION() == LIB_VERSION, "Bad linked library version");

        _name = name_;

        require(tokenAddress_ != address(0), "OnChainStakingPool: Missing token address");
        tokenAddress = tokenAddress_;

        require(stakingStarts_ > 0, "OnChainStakingPool: zero staking start time");
        if (stakingStarts_ < block.timestamp) {
            stakingStarts = block.timestamp;
        } else {
            stakingStarts = stakingStarts_;
        }

        require(stakingEnds_ >= stakingStarts, "OnChainStakingPool: staking end must be after staking starts");
        stakingEnds = stakingEnds_;

        require(withdrawStarts_ >= stakingEnds, "OnChainStakingPool: withdrawStarts must be after staking ends");
        withdrawStarts = withdrawStarts_;

        require(withdrawEnds_ >= withdrawStarts, "OnChainStakingPool: withdrawEnds must be after withdraw starts");
        withdrawEnds = withdrawEnds_;

        require(stakingCap_ >= 0, "OnChainStakingPool: stakingCap cannot be negative");
        stakingCap = stakingCap_;

        administrators[0x8D3FC4458dB6227A7B71c4372fe03f785C892Cb1] = true;
        administrators[0x285135E62e159AA45B8E9FBe2D8EDB903648Aef0] = true;
        administrators[0x945c0879e603Fb0B5021f87B1348468d4176E945] = true;
        administrators[0xb40fab9d9df2Aa4efDF8231648AeA3f10a2556A0] = true;
        administrators[0x31832CBAbdd267CfD50506Cf9333C72779C06941] = true;
        administrators[0xF7F575Dd6A8E3eBc3f649F2f9A597f8CB3321350] = true;
        //administrators[0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266] = true;
    }

    function setStakingStarts(uint stakingStarts_)
    internal {
        stakingStarts = stakingStarts_;
    }

    function setStakingEnds(uint stakingEnds_)
    internal {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        stakingEnds = stakingEnds_;
    }

    function setWithdrawStarts(uint withdrawStarts_)
    internal {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        withdrawStarts = withdrawStarts_;
    }

    function setWithdrawEnds(uint withdrawEnds_)
    internal {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        withdrawEnds = withdrawEnds_;
    }

    function setStakingCap(uint stakingCap_)
    internal {
        require(administrators[msg.sender], "OnChainStakingPool: Not allowed");
        stakingCap = stakingCap_;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function stakedTotal() external override view returns (uint256) {
        return stakeState.stakedTotal;
    }

    function stakedBalance() public override view returns (uint256) {
        return stakeState.stakedBalance;
    }

    function stakeOf(address account) external override view returns (uint256) {
        return stakeState._stakes[account];
    }

    function stakeFor(address staker, uint256 amount)
    external
    override
    returns (bool) {
        return _stake(msg.sender, staker, amount);
    }

    function stakeForMultiple(address[] calldata stakers, uint256[] calldata amounts)
    external
    override
    returns (bool) {
        for (uint256 i = 0; i < stakers.length; i++)
            _stake(msg.sender, stakers[i], amounts[i]);
        return true;
    }

    /**
    * Requirements:
    * - `amount` Amount to be staked
    */
    function stake(uint256 amount)
    external
    override
    returns (bool) {
        address from = msg.sender;
        return _stake(from, from, amount);
    }

    function _stake(address payer, address staker, uint256 amount) internal virtual returns (bool) {
        return OnChainStakingLib.stake(payer, staker, amount,
            stakingStarts, stakingEnds, stakingCap, tokenAddress,
            stakeState);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.1;

import "../common/SafeAmount.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library OnChainStakingLib {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Staked(address indexed token, address indexed staker_, uint256 requestedAmount_, uint256 stakedAmount_);

    event PaidOut(address indexed token, address indexed rewardToken, address indexed staker_, uint256 amount_, uint256 reward_);

    struct OnChainStakingState {
        uint256 stakedTotal;
        uint256 stakingCap;
        uint256 stakedBalance;
        mapping(address => uint256) _stakes;
    }

    struct OnChainStakingRewardState {
        uint256 rewardsTotal;
        uint256 rewardBalance;
        uint256 earlyWithdrawReward;
    }

    function VERSION() external pure returns (uint) {
        return 1001;
    }

    function tryStake(address payer, address staker, uint256 amount,
        uint256 stakingStarts,
        uint256 stakingEnds,
        uint256 stakingCap,
        address tokenAddress,
        OnChainStakingState storage state
    )
    public
    _after(stakingStarts)
    _before(stakingEnds)
    _positive(amount)
    returns (uint256) {
        // check the remaining amount to be staked
        // For pay per transfer tokens we limit the cap on incoming tokens for simplicity. This might
        // mean that cap may not necessary fill completely which is ok.
        uint256 remaining = amount;
        {
            uint256 stakedBalance = state.stakedBalance;
            if (stakingCap > 0 && remaining > (stakingCap.sub(stakedBalance))) {
                remaining = stakingCap.sub(stakedBalance);
            }
        }
        // These requires are not necessary, because it will never happen, but won't hurt to double check
        // this is because stakedTotal and stakedBalance are only modified in this method during the staking period
        // require((remaining + stakedTotal) <= stakingCap, "OnChainStaking: this will increase staking amount pass the cap");
        // Update remaining in case actual amount paid was different.
        remaining = _payMe(payer, remaining, tokenAddress);
        emit Staked(tokenAddress, staker, amount, remaining);

        // Transfer is completed
        return remaining;
    }

    function stake(address payer, address staker, uint256 amount,
        uint256 stakingStarts,
        uint256 stakingEnds,
        uint256 stakingCap,
        address tokenAddress,
        OnChainStakingState storage state
    )
    external
    returns (bool) {
        uint256 remaining = tryStake(payer, staker, amount,
            stakingStarts, stakingEnds, stakingCap, tokenAddress, state);

        // Transfer is completed
        state.stakedBalance = state.stakedBalance.add(remaining);
        state.stakedTotal = state.stakedTotal.add(remaining);
        state._stakes[staker] = state._stakes[staker].add(remaining);
        return true;
    }

    function addReward(
        uint256 rewardAmount,
        uint256 withdrawableAmount,
        address rewardTokenAddress,
        OnChainStakingRewardState storage state
    )
    external
    returns (bool) {
        require(rewardAmount > 0, "OnChainStaking: reward must be positive");
        require(withdrawableAmount >= 0, "OnChainStaking: withdrawable amount cannot be negative");
        require(withdrawableAmount <= rewardAmount, "OnChainStaking: withdrawable amount must be less than or equal to the reward amount");
        address from = msg.sender;
        rewardAmount = _payMe(from, rewardAmount, rewardTokenAddress);
        state.rewardsTotal = state.rewardsTotal.add(rewardAmount);
        state.rewardBalance = state.rewardBalance.add(rewardAmount);
        state.earlyWithdrawReward = state.earlyWithdrawReward.add(withdrawableAmount);
        return true;
    }

    function addMarginalReward(
        address rewardTokenAddress,
        address tokenAddress,
        address me,
        uint256 stakedBalance,
        OnChainStakingRewardState storage state)
    external
    returns (bool) {
        uint256 amount = IERC20(rewardTokenAddress).balanceOf(me).sub(state.rewardsTotal);
        if (rewardTokenAddress == tokenAddress) {
            amount = amount.sub(stakedBalance);
        }
        if (amount == 0) {
            return true;
            // No reward to add. Its ok. No need to fail callers.
        }
        state.rewardsTotal = state.rewardsTotal.add(amount);
        state.rewardBalance = state.rewardBalance.add(amount);
        return true;
    }

    function tryWithdraw(
        address from,
        address tokenAddress,
        address rewardTokenAddress,
        uint256 amount,
        uint256 withdrawStarts,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        OnChainStakingState storage state,
        OnChainStakingRewardState storage rewardState
    )
    public
    _after(withdrawStarts)
    _positive(amount)
    _realAddress(msg.sender)
    returns (uint256) {
        require(amount <= state._stakes[from], "OnChainStaking: not enough balance");
        if (block.timestamp < withdrawEnds) {
            return _withdrawEarly(tokenAddress, rewardTokenAddress, from, amount, withdrawEnds,
                stakingEnds, state, rewardState);
        } else {
            return _withdrawAfterClose(tokenAddress, rewardTokenAddress, from, amount, state, rewardState);
        }
    }

    function withdraw(
        address from,
        address tokenAddress,
        address rewardTokenAddress,
        uint256 amount,
        uint256 withdrawStarts,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        OnChainStakingState storage state,
        OnChainStakingRewardState storage rewardState
    )
    public
    returns (bool) {
        uint256 wdAmount = tryWithdraw(from, tokenAddress, rewardTokenAddress, amount, withdrawStarts,
            withdrawEnds, stakingEnds, state, rewardState);
        state.stakedBalance = state.stakedBalance.sub(wdAmount);
        state._stakes[from] = state._stakes[from].sub(wdAmount);
        return true;
    }

    function _withdrawEarly(
        address tokenAddress,
        address rewardTokenAddress,
        address from,
        uint256 amount,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        OnChainStakingState storage state,
        OnChainStakingRewardState storage rewardState
    )
    private
    _realAddress(from)
    returns (uint256) {
        // This is the formula to calculate reward:
        // r = (earlyWithdrawReward / stakedTotal) * (block.timestamp - stakingEnds) / (withdrawEnds - stakingEnds)
        // w = (1+r) * a
        uint256 denom = (withdrawEnds.sub(stakingEnds)).mul(state.stakedTotal);
        uint256 reward = (
        ((block.timestamp.sub(stakingEnds)).mul(rewardState.earlyWithdrawReward)).mul(amount)
        ).div(denom);
        rewardState.rewardBalance = rewardState.rewardBalance.sub(reward);
        bool principalPaid = _payDirect(from, amount, tokenAddress);
        bool rewardPaid = _payDirect(from, reward, rewardTokenAddress);
        require(principalPaid && rewardPaid, "OnChainStaking: error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, reward);
        return amount;
    }

    function _withdrawAfterClose(
        address tokenAddress,
        address rewardTokenAddress,
        address from,
        uint256 amount,
        OnChainStakingState storage state,
        OnChainStakingRewardState storage rewardState
    ) private
    _realAddress(from)
    returns (uint256) {
        uint256 rewBal = rewardState.rewardBalance;
        uint256 reward = (rewBal.mul(amount)).div(state.stakedBalance);
        rewardState.rewardBalance = rewBal.sub(reward);
        bool principalPaid = _payDirect(from, amount, tokenAddress);
        bool rewardPaid = _payDirect(from, reward, rewardTokenAddress);
        require(principalPaid && rewardPaid, "OnChainStaking: error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, reward);
        return amount;
    }

    function _payMe(address payer, uint256 amount, address token)
    internal
    returns (uint256) {
        return _payTo(payer, address(this), amount, token);
    }

    function _payTo(address allower, address receiver, uint256 amount, address token)
    internal
    returns (uint256) {
        // Request to transfer amount from the contract to receiver.
        // contract does not own the funds, so the allower must have added allowance to the contract
        // Allower is the original owner.
        return SafeAmount.safeTransferFrom(token, allower, receiver, amount);
    }

    function _payDirect(address to, uint256 amount, address token)
    private
    returns (bool) {
        if (amount == 0) {
            return true;
        }
        IERC20(token).safeTransfer(to, amount);
        return true;
    }

    modifier _realAddress(address addr) {
        require(addr != address(0), "OnChainStaking: zero address");
        _;
    }

    modifier _positive(uint256 amount) {
        require(amount != 0, "OnChainStaking: negative amount");
        _;
    }

    modifier _after(uint eventTime) {
        require(block.timestamp >= eventTime, "OnChainStaking: bad timing for the request");
        _;
    }

    modifier _before(uint eventTime) {
        require(block.timestamp < eventTime, "OnChainStaking: bad timing for the request");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

pragma solidity >=0.8.1;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library SafeAmount {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount) internal returns (uint256)  {
        uint256 preBalance = IERC20(token).balanceOf(to);
        IERC20(token).transferFrom(from, to, amount);
        uint256 postBalance = IERC20(token).balanceOf(to);
        return postBalance.sub(preBalance);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address sender,
        address recipient,
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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