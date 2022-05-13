/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/**
 *Submitted for verification at polygonscan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IEACAggregatorProxy
{
    function latestAnswer() external view returns (uint256);
}

contract MATICMining {

    using SafeMath for uint256;
    bool public safeguard;  //putting safeguard on will halt all non-owner functions
    mapping (address => bool) public frozenAccount;
    event FrozenAccounts(address target, bool frozen);
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress],"Caller must be admin");
        _;
    }
    /*==============================
    =            EVENTS           =
    ==============================*/

    event Reward_Buy(
       address indexed to,
       uint256 rewardAmount,
       uint256 level
    );
    event Withdraw(
        address indexed user,
        uint256 tokens
    );


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Matic Mining";
    uint256 private decimals = 18;
    mapping(address  => uint) public totalUserRewardBuy;
    mapping(address => uint) public totalUserRewardSell;

    uint public adminfeeperc = 10;
    uint public aiPoolperc = 5;
    uint public Poolperc = 3;
    uint public monthlyEarnersPerc = 70;
    uint public directIncomeperc = 6;
    uint[] public withdraw_limit = [3,4,5,5] ; //3 times of investment
    address public aiContract;
    address public monthlyTopEarner;
    address public defaultreferrer;

    uint public oneDay = 1; // change it to '1 days' in production
    uint public poolday= 60; // change it to '1 days' in production

    mapping(address => uint256) public tokenBalanceLedger_;
    mapping(address => uint256) public rewardBalanceLedger_;
    uint256 public tokenSupply_ = 0;

    mapping(address => bool) internal administrators;
    mapping(address => address) public genTree;
    mapping(address => uint) public refCount;
    mapping(address => uint256) public level1Holding_;


    // Separate return records
     mapping(address => uint256) public dailyROIGain;
     mapping(address => uint256) public claimeddailyROIGain;
     mapping(address => uint256) public directIncomeGain;
     mapping(address => uint256) public sponsorGain;
     mapping(address => uint256) public sponsordailyGain;
     mapping(address => uint256) public top5SponsorGain;
     mapping(address => uint256) public pendingDailyGain;


    uint public minimumBuyAmount = 1 * (10**decimals);

    address public terminal;
    uint16[] percent_ =  [300,200,100,50,50,25,25,10,10];
    uint[] public dailyROI = [50,60,65,70];
    uint public minWithdraw = 10 * (10**decimals);

    struct stakeInf
    {
        uint amount;
        uint stakeTime;
        uint totalRoi;
        uint lastWithdrawTime;
    }

    struct user
    {
      uint256 wid_limit;
      uint256 total_payouts;
      uint256 totalbus;
      uint256 totalInvested;
      uint256 total_withdrawn;
      bool inAIPool;
      bool onceInAI;
      address firstleg;
      uint256 firstlegbus;
      address firstlegAI;
    }


    mapping(address => user) public userInfo;
    mapping(address => stakeInf[]) public stakeInfo;
    mapping(address => uint) public totalStake;
    mapping(address => uint) public totalAIPool;
    mapping(address => uint40) public userjointime;
    uint public aiperonwdr = 20;

    uint8[] public pool_bonuses;
    uint40 public pool_last_draw = uint40(block.timestamp);
    uint256 public pool_cycle;
    uint256 public pool_balance;

    //ai distribution
   uint40 public ai_pool_last_draw = uint40(block.timestamp);
   uint256 public ai_pool_cycle;
   uint256 public ai_pool_balance;
   uint256 public AI_MinBusLimit = 50000 * (10 ** decimals);
   mapping(uint256 => mapping(address => uint256)) public ai_pool_users_refs_deposits_sum;
   mapping(address => uint) public top5Earners;
   address[] public ai_pool_top;

    mapping(uint256 => mapping(address => uint256)) public pool_users_refs_deposits_sum;
    mapping(uint8 => address) public pool_top;
    address public EACAggregatorProxyAddress;

    event PoolPayout(address indexed addr, uint256 amount);
    event stakeTokenEv(address _user, uint _amount, uint stakeIndex);
    event directPaid(address indexed user, address indexed referrer, uint amount);
    event AI_PoolPayout(address indexed addr, uint256 amount);
    event joinEv(address indexed _user, address indexed _referredBy, uint _amount);
    event ClaimEv(address indexed _user, uint256 amount, uint sindex);
    event SponsorROIEv(address indexed _user, address indexed _fromuser, uint256 amount, uint slevel);

    constructor(address _aiContract, address _EACAggregatorProxyAddress, address _monthlyTopEarner)
    {
        terminal = msg.sender;
        defaultreferrer = msg.sender;
        administrators[terminal] = true;
        aiContract = _aiContract;
        monthlyTopEarner = _monthlyTopEarner;
        //main -- 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0
        //testnet -- 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        EACAggregatorProxyAddress = _EACAggregatorProxyAddress;
        pool_bonuses.push(25);
        pool_bonuses.push(20);
        pool_bonuses.push(15);
        pool_bonuses.push(10);
        pool_bonuses.push(5);
        pool_bonuses.push(3);
        pool_bonuses.push(2);
        pool_bonuses.push(1);

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = terminal;
        }
    }

    /*==========================================
    =            VIEW FUNCTIONS            =
    ==========================================*/
    function MATICToUSD(uint maticAmount) public view returns(uint)
    {
        uint256  maticpreice = IEACAggregatorProxy(EACAggregatorProxyAddress).latestAnswer();
        return maticAmount * maticpreice * (10 ** (decimals-8)) / (10 ** (decimals));
    }
    function USDToMATIC(uint busdAmount) public view returns(uint)
    {
        uint256  maticpreice = IEACAggregatorProxy(EACAggregatorProxyAddress).latestAnswer();
        return busdAmount  / maticpreice * (10 ** (decimals-10));
    }
    function holdingLevel1(address _toCheck) public view returns(uint256)
    {
        return level1Holding_[_toCheck];
    }
    function isContract(address _address) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
    function NumberOfStakes(address _user) public view returns(uint)
    {
      return stakeInfo[_user].length;
    }

    function checklimit(address _addr, uint256 amount) public view returns(uint)
    {
      uint256 with_limit_token=  userInfo[_addr].wid_limit;
      uint remainamount;
      if(((userInfo[_addr].total_payouts.add(amount)) <= with_limit_token ) || _addr == terminal)
      {
        //if(_addr != terminal){
        //  if((isROI && stakeInfo[_addr][stakeIndex].totalRoi.add(amount) > with_limit_token ))
          //{
        //    remainamount = dailyROILimit - claimeddailyROIGain[_addr];
        //    return remainamount;
        //  }
        //}
         return amount;
      }
      else
      {
         remainamount = with_limit_token - userInfo[_addr].total_payouts;
        return remainamount;

      }
    }
    function claimable(uint stakeIndex, address _user) public view returns(uint256)
    {
        uint amount = stakeInfo[_user][stakeIndex].amount;
        if(amount>0)
        {
          //uint tim = stakeInfo[_user][stakeIndex].stakeTime;
          uint tim2 = stakeInfo[_user][stakeIndex].lastWithdrawTime;

          uint oD = oneDay;
//          uint usedDays = (tim2 - tim) / oD;
          uint daysPassed = (block.timestamp - tim2 ) / oD;
          //if(usedDays + daysPassed > lD ) daysPassed = lD - usedDays;
          uint256 amt = (amount * extraROI(amount*2) / 10000) * daysPassed ;
          uint256 checkedamt= checklimit(_user, amt);
          return checkedamt ;

        }
        return 0;
    }
    /*==========================================
    =            WRITE FUNCTIONS            =
    ==========================================*/
    function buy(address _referredBy,uint256 USDAmount) payable external returns(uint256)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed');
      //require(USDAmount % 100 == 0,"USD package must be multiple of 100");
      require(USDAmount <= MATICToUSD(msg.value),"Invalid MATIC");
      require(USDAmount >= minimumBuyAmount, "Minimum limit does not reach");
      if(genTree[msg.sender] != address(0))
      {
        uint lastindex = stakeInfo[msg.sender].length - 1 ;
        require(stakeInfo[msg.sender][lastindex].amount <= USDAmount, "Invest with similar or greater value than last investment");
      }
      if(_referredBy == address(0) || msg.sender == _referredBy || genTree[_referredBy] == address(0)) _referredBy = defaultreferrer;
      uint256 totalbus = USDAmount;
      USDAmount = USDAmount.div(2);
      uint256 aiPoolAmt = USDAmount * aiPoolperc/100;
      uint256 aiAmt = USDAmount - aiPoolAmt;
      payable(aiContract).transfer(USDToMATIC(aiAmt));
      payable(monthlyTopEarner).transfer(USDToMATIC(aiPoolAmt));
      ai_pool_balance += aiPoolAmt;
      totalAIPool[msg.sender] += USDAmount;
      userInfo[msg.sender].totalbus += USDAmount;
      userInfo[msg.sender].totalInvested += totalbus;
      if(genTree[msg.sender] == address(0))
      {
          genTree[msg.sender] = _referredBy;
          refCount[_referredBy]++;
          userjointime[msg.sender] = uint40(block.timestamp) + 86400;
          emit joinEv(msg.sender, _referredBy, totalbus);
      }
    	_pollDeposits(msg.sender, USDAmount);
      if(pool_last_draw + poolday < block.timestamp)
  		{
  			_drawPool();
  		}

      increaseTotalBus(msg.sender, USDAmount);
      _AIpollDeposits(msg.sender, USDAmount);
      if(ai_pool_last_draw + 600 < block.timestamp)
       {
         _drawAIPool();
       }
      uint tkn = purchaseTokens(msg.sender, USDAmount, _referredBy, totalbus);
      return tkn;
    }
    function withdrawDailyGain(uint256 _amount) external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      address _customerAddress = msg.sender;

      uint256 totaldaily = claimeddailyROIGain[_customerAddress];
      require(totaldaily  >= _amount && _amount >= minWithdraw, "beyond withdraw limit");

        uint256 amt;

        claimeddailyROIGain[_customerAddress] -= _amount ;

        address ref = genTree[msg.sender];
        for(uint i =1 ; i <= 20;i++)
        {
          if(i==1){
            amt = _amount * (i*10)/100;
          }
          else
          {
            amt = _amount * (i*5)/100;
          }
          if(ref == address(0)) ref = terminal;
          if(refCount[ref]>=i && level1Holding_[ref] >= (userInfo[ref].totalInvested * i) && ref!=terminal){
            uint256 checkedamt= checklimit(ref,amt);
            if(checkedamt==amt){
              sponsordailyGain[ref]+= amt;
            }
            else
            {
              uint remamt = amt - checkedamt;
              sponsordailyGain[ref] += checkedamt;
              sponsordailyGain[terminal] += remamt;
            }
            emit SponsorROIEv(ref, msg.sender, checkedamt, i);
            userInfo[ref].total_payouts += checkedamt;
            rewardBalanceLedger_[ref] +=checkedamt;
          }
          else{
            sponsordailyGain[terminal]+= amt;
          }
          ref = genTree[ref];
        }


      if(pool_last_draw + poolday < block.timestamp)
      {
        _drawPool();
      }
        uint256 adminfee = _amount * adminfeeperc/100;
        uint aipart = _amount * aiperonwdr /100;
        totalAIPool[msg.sender] += aipart;
        uint256 userbalance = USDToMATIC(_amount - adminfee - aipart);
        adminfee =USDToMATIC(adminfee);
        userInfo[_customerAddress].total_withdrawn += _amount ;
        payable(_customerAddress).transfer(userbalance);
        payable(aiContract).transfer(USDToMATIC(aipart));
        payable(terminal).transfer(adminfee);
        emit Withdraw(_customerAddress, _amount);

      return true;
    }
    function withdrawTopSponsorGain(uint256 _amount) external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      address _customerAddress = msg.sender;
      uint256 TopSponsorGain = top5SponsorGain[_customerAddress];
      require(TopSponsorGain >= _amount && _amount >= minWithdraw, "beyond withdraw limit");

      top5SponsorGain[_customerAddress] -= _amount;

      if(pool_last_draw + poolday < block.timestamp)
      {
        _drawPool();
      }
        uint256 adminfee = _amount * adminfeeperc/100;
        uint aipart = _amount * aiperonwdr /100;
        totalAIPool[msg.sender] += aipart;
        uint256 userbalance = USDToMATIC(_amount - adminfee - aipart);
        adminfee =USDToMATIC(adminfee);
        userInfo[_customerAddress].total_withdrawn += _amount ;
        payable(_customerAddress).transfer(userbalance);
        payable(aiContract).transfer(USDToMATIC(aipart));
        payable(terminal).transfer(adminfee);
        emit Withdraw(_customerAddress, _amount);

      return true;
    }
    function withdrawDirectIncomeGain(uint256 _amount) external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      address _customerAddress = msg.sender;

      require(directIncomeGain[_customerAddress]  >= _amount && _amount >= minWithdraw, "beyond withdraw limit");

      rewardBalanceLedger_[_customerAddress] -= _amount ;
      directIncomeGain[_customerAddress] -= _amount ;

      if(pool_last_draw + poolday < block.timestamp)
      {
        _drawPool();
      }
        uint256 adminfee = _amount * adminfeeperc/100;
        uint aipart = _amount * aiperonwdr /100;
        totalAIPool[msg.sender] += aipart;
        uint256 userbalance = USDToMATIC(_amount - adminfee - aipart);
        adminfee =USDToMATIC(adminfee);
        userInfo[_customerAddress].total_withdrawn += _amount ;
        payable(_customerAddress).transfer(userbalance);
        payable(aiContract).transfer(USDToMATIC(aipart));
        payable(terminal).transfer(adminfee);
        emit Withdraw(_customerAddress, _amount);

      return true;
    }
    function withdrawSponsorGain(uint256 _amount) external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      address _customerAddress = msg.sender;
      require(sponsorGain[_customerAddress]  >= _amount && _amount >= minWithdraw, "beyond withdraw limit");
      rewardBalanceLedger_[_customerAddress] -= _amount ;
      sponsorGain[_customerAddress] -= _amount ;

      if(pool_last_draw + poolday < block.timestamp)
      {
        _drawPool();
      }
        uint256 adminfee = _amount * adminfeeperc/100;
        uint aipart = _amount * aiperonwdr /100;
        totalAIPool[msg.sender] += aipart;
        uint256 userbalance = USDToMATIC(_amount - adminfee - aipart);
        adminfee =USDToMATIC(adminfee);
        userInfo[_customerAddress].total_withdrawn += _amount ;
        payable(_customerAddress).transfer(userbalance);
        payable(aiContract).transfer(USDToMATIC(aipart));
        payable(terminal).transfer(adminfee);
        emit Withdraw(_customerAddress, _amount);

      return true;
    }
    function withdrawSponsordailyGain(uint256 _amount) external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      address _customerAddress = msg.sender;
      require(sponsordailyGain[_customerAddress] >= _amount && _amount >= minWithdraw, "beyond withdraw limit");
      rewardBalanceLedger_[_customerAddress] -= _amount ;
      sponsordailyGain[_customerAddress] -= _amount ;

      if(pool_last_draw + poolday < block.timestamp)
      {
        _drawPool();
      }
      uint256 adminfee = _amount * adminfeeperc/100;
      uint aipart = _amount * aiperonwdr /100;
      totalAIPool[msg.sender] += aipart;
      uint256 userbalance = USDToMATIC(_amount - adminfee - aipart);
      adminfee =USDToMATIC(adminfee);
      userInfo[_customerAddress].total_withdrawn += _amount ;
      payable(_customerAddress).transfer(userbalance);
      payable(aiContract).transfer(USDToMATIC(aipart));
      payable(terminal).transfer(adminfee);
      emit Withdraw(_customerAddress, _amount);
      return true;
    }

    function withdrawAll() external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
      address _customerAddress = msg.sender;
      uint256 TopSponsorGain = top5SponsorGain[_customerAddress];
      uint256 totaldaily= claimeddailyROIGain[_customerAddress];
      require(rewardBalanceLedger_[_customerAddress] + totaldaily + TopSponsorGain >= minWithdraw, "beyond withdraw limit");
      uint256 _rewardbalance = rewardBalanceLedger_[_customerAddress] ;
      uint256 _balance = _rewardbalance + totaldaily + TopSponsorGain;
      if(_rewardbalance>0){
        require(rewardBalanceLedger_[_customerAddress] >=  _rewardbalance , "overflow found");
        rewardBalanceLedger_[_customerAddress] -= _rewardbalance ;
        directIncomeGain[_customerAddress] = 0;
        sponsorGain[_customerAddress]=0;
        sponsordailyGain[_customerAddress] =0;
      }
      top5SponsorGain[_customerAddress] -= TopSponsorGain;
      uint256 amt;

      if(totaldaily>0)
      {
        claimeddailyROIGain[_customerAddress] -= totaldaily ;
        address ref = genTree[msg.sender];
        for(uint i =1 ; i <= 20;i++)
        {
          amt = totaldaily * (i*5)/100;
          if(ref == address(0)) ref = terminal;
          if(refCount[ref]>=i && level1Holding_[ref] >= (userInfo[ref].totalInvested * i) && ref!=terminal){
            uint256 checkedamt= checklimit(ref,amt);
            if(checkedamt==amt){
              sponsordailyGain[ref]+= amt;
            }
            else
            {
              uint remamt = amt - checkedamt;
              sponsordailyGain[ref] += checkedamt;
              sponsordailyGain[terminal] += remamt;
            }
            emit SponsorROIEv(ref, msg.sender, checkedamt, i);
            userInfo[ref].total_payouts += checkedamt;
            rewardBalanceLedger_[ref] +=checkedamt;
          }
          else{
            sponsordailyGain[terminal]+= amt;
          }
          ref = genTree[ref];
        }
      }

      if(pool_last_draw + poolday < block.timestamp)
      {
        _drawPool();
      }
        uint256 adminfee = _balance * adminfeeperc/100;
        uint256 userbalance = USDToMATIC(_balance - adminfee);
        adminfee =USDToMATIC(adminfee);
        userInfo[_customerAddress].total_withdrawn += _balance ;
        payable(_customerAddress).transfer(userbalance);
        payable(terminal).transfer(adminfee);
        emit Withdraw(_customerAddress, _balance);

      return true;
    }

    function Claim(uint stakeIndex) external returns(bool)
    {
      require(!safeguard);
      require(!frozenAccount[msg.sender], "caller has been frozen");
      require(!isContract(msg.sender),  'No contract address allowed to withdraw');
        uint amount = stakeInfo[msg.sender][stakeIndex].amount;
        require( amount > 0, "nothing staked");
        uint tim2 = stakeInfo[msg.sender][stakeIndex].lastWithdrawTime;
        uint oD = oneDay;
          uint daysPassed = (block.timestamp - tim2 ) / oD;
          uint256 amt = (amount * extraROI(amount*2) / 10000) * daysPassed ;
          uint256 checkedamt= checklimit(msg.sender,amt);
            if(checkedamt < amt){
              uint remamt = amt - checkedamt;
              dailyROIGain[terminal] += remamt;
            }
          if(checkedamt > 0){
            stakeInfo[msg.sender][stakeIndex].lastWithdrawTime = block.timestamp;
            stakeInfo[msg.sender][stakeIndex].totalRoi += checkedamt ;
            dailyROIGain[msg.sender] += checkedamt;
            claimeddailyROIGain[msg.sender] += checkedamt ;
            userInfo[msg.sender].total_payouts += checkedamt ;
            emit ClaimEv( msg.sender, amt, stakeIndex);
          }
        return true;
    }
      receive() external payable {
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function increaseTotalBus(address _user,uint256 _totalbus) private
    {
      address directreferrer = genTree[_user];
      if(userInfo[directreferrer].firstleg == address(0) || userInfo[_user].totalbus > userInfo[directreferrer].firstlegbus)
      {
        userInfo[directreferrer].firstleg = _user;
        userInfo[directreferrer].firstlegbus = userInfo[_user].totalbus;
      }
      for(uint i=0;i<10;i++){
        _user = genTree[_user];
        userInfo[_user].totalbus += _totalbus ;
        if(_user==terminal)  break;
      }
    }
    function _pollDeposits(address _addr, uint256 _amount) private {
        pool_balance += _amount * Poolperc / 100;
        address upline = genTree[_addr];
        if(upline == address(0)) return;
        pool_users_refs_deposits_sum[pool_cycle][upline] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(pool_users_refs_deposits_sum[pool_cycle][upline] > pool_users_refs_deposits_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length - 1); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
        }
    }
    function _AIpollDeposits(address _addr, uint256 _totalbus) private {
        for(uint8 i = 0; i < 2; i++) {
          if(_addr == address(0)) return;
          ai_pool_users_refs_deposits_sum[ai_pool_cycle][_addr] += _totalbus;
          address directreferrer = genTree[_addr];
          if(userInfo[directreferrer].firstlegAI == address(0) ||
           ai_pool_users_refs_deposits_sum[ai_pool_cycle][_addr] > ai_pool_users_refs_deposits_sum[ai_pool_cycle][userInfo[directreferrer].firstlegAI])
          {
            userInfo[directreferrer].firstlegAI = _addr;
          }
          if(userInfo[_addr].onceInAI){
            if((ai_pool_users_refs_deposits_sum[ai_pool_cycle][_addr] - (ai_pool_users_refs_deposits_sum[ai_pool_cycle][userInfo[directreferrer].firstlegAI]/2)) >= AI_MinBusLimit && !userInfo[_addr].inAIPool)
            {
              userInfo[_addr].inAIPool =true;
              ai_pool_top.push(_addr);
            }
          }
          else
          {
            uint256 totalusdbus=userInfo[_addr].totalbus;
            if((totalusdbus - (userInfo[_addr].firstlegbus/2)) >= AI_MinBusLimit && !userInfo[_addr].inAIPool)
            {
              userInfo[_addr].inAIPool =true;
              userInfo[_addr].onceInAI =true;
              ai_pool_top.push(_addr);
            }
          }
          _addr = genTree[_addr];
        }
      }
      function _drawAIPool() private {
        if(ai_pool_top.length > 0 )
        {
          ai_pool_last_draw = uint40(block.timestamp);
          ai_pool_cycle++;

          uint256 draw_amount = (ai_pool_balance*monthlyEarnersPerc/100).div(ai_pool_top.length) ;

          for(uint8 i = 0; i < ai_pool_top.length; i++) {
              if(ai_pool_top[i] == address(0)) break;
                ai_pool_balance -= draw_amount;
                userInfo[ai_pool_top[i]].inAIPool = false;
                top5Earners[ai_pool_top[i]] += draw_amount;
                emit AI_PoolPayout(ai_pool_top[i], draw_amount);
          }
          delete ai_pool_top ;
        }

      }
      function _drawPool() private {
          pool_last_draw = uint40(block.timestamp);
          pool_cycle++;
          uint256 draw_amount = pool_balance ;
          for(uint8 i = 0; i < pool_bonuses.length; i++) {
              if(pool_top[i] == address(0)) break;
              uint256 win = (draw_amount * pool_bonuses[i]).div(100);
              uint256 checkedamt= checklimit(pool_top[i], win);
              if(checkedamt==win){
                top5SponsorGain[pool_top[i]] += win;
                userInfo[pool_top[i]].total_payouts += win;
              }
              else
              {
                uint remamt = win - checkedamt;
                top5SponsorGain[pool_top[i]] += checkedamt;
                top5SponsorGain[terminal] += remamt;
                userInfo[pool_top[i]].total_payouts += checkedamt;
              }
              pool_balance -= win;
              emit PoolPayout(pool_top[i], win);
              pool_top[i] = terminal;
          }
      }

    function purchaseTokens(address _customerAddress, uint256 _amountOfTokens, address _referredBy, uint256 mainamount) internal returns(uint256)
    {
        //deduct commissions for referrals
        uint256 directincome = _amountOfTokens * directIncomeperc / 100;
        uint256 checkedamt= checklimit(_referredBy, directincome);
        if(checkedamt==directincome){
          sponsorGain[_referredBy] += directincome;
          rewardBalanceLedger_[_referredBy] += directincome;
          emit directPaid(_customerAddress, _referredBy ,directincome);
        }
        else
        {
          uint remamt = directincome - checkedamt;
          sponsorGain[_referredBy] += checkedamt;
          sponsorGain[terminal] += remamt;
          rewardBalanceLedger_[_referredBy] += checkedamt;
          emit directPaid(_customerAddress, _referredBy ,checkedamt);
        }
        userInfo[_referredBy].total_payouts += checkedamt;

        tokenSupply_ = tokenSupply_.add(_amountOfTokens + (directincome));
        level1Holding_[_referredBy] += mainamount;
        if(refCount[_referredBy]==5 && level1Holding_[_referredBy] >= (userInfo[_referredBy].totalInvested * 5))
        {
          userInfo[_referredBy].wid_limit = userInfo[_referredBy].totalInvested * 5;
        }
        distributeRewards(_amountOfTokens,_customerAddress);
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].add(_amountOfTokens);
        stakeToken(_customerAddress,mainamount);
        return _amountOfTokens;
    }
    function stakeToken(address _user,uint256 mainamount) internal returns(bool)
    {
        uint amount = tokenBalanceLedger_[_user];
        tokenBalanceLedger_[_user] = 0;
        userInfo[_user].wid_limit += mainamount * getLimitByPackage(mainamount);
        stakeInf memory temp;
        tokenBalanceLedger_[address(this)] = tokenBalanceLedger_[address(this)].add(amount);
        temp.amount = amount;
        temp.stakeTime = block.timestamp;
        temp.lastWithdrawTime = block.timestamp;
        stakeInfo[_user].push(temp);
        totalStake[_user] += amount;
        emit stakeTokenEv(_user, amount, stakeInfo[_user].length);
        return true;
    }
    function distributeRewards(uint256 _amount, address _idToDistribute)  internal
    {
        _idToDistribute = genTree[_idToDistribute];
        uint256 amt;
        for(uint i=0; i<9; i++)
        {
            _idToDistribute = genTree[_idToDistribute];
            if(_idToDistribute == address(0)) _idToDistribute = terminal;
            amt= (_amount.mul(percent_[i])).div(10000);

            uint256 checkedamt= checklimit(_idToDistribute,amt);
            if(checkedamt==amt){
              rewardBalanceLedger_[_idToDistribute] += amt;
              totalUserRewardBuy[_idToDistribute] += amt;
              directIncomeGain[_idToDistribute] += amt;
              emit Reward_Buy(_idToDistribute,amt,i);
            }
            else
            {
              uint remamt = amt.sub(checkedamt);
              rewardBalanceLedger_[_idToDistribute] += checkedamt;
              totalUserRewardBuy[_idToDistribute] += checkedamt;
              directIncomeGain[_idToDistribute] += checkedamt;
              emit Reward_Buy(_idToDistribute,checkedamt,i);
              rewardBalanceLedger_[terminal] += remamt;
            }
            userInfo[_idToDistribute].total_payouts += checkedamt;
        }
        rewardBalanceLedger_[terminal] += _amount*2/100;
    }
    function extraROI(uint256 _grv) internal view returns(uint256)
    {
        if(_grv >= minimumBuyAmount && _grv <= 1000 * (10** decimals))
        {
            return dailyROI[0];
        }
        else if(_grv > 1000 * (10** decimals) && _grv <= 5000 * (10** decimals) )
        {
            return dailyROI[1];
        }
        else if(_grv > 5000 * (10** decimals) && _grv <= 10000 * (10** decimals) )
        {
            return dailyROI[2];
        }
        else if(_grv > 10000 * (10** decimals))
        {
            return dailyROI[3];
        }
        return 0;
    }
    function getLimitByPackage(uint256 _grv) internal view returns(uint256)
    {
        if(_grv >= minimumBuyAmount && _grv <= 1000 * (10** decimals))
        {
            return withdraw_limit[0];
        }
        else if(_grv > 1000 * (10** decimals) && _grv <= 5000 * (10** decimals) )
        {
            return withdraw_limit[1];
        }
        else if(_grv > 5000 * (10** decimals) && _grv <= 10000 * (10** decimals) )
        {
            return withdraw_limit[2];
        }
        else if(_grv > 10000 * (10** decimals))
        {
            return withdraw_limit[3];
        }
        return 0;
    }
    /*==========================================
    =            Admin FUNCTIONS            =
    ==========================================*/
    function drawAIPool() public onlyAdministrator returns(bool)
      {
        if(ai_pool_last_draw + 600 < block.timestamp)
        {
          _drawAIPool();
        }
        return true;
      }
    function settopEarners(address _user, uint256 _amt) external returns(bool)
    {
      require(msg.sender == monthlyTopEarner,'Invalid caller');
      top5Earners[_user] -= _amt;
      return true;
    }
    function setMinWithdraw(uint _minWithdraw) public onlyAdministrator returns(bool)
    {
        minWithdraw = (_minWithdraw).mul(10** decimals);
        return true;
    }
    function setAI_MinBusLimit(uint _AI_MinBusLimit) public onlyAdministrator returns(bool)
    {
        AI_MinBusLimit = (_AI_MinBusLimit).mul(10** decimals);
        return true;
    }
    function setAPPercOnWithdraw(uint _aiperonwdr) public onlyAdministrator returns(bool)
    {
        aiperonwdr = _aiperonwdr;
        return true;
    }

    function setUserWithdraw_limit(uint[] memory _numberoftimes) public onlyAdministrator returns(bool)
    {
        withdraw_limit = _numberoftimes;
        return true;
    }
    function setAdminFeeForWithdraw(uint _adminfeeperc) public onlyAdministrator returns(bool)
    {
        adminfeeperc = _adminfeeperc;
        return true;
    }
    function setAIPoolPerc(uint _aipoolperc) public onlyAdministrator returns(bool)
    {
        aiPoolperc = _aipoolperc;
        return true;
    }
    function setMonthlyEarnersPerc(uint _MonthlyEarnersperc) public onlyAdministrator returns(bool)
    {
        monthlyEarnersPerc = _MonthlyEarnersperc;
        return true;
    }
    function setPoolPerc(uint _Poolperc) public onlyAdministrator returns(bool)
    {
        Poolperc = _Poolperc;
        return true;
    }

    function setMinimumBuyAmount(uint _minimumBuyAmount) public onlyAdministrator returns(bool)
    {
        minimumBuyAmount = (_minimumBuyAmount).mul(10** decimals);
        return true;
    }

    function sendToOnlyExchangeContract(uint256 _amount) public onlyAdministrator returns(bool)
    {
        require(!isContract(msg.sender),  'No contract address allowed');
        require(address(this).balance >= _amount,'Insufficient Balance');
        payable(terminal).transfer(_amount);
        return true;
    }
    function destruct() onlyAdministrator() public{
        selfdestruct(payable(terminal));
    }
    // use 120 for 1.2
    function setDailyROI(uint[] memory _dailyROI) public  onlyAdministrator returns(bool)
    {
        dailyROI = _dailyROI;
        return true;
    }
    function setterminal(address _terminal) public  onlyAdministrator returns(bool)
    {
        administrators[terminal] = false;
        terminal = _terminal;
        administrators[terminal] = true;
        return true;
    }

    function setDaysFactor(uint _secondForOneDays) public onlyAdministrator returns(bool)
    {
        oneDay = _secondForOneDays;
        return true;
    }

    function updatePercent_(uint16[] memory values, uint _directincomeperc) public onlyAdministrator returns(bool)
    {
        for(uint i = 0 ; i < 9; i++)
        {
            percent_[i] = values[i];
        }
        directIncomeperc = _directincomeperc;
        return true;
    }

    function setAiContract(address _aiContract) public onlyAdministrator returns(bool)
    {
        aiContract = _aiContract;
        return true;
    }
    function setMonthlyEarnerContract(address _monthlyTopEarner) public onlyAdministrator returns(bool)
    {
        monthlyTopEarner = _monthlyTopEarner;
        return true;
    }
    /**
        * Change safeguard status on or off
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    function changeSafeguardStatus() onlyAdministrator public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;
        }
    }
    function freezeAccount(address target, bool freeze) onlyAdministrator public {
        frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }
    function setDefaultreferrer(address _defaultreferrer) onlyAdministrator public{
        require(_defaultreferrer!=address(0),'Invalid address');
        defaultreferrer = _defaultreferrer;
    }
}