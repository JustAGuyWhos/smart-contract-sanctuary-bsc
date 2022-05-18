/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint _totalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract protected {

    mapping (address => bool) is_auth;

    function authorized(address addy) public view returns(bool) {
        return is_auth[addy];
    }

    function set_authorized(address addy, bool booly) public onlyAuth {
        is_auth[addy] = booly;
    }

    modifier onlyAuth() {
        require( is_auth[msg.sender] || msg.sender==owner, "not owner");
        _;
    }

    address owner;
    modifier onlyOwner() {
        require(msg.sender==owner, "not owner");
        _;
    }

    bool locked;
    modifier safe() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }

    
    uint cooldown = 5 seconds;

    mapping(address => uint) cooldown_block;
    mapping(address => bool) cooldown_free;

    modifier cooled() {
        if(!cooldown_free[msg.sender]) { 
            require(cooldown_block[msg.sender] < block.timestamp);
            _;
            cooldown_block[msg.sender] = block.timestamp + cooldown;
        }
    }

    receive() external payable {}
    fallback() external payable {}
}

contract DiceGame is protected {
    // using SafeMath for uint;

    event placed_bet(address actor, address token, uint value, uint option, uint timestamp, uint id, uint selectedNumber);
    event won_bet(uint id, uint timestamp, uint jackpot, address actor);
    event won_bet_unpaid(uint id, uint timestamp, address actor, string message);
    event lost_bet(uint id, uint lost, uint timestamp, address actor);

    struct bets {
        address actor;
        bool active;
        bool win;
        uint timestamp;
        uint value;
        uint option;
        address token;
        uint status;
        uint selectedNumber;
    }

    struct PoolBets {
        uint id;
        address challenger;
        address accepter;
        uint totalBet; // amount of bet
        uint comission; // amount of bet
        string status; // pending || complete
        uint option;
        uint selectedNumber;
    }

    address public constant Dead = 0x000000000000000000000000000000000000dEaD;


    mapping (uint => bets) bet;
    mapping (uint => PoolBets) poolBet;
    mapping (uint => bool) bet_value;
    mapping(address => mapping(uint => bool)) bet_value_token;
    mapping(address => bool) token_enabled;
    mapping(uint => uint) option_odds;
    bool all_tokens;

    uint poolBetCounter = 0;
    uint last_id = 1;
    uint last_pool_id = 1;
    uint bets_treasury;

    uint bet_tax = 1;
    uint infra_cost = 100;
    address devWallet;
    address milkToken;

    event LogPublishPoolBet(
        uint indexed _id,
        address indexed _gambler,
        uint256 totalBet,
        uint timestamp
    );

    event LogAcceptBet(
        uint indexed _id,
        address indexed _challenger,
        address indexed _accepter,
        uint option,
        uint256 _price
    );

    event LogResolveBet(
        uint indexed _id,
        address indexed _challenger,
        address indexed _accepter,
        uint256 _prize
    );

    function enable_bet_value(uint value, bool booly) public onlyAuth {
        bet_value[value] = booly;
    }

    function enable_bet_value_token(uint value, bool booly, address token) public onlyAuth {
        bet_value_token[token][value] = booly;
    }

    function enable_option_odd(uint option, uint odd) public onlyAuth {
        option_odds[option] = odd;
    }

    function set_tax(uint tax) public onlyAuth {
        bet_tax = tax;
    }

    function set_infra_cost(uint cost) public onlyAuth {
        infra_cost = cost;
    }

    function set_milk_token(address _milkToken) public onlyAuth {
        milkToken = _milkToken;
    }

    constructor(address d, address _milkToken) {
        owner = msg.sender;
        is_auth[owner] = true;
        devWallet = d;
        milkToken = _milkToken;
        option_odds[1] = 600; // 6.0
        option_odds[2] = 200; // 2.0
        bet_value[101000000000000000] = true;
        bet_value[252500000000000000] = true;
        bet_value[505000000000000000] = true;
    }

    function place_bet(uint option) payable public safe {
        require(bet_value[msg.value], "Wrong value, thanks and bye bye");
        require(IERC20(milkToken).balanceOf(msg.sender) > 0, "No tokens");

        uint id = last_id;
        last_id += 1;


        uint divider = 100 * msg.value;
        uint divisor = 100 + bet_tax;
        uint bet_val = divider / divisor;


        bet[id].actor = msg.sender;
        bet[id].active = true;
        bet[id].timestamp = block.timestamp;
        bet[id].value = bet_val;
        bet[id].token = Dead;
        bet[id].option = option;
        bet[id].selectedNumber = 0;
        uint taxed = (bet_val * bet_tax)/100;
        sendComissions(taxed);

        bets_treasury += bet_val - taxed;


        emit placed_bet(msg.sender, Dead, bet_val, option, block.timestamp, id, 0);
    }

    // Publish a new bet
    function publish_bet(uint option, uint selectedNumber) payable public {
        // The challenger must deposit his bet
        require(msg.value > 0, "Has to send"); // Add min bet ?

        uint id = last_pool_id;
        last_pool_id += 1;

        poolBetCounter++;
        // Send commision
        uint divider = 100 * msg.value;
        uint divisor = 100 + bet_tax;
        uint bet_val = divider / divisor;

        poolBet[id].challenger = msg.sender;
        poolBet[id].accepter = address(0x0);
        poolBet[id].totalBet = bet_val;
        poolBet[id].status = 'pending';
        poolBet[id].selectedNumber = selectedNumber;
        poolBet[id].option = option;
        // poolBet[id].option = option;
        uint taxed = (bet_val * bet_tax)/100;
        sendComissions(taxed);

        poolBet[id].comission = taxed;
        bets_treasury += bet_val - taxed;
        
        // Trigger a log event
        emit LogPublishPoolBet(poolBetCounter, msg.sender, bet_val, block.timestamp);
    }

    // accept a new bet
    // Accept a bet
  function acceptBet(uint _id) payable public {
    // Check whether there is a bet published
    require(poolBetCounter > 0);

    // Check that the bet exists
    require(_id > 0 && _id <= poolBetCounter);

    // Check that the bet has not been accepted yet
    require(poolBet[_id].accepter == address(0x0), "Bet is already accepted by other");

    // Don't allow the challenger to accept his own bet
    require(msg.sender != poolBet[_id].challenger, "You can't challenge yourself");

    // The accepter must deposit his bet
    require(msg.value < poolBet[_id].totalBet, "Send same amount of bet price");

    poolBet[_id].accepter = msg.sender;
    poolBet[_id].status = 'both';

    // Trigger a log event
    emit LogAcceptBet(_id, poolBet[_id].challenger, poolBet[_id].accepter, poolBet[_id].option, poolBet[_id].totalBet);

  }

  // resolve bet
  function resolveBet(uint _id, bool challengerWins) onlyAuth public {
    // The bet must not be open
    require(poolBet[_id].accepter != address(0x0), "Bet has to get accepter");

    // The bet must not have been paid out yet
    require(poolBet[_id].totalBet > 0, "Bet has to get price");
    // Execute payout
    if (challengerWins) { // challenger wins
    (bool sendCommisionCb,) = poolBet[_id].challenger.call{value: poolBet[_id].totalBet}("");
      require(sendCommisionCb, 'Sent commision failed');
    } else { // accepter wins
    (bool sendCommisionCb,) = poolBet[_id].accepter.call{value: poolBet[_id].totalBet}("");
      require(sendCommisionCb, 'Sent commision failed');
    }

    // Set the bet status as paid out (price = 0)
    poolBet[_id].totalBet = 0;
    poolBet[_id].status = 'paid';

    // Trigger a log event
    emit LogResolveBet(_id, poolBet[_id].challenger, poolBet[_id].accepter, poolBet[_id].totalBet);
  }

    function place_bet_token(address addy, uint qty, uint option, uint selectedNumber) public safe {
        IERC20 tkn = IERC20(addy);
        require(bet_value_token[addy][qty], "Wrong value, thanks and bye bye");
        require(tkn.allowance(msg.sender, address(this)) >= qty, "Allowance needed");
        require(token_enabled[addy] || all_tokens, "Token not enabled");
        require(tkn.balanceOf(address(this)) >= (qty*2), "Payout not assured");
        tkn.transferFrom(msg.sender, address(this), qty);

        uint id = last_id;
        last_id += 1;

        uint bet_val = qty / ((100+bet_tax)/100);

        bet[id].actor = msg.sender;
        bet[id].active = true;
        bet[id].timestamp = block.timestamp;
        bet[id].value = qty;
        bet[id].token = addy;

        uint taxed = (bet_val * bet_tax)/100;
        sendComissions(taxed);

        bets_treasury += bet_val - taxed;

        emit placed_bet(msg.sender, addy, bet_val, option, block.timestamp, id, selectedNumber);
    }

    function get_bet_status(uint id) public view returns(uint, uint, address, bool, address, uint) {
        return(
            bet[id].value,
            bet[id].timestamp,
            bet[id].actor,
            bet[id].active,
            bet[id].token,
            bet[id].status
        );
    }

    function sendComissions(uint taxed) internal {
      uint commissionAmount = (taxed * infra_cost)/100;

      (bool sendCommisionCb,) = devWallet.call{value: (commissionAmount)}("");
      require(sendCommisionCb, 'Sent commision failed');
    }

    function win(uint id) public onlyAuth {
        require(bet[id].active, "Nope");
        bet[id].active = false;
        bet[id].status = 1;

        uint256 jackpot = bet[id].value * option_odds[bet[id].option] / 100;

        (bool sent,) =bet[id].actor.call{value: (jackpot)}("");
        if (!sent) {
            emit won_bet_unpaid(id, block.timestamp, bet[id].actor, "withdraw failed");
        } else {
            emit won_bet(id, block.timestamp, jackpot, bet[id].actor);
        }
    }

    function lose(uint id) public onlyAuth {
        require(bet[id].active, "Nope");
        bet[id].active = false;
        bet[id].status = 2;
        emit lost_bet(id, bet[id].value, block.timestamp, bet[id].actor);
    }

    function unstuck_bnb() public onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function unstuck_tokens(address tkn) public onlyOwner {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
    }

}