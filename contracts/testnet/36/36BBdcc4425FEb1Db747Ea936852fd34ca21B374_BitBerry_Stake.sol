/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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

interface IBEP20 {
    function redeembalance(uint256 amount) external;
    function balances(address _addr) external view returns(uint256);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
    
    address public _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BitBerry_Stake is Ownable {

    ///////////////////////    VARIABLES    ////////////////////////

    using SafeMath for uint256;
    IERC20 public Token;
    IERC20 public LpToken;
    address public NFTcontract;
    uint256 public totalStakedTokens;
    uint256 public time = 1 minutes;
    uint256 public LPlocktime = 5 minutes;   // 10 days (14400)
    uint256 public normalLockTime = 7 ;   // 10080 (7 days)

    uint256 public minBBRStake = 500000000000000000000;
    uint256 public minLPStake = 500000000000000000000;

    // uint256 public BBR_Perecent = 4960317460317460000;
    uint256 public BBR_Perecent = 10000000000000000000;
    uint256 public Lppercent = 10000000000000000000;
    // uint256 public Lppercent = 9920634920634921000;
    uint256 public currentRP;

    ///////////////////////////////////////////////////////////////
    ///////////////////////    MAPPING    /////////////////////////

    mapping(address => users) public User;
    mapping(address => usersLP) public UserLP;
    mapping(address => uint256) public _balances;

    //////////////////////////////////////////////////////////////
    ///////////////////////    EVENTS    /////////////////////////

    event Staker(address indexed from, uint256 indexed StakingAmount);
    event Redeem_Points(address indexed from, uint256 indexed redeem_Points);
    event WithdrawTokens(address indexed from, uint256 indexed withdrawnTokens);
    event RedeemBalance(address indexed from, uint256 indexed _CurrentRP);
    event LP_Staker(address indexed from, uint256 indexed stakedAmount);
    event LP_Redeem_Points(address indexed from, uint256 indexed LP_Points);
    event WithdrawLP(address indexed from, uint256 indexed tokenWithDraw);
    event NFTAddress(address indexed from, address indexed nft_Contract);
    event LP_Lock_Time(address indexed from, uint256 indexed lockTime);
    event EpochTime(address indexed from, uint256 indexed Time);

    ///////////////////////////////////////////////////////////////
    ///////////////////////    MODIFIER    /////////////////////////

    modifier onlyNFTContract {
        require(msg.sender == NFTcontract,"Only Call By The NFT Contract");
        _;
    }

    // Owner has to set BBR's "Token" and "LP_token" address
    constructor(IERC20 _Token,IERC20 _LpToken)
    {
        Token = _Token;
        LpToken = _LpToken;   
    }
    ///////////////////////////////////////////////////////////
    /////////////////    STRUCTURES     //////////////////////

    struct users {
        uint256 Total_Amount;
        uint256 Deposit_time;
        uint256 withdrawnToken;
        uint256 redeemedRP;
        uint256 mystakedTokens;
    }

    struct usersLP { 
        uint256 Total_Amount;
        uint256 Deposit_time;
        uint256 withdrawnToken;
        uint256 redeemedRP;
    }

    ////////////////////////////////////////////////////
    users[] public Users;
    usersLP[] public usersLPs;

    mapping(address => users[]) public userInfo;
    mapping(address => usersLP[]) public userLPInfo;
    //////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////
    ////////////////////////        FUNCTIONS       //////////////////////////

    // User stakes toekn_amount, which then stores in a mapping(User) against user's address
    function addStakedTokens(uint256 _amount) internal {
        User[msg.sender].mystakedTokens += _amount;
        totalStakedTokens += _amount;
    }

    // User enters token_amount to remove from mapping(User) against user's address 
    function removeStakedTokens(uint256 _amount) internal {
        User[msg.sender].mystakedTokens -= _amount;
        totalStakedTokens -= _amount;
    }

    
    /*
    ==> User will stake the amount.
    =>  before staking, function will check if the staking address is already existing or not.
    =>  enterd amount will be transfered from users' address to this contract and also stored in the mapping(User)
    ==>  When uer Stake the amount, redeemedRP will be set to zero.
    */

    function Stake( uint256 _amount) external {   
        require(minBBRStake <= _amount, "less BBR amount than expected!");
        users memory user = User[msg.sender];
        // Token.transferFrom(msg.sender,address(this),_amount);

        user.Total_Amount += _amount;
        user.Deposit_time = block.timestamp;
        user.redeemedRP=0;
        addStakedTokens(_amount);
        Users.push(user);
        userInfo[msg.sender] = Users;
        emit Staker(msg.sender, _amount);
    }
    

    // User will enter the address to calculate its BBR Points according to 1 DAY.
    function rewCalculator(address addr) public view returns(uint256, uint256){

        uint256 userDepTime;
        uint256 remainingenergy;
        uint256 _timeSlot =0;
        uint256 reward = 0;
        uint256 amount_;

        for(uint256 i; i< userInfo[addr].length; i++){
            userDepTime = userInfo[addr][i].Deposit_time;
            _timeSlot = (block.timestamp.sub(userDepTime)).div(time);
            amount_ = userInfo[addr][i].Total_Amount;
            if(_timeSlot >= normalLockTime){
                _timeSlot = normalLockTime;
            }
            
            reward += (_timeSlot).mul((amount_).mul(BBR_Perecent));
            
        }
        // uint256 userDepTime = User[addr].Deposit_time;

        //    if(User[addr].Deposit_time!=0) {

        //    }
        //    return remainingenergy;
        reward = reward.sub(rewardedAmount[addr]);
        remainingenergy += (reward.div(1 ether)).sub((User[addr].redeemedRP));
        reward = reward.div(1 ether);

        return (remainingenergy, reward);
    }

    mapping(address => uint256) public rewardedAmount;

    // USER call this function to store its points in _balances "Mapping"
    function redeem() public {

        users memory user = User[msg.sender];
        (uint256 point, )=rewCalculator(msg.sender);
        currentRP+=point;
        user.redeemedRP +=point;

        _balances[msg.sender]+=point;
        emit Redeem_Points(msg.sender, point);
    }
    

    /*
    ==> user call "WITHDRAW" function to transfer amount to the user's address
    =>  User's amount will be set to zero
    =>  User's time will be set to zero
    ==> These tokens will be removed from user's address
    */

    function withdrawtoken () public {

        // require(User[msg.sender].Total_Amount > 0 ,"No Staking Found!" );
        redeem();
        (,uint256 reward) = rewCalculator(msg.sender);
        // User[msg.sender].withdrawnToken = User[msg.sender].Total_Amount;
        User[msg.sender].withdrawnToken = reward;
        rewardedAmount[msg.sender] += reward;
        // if(block.timestamp < User[msg.sender].Deposit_time.add(normalLockTime)){
        //     BBRP = BBRP.sub((BBRP.mul(20)).div(100));
        //     _balances[msg.sender] -= BBRP;
        // }
// Token.transfer(msg.sender,reward);
        // Token.transfer(msg.sender,reward);
        // User[msg.sender].Total_Amount = 0;
        // User[msg.sender].Deposit_time = 0 ;
        // removeStakedTokens(User[msg.sender].mystakedTokens);
        emit WithdrawTokens(msg.sender, User[msg.sender].withdrawnToken);
    }

    function unStakeBBR() public {
        uint256 userDepTime;
        uint256 totalTime;
        for(uint256 i; i< userInfo[msg.sender].length; i++){
            userDepTime = userInfo[msg.sender][i].Deposit_time;
            totalTime = userDepTime.add(normalLockTime);
            if(block.timestamp >= totalTime){
                // Token.transfer(msg.sender,userInfo[msg.sender][i].Total_Amount);
                userInfo[msg.sender][i].Total_Amount = 0;
                userInfo[msg.sender][i].Deposit_time = 0;
            }
        }
    }

    function UserInfo(address _user) public view returns(users[] memory){
        return userInfo[_user];
    }

    // Users can see thier balances by passing their addresses
    function balances(address _addr) external view returns(uint256) {
    return _balances[_addr];
    }


    /*
    ==> User pass the amount, and that amount will be minus from "balances" mapping and "currentRP" varaible
    ==> This function will check if the function caller has the NFT or not.
    */

    function redeembalance(uint256 amount) external onlyNFTContract {

    require( _balances[tx.origin]>0," No Energy Found! ");
    _balances[tx.origin]-=amount;
    currentRP-=amount;
    emit RedeemBalance(msg.sender, currentRP);
    }
    
    /*
    ==> Users will be checked if it is already exists or not 
    =>  LP_TOKENS will be transfered from users address to this contract
    =>  Enterd amount will be stored in User's mapping against user's address
    ==> redeemedRP will be set to zero.
    */

    function StakeforLP( uint256 _amount) external {   
    require(minBBRStake <= _amount, "less BBR amount than expected!");
     
    // require(UserLP[msg.sender].Deposit_time == 0," User Already Exists " );
    LpToken.transferFrom(msg.sender,address(this),_amount);
    UserLP[msg.sender].Total_Amount += _amount;
    UserLP[msg.sender].Deposit_time = block.timestamp;
    UserLP[msg.sender].redeemedRP=0;
    
    emit LP_Staker(msg.sender, _amount);
    }

    // User will pass the address to calculate its RP_energy
    
    function RPcalculatorforLP(address user) public view returns(uint256) {
    uint256 remainingenergy;

    if(UserLP[user].Deposit_time!=0) {
        uint256 reward = ((block.timestamp.sub(UserLP[user].Deposit_time)).div(time)).mul((UserLP[user].Total_Amount.mul(Lppercent)));
        remainingenergy= (reward.div(1E18)).sub(UserLP[user].redeemedRP);    
    }
    return remainingenergy;
    }

    // The user will get his BBR points after calling this function.
   
    function redeemforLp() public {

    uint256 point=RPcalculatorforLP(msg.sender);
    currentRP+=point;
    UserLP[msg.sender].redeemedRP +=point;
    _balances[msg.sender]+=point;

    emit LP_Redeem_Points(msg.sender, point);
    }

    /*
    ==> User's amount should be greater than zero
    =>  Withdrawl time should begreater than deposit_Time+LP_LockTime
    ==> After withdrawl Token time and amount will be set to zero
    */

    function withdrawLPtoken ()  public  {
        
    require(UserLP[msg.sender].Total_Amount > 0 ," No Staking Found! " );
    require(block.timestamp>=(UserLP[msg.sender].Deposit_time.add(LPlocktime))," UnLock Time Not Reached");
    redeemforLp();
    UserLP[msg.sender].withdrawnToken = UserLP[msg.sender].Total_Amount;
    LpToken.transfer(msg.sender,UserLP[msg.sender].Total_Amount); 
    UserLP[msg.sender].Total_Amount = 0;
    UserLP[msg.sender].Deposit_time = 0 ;
    emit WithdrawLP(msg.sender, UserLP[msg.sender].withdrawnToken);
    }


    //////////////////////////////////////////////////////////////////////////
    ////////////////////////        ONLYOWNER       //////////////////////////  

    //  owner will set NFT contract Address

    function AddNFTContractAddress(address NFT_Address) external onlyOwner {
    NFTcontract=NFT_Address;
    }

    // Owner will set LPlockTime
  
    function setLPlocktime(uint256 _LPlocktime) external onlyOwner {
    LPlocktime=_LPlocktime;
    }

    function setLockTime(uint256 _locktime) external onlyOwner {
        normalLockTime=_locktime;
    }

    //  Owner will set Time
    
    function setTime(uint256 _epoch) external onlyOwner {
    time = _epoch;
    }

}

//  TOKEN:      0x243A9D6c022F943b86C5C278B424c1E43c3197ea
// LP-TOKEN:    0xB9F91081E7c2228F1a4dD6192c736558b5804F9A