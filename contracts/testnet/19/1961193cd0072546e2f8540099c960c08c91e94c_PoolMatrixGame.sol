/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT                                                               
//      ____              __   __  ___      __       _         ______                   
//     / __ \____  ____  / /  /  |/  /___ _/ /______(_)  __   / ____/___ _____ ___  ___ 
//    / /_/ / __ \/ __ \/ /  / /|_/ / __ `/ __/ ___/ / |/_/  / / __/ __ `/ __ `__ \/ _ \
//   / ____/ /_/ / /_/ / /  / /  / / /_/ / /_/ /  / />  <   / /_/ / /_/ / / / / / /  __/
//  /_/    \____/\____/_/  /_/  /_/\__,_/\__/_/  /_/_/|_|   \____/\__,_/_/ /_/ /_/\___/                                                                                     
                                                                
pragma solidity ^0.8.17;

contract PoolMatrixGame {

    uint constant LEVELS_COUNT = 20;
    uint constant ROOT_WALLETS_COUNT = 4;
    uint constant SECONDS_IN_DAY = 24 * 3600;
    uint constant SECONDS_IN_DAY_HALF = 12 * 3600;

    uint[] levelIntervals = [
        0 hours,   // level 1-13:00 ; 0d*24 + 0h
        3 hours,   // level 2-16:00 ; 0d*24 + 3h
        6 hours,   // level 3-19:00 ; 0d*24 + 6h
        24 hours,  // level 4-13:00 ; 1d*24 + 0h
        27 hours,  // level 5-16:00 ; 1d*24 + 3h
        30 hours,  // level 6-19:00 ; 1d*24 + 6h
        48 hours,  // level 7-13:00 ; 2d*24 + 0h
        54 hours,  // level 8-19:00 ; 2d*24 + 6h
        72 hours,  // level 9-13:00 ; 3d*24 + 0h
        78 hours,  // level 10-19:00 ; 3d*24 + 6h
        101 hours, // level 11-18:00 ; 4d*24 + 5h
        125 hours, // level 12-18:00 ; 5d*24 + 5h
        149 hours, // level 13-18:00 ; 6d*24 + 5h
        173 hours, // level 14-18:00 ; 7d*24 + 5h
        197 hours, // level 15-18:00 ; 8d*24 + 5h
        221 hours, // level 16-18:00 ; 9d*24 + 5h
        245 hours, // level 17-18:00 ; 10d*24 + 5h
        269 hours, // level 18-18:00 ; 11d*24 + 5h
        293 hours, // level 19-18:00 ; 12d*24 + 5h
        317 hours  // level 20-18:00 ; 13d*24 + 5h
    ];

    //----------------------------------------------------------------------------------------------------------------------
    //  Config for testing
    //----------------------------------------------------------------------------------------------------------------------
    
    uint[] levelPrices = [
        0.001 * 1e18, //  1 POOL = 0.001 ETH 
        0.002 * 1e18, //  2 POOL = 0.002 ETH 
        0.003 * 1e18, //  3 POOL = 0.003 ETH 
        0.004 * 1e18, //  4 POOL = 0.004 ETH 
        0.005 * 1e18, //  5 POOL = 0.005 ETH 
        0.006 * 1e18, //  6 POOL = 0.006 ETH 
        0.007 * 1e18, //  7 POOL = 0.007 ETH 
        0.008 * 1e18, //  8 POOL = 0.008 ETH 
        0.009 * 1e18, //  9 POOL = 0.009 ETH 
        0.010 * 1e18, // 10 POOL = 0.010 ETH 
        0.011 * 1e18, // 11 POOL = 0.011 ETH 
        0.012 * 1e18, // 12 POOL = 0.012 ETH 
        0.013 * 1e18, // 13 POOL = 0.013 ETH 
        0.014 * 1e18, // 14 POOL = 0.014 ETH 
        0.015 * 1e18, // 15 POOL = 0.015 ETH 
        0.016 * 1e18, // 16 POOL = 0.016 ETH 
        0.017 * 1e18, // 17 POOL = 0.017 ETH 
        0.018 * 1e18, // 18 POOL = 0.018 ETH 
        0.019 * 1e18, // 19 POOL = 0.019 ETH 
        0.020 * 1e18  // 20 POOL = 0.020 ETH 
    ];

    uint constant REGISTRATION_PRICE = 0.001 * 1e18; // 0.001 ETH
    uint constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    uint constant USER_REWARD_PERCENTS = 74; // 74% reward

    uint[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];
    //----------------------------------------------------------------------------------------------------------------------
    //  END OF: Config for testing
    //----------------------------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------------------------
    //  Config for production
    //----------------------------------------------------------------------------------------------------------------------

    /*uint[] levelPrices = [
        0.05 * 1e18, //  1 POOL = 0.05 BNB
        0.07 * 1e18, //  2 POOL = 0.07 BNB
        0.10 * 1e18, //  3 POOL = 0.10 BNB
        0.13 * 1e18, //  4 POOL = 0.13 BNB
        0.16 * 1e18, //  5 POOL = 0.16 BNB
        0.25 * 1e18, //  6 POOL = 0.25 BNB
        0.30 * 1e18, //  7 POOL = 0.30 BNB
        0.35 * 1e18, //  8 POOL = 0.35 BNB
        0.40 * 1e18, //  9 POOL = 0.40 BNB
        0.45 * 1e18, // 10 POOL = 0.45 BNB
        0.75 * 1e18, // 11 POOL = 0.75 BNB
        0.90 * 1e18, // 12 POOL = 0.90 BNB
        1.05 * 1e18, // 13 POOL = 1.05 BNB
        1.20 * 1e18, // 14 POOL = 1.20 BNB
        1.35 * 1e18, // 15 POOL = 1.35 BNB
        2.00 * 1e18, // 16 POOL = 2.00 BNB
        2.50 * 1e18, // 17 POOL = 2.50 BNB
        3.00 * 1e18, // 18 POOL = 3.00 BNB
        3.50 * 1e18, // 19 POOL = 3.50 BNB
        4.00 * 1e18  // 20 POOL = 4.00 BNB
    ];

    uint constant REGISTRATION_PRICE = 0.05 * 1e18; // 0.05 BNB
    uint constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    uint constant USER_REWARD_PERCENTS = 74; // 74% reward

    uint[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];*/
    //----------------------------------------------------------------------------------------------------------------------
    //  END OF: Config for production
    //----------------------------------------------------------------------------------------------------------------------

    struct User {
        uint id;
        address userAddr;
        address referrer;
        uint regDate;
        UserLevelInfo[] levels;
        uint maxLevel;
        uint debit;
        uint credit;
        uint referralReward;
        uint lastReferralReward;
        uint levelProfit;
        uint line1;
        uint line2;
        uint line3;
    }

    struct UserLevelInfo {
        uint openState; // 0 - closed, 1 - closed (opened once), 2 - opened
        uint payouts;
        uint partnerBonus;
        uint poolProfit;
        uint missedProfit;
    }

    address private adminWallet;
    address private regFeeWallet;
    address private marketingWallet;
    uint private initialDate;
    mapping (address => User) private users;
    address[] private userAddresses;
    uint private userCount;
    address private rootWallet1;
    address private rootWallet2;
    address private rootWallet3;
    address private rootWallet4;
    mapping(uint => address[]) private levelQueue;
    mapping(uint => uint) private headIndex;
    uint private marketingBalance;
    uint private transactionCounter;
    uint private turnoverAmount;
    uint private date24h1;
    uint private date24h2;
    uint32 private users24h1;
    uint32 private users24h2;
    uint32 private transactions24h1;
    uint32 private transactions24h2;
    uint private turnover24h1;
    uint private turnover24h2;
    uint private suspended;
    address private implementation;
    address private implementation2;

    struct UserExt {
        uint value1;
        uint value2;
    }

    mapping (address => UserExt) private userExts;

    constructor(bytes memory data) {
        uint level;

        // Capture the creation date and time
        initialDate = block.timestamp;

        // Defining wallets
        adminWallet = msg.sender;
        regFeeWallet = readAddress2(data, 0x15);
        marketingWallet = readAddress2(data, 0x29);
        rootWallet1 = readAddress2(data, 0x3d);
        rootWallet2 = readAddress2(data, 0x51);
        rootWallet3 = readAddress2(data, 0x65);
        rootWallet4 = readAddress2(data, 0x79);

        // Adding root users to the users table
        for (uint i = 0; i < ROOT_WALLETS_COUNT; i++) {
            address addr;
            address reff;
            if (i == 0) {
                addr = rootWallet1;
                reff = rootWallet2;
            }
            else if (i == 1) {
                addr = rootWallet2;
                reff = rootWallet3;
            }
            else if (i == 2) {
                addr = rootWallet3;
                reff = rootWallet4;
            }
            else {
                addr = rootWallet4;
                reff = rootWallet1;
            }
            
            users[addr].id = userCount;
            users[addr].userAddr = addr;
            users[addr].referrer = reff;
            users[addr].regDate = block.timestamp;
            users[addr].maxLevel = LEVELS_COUNT;
            //users[addr].debit = 0;
            //users[addr].credit = 0;
            //users[addr].referralReward = 0;
            //users[addr].lastReferralReward = 0;
            //users[addr].levelProfit = 0;
            //users[addr].line1 = 0;
            //users[addr].line2 = 0;
            //users[addr].line3 = 0;
            userAddresses.push(addr);
            userCount++;

            for (level = 0; level < LEVELS_COUNT; level++) {
                users[addr].levels.push(UserLevelInfo({
                    openState: 2, // opened
                    payouts: 0,
                    missedProfit: 0,
                    partnerBonus: 0,
                    poolProfit: 0
                }));
            }
        }

        // Filling levels queue with initial values
        for (level = 0; level < LEVELS_COUNT; level++) {
            levelQueue[level].push(rootWallet1);
            levelQueue[level].push(rootWallet2);
            levelQueue[level].push(rootWallet3);
            levelQueue[level].push(rootWallet4);
        }
    }

    receive() external payable {
        uint restOfAmount = msg.value;
        if (users[msg.sender].regDate == 0) {
            internalRegister2(rootWallet1, restOfAmount);
            restOfAmount -= REGISTRATION_PRICE;
        }
        internalBuyLevel2(users[msg.sender].maxLevel, restOfAmount);
        transactionCounter++;
    }

    fallback() external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), sload(implementation2.slot), ptr, calldatasize(), 0, 0 )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function readAddress2(bytes memory data, uint offs) pure private returns (address) {
        address addr;
        assembly {
            addr := mload(add(data, offs))
        }
        return addr;
    }

    function isContract2(address addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return (size > 0);
    }

    function stats24hNormalize2(uint half) private {
        uint date = block.timestamp / SECONDS_IN_DAY;
        if (half == 0) {
            if (date24h1 != date) {
                date24h1 = date;
                users24h1 = 0;
                transactions24h1 = 0;
                turnover24h1 = 0;
            }
        }
        else {
            if (date24h2 != date) {
                date24h2 = date;
                users24h2 = 0;
                transactions24h2 = 0;
                turnover24h2 = 0;
            }
        }
    }

    function internalRegister2(address referrer, uint investAmount) private {
        require(suspended == 0); // Check if contract is not suspended
        require(investAmount >= REGISTRATION_PRICE + levelPrices[0]); // Check if receive the right amount
        require(users[msg.sender].regDate == 0); // Check if user is already registered
        require(!isContract2(msg.sender)); // This should be user wallet, not contract or other bot

        // If referrer is not valid then set it to default
        if (users[referrer].regDate == 0)
            referrer = rootWallet1;

        // Adding user to the users table
        users[msg.sender].id = userCount;
        users[msg.sender].userAddr = msg.sender;
        users[msg.sender].referrer = referrer;
        users[msg.sender].regDate = block.timestamp;
        //users[msg.sender].maxLevel = 0;
        //users[msg.sender].debit = 0;
        //users[msg.sender].credit = 0;
        //users[msg.sender].referralReward = 0;
        //users[msg.sender].lastReferralReward = 0;
        //users[msg.sender].levelProfit = 0;
        //users[msg.sender].line1 = 0;
        //users[msg.sender].line2 = 0;
        //users[msg.sender].line3 = 0;
        userAddresses.push(msg.sender);
        userCount++;

        // Creating levels for the user
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            users[msg.sender].levels.push(UserLevelInfo({
                openState: 0, // closed
                payouts: 0,
                missedProfit: 0,
                partnerBonus: 0,
                poolProfit: 0
            }));
        }

        // Filling referrer lines
        address currRef = users[msg.sender].referrer;
        users[currRef].line1++;
        currRef = users[currRef].referrer;
        users[currRef].line2++;
        currRef = users[currRef].referrer;
        users[currRef].line3++;

        // Sending the money to the project wallet
        payable(regFeeWallet).transfer(REGISTRATION_PRICE);

        // Storing substracted amount
        users[msg.sender].credit += REGISTRATION_PRICE;
        turnoverAmount += REGISTRATION_PRICE;

        // Updating increments
        uint half = (block.timestamp / SECONDS_IN_DAY_HALF) % 2;
        stats24hNormalize2(half);
        if (half == 0) {
            users24h1++;
            turnover24h1 += REGISTRATION_PRICE;
        }
        else {
            users24h2++;
            turnover24h2 += REGISTRATION_PRICE;
        }
    }

    function internalBuyLevel2(uint level, uint investAmount) private {
        // Prepare the data
        uint levelPrice = levelPrices[level];

        //require(level >= 0 && level < LEVELS_COUNT); // Check if level number is valid
        require(suspended == 0); // Check if contract is not suspended
        require(investAmount >= levelPrice); // Check if receive the right amount
        require(users[msg.sender].regDate > 0); // Check if user is exists
        require(level <= users[msg.sender].maxLevel); // Check if level is allowed
        require(block.timestamp >= initialDate + levelIntervals[level]); // Check if level is available
        require(users[msg.sender].levels[level].openState != 2); // Check if level is not opened

        // Updating increments
        uint half = (block.timestamp / SECONDS_IN_DAY_HALF) % 2;
        stats24hNormalize2(half);
        if (half == 0) {
            transactions24h1++;
            turnover24h1 += investAmount;
        }
        else {
            transactions24h2++;
            turnover24h2 += investAmount;
        }

        // Storing substracted amount
        users[msg.sender].credit += investAmount;
        turnoverAmount += investAmount;

        // Sending fee for buying level
        uint levelFee = levelPrice * LEVEL_FEE_PERCENTS / 100;
        payable(marketingWallet).transfer(levelFee);
        marketingBalance += levelFee;
        investAmount -= levelFee;

        // Sending rewards to top referrers
        address referrer = users[msg.sender].referrer;
        for (uint i = 0; i < 3; i++) {
            // Calculating the value to invest to current referrer
            uint value = levelPrice * referrerPercents[i] / 100;

            // Skipping all the referres that does not have this level previoisly opened
            while (users[referrer].levels[level].openState == 0) {
                users[referrer].levels[level].missedProfit += value;
                referrer = users[referrer].referrer;
            }

            // If it is not root user than we sending money to it, otherwice we collecting the rest of money
            payable(referrer).transfer(value);
            users[referrer].debit += value;
            users[referrer].referralReward += value;
            users[referrer].lastReferralReward = value;
            users[referrer].levels[level].partnerBonus += value;
            investAmount -= value;

            // Switching to the next referrer (if we can)
            referrer = users[referrer].referrer;
        }

        // Sending reward to first user in the queue of this level
        address rewardAddress = levelQueue[level][headIndex[level]];
        if (rewardAddress != msg.sender) {
            uint reward = levelPrice * USER_REWARD_PERCENTS / 100;
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                investAmount -= reward;
                users[rewardAddress].debit += reward;
                users[rewardAddress].levelProfit += reward;
                users[rewardAddress].levels[level].poolProfit += reward;
                users[rewardAddress].levels[level].payouts++;
                if (users[rewardAddress].levels[level].payouts & 1 == 0 && users[rewardAddress].id >= ROOT_WALLETS_COUNT)
                    users[rewardAddress].levels[level].openState = 1; // closed (opened once)
                else
                    levelQueue[level].push(rewardAddress);
                delete levelQueue[level][headIndex[level]];
                headIndex[level]++;
            }
        }

        if (investAmount > 0) {
            payable(marketingWallet).transfer(investAmount); 
            marketingBalance += investAmount;
        }

        // Activating level
        levelQueue[level].push(msg.sender);
        users[msg.sender].levels[level].openState = 2;
        users[msg.sender].levels[level].missedProfit = 0;
        if (level >= users[msg.sender].maxLevel)
            users[msg.sender].maxLevel = level + 1;
    }

    function register2(address referrer) public payable {
        uint restOfAmount = msg.value;
        internalRegister2(referrer, restOfAmount);
        restOfAmount -= REGISTRATION_PRICE;
        internalBuyLevel2(0, restOfAmount);
        transactionCounter++;
    }

    function buyLevel2(uint level) public payable {
        internalBuyLevel2(level, msg.value);
    }

    function getSchedulel2() public view returns(uint date, uint[] memory intervals) {
        return (initialDate, levelIntervals);
    }

    function setSchedule2(uint date, uint[] memory intervals) public {
        require(msg.sender == adminWallet);
        initialDate = date;
        for (uint i = 0; i < LEVELS_COUNT; i++)
            levelIntervals[i] = intervals[i];
    }

    function getUserCount2() public view returns(uint) {
        return userCount;
    }

    function getUserAddresses2() public view returns(address[] memory) {
        return userAddresses;
    }

    function getUserAddressesFragment2(uint offset, uint count) public view returns(address[] memory) {
        address[] memory list = new address[](count);
        for (uint i = 0; i < count; i++)
            list[i] = userAddresses[offset + i];

        return list;
    }

    function getUsersFragment2(uint offset, uint count) public view returns(User[] memory) {
        User[] memory list = new User[](count);
        for (uint i = 0; i < count; i++)
            list[i] = users[userAddresses[offset + i]];

        return list;
    }

    function getUser2(address userAddr) public view returns(User memory) {
        return users[userAddr];
    }

    function getUserByID2(uint id) public view returns(User memory) {
        return getUser2(userAddresses[id]);
    }

    function hasUser2(address userAddr) public view returns(bool) {
        return users[userAddr].regDate > 0;
    }

    function getQueueSize2(uint level) public view returns (uint) {
        return levelQueue[level].length - headIndex[level];
    }

    function getQueueFragment2(uint level, uint offs, uint count) public view returns (address[] memory) {
        if (count == 0)
            count = getQueueSize2(level);

        address[] memory queue = new address[](count);
        uint index = 0;
        uint i = headIndex[level] + offs;
        uint n = i + count;
        for (; i < n; i++) {
            queue[index] = levelQueue[level][i];
            index++;
        }

        return queue;
    }

    function getQueueForLevel2(uint level) public view returns (address[] memory addresses, uint[] memory payouts) {
        uint queueSize = levelQueue[level].length - headIndex[level];
        address[] memory addressQueue = new address[](queueSize);
        uint[] memory payoutsQueue = new uint[](queueSize);

        uint index = 0;
        uint n = levelQueue[level].length;
        for (uint i = headIndex[level]; i < n; i++) {
            address addr = levelQueue[level][i];
            addressQueue[index] = addr;
            payoutsQueue[index] = users[addr].levels[level].payouts;
            index++;
        }

        return (addressQueue, payoutsQueue);
    }

    function getSlots2(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function levelIsOpened2(address userAddr, uint level) public view returns(bool) {
        return users[userAddr].levels[level].openState == 2;
    }

    function getBalances2(uint start, uint end) public view returns (uint counter, uint marketingFee, address[] memory wallets, address[] memory referrers, uint[] memory debits, uint[] memory credits) {
        if (start > end) {
            start = 0;
            end = userCount;
        }
        
        uint n = end - start;
        address[] memory referrerList = new address[](n);
        uint[] memory debitList = new uint[](n);
        uint[] memory creditList = new uint[](n);
        for (uint i = start; i < end; i++) {
            address addr = userAddresses[i];
            referrerList[i] = users[addr].referrer;
            debitList[i] = users[addr].debit;
            creditList[i] = users[addr].credit;
        }
        return (transactionCounter, marketingBalance, userAddresses, referrerList, debitList, creditList);
    }

    function withdraw2(uint amount, address payable destAddr) public {
        require(msg.sender == adminWallet);
        destAddr.transfer(amount);
    }

    function getTotalInfo2() public view returns(uint totalUsers, uint totalTransactions, uint totalTurnover, uint users24h, uint transactions24h, uint turnover24h) {
        return (
            userCount,
            transactionCounter,
            turnoverAmount,
            users24h1 + users24h2,
            transactions24h1 + transactions24h2,
            turnover24h1 + turnover24h2
        );
    }

    function getUserAddrByID2(uint id) public view returns(address) {
        return userAddresses[id];
    }

    function getUserIDByAddr2(address userAddr) public view returns(uint) {
        return users[userAddr].id;
    }

    function importCleanUsers2(uint startIndex) public {
        require(msg.sender == adminWallet);
        require(startIndex < userCount);
        uint i;

        for (i = startIndex; i < userCount; i++)
            users[userAddresses[i]].regDate = 0;
        for (i = startIndex; i < userCount; i++)
            userAddresses.pop();

        userCount = startIndex;
    }

    function importUsers2(User[] memory newUsers) public {
        require(msg.sender == adminWallet);
        for (uint i = 0; i < newUsers.length; i++) {
            User memory newUser = newUsers[i];
            address addr = newUser.userAddr; 
            User storage destUser = users[addr];

            if (destUser.regDate == 0) {
                destUser.id = userCount;
                userCount++;
                destUser.userAddr = addr;
                userAddresses.push(addr);
            }

            destUser.referrer = newUser.referrer;
            destUser.regDate = newUser.regDate;
            destUser.maxLevel = newUser.maxLevel;
            destUser.debit = newUser.debit;
            destUser.credit = newUser.credit;
            destUser.referralReward = newUser.referralReward;
            destUser.lastReferralReward = newUser.lastReferralReward;
            destUser.levelProfit = newUser.levelProfit;
            destUser.line1 = newUser.line1;
            destUser.line2 = newUser.line2;
            destUser.line3 = newUser.line3;

            while (users[addr].levels.length > 0)
                users[addr].levels.pop();
            
            for (uint level = 0; level < LEVELS_COUNT; level++) {
                UserLevelInfo memory sourceLevel = newUser.levels[level];
                users[addr].levels.push(UserLevelInfo({
                    openState: sourceLevel.openState,
                    payouts: sourceLevel.payouts,
                    partnerBonus: sourceLevel.partnerBonus,
                    poolProfit: sourceLevel.poolProfit,
                    missedProfit: sourceLevel.missedProfit
                }));
            }
        }
    }

    function importCleanQueues2(uint startLevel, uint endLevel, uint maxIterations) public {
        require(msg.sender == adminWallet);
        for (uint level = startLevel; level <= endLevel; level++) {
            while (maxIterations > 0) {
                if (levelQueue[level].length == 0) {
                    headIndex[level] = 0;
                    break;
                }

                levelQueue[level].pop();
                maxIterations--;
            }
        }
    }

    function importQueues2(address[][] memory addrs) public {
        require(msg.sender == adminWallet);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            uint n = addrs[level].length;
            for (uint i = 0; i < n; i++) {
                address addr = addrs[level][i];
                if (users[addr].regDate > 0)
                    levelQueue[level].push(addr);
            }
        }
    }

    function getSuspended2() public view returns (uint) {
        return suspended;
    }

    function setSuspended2(uint value) public {
        require(msg.sender == adminWallet);
        suspended = value;
    }

    function setParams2(uint totalTransactions, uint totalTurnover, uint marketingFee, uint32 users24h, uint32 transactions24h, uint turnover24h) public {
        require(msg.sender == adminWallet);
        transactionCounter = totalTransactions;
        turnoverAmount = totalTurnover;
        marketingBalance = marketingFee;
        users24h1 = users24h2 = (users24h >> 1);
        transactions24h1 = transactions24h2 = (transactions24h >> 1);
        turnover24h1 = turnover24h2 = (turnover24h >> 1);
    }

    function setImplementation2(address addr) public {
        require(msg.sender == adminWallet);
        implementation2 = addr;
    }

    function getImplementation2() public view returns (address) {
        return implementation2;
    }

    function setUserExt2(address addr, uint value1, uint value2) public {
        userExts[addr].value1 = value1;
        userExts[addr].value2 = value2;
    }

    function getUserExt2(address addr) public view returns (uint value1, uint value2) {
        return (
            userExts[addr].value1,
            userExts[addr].value2
        );
    }

}