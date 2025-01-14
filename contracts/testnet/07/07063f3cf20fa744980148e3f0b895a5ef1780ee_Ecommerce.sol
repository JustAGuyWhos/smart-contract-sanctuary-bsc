/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;



contract Ecommerce {
        enum status{placedOrder, cancelled,delivered}
        uint256 public productId;
        uint256 public buyerId; 
        address payable public owner;
        using SafeMath for uint256;

        constructor(address payable _owner){
        owner = _owner;
        }
function changeOwner(address payable _ownerAddress) public{
owner = _ownerAddress;
}
modifier onlyOwner{
    require(msg.sender == owner,'you are not the owner');
    _;
}
        //   constructor(){
        // owner =payable( msg.sender);
        // }
    
    struct SellOrder{
        string name;
        uint256 price;
        string description;
        uint256 productId;
        uint256 totalSell;
        uint256[] buyerId;
        address sellerAddress;
    }

    struct BuyOrder{
        uint256 productid;
        uint256 amount;
        uint256 buyId;
        address buyerAddress;
        status Status;
    }

    mapping( uint256 => SellOrder) public sellerOrder;
    
    function setSellOrder(string memory _name, uint256 _price, string memory _description, uint256 _totalSell) public{
        SellOrder storage sellDetails=sellerOrder[productId];
        sellDetails.name = _name;
        sellDetails.price = _price;
        sellDetails.description = _description;
        sellDetails.totalSell = _totalSell;
        sellDetails.sellerAddress =msg.sender;
        productId++;
    }

    function getSellOrder( uint256 _productId) public view  returns ( SellOrder memory ){
     return sellerOrder [_productId];
    }

    mapping (uint256 => BuyOrder) public buyOrder;

    function setBuyOrder ( uint256 _productId) public payable  {
    SellOrder memory sellDetails=sellerOrder[_productId];
   uint256 amount = sellDetails.price;

   require(msg.value == amount,' wrong amount');
    BuyOrder storage buyDetails= buyOrder[buyerId];
    buyDetails.productid = _productId;
    buyDetails.amount =sellDetails.price;
    buyDetails.buyerAddress= msg.sender;
    buyDetails.Status = status.placedOrder;
    buyerId++;

}

function refund(uint256 buyerId) public payable {
      BuyOrder storage buyDetails= buyOrder[buyerId];

uint256 refundAmount = buyDetails.amount;
address payable refunAddress = payable(buyDetails.buyerAddress);
    refunAddress.transfer(refundAmount);
    buyDetails.Status = status.cancelled;
}
function deliverOrder(uint256 _buyerId) public payable{
    BuyOrder storage buyDetails= buyOrder[_buyerId];
        SellOrder storage sellDetails=sellerOrder[buyDetails.productid];
        
   address payable sellerAddress = payable(sellDetails.sellerAddress);
   uint256 amount = sellDetails.price;
   uint256 selleramount=amount.mul(90).div(100);

    sellerAddress.transfer(selleramount);
    buyDetails.Status = status.delivered;
    
}

function withdraw (uint256 amount) public onlyOwner{
     owner.transfer(amount);
}
}