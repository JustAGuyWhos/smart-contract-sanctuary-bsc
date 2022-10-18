// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./lib/StakingBase.sol";
import "./lib/PartialBlacklist.sol";
import "./lib/Signatures.sol";
import "./lib/roles/Ownable.sol";


/** @title Staking stablecoin and getting rewards in rewarded tokens*/
contract Staking is StakingBase, Signatures, PartialBlacklist {

    bytes32 internal constant DELEGATE_BLACKLIST = keccak256("DELEGATE_BLACKLIST");
    bytes32 internal constant UNDELEGATE_BLACKLIST = keccak256("UNDELEGATE_BLACKLIST");
    bytes32 internal constant CLAIM_BLACKLIST = keccak256("CLAIM_BLACKLIST");

    /**
     * @notice contract initializer
     * @dev lengths of _durations and _interests arrays should be equal
     * @param _delegatedToken - address of ERC20 token for delegating
     * @param _rewardedToken - address of ERC20 token for claiming rewards
     * @param _durations - array of staking durations
     * @param _interests - array of interests for the appropriate durations.
     */
    function initialize(
        address _delegatedToken,
        address _rewardedToken,
        uint256[] memory _durations,
        uint256[] memory _interests
    ) external initializer {
        StakingBase._initialize(_delegatedToken, _rewardedToken, _durations, _interests);
        initialize();
    }

    /**
     * @notice registers delegated tokens to account address
     * @dev _rate has to be signed by address with signer role
     * @param amount - amount of approved tokens for delegating
     * @param duration - delegation duration
     */
    function delegate(string memory uid, uint256 amount, uint256 duration, uint8 v, bytes32 r, bytes32 s)
        external
        virtual 
        verifySignatureDelegate(uid, amount, duration, v, r, s)
        notBlacklisted(DELEGATE_BLACKLIST, msg.sender) 
    {
        _delegate(msg.sender, amount, block.timestamp, duration);
    }

    /**
     * @notice transfers delegated tokens back to delegator
     * @dev `msg.sender` has to be not blacklisted
     * @param amount - amount of tokens to undelegate
     */
    function undelegate(uint256 amount) external notBlacklisted(UNDELEGATE_BLACKLIST, msg.sender) {
        require(amount <= delegation[msg.sender].amount, "(undelegate) amount more than delegated");

        _undelegate(msg.sender, amount, block.timestamp);
    }

    /**
     * @notice mint `msg.sender`'s reward in rewarded tokens and undelegate all tokens
     * @dev _rate has to be signed by address with signer role
     * @param _rate - delegated to rewarded token exchange rate
     * @param _aliveUntil - timestamp of exchange rate deadline
     * @param v - v parameter of the ECDSA signature.
     * @param r - r parameter of the ECDSA signature.
     * @param s - s parameter of the ECDSA signature.
     */
    function claim(string memory uid, uint256 _rate, uint256 _aliveUntil, uint8 v, bytes32 r, bytes32 s)
        external
        virtual
        verifySignatureClaim(uid, _rate, _aliveUntil, v, r, s)
        inPast(_aliveUntil)
        notBlacklisted(CLAIM_BLACKLIST, msg.sender)
    {
        _claim(msg.sender, _rate);
    }

    /**
     * @notice mint `_accounts`'s rewards in rewarded tokens and undelegate all tokens
     * @dev _rate has to be signed by address with signer role
     * @param _rate - delegated to rewarded token exchange rate
     * @param _accounts - list of client addresses
     */
    function claimBatch(uint256 _rate, address[] memory _accounts)
        external
        virtual
        onlyOwner()
        notBlacklistedAccounts(CLAIM_BLACKLIST, _accounts)
    {
        for (uint i = 0; i < _accounts.length; i++) {
           _claim(_accounts[i], _rate);
        }
    }

    /**
     * @notice sets new delegated token address
     * @param _token - new token address for delegations
     */
    function setDelegatedToken(address _token) external onlyOwner {
        require(_token != address(0), "zero address of the token");
        delegatedToken = _token;
    }

    /**
     * @notice sets new rewarded token address
     * @param _token - new token address for rewards
     */
    function setRewardedToken(address _token) external onlyOwner {
        require(_token != address(0), "zero address of the token");
        rewardedToken = _token;
    }

    /**
     * @notice sets interest parameter for the duration of delegation
     * @param duration - duration of delegation
     * @param _interest - interest for the duration
     */
    function setInterest(uint256 duration, uint256 _interest) external onlyOwner {
        _setInterest(duration, _interest);
    }

    /**
     * @notice override and initialize inherited contracts
     */
    function initialize() internal override(Signatures, PartialBlacklist) {
        Signatures.initialize();
        PartialBlacklist.initialize();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./SafeMath.sol";
import "./SafeERC20Upgradeable.sol";
import "./utils/Initializable.sol";


interface IERC20Mintable {
    /**
     * @notice mint new tokens. Only for Minter
     * @param to - address of the token recipient
     * @param amount - amount to minting
     */
    function mint(address to, uint256 amount) external;
}


/** @title Staking contract for delegating and claiming ERC20 tokens*/
contract StakingBase is Initializable {
    using SafeERC20Upgradeable for IERC20;
    using SafeMath for uint256;

    struct Delegation {
        uint256 amount;
        uint256 timestamp;
        uint256 duration;
    }

    uint256 private constant PERCENT_PRECISION = 1000000;

    address public delegatedToken;
    address public rewardedToken;
    uint256 public totalStake;

    /**
     * @notice delegator address => Delegation
     */
    mapping (address => Delegation) public delegation;
    /**
     * @notice duration of delegation => interest
     */
    mapping (uint256 => uint256) public interest;

    event Delegate(address account, uint256 amount, uint256 timestamp, uint256 duration, uint256 interest);
    event Undelegate(address account, uint256 amount, uint256 timestamp);
    event Claim();

    /**
     * @notice calculates yield for `msg.sender` with given rate
     * @param _rate - delegated to rewarded token exchange rate
     */
    function calculateMe(uint256 _rate) public view returns(uint256 yield) {
        return calculateByAccount(_rate, msg.sender);
    }

    /**
     * @notice calculates yield for `_account` with given rate
     * @param _rate - delegated to rewarded token exchange rate
     * @param _account - users address
     */
    function calculateByAccount(uint256 _rate, address _account) public view returns(uint256 yield) {
        Delegation memory _delegation = delegation[_account];

        uint256 delegatedAmount = _delegation.amount;
        uint256 delegationInterest = interest[_delegation.duration];
        return calculate(delegatedAmount, _rate, delegationInterest);
    }

    /**
     * @notice calculates yield for given parameters
     * @param _delegatedAmount - amount of delegated tokens
     * @param _rate - delegated to rewarded token exchange rate
     * @param _delegationInterest - delegation interest
     */
    function calculate(
        uint256 _delegatedAmount, 
        uint256 _rate, 
        uint256 _delegationInterest
    ) public view returns(uint256 yield) {
        uint8 rewardedTokenDecimals = IERC20(rewardedToken).decimals();
        uint256 decimalPrecision = 10 ** rewardedTokenDecimals;

        uint256 delegatedYield = _delegatedAmount.mul(_delegationInterest).mul(decimalPrecision);
        uint256 rewardedYield = delegatedYield.div(PERCENT_PRECISION).div(_rate);

        return rewardedYield;
    }

    /**
     * @dev contract initializer
     * @dev lengths of _durations and _interests arrays should be equal
     * @param _delegatedToken - address of ERC20 token for delegating
     * @param _rewardedToken - address of ERC20 token for claiming rewards
     * @param _durations - array of staking durations
     * @param _interests - array of interests for the appropriate durations.
     */
    function _initialize(
        address _delegatedToken, 
        address _rewardedToken, 
        uint256[] memory _durations, 
        uint256[] memory _interests
    ) internal virtual onlyInitializing {
        delegatedToken = _delegatedToken;
        rewardedToken = _rewardedToken;

        for (uint256 i = 0; i < _durations.length; i++) {
            _setInterest(_durations[i], _interests[i]);
        }
    }

    /**
     * @dev increase delegator delegations
     * @dev duration must exist; verify `interest(duration)` to non-zero value
     * @param account - delegator address
     * @param amount - delegation amount
     * @param timestamp - timestamp of delegation beginning
     * @param duration - delegation duration
     */
    function _delegate(address account, uint256 amount, uint256 timestamp, uint256 duration) internal virtual {
        require(interest[duration] != 0, "(delegate) invalid duration");
        require(amount != 0, "(delegate) zero delegation");

        IERC20(delegatedToken).safeTransferFrom(account, address(this), amount);

        Delegation storage _delegation = delegation[account];

        _delegation.amount = _delegation.amount.add(amount);
        _delegation.timestamp = timestamp;
        _delegation.duration = duration;

        totalStake = totalStake.add(amount);
        
        emit Delegate(account, amount, timestamp, duration, interest[duration]);
    }

    /**
     * @dev decrease delegator delegation
     * @param account - delegator address
     * @param amount - amount of tokens to undelegate
     * @param timestamp - timestamp of delegation beginning
     */
    function _undelegate(address account, uint256 amount, uint256 timestamp) internal virtual {
        Delegation storage _delegation = delegation[account];
        require(amount != 0, "(undelegate) zero undelegation");
        require(amount <= _delegation.amount, "(undelegate) amount more than delegated");

        _delegation.amount = _delegation.amount.sub(amount);
        _delegation.timestamp = timestamp;
        totalStake = totalStake.sub(amount);

        IERC20(delegatedToken).safeTransfer(account, amount);
        emit Undelegate(account, amount, timestamp);
    }

    /**
     * @dev mint `msg.sender`'s reward in rewarded token
     * @param _account - delegator address
     * @param _rate - delegated to rewarded token exchange rate
     */
    function _claim(address _account, uint256 _rate) internal virtual {
        Delegation memory _delegation = delegation[_account];

        require(_delegation.amount != 0, "(claim) zero delegation");
        uint256 delegationFinishTimestamp = _delegation.timestamp.add(_delegation.duration);
        require(delegationFinishTimestamp <= block.timestamp, "(claim) delegation is not finished");

        uint256 reward = calculateByAccount(_rate, _account);

        _undelegate(_account, _delegation.amount, block.timestamp);
        IERC20Mintable(rewardedToken).mint(_account, reward);
    }

    /**
     * @notice sets interest parameter for the duration of delegation
     * @param duration - duration of delegation
     * @param _interest - interest for the duration
     */
    function _setInterest(uint256 duration, uint256 _interest) internal {
        interest[duration] = _interest;
    }
}

// SPDX-License-Identifier: MIT

/**
* Copyright CENTRE SECZ 2018
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity 0.8.11;

import "./roles/BlacklisterRole.sol";

/**
 * @title Partial Blacklist uses hash sum to set address blacklisted
 * @dev Allows accounts to be blacklisted by a "blacklister" role
*/
abstract contract PartialBlacklist is BlacklisterRole {

    mapping(bytes32 => mapping(address => bool)) internal blacklisted;

    event Blacklisted(bytes32 _part, address indexed _account);
    event UnBlacklisted(bytes32 _part, address indexed _account);
    event BlacklisterChanged(address indexed newBlacklister);

    function initialize() internal override virtual onlyInitializing {
        super.initialize();
    }

    /**
     * @dev Throws if argument account is blacklisted
     * @param _part Hash of part for blacklisting
     * @param _account The address to check
    */
    modifier notBlacklisted(bytes32 _part, address _account) {
        require(isBlacklisted(_part, _account) == false, "account blacklisted");
        _;
    }

    /**
     * @dev Throws if argument account is blacklisted
     * @param _part Hash of part for blacklisting
     * @param _accounts The address to check
    */
    modifier notBlacklistedAccounts(bytes32 _part, address[] memory _accounts) {
        for (uint i = 0; i < _accounts.length; i++) {
           require(isBlacklisted(_part, _accounts[i]) == false, "account blacklisted");
        }
        _;
    }

    /**
     * @dev Checks if account is blacklisted
     * @param _part Hash of part for blacklisting
     * @param _account The address to check
    */
    function isBlacklisted(bytes32 _part, address _account) public view returns (bool) {
        return blacklisted[_part][_account];
    }

    /**
     * @dev Adds account to blacklist
     * @param _part Hash of part for blacklisting
     * @param _account The address to blacklist
    */
    function blacklist(bytes32 _part, address _account) public onlyBlacklister {
        blacklisted[_part][_account] = true;
        emit Blacklisted(_part, _account);
    }

    /**
     * @dev Removes account from blacklist
     * @param _part Hash of part for blacklisting
     * @param _account The address to remove from the blacklist
    */
    function unBlacklist(bytes32 _part, address _account) public onlyBlacklister {
        blacklisted[_part][_account] = false;
        emit UnBlacklisted(_part, _account);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./libs.sol";
import "./roles/SignerRole.sol";

abstract contract Signatures is SignerRole{
    using StringLibrary for string;
    using BytesLibrary for bytes32;

    function initialize() internal override virtual onlyInitializing {
        super.initialize();
    }

    modifier inPast(uint256 timestamp) {
        require(block.timestamp <= timestamp, "(inPast) timestamp expired");
        _;
    }

    modifier verifySignatureDelegate(string memory uid, uint256 amount, uint256 duration, uint8 v, bytes32 r, bytes32 s) {
        require(signedBySignerDelegate(uid, amount, duration, v, r, s),
            "(verifySignature) signed by a non-signer");
        _;
    }

    function prepareMessageDelegate(string memory uid, uint256 amount, uint256 duration) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(uid, amount, duration));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) private pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function signedBySignerDelegate(string memory uid, uint256 amount, uint256 duration, uint8 v, bytes32 r, bytes32 s) internal view returns(bool) {
        bytes32 messageHash = prepareMessageDelegate(uid, amount, duration);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return isSigner(signer);
    }

    // ************************************************************

    modifier verifySignatureClaim(string memory uid, uint256 _rate, uint256 _aliveUntil, uint8 v, bytes32 r, bytes32 s) {
        require(signedBySignerClaim(uid, _rate, _aliveUntil, v, r, s),
            "(verifySignature) signed by a non-signer");
        _;
    }

    function prepareMessageClaim(string memory uid, uint256 _rate, uint256 _aliveUntil) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(uid, _rate, _aliveUntil));
    }

    function signedBySignerClaim(string memory uid, uint256 _rate, uint256 _aliveUntil, uint8 v, bytes32 r, bytes32 s) internal view returns(bool) {
        bytes32 messageHash = prepareMessageClaim(uid, _rate, _aliveUntil);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        address signer = ecrecover(ethSignedMessageHash, v, r, s);
        return isSigner(signer);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../utils/ContextUpgradeable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize() internal virtual onlyInitializing {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "./AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() external view returns (uint8);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./Roles.sol";
import "../utils/ContextUpgradeable.sol";
import "./Ownable.sol";

/**
 * @title BlacklisterRole
 * @dev A blacklister role contract.
 */
abstract contract BlacklisterRole is ContextUpgradeable, Ownable {
    using Roles for Roles.Role;

    event BlacklisterAdded(address indexed account);
    event BlacklisterRemoved(address indexed account);

    Roles.Role private _blacklisters;

    function initialize() internal override virtual onlyInitializing {
        super.initialize();
        __Context_init();
    }

    /**
     * @dev Makes function callable only if sender is a blacklister.
     */
    modifier onlyBlacklister() {
        require(isBlacklister(_msgSender()), "BlacklisterRole: caller does not have the Blacklister role");
        _;
    }

    /**
     * @dev Checks if the address is a blacklister.
     */
    function isBlacklister(address account) public view returns (bool) {
        return _blacklisters.has(account);
    }

    /**
     * @dev Makes the address a blacklister.
     */
    function addBlacklister(address account) external virtual onlyOwner {
        require(!isBlacklister(account), "(addBlacklister) account is already a blacklister");
        _addBlacklister(account);
    }

    /**
     * @dev Remove the address from a blacklister.
     */
    function removeBlacklister(address account) external virtual onlyOwner {
        require(isBlacklister(account), "(addBlacklister) account is not a blacklister");
        _removeBlacklister(account);
    }

    function _addBlacklister(address account) internal {
        _blacklisters.add(account);
        emit BlacklisterAdded(account);
    }

    function _removeBlacklister(address account) internal {
        _blacklisters.remove(account);
        emit BlacklisterRemoved(account);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./SafeMath.sol";

library BytesLibrary {
    function toString(bytes32 value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint8(value[i] >> 4)];
            str[1+i*2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }
}

library UintLibrary {
    using SafeMath for uint;

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function bp(uint value, uint bpValue) internal pure returns (uint) {
        return value.mul(bpValue).div(10000);
    }
}

library StringLibrary {
    using UintLibrary for uint256;

    function append(string memory _a, string memory _b) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory bab = new bytes(_ba.length + _bb.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }

    function append(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory bbb = new bytes(_ba.length + _bb.length + _bc.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bbb[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bbb[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) bbb[k++] = _bc[i];
        return string(bbb);
    }

    function recover(string memory message, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes memory msgBytes = bytes(message);
        bytes memory fullMessage = concat(
            bytes("\x19Ethereum Signed Message:\n"),
            bytes(msgBytes.length.toString()),
            msgBytes,
            new bytes(0), new bytes(0), new bytes(0), new bytes(0)
        );
        return ecrecover(keccak256(fullMessage), v, r, s);
    }

    function concat(bytes memory _ba, bytes memory _bb, bytes memory _bc, bytes memory _bd, bytes memory _be, bytes memory _bf, bytes memory _bg) internal pure returns (bytes memory) {
        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length + _bf.length + _bg.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) resultBytes[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) resultBytes[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) resultBytes[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) resultBytes[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) resultBytes[k++] = _be[i];
        for (uint i = 0; i < _bf.length; i++) resultBytes[k++] = _bf[i];
        for (uint i = 0; i < _bg.length; i++) resultBytes[k++] = _bg[i];
        return resultBytes;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./Roles.sol";
import "../utils/ContextUpgradeable.sol";
import "./Ownable.sol";

/**
 * @title SignerRole
 * @dev A signer role contract.
 */
abstract contract SignerRole is ContextUpgradeable, Ownable {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    function initialize() internal override virtual onlyInitializing {
        super.initialize();
        __Context_init();
    }

    /**
     * @dev Makes function callable only if sender is a signer.
     */
    modifier onlySigner() {
        require(isSigner(_msgSender()), "SignerRole: caller does not have the Signer role");
        _;
    }

    /**
     * @dev Checks if the address is a signer.
     */
    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    /**
     * @dev Makes the address a signer.
     */
    function addSigner(address account) external virtual onlyOwner {
        require(!isSigner(account), "(addSigner) account is already a signer");
        _addSigner(account);
    }

    /**
     * @dev Remove the address from a signers.
     */
    function removeSigner(address account) external virtual onlyOwner {
        require(isSigner(account), "(addSigner) account is not a signer");
        _removeSigner(account);
    }

    /**
     * @dev Removes the address from signers. Signer can be renounced only by himself.
     */
    function renounceSigner() public {
        _removeSigner(_msgSender());
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}