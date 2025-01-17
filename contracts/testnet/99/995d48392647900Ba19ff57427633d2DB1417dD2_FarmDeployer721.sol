//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./ERC721Farm.sol";
import "./IFarmDeployer.sol";

contract FarmDeployer721 is IFarmDeployer721 {

    modifier onlyFarmDeployer() {
        require(farmDeployer == msg.sender, "Only Farm Deployer");
        _;
    }

    address public immutable farmDeployer;

    /*
     * @notice Initialize the contract
     * @param _farmDeployer: Farm deployer address
     */
    constructor(
        address _farmDeployer
    ) {
        require(_farmDeployer != address(0));
        farmDeployer = _farmDeployer;
    }


    /*
     * @notice Deploys ERC721Farm contract. Requires amount of BNB to be paid
     * @param _stakeToken: Stake token address
     * @param _rewardToken: Reward token address
     * @param _startBlock: Start block
     * @param _rewardPerBlock: Reward per block (in rewardToken)
     * @param _userStakeLimit: Maximum amount of tokens a user is allowed to stake (if any, else 0)
     * @param _minimumLockTime: Minimum number of blocks user should wait after deposit to withdraw without fee
     * @param owner: Owner of the contract
     * @return farmAddress: Address of deployed pool contract
     */
    function deploy(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        address owner
    ) external onlyFarmDeployer returns(address farmAddress){

        farmAddress = address(new ERC721Farm());
        IERC721Farm(farmAddress).initialize(
            _stakeToken,
            _rewardToken,
            _startBlock,
            _rewardPerBlock,
            _userStakeLimit,
            _minimumLockTime,
            owner
        );
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IFarmDeployer.sol";


contract ERC721Farm is Ownable, ReentrancyGuard, IERC721Farm{

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256[] tokenIds, uint256 rewards);
    event EmergencyWithdraw(address indexed user, uint256[] tokenIds);
    event NewStartBlock(uint256 startBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewMinimumLockTime(uint256 minimumLockTime);
    event NewUserStakeLimit(uint256 userStakeLimit);
    event Withdraw(address indexed user, uint256[] tokenIds, uint256 rewards);

    IERC721 public stakeToken;
    IERC20 public rewardToken;
    IFarmDeployer private farmDeployer;


    uint256 public startBlock;
    uint256 public lastRewardBlock;
    uint256 public rewardPerBlock;
    uint256 public userStakeLimit;
    uint256 public minimumLockTime;
    uint256 public stakeTokenSupply = 0;
    uint256 public totalPendingReward = 0;
    uint256 public lastRewardTokenBalance = 0;

    // Accrued token per share
    uint256 public accTokenPerShare;

    // The precision factor
    uint256 public PRECISION_FACTOR;

    // Info of each user that stakes tokens (stakeToken)
    mapping(address => UserInfo) public userInfo;
    bool private initialized = false;

    struct UserInfo {
        uint256[] tokenIds; // List of token IDs
        uint256 rewardDebt; // Reward debt
        uint256 depositBlock; // Reward debt
    }

    /*
     * @notice Initialize the contract
     * @param _stakeToken: stake token address
     * @param _rewardToken: reward token address
     * @param _startBlock: start block
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _userStakeLimit: maximum amount of tokens a user is allowed to stake (if any, else 0)
     * @param _minimumLockTime: minimum number of blocks user should wait after deposit to withdraw without fee
     * @param owner: admin address with ownership
     */
    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        address contractOwner
    ) external {
        require(!initialized, "Already initialized");
        require(_rewardPerBlock > 0, "Invalid reward per block");
        initialized = true;

        transferOwnership(contractOwner);
        farmDeployer = IFarmDeployer(IFarmDeployer721(msg.sender).farmDeployer());

        stakeToken = IERC721(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        startBlock = _startBlock;
        lastRewardBlock = _startBlock;
        rewardPerBlock = _rewardPerBlock;
        userStakeLimit = _userStakeLimit;
        minimumLockTime = _minimumLockTime;

        uint256 decimalsRewardToken = uint256(
            IERC20Metadata(_rewardToken).decimals()
        );
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(30 - decimalsRewardToken));
    }


    /*
     * @notice Deposit staked tokens on behalf of msg.sender and collect reward tokens (if any)
     * @param tokenIds: Array of token index IDs to deposit
     */
    function deposit(uint256[] calldata tokenIds) external {
        _deposit(tokenIds, address(msg.sender));
    }


    /*
     * @notice Deposit staked tokens on behalf account and collect reward tokens (if any)
     * @param tokenIds: Array of token index IDs to deposit
     * @param account: future owner of deposit
     */
    function depositOnBehalf(uint256[] calldata tokenIds, address account) external {
        _deposit(tokenIds, account);
    }


    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @dev Requires approval for all to be set
     * @param tokenIds: Array of token index IDs to deposit
     * @param account: Future owner of deposit
     */
    function _deposit (
        uint256[] calldata tokenIds,
        address account
    ) internal nonReentrant {
        _collectFee();
        require(block.number >= startBlock, "Pool is not active yet");
        require(block.number < getFinalBlockNumber(), "Pool has ended");
        require(stakeToken.isApprovedForAll(msg.sender, address(this)), "Not approved");

        UserInfo storage user = userInfo[account];
        uint256 amountOfTokens = user.tokenIds.length;

        if (userStakeLimit > 0) {
            require(
                tokenIds.length + amountOfTokens <= userStakeLimit,
                "User amount above limit"
            );
        }

        _updatePool();

        uint256 pending = 0;
        if (amountOfTokens > 0) {
            pending = amountOfTokens * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                rewardToken.transfer(account, pending);
            }
            totalPendingReward -= pending;
        }

        for(uint i = 0; i < tokenIds.length; i++) {
            require(stakeToken.ownerOf(tokenIds[i]) == msg.sender, "Not an owner");
            user.tokenIds.push(tokenIds[i]);
            stakeToken.transferFrom(
                address(msg.sender),
                address(this),
                tokenIds[i]
            );
        }

        stakeTokenSupply += tokenIds.length;

        user.rewardDebt = user.tokenIds.length * accTokenPerShare / PRECISION_FACTOR;
        user.depositBlock = block.number;
        lastRewardTokenBalance = rewardToken.balanceOf(address(this));

        emit Deposit(account, tokenIds, pending);
    }


    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @notice Withdrawal before minimum lock time is impossible
     * @param tokenIds: Array of token index IDs to withdraw
     */
    function withdraw(uint256[] calldata tokenIds) external nonReentrant {
        _collectFee();
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountOfTokens = user.tokenIds.length;
        require(amountOfTokens >= tokenIds.length, "Invalid IDs");

        uint256 earliestBlockToWithdrawWithoutFee = user.depositBlock + minimumLockTime;
        require(block.number >= earliestBlockToWithdrawWithoutFee, "Can't withdraw yet");

        _updatePool();

        uint256 pending = amountOfTokens * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;

        if (tokenIds.length > 0) {
            for(uint i = 0; i < tokenIds.length; i++){
                bool tokenTransferred = false;
                for(uint j = 0; j < user.tokenIds.length; j++){
                    if(tokenIds[i] == user.tokenIds[j]) {
                        user.tokenIds[j] = user.tokenIds[user.tokenIds.length - 1];
                        user.tokenIds.pop();
                        stakeToken.transferFrom(address(this), msg.sender, tokenIds[i]);
                        tokenTransferred = true;
                        break;
                    }
                }
                require(tokenTransferred, "Token not found");
            }
            stakeTokenSupply -= tokenIds.length;
        }

        if (pending > 0) {
            rewardToken.transfer(address(msg.sender), pending);
            totalPendingReward -= pending;
        }

        user.rewardDebt = user.tokenIds.length * accTokenPerShare / PRECISION_FACTOR;
        lastRewardTokenBalance = rewardToken.balanceOf(address(this));

        emit Withdraw(msg.sender, tokenIds, pending);
    }


    /*
     * @notice Withdraw staked tokens without caring about rewards rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        _collectFee();
        UserInfo storage user = userInfo[msg.sender];

        uint256[] memory tokenArray = user.tokenIds;
        uint256 tokensAmount = tokenArray.length;
        uint256 pending = tokensAmount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        totalPendingReward -= pending;
        delete user.tokenIds;
        user.rewardDebt = 0;

        if(tokensAmount > 0){
            for(uint i = 0; i < tokenArray.length; i++) {
                stakeToken.transferFrom(
                    address(this),
                    address(msg.sender),
                    tokenArray[i]
                );
            }
            stakeTokenSupply -= tokensAmount;
        }
        lastRewardTokenBalance = rewardToken.balanceOf(address(this));

        emit EmergencyWithdraw(msg.sender, tokenArray);
    }


    /*
     * @notice Calculates the last block number according to available funds
     */
    function getFinalBlockNumber() public view returns (uint256) {
        uint256 contractBalance = rewardToken.balanceOf(address(this));
        uint256 firstBlock = stakeTokenSupply == 0 ? block.number : lastRewardBlock;
        return firstBlock + (contractBalance - totalPendingReward) / rewardPerBlock;
    }


    /*
     * @notice Allows Owner to withdraw ERC20 tokens from the contract
     * @param _tokenAddress: Address of ERC20 token contract
     * @param _tokenAmount: Amount of tokens to withdraw
     */
    function recoverERC20(
        address _tokenAddress,
        uint256 _tokenAmount
    ) external onlyOwner {
        _updatePool();

        if(_tokenAddress == address(rewardToken)){
            uint256 allowedAmount = rewardToken.balanceOf(address(this)) - totalPendingReward;
            require(_tokenAmount <= allowedAmount, "Over allowed amount");
        }

        IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }


    /*
     * @notice Sets start block of the pool
     * @param _startBlock: Number of start block
     */
    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(_startBlock >= block.number, "Can't set past block");
        require(startBlock >= block.number, "Staking has already started");
        startBlock = _startBlock;
        lastRewardBlock = _startBlock;

        emit NewStartBlock(_startBlock);
    }


    /*
     * @notice Sets reward amount per block
     * @param _rewardPerBlock: Token amount to be distributed for each block
     */
    function setRewardPerBlock(uint256 _rewardPerBlock) public onlyOwner {
        require(_rewardPerBlock != 0);
        rewardPerBlock = _rewardPerBlock;

        emit NewRewardPerBlock(_rewardPerBlock);
    }


    /*
     * @notice Sets maximum amount of tokens 1 user is able to stake. 0 for no limit
     * @param _userStakeLimit: Maximum amount of tokens allowed to stake
     */
    function setUserStakeLimit(uint256 _userStakeLimit) public onlyOwner {
        require(_userStakeLimit != 0);
        userStakeLimit = _userStakeLimit;

        emit NewUserStakeLimit(_userStakeLimit);
    }


    /*
     * @notice Sets minimum amount of blocks that should pass before user can withdraw his deposit
     * @param _minimumLockTime: Number of blocks
     */
    function setMinimumLockTime(uint256 _minimumLockTime) public onlyOwner {
        require(_minimumLockTime <= farmDeployer.maxLockTime(),"Over max lock time");
        require(_minimumLockTime < minimumLockTime, "Can't increase");
        minimumLockTime = _minimumLockTime;

        emit NewMinimumLockTime(_minimumLockTime);
    }


    /*
     * @notice Sets farm variables
     * @param _startBlock: Number of start block
     * @param _rewardPerBlock: Token amount to be distributed for each block
     * @param _userStakeLimit: Maximum amount of tokens allowed to stake
     * @param _minimumLockTime: Number of blocks
     */
    function setFarmValues(
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime
    ) external onlyOwner {
        //start block
        if (startBlock != _startBlock) {
            setStartBlock(_startBlock);
        }

        //reward per block
        if (rewardPerBlock != _rewardPerBlock) {
            setRewardPerBlock(_rewardPerBlock);
        }

        //user stake limit
        if (userStakeLimit != _userStakeLimit) {
            setUserStakeLimit(_userStakeLimit);
        }

        //min lock time
        if (minimumLockTime != _minimumLockTime) {
            setMinimumLockTime(_minimumLockTime);
        }
    }


    /*
     * @notice View function to get deposited tokens array.
     * @param _user User address
     * @return tokenIds Deposited token IDs array
     */
    function getUserStakedTokenIds(address _user)
        external
        view
        returns(uint256[] memory tokenIds)
    {
        return userInfo[_user].tokenIds;
    }


    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        if (block.number > lastRewardBlock && stakeTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 cakeReward = multiplier * rewardPerBlock;
            uint256 adjustedTokenPerShare = accTokenPerShare +
                cakeReward * PRECISION_FACTOR / stakeTokenSupply;
            return user.tokenIds.length * adjustedTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        } else {
            return user.tokenIds.length * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        }
    }


    /*
     * @notice Updates pool variables
     */
    function _updatePool() private {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (stakeTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 cakeReward = multiplier * rewardPerBlock;
        totalPendingReward += cakeReward;
        accTokenPerShare = accTokenPerShare +
            cakeReward * PRECISION_FACTOR / stakeTokenSupply;
        lastRewardBlock = block.number;
    }


    /*
     * @notice Calculates number of blocks to pay reward for.
     * @param _from: Starting block
     * @param _to: Ending block
     * @return Number of blocks, that should be rewarded
     */
    function _getMultiplier(
        uint256 _from,
        uint256 _to
    )
    private
    view
    returns (uint256)
    {
        uint256 finalBlock = getFinalBlockNumber();
        if (_to <= finalBlock) {
            return _to - _from;
        } else if (_from >= finalBlock) {
            return 0;
        } else {
            return finalBlock - _from;
        }
    }


    /*
     * @notice Calculates reward token income and transfers specific fee amount.
     * @notice Fee share and fee receiver are specified on Deployer contract
     */
    function _collectFee() private {
        uint256 incomeFee = farmDeployer.incomeFee();
        if (incomeFee > 0) {
            uint256 rewardBalance = rewardToken.balanceOf(address(this));
            if(rewardBalance != lastRewardTokenBalance) {
                uint256 income = rewardBalance - lastRewardTokenBalance;
                uint256 feeAmount = income * incomeFee / 10_000;
                rewardToken.transfer(farmDeployer.feeReceiver(), feeAmount);
            }
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IFarmDeployer {
    function maxLockTime() external returns(uint256);
    function incomeFee() external returns(uint256);
    function feeReceiver() external returns(address payable);
}

interface IFarmDeployer20 {
    function farmDeployer() external returns(address);
    function deploy(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        uint256 _earlyWithdrawalFee,
        address _feeReceiver,
        bool _keepReflectionOnDeposit,
        address owner
    ) external returns(address);
}

interface IFarmDeployer20FixEnd {
    function farmDeployer() external returns(address);
    function deploy(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        uint256 _earlyWithdrawalFee,
        address _feeReceiver,
        address owner
    ) external returns(address);
}

interface IFarmDeployer721 {
    function farmDeployer() external returns(address);
    function deploy(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        address owner
    ) external returns(address);
}

interface IFarmDeployer721FixEnd {
    function farmDeployer() external returns(address);
    function deploy(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        address owner
    ) external returns(address);
}

interface IERC20Farm {
    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        uint256 _earlyWithdrawalFee,
        address _feeReceiver,
        bool _keepReflectionOnDeposit,
        address owner
    ) external;
}

interface IERC20FarmFixEnd {
    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        uint256 _earlyWithdrawalFee,
        address _feeReceiver,
        address owner
    ) external;
}

interface IERC721Farm {
    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _rewardPerBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        address owner
    ) external;
}

interface IERC721FarmFixEnd {
    function initialize(
        address _stakeToken,
        address _rewardToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _userStakeLimit,
        uint256 _minimumLockTime,
        address owner
    ) external;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
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