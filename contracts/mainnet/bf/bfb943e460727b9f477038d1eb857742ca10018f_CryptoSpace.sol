/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

/**
 *Submitted for verification at Etherscan.io on 2022-06-27
*/

// File: Name.sol


//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678, 0x17F6AD8Ef982297579C203069C1DbfFE4348c372
pragma solidity ^0.8.9;

contract CryptoSpace {

    struct User {
        uint id;
        address referrer;
        uint levelsInRow;
        uint extraBR;
        mapping(uint => uint) lostMoney;
        mapping(uint => uint) freezedReferralReward;
        mapping(uint => bool) levelWasActivated;
        mapping(uint => bool) levelIsActive;
        mapping(uint => uint) levelToPlace;
        mapping(uint => uint) levelToAbsolutePlace;
        mapping(uint => uint) usersBeforePayment;
        mapping(uint => bool) Insurance;
        mapping(uint => uint) gottenRewards;
        mapping(uint => uint) gottenReferralRewards;
        mapping(uint => uint) reinvests;
    }

    struct Structure {
        uint StructureId;
        address mainTableLevel;
        address[4] firstTableLevel;
        address[6] secondTableLevel;
        uint freePlace;
        bool blocked;
    }

    struct Level{
    uint freeAbsolutePlace;
    mapping(uint => Structure) idToStructure;
    }

    uint constant LAST_LEVEL = 15;
    uint lastUserId = 5;
    uint reinvestCounter;
    uint registrationCost = 700000000000 wei;
    uint startProjectTime;
    bool freezedReferralRewardSending;

    mapping(uint => Level) levelToStructure;
    mapping(address => User) users;
    mapping(uint => address) idToAddress;
    mapping(uint => uint) minFreeSecondLevelStructure;
    mapping(uint => uint) minFreeFirstLevelStructure;
    bool[16] public levelIsAvailable;
    mapping(uint => mapping (uint => address)) pendingAddresses;
    mapping(uint => bool) expectationLevel;
    mapping(uint => uint) numberOfPendingAddresses;
    mapping(uint => uint) levelStartTime;
    mapping(uint => uint) referralRewardsSendTime;
    mapping(uint => uint) usersAtLevel;
    
    mapping(uint => uint) public levelPrice;
    mapping (uint => uint) public BRPercent;
    mapping (uint => uint) public referralsPercent;

    mapping(uint => address) owners;

    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Upgrade(address indexed user, uint structure, uint level);
    event NewUserPlace(address indexed user, uint structure, uint level, uint place);
    
    
    constructor(address ownerAddress, address ownerAddress1, address ownerAddress2, address ownerAddress3, address ownerAddress4, address backupAddress, address marketingAddress) {
        serValues();
        startProjectTime = block.timestamp;
        owners[1] = ownerAddress;
        owners[2] = ownerAddress1;
        owners[3] = ownerAddress2;
        owners[4] = ownerAddress3;
        owners[5] = ownerAddress4;
        owners[6] = backupAddress;
        owners[7] = marketingAddress;

        Structure memory structure = Structure({
            StructureId: 1,
            mainTableLevel: owners[1],
            firstTableLevel:[owners[2],owners[3],owners[4],owners[5]],
            secondTableLevel:[address(0),address(0),address(0),address(0),address(0),address(0)],
            freePlace: 6,
            blocked: false
        });

        for (uint i = 1; i <=5; i++) {
            users[owners[i]].id = i;
        users[owners[i]].referrer = owners[i];
        users[owners[i]].levelsInRow = 15;
        idToAddress[i] = owners[i];
        }
    
       for (uint i = 1; i <= LAST_LEVEL; i++) {
           for (uint j = 1; j <= 5; j++){
               users[owners[j]].levelWasActivated[i] = true;
               users[owners[j]].levelIsActive[i] = true;
               users[owners[j]].levelToPlace[i] = j;
               users[owners[j]].levelToAbsolutePlace[i] = j;
           }
           levelToStructure[i].idToStructure[1] = structure;
           levelToStructure[i].freeAbsolutePlace = 6;
           usersAtLevel[i] = 5;
       }
    }

    function getStart() external view returns(uint time) {
        return(block.timestamp);
    }

    modifier onlyOwner() {
      require(owners[1] == msg.sender, "Ownable: caller is not the owner");
      _;
    }  

    modifier levelIsOpen(uint level) {
      require(block.timestamp >= levelStartTime[level] && levelStartTime[level] > 0, "level is not opened");
      _;
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == registrationCost, "registration cost 1");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

        sendOnBackupAddress(0);
        
        lastUserId++;
        users[userAddress].id = lastUserId;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
                
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function buyNewLevel(uint level) public payable levelIsOpen(level) {
        if (!levelIsAvailable[level]) {
            _openLevel(level);
        }
        address userAddress = msg.sender;
        uint _levelPrice = levelPrice[level];
        if (users[userAddress].Insurance[level]) {
            _levelPrice += (_levelPrice * 5 / 100);
        }
        require(isUserExists(userAddress), "user is not exists. Register first.");
        require(level > 0 && level <= LAST_LEVEL, "invalid level");
        require(!users[userAddress].levelIsActive[level], "level already activated");
        require(msg.value == _levelPrice, "invalid amount");
        usersAtLevel[level]++;
        if (users[userAddress].Insurance[level]) {
         sendOnBackupAddress(level);    
        }
             
        users[userAddress].levelIsActive[level] = true;
        users[userAddress].levelWasActivated[level] = true;
        users[userAddress].reinvests[level] = reinvestCounter;

        if (level > 8) {
            uint _levelsInRow;
            for (uint i = 1; i <= 15; i++) {
                if (users[userAddress].levelIsActive[i] == false) {
                    break;
                }
                _levelsInRow = i;
            }
            users[userAddress].levelsInRow = _levelsInRow;
            if (_levelsInRow > 8) {
                users[userAddress].extraBR = BRPercent[_levelsInRow];
            }
        }

        updateStructure(userAddress, minFreeSecondLevelStructure[level], level);
           
        emit Upgrade(userAddress, minFreeSecondLevelStructure[level], level);
    }  

     function buyNewLevelWithInsurance(uint level) external payable levelIsOpen(level) {
        users[msg.sender].Insurance[level] = true;
        buyNewLevel(level);
    }  

    function paymentOfInsurance() external onlyOwner{
        for (uint i = 6; i <=lastUserId; i++) {
            uint InsurancePayment = 0;
            for (uint j = 1; j <= LAST_LEVEL; j++) {
                if (users[idToAddress[i]].Insurance[j]) {
                   InsurancePayment +=levelPrice[j] * 20 / 100;
                }
            }
            if (InsurancePayment > 0) {
               paymentCall(InsurancePayment, idToAddress[i]);
            }
        }
    }

    function paymentCall(uint Ipayment, address Iaddress) public payable onlyOwner {
        (bool success, bytes memory data) = owners[6].call
        (abi.encodeWithSignature("payment(uint256,address)", Ipayment, Iaddress));
    }

    function setlevelStartTime(uint level, uint time) external onlyOwner {
        levelStartTime[level] = time;
    }

    function _openLevel(uint level) internal {
        levelIsAvailable[level] = true;
        expectationLevel[level] = true;
        referralRewardsSendTime[level] = block.timestamp + 300;
    }

    function openLevel(uint level) external onlyOwner {
        require(!levelIsAvailable[level], "level is already opened");
        levelIsAvailable[level] = true;
        expectationLevel[level] = true;
        levelStartTime[level]++;
        referralRewardsSendTime[level] = block.timestamp + 300;
    }

    function sendFreezedReferralRewards(uint level) external onlyOwner {
        require(block.timestamp >= referralRewardsSendTime[level], "less than 5 minutes have passed since the opening of the level"); 
        require(referralRewardsSendTime[level] > 0, "level is not opened"); 
        expectationLevel[level] = false;
        if (numberOfPendingAddresses[level] > 0) {
            for (uint i = 1; i <= numberOfPendingAddresses[level]; i++) {
                freezedReferralRewardSending = true;
                sendReferralRewards(pendingAddresses[level][i], level);
            }
        }
    }

    function updateStructure(address userAddress, uint StructureId, uint level) private {
        users[userAddress].levelToPlace[level] = levelToStructure[level].idToStructure[StructureId].freePlace;
        users[userAddress].levelToAbsolutePlace[level] = levelToStructure[level].freeAbsolutePlace;
        users[userAddress].usersBeforePayment[level] = usersBeforeFirstPandingCounter(userAddress, level);
        
        levelToStructure[level].idToStructure[StructureId].secondTableLevel[(levelToStructure[level].idToStructure[StructureId].freePlace) - 6] = userAddress;
        levelToStructure[level].idToStructure[StructureId].freePlace++;
        levelToStructure[level].freeAbsolutePlace++;
        emit NewUserPlace(userAddress, StructureId, level, uint(users[userAddress].levelToPlace[level]));

        sendRewards(userAddress, StructureId, level);

        if (levelToStructure[level].idToStructure[StructureId].freePlace == 12){
            upgradeStructure(StructureId, level);
        }
    }

    function upgradeStructure(uint256 StructureId, uint level) private {

        for(uint i = 0; i < 4; i++) {
            address newMainTableLevel = levelToStructure[level].idToStructure[StructureId].firstTableLevel[i];
            uint256 newMatrixId = users[newMainTableLevel].levelToAbsolutePlace[level];
            Structure memory structure = Structure({
                StructureId: newMatrixId,
                mainTableLevel: newMainTableLevel,
                firstTableLevel:[address(0),address(0),address(0),address(0)],
                secondTableLevel:[address(0),address(0),address(0),address(0),address(0),address(0)],
                freePlace: 2,
                blocked: false
            });
            levelToStructure[level].idToStructure[newMatrixId] = structure;
            users[newMainTableLevel].levelToPlace[level] = 1;
        }

        address mainAddress = levelToStructure[level].idToStructure[StructureId].mainTableLevel;
        uint newfreePlace = levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].freePlace;

        for (uint i = 0; i < 6; i++) {
             if (newfreePlace > 5){
                 minFreeFirstLevelStructure[level]++;
                 newfreePlace = levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].freePlace;
             }          
             levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].firstTableLevel[newfreePlace - 2] = levelToStructure[level].idToStructure[StructureId].secondTableLevel[i];
             users[levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].firstTableLevel[newfreePlace - 2]].levelToPlace[level] = newfreePlace;
             levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].freePlace++;
             newfreePlace++;
        }

        if (users[mainAddress].id < 6) {
             if (newfreePlace > 5) {
                 minFreeFirstLevelStructure[level]++;
                 newfreePlace = levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].freePlace;
             }
            levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].firstTableLevel[newfreePlace - 2] = mainAddress;
            users[mainAddress].levelToPlace[level] = newfreePlace;
            users[mainAddress].levelToAbsolutePlace[level] = levelToStructure[level].freeAbsolutePlace;
            levelToStructure[level].freeAbsolutePlace++;
            levelToStructure[level].idToStructure[minFreeFirstLevelStructure[level]].freePlace++;
            reinvestCounter++;
        } else {
            users[mainAddress].levelIsActive[level] = false;
            users[mainAddress].levelToPlace[level] = 0;
            users[mainAddress].levelToAbsolutePlace[level] = 0;
            uint _levelsInRow = users[mainAddress].levelsInRow;
            if (_levelsInRow > 8 && level <= _levelsInRow) {
                users[mainAddress].levelsInRow = level - 1;
                if (users[mainAddress].levelsInRow > 8){
                    users[mainAddress].extraBR = BRPercent[_levelsInRow];
                } else {
                    users[mainAddress].extraBR = 0;           
                }
            }
        }
        
        levelToStructure[level].idToStructure[StructureId].blocked = true;
        minFreeSecondLevelStructure[level]++;
    }

    function sendRewards(address userAddress, uint256 StructureId, uint level) private {
        address payable receiver;
        if (users[userAddress].levelToPlace[level] == 11) {
              receiver = payable(levelToStructure[level].idToStructure[StructureId].mainTableLevel);
              users[receiver].usersBeforePayment[level] = 0;
        } else {
              if (users[userAddress].levelToPlace[level] == 8) {
                  receiver = payable(levelToStructure[level].idToStructure[StructureId].mainTableLevel);
                  users[receiver].usersBeforePayment[level] = 3;
              } else {
                    if (users[userAddress].levelToPlace[level] < 8 ) {
                        receiver = payable(levelToStructure[level].idToStructure[StructureId].firstTableLevel[users[userAddress].levelToPlace[level] - 6]);
                    } else {
                        receiver = payable(levelToStructure[level].idToStructure[StructureId].firstTableLevel[users[userAddress].levelToPlace[level] - 7]);
                       }
                    users[receiver].Insurance[level] = false;
                    users[receiver].usersBeforePayment[level] = usersBeforeSecondPandingCounter(receiver, level);
              }
        }

         uint BR;
        if (users[receiver].extraBR > 0) {
            BR = users[receiver].extraBR;
            } else {
                BR = BRPercent[level];
            }
        receiver.transfer(levelPrice[level]*BR/100);
        users[receiver].gottenRewards[level]+=levelPrice[level]*BR/100;
        

        if (expectationLevel[level] && referralRewardsSendTime[level] > block.timestamp && referralRewardsSendTime[level] > 0) {
            uint n = 0;
            address nextReferrer = userAddress;
            while (n <=6) {
                address _referrer = users[nextReferrer].referrer;
                if (users[_referrer].levelWasActivated[level]) {
                    n++;
                    nextReferrer = _referrer;
                } else {
                    break;
                }
            }
            if (n == 7) {
                sendReferralRewards(userAddress, level);
            } else {
                numberOfPendingAddresses[level]++;
                pendingAddresses[level][numberOfPendingAddresses[level]] = userAddress;
                uint i = 0;
                address _nextReferrer = userAddress;
                while (i <=6) {
                    address _referrer = users[_nextReferrer].referrer;
                    if (users[_referrer].levelWasActivated[level]) {
                        i++;
                    } else {
                        users[_referrer].freezedReferralReward[level] += levelPrice[level]*referralsPercent[i+1]/100;
                    }
                    _nextReferrer = _referrer;
                }
            }
        } else {
            sendReferralRewards(userAddress, level);
        }
            

        address payable _marketing = payable(owners[7]);
        uint marketingPercent = (77 - BR);
        _marketing.transfer(levelPrice[level]*marketingPercent/100);
    }

    function sendReferralRewards(address userAddress, uint level) private {
        address nextReferrer = userAddress;
        uint j = 1;
        while (j<= 7) {
        address payable _referrer = payable(users[nextReferrer].referrer);
        if (users[_referrer].levelWasActivated[level]){
            if (freezedReferralRewardSending) {
                users[_referrer].freezedReferralReward[level] = 0;
            }
            _referrer.transfer(levelPrice[level]*referralsPercent[j]/100);
            users[_referrer].gottenReferralRewards[level]+=levelPrice[level]*referralsPercent[j]/100;
            j++;
        } else {
            users[_referrer].lostMoney[level]+=levelPrice[level]*referralsPercent[j]/100;
        }
        nextReferrer = _referrer;
        }
        freezedReferralRewardSending = false;
    }

    function sendOnBackupAddress(uint level) private {
        address payable receiver = payable(owners[6]);
        if (level == 0){
            receiver.transfer(registrationCost);
        } else {
        receiver.transfer(levelPrice[level]*5/100);
        }
    }

    function isUserExists(address userAddress) public view returns (bool) {
        return (users[userAddress].id != 0);
    }

    function usersBeforeFirstPandingCounter(address userAddress, uint level) internal view returns (uint) {
        uint n = users[userAddress].levelToAbsolutePlace[level];
        if (n % 2 == 0) {
            return (((n-4)/2) + 5 + reinvestCounter + (reinvestCounter/2));
        } else {
        return (((n-5)/2) + 5 + reinvestCounter + ((reinvestCounter+1)/2));
        }
    }

    function usersBeforeSecondPandingCounter(address userAddress, uint level) internal view returns (uint) {
        return (6 * (users[userAddress].levelToAbsolutePlace[level] - levelToStructure[level].idToStructure[minFreeSecondLevelStructure[level]].StructureId - 1)
         + 15 - levelToStructure[level].idToStructure[minFreeSecondLevelStructure[level]].freePlace);
    }
    
    function availableLevels() public view returns(bool[16] memory) {
        return(levelIsAvailable);
    }

    function getlevelPrices() public onlyOwner view returns(uint[16] memory levelPrices) {
        uint[16] memory _levelPrices;
        for (uint i = 1; i < 16; i++) {
            _levelPrices[i] = levelPrice[i];
        }
        return(_levelPrices);
    }

    function userDataes(uint level, address userAddress) public onlyOwner view returns(uint id, address ref, uint levelsInRow,
    uint extraBR, uint lostMoney, bool levelWasActivate, bool levelIsActive, uint placeInStructure, uint absolutePlaceInLevel, uint usersBeforePayment, bool insurance) {
        address ad = userAddress;
        uint Lev = level;
        return (users[ad].id, users[ad].referrer, users[ad].levelsInRow, users[ad].extraBR,
        users[ad].lostMoney[Lev], users[ad].levelWasActivated[Lev], users[ad].levelIsActive[Lev], users[ad].levelToPlace[Lev],
        users[ad].levelToAbsolutePlace[Lev], users[ad].usersBeforePayment[Lev], users[ad].Insurance[Lev]);
    }

    function userSiteDataes(address userAddress) public onlyOwner view returns(uint extraBR, uint[16] memory lostMoney, bool[16] memory levelWasActivated, bool[16] memory levelIsActive, 
    uint[16] memory usersBeforePayment, bool[16] memory insurance, uint[16] memory userRewards, uint[16] memory userReferralRewards) {
        address ad = userAddress;
        uint[16] memory _lostMoney;
        bool[16] memory _levelWasActivated;
        bool[16] memory _levelIsActive;
        uint[16] memory _usersBeforePayment;
        bool[16] memory _insurance;
        uint[16] memory _userRewards;
        uint[16] memory _userReferralRewards;
        for (uint i = 1; i < 16; i++) {
            _lostMoney[i] = users[ad].lostMoney[i];
            _levelWasActivated[i] = users[ad].levelWasActivated[i];
            _levelIsActive[i] = users[ad].levelIsActive[i];
            _usersBeforePayment[i] = users[ad].usersBeforePayment[i];
            _insurance[i] = users[ad].Insurance[i];
            _userRewards[i] = users[ad].gottenRewards[i];
            _userReferralRewards[i] = users[ad].gottenReferralRewards[i];
        }
        return (users[ad].extraBR, _lostMoney, _levelWasActivated, _levelIsActive, _usersBeforePayment, _insurance, _userRewards, _userReferralRewards);
    }

    function userSiteDatesTwo(address userAddress) public onlyOwner view returns(uint[16] memory freezedReferralReward) {
        uint[16] memory _freezedReferralReward;
        for (uint i = 1; i < 16; i++) {
            _freezedReferralReward[i] = users[userAddress].freezedReferralReward[i];
        }
        return (_freezedReferralReward);
    }

    function levelStartTimeDates() public onlyOwner view returns(uint[16] memory levelsStartTime) {
        uint[16] memory _levelStartTime;
        for (uint i = 1; i < 16; i++) {
            _levelStartTime[i] = levelStartTime[i];
        }
        return (_levelStartTime);
    }

    function paymentProgressDates(address userAddress) public onlyOwner view returns(uint[16] memory userAbsolutePlace, uint[16] memory reinvest) {
        uint[16] memory _userAbsolutePlace;
         uint[16] memory _reinvest;
        for (uint i = 1; i < 16; i++) {
            _userAbsolutePlace[i] = users[userAddress].levelToAbsolutePlace[i];
            _reinvest[i] = users[userAddress].reinvests[i];
        }
        return (_userAbsolutePlace, _reinvest);
    }

    function userAtLevelDates() public onlyOwner view returns(uint[16] memory usersAtTheLevel) {
        uint[16] memory _usersAtTheLevel;
        for (uint i = 1; i < 16; i++) {
            _usersAtTheLevel[i] = usersAtLevel[i];
        }
        return (_usersAtTheLevel);
    }

    // function structureDates(uint256 StructureId, uint level) public view returns(uint, address, address[4] memory, address[6] memory, uint freePlace, bool StructureIsBlocked) {
    //     return (levelToStructure[level].idToStructure[StructureId].StructureId,
    //            levelToStructure[level].idToStructure[StructureId].mainTableLevel,
    //            levelToStructure[level].idToStructure[StructureId].firstTableLevel,
    //            levelToStructure[level].idToStructure[StructureId].secondTableLevel,
    //            levelToStructure[level].idToStructure[StructureId].freePlace,
    //            levelToStructure[level].idToStructure[StructureId].blocked);
    // }

    function balance() public view returns (uint) {
return (address(this).balance);
    }

    function serValues() private {
        BRPercent[1] = 60;
        BRPercent[2] = 60;
        BRPercent[3] = 60;
        BRPercent[4] = 60;
        BRPercent[5] = 60;
        BRPercent[6] = 60;
        BRPercent[7] = 60;
        BRPercent[8] = 60;
        BRPercent[9] = 61;
        BRPercent[10] = 63;
        BRPercent[11] = 66;
        BRPercent[12] = 69;
        BRPercent[13] = 72;
        BRPercent[14] = 76;
        BRPercent[15] = 77;

        referralsPercent[1] = 8;
        referralsPercent[2] = 5;
        referralsPercent[3] = 3;
        referralsPercent[4] = 2;
        referralsPercent[5] = 2;
        referralsPercent[6] = 2;
        referralsPercent[7] = 1;

        levelPrice[1] = 13000000000000 wei;
        levelPrice[2] = 17000000000000 wei; 
        levelPrice[3] = 24000000000000 wei;
        levelPrice[4] = 35000000000000 wei;
        levelPrice[5] = 50000000000000 wei;
        levelPrice[6] = 65000000000000 wei;
        levelPrice[7] = 90000000000000 wei;
        levelPrice[8] = 120000000000000 wei;
        levelPrice[9] = 170000000000000 wei;
        levelPrice[10] = 260000000000000 wei;
        levelPrice[11] = 390000000000000 wei;
        levelPrice[12] = 610000000000000 wei;
        levelPrice[13] = 960000000000000 wei;
        levelPrice[14] = 1400000000000000 wei;
        levelPrice[15] = 2200000000000000 wei;
        
        for (uint i = 1; i <= LAST_LEVEL; i++) {
            minFreeSecondLevelStructure[i] = 1;
            minFreeFirstLevelStructure[i] = 2;
        }
    }
}