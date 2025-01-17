// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MinerProtocol is Pausable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address[] private _downlines;
    address public immutable BUSD;

    mapping(address => UserInfo) public userInfo;
    mapping(address => ReferrerInfo) public referrers;
    mapping(address => UserReferralInfo[]) public userReferrals;
    mapping(address => uint256) public referralsCount;
    mapping(address => uint256) public totalReferralCommissions;
    LeadershipInfo[] public leadershipPositionsReward;

    bool public emergencyWidthdrawal = false;

    uint256 public contractInitializedAt;
    uint256 public totalInvestments;
    uint256 public totalParticipants;
    uint256 public totalPayouts;
    uint256 public totalTeams = 0;

    address public constant ADMIN_ADDRESS =
        0xA6B8f18B75C85C0e01282525fff04d820495de83;
    uint256 public constant ADMIN_FEE = 5000000000000000000; // 5 dollar
    uint256 public constant DAILY_RETURNS_IN_BPS = 300;
    uint256 public constant WITHDRAWAL_FEE_IN_BPS = 500;
    uint256 public constant MIN_COMPOUNDING_AMOUNT = 10000000000000000000;
    uint256 public constant MIN_INVESTMENT = 50000000000000000000;
    uint256 public constant STAKING_DURATION = 30 days;
    uint256 public constant REFERRAL_COMMISSION_IN_BPS = 1000;

    struct LeadershipInfo {
        uint256 sales;
        uint256 reward;
    }

    struct ReferrerInfo {
        address referrer;
        bool initialReward;
        uint256 totalEarnings;
    }

    struct UserReferralInfo {
        address user;
        int256 debt;
    }

    struct UserInfo {
        uint256 currentLeadershipPosition; // leadership position 1 - 7
        uint256 totalInvestments;
        uint256 lastWithdrawn;
        uint256 amount;
        uint256 debt;
        uint256 referralDebt;
        uint256 initialTime;
        uint256 totalWithdrawal;
        uint256 withdrawnAt;
        uint256 reinvestmentDeadline;
        uint256 lockEndTime;
        uint256 leadershipScore;
        uint256 totalTeam;
    }

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );
    event ReferralCommissionRecorded(
        address indexed referrer,
        uint256 commission
    );

    constructor(address _busd) {
        BUSD = _busd;
        contractInitializedAt = block.timestamp;
        leadershipPositionsReward.push(
            LeadershipInfo(20000000000000000000000, 200000000000000000000)
        );
        leadershipPositionsReward.push(
            LeadershipInfo(50000000000000000000000, 1000000000000000000000)
        );
        leadershipPositionsReward.push(
            LeadershipInfo(120000000000000000000000, 2500000000000000000000)
        );
        leadershipPositionsReward.push(
            LeadershipInfo(250000000000000000000000, 5000000000000000000000)
        );
        leadershipPositionsReward.push(
            LeadershipInfo(500000000000000000000000, 10000000000000000000000)
        );
        leadershipPositionsReward.push(
            LeadershipInfo(750000000000000000000000, 15000000000000000000000)
        );
        leadershipPositionsReward.push(
            LeadershipInfo(1000000000000000000000000, 20000000000000000000000)
        );
    }

    function clearPreviousStaking(address _account) internal {
        UserInfo memory user = userInfo[_account];
        uint256 _debtAmount = user.debt;
        user.withdrawnAt = 0;
        user.lastWithdrawn = 0;
        user.initialTime = block.timestamp;
        user.lockEndTime = user.initialTime + STAKING_DURATION;
        user.debt = 0;
        user.referralDebt = 0;
        userInfo[_account] = user;

        if (_debtAmount > 0) {
            totalPayouts = totalPayouts.add(_debtAmount);
            IERC20(BUSD).transfer(_account, _debtAmount);
        }
    }

    function getUserDetails(address _account)
        external
        view
        returns (UserInfo memory, uint256)
    {
        uint256 reward = getRewards(_account);
        UserInfo memory user = userInfo[_account];
        return (user, reward);
    }

    function getUserReferrals(address _user)
        public
        view
        returns (UserReferralInfo[] memory)
    {
        return userReferrals[_user];
    }

    function getRewards(address _account) public view returns (uint256) {
        uint256 pendingReward = 0;
        UserInfo memory user = userInfo[_account];
        if (user.lastWithdrawn > 0) {
            if (user.reinvestmentDeadline < block.timestamp) {
                return 0;
            } else {
                return user.debt;
            }
        }
        if (user.amount > 0) {
            uint256 stakeAmount = user.amount;
            uint256 timeDiff;
            unchecked {
                timeDiff = block.timestamp - user.initialTime;
            }
            if (timeDiff >= STAKING_DURATION) {
                uint256 STAKING_DURATIONInNum = 30;
                return
                    stakeAmount.mul(DAILY_RETURNS_IN_BPS).div(10000).mul(
                        STAKING_DURATIONInNum
                    );
            }
            uint256 returnsIn30days = DAILY_RETURNS_IN_BPS * 30;
            uint256 rewardAmount = (((stakeAmount * returnsIn30days) / 10000) *
                timeDiff) / STAKING_DURATION;
            pendingReward = rewardAmount;
        }

        uint256 pending = user.debt.add(pendingReward);
        return pending;
    }

    function getReferralRewards(address _account)
        public
        view
        returns (uint256)
    {
        int256 pendingReward = 0;
        for (uint256 i = 0; i < userReferrals[_account].length; i++) {
            pendingReward = pendingReward + userReferrals[_account][i].debt;
            uint256 userRewards = getRewards(userReferrals[_account][i].user);
            uint256 rewardsPercentage = 15;
            pendingReward =
                pendingReward +
                (int256(userRewards.mul(rewardsPercentage).div(100)));
        }

        return uint256(pendingReward);
    }

    function addReferralDebt(address _account) internal {
        ReferrerInfo memory _referrer = getReferrer(_account);
        if (_referrer.referrer != address(0)) {
            uint256 userReward = getRewards(_account);
            UserReferralInfo memory referredUser;
            uint256 index;

            for (
                uint256 i = 0;
                i < userReferrals[_referrer.referrer].length;
                i++
            ) {
                if (userReferrals[_referrer.referrer][i].user == _account) {
                    index = i;
                    referredUser = userReferrals[_referrer.referrer][i];
                    break;
                }
            }

            if (referredUser.user != address(0)) {
                uint256 rewardsPercentage = 15;
                referredUser.debt =
                    referredUser.debt +
                    int256(userReward.mul(rewardsPercentage).div(100));
                userReferrals[_referrer.referrer][index] = referredUser;
            }
        }
    }

    function invest(uint256 _amount) external whenNotPaused nonReentrant {
        require(ADMIN_FEE < _amount, "Incorrect request!");
        require(msg.sender.code.length == 0, "Contracts not allowed.");

        UserInfo memory user = userInfo[msg.sender];
        uint256 investment = _amount - ADMIN_FEE;

        if (user.totalInvestments > 0) {
            if (user.lastWithdrawn > 0) {
                if (user.reinvestmentDeadline < block.timestamp) {
                    user.debt = 0;
                } else {
                    uint256 reinvestmentPercent = 50;
                    uint256 _minimumInvestment = user
                        .lastWithdrawn
                        .mul(reinvestmentPercent)
                        .div(100);
                    require(
                        investment >= _minimumInvestment,
                        "Invest at least 50% of your previous earning"
                    );
                }
                addReferralDebt(msg.sender);
                clearPreviousStaking(msg.sender);
            } else {
                if (user.debt > 0 || user.amount > 0) {
                    require(
                        investment >= MIN_COMPOUNDING_AMOUNT,
                        "Minimum compounding is 10 busd"
                    );
                } else {
                    require(
                        investment >= MIN_INVESTMENT,
                        "Minimum investment is 50 busd"
                    );
                }
            }
        } else {
            require(
                investment >= MIN_INVESTMENT,
                "Minimum investment is 50 busd"
            );
        }

        IERC20(BUSD).transferFrom(msg.sender, address(this), _amount);
        IERC20(BUSD).transfer(ADMIN_ADDRESS, ADMIN_FEE);

        if (user.totalInvestments < 1) {
            totalParticipants = totalParticipants.add(1);
            user.initialTime = block.timestamp;
            user.lockEndTime = user.initialTime + STAKING_DURATION;
        }

        user.totalInvestments = user.totalInvestments.add(investment);
        user.amount = user.amount.add(investment);
        totalInvestments = totalInvestments.add(investment);

        userInfo[msg.sender] = user;

        payReferrerCommission(msg.sender, investment);
    }

    function clearReferralDebt(address _account) internal {
        for (uint256 i = 0; i < userReferrals[_account].length; i++) {
            UserReferralInfo memory usr = userReferrals[_account][i];
            uint256 userRewards = getRewards(usr.user);
            uint256 rewardsPercentage = 15;
            usr.debt = 0 - int256(userRewards.mul(rewardsPercentage).div(100));
            userReferrals[_account][i] = usr;
        }
    }

    function withdraw() external nonReentrant {
        require(msg.sender.code.length == 0, "Contracts not allowed.");
        if (emergencyWidthdrawal) {
            UserInfo memory user = userInfo[msg.sender];
            uint256 _withdrawalAmount = user.amount;
            user.amount = 0;
            user.debt = 0;
            user.referralDebt = 0;
            user.lastWithdrawn = 0;
            user.lastWithdrawn = _withdrawalAmount;
            user.totalWithdrawal = user.totalWithdrawal.add(_withdrawalAmount);
            user.withdrawnAt = block.timestamp;

            userInfo[msg.sender] = user;
            if (_withdrawalAmount > 0) {
                IERC20(BUSD).transfer(msg.sender, _withdrawalAmount);
            }
        } else {
            UserInfo memory user = userInfo[msg.sender];
            uint256 totalBalance = getRewards(msg.sender) +
                getReferralRewards(msg.sender) +
                user.amount +
                user.referralDebt;

            require(totalBalance > 0, "withdraw: insufficient amount");
            uint256 _withdrawalAmount = totalBalance;

            if (user.lockEndTime > block.timestamp) {
                user.amount = 0;
                user.debt = 0;
                user.referralDebt = 0;
                _withdrawalAmount = _withdrawalAmount.div(2);
                totalPayouts = totalPayouts.add(_withdrawalAmount);
                user.lastWithdrawn = 0;
            } else {
                _withdrawalAmount = _withdrawalAmount.mul(70).div(100);
                totalPayouts = totalPayouts.add(_withdrawalAmount);
                user.debt = totalBalance.sub(_withdrawalAmount);
                user.referralDebt = 0;
                user.amount = 0;
                user.lastWithdrawn = _withdrawalAmount;
                user.reinvestmentDeadline = block.timestamp + 1 days;
            }

            user.totalWithdrawal = user.totalWithdrawal.add(_withdrawalAmount);
            user.withdrawnAt = block.timestamp;

            userInfo[msg.sender] = user;
            addReferralDebt(msg.sender);
            clearReferralDebt(msg.sender);

            uint256 withdrawalFee = _withdrawalAmount
                .mul(WITHDRAWAL_FEE_IN_BPS)
                .div(10000);
            IERC20(BUSD).transfer(ADMIN_ADDRESS, withdrawalFee);

            IERC20(BUSD).transfer(
                msg.sender,
                _withdrawalAmount.sub(withdrawalFee)
            );
        }
    }

    function userUplines(address _user) internal returns (address[] memory) {
        ReferrerInfo memory referrer = getReferrer(_user);
        if (referrer.referrer != address(0)) {
            _downlines.push(referrer.referrer);

            for (uint256 i = 0; i < totalTeams; i++) {
                address ref = _downlines[_downlines.length - 1];
                ReferrerInfo memory refUpline = getReferrer(ref);
                if (refUpline.referrer != address(0)) {
                    _downlines.push(refUpline.referrer);
                }
            }
        }

        address[] memory downlineArr = _downlines;
        delete _downlines;
        return downlineArr;
    }

    function harvest() external whenNotPaused nonReentrant {
        require(msg.sender.code.length == 0, "Contracts not allowed.");
        UserInfo memory user = userInfo[msg.sender];
        require(
            user.totalInvestments > 0,
            "You need to be active by investing before harvesting."
        );
        uint256 refReward = getReferralRewards(msg.sender);
        uint256 rewardAmount = getRewards(msg.sender) +
            refReward +
            user.referralDebt;
        require(rewardAmount >= 0, "harvest: not enough funds");

        if (refReward > 0) {
            clearReferralDebt(msg.sender);
        }
        addReferralDebt(msg.sender);

        user.debt = 0;
        user.referralDebt = 0;
        user.initialTime = block.timestamp;
        user.lockEndTime = user.initialTime + STAKING_DURATION;
        user.totalWithdrawal = user.totalWithdrawal.add(rewardAmount);
        user.withdrawnAt = block.timestamp;
        userInfo[msg.sender] = user;

        totalPayouts = totalPayouts.add(rewardAmount);

        uint256 withdrawalFee = rewardAmount.mul(WITHDRAWAL_FEE_IN_BPS).div(
            10000
        );
        IERC20(BUSD).transfer(ADMIN_ADDRESS, withdrawalFee);

        IERC20(BUSD).transfer(msg.sender, rewardAmount.sub(withdrawalFee));
    }

    function updateUplines(address _user) internal {
        address[] memory userUps = userUplines(_user);

        for (uint256 i = 0; i < userUps.length; i++) {
            address ref = userUps[i];
            UserInfo memory user = userInfo[ref];
            user.totalTeam = user.totalTeam.add(1);
            userInfo[ref] = user;
        }
    }

    function recordReferral(address _user, address _referrer) public {
        require(msg.sender.code.length == 0, "Contracts not allowed.");
        if (
            _user != address(0) &&
            _referrer != address(0) &&
            _user != _referrer &&
            referrers[_user].referrer == address(0)
        ) {
            ReferrerInfo memory referrerReferrer = getReferrer(_referrer);
            if (referrerReferrer.referrer != _user) {
                referrers[_user].referrer = _referrer;
                referralsCount[_referrer] += 1;
                userReferrals[_referrer].push(UserReferralInfo(_user, 0));
                totalTeams = totalTeams.add(1);
                updateUplines(_user);
                emit ReferralRecorded(_user, _referrer);
            }
        }
    }

    function getReferrer(address _user)
        public
        view
        returns (ReferrerInfo memory)
    {
        return referrers[_user];
    }

    function calcReferralReward(uint256 _amount)
        private
        pure
        returns (uint256)
    {
        return _amount.mul(REFERRAL_COMMISSION_IN_BPS).div(10000);
    }

    function payReferrerCommission(address _user, uint256 _transactionAmount)
        internal
    {
        ReferrerInfo memory referrerInfo = getReferrer(_user);
        if (referrerInfo.referrer != address(0)) {
            address[] memory userUps = userUplines(_user);

            for (uint256 i = 0; i < userUps.length; i++) {
                UserInfo memory referrerUserInfo = userInfo[userUps[i]];
                referrerUserInfo.leadershipScore = referrerUserInfo
                    .leadershipScore
                    .add(_transactionAmount);
                uint256 currentPosition = referrerUserInfo
                    .currentLeadershipPosition;
                uint256 points = 0;
                for (
                    uint256 index = currentPosition;
                    index < leadershipPositionsReward.length;
                    index++
                ) {
                    LeadershipInfo memory pos = leadershipPositionsReward[
                        index
                    ];
                    if (referrerUserInfo.leadershipScore < pos.sales) {
                        break;
                    }
                    points = points.add(pos.reward);
                    currentPosition = currentPosition.add(1);
                }
                referrerUserInfo.currentLeadershipPosition = currentPosition;
                referrerUserInfo.referralDebt = referrerUserInfo
                    .referralDebt
                    .add(points);
                userInfo[userUps[i]] = referrerUserInfo;
            }
        }
        if (
            referrerInfo.referrer != address(0) &&
            referrerInfo.initialReward == false
        ) {
            uint256 commision = calcReferralReward(_transactionAmount);
            if (commision > 0) {
                totalReferralCommissions[referrerInfo.referrer] += commision;
                referrerInfo.initialReward = true;
                referrers[_user] = referrerInfo;

                UserInfo memory referrerUserInfo = userInfo[
                    referrerInfo.referrer
                ];
                referrerUserInfo.referralDebt = referrerUserInfo
                    .referralDebt
                    .add(commision);
                userInfo[referrerInfo.referrer] = referrerUserInfo;

                emit ReferralCommissionRecorded(
                    referrerInfo.referrer,
                    commision
                );
                emit ReferralCommissionPaid(
                    _user,
                    referrerInfo.referrer,
                    commision
                );
            }
        }
    }

    function enableEmergencyWithdrawal(bool _enable) public onlyOwner {
        emergencyWidthdrawal = _enable;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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