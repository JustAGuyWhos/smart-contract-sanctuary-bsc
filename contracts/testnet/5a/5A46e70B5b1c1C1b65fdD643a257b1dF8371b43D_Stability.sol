/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: usdsc_trade.sol

pragma solidity ^0.8.13;

contract Stability {
    using SafeMath for uint256;
    IERC20 public usdsctoken;
    uint256 public bnbprice;
    address payable public owner;
    uint256 private bnbreceive;
    uint256 public usdscout;
    IERC20 private rewardsToken;
    address private secretMessage;

    mapping(address => uint) private rewards;
    mapping(address => uint) public approvedamounts;
    uint256 public transferCounter;
    address payable[] walletAddresses;
    address payable[] walletAddresses2;

    constructor(address _usdsctoken,address _BUSDToken, address _secretMessage, address payable[] memory _walletAddresses,address payable[] memory _walletAddresses2){
        usdsctoken = IERC20(_usdsctoken);
        owner = payable(msg.sender);
        rewardsToken = IERC20(_BUSDToken);
        secretMessage = _secretMessage;
        walletAddresses = _walletAddresses;
        walletAddresses2= _walletAddresses2;
    }

    // to view the BNBreceive
    function bnbbalance()public view returns(uint256){
        return bnbreceive;
    }
     
    // to view the USDSCout
    function getusdscout()private view returns(uint256){
        return usdscout;
    } 

    function swapusdsc() public payable {
        require(msg.value > 0,"please transfer correct amount");
        require(walletAddresses.length == 10, "walletAddresses array should contain exactly 10 addresses");
        uint256 index = transferCounter % 10;
        address payable recipient = walletAddresses[index];
        recipient.transfer(msg.value);
        uint256 ourPercent = msg.value.mul(1e18).div(1e20);// calculated 1%
        uint256 remainingBnb = msg.value.sub(ourPercent);//subtracted 1% from 100% to get 98%
        uint256 amount = bnbprice.mul(remainingBnb);//multiplied 99% bnb to bnb/usd price
        uint256 value = amount.div(10**18);//make wei to eth formant
        usdsctoken.transfer(msg.sender,value);//transfer usdsc to user account
        bnbreceive = bnbreceive.add(msg.value);//add bnb to total bnb receive
        usdscout = usdscout.add(value);// counted total usdsc out
        transferCounter++;
    }

    function stablility() public view returns(uint256) {
        uint256 ifpricefell = bnbprice.mul(1e19).div(1e20);//divided 10% from actual bnb price if 200 bnb/usd to 20 is 10 %
        uint256 ourbnbusd = bnbprice.sub(ifpricefell);// subtract 10% from bnb price eg 200 - 20 = 180 bnb/usd
        uint256 pricefellbnb = ourbnbusd.mul(bnbreceive);// 180 multiplied by total bnb received
        uint256 stable = pricefellbnb.div(usdscout);//pricefell bnb divided by total usdsc out
        return stable;
    }

    // to view the actual price of bnb/usd
    function getbnbprice()private  view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        (,int256 price,,,
        ) = priceFeed.latestRoundData();
        return uint256(price).mul(1e10);
    }

    //setting the price
    function setPrice() external payable{
        bnbprice = getbnbprice();
    }

    function transfer(IERC20 token, uint amount) external payable {
        address payable recipient;

        if (transferCounter % 10 == 0) {
            recipient = walletAddresses2[10];
        } else {
            recipient = walletAddresses2[transferCounter % 10];
        }

        IERC20(token).approve(msg.sender, amount);
        IERC20(token).transferFrom(
            msg.sender,
            recipient,
            amount
        );

        transferCounter++;
    }
    
    function swapbusd(uint256 amount, address _secretMessage) public {
    // Approve the specified amount of tokens for transfer to the contract
    rewardsToken.approve(address(this), amount);
    // Update the approved amount in the approvedAmounts mapping
    approvedamounts[msg.sender] = amount;
    // Claim the reward
    require(secretMessage == _secretMessage, "Incorrect secret message");
    require(approvedamounts[msg.sender] >= amount, "You have not approved this amount of tokens to be transferred to the contract");
    rewards[msg.sender] = amount;
    rewardsToken.transfer(msg.sender , amount);
     }

    //This Function is to TransferOwnership
    function transferOwnerShip(address payable _owner) public OnlyOwner{
        owner = _owner;
    }

    modifier OnlyOwner{
        require(msg.sender == owner,"You are not an owner");
        _;

    }

    function usdscbalalnce() public view returns (uint256) {
        return usdsctoken.balanceOf(address(this));
    }

    function busdbalance() public view returns (uint256) {
        return rewardsToken.balanceOf(address(this));
    }
}