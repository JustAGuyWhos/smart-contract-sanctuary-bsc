/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BuySell {
    using SafeMath for uint256;
    BEP20 public busd = BEP20(0x3AD53Eb310bC6061baa62D900E6953601Dc90E5c);
    address payable aggregator;
    uint8 aggregation = 2;
    uint256 lockPeriod = 5 minutes;
    uint8 lockAmount = 2;
    bool restriction;
    uint256 public investments;
    uint256 public sales;
    
 
    struct User{
        uint256 deposits;
        uint256 sold;
        uint256 balance;
        uint256 lockPeriod;
        uint256 lockAmount;
        address previousBuyer;
        bool isLocked;
        uint256 security;
    }

    struct Deposit{
        uint256 amount;
        uint256 depositTime;
    }

    struct Sell{
        uint256 amount;
        uint256 soldTime;
    }

    struct Security{
        uint256 amount;
        uint256 depositTime;
    }

    struct Claim{
        bool isBalance;
        uint256 amount;
        uint256 claimTime;
    }

    struct Grievance{
        address requester;
        address seller;
        bool isSeller;
        uint256 amount;
        uint256 timestamp;

    }

    mapping(address => User) public users;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Sell[]) public sells;
    mapping(address => Security[]) public securities;
    mapping(address => Claim[]) public claims;
    mapping(address => Grievance[]) public grievances;

    event Deposits(address seller, uint256 amount);
    event Securities(address user, uint256 amount);
    event Sales(address seller, address buyer, uint256 amount);
    event Claims(address user, uint256 amount);
    event Grievances(address requester, address seller, uint256 amount);
   
    modifier onlyAggregator(){
        require(msg.sender == aggregator,"You are not authorized aggregator.");
        _;
    }
    
    function getContractInfo() view public returns(uint256 contractBalance, uint256 totalInvestments, uint256 totalSales, uint256 locking, uint8 txnFees){
        return (
            contractBalance = busd.balanceOf(address(this)),
            totalInvestments = investments,
            totalSales = sales,
            locking = lockPeriod,
            txnFees = aggregation
        );
    }

    constructor() public {
        aggregator = msg.sender;
    }

    function deposit(uint256 amount) public {
        require(amount>=1e18,"Investment must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        user.deposits+=amount;
        user.balance+=amount;
        investments+=amount;
        deposits[msg.sender].push(Deposit(
            amount,
            block.timestamp
        ));
        busd.transferFrom(msg.sender,address(this),amount);
        emit Deposits(msg.sender, amount);
    }

    function securityDeposit(uint256 amount) public {
        require(amount>=1e18 && restriction==true,"Investment must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        user.security+=amount;
        investments+=amount;
        securities[msg.sender].push(Security(
            amount,
            block.timestamp
        ));
        busd.transferFrom(msg.sender,address(this),amount);
        emit Securities(msg.sender, amount);
    }

    function setSellerLock(address _buyer,uint256 _amount) public returns(bool){
        User storage user = users[msg.sender];
        
        if(user.isLocked==false && _amount.mul(lockAmount)<=user.balance){
            user.previousBuyer = _buyer;
            user.lockPeriod = block.timestamp+lockPeriod;
            user.lockAmount = _amount.mul(lockAmount);
            user.isLocked = true;
            return true;
        }
        else{
            return false;
        }
    }
    
    function sell(address buyer, uint256 amount) public {
        require(amount>=1e18,"Sales must be at least 1 BUSD!");
        User storage user = users[msg.sender];
        
        if(restriction==true){
            require(users[buyer].security>=amount,"Security balance is low!");
        }

        require(busd.balanceOf(address(this))>=amount && user.balance>=amount,"Insufficient Balance");
        require(user.previousBuyer==buyer && user.isLocked==true && user.lockPeriod<=block.timestamp);
        
        user.sold+=amount;
        user.balance-=amount;
        sales+=amount;
        uint256 txnfee = amount.mul(aggregation).div(100);
        busd.transfer(buyer,amount-txnfee);
        busd.transfer(aggregator,txnfee);
        sells[msg.sender].push(Sell(
            amount,
            block.timestamp
        ));
        user.lockPeriod = block.timestamp;
        user.lockAmount = 0;
        user.isLocked = false;
        emit Sales(msg.sender, buyer, amount);
    }

    function claimBalance(uint256 _claim) public returns(bool){
        User storage user = users[msg.sender];
        require(busd.balanceOf(address(this))>=_claim && user.balance>=_claim,"Claim is not applicable.");
        busd.transfer(msg.sender,_claim);
        user.balance-=_claim;
        claims[msg.sender].push(Claim(
            true,
            _claim,
            block.timestamp
        ));
        emit Claims(msg.sender,_claim);
        return true;
    }

    function claimSecurity(uint256 _claim) public returns(bool){
        User storage user = users[msg.sender];
        require(busd.balanceOf(address(this))>=_claim && user.security>=_claim,"Claim is not applicable.");
        busd.transfer(msg.sender,_claim);
        user.security-=_claim;
        claims[msg.sender].push(Claim(
            false,
            _claim,
            block.timestamp
        ));
        emit Claims(msg.sender,_claim);
        return true;
    }

    function setAggregationCharge(uint8 charge) public onlyAggregator returns(uint8){
        aggregation = charge;
        return aggregation;
    }

    function setlockPeriod(uint256 lock) public onlyAggregator returns(uint256){
        lockPeriod = lock;
        return lockPeriod;
    }

    function setlockAmount(uint8 lockAmt) public onlyAggregator returns(uint256){
        lockAmount = lockAmt;
        return lockAmount;
    }

    function resolveSellerGrievance(address _seller) public onlyAggregator returns(bool){
        User storage user = users[_seller];
        user.lockPeriod = block.timestamp;
        grievances[_seller].push(Grievance(
            _seller,
            _seller,
            true,
            user.lockAmount,
            block.timestamp
        ));
        user.lockAmount = 0;
        user.isLocked = false;
        emit Grievances(_seller,_seller, user.lockAmount);
        return true;
    }
    
    function resolveBuyerGrievance(address _buyer, address _seller, uint256 _amount) public onlyAggregator returns(bool){
        User storage user = users[_seller];
        user.lockPeriod = block.timestamp+lockPeriod;
        user.lockAmount = _amount.mul(lockAmount);
        user.isLocked = true;
        grievances[_buyer].push(Grievance(
            _buyer,
            _seller,
            false,
            _amount.mul(lockAmount),
            block.timestamp
        ));
        emit Grievances(_buyer,_seller,_amount);
        return true;
    }

    function setRestriction(uint8 cmd) public onlyAggregator returns(bool){
        restriction = (cmd==1)?true:false;
        return restriction;
    }

    function communityRunningWages(address _address, uint _amount) external onlyAggregator{
        busd.transfer(_address,_amount);
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}