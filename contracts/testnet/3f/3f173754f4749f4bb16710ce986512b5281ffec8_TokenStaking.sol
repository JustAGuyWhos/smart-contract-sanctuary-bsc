/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/TokenStaking.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


error Staking_TransferFailed();
error Staking__NeedsMoreThanZero();

contract TokenStaking {
	IERC20 public s_stakingToken;
	IERC20 public s_rewardToken;

	uint256 public constant REWARD_RATE = 100;
	uint public s_rewardPerTokenStored;
	uint public s_lastUpdateTime;

	//someone's address -> how much they have been paid
	mapping(address => uint256) public s_userRewardPerTokenPaid;

	//someone's address -> how much rewards it has
	mapping(address => uint256) public s_rewards;

	uint256 public s_totalSupply;

	//someone's address -> how much they staked
	mapping(address => uint256) public s_balances;

	modifier updateReward(address account) {
		// Important: rewards per token, last timestamps
		s_rewardPerTokenStored = rewardPerToken();
		s_lastUpdateTime = block.timestamp;
		s_rewards[account] = earned(account);
		s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
		_;
	}

	modifier moreThanZero(uint256 amount) {
		if (amount == 0) {
			revert Staking__NeedsMoreThanZero();
		}
		_;
	}

	constructor(address stakingToken, address rewardToken) {
		s_stakingToken = IERC20(stakingToken);
		s_rewardToken = IERC20(rewardToken);
	}

	function earned(address account) public view returns (uint256) {
		uint256 currentBalance = s_balances[account];

		// amount thay've been paid already
		uint256 amountPaid = s_userRewardPerTokenPaid[account];
		uint256 currentRewardPerToken = rewardPerToken();
		uint256 pastRewards = s_rewards[account];
		uint256 _earned = ((currentBalance * (currentRewardPerToken - amountPaid)) /
			1e18) + pastRewards;
		return _earned;
	}

	function rewardPerToken() public view returns (uint256) {
		if (s_totalSupply == 0) {
			return s_rewardPerTokenStored;
		}
		return
			s_rewardPerTokenStored +
			(((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) /
				s_totalSupply);
	}

	function stake(
		uint amount
	) external updateReward(msg.sender) moreThanZero(amount) {
		s_balances[msg.sender] += amount;
		s_totalSupply += amount;
		bool success = s_stakingToken.transferFrom(
			msg.sender,
			address(this),
			amount
		);

		if (!success) {
			revert Staking_TransferFailed();
		}
	}

	function withdraw(
		uint256 amount
	) external updateReward(msg.sender) moreThanZero(amount) {
		s_balances[msg.sender] -= amount;
		s_totalSupply -= amount;
		bool success = s_stakingToken.transfer(msg.sender, amount);
		if (!success) {
			revert Staking_TransferFailed();
		}
	}

	function claimReward() external updateReward(msg.sender) {
		uint256 reward = s_rewards[msg.sender];
		bool success = s_rewardToken.transfer(msg.sender, reward);
		if (!success) {
			revert Staking_TransferFailed();
		}
	}
}