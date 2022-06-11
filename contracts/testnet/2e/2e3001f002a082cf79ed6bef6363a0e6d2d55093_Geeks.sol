// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.2;

import "./DividendPayingToken.sol";
import "./SafeMath.sol";
import "./IterableMapping.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";



contract Geeks is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    bool private swapping;

    GEEKSDividendTracker public dividendTracker;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    address public immutable BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD

    uint256 public swapTokensAtAmount = 5000000000000 * (10**18);
    uint256 public _maxWalletAmount = 100000000000000 * (10**18);
    

    mapping(address => bool) public _isBlacklisted;
    mapping(address=>uint) public MustBuyForJackpot;
    mapping(address=>bool) public Added;
    address [] public eligibleForJackpot;
    uint public Winners=1;
    uint256 public totalBusdBurnt=0;
    uint256 public _MustBuyForJackpot = 2000000000000 * (10**18);
    uint public LastJackpotRound=0;
    uint public lastRoundTimestamp;
    mapping (address=>uint) lastBuyTimestamp;

    uint256 public BUSDRewardsFee = 3;
    uint256 public liquidityFee = 1;
    uint256 public BusdburnFee = 1;
    uint256 public JackpotFee = 1;
    uint256 public MarketingFee = 3;
    uint256 public burnFee = 2;
    uint256 public totalFees = BUSDRewardsFee.add(liquidityFee).add(MarketingFee).add(BusdburnFee).add(JackpotFee);

    address public _MarketingWalletAddress = 0x4BD60D7378de771EfB3cAe8520Cce2aA2797fcF7;
    address public _JackpotWalletAddress = 0xFB3928e88356A9151d57A76fc863B8A67Efe6f86;




    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

     // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    uint256 public _sellFee = 13;
    uint256 public _maxSellAmount = 10000000000000 * (10**18);
    uint256 public _totalSupplyToken = 1000000000000000 * (10**18);

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );
    
    event BusdBurnt(
        uint256 tokensBurnt,
        uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() public ERC20("Geeks", "GEEKS") {

    	dividendTracker = new GEEKSDividendTracker();


    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(deadWallet);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        excludeFromFees(_MarketingWalletAddress, true);
        excludeFromFees(address(this), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 1000000000000000 * (10**18));
    }

    receive() external payable {

  	}

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "GEEKS: The dividend tracker already has that address");

        GEEKSDividendTracker newDividendTracker = GEEKSDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "GEEKS: The new dividend tracker must be owned by the GEEKS token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "GEEKS: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "GEEKS: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }


    function setBUSDRewardsFee(uint256 value) external onlyOwner{
        BUSDRewardsFee = value;
       totalFees = BUSDRewardsFee.add(liquidityFee).add(MarketingFee).add(BusdburnFee).add(JackpotFee);
    }
    
    function setBusdburnFee(uint256 value) external onlyOwner{
        BusdburnFee = value;
       totalFees = BUSDRewardsFee.add(liquidityFee).add(MarketingFee).add(BusdburnFee).add(JackpotFee);
       
    }
    
    function setJackpotFee(uint256 value) external onlyOwner{
        JackpotFee = value;
       totalFees = BUSDRewardsFee.add(liquidityFee).add(MarketingFee).add(BusdburnFee).add(JackpotFee);
    }
    
   function setLiquiditFee(uint256 value) external onlyOwner{
       liquidityFee = value;
        totalFees = BUSDRewardsFee.add(liquidityFee).add(MarketingFee).add(BusdburnFee).add(JackpotFee);
    }

    function setMarketingFee(uint256 value) external onlyOwner{
        MarketingFee = value;
       totalFees = BUSDRewardsFee.add(liquidityFee).add(MarketingFee).add(BusdburnFee).add(JackpotFee);
    }

     function setBurnFee(uint256 value) external onlyOwner{
        burnFee = value;
    }

     function setLotteryWallet(address payable wallet) external onlyOwner{
        _JackpotWalletAddress = wallet;
    }
    
    function setswapTokensAtAmount(uint256 value) external onlyOwner{
        swapTokensAtAmount = value*(10**18);
        
    }
    
    function setMaxWallet(uint256 value) external onlyOwner{
        _maxWalletAmount = value.mul(_totalSupplyToken).div(100);
    }

    function setSellAmount(uint256 value) external onlyOwner{
       _maxSellAmount = value*(10**18);
       
       
    }
    function setMustBuyForJackpot(uint256 value) external onlyOwner{
        _MustBuyForJackpot = value*(10**18);
    }
    
    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(_MarketingWalletAddress).transfer(amountBNB * amountPercentage / 100);
    }

    function setWinners(uint value) external onlyOwner{
        Winners = value;
    }
    
    function setSellFee(uint256 value) external onlyOwner{
        _sellFee = value;
    }

    function getEligibleForJackpot() public view returns (uint256) {
        return eligibleForJackpot.length;

    }


    function getPrizePool() public view returns (uint) {
        return address(this).balance;

    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupplyToken.sub(balanceOf(deadWallet));
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "GEEKS: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }
    


    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "GEEKS: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "GEEKS: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "GEEKS: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }
    
    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();

    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(msg.sender, false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    
    function random(uint _rand) internal view returns  (uint) {
   
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, _rand))) % eligibleForJackpot.length ;
   
   
    return randomnumber;
    }
   
   
    function PickWinners(uint percent , uint _rand) external onlyOwner{
        LastJackpotRound++;
        lastRoundTimestamp = block.timestamp;
        
        uint i;
        uint bal = address(this).balance;
        uint jackpotbnbs= bal.mul(percent).div(100);
        uint perperson = jackpotbnbs.div(Winners);
       
       
        for(i=0;i<Winners;i++){
            uint rand = random(_rand);
            _rand = _rand + 1;
            address payable lucky = payable(eligibleForJackpot[rand]);
            lucky.transfer(perperson);
           
           
           
           
        }
       
        delete eligibleForJackpot;
       
       
       
    }
    

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');


        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;


	        if(automatedMarketMakerPairs[from]){

            if (amount >= _MustBuyForJackpot && Added[to] == false) {
			     Added[to] = true;
                eligibleForJackpot.push(to);
          
            }
        }
				
        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            uint256 MarketingTokens = contractTokenBalance.mul(MarketingFee).div(totalFees);
            swapAndSendToFee(MarketingTokens);
            
            uint256 BusdTokens = contractTokenBalance.mul(BusdburnFee).div(totalFees);
            swapAndSendToBurn(BusdTokens);
            
            uint256 JackpotTokens = contractTokenBalance.mul(JackpotFee).div(totalFees);
            swapAndSendToFee3(JackpotTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);

            swapping = false;
        }


        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 burnAmt = amount.mul(burnFee).div(100);
        	uint256 fees = amount.mul(totalFees).div(100);
        	if(automatedMarketMakerPairs[to]){
        	    require(amount <= _maxSellAmount, "Transfer amount exceeds allowed sell amount.");

        	        fees = fees.mul(_sellFee).div(100);
        	  

        	}

            if ((balanceOf(from) - (amount)) <= _MustBuyForJackpot && Added [from] == true) {
				//Sold tokens, end balance below lottery minimum
                Added[from] = false; 
                eligibleForJackpot.pop(); 
                
			}
            
        
        	if(automatedMarketMakerPairs[from]){
        	require(amount + balanceOf(to) <= _maxWalletAmount, "Transfer amount exceeds maxWalletAmount.");
        	 
        	}
        	amount = amount.sub(fees).sub(burnAmt);
            

            super._transfer(from, address(this), fees);
            super._transfer(from, deadWallet, burnAmt);
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}
        }
    }

    function swapAndSendToFee(uint256 tokens) private  {

        uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));

        swapTokensForCake(tokens);
        uint256 newBalance = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);
        IERC20(BUSD).transfer(_MarketingWalletAddress, newBalance);
    }
    
     function swapAndSendToBurn (uint256 tokens) private {
        uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));
        
        swapTokensForCake(tokens);
        uint256 tokensBurnt = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);
        IERC20(BUSD).transfer(deadWallet,tokensBurnt);
        
        totalBusdBurnt = totalBusdBurnt.add(tokensBurnt);

        emit BusdBurnt(tokensBurnt, tokens);
    }
    
    
    function swapAndSendToFee3(uint256 tokens) private  {

        uint256 initialBUSDBalance = IERC20(BUSD).balanceOf(address(this));

        swapTokensForCake(tokens);
        uint256 newBalance = (IERC20(BUSD).balanceOf(address(this))).sub(initialBUSDBalance);
        IERC20(BUSD).transfer(_JackpotWalletAddress, newBalance);
    }
    
    function swapAndLiquify(uint256 tokens) private {
       // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }


    function swapTokensForEth(uint256 tokenAmount) private {


        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapTokensForCake(uint256 tokenAmount) private {

        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = BUSD;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );

    }
    
    
    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForCake(tokens);
        uint256 dividends = IERC20(BUSD).balanceOf(address(this));
        bool success = IERC20(BUSD).transfer(address(dividendTracker), dividends);

        if (success) {
            dividendTracker.distributeBUSDDividends(dividends);
            emit SendDividends(tokens, dividends);
        }
    }
}

contract GEEKSDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() public DividendPayingToken("GEEKS_Dividen_Tracker", "GEEKS_Dividend_Tracker") {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 10000000000 * (10**18); //must hold 1000+ tokens
    }

    function _transfer(address, address, uint256) internal override {
        require(false, "GEEKS_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public override {
        require(false, "GEEKS_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main GEEKS contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "GEEKS_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "GEEKS_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }



    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}