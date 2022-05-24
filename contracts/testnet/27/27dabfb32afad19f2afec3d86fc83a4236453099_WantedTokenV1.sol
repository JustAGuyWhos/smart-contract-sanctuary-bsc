// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./WantedStorageV1.sol";

contract WantedTokenV1 is ERC20Upgradeable, WantedStorageV1 {

    function initialize() initializer public {
        __ERC20_init("WANTED", "WNTD");
        __Ownable_init();
        _mint(msg.sender, (1000000000 * (10 ** decimals())));   

        tokenPrice = 20000000000000000;
        saleStatus = true;

        intervalTime = [600, 1200];
        counterArray = [1, 2];
    }

    /**@dev This function sets all the Tokenomics.
      *@param _burnPercent the array containing taxes for buy, transfer, sell.
      *@param _liqPercent the array containing taxes for buy, transfer, sell.
      *@param _marketPercent the array containing taxes for buy, transfer, sell.
      *@param _nftSweepstakePercent the array containing taxes for buy, transfer, sell.
      *@param _sustainPercent the array containing taxes for buy, transfer, sell.
      *@param _tokenSweepstakePercent the array containing taxes for buy, transfer, sell.
      */
    function setToknomics(
        uint256[] calldata _burnPercent, 
        uint256[] calldata _liqPercent, 
        uint256[] calldata _marketPercent, 
        uint256[] calldata _nftSweepstakePercent, 
        uint256[] calldata _sustainPercent, 
        uint256[] calldata _tokenSweepstakePercent
    ) 
        external
        onlyOwner 
    {
        for(uint256 i = 0; i < 3; i++) {
            Tokenomics storage data = TokenomicDetails[i+1];
            data.burnPercent = _burnPercent[i];
            data.liqPercent = _liqPercent[i];
            data.marketPercent = _marketPercent[i];
            data.nftSweepstakePercent = _nftSweepstakePercent[i];
            data.sustainPercent = _sustainPercent[i];
            data.tokenSweepstakePercent = _tokenSweepstakePercent[i];
        }
    }

    /**@dev updates the sale status and token price.
      *@param _price Price of one Wanted Token in BNB(wei).
      *@param _status Status of the sale.
      */
    function updateSaleStatusAndPrice(uint256 _price, bool _status) 
        external 
        onlyOwner 
    {
        tokenPrice = _price;
        saleStatus = _status;
        emit UpdatedSaleStatusAndPrice(_status, _price);
    }

    /**@dev Updates the wallet address of LMS, NFT, and Token.
      *@param _lmsWallet Wallet address for holding Liquidity, Marketing & Sustainability charges.
      *@param _nftSweepstakeWallet Wallet address for holding NFT charges.
      *@param _tokenSweepstakeWallet Wallet address for holding Token charges.
      */
    function updateWallets(
        address _lmsWallet, 
        address _nftSweepstakeWallet, 
        address _tokenSweepstakeWallet
    ) 
        external 
        onlyOwner 
    {
        LMSWallet = _lmsWallet;
        nftSweepstakeWallet = _nftSweepstakeWallet;
        tokenSweepstakeWallet = _tokenSweepstakeWallet;

        emit WalletsUpdated(LMSWallet, nftSweepstakeWallet, tokenSweepstakeWallet);
    }

    /**@dev Buy Wanted Tokens.
      *@notice For Buying Wanted Tokens send BNB Coins
      */
    function buyToken() payable external nonReentrant  {
        require(saleStatus, "WantedTokenV1: sale is closed");
        require(!AddressUpgradeable.isContract(owner()), "WantedTokenV3: Invalid merchant wallet address");

        uint256 amount = ((10**decimals()) * msg.value) / tokenPrice;
        amount = _taxDeduction(amount,owner(), 1);

        _vesting(amount);

        payable(owner()).transfer(msg.value);
        
    }

    /**@dev Withdraw vested Tokens.
      *@notice User can withdraw releasable vested tokens.
      */
    function withdraw() external {

        uint256 releaseAmount = 0;

        for(uint256 i = 0; i < userInvestingIds[msg.sender].length; i++){
           releaseAmount +=  _withdraw(userInvestingIds[msg.sender][i]);
        }

        require(releaseAmount > 0, 'WantedTokenV1: release Amount is zero');

        _transfer(address(this), msg.sender, releaseAmount);
           
        emit WithdrawFromVesting(msg.sender, releaseAmount);

    }

    /**@dev To counter deduction of tax after selling of tokens on Pancakeswap.
      *@param _address this are address which Pancakeswap(router, factory) uses.
      */
    function addPairAddress(address[] calldata _address)
        external
        onlyOwner
    {
        for(uint256 i = 0; i < _address.length; i++) {
            pairAddress[_address[i]] = true;
        }
    }

    /**@dev Reward Distribution to Winners of Lottery/Sweepstake.
      *@param addressess Array containing winners wallet addresses.
      *@param SweepstakeType For token it is 1 and for NFT it is 2.
      */
    function rewardsDistribution(
        address[] calldata addressess, 
        uint8 SweepstakeType
    ) 
        external
        onlyOwner 
    {
        // if(SweepstakeType == 1) {
        //     //require(tSweepstakeCallDeadline < block.timestamp,"ERROR : CAN BE CALLED WEEKLY");
        //     tSweepstakeCallDeadline += 7 days;
        // }else if(SweepstakeType == 2) {
        //     //require(nSweepstakeCallDeadline < block.timestamp, "ERROR : CAN BE CALLED DAILY");
        //     nSweepstakeCallDeadline += 1 days;
        // }

        address[] memory tempAddresses = new address[](addressess.length);

        if(SweepstakeType == 1) {
            if(tokenRewardAmount !=0) {
                _transfer(tokenSweepstakeWallet,LMSWallet,tokenRewardAmount);
            }
            tokenRewardAmount = balanceOf(tokenSweepstakeWallet);
            tokenRewardPerUser = tokenRewardAmount / addressess.length;
        }else if(SweepstakeType == 2) {
            if(nftRewardAmount != 0) {
                _transfer(nftSweepstakeWallet,LMSWallet,nftRewardAmount);
            }
            nftRewardAmount = balanceOf(nftSweepstakeWallet);
            nftRewardPerUser = nftRewardAmount / addressess.length;
        }
        
        for(uint256 i = 0; i < addressess.length; i++) {
            
            RewardData storage data = rewardData[addressess[i]];

            if(SweepstakeType == 1) {
                data.tokenSweepstakeAmount = tokenRewardPerUser;
                data.tokenSweepstakeTimestamp = block.timestamp + 7 days;    
            }else if(SweepstakeType == 2) {
                data.nftSweepstakeAmount = nftRewardPerUser;
                data.nftSweepstakeTimestamp = block.timestamp + 1 days;
            }

            tempAddresses[i] = addressess[i];
        }
        if(SweepstakeType == 1){
            emit RewardReceived(tempAddresses, tokenRewardPerUser, SweepstakeType);
        }else {
            emit RewardReceived(tempAddresses, nftRewardPerUser, SweepstakeType);
        }

    }    

    /**@dev For claiming the winninng amount in Sweepstake Lottery.
      *@param SweepstakeType For token it is 1 and for NFT it is 2.
      */
    function claimReward(uint8 SweepstakeType) external {
        
        RewardData storage data = rewardData[msg.sender];

        if(SweepstakeType == 1) {
            require(data.tokenSweepstakeTimestamp > block.timestamp,"ERROR : Reward Expired OR You haven't Won the Sweepstake ");
            
            data.tokenSweepstakeAmount = 0;
            data.tokenSweepstakeTimestamp = block.timestamp;
            tokenRewardAmount -= tokenRewardPerUser;

            _transfer(tokenSweepstakeWallet, msg.sender, tokenRewardPerUser);

            emit Claimed(msg.sender, tokenRewardPerUser, SweepstakeType);
        }
        else if(SweepstakeType == 2) {
            require(data.nftSweepstakeTimestamp > block.timestamp,"ERROR : Reward Expired OR You haven't Won the Sweepstake ");
            
            data.nftSweepstakeAmount = 0;
            data.nftSweepstakeTimestamp = block.timestamp;
            nftRewardAmount -= nftRewardPerUser;
            
            _transfer(nftSweepstakeWallet, msg.sender, nftRewardPerUser);

            emit Claimed(msg.sender, nftRewardPerUser, SweepstakeType);
        }

    }

    /**@dev Shows the details of vesting of tokens.
      *@param investId Id which is stored in mapping with all details.
      *@return recipient Wallet address of recipient.
      *@return deposit Total Amount vested with this ID.
      *@return startTime 
      *@return stopTime
      *@return remainingBalance
      *@return ratePerSection
      *@return releaseAmount
      */
    function viewVestingDetails(uint256 investId)
        public
        view
        returns (
            address recipient,
            uint256 deposit,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance,
            uint256 ratePerSection,
            uint256 releaseAmount
        )
    {
        recipient = invests[investId].recipient;
        deposit = invests[investId].deposit;
        startTime = invests[investId].startTime;
        stopTime = invests[investId].stopTime;
        remainingBalance = invests[investId].remainingBalance;
        ratePerSection = invests[investId].ratePerSection;

        uint256 percent = invests[investId].ratePerSection;
        uint256 duration = block.timestamp - invests[investId].startTime;

        uint256 amount;

        if(block.timestamp >= invests[investId].stopTime) {  // current time is passed the stop time        
            releaseAmount = invests[investId].remainingBalance;
        }else {
            for(uint256 i = 0; i < 2; i++) {
                if(intervalTime[i] <= duration && intervalTime[i+1] >= duration) {     
                    uint256 counter = counterArray[i];
                    counter = counter - invests[investId].releaseCounter;
                    amount = percent * counter;
                }  
            }
            releaseAmount = amount;
        } 
        
    }

    /**@dev Shows All Tokens user have.
      *@param _user User Wallet address.
      *@return TotalLockAmount Total locked tokens of the user.
      *@return TotalClaimedBalance Total claimed tokens.
      *@return TotalUnclaimedBalance total unclaimed tokens.*/
    function userTotalAmount(address _user) 
        external 
        view 
        returns (
            uint256 TotalLockAmount, 
            uint256 TotalClaimedBalance, 
            uint256 TotalUnclaimedBalance
        )
    {
        // uint256 releaseAmt = 0;
        // uint256 remainAmt = 0;
        // uint256 claimAmt = 0;
        for(uint i = 0; i < userInvestingIds[_user].length; i++) {
            uint256 Id = userInvestingIds[_user][i];
            (
                address recipient,
                uint256 deposit,
                uint256 startTime,
                uint256 stopTime,
                uint256 remainingBalance,
                uint256 ratePerSection,
                uint256 releaseAmount
            ) = viewVestingDetails(Id);
            if(releaseAmount != 0) {
                TotalUnclaimedBalance += releaseAmount;
            }
            if((remainingBalance - TotalUnclaimedBalance) != 0) {
                TotalLockAmount += (remainingBalance - TotalUnclaimedBalance);
            }
            if((invests[Id].releaseCounter * ratePerSection) != 0) {
                TotalClaimedBalance += (invests[Id].releaseCounter * ratePerSection);
            }  
        }
        // TotalUnclaimedBalance = releaseAmt;
        // TotalLockAmount = remainAmt;
        // TotalClaimedBalance = claimAmt;

        return (
            TotalLockAmount, 
            TotalClaimedBalance, 
            TotalUnclaimedBalance
        );
    }

    /// Transfer tax and Sell Tax Section
    /**@dev It is mainly used for selling of Tokens.
      *@param from Token Holder Address.
      *@param to Recipient Address.
      *@param amount No of tokens(in 10**6). 
      *@return bool.
      */
    function transferFrom(
        address from,
        address to,
        uint256 amount 
    ) 
        public 
        virtual 
        override 
        returns (bool) 
    {
        address spender = _msgSender();  
        //tempAmount = amount;  

        _spendAllowance(from, spender, amount);

        if(pairAddress[to] == true) {
            amount = _taxDeduction(amount, from, 3);
        }else {
            amount = _taxDeduction(amount, from, 2);
        }   

        _transfer(from, to, amount);

        return true;
    }

    /**@dev Transfers tokens from one account to other.
      *@param to Recipient Address.
      *@param amount No of tokens(in 10**6). 
      *@return bool.
      */
    function transfer(address to, uint256 amount) 
        public 
        virtual 
        override 
        returns (bool) 
    {
        address from = _msgSender();
        //tempAmount = amount;

        if(pairAddress[from] == true){
            amount = _taxDeduction(amount, from, 1);
        }else{
            amount = _taxDeduction(amount, from, 2);
        }
        _transfer(from, to, amount);
        return true;
    }

    function _feeCalculation(uint256 _percent, uint256 _amount) 
        private 
        pure 
        returns (uint256 fees)
    {
        fees = (_percent * _amount) / 100;
    }

    function decimals() public view virtual override returns (uint8) {
      
        return 6;
    }  

    function _vesting(uint256 amount) private returns (bool) {
        
        uint256 _amount = _feeCalculation(20, amount);
        
        _transfer(owner(), msg.sender, _amount);
        amount -= _amount;
        _transfer(owner(), address(this), (amount));
        
        vestingCounter += 1;

        userInvestingIds[msg.sender].push(vestingCounter);

        require(amount % 2 == 0 && amount > 0, "WantedTokenV1: deposit cannot be proportionally divided");

        uint256 ratePerSection = amount / 2;  // release tokens per section. 
        invests[vestingCounter] = Vesting({
            Id: vestingCounter,
            remainingBalance: amount,
            deposit: amount,
            ratePerSection: ratePerSection,
            recipient: msg.sender,
            startTime: block.timestamp,
            stopTime: block.timestamp + intervalTime[1],
            releaseCounter: 0
        });

        emit CreateVesting(vestingCounter, msg.sender, amount, block.timestamp, invests[vestingCounter].stopTime);

        return true;
    }

    function _withdraw(uint256 investId) private returns(uint256) {

        uint256 percent = invests[investId].ratePerSection;
        uint256 duration = block.timestamp - invests[investId].startTime;

        uint256 releaseAmount = 0;

        if(invests[investId].remainingBalance == 0) {
            return 0;
        }

        if(block.timestamp >= invests[investId].stopTime) {  // current time is passed the stop time
                
            releaseAmount = invests[investId].remainingBalance;
            invests[investId].remainingBalance = 0;
            invests[investId].releaseCounter = 2;
            
            return releaseAmount;
        }
            
        for(uint256 i = 0; i < 2; i++){
            // checks the interval of time and releases amount accordingly
            if(intervalTime[i] <= duration && intervalTime[i+1] >= duration) {
                    
                uint256 counter = counterArray[i];
                counter = counter - invests[investId].releaseCounter;
                releaseAmount = percent * counter;

                invests[investId].remainingBalance = invests[investId].remainingBalance - releaseAmount;
                invests[investId].releaseCounter = invests[investId].releaseCounter + counter;

                return releaseAmount;
            }
        }

        return releaseAmount;
    }   

    function _taxDeduction(uint256 amount, address from, uint8 transactionType) internal returns(uint256){
        
        Tokenomics storage data = TokenomicDetails[transactionType];

        uint256 tempAmount = amount;

        uint256 percent = data.liqPercent + data.marketPercent + data.sustainPercent;

        uint256 _amount = _feeCalculation(percent, tempAmount);
        _transfer(from, LMSWallet, _amount);
        amount -= _amount;

        if(data.burnPercent != 0){
            _amount = _feeCalculation(data.burnPercent, tempAmount);
            _burn(from, _amount);
            amount -= _amount;
        }

        if(data.nftSweepstakePercent != 0){
            _amount = _feeCalculation(data.nftSweepstakePercent, tempAmount);
            _transfer(from, nftSweepstakeWallet, _amount);
            amount -= _amount;
        }

        if(data.tokenSweepstakePercent != 0){
            _amount = _feeCalculation(data.tokenSweepstakePercent, tempAmount);
            _transfer(from, tokenSweepstakeWallet, _amount);
            amount -= _amount;
        }

        return amount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
abstract contract WantedStorageV1 is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    struct Tokenomics {
        uint256 liqPercent;
        uint256 burnPercent;
        uint256 marketPercent;
        uint256 sustainPercent;
        uint256 nftSweepstakePercent;
        uint256 tokenSweepstakePercent;
    }

    mapping(uint256 => Tokenomics) public TokenomicDetails;

    struct RewardData{
        uint256 tokenSweepstakeAmount;
        uint256 nftSweepstakeAmount;
        uint256 tokenSweepstakeTimestamp;
        uint256 nftSweepstakeTimestamp;
    }

    mapping(address => RewardData) public rewardData;

     struct Vesting {
        uint256 Id;
        uint256 deposit;
        uint256 releaseCounter;
        uint256 ratePerSection;
        uint256 remainingBalance;
        uint256 startTime;
        uint256 stopTime;
        address recipient;
    }

    uint256 public vestingCounter;

    mapping(address => uint256[]) public userInvestingIds;
   
    mapping(uint256 => Vesting) internal invests;
    // for testing 5 min interval in seconds
    uint256[] intervalTime;

    uint256[] counterArray;

    mapping(address => bool) public pairAddress;
    
    uint256 public tokenPrice;

    bool public saleStatus;

    address public LMSWallet;

    address public nftSweepstakeWallet;

    address public tokenSweepstakeWallet; 

    uint256 internal tSweepstakeCallDeadline;

    uint256 internal nSweepstakeCallDeadline;

    uint256 internal tokenRewardAmount;

    uint256 internal tokenRewardPerUser;

    uint256 internal nftRewardAmount;

    uint256 internal nftRewardPerUser;

    // events
    event UpdatedSaleStatusAndPrice(bool Salestatus, uint256 Tokenprice);
    event WalletsUpdated(
        address indexed LMSWallet,
        address indexed nftSweepstakeWallet,
        address indexed tokenSweepstakeWallet);
    event CreateVesting(
        uint256 indexed investId,
        address indexed recipient,
        uint256 deposit,
        uint256 startTime,
        uint256 stopTime
    );

    event WithdrawFromVesting( 
        address indexed recipient, 
        uint256 amount
    );

    event Claimed(address owner, uint256 amount, uint8 SweepstakeType);

    event RewardReceived(address[] addresses, uint256 amount, uint SweepstakeType);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}