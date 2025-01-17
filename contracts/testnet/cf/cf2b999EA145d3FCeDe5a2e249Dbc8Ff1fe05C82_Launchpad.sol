/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

contract Launchpad is Ownable {
    
    using SafeMath for uint256;

    mapping(address => mapping(address => bool)) isWhitelisted;
    
    struct Buyers {
        address addr;
        uint256 amount;
    }

    struct tokenConfig {
        bool enableWhitelist;
        bool vestEnabled;
        uint256 decimals;
        uint256 amount;
        uint256 firstRelease;
        uint256 cyclePeriod;
        uint256 tokenPerCycle;
        uint256 startTime; 
        uint256 rate; 
        uint256 projStrtTime; 
        uint256 projEndTime; 
        bool ended;
        uint256 softcap; 
        Buyers[] bbuyers;
    }

    address payable admin;
    uint256 listingPrice = 1 ether;
    mapping(address => uint256) totalRaised;
    mapping(address => address) token2Owner;
    mapping(address => tokenConfig) tokenConfigs;
    mapping(address => address[]) whitelists;
    mapping(address => mapping (address => uint256)) tokenBuyers;
    mapping(address => mapping (address => uint256)) rounds;
    mapping(address => mapping (address => uint256)) boughtAmount;
    
    constructor (address payable _admin) {
        admin = _admin;
    }
    
    function setConfigs(address token, bool enableWhitelist) public {
        require (msg.sender == token2Owner[token]);
        tokenConfigs[token].enableWhitelist = enableWhitelist;
    }

    function setWhitelists(address token, address[] memory addresses) public {
        require (msg.sender == token2Owner[token]);
        require (tokenConfigs[token].enableWhitelist == true);

        for (uint256 i = 0 ; i < addresses.length ; i++) {
            isWhitelisted[token][addresses[i]] = true;
            if (isDuplicated(whitelists[token], addresses[i]) == false)
                whitelists[token].push(addresses[i]);
        }
    }

    function isDuplicated(address[] memory whitelist, address addr) private pure returns (bool){
        for (uint256 i = 0 ; i < whitelist.length ; i++)
            if (whitelist[i] == addr) return true;
        return false;
    }

    function getBlockTimestamp() public view returns(uint256) {
        return block.timestamp;
    }

    function getWhitelist(address token) public view returns (address[] memory) {
        uint256 count;
        for (uint256 i = 0 ; i < whitelists[token].length ; i++) {
            address addr = whitelists[token][i];
            if (isWhitelisted[token][addr] == true)
                count++;
        }
        address[] memory whitelist = new address[](count);
        count = 0;
        for (uint256 i = 0 ; i < whitelists[token].length ; i++) {
            address addr = whitelists[token][i];
            if (isWhitelisted[token][addr] == true)
                whitelist[count++] = addr;
        }
        return whitelist;
    }
    
    function resetWhitelists(address token, address[] memory addresses) public {
        require (msg.sender == token2Owner[token]);
        require (tokenConfigs[token].enableWhitelist == true);

        for (uint256 i = 0 ; i < addresses.length ; i++)
            isWhitelisted[token][addresses[i]] = false;
    }
    
    function setListingPrice(uint256 listPrice) public onlyOwner {
        listingPrice = listPrice;
    }
    
    function listToken(
        address token, 
        uint256 dec, 
        bool whitelisted, 
        uint256 tokenAmount, 
        uint256 rate, 
        uint256 start, 
        uint256 end, 
        bool vestEnabled, 
        uint256 firstReleasing, 
        uint256 cycle, 
        uint256 tokenPerCycling 
    ) external payable {
        require(msg.value >= listingPrice);
        token2Owner[token] = msg.sender;
        tokenConfigs[token].amount = tokenAmount * (10 ** (18 - dec));
        tokenConfigs[token].rate = rate;
        tokenConfigs[token].projStrtTime = start;
        tokenConfigs[token].projEndTime = end;
        tokenConfigs[token].decimals = dec;
        tokenConfigs[token].enableWhitelist = whitelisted;

        if (vestEnabled) {
            tokenConfigs[token].vestEnabled = true;
            tokenConfigs[token].firstRelease = firstReleasing;
            tokenConfigs[token].cyclePeriod = cycle;
            tokenConfigs[token].tokenPerCycle = tokenPerCycling;
            
        }
    } 
    
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function sendBNB(uint256 amount) private {
        admin.transfer(amount);
    }

    function withdrawBNB() payable external onlyOwner {
        sendBNB(address(this).balance);
    }

    function tokenOwners(address token) public view returns (address) {
        return token2Owner[token];
    }

    function getTotalRaised(address token) external view returns (uint256){
        return totalRaised[token];
    }

    function finalizeToken(address token) external {
        require(msg.sender == token2Owner[token]);
        tokenConfigs[token].ended = true;
        tokenConfigs[token].startTime = block.timestamp;
        withdrawBNBToTokenOwners(token);
    }

    function isUnLocked(address token, address buyer) public view returns (bool) {
        if (block.timestamp - tokenConfigs[token].startTime < 0) return false;
        uint256 duration = block.timestamp - tokenConfigs[token].startTime;
        uint256 cycle = tokenConfigs[token].cyclePeriod;
        uint256 round = duration / cycle;
        if (round != 0 && round < rounds[buyer][token]) return false;
        return true;
    }

    function calculate(address token, address buyer) private returns (bool) {
        uint256 duration = block.timestamp - tokenConfigs[token].startTime;
        uint256 cycle = tokenConfigs[token].cyclePeriod;
        uint256 round = duration / cycle;
        uint256 ttalAmount = tokenBuyers[buyer][token];
        if (round < rounds[buyer][token]) return false;
        uint256 availableAmount = ttalAmount * tokenConfigs[token].firstRelease / 100 + round * ttalAmount * tokenConfigs[token].tokenPerCycle / 100;
        if (availableAmount > tokenBuyers[buyer][token])
            availableAmount = tokenBuyers[buyer][token];
        rounds[buyer][token] = rounds[buyer][token] + 1;
        IERC20(token).transferFrom(token2Owner[token], buyer, availableAmount - boughtAmount[buyer][token]);
        boughtAmount[buyer][token] += availableAmount - boughtAmount[buyer][token];
        tokenBuyers[buyer][token] -= availableAmount - boughtAmount[buyer][token];
        return true;
    }

    function claimToken(address token) external {
        require(tokenConfigs[token].ended);
        require(tokenBuyers[msg.sender][token] > 0);
        tokenConfig memory config = tokenConfigs[token];
        if (config.vestEnabled) {
            require (calculate(token, msg.sender));
        }
        else {
            IERC20(token).transferFrom(token2Owner[token], msg.sender, tokenBuyers[msg.sender][token]);
            tokenBuyers[msg.sender][token] = 0;
        }
    }

    function cancelToken(address token) external {
        require(msg.sender == token2Owner[token]);
        require(tokenConfigs[token].ended == false);
        tokenConfigs[token].ended = true;
        refundListingPrice(msg.sender);
        refundToBuyers(token);
        // refundToken(token);
    }

    function refundToken(address token) private {
        IERC20(token).transfer(token2Owner[token], tokenConfigs[token].amount);
    }

    function withdrawBNBToTokenOwners(address token) private {
        payable(token2Owner[token]).transfer(totalRaised[token]);
    }

    function refundListingPrice(address addr) private {
        payable(addr).transfer(listingPrice);
    }
    
    function buy(address token) external payable {
        require(msg.value > 0);
        require(tokenBuyers[msg.sender][token] <= tokenConfigs[token].amount);
        uint256 noww = block.timestamp;
        uint256 start = tokenConfigs[token].projStrtTime;
        uint256 end = tokenConfigs[token].projEndTime;
        uint256 dec = tokenConfigs[token].decimals;
        require(!tokenConfigs[token].ended && noww >= start && noww <= end);
        if (tokenConfigs[token].enableWhitelist == true) {
            require (isWhitelisted[token][msg.sender]);
        }
        totalRaised[token] += msg.value;

        bool isExisting = false;
        uint256 pointer = 10000000000;

        (isExisting, pointer) = isAlreadyBought(msg.sender, token);

        if (isExisting)
            tokenConfigs[token].bbuyers[pointer].amount += msg.value;
        else {
            Buyers memory buyer;
            buyer.addr = msg.sender;
            buyer.amount = msg.value;
            tokenConfigs[token].bbuyers.push(buyer);
        }
        
        uint256 rate1 = tokenConfigs[token].rate;
        tokenBuyers[msg.sender][token] += msg.value / (10 ** (18 - dec)) * rate1;
    }

    function isAlreadyBought(address addr, address token) private view returns (bool, uint256){
        tokenConfig memory tb = tokenConfigs[token];
        for (uint256 i = 0 ; i < tb.bbuyers.length ; i++) 
            if (tb.bbuyers[i].addr == addr)
                return (true, i);

        return (false, 10000000000);
    }

    function refundToBuyers(address token) private {
        Buyers[] memory byers = tokenConfigs[token].bbuyers;
        for (uint256 i = 0 ; i < byers.length ; i++) 
            payable(byers[i].addr).transfer(byers[i].amount);
    }

    receive() external payable {}
}