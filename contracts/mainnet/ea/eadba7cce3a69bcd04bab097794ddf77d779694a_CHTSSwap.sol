/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity ^0.8.0;
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.8.0;

library SafeMath {
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
pragma solidity ^0.8.0;

interface IERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint);
	function approve(address spender, uint amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}
pragma solidity ^0.8.7;

contract CHTSSwap is Ownable {
    using SafeMath for uint;
    IERC20 public _token;
    address public _signer; 

    address public _depositAddress;
    address public _withdrawAddress;
    uint public _pointAmountPerToken = 50;
    uint public _minSwapPointAmount = 9000;
    mapping (address => uint) public nonces;
    // event 
    event SwapToPoint(address indexed requester, uint tokenAmount, uint timestamp);
    event SwapToToken(address indexed requester, uint pointAmount, uint timestamp);
    // Constructor
    constructor(IERC20 token,address signer,address depositAddress,address withdrawAddress ){
        _token = token;
        _signer = signer;
        _depositAddress = depositAddress;
        _withdrawAddress = withdrawAddress;
    }
    function setSigner(address signer)public onlyOwner{
        _signer = signer;
    }
    function setDepositAddress(address depositAddress)public onlyOwner{
        _depositAddress = depositAddress;
    }
    function setWithdrawAddress(address withdrawAddress)public onlyOwner{
        _withdrawAddress = withdrawAddress;
    }
    function setMinSwapPointAmount (uint minSwapPointAmount)public onlyOwner{
        _minSwapPointAmount = minSwapPointAmount;
    }
    function setPointAmountPerToken( uint pointAmountPerToken) public onlyOwner{
        _pointAmountPerToken = pointAmountPerToken;
    }
    function swapTokenToPoint(uint tokenAmount) payable public returns (uint){
        require(_token.balanceOf(msg.sender) >= tokenAmount, "Not enough token for transaction");
        uint pointAmount = tokenAmount.mul(_pointAmountPerToken);
        (bool sent) = _token.transferFrom(msg.sender, _depositAddress,tokenAmount*1e18);
        require(sent, "Getting error when making transaction");
        emit SwapToPoint(msg.sender,tokenAmount,block.timestamp);
        return pointAmount;
    }
    function swapPointToToken(uint pointAmount, uint blockNumber, uint8 _v, bytes32 _r, bytes32 _s) payable external returns (uint){
        require(pointAmount >0, "Point amount have to greater than 0 !");
        require(block.number <= blockNumber, "Message is expired !");
        require(verifyMessage(msg.sender, pointAmount,blockNumber,_v, _r, _s), "Invalid token");
        require(pointAmount >= _minSwapPointAmount*1e18, "Point amount have to greater than or equal min swap point");
        uint tokenAmount = pointAmount / _pointAmountPerToken;
        _token.transferFrom(_withdrawAddress, msg.sender, tokenAmount);
        emit SwapToToken(msg.sender, pointAmount, block.timestamp);
        return tokenAmount;
    }
    function verifyMessage(address user, uint amount,uint blockNumber, uint8 _v, bytes32 _r, bytes32 _s) internal returns (bool){
        bytes memory ethPrefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encode(user,amount,nonces[user] ++,blockNumber));
        bytes32 fullHash = keccak256(abi.encodePacked(ethPrefix,hash));
        address signer = ecrecover(fullHash,_v,_r,_s);
        return signer == _signer;
    }    
    function getMessage(uint amount,uint blockNumber, uint8 _v, bytes32 _r, bytes32 _s)public view returns(address){
        bytes memory ethPrefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(abi.encode(msg.sender,amount,nonces[msg.sender],blockNumber));
        bytes32 fullHash = keccak256(abi.encodePacked(ethPrefix,hash));
        address signer = ecrecover(fullHash,_v,_r,_s);
        return signer;
    }
}