/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

pragma solidity ^0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20Upgradeable {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

contract OperonOriginsUpgradeable is IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    bool public _lockStatus = false;
    bool private isValue;
    uint256 public airdropcount = 0;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    mapping(address => uint256) private time;

    mapping(address => uint256) private _lockedAmount;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply,
        address owner
    ) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply * (10**uint256(decimals));
        _balances[owner] = _totalSupply;
        _owner = owner;
    }

    /*----------------------------------------------------------------------------
     * Functions for owner
     *----------------------------------------------------------------------------
     */

    /**
     * @dev get address of smart contract owner
     * @return address of owner
     */
    function getowner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev modifier to check if the message sender is owner
     */
    modifier onlyOwner() {
        require(isOwner(), "You are not authenticate to make this transfer");
        _;
    }

    /**
     * @dev Internal function for modifier
     */
    function isOwner() internal view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfer ownership of the smart contract. For owner only
     * @return request status
     */
    function transferOwnership(address newOwner)
        public
        onlyOwner
        returns (bool)
    {
        _owner = newOwner;
        return true;
    }

    /* ----------------------------------------------------------------------------
     * Locking functions
     * ----------------------------------------------------------------------------
     */

    /**
     * @dev Lock all transfer functions of the contract
     * @return request status
     */
    function setAllTransfersLockStatus(bool RunningStatusLock)
        external
        onlyOwner
        returns (bool)
    {
        _lockStatus = RunningStatusLock;
        return true;
    }

    /**
     * @dev check lock status of all transfers
     * @return lock status
     */
    function getAllTransfersLockStatus() public view returns (bool) {
        return _lockStatus;
    }

    /**
     * @dev time calculator for locked tokens
     */
    function addLockingTime(
        address lockingAddress,
        uint8 lockingTime,
        uint256 amount
    ) internal returns (bool) {
        time[lockingAddress] = block.timestamp + (lockingTime * 1 days);
        _lockedAmount[lockingAddress] = amount;
        return true;
    }

    /**
     * @dev check for time based lock
     * @param _address address to check for locking time
     * @return time in block format
     */
    function checkLockingTimeByAddress(address _address)
        public
        view
        returns (uint256)
    {
        return time[_address];
    }

    /**
     * @dev return locking status
     * @param userAddress address of to check
     * @return locking status in true or false
     */
    function getLockingStatus(address userAddress) public view returns (bool) {
        if (block.timestamp < time[userAddress]) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev  Decreaese locking time
     * @param _affectiveAddress Address of the locked address
     * @param _decreasedTime Time in days to be affected
     */
    function decreaseLockingTimeByAddress(
        address _affectiveAddress,
        uint256 _decreasedTime
    ) external onlyOwner returns (bool) {
        require(
            _decreasedTime > 0 && time[_affectiveAddress] > block.timestamp,
            "Please check address status or Incorrect input"
        );
        time[_affectiveAddress] =
            time[_affectiveAddress] -
            (_decreasedTime * 1 days);
        return true;
    }

    /**
     * @dev Increase locking time
     * @param _affectiveAddress Address of the locked address
     * @param _increasedTime Time in days to be affected
     */
    function increaseLockingTimeByAddress(
        address _affectiveAddress,
        uint256 _increasedTime
    ) external onlyOwner returns (bool) {
        require(
            _increasedTime > 0 && time[_affectiveAddress] > block.timestamp,
            "Please check address status or Incorrect input"
        );
        time[_affectiveAddress] =
            time[_affectiveAddress] +
            (_increasedTime * 1 days);
        return true;
    }

    /**
     * @dev modifier to check validation of lock status of smart contract
     */
    modifier AllTransfersLockStatus() {
        require(
            _lockStatus == false,
            "All transactions are locked for this contract"
        );
        _;
    }

    /**
     * @dev modifier to check locking amount
     * @param _address address to check
     * @param requestedAmount Amount to check
     */
    modifier checkLocking(address _address, uint256 requestedAmount) {
        if (block.timestamp < time[_address]) {
            require(
                !(_balances[_address] - _lockedAmount[_address] <
                    requestedAmount),
                "Insufficient unlocked balance"
            );
        } else {
            require(1 == 1, "Transfer can not be processed");
        }
        _;
    }

    /* ----------------------------------------------------------------------------
     * View only functions
     * ----------------------------------------------------------------------------
     */

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Total number of tokens in existence.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /* ----------------------------------------------------------------------------
     * Transfer, allow, mint and burn functions
     * ----------------------------------------------------------------------------
     */

    /**
     * @dev Transfer token to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value)
        public
        override
        AllTransfersLockStatus
        checkLocking(msg.sender, value)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        AllTransfersLockStatus
        checkLocking(from, value)
        returns (bool)
    {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Transfer tokens to a secified address (For Only Owner)
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return Transfer status in true or false
     */
    function transferByOwner(
        address to,
        uint256 value,
        uint8 lockingTime
    ) public AllTransfersLockStatus onlyOwner returns (bool) {
        addLockingTime(to, lockingTime, value);
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev withdraw locked tokens only (For Only Owner)
     * @param from locked address
     * @param to address to be transfer tokens
     * @param value amount of tokens to unlock and transfer
     */
    function transferLockedTokens(
        address from,
        address to,
        uint256 value
    ) external onlyOwner {
        require(
            (_lockedAmount[from] >= value) && (block.timestamp < time[from]),
            "Insufficient unlocked balance"
        );
        require(from != address(0) && to != address(0), "Invalid address");
        _lockedAmount[from] = _lockedAmount[from] - value;
        _transfer(from, to, value);
    }

    /**
     * @dev Airdrop function to airdrop tokens. Best works upto 50 addresses in one time. Maximum limit is 200 addresses in one time.
     * @param _addresses array of address in serial order
     * @param _amount amount in serial order with respect to address array
     */
    function airdropByOwner(
        address[] memory _addresses,
        uint256[] memory _amount
    ) public AllTransfersLockStatus onlyOwner returns (bool) {
        require(_addresses.length == _amount.length, "Invalid Array");
        uint256 count = _addresses.length;
        for (uint256 i = 0; i < count; i++) {
            _transfer(msg.sender, _addresses[i], _amount[i]);
            airdropcount = airdropcount + 1;
        }
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(to != address(0), "Invalid to address");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(spender != address(0), "Invalid address");
        require(owner != address(0), "Invalid address");
        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowed[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "Invalid account");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value)
        public
        onlyOwner
        checkLocking(msg.sender, value)
    {
        _burn(msg.sender, value);
    }
}
// File: @openzeppelin/[email protected]/utils/Strings.sol

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/[email protected]/utils/Context.sol

pragma solidity ^0.8.0;

/*
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/[email protected]/access/Ownable.sol

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

// File: @openzeppelin/[email protected]/utils/Address.sol

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

// File: @openzeppelin/[email protected]/utils/introspection/IERC165.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}

// File: @openzeppelin/[email protected]/token/ERC1155/IERC1155Receiver.sol

pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/[email protected]/token/ERC1155/IERC1155.sol

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event Buy(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 amount,
        uint256 quantity
    );

    event Acceptbid(
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 amount,
        uint256 quantity
    );

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/[email protected]/token/ERC1155/extensions/IERC1155MetadataURI.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
}

// File: @openzeppelin/[email protected]/token/ERC1155/ERC1155.sol

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC1155Upgradeable,
    IERC1155MetadataURIUpgradeable
{
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    string private _name;
    string private _symbol;
    struct Metadata {
        string name;
        string ipfsimage;
        string ipfsmetadata;
    }
    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) public _balances;
    mapping(uint256 => Metadata) token_id;
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) public _creator;
    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(
        string memory uri_,
        string memory name_,
        string memory symbol_
    ) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_, name_, symbol_);
    }

    function __ERC1155_init_unchained(
        string memory uri_,
        string memory name_,
        string memory symbol_
    ) internal initializer {
        _setURI(uri_);
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory ipfsmetadata)
    {
        Metadata memory date = token_id[tokenId];
        ipfsmetadata = date.ipfsmetadata;
        return ipfsmetadata;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal {
        _operatorApprovals[owner][operator] = approved;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(
            _msgSender() != operator,
            "ERC1155: setting approval status for self"
        );

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, address(this)),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");
        address operator = _msgSender();
        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );
        uint256 fromBalance = _balances[id][from];
        require(
            fromBalance >= amount,
            "ERC1155: insufficient balance for transfer"
        );
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            account,
            id,
            amount,
            data
        );
    }

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }
        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have atleast `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            account,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ""
        );

        uint256 accountBalance = _balances[id][account];
        require(
            accountBalance >= amount,
            "ERC1155: burn amount exceeds balance"
        );
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:ERC1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(
                accountBalance >= amount,
                "ERC1155: burn amount exceeds balance"
            );
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155ReceiverUpgradeable(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155ReceiverUpgradeable.onERC1155Received.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response !=
                    IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    uint256[47] private __gap;
}

// File: contracts/operan/OperonOriginsNFT.sol

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

// import "./RandomNumberGenerator.sol";

contract OperonOriginsNFTUpgradeable is ERC1155Upgradeable, OwnableUpgradeable {
    address private companyOfficialAddress;
    // using Counters for Counters.Counter;
    // Counters.Counter private characterIds;

    mapping(uint256 => bool) private mappingTokenIdToAvailability;

    uint256[] public tokenList;
    mapping(uint256 => address[]) public tokenOwners;
    mapping(address => uint256[]) public userTokens;
    mapping(uint256 => address payable) public tokenCreators;
    address marketplace;
    address owneraddress;

    constructor() public ERC1155Upgradeable() {
        companyOfficialAddress = msg.sender;
    }

    /**
     *    Mint token and transer to provided address
     *    @param to address of the owner
     *    @param tokenId token Id
     *    @param amount quantity of respected tokenId
     */
    function mint(
        address payable to,
        uint256 tokenId,
        uint256 amount
    ) public returns (uint256) {
        require(msg.sender == owneraddress || msg.sender == marketplace);
        require(tokenId > 0, "Token Id is required");
        require(amount >= 1, "Amount is required");
        require(to == address(to), "Error: Invalid address provided");
        require(
            mappingTokenIdToAvailability[tokenId] == false,
            "Error: This token id has been already allocated. Please try different one."
        );

        _mint(to, tokenId, amount, "");
        mappingTokenIdToAvailability[tokenId] = true;
        tokenList.push(tokenId);
        tokenOwners[tokenId].push(to);
        userTokens[to].push(tokenId);
        tokenCreators[tokenId] = to;
        return tokenId;
    }

    /**
     *    Mint token in batch and transer to provided address
     *
     *    @param to address of owner
     *    @param tokenIds array iist of token Ids
     *    @param amounts arrray list of quantity of a specific token Id
     */
    function mintBatch(
        address payable to,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) public onlyOwner {
        require(
            msg.sender == companyOfficialAddress,
            "Error: You do not have permission to perform this action."
        );
        require(to == address(to), "Error: Invalid address provided");
        require(tokenIds.length > 0, "TokenIds array can not be empty");
        require(amounts.length > 0, "Amounts array can not be empty");

        _mintBatch(to, tokenIds, amounts, "");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenList.push(tokenIds[i]);
            tokenOwners[tokenIds[i]].push(to);
            userTokens[to].push(tokenIds[i]);
            tokenCreators[tokenIds[i]] = to;
        }
    }

    function burn(
        address account,
        uint256 id,
        uint256 quantity
    ) public {
        require(msg.sender == account || msg.sender == marketplace);
        _burn(account, id, quantity);
    }

    function setMarketplaceAddress(address marketplaceaddress)
        public
        onlyOwner
    {
        marketplace = marketplaceaddress;
    }

    function setOwnerAddress(address ownerAddress) public onlyOwner {
        owneraddress = ownerAddress;
    }

    /**
     *  Return uri of provided token Id
     *  @return token uri
     */
    function getUri(uint256 tokenId) public view returns (string memory) {
        require(tokenId > 0, "Token Id is required");
        return (
            string(
                abi.encodePacked(
                    uri(0),
                    StringsUpgradeable.toString(tokenId),
                    ".json"
                )
            )
        );
    }

    /**
     *  Return uri of provided token Id
     *  @return token uri
     */
    function getToken() public view returns (uint256[] memory) {
        return tokenList;
    }

    function getTokenOwner(uint256 tokenId)
        public
        view
        returns (address payable)
    {
        return tokenCreators[tokenId];
    }

    /**
     *  Return uri of provided token Id
     *  @return token uri
     */
    function getOwner(uint256 id) public view returns (address[] memory) {
        return tokenOwners[id];
    }

    /**
     *  Return uri of provided token Id
     *  @return token uri
     */
    function getids(address useradd) public view returns (uint256[] memory) {
        return userTokens[useradd];
    }

    /**
     * Sets new metadata uri
     * @param metadataUrl full URL of the metadata
     */
    function setUri(string memory metadataUrl) public {
        require(bytes(metadataUrl).length > 0, "URI is required.");
        _setURI(metadataUrl);
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        tokenOwners[id].push(to);
        userTokens[to].push(id);

        // require(
        //     from == _msgSender() || isApprovedForAll(from, _msgSender()),
        //     "ERC1155: caller is not owner nor approved"
        // );
        _safeTransferFrom(from, to, id, amount, data);
    }
}

// File: contracts/operan/OperonOriginsMarketplace.sol

pragma solidity ^0.8.0;

contract OperonOriginsMarketplaceUpgradeable is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable
{
    event OfferingPlaced(
        bytes32 indexed offeringId,
        address indexed hostContract,
        address indexed offerer,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        string uri
    );
    event OfferingUpdated(
        bytes32 indexed offeringId,
        string baseCurrency,
        uint256 price
    );

    event burnTokenResp(address to, uint256 tokenId, uint256 amount);
    event mintToken(address to, uint256 tokenId, uint256 amount);
    event transfertoken(address from, uint256 tokenId, uint256 amount);

    event OfferingClosed(bytes32 indexed offeringId, address indexed buyer);
    event PaymentSent(
        address indexed beneficiary,
        string currency,
        uint256 value
    );
    event MaintainerChanged(
        address indexed previousMaintainer,
        address indexed newMaintainer
    );

    address private maintainer;
    uint256 private offeringNonce;
    address private OROOfficialContractAddress;
    uint256 private constant decimal = 18;
    uint256 private serviceValue;
    address payable adminAddress;
    uint256 private constant defaultRoy = 5 * 10**uint256(18);

    enum offeringStatus {
        OPEN,
        CLOSED,
        CANCELLED
    }

    struct offering {
        address payable offerer;
        address hostContract;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        string baseCurrency;
        offeringStatus status;
    }

    mapping(bytes32 => offering) offeringRegistry;
    mapping(uint256 => uint256) public _royal;
    mapping(uint256 => mapping(address => uint256)) public saletoken;

    function initialize(uint256 _serviceValue, address payable adminfeeAddress)
        public
        initializer
    {
        ERC1155Upgradeable.__ERC1155_init("", "", "");
        __Ownable_init();
        maintainer = adminfeeAddress;
        serviceValue = _serviceValue;
        adminAddress = adminfeeAddress;
    }

    modifier onlyMaintainer() {
        require(
            msg.sender == maintainer,
            "Error: This action can be performed by current maintainer only"
        );
        _;
    }

    /**
     *   @dev listing new token for sale
     *   @param _hostContract address of the NFT owner
     *   @param _tokenId id of token
     *   @param _price price of token
     *   @param _baseCurrency BNB or ETH
     *   @return offeringId of offering
     */
    function placeOffering(
        address _hostContract,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price,
        string memory _baseCurrency
    ) external returns (bytes32 offeringId) {
        require(
            keccak256(abi.encodePacked(_baseCurrency)) ==
                keccak256(abi.encodePacked("ORO")) ||
                keccak256(abi.encodePacked(_baseCurrency)) ==
                keccak256(abi.encodePacked("BNB")),
            "Error: Base price can either be in BNB or ORO"
        );

        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );

        bytes32 compositeKey = keccak256(
            abi.encodePacked(msg.sender, _tokenId)
        );

        uint256 tokenBalance = hostContract.balanceOf(msg.sender, _tokenId);

        require(
            tokenBalance >= saletoken[_tokenId][msg.sender] + _amount,
            "Limit Exceeds"
        );

        bytes32 offeringId = keccak256(
            abi.encodePacked(
                offeringNonce,
                _hostContract,
                _tokenId,
                tokenBalance
            )
        );

        offeringRegistry[offeringId].offerer = payable(msg.sender);
        offeringRegistry[offeringId].hostContract = _hostContract;
        offeringRegistry[offeringId].tokenId = _tokenId;
        offeringRegistry[offeringId].amount = _amount;
        offeringRegistry[offeringId].price = _price;
        offeringRegistry[offeringId].baseCurrency = _baseCurrency;
        offeringRegistry[offeringId].status = offeringStatus.OPEN;
        offeringNonce += 1;

        saletoken[_tokenId][msg.sender] =
            saletoken[_tokenId][msg.sender] +
            _amount;

        string memory uri = hostContract.getUri(_tokenId);
        emit OfferingPlaced(
            offeringId,
            offeringRegistry[offeringId].hostContract,
            msg.sender,
            offeringRegistry[offeringId].tokenId,
            offeringRegistry[offeringId].amount,
            offeringRegistry[offeringId].price,
            uri
        );
        return offeringId;
    }

    /**
     *   @dev purchase the listing offering
     *   @param _offeringId identifier of offering
     */
    function cancelOffering(bytes32 _offeringId) external {
        require(
            msg.sender == offeringRegistry[_offeringId].offerer,
            "Error: You can not perform this action"
        );
        require(
            offeringRegistry[_offeringId].status == offeringStatus.OPEN,
            "Error: Offering is closed or cancelled already"
        );

        saletoken[offeringRegistry[_offeringId].tokenId][msg.sender] =
            saletoken[offeringRegistry[_offeringId].tokenId][msg.sender] -
            offeringRegistry[_offeringId].amount;

        offeringRegistry[_offeringId].status = offeringStatus.CANCELLED;

        emit OfferingClosed(_offeringId, msg.sender);
    }

    /**
     *   @dev update details of the offereing
     *   @param _offeringId identifier of offering
     *   @param _price updated price for token
     */
    function updateOffering(bytes32 _offeringId, uint256 _price) external {
        require(
            msg.sender == offeringRegistry[_offeringId].offerer,
            "Error: You can not perform this action"
        );
        require(
            offeringRegistry[_offeringId].status == offeringStatus.OPEN,
            "Error: Offering is closed or cancelled already"
        );
        offeringRegistry[_offeringId].price = _price;

        emit OfferingUpdated(
            _offeringId,
            offeringRegistry[_offeringId].baseCurrency,
            _price
        );
    }

    /**
     *   @dev purchase the listing offering
     *   @param _offeringId identifier of offering
     */
    function purchaseOffering(bytes32 _offeringId, uint256 amount)
        external
        payable
    {
        require(
            offeringRegistry[_offeringId].status == offeringStatus.OPEN,
            "Error: Offering is closed or cancelled already"
        );

        require(
            offeringRegistry[_offeringId].offerer != msg.sender,
            "Error: Can not buy your own offering"
        );

        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            offeringRegistry[_offeringId].hostContract
        );

        address payable nftCreator = hostContract.getTokenOwner(
            offeringRegistry[_offeringId].tokenId
        );

        uint256 tokenBalanceNFT = hostContract.balanceOf(
            offeringRegistry[_offeringId].offerer,
            offeringRegistry[_offeringId].tokenId
        );

        require(
            offeringRegistry[_offeringId].amount >= amount,
            "Error: Insufficient balance"
        );

        uint256 royaltyAmount = _royal[offeringRegistry[_offeringId].tokenId];
        if (royaltyAmount == 0) {
            royaltyAmount = defaultRoy;
        }

        uint256 nftTotalPrice = offeringRegistry[_offeringId].price * amount;

        uint256 _adminfee = (nftTotalPrice * serviceValue) / 10**uint256(20);

        uint256 roy = (nftTotalPrice * royaltyAmount) / 10**uint256(20);

        uint256 netamount = nftTotalPrice - roy;

        // check whether required tokens is available or provided
        if (
            keccak256(
                abi.encodePacked(offeringRegistry[_offeringId].baseCurrency)
            ) == keccak256(abi.encodePacked("ORO"))
        ) {
            OperonOriginsUpgradeable tokenContract = OperonOriginsUpgradeable(
                OROOfficialContractAddress
            );
            uint256 tokenBalance = tokenContract.balanceOf(msg.sender);
            address tokenCreator = offeringRegistry[_offeringId].offerer;
            require(
                tokenBalance >= nftTotalPrice + _adminfee,
                "Error: Not having enough tokens to buy"
            );

            uint256 approveValue = tokenContract.allowance(
                msg.sender,
                address(this)
            );

            require(
                approveValue >= offeringRegistry[_offeringId].price,
                "Error: Approve the token to purchase"
            );

            tokenContract.transferFrom(msg.sender, maintainer, _adminfee);

            tokenContract.transferFrom(msg.sender, nftCreator, roy);

            tokenContract.transferFrom(msg.sender, tokenCreator, netamount);

            emit PaymentSent(tokenCreator, "ORO", nftTotalPrice);
        } else {
            require(
                msg.value >= nftTotalPrice + _adminfee,
                "Error: Not enough funds provided"
            );
            address payable offerer = offeringRegistry[_offeringId].offerer;

            adminAddress.transfer(_adminfee);
            nftCreator.transfer(roy);
            offerer.transfer(netamount);

            emit PaymentSent(
                offeringRegistry[_offeringId].offerer,
                "BNB",
                nftTotalPrice
            );
        }

        // Transfering NFT tokens and marking offering as closed

        hostContract.safeTransferFrom(
            offeringRegistry[_offeringId].offerer,
            msg.sender,
            offeringRegistry[_offeringId].tokenId,
            amount,
            ""
        );

        offeringRegistry[_offeringId].amount =
            offeringRegistry[_offeringId].amount -
            amount;
        saletoken[offeringRegistry[_offeringId].tokenId][
            offeringRegistry[_offeringId].offerer
        ] =
            saletoken[offeringRegistry[_offeringId].tokenId][
                offeringRegistry[_offeringId].offerer
            ] -
            amount;

        if (offeringRegistry[_offeringId].amount == 0) {
            offeringRegistry[_offeringId].status = offeringStatus.CLOSED;
        }

        emit OfferingClosed(_offeringId, msg.sender);
    }

    /**
     *   @dev returns the details of the specified offfering
     *   @param _offeringId identifier of offering
     */
    function viewOfferingNFT(bytes32 _offeringId)
        external
        view
        returns (
            address offerer,
            address hostContract,
            uint256 tokenId,
            uint256 amount,
            uint256 price,
            offeringStatus status
        )
    {
        return (
            offeringRegistry[_offeringId].offerer,
            offeringRegistry[_offeringId].hostContract,
            offeringRegistry[_offeringId].tokenId,
            offeringRegistry[_offeringId].amount,
            offeringRegistry[_offeringId].price,
            offeringRegistry[_offeringId].status
        );
    }

    function burnToken(
        address to,
        uint256 tokenId,
        uint256 amount,
        address _hostContract,
        bytes32 _offeringId,
        uint256 offer
    ) public {
        require(msg.sender == to);
        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );
        uint256 tokenBalance = hostContract.balanceOf(to, tokenId);
        require(tokenBalance >= amount, "Insufficient balance");
        if (offer == 1) {
            offeringRegistry[_offeringId].amount =
                offeringRegistry[_offeringId].amount -
                amount;
            saletoken[tokenId][msg.sender] =
                saletoken[tokenId][msg.sender] -
                amount;
        }
        hostContract.burn(to, tokenId, amount);
        emit burnTokenResp(to, tokenId, amount);
    }

    function mint(
        address payable account,
        uint256 id,
        uint256 quantity,
        address _hostContract,
        uint256 royalty
    ) public {
        require(msg.sender == account);
        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );
        _royal[id] = royalty;
        hostContract.mint(account, id, quantity);
        emit mintToken(account, id, quantity);
    }

    function transfer(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        address _hostContract,
        bytes32 _offeringId,
        uint256 offer
    ) public {
        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );
        uint256 tokenBalance = hostContract.balanceOf(msg.sender, id);
        require(tokenBalance >= amount, "Insufficient balance");
        if (offer == 1) {
            offeringRegistry[_offeringId].amount =
                offeringRegistry[_offeringId].amount -
                amount;
            saletoken[offeringRegistry[_offeringId].tokenId][msg.sender] =
                saletoken[offeringRegistry[_offeringId].tokenId][msg.sender] -
                amount;
        }
        hostContract.safeTransferFrom(from, to, id, amount, "");
        emit transfertoken(from, id, amount);
    }

    /**
     *   @dev returns all the token values
     *   @param _hostContract address of the NFT owner
     */
    function getTokenIds(address _hostContract)
        external
        view
        returns (uint256[] memory)
    {
        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );

        return hostContract.getToken();
    }

    /**
     *   @dev returns all the token values
     *   @param _hostContract address of the NFT owner
     *   @param id toekn id
     */
    function getOwners(uint256 id, address _hostContract)
        external
        view
        returns (address[] memory)
    {
        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );

        return hostContract.getOwner(id);
    }

    /**
     *   @dev returns all the token values
     *   @param _hostContract address of the NFT owner
     *   @param useraddress address of the user
     */
    function getTokens(address useraddress, address _hostContract)
        external
        view
        returns (uint256[] memory)
    {
        OperonOriginsNFTUpgradeable hostContract = OperonOriginsNFTUpgradeable(
            _hostContract
        );

        return hostContract.getids(useraddress);
    }

    /**
     *   @dev changes the existing maintainer
     *   @param _newMaintainer new proposed maintainer
     */
    function changeMaintainer(address _newMaintainer) external onlyMaintainer {
        address previousMaintainer = maintainer;
        maintainer = _newMaintainer;
        emit MaintainerChanged(previousMaintainer, maintainer);
    }

    /**
     *   @dev changes update the fees
     *   @param fees new fees
     */
    function changeFees(uint256 fees) external onlyMaintainer {
        serviceValue = fees;
    }

    function getFees() external view returns (uint256) {
        return serviceValue;
    }

    /**
     *   @dev changes the existing maintainer
     *   @param _newAddress new token contract address
     */
    function changeTokenAddress(address _newAddress) external onlyMaintainer {
        require(
            _newAddress == address(_newAddress),
            "Error: provided address is invalid"
        );

        OROOfficialContractAddress = _newAddress;
    }
}