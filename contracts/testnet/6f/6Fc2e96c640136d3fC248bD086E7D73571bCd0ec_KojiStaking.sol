// SPDX-License-Identifier: GPL-3.0-or-later

// koji.earth Staking Contract Version 1.0
// Stake your $KOJI for the Koji Comic NFT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./KojiFlux.sol";

interface IKojiNFT {
  function mintNFT(address recipient, uint256 minttier, uint256 id, bool superMinted, bool bnbMinted) external returns (uint256);
  function getIfMinted(address _recipient, uint256 _nftID) external view returns (bool);
  function getIfSuperMinted(address _recipient, uint256 _nftID) external view returns (bool);
  function getNFTwindow(uint256 _nftID) external view returns (uint256, uint256, uint256);
  function getNFTredeemable(uint256 _nftID) external view returns (bool); 
  function getNFTInfo(uint256 _nftID) external view returns(string[] memory, uint256[] memory, bool[] memory); 
  function getBNBtier1minted(address _recipient, uint _nftID) external view returns (bool);
  function getBNBtier2minted(address _recipient, uint _nftID) external view returns (bool);
  function gettier1USDprice() external view returns (uint,uint);
  function gettier2USDprice() external view returns (uint,uint);
  function getMintTotalsAfterWindow(uint _nftID, uint _tier) external view returns (uint);
}

// Interface for the Koji Oracle
interface IOracle {
    function getMinKOJITier1Amount(uint256 amount) external view returns (uint256); 
    function getMinKOJITier2Amount(uint256 amount) external view returns (uint256); 
    function getConversionRate() external view returns (uint256);
    function getKojiUSDPrice() external view returns (uint256, uint256, uint256);
    function getSuperMintKojiPrice(uint256 _amount) external view returns (uint256);
    function getSuperMintFluxPrice(uint256 _amount) external view returns (uint256);
    function gettier1USDprice() external view returns (uint,uint);
    function gettier2USDprice() external view returns (uint,uint);
}

// Interface for the rewards pool
interface IKojiRewards {
    function payPendingRewards(address _holder, uint256 _amount) external;
}

interface IMarketOrder {
    function marketBuy(address _token, address _recipient) external payable returns (uint);
}

// Allows another user(s) to change contract settings
contract Authorizable is Ownable {

    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[_msgSender()] || owner() == address(_msgSender()), "E01");
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != address(0), "E02");
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != address(0), "E02");
        require(_toRemove != address(_msgSender()), "E03");
        authorized[_toRemove] = false;
    }

}

contract KojiStaking is Ownable, Authorizable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 usdEquiv; //USD equivalent of $Koji staked
        uint256 stakeTime; //block.timestamp of when user staked
        uint256 unstakeTime; //block.timestamp of when user unstaked
        uint256 supermintaccrualperiod; //amount of time to wait for supermint
        uint256 supermintstaketimer; //time at which supermint accrual starts
        uint tierAtStakeTime; //tier 1 or 2 when user staked
        bool blacklisted; //user is prevented from minting
        //
        // We do some fancy math here. Basically, any point in time, the amount of KOJIFLUX tokens
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accKojiPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws tokens to a pool. Here's what happens:
        //   1. The pool's `accKojiPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 stakeToken; // Address of token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. KOJIFLUX tokens to distribute per block.
        uint256 lastRewardBlock; // Last block number that KOJIFLUX tokens distribution occurs.
        uint256 accKojiPerShare; // Accumulated KOJIFLUX tokens per share, times 1e12. See below.
        uint256 runningTotal; // Total accumulation of tokens (not including reflection, pertains to pool 1 ($Koji))
    }

    KojiFlux public immutable kojiflux; // The KOJIFLUX BEP20 Token.
    uint256 private kojiPerBlock; // KOJIFLUX tokens distributed per block. Use getKojiPerBlock() to get the updated reward.

    PoolInfo[] public poolInfo; // Info of each pool.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // Info of each user that stakes LP tokens.
    address[] stakeholders;
    mapping (address => uint256) stakeholderIndexes;
    
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public startBlock; // The block number when KOJIFLUX token mining starts.

    uint256 public blockRewardUpdateCycle = 1 days; // The cycle in which the kojiPerBlock gets updated.
    uint256 public blockRewardLastUpdateTime = block.timestamp; // The timestamp when the block kojiPerBlock was last updated.
    uint256 public blocksPerDay = 28800; // The estimated number of mined blocks per day, lowered so rewards are halved to start.
    uint256 public blockRewardPercentage = 10; // The percentage used for kojiPerBlock calculation.
    uint256 public poolReward = 1000000000000000000; // Starting basis for poolReward (default 1B).
    uint256 public kojiUsdPeg = 1000; // Default peg price of KOJI/USD to base conversion/bonus numbers on (default 1000).
    uint256 public tier1kojiPeg = 2000000000000000000; // tier1 stake peg @ 1000 Gwei to calc bonus (default 2B).
    uint256 public tier2kojiPeg = 250000000000000000; // tier1 stake peg @ 1000 Gwei to calc bonus (default 250M).
    uint256 public conversionRate = 1000; // Conversion rate of KOJIFLUX => $KOJI (default 100%).
    
    uint256 public upperLimiter = 201; // Percent numerator above minKojiTier1Stake so user can deposit enough for tier 1
    
    uint256 public minKojiTier1Stake = 1000000000000; // Min stake amount (default $1000 USD of $KOJI).
    uint256 public minKojiTier2Stake = 250000000000; // Min stake amount (default $250 USD of $KOJI).
    uint256 public superMintFluxPrice1 = 50000000000; // KOJIFLUX Cost to purchase a superMint ($50 FLUX default).
    uint256 public superMintFluxPrice2 = 12500000000; // KOJIFLUX Cost to purchase a superMint ($12.50 FLUX default).
    uint256 public superMintKojiPrice = 100000000000; // KOJIFLUX Cost to purchase a superMint ($100 of KOJI default, peggd to USD).
    uint256 public superMintIncrease = 25000000000; // KOJIFLUX price increase each time a user buys a supermint with KOJI
    uint256 private taxableAmount = 1000;
    uint256 public unstakePenaltyStartingTax = 30;
    uint256 public unstakePenaltyDefaultTax = 10;
    uint256 public unstakePenaltyDenominator = 1000;

    uint256 public penaltyPeriod = 86400;  // time in seconds of unstake penalty period (24 hours).
    uint256 public supermintAccrualFrame1 = 1814400; // time in seconds to accrue 1 supermint just by staking (default 21 days).
    uint256 public supermintAccrualFrame2 = 4233600; // time in seconds to accrue 1 supermint just by staking (default 49 days).

    bool public enableKojiSuperMintBuying = true; // Whether users can purchase superMints with $KOJI (default is false).
    bool public enableFluxSuperMintBuying = true; // Whether users can purchase superMints with $KOJI (default is false).
    bool public enableTaxlessWithdrawals = false; // Switch to use in case of farming contract migration.
    bool public convertRewardsEnabled = true; // Switch to enable/disable kojiflux -> koji oracle conversion.

    mapping(address => bool) public addedstakeTokens; // Used for preventing staked tokens from being added twice in add().
    mapping(address => uint256) private userBalance; // Balance of KOJIFLUX for each user that survives staking/unstaking/redeeming.
    mapping(address => uint256) private userRealized; // Balance of KOJIFLUX for each user that survives staking/unstaking/redeeming.
    mapping(address => bool) public superMint; // Whether the wallet has a mint booster allowing require bypass.
    mapping(address => uint) public superMintCounter; // Whether the wallet has a mint booster allowing require bypass.
    mapping(address => bool) public userStaked; // Denotes whether the user is currently staked or not, must be eligible for tiers 1/2 for true.
    
    address public NFTAddress; //NFT contract address
    address public KojiFluxAddress; //KOJIFLUX contract address
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public kojiaddress;
    address public marketorder;

    IOracle public oracle;
    IERC20 kojitoken;
    IKojiRewards public rewards;
    uint kojipurchased;

    event Unstake(address indexed user, uint256 indexed pid);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event KojiBuy(uint indexed bnbamount, uint indexed kojiamount);

    constructor(
        uint256 _startBlock,
        KojiFlux _kojiflux,
        address _oracle,
        address _rewards,
        address _token,
        address _marketorder
    ) {
        require(address(_kojiflux) != address(0), "E04");

        kojiflux = _kojiflux;
        KojiFluxAddress = address(_kojiflux);

        kojiaddress = _token;
        kojitoken = IERC20(_token); //$KOJI token
        
        startBlock = _startBlock;

        authorized[_msgSender()] = true;

        oracle = IOracle(_oracle); // Oracle
        rewards = IKojiRewards(_rewards); // Rewards contract
        marketorder = address(_marketorder);

    }

   // receive() external payable {}

    modifier updateKojiPerBlock() {
        (uint256 blockReward, bool update) = getKojiPerBlock();
        if (update) {
            kojiPerBlock = blockReward;
            blockRewardLastUpdateTime = block.timestamp;
        }
        _;
    }

    function getKojiPerBlock() public view returns (uint256, bool) {
        if (block.number < startBlock) {
            return (0, false);
        }

        if (block.timestamp >= getKojiPerBlockUpdateTime() || kojiPerBlock == 0) {
            return (poolReward.mul(blockRewardPercentage).div(100).div(blocksPerDay), true);
        }

        return (kojiPerBlock, false);
    }

    function getKojiPerBlockUpdateTime() public view returns (uint256) {
        // if blockRewardUpdateCycle = 1 day then roundedUpdateTime = today's UTC midnight
        uint256 roundedUpdateTime = blockRewardLastUpdateTime - (blockRewardLastUpdateTime % blockRewardUpdateCycle);
        // if blockRewardUpdateCycle = 1 day then calculateRewardTime = tomorrow's UTC midnight
        uint256 calculateRewardTime = roundedUpdateTime + blockRewardUpdateCycle;
        return calculateRewardTime;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new token to the pool. Can only be called by the owner.
    // There are no functions in this contract for LP staking or adding secondary tokens to stake
    function add(
        uint256 _allocPoint,
        IERC20 _stakeToken,
        bool _withUpdate
    ) public onlyOwner {
        require(address(_stakeToken) != address(0), "E05");
        require(!addedstakeTokens[address(_stakeToken)], "E06");

        require(_allocPoint >= 1 && _allocPoint <= 100, "E07");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            stakeToken : _stakeToken,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accKojiPerShare : 0,
            runningTotal : 0 
        }));

        addedstakeTokens[address(_stakeToken)] = true;
    }

    // Update the given pool's KOJIFLUX token allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyAuthorized {
        require(_allocPoint >= 1 && _allocPoint <= 100, "E07");

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Update the given pool's KOJIFLUX token allocation point when pool.
    function adjustPools(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) internal {
        require(_allocPoint >= 1 && _allocPoint <= 100, "E07");

        if (_withUpdate) {
            updatePool(_pid);
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // View function to see pending KOJIFLUX tokens on frontend.
    function pendingRewards(uint256 _pid, address _user) public view returns (uint256) { 
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accKojiPerShare = pool.accKojiPerShare;
        (,uint256 bonusRate) = getConversionAmount(user.amount,_user);

        uint256 tokenSupply = kojiflux.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && tokenSupply != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);
            (uint256 blockReward, ) = getKojiPerBlock();
            uint256 kojiReward = multiplier.mul(blockReward).mul(pool.allocPoint).div(totalAllocPoint);
            accKojiPerShare = accKojiPerShare.add(kojiReward.mul(1e12).div(tokenSupply));
        }
        uint256 newamount = user.amount.mul(accKojiPerShare).div(1e12).sub(user.rewardDebt);
        
        return newamount.mul(bonusRate).div(100);
        
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public onlyAuthorized {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date when tokenSupply changes
    // For every deposit/withdraw pool recalculates accumulated token value
    function updatePool(uint256 _pid) public updateKojiPerBlock {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        //uint256 tokenSupply = pool.runningTotal; 
        uint256 tokenSupply = kojiflux.balanceOf(address(this));
        if (tokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = block.number.sub(pool.lastRewardBlock);
        uint256 kojiReward = multiplier.mul(kojiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);

        // No minting is required, the contract should have KOJIFLUX token balance pre-allocated
        // Accumulated KOJIFLUX per share is stored multiplied by 10^12 to allow small 'fractional' values
        pool.accKojiPerShare = pool.accKojiPerShare.add(kojiReward.mul(1e12).div(tokenSupply));
        pool.lastRewardBlock = block.number;
    }

    function updatePoolReward(uint256 _amount) public onlyAuthorized {
        poolReward = _amount;
    }

    // Deposit tokens/$KOJI to KojiFarming for KOJIFLUX token allocation.
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        updatePool(_pid);

        (uint256 minstake1, uint256 minstake2) = getOracleMinMax();

        if (_amount > 0) {
          
            if(user.amount == 0) { // We only want the minimum to apply on first deposit, not subsequent ones
                require(_amount >= minstake2 && _amount <= minstake1.mul(upperLimiter).div(100)  , "E42");
                user.stakeTime = block.timestamp;
                user.unstakeTime = block.timestamp;
                user.supermintstaketimer = block.timestamp;

            } else { // If user has already deposited, secure rewards before reconfiguring rewardDebt
            
                require(user.amount.add(_amount) <= minstake1.mul(upperLimiter).div(100), "E41");
                userBalance[_msgSender()] = userBalance[_msgSender()].add(pendingRewards(_pid, _msgSender()));
                user.unstakeTime = block.timestamp;

                 if (userBalance[_msgSender()] > 0) {
            
                    (userBalance[_msgSender()],) = getConversionAmount(userBalance[_msgSender()], _msgSender());
                }
            }

            pool.runningTotal = pool.runningTotal.add(_amount);
            user.amount = user.amount.add(_amount);
            pool.stakeToken.safeTransferFrom(address(_msgSender()), address(this), _amount);
            
            user.usdEquiv = getUSDequivalent(user.amount);
            user.tierAtStakeTime = getTierequivalent(user.amount);
            user.supermintaccrualperiod = getOverStakeTimeframe(user.tierAtStakeTime,user.amount);
            user.blacklisted = false;
        
            if (user.tierAtStakeTime == 1 || user.tierAtStakeTime == 2) {
                addStakeholder(_msgSender());

                if(userBalance[_msgSender()] > 0) {
                    (,uint bonusrate) = getConversionAmount(userBalance[_msgSender()], _msgSender());
                    userBalance[_msgSender()] = userBalance[_msgSender()].mul(100).div(bonusrate);
                }
                

            }

            user.rewardDebt = user.amount.mul(pool.accKojiPerShare).div(1e12);
            emit Deposit(_msgSender(), _pid, _amount);

        } else {
            require(_amount > 0, "E45");
        }
    }

    // Withdraw tokens from KojiFarming
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        uint256 userAmount = user.amount;
        require(_amount > 0, "E08");
        require(user.amount >= _amount, "E09");

        updatePool(_pid);
    
        uint256 netamount = _amount; //stack too deep
        uint bonusrate;

        userBalance[_msgSender()] = userBalance[_msgSender()].add(pendingRewards(_pid, _msgSender()));

        if (userBalance[_msgSender()] > 0) {
            
            (userBalance[_msgSender()],) = getConversionAmount(userBalance[_msgSender()], _msgSender());
             
        }

        if(!enableTaxlessWithdrawals) { // Switch for tax free / reflection free withdrawals

            netamount = getWithdrawResult(_msgSender(), _amount);
        }

        pool.runningTotal = pool.runningTotal.sub(_amount);
        user.amount = user.amount.sub(_amount);

        pool.stakeToken.safeTransfer(address(_msgSender()), netamount);
        emit Withdraw(_msgSender(), _pid, netamount);         

        if (userAmount == _amount) { // User is retrieving entire balance, set rewardDebt to zero
            user.rewardDebt = 0;
            user.unstakeTime = block.timestamp;
            user.usdEquiv = 0;
            user.tierAtStakeTime = 0;
            user.blacklisted = true;
            user.supermintstaketimer = block.timestamp;
            user.supermintaccrualperiod = 9999999999;
            removeStakeholder(_msgSender());
        } else {
            if (getTierequivalent(user.amount) == 1) {
                user.usdEquiv = getUSDequivalent(user.amount);
                user.unstakeTime = block.timestamp;
                user.tierAtStakeTime = 1;
                user.blacklisted = false;
                user.supermintaccrualperiod = getOverStakeTimeframe(user.tierAtStakeTime,user.amount);
                (,bonusrate) = getConversionAmount(userBalance[_msgSender()], _msgSender());
                userBalance[_msgSender()] = userBalance[_msgSender()].mul(100).div(bonusrate);
            } else {
                if (getTierequivalent(user.amount) == 2) {
                user.usdEquiv = getUSDequivalent(user.amount);
                user.unstakeTime = block.timestamp;
                user.tierAtStakeTime = 2;
                user.blacklisted = false;
                user.supermintaccrualperiod = getOverStakeTimeframe(user.tierAtStakeTime,user.amount);
                (,bonusrate) = getConversionAmount(userBalance[_msgSender()], _msgSender());
                userBalance[_msgSender()] = userBalance[_msgSender()].mul(100).div(bonusrate);
                } else {
                    user.usdEquiv = getUSDequivalent(user.amount);
                    user.unstakeTime = block.timestamp;
                    user.tierAtStakeTime = 0;
                    user.blacklisted = true;
                    user.supermintaccrualperiod = 9999999999;
                }
            }
            
            user.rewardDebt = user.amount.mul(pool.accKojiPerShare).div(1e12); 
        }                      
    }

    function setBlockRewardUpdateCycle(uint256 _blockRewardUpdateCycle) external onlyAuthorized {
        require(_blockRewardUpdateCycle > 0, "E10");
        blockRewardUpdateCycle = _blockRewardUpdateCycle;
    }

    // Just in case an adjustment is needed since mined blocks per day changes constantly depending on the network
    function setBlocksPerDay(uint256 _blocksPerDay) external onlyAuthorized {
        require(_blocksPerDay >= 1 && _blocksPerDay <= 28800, "E11");
        blocksPerDay = _blocksPerDay;
    }

    function setBlockRewardPercentage(uint256 _blockRewardPercentage) external onlyAuthorized {
        require(_blockRewardPercentage >= 1 && _blockRewardPercentage <= 100, "E12");
        blockRewardPercentage = _blockRewardPercentage;
    }

    // This will allow to rescue ETH sent to the contract
    /*function rescueETHFromContract() external onlyAuthorized {
        address payable _owner = payable(_msgSender());
        _owner.transfer(address(this).balance);
    }*/

    // Function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyAuthorized {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    // Returns total stake amount ($KOJI token) and address of that token respectively
    function getTotalStake(uint256 _pid, address _user) external view returns (uint256, IERC20) { 
         PoolInfo storage pool = poolInfo[_pid];
         UserInfo storage user = userInfo[_pid][_user];

        return (user.amount, pool.stakeToken);
    }

    // Gets the full ledger of deposits into each pool
    function getRunningDepositTotal(uint256 _pid) external view returns (uint256) { 
         PoolInfo storage pool = poolInfo[_pid];

        return (pool.runningTotal);
    }

    // Gets the total of all pending rewards from each pool
    function getTotalPendingRewards(address _user) public view returns (uint256) { 

        return pendingRewards(0, _user);
    }

    // Gets the total amount of rewards secured (not pending)
    function getAccruedRewards(address _user) external view returns (uint256) { 
        return userBalance[_user];
    }

    // Gets the total of pending + secured rewards
    function getTotalRewards(address _user) public view returns (uint256) { 
       
        return getTotalPendingRewards(_user).add(userBalance[_user]);
    }

    // Moves all pending rewards into the accrued array
    function redeemTotalRewards(address _user) public { 

        require(_msgSender() == _user || _msgSender() == address(this) || _msgSender() == address(rewards), "E01");

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_user];

        updatePool(0);
                
        userBalance[_user] = userBalance[_user].add(pendingRewards(0, _user));

        user.rewardDebt = user.amount.mul(pool.accKojiPerShare).div(1e12); 

    }

    // Convert KojiFlux to $KOJI
    function convertAndWithdraw(uint _percentage) external nonReentrant {
    
        UserInfo storage user = userInfo[0][_msgSender()];

        require(user.amount > 0, "E13");

        redeemTotalRewards(_msgSender());
        
        require(userBalance[_msgSender()] > 0, "E14");

        uint256 fluxamount = userBalance[_msgSender()].mul(_percentage).div(100);
        (uint256 newamount,) = getConversionAmount(fluxamount, _msgSender());

        rewards.payPendingRewards(_msgSender(), newamount);

        userRealized[_msgSender()] = userRealized[_msgSender()].add(fluxamount);
        userBalance[_msgSender()] = userBalance[_msgSender()].sub(fluxamount);
        
    }

    // Set NFT contract address
     function setNFTAddress(address _address) external onlyAuthorized {
        NFTAddress = _address;
    }

    // Set KOJIFLUX contract address
     function setKojiFluxAddress(address _address) external onlyAuthorized {
        KojiFluxAddress = _address;
    }

    // Redeem the NFT
    function redeem(uint256 _nftID, uint256 _tier) external nonReentrant {

        require(_tier > 0 && _tier < 3, "E43");

        bool[] memory bools = new bool[](4);
        
        (,,bools) = IKojiNFT(NFTAddress).getNFTInfo(_nftID);

        require(bools[3], "E44");

        // Get user tier/info
        UserInfo storage user = userInfo[0][_msgSender()];

        bool minted = IKojiNFT(NFTAddress).getIfMinted(_msgSender(), _nftID);
        (uint256 timestart,,) = IKojiNFT(NFTAddress).getNFTwindow(_nftID);
        bool redeemable = IKojiNFT(NFTAddress).getNFTredeemable(_nftID);
        require(redeemable, "E15");
        require(!minted, "E16");
        require(user.tierAtStakeTime == _tier, "E17");
        require(user.stakeTime <= timestart, "E18");
        
        IKojiNFT(NFTAddress).mintNFT(_msgSender(), _tier, _nftID, false, false);
           
    }

    // Redeem the NFT via supermint
    function supermint(uint256 _nftID) external nonReentrant {

        bool[] memory bools = new bool[](4);
        
        (,,bools) = IKojiNFT(NFTAddress).getNFTInfo(_nftID);

        require(bools[3], "E44");

        if (superMint[_msgSender()]) {

            // Get user tier/info
            UserInfo storage user = userInfo[0][_msgSender()];

            (uint256 timestart,,) = IKojiNFT(NFTAddress).getNFTwindow(_nftID);
            bool superminted = IKojiNFT(NFTAddress).getIfSuperMinted(_msgSender(), _nftID);

            require(!superminted, "E16");
            require(block.timestamp >= timestart, "E18");
            require(user.tierAtStakeTime != 0, "E20");

            superMint[_msgSender()] = false;
            IKojiNFT(NFTAddress).mintNFT(_msgSender(), 1, _nftID, true, false);
            IKojiNFT(NFTAddress).mintNFT(_msgSender(), 2, _nftID, true, false);

        } else {
            require(superMint[_msgSender()], "E21");
        }
    }

    // Purchase the NFT via BNB  
    function purchasetier(uint256 _nftID, uint256 _tier) external payable nonReentrant {
        require(_tier > 0 && _tier < 3, "E43");

        bool[] memory bools = new bool[](4);
        
        (,,bools) = IKojiNFT(NFTAddress).getNFTInfo(_nftID);

        require(bools[3], "E44");

        (uint256 timestart,,) = IKojiNFT(NFTAddress).getNFTwindow(_nftID);
        require(block.timestamp >= timestart, "E18");
        uint price;
        uint increase;

        if(_tier == 1) {
            (price, increase) = IKojiNFT(NFTAddress).gettier1USDprice();
            require(!IKojiNFT(NFTAddress).getBNBtier1minted(_msgSender(), _nftID),"E26");
        } else {
            (price, increase) = IKojiNFT(NFTAddress).gettier2USDprice();
            require(!IKojiNFT(NFTAddress).getBNBtier2minted(_msgSender(), _nftID),"E26");
        }
        
        require(price > 0, "E25");
        
        uint mintsAfterWindow = IKojiNFT(NFTAddress).getMintTotalsAfterWindow(_nftID, _tier);

        if(mintsAfterWindow > 0) {price = price.add(mintsAfterWindow.mul(increase));}

        require(msg.value >= price, "E40");
        
        uint amountpurchased = IMarketOrder(marketorder).marketBuy{value : msg.value}(kojiaddress, DEAD);

        IKojiNFT(NFTAddress).mintNFT(_msgSender(), _tier, _nftID, false, true);

        emit KojiBuy(msg.value, amountpurchased);
    }

    function setKojiFluxBalance(address _address, uint256 _amount) public {
        require(authorized[_msgSender()] || _msgSender() == address(rewards), "E01");
        userBalance[_address] = _amount;
    }

    function reduceKojiFluxBalance(address _address, uint256 _amount) public onlyAuthorized {
        userBalance[_address] = userBalance[_address].sub(_amount);
    }

    function increaseKojiFluxBalance(address _address, uint256 _amount) public onlyAuthorized {
        userBalance[_address] = userBalance[_address].add(_amount);
    }

    function getKojiFluxBalance(address _address) public view returns (uint256) {
        return userBalance[_address];
    }

    // Set the conversion rate between KOJIFLUX and the $koji token
    function setConverstionRate(uint256 _rate) public onlyAuthorized {
        conversionRate = _rate;
    }

    // Get rate of KojiFlux/$Koji conversion
    function getConversionRate() external view returns (uint256) {
        return conversionRate;
    }

    function getOracleConversionRate() public view returns (uint256) {
        (,,uint256 kojiusd) = oracle.getKojiUSDPrice();
        if(kojiusd < kojiUsdPeg || !convertRewardsEnabled) {
            return conversionRate;
        } else {
            uint256 newrate = kojiusd.mul(100).div(kojiUsdPeg); //result in 100s (div by 1000 to get decimal)
            uint256 newconversionRate = conversionRate.sub(newrate); //1000 minus 125 = 875 (87.5%)
            return newconversionRate;
        }
    }

    // Get amount of Koji for KojiFlux
    function getConversionAmount(uint256 _amount, address _address) public view returns (uint256,uint256) {

        uint256 bonusRate = 100; 
        uint256 newconversionRate = getOracleConversionRate();

        uint256 newamount = _amount.mul(newconversionRate).div(1000); //should reduce if KOJI price increases

        UserInfo storage user0 = userInfo[0][_address]; //now add bonus in for smaller stakers based on peg tier1/tier2 amount
        if (user0.tierAtStakeTime == 1) {
            if(user0.amount > tier1kojiPeg) {
                bonusRate = 200;
            }
            if(user0.amount <= tier1kojiPeg) { // user is staking below peg amount, calc bonus
                bonusRate = tier1kojiPeg.mul(150).div(user0.amount); // 2B div 1.5B = 1.3x bonus rate
            }
        } else {
            if (user0.tierAtStakeTime == 2) {
                uint256 halftier1kojiPeg = tier1kojiPeg.div(2);
                if(user0.amount >= halftier1kojiPeg) { 
                    bonusRate = tier1kojiPeg.mul(100).div(user0.amount); // 2B div 1B = 2x bonus rate
                }
                if(user0.amount >= tier2kojiPeg && user0.amount < halftier1kojiPeg) { // user is staking above tier 2 amount but still tier 2, calc bonus based on tier1
                    bonusRate = halftier1kojiPeg.mul(100).div(user0.amount); // 1B div 500M = 2x bonus rate
                }
                if(user0.amount <= tier2kojiPeg) { // user is staking below peg amount, calc bonus
                    bonusRate = tier2kojiPeg.mul(100).div(user0.amount); // 250M div 125M = 2x bonus rate
                }
            } else {
                newamount = _amount.mul(conversionRate).div(1000); //keep rewards up for stakers less than tier 2 (tier 0)
            }
        }
        
        newamount = newamount.mul(bonusRate).div(100);
            
        return (newamount,bonusRate);
    }

    // Get dollar amount of Koji for KojiFlux
    function getConversionPrice(uint256 _amount) public view returns (uint256) {
        uint256 netamount = _amount.mul(getOracleConversionRate()).div(100);
        (,,uint256 kojiusd) = oracle.getKojiUSDPrice();
        uint256 netusdamount = kojiusd.mul(netamount);

        return netusdamount;
    }

    // Get pending dollar amount of Koji for KojiFlux
    function getPendingUSDRewards(address _holder) public view returns (uint256) { 

        return getConversionPrice(getTotalRewards(_holder)).div(10**9);
    }

    // Sets min/max staking amounts for Koji token
    function setKojiStakingMinMax(uint256 _min1, uint256 _min2) external onlyAuthorized {

        require(_min2 > 0, "E27");
        require(_min1 > _min2, "E28");
        
        minKojiTier1Stake = _min1;
        minKojiTier2Stake = _min2;
    }

    // Get the min and max staking amounts 
    function getOracleMinMax() public view returns (uint256, uint256) {
        
        return (oracle.getMinKOJITier1Amount(minKojiTier1Stake), oracle.getMinKOJITier2Amount(minKojiTier2Stake)); //tier1 min, tier2 min
    }

    function getOracleMaxStaking() public view returns (uint256, uint256) {
       
        return (oracle.getMinKOJITier1Amount(minKojiTier1Stake).mul(200).div(100), oracle.getMinKOJITier2Amount(minKojiTier2Stake).mul(400).div(100)); //tier 1 max, tier 2 max
    }


    // Gets Tier equivalent of input amount of KOJI tokens
    function getTierequivalent(uint256 _amount) public view returns (uint256) {

        uint256 totalvalue = getUSDequivalent(_amount);

        if (totalvalue >= minKojiTier1Stake.sub(1000000000)) {
            return 1;
        } else {
            if (totalvalue >= minKojiTier2Stake.sub(1000000000) && totalvalue < minKojiTier1Stake.sub(1000000000)) {
                return 2;
            } else {
                return 0;
            }
        }
    }

    // Gets multiplier for supermint accrual period reduction
    function getOverStakeTimeframe(uint _usertier, uint256 _amount) internal view returns (uint256) {

        uint256 multiplier = 100;

        (uint256 tier1min, uint256 tier2min) = getOracleMinMax();

        if (_usertier == 1) {
            if(_amount >= tier1min) { multiplier = _amount.mul(100).div(tier1min);}

            if (multiplier > 150) {multiplier = 150;}

            return supermintAccrualFrame1.mul(100).div(multiplier);

        } else {
            if(_amount >= tier2min) { multiplier = _amount.mul(100).div(tier2min);}

            if (multiplier > 200) {multiplier = 200;}

            return supermintAccrualFrame2.mul(100).div(multiplier);
        }
        
    }

    // Gets multiplier for flux supermint purchases
    function getSuperMintFluxPrice(uint _usertier, uint256 _useramount) public view returns (uint256) {

        uint256 multiplier = 100;
        uint256 fluxprice;

        (uint256 tier1min, uint256 tier2min) = getOracleMinMax();

        if (_usertier == 1) {
            if(_useramount >= tier1min) { multiplier = _useramount.mul(100).div(tier1min);}

            if (multiplier > 500) {multiplier = 500;}

            fluxprice = oracle.getSuperMintFluxPrice(superMintFluxPrice1);

            return fluxprice.mul(multiplier).div(100);

        } else {
            if(_useramount >= tier2min) { multiplier = _useramount.mul(100).div(tier2min);}

            if (multiplier > 2000) {multiplier = 2000;}

            fluxprice = oracle.getSuperMintFluxPrice(superMintFluxPrice2);

            return fluxprice.mul(multiplier).div(100);
        }
        
    }

    function getSuperMintKojiPrice() external view returns(uint256) {
        return oracle.getSuperMintKojiPrice(superMintKojiPrice).add((oracle.getSuperMintKojiPrice(superMintIncrease)).mul(superMintCounter[_msgSender()]));
    }

    // Gets USD equivalent of input amount of KOJI tokens
    function getUSDequivalent(uint256 _amount) public view returns (uint256) {
        (,,uint256 kojiusdvalue) = oracle.getKojiUSDPrice();

        return kojiusdvalue.mul(_amount).div(10**9);
    }

    // Function to buy superMint internally with KojiFlux
    function buySuperMintFlux() external nonReentrant {
        UserInfo storage user = userInfo[0][_msgSender()]; 

        require(!user.blacklisted, "E29");
        require(enableFluxSuperMintBuying, "E30");
        require(!superMint[_msgSender()], "E31");
        
        (,bool supermintunlocked) = getAccrualTime(_msgSender());

        require(supermintunlocked, "E32");

        redeemTotalRewards(_msgSender());

        uint256 fluxprice = getSuperMintFluxPrice(user.tierAtStakeTime,user.amount);

        require(userBalance[_msgSender()] >= fluxprice, "E33");

        userBalance[_msgSender()] = userBalance[_msgSender()].sub(fluxprice);
        superMint[_msgSender()] = true;

        user.supermintstaketimer = block.timestamp;
    }

    // Function to buy superMint with $KOJI
    function buySuperMintKoji() external nonReentrant {
        require(enableKojiSuperMintBuying, "E34");
        uint256 kojisupermintprice = oracle.getSuperMintKojiPrice(superMintKojiPrice);
        kojisupermintprice = kojisupermintprice.add((oracle.getSuperMintKojiPrice(superMintIncrease)).mul(superMintCounter[_msgSender()]));
        require(kojitoken.balanceOf(_msgSender()) >= kojisupermintprice, "E35"); 
        require(!superMint[_msgSender()], "E31");

        IERC20(kojitoken).transferFrom(_msgSender(), address(rewards), kojisupermintprice);
        superMint[_msgSender()] = true;
        superMintCounter[_msgSender()]++;
    }

    function changeOracle(address _oracle) external onlyAuthorized {
        oracle = IOracle(_oracle);
    }

    function changeRewards(address _rewards) external onlyAuthorized {
        rewards = IKojiRewards(_rewards);
    }

    function changeUpperLimiter(uint256 _upperlimit) external onlyAuthorized {
        require(_upperlimit > 100, "E36");
        upperLimiter = _upperlimit;
    }

    function addStakeholder(address stakeholder) internal {
        if (userStaked[stakeholder]) {
            return;
        } else {
            stakeholderIndexes[stakeholder] = stakeholders.length;
            stakeholders.push(stakeholder);
            userStaked[stakeholder] = true;
        }
        
    }

    function removeStakeholder(address stakeholder) internal {
         if (!userStaked[stakeholder]) {
            return;
        } else {
        stakeholders[stakeholderIndexes[stakeholder]] = stakeholders[stakeholders.length-1];
        stakeholderIndexes[stakeholders[stakeholders.length-1]] = stakeholderIndexes[stakeholder];
        stakeholders.pop();
        userStaked[stakeholder] = false;
        }
    }

    /*function giveAllsuperMint() external onlyAuthorized {

        uint256 length = stakeholders.length;

        for (uint256 x = 0; x < length; ++x) {

             superMint[stakeholders[x]] = true;
        }

    }*/

    function getUnstakePenalty(uint256 _staketime) public view returns (uint256) {

        uint256 totaldays = block.timestamp.sub(_staketime);
        
        totaldays = totaldays.div(penaltyPeriod);

        if (totaldays >= unstakePenaltyStartingTax) {

            return unstakePenaltyDefaultTax;

        } else {

            uint256 totalunstakefee  = unstakePenaltyStartingTax.sub(totaldays);

            if (totalunstakefee <= unstakePenaltyDefaultTax) {
                return unstakePenaltyDefaultTax;
            } else {
                return totalunstakefee;
            }

        }


    }

    function setSuperMintBuying(bool _fluxbuying, bool _kojibuying) external onlyAuthorized {
        enableFluxSuperMintBuying = _fluxbuying;
        enableKojiSuperMintBuying = _kojibuying;
    }

    function setSuperMintPrices(uint256 _fluxprice1, uint256 _fluxprice2, uint256 _kojiprice, uint256 _increase) external onlyAuthorized  {
        superMintFluxPrice1 = _fluxprice1;
        superMintFluxPrice2 = _fluxprice2;
        superMintKojiPrice = _kojiprice;
        superMintIncrease = _increase;
    }

    // Get the holder rewards of users staked $koji if they were to withdraw
    function getWithdrawResult(address _holder, uint256 _amount) public view returns (uint256) {

        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_holder];

        if (_amount == 0) { //pass 0 to use full user.amount, otherwise pass partial amount
            _amount = user.amount;
        } 

        uint256 netamount;

        uint256 tokenSupply = pool.stakeToken.balanceOf(address(this)); // Get total amount of KOJI tokens
        uint256 totalRewards = tokenSupply.sub(pool.runningTotal); // Get difference between contract address amount and ledger amount
        uint256 percentRewards = _amount.mul(100).div(pool.runningTotal); // Get % of share out of 100
        uint256 reflectAmount = percentRewards.mul(totalRewards).div(100); // Get % of reflect amount           
        uint256 taxfeenumerator = getUnstakePenalty(user.unstakeTime);
        uint256 taxfee = taxableAmount.sub(taxableAmount.mul(taxfeenumerator).div(unstakePenaltyDenominator));
        netamount = _amount.mul(taxfee).div(unstakePenaltyDenominator);
        netamount = netamount.add(reflectAmount);

        return netamount;

    }

    function getHolderRewards(address _address, uint256 _amount) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][_address];

        if (_amount == 0) { //pass 0 to use full user.amount, otherwise pass partial amount
            _amount = user.amount;
        } 
        uint256 tokenSupply = pool.stakeToken.balanceOf(address(this)); // Get total amount of tokens
        uint256 totalRewards = tokenSupply.sub(pool.runningTotal); // Get difference between contract address amount and ledger amount
        
         if (totalRewards > 0) { // Include reflection
            uint256 percentRewards = _amount.mul(100).div(pool.runningTotal); // Get % of share out of 100
            uint256 reflectAmount = percentRewards.mul(totalRewards).div(100); // Get % of reflect amount

            return reflectAmount; // return reflection amount

         } else {

             return 0;

         }

    }

    function setTaxlessWithdrawals(bool _status) external onlyAuthorized {
        enableTaxlessWithdrawals = _status;
    }

    function setSuperMintStatus(address _holder, bool _status) external { //***remove or add onlyAuthorized for production
        superMint[_holder] = _status;
    }

    // remaining time until user can unlock a supermint purchased with FLUX
    function getAccrualTime(address _holder) public view returns (uint256,bool) {
        UserInfo storage user = userInfo[0][_holder]; 

        uint256 timeleft = user.supermintstaketimer.add(user.supermintaccrualperiod);

        if (timeleft > block.timestamp) {
            return (timeleft.sub(block.timestamp),false);
        } else {
            return (0,true);
        }
    
    }

    // Set FLUX -> KOJI oracle conversion enabled/disabled
    function setConvertRewards(bool _status) external onlyAuthorized {
        convertRewardsEnabled = _status;
    }

    function setTimePeriods(uint256 _penaltyPeriod, uint256 _tier1smperiod, uint256 _tier2smperiod) external onlyAuthorized {
        require(_penaltyPeriod > 0, "E37");
        require(_tier1smperiod > 0, "E38");
        require(_tier2smperiod > 0, "E39");
        penaltyPeriod = _penaltyPeriod;
        supermintAccrualFrame1 = _tier1smperiod;
        supermintAccrualFrame2 = _tier2smperiod;
    }

    function changePegAmounts(uint256 _kojiusd, uint256 _tier1peg, uint256 _tier2peg) external onlyAuthorized {
        kojiUsdPeg = _kojiusd;
        tier1kojiPeg = _tier1peg;
        tier2kojiPeg = _tier2peg;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title  
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 * Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/examples/SimpleToken.sol
 */
contract KojiFlux is ERC20 {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    address owner = payable(address(msg.sender));

    modifier onlyOwner() {
        require(msg.sender == owner);
    _;
    }

    // This will allow to rescue ETH sent by mistake directly to the contract
    function rescueETHFromContract() external onlyOwner {
        address payable _owner = payable(_msgSender());
        _owner.transfer(address(this).balance);
    }

    // Function to allow admin to claim *other* ERC20 tokens sent to this contract (by mistake)
    function transferERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        require(_tokenAddr != address(this), "Cannot transfer out native token");
        IERC20(_tokenAddr).transfer(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

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
        return 9;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
     * by making the `nonReentrant` function external, and make it call a
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
        _setOwner(_msgSender());
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

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}