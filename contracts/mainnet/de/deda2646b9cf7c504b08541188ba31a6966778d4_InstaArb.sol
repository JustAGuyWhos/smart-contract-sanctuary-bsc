/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/arbhelper.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;


interface IERC20 {
  function totalSupply() external view returns (uint);
  function balanceOf(address account) external view returns (uint);
  function transfer(address recipient, uint amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(uint256 amount0Out,	uint256 amount1Out,	address to,	bytes calldata data) external;
}

contract InstaArb is Ownable {

  receive() external payable {}

  function swap(address router, address[] memory path, uint256 _amount) private {
    IERC20(path[0]).approve(router, _amount);
    uint deadline = block.timestamp + 300;
    IUniswapV2Router(router).swapExactTokensForTokens(_amount, 1, path, address(this), deadline);
  }

  function DexTrade(address _router, address[] memory path_to, address[] memory path_back,uint256 _amount) external onlyOwner {
    address _token1=path_to[0];
    address _token2=path_back[0];
    uint startBalance = IERC20(_token1).balanceOf(address(this));
    uint token2InitialBalance = IERC20(_token2).balanceOf(address(this));
    //swap(_router,path_to,_amount);
    uint deadline = block.timestamp + 300;
    IUniswapV2Router(_router).swapExactETHForTokens{value: _amount}( 1, path_to, address(this), deadline);
    uint token2Balance = IERC20(_token2).balanceOf(address(this));
    uint tradeableAmount = token2Balance - token2InitialBalance;
    //swap(_router,path_back,tradeableAmount);
    IUniswapV2Router(_router).swapExactTokensForETH( tradeableAmount, 1, path_back, address(this), deadline);
    uint endBalance = IERC20(_token1).balanceOf(address(this));
    require(endBalance > startBalance, "Trade Reverted, No Profit Made");
  }


  function getBalance (address _tokenContractAddress) external view  returns (uint256) {
    uint balance = IERC20(_tokenContractAddress).balanceOf(address(this));
    return balance;
  }
  
  function recoverEth() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function recoverTokens(address tokenAddress) external onlyOwner {
    IERC20 token = IERC20(tokenAddress);
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

}