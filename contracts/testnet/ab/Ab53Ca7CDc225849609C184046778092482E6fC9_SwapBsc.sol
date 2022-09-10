// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@zetachain/contracts/packages/protocol-contracts/contracts/ZetaInteractor.sol";
import "@zetachain/contracts/packages/protocol-contracts/contracts/interfaces/ZetaInterfaces.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

import "./SwapErrors.sol";

/**
 * XC Swap Goerli -> Mumbai (Uniswap V3 to Uniswap V3)
 */
contract SwapBsc is ZetaInteractor, ZetaReceiver, SwapErrors, Pausable {
    bytes32 private constant SWAP_MESSAGE = keccak256("XC_SWAP");
    uint16 private constant MAX_DEADLINE = 180; // Max time a swap can take in seconds
    address public immutable iZetaToken; // ZETA token address
    address public immutable WETH;
    uint16 private sProtocolFee = 100; // 1% in basis points (parts per 10,000)
    uint256 MAX_INT = 2**256 - 1;

    IUniswapV2Router02 public immutable swapRouter;
    uint24 public constant poolFee = 500;

    // Events
    event FirstLegSuccess(
        address sourceTxOrigin,
        address fromToken,
        uint256 fromTokenAmount,
        address toToken,
        uint256 toTokenFinalAmount,
        address receiverAddress,
        uint256 protocolFee
    );
    event SecondLegSuccess(
        address sourceTxOrigin,
        address fromToken,
        uint256 fromTokenAmount,
        address toToken,
        uint256 toTokenFinalAmount,
        address receiverAddress
    );
    event RevertedSwap(
        address sourceTxOrigin,
        address fromToken,
        uint256 fromTokenAmount,
        uint256 fromTokenReturnedAmount
    );

    // Input arguments
    /* TODO: Add fromToken param */
    struct XcSwapArgs {
        bytes receiverAddress;
        uint256 fromTokenAmount;
        address toToken;
        bool isToTokenEth;
        /**
         * @dev The minimum amount of tokens that receiverAddress should get,
         * if it's not reached, the transaction will revert on the destination chain
         */
        uint256 toTokenMinAmount;
        uint256 toChainId;
        uint256 toChainGasLimit;
    }

    struct XcMessage {
        bytes32 messageType;
        address sourceTxOrigin;
        address fromToken;
        uint256 fromTokenAmount;
        address toToken;
        bool isToTokenEth;
        uint256 toTokenMinAmount;
        bytes receiverAddressEncoded;
    }

    constructor(
        address _zetaConnector,
        address _zetaToken,
        address _swapRouter,
        address _WETH
    ) ZetaInteractor(_zetaConnector) {
        iZetaToken = _zetaToken;
        swapRouter = IUniswapV2Router02(_swapRouter);
        WETH = _WETH;

        /* Approve connector for ZETA token */
        TransferHelper.safeApprove(_zetaToken, address(_zetaConnector), MAX_INT);

        /* Approve the router to spend ZETA token */
        TransferHelper.safeApprove(_zetaToken, address(_swapRouter), MAX_INT);
    }

    /// @dev Allows this contract to receive ether.
    receive() external payable {}

    /** For simplicity only eth to tokens is implemented. Function for tokens to tokens:
     * https://github.com/zeta-chain/zetachain/blob/main/packages/example-contracts/contracts/multi-chain-swap/MultiChainSwap.base.sol#L129
     */
    function swapETHForTokensCrossChain(XcSwapArgs calldata args) external payable {
        if (!_isValidChainId(args.toChainId)) revert InvalidDestinationChainId();

        if (msg.value == 0) revert ValueShouldBeGreaterThanZero();

        // Create swap params
        uint256 zetaValueAndGas;
        {
            address[] memory path = new address[](2);
            path[0] = WETH;
            path[1] = iZetaToken;

            uint256[] memory amounts = swapRouter.swapExactETHForTokens{value: msg.value}(
                0, /// @dev Output can't be validated here, it's validated after the next swap
                path,
                address(this),
                block.timestamp + MAX_DEADLINE
            );

            zetaValueAndGas = amounts[path.length - 1];
        }

        if (zetaValueAndGas == 0) revert ErrorSwappingTokens();

        uint256 protocolFee = (zetaValueAndGas * sProtocolFee) / 10000;
        zetaValueAndGas -= protocolFee; // TODO: takes fee of (value + gas) - should just be on value

        connector.send(
            ZetaInterfaces.SendInput({
                destinationChainId: args.toChainId,
                destinationAddress: interactorsByChainId[args.toChainId],
                destinationGasLimit: args.toChainGasLimit,
                message: abi.encode(
                    XcMessage({
                        messageType: SWAP_MESSAGE,
                        sourceTxOrigin: msg.sender,
                        fromToken: WETH, // Needs to be parameterized
                        toToken: args.toToken,
                        isToTokenEth: args.isToTokenEth,
                        receiverAddressEncoded: args.receiverAddress,
                        toTokenMinAmount: args.toTokenMinAmount,
                        fromTokenAmount: args.fromTokenAmount
                    })
                ),
                zetaValueAndGas: zetaValueAndGas,
                zetaParams: abi.encode("")
            })
        );

        emit FirstLegSuccess(
            msg.sender,
            iZetaToken,
            args.fromTokenAmount,
            args.toToken,
            zetaValueAndGas,
            address(uint160(bytes20(args.receiverAddress))),
            protocolFee
        );
    }

    function onZetaMessage(ZetaInterfaces.ZetaMessage calldata rawZetaMessage)
        external
        override
        isValidMessageCall(rawZetaMessage)
    {
        XcMessage memory xcMessage = abi.decode(rawZetaMessage.message, (XcMessage));

        if (xcMessage.messageType != SWAP_MESSAGE) revert InvalidMessageType();

        address receiverAddress = address(uint160(bytes20(xcMessage.receiverAddressEncoded)));

        uint256 outTokenFinalAmount;
        if (xcMessage.toToken == iZetaToken) {
            if (rawZetaMessage.zetaValue < xcMessage.toTokenMinAmount)
                revert InsufficientOutToken();

            bool success = IERC20(iZetaToken).transfer(receiverAddress, rawZetaMessage.zetaValue);
            if (!success) revert ErrorTransferringTokens(iZetaToken);

            outTokenFinalAmount = rawZetaMessage.zetaValue;
        } else {
            /**
             * @dev If the out token is not Zeta, get it using Uniswap
             */

            address[] memory path;
            if (xcMessage.toToken == WETH || xcMessage.isToTokenEth) {
                path = new address[](2);
                path[0] = iZetaToken;
                path[1] = WETH;
            } else {
                path = new address[](3);
                path[0] = iZetaToken;
                path[1] = WETH;
                path[2] = xcMessage.toToken;
            }

            uint256[] memory amounts;
            if (xcMessage.isToTokenEth) {
                amounts = swapRouter.swapExactTokensForETH(
                    rawZetaMessage.zetaValue,
                    xcMessage.toTokenMinAmount,
                    path,
                    receiverAddress,
                    block.timestamp + MAX_DEADLINE
                );
            } else {
                amounts = swapRouter.swapExactTokensForTokens(
                    rawZetaMessage.zetaValue,
                    xcMessage.toTokenMinAmount,
                    path,
                    receiverAddress,
                    block.timestamp + MAX_DEADLINE
                );
            }

            outTokenFinalAmount = amounts[amounts.length - 1];
            if (outTokenFinalAmount == 0) revert ErrorSwappingTokens();
            if (outTokenFinalAmount < xcMessage.toTokenMinAmount) revert InsufficientOutToken();
        }

        emit SecondLegSuccess(
            xcMessage.sourceTxOrigin,
            xcMessage.fromToken,
            xcMessage.fromTokenAmount,
            xcMessage.toToken,
            outTokenFinalAmount,
            receiverAddress
        );
    }

    function onZetaRevert(ZetaInterfaces.ZetaRevert calldata rawZetaRevert)
        external
        override
        isValidRevertCall(rawZetaRevert)
    {
        XcMessage memory xcMessage = abi.decode(rawZetaRevert.message, (XcMessage));

        if (xcMessage.messageType != SWAP_MESSAGE) revert InvalidMessageType();

        address receiverAddress = address(uint160(bytes20(xcMessage.receiverAddressEncoded)));

        uint256 inputTokenReturnedAmount;
        if (xcMessage.fromToken == iZetaToken) {
            bool success1 = IERC20(iZetaToken).approve(
                address(this),
                rawZetaRevert.remainingZetaValue
            );
            bool success2 = IERC20(iZetaToken).transferFrom(
                address(this),
                receiverAddress,
                rawZetaRevert.remainingZetaValue
            );
            if (!success1 || !success2) revert ErrorTransferringTokens(iZetaToken);
            inputTokenReturnedAmount = rawZetaRevert.remainingZetaValue;
        } else {
            /**
             * @dev If the source input token is not Zeta, trade it using Uniswap
             */
            {
                bool success = IERC20(iZetaToken).approve(
                    address(swapRouter),
                    rawZetaRevert.remainingZetaValue
                );
                if (!success) revert ErrorTransferringTokens(iZetaToken);
            }

            address[] memory path;
            if (xcMessage.fromToken == WETH) {
                path = new address[](2);
                path[0] = iZetaToken;
                path[1] = WETH;
            } else {
                path = new address[](3);
                path[0] = iZetaToken;
                path[1] = WETH;
                path[2] = xcMessage.fromToken;
            }
            {
                uint256[] memory amounts;

                if (xcMessage.fromToken == WETH) {
                    amounts = swapRouter.swapExactTokensForETH(
                        rawZetaRevert.remainingZetaValue,
                        0, /// @dev Any output is fine, otherwise the value will be stuck in the contract
                        path,
                        receiverAddress,
                        block.timestamp + MAX_DEADLINE
                    );
                } else {
                    amounts = swapRouter.swapExactTokensForTokens(
                        rawZetaRevert.remainingZetaValue,
                        0, /// @dev Any output is fine, otherwise the value will be stuck in the contract
                        path,
                        receiverAddress,
                        block.timestamp + MAX_DEADLINE
                    );
                }
                inputTokenReturnedAmount = amounts[amounts.length - 1];
            }
        }

        emit RevertedSwap(
            xcMessage.sourceTxOrigin,
            xcMessage.fromToken,
            xcMessage.fromTokenAmount,
            inputTokenReturnedAmount
        );
    }

    function setProtocolFee(uint16 _protocolFee) public onlyOwner {
        sProtocolFee = _protocolFee;
    }

    function withdrawNativeToken() external onlyOwner {
        require(payable(owner()).send(address(this).balance));
    }

    function withdrawZeta() external onlyOwner {
        IERC20(iZetaToken).transfer(owner(), IERC20(iZetaToken).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface SwapErrors {
    error ErrorTransferringTokens(address token);

    error ErrorTransferringEther();

    error ErrorApprovingTokens(address token);

    error InvalidMessageType();

    error InvalidCallTarget();

    error InvalidCallData();

    error InvalidTokenAddress();

    error BuyZetaFailed();

    error SellZetaFailed();

    error NotImplemented();

    error ValueShouldBeGreaterThanZero();

    error OutTokenInvariant();

    error ErrorSwappingTokens();

    error InsufficientOutToken();
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ZetaInterfaces.sol";
import "./interfaces/ZetaInteractorErrors.sol";

abstract contract ZetaInteractor is Ownable, ZetaInteractorErrors {
    bytes32 constant ZERO_BYTES = keccak256(new bytes(0));
    uint256 internal immutable currentChainId;
    ZetaConnector public immutable connector;

    /**
     * @dev Maps a chain id to its corresponding address of the MultiChainSwap contract
     * The address is expressed in bytes to allow non-EVM chains
     * This mapping is useful, mainly, for two reasons:
     *  - Given a chain id, the contract is able to route a transaction to its corresponding address
     *  - To check that the messages (onZetaMessage, onZetaRevert) come from a trusted source
     */
    mapping(uint256 => bytes) public interactorsByChainId;

    modifier isValidMessageCall(ZetaInterfaces.ZetaMessage calldata zetaMessage) {
        _isValidCaller();
        if (keccak256(zetaMessage.zetaTxSenderAddress) != keccak256(interactorsByChainId[zetaMessage.sourceChainId]))
            revert InvalidZetaMessageCall();
        _;
    }

    modifier isValidRevertCall(ZetaInterfaces.ZetaRevert calldata zetaRevert) {
        _isValidCaller();
        if (zetaRevert.zetaTxSenderAddress != address(this)) revert InvalidZetaRevertCall();
        if (zetaRevert.sourceChainId != currentChainId) revert InvalidZetaRevertCall();
        _;
    }

    constructor(address zetaConnectorAddress) {
        currentChainId = block.chainid;
        connector = ZetaConnector(zetaConnectorAddress);
    }

    function _isValidCaller() private view {
        if (msg.sender != address(connector)) revert InvalidCaller(msg.sender);
    }

    /**
     * @dev Useful for contracts that inherit from this one
     */
    function _isValidChainId(uint256 chainId) internal view returns (bool) {
        return (keccak256(interactorsByChainId[chainId]) != ZERO_BYTES);
    }

    function setInteractorByChainId(uint256 destinationChainId, bytes calldata contractAddress) external onlyOwner {
        interactorsByChainId[destinationChainId] = contractAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface ZetaInterfaces {
    /**
     * @dev Use SendInput to interact with the Connector: connector.send(SendInput)
     */
    struct SendInput {
        /// @dev Chain id of the destination chain. More about chain ids https://docs.zetachain.com/learn/glossary#chain-id
        uint256 destinationChainId;
        /// @dev Address receiving the message on the destination chain (expressed in bytes since it can be non-EVM)
        bytes destinationAddress;
        /// @dev Gas limit for the destination chain's transaction
        uint256 destinationGasLimit;
        /// @dev An encoded, arbitrary message to be parsed by the destination contract
        bytes message;
        /// @dev ZETA to be sent cross-chain + ZetaChain gas fees + destination chain gas fees (expressed in ZETA)
        uint256 zetaValueAndGas;
        /// @dev Optional parameters for the ZetaChain protocol
        bytes zetaParams;
    }

    /**
     * @dev Our Connector calls onZetaMessage with this struct as argument
     */
    struct ZetaMessage {
        bytes zetaTxSenderAddress;
        uint256 sourceChainId;
        address destinationAddress;
        /// @dev Remaining ZETA from zetaValueAndGas after subtracting ZetaChain gas fees and destination gas fees
        uint256 zetaValue;
        bytes message;
    }

    /**
     * @dev Our Connector calls onZetaRevert with this struct as argument
     */
    struct ZetaRevert {
        address zetaTxSenderAddress;
        uint256 sourceChainId;
        bytes destinationAddress;
        uint256 destinationChainId;
        /// @dev Equals to: zetaValueAndGas - ZetaChain gas fees - destination chain gas fees - source chain revert tx gas fees
        uint256 remainingZetaValue;
        bytes message;
    }
}

interface ZetaConnector {
    /**
     * @dev Sending value and data cross-chain is as easy as calling connector.send(SendInput)
     */
    function send(ZetaInterfaces.SendInput calldata input) external;
}

interface ZetaReceiver {
    /**
     * @dev onZetaMessage is called when a cross-chain message reaches a contract
     */
    function onZetaMessage(ZetaInterfaces.ZetaMessage calldata zetaMessage) external;

    /**
     * @dev onZetaRevert is called when a cross-chain message reverts.
     * It's useful to rollback to the original state
     */
    function onZetaRevert(ZetaInterfaces.ZetaRevert calldata zetaRevert) external;
}

/**
 * @dev ZetaTokenConsumer makes it easier to handle the following situations:
 *   - Getting Zeta using native coin (to pay for destination gas while using `connector.send`)
 *   - Getting Zeta using a token (to pay for destination gas while using `connector.send`)
 *   - Getting native coin using Zeta (to return unused destination gas when `onZetaRevert` is executed)
 *   - Getting a token using Zeta (to return unused destination gas when `onZetaRevert` is executed)
 * @dev The interface can be implemented using different strategies, like UniswapV2, UniswapV3, etc
 */
interface ZetaTokenConsumer {
    event EthExchangedForZeta(uint256 amountIn, uint256 amountOut);
    event TokenExchangedForZeta(address token, uint256 amountIn, uint256 amountOut);
    event ZetaExchangedForEth(uint256 amountIn, uint256 amountOut);
    event ZetaExchangedForToken(address token, uint256 amountIn, uint256 amountOut);

    function getZetaFromEth(address destinationAddress, uint256 minAmountOut) external payable returns (uint256);

    function getZetaFromToken(
        address destinationAddress,
        uint256 minAmountOut,
        address inputToken,
        uint256 inputTokenAmount
    ) external returns (uint256);

    function getEthFromZeta(
        address destinationAddress,
        uint256 minAmountOut,
        uint256 zetaTokenAmount
    ) external returns (uint256);

    function getTokenFromZeta(
        address destinationAddress,
        uint256 minAmountOut,
        address outputToken,
        uint256 zetaTokenAmount
    ) external returns (uint256);
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
pragma solidity 0.8.7;

interface ZetaInteractorErrors {
    error InvalidDestinationChainId();

    error InvalidCaller(address caller);

    error InvalidZetaMessageCall();

    error InvalidZetaRevertCall();
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