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

pragma solidity 0.8.4;

/*
 _____ _         _____               
|     |_|___ ___|   __|_ _ _ ___ ___ 
| | | | |   | . |__   | | | | .'| . |
|_|_|_|_|_|_|___|_____|_____|__,|  _|
                                |_| 
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IVestingMaster.sol";
import "./interfaces/IMinoVault.sol";
import "./interfaces/IMinoDistributor.sol";

contract MinoSupporterFarm is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event UpdateEmissionRate(address indexed user, uint256 tokenPerBlock);
    event UpdateEndBlock(address indexed user, uint256 endBlock);
    event SetEarlyExitFee(address indexed user, uint256 earlyExitFee);
    event SetDevAddress(address indexed user, address devAddress);
    event SetVestingMaster(address indexed user, address vestingMaster);
    event SetDevSupply(address indexed user, uint256 devSupply);

    struct UserInfo {
        uint256 shares;
        uint256 rewardDebt;
        uint256 lastDepositedTime;
    }

    struct PoolInfo {
        IERC20 want;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
    }

    /* ========== CONSTANTS ============= */

    // Denominator for fee calculations.
    uint256 public constant FEE_DENOM = 10000;

    // Mino token
    IERC20 public immutable mino;

    // The block number when mining starts.
    uint256 public immutable startBlock;

    IMinoVault public immutable minoVault;

    /* ========== STATE VARIABLES ========== */

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Mino tokens rewarded per block.
    uint256 public minoPerBlock;
    
    // The block number when mining ends.
    uint256 public endBlock;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;

    // Developer address.
    address public devAddress;

    // Vesting contract that vested rewards get sent to.
    IVestingMaster public vestingMaster;

    IMinoDistributor public minoDistributor;

    /* ========== MODIFIERS ========== */

    modifier validatePid(uint256 _pid) {
        require(
            _pid < poolInfo.length,
            "MinoSupporterFarm::validatePid: Not exist"
        );
        _;
    }

    modifier onlyGovernance() {
        require(
            (msg.sender == devAddress || msg.sender == owner()),
            "MinoSupporterFarm::onlyGovernance: Not gov"
        );
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _minoVault,
        address _vestingMaster,
        address _mino,
        uint256 _minoPerBlock,
        uint256 _startBlock,
        uint256 _endBlock,
        address _devAddress
    ) {
        require(
            _startBlock < _endBlock,
            "MinoSupporterFarm::constructor: End less than start"
        );
        minoVault = IMinoVault(_minoVault);
        vestingMaster = IVestingMaster(_vestingMaster);
        mino = IERC20(_mino);
        minoPerBlock = _minoPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
        devAddress = _devAddress;
    }

    function initDistributor(address _minoDistributor) external onlyOwner {
        require(address(minoDistributor) == address(0), "MinoSupporterFarm::initDistributor: Distributor already set");
        minoDistributor = IMinoDistributor(_minoDistributor);
    }
    

    /* ========== VIEWS ========== */

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function pendingMino(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && user.shares != 0) {
            uint256 tokenReward = getStakingReward(_pid);
            accTokenPerShare = accTokenPerShare + (
                tokenReward * 1e12 / totalAllocPoint
            );
        }
        return user.shares * accTokenPerShare / 1e12 - user.rewardDebt;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock || pool.lastRewardBlock >= endBlock) {
            return;
        }
        uint256 lastRewardBlock = block.number >= endBlock ? endBlock : block.number;
        uint256 lpSupply = pool.want.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = lastRewardBlock;
            return;
        }
        uint256 tokenReward = getStakingReward(_pid);
        pool.accTokenPerShare += tokenReward * 1e12 / lpSupply;
        pool.lastRewardBlock = lastRewardBlock;
        minoDistributor.withdrawReward(2);
        (address supporterAddress,,,) = minoDistributor.distributees(1);
        if (supporterAddress == address(this)) {
            minoDistributor.withdrawReward(1);
        }

    }

    function deposit(uint256 _pid, uint256 _wantAmt) external nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.shares > 0) {
            uint256 pending =
                user.shares * pool.accTokenPerShare / 1e12 - (
                    user.rewardDebt
                );
            if (pending > 0) {
                uint256 locked;
                if (address(vestingMaster) != address(0)) {
                    locked = pending * (vestingMaster.lockedPeriodAmount() + 1) / vestingMaster.lockedPeriodAmount();
                }
                safeTokenTransfer(msg.sender, pending - locked);
                if (locked > 0) {
                    uint256 actualAmount = safeTokenTransfer(
                        address(vestingMaster),
                        locked
                    );
                    vestingMaster.lock(msg.sender, actualAmount);
                }
            }
        }
        if (_wantAmt > 0) {
            pool.want.safeTransferFrom(
                address(msg.sender),
                address(this),
                _wantAmt
            );

            user.shares += _wantAmt;
            user.lastDepositedTime = block.timestamp;
        }
        user.rewardDebt = user.shares * pool.accTokenPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _wantAmt);
    }

    function withdraw(uint256 _pid, uint256 _wantAmt)
        public
        nonReentrant
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.shares > 0) {
            uint256 pending =
                user.shares * pool.accTokenPerShare / 1e12 - user.rewardDebt;
            if (pending > 0) {
                uint256 locked;
                if (address(vestingMaster) != address(0)) {
                    locked = pending / (vestingMaster.lockedPeriodAmount() + 1) * vestingMaster.lockedPeriodAmount();
                }
                safeTokenTransfer(msg.sender, pending - locked);
                if (locked > 0) {
                    uint256 actualAmount = safeTokenTransfer(
                        address(vestingMaster),
                        locked
                    );
                    vestingMaster.lock(msg.sender, actualAmount);
                }
            }
        }

        if (_wantAmt > user.shares) {
            _wantAmt = user.shares;
        }
        if (_wantAmt > 0) {
            user.shares -= _wantAmt;
            pool.want.safeTransfer(address(msg.sender), _wantAmt);
        }
        user.rewardDebt = user.shares * pool.accTokenPerShare / 1e12;
        emit Withdraw(msg.sender, _pid, _wantAmt);
    }

    function withdrawAll(uint256 _pid) external {
        withdraw(_pid, type(uint256).max);
    }

    function emergencyWithdraw(uint256 _pid)
        external
        nonReentrant
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _wantAmt = user.shares;
        user.shares = 0;
        user.rewardDebt = 0;
        pool.want.safeTransfer(address(msg.sender), _wantAmt);
        emit EmergencyWithdraw(msg.sender, _pid, _wantAmt);
    }

    function getStakingReward(uint256 _pid) internal view returns (uint256 tokenReward) {
        PoolInfo storage pool = poolInfo[_pid];
        require(
            pool.lastRewardBlock < block.number,
            "MinoSupporterFarm::getStakingReward: Must less than block number"
        );

        (,,, uint256 stakingReward) = minoDistributor.distributees(2);
        (address supporterAddress,,, uint256 accReward) = minoDistributor.distributees(1);
        if (supporterAddress == address(this)) {
            stakingReward += accReward;
        }

        uint256 multiplier = block.number - pool.lastRewardBlock;
        if (block.number >= endBlock) {
            multiplier = pool.lastRewardBlock - endBlock;
        }
        tokenReward = multiplier * minoPerBlock + stakingReward;
    }

    /* ========== UTILITY FUNCTIONS ========== */

    function safeTokenTransfer(address _to, uint256 _amount)
        internal
        returns (uint256)
    {
        uint256 balance = mino.balanceOf(address(this));
        if (_amount > balance) {
            _amount = minoVault.minoSupporterWithdraw(_amount - balance);
        }

        require(
            mino.transfer(_to, _amount),
            "MinoSupporterFarm::safeTokenTransfer: Transfer failed"
        );
        return _amount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/*
 _____ _         _____               
|     |_|___ ___|   __|_ _ _ ___ ___ 
| | | | |   | . |__   | | | | .'| . |
|_|_|_|_|_|_|___|_____|_____|__,|  _|
                                |_| 
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

interface IMinoDistributor {

    /* ========== VIEWS ========== */
    function uniRouterAddress() external returns (address);

    function devShare() external returns (uint256);

    function devAddress() external returns (address);

    function govShare() external returns (uint256);

    function govAddress() external returns (address);

    function harvestShare() external returns (uint256);

    function supporterShare() external returns (uint256);

    // Slippage factor for swaps
    function slippageFactor() external returns (uint256);

    function distributees(uint256 _pid) external view returns (address distributeeAddress, address token, uint256 share, uint256 accReward);

    function nftStakingAddress() external returns (address);

    function minoSupporterReward() external returns (uint256);

    function minoStakingReward() external returns (uint256);

    /* ========== MUTATIVE FUNCTIONS ========== */

    function harvest() external;

    /* ========== RESTRICTED FUNCTIONS ========== */

    function withdrawReward(uint256 _pid) external returns (uint256);

    function updateSlippageFactor(uint256 _slippageFactor) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

/*
 _____ _         _____               
|     |_|___ ___|   __|_ _ _ ___ ___ 
| | | | |   | . |__   | | | | .'| . |
|_|_|_|_|_|_|___|_____|_____|__,|  _|
                                |_| 
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

interface IMinoVault {

    /* ========== VIEWS ========== */

    function mino() external returns (address);

    function minoFarm() external returns (address);
    function minoSupporterFarm() external returns (address);

    function devAddress() external returns (address);

    /* ========== RESTRICTED FUNCTIONS ========== */

    function minoFarmWithdraw(uint256 amount) external returns (uint256);

    function minoSupporterWithdraw(uint256 amount) external returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma abicoder v2;

/*
 _____ _         _____               
|     |_|___ ___|   __|_ _ _ ___ ___ 
| | | | |   | . |__   | | | | .'| . |
|_|_|_|_|_|_|___|_____|_____|__,|  _|
                                |_| 
*
* MIT License
* ===========
*
* Copyright (c) 2022 MinoSwap
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVestingMaster {

    /* ========== STRUCTS ========== */

    // Info of each user's vesting.
    struct LockedReward {
        uint256 vesting; // How much is being vested in total
        uint256 pending; // Rewards yet to be claimed (vesting - amount_claimed)
        uint256 start; // Start of the vesting period
        uint256 lastClaimed; // Last time the vested amount was claimed
    }
    
    /* ========== EVENTS ========== */

    event Lock(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event AddFarm(address indexed user, address farmAddress);
    event RemoveFarm(address indexed user, address farmAddress);
    event SetDevAddress(address indexed user, address devAddress);

    /* ========== RESTRICTED FUNCTIONS ========== */

    function lock(address, uint256) external;
    function addFarm(address) external;
    function removeFarm(address) external;
    function setDevAddress(address) external;

    /* ========== MUTATIVE FUNCTIONS ========== */

    function claim() external;

    /* ========== VIEWS ========== */

    function vestingToken() external view returns (IERC20);

    function period() external view returns (uint256);

    function lockedPeriodAmount() external view returns (uint256);

    function totalLockedRewards() external view returns (uint256);

    function getVestingAmount() external view returns (uint256, uint256);

    function farms(address) external view returns (bool);

    function devAddress() external view returns (address);
}