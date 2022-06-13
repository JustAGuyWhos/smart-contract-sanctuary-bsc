/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity 0.4.25;

contract GSPTSTAKING {
    using SafeMath for uint256;
    IBEP20 public token;
    struct Tarif {
        uint256 life_days;
        uint256 percent;
        uint256 min_inv;
    }

    struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint256 totalWithdraw;
        uint256 time;
    }

    struct Player {
        address upline;
        uint256 j_time;
         uint256 checkpoint;
        uint256 dividends;
        //uint256 match_bonus;
        uint256 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        Deposit[] deposits;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) levelBusiness;
    }

    address public owner;
   
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public withdrawFee;
    uint256 public releaseTime = 1598104800;//1598104800
    uint8[] public ref_bonuses; // 1 => 1%



    Tarif[] public tarifs;
    mapping(address => Player) public players;
   

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor(IBEP20 tokenAdd) public {
        owner = msg.sender;
        //stakingAddress = _stakingAddress;
        token = tokenAdd;

        //days , total return percentage//min invest
        // tarifs.push(Tarif(180,9,100));    // 1.5% per month for 180 days min 100
        // tarifs.push(Tarif(365,24,10000)); // 2% per month for 365 days min 10 k
        // tarifs.push(Tarif(730,60,50000)); // 2.5% per month for 2 years days min 50 k


        tarifs.push(Tarif(1,90,10 * 10 ** 18));    // 1.5% per month for 180 days min 100
        tarifs.push(Tarif(2,240,100 * 10 ** 18)); // 2% per month for 365 days min 10 k
        tarifs.push(Tarif(3,600,500 * 10 ** 18)); // 2.5% per month for 2 years days min 50 k
      
        
        ref_bonuses.push(75);    //0.75 % // X =100
        ref_bonuses.push(50); // 0.5 %
        ref_bonuses.push(25); // 0.25 %
   
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            _updateTotalPayout(_addr);
            players[_addr].last_payout = uint256(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _updateTotalPayout(address _addr) private{
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

            if(from < to) {
                player.deposits[i].totalWithdraw += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;

          
       
            uint256 bonus = _amount * ref_bonuses[i] / 10000;

           // players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;

            match_bonus += bonus;
            token.transfer(up,bonus);
            emit MatchPayout(up, _addr, bonus);
         

            up = players[up].upline;
        }
    }
    
    

    function _setUpline(address _addr, address _upline,uint256 amount) private {
        if(players[_addr].upline == address(0)) {//first time entry
            if(players[_upline].deposits.length == 0) {//no deposite from my upline
                _upline = owner;
            }
            players[_addr].upline = _upline;
            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                players[_upline].structure[i]++;
                 players[_upline].levelBusiness[i] += amount;
                _upline = players[_upline].upline;
                if(_upline == address(0)) break;
            }
        }
        
         else
             {
                _upline = players[_addr].upline;
            for( i = 0; i < ref_bonuses.length; i++) {
                     players[_upline].levelBusiness[i] += amount;
                    _upline = players[_upline].upline;
                    if(_upline == address(0)) break;
                }
        }
        
    }

   function deposit(uint8 _tarif, address _upline, uint256 token_quantity) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        uint256 amt = token_quantity * 10 ** 18;
        require(amt >= tarifs[_tarif].min_inv, "Less Then the min investment");
        //require(value_to_check <= tarifs[_tarif].max_inv, "more Then the max investment");
        require(now >= releaseTime, "not open yet");
        
       // require(player.deposits.length < 1,'cannot reinvest before 1 year');
        player.checkpoint = block.timestamp;
        token.transferFrom(msg.sender, address(this), amt);
        Player storage player = players[msg.sender];

        _setUpline(msg.sender, _upline,amt);
        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: amt,
            totalWithdraw: 0,
            time: uint256(block.timestamp) 
        }));
        

        player.total_invested += amt;
        player.j_time =  uint256(block.timestamp);
        invested += amt;

        _refPayout(msg.sender, amt);


     // token.transfer(owner,amt.mul(10).div(100));
      
        emit NewDeposit(msg.sender, amt, _tarif);
    }

function withdraw() payable external {
    
        Player storage player = players[msg.sender];
        _payout(msg.sender);
        require(player.dividends > 0 , "Zero amount");
        uint256 amount = player.dividends;
        //require(amount > 10 * 10 ** 18,'Less then the min withdrawl'); //10$
          

      
        player.dividends = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;
         player.checkpoint = block.timestamp;

        emit Withdraw(msg.sender, amount);
        token.transfer(msg.sender,amount);
       
       
    }
    
    function withdraw_capital() payable external{
        
          Player storage player = players[msg.sender];
         for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;

           

            if(uint256(block.timestamp) > time_end )
            {
                token.transfer(msg.sender,dep.amount);
                delete player.deposits[i];

            }
        }
    }
    
    

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }
    
    function deposit_info(address _addr) view external returns(uint256[] memory dep_amt,uint256[] memory dep_time)
    {
         Player storage player = players[_addr];
          uint256[] memory _dep_amt = new uint256[](player.deposits.length);
        uint256[] memory _dep_time = new uint256[](player.deposits.length);
         for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            
            _dep_amt[i] =dep.amount;
          _dep_time[i] =   dep.time;
        }
        
        return (_dep_amt,_dep_time);
         
    }



    /*
        Only external call
    */
    function userInfo(address _addr) view external returns(uint256[] memory structure,uint256[] memory structurebusiness) {
        Player storage player = players[_addr];
        
        uint256[] memory _structure = new uint256[](ref_bonuses.length);
        uint256[] memory _structurebusiness = new uint256[](ref_bonuses.length);
     


        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            _structure[i] = player.structure[i];
            _structurebusiness[i] =  player.levelBusiness[i];
           
        }

        return (_structure,_structurebusiness);
    }
    


    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (invested, withdrawn, match_bonus);
    }
 
    
}
   

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

}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}