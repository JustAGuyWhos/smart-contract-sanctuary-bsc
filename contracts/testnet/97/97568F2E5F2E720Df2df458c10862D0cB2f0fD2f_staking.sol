// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC20.sol";
import "./Ownable.sol";
import"./SafeMath.sol";

contract staking is Ownable {
    using SafeMath for uint256;

    address private devWallet;

    address private treasury;

    uint256 private divider=10000;

    uint256 public depoiteTax=500;

    uint256 public withdrawTax=1000;

    uint256 public rewardTax=1500;

    bool public hasStart=true;

    uint256 public totalInveted;

    uint256 [] percentage=[110,330,500];

    IERC20 token=IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    struct depoite{
        uint256 amount;
        uint256 depositeTime;
    }

    struct user {
        depoite[] deposites;
        address refferAddress;
        uint256 totalRewardWithdraw;
    }

    mapping (address=>user) public investor;

	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardWithdraw(address indexed user,uint256 amount);

    constructor() Ownable(msg.sender){
        devWallet=0xC8934823c0a96e9b0170098D975902d22E22f84c;
        treasury=0xC8934823c0a96e9b0170098D975902d22E22f84c;
    }
    function toggleSale(bool _sale) public  onlyOwner{
        hasStart=_sale;
    }

    function setWallet( address _treasury, address _devWallet) public  onlyOwner{
        treasury=_treasury;
        devWallet=_devWallet;
    }

    function setTax(uint256 _depoiteTax,uint256 _withdrawTax,uint256 _rewardTax) public  onlyOwner{
        depoiteTax=_depoiteTax;
        withdrawTax=_withdrawTax;
        rewardTax=_rewardTax;
    }

    function invest(uint256 amount,address reffer) public  {
        require(hasStart,"Sale is not satrted yet");
        require(amount<=token.allowance(msg.sender, address(this)),"Insufficient Allowence to the contract");

        uint256 tax=amount.mul(depoiteTax).div(divider);
        token.transferFrom(msg.sender, treasury, tax);
        token.transferFrom(msg.sender, address(this), amount.sub(tax));

        user storage users =investor[msg.sender];
        if(reffer==address(0) || reffer==msg.sender){
            users.refferAddress=owner();   
        }else{
            users.refferAddress=reffer;
        }

        users.deposites.push(depoite(amount, block.timestamp));
        totalInveted=totalInveted.add(amount);

        emit NewDeposit(msg.sender, amount);
    }
    
    function withdrawTokens()public {
        require(hasStart,"Sale is not Started yet");
        uint256 totalDeposite=getUserTotalDeposite(msg.sender);
        require(totalDeposite>0,"No Deposite Found");
        require(totalDeposite>=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider);
        token.transfer(treasury, tax);
        token.transfer(msg.sender, totalDeposite.sub(tax));
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            investor[msg.sender].deposites[i].amount=0;
        }
        emit Withdrawn(msg.sender, totalDeposite);

    }

    function withdrawReward()public {
        require(hasStart,"Sale is not Started yet");
        uint256 totalRewards=calclulateReward(msg.sender);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards>=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 tax=totalRewards.mul(rewardTax).div(divider);
        token.transfer(devWallet, tax);
        token.transfer(msg.sender, totalRewards.sub(tax));
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            investor[msg.sender].deposites[i].depositeTime=block.timestamp;
        }
        investor[msg.sender].totalRewardWithdraw+=totalRewards;
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    function calclulateReward(address _user) public view returns(uint256 totalReward){
        uint256 depositeAmount;
        uint256 currenctTime=block.timestamp;
        user storage users=investor[_user];
        for(uint256 i=0;i<users.deposites.length;i++){
            depositeAmount=users.deposites[i].amount;
            uint256 time=currenctTime.sub(users.deposites[i].depositeTime);
            if(time<=20 days){
                totalReward+=depositeAmount.mul(percentage[0]).div(divider).mul(time).div(1 days);
            }else if(time>=21 days && time<=40 days){
                totalReward+=depositeAmount.mul(percentage[1]).div(divider).mul(time).div(1 days);
            }else if(time>=41 days){
                totalReward+=depositeAmount.mul(percentage[2]).div(divider).mul(time).div(1 days);
            }
        }
    }

    function abcd(address _user) public view returns(uint256 totalReward){
        
    }
    function getUserTotalDeposite(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            _totalInvestment=_totalInvestment.add(investor[_user].deposites[i].amount);
        }
    }

    function getUserTotalRewardWithdraw(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdraw;
    }

    function getContractBUSDBalacne() public view returns(uint256 totalBUSD){
        totalBUSD=token.balanceOf(address(this));
    }

    function getContractBNBBalacne() public view returns(uint256 totalBNB){
        totalBNB=address(this).balance;
    }

     
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./context.sol";
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
    constructor(address newOwner) {
        _setOwner(newOwner);
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}