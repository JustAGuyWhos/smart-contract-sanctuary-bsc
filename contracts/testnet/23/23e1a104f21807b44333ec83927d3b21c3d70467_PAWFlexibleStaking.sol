/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier:UNLICENSE
pragma solidity ^0.8.17;


contract PAWFlexibleStaking{
    //Variable and other Declarations
    address public PAW;
    uint256 public TotalDeposits;
    uint256 public RewardMultiplier;
    address public Operator;
    bool public RewardsPaused = false;

    //Add Total Staked (for projections)

    mapping(address => uint256) public Deposits;
    mapping(address => uint256) public LastUpdateUnix;

    //Events
    event Deposited(uint256 NewBalance, address user);
    event Withdrawn(uint256 NewBalance, address user);
    event Claimed(uint256 Amount, address user);
    event ReInvested(uint256 NewBalance, address user);


    constructor(){ // APY is 0.1% to 1, so 1% is 10, 10% is 100, etc...
        PAW = 0x3C751A60a871283495A33f5EBc75cB3A606b8338;
        RewardMultiplier = 110 * 792744; // DEFAULT APY IS 11.0%
        Operator = msg.sender;
    }


    //Public Functions
    function Deposit(uint256 amount) public returns(bool success){  
        require(amount >= 1000000000000000000, "The minimum deposit for staking is 1 PAW");
        require(ERC20(PAW).balanceOf(msg.sender) >= amount, "You do not have enough PAW to stake this amount");
        require(ERC20(PAW).allowance(msg.sender, address(this)) >= amount, "You have not given the staking contract enough allowance");

        if(Deposits[msg.sender] > 0 && RewardsPaused == false){
            ReInvest();
        }

        Update(msg.sender);
        ERC20(PAW).transferFrom(msg.sender, address(this), amount);
        TotalDeposits = TotalDeposits + amount;
        Deposits[msg.sender] = (Deposits[msg.sender] + amount);

        emit Deposited(Deposits[msg.sender], msg.sender);
        return(success);
    }

    function Withdraw(uint256 amount) public returns(bool success){
        require(Deposits[msg.sender] >= amount);
        
        if((ERC20(PAW).balanceOf(address(this)) - (GetUnclaimed(msg.sender))) >= TotalDeposits && RewardsPaused == false){
            Claim();
        }

        Deposits[msg.sender] = Deposits[msg.sender] - amount;
        TotalDeposits = TotalDeposits - amount;
        ERC20(PAW).transfer(msg.sender, amount);
        
        emit Withdrawn(Deposits[msg.sender], msg.sender);
        return(success);
    }

    function ReInvest() public returns(bool success){
        require(RewardsPaused == false);
        require(GetUnclaimed(msg.sender) > 0);
        
        uint256 Unclaimed = GetUnclaimed(msg.sender);
        require((ERC20(PAW).balanceOf(address(this)) - Unclaimed) >= TotalDeposits, "The contract does not have enough PAW to pay profits at the moment"); //This exists as protection in the case that the contract has not been refilled with PAW in time
        Update(msg.sender);

        Deposits[msg.sender] = Deposits[msg.sender] + Unclaimed;
        TotalDeposits = TotalDeposits + Unclaimed;
        
        emit ReInvested(Deposits[msg.sender], msg.sender);
        return(success);
    }


    function Claim() public returns(bool success){
        require(RewardsPaused == false);
        uint256 Unclaimed = GetUnclaimed(msg.sender);
        require(Unclaimed > 0);

        require((ERC20(PAW).balanceOf(address(this)) - Unclaimed) >= TotalDeposits, "The contract does not have enough PAW to pay profits at the moment"); //This exists as protection in the case that the contract has not been refilled with PAW in time
        Update(msg.sender);

        ERC20(PAW).transfer(msg.sender, Unclaimed);
        
        emit Claimed(Unclaimed, msg.sender);
        return(success);
    }

    //OwnerOnly Functions

    function ChangeMultiplier(uint256 NewAPY) public returns(bool success){
        require(msg.sender == Operator);

        RewardMultiplier = NewAPY * 792744;

        return(success);
    }

    function RemoveRewardPool() public returns(bool success){
        require(msg.sender == Operator);

        ERC20(PAW).transfer(msg.sender, (ERC20(PAW).balanceOf(address(this)) - TotalDeposits));

        return(success);
    }

    function PauseRewards() public returns(bool success){
        require(msg.sender == Operator);

        RewardsPaused = true;

        return(success);
    }

    function UnpauseRewards() public returns(bool success){
        require(msg.sender == Operator);

        RewardsPaused = false;

        return(success);
    }

    //Internal Functions
    function Update(address user) internal{
        LastUpdateUnix[user] = block.timestamp;
    }


    //Functional view functions

    function GetUnclaimed(address user) public view returns(uint256){
        uint256 Time = (block.timestamp - LastUpdateUnix[user]);
        uint256 Unclaimed;

        Unclaimed = (((RewardMultiplier * Time) * Deposits[user]) / 1000000000000000); //7927448 per %

        return(Unclaimed);
    }

    //Informatical view functions
}

interface ERC20 {
  function balanceOf(address owner) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint value) external returns (bool);
  function Mint(address _MintTo, uint256 _MintAmount) external;
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool); 
  function totalSupply() external view returns (uint);
}