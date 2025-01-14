// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

interface IUniswapV2Router
{
	function WETH() external view returns (address _WETH);
	function factory() external view returns (address _factory);

	function addLiquidityETH(address _token, uint256 _amountTokenDesired, uint256 _amountTokenMin, uint256 _amountETHMin, address _to, uint256 _deadline) external payable returns (uint256 _amountToken, uint256 _amountETH, uint256 _liquidity);
	function addLiquidity(address _tokenA, address _tokenB, uint256 _amountADesired, uint256 _amountBDesired, uint256 _amountAMin, uint256 _amountBMin, address _to, uint256 _deadline) external returns (uint256 _amountA, uint256 _amountB, uint256 _liquidity);
	function swapExactETHForTokens(uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function swapExactTokensForETH(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external payable;
	function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external;
	function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external;
	function swapETHForExactTokens(uint256 _amountOut, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory _amounts);
	function swapTokensForExactETH(uint256 _amountOut, uint256 _amountInMax, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
	function swapTokensForExactTokens(uint256 _amountOut, uint256 _amountInMax, address[] calldata _path, address _to, uint256 _deadline) external returns (uint256[] memory _amounts);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { IUniswapV2Router } from "./IUniswapV2Router.sol";

contract LevelXSeed is Initializable, ReentrancyGuard
{
	using Address for address payable;
	using SafeERC20 for IERC20;

	struct AccountInfo {
		bool exists; // existence flag
		uint256 amount; // amount of LVLX bought
		uint256 cost; // amount of BUSD paid
	}

	/*
	 10M LVLX @ $.004
	  9M LVLX @ $.005
	  8M LVLX @ $.006
	  7M LVLX @ $.007
	  6M LVLX @ $.008
	 */

	uint256 constant BUY_FEE = 12.5e16; // 12.5%
	uint256 constant BASE_BRACKET = 10_000_000e18; // 10M LVLX
	uint256 constant BRACKET_DECREMENT = 1_000_000e18; // 1M LVLX
	uint256 constant BASE_PRICE = 0.000004e18; // 0.000004 BUSD
	uint256 constant PRICE_INCREMENT = 0.000001e18; // 0.000001 BUSD
	uint256 constant MAX_ROUNDS = 5;

	address public router;
	address public wrappedToken;
	address public paymentToken;
	address public bankroll;
	uint256 public launchTime;
	uint256 public limitPerAccount;

	uint256 public baseBracket;
	uint256 public bracket;
	uint256 public price;
	uint256 public round;
	uint256 public totalSold;
	uint256 public totalReceived;

	address[] public accountIndex;
	mapping(address => AccountInfo) public accountInfo;

	function accountIndexLength() external view returns (uint256 _length)
	{
		return accountIndex.length;
	}

	modifier hasLaunched
	{
		require(block.timestamp >= launchTime);
		_;
	}

	constructor(address _router, address _paymentToken, address _bankroll, uint256 _launchTime, uint256 _limitPerAccount)
	{
		initialize(_router, _paymentToken, _bankroll, _launchTime, _limitPerAccount);
	}

	function initialize(address _router, address _paymentToken, address _bankroll, uint256 _launchTime, uint256 _limitPerAccount) public initializer
	{
		address _wrappedToken = IUniswapV2Router(_router).WETH();
		require(_paymentToken != _wrappedToken, "invalid token");
		router = _router;
		wrappedToken = _wrappedToken;
		paymentToken = _paymentToken;
		bankroll = _bankroll;
		launchTime = _launchTime;
		limitPerAccount = _limitPerAccount;

		baseBracket = BASE_BRACKET;
		bracket = BASE_BRACKET;
		price = BASE_PRICE;
		round = 1;
		totalSold = 0;
		totalReceived = 0;
	}

	function airdrop(address _token, address _from) external
	{
		IERC20(_token).safeTransferFrom(_from, address(this), totalSold);
		for (uint256 _i = 0; _i < accountIndex.length; _i++) {
			address _account = accountIndex[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];
			IERC20(_token).safeTransfer(_account, _accountInfo.amount);
		}
	}

	function _calcCostFromAmount(uint256 _amount) internal returns (uint256 _cost)
	{
		_cost = 0;
		while (round <= MAX_ROUNDS) {
			uint256 _available = bracket - totalSold;
			uint256 _value = _available * price / 1e18;
			if (_available >= _amount) {
				uint256 _c = _amount * price / 1e18;
				totalSold += _amount;
				return _cost + _c;
			}
			_cost += _value;
			_amount -= _available;
			totalSold += _available;
			baseBracket -= BRACKET_DECREMENT;
			bracket += baseBracket;
			price += PRICE_INCREMENT;
			round++;
		}
		return 0;
	}

	function _calcAmountFromCost(uint256 _cost) internal returns (uint256 _amount)
	{
		_amount = 0;
		while (round <= MAX_ROUNDS) {
			uint256 _available = bracket - totalSold;
			uint256 _value = _available * price / 1e18;
			if (_value >= _cost) {
				uint256 _a = _cost * 1e18 / price;
				if (_a > _available) _a = _available;
				totalSold += _a;
				return _amount + _a;
			}
			_cost -= _value;
			_amount += _available;
			totalSold += _available;
			baseBracket -= BRACKET_DECREMENT;
			bracket += baseBracket;
			price += PRICE_INCREMENT;
			round++;
		}
		return 0;
	}

	function buyFromAmount(address _token, bool _directRoute, uint256 _amount, uint256 _maxTokenAmount) external payable nonReentrant hasLaunched returns (uint256 _cost)
	{
		require(_amount > 0, "invalid amount");
		uint256 _netCost = _calcCostFromAmount(_amount);
		require(_netCost != 0, "sold out");
		_cost = _netCost * 1e18 / (1e18 - BUY_FEE) + 1; // applies buy fee
		totalReceived += _cost;
		{
			AccountInfo storage _accountInfo = accountInfo[msg.sender];
			if (!_accountInfo.exists) {
				_accountInfo.exists = true;
				accountIndex.push(msg.sender);
			}
			_accountInfo.amount += _amount;
			_accountInfo.cost += _cost;
			require(_accountInfo.amount <= limitPerAccount, "limit reached");
		}
		uint256 _tokenAmount;
		if (_token == paymentToken) {
			require(msg.value == 0, "invalid value");
			_tokenAmount = _cost;
			require(_tokenAmount <= _maxTokenAmount, "high slippage");
			IERC20(paymentToken).safeTransferFrom(msg.sender, bankroll, _cost);
		} else {
			if (_token == address(0)) {
				require(msg.value == _maxTokenAmount, "invalid value");
				address[] memory _path = new address[](2);
				_path[0] = wrappedToken;
				_path[1] = paymentToken;
				_tokenAmount = IUniswapV2Router(router).swapETHForExactTokens{value: _maxTokenAmount}(_cost, _path, bankroll, block.timestamp)[0];
				uint256 _excessTokenAmount = _maxTokenAmount - _tokenAmount;
				if (_excessTokenAmount > 0) {
					payable(msg.sender).sendValue(_excessTokenAmount);
				}
			} else {
				require(msg.value == 0, "invalid value");
				IERC20(_token).safeTransferFrom(msg.sender, address(this), _maxTokenAmount);
				IERC20(_token).safeApprove(router, _maxTokenAmount);
				address[] memory _path;
				if (_directRoute) {
					_path = new address[](2);
					_path[0] = _token;
					_path[1] = paymentToken;
				} else {
					require(_token != wrappedToken, "not indirect");
					_path = new address[](3);
					_path[0] = _token;
					_path[1] = wrappedToken;
					_path[2] = paymentToken;
				}
				_tokenAmount = IUniswapV2Router(router).swapTokensForExactTokens(_cost, _maxTokenAmount, _path, bankroll, block.timestamp)[0];
				IERC20(_token).safeApprove(router, 0);
				uint256 _excessTokenAmount = _maxTokenAmount - _tokenAmount;
				if (_excessTokenAmount > 0) {
					IERC20(_token).safeTransfer(msg.sender, _excessTokenAmount);
				}
			}
		}
		emit Buy(msg.sender, _amount, _cost);
		return _cost;
	}

	function buyFromCost(address _token, bool _directRoute, uint256 _tokenAmount, uint256 _minAmount) external payable nonReentrant hasLaunched returns (uint256 _amount)
	{
		uint256 _cost;
		if (_token == paymentToken) {
			require(msg.value == 0, "invalid value");
			_cost = _tokenAmount;
			IERC20(paymentToken).safeTransferFrom(msg.sender, bankroll, _cost);
		} else {
			if (_token == address(0)) {
				require(msg.value == _tokenAmount, "invalid value");
				address[] memory _path = new address[](2);
				_path[0] = wrappedToken;
				_path[1] = paymentToken;
				_cost = IUniswapV2Router(router).swapExactETHForTokens{value: _tokenAmount}(0, _path, bankroll, block.timestamp)[_path.length - 1];
			} else {
				require(msg.value == 0, "invalid value");
				IERC20(_token).safeTransferFrom(msg.sender, address(this), _tokenAmount);
				IERC20(_token).safeApprove(router, _tokenAmount);
				address[] memory _path;
				if (_directRoute) {
					_path = new address[](2);
					_path[0] = _token;
					_path[1] = paymentToken;
				} else {
					require(_token != wrappedToken, "not indirect");
					_path = new address[](3);
					_path[0] = _token;
					_path[1] = wrappedToken;
					_path[2] = paymentToken;
				}
				_cost = IUniswapV2Router(router).swapExactTokensForTokens(_tokenAmount, 0, _path, bankroll, block.timestamp)[_path.length - 1];
			}
		}
		uint256 _netCost = _cost * (1e18 - BUY_FEE) / 1e18; // applies buy fee
		require(_netCost > 0, "invalid amount");
		_amount = _calcAmountFromCost(_netCost);
		require(_amount != 0, "sold out");
		require(_amount >= _minAmount, "high slippage");
		totalReceived += _cost;
		{
			AccountInfo storage _accountInfo = accountInfo[msg.sender];
			if (!_accountInfo.exists) {
				_accountInfo.exists = true;
				accountIndex.push(msg.sender);
			}
			_accountInfo.amount += _amount;
			_accountInfo.cost += _cost;
			require(_accountInfo.amount <= limitPerAccount, "limit reached");
		}
		emit Buy(msg.sender, _amount, _cost);
		return _amount;
	}

	receive() external payable {}

	event Buy(address indexed _account, uint256 _amount, uint256 _cost);
}