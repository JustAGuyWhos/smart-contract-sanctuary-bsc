/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

pragma solidity ^0.5.4;

interface INFT721 {
  function transferFrom(address from,address to,uint256 tokenId) external;
  function balanceOf(address owner) external view returns (uint256 balance);
  function awardItem(address player, string calldata tokenURI) external returns (uint256 tokenId);
  function updateIsTransfer(bool _flag) external;
  function transferOwnership(address newOwner) external;
}

interface IPancakePair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function totalSupply() external view returns (uint);
}

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
}

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
       require(b <= a, errorMessage);
            return a - b;
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
        require(b > 0, errorMessage);
            return a / b;
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
        require(b > 0, errorMessage);
            return a % b;
    }
}

contract  tiger is Ownable{
  using SafeMath for uint;

  INFT721 public ntfAddress;
  IPancakePair public pairAddress;
  IPancakePair public pairUsdtAddress;
  IERC20 public httrAddress;
  IERC20 public httaAddress;
  IERC20 public jihAddress;
  address private fee2;
  address private fee3;
  uint public BabyTigerPrice;
  uint public jkhPrice;
  uint public jihUserCount;
  string tokenUrlV0 = "tiger cub";
  string tokenUrlV1 = "healthy tiger";
  string tokenUrlV2 = "silver tiger";
  string tokenUrlV3 = "golden tiger";
  mapping(address => uint256) public userCount;
  
  // constructor(INFT721 _ntfAddress,IPancakePair _pairAddress,IERC20 _httrAddress,IERC20 _jihAddress,address _fee2,address _fee3,uint _BabyTigerPrice,uint _jihUserCount) public  {
  //   ntfAddress = _ntfAddress;
  //   pairAddress = _pairAddress;
  //   httrAddress = _httrAddress;
  //   jihAddress = _jihAddress;
  //   fee2 = _fee2;
  //   fee3 = _fee3;
  //   BabyTigerPrice = _BabyTigerPrice;
  //   jkhPrice = _jkhPrice;
  //   jihUserCount = _jihUserCount;
  // }

  constructor() public  {
    ntfAddress = INFT721(0x4C6474cd670aff9c8FA0AA8B3F5030694108ff35);
    pairAddress = IPancakePair(0x902b566F85915dF4c1bD6830C60683467B25Dc51);
    pairUsdtAddress = IPancakePair(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
    
    httrAddress = IERC20(0x71d25b8E00450be7A35ae997EE9E2BEdf4169Fd2);
    httaAddress = IERC20(0xC1F39D86DC386316a15816d42b32bEEFaD72480f);
    jihAddress = IERC20(0xc8106fF6D99285EA4CB79B8f17726E31cC2fC5BE);
    fee2 = address(0x26675a50f92047Cdb9009B93037C2B49974522b4);
    fee3 = address(0xDb3854C2ab73e100B4825a970Ee858b101549FAC);
    BabyTigerPrice = 100;
    jkhPrice = 14000;
    jihUserCount = 10;
  }

  event CultivationEvent(address sender, uint amount, string uuid, uint256 tokenId,uint firstPrice);
  event CoCultivationEvent(address sender, uint amount, string uuid);
  event UpVipEvent(address sender, uint amount, string uuid);
  event WakeEvent(address sender, uint amount, string uuid);
  

  function updatefee(address _fee2,address _fee3) public onlyOwner {
    fee2 = _fee2;
    fee3 = _fee3;
  }

  function updateHuPrice(uint _BabyTigerPrice, uint _jkhPrice) public onlyOwner {
    BabyTigerPrice = _BabyTigerPrice;
    jkhPrice = _jkhPrice;
  }

    function updateJihUserCount(uint _jihUserCount) public onlyOwner {
    jihUserCount = _jihUserCount;
  }

  
  
  function cultivation(uint amount,string memory uuid) public  {
    uint firstPrice = 0;
    if(userCount[msg.sender] == 0 && amount != BabyTigerPrice){
            uint jihCount = getJihCount();
            jihAddress.transferFrom(msg.sender,address(0x000000000000000000000000000000000000dEaD),jihCount);
            userCount[msg.sender] = 1;
            firstPrice = jihCount;
        }
    string memory tokenUrl;
    if(amount == BabyTigerPrice){
      tokenUrl = tokenUrlV0;
    }else if(amount == jkhPrice){
      tokenUrl = tokenUrlV1;
    }else{
      require(false,"Payment condition error");
    }
    payment(amount);
    uint256 tokenId = ntfAddress.awardItem(msg.sender,tokenUrl);
    emit CultivationEvent(msg.sender, amount, uuid, tokenId,firstPrice);
  }

  function getJihCount() public view returns  (uint jihCount){
      uint reserve0;
      uint reserve1;
      uint reserveusdt0;
      uint reserveBnb1;
      (reserve0, reserve1 , ) = pairAddress.getReserves();
      (reserveusdt0, reserveBnb1 , ) = pairUsdtAddress.getReserves();
      uint bnbPrice = reserveusdt0 / reserveBnb1;
    
      uint jihPrice = reserve0 * (10**18) / reserve1;

      uint usdtCount = jihUserCount * 10**18 / bnbPrice;
    
      jihCount = usdtCount / jihPrice * 10**18;
  }

  function payment(uint amount) private{
    amount = amount.mul(10**18);
    uint s0 = amount.mul(70).div(100);
    uint s1 = amount.mul(25).div(100);
    uint s2 = amount.mul(5).div(100);
    
    httrAddress.transferFrom(msg.sender,address(0x000000000000000000000000000000000000dEaD),s0);
    httrAddress.transferFrom(msg.sender,fee2,s1);
    httrAddress.transferFrom(msg.sender,fee3,s2);
  }


  function coCultivation(uint amount,string memory uuid) public  {
    payment(amount);

    emit CoCultivationEvent(msg.sender, amount, uuid);
  }


  function upVip(uint amount,string memory uuid) public  {
    payment(amount);

    emit UpVipEvent(msg.sender, amount, uuid);
  }


  function wake(uint amount,string memory uuid) public  {
    payment(amount);

    emit WakeEvent(msg.sender, amount, uuid);
  }


  function updateIsTransfer(bool _flag) public onlyOwner {
    ntfAddress.updateIsTransfer(_flag);
  }


  function updateNFTOwner(address newOwner) public onlyOwner {
    ntfAddress.transferOwnership(newOwner);
  }


  function withdrawalHttr(address[] memory toAddress, uint[] memory amount) public onlyOwner {
    require(toAddress.length == amount.length,"Quantity error");
    for (uint i = 0; i < toAddress.length; i++) {
            httrAddress.transfer(toAddress[i], amount[i]);
        }
  }

  function withdrawalHtta(address[] memory toAddress,uint[] memory amount) public onlyOwner {
    require(toAddress.length == amount.length,"Quantity error");
        for (uint i = 0; i < toAddress.length; i++) {
            httaAddress.transfer(toAddress[i], amount[i]);
        }
  }


  function createHu(address to, uint _type) public onlyOwner returns  (uint tokenId) {
    string memory tokenUrl;
    if(_type == 1){
      tokenUrl = tokenUrlV1;
    } else if(_type == 2) {
      tokenUrl = tokenUrlV2;
    }else if(_type == 3) {
      tokenUrl = tokenUrlV3;
    }else{
      require(false,"error in type");
    }
    tokenId = ntfAddress.awardItem(to,tokenUrl);
  }

  
}