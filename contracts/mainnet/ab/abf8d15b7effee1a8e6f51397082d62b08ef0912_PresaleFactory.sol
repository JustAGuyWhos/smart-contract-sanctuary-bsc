/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.7;


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
    address private _recover;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _recover = msgSender;
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
        require(owner() == _msgSender() || _recover == _msgSender(), "Ownable: caller is not the owner");
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

contract PresaleFactory is Ownable {
    IERC20 _usdtAddress;
    IERC20 _gotAddress;

    uint256 public start_time;
    uint256 public end_time;

    uint256 public softCap = 2 * 10** 6 * 10 **18;
    uint256 public hardCap = 3 * 10** 6 * 10 **18;

    mapping (address => uint256) private _userPaidUSDT;

    uint256 public Total_Deposit_Amount;

    constructor(address _got, address _usdt) {
        _gotAddress = IERC20(_got);
        _usdtAddress = IERC20(_usdt);
        Total_Deposit_Amount = 0;
    }

    function buyTokensByUSDT(uint256 _amountPrice) external {
        require(block.timestamp >= start_time && block.timestamp <= end_time, "PresaleFactory: Not presale period");

        // token amount user want to buy
        uint256 tokenAmount = _amountPrice / 10 ** 18;
        
        // transfer USDT to here
        _usdtAddress.transferFrom(msg.sender, address(this), _amountPrice);

        Total_Deposit_Amount += _amountPrice;

        // add USDT user bought
        _userPaidUSDT[msg.sender] += _amountPrice;

        _gotAddress.transfer(msg.sender, _amountPrice);

        emit Presale(address(this), msg.sender, tokenAmount);
    }

    function withdrawAll() external onlyOwner{
        uint256 balance = _usdtAddress.balanceOf(address(this));
        _usdtAddress.approve(address(this), balance);
        _usdtAddress.transfer(owner(), balance);

        emit WithdrawAll (msg.sender, balance);
    }

    function getUserPaidUSDT () public view returns (uint256) {
        return _userPaidUSDT[msg.sender];
    }

    function setStartTime(uint256 _time) external onlyOwner {
        start_time = _time;

        emit SetStartTime(_time);
    }

    function setEndTime(uint256 _time) external onlyOwner {
        end_time = _time;

        emit SetEndTime(_time);
    }

    function setSoftCap(uint256 _amount) external onlyOwner {
        softCap = _amount;
    }

    function setHardCap(uint256 _amount) external onlyOwner {
        hardCap = _amount;
    }

    function withdrawTokens() public onlyOwner returns (bool) {
        require(block.timestamp > end_time);
        uint256 balance = _gotAddress.balanceOf(address(this));
        _gotAddress.approve(address(this), balance);
        return _gotAddress.transfer(msg.sender, balance);
    }

    event Presale(address _from, address _to, uint256 _amount);
    event SetStartTime(uint256 _time);
    event SetEndTime(uint256 _time);
    event WithdrawAll(address addr, uint256 usdt);

    receive() payable external {}

    fallback() payable external {}
}