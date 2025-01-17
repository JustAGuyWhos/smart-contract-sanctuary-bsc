/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

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


interface IWETHGym {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external;

    function balanceOf(address dst) external view returns (uint256);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}


interface IVault {
    /// @dev Return the total ERC20 entitled to the token holders. Be careful of unaccrued interests.
    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /// @dev Add more ERC20 to the bank. Hope to get some good returns.
    function deposit(uint256 amountToken) external payable;

    /// @dev Withdraw ERC20 from the bank by burning the share tokens.
    function withdraw(uint256 share) external;

    /// @dev Request funds from user through Vault
    function requestFunds(address targetedToken, uint256 amount) external;

    function token() external view returns (address);

    function pendingReward(uint256, address) external view returns (uint256);
}

interface IFarming {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }
    struct PoolInfo {
        address lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    function autoDeposit(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable;

    function pendingRewardTotal(address) external view returns (uint256 total);
}

contract GymMLM is OwnableUpgradeable {
    uint256 public currentId;
    uint256 public oldUserTransferTimestampLimit;

    address public bankAddress;

    uint256[16] public directReferralBonuses;
    uint256[16] public levels;
    uint256[16] public oldUserLevels;

    mapping(address => uint256) public addressToId;
    mapping(uint256 => address) public idToAddress;
    mapping(address => uint256) public investment;
    mapping(address => address) public userToReferrer;
    mapping(address => uint256) public scoring;
    mapping(address => uint256) public firstDepositTimestamp;

    address public farming;
    address public singlePool;
    uint256 public singlePoolStartTimestamp;

    event NewReferral(address indexed user, address indexed referral);

    event ReferralRewardReceived(
        address indexed user,
        address indexed referral,
        uint256 level,
        uint256 amount,
        address wantAddress
    );

    /**
    * @notice User qualification
     * @param ownDepositBNB: User deposit vault in BNB. *100
     * @param usdAmountPool: User active uds amount pool.
     * @param directPartners: User direct partners
     * @param partnerLevel: User partner level
     */
    struct UserQualification {
        uint256 depositBNB;
        uint256 usdAmountPool;
        uint32 directPartners;
        uint32 partnerLevel;
    }

    uint256 public directPartnersConditionsTimestamp;
    address public accountContractAddress;

    mapping(uint32 => UserQualification) public userQualification;
    mapping(address => address[]) public directPartners;
    //地址=>类型=>Token=>奖励数量
    mapping(address => mapping(uint256 => mapping(address => uint256))) public rewardInfo;

    function initialize(address rooter) external initializer {
        directReferralBonuses = [1000, 700, 500, 400, 400, 300, 100, 100, 100, 50, 50, 50, 50, 50, 25, 25];
        addressToId[rooter] = 1;
        idToAddress[1] = rooter;
        userToReferrer[rooter] = rooter;
        currentId = 2;
        levels = [0.05 ether,0.1 ether,0.25 ether,0.5 ether,1 ether,3 ether,5 ether,10 ether,15 ether,25 ether,30 ether,35 ether,40 ether,70 ether,100 ether,200 ether];
        oldUserLevels = [0 ether,0.045 ether,0.045 ether,0.045 ether,0.045 ether,0.045 ether,1.35 ether,4.5 ether,9 ether,13.5 ether,22.5 ether,27 ether,31.5 ether,36 ether,45 ether,90 ether];

        __Ownable_init();
    }

    modifier onlyBank() {
        require(msg.sender == bankAddress || msg.sender == farming , "GymMLM:: Only bank");
        
        // require(msg.sender == bankAddress || msg.sender == farming || msg.sender == singlePool, "GymMLM:: Only bank");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    /**
     * @notice  Function to set conditions timestamp
     * @param timestamp timestamp for set up
     */
    function setDirectPartnersConditionsTimestamp(uint256 timestamp) external onlyOwner {
        directPartnersConditionsTimestamp = timestamp;
    }

    /**
     * @notice  Function to set conditions timestamp
     * @param _level:  qualification level
     * @param _depositBNB:  value of min deposit in BNB
     * @param _gymnetFarm:  value of min gymnet farm
     * @param _directPartnersCount:  direct partners count
     * @param _partnerLevel:  direct partner level
     */
    function setUserQualification(
        uint32 _level,
        uint256 _depositBNB,
        uint256 _gymnetFarm,
        uint32 _directPartnersCount,
        uint32 _partnerLevel
    ) external onlyOwner {
        userQualification[_level] = UserQualification(_depositBNB, _gymnetFarm, _directPartnersCount, _partnerLevel);
    }

    /**
     * @notice  Function to update MLM commission
     * @param _level commission level for change
     * @param _commission new commission
     */
    function updateMLMCommission(uint256 _level, uint256 _commission) external onlyOwner {
        directReferralBonuses[_level] = _commission;
    }

    /**
     * @notice  Function to update direct partners information
     * @param _referrer: Address of referrer user
     * @param _directPartners: Array of addresses of user direct partners
     */
    function updateDirectPartners(address _referrer, address[] calldata _directPartners) external {
        for(uint32 i = 0; i < _directPartners.length; i++){
            if (
                userToReferrer[_directPartners[i]] == _referrer
                && isUniqueDirectPartner(_referrer, _directPartners[i])
            ) {
                    directPartners[_referrer].push(_directPartners[i]);
            }
        }
    }

    function updateScoring(address _token, uint256 _score) external onlyOwner {
        scoring[_token] = _score;
    }

    function _addUser(address _user, address _referrer) private {
        addressToId[_user] = currentId;
        idToAddress[currentId] = _user;
        userToReferrer[_user] = _referrer;
        directPartners[_referrer].push(_user);
        currentId++;
        emit NewReferral(_referrer, _user);
    }

    /**
     * @notice  Function to add GymMLM
     * @param _user Address of user
     * @param _referrerId Address of referrer
     */
    function addGymMLM(address _user, uint256 _referrerId) external onlyBank {
        address _referrer = userToReferrer[_user];

        if (_referrer == address(0)) {
            _referrer = idToAddress[_referrerId];
        }

        require(_user != address(0), "GymMLM::user is zero address");

        require(_referrer != address(0), "GymMLM::referrer is zero address");

        require(
            userToReferrer[_user] == address(0) || userToReferrer[_user] == _referrer,
            "GymMLM::referrer is zero address"
        );

        // If user didn't exsist before
        if (addressToId[_user] == 0) {
            _addUser(_user, _referrer);
        }
    }

    /**
     * @notice Function to distribute rewards to referrers
     * @param _wantAmt Amount of assets that will be distributed
     * @param _wantAddr Address of want token contract
     * @param _user Address of user
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     */
    function distributeRewards(
        uint256 _wantAmt,
        address _wantAddr,
        address _user,
        uint32 _type
    ) public onlyBank {
        uint256 index;
        uint256 length = directReferralBonuses.length;

        IERC20 token = IERC20(_wantAddr);

        while (index < length && addressToId[userToReferrer[_user]] != 1) {
            address referrer = userToReferrer[_user];
            if (index < _getUserLevel(referrer) && investment[referrer] > 0) {
                uint256 reward = (_wantAmt * directReferralBonuses[index]) / 10000;
                uint256 rewardToTransfer = reward;
                // update accountant information
                // uint256 _borrowedAmount = IAccountant(accountContractAddress).getUserBorrowedAmount(referrer, _type);
                // if (_borrowedAmount > 0 && _wantAddr == 0x3a0d9d7764FAE860A659eb96A500F1323b411e68) {
                //     if (reward >= _borrowedAmount) {
                //         token.transfer(accountContractAddress, _borrowedAmount);
                //         IAccountant(accountContractAddress).updateBorrowedAmount(referrer, _borrowedAmount, false, _type);
                //         rewardToTransfer = reward - _borrowedAmount;
                //     } else {
                //         token.transfer(accountContractAddress, reward);
                //         IAccountant(accountContractAddress).updateBorrowedAmount(referrer, reward, false, _type);
                //         rewardToTransfer = 0;
                //     }
                // }
                // ====
                rewardInfo[_user][_type][_wantAddr] = rewardInfo[_user][_type][_wantAddr]+rewardToTransfer;
                require(token.transfer(referrer, rewardToTransfer), "GymMLM:: Transfer failed");
                emit ReferralRewardReceived(referrer, _user, index, reward, _wantAddr);
            }
            _user = userToReferrer[_user];
            index++;
        }

        if (token.balanceOf(address(this)) > 0) {
            require(token.transfer(bankAddress, token.balanceOf(address(this))), "GymMLM:: Transfer failed");
        }

        return;
    }

    function setBankAddress(address _bank) external onlyOwner {
        bankAddress = _bank;
    }
    // function setSinglePoolStartTimestamp(uint256 _singlePoolStartTimestamp) external onlyOwner {
    //     singlePoolStartTimestamp = _singlePoolStartTimestamp;
    // }
    // function setSinglePoolAddress(address _singlePool) external onlyOwner {
    //     singlePool = _singlePool;
    // }
    function setOldUserTransferTimestampLimit(uint256 _limit) external onlyOwner {
        oldUserTransferTimestampLimit = _limit;
    }

    /**
     * @notice  Function to set Farming address
     * @param _address Address of treasury address
     */
    function setFarmingAddress(address _address) external onlyOwner {
        farming = _address;
    }

    function setAccountantAddress(address _address) external onlyOwner {
        accountContractAddress = _address;
    }

    function seedUsers(address[] memory _users, address[] memory _referrers) external onlyOwner {
        require(_users.length == _referrers.length, "Length mismatch");
        for (uint256 i; i < _users.length; i++) {
            addressToId[_users[i]] = currentId;
            idToAddress[currentId] = _users[i];
            userToReferrer[_users[i]] = _referrers[i];
            currentId++;

            emit NewReferral(_referrers[i], _users[i]);
        }
    }

    function updateInvestment(address _user, uint256 _newInvestment) external onlyBank {
        if (firstDepositTimestamp[_user] == 0) firstDepositTimestamp[_user] = block.timestamp;
        investment[_user] = _newInvestment;
    }

    /**
     * @notice Function to get pending rewards to referrers
     * @param _userAddress: User address
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     * @return Pending Rewards
     */
    function getPendingRewards(
        address _userAddress,
        uint32 _type
    )
        public
        view 
        returns (uint256)
    {
        require(accountContractAddress != address(0), "GymMLM:: Account contract address is zero address");

        uint32 _level = _getUserLevel(_userAddress);
        uint256 _rewardsPendingTotal = _getPendingRewards(_userAddress, _type, _level, 0);
        // uint256 _borrowedAmount = IAccountant(accountContractAddress).getUserBorrowedAmount(_userAddress, _type);

        // if (_borrowedAmount >= _rewardsPendingTotal) {
        //     return 0;
        // }

        // return _rewardsPendingTotal - _borrowedAmount;
        return _rewardsPendingTotal;

    }

    /**
     * @notice Public function to define default userQualification
     */
    function setDefaultQualificationData() public onlyOwner {
        userQualification[0] = UserQualification(0.05 ether, 0, 0, 0);
        userQualification[1] = UserQualification(0.1 ether, 0, 0, 0);
        userQualification[2] = UserQualification(0.25 ether, 200, 0, 0);
        userQualification[3] = UserQualification(0.5 ether, 200, 0, 0);
        userQualification[4] = UserQualification(1 ether, 2000, 2, 2);
        userQualification[5] = UserQualification(3 ether, 4000, 3, 2);
        userQualification[6] = UserQualification(5 ether, 10000, 5, 2);
        userQualification[7] = UserQualification(10 ether, 20000, 5, 2);
        userQualification[8] = UserQualification(15 ether, 40000, 6, 5);
        userQualification[9] = UserQualification(25 ether, 45000, 7, 5);
        userQualification[10] = UserQualification(30 ether, 50000, 8, 5);
        userQualification[11] = UserQualification(35 ether, 60000, 9, 5);
        userQualification[12] = UserQualification(40 ether, 65000, 10, 5);
        userQualification[13] = UserQualification(70 ether, 70000, 5, 5);
        userQualification[14] = UserQualification(100 ether, 75000, 5, 5);
        userQualification[15] = UserQualification(200 ether, 80000, 5, 5);
    }

    /**
     * @notice Public function to get GYMNET amount
     * @param _userAddress: User address for get active gymnet amount
     */
    // function getUSDAmount(
    //     address _userAddress
    // ) public view returns (uint256) {
    //     require(singlePool != address(0), "GymMLM::Single pool address zero");
    //     return IGymSinglePool(singlePool).getUserInfo(_userAddress).totalDepositDollarValue;
    // }

       /**
     * @notice Public view function to user qualification
     * @param _userAddress: user address to get the qualification
     * @return _userQualification User Qualification
     */
    function getUserDirectPartnerQualification(address _userAddress) public view returns (uint32 _userQualification) {
        address[] memory _directPartners = directPartners[_userAddress];
        // uint256 _usdAmount = getUSDAmount(_userAddress);
        for (uint32 i = 0; i < levels.length ; i++) {
            if (
                investment[_userAddress] >= userQualification[i].depositBNB/1000
                // && _usdAmount >= userQualification[i].usdAmountPool
                && _directPartners.length >= userQualification[i].directPartners
                && checkPartnersLevel(_directPartners, userQualification[i].directPartners, userQualification[i].partnerLevel)
            ) {
                _userQualification = i+1;
            } else {
                break;
            }
        }
    }

    /**
     * @notice Public view function to get user MLM level
     * @param _user: user address to get the level
     * @return userLevel user MLM level
     */
    function getUserCurrentLevel(address _user) public view returns(uint32 userLevel) {
        return _getUserLevel(_user);
    }

    /**
    * @notice Internal view function to check direct partners levels
     * @param _partners: array of addresses for check
     * @param _level: minimum level of partner
     * @return bool flag
     */
    function checkPartnersLevel(
        address[] memory _partners,
        uint32 _length,
        uint32 _level
    ) internal view returns (bool) {
        if (_level == 0) return true;
        uint32  currentLength ;
        for (uint32 i = 0; i < _partners.length; i++) {
            if (_getUserLevel(_partners[i]) >= _level) {
                currentLength ++;
            }
        }
        if(currentLength >= _length)
            return true;
        else
            return false;
    }

    /**
    * @notice Internal view function to get user MLM level
     * @param _userAddress: user address to get the level
     * @return user MLM level
     */
    function _getUserLevel(
        address _userAddress
    ) internal view returns (uint32) {
        uint32 _userLevel;
        uint256 _firstDepositTimestamp = firstDepositTimestamp[_userAddress];
        address[] memory _directPartners = directPartners[_userAddress];
        // uint256 _usdAmount = getUSDAmount(_userAddress);
        for (uint32 i = 0; i < levels.length ; i++) {
            if (
                (
                    _firstDepositTimestamp < oldUserTransferTimestampLimit
                    && investment[_userAddress] >= oldUserLevels[i]
                ) || (
                    oldUserTransferTimestampLimit < _firstDepositTimestamp
                    && (
                        directPartnersConditionsTimestamp == 0 || _firstDepositTimestamp < directPartnersConditionsTimestamp
                    )
                    && investment[_userAddress] >= levels[i]/1000
                )
            ){
                _userLevel = i+1;
            } else if (directPartnersConditionsTimestamp != 0 && directPartnersConditionsTimestamp < _firstDepositTimestamp) {
                if (
                    investment[_userAddress] >= userQualification[i].depositBNB/1000
                    // && _usdAmount >= userQualification[i].usdAmountPool
                    && _directPartners.length >= userQualification[i].directPartners
                    && checkPartnersLevel(_directPartners, userQualification[i].directPartners, userQualification[i].partnerLevel)
                ) {
                    _userLevel = i+1;
                } else {
                    break;
                }
            } 
        }
        // if (singlePoolStartTimestamp !=0 && singlePoolStartTimestamp < block.timestamp) {
        //     uint32 levelInSinglePool = IGymSinglePool(singlePool).getUserLevelInSinglePool(_userAddress);
        //     // if(levelInSinglePool == 0) levelInSinglePool = 1;
        //     uint32 levelVaultAndPool = _userLevel >= levelInSinglePool ? levelInSinglePool : _userLevel;
        //     _userLevel = levelVaultAndPool;
        // }
        
        return _userLevel;
    }

    /**
     * @notice Pure Function to calculate percent of amount
     * @param _amount: Amount
     * @param _percent: User address
     */
    function calculatePercentOfAmount(uint256 _amount, uint256 _percent) private pure returns (uint256) {
        return _amount * _percent / 10000;
    }

    /**
     * @notice Private function to get pending rewards to referrers
     * @param _userAddress: User address
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     * @param _level: User level (default = 0)
     * @param _depth: depth of direct partners (default = 0)
     * @return Pending Rewards
     */
    function _getPendingRewards(
        address _userAddress,
        uint32 _type,
        uint32 _level,
        uint32 _depth
    )
        private
        view 
        returns (uint256)
    {
        if (_depth > _level + 1) {
            return 0;
        }
        uint256  _rewardsPendingTotal;
        uint256 convertBalance;
        address[] memory _directChilds = directPartners[_userAddress];

        if (_depth != 0) {
            convertBalance = _getPendingRewardBalance(_userAddress, _type);
            _rewardsPendingTotal = calculatePercentOfAmount(convertBalance, directReferralBonuses[_depth-1]);
        } else {
             _rewardsPendingTotal = 0;
        }

        for (uint32 i = 0; i < _directChilds.length; i++) {
            _rewardsPendingTotal += _getPendingRewards(_directChilds[i], _type, _level, _depth + 1);
        }

        return _rewardsPendingTotal;

    }

    /**
     * @notice Private function to get pending rewards to referrers
     * @param _userAddress: User address
     * @param _type: type of pending rewards (
                1 - VaultBank,
                2 - Farming,
                3 - SinglePool
       )
     * @return Pending Rewards
     */
    function _getPendingRewardBalance(address _userAddress, uint32 _type) private view returns (uint256) {
        uint256 convertBalance;
         if (_type == 1) {
                require(bankAddress != address(0), "GymMLM:: Vault contract address is zero address");
                convertBalance = IVault(bankAddress).pendingReward(0, _userAddress);
            } else if (_type == 2) {
                require(farming != address(0), "GymMLM:: Farming contract address is zero address");
                convertBalance = IFarming(farming).pendingRewardTotal(_userAddress);
            } 
            // else if (_type == 3) {
            //     require(singlePool != address(0), "GymMLM:: Single Pool contract address is zero address");
            //     uint256 _depositId = IGymSinglePool(singlePool).getUserInfo(_userAddress).depositId;
            //     for (uint32 i = 0; i < _depositId; i++) {
            //         convertBalance += IGymSinglePool(singlePool).pendingReward(i, _userAddress);
            //     }
            // }
        return convertBalance;
    }

    function getDirectPartnersLength(address _userAddress) public view returns(uint256){
        return directPartners[_userAddress].length;
    }

    /**
     * @notice  Function to check is unique direct partner
     * @param _userAddress: Address of referrer user
     * @param _referrAddress: referr user address
     */
    function isUniqueDirectPartner(address _userAddress, address _referrAddress) private view returns(bool) {
        address[] memory _directPartners = directPartners[_userAddress];
        if (_directPartners.length == 0) {
            return true;
        }
        for (uint32 i = 0; i < _directPartners.length; i++){
            if (_referrAddress == _directPartners[i]){
                return false;
            }
        }
        return true;
    }

}