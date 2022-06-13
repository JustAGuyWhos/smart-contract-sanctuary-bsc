// TODO:
//
// - test token transfer to contract [+]
// - user structure — balances (total, liquid), timelocks (start, release) [+]
// - approve USDT [+]
// - get USDT allowance [+]
// - get USDT user balance [+]
// - token purchase function [+]
// - get contract usdt balance [+]
// - add user amount limits checks [+]
// - token locks [+]
// - token claim function [+]
// - raised balance withdraw function [+]
// - add round end conditions

// FUNCTIONS for UI:
//
// - Round end date => ROUND_END_DATE
// - Tokens left => availableTreasury
// - Buy tokens (recieve in USDT, input amount in SQAT) => buySqat(uint256 _amount)
// - Return user liquid balance => getUserLiquidSqat()
// - Pending for claim for user => getUserPendingSqat()
// - Next unlock date for user => getUserNextUnlockDate()
// - Check allowance => getUserUsdtAllowance()
// - Set allowance => call USDT contract from website directly (approve amount = 200000000000000000000000000 wei)
// - Check if user tokens unlocked and transfer them to user => claimTokens()

// DEPLOYMENT:
//
// - Deploy SQAT token
// - Deploy SeedRound, pass SQAT && USDT token addresses to constructor

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../libs/@openzeppelin/contracts/security/Pausable.sol";
import "../libs/@openzeppelin/contracts/access/Ownable.sol";
import "../libs/@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ISQAT.sol";

contract SeedRound is Pausable, Ownable {
  uint256 constant public               SEED_ROUND_FUND = 20000000 ether;
  uint256 constant public               SQAT_PRICE_USDT = 10;     // 0.1 usdt
  uint256 constant public               MAX_SQAT_PER_ADDRESS = 500000 ether;
  uint256 constant public               MIN_PURCHASE_AMOUNT = 1000 ether;
  uint256 constant public               ROUND_END_DATE = 1656018000; // 23.06.22 24:00
  uint256 constant public               LOCK_PERIOD = 20 seconds;  // <------------- change to 30 days

  address                               sqatAddress;
  address                               usdtAddress;
  ISQAT                                 SQAT;
  IERC20                                USDT;

  uint256 public                        availableTreasury = SEED_ROUND_FUND;

  struct                                User {
    uint256                             totalSqatBalance;
    uint256                             liquidBalance;
    uint256                             pendingForClaim;
    uint256                             nextUnlockDate;
    uint8                               numUnlocks; // 6 in total
    bool                                haveBought;
    bool                                isLocked;
  }
  mapping(address => User) public       users;

  event                                 SqatPurchased(address indexed user, uint256 amount);
  event                                 SqatClaimed(address indexed user,
                                                    uint256 amount,
                                                    uint256 claimsLeft,
                                                    uint256 nextUnlockDate);
  event                                 BalanceWithdrawn(address reciever, uint256 amount);

  constructor(address sqat, address usdt) {
    sqatAddress = sqat;
    usdtAddress = usdt;
    SQAT = ISQAT(sqatAddress);
    USDT = IERC20(usdtAddress);
    SQAT.grantManagerToContractInit(address(this), SEED_ROUND_FUND);
    SQAT.transferFrom(sqat, address(this), SEED_ROUND_FUND);
    SQAT.revokeManagerAfterContractInit(address(this));
  }

  modifier                              areTokensAvailable(uint256 amount) {
    require(amount >= MIN_PURCHASE_AMOUNT,
                                        "Min purchase amount is 1k!");
    require(availableTreasury - amount >= 0,
                                        "Not enough SQAT tokens left!");
    require(getUserUsdtAllowance() >= amount,
                                        "Not enough allowance, approve your USDT first!");
    require((users[msg.sender].totalSqatBalance + amount) <= MAX_SQAT_PER_ADDRESS,
                                        "Maximum amount of tokens per address is 500k!");
    _;
  }

  modifier                              checkLock() {
    require(block.timestamp >= users[msg.sender].nextUnlockDate,
                                        "Tokens are still locked!");
    users[msg.sender].isLocked = false;
    _;
  }

  function                              claimTokens() public checkLock() {
    address                             user = msg.sender;
    User storage                        userStruct = users[user];
    uint256                             amountToClaim; // 15%

    if (userStruct.numUnlocks < 5) {
      amountToClaim = (userStruct.pendingForClaim / 10000) * 1500;
    }
    else if (userStruct.numUnlocks == 5) {
      amountToClaim = userStruct.pendingForClaim;
    }
    else {
      revert("Nothing to claim!");
    }
    SQAT.transfer(user, amountToClaim);
    userStruct.liquidBalance += amountToClaim;
    userStruct.pendingForClaim -= amountToClaim;
    userStruct.nextUnlockDate += LOCK_PERIOD;
    userStruct.numUnlocks += 1;
    userStruct.isLocked = true;
    emit SqatClaimed(user,
                     amountToClaim,
                     6 - userStruct.numUnlocks,
                     userStruct.nextUnlockDate);
  }

  // @notice                            allows to purchase SQAT tokens
  // @param                             [uint256] _amount => amount of SQAT tokens to purchase
  function                              buySqat(uint256 _amount) public areTokensAvailable(_amount) {
    address                             user = msg.sender;
    uint256                             priceUSDT = _amount / SQAT_PRICE_USDT;

    require(USDT.balanceOf(user) >= priceUSDT, "Not enough USDT tokens!");
    require(USDT.transferFrom(user, address(this), priceUSDT) == true, "Failed to transfer USDT!");
    if (users[user].haveBought == false) {
      users[user].haveBought = true;
    }
    SQAT.transfer(user, _amount);
    _lockAndDistribute(_amount);
    emit SqatPurchased(msg.sender, _amount);
  }

  function                              _lockAndDistribute(uint256 _amount) internal {
    address                             user = msg.sender;
    User storage                        userStruct = users[user];
    uint256                             timestampNow = block.timestamp;
    uint256                             immediateAmount = (_amount / 10000) * 1000;  // 10%

    userStruct.totalSqatBalance += _amount;
    availableTreasury -= _amount;
    userStruct.liquidBalance += immediateAmount;                          // issue 10% immediately
    userStruct.pendingForClaim += _amount - immediateAmount;              // lock the rest
    userStruct.nextUnlockDate = timestampNow + LOCK_PERIOD;               // lock for 3 months
    userStruct.isLocked = true;
    userStruct.numUnlocks = 0;
  }

  function                              getContractUsdtBalance() public view returns(uint256) {
    return(USDT.balanceOf(address(this)));
  }

  function                              getUserUsdtBalance() public view returns(uint256) {
    return(USDT.balanceOf(msg.sender));
  }

  function                              getUserUsdtAllowance() public view returns(uint256) {
    return (USDT.allowance(msg.sender, address(this)));
  }

  function                              getUserLiquidSqat() public view returns(uint256) {
    return(users[msg.sender].liquidBalance);
  }

  function                              getUserPendingSqat() public view returns(uint256) {
    return(users[msg.sender].pendingForClaim);
  }

  function                              getUserNextUnlockDate() public view returns(uint256) {
    return(users[msg.sender].nextUnlockDate);
  }

  function                              withdrawRaisedFunds(address _reciever) public onlyOwner {
    uint256                             balance = getContractUsdtBalance();

    USDT.transfer(_reciever, balance);
    emit BalanceWithdrawn(_reciever, balance);
  }

  function                              pause() public onlyOwner {
      _pause();
  }

  function                              unpause() public onlyOwner {
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
pragma solidity ^0.8.4;

// @notice SQAT token contract interface
interface ISQAT {
  function        balanceOf(address account) external view returns (uint256);
  function        transfer(address to, uint256 amount) external returns (bool);
  function        transferFrom(address from,
                               address to,
                               uint256 amount
                               ) external returns (bool);
  function        approve(address spender, uint256 amount) external returns (bool);
  function        allowance(address owner, address spender) external view returns (uint256);
  function        grantManagerToContractInit(address account, uint256 amount) external;
  function        revokeManagerAfterContractInit(address account) external;
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