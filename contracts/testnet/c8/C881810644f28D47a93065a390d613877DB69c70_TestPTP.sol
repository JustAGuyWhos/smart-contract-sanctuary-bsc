// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
contract TestPTP is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 startDate = 1649965200;                           
    uint256 counterId = 0;            
    address originAddress = 0x6b26678F4f392B0E400CC419FA3E5161759ca380;
    uint256 originAmount = 0;  
    uint256 stakerPool = 0; 
    uint256 totalPenalties = 0;
    uint256 unclaimedAAToken = 0;
    uint256 unClaimedBtc = 19000000 * 10 ** 8;
    uint256 claimedBTC = 0;
    uint256 maxValueBPB = 150000000 * 10 ** 8;   
    uint256 divValueBPB = 1500000000 * 10 ** 8;
    uint256 shareRate = 1;
    uint256 claimedBtcAddrCount = 0;
    uint256  BIG_PAY_DAY = 351;
    uint256 unclaimed_BTC_Payout_Bucket = 0;
    uint256 CLAIMABLE_BTC_ADDR_COUNT = 27997742;
    // uint256 totalSharesStaked = 0;

    address[] private referAddresses;
    address[] internal stakeAddress;
    address[] internal freeStakeholders;
    struct transferInfo {
        address to;
        address from; 
        uint256 amount;
    }

    struct freeStakePerDayInfo {
        address walletAddress;
        string btcAddress;
        uint256 balanceAtMoment;
        uint256 dayFreeStake;
    }

     struct freeStakeClaimInfo {
        string btcAddress;
        uint256 balanceAtMoment;
        uint256 dayFreeStake;
        uint256 claimedAmount;
        uint256 rawBtc;
    }

    struct stakeRecord {
       uint256 stakeShare;
       uint numOfDays;
       uint256 currentTime;
       bool claimed;
       uint256 id;
       uint256 startDay;
       uint256 endDay;
       uint256 endDayTimeStamp;
       bool isFreeStake;
       string stakeName;
       uint256 stakeAmount; 
       
    }   
    //Adoption Amplifier Struct
    struct RecordInfo {
        uint256 amount;
        uint256 time;
        bool claimed;
        address user;
        address refererAddress;
    }

    struct referalsRecord {
        address referdAddress;
        uint256 day;
        uint256 awardedPTP;
    }

    struct stakeRewardDailyData{ 
        uint256 day;
        uint256 dailyReward;
        uint256 percentShareOfDay;
        uint256 rewardAmount;
    }

    struct TotalStakedShare{
        uint256 share;
        uint256 endDay;
    }
    mapping(uint256 => mapping(address => RecordInfo)) public AARecords;
    mapping (address => referalsRecord[]) public referals;
    mapping (uint => uint256) public totalETH; 
    mapping (uint => uint256) public totalHexAvailable;
    mapping (uint => bool) public checkDay;
    mapping (uint => bool) public checkFreeStakeDay; 
    mapping (address => address) internal referalAddress;
    mapping (uint256 => address[]) public perDayAARecords;
    mapping(address => uint256) internal stakes;
    mapping(address => stakeRecord[]) public  stakeHolders;
    mapping (address => transferInfo[]) public transferRecords;
    mapping (uint => freeStakePerDayInfo[]) public freeStakeRecords;
    mapping (address => freeStakeClaimInfo[]) public freeStakeClaimRecords;
    mapping (address => uint256) internal balanceAtFreeStake;
    mapping(uint256 => stakeRewardDailyData[]) rewardDataOfStakes;
    mapping(uint256 => uint256) dailyRewardRecords;
    mapping (uint => bool) public dailyShare;
    mapping (uint256 => uint256) public dayTotalStakedShare;
    // mapping (uint => bool) public checkStakeDailyReward;
    event Received(address, uint256);

    constructor() ERC20("10Pantacles", "PTP")  {
    }

    receive() external payable {
        addRecord(msg.sender, msg.value);
    }

    function totalBalance() external view returns(uint) {
     return payable(address(this)).balance;
    }

    function withdraw() public onlyOwner {
     payable(msg.sender).transfer(this.totalBalance());
    }

    function mintAmount(address user, uint256 amount) internal {
         _mint(user,amount);
    }

    function findDay() public view returns(uint) {
        uint day = block.timestamp.sub(startDate);
        day = day.div(180);
        return day;
    }

    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder){
            stakeAddress.push(_stakeholder);
        }
    }

    function isStakeholder(address _address) public view returns(bool, uint256) { 

        for (uint256 s = 0; s < stakeAddress.length; s += 1){
            if (_address == stakeAddress[s]) return (true, s);
        }
        return (false, 0);
    }

    function generateId() public returns(uint256) {
        return counterId++;

    } 

    function findEndDayTimeStamp(uint256 day) public view returns(uint256){
       uint256 futureDays = day.mul(180);
       futureDays = block.timestamp.add(futureDays);
       return futureDays;
    }

    function findMin (uint256 value) public view returns(uint256){
        
        uint256 minValue;
        if(value <=  maxValueBPB){
            minValue = value;
        }
        else{
            minValue = maxValueBPB; 
        }
       return minValue; 
    }

    function findBiggerPayBetter(uint256 inputPTP) public view returns(uint256){
        uint256 minValue = findMin(inputPTP);
        uint256 BPB = inputPTP.mul(minValue);
        BPB = BPB.div(divValueBPB); 
        return BPB;
    }  

    function findLongerPaysBetter(uint256 inputPTP, uint256 numOfDays) public pure returns(uint256){
        uint256 daysToUse = numOfDays.sub(1); 
        uint256 LPB = inputPTP.mul(daysToUse);
        LPB = LPB.div(1820);
        return LPB;
    } 

    function generateShare(uint256 inputPTP, uint256 LPB , uint256 BPB) public view returns(uint256){
            uint256 share = LPB.add(BPB);
            share = share.add(inputPTP);
            share = share.div(shareRate);
            return share;  
    }

    function createStake(uint256 _stake,uint day,string memory stakeName) public {
        uint256 balance = balanceOf(msg.sender);
        require(balance >= _stake,'Not enough amount for staking');
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        if(! _isStakeholder) addStakeholder(msg.sender);
         _burn(msg.sender,_stake);
        uint256 id = generateId();
        uint256 currentDay = findDay();
        uint256 endDay = currentDay.add(day);
        uint256 endDayTimeStamp = findEndDayTimeStamp(day);
        stakerPool = stakerPool.add(_stake);
        uint256 BPB = findBiggerPayBetter(_stake);
        originAmount = originAmount.add(BPB);
        uint256 LPB = findLongerPaysBetter(_stake,day);
        originAmount = originAmount.add(LPB);
        uint256 share = generateShare(_stake,LPB,BPB);
        dayTotalStakedShare[currentDay] = dayTotalStakedShare[day].add(share);
        stakeRecord memory myRecord = stakeRecord({id:id,stakeShare:share,stakeName:stakeName, numOfDays:day, currentTime:block.timestamp,claimed:false,startDay:currentDay,endDay:endDay,
        endDayTimeStamp:endDayTimeStamp,isFreeStake:false,stakeAmount:_stake});
        stakeHolders[msg.sender].push(myRecord);
    }

    function transferStake(uint256 id,address transferTo) public {
     stakeRecord[] memory myRecord = stakeHolders[msg.sender];
     for(uint i=0; i<myRecord.length; i++){
        if(myRecord[i].id == id){
        stakeHolders[transferTo].push(stakeHolders[msg.sender][i]); 
        delete(stakeHolders[msg.sender][i]);
        }
     }
    }

    function setDailyShare (uint256 day) public onlyOwner{
        bool check = dailyShare[day];
        require(!check,'not set twice');
        uint256 fixedPercent = 369;    
        uint256 totalSupply = unClaimedBtc.add(claimedBTC);
        totalSupply = totalSupply.div(10 ** 4);
        uint256 dailyReward = totalSupply.mul(fixedPercent);
        dailyReward = dailyReward.div(10 ** 4);
        dailyReward = dailyReward.div(365);
        dailyRewardRecords[day] = dailyReward * 10 ** 8; 
        dailyShare[day] = true;
    }

    function getDailyShare (uint256 day) public view returns(uint256){
        return  dailyRewardRecords[day];
    }

    function findBPDPercent (uint256 share,uint256 totalSharesOfBPD) public pure returns (uint256){
        uint256 totalShares = totalSharesOfBPD;
        uint256 sharePercent = share * 10 ** 4;
        sharePercent = sharePercent.div(totalShares);
        sharePercent = sharePercent * 10 ** 2;
        return sharePercent;   
    }

    function findStakeSharePercent (uint256 share,uint256 day) public view returns (uint256){
        uint256 totalShares = dayTotalStakedShare[day];
        uint256 sharePercent = share * 10 ** 4;
        sharePercent = sharePercent.div(totalShares);
        sharePercent = sharePercent * 10 ** 2;
        return sharePercent;   
    }

    function _calcAdoptionBonus(uint256 payout)public view returns (uint256){
        uint256 bonus = 0;
        uint256 viral = payout.mul(claimedBtcAddrCount);
        viral = viral.div(CLAIMABLE_BTC_ADDR_COUNT);
        uint256 crit = payout.mul( claimedBTC) ;
        crit = crit.div(unClaimedBtc);
        bonus = viral.add(crit);
        return bonus; 
    }

    function getAllDayReward(uint256 beginDay,uint256 endDay,uint256 stakeShare) public view returns (uint256 ){
         uint256 totalIntrestAmount = 0;
        for (uint256 day = beginDay; day < endDay; day++) {
            totalIntrestAmount += dailyRewardRecords[day].mul(stakeShare).div(dayTotalStakedShare[day]);
            }
          if (beginDay <= BIG_PAY_DAY && endDay > BIG_PAY_DAY) {
              uint256 sharePercentOfBPD = findBPDPercent(stakeShare,dayTotalStakedShare[350]);
              uint256 bigPaySlice = unclaimed_BTC_Payout_Bucket.mul(sharePercentOfBPD);
              bigPaySlice = bigPaySlice.div(100 * 10 ** 4);
              totalIntrestAmount = bigPaySlice.add(_calcAdoptionBonus(bigPaySlice));
            }
        return totalIntrestAmount;
    }

    function findDayDiff(uint256 endDayTimeStamp) public view returns(uint) {
        uint day = block.timestamp.sub(endDayTimeStamp);
        day = day.div(180);
        return day;
    }
    
     function findEstimatedIntrest (uint256 stakeShare,uint256 startDay) public view returns (uint256) {
            uint256 day = findDay();
            uint256 sharePercent = findStakeSharePercent(stakeShare,startDay);
            uint256 dailyEstReward = dailyRewardRecords[day];
            uint256 perDayProfit = dailyEstReward.mul(sharePercent);
            perDayProfit = perDayProfit.div(100 * 10 ** 4);
            return perDayProfit;

    }

    function getDayRewardForPenalty(uint256 beginDay,uint256 stakeShare, uint256 dayData) public view returns (uint256){
         uint256 totalIntrestAmount = 0;
          for (uint256 day = beginDay; day < beginDay.add(dayData); day++) {
            totalIntrestAmount = dailyRewardRecords[day].mul(stakeShare);
            totalIntrestAmount = totalIntrestAmount.div(dayTotalStakedShare[day]);
            }
        return totalIntrestAmount;
    }

    function earlyPenaltyForShort(stakeRecord memory stakeData,uint256 totalIntrestAmount) public view returns(uint256){
            uint256 emergencyDayEnd = findDayDiff(stakeData.currentTime);
            uint256 penalty;
            if(emergencyDayEnd == 0){
                uint256 estimatedAmount = findEstimatedIntrest(stakeData.stakeShare,stakeData.startDay);
                estimatedAmount = estimatedAmount.mul(90);
                penalty = estimatedAmount;
            }

            if(emergencyDayEnd < 90 && emergencyDayEnd !=0){
                penalty = totalIntrestAmount.mul(90);
                penalty = penalty.div(emergencyDayEnd);
               
            }

            if(emergencyDayEnd == 90){
                penalty = totalIntrestAmount;
                
            }

            if(emergencyDayEnd > 90){
                uint256 rewardTo90Days = getDayRewardForPenalty(stakeData.startDay,stakeData.stakeShare,89);
                 penalty = totalIntrestAmount.sub(rewardTo90Days);
            }
            return penalty;
    }

    function earlyPenaltyForLong(stakeRecord memory stakeData,uint256 totalIntrestAmount) public view returns(uint256){
            uint256 emergencyDayEnd = findDayDiff(stakeData.currentTime);
            uint256 endDay = stakeData.numOfDays;
            uint256 halfOfStakeDays = endDay.div(2);
            uint256 penalty ;
            if(emergencyDayEnd == 0){
                uint256 estimatedAmount = findEstimatedIntrest(stakeData.stakeShare,stakeData.startDay);
                estimatedAmount = estimatedAmount.mul(halfOfStakeDays);
                penalty = estimatedAmount;
            }

            if(emergencyDayEnd < halfOfStakeDays && emergencyDayEnd != 0){
                penalty = totalIntrestAmount.mul(halfOfStakeDays);
                penalty = penalty.div(emergencyDayEnd);
            }

            if(emergencyDayEnd == halfOfStakeDays){
                penalty = totalIntrestAmount;
                
            }

            if(emergencyDayEnd > halfOfStakeDays){
                uint256 rewardToHalfDays = getDayRewardForPenalty(stakeData.startDay,stakeData.stakeShare,halfOfStakeDays);
                penalty = totalIntrestAmount.sub(rewardToHalfDays);   
            }
            return penalty;
    }

    function latePenalties (stakeRecord memory stakeData,uint256 totalAmountReturned) public  returns(uint256){
            uint256 dayAfterEnd = findDayDiff(stakeData.endDayTimeStamp);
            if(dayAfterEnd > 14){
            uint256 transferAmount = totalAmountReturned;
            uint256 perDayDeduction = 143 ;
            uint256 penalty = transferAmount.mul(perDayDeduction);
            penalty = penalty.div(1000); 
            penalty = penalty.div(100);
            uint256 totalPenalty = dayAfterEnd.mul(penalty);
            uint256 halfOfPenalty = totalPenalty.div(2);
            totalPenalties = totalPenalties.add(halfOfPenalty);
            originAmount = originAmount.add(halfOfPenalty);
            uint256 actualAmount = 0;
            if(totalPenalty < totalAmountReturned){
            actualAmount = totalAmountReturned.sub(totalPenalty);
            }
            return actualAmount;
            }
            else{
            return totalAmountReturned;
            }
    } 

    function settleStakes (address _sender,uint256 id) internal  {
        stakeRecord[] memory myRecord = stakeHolders[_sender];
        for(uint i=0; i<myRecord.length; i++){
            if(myRecord[i].id == id){
                myRecord[i].claimed = true;
                stakeHolders[_sender][i] = myRecord[i];
            }
        }
    }

    function claimStakeReward (uint id) public  {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        require(_isStakeholder,'Not SH');
        stakeRecord[] memory myRecord2 = stakeHolders[msg.sender];
        stakeRecord memory stakeData;
        for(uint i=0; i<myRecord2.length; i++){
            if(myRecord2[i].id == id){
                stakeData = myRecord2[i];
            }
        }
        uint256 totalIntrestAmount = getAllDayReward(stakeData.startDay,stakeData.endDay,stakeData.stakeShare);
        if(block.timestamp < stakeData.endDayTimeStamp){
            if(stakeData.numOfDays < 180){
                uint256 penalty = earlyPenaltyForShort(stakeData,totalIntrestAmount); 
                uint256 halfOfPenalty = penalty.div(2);
                totalPenalties = totalPenalties.add(halfOfPenalty);
                originAmount = originAmount.add(halfOfPenalty); 
                uint256 compeleteAmount = stakeData.stakeAmount.add(totalIntrestAmount);
                uint256 amountToMint = 0;
                if(penalty < compeleteAmount){ 
                amountToMint = compeleteAmount.sub(penalty);
                }
                mintAmount(msg.sender,amountToMint);
            }
            
            if(stakeData.numOfDays >= 180){
                uint256 penalty = earlyPenaltyForLong(stakeData,totalIntrestAmount); 
                uint256 halfOfPenalty = penalty.div(2);
                totalPenalties = totalPenalties.add(halfOfPenalty);
                originAmount = originAmount.add(halfOfPenalty); 
                uint256 compeleteAmount = stakeData.stakeAmount.add(totalIntrestAmount);
                uint256 amountToMint = 0;
                if(penalty < compeleteAmount){ 
                amountToMint = compeleteAmount.sub(penalty);
                }
                mintAmount(msg.sender,amountToMint);
            }
        }

        if(block.timestamp >= stakeData.endDayTimeStamp){
         uint256 totalAmount = stakeData.stakeAmount.add(totalIntrestAmount);
         uint256 amounToMinted = latePenalties(stakeData,totalAmount);
         mintAmount(msg.sender,amounToMinted);
        }
        // dayTotalStakedShare[day] = dayTotalStakedShare[day].sub(stakeData.stakeShare);
        settleStakes(msg.sender,id);

    }

    function getStakeRecords() public view returns (stakeRecord[] memory stakeHolder) {
        
        return stakeHolders[msg.sender];
    }

    function getDayTotalStakedShare(uint256 day) public view returns (uint256){
        return dayTotalStakedShare[day];
    }
    //Free Stake functionality
    function isFreeStakeholder(address _address) public view returns(bool, uint256) { 
        for (uint256 s = 0; s < freeStakeholders.length; s += 1){
            if (_address == freeStakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function createFreeStakeRecord(address freeStakeHolder,string memory btcAddress,uint256 day,uint256 balance) internal onlyOwner{

        freeStakePerDayInfo memory myRecord = freeStakePerDayInfo({walletAddress:freeStakeHolder,balanceAtMoment:balance,btcAddress:btcAddress,dayFreeStake:day});
        freeStakeRecords[day].push(myRecord);
    }

    function createFreeStake(address user,string memory btcAddress,uint balance) public onlyOwner{
        require(block.timestamp < startDate + 31536000,'Free stakes available just 1 year');
        require(block.timestamp >= startDate ,'Free stakes not started yet');
        require(balance > 0, 'You need to have more than 0 Btc in your wallet');
        // address ownerAddress = owner();
        // require(ownerAddress != user, 'Owner not allowed');
        (bool _isFreeStakeholder, ) = isFreeStakeholder(user);
        if(!_isFreeStakeholder){
            freeStakeholders.push(user);
        }
        uint day = findDay();
        balanceAtFreeStake[user] = balanceAtFreeStake[user].add(balance);
        createFreeStakeRecord(user,btcAddress,day,balance); 
        claimedBtcAddrCount ++ ;
        unClaimedBtc = unClaimedBtc.sub(balance);
        claimedBTC = claimedBTC.add(balance);
      
    }

    function getFreeStakeRecords(uint day) public view returns (freeStakePerDayInfo[] memory freeStakeRecord) {
        
        return freeStakeRecords[day];
    }

    function getRefererAddress(address sender) public view returns(address){
        return referalAddress[sender];
    }

    function findUserReferal(address user) public view returns (address){
        address referer = getRefererAddress(user);
        return referer;

    }

    function findSillyWhalePenalty(uint256 amount) public pure returns (uint256){
        if(amount < 1000e8){
            return amount;
        }
        else if(amount >= 1000e8 && amount < 10000e8){  
            uint256 penaltyPercent = amount.sub(1000e8);
            penaltyPercent = penaltyPercent.mul(25 * 10 ** 2);
            penaltyPercent = penaltyPercent.div(9000e8); 
            penaltyPercent = penaltyPercent.add(50 * 10 ** 2); 
            uint256 deductedAmount = amount.mul(penaltyPercent); 
            deductedAmount = deductedAmount.div(10 ** 4);          
            uint256 adjustedBtc = amount.sub(deductedAmount);  
            return adjustedBtc;   
        }
        else { 
            uint256 adjustedBtc = amount.mul(25);
            adjustedBtc = adjustedBtc.div(10 ** 2);
            return adjustedBtc;  
        }
    }

    function findLatePenaltiy(uint256 dayPassed) public pure returns (uint256){
        uint256 totalDays = 350;
        uint256 latePenalty = totalDays.sub(dayPassed);
        latePenalty = latePenalty.mul( 10 ** 4);
        latePenalty = latePenalty.div(350);
        return latePenalty; 
    }

    function findSpeedBonus(uint256 day,uint256 share) public pure returns (uint256){
      uint256 speedBonus = 0;
      uint256 initialAmount = share;
      uint256 percentValue = initialAmount.mul(20);
      uint256 perDayValue = percentValue.div(350);  
      uint256 deductedAmount = perDayValue.mul(day);      
      speedBonus = percentValue.sub(deductedAmount);
      return speedBonus;

    }

    function findReferalBonus(address user,uint256 share,address referer) public pure returns(uint256) { 
       uint256 fixedAmount = share;
       uint256 sumUpAmount = 0;
      if(referer != address(0)){
       if(referer != user){
         
        // if referer is not user it self
        uint256 referdBonus = fixedAmount.mul(10);
        referdBonus = referdBonus.div(100);
        sumUpAmount = sumUpAmount.add(referdBonus);
       }
       else{
        // if a user referd it self  
        uint256 referdBonus = fixedAmount.mul(20);
        referdBonus = referdBonus.div(100);
        sumUpAmount = sumUpAmount.add(referdBonus);
        }
       }
       return sumUpAmount;
    }

    function createReferalRecords(address refererAddress, address referdAddress,uint256 awardedPTP) public {
        uint day = findDay();
        referalsRecord memory myRecord = referalsRecord({referdAddress:referdAddress,day:day,awardedPTP:awardedPTP});
        referals[refererAddress].push(myRecord);
    }

    function createFreeStakeClaimRecord(address userAddress,string memory btcAddress,uint256 day,uint256 balance,uint256 claimedAmount) internal onlyOwner{

     freeStakeClaimInfo memory myRecord = freeStakeClaimInfo({btcAddress:btcAddress,balanceAtMoment:balance,dayFreeStake:day,claimedAmount:claimedAmount,rawBtc:unClaimedBtc});
     freeStakeClaimRecords[userAddress].push(myRecord);
    }

    function freeStaking(uint256 stakeAmount,address userAddress) internal onlyOwner {
        uint256 id = generateId();
        uint256 dayInYear = 365;
        uint256 startDay = findDay();
        uint256 endDay = startDay.add(dayInYear);   
        uint256 endDayTimeStamp = findEndDayTimeStamp(endDay);
        // uint256 roiPercent = findPercentSlot();
        // uint256 BPB = findBiggerPayBetter(stakeAmount);
        stakerPool = stakerPool.add(stakeAmount);        
        // originAmount = originAmount.add(BPB);
        // uint256 LPB = findLongerPaysBetter(stakeAmount,dayInYear);
        // originAmount = originAmount.add(LPB);
        uint256 share = generateShare(stakeAmount,0,0);

        stakeRecord memory myRecord = stakeRecord({id:id,stakeShare:share, stakeName:'', numOfDays:dayInYear,
         currentTime:block.timestamp,claimed:false,startDay:startDay,endDay:endDay,
        endDayTimeStamp:endDayTimeStamp,isFreeStake:true,stakeAmount:stakeAmount});
        stakeHolders[userAddress].push(myRecord); 

    }

    function distributeFreeStake(uint256 day) public  onlyOwner {
        //  require(block.timestamp < startDate + 31536000,'End');
         bool _findDay = checkFreeStakeDay[day]; 
         require(!_findDay,"can't set again");
         checkFreeStakeDay[day] = true;
         freeStakePerDayInfo[] memory freeStakeRecord = getFreeStakeRecords(day);
         if(freeStakeRecord.length > 0) {    
             for(uint i = 0; i < freeStakeRecord.length; i++){
                address userReferer = findUserReferal(freeStakeRecord[i].walletAddress);
                uint256 balance = freeStakeRecord[i].balanceAtMoment;
                uint256 sillyWhaleValue = findSillyWhalePenalty(balance);
                uint share = sillyWhaleValue * 10 ** 8;
                share = share.div(10 ** 4);
                uint256 actualAmount = share;  
                uint256 latePenalty = findLatePenaltiy(freeStakeRecord[i].dayFreeStake);
                actualAmount = actualAmount.mul(latePenalty);
                //Late Penalty return amount in 4 decimal to avoid decimal issue,
                // we didvide with 10 ** 4 to find actual amount 
                actualAmount = actualAmount.div(10 ** 4);
                //Speed Bonus
               
                uint256 userSpeedBonus = findSpeedBonus(freeStakeRecord[i].dayFreeStake,actualAmount);
                userSpeedBonus = userSpeedBonus.div(100);
                actualAmount = actualAmount.add(userSpeedBonus);
                originAmount = originAmount.add(actualAmount);

                uint256 refBonus = 0;
                address userAddress = freeStakeRecord[i].walletAddress;
                string memory btcAddress = freeStakeRecord[i].btcAddress;
                uint256 balanceAtMoment = freeStakeRecord[i].balanceAtMoment;
                uint256 dayFreeStake = freeStakeRecord[i].dayFreeStake;  
           //Referal Mints 
            if(userReferer != userAddress && userReferer != address(0)){
                uint256 amount = share;
                uint256 referingBonus = amount.mul(20);
                referingBonus = referingBonus.div(100);
                originAmount = originAmount.add(referingBonus);
                mintAmount(userReferer,referingBonus);
           }
        
         //Referal Bonus
            if(userReferer != address(0)){
            refBonus = findReferalBonus(userAddress,share,userReferer);
            actualAmount = actualAmount.add(refBonus);
            originAmount = originAmount.add(refBonus);
            createReferalRecords(userReferer,userAddress,refBonus);
          }
         uint256 mintedValue = actualAmount.mul(10); 
         mintedValue = mintedValue.div(100);
         mintAmount(userAddress,mintedValue); 
         createFreeStakeClaimRecord(userAddress,btcAddress,dayFreeStake,balanceAtMoment,mintedValue);

         uint256 stakeAmount = actualAmount.mul(90);
         stakeAmount = stakeAmount.div(100); 
         freeStaking(stakeAmount,userAddress);

            }
         
        }

    }

    function getFreeStakeClaimRecord() public view returns (freeStakeClaimInfo[] memory claimRecords){
       return freeStakeClaimRecords[msg.sender];
    } 

    function extendStakeLength(uint256 totalDays, uint256 id) public { 
        stakeRecord[] memory myRecord = stakeHolders[msg.sender];
        for(uint i=0; i<myRecord.length; i++){
            if(myRecord[i].id == id){
                if(myRecord[i].isFreeStake){
                    if(totalDays >= 365){
                        require(myRecord[i].startDay + totalDays > myRecord[i].numOfDays , 'condition should not be meet');
                        myRecord[i].numOfDays = myRecord[i].startDay + totalDays;
                        myRecord[i].endDay = (myRecord[i].startDay).add(totalDays);
                        myRecord[i].endDayTimeStamp = findEndDayTimeStamp(myRecord[i].endDay);
                    }
                }
                else{
                    if(totalDays >= 1){
                        require(myRecord[i].startDay + totalDays > myRecord[i].numOfDays , 'condition should not be meet');
                        myRecord[i].numOfDays = myRecord[i].startDay + totalDays;
                        myRecord[i].endDay = (myRecord[i].startDay).add(totalDays);
                        myRecord[i].endDayTimeStamp = findEndDayTimeStamp(myRecord[i].endDay);
                    }
                }
           stakeHolders[msg.sender][i] = myRecord[i];
            }
        }
    }

    function findAddress(uint256 day, address sender)public view returns(bool){
        address addressValue = AARecords[day][sender].user;
        if(addressValue == address(0)){
            return false;
        }
        else{
           return true;
        }
    }

    function addRecord (address _sender, uint256 _amount) internal {
        require(_amount > 0, '0 Balance');
        uint day = findDay();
        address refererAddress = getRefererAddress(_sender);
        RecordInfo memory myRecord = RecordInfo({amount: _amount, time: block.timestamp, claimed: false, user:_sender,refererAddress:refererAddress});
        bool check = findAddress(day,_sender);
        if(check == false){
            AARecords[day][_sender] = myRecord;
            perDayAARecords[day].push(_sender);
        }  
        else{
            RecordInfo memory record = AARecords[day][_sender];
            record.amount = record.amount.add(_amount);
            AARecords[day][_sender] = record;
        }
      
        totalETH[day] = totalETH[day] + _amount;
    }

    function setAvailabePTP (uint256 day) public onlyOwner {
       //  require(block.timestamp < startDate + 31536000,'END');
        uint256 hexAvailabel = 0;
       
        uint256 firstDayAvailabilty = 1000000000 * 10 ** 8; 
        if(day == 0){
            hexAvailabel = firstDayAvailabilty;
        }
        else{
            uint256 othersDayAvailability = unClaimedBtc;
            //as per rules we have to multiply it with 10^8 than divided with 10 ^ 4 but as we can make it multiply 
            //with 10 ^ 4
            othersDayAvailability = othersDayAvailability.mul(10 ** 4);
            hexAvailabel = othersDayAvailability.div(350);
            if(day > 1){
                unclaimedRecord(day);
            }
        }
 
        bool _findDay = checkDay[day]; 
        require(!_findDay,"can't set again");
        totalHexAvailable[day] = totalHexAvailable[day].add(hexAvailabel);
        checkDay[day] = true;
    }

    function getTotalBNB (uint day) public view returns (uint256){
       return totalETH[day];
    }

    function getAvailablePTP (uint day) public view returns (uint256){
       return totalHexAvailable[day];
    }

    function getTransactionRecords(uint day,address user) public view returns (RecordInfo memory record) {   
            return AARecords[day][user];
    }

    function countShare (uint256 userSubmittedBNB, uint256 dayTotalBNB, uint256 availablePTP) public pure returns  (uint256) {
        uint256 share = 0;
        share = userSubmittedBNB.div(dayTotalBNB);
        share = share.mul(availablePTP);
        return share;
    }

    function settleSubmission (uint day, address user) internal  {
        RecordInfo memory myRecord = AARecords[day][user];
                 myRecord.claimed = true;
                 AARecords[day][user] = myRecord;
    }

    function claimAATokens () public {
        uint256 presentDay = findDay();
        require(presentDay > 0,'not now');
        uint256 prevDay = presentDay.sub(1);
        uint256 dayTotalBNB = getTotalBNB(prevDay);
        uint256 availablePTP = getAvailablePTP(prevDay);
        RecordInfo memory record = getTransactionRecords(prevDay,msg.sender);
        if(record.user != address(0) && record.claimed == false){
           uint256 userSubmittedBNB = record.amount;
           uint256 userShare = 0;
           uint256 referalBonus = 0;
           userShare = countShare(userSubmittedBNB,dayTotalBNB,availablePTP);
            address userReferer = findUserReferal(msg.sender);
             if(userReferer != msg.sender && userReferer !=address(0)){
             uint256 amount = userShare;
             uint256 referingBonus = amount.mul(20);
             referingBonus = referingBonus.div(100);
             originAmount = originAmount.add(referingBonus);
             mintAmount(userReferer,referingBonus);
             createReferalRecords(userReferer,msg.sender,referingBonus);
             }
            referalBonus =  findReferalBonus(msg.sender,userShare,userReferer);  
             userShare = userShare.add(referalBonus);
             originAmount = originAmount.add(referalBonus);
             mintAmount(msg.sender,userShare);
             settleSubmission(prevDay,msg.sender);
             if(userReferer != address(0)){
            createReferalRecords(userReferer,msg.sender,referalBonus);
             }
        }
    }

    function foundUserReferals(address sender) public view returns(address[] memory a) {
     address[] memory userReferalAccounts = new address[](referAddresses.length);
        for(uint i = 0; i< referAddresses.length; i++){
            if(referalAddress[referAddresses[i]] == sender){
                userReferalAccounts[i]=referAddresses[i];
            }
        }
        return userReferalAccounts;
    }

    function getReferalRecords(address refererAddress) public view returns (referalsRecord[] memory referal) {
        
        return referals[refererAddress];
    }

    function unclaimedRecord(uint256 presentDay) internal onlyOwner {
        uint256 prevDay = presentDay.sub(2);
        uint256 dayTotalBNB = getTotalBNB(prevDay);
        uint256 availablePTP = getAvailablePTP(prevDay);
        address[] memory allUserAddresses = perDayAARecords[prevDay];
        if(allUserAddresses.length > 0){
            for(uint i = 0; i < allUserAddresses.length; i++){
                uint256 userSubmittedBNB = 0;
                uint256 userShare = 0;
                RecordInfo memory record = getTransactionRecords(prevDay,allUserAddresses[i]);
                if(record.claimed == false){
                    userSubmittedBNB = record.amount;
                    userShare = countShare(userSubmittedBNB,dayTotalBNB,availablePTP);
                    unclaimedAAToken = unclaimedAAToken.add(userShare);
                    settleSubmission(prevDay,allUserAddresses[i]);
                }
            
            } 
        }  
        else{
         unclaimedAAToken = unclaimedAAToken.add(availablePTP);
        }
    }

    function transferPTP(address recipientAddress, uint256 _amount) public{
        _transfer(msg.sender,recipientAddress,_amount);
        transferInfo memory myRecord = transferInfo({amount: _amount,to:recipientAddress, from: msg.sender});
        transferRecords[msg.sender].push(myRecord);
    }

    function getTransferRecords( address _address ) public view returns (transferInfo[] memory transferRecord) {
        return transferRecords[_address];
    }
    //Origin Amount
    function getOriginAmount() public view returns (uint256){
        return originAmount;
    }

    function setBigPayDay() public onlyOwner{
        uint256 btc = unClaimedBtc.div(10 ** 8);
        uint256 bigPayDayAmount = btc.mul(2857);
        //it should be divieded with 10 ** 6 but we have to convert it in hex so we div it 10 ** 2

        bigPayDayAmount = bigPayDayAmount.div(10 ** 2);
        unclaimed_BTC_Payout_Bucket = unclaimed_BTC_Payout_Bucket.add(bigPayDayAmount);
    }

    function getBigPayDay() public view returns (uint256){
        return unclaimed_BTC_Payout_Bucket;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}