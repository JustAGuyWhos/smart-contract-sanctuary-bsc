/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// pragma solidity >=0.5.0;
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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WHT() external pure returns (address);
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

// pragma solidity >=0.6.2;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract TokenDividendTracker is Ownable {

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    IUniswapV2Router02 uniswapV2Router;
    address public uniswapV2Pair;
    address public lpRewardToken;
    // 上次分红时间
    uint256 public LPRewardLastSendTime;
    address public contractUSDT;
    address public contractToken;//this token本币

    address public walletMarket;
    uint256 public amountToAddLiquidity=1000000000000000000;

    constructor(address ROUTER, address uniswapV2Pair_,address USDT,address token,address _walletMarket){
        uniswapV2Pair = uniswapV2Pair_;
        contractUSDT = USDT;
        contractToken =  token;
        uniswapV2Router = IUniswapV2Router02(ROUTER);
        walletMarket = _walletMarket;
    }
    receive() external payable {}
    function resetLPRewardLastSendTime() public onlyOwner {
        LPRewardLastSendTime = 0;
    }

    // LP分红发放
    function process(uint256 gas) external {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        // uint256 nowbanance = IERC20(lpRewardToken).balanceOf(address(this));
        uint256 nowbanance = address(this).balance;
        if(nowbanance == 0) return;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                LPRewardLastSendTime = block.timestamp;
                return;
            }

            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                return;
            }
            if(address(this).balance  < amount ) return;
            // IERC20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            payable(shareholders[currentIndex]).transfer(amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external {
        if(_updated[shareholder] ){      
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function setAmountToAddLiquidity(uint256 number) external {
        amountToAddLiquidity = number;
    }
    function swapAndLiquify() external {
       // split the contract balance into halves
        uint256 tokenBalance = IERC20(address(contractToken)).balanceOf(address(this));
        if(tokenBalance == 0 ) return;

        uint256 half = tokenBalance.div(2);
        uint256 otherHalf = tokenBalance.sub(half);

        uint256 initialBalance = IERC20(address(contractUSDT)).balanceOf(address(this));

        // swap tokens for tokens
        swapTokensForTokens(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much usdt did we just swap into?
        uint256 newBalance = IERC20(address(contractUSDT)).balanceOf(address(this)).sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(contractToken);
        path[1] = address(contractUSDT);

        IERC20(address(contractToken)).approve( address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Tokens
            path,
            address(this),
            block.timestamp
        );

    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(address(contractToken)).approve(address(uniswapV2Router), tokenAmount);
        IERC20(address(contractUSDT)).approve(address(uniswapV2Router), usdtAmount);
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(contractToken),
            address(contractUSDT),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(walletMarket),
            block.timestamp
        );

    }
    
}

contract Token is IERC20,Ownable {



    using SafeMath for uint256;

    uint8 private transferFeeOnOff=1; //1 fee 2 nofee

    uint8 public buyDeadFee = 1;
    uint8 public buyBackFee = 1; 
    uint8 public buyLpFee = 2; 
    uint8 public buyMarketFee = 2; 
 
    address public walletDead = 0x000000000000000000000000000000000000dEaD;
    address public walletMarket = 0xE1A9beDE50CE9eA3556C87021E7DfD9106946022;

    TokenDividendTracker public dividendTracker;
    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;

    address public uniswapV2Pair;//if transfer from this address ,meaning some one buying
    IUniswapV2Router02 uniswapV2Router;

    uint8 private buyOnOff=1; //1can buy 2can not buy
    uint256 private openMarketTime = 0; 
    
    uint256 private openMarketControlTime = 300; //5min
    uint256 private openMarketControlAmount; //1000coin

    bool private swapping;
    uint256 public swapTokensAtAmount;
    uint256 public AmountLpRewardFee;
    uint256 public AmountMarketRewardFee;
    uint256 public AmountLiquidityFee;
    uint256 public minPeriod = 1;
    uint256 distributorGas = 200000;

    address public contractUSDT;//test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 main 0x55d398326f99059fF775485246999027B3197955

    // test 0x9ac64cc6e4415144c455bd8e4837fea55603e5c3 main 0x10ED43C718714eb63d5aA57B78B54704E256024E
    constructor(address ROUTER, address USDT){
        _decimals = 18;
        _symbol = "CocaCola";
        _name = "CocaCola";
        _totalSupply = 1100000 * (10**_decimals);//first mint 1w

        //swapTokensAtAmount = _totalSupply.mul(2).div(100000); // 0.00002%;
        swapTokensAtAmount = 10*(10**_decimals);
        openMarketControlAmount = 1000*(10**_decimals);

        _creator = _msgSender();

        contractUSDT = USDT;

        uniswapV2Router = IUniswapV2Router02(ROUTER);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(contractUSDT, address(this));
        // uniSwapEthPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), IUniswapV2Router02.WETH());

        dividendTracker = new TokenDividendTracker(ROUTER,uniswapV2Pair,USDT,address(this),walletMarket);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(walletDead)] = true;
        isDividendExempt[address(walletMarket)] = true;
        isDividendExempt[address(dividendTracker)] = true;

        emit Transfer(address(0), address(_creator), 1000000 * (10**_decimals));
        _balances[address(_creator)] = 1000000 * (10**_decimals);
        emit Transfer(address(0), address(walletDead), 100000 * (10**_decimals));
        _balances[address(walletDead)] = 100000 * (10**_decimals);
    }

    address private _creator;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    //
    receive() external payable {}
    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
            revert();
        }
        _;
    }



    function setBuyDeadFee(uint8 num) external onlyOwner returns (uint8){
        buyDeadFee = num;
        return buyDeadFee;
    }
    function setBuyBackFee(uint8 num) external onlyOwner returns (uint8){
        buyBackFee = num;
        return buyBackFee;
    }
    function setBuyMarketFee(uint8 num) external onlyOwner returns (uint8){
        buyMarketFee = num;
        return buyMarketFee;
    }
    function setBuyLpFee(uint8 num) external onlyOwner returns (uint8){
        buyLpFee = num;
        return buyLpFee;
    }
    function setWalletDead(address add) external onlyOwner returns (address){
        walletDead = add;
        return walletDead;
    }
    function setWalletMarket(address add) external onlyOwner returns (address){
        walletMarket = add;
        return walletMarket;
    }
    function setSwapTokensAtAmount(uint8 num) external onlyOwner returns (uint256){
        swapTokensAtAmount = num*(10**_decimals);
        return swapTokensAtAmount;
    }
    function setTransferFeeOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        transferFeeOnOff = oneortwo;
        return transferFeeOnOff;
    }
    function setBuyOnOff(uint8 oneortwo) external onlyOwner returns (uint8){
        buyOnOff = oneortwo;
        if(oneortwo == 1){
            openMarketTime = block.timestamp;
        }else{
            openMarketTime = 0;
        }
        return buyOnOff;
    }
    function setMinPeriod(uint256 number) public onlyOwner {
        minPeriod = number;
    }
    function setOpenMarketControlAmount(uint256 number) public onlyOwner {
        openMarketControlAmount = number*(10**_decimals);
    }
    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 2000000, "distributorGas must be between 200,000 and 2000,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }
    function processDividend() public {
        try dividendTracker.process(distributorGas) {} catch {}
    }
    function setAmountToAddLiquidity(uint256 number) external {
        try dividendTracker.setAmountToAddLiquidity(number) {} catch {}
    }

    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function name() external override view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return _creator;
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external override view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external onlyPayloadSize(2 * 32) override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public onlyPayloadSize(2 * 32) returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public onlyPayloadSize(2 * 32) returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    //burn, destroy to 0x000dead
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        require(account != address(1), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _balances[address(walletDead)] = _balances[address(walletDead)].add(amount);

        //_totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(1), amount);
    }

    function transferFrom(address _owner, address _to, uint256 amount) external override returns (bool) {
        _transferFrom( _owner,  _to,  amount);
        return true;
    }
    function _transferFrom(address _owner, address _to, uint256 amount) internal returns (bool) {
        _transfer(_owner, _to, amount);
        _approve(_owner, _msgSender(), _allowances[_owner][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    

    function swapRewardToken(uint256 tokenAmount,address toAccount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = address(contractUSDT);
        path[2] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(toAccount),
            block.timestamp
        );
    
    }
    function takeAllFee(address from, uint256 amount) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 DFee = 0;
        uint256 BFee = 0;
        uint256 LFee = 0;
        uint256 MFee = 0;

        //buy or sell

        DFee = amount.mul(buyDeadFee).div(100);
        BFee = amount.mul(buyBackFee).div(100);
        MFee = amount.mul(buyMarketFee).div(100);
        LFee = amount.mul(buyLpFee).div(100);

        uint256 amountDestroy = _balances[walletDead];
        
        if(DFee > 0 && _totalSupply.sub(amountDestroy) >110000*(10**_decimals)){
            doTransfer(from, walletDead, DFee);
            amountAfter = amountAfter.sub(DFee);
        } 
        if(BFee > 0){
            doTransfer(from, address(dividendTracker), BFee);
            amountAfter = amountAfter.sub(BFee);
            AmountLiquidityFee += BFee;
        } 
        if(MFee > 0) doTransfer(from, address(this), MFee);
        amountAfter = amountAfter.sub(MFee);
        AmountMarketRewardFee += MFee;

        if(LFee > 0) doTransfer(from, address(this), LFee);
        amountAfter = amountAfter.sub(LFee);
        AmountLpRewardFee += LFee;

        return amountAfter;

    }
    function swap() external {
        uint256 contractTokenBalance = _balances[address(this)];
        bool canSwap = contractTokenBalance >= AmountLpRewardFee;
        if( canSwap &&
            !swapping 
        ) {
            swapping = true;
            if(AmountLpRewardFee > 0){
                swapRewardToken(AmountLpRewardFee,address(dividendTracker));
                AmountLpRewardFee = 0;
            }
            if(AmountMarketRewardFee > 0){
                swapRewardToken(AmountMarketRewardFee,address(walletMarket));
                AmountMarketRewardFee = 0;
            }
            if(AmountLiquidityFee > 0){
                try dividendTracker.swapAndLiquify() {} catch {}
                AmountLiquidityFee = 0;
            }
            swapping = false;
        }
    }
    
    function _transfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(_balances[from] >= amount, "BEP20: transfer amount exceeds balance");
        if(amount == 0 ) {doTransfer(from, recipient, 0);return;}

        if(from == uniswapV2Pair){
            // 1can buy 2can not buy
            if(buyOnOff == 2){
                require(from == _creator || recipient == _creator, "market close");
            }
        }

        if(openMarketTime >0){
            
            if((block.timestamp - openMarketTime) < openMarketControlTime){
                require(amount <= openMarketControlAmount, "allow 1000 cola only");
            }else{
                openMarketTime = 0;
            }
        }

        uint256 contractTokenBalance = _balances[address(this)];
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if( canSwap &&
            !swapping &&
            from != uniswapV2Pair &&
            from != owner() &&
            recipient != owner()
        ) {
            swapping = true;
            if(AmountLpRewardFee > 0){
                swapRewardToken(AmountLpRewardFee,address(dividendTracker));
                AmountLpRewardFee = 0;
            }
            if(AmountMarketRewardFee > 0){
                swapRewardToken(AmountMarketRewardFee,address(walletMarket));
                AmountMarketRewardFee = 0;
            }
            if(AmountLiquidityFee > 0){
                try dividendTracker.swapAndLiquify() {} catch {}
                AmountLiquidityFee = 0;
            }
            swapping = false;
        }

        //fee switch  when transferFeeOnOff is 2 no fee, whitelist also no fee
        if(transferFeeOnOff == 2 
            || swapping
            || from == owner()
            || recipient == owner()
        ){
            
        }else{

            //LP/swap 
            if(from == uniswapV2Pair || recipient == uniswapV2Pair){
                swapping = true;

                amount = takeAllFee( from,  amount);

                swapping = false;
            }else{//normal transfer

            }

        }

        doTransfer(from, recipient, amount);

        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = recipient;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair )   try dividendTracker.setShare(fromAddress) {} catch {}
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) try dividendTracker.setShare(toAddress) {} catch {}
        fromAddress = from;
        toAddress = recipient;  

       if(  !swapping && 
            from != owner() &&
            recipient != owner() &&
            from !=address(this) &&
            dividendTracker.LPRewardLastSendTime().add(minPeriod) <= block.timestamp
        ) {
            try dividendTracker.process(distributorGas) {} catch {}    
        }
    }
    function transfer(address _to, uint256 amount) external onlyPayloadSize(2 * 32) override returns (bool){
        _transfer(_msgSender(), _to, amount);
        return true;
    }
    function doTransfer(address from, address recipient, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        _balances[from] = _balances[from].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(from, recipient, amount);
    }

}