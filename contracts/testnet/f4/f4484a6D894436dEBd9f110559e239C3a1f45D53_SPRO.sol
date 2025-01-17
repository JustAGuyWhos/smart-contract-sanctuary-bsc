// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
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

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract SPRO is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event PayBiggestBuyer(address indexed account, uint256 indexed period, uint256 amount);

    string public _name = "Staking Pro";
    string public _symbol = "SPRO";
    uint8 public _decimals = 18;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 18;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 11;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 40 * 10**4 * 10**DECIMALS;

    uint256 public MAX_TOTAL_FEE = 250;
    uint256 public liquidityFee = 40;
    uint256 public treasuryFee = 30;
    uint256 public insuranceFundFee = 50;
    uint256 public sellFee = 20;
    uint256 public firePitFee = 20;
    uint256 public rewardBuyerFee = 10;
    uint256 public totalFee = liquidityFee.add(treasuryFee).add(insuranceFundFee).add(firePitFee);
    uint256 public feeDenominator = 1000;

    uint256 public extraFee = 0;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public busdToken = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public insuranceFundReceiver;
    address public riskFreeValueReceiver;
    address public firePit;
    address public pairAddress;
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    struct user {
        uint256 firstBuy;
        uint256 lastTradeTime;
        uint256 tradeAmount;
    }

    uint256 public CHECK_PRICE_TIME = 3600;
    uint256 public lastCheckPriceTime = 0;
    uint256 public lastCheckPrice = 0;

    uint256 public MAX_SELL_LIMIT = 25;
    // uint256 public MIN_SELL_LIMIT = 1;
    uint256 public sellLimit = 10;
    uint256 public TwentyFourhours = 86400;
    mapping(address => user) public tradeData;
    mapping(address => user) public tradeBuyData;

    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 325 * 10**7 * 10**DECIMALS;
    uint256 public maxSellTransactionAmount = 50000 * 10 ** DECIMALS;

    uint256 public rebaseCycle = 60; // minutes unit
    uint256 public rebaseRateFirstYear = 94233281; // minutes unit 

    bool public _autoTakeFee;
    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    /** Reward Biggest Buyer **/
    bool public isRewardBiggestBuyer = true;
    uint256 public biggestBuyerPeriod = 3600;
    uint256 public immutable launchTime = block.timestamp;
    uint256 public  totalBiggestBuyerPaid;
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;

    uint256 private treasuryFeeCollect = 0;
    uint256 private insuranceFeeCollect = 0;
    uint256 private firePitFeeCollect = 0;
    uint256 private rewardBuyerFeeCollect = 0;

    uint private swapbackPeriod = 25;
    uint private txForSwapback = 0;

    constructor() ERC20Detailed("Staking Pro", "SPRO", uint8(DECIMALS)) Ownable() {

        router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        address pairBusd = IPancakeSwapFactory(router.factory()).createPair(address(this), busdToken);
      
        autoLiquidityReceiver = 0x22d3D569C57AeF352fA5916C483828d474Ce72A8;
        treasuryReceiver = 0x1fCfFEfA2923eeb50efa84F87F6ce2554823A7Bd;
        insuranceFundReceiver = 0x8AdeaF792d63c95171478284c66a84574528b617;
        riskFreeValueReceiver = 0x1b85fF5cb0bd1E48063b6934c29B7A62697B619C;
        firePit = 0x000000000000000000000000000000000000dEaD;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pairBusd] = uint256(-1);
        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoTakeFee = true;
        _autoRebase = true;
        _autoAddLiquidity = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[riskFreeValueReceiver] = true;
        _isFeeExempt[firePit] = true;

        IERC20(busdToken).approve(address(router), uint256(-1));
        IERC20(busdToken).approve(address(pairBusd), uint256(-1));
        IERC20(busdToken).approve(address(this), uint256(-1));

        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function rebase() internal {
        
        if ( inSwap ) return;

        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(rebaseCycle * 60);
        uint256 epoch = times.mul(rebaseCycle);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = rebaseRateFirstYear;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 2110000;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
            rebaseRate = 140000;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 20000;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply.mul((10**RATE_DECIMALS).add(rebaseRate)).div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(60));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function setIsRewardBiggestBuyer(bool _status, uint256 _biggestBuyerPeriod) external onlyOwner {
        require(_biggestBuyerPeriod >= 300, "Period too small");
        isRewardBiggestBuyer = _status;
        biggestBuyerPeriod = _biggestBuyerPeriod;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
            
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        // // buy tokens
        // if (sender == pair) { 
        //     uint blkTime = block.timestamp;            
        //     if( blkTime > tradeBuyData[sender].lastTradeTime + CHECK_PRICE_TIME) {
        //         tradeBuyData[sender].lastTradeTime = blkTime;
        //         tradeBuyData[sender].tradeAmount = amount;
        //     }
        // }

        // sell tokens
        if (recipient == pair &&
            sender != address(router)  // not remove liquidity
        ) {
            
            if ( !excludedAccount) {
                require(amount <= maxSellTransactionAmount, "Error amount");

                uint blkTime = block.timestamp;                
                uint256 onePercent = balanceOf(sender).mul(sellLimit).div(100); //Should use variable
                require(amount <= onePercent, "ERR: Can't sell more than set %");
                
                if( blkTime > tradeData[sender].lastTradeTime + TwentyFourhours) {
                    tradeData[sender].lastTradeTime = blkTime;
                    tradeData[sender].tradeAmount = amount;
                }
                else if( (blkTime < tradeData[sender].lastTradeTime + TwentyFourhours) && (( blkTime > tradeData[sender].lastTradeTime)) ){
                    require(tradeData[sender].tradeAmount + amount <= onePercent, "ERR: Can't sell more than 1% in One day");
                    tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
                }
            }            
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        if(isRewardBiggestBuyer){
            uint256 _periodAfterLaunch = getPeriod();

            if(sender == pair && !_isContract(recipient)){
                if (amount > biggestBuyerAmount[_periodAfterLaunch]) {
                    biggestBuyer[_periodAfterLaunch] = recipient;
                    biggestBuyerAmount[_periodAfterLaunch] = amount;
                }
            }

            _checkAndPayBiggestBuyer(_periodAfterLaunch);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : takeFeeRisk(sender, recipient, amount);
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

        txForSwapback = txForSwapback.add(1);
        emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));
        return true;
    }

    function takeFeeRisk(address from, address to, uint256 amount) internal returns (uint256) {

        bool excludedAccount = _isFeeExempt[from] || _isFeeExempt[to];
        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (excludedAccount) {  
            return gonAmount;           
        }else {
            _gonBalances[riskFreeValueReceiver] = _gonBalances[riskFreeValueReceiver].add(gonAmount.div(100)); 
            emit Transfer(from, riskFreeValueReceiver, gonAmount.div(100).div(_gonsPerFragment));
            return gonAmount.sub(gonAmount.div(100));
        }    
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal  returns (uint256) {
        uint256 _totalFee = totalFee;
        uint256 _treasuryFee = treasuryFee;

        if (recipient == pair) {
            
            bool moreOnePercent = checkPriceChangedOnepercentMore(pairAddress, 1*10**DECIMALS);

            if (moreOnePercent) {
                extraFee = MAX_TOTAL_FEE - totalFee;
            } else {
                extraFee = 0;
            } 

            _totalFee = totalFee.add(sellFee).add(extraFee);
            _treasuryFee = treasuryFee.add(sellFee).add(extraFee);
        }

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);
       
        // _gonBalances[firePit] = _gonBalances[firePit].add(
        //     gonAmount.div(feeDenominator).mul(firePitFee)
        // );

        treasuryFeeCollect = treasuryFeeCollect.add(gonAmount.div(feeDenominator).mul(_treasuryFee));
        insuranceFeeCollect = insuranceFeeCollect.add(gonAmount.div(feeDenominator).mul(insuranceFundFee));
        firePitFeeCollect = firePitFeeCollect.add(gonAmount.div(feeDenominator).mul(firePitFee));
        rewardBuyerFeeCollect = rewardBuyerFeeCollect.add(gonAmount.div(feeDenominator).mul(rewardBuyerFee));

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.div(feeDenominator).mul(_treasuryFee.add(insuranceFundFee).add(firePitFee).add(rewardBuyerFee))
        );

        _gonBalances[autoLiquidityReceiver] = _gonBalances[autoLiquidityReceiver].add(
            gonAmount.div(feeDenominator).mul(liquidityFee.sub(rewardBuyerFee))
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(_gonsPerFragment);
        _gonBalances[address(this)] = _gonBalances[address(this)].add(_gonBalances[autoLiquidityReceiver]);
        _gonBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {

        // initialize txForSwapback
        txForSwapback = 0;
        
        uint256 amountToSwapBNB = rewardBuyerFeeCollect.div(_gonsPerFragment);

        if( amountToSwapBNB == 0) {
            return;
        }

        _swapTokensForBNB(amountToSwapBNB, address(this));

        uint256 amountToSwapTrBUSD = treasuryFeeCollect.div(_gonsPerFragment);
        uint256 amountToSwapInBUSD = insuranceFeeCollect.div(_gonsPerFragment);
        if( amountToSwapTrBUSD.add(amountToSwapInBUSD) == 0) {
            return;
        }
        // swap BUSD for treasury , insurance
        uint256 balanceBUSDBefore = IERC20(busdToken).balanceOf(address(this));
        _swapTokensForBusd(amountToSwapTrBUSD.add(amountToSwapInBUSD), address(this));
        uint256 amtBUSD = IERC20(busdToken).balanceOf(address(this)).sub(balanceBUSDBefore);

        // send BUSD to treasury receier
        IERC20(busdToken).transferFrom(address(this), treasuryReceiver, amtBUSD.mul(amountToSwapTrBUSD).div(amountToSwapTrBUSD.add(amountToSwapInBUSD)));
        // send BUSD to insurance receiver
        IERC20(busdToken).transferFrom(address(this), insuranceFundReceiver, IERC20(busdToken).balanceOf(address(this)));
               
        // send autoburn amount to dead
        uint256 amtSproFirepit = _gonBalances[address(this)].div(_gonsPerFragment);
        _transferFrom(address(this), firePit, amtSproFirepit);
        // log transfer to DEAD wallet
        emit Transfer(
            address(this),
            firePit,
            amtSproFirepit
        );

        treasuryFeeCollect = 0;
        insuranceFeeCollect = 0;
        firePitFeeCollect = 0;
        rewardBuyerFeeCollect = 0;
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"There is no spro token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return 
            _autoTakeFee &&
            (pair == from || pair == to) &&            
            !(from == pair && to == address(router)) &&  // not remove liquidity
            (from != address(router)) &&   // not remove liquidity
            !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair  &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + rebaseCycle * 60);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + 1 days);
    }

    function shouldSwapBack() internal view returns (bool) {
        // return !inSwap && 
        //     msg.sender != pair && 
        //     txForSwapback >= swapbackPeriod;
        return !inSwap && 
            msg.sender != pair;
    }

    function setAutoTakeFee(bool _flag) external onlyOwner {
        _autoTakeFee = _flag;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _insuranceFundReceiver,
        address _firePit
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        insuranceFundReceiver = _insuranceFundReceiver;
        firePit = _firePit;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed exteranlly owned account");
        blacklist[_botAddress] = _flag;    
    }
    
    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setSellLimit(uint _limit) external onlyOwner {
        require(_limit <= MAX_SELL_LIMIT, "Exceed max 25%");
        // require(_limit >= MIN_SELL_LIMIT, "Exceed min 1%");
        sellLimit = _limit;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        // require(_maxTxn > 0, "Max transaction must be greater than 0");
        maxSellTransactionAmount = _maxTxn;
    }

    function setFees(uint256 _liquidityFee, uint256 _insurranceFund, uint256 _treasuryFee, uint256 _sellFeeTreasuryAdded, uint256 _burnFee) external onlyOwner {
        require(
            _liquidityFee.add(_insurranceFund).add(_treasuryFee).add(_sellFeeTreasuryAdded).add(_burnFee) <= MAX_TOTAL_FEE, 
            "Exceed fee 25%"
        );

        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        insuranceFundFee = _insurranceFund;
        sellFee = _sellFeeTreasuryAdded;
        firePitFee = _burnFee;
    }

    function checkPriceChangedOnepercentMore(address _pairAddress, uint amount) internal returns(bool) {
        
        require((block.timestamp - lastCheckPriceTime) >= CHECK_PRICE_TIME, "not check price time");
        uint price = getTokenPriceChanged(_pairAddress, amount);
        bool ret = false;

        if ( (lastCheckPrice != 0) && 
             (price < lastCheckPrice) && 
             (lastCheckPrice.sub(price).div(lastCheckPrice).mul(100) >= 1)) {
            ret = true;
        }   

        lastCheckPriceTime = block.timestamp;
        lastCheckPrice = price;     
        return ret;
    }

    function getTokenPriceChanged(address _pairAddress, uint amount) internal view returns(uint) {
        IPancakeSwapPair _pair = IPancakeSwapPair(_pairAddress);
        // IERC20 token1 = IERC20(_pair.token1());
        (uint Res0, uint Res1,) = _pair.getReserves();

        // decimals
        uint res0 = Res0*(10**_pair.decimals());
        uint tokenPrice = (amount*res0)/Res1;
        return(tokenPrice); // return amount of token0 needed to buy token1
    }

    function manualRebase() external {
        require(shouldRebase(), "Not rebase time");
        rebase();
    }
    
    function setRebaseCycleRateMinutesUnit(uint256 _rebaseCycleMinutesUnit, uint256 _rebaseRateFirstYear) external onlyOwner {
        rebaseCycle = _rebaseCycleMinutesUnit;
        rebaseRateFirstYear = _rebaseRateFirstYear;
    }

    function _swapTokensForBNB(uint256 tokenAmount, address receiver) private {
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _swapWETHForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path;
        
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = busdToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _swapTokensForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path;
        
        path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = busdToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _transferBNBToWallet(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function getPeriod() public view returns (uint256) {
        uint256 secondsSinceLaunch = block.timestamp - launchTime;
        return 1 + (secondsSinceLaunch / biggestBuyerPeriod);
    }

    function payBiggestBuyerOutside(uint256 _hour) external onlyOwner {
        _checkAndPayBiggestBuyer(_hour);
    }

    function _checkAndPayBiggestBuyer(uint256 _currentPeriod) private {
        uint256 _prevPeriod = _currentPeriod - 1;
        if (
            _currentPeriod > 1 &&
            biggestBuyerAmount[_prevPeriod] > 0 &&
            biggestBuyerPaid[_prevPeriod] == 0
        ) {
            uint256 _rewardAmount = address(this).balance;
            if (_rewardAmount > 0) {
                _transferBNBToWallet(payable(biggestBuyer[_prevPeriod]), _rewardAmount);
                totalBiggestBuyerPaid = totalBiggestBuyerPaid + _rewardAmount; 
                biggestBuyerPaid[_prevPeriod] = _rewardAmount;
                
                emit PayBiggestBuyer(biggestBuyer[_prevPeriod], _prevPeriod, _rewardAmount);
            }
        }
    }

    function setSwapBackPeriod(uint256 _swapbackPeriod) external onlyOwner {
        swapbackPeriod = _swapbackPeriod;
    }

    receive() external payable {}
}