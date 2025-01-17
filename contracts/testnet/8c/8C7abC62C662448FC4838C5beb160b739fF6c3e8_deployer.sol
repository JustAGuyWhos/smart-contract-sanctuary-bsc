//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./launchpad.sol";

contract deployer is Ownable {
    using SafeMath for uint256;

    struct pools {
        address _owner;
        uint256 _createdTime;
    }

    mapping(address => pools) public launchpads;

    uint256 public feeAmount = 1 * 10**17;

    uint256 public tokenFeePercentage = 200;
    uint256 public bnbFeePercentage = 100;
    uint256 public insuranceFund = 25;

    address public tokenLocker = 0xdbaf0b3eEeC1Fefe3FAb9c6520d7a8ac17a9aafE;

    event nePoolCreated(address _poolAddress, address _owner);

    constructor() {}

    receive() external payable {}

    function createNewPool(
        address _tokenAddress,
        uint256[11] memory _poolDetails,
        uint256[] memory vestingDetails,
        address _router,
        bool isWhitelisted,
        uint256 publicStartTime
    ) public payable returns (address) {
        require(
            msg.value >= feeAmount,
            "Please submit the asking price in order to complete the pool creating"
        );
        payable(address(this)).transfer(feeAmount);

        uint256 requireTokensToPreSale = _poolDetails[3]
            .mul(_poolDetails[2])
            .div(10**18);

        uint256 poolFeeAmount = requireTokensToPreSale
            .mul(tokenFeePercentage)
            .div(10000);

        uint256 tokensToLp = _poolDetails[9]
            .mul((_poolDetails[2].mul(_poolDetails[7]).div(100)))
            .div(10**18);

        uint256 totelRequireTokens = requireTokensToPreSale
            .add(poolFeeAmount)
            .add(tokensToLp);

        uint256[3] memory _fees = [
            bnbFeePercentage,
            tokenFeePercentage,
            insuranceFund
        ];

        // require(
        //     IERC20(_tokenAddress).balanceOf(msg.sender) >= totelRequireTokens,
        //     "You don't have enough tokens to create the pre sale"
        // );
        // deploy new pool
        Launchpad newPool;

        newPool = new Launchpad(
            _tokenAddress,
            msg.sender,
            _poolDetails,
            vestingDetails,
            isWhitelisted,
            publicStartTime,
            _router,
            _fees,
            tokenLocker
        );

        IERC20(_tokenAddress).transferFrom(
            address(msg.sender),
            address(newPool),
            totelRequireTokens
        );

        newPool.transferOwnership(owner());

        launchpads[address(newPool)]._owner = msg.sender;
        launchpads[address(newPool)]._createdTime = block.timestamp;

        emit nePoolCreated(address(newPool), msg.sender);

        return address(newPool);
    }

    function withdrawBnb() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB);
    }

    function withdrawBep20Tokens(address _token, uint256 percentage)
        public
        onlyOwner
    {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        require(tokenBalance > 0, "No enough tokens in the pool");

        uint256 tokensToTransfer = tokenBalance.mul(percentage).div(100);

        IERC20(_token).transfer(msg.sender, tokensToTransfer);
    }

    function changeFeeAmount(uint256 _feeAmount) public onlyOwner {
        feeAmount = _feeAmount;
    }

    function changeFeePercentages(
        uint256 _tokenFee,
        uint256 _bnbFee,
        uint256 _insuranceFund
    ) public onlyOwner {
        tokenFeePercentage = _tokenFee;
        bnbFeePercentage = _bnbFee;
        insuranceFund = _insuranceFund;
    }

    function changeLockerAddress(address _locker) external onlyOwner {
        tokenLocker = _locker;
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./Interfaces/ITokenLocker.sol";

contract Launchpad is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct Share {
        uint256 bnbAmount;
        uint256 tokensAmount;
        uint256 enrolledAt;
        bool isClaimed;
        uint256 lastClaim;
        uint256 lastClaimTime;
        uint256 nextClaimTime;
        uint256 totalClaim;
        uint256 remainingClaim;
    }

    struct RewardShare {
        uint256 shareAmount;
        uint256 totalClaimed;
        uint256 lastClaimedTime;
        uint256 lastClaimedAmount;
    }

    IERC20 public tokenAddress;

    ITokenLocker public tokenLocker;

    IUniswapV2Router02 public router;
    address public pair;

    mapping(address => bool) public isRouterWhitelisted;

    //reward details
    IERC20 public rewardToken;
    uint256 public totalClaimedRewards;
    uint256 public rewardPerShare;
    uint256 public totalRewardShares;
    bool public isRewardTokenSet;

    bool public createdWithToken = true;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public poolCreatedAt;
    uint256 public hardCap;
    uint256 public softCap;
    uint256 public minimumParticipate;
    uint256 public maximumParticipate;
    uint256 public tokensPerbnb;
    uint256 public totalTokenAmount;
    uint256 public remainingTokens;
    uint256 public filledBNB;
    uint256 public remainingBNB;

    bool public isSoftCapFilled;
    bool public isVesting;

    uint256 public investorCount;

    uint256 public initialRelease;
    uint256 public releaseCycle;
    uint256 public releasePercentage;

    uint256 public finalizedAt;

    address public poolOwner;

    uint256 public lpPercentage;
    uint256 public lpLockTime;
    uint256 public launchRate;

    // whitelist Details
    bool public isWhitelisted;
    uint256 public goPublicTime;

    mapping(address => bool) public isWhiteListed;

    address[] public whitelistedUsers;

    address[] public investors;

    uint256 public insuranceFundPercentage;
    uint256 public insuranceFundAmount;

    mapping(address => Share) public shares;
    mapping(address => RewardShare) public rewards;

    /*
    pool status

    0 pending
    1 live
    2 sales ended
    3 canceled
    4 finalized
    **/

    uint256 public poolStatus;

    uint256 public tokenFee;
    uint256 public bnbFee;

    event newParticipate(
        address investor,
        uint256 bnbAmount,
        uint256 tokenAmount
    );

    event tokensClaim(address investor, uint256 tokensAmount);
    event leavePool(address investor, uint256 bnbAmount);

    // reward related events

    event rewardClaimed(address investor, uint256 amount);

    receive() external payable {}

    constructor(
        address _tokenAddress,
        address _owner,
        uint256[11] memory _poolDetails,
        uint256[] memory vestingDetails,
        bool _isWhitelisted,
        uint256 _goPublic,
        address _router,
        uint256[3] memory _fees,
        address locker
    ) {
        tokenAddress = IERC20(_tokenAddress);
        startTime = _poolDetails[0];
        endTime = _poolDetails[1];
        hardCap = _poolDetails[2];
        tokensPerbnb = _poolDetails[3];
        totalTokenAmount = _poolDetails[4];
        minimumParticipate = _poolDetails[5];
        maximumParticipate = _poolDetails[6];
        softCap = _poolDetails[10];
        //lp
        lpPercentage = _poolDetails[7];
        lpLockTime = _poolDetails[8];
        launchRate = _poolDetails[9];

        router = IUniswapV2Router02(_router);

        tokenLocker = ITokenLocker(locker);

        remainingTokens = totalTokenAmount;

        bnbFee = _fees[0];
        tokenFee = _fees[1];

        poolOwner = _owner;

        insuranceFundPercentage = _fees[2];

        remainingBNB = hardCap;

        if (vestingDetails[0] > 0) {
            initialRelease = vestingDetails[0];
            releaseCycle = vestingDetails[1];
            releasePercentage = vestingDetails[2];

            isVesting = true;
        }

        // set whitelist
        isWhitelisted = _isWhitelisted;
        goPublicTime = _goPublic;

        poolStatus = 0;
        isSoftCapFilled = false;
        poolCreatedAt = block.timestamp;
    }

    function participateToSale() public payable nonReentrant {
        syncPool();

        require(poolStatus == 1, "Pool not in live");
        if (isWhitelisted) {
            require(
                goPublicTime <= block.timestamp || isWhiteListed[msg.sender],
                "You are not a whitelisted user"
            );
        }
        require(
            shares[msg.sender].bnbAmount.add(msg.value) <= maximumParticipate,
            "You Already reached maximum participate amount"
        );
        require(
            msg.value >= minimumParticipate &&
                msg.value <= maximumParticipate &&
                msg.value <= remainingBNB,
            "Your Amount is not in minimum and maximum range"
        );
        uint256 tokensToUser = tokensPerbnb.mul(msg.value).div(10**18);
        require(
            remainingTokens >= tokensToUser,
            "No enough tokens in the pool"
        );
        remainingTokens = remainingTokens.sub(tokensToUser);

        payable(address(this)).transfer(msg.value);
        filledBNB = filledBNB.add(msg.value);
        remainingBNB = hardCap.sub(filledBNB);

        shares[msg.sender].bnbAmount = shares[msg.sender].bnbAmount.add(
            msg.value
        );
        shares[msg.sender].tokensAmount = shares[msg.sender].tokensAmount.add(
            tokensToUser
        );
        shares[msg.sender].enrolledAt = block.timestamp;
        shares[msg.sender].isClaimed = false;

        rewards[msg.sender].shareAmount = rewards[msg.sender].shareAmount.add(
            tokensToUser
        );

        totalRewardShares = totalRewardShares.add(tokensToUser);

        investorCount = investorCount.add(1);

        investors.push(msg.sender);

        syncPool();

        emit newParticipate(msg.sender, msg.value, tokensToUser);
    }

    function claimBnb() public payable nonReentrant {
        syncPool();
        require(poolStatus == 3, "Pool not canceled");
        require(
            shares[msg.sender].bnbAmount > 0,
            "You do not have bnb in the pool"
        );
        payable(msg.sender).transfer(shares[msg.sender].bnbAmount);

        remainingTokens = remainingTokens.add(shares[msg.sender].tokensAmount);
        filledBNB = filledBNB.sub(shares[msg.sender].bnbAmount);
        remainingBNB = hardCap.sub(filledBNB);

        emit leavePool(msg.sender, shares[msg.sender].bnbAmount);

        shares[msg.sender].bnbAmount = 0;
        shares[msg.sender].tokensAmount = 0;
        shares[msg.sender].enrolledAt = 0;
        shares[msg.sender].isClaimed = false;

        rewards[msg.sender].shareAmount = 0;
        totalRewardShares = totalRewardShares.sub(
            shares[msg.sender].tokensAmount
        );

        investorCount = investorCount.sub(1);

        syncPool();
    }

    function sendBnb(address _investor) internal {
        if (shares[_investor].bnbAmount > 0) {
            remainingTokens = remainingTokens.add(
                shares[_investor].tokensAmount
            );
            filledBNB = filledBNB.sub(shares[_investor].bnbAmount);
            remainingBNB = hardCap.sub(filledBNB);

            emit leavePool(_investor, shares[_investor].bnbAmount);

            shares[_investor].bnbAmount = 0;
            shares[_investor].tokensAmount = 0;
            shares[_investor].enrolledAt = 0;
            shares[_investor].isClaimed = false;

            rewards[_investor].shareAmount = 0;
            totalRewardShares = totalRewardShares.sub(
                shares[_investor].tokensAmount
            );
            payable(_investor).transfer(shares[_investor].bnbAmount);
            investorCount = investorCount.sub(1);
        }
    }

    function claimTokens() public nonReentrant {
        require(poolStatus == 4, "Pool not finalized yet");
        require(
            shares[msg.sender].bnbAmount > 0,
            "You do not have bnb in the pool"
        );

        require(
            !shares[msg.sender].isClaimed,
            "You already Claimed your tokens"
        );
        if (isVesting) {
            uint256 firstRelease = shares[msg.sender]
                .tokensAmount
                .mul(initialRelease)
                .div(100);

            tokenAddress.transfer(msg.sender, firstRelease);

            uint256 claimTimeDifferent = block.timestamp.sub(finalizedAt);

            shares[msg.sender].nextClaimTime = block.timestamp.add(
                releaseCycle.sub(claimTimeDifferent)
            );

            shares[msg.sender].lastClaim = firstRelease;
            shares[msg.sender].lastClaimTime = block.timestamp;
            shares[msg.sender].totalClaim = firstRelease.add(
                shares[msg.sender].totalClaim
            );
            shares[msg.sender].remainingClaim = shares[msg.sender]
                .tokensAmount
                .sub(shares[msg.sender].totalClaim);

            shares[msg.sender].isClaimed = true;
            emit tokensClaim(msg.sender, firstRelease);
        } else {
            tokenAddress.transfer(msg.sender, shares[msg.sender].tokensAmount);

            shares[msg.sender].isClaimed = true;

            emit tokensClaim(msg.sender, shares[msg.sender].tokensAmount);
        }
    }

    function sendTokens(address _investor) internal {
        if (shares[_investor].bnbAmount > 0 && !shares[_investor].isClaimed) {
            if (isVesting) {
                uint256 firstRelease = shares[_investor]
                    .tokensAmount
                    .mul(initialRelease)
                    .div(100);

                tokenAddress.transfer(_investor, firstRelease);

                uint256 claimTimeDifferent = block.timestamp.sub(finalizedAt);

                shares[_investor].nextClaimTime = block.timestamp.add(
                    releaseCycle.sub(claimTimeDifferent)
                );

                shares[_investor].lastClaim = firstRelease;
                shares[_investor].lastClaimTime = block.timestamp;
                shares[_investor].totalClaim = firstRelease.add(
                    shares[_investor].totalClaim
                );
                shares[_investor].remainingClaim = shares[_investor]
                    .tokensAmount
                    .sub(shares[_investor].totalClaim);

                shares[_investor].isClaimed = true;
                emit tokensClaim(_investor, firstRelease);
            } else {
                tokenAddress.transfer(
                    _investor,
                    shares[_investor].tokensAmount
                );

                shares[_investor].isClaimed = true;

                emit tokensClaim(_investor, shares[_investor].tokensAmount);
            }
        }
    }

    function claimVesting() public nonReentrant {
        syncPool();

        require(poolStatus == 4, "Pool not finalized yet");
        require(
            shares[msg.sender].remainingClaim > 0,
            "You do not have tokens to claim in the pool"
        );

        require(
            shares[msg.sender].nextClaimTime <= block.timestamp,
            "You can not claim tokens at this time"
        );

        uint256 tokensToClaim = shares[msg.sender]
            .tokensAmount
            .mul(releasePercentage)
            .div(100);

        if (shares[msg.sender].remainingClaim > tokensToClaim) {
            tokenAddress.transfer(msg.sender, tokensToClaim);
            emit tokensClaim(msg.sender, tokensToClaim);
        } else {
            tokenAddress.transfer(
                msg.sender,
                shares[msg.sender].remainingClaim
            );
            emit tokensClaim(msg.sender, shares[msg.sender].remainingClaim);
        }
        uint256 claimTimeDifferent = block.timestamp.sub(
            shares[msg.sender].nextClaimTime
        );

        shares[msg.sender].lastClaim = tokensToClaim;
        shares[msg.sender].lastClaimTime = block.timestamp;
        shares[msg.sender].totalClaim = tokensToClaim.add(
            shares[msg.sender].totalClaim
        );
        shares[msg.sender].remainingClaim = shares[msg.sender].tokensAmount.sub(
            shares[msg.sender].totalClaim
        );

        shares[msg.sender].nextClaimTime = block.timestamp.add(
            releaseCycle.sub(claimTimeDifferent)
        );
    }

    function cancelPool() public onlyOwner {
        require(poolStatus != 4, "You can not cancel pool after finalize");

        poolStatus = 3;

        uint256 tokenBalance = tokenAddress.balanceOf(address(this));

        tokenAddress.transfer(poolOwner, tokenBalance);
    }

    function syncPool() public {
        if (poolStatus != 4 && poolStatus != 3) {
            if (poolStatus == 0 && startTime <= block.timestamp) poolStatus = 1;
            else if (filledBNB >= hardCap) poolStatus = 2;
            else if (endTime <= block.timestamp && softCap < filledBNB)
                poolStatus = 3;
            else if (endTime <= block.timestamp && softCap >= filledBNB)
                poolStatus = 3;
        }
    }

    function finalizePool() external nonReentrant {
        require(
            msg.sender == poolOwner,
            "Only pool owner can finalize the pool"
        );
        syncPool();

        require(poolStatus == 2, "You can not finalize the pool at this stage");

        uint256 poolFeeToken = totalTokenAmount.mul(tokenFee).div(10000);
        uint256 bnbForAddLp = filledBNB.mul(lpPercentage).div(100);

        uint256 tokensForLp = bnbForAddLp.mul(launchRate).div(10**18);

        addLiquidity(bnbForAddLp, tokensForLp, msg.sender);

        if (remainingTokens > 0) {
            // refund remaining tokens to owner
            tokenAddress.transfer(poolOwner, remainingTokens);
        }
        tokenAddress.transfer(address(owner()), poolFeeToken);

        // calculate bnb fee for launch pad

        uint256 bnbFeeForLaunchPad = filledBNB.mul(bnbFee).div(10000);

        uint256 bnbForOwner = filledBNB.sub(bnbFeeForLaunchPad).sub(
            bnbForAddLp
        );

        insuranceFundAmount = bnbForOwner.mul(insuranceFundPercentage).div(100);

        payable(address(owner())).transfer(bnbFeeForLaunchPad);

        payable(poolOwner).transfer(bnbForOwner.sub(insuranceFundAmount));

        finalizedAt = block.timestamp;

        poolStatus = 4;
    }

    function addLiquidity(
        uint256 bnbAmount,
        uint256 tokenAmount,
        address _lpOwner
    ) internal {
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        tokenAddress.approve(address(router), tokenAmount);

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        uint256 pirBalance = IUniswapV2Pair(pair).balanceOf(address(this));

        // lock piar tokens
        uint256 lockerId = tokenLocker.lockTokens(
            pair,
            pirBalance,
            lpLockTime,
            true
        );

        tokenLocker.transferLockerOwnerShip(lockerId, _lpOwner);
    }

    function syncRewards() public {
        uint256 currentRewardBalance = rewardToken.balanceOf(address(this));

        uint256 totalRewardForShares = rewardPerShare.mul(totalRewardShares);

        uint256 previousTokenBalance = totalRewardForShares.sub(
            totalClaimedRewards
        );

        uint256 newRewardBalance = currentRewardBalance.sub(
            previousTokenBalance
        );

        if (newRewardBalance > 0) {
            rewardPerShare = rewardPerShare.add(
                newRewardBalance.div(totalRewardShares)
            );
        }
    }

    function claimRewards() public nonReentrant {
        require(isRewardTokenSet, "A reward token not set to this pool");
        syncRewards();

        require(
            rewards[msg.sender].shareAmount > 0,
            "you can not claim rewards"
        );

        uint256 rewardsToSend = (
            rewardPerShare.mul(rewards[msg.sender].shareAmount)
        ).sub(rewards[msg.sender].totalClaimed);

        if (rewardsToSend > 0) {
            rewards[msg.sender].totalClaimed = rewardsToSend.add(
                rewards[msg.sender].totalClaimed
            );

            rewards[msg.sender].lastClaimedTime = block.timestamp;
            rewards[msg.sender].lastClaimedAmount = rewardsToSend;
            rewardToken.transfer(msg.sender, rewardsToSend);

            emit rewardClaimed(msg.sender, rewardsToSend);
        }
    }

    function setRewardToken(address _reward) public {
        require(
            msg.sender == poolOwner,
            "Only pool owner can finalize the pool"
        );

        isRewardTokenSet = true;

        rewardToken = IERC20(_reward);
    }

    function releaseInsuranceFund() public onlyOwner {
        payable(poolOwner).transfer(insuranceFundAmount);
    }

    function takeInsuranceFund() public onlyOwner {
        payable(msg.sender).transfer(insuranceFundAmount);
    }

    function withdrawBnb() public onlyOwner {
        require(address(this).balance > 0, "No enough bnb in the pool");

        payable(msg.sender).transfer(address(this).balance);
    }

    function whiteListUsers(address[] memory _wallets) public {
        require(msg.sender == poolOwner, "Only pool owner can whitelist users");

        require(
            _wallets.length <= 15,
            "you can white list maximum 15 wallets at a time"
        );

        for (uint256 i = 0; i < _wallets.length; i++) {
            isWhiteListed[_wallets[i]] = true;

            whitelistedUsers.push(_wallets[i]);
        }
    }

    function getWhiteListedUsers() public view returns (address[] memory) {
        return whitelistedUsers;
    }

    function withdrawBep20Tokens(address _token, uint256 percentage)
        public
        onlyOwner
    {
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        require(tokenBalance > 0, "No enough tokens in the pool");

        uint256 tokensToTransfer = tokenBalance.mul(percentage).div(100);

        IERC20(_token).transfer(msg.sender, tokensToTransfer);
    }

    function distributeTokens(uint256 from, uint256 to) public {
        syncPool();

        require(
            msg.sender == poolOwner || msg.sender == owner(),
            "Only pool owner can call this function"
        );

        uint256 totalUsers = to.sub(from);
        require(totalUsers <= 50, "Please use less than 50 users at a time");

        require(poolStatus == 4, "Pool not finalized yet");

        for (uint256 i = from.sub(1); i < to; i++) {
            sendTokens(investors[i]);
        }
    }

    function distributeBnb(uint256 from, uint256 to) public {
        syncPool();

        require(
            msg.sender == poolOwner || msg.sender == owner(),
            "Only pool owner can call this function"
        );

        uint256 totalUsers = to.sub(from);
        require(totalUsers <= 50, "Please use less than 50 users at a time");

        require(poolStatus == 3, "Pool not canceled");

        for (uint256 i = from.sub(1); i < to; i++) {
            sendBnb(investors[i]);
        }
    }

    function addLiquidity() internal {}
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

interface ITokenLocker {
    function lockTokens(
        address _tokenAddress,
        uint256 amount,
        uint256 lockTime,
        bool isLp
    ) external payable returns (uint256);

    function transferLockerOwnerShip(uint256 lockerId, address _newOwner)
        external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}