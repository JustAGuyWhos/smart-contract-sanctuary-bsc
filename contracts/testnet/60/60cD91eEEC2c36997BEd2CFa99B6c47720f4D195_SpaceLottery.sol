/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
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
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SpaceLottery {

    using SafeMath for uint256;
    IERC20 public token_SPO;

    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public PROJECT   = 20;
    uint256 public MIN_BUY = 3 * 1e18; /** 3 SPO **/
    uint256 public MAX_BUY = 150 * 1e18; /** 100 SPO **/

    /* lottery */
	bool public LOTTERY_ACTIVATED = true;
    uint256 public LOTTERY_START_TIME;
    uint256 public LOTTERY_PERCENT = 900;
    uint256 public LOTTERY_STEP = 3 * 60 * 60; /** every 3 hours. **/
    uint256 public LOTTERY_TICKET_PRICE = 3 * 1e18; /** 3 SPO **/
    uint256 public MAX_LOTTERY_TICKET = 50;
    uint256 public MAX_LOTTERY_PARTICIPANTS = 30;
    uint256 public lotteryRound = 0;
    uint256 public currentPot = 0;
    uint256 public participants = 0;
    uint256 public totalTickets = 0;

    /* statistics */
    uint256 public totalLotteryBonus;
    uint256 public totalEntries;

    /* addresses */
    address payable public owner;
    address payable public owner1;
    address payable public partner1;
    address payable public partner2;
    address payable public partner3;

    struct User {
        uint256 userTotalEntries;
        uint256 totalLotteryBonus;
    }

    struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    }

    LotteryHistory[] internal lotteryHistory;
    mapping(address => User) private users;
    mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/
    event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);

    constructor()
    // (address payable _owner, address payable _owner1, address payable _partner1, address payable _partner2, address payable _partner3)
    {
        owner = payable(0xC353bC8E1C4d3C6F4870D83262946E8C32e126b3);
        owner1 = payable(0x89Ecb386F841c7146dbebb8C821A5b93dC77fcFA);
        partner1 = payable(0xF1C44214b04b5C194A2791d5d0D56FA87add3C7A);
        partner2 = payable(0xAD8303D48CC4dE2887557AaF4D82fB20A5f384C8);
        partner3 = payable(0xAD8303D48CC4dE2887557AaF4D82fB20A5f384C8);
        token_SPO = IERC20(0xe49B52Ca4D1d8d6e0956086110E961B65BaA560B);
    }

    /** lottery **/
    function LOTTERY_STARTED(bool value) public {
        require(msg.sender == owner, "Admin use only.");
        LOTTERY_ACTIVATED = value;
        LOTTERY_START_TIME = block.timestamp;
    }

    /** transfer amount of SPO **/
    function gamble(uint256 amount) public payable{
        require(LOTTERY_ACTIVATED);
        require(amount >= MIN_BUY && amount <= MAX_BUY, "MIN/MAX requirement not satisfied.");
        User storage user = users[msg.sender];
        token_SPO.transferFrom(address(msg.sender), address(this), amount);
        user.userTotalEntries = user.userTotalEntries.add(amount);
        totalEntries = totalEntries.add(amount);
		_buyTickets(msg.sender, amount);
    }

    /** lottery section! **/
    function _buyTickets(address userAddress, uint256 amount) private {
        require(amount != 0, "zero purchase amount");
        uint256 userTickets = ticketOwners[lotteryRound][userAddress];
        uint256 numTickets = amount.div(LOTTERY_TICKET_PRICE); // 90% of deposit

        /** if the user has no tickets before this point, but they just purchased a ticket **/
        if(userTickets == 0) {
            participantAdresses[lotteryRound][participants] = userAddress;

            if(numTickets > 0){
              participants = participants.add(1);
            }
        }

        if (userTickets.add(numTickets) > MAX_LOTTERY_TICKET) {
            numTickets = MAX_LOTTERY_TICKET.sub(userTickets);
        }

        ticketOwners[lotteryRound][userAddress] = userTickets.add(numTickets);
        /** 90% of deposit will be put into the pot **/
        currentPot = currentPot.add(amount.mul(LOTTERY_PERCENT).div(PERCENTS_DIVIDER));
        /** 10% of deposit will be for tax **/
        uint256 _projectFee = amount.mul(PROJECT).div(PERCENTS_DIVIDER);
        token_SPO.transfer(owner, _projectFee);
        token_SPO.transfer(owner1, _projectFee);
        token_SPO.transfer(partner1, _projectFee);
        token_SPO.transfer(partner2, _projectFee);
        token_SPO.transfer(partner3, _projectFee);
        totalTickets = totalTickets.add(numTickets);

        if(block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
            chooseWinner();
        }
    }

   /** will auto execute, when condition is met. buy, hatch and sell, can be triggered manually by admin if theres no user action. **/
    function chooseWinner() public {
       require(((block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP) || participants >= MAX_LOTTERY_PARTICIPANTS),
        "Lottery must run for LOTTERY_STEP or there must be MAX_LOTTERY_PARTICIPANTS particpants");
        /** only draw winner if participant > 0. **/
        if(participants != 0){
            uint256[] memory init_range = new uint256[](participants);
            uint256[] memory end_range = new uint256[](participants);

            uint256 last_range = 0;

            for(uint256 i = 0; i < participants; i++){
                uint256 range0 = last_range.add(1);
                uint256 range1 = range0.add(ticketOwners[lotteryRound][participantAdresses[lotteryRound][i]].div(1e18));

                init_range[i] = range0;
                end_range[i] = range1;
                last_range = range1;
            }

            uint256 random = _getRandom().mod(last_range).add(1);

            for(uint256 i = 0; i < participants; i++){
                if((random >= init_range[i]) && (random <= end_range[i])){

                    /** winner found **/
                    address winnerAddress = participantAdresses[lotteryRound][i];
                    User storage user = users[winnerAddress];

                    /** winner will have the prize in their claimable rewards. **/
                    uint256 reward = currentPot.mul(LOTTERY_PERCENT).div(PERCENTS_DIVIDER);
                    token_SPO.transfer(winnerAddress, reward);

                    /** record users total lottery rewards **/
                    user.totalLotteryBonus = user.totalLotteryBonus.add(reward);
                    totalLotteryBonus = totalLotteryBonus.add(reward);

                    /** record round **/
                    lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, reward, participants, totalTickets));
                    emit LotteryWinner(winnerAddress, reward, lotteryRound);

                    /** reset lotteryRound **/
                    currentPot = 0;
                    participants = 0;
                    totalTickets = 0;
                    LOTTERY_START_TIME = block.timestamp;
                    lotteryRound = lotteryRound.add(1);
                    break;
                }
            }
        }else{
            /** if lottery step is done but no participant, reset lottery start time. **/
            LOTTERY_START_TIME = block.timestamp;
        }
       
    }

    /**  select lottery winner **/
    function _getRandom() private view returns(uint256){
        bytes32 _blockhash = blockhash(block.number-1);
        return uint256(keccak256(abi.encode(_blockhash,block.timestamp,currentPot, block.difficulty, getBalance())));
    }

    function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot,
	  uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
		round = lotteryHistory[index].round;
		winnerAddress = lotteryHistory[index].winnerAddress;
		pot = lotteryHistory[index].pot;
		totalLotteryParticipants = lotteryHistory[index].totalLotteryParticipants;
		totalLotteryTickets = lotteryHistory[index].totalLotteryTickets;
	}

    function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
	  uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
      uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round){
		lotteryStartTime = LOTTERY_START_TIME;
		lotteryStep = LOTTERY_STEP;
		lotteryTicketPrice = LOTTERY_TICKET_PRICE;
		maxLotteryParticipants = MAX_LOTTERY_PARTICIPANTS;
		round = lotteryRound;
		lotteryCurrentPot = currentPot;
		lotteryParticipants = participants;
	    totalLotteryTickets = totalTickets;
        maxLotteryTicket = MAX_LOTTERY_TICKET;
        lotteryPercent = LOTTERY_PERCENT;
	}

    function getUserInfo(address _adr) public view returns(User memory) {
        return users[_adr];
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getUserTickets(address _userAddress) public view returns(uint256) {
         return ticketOwners[lotteryRound][_userAddress];
    }

    function getLotteryTimer() public view returns(uint256) {
        return LOTTERY_START_TIME.add(LOTTERY_STEP);
    }

    function getBalance() public view returns(uint256){
        return token_SPO.balanceOf(address(this));
    }

    function getSiteInfo() public view returns (uint256 _totalEntries, uint256 _totalLotteryBonus) {
        return (totalEntries, totalLotteryBonus);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /** wallet addresses **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = payable(value);
    }

    function PRC_PROJECT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        PROJECT = value;
    }

    /* lottery setters */
    function SET_LOTTERY_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
         /** hour conversion **/
        LOTTERY_STEP = value * 60 * 60;
    }

    function SET_LOTTERY_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10 && value <= 50); /** 5% max **/
        LOTTERY_PERCENT = value;
    }

    function SET_LOTTERY_TICKET_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        LOTTERY_TICKET_PRICE = value * 1e18;
    }

    function SET_MAX_LOTTERY_TICKET(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 1 && value <= 100);
        MAX_LOTTERY_TICKET = value;
    }

    function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 2 && value <= 200); /** min 10, max 200 **/
        MAX_LOTTERY_PARTICIPANTS = value;
    }

    function SET_MIN_BUY(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_BUY = value * 1e18;
    }

    function SET_MAX_BUY(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MAX_BUY = value * 1e18;
    }  
}