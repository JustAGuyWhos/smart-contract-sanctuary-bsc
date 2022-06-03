/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: TokenSale2-SLT.sol


pragma solidity ^0.8.4;






interface ISLTToken {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  
}

contract SLTTokenSale is ReentrancyGuard, Context, Ownable {

    using SafeMath for uint256;
    mapping (address => uint256) public _rewards;
    mapping (address => uint256) private _lastUpdatedTime;
    mapping (address => uint256) public _unlockTime;
    mapping (address => uint256) public _part;

    mapping(address => bool) whitelistedAddresses;

    ISLTToken _token;
    uint256 private _tokenDecimals;
    uint256 public _price;
    uint public availableTokensICO;

    address payable public _wallet;

    bool public saleActive = false;
    bool public PreSaleActive = false;

    event TokensPurchased(address purchaser, address owner, uint256 value, uint256 amount);

    constructor (uint256 price, address payable wallet, address token)  {
        require(price >= 0);
        require(wallet != address(0), "Wallet is the zero address");
        
        _price = price; //in Wei
        _wallet = wallet;
        _tokenDecimals = 18;
        _token = ISLTToken(token);
    }
    
    //Switch
    function startICO() external onlyOwner {
        availableTokensICO = _token.balanceOf(address(this));
        saleActive = true;
    }

    function startPresaleICO() external onlyOwner {
        availableTokensICO = _token.balanceOf(address(this));
        PreSaleActive = true;
    }

    function endPresaleICO() external onlyOwner {
        PreSaleActive = false;
    }

    function endICO() external onlyOwner {
        saleActive = false;
    }

    //WLs
    function addToWL(address wallet) public onlyOwner {
        whitelistedAddresses[wallet] = true;
    }

    function deleteFromWL(address wallet) public onlyOwner {
        whitelistedAddresses[wallet] = false;
    }

    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        } else {
            uint256 c = a * b;
            assert(c / a == b);
            return c;
        }
    }
    
    //Selling
    function buyTokens(uint256 tokensAmount) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        require(saleActive, "Sale is not active");
        require(msg.sender != address(0), "Receiver is the zero address");
        require(weiAmount >= tokensAmount * _price, "Exceed BNB balance");

        uint256 scaledAmount = safeMultiply(tokensAmount, uint256(10) ** _tokenDecimals);

        availableTokensICO = availableTokensICO - scaledAmount;

        _token.approve(msg.sender, scaledAmount);
        _rewards[msg.sender] += scaledAmount;
        _wallet.transfer(address(this).balance);

        firstPayment(msg.sender, scaledAmount);
        _part[msg.sender] = _rewards[msg.sender]/10;
        
        emit TokensPurchased(msg.sender, _wallet, weiAmount, scaledAmount);
    }

    function buyTokensToWallet(uint256 tokensAmount, address account) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        require(saleActive, "Sale is not active");
        require(account != address(0), "Receiver is the zero address");
        require(weiAmount >= tokensAmount * _price, "Exceed BNB balance");

        uint256 scaledAmount = safeMultiply(tokensAmount, uint256(10) ** _tokenDecimals);

        availableTokensICO = availableTokensICO - scaledAmount;

        _token.approve(msg.sender, scaledAmount);
        _rewards[msg.sender] += scaledAmount;
        _wallet.transfer(address(this).balance);

        firstPayment(msg.sender, scaledAmount);
        _part[msg.sender] = _rewards[msg.sender]/10;
        
        emit TokensPurchased(msg.sender, _wallet, weiAmount, scaledAmount);
    }

    function buyTokensWL(uint256 tokensAmount) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        require(PreSaleActive, "Sale is not active");
        require(msg.sender != address(0), "Receiver is the zero address");
        require(weiAmount >= tokensAmount * _price, "Exceed BNB balance");
        require(whitelistedAddresses[msg.sender], "You are not whitelisted now");

        uint256 scaledAmount = safeMultiply(tokensAmount, uint256(10) ** _tokenDecimals);

        availableTokensICO = availableTokensICO - scaledAmount;

        _token.approve(msg.sender, scaledAmount);
        _rewards[msg.sender] += scaledAmount;
        _wallet.transfer(address(this).balance);

        firstPayment(msg.sender, scaledAmount);
        _part[msg.sender] = _rewards[msg.sender]/10;
        
        emit TokensPurchased(msg.sender, _wallet, weiAmount, scaledAmount);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "Contract has no money");
        _wallet.transfer(address(this).balance);    
    }

    function firstPayment(address account, uint256 tokens) private {
        require(_rewards[account] >= tokens, "Not enough Tokens");
        _token.transfer(account, tokens/10);
        _rewards[account] -= tokens/10;
        _lastUpdatedTime[msg.sender] = block.timestamp;
        _unlockTime[msg.sender] = block.timestamp + 5256000;
    }

    function claimTokens() public {
        require(block.timestamp >= _unlockTime[msg.sender], "Wallet is still locked");
        require(_rewards[msg.sender] >= 0, "Rewards should be more than 0");
        _token.transfer(msg.sender, _part[msg.sender]);
        _rewards[msg.sender] -= _part[msg.sender];
        _unlockTime[msg.sender] = block.timestamp + 2628000;
    }

    //View

    function checkBalance(address wallet) public view returns(uint256){
        return _token.balanceOf(wallet);
    }

    function checkMeinWL(address wallet) public view returns(bool){
        return whitelistedAddresses[wallet];
    }

    //Setting
    
    function setPrice(uint256 newPrice) external onlyOwner {
        _price = newPrice;
    }
    
    function setWalletReceiver(address payable newWallet) external onlyOwner {
        _wallet = newWallet;
    }

    function setNewToken(address _newToken) external onlyOwner {
        _token = ISLTToken(_newToken);
    }

}