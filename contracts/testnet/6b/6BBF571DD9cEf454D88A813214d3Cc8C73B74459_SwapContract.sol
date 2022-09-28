// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IRouter.sol";

import "./Vault.sol";

contract SwapContract is Ownable {
    uint256 public constant MAX_INT = 2**255;
    mapping(address => bool) public operator;

    IFactory public factory;
    IRouter public router;
    address public swapToken;
    Vault[] public vaults;
    modifier onlyOperator() {
        require(operator[msg.sender] || msg.sender == owner(), "Only Operator");
        _;
    }

    constructor(IRouter _router, address _swapToken) {
        router = _router;

        factory = IFactory(router.factory());

        swapToken = _swapToken;

        IERC20(_swapToken).approve(address(_router), 2**255);
    }

    function approve(IERC20 _token, address _spender) external onlyOperator {
        _token.approve(_spender, 2**255);
    }

    function executeMaxWithPath(
        uint256 _amountOut,
        uint256 _amountInMax,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            bytes memory bytecode = type(Vault).creationCode;
            bytes32 salt = keccak256(
                abi.encodePacked(address(this), vaults.length)
            );
            address vault;

            assembly {
                vault := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }

            router.swapTokensForExactTokens(
                _amountOut,
                _amountInMax,
                path,
                vault,
                MAX_INT
            );

            vaults.push(Vault(vault));
        }
    }

    function normalExecuteMaxWithPath(
        uint256 _amountOut,
        uint256 _amountInMax,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            router.swapTokensForExactTokens(
                _amountOut,
                _amountInMax,
                path,
                owner(),
                MAX_INT
            );
        }
    }

    function selectiveExecuteMaxWithPath(
        uint256 _amountOut,
        uint256 _amountInMax,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            router.swapTokensForExactTokens(
                _amountOut,
                _amountInMax,
                path,
                msg.sender,
                MAX_INT
            );
        }
    }

    function safeExecuteMaxWithPath(
        uint256 _amountOut,
        uint256 _amountInMax,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            router.swapTokensForExactTokens(
                _amountOut,
                _amountInMax,
                path,
                address(this),
                MAX_INT
            );
        }

        address executeToken = path[path.length - 1];
        uint256 balance = IERC20(executeToken).balanceOf(address(this));
        require(balance >= _amountOut, "balance not enough");

        IERC20(executeToken).transfer(owner(), balance);
    }

    function normalExecuteMinWithPath(
        uint256 _amountIn,
        uint256 _minAmountOut,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            router.swapExactTokensForTokens(
                _amountIn,
                _minAmountOut,
                path,
                owner(),
                MAX_INT
            );
        }
    }

    function selectiveExecuteMinWithPath(
        uint256 _amountIn,
        uint256 _minAmountOut,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            router.swapExactTokensForTokens(
                _amountIn,
                _minAmountOut,
                path,
                msg.sender,
                MAX_INT
            );
        }
    }

    function safeExecuteMinWithPath(
        uint256 _amountIn,
        uint256 _minAmountOut,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            router.swapExactTokensForTokens(
                _amountIn,
                _minAmountOut,
                path,
                address(this),
                MAX_INT
            );
        }

        address executeToken = path[path.length - 1];
        uint256 balance = IERC20(executeToken).balanceOf(address(this));
        require(balance >= _minAmountOut, "balance not enough");

        IERC20(executeToken).transfer(owner(), balance);
    }

    function executeMinWithPath(
        uint256 _amountIn,
        uint256 _minAmountOut,
        address[] memory path,
        uint256 round
    ) external onlyOperator {
        for (uint256 i = 0; i < round; i++) {
            bytes memory bytecode = type(Vault).creationCode;
            bytes32 salt = keccak256(
                abi.encodePacked(address(this), vaults.length)
            );
            address vault;

            assembly {
                vault := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }

            router.swapExactTokensForTokens(
                _amountIn,
                _minAmountOut,
                path,
                vault,
                MAX_INT
            );

            vaults.push(Vault(vault));
        }
    }

    function getAllTokens(IERC20 _token, address _recipient) public onlyOwner {
        for (uint256 i = 0; i < vaults.length; i++) {
            vaults[i].getTokens(address(_token), _recipient);
        }
    }

    function getTokensAt(
        Vault _vault,
        IERC20 _token,
        address _recipient
    ) public onlyOwner {
        _vault.getTokens(address(_token), _recipient);
    }

    function withdraw(IERC20 _token, uint256 _amount) external onlyOperator {
        _token.transfer(msg.sender, _amount);
    }

    function withdrawAll(IERC20 _token) external onlyOperator {
        uint256 balance = _token.balanceOf(address(this));
        _token.transfer(msg.sender, balance);
    }

    function addBatchOperator(address[] memory _operators) public onlyOperator {
        for (uint256 i = 0; i < _operators.length; i++) {
            operator[_operators[i]] = true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Vault {
    address public factory;
    bool public isInitialized;

    constructor () {
        factory = msg.sender;
    }

    function getTokens(address _token, address _recipient) public {
        require(msg.sender == factory, "PERMISSIONS");
        uint256 balance = ERC20Interface(_token).balanceOf(address(this));
        ERC20Interface(_token).transfer(_recipient, balance);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
}