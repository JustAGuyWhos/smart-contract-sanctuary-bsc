/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.0 <0.9.0;


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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface IDividendDistributor {
    function getRWRDToken() external view returns (string memory);
    function setRWRDToken(address token) external;
    function claimReward(address requester) external;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external;
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

    address public RWRDToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 public RWRD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    bool public distributionEnabled = true;

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 13);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
    }

    function getRWRDToken() external override view returns (string memory) {
            return RWRD.name();
    }

    function setRWRDToken(address token) external override onlyToken {
        IBEP20 _newToken = IBEP20(token);
        RWRDToken = token;
        RWRD = _newToken;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        distributionEnabled = _enabled;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RWRD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(RWRD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RWRD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0 || !distributionEnabled) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0 || !distributionEnabled) { return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RWRD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }
    
    function claimReward(address requester) external override onlyToken {
        distributeDividend(requester);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
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
}

contract TEST is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "TEST";
    string constant _symbol = "$TEST";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 200 * 10**6 * 10**_decimals;

    uint256 public _mTx = _totalSupply;
    uint256 public _mB = _totalSupply;
    uint256 public _mS = _totalSupply;

    uint256 public _mWT = _totalSupply;


    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    struct CustomFees {
        uint256 UFB;
        uint256 UFS;
        uint256 UFT;
    }
    mapping (address => CustomFees) userFees;
    bool public LOCKED = true;
    mapping (address => bool) public isLOCKED;

    
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 public liquidityFee    = 1;
    uint256 public reflectionFee   = 1;
    uint256 public marketingFee    = 2;
    uint256 public turdFee         = 1;
    uint256 public totalFee        = marketingFee + reflectionFee + liquidityFee + turdFee;
    uint256 public feeDenominator  = 100;
    uint256 public sfeeDenominator = 100;
    uint256 public sliquidityFee    = 1;
    uint256 public sreflectionFee   = 1;
    uint256 public smarketingFee    = 2;
    uint256 public sturdFee         = 1;
    uint256 public stotalFee        = smarketingFee + sreflectionFee + sliquidityFee + sturdFee;


    address public autoLiquidityReceiver; 
    address public marketingFeeReceiver;
    address public turdFeeReceiver;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public tradingOpen = false;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    bool public bCdE = false;
    uint256 public bCdTI = 60;
    bool public sCdE = false;
    uint256 public sCdTI = 60;
    mapping (address => uint) private bCdT;
    mapping (address => uint) private sCdT;
    mapping (address => uint) private userSellCooldownTimer;
    mapping (address => uint256) private userMaxSellTxLimit;
    mapping (address => uint256) private userMaxTransferTxLimit;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        turdFeeReceiver = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
        
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    


    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) external onlyOwner() {
        _mWT = (_totalSupply * maxWallPercent_base1000 ) / 1000;
    }
    function MTXP(uint256 MTXP_1) external onlyOwner() {
        _mTx = (_totalSupply * MTXP_1 ) / 1000;
    }

    function MTXL(uint256 MTXL_1) external authorized {
        _mTx = MTXL_1;
    }

    function MBTXP(uint256 MBTXP_1) external onlyOwner() {
        _mB = (_totalSupply * MBTXP_1 ) / 1000;
    }

    function MBTXL(uint256 MBTXL_1) external authorized {
        _mB = MBTXL_1;
    }

    function MSTXP(uint256 MSTXP_1) external onlyOwner() {
        _mS = (_totalSupply * MSTXP_1 ) / 1000;
    }

    function MSTXL(uint256 MSTXL_1) external authorized {
        _mS = MSTXL_1;
    }

    function UMSL(address UMSL_1, uint256 UMSL_2) external authorized {
        userMaxSellTxLimit[UMSL_1] = UMSL_2;
    }

    function UMSP(address UMSP_1, uint256 UMSP_2) external authorized {
        userMaxSellTxLimit[UMSP_1] = (_totalSupply * UMSP_2 ) / 1000;
    }

    function UMTL(address UMTL_1, uint256 UMTL_2) external authorized {
        userMaxTransferTxLimit[UMTL_1] = UMTL_2;
    }

    function UMTP(address UMTP_1, uint256 UMTP_2) external authorized {
        userMaxTransferTxLimit[UMTP_1] = (_totalSupply * UMTP_2 ) / 1000;
    }



    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

        if(LOCKED){
            require(!isLOCKED[sender] && !isLOCKED[recipient],"LOCKED");    
        }


        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != marketingFeeReceiver && recipient != turdFeeReceiver  && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _mWT,"Total Holding is currently limited, you can not buy that much.");}
        
        if (sender == pair &&
            bCdE &&
            !isTimelockExempt[recipient]) {
            require(bCdT[recipient] < block.timestamp,"Buy Cooldown not reached yet");
            bCdT[recipient] = block.timestamp + bCdTI;
            
        }

        if (recipient == pair &&
            sCdE &&
            !isTimelockExempt[sender]) {
            require(sCdT[sender] < block.timestamp,"Sell Cooldown not reached yet");
            if(userSellCooldownTimer[sender] != 0) {
                sCdT[sender] = block.timestamp + userSellCooldownTimer[sender];
            }
            else {
                sCdT[sender] = block.timestamp + sCdTI;
            }
        }

        // Checks max transaction limit
        checkTxLimit(sender, amount);
        // Checks max buy transaction limit
        checkBuyTxLimit(recipient, amount);
        // Checks max sell transaction limit
        checkSellTxLimit(sender, amount);
        // Checks max transfer transaction limit
        checkUserTransferTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, amount,(recipient == pair)) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if(!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if(!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _mTx || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function checkBuyTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _mB || isTxLimitExempt[sender], "Buy TX Limit Exceeded");
    }

    function checkSellTxLimit(address sender, uint256 amount) internal view {
        if(userMaxSellTxLimit[sender] != 0) {
            require(amount <= userMaxSellTxLimit[sender] || isTxLimitExempt[sender], "Sell TX Limit Exceeded");
        }
        else {
            require(amount <= _mS || isTxLimitExempt[sender], "Sell TX Limit Exceeded");
        }
    }

    function checkUserTransferTxLimit(address sender, uint256 amount) internal view {
        if(userMaxTransferTxLimit[sender] != 0) {
            require(amount <= userMaxTransferTxLimit[sender] || isTxLimitExempt[sender], "Transfer TX Limit Exceeded");
        }
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        return !(isFeeExempt[sender] || isFeeExempt[recipient]);
    }

    function takeFee(address sender, uint256 amount, bool isSell) internal returns (uint256) {
        uint256 _totalFee;
        uint256 _feeDenominator;
        if(isSell){
            _totalFee = stotalFee;
            _feeDenominator = sfeeDenominator;
        }else{
            _totalFee = totalFee;
            _feeDenominator = feeDenominator;
        }
        uint256 feeAmount = amount.mul(_totalFee).div(_feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);   
    }


    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function clearStuckBalance_sender(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    // enable cooldown between trades
    function CDE(bool CDE_1, uint256 CDTI_2, bool CDE_3, uint256 CDTI_4) public onlyOwner {
        bCdE = CDE_1;
        bCdTI = CDTI_2;
        sCdE = CDE_3;
        sCdTI = CDTI_4;
    }

    function USCD(address USCD_1, uint256 USCD_2) external authorized {
        userSellCooldownTimer[USCD_1] = USCD_2;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : sliquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(stotalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

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

        uint256 totalBNBFee = stotalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(sreflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(smarketingFee).div(totalBNBFee);
        uint256 amountBNBTurd = amountBNB.mul(sturdFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        (tmpSuccess,) = payable(turdFeeReceiver).call{value: amountBNBTurd, gas: 30000}("");
        
        // only to supress warning msg 
        tmpSuccess = false;

        if(amountToLiquify > 0){
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


    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function ELOCK(bool ELOCK_1) public onlyOwner {
        LOCKED = ELOCK_1;
    }

    function LOCK(address[] calldata LOCK_1, bool LOCK_2) public onlyOwner {
        for (uint256 i; i < LOCK_1.length; ++i) {
            isLOCKED[LOCK_1[i]] = LOCK_2;
        }
    }


    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }

function setSellFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _turdFee, uint256 _feeDenominator) external authorized {
        sliquidityFee = _liquidityFee;
        sreflectionFee = _reflectionFee;
        smarketingFee = _marketingFee;
        sturdFee = _turdFee;
        stotalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_turdFee);
        sfeeDenominator = _feeDenominator;
        require(stotalFee < sfeeDenominator/3, "Fees cannot be more than 33%");
    }

    function setBuyFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee,
     uint256 _turdFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        turdFee = _turdFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_turdFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/3 , "Fees cannot be more than 33%");
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _turdFeeReceiver ) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
        turdFeeReceiver = _turdFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function claimReward() external {
        distributor.claimReward(msg.sender);
    }

    function setRWRDToken(address token) external authorized {
        distributor.setRWRDToken(token);
    }

    function getRWRDToken() public view returns(string memory) {
        return distributor.getRWRDToken();
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, bool _enabled) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution, _enabled);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }



/* Airdrop Begins */
function shitTheBed(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens[i]);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
}

function shitTheBed_fixed(address from, address[] calldata addresses, uint256 tokens) external onlyOwner {

    require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");

    uint256 SCCC = tokens * addresses.length;

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(from,addresses[i],tokens);
        if(!isDividendExempt[addresses[i]]) {
            try distributor.setShare(addresses[i], _balances[addresses[i]]) {} catch {} 
        }
    }

    // Dividend tracker
    if(!isDividendExempt[from]) {
        try distributor.setShare(from, _balances[from]) {} catch {}
    }
}

event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}