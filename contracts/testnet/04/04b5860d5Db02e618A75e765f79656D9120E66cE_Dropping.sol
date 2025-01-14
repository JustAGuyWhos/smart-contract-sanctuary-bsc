/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

pragma solidity =0.6.6;


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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}

// owner
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "owner error");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// Dropping contract
contract Dropping is Ownable {
    using SafeMath for uint256;

    address public routerAddress;  // 路由合约地址
    address public factoryAddress; // 工厂合约地址
    address public wbnbAddress;    // wbnb合约地址

    constructor(address _routerAddress, address _factoryAddress, address _wbnbAddress) public {
        routerAddress = _routerAddress;
        factoryAddress = _factoryAddress;
        wbnbAddress = _wbnbAddress;
    }

    event TranferEq(address _token, uint256 _total);
    event TranferNeq(address _token, uint256 _total);
    event TranferFromEq(address _token, uint256 _total);
    event TranferFromNeq(address _token, uint256 _total);
    event TranferETHEq(uint256 _total);
    event TranferETHNeq(uint256 _total);

    // 提取合约里面的币
    // 参数1: Token地址
    // 参数2: To地址
    // 参数2：提取的数量
    function withdraw(address _token, address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransfer(_token, _to, _value);
    }

    // 批量转代币, 从合约里面扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组equal
    // 参数3: 每个地址接收的数量
    function tranferEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value);
        }
        emit TranferEq(_token, _value * _addr.length);
    }

    // 批量转代币, 从合约里面扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组; [0x123...,0x234...,...](区块链浏览器格式)
    // 参数3: 数量数组; [1,2,...](区块链浏览器格式)
    function tranferNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransfer(_token, _addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferNeq(_token, _all);
    }

    // 批量转代币, 从发送者地址扣币, 一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组
    // 参数3: 每个地址接收的数量
    function tranferFromEq(address _token, address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value);
        }
        emit TranferFromEq(_token, _value * _addr.length);
    }

    // 批量转代币, 从发送者地址扣币, 不一样的数量
    // 参数1: Token地址
    // 参数2: 接收者地址数组
    // 参数3: 数量数组
    function tranferFromNeq(address _token, address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferFromNeq(_token, _all);
    }

    // 提取主链币
    // 参数1: To地址
    // 参数2: 提取的数量
    function withdrawETH(address _to, uint256 _value) public onlyOwner {
        TransferHelper.safeTransferETH(_to, _value);
    }

    // 接收主链币
    receive() external payable {}

    // 批量转主链币, 从合约里面扣币, 一样的数量
    // 参数1: 接收者地址数组equal
    // 参数2: 每个地址接收的数量
    function tranferETHEq(address[] memory _addr, uint256 _value) public onlyOwner {
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferETH(_addr[i], _value);
        }
        emit TranferETHEq(_value * _addr.length);
    }

    // 批量转主链币, 从合约里面扣币, 不一样的数量
    // 参数1: 接收者地址数组
    // 参数2: 数量数组
    function tranferETHNeq(address[] memory _addr, uint256[] memory _value) public onlyOwner {
        require(_addr.length == _value.length, "length error");
        uint256 _all = 0;
        for(uint256 i = 0; i < _addr.length; i++) {
            TransferHelper.safeTransferETH(_addr[i], _value[i]);
            _all += _value[i];
        }
        emit TranferETHNeq(_all);
    }

    // BNBT币。给小区分红和LP持币分红, 都是直接空投。BNB是分红合约打进来的, BNBDAO是项目方打进来的。

    // BNBDAO币。添加流动性和卖出时会扣除手续费BNBDAO币到这里
    // 然后一半兑换成BNB(WBNB)打进BNBT-BNB池子, 一半兑换成BNBT打进黑洞地址;
    // 参数1：BNBDAO合约地址
    // 参数2：BNBDAO的拿去兑换的数量
    // 参数3：BNBT合约地址
    function swapAndBurn(address _bnbdaoAddress, uint256 _bnbdaoValue, address _bnbtAddress) public onlyOwner {
        uint256 _balancesBefore = address(this).balance;
        bnbdaoSwapBNB(_bnbdaoAddress, _bnbdaoValue); // BNBDAO兑换成BNB
        uint256 _balancesLater = address(this).balance; // 兑换完成之后的BNB余额
        uint256 _v = _balancesLater.sub(_balancesBefore).div(2); // 增加的数量 一半兑换成BNBT直接销毁
        bnbSwapBNBT(_bnbtAddress, _v);      // 一半BNB兑换成BNBT, 并直接销毁。

        // 给到BNBT-BNB的资金池, 然后更新储备量
        address _lpAddress = IUniswapV2Factory(factoryAddress).getPair(_bnbtAddress, wbnbAddress);
        if(_lpAddress != address(0)) {
            // 把BNB兑换成WBNB
            TransferHelper.safeTransferETH(wbnbAddress, _v);
            // 把WBNB回流到BNBT-WBNB的资金池
            TransferHelper.safeTransfer(wbnbAddress, _lpAddress, _v);
            IUniswapV2Pair(_lpAddress).sync();
        }
    }

    // BNBDAO币兑换成BNB
    // 把一定数量的BNBDAO币兑换成BNB
    // 参数1：BNBDAO合约地址
    // 参数2：BNBDAO的数量
    function bnbdaoSwapBNB(address _bnbdaoAddress, uint256 _bnbdaoValue) internal onlyOwner {
        // BNBDAO换成BNB
        address[] memory _path = new address[](2); // 兑换
        _path[0] = _bnbdaoAddress;
        _path[1] = wbnbAddress;
        // 把token授权给路由合约。
        TransferHelper.safeApprove(_bnbdaoAddress, routerAddress, _bnbdaoValue);
        IUniswapV2Router02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _bnbdaoValue,
            0, // 接受任意金额的兑换
            _path,
            address(this),
            block.timestamp + 300);
    }

    // 给定数量的BNB兑换成BNBT币, 并且直接销毁。
    // 参数1：BNBT合约地址
    // 参数2：兑换BNB的数量
    function bnbSwapBNBT(address _bnbtAddress, uint256 _v) internal onlyOwner {
        if(_v == 0) return;
        address[] memory _path = new address[](2);  // 兑换
        _path[0] = wbnbAddress;
        _path[1] = _bnbtAddress;
        IUniswapV2Router02(routerAddress).swapExactETHForTokens{value: _v}(
            0, // 接受任意金额的兑换
            _path,
            address(0),
            block.timestamp + 300);
    }

}