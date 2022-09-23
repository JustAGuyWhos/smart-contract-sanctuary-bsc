// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/TransferHelper.sol";
import "./interface/IAuthCenter.sol";
import "./interface/IFundsProvider.sol";
import "./interface/IOpManager.sol";
import "./FundsBasic.sol";

// import "hardhat/console.sol";

contract SwapOperator is Ownable, FundsBasic {
    using TransferHelper for address;

    event SwapWithdraw(
        string id,
        string uniqueId,
        address srcToken,
        address dstToken,
        uint256 srcAmount,
        uint256 dstAmount
    );
    event Fee(string uniqueId, address feeTo, address token, uint256 amount);

    event UpdateOneInchRouter(address pre, address oneInchRouter);
    event SetOpManager(address preOpManager, address opManager);
    event SetAuthCenter(address preAuthCenter, address authCenter);
    event SetFundsProvider(address preFundsProvider, address fundsProvider);
    event SetFeeTo(address preFeeTo, address feeTo);

    event Swap(
        string id,
        string uniqueId,
        address caller, // EOA
        uint8 action,
        address srcToken,
        address dstToken,
        address from, // asset from
        address to, // asset final to
        // address swapFeeTo,
        uint256 swapFeeAmt,
        // address gasFeeTo,
        uint256 gasFeeAmt,
        uint256 srcAmtSwap,
        uint256 retAmt
    );

    address public opManager;
    address public accountManager;
    address public authCenter;
    address public fundsProvider;
    address payable public swapFeeTo;
    address payable public gasFeeTo;
    address public oneInchRouter;
    // address oneInchRouter = 0x1111111254fb6c44bAC0beD2854e76F90643097d;

    bool flag;

    enum AssetFrom {
        FUNDSPROVIDER,
        ACCOUNT
    }

    enum Action {
        SWAP,
        PRECROSS
    }

    modifier onlyRunning() {
        bool running = IOpManager(opManager).isRunning(address(this));
        require(running, "ByfiWeb3Swap: op paused!");
        _;
    }

    bytes4 constant general_selector = 0x7c025200;

    function init(
        // address _opManager,
        // address _authCenter,
        // address _fundsProvider,
        address _oneInchRouter,
        address payable _swapFeeTo,
        address payable _gasFeeTo
    ) external {
        require(!flag, "ByfiWeb3Swap: already initialized!");
        // super.initialize(); // Ownable
        // opManager = _opManager;
        // authCenter = _authCenter;
        // fundsProvider = _fundsProvider;
        oneInchRouter = _oneInchRouter;
        swapFeeTo = _swapFeeTo;
        gasFeeTo = _gasFeeTo;
        flag = true;
    }

    function doSwap(
        string memory _id,
        string memory _uniqueId,
        address _payer,
        uint8 _action,
        uint256 _swapFeeAmt,
        uint256 _gasFeeAmt,
        bytes calldata _data
    ) external payable returns (uint256 retAmt) {
        // ) external onlyRunning returns (uint256 retAmt) { //TODO
        require(_action <= 1, "ByfiWeb3Swap: _assetFrom or _action invalid!");

        retAmt = _swapInternal(
            _id,
            _uniqueId,
            _payer,
            _action,
            _swapFeeAmt,
            _gasFeeAmt,
            _data
        );
    }

    struct LocalVars {
        uint256 value;
        bool success;
        bytes retData;
    }

    // 1inch Data Struct
    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address payable srcReceiver; // don't use
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    function _swapInternal(
        string memory _id,
        string memory _uniqueId,
        address _payer,
        uint8 _action,
        uint256 _swapFeeAmt,
        uint256 _gasFeeAmt,
        bytes calldata _data
    ) internal returns (uint256 retAmt) {
        LocalVars memory vars;

        require(_data.length > 4, "ByfiWeb3Swap: invalid data");
        require(
            bytes4(_data[0:4]) == general_selector,
            "ByfiWeb3Swap: invalid selector"
        );

        /********************* DECODE DATA ***********************
         * selector: 0x7c025200
         * aggregator_selector = bytes4(keccak256(bytes("swap(address,(address,address,address,address,uint256,uint256,uint256,bytes),bytes)")));
         * function swap(
         *    IAggregationExecutor caller,
         *    SwapDescription calldata desc,
         *    bytes calldata data) external payable
         *
         *   returns (
         *      uint256 returnAmount,
         *      uint256 spentAmount,
         *      uint256 gasLeft
         *   )
         ********************************************* ***********/

        SwapDescription memory desc;

        (, desc, ) = abi.decode(_data[4:], (address, SwapDescription, bytes));

        /*
        console.log("srcToken:", address(desc.srcToken));
        console.log("dstToken:", address(desc.dstToken));
        console.log("srcReceiver:", desc.srcReceiver);
        console.log("dstReceiver:", desc.dstReceiver);
        console.log("amount:", desc.amount);
        console.log("minReturnAmount:", desc.minReturnAmount);
        */

        /******************* from: payer, to: dstReceiver ***********/
        // get src tokens from payer to OPERATOR
        if (_payer == fundsProvider) {
            // From FundsProvider
            // TODO need withilist for caller

            IFundsProvider(_payer).pull(
                address(desc.srcToken),
                desc.amount,
                address(this)
            );

            // transfer fee to 'gasFeeTo'
            if (_gasFeeAmt > 0) {
                IFundsProvider(_payer).pull(
                    address(desc.srcToken),
                    _gasFeeAmt,
                    gasFeeTo
                );
            }
        } else {
            // From EOA ETH_ADDRESS
            if (address(desc.srcToken) == ETH_ADDRESS) {
                require(
                    msg.value == desc.amount + _swapFeeAmt,
                    "ByfiWeb3Swap: msg.value should eaqul to amount set in api"
                );

                // transfer fee to 'swapFeeTo'
                address(swapFeeTo).safeTransferETH(_swapFeeAmt);

                // approve To 1inch
                vars.value = desc.amount;
            } else {
                //  From EOA ERC20 Token
                require(
                    msg.value == 0,
                    "ByfiWeb3Swap: wrong msg.value, should be 0"
                );

                // eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee , maybe lowercase //TODO
                address(desc.srcToken).safeTransferFrom(
                    _payer,
                    address(this),
                    desc.amount
                );

                // transfer fee to 'swapFeeTo'
                address(desc.srcToken).safeTransferFrom(
                    _payer,
                    swapFeeTo,
                    _swapFeeAmt
                );

                // approve to 1inch for erc20
                address(desc.srcToken).safeApprove(oneInchRouter, desc.amount);
            }
        }

        // call swap
        (vars.success, vars.retData) = oneInchRouter.call{value: vars.value}(
            _data
        );
        if (!vars.success) revert("ByfiWeb3Swap: 1Inch swap failed");

        // decode return data
        // uint256 spentAmt;
        // (retAmt,,) = abi.decode(vars.retData, (uint256, uint256, uint256)); //TODO
        // console.log("returnAmount:", retAmt);
        // console.log("spentAmt:", spentAmt); //TODO

        // require(retAmt > 0, "ByfiWeb3Swap: swap retAmt should not be 0!");

        emit Swap(
            _id,
            _uniqueId,
            msg.sender,
            _action,
            address(desc.srcToken),
            address(desc.dstToken),
            _payer,
            desc.dstReceiver,
            // swapFeeTo,
            _swapFeeAmt,
            // gasFeeTo,
            _gasFeeAmt,
            desc.amount,
            retAmt
        );
    }

    // function makeData(
    //     address _payer,
    //     uint8 _action,
    //     address _srcToken,
    //     address _dstToken
    // ) internal returns (address from, address to) {
    //     if (
    //         uint8(AssetFrom.FUNDSPROVIDER) == _assetFrom &&
    //         uint8(Action.SWAP) == _action
    //     ) {
    //         // by offchain account, usdt provided by funds provider, swap
    //         require(
    //             IFundsProvider(fundsProvider).isSupported(_srcToken),
    //             "ByfiWeb3Swap: src token not supported by funds provider!"
    //         );
    //         from = fundsProvider;
    //         to = account;
    //     } else if (
    //         uint8(AssetFrom.ACCOUNT) == _assetFrom &&
    //         uint8(Action.SWAP) == _action
    //     ) {
    //         // by onchain account, token provided by sub constract, swap
    //         from = account;
    //         to = account;
    //     } else if (
    //         uint8(AssetFrom.ACCOUNT) == _assetFrom &&
    //         uint8(Action.PRECROSS) == _action
    //     ) {
    //         // by onchain account, token provided by sub contract, cross chain
    //         require(
    //             IFundsProvider(fundsProvider).isSupported(_dstToken),
    //             "ByfiWeb3Swap: dst token not supported by funds provider!"
    //         );
    //         from = account;
    //         to = fundsProvider;
    //     } else {
    //         revert("ByfiWeb3Swap: invalid asset from and action combination!");
    //     }
    // }

    function updateOneInchRouter(address _router) external onlyOwner {
        address pre = oneInchRouter;
        oneInchRouter = _router;

        emit UpdateOneInchRouter(pre, oneInchRouter);
    }

    function setOpManager(address _opManager) external onlyOwner {
        address pre = opManager;
        opManager = _opManager;
        emit SetOpManager(pre, _opManager);
    }

    function setAuthCenter(address _authCenter) external onlyOwner {
        address pre = authCenter;
        authCenter = _authCenter;
        emit SetAuthCenter(pre, _authCenter);
    }

    function setFundsProvider(address _fundsProvider) external onlyOwner {
        address pre = fundsProvider;
        fundsProvider = _fundsProvider;
        emit SetFundsProvider(pre, _fundsProvider);
    }

    // function setFeeTo(address _feeTo) external onlyOwner {
    //     address pre = feeTo;
    //     feeTo = _feeTo;
    //     emit SetFeeTo(pre, _feeTo);
    // }

    function push(address _token, uint256 _amt)
        external
        payable
        override
        returns (uint256 amt)
    {
        _token;
        _amt;
        amt;
        revert();
    }

    function pull(
        address _token,
        uint256 _amt,
        address _to
    ) external override returns (uint256 amt) {
        IAuthCenter(authCenter).ensureOperatorPullAccess(_msgSender());
        amt = _pull(_token, _amt, _to);
    }

    function _getTokenBal(IERC20 token) internal view returns (uint256 _amt) {
        _amt = address(token) == ETH_ADDRESS
            ? address(this).balance
            : token.balanceOf(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lib/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract FundsBasic {
    address internal constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    using TransferHelper for address;
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    event Push(address token, uint256 amt);
    event Pull(address token, uint256 amt, address to);

    function push(address _token, uint256 _amt) external payable virtual returns (uint256 amt);

    function pull(
        address _token,
        uint256 _amt,
        address _to
    ) external virtual returns (uint256 amt);

    function _push(address _token, uint256 _amt) internal virtual returns (uint256 amt) {
        amt = _amt;

        if (_token != ETH_ADDRESS) {
            _token.safeTransferFrom(msg.sender, address(this), _amt);
        } else {
            require(msg.value == _amt, "ByfiWeb3Swap: Invalid Ether Amount");
        }
        emit Push(_token, _amt);
    }

    function _pull(
        address _token,
        uint256 _amt,
        address _to
    ) internal noReentrant returns (uint256 amt) {
        amt = _amt;
        if (_token == ETH_ADDRESS) {
            (bool retCall, ) = _to.call{ value: _amt }("");
            require(retCall != false, "ByfiWeb3Swap: pull ETH from account fail");
        } else {
            _token.safeTransfer(_to, _amt);
        }
        emit Pull(_token, _amt, _to);
    }

    function getBalance(IERC20[] memory _tokens) external view returns (uint256, uint256[] memory) {
        uint256[] memory array = new uint256[](_tokens.length);

        for (uint256 i = 0; i < _tokens.length; i++) {
            array[i] = _tokens[i].balanceOf(address(this));
        }
        return (address(this).balance, array);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthCenter {
    function ensureAccountAccess(address _caller) external view;
    function ensureFundsProviderPullAccess(address _caller) external view;
    function ensureFundsProviderRebalanceAccess(address _caller) external view;
    function ensureOperatorAccess(address _caller) external view;
    function ensureOperatorPullAccess(address _caller) external view;
    function ensureAccountManagerAccess(address _caller) external view;
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOpManager {
    function isRunning(address _op) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFundsProvider {
    function init(address _authCenter) external;

    function getBalance(address[] memory _tokens)
        external
        view
        returns (uint256, uint256[] memory);

    function pull(
        address token,
        uint256 amt,
        address to
    ) external returns (uint256 _amt);

    function push(address token, uint256 amt)
        external
        payable
        returns (uint256 _amt);

    function isSupported(address _token) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
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