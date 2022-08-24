/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IUniswapRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract Bank {
    address public owner; // 合约的拥有者
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswapRouter
    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955; // usdt
    address public tokenAddress;
    uint256 public baseToken = 1000000000000000000;
    uint256 public basePrice = 1e18; // 基础价格
    uint256 public tokenPrice = 3; // 代币价格
    uint256 public useAmount = 1000000000000000000000000; // 每次解锁量
    uint256 public totalUseAmount = 2000000000000000000000000; // 总解锁量

    address public team = 0x751fDa519beAcEE6d6a07aCFB3BCEbACE22c07F8; // 团队
    address public dao = 0xd5F09dc8F83Cc8eAa3F6157Df1E8DA7a00E29E06; // dao
    address public market = 0x7A5E0F7E14131BB461c3D9c3486b8b097Bf34bA5; // 市场
    address public reward = 0x3d92c2598daC9c29c7Fe2bC8f75A8fEfffE87E27; // 奖励

    uint256 public teamRate = 100; // 团队比例 100 / 1000;
    uint256 public daoRate = 200; // dao比例 100 / 1000;
    uint256 public marketRate = 300; // 市场比例 100 / 1000;
    uint256 public rewardRate = 400; // 奖励比例 100 / 1000;

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function initalize(address _token) public {
        require(tokenAddress == address(0));
        tokenAddress = _token;
    }

    // 计算兑换价格
    function getSwapPrice(
        uint256 amount,
        address tokenA,
        address tokenB
    ) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory amounts = IUniswapRouter(routerAddress).getAmountsOut(
            amount,
            path
        );
        return amounts[1];
    }

    function unlock() public onlyOwner {
        uint256 _price = getSwapPrice(baseToken, tokenAddress, usdtAddress);
        uint256 _priceUint = _price / basePrice; // 去除小数
        require(_priceUint > tokenPrice, "price is too low");

        uint256 _useAmount = (_priceUint - tokenPrice) * useAmount;
        totalUseAmount += _useAmount;
        tokenPrice = _priceUint;

        uint256 _teamReward = (_useAmount * teamRate) / 1000;
        uint256 _daoReward = (_useAmount * daoRate) / 1000;
        uint256 _marketReward = (_useAmount * marketRate) / 1000;

        TransferHelper.safeTransfer(tokenAddress, team, _teamReward);
        TransferHelper.safeTransfer(tokenAddress, dao, _daoReward);
        TransferHelper.safeTransfer(tokenAddress, market, _marketReward);
        TransferHelper.safeTransfer(
            tokenAddress,
            reward,
            _useAmount - _teamReward - _daoReward - _marketReward
        );
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setTeam(address _team, uint256 _rate) public onlyOwner {
        team = _team;
        teamRate = _rate;
    }

    function setDao(address _dao, uint256 _rate) public onlyOwner {
        dao = _dao;
        daoRate = _rate;
    }

    function setMarket(address _market, uint256 _rate) public onlyOwner {
        market = _market;
        marketRate = _rate;
    }

    function setReward(address _reward, uint256 _rate) public onlyOwner {
        reward = _reward;
        rewardRate = _rate;
    }
}