/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract PoolMatrixGame {

    uint8 constant LEVELS_COUNT = 20;
    uint constant ROOT_WALLETS_COUNT = 4;
    uint32 constant SECONDS_IN_DAY = 24 * 3600;
    uint32 constant SECONDS_IN_DAY_QUARTER = 6 * 3600;

    uint256[] levelIntervals = [
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
	
    uint256[] levelPrices = [
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

    uint256 constant REGISTRATION_PRICE = 0.05 * 1e18; // 0.05 BNB
    uint256 constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    uint256 constant USER_REWARD_PERCENTS = 74; // 74% reward

    uint256[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];

    struct User {
        uint registrationTimestamp;
        uint32 id;
        address userAddr;
        address referrer;
        uint256 initialBalance;
        uint256 debit;
        uint256 credit;
        UserLevelInfo[] levels;
        uint8 maxLevel;
        uint256[] userCountInLine;
        uint256 referralReward;
        uint256 lastReferralReward;
        uint256 levelProfit;
    }

    struct UserLevelInfo {
        bool opened;
        bool openedOnce;
        uint8 payouts;
        uint missedProfit;
        uint256 partnerBonus;
        uint256 poolProfit;
    }

    struct Stats24h {
        uint32 date;
        uint32 totalUsers;
        uint32 totalTransactions;
        uint256 totalTurnover;
    }

    address public adminWallet; // The wallet from which contract has been created
    address public regFeeWallet; // For registration rewards
    address public marketingWallet; // For fees for buying levels
    
    uint256 initialTimestamp;
    mapping (address => bool) internal admins;
    mapping (address => User) internal users;
    mapping (uint => address) internal userAddrByID;
    address[] internal userAddresses;
    uint32 userCount;
    mapping(uint8 => address[]) internal levelQueue;
    mapping(uint8 => uint) internal headIndex;
    address[] internal rootWallets;
    uint256 regFeeBalance;
    uint256 marketingBalance;
    uint256 transactionCounter;
    uint256 turnoverAmount;
    Stats24h[] stats24h;

    constructor(address regFee, address marketing, address[] memory owners, address[] memory roots) {
        uint i;
        uint8 level;

        // Defining wallets
        adminWallet = msg.sender;
        regFeeWallet = regFee;
        marketingWallet = marketing;

        // Capture the creation date and time
        initialTimestamp = 1662973200;//block.timestamp;

        // Define admins
        admins[msg.sender] = true;
        for (i = 0; i < owners.length; i++)
            admins[owners[i]] = true;

        // Define root users
        for (i = 0; i < roots.length; i++) 
            rootWallets.push(roots[i]);

        // Adding root users to the users table
        for (i = 0; i < ROOT_WALLETS_COUNT; i++) {
            address addr = rootWallets[i];
            
            userCount++;
            users[addr].registrationTimestamp = block.timestamp;
            users[addr].id = userCount;
            users[addr].userAddr = addr;
            users[addr].referrer = rootWallets[(i + 1) % 4];
            users[addr].initialBalance = 0;
            users[addr].debit = 0;
            users[addr].credit = 0;
            users[addr].maxLevel = LEVELS_COUNT;
            users[addr].userCountInLine = new uint256[](3);
            users[addr].referralReward = 0;
            users[addr].lastReferralReward = 0;
            users[addr].levelProfit = 0;
            userAddrByID[userCount] = addr;
            userAddresses.push(addr);

            for (level = 0; level < LEVELS_COUNT; level++) {
                users[addr].levels.push(UserLevelInfo({
                    opened: true,
                    openedOnce: true,
                    payouts: 0,
                    missedProfit: 0,
                    partnerBonus: 0,
                    poolProfit: 0
                }));
            }
        }

        // Filling levels queue with initial values
        for (level = 0; level < LEVELS_COUNT; level++) {
            for (i = 0; i < rootWallets.length; i++)
                levelQueue[level].push(rootWallets[i]);
        }

        // Allocating arrays for global increments
        for (i = 0; i < 4; i++) {
            stats24h.push(Stats24h({
                date: uint32(block.timestamp / SECONDS_IN_DAY),
                totalUsers: 0,
                totalTransactions: 0,
                totalTurnover: 0
            }));
        }
    }

    receive() external payable {
        uint256 restOfAmount = msg.value;
        if (users[msg.sender].id == 0) {
            register(rootWallets[0], restOfAmount, 0);
            restOfAmount -= REGISTRATION_PRICE;
        }
        buyLevel(users[msg.sender].maxLevel + 1, restOfAmount);
        transactionCounter++;
    }

    fallback() external payable {
        bytes memory data = msg.data;
        uint8 action;
        address referrer;
        uint8 levelNumber;
        uint256 initialBalance;
       
        // Reading action
        assembly {
            action := mload(add(data, 1))
        }

        // Executing the action
        uint256 restOfAmount = msg.value;
        if (action == 1) { // Register and buy level
            if (msg.data.length >= 53) {
                assembly {
                    referrer := mload(add(data, 21))
                    initialBalance := mload(add(data, 53))
                }
            }
            else {
                assembly {
                    referrer := mload(add(data, 21))
                    initialBalance := 0
                }
            }
            register(referrer, restOfAmount, initialBalance);
            restOfAmount -= REGISTRATION_PRICE;
            buyLevel(1, restOfAmount);
            transactionCounter++;
        }
        else if (action == 2) { // Buy the level
            assembly {
                levelNumber := mload(add(data, 2))
            }
            buyLevel(levelNumber, restOfAmount);
            transactionCounter++;
        }
    }

    function isContract(address addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return (size > 0);
    }

    function getInitialTimestamp() public view returns(uint) {
        return initialTimestamp;
    }

    function getSchedule() public view returns(uint initialDate, uint[] memory intervals) {
        return (initialTimestamp, levelIntervals);
    }

    function setInitialTimestamp(uint timestamp) public payable returns(bool) {
        if (!admins[msg.sender])
            return false;

        initialTimestamp = timestamp;
        return true;
    }

    function register(address referrer, uint256 investAmount, uint256 initialBalance) public payable {
        require(investAmount >= REGISTRATION_PRICE); // Check if receive the right amount
        require(users[msg.sender].id == 0); // Check if user is already registered
        require(!isContract(msg.sender)); // This should be user wallet, not contract or other bot

        // If referrer is not valid then set it to default
        if (referrer == msg.sender && referrer == address(0) && users[referrer].id == 0)
            referrer = rootWallets[0];

        // Adding user to the users table
        userCount++;
        users[msg.sender].registrationTimestamp = block.timestamp;
        users[msg.sender].id = userCount;
        users[msg.sender].userAddr = msg.sender;
        users[msg.sender].referrer = referrer;
        users[msg.sender].initialBalance = initialBalance;
        users[msg.sender].debit = 0;
        users[msg.sender].credit = 0;
        users[msg.sender].maxLevel = 0;
        users[msg.sender].userCountInLine = new uint256[](3);
        users[msg.sender].referralReward = 0;
        users[msg.sender].lastReferralReward = 0;
        users[msg.sender].levelProfit = 0;
        userAddrByID[userCount] = msg.sender;
        userAddresses.push(msg.sender);

        // Creating levels for the user
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            users[msg.sender].levels.push(UserLevelInfo({
                opened: false,
                openedOnce: false,
                payouts: 0,
                missedProfit: 0,
                partnerBonus: 0,
                poolProfit: 0
            }));
        }

        // Sending the money to the project wallet
        payable(regFeeWallet).transfer(REGISTRATION_PRICE);
        regFeeBalance += REGISTRATION_PRICE;

        // Storing substracted amount
        users[msg.sender].credit += REGISTRATION_PRICE;
        turnoverAmount += REGISTRATION_PRICE;

        // Updating increments
        uint32 quarter = uint32((block.timestamp / SECONDS_IN_DAY_QUARTER) % 4);
        stats24hNormalize(quarter);
        stats24h[quarter].totalUsers++;
        stats24h[quarter].totalTurnover += REGISTRATION_PRICE;
    }

    function buyLevel(uint8 level, uint256 investAmount) public payable {
        // Prepare the data
        level--;
        uint256 levelPrice = levelPrices[level];

        require(level >= 0 && level < LEVELS_COUNT); // Check if level number is valid
        require(investAmount >= levelPrice); // Check if receive the right amount
        require(users[msg.sender].referrer != address(0)); // Check if user is exists and it has a referrer
        require(level <= users[msg.sender].maxLevel); // Check if level is allowed
        require(block.timestamp >= initialTimestamp + levelIntervals[level]); // Check if level is avalilable

        // Storing substracted amount
        users[msg.sender].credit += investAmount;
        turnoverAmount += investAmount;

        // Sending fee for buying level
        uint256 levelFee = levelPrice * LEVEL_FEE_PERCENTS / 100;
        payable(marketingWallet).transfer(levelFee);
        marketingBalance += levelFee;
        investAmount -= levelFee;

        // Sending rewards to top referrers
        address referrer = users[msg.sender].referrer;
        for (uint i = 0; i < 3; i++) {
            // Calculating the value to invest to current referrer
            uint256 value = levelPrice * referrerPercents[i] / 100;

            // Skipping all the referres that does not have this level opened
            while (!users[referrer].levels[level].openedOnce) {
                users[referrer].levels[level].missedProfit += value;
                referrer = users[referrer].referrer;
            }

            // If it is not root user than we sending money to it, otherwice we collecting the rest of money
            payable(referrer).transfer(value);
            users[referrer].debit += value;
            users[referrer].referralReward += value;
            users[referrer].lastReferralReward = value;
            users[referrer].userCountInLine[i]++;
            users[referrer].levels[level].partnerBonus += value;
            investAmount -= value;

            // Switching to the next referrer (if we can)
            referrer = users[referrer].referrer;
        }

        // Sending reward to first user in the queue of this level
        address rewardAddress = levelQueue[level][headIndex[level]];
        if (rewardAddress != msg.sender) {
            uint256 reward = levelPrice * USER_REWARD_PERCENTS / 100;
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                investAmount -= reward;
                users[rewardAddress].debit += reward;
                users[rewardAddress].levelProfit += reward;
                users[rewardAddress].levels[level].poolProfit += reward;
                users[rewardAddress].levels[level].payouts++;
                if (users[rewardAddress].levels[level].payouts >= 2 && users[rewardAddress].id >= ROOT_WALLETS_COUNT) {
                    users[rewardAddress].levels[level].opened = false;
                    users[rewardAddress].levels[level].payouts = 0;
                }
                else {
                    levelQueue[level].push(rewardAddress);
                }
                delete levelQueue[level][headIndex[level]];
                headIndex[level]++;
            }
        }

        if (investAmount > 0) {
            payable(marketingWallet).transfer(investAmount); 
            marketingBalance += investAmount;
        }

        // Activating level
        if (!users[msg.sender].levels[level].opened) {
            if (!users[msg.sender].levels[level].openedOnce) {
                levelQueue[level].push(msg.sender);
            }
            else {
                levelQueue[level].push(address(0));
                uint len = levelQueue[level].length;
                uint pos = headIndex[level] + block.timestamp % (len - headIndex[level]);
                for (uint i = len - 2; i >= pos; i--)
                    levelQueue[level][i + 1] = levelQueue[level][i];
                levelQueue[level][pos] = msg.sender;
            }

            users[msg.sender].levels[level].opened = true;
            users[msg.sender].levels[level].openedOnce = true;
            users[msg.sender].levels[level].missedProfit = 0;
            if (level >= users[msg.sender].maxLevel)
                users[msg.sender].maxLevel = level + 1;
        }

        // Updating increments
        uint32 quarter = uint32((block.timestamp / SECONDS_IN_DAY_QUARTER) % 4);
        stats24hNormalize(quarter);
        stats24h[quarter].totalTransactions++;
        stats24h[quarter].totalTurnover += investAmount;
    }

    function stats24hNormalize(uint32 quarter) private {
        uint32 date = uint32(block.timestamp / SECONDS_IN_DAY);
        if (stats24h[quarter].date != date) {
            stats24h[quarter].date = date;
            stats24h[quarter].totalUsers = 0;
            stats24h[quarter].totalTransactions = 0;
            stats24h[quarter].totalTurnover = 0;
        }
    }

    function getUserAddresses() public view returns(address[] memory) {
        return userAddresses;
    }

    function getUsers() public view returns(User[] memory) {
        User[] memory list = new User[](userAddresses.length);

        for (uint i = 0; i < userAddresses.length; i++)
            list[i] = users[userAddresses[i]];

        return list;
    }

    function getUser(address userAddr) public view returns(User memory) {
        return users[userAddr];
    }

    function hasUser(address userAddr) public view returns(bool) {
        return users[userAddr].id > 0;
    }

    function getQueueForLevel(uint8 level) public view returns (address[] memory addresses, uint8[] memory payouts) {
        require (level >= 1 && level <= LEVELS_COUNT); // Invalid level
        level--;
        
        uint queueSize = levelQueue[level].length - headIndex[level];
        address[] memory addressQueue = new address[](queueSize);
        uint8[] memory payoutsQueue = new uint8[](queueSize);

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

    function getSlots(address userAddr) public view returns(int16[] memory slots, uint256[] memory missedProfits, uint256[] memory partnerBonuses, uint256[] memory poolProfits) {
        require (users[userAddr].id > 0); // Invalid user

        // Collecting slots
        int16[] memory slotList = new int16[](LEVELS_COUNT);
        uint256[] memory partnerBonusList = new uint256[](LEVELS_COUNT);
        uint256[] memory poolProfitList = new uint256[](LEVELS_COUNT);
        uint missedProfitCount = 0;
        for (uint8 level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialTimestamp + levelIntervals[level]) {
                slotList[level] = 10; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

            int8 missedProfitFlag = int8((users[userAddr].levels[level].missedProfit > 0) ? 1 : 0);
			if (missedProfitFlag > 0)
				missedProfitCount++;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 20 + missedProfitFlag; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (!users[userAddr].levels[level].opened) {
                if (!users[userAddr].levels[level].openedOnce)
                    slotList[level] = 30 + missedProfitFlag; // Available for opening
                else
                    slotList[level] = 40 + missedProfitFlag; // Available for reopening

                continue;
            }

            int place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    int n = int(levelQueue[level].length - headIndex[level]);
                    slotList[level] = -int16((n - place + 1) * 1000 / n); // Slot is opened
                    break;
                }
            }
        }

        // Collecting missing profits
        uint256[] memory missedProfitList = new uint256[](missedProfitCount);
        if (missedProfitCount > 0) {
            uint8 index = 0;
            for (uint8 level = 0; level < LEVELS_COUNT; level++) {
                if (users[userAddr].levels[level].missedProfit > 0) {
                    missedProfitList[index] = users[userAddr].levels[level].missedProfit;
                    index++;
                }
            }
        }

        return (slotList, missedProfitList, partnerBonusList, poolProfitList);
    }

    function levelIsOpened(address userAddr, uint8 level) public view returns(bool) {
        //require (users[userAddr].id > 0); // Invalid user
        //require (level >= 1 && level <= LEVELS_COUNT); // Invalid level
        return users[userAddr].levels[level - 1].opened;
    }

    function getTransactionCounter() public view returns(uint) {
        return transactionCounter;
    }

    function getBalances() public view returns (uint256 counter, uint256 regFee, uint256 marketingFee, address[] memory wallets, address[] memory referrers, uint256[] memory initials, uint256[] memory debits, uint256[] memory credits) {
        uint n = userAddresses.length;
        address[] memory referrerList = new address[](n);
        uint256[] memory initialBalances = new uint256[](n);
        uint256[] memory debitList = new uint256[](n);
        uint256[] memory creditList = new uint256[](n);
        for (uint i = 0; i < n; i++) {
            address addr = userAddresses[i];
            referrerList[i] = users[addr].referrer;
            initialBalances[i] = users[addr].initialBalance;
            debitList[i] = users[addr].debit;
            creditList[i] = users[addr].credit;
        }
        return (transactionCounter, regFeeBalance, marketingBalance, userAddresses, referrerList, initialBalances, debitList, creditList);
    }

    function withdraw(uint amount, address payable destAddr) public {
        require(admins[msg.sender]); // Only admin can withdraw
        destAddr.transfer(amount);
    }

    function getTotalInfo() public view returns(uint256 totalUsers, uint256 totalTransactions, uint256 totalTurnover, uint32 totalUsersIncrement, uint32 totalTransactionsIncrement, uint256 totalTurnoverIncrement) {
        uint32 usersIncrement = stats24h[0].totalUsers + stats24h[1].totalUsers + stats24h[2].totalUsers + stats24h[3].totalUsers;
        uint32 transactionsIncrement = stats24h[0].totalTransactions + stats24h[1].totalTransactions + stats24h[2].totalTransactions + stats24h[3].totalTransactions;
        uint256 turnoverIncrement = stats24h[0].totalTurnover + stats24h[1].totalTurnover + stats24h[2].totalTurnover + stats24h[3].totalTurnover;
        return (userCount, transactionCounter, turnoverAmount, usersIncrement, transactionsIncrement, turnoverIncrement);
    }

    function getUserAddrByID(uint id) public view returns(address) {
        return userAddrByID[id];
    }

    function getUserIDByAddr(address userAddr) public view returns(uint) {
        return users[userAddr].id;
    }

}