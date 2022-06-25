/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

pragma solidity ^0.8.0;

interface IBEP20 {
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/* @dev Contract module which provides a basic access control mechanism, where
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.0;

    contract FantomPadStaking is Ownable {
        IBEP20  public token;
        uint public projectIds;
        uint public totalStaking;
        uint public totalDepositTokens;
        uint public totalRewardsGiven;

        mapping(address=>bool) public isBlocked;

        struct stakeInfo {
            uint stakeAmount;
            uint stakeTime;
            uint id;
        }

        mapping (address => uint) public rewardStored;
        mapping (address => bool) public whiteListProjectOwner;
        mapping (address => mapping (string => uint)) public projectList;
        mapping (address => bool) public allowOnce;
        mapping (address => stakeInfo[]) public userStakeInformation;
        mapping(address => uint256) public StakesPerUser;
        mapping (address => uint) public stakeTime;
        event unstakeFPAD (address _user, uint _amount);
        event rewards(address _user, uint _amount);
        event Stake(address _sender, address _recipient,uint _amount,uint id);

         modifier onlyWhitelisted (address _user) {
            require (whiteListProjectOwner[_user],'!Whitelisted');
            _;
        }

        modifier onlyOnce (address _user) {
            require (!allowOnce[_user],'Already Created');
            _;
        }


        function setToken(address _address) external onlyOwner{
            token = IBEP20(_address);
        }


        // Staking Part
        function stakeTokens(uint _amount) external {
            stakeInfo memory stake;
            stake.stakeTime = block.timestamp;
            stake.stakeAmount = _amount;
            totalStaking +=_amount;
            StakesPerUser[msg.sender] += 1;
            stake.id = StakesPerUser[msg.sender];
            userStakeInformation[msg.sender].push(stake);
            token.transferFrom(msg.sender,address(this), _amount);
            emit Stake(msg.sender, address(this),_amount,stake.id);
        }

        function stakeLength(address _user) external view returns(uint){
            return userStakeInformation[_user].length;
        }

        function withdrawRewards (uint poolId) public {
            require(!isBlocked[msg.sender],"User Blocked");
            uint totalRewards = getReward(msg.sender, poolId);
            rewardStored[msg.sender] = 0;
            totalRewardsGiven+=totalRewards;
            token.transfer (msg.sender, totalRewards);
            emit rewards(msg.sender,totalRewards);
        }

        function withdrawStakedTokens(uint poolId) external {
             require(!isBlocked[msg.sender],"User Blocked");
             uint _amount = (userStakeInformation[msg.sender][poolId].stakeAmount) ;
             withdrawRewards(poolId);
             totalStaking-=_amount;
            token.transfer (msg.sender, _amount);
            delete userStakeInformation[msg.sender][poolId];
            emit unstakeFPAD(msg.sender, _amount);
            
        }

        function getReward(address _user, uint _poolId) public view returns (uint) {
            uint amount;
            uint depositedAmount = userStakeInformation[_user][_poolId].stakeAmount;
            amount += depositedAmount * 1 * 30;
            amount = amount / 100;
            amount = amount /365;
            uint totalDays = (block.timestamp - userStakeInformation[_user][_poolId].stakeTime)/ 1 minutes;
            uint finalAmount = rewardStored[_user]+amount * totalDays;
            return finalAmount;
        }
        function withDrawFunds(address _tokenAddress, uint amount, bool inBNB) external onlyOwner {
            if (!inBNB) {
                token = IBEP20(_tokenAddress);
                require(token.balanceOf(address(this))>0,'!Balance');
                token.transfer(owner(), amount);
            }
            else {
                require (address(this).balance> 0,'!Balance');
                payable (owner()).transfer(address(this).balance);
            }
        }

        function totalContractBalance()  public view returns(uint){
           return token.balanceOf(address(this));
        }

        function depositTokens(uint256  amount) external onlyOwner{
            totalDepositTokens+=amount;
            token.transferFrom(msg.sender, address(this),amount);
        }

        function tokensLeft() external view returns(uint){
            return (totalDepositTokens-totalRewardsGiven);
        }

        function blockUser(address _address,bool _bool) external onlyOwner{
         isBlocked[_address]=_bool;
        }

    }