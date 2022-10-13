//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPancakeSwapRouter {
	function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

contract SOTAExchange is Ownable {
	address public pancakeswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
	address public USDT = 0x55d398326f99059fF775485246999027B3197955;
	address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

	function changeRouter(address _newRouter) external onlyOwner {
		pancakeswapRouter = _newRouter;
	}

	/**
	 * @dev get path for exchange ETH->BNB->USDT via Pancake
	 */
	function getPathFromTokenToUSDT(address token) private view returns (address[] memory) {
		if (token == WBNB) {
			address[] memory path = new address[](2);
			path[0] = WBNB;
			path[1] = USDT;
			return path;
		} else {
			address[] memory path = new address[](3);
			path[0] = token;
			path[1] = WBNB;
			path[2] = USDT;
			return path;
		}
	}

	function getPathFromUsdtToToken(address token) private view returns (address[] memory) {
		if (token == WBNB) {
			address[] memory path = new address[](2);
			path[0] = USDT;
			path[1] = WBNB;
			return path;
		} else {
			address[] memory path = new address[](3);
			path[0] = USDT;
			path[1] = WBNB;
			path[2] = token;
			return path;
		}
	}

	function estimateToUSDT(address _paymentToken, uint256 _paymentAmount) public view returns (uint256) {
		uint256[] memory amounts;
		uint256 result;
		if (_paymentToken != USDT) {
			address[] memory path;
			uint256 amountIn = _paymentAmount;
			if (_paymentToken == address(0)) {
				path = getPathFromTokenToUSDT(WBNB);
				amounts = IPancakeSwapRouter(pancakeswapRouter).getAmountsOut(amountIn, path);
				result = amounts[1];
			} else {
				path = getPathFromTokenToUSDT(_paymentToken);
				amounts = IPancakeSwapRouter(pancakeswapRouter).getAmountsOut(amountIn, path);
				result = amounts[2];
			}
		} else {
			result = _paymentAmount;
		}
		return result;
	}

	function estimateFromUSDT(address _paymentToken, uint256 _usdtAmount) public view returns (uint256) {
		uint256[] memory amounts;
		uint256 result;
		if (_paymentToken != USDT) {
			address[] memory path;
			uint256 amountIn = _usdtAmount;
			if (_paymentToken == address(0)) {
				path = getPathFromUsdtToToken(WBNB);
				amounts = IPancakeSwapRouter(pancakeswapRouter).getAmountsOut(amountIn, path);
				result = amounts[1];
			} else {
				path = getPathFromUsdtToToken(_paymentToken);
				amounts = IPancakeSwapRouter(pancakeswapRouter).getAmountsOut(amountIn, path);
				result = amounts[2];
			}
		} else {
			result = _usdtAmount;
		}
		return result;
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