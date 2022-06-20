/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.9;


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
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

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)
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

// 
interface IOraclePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IOracleTwap {
    function consultAveragePrice(
        address _pair,
        address _token,
        uint256 _amountIn
    ) external view returns (uint256 _amountOut);

    function updateAveragePrice(address _pair) external;
}

contract HmineSacrifice is Ownable, ReentrancyGuard {
    using Address for address payable;
    using SafeERC20 for IERC20;

    struct Sacrifice {
        bool isEnabled;
        bool isStable;
        address oracleAddress;
    }

    struct User {
        string nickname;
        address user;
        uint256 amount;
    }

    mapping(address => Sacrifice) public sacrifices;
    uint256 public startRoundOne = 0;
    uint256 public startRoundTwo = 0;
    uint256 constant roundPeriod = 48 hours;
    uint256 public hminePerRound = 50000e18; // Hmine per round is 50K
    uint256 public roundOneHmine;
    uint256 public roundTwoHmine;
    uint256 constant initPrice = 600; // The price is dvisible by 100.  So in this case 600 is actually $6.00
    uint256 public index = 0;
    mapping(address => uint256) userIndex;
    mapping(uint256 => User) public users;
    address payable public immutable sacrificesTo;
    address public immutable wbnb;
    address public twap;
    uint256 public twapMax = 30;

    constructor(
        address payable _sacTo,
        address _wbnb,
        address _bnbLP,
        address _twap
    ) {
        sacrificesTo = _sacTo;
        wbnb = _wbnb;
        twap = _twap;
        _addSac(_wbnb, false, _bnbLP);
    }

    function getSacrificeInfo(address _token)
        external
        view
        returns (Sacrifice memory)
    {
        return sacrifices[_token];
    }

    // Returns the users data by address lookup.
    function getUserByAddress(address _user)
        external
        view
        returns (User memory)
    {
        uint256 _index = userIndex[_user];
        return users[_index];
    }

    // Returns the users data by Index.
    function getUserByIndex(uint256 _index)
        external
        view
        returns (User memory)
    {
        return users[_index];
    }

    // Returns the current round.
    function getCurrentRound() external view returns (uint16) {
        return _getCurrentRound();
    }

    function _getCurrentRound() internal view returns (uint16) {
        if (startRoundTwo != 0 && block.timestamp <= startRoundTwo + roundPeriod && block.timestamp > startRoundTwo) return 2;
        if (startRoundOne != 0 && block.timestamp <= startRoundOne + roundPeriod && block.timestamp >= startRoundOne) return 1;
        return 0;
    }

    function updateNickname(string memory nickname) external {
        uint256 _index = userIndex[msg.sender];
        require(index != 0, "User does not exist");
        users[_index].nickname = nickname;
    }

    function addToRoundTotal(uint256 _amount) internal {
        if(_getCurrentRound() == 2){
            roundTwoHmine += _amount;
        }
        else {
            roundOneHmine += _amount;
        }
    }

    function sacrificeERC20(address _token, uint256 _amount)
        external
        nonReentrant
    {
        require(hasSacrifice(_token), "Sacrifice not supported");
        require(_amount > 0, "Amount cannot be less than zero");

        uint256 price = initPrice;
        if (
            _getCurrentRound() == 2
        ) {
            price = initPrice + 50;
        }

        uint256 _hmineAmount;
        if (sacrifices[_token].isStable) {
            _hmineAmount = (_amount * 100) / price;
        } else {
            _hmineAmount =
                (getAmountInStable(
                    _token,
                    sacrifices[_token].oracleAddress,
                    _amount
                ) * 100) /
                price;
        }

        require(validateRound(_hmineAmount), "Round ended or not started yet");

        uint256 _index = assignUserIndex(msg.sender);
        users[_index].user = msg.sender;
        users[_index].amount += _hmineAmount;
        addToRoundTotal(_hmineAmount);
        IERC20(_token).safeTransferFrom(msg.sender, sacrificesTo, _amount);

        emit UserSacrifice(msg.sender, _token, _amount, _hmineAmount);
    }

    function sacrificeBNB() external payable nonReentrant {
        uint256 _amount = msg.value;
        require(hasSacrifice(wbnb), "Sacrifice not supported");
        require(_amount > 0, "Amount cannot be less than zero");

        uint256 price = initPrice;
        if (
            _getCurrentRound() == 2
        ) {
            price = initPrice + 50;
        }

        uint256 _hmineAmount = (getAmountInStable(
            wbnb,
            sacrifices[wbnb].oracleAddress,
            _amount
        ) * 100) / price;

        require(validateRound(_hmineAmount), "Round ended or not started yet");

        uint256 _index = assignUserIndex(msg.sender);
        users[_index].user = msg.sender;
        users[_index].amount += _hmineAmount;
        addToRoundTotal(_hmineAmount);
        sacrificesTo.sendValue(_amount);

        emit UserSacrifice(msg.sender, wbnb, _amount, _hmineAmount);
    }

    function updateRoundMax(uint256 _max) external onlyOwner {
        require(startRoundOne == 0 && startRoundTwo == 0, "Cannot update after round started");
        hminePerRound = _max;
    }

    function updateTwap(address _twap) external onlyOwner {
        require(address(0) != _twap, "Cannot be contract.");
        twap = _twap;
    }

    function updateTwapMax(uint256 _twapMax) external onlyOwner {
        require(_twapMax > 0, "Cannot be less than zero");
        twapMax = _twapMax;
    }

    function startFirstRound(uint256 _time) external onlyOwner {
        require(
            startRoundOne > block.timestamp || startRoundOne == 0,
            "Rounds were already started"
        );
        startRoundOne = _time;
    }

    function startSecondRound(uint256 _time) external onlyOwner {
        require(_time > startRoundOne + roundPeriod && startRoundOne != 0, "First round not started or ended");
        require(
            startRoundTwo > block.timestamp || startRoundTwo == 0,
            "Rounds were already started"
        );
        startRoundTwo = _time;
    }

    function addSacToken(
        address _token,
        bool _isStable,
        address _lpAddress
    ) external onlyOwner {
        require(address(0) != _token, "Cannot be contract.");
        require(!hasSacrifice(_token), "Sacrifice is already supported");

        if (address(0) != _lpAddress) {
            address _token0 = IOraclePair(_lpAddress).token0();
            address _token1 = IOraclePair(_lpAddress).token1();
            require(
                (_token == _token0 || _token == _token1) &&
                    IERC20Metadata(_token0).decimals() == 18 &&
                    IERC20Metadata(_token1).decimals() == 18,
                "Invalid lp"
            );
        } else {
            require(IERC20Metadata(_token).decimals() == 18, "Invalid decimal");
        }

        _addSac(_token, _isStable, _lpAddress);
    }

    function updateSacrifice(
        address _token,
        bool _isStable,
        address _lpAddress
    ) public onlyOwner {
        require(hasSacrifice(_token), "Sacrifice not supported");
        address _token0 = IOraclePair(_lpAddress).token0();
        address _token1 = IOraclePair(_lpAddress).token1();
        require(
            (_token == _token0 || _token == _token1) &&
                IERC20Metadata(_token0).decimals() == 18 &&
                IERC20Metadata(_token1).decimals() == 18,
            "Invalid lp"
        );
        sacrifices[_token].isStable = _isStable;
        sacrifices[_token].oracleAddress = _lpAddress;
    }

    function removeSacrifice(address _token) external onlyOwner {
        require(hasSacrifice(_token), "Sacrifice not supported");
        delete sacrifices[_token];
    }

    // Checks if token is a supported asset to sacrifice.
    function hasSacrifice(address _token) internal view returns (bool) {
        return sacrifices[_token].isEnabled;
    }

    function _addSac(
        address _token,
        bool _isStable,
        address _lpAddress
    ) internal {
        sacrifices[_token] = Sacrifice(true, _isStable, _lpAddress);
    }

    // Takes in a user address and finds an existing index that is corelated to the user.
    // If index not found (ZERO) then it assigns an index to the user.
    function assignUserIndex(address _user) internal returns (uint256) {
        if (userIndex[_user] == 0) userIndex[_user] = ++index;
        return userIndex[_user];
    }

    // If token is not a stable token, use this to find the price for the token.
    // This uses an active LP approach.
    function getAmountInStable(
        address _token,
        address _lp,
        uint256 _amount
    ) internal returns (uint256 _price) {
        IOraclePair LP = IOraclePair(_lp);
        (uint256 reserve0, uint256 reserve1, ) = LP.getReserves();
        address token0 = LP.token0();
        if (token0 == _token) {
            _price = (reserve1 * _amount) / reserve0;
        } else {
            _price = (reserve0 * _amount) / reserve1;
        }

        // twap protection
        IOracleTwap(twap).updateAveragePrice(_lp);
        uint256 twapPrice = IOracleTwap(twap).consultAveragePrice(
            _lp,
            _token,
            _amount
        );
        require(
            _price < (twapPrice * (1000 + twapMax)) / 1000,
            "TWAP Price Error"
        );
    }

    /* Check to make sure that conditions are met for the transaction to go through.
     ** Cannot start sacrifice unless startTime has been specified.
     ** Cannot sacrifice for anymore if 50K HMINE met before round 1 ends.
     ** Cannot sacrifice if 100K HMINE met or round2 ends.
     */
    function validateRound(uint256 _hmineAmount) internal view returns (bool) {
        // Rounds have not started yet or have already ended.
        if (_getCurrentRound() == 0) return false;

        //  Round one started but not ended yet
        if (
            _getCurrentRound() == 1
        ) {
            if(roundOneHmine + _hmineAmount > hminePerRound) return false;
        }

        // Round two started but not ended
        if (
            _getCurrentRound() == 2
        ) {
            if(roundTwoHmine + _hmineAmount > hminePerRound) return false;
        }

        return true;
    }

    event UserSacrifice(
        address indexed _user,
        address indexed _token,
        uint256 _amount,
        uint256 _hmineAmount
    );
}