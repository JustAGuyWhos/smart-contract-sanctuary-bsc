/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// File: contracts/helpers/Context.sol


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
// File: contracts/helpers/Ownable.sol


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
// File: contracts/interfaces/IERC20.sol


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
// File: contracts/interfaces/ICRDIT.sol


// ATSUSHI MANDAI CRDIT Contracts

pragma solidity ^0.8.0;


/**
 * @dev Interface of the CRDIT
 */
interface ICRDIT is IERC20 {

    /**
     * @dev Returns the current tax rate.
     */
    function tax() external view returns(uint8);

    /**
     * @dev Returns the mintAddLimit.
     */
    function mintAddLimit() external view returns(uint8);

    /**
     * @dev Returns the sum of mint limits.
     */
    function mintLimitSum() external view returns(uint);

    /**
     * @dev Returns the mint limit of an address.
     */
    function mintLimitOf(address _address) external view returns(uint);

    /**
     * @dev Returns whether an address is an issuer or not.
     */
    function isIssuer(address _address) external view returns(bool);

    /**
     * @dev Returns whether an address is in the blacklist or not.
     */
    function blackList(address _address) external view returns(bool);

    /**
     * @dev Returns the amount after deducting tax.
     */
    function checkTax(uint _amount) external view returns(uint);

    /**
     * @dev Changes the tax rate of CRDIT.
     */
    function changeTax(uint8 _newTax) external returns(bool);

    /**
     * @dev Changes the mintAddLimit.
     */
    function changeMintAddLimit(uint8 _newLimit) external returns(bool);

    /**
     * @dev Changes the mint limit of an address.
     */
    function changeMintLimit(address _address, uint _amount) external returns(bool);

    /**
     * @dev Changes the mint limit of an address.
     */
    function changeBlackList(address _address, bool _bool) external returns(bool);

    /**
     * @dev Lets an issuer mint new CRDIT within its limit.
     */
    function issuerMint(address _to, uint256 _amount) external returns(bool);

    /**
     * @dev Lets an issuer burn CRDIT to recover its limit.
     */
    function issuerBurn(uint256 _amount) external returns(bool);

    /**
     * @dev Burns CRDIT.
     */
    function burn(uint256 amount) external;

    /**
     * @dev Burns CRDIT from its owner.
     */
    function burnFrom(address account, uint256 amount) external;

    /**
     * @dev Returns the cap of the token.
     */
    function cap() external view returns (uint256);
}
// File: contracts/CRDITFaucet.sol


// ATSUSHI MANDAI CRDIT Faucet Contracts

pragma solidity ^0.8.0;



/// @title CRDIT Faucet
/// @author Atsushi Mandai
/// @notice A simple faucet contract for CRDIT.
contract CRDITFaucet is Ownable {

    event MintedCRDIT(uint256 amount);

    /**
     * @dev Address of CRDIT.
     */
    address public CRDITAddress = 0x9Ef046a7AF1B2e456D7b619da2e469BaBA018193;

    /**
     * @dev Amount of CREDIT this faucet gives to a user.
     */
    uint256 public faucetAmount = 95 * (10**18);

    /**
     * @dev Amount of CREDIT this faucet gives to an agent.
     */
    uint256 public agentRewards = 5 * (10**18);

    /**
     * @dev Holds the next mint available time.
     */
    mapping(address => uint256) public addressToTime;

    /**
     * @dev Let the contract owner change the address of CRDIT.
     */ 
    function changeCRDITAddress(address _address) public onlyOwner returns(bool) {
        CRDITAddress = _address;
        return true;
    }

    /**
     * @dev Let the contract owner change the faucetAmount.
     */ 
    function changeFaucetAmount(uint256 _amount) public onlyOwner returns(bool) {
        faucetAmount = _amount;
        return true;
    }

    /**
     * @dev Let the contract owner change the agentRewards.
     */ 
    function changeAgentRewards(uint256 _amount) public onlyOwner returns(bool) {
        agentRewards = _amount;
        return true;
    }

    /**
     * @dev Returns whether a user is available to mint CRDIT or not.
     */ 
    function checkMintReady(address _address) public view returns(bool) {
        if(block.timestamp > addressToTime[_address]) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Adds 1 day to addressToTime[_msgSender()], then mints fixed amount of CRDIT for _msgSender().
     */
    function mintFixedCRDIT(address _agent) public returns(uint256) {
        require(block.timestamp > addressToTime[_msgSender()], "24 hours have not passed since the last mint");
        ICRDIT crdit = ICRDIT(CRDITAddress);
        require(crdit.mintLimitOf(address(this)) > faucetAmount + agentRewards, "This contract has reached its mint limit");
        addressToTime[_msgSender()] = block.timestamp + 1 days;
        bool minted = crdit.issuerMint(_msgSender(), faucetAmount);
        crdit.issuerMint(_agent, agentRewards);
        if (minted == true) {
            emit MintedCRDIT(faucetAmount);
            return faucetAmount;
        } else {
            emit MintedCRDIT(0);
            return 0;
        }
    }

    /**
     * @dev Adds 1 day to addressToTime[_msgSender()], then mints random amount of CRDIT for _msgSender().
     */
    function mintRandomCRDIT(address _agent) public returns(uint256) {
        require(block.timestamp > addressToTime[_msgSender()], "24 hours have not passed since the last mint");
        ICRDIT crdit = ICRDIT(CRDITAddress);
        require(crdit.mintLimitOf(address(this)) > (faucetAmount * 120 / 100) + agentRewards, "This contract has reached its mint limit");
        addressToTime[_msgSender()] = block.timestamp + 1 days;
        uint256 rand = uint256(keccak256(abi.encodePacked(_msgSender(), block.number, crdit.totalSupply()))) % 3;
        uint256 value = faucetAmount;
        bool minted;
        if (rand == 1) {
            value = faucetAmount * 80 / 100;
            minted = crdit.issuerMint(_msgSender(), value);
        } else if (rand == 2) {
            minted = crdit.issuerMint(_msgSender(), value);
        } else {
            value = faucetAmount * 120 / 100;
            minted = crdit.issuerMint(_msgSender(), value);
        }
        crdit.issuerMint(_agent, agentRewards);
        if (minted = true) {
            emit MintedCRDIT(value);
            return value;
        } else {
            emit MintedCRDIT(0);
            return 0;
        }
    }
}