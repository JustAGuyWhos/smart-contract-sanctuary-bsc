/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
  _______ _            ____  _   _ ____        _                     __     _ _           
 |__   __| |          |  _ \| \ | |  _ \      | |                   / _|   | (_)          
    | |  | |__   ___  | |_) |  \| | |_) |   __| |_      ____ _ _ __| |_    | |___   _____ 
    | |  | '_ \ / _ \ |  _ <| . ` |  _ <   / _` \ \ /\ / / _` | '__|  _|   | | \ \ / / _ \
    | |  | | | |  __/ | |_) | |\  | |_) | | (_| |\ V  V / (_| | |  | |    _| | |\ V /  __/
    |_|  |_| |_|\___| |____/|_| \_|____/   \__,_| \_/\_/ \__,_|_|  |_|   (_)_|_| \_/ \___|
                                                                                                
**/ 

pragma solidity ^0.8.7; // solhint-disable-line

contract TheBnbDwarf { 

    // Is the miner enabled ! 
    bool public initialized=false;

    // Constants.  
    uint256 private minBNBCentsToInvest=50;      // The lowest limit to invest = 0.5BNB
    uint256 private secondsByDay=600;            // 1Day = 600: DEV & 86400 : PRD
    uint256 private dailyROIPercent=10;          // Rewards % of sender balance on period
    uint256 private feePercent=10;               // Amount of fees
    uint256 private minClaimToAvoidSanityTax=6;  // Min claim to disable sustainability tax
    uint256 private sanityTaxAmountPercent=90;   // Sustainability tax amount 
 
    // Team addresses
    address private devAddress=0x0d8dD7B14937f9c8087B644C9ab20F3B487760A5;
    address private marketingAddress=0x9069Ac19B7657C276008139734d5Db7a0596a3C5;

    // Some usable pools 
    mapping (address => uint256) private sendersBalance;         // Pool to store senders balance
    mapping (address => uint256) private sendersInvestment;      // Pool to store senders investment amount
    mapping (address => uint256) private sendersWithdrawal;      // Store senders withdrawal amount
    mapping (address => uint256) private lastClaimDatePerSender; // Store senders last claim dates
    mapping (address => uint256) private senderCompoundCounts;   // Store senders compound count


    /**
     * Build the contract
     */
    constructor()  { 
        initialize();
    } 
 

    /**
     * Initialize the miner, let's play. 
     * 
     */
    function initialize() public { 
        initialized=true; 
    }


    /**
     * Reinvest liquid value 
     * 
     */
    function compound() public {

        require(initialized);
        require(getSenderNextClaimDate() < block.timestamp, "You need to wait before compounding."); 
    
        // Lock liquidity to sender balance. 
        sendersBalance[msg.sender]=add(getSenderBalance(), getSenderLiquidAmount());

        // The last claim date is block.timestamp. 
        resetLastClaimDate(); 
        
        // Add 1 compound to the user count 
        bumpSenderCompoundCount(); 
    }


    /**
     * Send back liquidity to the sender, collect tax for dev & marketing 
     * 
     */
    function withdraw() public {
        require(initialized);
        require(getSenderNextClaimDate() < block.timestamp, "You need to wait before withdraw.");
        
        uint256 currentAmount=getSenderLiquidAmount();

        // Sustainability tax management
        if(getSenderCompoundCount() < minClaimToAvoidSanityTax) {
            currentAmount = (currentAmount * (100 - sanityTaxAmountPercent)) / 100; 
        }

        uint256 fees=getDevFee(currentAmount);

        // Reset the last action date 
        resetLastClaimDate(); 

        // Reset the compound counter 
        resetCompoundCounter();

        // Dispatch fees
        collectFees(fees);

        // Transfer liquidity to user.  
        payable(msg.sender).transfer(sub(currentAmount, fees));
    }



    /**
     * Add coins to the miner 
     */
    function deposit() external payable {    
        require(initialized, "Not started"); 
          
        uint256 amountValue = msg.value;   
        uint256 fees = getDevFee(amountValue); 
        
        // Reset the last action date 
        resetLastClaimDate(); 
 
        // Reset the compound counter 
        resetCompoundCounter();
 
        // Dispatch fees 
        collectFees(fees);

        // Add values to balance & investments 
        sendersInvestment[msg.sender] = add(getSenderInvestment(), msg.value); 
        sendersBalance[msg.sender]=add(getSenderBalance(), sub(amountValue, fees));
    }


    /**
     * Calculate dev fee amount  
     * 
     * return int 
     */
    function getDevFee(uint256 amount) view private returns(uint256){
        return div(mul(amount, feePercent), 100); 
    }


    /**
     * Dispatch fees to the team 
     */
    function collectFees(uint256 fee) private {
        uint256 fee2=fee/2;

        payable(marketingAddress).transfer(fee2);
        payable(devAddress).transfer(fee-fee2); 
    }


    /**
     * Returns the smart contract balance 
     * 
     * @return Integer
     */
    function getBalance() public view returns(uint256){
        return payable(address(this)).balance; 
    }


    /**
     * Returns the sender balance 
     * 
     * @return Integer
     */
    function getSenderBalance() public view returns(uint256){
        return sendersBalance[msg.sender];
    }


    /**
     * Returns the sender balance 
     * 
     * @return Integer
     */
    function getMinClaimToAvoidSanityTax() public view returns(uint256){
        return minClaimToAvoidSanityTax; 
    }


    /**
     * Returns the sender next claim timestamp.
     * 
     * @return Integer
     */
    function getSenderNextClaimDate() public view returns(uint256){
        if(getSenderBalance() == 0) {
            return 0;
        }
        return lastClaimDatePerSender[msg.sender] + secondsByDay; 
    }


    /**
     * Set the sender last action date to block.timestamp. 
     * 
     */
    function resetLastClaimDate() private {
        lastClaimDatePerSender[msg.sender]=block.timestamp;
    }


    /**
     * Return the sender last claim date
     * 
     */
    function getSenderLastClaimDate() public view returns(uint256) {
        return lastClaimDatePerSender[msg.sender]; 
    }


    /**
     * Add 1 to the send compound count to allow him to avoid tax a day.
     */
    function bumpSenderCompoundCount() private {
        senderCompoundCounts[msg.sender]=senderCompoundCounts[msg.sender]+1;
    }


    /**
     * Set the sender last action date to block.timestamp. 
     * 
     */
    function resetCompoundCounter() private {
        senderCompoundCounts[msg.sender]=0;
    }


   /**
     * Set the sender last action date to block.timestamp. 
     * 
     */
    function getSenderCompoundCount() public view returns(uint256) {
        return senderCompoundCounts[msg.sender];
    }


   /**
     * Return the total value invested by the sender
     * 
     */
    function getSenderInvestment() public view returns(uint256) {
        return sendersInvestment[msg.sender];
    }

 
    /**
     * Return the current user liquid reward 
     * 
     * @return Integer  
     */
    function getSenderLiquidAmount() public view returns(uint256){
        uint256 secondsPassed=getSecondPassedFromLastClaim();
  
        if(secondsPassed > secondsByDay) {
            return getEstimatedDailyRewards(); 
        } 
     
        //10/100 = secondsByDay (100/100)
        //ratio  = ((getSenderBalance() * 10) / 100 * (secondsPassed * 1e18/secondsByDay)) / 1e18

        // Multiply & Divide by 1e18 to avoid underflow 
        return((getSenderBalance() * dailyROIPercent) / 100 * (secondsPassed * 1e18/secondsByDay)) / 1e18; 
    }


    /**
     * Return the estimated daily reward for the sender
     * 
     * 
     * @return Integer  
     */
    function getSecondPassedFromLastClaim() public view returns(uint256){
        return block.timestamp - lastClaimDatePerSender[msg.sender];
    } 


    /**
     * Return the estimated daily reward for the sender
     * 
     * 
     * @return Integer 
     */
    function getEstimatedDailyRewards() public view returns(uint256){
        return getSenderBalance() * dailyROIPercent / 100; 
    }


    /**
     * Some math Utils
     */

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }


    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }


    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}