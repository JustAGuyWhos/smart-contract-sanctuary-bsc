/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

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

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
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

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner onlyOwner
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract MachinaToken is IBEP20, Ownable {
    
    using SafeMath for uint256;

    string constant _name = "Ex china";
    string constant _symbol = "Ex china";
    uint8 constant _decimals = 18;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
	address marketingAddress = 0xd875fc25F50EfdDfcd5070eB7c78aA80ae682Db7; //market wallet

    uint256 _totalSupply = 1 * 10000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _walletMax = _totalSupply ;
    
    bool public restrictWhales = true;

    mapping (address => bool) public areadyKnowContracts;

    bool public gasLimitOpen = true;
    uint256 public maxGasOfBot = 10000000000;
    mapping (address => bool) public gasBlockList;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;
	
	mapping (address => bool) public exchangePairs;

    uint256 public liquidityFee = 10;
    uint256 public rewardsFee = 0;
	uint256 public marketingFee = 50;
	
	//sell extra add 3% fee.
    uint256 public extraFeeOnSell = 0;
    uint256 public burnPercentage = 0;

    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;

    address public autoLiquidityReceiver = marketingAddress;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public antiBotOpen = true;
    bool public tradingOpen = false;
    uint256 public silentBlockNumber = 3;
    uint256 public minReverse = 0;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = _totalSupply * 5 / 4000;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () Ownable(msg.sender) {
        
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = 2**256 - 1;

        minReverse = (10**_decimals)/100000;
		
		exchangePairs[pair] = true;

        areadyKnowContracts[pair] =  true;
        areadyKnowContracts[address(this)] =  true;
        areadyKnowContracts[routerAddress] =  true;  

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;
        
        totalFee = liquidityFee.add(rewardsFee).add(marketingFee);
        totalFeeIfSelling = totalFee.add(extraFeeOnSell);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
    

    function name() external pure override returns (string memory) { return _name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function getOwner() external view override returns (address) { return owner; }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, 2**256 - 1);
    }

    function changeTxLimit(uint256 newLimit) external onlyOwner {
        _maxTxAmount = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function changeRestrictWhales(bool newValue) external onlyOwner {
       restrictWhales = newValue;
    }
    
    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }


    function changeFees(uint256 newLiqFee, uint256 newRewardFee,uint256 newMarkingFee,uint256 newExtraSellFee) external onlyOwner {
        liquidityFee = newLiqFee;
        rewardsFee = newRewardFee;
		marketingFee = newMarkingFee;
        extraFeeOnSell = newExtraSellFee;
        
        totalFee = liquidityFee.add(rewardsFee).add(marketingFee);
        totalFeeIfSelling = totalFee.add(extraFeeOnSell);
    }

    function changeFeeReceivers(address newLiquidityReceiver) external onlyOwner {
        autoLiquidityReceiver = newLiquidityReceiver;
    }

    function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit, bool swapByLimitOnly) external onlyOwner {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
        swapAndLiquifyByLimitOnly = swapByLimitOnly;
    }

    function setSilentBlockNumber(uint256 newValue) external onlyOwner {
		silentBlockNumber = newValue;
	}

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setAntiBot(bool newValue) external onlyOwner {
        antiBotOpen=newValue;
    }

    function setAreadyKnowAddress(address addr,bool newValue) external onlyOwner {
        areadyKnowContracts[addr] = newValue;
    }

    function antiBot(address sender,address recipient) public{
        if (block.number > launchedAt + 4) {
            return;
        }

        //While in silent block. sell not allowed .
        if(exchangePairs[recipient]){
            require( block.number > launchedAt + silentBlockNumber,"silent block");
        }

        //Contract sell not allowed.
        bool isBotSell = (!areadyKnowContracts[sender] && isContract(sender) ) && exchangePairs[recipient];
        require( isBotSell == false,"anti bot sell");

        //Check gas Block list of sell.
        if(gasLimitOpen && !areadyKnowContracts[sender] && exchangePairs[recipient]){
            require(!gasBlockList[sender],"anti height gas");
        }

        //Check the gas of buy
        if(gasLimitOpen && exchangePairs[sender] && !areadyKnowContracts[recipient] && tx.gasprice > maxGasOfBot ){
            //if gas is to height . add to block list
            gasBlockList[recipient] =  true;
        }

    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != 2**256 - 1){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(inSwapAndLiquify || isFeeExempt[sender] || isFeeExempt[recipient] ){ return _basicTransfer(sender, recipient, amount); }

        //anti the bot.
        if(!isFeeExempt[sender] && !isFeeExempt[recipient] && antiBotOpen){
            antiBot(sender,recipient);
        }

        if(!isFeeExempt[sender] && !isFeeExempt[recipient]){
            require(tradingOpen, "Trading not open yet");
        }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }

        if(amount <= minReverse){
            return true;
        }

        amount -= minReverse;

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if(!isTxLimitExempt[recipient] && restrictWhales)
        {
            require(_balances[recipient].add(amount) <= _walletMax);
        }

        uint256 finalAmount = takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeApplicable = pair == recipient ? totalFeeIfSelling : totalFee;
        uint256 feeAmount = amount.mul(feeApplicable).div(1000);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function tradingStatus(bool newStatus) public onlyOwner {
        tradingOpen = newStatus;
        if(tradingOpen){
            launchedAt = block.number;
        }else{
            launchedAt = 0;
        }
    }

    function gasLimitStatus(uint256 maxGasPrice, bool newStatus) public onlyOwner {
        gasLimitOpen = newStatus;
        maxGasOfBot = maxGasPrice;
    }

    function setGasBlockList(address acc,bool status)  public onlyOwner {
        gasBlockList[acc] = status;
    }

    function swapBack() internal lockTheSwap {
        
        uint256 tokenToSwap = _balances[address(this)];
        uint256 amountToLiquify = tokenToSwap.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = tokenToSwap.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
		uint256 amountBNBMarking = amountBNB.sub(amountBNBLiquidity);

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
		
		if( amountBNBMarking > 0){
			TransferHelper.safeTransferETH(marketingAddress, amountBNBMarking);
		}
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountMETA);

}