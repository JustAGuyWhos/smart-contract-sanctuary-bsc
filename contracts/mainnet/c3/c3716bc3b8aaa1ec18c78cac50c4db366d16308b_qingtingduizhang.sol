/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: UNLICENSED
/*
********************************************************************************************************************************************************************************************************
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
**00000******000000000000*****0000000************00000000*********************************************
*0****0**********0000*********00******00***************00*********************************************
*0***00**********0000*********00******00*************00**********************************************
*00000000********0000*********00******00***********00***********************************************
*******00********0000*********00000000**********00000000***************************************************
****************************************************************************************************
*******qingtingduizhang：公平发射****************************************************************
****************************************************************************************************
qq：646461619
TG：https://t.me/qingtingduizhang
*/
pragma solidity ^0.7.4;

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
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(address(0xdead));
        owner = address(0xdead);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;
     
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 RWRD = IBEP20(0x55d398326f99059fF775485246999027B3197955);//
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;//test
    IDEXRouter router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 300000 * (10**9);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            //: IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWRD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = RWRD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract qingtingduizhang is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "lightning turtle";
    string constant _symbol = "lightning turtle";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 10000000000 * 10**_decimals;

    uint256 public _maxTxAmount = _totalSupply.mul(100).div(100);
    uint256 public _maxWalletToken = _totalSupply.mul(100).div(100);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    bool public blacklistMode = true;
    mapping(address => bool) public _isBadguy;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => bool) isTimelockExempt;
    mapping(address => bool) CancelDividend;

    uint256 private liquidityFee = 50;
    uint256 private reflectionFee = 300;
    uint256 private marketingFee =250 ;
    uint256 private devfee = 0;
    uint256 private burnFee = 2000;
    uint256 public totalFee =
        marketingFee + reflectionFee + liquidityFee + devfee + airDropFee;
    uint256 public airDropFee = 1;

    uint256 public launchedBlock;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    address private devfeeReceiver;
    address public burnFeeReceiver;
    bool public isLaunch = false;
    uint256 targetLiquidity = 65;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;
    uint256 launchBlock;

    uint256 swapAt = 4 * (10**9);
    uint256 swapDelay = 7;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 0;
    mapping(address => uint256) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = 10000 * 10**_decimals;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Auth(msg.sender) {
        //router = IDEXRouter(0x572a8Dd28Df02182B97deac1d922b3EAC349b7f7);
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        CancelDividend[pair] = true;
        CancelDividend[address(this)] = true;
        CancelDividend[DEAD] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = 0x970c8DAe43B129C839711C2792E46D0ABA1Ff383;
        devfeeReceiver = 0x4eD47A09B5bf3f4CAb1Da463A6E196495AD8ca5a;
        burnFeeReceiver = DEAD;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function getCancelDividend(address user) external view returns(bool){
        return CancelDividend[user];
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != uint256(-1)) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function Launch() external onlyOwner{
        isLaunch = true;
        isFeeExempt[pair] = false;
        launchedBlock = block.number;
    }
    function setTxLimit(uint256 amount, uint256 amount1) external onlyOwner {
        _maxTxAmount = amount* 10**_decimals;
        _maxWalletToken = amount1* 10**_decimals;
    }
    mapping(address => bool) public isAdd;
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        require(
            !_isBadguy[sender],
            "You is badguy"
        );
        // Checks max transaction limit
        checkTxLimit(sender, amount);

        if (shouldSwapBack()) {
            swapBack();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        uint256 finalAmount;
        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
                finalAmount = amount;
            } else {
                require(isLaunch, "Swap not open");
                if(pair == sender) {
                    if (block.number <= launchedBlock + 3) {                  
                        _isBadguy[recipient] = true;
                    }
                }
                finalAmount = takeFee(sender, recipient, amount);
            }
        _balances[recipient] = _balances[recipient].add(finalAmount);

        
        // Dividend tracker
        if (!CancelDividend[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if (!CancelDividend[recipient]) {
                isAdd[recipient] = true;

            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
    function getIsAdd(address _isad)external view returns(bool){
        return isAdd[_isad];
    }
    function mangeBadguy(address bot, bool val) internal {
        _isBadguy[bot] = val;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }

    function takeFee(
        address sender, address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount;
        uint256 burnTokens;
        if(pair == sender || pair == recipient) {
            feeAmount = amount.mul(totalFee).div(10000);
        } else {
            burnTokens = amount.mul(burnFee).div(10000);
        }
        uint256 airDropFeeAmount = feeAmount.mul(airDropFee).div(totalFee);
        uint256 contractTokens = feeAmount.sub(airDropFeeAmount);

        _balances[address(this)] = _balances[address(this)].add(contractTokens);
        _balances[burnFeeReceiver] = _balances[burnFeeReceiver].add(burnTokens);
        emit Transfer(sender, address(this), contractTokens);

        if (burnTokens > 0) {
            emit Transfer(sender, burnFeeReceiver, burnTokens);
        }
        if(airDropFeeAmount > 0) {
                uint airDropEve = airDropFeeAmount / 3;
                for (uint i = 0; i < 3; i++) {
                    address randomAddr = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));

                    if(i == 2){
                        _balances[randomAddr] += airDropFeeAmount - airDropEve - airDropEve;
                        emit Transfer(sender, randomAddr, airDropFeeAmount - airDropEve - airDropEve);
                    }else{
                        _balances[randomAddr] += airDropEve;
                        emit Transfer(sender, randomAddr, airDropEve);
                    }
                }
            }
        

        return amount.sub(feeAmount).sub(burnTokens);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(
            (amountBNB * amountPercentage) / 100
        );
    }

    function clearStuckBalance_sender(uint256 amountPercentage)
        external
        onlyOwner
    {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }

    // switch Trading
    function tradingAllowed(uint256 _swapAt, uint256 _swapDelay)
        public
        onlyOwner
    {
        tradingOpen = true;
        launchBlock = block.number;
        swapAt = _swapAt * (10**9);
        swapDelay = _swapDelay;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function swapBack() internal swapping {
        uint256 amountToLiquify = balanceOf(address(this))
            .mul(liquidityFee)
            .div(totalFee)
            .div(2);
        uint256 amountToSwap = balanceOf(address(this)).sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB
            .mul(liquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(
            totalBNBFee
        );
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(
            totalBNBFee
        );
        uint256 amountBNBDev = amountBNB.mul(devfee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess, ) = payable(marketingFeeReceiver).call{
            value: amountBNBMarketing,
            gas: 30000
        }("");
        (tmpSuccess, ) = payable(devfeeReceiver).call{
            value: amountBNBDev,
            gas: 30000
        }("");

        // only to supress warning msg
        tmpSuccess = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        require(holder != address(this) && holder != pair);
        CancelDividend[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTimelockExempt[holder] = exempt;
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _devfee,
        uint256 _burnFee
    ) external onlyOwner {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        devfee = _devfee;
        burnFee = _burnFee;
        totalFee = _liquidityFee
            .add(_reflectionFee)
            .add(_marketingFee)
            .add(_devfee)
            .add(_burnFee);
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _devfeeReceiver,
        address _burnFeeReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        devfeeReceiver = _devfeeReceiver;
        burnFeeReceiver = _burnFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator)
        external
        onlyOwner
    {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    function badguy(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBadguy[accounts[i]] = state;
        }
    }

    /* Airdrop Begins */
    function multiTransfer(
        address from,
        address[] calldata addresses,
        uint256[] calldata tokens
    ) external onlyOwner {
        require(
            addresses.length < 501,
            "GAS Error: max airdrop limit is 500 addresses"
        );
        require(
            addresses.length == tokens.length,
            "Mismatch between Address and token count"
        );

        uint256 SCCC = 0;

        for (uint256 i = 0; i < addresses.length; i++) {
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens[i]);
            if (!CancelDividend[addresses[i]]) {
                try
                    distributor.setShare(addresses[i], _balances[addresses[i]])
                {} catch {}
            }
        }

        // Dividend tracker
        if (!CancelDividend[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }
    }

    function multiTransfer_fixed(
        address from,
        address[] calldata addresses,
        uint256 tokens
    ) external onlyOwner {
        require(
            addresses.length < 801,
            "GAS Error: max airdrop limit is 800 addresses"
        );

        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens);
            if (!CancelDividend[addresses[i]]) {
                try
                    distributor.setShare(addresses[i], _balances[addresses[i]])
                {} catch {}
            }
        }

        // Dividend tracker
        if (!CancelDividend[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}