/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

pragma solidity 0.7.0;

// SPDX-License-Identifier: MIT
// RAPTOR lottery
// based on solidity and proof of work systems
// basically each ticket has an hash (hash of last ticket and blockchain data such as block hash), then hash with best PoW difficulty (basically lower number) is taken as winner of round
// I know a contract could guess result and revert if result is bad, so contracts cannot play !


// ===== BEGINNING OF JOKE PART =====

// /---\
// |- -|
// | - |      I had a call with dinos and they're handling asteroid	
// \ --/ <--- PSA (Prehistoric Space Agency) says one more green candle will allow getting back in outterspace

// ===== END OF JOKE PART =====

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface feeReceiverInterface {
	function receiveFees(address token, uint256 amount) external;
}

interface MasterChefInterface {
	function enterStaking(uint256 amount) external;
	function leaveStaking(uint256 amount) external;
	function pendingCake(uint256 _pid, address _user) external view returns (uint256);
	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
}

contract Owned {
    address public owner;
    address public newOwner;
	address public donation;
	address public marketing;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor(address _donation, address _marketing) {
        owner = msg.sender;
		donation = _donation;
		marketing = _marketing;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
	
	function _chainId() internal pure returns (uint256) {
		uint256 id;
		assembly {
			id := chainid()
		}
		return id;
	}
	
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract randompow is Owned {
	using SafeMath for uint256;

	address public currentWinner;
	mapping (uint256 => bytes32) public bestdiff; // best hash found
	bytes32 lastSolution;
	bytes32 public currentChallenge;
	uint256 public ticketPrice;
	ERC20Interface public RAPTOR;
	
	struct Round {
		address winner;
		uint256 jackpot;
		uint256 tickets;
	}
	mapping (uint256 => mapping (address => uint256)) public ticketsPerDraw; // tickets owed by a given address for a given round
	
	mapping (uint256 => Round) public round;
	
	uint256 public allTimeTickets; // alltime "minted" tickets
	
	uint256 drawTimeInSeconds;
	uint256 public chainId; // current ChainID


	uint256 public totalTicketsMinted;
	uint256 public currentDraw;
	uint256 public lastDraw;

	event NewTicket(uint256 indexed round, bytes32 indexed hash, address indexed player);
	event NewRound(address indexed winner, uint256 indexed Jackpot, uint256 indexed roundNumber);
	
	function isContract(address _addr) public view returns (bool){
		uint32 size;
		assembly {
			size := extcodesize(_addr)
		}
		return (size > 0);
	}
	
	modifier onlyHuman {
		require(((msg.sender == tx.origin)||(msg.sender == address(RAPTOR))), "Beep ? No, contracts cannot play !");
		_;
	}
	
	constructor(ERC20Interface _raptor, uint256 _ticketPrice, address _donation, address _marketing) Owned(_donation, _marketing) {
		chainId = _chainId();
		currentChallenge = keccak256("Crypto mining is made out of computations... so math exercises could be money making");
		drawTimeInSeconds = 604800;
		RAPTOR = _raptor;
		currentDraw += 1;
		lastDraw = block.timestamp;
		ticketPrice = _ticketPrice;
		currentChallenge = keccak256("(RPTR > (BTC + LTC + ETH...)) returned true");
	}
	
	function changeDrawTime(uint256 dontForgetItsInSeconds) public onlyOwner {
		require(dontForgetItsInSeconds > 0, "Delay has to be positive");
		drawTimeInSeconds = dontForgetItsInSeconds;
	}
	
	function changeTicketPrice(uint256 newPrice) public onlyOwner {
		ticketPrice = newPrice;
	}

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public {
        data; // silents warning
        require(token == address(RAPTOR));
        require(tokens >= ticketPrice, "INSUFFICIENT_APPROVAL");
		require(from == tx.origin, "Beep ? No, contracts cannot play");
		deductTicketPrice(from);
		getTicketFor(from);
	}

	function deductTicketPrice(address guy) internal {
		drawPrize();
		RAPTOR.transferFrom(guy,address(this), ticketPrice);
		RAPTOR.transfer(marketing,(ticketPrice*15)/100);
		RAPTOR.transfer(address(0xdead),(ticketPrice*10)/100);
	}
	
	function getTicketFor(address guy) internal onlyHuman returns (bytes32 hash) {
		allTimeTickets += 1;
		ticketsPerDraw[currentDraw][guy] += 1;
		lastSolution = keccak256(abi.encodePacked(currentChallenge, address(this), guy, blockhash(block.number-1)));
		if ((lastSolution < bestdiff[currentDraw])||(round[currentDraw].tickets == 0)) {
			bestdiff[currentDraw] = lastSolution;
			round[currentDraw].winner = guy;
		}
		round[currentDraw].tickets += 1;
		totalTicketsMinted += 1;
		emit NewTicket(currentDraw, lastSolution, guy);
		currentChallenge = keccak256(abi.encodePacked(currentChallenge, guy, msg.sender, blockhash(block.number - 1), lastSolution, bestdiff[currentDraw], block.coinbase));
		return lastSolution;
	}
	
	
	function giveTicketTo(address guy) internal returns (bytes32 hash) {
		deductTicketPrice(msg.sender);
		return getTicketFor(guy);
	}
	
	
	function getTicket() public returns (bytes32 hash) {
		deductTicketPrice(msg.sender);
		return getTicketFor(msg.sender);
	}
	
	function getCurrentWinner() public view returns (address) {
		return round[currentDraw].winner;
	}
	
	function ticketBalanceOf(address guy) public view returns (uint256) {
		return ticketsPerDraw[currentDraw][guy];
	}
	
	function setdonation(address guy) public onlyOwner {
		donation = guy;
	}
	
	function setmarketing(address guy) public onlyOwner {
		marketing = guy;
	}
	
	function currentJackpot() public view returns (uint256) {
		return RAPTOR.balanceOf(address(this)).mul(9).div(10);
	}
	
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
	
	
	function drawPrize() public {
		if ((block.timestamp - lastDraw) >= drawTimeInSeconds) {
			uint256 _jackpot = RAPTOR.balanceOf(address(this)).mul(9).div(10);
			round[currentDraw].jackpot = _jackpot;
			RAPTOR.transfer(round[currentDraw].winner, _jackpot);
			currentChallenge = keccak256(abi.encodePacked(currentChallenge, msg.sender, msg.data, blockhash(block.number-1), block.coinbase, "RAPTOR > BTC"));
			emit NewRound(round[currentDraw].winner, _jackpot, currentDraw+1);
			currentDraw += 1;
			lastDraw = block.timestamp;
		}
	}
	
	function drawReady() public view returns (bool) {
		return ((block.timestamp - lastDraw) >= drawTimeInSeconds);
	}

	function timeRemaining() public view returns (uint256) {
		if (drawReady()) {
			return 0;
		}
		else {
			return (drawTimeInSeconds - (block.timestamp - lastDraw));
		}
	}
	
	fallback () external {
		revert();
	}
}