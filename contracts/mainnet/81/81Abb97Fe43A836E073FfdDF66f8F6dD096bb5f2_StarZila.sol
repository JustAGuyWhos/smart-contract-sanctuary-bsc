// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/BEP20.sol";
import "./rebase/RebaseMethods.sol";
import "./helpers/Ownable.sol";

import "./reflection/ReflectionTracker.sol";
import "./reflection/ReflectionEvents.sol";
import "./utils/IterableMapping.sol";

contract StarZila is ReflectionEvents, RebaseMethods, BEP20("StarZila", "STZ"), Ownable {
    using SafeMath for uint;

    ReflectionTracker public reflectionTracker;

    mapping(address => bool) public _isBlacklisted;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _ammPairs;
    mapping ( address => bool ) public _dexAddresses;
    mapping (address => bool) private canTransferBeforeTradingIsEnabled;

    uint256 public reflectionFee = 100;
    uint256 public totalFees = reflectionFee;
    uint256 public sellReflectionFee = 150;
    uint256 public totalSellFees = sellReflectionFee;
    uint256 public gasForProcessing = 300000;
    uint256 public accReflectionFee;

    uint256 public MIN_AMOUNT_DISTRIBUTE = 10_000 ether;
    uint256 public stzReflection = 3000;
    uint256 public bnbReflection = 7000;
    uint256 public dec = 1e4;

    bool public tradingEnabled;
    bool private swapping;

    address public _owner;

    modifier isSwapping() {
        swapping = true;
        _;
        swapping = false;
    }

    constructor(address owner) {

        reflectionTracker = new ReflectionTracker();

        _owner = owner;
        _totalSupply = INITIAL_SUPPLY;
        _divBalances[owner] = TOTAL_DIVS;

        _divsPerFragment = TOTAL_DIVS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        
        _autoRebase = true;
        _isFeeExempt[owner] = true;
        _isFeeExempt[address(this)] = true;
        
        // _transferOwnership(owner);

        reflectionTracker.excludeFromReflections(address(reflectionTracker));
        reflectionTracker.excludeFromReflections(address(this));
        // reflectionTracker.excludeFromReflections(_owner);
        reflectionTracker.excludeFromReflections(DEAD);

        excludeFromFees(address(this), true);
        excludeFromFees(owner, true);

        canTransferBeforeTradingIsEnabled[owner] = true;
        emit Transfer(address(0x0), owner, _totalSupply);
    }

    function updateOwner(address owner) external onlyOwner {
        _owner = owner;
        
        _autoRebase = true;
        _isFeeExempt[_owner] = true;
        _isFeeExempt[address(this)] = true;
        excludeFromFees(owner, true);

        canTransferBeforeTradingIsEnabled[owner] = true;
    }

    // Setter Functions
    function setBuyFees(uint256 _reflectionFee)  external onlyOwner {
        reflectionFee = _reflectionFee;
        totalFees = reflectionFee;
        emit SetBuyFees(_reflectionFee);
    }

    function setSellFees(uint256 _sellreflectionFee)  external onlyOwner {
        totalSellFees = _sellreflectionFee;
        emit SetSellFees(_sellreflectionFee);
    }

    function setTradingIsEnabled() external onlyOwner {
        tradingEnabled = !tradingEnabled;
    }

    function setAccountCanTransferBefore(address account, bool status) external onlyOwner {
        canTransferBeforeTradingIsEnabled[account] = status;
    }

    function excludeFromReflections(address account) external onlyOwner {
        reflectionTracker.excludeFromReflections(account);
    }

    function isExcludedFromReflections(address account) external view returns (bool){
        return reflectionTracker.excludedFromReflections(account);
    }

    function updateReflectionTracker(address newAddress) public onlyOwner {
        require(newAddress != address(reflectionTracker), "StarZila: Exists");

        ReflectionTracker newReflectionTracker = ReflectionTracker(payable(newAddress));

        require(newReflectionTracker.owner() == address(this), "Not Owned by StarZila Token");

        newReflectionTracker.excludeFromReflections(address(newReflectionTracker));
        newReflectionTracker.excludeFromReflections(address(this));
        newReflectionTracker.excludeFromReflections(address(router));

        emit UpdateReflectionTracker(newAddress, address(reflectionTracker));

        reflectionTracker = newReflectionTracker;
    }

    function updatePancakeRouter(address newAddress) public onlyOwner {
        require(newAddress != address(router), "StarZila: Exists!");
        emit UpdatePancakeRouter(newAddress, address(router));

        router = IRouter02(newAddress);
        // _allowedSplits[address(this)][address(router)] = type(uint256).max;

        address _pair = IFactory(router.factory()).createPair(address(this), router.WETH());
        pair = _pair;
        pairAddress = pair;
        pairContract = IPair(pair);

        _setDexAddresses(router, true);
        _setAMMAddresses(address(pair), true);

        // reflectionTracker.excludeFromReflections(address(router));

        // _isExcludedFromFees[newAddress] = true;
        // _isExcludedFromAmountLimit[newAddress] = true;
        // _isExcludedFromPeriodLimit[newAddress] = true;
        // _isExcludedFromPeriodLimit[address(pair)] = true;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "StarZila: Between 200k - 500k");
        require(newValue != gasForProcessing, "StarZila: Same");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        reflectionTracker.updateClaimWait(claimWait);
    }

    function setDexAddresses(IRouter02 _router, bool value) public onlyOwner {
        require(address(router) != address(_router), "StarZila: P1");

        _setDexAddresses(_router, value);
    }

    function _setDexAddresses(IRouter02 _router, bool value) private {
        require(_dexAddresses[address(_router)] != value, "StarZila: No Change!");
        _dexAddresses[address(_router)] = value;

        if(value) {
            _allowedSplits[address(this)][address(_router)] = type(uint256).max;

            reflectionTracker.excludeFromReflections(address(_router));
            _isExcludedFromFees[address(_router)] = true;
            
        }
    }

    function setAMMAddresses(address _pair, bool value) public onlyOwner {
        require(address(pair) != address(_pair), "StarZila: P1");

        _setAMMAddresses(_pair, value);
    }

    function _setAMMAddresses(address _pair, bool value) private {
        require(_ammPairs[address(_pair)] != value, "StarZila: No Change!");
        _ammPairs[address(_pair)] = value;

        if(value) {
            reflectionTracker.excludeFromReflections(_pair);
        }
    }

    function setRebaseRates(uint idx, uint256 value) external onlyOwner {
        rebaseRates[idx] = value;
    }

    function setRebaseOccurence(uint _interval) external onlyOwner {
        _rebaseOccurence = _interval;
    }

    // Excluding Functions
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "StarZila: Exists!");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    // Getter Functions
    function getClaimWait() external view returns(uint256) {
        return reflectionTracker.claimWait();
    }

    function getTotalReflectionsDistributedBNB() external view returns (uint256) {
        return reflectionTracker.totalReflectionsDistributedBNB();
    }

    function getTotalReflectionsDistributedSTZ() external view returns (uint256) {
        return reflectionTracker.totalReflectionsDistributedSTZ();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableReflectionOfBNB(address account) public view returns(uint256) {
        return reflectionTracker.withdrawableReflectionOfBNB(account);
    }

    function withdrawableReflectionOfSTZ(address account) public view returns(uint256) {
        return reflectionTracker.withdrawableReflectionOfSTZ(account);
    }

    function reflectionTokenBalanceOf(address account) public view returns (uint256) {
        return reflectionTracker.balanceOf(account);
    }

    function getAccountReflectionsInfo(address account) external view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256, uint256, uint256 ) {
        return reflectionTracker.getAccount(account);
    }

    function getAccountReflectionsInfoAtIndex(uint256 index) external view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256, uint256, uint256 ) {
        return reflectionTracker.getAccountAtIndex(index);
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return reflectionTracker.getLastProcessedIndex();
    }

    function getNumberOfReflectionTokenHolders() external view returns(uint256) {
        return reflectionTracker.getNumberOfTokenHolders();
    }

    function getTradingIsEnabled() public view returns (bool) {
        return tradingEnabled;
    }

    // Claim Functions
    function processReflectionTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = reflectionTracker.process(gas);
        emit ProcessedReflectionTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        reflectionTracker.processAccount(payable(msg.sender), false);
    }

    // Reflection Functions
    function swapTokensForBNB(uint256 tokenAmount) internal {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapAndDistributeBNB(uint256 tokens) internal {
        uint256 _stzReflection = tokens.mul(stzReflection).div(dec);
        uint256 _bnbReflection = tokens.mul(bnbReflection).div(dec);

        swapTokensForBNB(_bnbReflection);
        uint256 balance = address(this).balance;
        uint256 forReflections = balance;

        _transfer(address(this), address(reflectionTracker), _stzReflection);

        reflectionTracker.distributeReflections{value: forReflections}();
        
        // (bool success,) = address(reflectionTracker).call{value: forReflections}("");
        emit SwapAndSendTo(accReflectionFee, forReflections, "REFLECTIONS");
        accReflectionFee = 0;
    }

    // Internal Transfer Functions
    function transfer(address to, uint256 value) public override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom( address from, address to, uint256 value ) public override validRecipient(to) returns (bool) {
        if (_allowedSplits[from][msg.sender] != type(uint256).max) {
            _allowedSplits[from][msg.sender] = _allowedSplits[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount ) internal returns (bool) {
        uint256 divAmount = amount.mul(_divsPerFragment);
        _divBalances[from] = _divBalances[from].sub(divAmount);
        _divBalances[to] = _divBalances[to].add(divAmount);
        return true;
    }

    function _transferFrom( address sender, address recipient, uint256 amount ) internal returns (bool) {
        if(amount == 0) {
            _basicTransfer(sender, recipient, 0);
            return true;
        }

        if (swapping) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldRebase()) {
           rebase();
        }

        bool tradingIsEnabled = getTradingIsEnabled();

        if(!tradingIsEnabled) {
            require(canTransferBeforeTradingIsEnabled[sender], "StarZila: Trading disabled");
        }

        if (!swapping && !_ammPairs[sender] && !_ammPairs[recipient] && sender != owner() && recipient != owner() ) {
            if ( balanceOf(address(this)) >= MIN_AMOUNT_DISTRIBUTE) {
                swapping = true;
                swapAndDistributeBNB(balanceOf(address(this)));
                swapping = false;
            }
        }

        uint256 divAmount = amount.mul(_divsPerFragment);
        _divBalances[sender] = _divBalances[sender].sub(divAmount);
        
        uint256 divAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, divAmount)
            : divAmount;
        _divBalances[recipient] = _divBalances[recipient].add(
            divAmountReceived
        );

        try reflectionTracker.setBalance(payable(sender), balanceOf(sender)) {} catch {}
        try reflectionTracker.setBalance(payable(recipient), balanceOf(recipient)) {} catch {}

        if(!swapping) {
            uint256 gas = gasForProcessing;

            try reflectionTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedReflectionTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            }
            catch {

            }
        }

        emit Transfer(sender, recipient, divAmountReceived.div(_divsPerFragment));
        return true;
    }

    function takeFee(address sender, address recipient, uint256 divAmount ) internal  returns (uint256) {
        uint256 _totalFee = reflectionFee;

        if (_ammPairs[recipient]) {
            _totalFee = sellReflectionFee;
        }

        uint256 feeAmount = divAmount.mul(_totalFee).div(feeDenominator);
        _divBalances[address(this)] = _divBalances[address(this)].add(
            feeAmount
        );

        emit Transfer(sender, address(this), (feeAmount).div(_divsPerFragment));
        return divAmount.sub(feeAmount);
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return (_ammPairs[from] || _ammPairs[to]) && !swapping && !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            tradingEnabled &&
            !_ammPairs[msg.sender]  &&
            !swapping &&
            block.timestamp >= (_lastRebasedTime + _rebaseOccurence);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function distributeBNBReflections() external onlyOwner isSwapping {
        swapAndDistributeBNB(balanceOf(address(this)));
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowedSplits[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        uint256 oldValue = _allowedSplits[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedSplits[msg.sender][spender] = 0;
        } else {
            _allowedSplits[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval( msg.sender, spender, _allowedSplits[msg.sender][spender] );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _allowedSplits[msg.sender][spender] = _allowedSplits[msg.sender][
            spender
        ].add(addedValue);
        emit Approval( msg.sender, spender, _allowedSplits[msg.sender][spender] );
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _allowedSplits[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_DIVS.sub(_divBalances[DEAD]).sub(_divBalances[ZERO])).div(
                _divsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !swapping;
    }

    function manualSync() external {
        IPair(pair).sync();
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = _divBalances[pair].div(_divsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelist(address _addr) external onlyOwner {
        _isFeeExempt[_addr] = true;
    }
    
    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPair(_address);
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view override returns (uint256) {
        return _divBalances[who].div(_divsPerFragment);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
import "../helpers/Context.sol";
import "../helpers/Ownable.sol";
import "../utils/SafeMath.sol";

import "./IBEP20.sol";
import "./IBEP20Metadata.sol";

contract BEP20 is Context, IBEP20, IBEP20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
      address sender,
      address recipient,
      uint256 amount
    ) internal virtual {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");

      _beforeTokenTransfer(sender, recipient, amount);

      uint256 senderBalance = _balances[sender];
      require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
      unchecked {
        _balances[sender] = senderBalance - amount;
      }
      _balances[recipient] += amount;

      emit Transfer(sender, recipient, amount);

      _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
      require(account != address(0), "BEP20: mint to the zero address");

      _beforeTokenTransfer(address(0), account, amount);

      _totalSupply += amount;
      _balances[account] += amount;
      emit Transfer(address(0), account, amount);

      _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
      require(account != address(0), "BEP20: burn from the zero address");

      _beforeTokenTransfer(account, address(0), amount);

      uint256 accountBalance = _balances[account];
      require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
      unchecked {
        _balances[account] = accountBalance - amount;
      }
      _totalSupply -= amount;

      emit Transfer(account, address(0), amount);

      _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Interfaces
import "../interfaces/IBEP20.sol";
import "../interfaces/IRouter.sol";
import "../interfaces/IFactory.sol";
import "../interfaces/IPair.sol";

// Libraries
import "../utils/SafeMath.sol";
import "../utils/SafeBEP20.sol";

// Rebase Files
import "./RebaseEvents.sol";
import "./RebaseInfo.sol";

contract RebaseMethods is RebaseEvents, RebaseInfo {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    receive() external payable {}

    function rebase() internal {
        
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(_rebaseOccurence);
        uint256 epoch = times.mul(15);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = rebaseRates[0];
        } else if (deltaTimeFromInit >= (365 days) && deltaTimeFromInit < ( 720 days )) {
            rebaseRate = rebaseRates[1];
        } else if (deltaTimeFromInit >= (720 days) && deltaTimeFromInit < ( 1095 days )) {
            rebaseRate = rebaseRates[2];
        } else if (deltaTimeFromInit >= (1095 days) && deltaTimeFromInit < ( 1460 days )) {
            rebaseRate = rebaseRates[3];
        } else if (deltaTimeFromInit >= (1460 days)) {
            rebaseRate = rebaseRates[4];
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _divsPerFragment = TOTAL_DIVS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(_rebaseOccurence));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
import "./Context.sol";

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() external onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ReflectionPayingToken.sol";

import "../helpers/Ownable.sol";

import "../utils/SafeMath.sol";
import "../utils/IterableMapping.sol";
import "../utils/SafeMathInt.sol";

contract ReflectionTracker is ReflectionPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromReflections;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait = 1 hours;
    uint256 public immutable minimumTokenBalanceForReflections;

    event ExcludeFromReflections(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() ReflectionPayingToken("ReflectionTracker", "RFLT") {
        claimWait = 3600;
        minimumTokenBalanceForReflections = 0;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "ReflectionTracker: No transfers allowed");
    }

    function withdrawReflectionBNB() public pure override {
        require(false, "ReflectionTracker: withdrawReflection disabled. Use the 'claim' function on the main OBD contract.");
    }

    function withdrawReflectionSTZ() public pure override {
        require(false, "ReflectionTracker: withdrawReflection disabled. Use the 'claim' function on the main OBD contract.");
    }

    function excludeFromReflections(address account) external onlyOwner {
        require(!excludedFromReflections[account]);
        excludedFromReflections[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromReflections(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "ReflectionTracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "ReflectionTracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }



    function getAccount(address _account) public view returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        uint256 withdrawableReflectionsBNB,
        uint256 withdrawableReflectionsSTZ,
        uint256 totalReflectionsBNB,
        uint256 totalReflectionsSTZ,
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


        withdrawableReflectionsBNB = withdrawableReflectionOfBNB(account);
        withdrawableReflectionsSTZ = withdrawableReflectionOfBNB(account);

        totalReflectionsBNB = accumulativeReflectionOfBNB(account);
        totalReflectionsSTZ = accumulativeReflectionOfBNB(account);

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
        uint256,
        uint256,
        uint256) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0, 0, 0);
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
        if(excludedFromReflections[account]) {
            return;
        }

        if(newBalance >= minimumTokenBalanceForReflections) {
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
        uint256 amountBNB = _withdrawReflectionOfUserBNB(account);
        uint256 amountSTZ = _withdrawReflectionOfUserSTZ(account);

        if(amountBNB > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amountBNB, automatic);
            return true;
        }

        if(amountSTZ > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amountSTZ, automatic);
            return true;
        }

        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract ReflectionEvents {
    event UpdateReflectionTracker(address indexed newAddress, address indexed oldAddress);
    event UpdatePancakeRouter(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromPeriodLimit(address indexed account, bool isExcluded);
    event ExcludeFromAmountLimit(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SetTimeLimit(uint256 indexed newValue, uint256 indexed oldValue);
    event SetBuyFees(uint256 ReflectionFee);
    event SetSellFees(uint256 SellReflectionFee);
    event SwapAndSendTo(
        uint256 tokensSwapped,
        uint256 amount,
        string to
    );
    event ProcessedReflectionTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }



    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

contract Context {
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IBEP20.sol";

interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IRouter01 {
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

interface IRouter02 is IRouter01 {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IFactory {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function sync() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
import '../interfaces/IBEP20.sol';
import './SafeMath.sol';
import '../helpers/AddressHelper.sol';

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract RebaseEvents {
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Interfaces
import "../interfaces/IPair.sol";
import "../interfaces/IRouter.sol";

contract RebaseInfo {

    IPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 18;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint8 public constant RATE_DECIMALS = 9;

    uint256 internal constant INITIAL_SUPPLY = 1 * 1e6 * 10**DECIMALS;
    uint256 public feeDenominator = 1e3;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public pairAddress;
    bool public swapEnabled = true;
    IRouter02 public router;
    address public pair;

    bool inSwap = false;

    uint256 internal constant TOTAL_DIVS = MAX_UINT256 - (MAX_UINT256 % INITIAL_SUPPLY);

    uint256 internal constant MAX_SUPPLY = 10_000 * 1e6 * 10**DECIMALS;

    bool public _autoRebase;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _totalSupply;
    uint256 internal _divsPerFragment;
    uint public _rebaseOccurence = 15 minutes;

    mapping(address => uint256) internal _divBalances;
    mapping(address => mapping(address => uint256)) internal _allowedSplits;

    uint256[] public rebaseRates = [68750, 63540, 57290, 50000, 41660];
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Interfaces
import "../interfaces/BEP20.sol";
import "./ReflectionInterfaces.sol";

// Utils
import "../utils/SafeMathInt.sol";
import "../utils/SafeMathUint.sol";

contract ReflectionPayingToken is BEP20, ReflectionPayingTokenInterface, ReflectionPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 constant internal magnitude = 2**128;

    uint256 internal magnifiedReflectionPerShareBNB;
    uint256 internal magnifiedReflectionPerShareSTZ;

    IBEP20 internal stz = IBEP20(address(0));

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedReflectionCorrectionsBNB;
    mapping(address => int256) internal magnifiedReflectionCorrectionsSTZ;

    mapping(address => uint256) internal withdrawnReflectionsBNB;
    mapping(address => uint256) internal withdrawnReflectionsSTZ;

    uint256 public totalReflectionsDistributedBNB;
    uint256 public totalReflectionsDistributedSTZ;

    constructor(string memory _name, string memory _symbol)  BEP20(_name, _symbol) {

    }

    /// @dev Distributes dividends whenever ether is paid to this contract.
    receive() external payable {
        // distributeReflections();
    }

    /// @notice Distributes ether to token holders as dividends.
    /// @dev It reverts if the total supply of tokens is 0.
    /// It emits the `ReflectionsDistributed` event if the amount of received ether is greater than 0.
    /// About undistributed ether:
    ///   In each distribution, there is a small amount of ether not distributed,
    ///     the magnified amount of which is
    ///     `(msg.value * magnitude) % totalSupply()`.
    ///   With a well-chosen `magnitude`, the amount of undistributed ether
    ///     (de-magnified) in a distribution can be less than 1 wei.
    ///   We can actually keep track of the undistributed ether in a distribution
    ///     and try to distribute it in the next distribution,
    ///     but keeping track of such data on-chain costs much more than
    ///     the saved ether, so we don't do that.
    function distributeReflections() public override payable {
        require(totalSupply() > 0);

        if (msg.value > 0) {
            magnifiedReflectionPerShareBNB = magnifiedReflectionPerShareBNB.add(
                (msg.value).mul(magnitude) / totalSupply()
            );

            emit ReflectionsDistributed(msg.sender, msg.value);
            totalReflectionsDistributedBNB = totalReflectionsDistributedBNB.add(msg.value);
        }

        if ( stz.balanceOf(address(this)) > 0 ) {
            magnifiedReflectionPerShareSTZ = magnifiedReflectionPerShareSTZ.add(
                (stz.balanceOf(address(this))).mul(magnitude) / totalSupply()
            );

            emit ReflectionsDistributed(msg.sender, stz.balanceOf(address(this)));
            totalReflectionsDistributedSTZ = totalReflectionsDistributedSTZ.add(stz.balanceOf(address(this)));
        }
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `ReflectionWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawReflectionBNB() public virtual override {
        _withdrawReflectionOfUserBNB(payable(msg.sender));
    }

    function withdrawReflectionSTZ() public virtual override {
        _withdrawReflectionOfUserSTZ(payable(msg.sender));
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `ReflectionWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawReflectionOfUserBNB(address payable user) internal returns (uint256) {
        uint256 _withdrawableReflection = withdrawableReflectionOfBNB(user);
        if (_withdrawableReflection > 0) {
            withdrawnReflectionsBNB[user] = withdrawnReflectionsBNB[user].add(_withdrawableReflection);
            emit ReflectionWithdrawn(user, _withdrawableReflection);
            (bool success,) = user.call{value: _withdrawableReflection, gas: 3000}("");

            if(!success) {
                withdrawnReflectionsBNB[user] = withdrawnReflectionsBNB[user].sub(_withdrawableReflection);
                return 0;
            }

            return _withdrawableReflection;
        }

        return 0;
    }

    function _withdrawReflectionOfUserSTZ(address payable user) internal returns (uint256) {
        uint256 _withdrawableReflection = withdrawableReflectionOfSTZ(user);
        if (_withdrawableReflection > 0) {
            withdrawnReflectionsSTZ[user] = withdrawnReflectionsSTZ[user].add(_withdrawableReflection);
            emit ReflectionWithdrawn(user, _withdrawableReflection);
            stz.transfer(user, _withdrawableReflection);

            return _withdrawableReflection;
        }

        return 0;
    }


    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function reflectionOfBNB(address _owner) public view override returns(uint256) {
        return withdrawableReflectionOfBNB(_owner);
    }

    function reflectionOfSTZ(address _owner) public view override returns(uint256) {
        return withdrawableReflectionOfSTZ(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableReflectionOfBNB(address _owner) public view override returns(uint256) {
        return accumulativeReflectionOfBNB(_owner).sub(withdrawnReflectionsBNB[_owner]);
    }

    function withdrawableReflectionOfSTZ(address _owner) public view override returns(uint256) {
        return accumulativeReflectionOfSTZ(_owner).sub(withdrawnReflectionsSTZ[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnReflectionOfBNB(address _owner) public view override returns(uint256) {
        return withdrawnReflectionsBNB[_owner];
    }

    function withdrawnReflectionOfSTZ(address _owner) public view override returns(uint256) {
        return withdrawnReflectionsSTZ[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeReflectionOf(_owner) = withdrawableReflectionOf(_owner) + withdrawnReflectionOf(_owner)
    /// = (magnifiedReflectionPerShare * balanceOf(_owner) + magnifiedReflectionCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeReflectionOfBNB(address _owner) public view override returns(uint256) {
        return magnifiedReflectionPerShareBNB.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedReflectionCorrectionsBNB[_owner]).toUint256Safe() / magnitude;
    }

    function accumulativeReflectionOfSTZ(address _owner) public view override returns(uint256) {
        return magnifiedReflectionPerShareSTZ.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedReflectionCorrectionsSTZ[_owner]).toUint256Safe() / magnitude;
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedReflectionCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedReflectionPerShareBNB.mul(value).toInt256Safe();
        magnifiedReflectionCorrectionsBNB[from] = magnifiedReflectionCorrectionsBNB[from].add(_magCorrection);
        magnifiedReflectionCorrectionsBNB[to] = magnifiedReflectionCorrectionsBNB[to].sub(_magCorrection);

        _magCorrection = magnifiedReflectionPerShareSTZ.mul(value).toInt256Safe();
        magnifiedReflectionCorrectionsSTZ[from] = magnifiedReflectionCorrectionsSTZ[from].add(_magCorrection);
        magnifiedReflectionCorrectionsSTZ[to] = magnifiedReflectionCorrectionsSTZ[to].sub(_magCorrection);
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedReflectionCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedReflectionCorrectionsBNB[account] = magnifiedReflectionCorrectionsBNB[account]
        .sub( (magnifiedReflectionPerShareBNB.mul(value)).toInt256Safe() );

        magnifiedReflectionCorrectionsSTZ[account] = magnifiedReflectionCorrectionsSTZ[account]
        .sub( (magnifiedReflectionPerShareSTZ.mul(value)).toInt256Safe() );
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedReflectionCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedReflectionCorrectionsBNB[account] = magnifiedReflectionCorrectionsBNB[account]
        .add( (magnifiedReflectionPerShareBNB.mul(value)).toInt256Safe() );

        magnifiedReflectionCorrectionsBNB[account] = magnifiedReflectionCorrectionsBNB[account]
        .add( (magnifiedReflectionPerShareBNB.mul(value)).toInt256Safe() );
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if(newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if(newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library SafeMathInt {
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when multiplying INT256_MIN with -1
        // https://github.com/RequestNetwork/requestNetwork/issues/43
        require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

        int256 c = a * b;
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing INT256_MIN by -1
        // https://github.com/RequestNetwork/requestNetwork/issues/43
        require(!(a == - 2**255 && b == -1) && (b > 0));

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ReflectionPayingTokenOptionalInterface {
    function withdrawableReflectionOfBNB(address _owner) external view returns(uint256);
    function withdrawableReflectionOfSTZ(address _owner) external view returns(uint256);

    function withdrawnReflectionOfBNB(address _owner) external view returns(uint256);
    function withdrawnReflectionOfSTZ(address _owner) external view returns(uint256);
    
    function accumulativeReflectionOfBNB(address _owner) external view returns(uint256);
    function accumulativeReflectionOfSTZ(address _owner) external view returns(uint256);
}

interface ReflectionPayingTokenInterface {
    function reflectionOfBNB(address _owner) external view returns(uint256);
    function reflectionOfSTZ(address _owner) external view returns(uint256);
    function distributeReflections() external payable;
    function withdrawReflectionBNB() external;
    function withdrawReflectionSTZ() external;

    event ReflectionsDistributed(address indexed from, uint256 weiAmount);
    event ReflectionWithdrawn(address indexed to, uint256 weiAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}