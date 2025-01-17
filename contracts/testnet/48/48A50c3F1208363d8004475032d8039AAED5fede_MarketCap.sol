// SPDX-License-Identifier: NONE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MarketCap {
    address public immutable WETH; // 18 Decimals
    address public immutable BUSD; // 18 Decimals

    IRouterV2 public immutable Router;
    IFactoryV2 public immutable Factory;

    ChainLink public Oracle;

    constructor(address _UniswapV2Router, address _BUSD) {
        Router = IRouterV2(_UniswapV2Router);
        Factory = IFactoryV2(Router.factory());
        WETH = Router.WETH();
        BUSD = _BUSD;
    }

    function getMarketCap(address tokenA, address tokenB) public view returns (uint) {
        uint decimals = IERC20Metadata(tokenA).decimals();
        uint mult = 10 ** decimals;
        uint[] memory amounts;
        uint marketCap;

        if (address(Oracle) != address(0)) {
            uint price = uint(Oracle.latestAnswer()) / (10 ** Oracle.decimals());

            if (tokenB == WETH) {
                address[] memory _path = new address[](2);
                _path[0] = tokenA; _path[1] = WETH;
                amounts = Router.getAmountsOut(mult, _path);
            } else {
                address Pair = Factory.getPair(tokenA, tokenB);
                require(Pair != address(0), "!Pair");
                address[] memory _path = new address[](3);
                _path[0] = tokenA; _path[1] = tokenB; _path[2] = WETH;
                amounts = Router.getAmountsOut(mult, _path);
            }

            uint priceUSD = amounts[amounts.length-1] * price;
            marketCap = priceUSD * IERC20(tokenA).totalSupply();
        } else {
            if (tokenB == WETH) {
                address[] memory _path = new address[](3);
                _path[0] = tokenA; _path[1] = WETH; _path[2] = BUSD;
                amounts = Router.getAmountsOut(mult, _path);
            } else {
                address Pair = Factory.getPair(tokenA, tokenB);
                require(Pair != address(0), "!Pair");
                address[] memory _path = new address[](4);
                _path[0] = tokenA; _path[1] = tokenB; _path[2] = WETH; _path[3] = BUSD;
                amounts = Router.getAmountsOut(mult, _path);
            }

            marketCap = amounts[amounts.length-1] * IERC20(tokenA).totalSupply();
        }

        uint realUSD =  marketCap / (10 ** (18 + decimals));
        return realUSD;
    }
}

interface IRouterV2 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IFactoryV2 {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface ChainLink {
    function decimals() external view returns (uint8);
    function latestAnswer() external view returns (int256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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