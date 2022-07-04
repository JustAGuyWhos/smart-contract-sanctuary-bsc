/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-09
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor ()  { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

contract FitngoICO is Context, Ownable {
    IBEP20 public Token2;
    IBEP20 public token;    
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

    struct user{
        uint256 depositeAmount;
        uint256 time;
        uint256 tokenWindrwal;
    }

    mapping(address=>user) public userInfo;
  
    bool private hasStart=false;
    bool private finialzie=false;
    address[]  public _useraddress;
    uint256 public softcap=250;
    uint256 public  hardcap=500;
    uint256 public endDate=1662034070;
    uint256 public startDate=1656677288;
    uint256 public minimumDeposite=0.1 ether;
    uint256 public maximumDeposite=10 ether;
    uint256 public tokenPerUsd=3; 
    AggregatorV3Interface public priceFeedBnb;
    AggregatorV3Interface public priceFeedBUSD;
    address public BUSD=0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    constructor()  {
        priceFeedBnb = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);//test net
        priceFeedBUSD = AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa);//test net
        token=IBEP20(0x699CAefc94Ae278CCA3AfFa78862921AED517482);
    }

    /**
    * @dev Pause the sale.
    */   
    function pauseSale() external onlyOwner returns (bool){
        hasStart=false;
        return true;
    }
    /**
    * @dev Start the sale.
    */
    function startSale() external onlyOwner returns (bool){
        hasStart=true;
        return true;
    }


   function getLatestPriceBnb() public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8);
    }
    
    function getLatestPriceBUSD() public view returns (uint256) {
        (,int price,,,) = priceFeedBUSD.latestRoundData();
        return uint256(price).div(1e8);
    }    


  /**
   * @dev Returns the bep token owner.
   */
   function buyToken() public payable{
        require(hasStart==true,"Sale is not started");
        require(block.timestamp>startDate,"Sale has not stared yet!"); 
        require(block.timestamp<endDate,"Sale Completed"); 
        require(msg.value>=minimumDeposite,"Minimum Amount Not reached");
        require(msg.value<=maximumDeposite,"maximum Amount reached");      
        uint256 numberOfTokens=bnbToToken(msg.value,0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);        
        userInfo[msg.sender].depositeAmount=msg.value.add(userInfo[msg.sender].depositeAmount);
        userInfo[msg.sender].time=block.timestamp;
        userInfo[msg.sender].tokenWindrwal=(numberOfTokens).add(userInfo[msg.sender].tokenWindrwal);        

       if(!checkExitsAddress(msg.sender)){
            _useraddress.push(msg.sender);
        }
        // token.transfer(msg.sender, numberOfTokens); 
        // payable(owner()).transfer(msg.value);
   }
   
   function swapTokens(address _token2,uint256 _amount) public payable{
        require(hasStart==true,"Sale is not started");
        require(block.timestamp>startDate,"Sale has not stared yet!"); 
        require(block.timestamp<endDate,"Sale Completed"); 
        require(_amount>=minimumDeposite,"Minimum Amount Not reached");
        require(_amount<=maximumDeposite,"maximum Amount reached");  

        uint256 numberOfTokens=bnbToToken(_amount,_token2);
        userInfo[msg.sender].depositeAmount=msg.value.add(userInfo[msg.sender].depositeAmount);
        userInfo[msg.sender].time=block.timestamp;
        userInfo[msg.sender].tokenWindrwal=(numberOfTokens).add(userInfo[msg.sender].tokenWindrwal);  

       if(!checkExitsAddress(msg.sender)){
            _useraddress.push(msg.sender);
        }
   }    
  // to change Price of the token
    function changePrice(uint256 _tokenPerUsd) external onlyOwner{
        tokenPerUsd = _tokenPerUsd;
    }
    
    function finilizeICO() public onlyOwner{
        require(block.timestamp>endDate,"ICO Is Not completed yet");
        finialzie=true;
        hasStart=false;
    }
    function checkExitsAddress(address _userAdd) private view returns (bool){
       bool found=false;
        for (uint i=0; i<_useraddress.length; i++) {
            if(_useraddress[i]==_userAdd){
                found=true;
                break;
            }
        }
        return found;
    }
    // to check number of token for given BNB
    function bnbToToken(uint256 _amount, address currency) public view returns(uint256){
        uint256 precision = 1e4;
        uint256 numberOfTokens;
        uint256 bnbToUsd;
        if(currency==BUSD){
         bnbToUsd = precision.mul(_amount).mul(getLatestPriceBUSD()).div(1e18);  
        }else{
          bnbToUsd = precision.mul(_amount).mul(getLatestPriceBnb()).div(1e18);
        }
        numberOfTokens = bnbToUsd.mul(tokenPerUsd);
        return numberOfTokens.mul(1e18).div(precision);
    }
   function Claim() public{
      
      if(finialzie){
            payable(msg.sender).transfer(userInfo[msg.sender].depositeAmount);
      }else{
          require(address(this).balance>softcap,"Softcap Not Crossed");
          require(block.timestamp>endDate,"ICO Is Not Completed Yet");
          if(checkExitsAddress(msg.sender)){      

            token.transfer(msg.sender, userInfo[msg.sender].tokenWindrwal);        
            userInfo[msg.sender].depositeAmount=0;
            userInfo[msg.sender].time=0;
            userInfo[msg.sender].tokenWindrwal=0;
          }   
      }  
   }

    function withdrwal(address _currency) public onlyOwner{
        require(block.timestamp>endDate,"ICO Is Not completed yet");
        if(_currency == BUSD){
            Token2.transferFrom(address(this),owner(),Token2.balanceOf(address(this)));   
        }else{            
            payable(owner()).transfer(address(this).balance);
        }
    }

    function setEndDate(uint256 _timestamp) public onlyOwner returns (bool){
        endDate=_timestamp;
        return true;
    }


    // function clearData() private{
    //   for(uint256 index=0;index<_useraddress.length;index++){
    //         userInfo[_useraddress[index]].depositeAmount=0;
    //         userInfo[_useraddress[index]].time=0;
    //         userInfo[_useraddress[index]].tokenWindrwal=0;
    //     }
    //     delete _useraddress;
    // }
  
}