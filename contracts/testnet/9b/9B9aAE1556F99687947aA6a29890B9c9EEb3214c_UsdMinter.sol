// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

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

interface IUSD {
    function owner() external view returns (address);

    function burn(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

interface IDepositUSD {
    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external;
}

contract UsdMinter {
    address public usdTokenAddress; // usd token address
    address public depositAddress; // 存款合约地址

    address public routerAddress = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0; // uniswapRouter
    address public usdtAddress = 0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; // usdt

    address public tokenAddress; // token
    address public pairAddress; // token/usdt pair address

    mapping(address => bool) public swapTokens; // 支持兑换的token

    uint256 public hourLimitTime; // 当前小时周期的时间
    uint256 public dayLimitTime; // 当前周期的时间
    uint256 public hourMintLimitAmount; // 当前小时周期铸造的usd数量
    uint256 public dayMintLimitAmount; // 当前天周期铸造的usd数量
    uint256 public hourBurnLimitAmount; // 当前小时周期消耗的usd数量
    uint256 public dayBurnLimitAmount; // 当前天周期消耗的usd数量

    uint256 public maxMintLimit = 5; // 每次铸造的最大数量 LP 0.5%
    uint256 public maxBurnLimit = 5; // 每次销毁的最大数量 LP 0.5%

    uint256 public hourMintLimit = 5000 * 1e18; // 每小时铸造上限 具体值 1000
    uint256 public hourBurnLimit = 5000 * 1e18; // 每小时销毁上限 1000
    uint256 public dayMintLimit = 50000 * 1e18; // 每天铸造上限 10000
    uint256 public dayBurnLimit = 50000 * 1e18; // 每天销毁上限 10000

    constructor(
        address token_,
        address usd_,
        address deposit_
    ) {
        usdTokenAddress = usd_;
        tokenAddress = token_;
        depositAddress = deposit_;
        approveUniswap(tokenAddress);
    }

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(usdTokenAddress).owner(),
            "caller is not the owner"
        );
        _;
    }

    function approveUniswap(address _token) public {
        IERC20(_token).approve(routerAddress, ~uint256(0));
    }

    function setPairAddress(address pair_) external onlyOwner {
        pairAddress = pair_;
    }

    function setSwapTokens(address[] memory _tokens, bool _value)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_value && !swapTokens[_tokens[i]]) {
                approveUniswap(_tokens[i]);
            }
            swapTokens[_tokens[i]] = _value;
        }
    }

    function setMaxLimit(uint256 maxMintLimit_, uint256 maxBurnLimit_)
        external
        onlyOwner
        returns (bool)
    {
        maxMintLimit = maxMintLimit_;
        maxBurnLimit = maxBurnLimit_;
        return true;
    }

    function setLimit(
        uint256 hourMintLimit_,
        uint256 hourBurnLimit_,
        uint256 dayMintLimit_,
        uint256 dayBurnLimit_
    ) external onlyOwner returns (bool) {
        hourMintLimit = hourMintLimit_;
        hourBurnLimit = hourBurnLimit_;
        dayMintLimit = dayMintLimit_;
        dayBurnLimit = dayBurnLimit_;
        return true;
    }

    function _tokenAmount(uint256 tokenAmount) private returns (uint256) {
        //单次铸币数量不超过流动池的1%
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 maxAmount = (tokenLP * maxMintLimit) / 1000;
        require(tokenAmount <= maxAmount, "amount max limit error");

        uint256 beforeBalance = IERC20(tokenAddress).balanceOf(depositAddress);

        //转入资产
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            depositAddress, //转入存储合约
            tokenAmount
        );

        uint256 afterBalance = IERC20(tokenAddress).balanceOf(depositAddress);
        //确切的转入金额(防止有fee的Token)
        uint256 amount = afterBalance - beforeBalance;
        return amount;
    }

    function _swapTokenAmount(address _token, uint256 tokenAmount)
        private
        returns (uint256)
    {
        require(swapTokens[_token] == true, "token not in swapTokens");
        require(tokenAmount > 0, "amount error");

        //单次铸币数量不超过流动池的1%
        uint256 swapTokenAmount = getSwapPrice(
            tokenAmount,
            _token,
            address(0),
            tokenAddress
        );
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 maxAmount = (tokenLP * maxMintLimit) / 1000;
        require(swapTokenAmount <= maxAmount, "amount max limit error");

        uint256 beforeBalance = IERC20(_token).balanceOf(address(this));

        //转入资产
        TransferHelper.safeTransferFrom(
            _token,
            msg.sender,
            address(this), //转入存储合约
            tokenAmount
        );

        uint256 afterBalance = IERC20(_token).balanceOf(address(this));
        //确切的转入金额(防止有fee的Token)
        uint256 amount = afterBalance - beforeBalance;
        require(amount > 0, "amount error");

        uint256 beforeSwap = IERC20(tokenAddress).balanceOf(depositAddress);

        //swap token
        swapTokensToToken(amount, _token, tokenAddress, depositAddress);

        uint256 afterSwap = IERC20(tokenAddress).balanceOf(depositAddress);
        uint256 swapAmount = afterSwap - beforeSwap;
        return swapAmount;
    }

    function mintUsd(address _token, uint256 tokenAmount) public {
        uint256 amount;
        if (_token == tokenAddress) {
            amount = _tokenAmount(tokenAmount);
        } else {
            amount = _swapTokenAmount(_token, tokenAmount);
        }

        require(amount > 0, "amount error");

        uint256 usdAmount = getSwapPrice(
            amount,
            tokenAddress,
            address(0),
            usdtAddress
        );
        require(usdAmount > 0, "usd amount error");

        // 每小时铸造上限 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourMintLimitAmount = 0;
        }

        require(
            usdAmount + hourMintLimitAmount <= hourMintLimit,
            "hour mint limit error"
        );
        hourMintLimitAmount = hourMintLimitAmount + usdAmount;

        // 每天铸造上限 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayMintLimitAmount = 0;
        }
        require(
            usdAmount + dayMintLimitAmount <= dayMintLimit,
            "day mint limit error"
        );
        dayMintLimitAmount = dayMintLimitAmount + usdAmount;

        IUSD(usdTokenAddress).mint(msg.sender, usdAmount);
    }

    // usd=>token
    function burnUsd(address _token, uint256 usdAmount) public {
        if (_token != tokenAddress) {
            require(swapTokens[_token] == true, "token not in swapTokens");
        }
        uint256 tokenAmount = getSwapPrice(
            usdAmount,
            usdtAddress,
            address(0),
            tokenAddress
        );
        require(tokenAmount > 0, "token amount error");
        require(tokenAmount <= IERC20(tokenAddress).balanceOf(depositAddress));

        //单次铸币数量不超过流动池的1%
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 maxAmount = (tokenLP * maxBurnLimit) / 1000;
        require(tokenAmount <= maxAmount, "amount max limit error");

        // 每小时销毁上限 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourBurnLimitAmount = 0;
        }
        require(
            usdAmount + hourBurnLimitAmount <= hourBurnLimit,
            "hour burn limit error"
        );
        hourBurnLimitAmount = hourBurnLimitAmount + usdAmount;

        // 每天销毁上限 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayBurnLimitAmount = 0;
        }
        require(
            usdAmount + dayBurnLimitAmount <= dayBurnLimit,
            "day burn limit error"
        );
        dayBurnLimitAmount = dayBurnLimitAmount + usdAmount;

        IUSD(usdTokenAddress).burn(msg.sender, usdAmount);
        if (_token == tokenAddress) {
            IDepositUSD(depositAddress).withdrawToken(
                tokenAddress,
                msg.sender,
                tokenAmount
            );
        } else {
            IDepositUSD(depositAddress).withdrawToken(
                tokenAddress,
                address(this),
                tokenAmount
            );

            //swap token
            swapTokensToToken(tokenAmount, tokenAddress, _token, msg.sender);
        }
    }

    // 计算兑换价格
    function getSwapPrice(
        uint256 amount,
        address tokenIn,
        address tokenBridge,
        address tokenTo
    ) public view returns (uint256) {
        address[] memory path;
        if (tokenBridge != address(0)) {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = tokenBridge;
            path[2] = tokenTo;
        } else {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenTo;
        }

        uint256[] memory amounts = IUniswapRouter(routerAddress).getAmountsOut(
            amount,
            path
        );
        return amounts[amounts.length - 1];
    }

    function swapTokensToToken(
        uint256 amount,
        address tokenA,
        address tokenB,
        address to
    ) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        // make the swap
        IUniswapRouter(routerAddress)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                to,
                block.timestamp
            );
    }
}