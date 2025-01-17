// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ICOMM {
    function handleComm(address _fromUser, uint _amount, IERC20 tokenBuy) external;
}
interface IPancakeRouter {
    function getAmountsOut(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}
contract LotterySOW is Ownable {
    IPancakeRouter public pancakeRouter;
    address public immutable BUSD;
    address public immutable WBNB;

    using SafeERC20 for IERC20;
    address public asset2BuyAdress;
    ICOMM public commTreasury;
    mapping(uint => bool) public nonces;
    address[] public top10Winner;
    address[] public top10Player;
    uint public indexTop10Winner;
    uint public indexTop10Player;

    struct Pool {
        uint minTokenAmount; // BUSD
        uint maxTokenAmount; // BUSD
        uint decimal;
        uint referCommission; // decimal 100
        bool isOpen;
    }
    struct Spin {
        uint pid;
        uint number;
        uint amountToken;
        bool result;
        uint resultNumber;
        uint timestamp;
    }
    struct RewardInfo {
        uint pid;
        uint amount;
        uint resultNumber;
    }
    struct User {
        uint totalSpin;
        uint totalWin;
        bool top10Winner;
        bool top10Player;
        uint[] rewards;
        Spin[] spins;
        mapping(uint => RewardInfo) rewardInfo;
    }

    Pool[] public poolsLottery;
    mapping(address => User) public users;
    mapping(address => mapping(uint => uint)) public userSpined; // user => datetime => spined
    mapping(address => uint) public userTotalSpined; // user => spined

    constructor(IPancakeRouter _pancakeRouteAddress, address _WBNBAddress, address _BUSDAddress, ICOMM _commTreasury, address _asset2BuyAdress) {
        pancakeRouter = _pancakeRouteAddress;
        WBNB = _WBNBAddress;
        BUSD = _BUSDAddress;
        asset2BuyAdress = _asset2BuyAdress;
        commTreasury = _commTreasury;
    }
    function pools(uint pid) external view returns(uint minTokenAmount, uint maxTokenAmount, uint decimal, uint referCommission, bool isOpen) {
        Pool memory p = poolsLottery[pid];
        minTokenAmount = busd2Token(asset2BuyAdress, p.minTokenAmount);
        maxTokenAmount = busd2Token(asset2BuyAdress, p.maxTokenAmount);
        decimal = p.decimal;
        referCommission = p.referCommission;
        isOpen = p.isOpen;
    }
    function bnbPrice() public view returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = WBNB;
        amounts = IPancakeRouter(pancakeRouter).getAmountsIn(1 ether, path);
    }

    function tokenPrice(address token) public view returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = BUSD;
        amounts = IPancakeRouter(pancakeRouter).getAmountsIn(1 ether, path);
    }
    function busd2Token(address token, uint busd) public view returns (uint amount){
        uint[] memory amounts = tokenPrice(token);
        amount = amounts[0] * busd / 1 ether;
    }
    function setAsset2BuyAdress(address _asset2BuyAdress) external onlyOwner {
        asset2BuyAdress = _asset2BuyAdress;
    }
    function setTreasury(ICOMM _commTreasury) external onlyOwner {
        commTreasury = _commTreasury;
    }
    function getUserReward(address _user) external view returns(RewardInfo[] memory list, uint[] memory _users) {
        uint length = users[_user].rewards.length;
        list = new RewardInfo[](length);
        for(uint i = 0; i < length; i++) {
            list[i] = users[_user].rewardInfo[users[_user].rewards[i]];
        }
        _users = users[_user].rewards;
    }
    function getReward(address _user) external view returns(RewardInfo[] memory list, uint[] memory _users) {
        uint length = users[_user].rewards.length;
        list = new RewardInfo[](length);
        for(uint i = 0; i < length; i++) {
            list[i] = users[_user].rewardInfo[users[_user].rewards[i]];
        }
        _users = users[_user].rewards;
    }
    function getUserSpins(address _user, uint _limit, uint _skip) external view returns(Spin[] memory list, uint totalItem) {
        totalItem = users[_user].spins.length;
        if(totalItem > 0 && totalItem >= _skip) {
            uint limit = totalItem >= _skip ? totalItem - _skip : 0;

            if(limit > 0) {
                uint limitIndex = limit >= _limit ? limit - _limit : 0;
                uint lengthReturn = _limit <= totalItem - _skip ? _limit : totalItem - _skip;
                list = new Spin[](lengthReturn);
                uint index = limit-1;
                for(uint i = index; i >= limitIndex; i--) {
                    list[index - i] = users[_user].spins[i];
                    if(i == 0) break;
                }
            }
        }
    }
    function getTop10Winner() external view returns(address[]memory) {
        return top10Winner;
    }
    function getTop10Player() external view returns(address[] memory) {
        return top10Player;
    }
    function setTop10Winner() internal {
        if(!users[msg.sender].top10Winner) {
            if(top10Winner.length < 10) {
                top10Winner.push(msg.sender);
                users[msg.sender].top10Winner = true;
            } else {
                if(users[msg.sender].totalWin > users[top10Winner[indexTop10Winner]].totalWin) {
                    users[top10Winner[indexTop10Winner]].top10Winner = false;
                    top10Winner[indexTop10Winner] = msg.sender;
                    users[msg.sender].top10Winner = true;
                    resetIndexWinner();
                }
            }
        }
    }
    function setTop10Player() internal {
        if(!users[msg.sender].top10Player) {
            if(top10Player.length < 10) {
                top10Player.push(msg.sender);
                users[msg.sender].top10Player = true;
            } else {
                if(users[msg.sender].totalSpin > users[top10Player[indexTop10Player]].totalSpin) {
                    users[top10Player[indexTop10Player]].top10Player = false;
                    top10Winner[indexTop10Player] = msg.sender;
                    users[msg.sender].top10Player = true;
                    resetIndexPlayer();
                }
            }
        }
    }
    function resetIndexWinner() internal {
        uint smallest = users[top10Winner[indexTop10Winner]].totalWin;
        for(uint i = 0; i < 10; i++) {
            if(smallest > users[top10Winner[i]].totalWin) {
                smallest = users[top10Winner[i]].totalWin;
                indexTop10Winner = i;
            }
        }
    }
    function resetIndexPlayer() internal {
        uint smallest = users[top10Player[indexTop10Player]].totalSpin;
        for(uint i = 0; i < 10; i++) {
            if(smallest > users[top10Player[i]].totalSpin) {
                smallest = users[top10Player[i]].totalSpin;
                indexTop10Player = i;
            }
        }
    }

    function getDate() public view returns (uint256) {
        return block.timestamp / 1 days;
    }
    function random(uint nonce, uint percentDecimal) public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, nonce, address(this))))%percentDecimal;
    }

    function spins(uint _pid, uint[] memory _nonces, uint[] memory numbers, uint[] memory _amounts) external {
        for(uint i = 0; i < numbers.length; i++) {
            spin(_pid, _nonces[i], numbers[i], _amounts[i]);
        }
    }
    function spin(uint _pid, uint nonce, uint number, uint amount) public {
        require(!nonces[nonce], "Lottery::spin: nonce used");
        Pool storage p = poolsLottery[_pid];
        require(p.isOpen, "Lottery::spin: _pid is not exist");
        require(number < p.decimal, "Lottery::spin: number invalid");
        uint minTokenAmount = busd2Token(asset2BuyAdress, p.minTokenAmount);
        uint maxTokenAmount = busd2Token(asset2BuyAdress, p.maxTokenAmount);
        require(amount >= minTokenAmount && amount < maxTokenAmount, "Lottery::spin: amount invalid");

        uint reward = amount * (p.decimal - p.decimal / 10);
        uint comm = p.referCommission * amount / 100;

        uint256 date = getDate();
        userSpined[_msgSender()][date]++;
        userTotalSpined[_msgSender()]++;

        User storage user = users[_msgSender()];

        user.totalSpin += amount;

        IERC20(asset2BuyAdress).transferFrom(_msgSender(), address(commTreasury), comm);
        IERC20(asset2BuyAdress).transferFrom(_msgSender(), address(this), amount-comm);

        commTreasury.handleComm(_msgSender(), comm, IERC20(asset2BuyAdress));
        setTop10Player();
        uint resultNumber = random(nonce, p.decimal);
        nonces[nonce] = true;
        bool result = resultNumber == number;
        user.spins.push(Spin(_pid, number, amount, result, resultNumber, block.timestamp));
        if(result) {
            IERC20(asset2BuyAdress).transfer(_msgSender(), reward);
            user.totalWin += reward;
            user.rewards.push(block.timestamp);
            user.rewardInfo[block.timestamp] = RewardInfo(_pid, reward, resultNumber);
            setTop10Winner();
        }
    }
    function togglePool(uint _pid, bool _isOpen) public onlyOwner {
        Pool storage p = poolsLottery[_pid];
        require(p.minTokenAmount > 0, "Lottery::togglePool pool is not exist");
        p.isOpen = _isOpen;
    }
    function updateLimitBuyPool(uint _pid, uint _minTokenAmount, uint _maxTokenAmount) public onlyOwner {
        Pool storage p = poolsLottery[_pid];
        require(p.isOpen, "Lottery::updatePool pool is not open");
        p.minTokenAmount = _minTokenAmount;
        p.maxTokenAmount = _maxTokenAmount;
    }
    function updatePool(uint _pid, uint _referCommission) public onlyOwner {
        Pool storage p = poolsLottery[_pid];
        require(p.isOpen, "Lottery::updatePool pool is not open");
        p.referCommission = _referCommission;
    }
    function addPool(uint _minTokenAmount, uint _maxTokenAmount, uint _decimal, uint _referCommission) public onlyOwner {
        require(_minTokenAmount > 0 && _maxTokenAmount > _minTokenAmount, "Lottery::addPool _price invalid");
//        if(_poolReward > 0) IERC20(asset2BuyAdress).safeTransferFrom(_msgSender(), address(this), _poolReward);
        poolsLottery.push(Pool(_minTokenAmount, _maxTokenAmount, _decimal, _referCommission, true));
    }
    function inCaseTokensGetStuck(IERC20 _token) external onlyOwner {

        uint amount = _token.balanceOf(address(this));
        _token.transfer(msg.sender, amount);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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