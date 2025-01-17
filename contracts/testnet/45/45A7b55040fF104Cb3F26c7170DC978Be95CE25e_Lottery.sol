/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity  >=0.5.0 <0.9.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract Lottery is Ownable{

  using SafeMath for uint;

  struct  _player{
      address[] players;
      uint256 currenttime;
      uint256 winningamount;
      uint256 winners;
      uint256 received_entry;
      uint256 total_entry;

    }

    struct count {  
       address location; 
       uint256 amut;
    }
    count[] private _winners;
    
    
    address  private winner;
    
    event NewEntry(address count);
    event WinnerSelected(address winner, uint amount);
    
    // mapping (uint256 => mapping(address => uint256[])) public amount;

    mapping(uint256 => mapping(address => uint256))public playerentry;
    mapping(address => uint256) public previouslevel;
    mapping(uint256 => _player) public  fin;
    uint256 min_amount=10;
    // uint256 min_entries=2;
    uint256 public time=90 days;
    // mapping(uint256 =>  mapping(uint256 => _player)) public fin;
    IBEP20 public Token;

    constructor(IBEP20 _Token) {
              Token = _Token;
              
              time = time+block.timestamp;
            }

            function change_minfee(uint256 _fee) public onlyOwner {
              
              min_amount = _fee;
            }
            // function set_min_entry(uint256 entry) public {
            //   require(owner==msg.sender,"only owner can call");
            //   min_entries = entry;
            // }
            function set_time(uint256 _time) public onlyOwner{
              
              time = _time;
            }


    function plans(uint256 _level,uint256 _amount) public  {
        
        require(_amount >= min_amount ,"amount must be greater");

         if (_level==1)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =100;
              fin[_level].winners=2;
              fin[_level].total_entry = 6;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=2,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
                

             }
         else  if (_level==2)
            {
          
              fin[_level].currenttime= block.timestamp;  
               fin[_level].winningamount =20;
               fin[_level].winners=25;
               fin[_level].total_entry = 1000;
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=10,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==3)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =50;
              fin[_level].winners=10;
              fin[_level].total_entry = 1000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=10,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==4)
            {
             fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =100 ;
              fin[_level].winners=10;
              fin[_level].total_entry = 2000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=20,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==5)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =250 ;
              fin[_level].winners=10;
              fin[_level].total_entry = 5000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=50,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==6)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =500 ;
              fin[_level].winners=5;
              fin[_level].total_entry = 5000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=50,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==7)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =1000 ;
              fin[_level].winners=4;
              fin[_level].total_entry = 8000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=80,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==8)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =2500 ;
              fin[_level].winners=2;
              fin[_level].total_entry = 10000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=100,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==9)
            {
             fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =5000 ;
              fin[_level].winners=2;
              fin[_level].total_entry = 20000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=200,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
             else  if (_level==10)
            {
              fin[_level].currenttime= block.timestamp;  
              fin[_level].winningamount =10000 ;
              fin[_level].winners=2;
              fin[_level].total_entry = 40000;
              
                require (fin[_level].received_entry<=fin[_level].total_entry,"total entries exceeded");
                fin[_level].received_entry+=1;
                 require (playerentry[_level][msg.sender]<=400,"multiple entries exceeded");
                 playerentry[_level][msg.sender] += 1;
                // emit NewEntry(msg.sender);
                Token.transferFrom(msg.sender,address(this), _amount);
                fin[_level].players.push(msg.sender);
                //  amount[_level][msg.sender].push(_amount);
            }
    }

    function showWinners(uint256 _level) public view returns ( address[] memory, uint[] memory){
        address[] memory addrs = new address[](_winners.length);
        uint[]  memory numbers = new uint[](_winners.length);
        
        for (uint i = 0; i < fin[_level].winners; i++) {
            count storage person = _winners[i];
            addrs[i] = person.location;
            numbers[i] = person.amut;
            
        }
        
        return (addrs, numbers);
       
    }
    // function _resetLottery(uint256 _level) public {

    //     require(msg.sender==owner,"you are not the owner");
    //     count.location = new address[](0);
        
    // }
    
  
  
  
    function randomNumberSelector()
              internal view returns(uint)
        {
          return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty)));
        }

    function selectWinner(uint256 _level) public onlyOwner {
           // uint256 min=fin[_level].total_entry/min_entries;
           //  require(fin[_level].received_entry>=min,"please wait to reach minimum entries");
           require(block.timestamp>=time,"Time not reached");
           uint256 winerRatio =(fin[_level].received_entry.div(fin[_level].total_entry)).mul(100);
           uint256 newwinner=((winerRatio).mul(fin[_level].winners)).div(100); 
           uint256 _amount = (newwinner).mul(fin[_level].winningamount);
           uint256 _amounteverywinner= (_amount).div(fin[_level].winners);
        
        // if(block.timestamp>fin[_level].currenttime && fin[_level].received_entry<fin[_level].total_entry){
        for(uint256 i; i<fin[_level].winners; i++){
    
        winner=fin[_level].players[randomNumberSelector() % fin[_level].players.length];
        Token.transfer(winner,_amounteverywinner); 
         _winners.push(count({location: winner, amut:_amounteverywinner}));
        emit WinnerSelected (winner, _amounteverywinner);
        // fin[_level].players.pop();
        }
       
        delete fin[_level].players;
        
    }
    

}