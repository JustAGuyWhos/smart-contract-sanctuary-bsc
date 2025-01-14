// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract StakingPro is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeMath for uint8;



    struct Stake{
        uint deposit_amount;        //Deposited Amount
        uint stake_creation_time;   //The time when the stake was created
        bool returned;              //Specifies if the funds were withdrawed
        uint alreadyWithdrawedAmount;   //TODO Correct Lint
    }


    struct Account{
        address referral;
        uint referralAlreadyWithdrawed;
    }


    //---------------------------------------------------------------------
    //-------------------------- EVENTS -----------------------------------
    //---------------------------------------------------------------------


    /**
    *   @dev Emitted when the pot value changes
     */
    event PotUpdated(
        uint newPot
    );


    /**
    *   @dev Emitted when a customer tries to withdraw an amount
    *       of token greater than the one in the pot
     */
    event PotExhausted(

    );


    /**
    *   @dev Emitted when a new stake is issued
     */
    event NewStake(
        uint stakeAmount,
        address from
    );

    /**
    *   @dev Emitted when a new stake is withdrawed
     */
    event StakeWithdraw(
        uint stakeID,
        uint amount
    );

    /**
    *   @dev Emitted when a referral reward is sent
     */
    event referralRewardSent(
        address account,
        uint reward
    );

    event rewardWithdrawed(
        address account
    );


    /**
    *   @dev Emitted when the machine is stopped (500.000 tokens)
     */
    event machineStopped(
    );

    /**
    *   @dev Emitted when the subscription is stopped (400.000 tokens)
     */
    event subscriptionStopped(
    );



    //--------------------------------------------------------------------
    //-------------------------- GLOBALS -----------------------------------
    //--------------------------------------------------------------------

    mapping (address => Stake[]) private stake; /// @dev Map that contains account's stakes

    address private tokenAddress;

    ERC20 private ERC20Interface;

    uint private pot;    //The pot where token are taken

    uint256 private amount_supplied;    //Store the remaining token to be supplied

    uint private pauseTime;     //Time when the machine paused
    uint private stopTime;      //Time when the machine stopped




    // @dev Mapping the referrals
    mapping (address => address[]) private referral;    //Store account that used the referral

    mapping (address => Account) private account_referral;  //Store the setted account referral


    address[] private activeAccounts;   //Store both staker and referer address


    uint256 private constant _DECIMALS = 18;

    uint256 private constant _INTEREST_PERIOD = 1 days;    //One Month
    uint256 private constant _INTEREST_VALUE = 333;    //0.333% per day

    uint256 private constant _PENALTY_VALUE = 20;    //20% of the total stake



    uint256 private constant _MIN_STAKE_AMOUNT = 100 * (10**_DECIMALS);

    uint256 private constant _MAX_STAKE_AMOUNT = 100000 * (10**_DECIMALS);

    uint private constant _REFERALL_REWARD = 333; //0.333% per day

    uint256 private constant _MAX_TOKEN_SUPPLY_LIMIT =     50000000 * (10**_DECIMALS);
    uint256 private constant _MIDTERM_TOKEN_SUPPLY_LIMIT = 40000000 * (10**_DECIMALS);


    constructor() public {
        pot = 0;
        amount_supplied = _MAX_TOKEN_SUPPLY_LIMIT;    //The total amount of token released
        tokenAddress = address(0);
    }

    //--------------------------------------------------------------------
    //-------------------------- TOKEN ADDRESS -----------------------------------
    //--------------------------------------------------------------------


    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(Address.isContract(_tokenAddress), "The address does not point to a contract");

        tokenAddress = _tokenAddress;
        ERC20Interface = ERC20(tokenAddress);
    }

    function isTokenSet() external view returns (bool) {
        if(tokenAddress == address(0))
            return false;
        return true;
    }

    function getTokenAddress() external view returns (address){
        return tokenAddress;
    }

    //--------------------------------------------------------------------
    //-------------------------- ONLY OWNER -----------------------------------
    //--------------------------------------------------------------------


    function depositPot(uint _amount) external onlyOwner nonReentrant {
        require(tokenAddress != address(0), "The Token Contract is not specified");

        pot = pot.add(_amount);

        if(ERC20Interface.transferFrom(msg.sender, address(this), _amount)){
            //Emit the event to update the UI
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }

    }


    function returnPot(uint _amount) external onlyOwner nonReentrant{
        require(tokenAddress != address(0), "The Token Contract is not specified");
        require(pot.sub(_amount) >= 0, "Not enough token");

        pot = pot.sub(_amount);

        if(ERC20Interface.transfer(msg.sender, _amount)){
            //Emit the event to update the UI
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }

    }


    function finalShutdown() external onlyOwner nonReentrant{

        uint machineAmount = getMachineBalance();

        if(!ERC20Interface.transfer(owner(), machineAmount)){
            revert("Unable to transfer funds");
        }
        //Goodbye
    }

    function getAllAccount() external onlyOwner view returns (address[] memory){
        return activeAccounts;
    }

    /**
    *   @dev Check if the pot has enough balance to satisfy the potential withdraw
     */
    function getPotentialWithdrawAmount() external onlyOwner view returns (uint){
        uint accountNumber = activeAccounts.length;

        uint potentialAmount = 0;

        for(uint i = 0; i<accountNumber; i++){

            address currentAccount = activeAccounts[i];

            potentialAmount = potentialAmount.add(calculateTotalRewardReferral(currentAccount));    //Referral

            potentialAmount = potentialAmount.add(calculateTotalRewardToWithdraw(currentAccount));  //Normal Reward
        }

        return potentialAmount;
    }


    //--------------------------------------------------------------------
    //-------------------------- CLIENTS -----------------------------------
    //--------------------------------------------------------------------

    /**
    *   @dev Stake token verifying all the contraint
    *   @notice Stake tokens
    *   @param _amount Amoun to stake
    *   @param _referralAddress Address of the referer; 0x000...1 if no referer is provided
     */
    function stakeToken(uint _amount, address _referralAddress) external nonReentrant {

        require(tokenAddress != address(0), "No contract set");

        require(_amount >= _MIN_STAKE_AMOUNT, "You must stake at least 100 tokens");
        require(_amount <= _MAX_STAKE_AMOUNT, "You must stake at maximum 100000 tokens");

        require(!isSubscriptionEnded(), "Subscription ended");

        address staker = msg.sender;
        Stake memory newStake;

        newStake.deposit_amount = _amount;
        newStake.returned = false;
        newStake.stake_creation_time = block.timestamp;
        newStake.alreadyWithdrawedAmount = 0;

        stake[staker].push(newStake);

        if(!hasReferral()){
            setReferral(_referralAddress);
        }

        activeAccounts.push(msg.sender);

        if(ERC20Interface.transferFrom(msg.sender, address(this), _amount)){
            emit NewStake(_amount, _referralAddress);
        }else{
            revert("Unable to transfer funds");
        }


    }

    /**
    *   @dev Return the staked tokens, requiring that the stake was
    *        not alreay withdrawed
    *   @notice Return staked token
    *   @param _stakeID The ID of the stake to be returned
     */
    function returnTokens(uint _stakeID) external nonReentrant returns (bool){
        Stake memory selectedStake = stake[msg.sender][_stakeID];

        //Check if the stake were already withdraw
        require(selectedStake.returned == false, "Stake were already returned");

        uint deposited_amount = selectedStake.deposit_amount;
        //Get the net reward
        uint penalty = calculatePenalty(deposited_amount);

        //Sum the net reward to the total reward to withdraw
        uint total_amount = deposited_amount.sub(penalty);


        //Update the supplied amount considering also the penalty
        uint supplied = deposited_amount.sub(total_amount);
        require(updateSuppliedToken(supplied), "Limit reached");

        //Add the penalty to the pot
        pot = pot.add(penalty);


        //Only set the withdraw flag in order to disable further withdraw
        stake[msg.sender][_stakeID].returned = true;

        if(ERC20Interface.transfer(msg.sender, total_amount)){
            emit StakeWithdraw(_stakeID, total_amount);
        }else{
            revert("Unable to transfer funds");
        }


        return true;
    }


    function withdrawReward(uint _stakeID) external nonReentrant returns (bool){
        Stake memory _stake = stake[msg.sender][_stakeID];

        uint rewardToWithdraw = calculateRewardToWithdraw(_stakeID);

        require(updateSuppliedToken(rewardToWithdraw), "Supplied limit reached");

        if(rewardToWithdraw > pot){
            revert("Pot exhausted");
        }

        pot = pot.sub(rewardToWithdraw);

        stake[msg.sender][_stakeID].alreadyWithdrawedAmount = _stake.alreadyWithdrawedAmount.add(rewardToWithdraw);

        if(ERC20Interface.transfer(msg.sender, rewardToWithdraw)){
            emit rewardWithdrawed(msg.sender);
        }else{
            revert("Unable to transfer funds");
        }

        return true;
    }


    function withdrawReferralReward() external nonReentrant returns (bool){
        uint referralCount = referral[msg.sender].length;

        uint totalAmount = 0;

        for(uint i = 0; i<referralCount; i++){
            address currentAccount = referral[msg.sender][i];
            uint currentReward = calculateRewardReferral(currentAccount);

            totalAmount = totalAmount.add(currentReward);

            //Update the alreadyWithdrawed status
            account_referral[currentAccount].referralAlreadyWithdrawed = account_referral[currentAccount].referralAlreadyWithdrawed.add(currentReward);
        }

        require(updateSuppliedToken(totalAmount), "Machine limit reached");

        //require(withdrawFromPot(totalAmount), "Pot exhausted");

        if(totalAmount > pot){
            revert("Pot exhausted");
        }

        pot = pot.sub(totalAmount);


        if(ERC20Interface.transfer(msg.sender, totalAmount)){
            emit referralRewardSent(msg.sender, totalAmount);
        }else{
            revert("Unable to transfer funds");
        }


        return true;
    }

    /**
    *   @dev Check if the provided amount is available in the pot
    *   If yes, it will update the pot value and return true
    *   Otherwise it will emit a PotExhausted event and return false
     */
    function withdrawFromPot(uint _amount) public nonReentrant returns (bool){

        if(_amount > pot){
            emit PotExhausted();
            return false;
        }

        //Update the pot value

        pot = pot.sub(_amount);
        return true;

    }


    //--------------------------------------------------------------------
    //-------------------------- VIEWS -----------------------------------
    //--------------------------------------------------------------------

    /**
    * @dev Return the amount of token in the provided caller's stake
    * @param _stakeID The ID of the stake of the caller
     */
    function getCurrentStakeAmount(uint _stakeID) external view returns (uint256)  {
        require(tokenAddress != address(0), "No contract set");

        return stake[msg.sender][_stakeID].deposit_amount;
    }

    /**
    * @dev Return sum of all the caller's stake amount
    * @return Amount of stake
     */
    function getTotalStakeAmount() external view returns (uint256) {
        require(tokenAddress != address(0), "No contract set");

        Stake[] memory currentStake = stake[msg.sender];
        uint nummberOfStake = stake[msg.sender].length;
        uint totalStake = 0;
        uint tmp;
        for (uint i = 0; i<nummberOfStake; i++){
            tmp = currentStake[i].deposit_amount;
            totalStake = totalStake.add(tmp);
        }

        return totalStake;
    }

    /**
    *   @dev Return all the available stake info
    *   @notice Return stake info
    *   @param _stakeID ID of the stake which info is returned
    *
    *   @return 1) Amount Deposited
    *   @return 2) Bool value that tells if the stake was withdrawed
    *   @return 3) Stake creation time (Unix timestamp)
    *   @return 4) The eventual referAccountess != address(0), "No contract set");
    *   @return 5) The current amount
    *   @return 6) The penalty of withdraw
    */
    function getStakeInfo(uint _stakeID) external view returns(uint, bool, uint, address, uint, uint){

        Stake memory selectedStake = stake[msg.sender][_stakeID];

        uint amountToWithdraw = calculateRewardToWithdraw(_stakeID);

        uint penalty = calculatePenalty(selectedStake.deposit_amount);

        address myReferral = getMyReferral();

        return (
            selectedStake.deposit_amount,
            selectedStake.returned,
            selectedStake.stake_creation_time,
            myReferral,
            amountToWithdraw,
            penalty
        );
    }


    /**
    *  @dev Get the current pot value
    *  @return The amount of token in the current pot
     */
    function getCurrentPot() external view returns (uint){
        return pot;
    }

    /**
    * @dev Get the number of active stake of the caller
    * @return Number of active stake
     */
    function getStakeCount() external view returns (uint){
        return stake[msg.sender].length;
    }


    function getActiveStakeCount() external view returns(uint){
        uint stakeCount = stake[msg.sender].length;

        uint count = 0;

        for(uint i = 0; i<stakeCount; i++){
            if(!stake[msg.sender][i].returned){
                count = count + 1;
            }
        }
        return count;
    }


    function getReferralCount() external view returns (uint) {
        return referral[msg.sender].length;
    }

    function getAccountReferral() external view returns (address[] memory){
        referral[msg.sender];
    }

    function getAlreadyWithdrawedAmount(uint _stakeID) external view returns (uint){
        return stake[msg.sender][_stakeID].alreadyWithdrawedAmount;
    }


    //--------------------------------------------------------------------
    //-------------------------- REFERRALS -----------------------------------
    //--------------------------------------------------------------------


    function hasReferral() public view returns (bool){

        Account memory myAccount = account_referral[msg.sender];

        if(myAccount.referral == address(0) || myAccount.referral == address(0x0000000000000000000000000000000000000001)){
            //If I have no referral...
            assert(myAccount.referralAlreadyWithdrawed == 0);
            return false;
        }

        return true;
    }


    function getMyReferral() public view returns (address){
        Account memory myAccount = account_referral[msg.sender];

        return myAccount.referral;
    }


    function setReferral(address referer) internal {
        require(referer != address(0), "Invalid address");
        require(!hasReferral(), "Referral already setted");

        if(referer == address(0x0000000000000000000000000000000000000001)){
            return;   //This means no referer
        }

        if(referer == msg.sender){
            revert("Referral is the same as the sender, forbidden");
        }

        referral[referer].push(msg.sender);

        Account memory account;

        account.referral = referer;
        account.referralAlreadyWithdrawed = 0;

        account_referral[msg.sender] = account;

        activeAccounts.push(referer);    //Add to the list of active account for pot calculation
    }


    function getCurrentReferrals() external view returns (address[] memory){
        return referral[msg.sender];
    }


    /**
    *   @dev Calculate the current referral reward of the specified customer
    *   @return The amount of referral reward related to the given customer
     */
    function calculateRewardReferral(address customer) public view returns (uint){

        uint lowestStake;
        uint lowStakeID;
        (lowestStake, lowStakeID) = getLowestStake(customer);

        if(lowestStake == 0 && lowStakeID == 0){
            return 0;
        }

        uint periods = calculateAccountStakePeriods(customer, lowStakeID);

        uint currentReward = lowestStake.mul(_REFERALL_REWARD).mul(periods).div(100000);

        uint alreadyWithdrawed = account_referral[customer].referralAlreadyWithdrawed;


        if(currentReward <= alreadyWithdrawed){
            return 0;   //Already withdrawed all the in the past
        }


        uint availableReward = currentReward.sub(alreadyWithdrawed);

        return availableReward;
    }


    function calculateTotalRewardReferral() external view returns (uint){

        uint referralCount = referral[msg.sender].length;

        uint totalAmount = 0;

        for(uint i = 0; i<referralCount; i++){
            totalAmount = totalAmount.add(calculateRewardReferral(referral[msg.sender][i]));
        }

        return totalAmount;
    }

    function calculateTotalRewardReferral(address _account) public view returns (uint){

        uint referralCount = referral[_account].length;

        uint totalAmount = 0;

        for(uint i = 0; i<referralCount; i++){
            totalAmount = totalAmount.add(calculateRewardReferral(referral[_account][i]));
        }

        return totalAmount;
    }

    /**
     * @dev Returns the lowest stake info of the current account
     * @param customer Customer where the lowest stake is returned
     * @return uint The stake amount
     * @return uint The stake ID
     */
    function getLowestStake(address customer) public view returns (uint, uint){
        uint stakeNumber = stake[customer].length;
        uint min = _MAX_STAKE_AMOUNT;
        uint minID = 0;
        bool foundFlag = false;

        for(uint i = 0; i<stakeNumber; i++){
            if(stake[customer][i].deposit_amount <= min){
                if(stake[customer][i].returned){
                    continue;
                }
                min = stake[customer][i].deposit_amount;
                minID = i;
                foundFlag = true;
            }
        }


        if(!foundFlag){
            return (0, 0);
        }else{
            return (min, minID);
        }

    }



    //--------------------------------------------------------------------
    //-------------------------- INTERNAL -----------------------------------
    //--------------------------------------------------------------------

    /**
     * @dev Calculate the customer reward based on the provided stake
     * param uint _stakeID The stake where the reward should be calculated
     * @return The reward value
     */
    function calculateRewardToWithdraw(uint _stakeID) public view returns (uint){
        Stake memory _stake = stake[msg.sender][_stakeID];

        uint amount_staked = _stake.deposit_amount;
        uint already_withdrawed = _stake.alreadyWithdrawedAmount;

        uint periods = calculatePeriods(_stakeID);  //Periods for interest calculation

        uint interest = amount_staked.mul(_INTEREST_VALUE);

        uint total_interest = interest.mul(periods).div(100000);

        uint reward = total_interest.sub(already_withdrawed); //Subtract the already withdrawed amount

        return reward;
    }

    function calculateRewardToWithdraw(address _account, uint _stakeID) internal view onlyOwner returns (uint){
        Stake memory _stake = stake[_account][_stakeID];

        uint amount_staked = _stake.deposit_amount;
        uint already_withdrawed = _stake.alreadyWithdrawedAmount;

        uint periods = calculateAccountStakePeriods(_account, _stakeID);  //Periods for interest calculation

        uint interest = amount_staked.mul(_INTEREST_VALUE);

        uint total_interest = interest.mul(periods).div(100000);

        uint reward = total_interest.sub(already_withdrawed); //Subtract the already withdrawed amount

        return reward;
    }

    function calculateTotalRewardToWithdraw(address _account) internal view onlyOwner returns (uint){
        Stake[] memory accountStakes = stake[_account];

        uint stakeNumber = accountStakes.length;
        uint amount = 0;

        for( uint i = 0; i<stakeNumber; i++){
            amount = amount.add(calculateRewardToWithdraw(_account, i));
        }

        return amount;
    }

    function calculateCompoundInterest(uint _stakeID) external view returns (uint256){

        Stake memory _stake = stake[msg.sender][_stakeID];

        uint256 periods = calculatePeriods(_stakeID);
        uint256 amount_staked = _stake.deposit_amount;

        uint256 excepted_amount = amount_staked;

        //Calculate reward
        for(uint i = 0; i < periods; i++){

            uint256 period_interest;

            period_interest = excepted_amount.mul(_INTEREST_VALUE).div(100);

            excepted_amount = excepted_amount.add(period_interest);
        }

        assert(excepted_amount >= amount_staked);

        return excepted_amount;
    }

    function calculatePeriods(uint _stakeID) public view returns (uint){
        Stake memory _stake = stake[msg.sender][_stakeID];


        uint creation_time = _stake.stake_creation_time;
        uint current_time = block.timestamp;

        uint total_period = current_time.sub(creation_time);

        uint periods = total_period.div(_INTEREST_PERIOD);

        return periods;
    }

    function calculateAccountStakePeriods(address _account, uint _stakeID) public view returns (uint){
        Stake memory _stake = stake[_account][_stakeID];


        uint creation_time = _stake.stake_creation_time;
        uint current_time = block.timestamp;

        uint total_period = current_time.sub(creation_time);

        uint periods = total_period.div(_INTEREST_PERIOD);

        return periods;
    }

    function calculatePenalty(uint _amountStaked) private pure returns (uint){
        uint tmp_penalty = _amountStaked.mul(_PENALTY_VALUE);   //Take the 10 percent
        return tmp_penalty.div(100);
    }

    function updateSuppliedToken(uint _amount) internal returns (bool){
        
        if(_amount > amount_supplied){
            return false;
        }
        
        amount_supplied = amount_supplied.sub(_amount);
        return true;
    }

    function checkPotBalance(uint _amount) internal view returns (bool){
        if(pot >= _amount){
            return true;
        }
        return false;
    }



    function getMachineBalance() internal view returns (uint){
        return ERC20Interface.balanceOf(address(this));
    }

    function getMachineState() external view returns (uint){
        return amount_supplied;
    }

    function isSubscriptionEnded() public view returns (bool){
        if(amount_supplied >= _MAX_TOKEN_SUPPLY_LIMIT - _MIDTERM_TOKEN_SUPPLY_LIMIT){
            return false;
        }else{
            return true;
        }
    }

    function isMachineStopped() public view returns (bool){
        if(amount_supplied > 0){
            return true;
        }else{
            return false;
        }
    }

    //--------------------------------------------------------------
    //------------------------ DEBUG -------------------------------
    //--------------------------------------------------------------

    function getOwner() external view returns (address){
        return owner();
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

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
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
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