/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: No License
pragma solidity ^0.7.4;

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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
 contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
     emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an BNB balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

contract TravelersePrivatesale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //===============================================//
    //          Contract Variables                   //
    //===============================================//

    
    // Start time 06/29/2022 @ 1:00 pm (UTC) //
    uint256 public constant CROWDSALE_START_TIME = 1656507600;
    
    //Minimum contribution is 0.1 BNB
    uint256 public constant MIN_CONTRIBUTION_BNB = 100000000000000000;
    
    //Maximum contribution is 100 BNB
    uint256 public constant MAX_CONTRIBUTION_BNB = 100000000000000000000;

    //Minimum contribution is 20 BUSD
    uint256 public constant MIN_CONTRIBUTION_BUSD = 20000000000000000000;
    
    //Maximum contribution is 50000 BUSD
    uint256 public constant MAX_CONTRIBUTION_BUSD = 50000000000000000000000;

    // Contributions state
    mapping(address => uint256) public contributionsInBNB;
    mapping(address => uint256) public contributionsInBUSD;
    mapping(address => bool) public claimed;
    mapping(address => bool) public claimedReferral;
    //referral rewards
    mapping(address => address) public referrer;
    mapping(address => uint256) public referralRewardInBNB;
    mapping(address => uint256) public referralRewardInBUSD;

    // Note whitelisted addresses
    mapping(address => bool) public whitelisted;

    // Total wei raised (BNB)
    uint256 public weiRaisedBNB;
    
    mapping(address => uint256) public totalReferrals;

    // Total wei raised (BUSD)
    uint256 public weiRaisedBUSD;
    
    //Whether the user can claim or not
    bool public canClaim;

    //Whether the user can claim referral rewards or not
    bool public canClaimReferral;
    
    bool public saleOnForPublic;

    uint256 public referralRebaseAmount = 65;

    // Pointer to the TravelerseToken
    IERC20 public travelerseToken;

    // How many travelerse do we send per BNB contributed.
    uint256 public TravelersePerBnb;
    // How many travelerse do we send per BUSD contributed.
    uint256 public TravelersePerBusd;

    uint256 public referralReward = 10;

    IERC20 public busdToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    
    //===============================================//
    //                 Constructor                   //
    //===============================================//
    constructor(uint256 _travelersePerBnb, uint256 _travelersePerBusd) {
        TravelersePerBnb = _travelersePerBnb;
        TravelersePerBusd = _travelersePerBusd;
    }
    
    
    //===============================================//
    //                   Events                      //
    //===============================================//
    event TokenPurchase(
        address indexed beneficiary,
        uint256 weiAmount,
        uint256 tokenAmount
    );
    
    event TokenTransfer(
        address indexed beneficiary,
        uint256 weiAmount,
        uint256 tokenAmount
    );
    
    event LogUserAdded (address _user);

    //===============================================//
    //                   Methods                     //
    //===============================================//

    // Main entry point for buying into the Pre-Sale. Contract Receives $BNB
    function purchaseTRAVELERSETokensInBNB(address _referrer) external payable {
          // Validations.
            require(
                msg.sender != address(0),
                "TravelerseCrowdsale: beneficiary is the zero address"
            );
            require(saleOnForPublic, "Sorry the sale is yet not open for general public");
            
            require(isOpen() == true, "Crowdsale has not yet started");
            require(!canClaim, "Sale is over");
            
            require(msg.value >= MIN_CONTRIBUTION_BNB, "TRAVELERSECrowdsale: minimum contribution is 0.1 BNB");
            require(contributionsInBNB[msg.sender] + msg.value <= MAX_CONTRIBUTION_BNB, "TRAVELERSECrowdsale: maximum contribution is 100 BNB");
            
            // If we've passed validations, let's get them $TRAVELERSEs
            _buyTokensInBNB(msg.sender, msg.value, _referrer);
      
    }

    // Main entry point for buying into the Pre-Sale. Contract Receives $BUSD
    function purchaseTRAVELERSETokensInBUSD(uint256 _busdAmount, address _referrer) public  {
          // Validations.
            require(
                msg.sender != address(0),
                "TravelerseCrowdsale: beneficiary is the zero address"
            );
            require(saleOnForPublic, "Sorry the sale is yet not open for general public");
            
            require(isOpen() == true, "Crowdsale has not yet started");
            require(!canClaim, "Sale is over");
            
            require(_busdAmount >= MIN_CONTRIBUTION_BUSD, "TRAVELERSECrowdsale: minimum contribution is 20 BUSD");
            require(contributionsInBUSD[msg.sender] + _busdAmount <= MAX_CONTRIBUTION_BUSD, "TRAVELERSECrowdsale: maximum contribution is 50k BUSD");
           
            // If we've passed validations, let's get them $TRAVELERSEs
            _buyTokensInBUSD(msg.sender, _busdAmount, _referrer);
      }

    /**
     * Function that perform the actual transfer of $TRAVELERSEs
     */
    function _buyTokensInBNB(address beneficiary, uint256 _amount, address _referrer) internal {
        
        // Update how much wei we have raised
        weiRaisedBNB = weiRaisedBNB.add(_amount);
        // Update how much wei has this address contributed
        contributionsInBNB[beneficiary] = contributionsInBNB[beneficiary].add(_amount);
        if(referrer[beneficiary] == address(0) && _referrer != beneficiary && _referrer != address(0)){
            referrer[beneficiary] = _referrer; 
            totalReferrals[_referrer] ++;
        }
        referralRewardInBNB[referrer[beneficiary]] += _amount.mul(referralReward).div(100);
}

    function _buyTokensInBUSD(address beneficiary, uint256 _busdAmount, address _referrer) internal {
        
        busdToken.safeTransferFrom(beneficiary, address(this), _busdAmount);

        // Update how much wei we have raised
        weiRaisedBUSD = weiRaisedBUSD.add(_busdAmount);
        // Update how much wei has this address contributed
        contributionsInBUSD[beneficiary] = contributionsInBUSD[beneficiary].add(_busdAmount);

        if(referrer[beneficiary] == address(0) && _referrer != beneficiary && _referrer != address(0)){
            referrer[beneficiary] = _referrer; 
            totalReferrals[_referrer] ++;
        }
            referralRewardInBUSD[referrer[beneficiary]] += _busdAmount.mul(referralReward).div(100);
    }
    
    function claimTokens() public {
        require(!claimed[msg.sender],"You have already claimed your tokens");
        require(canClaim, "Claim of tokens is not activated, please wait!");
        
        uint256 contributedAmountBNB = contributionsInBNB[msg.sender];
        uint256 contributedAmountBUSD = contributionsInBUSD[msg.sender];

        require(contributedAmountBNB > 0 || contributedAmountBUSD > 0 , "You haven't contributed anything");


        // Calculate how many $TRAVELERSEs can be bought with contributed amount
        uint256 tokenAmountBNB = _getTokenAmountBNB(contributedAmountBNB);
        uint256 tokenAmountBUSD = _getTokenAmountBUSD(contributedAmountBUSD);
     
        uint256 finalTokenAmount = tokenAmountBNB.add(tokenAmountBUSD);
        finalTokenAmount += finalTokenAmount.mul(5).div(100); //give 5% bonus tokens to private sale investors
        claimed[msg.sender] = true;
        
        // Transfer the $TRAVELERSEs to the beneficiary
        travelerseToken.safeTransfer(msg.sender, finalTokenAmount);

        // Create an event for this purchase
        emit TokenTransfer(msg.sender, contributedAmountBNB, tokenAmountBNB);
        emit TokenTransfer(msg.sender, contributedAmountBUSD, tokenAmountBUSD);
    }

    function claimReferralTokens() public {

        require(!claimedReferral[msg.sender],"You have already claimed your referral tokens");
        require(canClaimReferral, "Claim of referral tokens is not activated, please wait!");
        
        uint256 referralAmountBNB = referralRewardInBNB[msg.sender];
        uint256 referralAmountBUSD = referralRewardInBUSD[msg.sender];

        require(referralAmountBNB > 0 || referralAmountBUSD > 0 , "You haven't contributed anything");


        // Calculate how many $TRAVELERSEs can be bought with contributed amount
        uint256 tokenAmountBNB = _getTokenAmountBNB(referralAmountBNB);
        uint256 tokenAmountBUSD = _getTokenAmountBUSD(referralAmountBUSD);
     
        uint256 finalTokenAmount = tokenAmountBNB.add(tokenAmountBUSD);

        //give 65% ineterest of 1 month
        finalTokenAmount += finalTokenAmount.mul(referralRebaseAmount).div(100); 

        claimedReferral[msg.sender] = true;
        
        // Transfer the $TRAVELERSEs to the beneficiary
        travelerseToken.safeTransfer(msg.sender, finalTokenAmount);

        // Create an event for this purchase
        emit TokenTransfer(msg.sender, referralAmountBNB, tokenAmountBNB);
        emit TokenTransfer(msg.sender, referralAmountBUSD, tokenAmountBUSD);
    

    }

    // Calculate how many $TRAVELERSEs do they get given the amount of wei
    function _getTokenAmountBNB(uint256 weiAmount) internal view returns (uint256)
    {
        return weiAmount.mul(TravelersePerBnb);
    }

    // Calculate how many $TRAVELERSEs do they get given the amount of BUSD
    function _getTokenAmountBUSD(uint256 _amount) internal view returns (uint256)
    {
        return _amount.mul(TravelersePerBusd);
    }
    
    function getTokenCountForUser(address _userAddress) public view returns (uint256){
        
        uint256 contributedAmountBNB = contributionsInBNB[_userAddress];
        uint256 contributedAmountBUSD = contributionsInBUSD[_userAddress];

        // Calculate total $TRAVELERSEs 
        uint256 tokenAmountBNB = _getTokenAmountBNB(contributedAmountBNB);
        uint256 tokenAmountBUSD = _getTokenAmountBUSD(contributedAmountBUSD);
     
        uint256 finalTokenAmount = tokenAmountBNB.add(tokenAmountBUSD);
        if(!claimed[_userAddress])
            return finalTokenAmount;
        else    
            return 0;
    }

    function getReferralTokenCountForUser(address _userAddress) public view returns (uint256){
        
        uint256 referralAmountBNB = referralRewardInBNB[_userAddress];
        uint256 referralAmountBUSD = referralRewardInBUSD[_userAddress];

        // Calculate total $TRAVELERSEs 
        uint256 tokenAmountBNB = _getTokenAmountBNB(referralAmountBNB);
        uint256 tokenAmountBUSD = _getTokenAmountBUSD(referralAmountBUSD);
     
        uint256 finalTokenAmount = tokenAmountBNB.add(tokenAmountBUSD);
        if(!claimedReferral[_userAddress])
            return finalTokenAmount;
        else    
            return 0;
    }


    
    
    

    /*************************** CONTROL FUNCTIONS **************************************/
    

    // Is the sale open now?
    function isOpen() public view returns (bool) {
        return block.timestamp >= CROWDSALE_START_TIME;
    }

    function changeTravelerseBnbRate(uint256 _newRate) public onlyOwner returns(bool) {
        require(_newRate != 0, "New Rate can't be 0");
        TravelersePerBnb = _newRate;
        return true;
    }
    
    function openSaleForAll() public onlyOwner {
        require(!saleOnForPublic,"already open");
        saleOnForPublic = true;
    }
    
    function activateClaim() public onlyOwner{
        require(!canClaim, "already activated");
        canClaim = true;
    }

    function activateReferralClaim() public onlyOwner{
        require(!canClaimReferral, "already activated");
        canClaimReferral = true;
    }

    function changeReferralReward(uint256 _referralReward) public onlyOwner{
        referralReward = _referralReward;
    }

    function getTotalReferralsCount(address _userAddress) public view returns (uint256) {
        return totalReferrals[_userAddress];
    }
    
    function addTokenAddress(IERC20 _travelerseToken)public onlyOwner{
        travelerseToken = _travelerseToken;
    }
    
    function takeOutRemainingTokens() public onlyOwner {
        travelerseToken.safeTransfer(msg.sender, travelerseToken.balanceOf(address(this)));
    }
    
    function takeOutFundingRaisedInBNB()public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function takeOutFundingRaisedInBusd() public onlyOwner {
        busdToken.safeTransfer(owner, busdToken.balanceOf(address(this)));
    }
    
}