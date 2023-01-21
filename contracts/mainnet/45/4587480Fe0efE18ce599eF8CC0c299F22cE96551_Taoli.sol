// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.9;
import "./interface.sol";

contract Taoli {
    mapping (string => address) COINS;

    function balanceOf(address coin, address account) public view returns (uint256) {
        return IERC20(coin).balanceOf(account);
    }

    function getBalancesByAddress(address account, address[] memory coins) public view returns (uint[] memory) {
        uint[] memory result = new uint[](coins.length);
        for(uint i=0; i<coins.length; i++){
            result[i] = this.balanceOf(coins[i], account);
        }
        return result;
    }

    function getReserves(address pair) public view returns (uint112, uint112) {
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = UniswapPair(pair).getReserves();
        return (reserve0, reserve1);
    }

    function getReservesByAddress(address[] memory pairs) public view returns (uint[] memory) {
        uint[] memory result = new uint[](pairs.length * 2);
        for(uint i=0; i<pairs.length; i++){
            (result[i * 2], result[i *2 + 1]) = this.getReserves(pairs[i]);
        }
        return result;
    }

    function getSkim(address pair) public view returns (uint256, uint256) {
        (uint112 reserve0, uint112 reserve1, ) = UniswapPair(pair).getReserves();
        address _token0 = UniswapPair(pair).token0();
        address _token1 = UniswapPair(pair).token1(); 
        uint256 result0 = this.balanceOf(_token0, pair) - reserve0;
        uint256 result1 = this.balanceOf(_token1, pair) - reserve1;
        return (result0, result1);
    }

    function getSkimByAddress(address[] memory pairs) public view returns (uint[] memory) {
        uint[] memory result = new uint[](pairs.length * 2);
        for(uint i=0; i<pairs.length; i++){
            (result[i * 2], result[i *2 + 1]) = this.getSkim(pairs[i]);
        }
        return result;
    }
}

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view
        returns (uint256);
    function decimals() external view returns (uint8);
}

interface UniswapRoute {
    function factory() external view returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface UniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
}

interface UniswapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}