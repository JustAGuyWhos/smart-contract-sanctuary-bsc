// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract GQGalacticAllianceLimited is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint8 constant TOKEN1 = 1;
    uint8 constant TOKEN2 = 2;

    // Is contract initialized
    bool public isInitialized;

    // The block number when REWARD distribution ends.
    uint256 public endBlock;

    // The block number when REWARD distribution starts.
    uint256 public startBlock;

    // The block number of the last pool update
    uint256 public lastUpdateBlock;

    // Lockup duration for deposit
    uint256 public lockUpDuration;

    // The limit amount for staking
    uint256 public maxStakeAmount;

    // Withdraw fee in BP
    uint256 public withdrawFee;

    // Withdraw fee destiny address
    address public feeAddress;

    // The staked token
    IERC20Upgradeable public stakedToken;

    // Accrued token per share
    mapping(uint8 => uint256) public mapOfAccTokenPerShare;

    // REWARD tokens created per block.
    mapping(uint8 => uint256) public mapOfRewardPerBlock;

    // The precision factor for reward tokens
    mapping(uint8 => uint256) public mapOfPrecisionFactor;

    // decimals places of the reward token
    mapping(uint8 => uint8) public mapOfRewardTokenDecimals;

    // The reward token
    mapping(uint8 => address) public mapOfRewardTokens;

    // Info of each user that stakes tokens (stakedToken)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // Staked tokens the user has provided
        uint256 rewardDebt1; // Reward debt1
        uint256 rewardDebt2; // Reward debt2
        uint256 firstDeposit; // First deposit before withdraw
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewEndBlock(uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);
    event NewLockUpDuration(uint256 lockUpDuration);

    constructor() initializer {}

    /*
     * @notice Constructor of the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken1: reward token1 address
     * @param _rewardToken2: reward token2 address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _endBlock: end block
     * @param _lockUpDuration: duration for the deposit
     * @param _withdrawFee: fee for early withdraw
     * @param _feeAddress: address where fees for early withdraw will be send
     */
    function initialize(
        IERC20Upgradeable _stakedToken,
        address _rewardToken1,
        address _rewardToken2,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _lockUpDuration,
        uint256 _withdrawFee,
        address _feeAddress,
        uint256 _maxStakeAmount
    ) public initializer {
        __Ownable_init();
        stakedToken = _stakedToken;
        mapOfRewardTokens[TOKEN1] = _rewardToken1;
        mapOfRewardTokens[TOKEN2] = _rewardToken2;
        startBlock = _startBlock;
        endBlock = _endBlock;
        lockUpDuration = _lockUpDuration;
        withdrawFee = _withdrawFee;
        feeAddress = _feeAddress;
        maxStakeAmount = _maxStakeAmount;

        mapOfRewardTokenDecimals[TOKEN1] = IERC20MetadataUpgradeable(
            mapOfRewardTokens[TOKEN1]
        ).decimals();
        mapOfRewardTokenDecimals[TOKEN2] = IERC20MetadataUpgradeable(
            mapOfRewardTokens[TOKEN2]
        ).decimals();
        require(
            mapOfRewardTokenDecimals[TOKEN1] < 30 &&
                mapOfRewardTokenDecimals[TOKEN2] < 30,
            "Must be inferior to 30"
        );

        mapOfPrecisionFactor[TOKEN1] = uint256(
            10**(uint256(30).sub(uint256(mapOfRewardTokenDecimals[TOKEN1])))
        );
        mapOfPrecisionFactor[TOKEN2] = uint256(
            10**(uint256(30).sub(uint256(mapOfRewardTokenDecimals[TOKEN2])))
        );

        // Set the lastRewardBlock as the startBlock
        lastUpdateBlock = startBlock;

        isInitialized = true;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to deposit (in stakedToken)
     */
    function deposit(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.amount + _amount <= maxStakeAmount,
            "deposit: limit reached"
        );
        _updatePool();

        if (user.amount > 0) {
            uint256 pendingToken1 = user
                .amount
                .mul(mapOfAccTokenPerShare[TOKEN1])
                .div(mapOfPrecisionFactor[TOKEN1])
                .sub(user.rewardDebt1);
            if (pendingToken1 > 0) {
                _safeTokenTransfer(
                    mapOfRewardTokens[TOKEN1],
                    msg.sender,
                    pendingToken1
                );
            }
            uint256 pendingToken2 = user
                .amount
                .mul(mapOfAccTokenPerShare[TOKEN2])
                .div(mapOfPrecisionFactor[TOKEN2])
                .sub(user.rewardDebt2);

            if (pendingToken2 > 0) {
                _safeTokenTransfer(
                    mapOfRewardTokens[TOKEN2],
                    msg.sender,
                    pendingToken2
                );
            }
        }

        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            stakedToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.firstDeposit = user.firstDeposit == 0
                ? block.timestamp
                : user.firstDeposit;
        }

        user.rewardDebt1 = user.amount.mul(mapOfAccTokenPerShare[TOKEN1]).div(
            mapOfPrecisionFactor[TOKEN1]
        );

        user.rewardDebt2 = user.amount.mul(mapOfAccTokenPerShare[TOKEN2]).div(
            mapOfPrecisionFactor[TOKEN2]
        );

        emit Deposit(msg.sender, _amount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in rewardToken)
     */
    function withdraw(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Error: Invalid amount");
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");
        _updatePool();

        uint256 pendingToken1 = user
            .amount
            .mul(mapOfAccTokenPerShare[TOKEN1])
            .div(mapOfPrecisionFactor[TOKEN1])
            .sub(user.rewardDebt1);
        uint256 pendingToken2 = user
            .amount
            .mul(mapOfAccTokenPerShare[TOKEN2])
            .div(mapOfPrecisionFactor[TOKEN2])
            .sub(user.rewardDebt2);

        user.amount = user.amount.sub(_amount);
        uint256 _amountToSend = _amount;
        if (block.timestamp < (user.firstDeposit + lockUpDuration)) {
            uint256 _feeAmountToSend = _amountToSend.mul(withdrawFee).div(
                10000
            );
            stakedToken.safeTransfer(address(feeAddress), _feeAmountToSend);
            _amountToSend = _amountToSend - _feeAmountToSend;
        }
        stakedToken.safeTransfer(address(msg.sender), _amountToSend);
        user.firstDeposit = user.firstDeposit == 0
            ? block.timestamp
            : user.firstDeposit;

        if (pendingToken1 > 0) {
            _safeTokenTransfer(
                mapOfRewardTokens[TOKEN1],
                msg.sender,
                pendingToken1
            );
        }
        if (pendingToken2 > 0) {
            _safeTokenTransfer(
                mapOfRewardTokens[TOKEN2],
                msg.sender,
                pendingToken2
            );
        }

        user.rewardDebt1 = user.amount.mul(mapOfAccTokenPerShare[TOKEN1]).div(
            mapOfPrecisionFactor[TOKEN1]
        );
        user.rewardDebt2 = user.amount.mul(mapOfAccTokenPerShare[TOKEN2]).div(
            mapOfPrecisionFactor[TOKEN2]
        );

        emit Withdraw(msg.sender, _amount);
    }

    /*
     * @notice Claim reward tokens
     */
    function claim() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _updatePool();

        if (user.amount > 0) {
            uint256 pendingToken1 = user
                .amount
                .mul(mapOfAccTokenPerShare[TOKEN1])
                .div(mapOfPrecisionFactor[TOKEN1])
                .sub(user.rewardDebt1);

            if (pendingToken1 > 0) {
                _safeTokenTransfer(
                    mapOfRewardTokens[TOKEN1],
                    msg.sender,
                    pendingToken1
                );
                emit Claim(msg.sender, pendingToken1);
            }
            uint256 pendingToken2 = user
                .amount
                .mul(mapOfAccTokenPerShare[TOKEN2])
                .div(mapOfPrecisionFactor[TOKEN2])
                .sub(user.rewardDebt2);

            if (pendingToken2 > 0) {
                _safeTokenTransfer(
                    mapOfRewardTokens[TOKEN2],
                    msg.sender,
                    pendingToken2
                );
                emit Claim(msg.sender, pendingToken2);
            }
        }

        user.rewardDebt1 = user.amount.mul(mapOfAccTokenPerShare[TOKEN1]).div(
            mapOfPrecisionFactor[TOKEN1]
        );

        user.rewardDebt2 = user.amount.mul(mapOfAccTokenPerShare[TOKEN2]).div(
            mapOfPrecisionFactor[TOKEN2]
        );
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 _amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt1 = 0;
        user.rewardDebt2 = 0;

        // Avoid users send an amount with 0 tokens
        if (_amountToTransfer > 0) {
            if (block.timestamp < (user.firstDeposit + lockUpDuration)) {
                uint256 _feeAmountToSend = _amountToTransfer
                    .mul(withdrawFee)
                    .div(10000);
                stakedToken.safeTransfer(address(feeAddress), _feeAmountToSend);
                _amountToTransfer = _amountToTransfer - _feeAmountToSend;
            }
            stakedToken.safeTransfer(address(msg.sender), _amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, _amountToTransfer);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(stakedToken),
            "Cannot be staked token"
        );
        require(
            _tokenAddress != mapOfRewardTokens[TOKEN1] &&
                _tokenAddress != mapOfRewardTokens[TOKEN2],
            "Cannot be reward token"
        );

        IERC20Upgradeable(_tokenAddress).safeTransfer(
            address(msg.sender),
            _tokenAmount
        );

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /*
     * @notice Stop rewards
     * @dev Only callable by owner
     */
    function stopReward() external onlyOwner {
        endBlock = block.number;
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     */
    function updateRewardPerBlock(uint8 _rewardTokenId, uint256 _rewardPerBlock)
        external
        onlyOwner
    {
        require(block.number < startBlock, "Pool has started");
        mapOfRewardPerBlock[_rewardTokenId] = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    /**
     * @notice It allows the admin to update start and end blocks
     * @dev This function is only callable by owner.
     * @param _startBlock: the new start block
     * @param _bonusEndBlock: the new end block
     */
    function updateStartAndEndBlocks(
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external onlyOwner {
        require(block.number < startBlock, "Pool has started");
        require(
            _startBlock < _bonusEndBlock,
            "New startBlock must be lower than new endBlock"
        );
        require(
            block.number < _startBlock,
            "New startBlock must be higher than current block"
        );

        startBlock = _startBlock;
        endBlock = _bonusEndBlock;

        // Set the lastRewardBlock as the startBlock
        lastUpdateBlock = startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }

    /*
     * @notice Sets the lock up duration
     * @param _lockUpDuration: The lock up duration in seconds (block timestamp)
     * @dev This function is only callable by owner.
     */
    function setLockUpDuration(uint256 _lockUpDuration) external onlyOwner {
        lockUpDuration = _lockUpDuration;
        emit NewLockUpDuration(lockUpDuration);
    }

    /*
     * @notice Sets start block of the pool given a block amount
     * @param _blocks: block amount
     * @dev This function is only callable by owner.
     */
    function poolStartIn(uint256 _blocks) external onlyOwner {
        poolSetStart(block.number.add(_blocks));
    }

    /*
     * @notice Set the duration and start block of the pool
     * @param _startBlock: start block
     * @param _durationBlocks: duration block amount
     * @dev This function is only callable by owner.
     */
    function poolSetStartAndDuration(
        uint256 _startBlock,
        uint256 _durationBlocks
    ) external onlyOwner {
        poolSetStart(_startBlock);
        poolSetDuration(_durationBlocks);
    }

    /*
     * @notice Withdraws the remaining funds
     * @param _to The address where the funds will be sent
     */
    function withdrawRemains(uint8 _rewardTokenId, address _to)
        external
        onlyOwner
    {
        require(block.number > endBlock, "Error: Pool not finished yet");
        uint256 tokenBal = IERC20Upgradeable(mapOfRewardTokens[_rewardTokenId])
            .balanceOf(address(this));
        require(tokenBal > 0, "Error: No remaining funds");
        IERC20Upgradeable(mapOfRewardTokens[_rewardTokenId]).safeTransfer(
            _to,
            tokenBal
        );
    }

    /*
     * @notice Deposits the reward token1 funds
     * @param _to The address where the funds will be sent
     */
    function depositRewardTokenFunds(uint8 _rewardTokenId, uint256 _amount)
        external
        onlyOwner
    {
        IERC20Upgradeable(mapOfRewardTokens[_rewardTokenId]).safeTransfer(
            address(this),
            _amount
        );
    }

    /*
     * @notice Gets the reward per block for UI
     * @return reward per block
     */
    function rewarPerBlockUI(uint8 _rewardTokenId)
        external
        view
        returns (uint256)
    {
        return
            mapOfRewardPerBlock[_rewardTokenId].div(
                10**uint256(mapOfRewardTokenDecimals[_rewardTokenId])
            );
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(uint8 _rewardTokenId, address _user)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_user];
        uint256 rewardDebt = _rewardTokenId == TOKEN1
            ? user.rewardDebt1
            : user.rewardDebt2;
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));
        if (block.number > lastUpdateBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastUpdateBlock, block.number);
            uint256 tokenReward = multiplier.mul(
                mapOfRewardPerBlock[_rewardTokenId]
            );
            uint256 adjustedPerShare = mapOfAccTokenPerShare[_rewardTokenId]
                .add(
                    tokenReward.mul(mapOfPrecisionFactor[_rewardTokenId]).div(
                        stakedTokenSupply
                    )
                );
            return
                user
                    .amount
                    .mul(adjustedPerShare)
                    .div(mapOfPrecisionFactor[_rewardTokenId])
                    .sub(rewardDebt);
        } else {
            return
                user
                    .amount
                    .mul(mapOfAccTokenPerShare[_rewardTokenId])
                    .div(mapOfPrecisionFactor[_rewardTokenId])
                    .sub(rewardDebt);
        }
    }

    /*
     * @notice Sets start block of the pool
     * @param _startBlock: start block
     * @dev This function is only callable by owner.
     */
    function poolSetStart(uint256 _startBlock) public onlyOwner {
        require(block.number < startBlock, "Pool has started");
        uint256 rewardDurationValue = rewardDuration();
        startBlock = _startBlock;
        endBlock = startBlock.add(rewardDurationValue);
        lastUpdateBlock = startBlock;
        emit NewStartAndEndBlocks(startBlock, endBlock);
    }

    /*
     * @notice Set the duration of the pool
     * @param _durationBlocks: duration block amount
     * @dev This function is only callable by owner.
     */
    function poolSetDuration(uint256 _durationBlocks) public onlyOwner {
        require(block.number < startBlock, "Pool has started");
        endBlock = startBlock.add(_durationBlocks);
        poolCalcRewardPerBlock(TOKEN1);
        poolCalcRewardPerBlock(TOKEN2);
        emit NewEndBlock(endBlock);
    }

    /*
     * @notice Calculates the rewardPerBlock of the pool
     * @dev This function is only callable by owner.
     */
    function poolCalcRewardPerBlock(uint8 _rewardTokenId) public onlyOwner {
        uint256 rewardBal = IERC20Upgradeable(mapOfRewardTokens[_rewardTokenId])
            .balanceOf(address(this));
        mapOfRewardPerBlock[_rewardTokenId] = rewardBal.div(rewardDuration());
    }

    /*
     * @notice Gets the reward duration
     * @return reward duration
     */
    function rewardDuration() public view returns (uint256) {
        return endBlock.sub(startBlock);
    }

    /*
     * @notice SendPending tokens to claimer
     * @param pending: amount to claim
     */
    function _safeTokenTransfer(
        address _rewardToken,
        address _to,
        uint256 _amount
    ) internal {
        uint256 rewardTokenBalance = IERC20Upgradeable(_rewardToken).balanceOf(
            address(this)
        );
        if (_amount > rewardTokenBalance) {
            IERC20Upgradeable(_rewardToken).safeTransfer(
                _to,
                rewardTokenBalance
            );
        } else {
            IERC20Upgradeable(_rewardToken).safeTransfer(_to, _amount);
        }
    }

    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if (block.number <= lastUpdateBlock) {
            return;
        }

        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));

        if (stakedTokenSupply == 0) {
            lastUpdateBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastUpdateBlock, block.number);
        uint256 tokenReward1 = multiplier.mul(mapOfRewardPerBlock[TOKEN1]);
        uint256 tokenReward2 = multiplier.mul(mapOfRewardPerBlock[TOKEN2]);
        mapOfAccTokenPerShare[TOKEN1] = mapOfAccTokenPerShare[TOKEN1].add(
            tokenReward1.mul(mapOfPrecisionFactor[TOKEN1]).div(
                stakedTokenSupply
            )
        );
        mapOfAccTokenPerShare[TOKEN2] = mapOfAccTokenPerShare[TOKEN2].add(
            tokenReward2.mul(mapOfPrecisionFactor[TOKEN2]).div(
                stakedTokenSupply
            )
        );
        lastUpdateBlock = block.number;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     * @return multiplier
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= endBlock) {
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            return endBlock.sub(_from);
        }
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
library SafeMathUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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