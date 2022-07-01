/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-29
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
contract LuckyWallet{
    function depositForAddress(uint256 amount,address to) public {}
    }

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
    function allowance(address _owner, address spender)
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

contract LuckyStaking {
    mapping (address=>uint256) stake;
    mapping (address=>uint256) lastClaimed;
    mapping (address=>uint256) blockSinceDeposit;
    
    
    
    
    uint256[] depositHistory;
    uint256[] removeStakeHistory;
    uint256[] claimDividendsHistory;
    uint256[] reinvestDividendsHistory;
    
    address[] reinvestDividendsHistoryAddress;
    address[] depositHistoryAddress;
    address[] removeStakeHistoryAddress;
    address[] claimDividendsHistoryAddress;
    
    uint256[] reinvestDividendsHistoryTS;
    uint256[] depositHistoryTS;
    uint256[] removeStakeHistoryTS;
    uint256[] claimDividendsHistoryTS;    
    
    uint256 totalDeposits;
    uint256 stakers;
    uint256 waitBlocks=100;
    uint256 divideByDays=10;
    
    uint256 depositFee=0;
    uint256 withdrawalFee=0;   
    uint256 dividendFee=2;
    uint256 ownerFee=2;
    
    address public CNRContract = 0xb0800b08B109aC82D04dC82c25eECfC654Fc6662;
    address public owner=0x020Ea6F53B4301A782DC8F658e35694cDda4d721;
    address public luckywallet=0x1f2bE551629Eeb2f4Fc5FA47a308321CF79cF032;
    IBEP20 public CNR = IBEP20(CNRContract);

    LuckyWallet LuckyWalletContract=LuckyWallet(0x1f2bE551629Eeb2f4Fc5FA47a308321CF79cF032);   
     // START Modify Variables
   
    function modifyOwner(address newOwner) public {
        if(msg.sender==owner){
            owner=newOwner;
        }
    }

    function modifyLuckyWallet(address newWallet) public {
        if(msg.sender==owner){
            luckywallet=newWallet;
        }
    }    
    
    function modifyWaitBlock(uint256 newWaitBlocks) public {
        if(msg.sender==owner){
            waitBlocks=newWaitBlocks;
        }
    }
    
    function modifyDivideByDays(uint256 newDays) public{
        if(msg.sender==owner){
            divideByDays=newDays;
        }
    }
    
    function modifyDepositFee(uint256 newDepositFee) public{
        if(msg.sender==owner){
            depositFee=newDepositFee;
        }
    }
    
    function modifyWithdrawalFee(uint256 newWithdrawalFee) public{
        if(msg.sender==owner){
            withdrawalFee=newWithdrawalFee;
        }
    }
    
    function modifyDividendFee(uint256 newDividendFee) public {
        if(msg.sender==owner){
            dividendFee=newDividendFee;
        }
    }
    
    function modifyOwnerFee(uint256 newOwnerFee) public {
        if(msg.sender==owner){
            ownerFee=newOwnerFee;
        }
    }
     //a END Modify Variables
    
    // START Retrieve Data
    function getShareOfPool(address user) public view returns (uint256){
            return stake[user]/(totalDeposits/10000);
    }
    
    function getEstimatedPayout(address user) public view returns (uint256){
            uint256 reward=(1*(((CNR.balanceOf(address(this))-totalDeposits)*(stake[user]/(totalDeposits/10000)))/divideByDays))/10000;
            uint256 rewardPostFees=reward-((reward/100)*(ownerFee+dividendFee));
            return rewardPostFees;
    }

    function getDaysPassed(address user) public view returns (uint256){
        return ((block.number-lastClaimed[user])/waitBlocks);

    }
    
    function blocksLeftUntilPayout(address user) public view returns (uint256){
        uint256 blocksLeft=(lastClaimed[user]+waitBlocks)-block.number;
        return blocksLeft;
    }

    function userStake(address user) public view returns (uint256){
        return stake[user];
    }
    
    function totalStakers() public view returns (uint256){
        return stakers;
    }
    

    function currentClaimableDividends (address user) public view returns (uint256){
            uint256 daysPassed=((block.number-lastClaimed[user])/waitBlocks);
            uint256 reward=(daysPassed*(((CNR.balanceOf(address(this))-totalDeposits)*(stake[user]/(totalDeposits/10000)))/divideByDays))/10000;
            if(reward>(CNR.balanceOf(address(this))-totalDeposits)){
                reward=((((CNR.balanceOf(address(this))-totalDeposits)*(stake[msg.sender]/(totalDeposits/10000)))/divideByDays))/10000;
            }            
            uint256 rewardPostFees=reward-((reward/100)*(ownerFee+dividendFee));
            return rewardPostFees;
    }
    function smartContractBalance() public view returns (uint256){
        return CNR.balanceOf(address(this));
    }
    function totalDividends() public view returns (uint256){
        uint256 totaldividends=(CNR.balanceOf(address(this))-totalDeposits);
        return totaldividends;
    }
    function dailyDividendsAvailable() public view returns (uint256){
        uint256 dailydivs=(CNR.balanceOf(address(this))-totalDeposits)/divideByDays;
        return dailydivs;

    }
    function totalStakedInEscrow() public view returns (uint256){
        return totalDeposits;
    }
    
    // END Retrieve Data
    
    
    // START Activity History
    function sendDepositHistory() public view returns (uint256[] memory){
        return depositHistory;
    }
    function sendDepositHistoryTS() public view returns (uint256[] memory){
        return depositHistoryTS;
    }    
    function sendDepositHistoryAddress() public view returns (address[] memory){
        return depositHistoryAddress;
    }    
    
    function sendWithdrawalHistory() public view returns (uint256[] memory){
        return removeStakeHistory;
    }
    
    function sendWithdrawalHistoryAddress() public view returns (address[] memory){
        return removeStakeHistoryAddress;
    } 
    
    function sendWithdrawalHistoryTS() public view returns (uint256[] memory){
        return removeStakeHistoryTS;
    }    
    
    function sendClaimDividendsHistory() public view returns (uint256[] memory){
        return claimDividendsHistory;
    }
    function sendClaimDividendsHistoryAddress() public view returns (address[] memory){
        return claimDividendsHistoryAddress;
    }
    function sendClaimDividendsHistoryTS() public view returns (uint256[] memory){
        return claimDividendsHistoryTS;
    }   
    
    function sendReinvestDividendsHistory ()public view returns (uint256[] memory){
        return reinvestDividendsHistory;
    }
    function sendReinvestDividendsHistoryAddress ()public view returns (address[] memory){
        return reinvestDividendsHistoryAddress;
    }    
    function sendReinvestDividendsHistoryTS ()public view returns (uint256[] memory){
        return reinvestDividendsHistoryTS;
    }
    // END Activity History
    
    
       // START Contract Functinality
  
    function claimDividends() public{
        if((lastClaimed[msg.sender]+waitBlocks)<block.number){
            uint256 daysPassed=((block.number-lastClaimed[msg.sender])/waitBlocks);
            uint256 reward=(daysPassed*(((CNR.balanceOf(address(this))-totalDeposits)*(stake[msg.sender]/(totalDeposits/10000)))/divideByDays))/10000;

            if(reward>(CNR.balanceOf(address(this))-totalDeposits)){
                reward=((((CNR.balanceOf(address(this))-totalDeposits)*(stake[msg.sender]/(totalDeposits/10000)))/divideByDays))/10000;
            }

            uint256 rewardPostFees=reward-((reward/100)*(ownerFee+dividendFee));
            uint256 devFee=((reward/100)*ownerFee);
            lastClaimed[msg.sender]=block.number;
            CNR.transfer(owner,devFee);
            CNR.transfer(luckywallet,rewardPostFees);
            LuckyWalletContract.depositForAddress(rewardPostFees,msg.sender);
            claimDividendsHistory.push(reward);
            claimDividendsHistoryAddress.push(msg.sender);
            claimDividendsHistoryTS.push(block.number);

        }
    }
    
    function reinvestDividends() public {
             if((lastClaimed[msg.sender]+waitBlocks)<block.number){
            uint256 daysPassed=((block.number-lastClaimed[msg.sender])/waitBlocks);
            uint256 reward=(daysPassed*(((CNR.balanceOf(address(this))-totalDeposits)*(stake[msg.sender]/(totalDeposits/10000)))/divideByDays))/10000;

            if(reward>(CNR.balanceOf(address(this))-totalDeposits)){
                reward=((((CNR.balanceOf(address(this))-totalDeposits)*(stake[msg.sender]/(totalDeposits/10000)))/divideByDays))/10000;
            }            
            totalDeposits=(totalDeposits+reward);
            stake[msg.sender]=(stake[msg.sender]+reward);
            lastClaimed[msg.sender]=block.number;
            reinvestDividendsHistory.push(reward);
            reinvestDividendsHistoryAddress.push(msg.sender);
            reinvestDividendsHistoryTS.push(block.number);
        }   
    }

    function internalDeposit (uint256 amount, address player) public {
        require(msg.sender==luckywallet,"Caller must be wallet");
        depositHistory.push(amount);
        depositHistoryAddress.push(player);
        depositHistoryTS.push(block.number);
        lastClaimed[player]=block.number;
        blockSinceDeposit[player]=block.number;
        stakers+=1;
        stake[player]+=amount;
        totalDeposits+=amount;
    }


    function deposit (uint amount) public
    {
        depositHistory.push(amount);
        depositHistoryAddress.push(msg.sender);
        depositHistoryTS.push(block.number);
        CNR.transferFrom(msg.sender,address(this),amount);
        lastClaimed[msg.sender]=block.number;
        blockSinceDeposit[msg.sender]=block.number;
        stakers+=1;
        stake[msg.sender]+=amount;
        totalDeposits+=amount;
        
    }
    
    function removeStake() public{

        
        removeStakeHistory.push(stake[msg.sender]);
        removeStakeHistoryAddress.push(msg.sender);
        removeStakeHistoryTS.push(block.number);
        uint256 divFee=((stake[msg.sender]/100)*dividendFee);
        uint256 devFee=((stake[msg.sender]/100)*ownerFee);
        uint256 amountToRemovePostFees=stake[msg.sender]-divFee-devFee;
        CNR.transfer(owner,devFee);
        CNR.transfer(luckywallet,amountToRemovePostFees);
        LuckyWalletContract.depositForAddress(amountToRemovePostFees,msg.sender);
        totalDeposits-=stake[msg.sender];
        delete stake[msg.sender];

    }

        // END Contract Functinality
   
    
    



    
}