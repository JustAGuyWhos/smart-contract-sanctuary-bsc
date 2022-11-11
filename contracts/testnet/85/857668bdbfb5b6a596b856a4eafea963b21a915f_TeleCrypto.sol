/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// File: @pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol



pragma solidity >=0.4.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/XR_05.sol


pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TeleCrypto {
    IBEP20 public busd;
    address public owner;
    uint256 bal;
    uint256[] public luckynumbers;

    event BuyTickets(address _from, uint256[] _luckyNumbers);

    constructor() {
        busd = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        owner = msg.sender;
    }

    receive() external payable {}

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Approvetokens(uint256 _tokenamount) public returns (bool) {
        busd.approve(address(this), _tokenamount);
        return true;
    }

    function GetAllowance() public view returns (uint256) {
        return busd.allowance(address(this), msg.sender);
    }

    function GetUserTokenBalance() public view returns (uint256) {
        return busd.balanceOf(msg.sender);
    }

    function GetOwner() public view returns (address) {
        return owner;
    }

    function GetContractAddress() public view returns (address) {
        return address(this);
    }

    function ShowTicket() public view returns (uint256[] memory) {
        return luckynumbers;
    }

    function BuyTicket(uint256[] memory _luckyNumbers) public payable {
        for (uint256 i = 0; i < _luckyNumbers.length; ++i) {
            luckynumbers.push(_luckyNumbers[i]);
        }

        emit BuyTickets(msg.sender, _luckyNumbers);
    }

    function Deposit(uint256 _tokenamount) public payable {
        busd = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        busd.transferFrom(msg.sender, address(this), _tokenamount);
        bal += msg.value;
    }

    function Withdraw(address _busd, uint256 _amount) external payable {
        require(msg.sender == owner, "Only owner can withdraw!");
        IBEP20(_busd);
        busd.transfer(msg.sender, _amount);
    }
}