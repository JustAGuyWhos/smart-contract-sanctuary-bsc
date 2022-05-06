//SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interfaces/IERC20Basic.sol";
import "./interfaces/IUniswapBasic.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/**
 * @title A contract that allows multiple payments in one transaction
 * @author Lucas Marc
 */
contract Payroll is Ownable, Initializable {
    IUniswapBasic public swapRouter;
    bool public isSwapV2;

    struct Payment {
        address token;
        uint256 totalAmountToPay;
        address[] receivers;
        uint256[] amountsToTransfer;
    }

    struct Swap {
        address token;
        uint256 amountOut;
        uint256 amountInMax;
        uint24 poolFee;
    }

    function initialize(address _swapRouter, bool _isSwapV2) public initializer {
        isSwapV2 = _isSwapV2;
        swapRouter = IUniswapBasic(_swapRouter);
    }

    /**
     * Set the SwapRouter and the version to be used
     * @param _swapRouter Router address to execute swaps
     */
    function setSwapRouter(address _swapRouter, bool _isSwapV2) public onlyOwner {
        isSwapV2 = _isSwapV2;
        swapRouter = IUniswapBasic(_swapRouter);
    }

    event BatchPaymentFinished(address[] _receivers, uint256[] _amountsToTransfer);

    event SwapFinished(address _tokenIn, address _tokenOut, uint256 _amountReceived);

    /**
     * Perform the swap, the transfer and finally the payment to the given addresses
     * @param _erc20TokenOrigin ERC20 token address to swap for another
     * @param _totalAmountToSpend Total amount of erc20TokenOrigin to spend in swaps and payments.
     * You must know the total amount of erc20TokenOrigin to spend on swaps and also to spend on payments.
     * @param _deadline The unix timestamp after a swap will fail
     * @param _swaps The array of the Swaps data
     * @param _payments The array of the Payment data
     * @notice Currently the function only works with ERC20 tokens
     */
    function performSwapAndPayment(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSpend,
        uint32 _deadline,
        Swap[] calldata _swaps,
        Payment[] calldata _payments
    ) external {
        if (_swaps.length > 0) {
            performSwap(_erc20TokenOrigin, _totalAmountToSpend, _deadline, _swaps);
        }

        transferFromWallet(_payments);
        performMultiPayment(_payments);

        // returns the leftover of erc20TokenOrigin if it was not used in payments
        returnLeftover(_erc20TokenOrigin);
    }

    /**
     * Transfer the totalAmountToPay minus the current balance of the contract
     * for each token from the msg.sender to this contract
     * msg.sender must approve this contract for each token
     * @param _payments The array of the Payment data
     * @notice Currently the function only works with ERC20 tokens
     */
    function transferFromWallet(Payment[] calldata _payments) internal {
        uint256 currentBalance;
        for (uint256 i = 0; i < _payments.length; i++) {
            currentBalance = IERC20Basic(_payments[i].token).balanceOf(address(this));
            if (_payments[i].totalAmountToPay > currentBalance) {
                TransferHelper.safeTransferFrom(
                    _payments[i].token,
                    msg.sender,
                    address(this),
                    _payments[i].totalAmountToPay - currentBalance
                );
            }
        }
    }

    /**
     * Perform the swap to the given token addresses and amounts
     * @param _erc20TokenOrigin ERC20 token address to swap for another
     * @param _totalAmountToSpend Total amount of erc20TokenOrigin to spend in swaps
     * @param _deadline The unix timestamp after a swap will fail
     * @param _swaps The array of the Swaps data
     * @notice Currently the function only works with ERC20 tokens
     */
    function performSwap(
        address _erc20TokenOrigin,
        uint256 _totalAmountToSpend,
        uint32 _deadline,
        Swap[] calldata _swaps
    ) internal {
        // transfer the totalAmountToSpend of erc20TokenOrigin from the msg.sender to this contract
        // msg.sender must approve this contract for erc20TokenOrigin
        TransferHelper.safeTransferFrom(_erc20TokenOrigin, msg.sender, address(this), _totalAmountToSpend);

        // approves the swapRouter to spend totalAmountToSpend of erc20TokenOrigin
        TransferHelper.safeApprove(_erc20TokenOrigin, address(swapRouter), _totalAmountToSpend);

        if (isSwapV2) {
            for (uint256 i = 0; i < _swaps.length; i++) {
                swapTokensForExactTokens(
                    _erc20TokenOrigin,
                    _swaps[i].token,
                    _swaps[i].amountOut,
                    _swaps[i].amountInMax,
                    _deadline
                );
            }
        } else {
            for (uint256 i = 0; i < _swaps.length; i++) {
                swapExactOutputSingle(
                    _erc20TokenOrigin,
                    _swaps[i].token,
                    _swaps[i].poolFee,
                    _swaps[i].amountOut,
                    _swaps[i].amountInMax,
                    _deadline
                );
            }
        }

        // removes the approval to swapRouter
        TransferHelper.safeApprove(_erc20TokenOrigin, address(swapRouter), 0);
    }

    /**
     * Perform ERC20 tokens swap using UniSwap v2 protocol
     * @param _tokenIn ERC20 token address to swap for another
     * @param _tokenOut ERC20 token address to receive
     * @param _amountOut Exact amount of tokenOut to receive
     * @param _amountInMax Max amount of tokenIn to pay
     * @param _deadline The unix timestamp after a swap will fail
     * @notice Currently the function only works with ERC20 tokens
     * @notice Currently the function only works with single pools tokenIn/tokenOut
     */
    function swapTokensForExactTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOut,
        uint256 _amountInMax,
        uint32 _deadline
    ) internal {
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        // return the amount spend of tokenIn
        uint256 amountIn = swapRouter.swapTokensForExactTokens(
            _amountOut,
            _amountInMax,
            path,
            address(this),
            _deadline
        )[0];

        emit SwapFinished(_tokenIn, _tokenOut, amountIn);
    }

    /**
     * Perform ERC20 tokens swap using UniSwap v3 protocol
     * @param _tokenIn ERC20 token address to swap for another
     * @param _tokenOut ERC20 token address to receive
     * @param _poolFee Pool fee tokenIn/tokenOut
     * @param _amountOut Exact amount of tokenOut to receive
     * @param _amountInMax Max amount of tokenIn to pay
     * @param _deadline The unix timestamp after a swap will fail
     * @notice Currently the function only works with ERC20 tokens
     * @notice Currently the function only works with single pools tokenIn/tokenOut
     */
    function swapExactOutputSingle(
        address _tokenIn,
        address _tokenOut,
        uint24 _poolFee,
        uint256 _amountOut,
        uint256 _amountInMax,
        uint32 _deadline
    ) internal {

        // return the amount spend of tokenIn
        uint256 amountIn = swapRouter.exactOutputSingle(
            IUniswapBasic.ExactOutputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: _poolFee,
                recipient: address(this),
                deadline: _deadline,
                amountOut: _amountOut,
                amountInMaximum: _amountInMax,
                sqrtPriceLimitX96: 0
            })
        );

        emit SwapFinished(_tokenIn, _tokenOut, amountIn);
    }

    /**
     * Perform the payments to the given addresses and amounts
     * @param _payments The array of the Payment data
     */
    function performMultiPayment(Payment[] calldata _payments) internal {
        for (uint256 i = 0; i < _payments.length; i++) {
            performPayment(_payments[i].token, _payments[i].receivers, _payments[i].amountsToTransfer);

            // return the leftover for each token after perform all payments
            returnLeftover(_payments[i].token);
        }
    }

    /**
     * Performs the payment to the given addresses
     * @param _erc20TokenAddress The address of the ERC20 token to transfer
     * @param _receivers The array of payment receivers
     * @param _amountsToTransfer The array of payments' amounts to perform. The amount will be transfered to the address on _receivers with the same index.
     * @notice Currently the function only works with only one ERC20 token
     */
    function performPayment(
        address _erc20TokenAddress,
        address[] calldata _receivers,
        uint256[] calldata _amountsToTransfer
    ) internal {
        require(_amountsToTransfer.length == _receivers.length, "Arrays must have same length");

        for (uint256 i = 0; i < _receivers.length; i++) {
            require(_receivers[i] != address(0), "Cannot send to a 0 address");
            TransferHelper.safeTransfer(_erc20TokenAddress, _receivers[i], _amountsToTransfer[i]);
        }
        emit BatchPaymentFinished(_receivers, _amountsToTransfer);
    }

    /**
     * Return all balance of an ERC20 to the msg.sender
     * @param _erc20TokenAddress The address of the ERC20 token to transfer
     * @notice Currently the function only works with only one ERC20 token
     */
    function returnLeftover(address _erc20TokenAddress) internal {
        uint256 accountBalance = IERC20Basic(_erc20TokenAddress).balanceOf(address(this));

        if (accountBalance > 0) {
            TransferHelper.safeTransfer(_erc20TokenAddress, msg.sender, accountBalance);
        }
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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

//SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
interface IERC20Basic {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

//SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

/**
 * @title UniswapBasic
 * @dev Simpler version of Uniswap v2 and v3 protocol interface
 */
interface IUniswapBasic {
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
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