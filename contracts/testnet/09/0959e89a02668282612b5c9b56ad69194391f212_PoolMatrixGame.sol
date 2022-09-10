/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

contract PoolMatrixGame {

    uint8 constant levelsCount = 20;

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

    //======================================================================================================================
    //  Config for testing
    //======================================================================================================================
    
    uint256[] levelPrices = [
        0.001 * 1e18, //  1 POOL = 0.001 ETH 
        0.001 * 1e18, //  2 POOL = 0.001 ETH 
        0.001 * 1e18, //  3 POOL = 0.001 ETH 
        0.001 * 1e18, //  4 POOL = 0.001 ETH 
        0.001 * 1e18, //  5 POOL = 0.001 ETH 
        0.001 * 1e18, //  6 POOL = 0.001 ETH 
        0.001 * 1e18, //  7 POOL = 0.001 ETH 
        0.001 * 1e18, //  8 POOL = 0.001 ETH 
        0.001 * 1e18, //  9 POOL = 0.001 ETH 
        0.001 * 1e18, // 10 POOL = 0.001 ETH 
        0.001 * 1e18, // 11 POOL = 0.001 ETH 
        0.001 * 1e18, // 12 POOL = 0.001 ETH 
        0.001 * 1e18, // 13 POOL = 0.001 ETH 
        0.001 * 1e18, // 14 POOL = 0.001 ETH 
        0.001 * 1e18, // 15 POOL = 0.001 ETH 
        0.001 * 1e18, // 16 POOL = 0.001 ETH 
        0.001 * 1e18, // 17 POOL = 0.001 ETH 
        0.001 * 1e18, // 18 POOL = 0.001 ETH 
        0.001 * 1e18, // 19 POOL = 0.001 ETH 
        0.001 * 1e18  // 20 POOL = 0.001 ETH 
    ];

    uint256[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];

    uint256 constant REGISTRATION_PRICE = 0.001 * 1e18; // 0.001 eth
    uint256 constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    uint256 constant PRIORITY_DELAY = 3 minutes;
    //======================================================================================================================
    //  END OF: Config for testing
    //======================================================================================================================

    //======================================================================================================================
    //  Config for production
    //======================================================================================================================
    /*
    uint8 constant levelsCount = 20;

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

    uint256[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];

    uint256 constant REGISTRATION_PRICE = 0.05 * 1e18; // 0.05 bnb
    uint256 constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    */
    //======================================================================================================================
    //  END OF: Config for production
    //======================================================================================================================

    struct User {
        bool registered;
        uint registrationTimestamp;
        address userAddr;
        bool isRootUser;
        address referrer;
        uint256 initialBalance;
        uint256 debit;
        uint256 credit;
        UserLevelInfo[] levels;
        uint8 maxLevel;
        bool isPredefined;
    }

    struct UserLevelInfo {
        bool opened;
        bool openedOnce;
        uint8 payouts;
        uint missedProfit;
    }

    address public adminWallet; // The wallet from which contract has been created
    address public regFeeWallet; // For registration rewards
    address public marketingWallet; // For fees for buying levels
    
    uint initialTimestamp;
    mapping (address => bool) internal admins;
    mapping (address => User) internal users;
    address[] internal userAddresses;
    mapping(uint8 => address[]) internal levelQueue;
    mapping(uint8 => uint) internal headIndex;
    address[] internal rootWallets;
    mapping (address => bool) predefinedWallets;
    uint predefinedWalletsCount;
    uint256 regFeeBalance;
    uint256 marketingBalance;
    uint256 transactionCounter;

    event ContractCreated(address regFee, address marketing, address[] owners, address[] roots, address[] predefines);
    event UserRegistered(address indexed userAddr);
    event LevelActivated(address indexed userAddr, uint8 level);
    event LevelDeactivated(address indexed userAddr, uint8 level);

    constructor(address regFee, address marketing, address[] memory owners, address[] memory roots, address[] memory predefines) {
        uint i;
        uint8 level;

        // Defining wallets
        adminWallet = msg.sender;
        regFeeWallet = regFee;
        marketingWallet = marketing;

        // Capture the creation date and time
        initialTimestamp = block.timestamp; // 1662814800 = GMT: Saturday, 10 September 2022, 13:00:00

        // Define admins
        admins[msg.sender] = true;
        for (i = 0; i < owners.length; i++)
            admins[owners[i]] = true;

        // Define root users
        for (i = 0; i < roots.length; i++) 
            rootWallets.push(roots[i]);

        // Define initial wallets
        predefinedWalletsCount = predefines.length;
        for (i = 0; i < predefinedWalletsCount; i++)
            predefinedWallets[predefines[i]] = true;

        // Adding root users to the users table
        for (i = 0; i < rootWallets.length; i++) {
            address addr = rootWallets[i];
            
            users[addr].registered = true;
            users[addr].registrationTimestamp = block.timestamp;
            users[addr].userAddr = addr;
            users[addr].isRootUser = true;
            users[addr].referrer = rootWallets[(i + 1) % 4];
            users[addr].initialBalance = 0;
            users[addr].debit = 0;
            users[addr].credit = 0;
            users[addr].maxLevel = levelsCount;
            users[addr].isPredefined = false;
            userAddresses.push(addr);

            for (level = 0; level < levelsCount; level++) {
                users[addr].levels.push(UserLevelInfo({
                    opened: true,
                    openedOnce: true,
                    payouts: 0,
                    missedProfit: 0
                }));
            }
        }

        // Filling levels queue with initial values
        for (level = 0; level < levelsCount; level++) {
            for (i = 0; i < predefinedWalletsCount; i++)
                levelQueue[level].push(address(0));

            headIndex[level] = predefinedWalletsCount;

            for (i = 0; i < rootWallets.length; i++)
                levelQueue[level].push(rootWallets[i]);
        }
       
        emit ContractCreated(regFee, marketing, owners, roots, predefines);
    }

    receive() external payable {
        // Register and buy level
        uint256 restOfAmount = msg.value;
        register(rootWallets[0], restOfAmount, 0);
        restOfAmount -= REGISTRATION_PRICE;
        buyLevel(1, restOfAmount);
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
        // Check if receive the right amount
        require(investAmount >= REGISTRATION_PRICE);

        // Check if user is already registered
        require(users[msg.sender].registered == false);

        // If referrer is not valid then set it to default
        if (referrer == msg.sender && referrer == address(0) && !users[referrer].registered)
            referrer = rootWallets[0];

        // Adding user to the users table
        users[msg.sender].registered = true;
        users[msg.sender].registrationTimestamp = block.timestamp;
        users[msg.sender].userAddr = msg.sender;
        users[msg.sender].isRootUser = false;
        users[msg.sender].referrer = referrer;
        users[msg.sender].initialBalance = initialBalance;
        users[msg.sender].debit = 0;
        users[msg.sender].credit = 0;
        users[msg.sender].maxLevel = 1;
        users[msg.sender].isPredefined = predefinedWallets[msg.sender];
        userAddresses.push(msg.sender);

        // Creating levels for the user
        for (uint level = 0; level < levelsCount; level++) {
            users[msg.sender].levels.push(UserLevelInfo({
                opened: false,
                openedOnce: false,
                payouts: 0,
                missedProfit: 0
            }));
        }

        // Sending the money to the project wallet
        payable(regFeeWallet).transfer(REGISTRATION_PRICE);
        regFeeBalance += REGISTRATION_PRICE;

        // Storing substracted amount
        users[msg.sender].credit += REGISTRATION_PRICE;

        // Tell that registration was sucessfully completed
        emit UserRegistered(msg.sender);
    }

    function buyLevel(uint8 level, uint256 investAmount) public payable {
        level--;

        // Check if level number is valid
        require(level >= 0 && level < levelsCount);

        // Check if receive the right amount
        require(investAmount >= levelPrices[level]);

        // Check if user is exists and it has a referrer
        require(users[msg.sender].referrer != address(0));

        // Check if level is allowed
        require(level <= users[msg.sender].maxLevel);

        // Check if level is avalilable
        require(block.timestamp >= initialTimestamp + levelIntervals[level]);

        // Prepare the data
        uint256 restOfAmount = investAmount;

        // Sending fee for buying level
        uint256 levelFee = investAmount * LEVEL_FEE_PERCENTS / 100;
        payable(marketingWallet).transfer(levelFee);

        marketingBalance += levelFee;
        restOfAmount -= levelFee;

        // Sending rewards to top referrers
        address referrer = users[msg.sender].referrer;
        for (uint i = 0; i < 3; i++) {
            // Calculating the value to invest to current referrer
            uint256 value = investAmount * referrerPercents[i] / 100;

            // Skipping all the referres that does not have this level opened
            while (!users[referrer].levels[level].openedOnce) {
                users[referrer].levels[level].missedProfit += value;
                referrer = users[referrer].referrer;
            }

            // If it is not root user than we sending money to it, otherwice we collecting the rest of money
            payable(referrer).transfer(value);
            users[referrer].debit += value;
            restOfAmount -= value;

            // Switching to the next referrer (if we can)
            referrer = users[referrer].referrer;
        }

        // Sending reward to first user in the queue of this level
        address rewardAddress = levelQueue[level][headIndex[level]];
        if (rewardAddress != msg.sender) {
            bool sent = payable(rewardAddress).send(restOfAmount);
            if (sent) {
                users[rewardAddress].debit += restOfAmount;
                users[rewardAddress].levels[level].payouts++;
                if (users[rewardAddress].levels[level].payouts >= 2 && !users[rewardAddress].isRootUser) {
                    users[rewardAddress].levels[level].opened = false;
                    users[rewardAddress].levels[level].payouts = 0;
                    emit LevelDeactivated(msg.sender, level);
                }
                else {
                    levelQueue[level].push(rewardAddress);
                }
                delete levelQueue[level][headIndex[level]];
                headIndex[level]++;
            }
            else {
                payable(marketingWallet).transfer(restOfAmount);
                marketingBalance += restOfAmount;
            }
        }
        else {
            payable(marketingWallet).transfer(restOfAmount);
            marketingBalance += restOfAmount;
        }

        // Activating level
        if (!users[msg.sender].levels[level].opened) {
            users[msg.sender].levels[level].opened = true;
            users[msg.sender].levels[level].openedOnce = true;
            users[msg.sender].levels[level].missedProfit = 0;
            if (level >= users[msg.sender].maxLevel)
                users[msg.sender].maxLevel = level + 1;
            
            uint256 openTime = initialTimestamp + levelIntervals[level];
            if (users[msg.sender].isPredefined && block.timestamp >= openTime && block.timestamp <= openTime + PRIORITY_DELAY) {
                headIndex[level]--;
                uint index = headIndex[level];
                uint maxLen = levelQueue[level].length - 1;
                while (index < maxLen) {
                    address addr = levelQueue[level][index + 1];
                    if (users[addr].isRootUser || users[addr].isPredefined) {
                        levelQueue[level][index] = levelQueue[level][index + 1];
                        index++;
                    }
                    else                      
                        break;
                }
                levelQueue[level][index] = msg.sender;
            }
            else {
                levelQueue[level].push(msg.sender);
            }

            emit LevelActivated(msg.sender, level + 1);
        }

        // Storing substracted amount
        users[msg.sender].credit += investAmount;
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

    function getUser(address userAddr) public view returns(bool registered, uint registrationTimestamp, address userAddress, address referrer, uint256 debit, uint256 credit, UserLevelInfo[] memory levels, bool predefined) {
        require (users[userAddr].registered, "Invalid user");
        User memory user = users[userAddr];
        return (
            user.registered,
            user.registrationTimestamp,
            user.userAddr,
            user.referrer,
            user.debit,
            user.credit,
            user.levels,
            user.isPredefined
        );
    }

    function hasUser(address userAddr) public view returns(bool) {
        return users[userAddr].registered;
    }

    function getQueueForLevel(uint8 level) public view returns (address[] memory addresses, uint8[] memory payouts) {
        require (level >= 1 && level <= levelsCount);
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

    function getPlaceInQueue(address userAddr, uint8 level) public view returns(uint, uint) {
        require (users[userAddr].registered, "Invalid user");
        require (level >= 1 && level <= levelsCount, "Invalid level");
        level--;

        if (!users[userAddr].levels[level].opened)
            return (0, 0);

        uint place = 0;
        for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
            place++;
            if (levelQueue[level][i] == userAddr)
                return (place, levelQueue[level].length - headIndex[level]);
        }

        revert();
    }

    function getSlots(address userAddr) public view returns(int16[] memory slots, uint256[] memory missedProfits) {
        require (users[userAddr].registered, "Invalid user");

        // Collecting slots
        int16[] memory slotList = new int16[](levelsCount);
        uint missedProfitCount = 0;
        for (uint8 level = 0; level < levelsCount; level++) {
            if (block.timestamp < initialTimestamp + levelIntervals[level]) {
                slotList[level] = 10; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

            int8 missedProfitFlag = int8((users[userAddr].levels[level].missedProfit > 0) ? 1 : 0);

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 20 + missedProfitFlag; // Not allowed yet (previous level is not opened)
                missedProfitCount++;
                continue;
            }

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
            for (uint8 level = 0; level < levelsCount; level++) {
                if (users[userAddr].levels[level].missedProfit > 0) {
                    missedProfitList[index] = users[userAddr].levels[level].missedProfit;
                    index++;
                }
            }
        }

        return (slotList, missedProfitList);
    }

    function levelIsOpened(address userAddr, uint8 level) public view returns(bool) {
        require (users[userAddr].registered, "Invalid user");
        require (level >= 1 && level <= levelsCount, "Invalid level");
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
        require(admins[msg.sender], "Only admin can withdraw");
        destAddr.transfer(amount);
    }

}