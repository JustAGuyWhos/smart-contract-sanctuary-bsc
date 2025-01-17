/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-10
 */

/**
 *Submitted for verification at BscScan.com on 2022-04-14
 */

/**
 *Submitted for verification at BscScan.com on 2022-02-10
 */

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

// SPDX-License-Identifier: BSD-4-Clause

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
}

// File: @openzeppelin/contracts/utils/Address.sol

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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File: @openzeppelin/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

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
        require(
            _initializing ? _isConstructor() : !_initialized,
            "Initializable: contract is already initialized"
        );

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
        return !Address.isContract(address(this));
    }
}

pragma solidity ^0.8.6;

/*
 * ApeSwapFinance
 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */


interface IWineryNFT {
    function getInfoForStaking(uint tokenId) external view returns (address tokenOwner, bool stakeFreeze, uint robiBoost);  
}

interface IWineryIDONFT {
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract WineryIDOLRPS is ReentrancyGuard, Initializable {
    using SafeERC20 for IERC20;
    IWineryNFT public wineryNFT;
    IWineryIDONFT public wineryIDONFT;
    uint256 public constant HARVEST_PERIODS = 7;

    uint256[HARVEST_PERIODS] public harvestReleaseTimestamps;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        bool[HARVEST_PERIODS] claimed; // default false
    }

    address public owner;

    mapping(address => bool) public registers;
    mapping(address => bool) public whitelist;

    // Allocation amount;
    uint256 public allocationLimitDAO;
    uint256 public allocationLimitIDO;

    // The raising token
    IERC20 public raisingToken;
    uint256 public raisingAmount;

    // The offering token
    IERC20 public offeringToken;
    uint256 public offeringAmount;

    // Start, end of IDO.
    uint256 public startTime;
    uint256 public endTime;
    uint256 public startClaimingTime;

    // Total raising amount;
    uint256 public totalAmount;

    address public treasuryDepositAddress; // The address that receive staking
    address public treasuryWithdrawAddress; // The address that sent profit

    // address => amount
    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 offeringAmount);

    constructor(IWineryNFT _wineryNFT, IWineryIDONFT _wineryIDONFT) {
        wineryNFT = _wineryNFT;
        wineryIDONFT = _wineryIDONFT;
    }

    function initialize(
        IERC20 _raisingToken,
        uint256 _raisingAmount,
        IERC20 _offeringToken,
        uint256 _offeringAmount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _startClaimingTime,
        uint256 _vestingOffset, // Timestamp offset between vesting distributions
        address _treasuryDepositAddress,
        address _treasuryWithdrawAddress,
        uint256 _allocationLimitDAO,
        uint256 _allocationLimitIDO
    ) external initializer {
        owner = msg.sender;

        raisingToken = _raisingToken;
        raisingAmount = _raisingAmount;

        offeringToken = _offeringToken;
        offeringAmount = _offeringAmount;

        startTime = _startTime;
        endTime = _endTime;
        startClaimingTime = _startClaimingTime;

        treasuryDepositAddress = _treasuryDepositAddress;
        treasuryWithdrawAddress = _treasuryWithdrawAddress;

        allocationLimitDAO = _allocationLimitDAO;
        allocationLimitIDO = _allocationLimitIDO;

        // Setup vesting release blocks
        for (uint256 i = 0; i < HARVEST_PERIODS; i++) {
            harvestReleaseTimestamps[i] =
                _startClaimingTime +
                (_vestingOffset * i);
        }
    }

    // Update the start time
    function updateWineryNFT(IWineryNFT _wineryNFT) external onlyOwner {
        wineryNFT = _wineryNFT;
    }

    function updateWineryIDONFT(IWineryIDONFT _wineryIDONFT) external onlyOwner {
        wineryIDONFT = _wineryIDONFT;
    }

    // Update the start time
    function updateStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    // Update the end time
    function updateEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }

    // Update the start claiming time
    function updateStartClaimingTime(
        uint256 _startClaimingTime,
        uint256 _vestingOffset
    ) external onlyOwner {
        startClaimingTime = _startClaimingTime;
        for (uint256 i = 0; i < HARVEST_PERIODS; i++) {
            harvestReleaseTimestamps[i] =
                _startClaimingTime +
                (_vestingOffset * i);
        }
    }

    // Update treasury deposit address
    function setTreasuryDepositAddress(address _treasuryDepositAddress)
        public
        onlyOwner
    {
        treasuryDepositAddress = _treasuryDepositAddress;
    }

    // Update treasury withdraw address
    function setTreasuryWithdrawAddress(address _treasuryWithdrawAddress)
        public
        onlyOwner
    {
        treasuryWithdrawAddress = _treasuryWithdrawAddress;
    }

    // Update allocation limits.
    function updateAllocationLimit(uint256 _allocationLimitDAO,uint256 _allocationLimitIDO) public onlyOwner {
        allocationLimitDAO = _allocationLimitDAO;
        allocationLimitIDO = _allocationLimitIDO;
    }

    // Check is registered.
    function isRegistered(address _user) public view returns (bool) {
        return registers[_user];
    }

    // Check is whitelist.
    function isWhitelist(address _user,uint256 _nftId) public view returns (bool) {
        // user DAO or Own IDO Nft
        return isDAO(_user, _nftId) || isIDOOwner(_user);
    }

    function isDAO(address _user,uint256 _nftId) public view returns (bool) {
        (address tokenOwner, bool stakeFreeze, uint robiBoost) = wineryNFT.getInfoForStaking(_nftId);
        return (tokenOwner == _user && stakeFreeze == true);
    }

    function isIDOOwner(address _user) public view returns (bool) {
        uint256 balanceOfOwner = wineryIDONFT.balanceOf(_user);
        return balanceOfOwner > 0;
    }

    function setOfferingAmount(uint256 _offerAmount) public onlyOwner {
        require(block.timestamp < startTime, "cannot update during active ido");
        offeringAmount = _offerAmount;
    }

    function setRaisingAmount(uint256 _raisingAmount) public onlyOwner {
        require(block.number < startTime, "cannot update during active ido");
        raisingAmount = _raisingAmount;
    }

    function getLimitDeposit(address _user,uint256 _nftId) public view returns (uint256) {
        uint256 limit = 0;

        // DAO
        
        if (isDAO(_user, _nftId)) {
            if (allocationLimitDAO > 0) {
                
                limit = allocationLimitDAO - userInfo[_user].amount;

                uint256 remainAmount = raisingAmount - totalAmount;
                if (remainAmount < limit) {
                    limit = remainAmount;
                }
            } else {
                limit = raisingAmount - totalAmount;
            }

            return limit;
        }
        
         // IDO
        
        if (isIDOOwner(_user)) {
            if (allocationLimitIDO > 0) {
                limit = allocationLimitIDO - userInfo[_user].amount;

                uint256 remainAmount = raisingAmount - totalAmount;
                if (remainAmount < limit) {
                    limit = remainAmount;
                }
            } else {
                limit = raisingAmount - totalAmount;
            }

            return limit;
        }
        
        return limit;
    }


    /// @dev Deposit ERC20 tokens with support for reflect tokens
    function deposit(uint256 _amount,uint256 _nftId) external nonReentrant onlyActiveIDO {
        require(_amount > 0, "_amount not > 0");

        require(
            totalAmount + _amount <= raisingAmount,
            "totalAmount + _amount > offeringAmount"
        );

        require(
            isWhitelist(msg.sender,_nftId) || isRegistered(msg.sender),
            "User is not whitelisted or registered"
        );

        require(
            _amount <= getLimitDeposit(msg.sender,_nftId),
            "Deposit amount is greater than the limit"
        );

        raisingToken.safeTransferFrom(
            msg.sender,
            treasuryDepositAddress,
            _amount
        );

        depositInternal(_amount);
    }

    /// @notice To support ERC20 and native token deposits this function does not transfer
    ///  any tokens in, but only updates the state. Make sure to transfer in the funds
    ///  in a parent function
    function depositInternal(uint256 _amount) internal {
        userInfo[msg.sender].amount += _amount;
        totalAmount += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function harvest(uint256 harvestPeriod) external nonReentrant {
        require(harvestPeriod < HARVEST_PERIODS, "harvest period out of range");
        require(
            block.timestamp > harvestReleaseTimestamps[harvestPeriod],
            "not harvest time"
        );
        require(userInfo[msg.sender].amount > 0, "have you participated?");
        require(
            !userInfo[msg.sender].claimed[harvestPeriod],
            "harvest for period already claimed"
        );

        uint256 offeringTokenAmountPerPeriod = getOfferingAmountPerPeriod(
            msg.sender,
            harvestPeriod
        );

        offeringToken.safeTransferFrom(
            treasuryWithdrawAddress,
            msg.sender,
            offeringTokenAmountPerPeriod 
        );

        userInfo[msg.sender].claimed[harvestPeriod] = true;

        emit Harvest(msg.sender, offeringTokenAmountPerPeriod);
    }

    function hasHarvested(address _user, uint256 harvestPeriod)
        external
        view
        returns (bool)
    {
        return userInfo[_user].claimed[harvestPeriod];
    }

    function getTotalStakeTokenBalance() public view returns (uint256) {
        return totalAmount;
    }

    /// @notice Calculate a user's offering amount to be received by multiplying the offering amount by
    ///  the user allocation percentage.
    /// @dev User allocation is scaled up by the ALLOCATION_PRECISION which is scaled down before returning a value.
    /// @param _user Address of the user allocation to look up
    function getOfferingAmount(address _user) public view returns (uint256) {
        return (userInfo[_user].amount * offeringAmount) / raisingAmount;
    }

    // get the amount of IDO token you will get per harvest period
    function getOfferingAmountPerPeriod(address _user, uint256 _period)
        public
        view
        returns (uint256)
    {

        // Total 7 time
        if (_period == 0) {
            // 5% first time
            return (getOfferingAmount(_user) * 5) / 100;
        } else {
            // 15.83333% linear for 6 months
            return (getOfferingAmount(_user) * 95) / 600;
        }
    } 

    /// @notice Get the amount of tokens a user is eligible to receive based on current state.
    /// @param _user address of user to obtain token status
    function userTokenStatus(address _user)
        public
        view
        returns (uint256 offeringTokenHarvest, uint256 offeringTokensVested)
    {
        uint256 currentTime = block.timestamp;
        if (currentTime < endTime) {
            return (0, 0);
        }

        for (uint256 i = 0; i < HARVEST_PERIODS; i++) {
            if (
                currentTime >= harvestReleaseTimestamps[i] &&
                !userInfo[_user].claimed[i]
            ) {
                // If offering tokens are available for harvest AND user has not claimed yet
                offeringTokenHarvest += getOfferingAmountPerPeriod(_user, i);
            } else if (currentTime < harvestReleaseTimestamps[i]) {
                // If harvest period is in the future
                offeringTokensVested += getOfferingAmountPerPeriod(_user, i);
            }
        }

        return (offeringTokenHarvest, offeringTokensVested);
    }

    /// @notice Internal function to handle stake token transfers. Depending on the stake
    ///   token type, this can transfer ERC-20 tokens or native EVM tokens.
    /// @param _to address to send stake token to
    /// @param _amount value of reward token to transfer
    function safeTransferStakeInternal(address _to, uint256 _amount) internal {
        require(
            _amount <= getTotalStakeTokenBalance(),
            "not enough stake token"
        );

        // Transfer ERC20 to address
        IERC20(raisingToken).safeTransfer(_to, _amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not admin");
        _;
    }

    modifier onlyActiveIDO() {
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "not ido time"
        );
        _;
    }
}