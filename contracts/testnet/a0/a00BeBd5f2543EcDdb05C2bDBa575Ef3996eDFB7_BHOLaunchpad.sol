// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/erc20/IERC20.sol";
import "@openzeppelin/contracts/token/erc20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./../interfaces/IBHOStaking.sol";
import "./../interfaces/IAddressDecentralization.sol";
import "./../libs/SharedConstants.sol";
import "./../../utils/Whitelist.sol";
import "./../../utils/SafeArrayUint.sol";
import "./../../utils/SafeArrayAddress.sol";

contract BHOLaunchpad is Initializable, Context, Whitelist, SharedConstants {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeArrayUint for uint256[];
    using SafeArrayAddress for address[];

    uint256 public constant DECIMALS_PERCENT = 1e3;
    uint256 public emergencyWithdrawFee = 10 * DECIMALS_PERCENT; // 90%

    address public FACTORY_ADDRESS;

    uint256 public percentCanBuyInFCFS = 25 * DECIMALS_PERCENT;

    address constant BURN_ADDRESS =
        address(0x000000000000000000000000000000000000dEaD);

    /* events */
    event EmergencyWithdraw(address indexed buyer, uint256 indexed amount);
    event EmergencyWithdrawFeeChange(uint256 indexed percent);
    event PercentBuyInFCFSChange(uint256 indexed percent);
    event BuyTokenInAllocationRound(
        address indexed buyer,
        uint256 indexed amount
    );
    event BuyTokenInAllocationFCFS(
        address indexed buyer,
        uint256 indexed amount
    );
    event ClaimToken(address indexed buyer, uint256 indexed amount);
    event WithdrawToken(address indexed buyer, uint256 indexed amount);
    event Contribute(address indexed buyer, uint256 indexed amount);
    event Register(address indexed addr);
    event UnRegister(address indexed addr);
    event StatusChange(Statuses indexed status);
    event UserBeneficiaryChange(address indexed user, string indexed beneficiary);

    LaunchpadData private launchpadData;
    VestingTimeline private vestingTimeline;

    Statuses public status;

    IBHOStaking public staking;

    uint256 public capacity;
    uint256 public capacityAllocation;
    uint256 public capacityFCFS;
    uint256 public totalPoolWeight;
    address[] private participants;

    mapping(address => uint256) public amountsInAllocation;
    mapping(address => uint256) public amountsInFCFS;

    mapping(address => VestingHistory[]) private vestingHistories;

    mapping(address => RegistrationInfo) private registrationList;

    // The Address Decentralization
    IAddressDecentralization public addrDec;

    /* Modifier */
    modifier checkWhoCanBuy() {
        // whitelist
        if (launchpadData.presaleType == PresaleType.WHITELIST) {
            require(isWhitelisted(_msgSender()), "Address does not exist");
            _;
            return;
        }
        require(
            registrationList[_msgSender()].isRegister,
            "Address dont register yet"
        );
        _;
    }

    modifier checkWhoCanRegister() {
        // whitelist
        if (launchpadData.presaleType == PresaleType.WHITELIST) {
            require(isWhitelisted(_msgSender()), "Address does not exist");
            _;
            return;
        }
        _;
    }

    modifier onlyRole(string memory _stringRole) {
        // Is Root Admin
        bytes32 role;
        if (keccak256(abi.encodePacked(_stringRole)) == keccak256(abi.encodePacked("rootadmin"))) {
            role = 0x00;
        } else {
            // Get role by strings
            role = addrDec.getRoleByString(_stringRole);
        }

        require(
            addrDec.hasRoleV2(role, _msgSender()),
            string(abi.encodePacked("account is missing role ", _stringRole))
        );
        _;
    }

    function initialize(
        LaunchpadData memory _launchpadData,
        VestingTimeline memory _vestingTimeline,
        IBHOStaking _stakingAddr,
        IAddressDecentralization _addrDec
    ) external initializer {
        // check time register, allocation, fcfs
        require(
            _launchpadData.register.startAt <= _launchpadData.register.endAt,
            "Register time invalid"
        );
        require(
            _launchpadData.register.endAt <= _launchpadData.allocation.startAt,
            "Register time must be before Allocation time"
        );

        require(
            _launchpadData.allocation.startAt <=
                _launchpadData.allocation.endAt,
            "Allocation time invalid"
        );
        require(
            _launchpadData.allocation.endAt <= _launchpadData.fcfs.startAt,
            "Allocation time must be before FCFS time"
        );

        require(
            _launchpadData.fcfs.startAt <= _launchpadData.fcfs.endAt,
            "FCFS time invalid"
        );

        require(
            _launchpadData.presaleRate > 0,
            "Presale rate must be greater than 0"
        );
        require(
            _vestingTimeline.percents.length ==
                _vestingTimeline.timestamps.length,
            "Vesting timeline invalid format"
        );
        require(
            _vestingTimeline.percents.sum() == (100 * DECIMALS_PERCENT),
            "Total percents must be equal 100"
        );
        require(
            _validateVestingTimeline(
                _vestingTimeline,
                _launchpadData.fcfs.endAt
            ),
            "Vesting timeline must be after end time"
        );

        launchpadData = _launchpadData;
        vestingTimeline = _vestingTimeline;
        FACTORY_ADDRESS = _msgSender();
        staking = _stakingAddr;
        addrDec = _addrDec;
        emergencyWithdrawFee = 10 * DECIMALS_PERCENT;
        percentCanBuyInFCFS = 25 * DECIMALS_PERCENT;
    }

    /******************************************* Admin function below *******************************************/

    /**
     * @dev Collect BUSD afte launchpad finalize to _recipient
     */
    function collectTokenPayment(address _recipient)
        external
        onlyRole("rootadmin")
    {
        // Get 100% BUSD
        uint256 amountToken = capacity.mul(100).div(100);
        launchpadData.payInToken.transfer(_recipient, amountToken);

        // Get remain BUSD include fee emergency withdraw
        launchpadData.payInToken.transfer(
            _recipient,
            launchpadData.payInToken.balanceOf(address(this))
        );
    }

    /**
     * @dev Update percent can buy in FCFS
     */
    function updatePercentCanBuyInFCFS(uint256 _percent)
        external
        onlyRole("manager")
    {
        require(_percent > 0, "Percent be greater than 0");
        require(_percent <= 100 * DECIMALS_PERCENT, "Percent be less than 100");
        percentCanBuyInFCFS = _percent;

        emit PercentBuyInFCFSChange(_percent);
    }

    /**
     * @dev Update emergencyWithdrawFee
     */
    // function updateEmergencyWithdrawFee(uint256 _percent)
    //     external
    //     onlyRole("manager")
    // {
    //     require(_percent > 0, "Percent be greater than 0");
    //     require(_percent <= 100 * DECIMALS_PERCENT, "Percent be less than 100");
    //     emergencyWithdrawFee = _percent;

    //     emit EmergencyWithdrawFeeChange(_percent);
    // }

    /**
     * @dev update presale type : public, whitelist, ...
     */
    function updatePresaleType(PresaleType _presaleType)
        public
        onlyRole("manager")
    {
        launchpadData.presaleType = _presaleType;
    }

    /**
     * @dev finalize launchpad,then user can claim token launchpad and admin can collect BUSD
     */
    function finalize() public onlyRole("manager") {
        require(status != Statuses.FINALIZE, "Launchpad is finalized");
        require(status != Statuses.CANCELLED, "Launchpad is cancelled");

        // If address token == address(0), so do nothing
        if (address(launchpadData.token) != address(0)) {
             _handleUnsoldToken(_msgSender());
        }
        status = Statuses.FINALIZE;

        emit StatusChange(Statuses.FINALIZE);
    }

    /**
     * @dev cancel launchpad, then user can withdraw BUSD
     */
    function cancel() public onlyRole("manager") {
        // require(status != Statuses.FINALIZE, "Launchpad is finalized");
        require(status != Statuses.CANCELLED, "Launchpad is cancelled");
        status = Statuses.CANCELLED;
        if (address(launchpadData.token) != address(0)) {
            launchpadData.token.transfer(
                _msgSender(),
                launchpadData.token.balanceOf(address(this))
            );
        }
        emit StatusChange(Statuses.CANCELLED);
    }

    /**
     * @dev add whitelist
     */
    function addMulti(address[] memory _addresses) public onlyRole("manager") {
        _addMulti(_addresses);
    }

    /**
     * @dev remove whitelist
     */
    function removeMulti(address[] memory _addresses)
        public
        onlyRole("manager")
    {
        _removeMulti(_addresses);
    }

    /******************************************* Participant function below *******************************************/

    /**
     * @dev User have to register before buy token launchpad
     */
    function register(string memory _beneficiary) public checkWhoCanRegister {
        // check time register round
        require(
            block.timestamp > launchpadData.register.startAt,
            "Register time dont start yet"
        );
        require(
            block.timestamp < launchpadData.register.endAt,
            "Register time expired"
        );
        address user = _msgSender();
        (string memory id, , uint256 poolWeight) = staking.levelOf(user);

        require(!registrationList[user].isRegister, "User registerd");
        registrationList[user] = RegistrationInfo({
            id: id,
            poolWeight: poolWeight,
            isRegister: true,
            beneficiary: _beneficiary
        });

        totalPoolWeight = totalPoolWeight.add(uint256(poolWeight));
        emit Register(user);
    }

    /**
     * @dev User un register
     */
    function unregister() public checkWhoCanRegister {
        // check time register round
        require(
            block.timestamp > launchpadData.register.startAt,
            "Register time dont start yet"
        );
        require(
            block.timestamp < launchpadData.register.endAt,
            "Register time expired"
        );
        address user = _msgSender();
        require(registrationList[user].isRegister, "User unregisterd");

        totalPoolWeight = totalPoolWeight.sub(
            uint256(registrationList[user].poolWeight)
        );

        registrationList[user] = RegistrationInfo({
            id: "",
            poolWeight: 0,
            isRegister: false,
            beneficiary: ""
        });
        emit UnRegister(user);
    }

    /**
     * @dev User update beneficiary address
     */
    function updateBeneficiary(string memory _beneficiary) public {
        address user = _msgSender();
        require(registrationList[user].isRegister, "User unregisterd");
        registrationList[user].beneficiary = _beneficiary;

        emit UserBeneficiaryChange(user, _beneficiary);
    }

    /**
     * @dev Info of user after registed
     */
    function registrationInfo(address _addr)
        public
        view
        returns (RegistrationInfo memory)
    {
        return registrationList[_addr];
    }

    /**
     * @dev Buy token for Allocation round
     */
    function buyTokenAllocation(uint256 _amount) external checkWhoCanBuy {
        require(_amount > 0, "Amount must the greater than 0");
        require(status != Statuses.CANCELLED, "Launchpad is cancelled");
        require(status != Statuses.FINALIZE, "Launchpad is finalized");
        // // check start, end time
        // require(block.timestamp < launchpadData.endAt, "Launchpad ended");
        // require(
        //     block.timestamp > launchpadData.startAt,
        //     "Launchpad do not start yet"
        // );
        // check hard cap
        require(
            capacity.add(_amount) <= launchpadData.hardCap,
            "The capacity has exceeded the limit"
        );
        // check time allocation round

        require(
            block.timestamp > launchpadData.allocation.startAt,
            "Allocation round dont start yet"
        );
        require(
            block.timestamp < launchpadData.allocation.endAt,
            "Allocation round expired"
        );

        // max BUSD user can buy
        address buyer = _msgSender();

        uint256 maxBuy = _getBaseAllocation().mul(
            registrationList[buyer].poolWeight
        );

        require(
            amountsInAllocation[buyer].add(_amount) <= maxBuy,
            "Buying limit has been exceeded in Allocation round"
        );

        // Add +1 user participant
        if (amountStaked(buyer) == 0) {
            participants.addAddress(buyer);
        }

        amountsInAllocation[buyer] = amountsInAllocation[buyer].add(_amount);
        capacity = capacity.add(_amount);
        capacityAllocation = capacityAllocation.add(_amount);

        // safe transfer payIntoken to launchpad
        launchpadData.payInToken.transferFrom(buyer, address(this), _amount);

        emit BuyTokenInAllocationRound(buyer, _amount);
    }

    /**
     * @dev Buy token for first round
     */
    function buyTokenFCFS(uint256 _amount) external {
        require(_amount > 0, "Amount must the greater than 0");
        require(status != Statuses.CANCELLED, "Launchpad is cancelled");
        require(status != Statuses.FINALIZE, "Launchpad is finalized");
        // // check start, end time
        // require(
        //     block.timestamp > launchpadData.startAt,
        //     "Launchpad do not start yet"
        // );

        // check hard cap
        require(
            capacity.add(_amount) <= launchpadData.hardCap,
            "The capacity has exceeded the limit"
        );

        // check time FCFS
        require(
            block.timestamp > launchpadData.fcfs.startAt,
            "FCFS round dont start yet"
        );
        require(
            block.timestamp < launchpadData.fcfs.endAt,
            "FCFS round expired"
        );

        uint256 decimalsOfToken = launchpadData.payInToken.decimals();
        uint256 minBuy = 25 * 10**decimalsOfToken;
        uint256 maxBuy = 250 * 10**decimalsOfToken;

        address buyer = _msgSender();

        require(
            minBuy <= _amount,
            "Buying limit is below required min amount in FCFS round"
        );
        require(
            amountsInFCFS[buyer].add(_amount) <= maxBuy,
            "Buying limit has been exceeded in FCFS round"
        );

        // Add +1 user participant
        if (amountStaked(buyer) == 0) {
            participants.addAddress(buyer);
        }

        // // Just buy max 25% from Alloaction round
        // uint256 percentInDecimals = 100 * DECIMALS_PERCENT;
        // uint256 maxBuy = _getBaseAllocation()
        //     .mul(registrationList[buyer].poolWeight)
        //     .mul(percentCanBuyInFCFS)
        //     .div(percentInDecimals);

        // require(
        //     amountsInFCFS[buyer].add(_amount) <= maxBuy,
        //     "Buying limit has been exceeded in FCFS round"
        // );

        amountsInFCFS[buyer] = amountsInFCFS[buyer].add(_amount);
        capacity = capacity.add(_amount);
        capacityFCFS = capacityFCFS.add(_amount);

        // safe transfer payIntoken to launchpad
        launchpadData.payInToken.transferFrom(buyer, address(this), _amount);

        emit BuyTokenInAllocationFCFS(buyer, _amount);
    }

    /**
     * @dev Claim token launchpad after finalize
     */
    function claim(uint8 _index)
        external
        returns (uint256 amount, uint256 claimAt)
    {
        require(address(launchpadData.token) != address(0), "Token is zero-address");
        require(status == Statuses.FINALIZE, "Launchpad do not finalized yet");
        address buyer = _msgSender();
        uint256 amountUserStaked = amountsInAllocation[buyer].add(
            amountsInFCFS[buyer]
        );
        require(amountUserStaked > 0, "Wallet do not contribute token yet");
        require(_index < vestingTimeline.percents.length, "Index invalid");
        require(_isUserClaimed(buyer, _index), "Address claimed");

        // check user vested

        // check it's time to claim with _index vesting timeline
        uint256 percent = vestingTimeline.percents[_index];
        uint256 timestamp = vestingTimeline.timestamps[_index];

        require(block.timestamp > timestamp, "It is not time to next claim");

        uint256 decimalsOfToken = launchpadData.payInToken.decimals();
        uint256 amountOfUser = amountUserStaked
            .mul(launchpadData.presaleRate)
            .div(10**decimalsOfToken);

        uint256 percentInDecimals = 100 * DECIMALS_PERCENT;

        uint256 amountWillVesting = amountOfUser.mul(percent).div(
            percentInDecimals
        );

        // safe transfer token's launchpad for user
        launchpadData.token.transfer(buyer, amountWillVesting);

        // store vesting history
        VestingHistory memory history = VestingHistory(
            _index,
            amountWillVesting,
            block.timestamp
        );
        vestingHistories[buyer].push(history);

        emit ClaimToken(buyer, amountWillVesting);
        return (amountWillVesting, timestamp);
    }

    /**
     * @dev Emergency Withdraw if launchpad does not final yet
     */
    // function emergencyWithdraw() external {
    //     require(status != Statuses.FINALIZE, "Launchpad is finalized");

    //     address buyer = _msgSender();

    //     uint256 amountUserStaked = amountsInAllocation[buyer].add(
    //         amountsInFCFS[buyer]
    //     );

    //     require(amountUserStaked > 0, "Withdrawed");

    //     uint256 percentInDecimals = 100 * DECIMALS_PERCENT;

    //     uint256 amountFinal = amountUserStaked
    //         .mul(percentInDecimals.sub(emergencyWithdrawFee))
    //         .div(percentInDecimals);

    //     capacityAllocation = capacityAllocation.sub(amountsInAllocation[buyer]);
    //     capacityFCFS = capacityFCFS.sub(amountsInFCFS[buyer]);
    //     amountsInAllocation[buyer] = 0;
    //     amountsInFCFS[buyer] = 0;

    //     capacity = capacity.sub(amountUserStaked);

    //     launchpadData.payInToken.transfer(buyer, amountFinal);

    //     // Sub -1 user participant
    //     if (amountStaked(buyer) == 0) {
    //         participants.removeAddress(buyer);
    //     }

    //     emit EmergencyWithdraw(buyer, amountFinal);
    // }

    /**
     * @dev Withdraw token staked when launchpad canncelled
     */
    function withdrawToken() external {
        require(status == Statuses.CANCELLED, "Launchpad is not cancelled yet");

        address buyer = _msgSender();

        uint256 amountUserStaked = amountsInAllocation[buyer].add(
            amountsInFCFS[buyer]
        );

        require(amountUserStaked > 0, "Withdrawed");

        capacityAllocation = capacityAllocation.sub(amountsInAllocation[buyer]);
        capacityFCFS = capacityFCFS.sub(amountsInFCFS[buyer]);
        amountsInAllocation[buyer] = 0;
        amountsInFCFS[buyer] = 0;
        capacity = capacity.sub(amountUserStaked);

        launchpadData.payInToken.transfer(buyer, amountUserStaked);

        emit WithdrawToken(buyer, amountUserStaked);
    }

    /******************************************* Common function below *******************************************/

    /**
     * @dev Get base allocation ( BUSD )
     */
    function getBaseAllocation() public view returns (uint256) {
        return _getBaseAllocation();
    }

    /**
     * @dev Amount of address buy token
     */
    function amountStaked(address _addr) public view returns (uint256) {
        return amountsInAllocation[_addr].add(amountsInFCFS[_addr]);
    }

    /**
     * @dev Get max token payment ( BUSD ) user can buy
     */
    function getMaxTokenPayment(address _addr) public view returns (uint256) {
        // BUSD
        uint256 maxBuy = _getBaseAllocation().mul(
            registrationList[_addr].poolWeight
        );
        return maxBuy;
    }

    /**
     * @dev return launchpad data: hardCap, token, tokenPayment...
     */
    function getLaunchpadData() public view returns (LaunchpadData memory) {
        return launchpadData;
    }

    /**
     * @dev return list vesting schedule
     */
    function getLaunchpadVesting()
        public
        view
        returns (VestingTimeline memory)
    {
        return vestingTimeline;
    }

    /**
     * @dev return list vesting historeis of user
     */
    function getVestingHistories(address _addr)
        public
        view
        returns (VestingHistory[] memory)
    {
        return vestingHistories[_addr];
    }

    /**
     * @dev return list parpitipants
     */
    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    /******************************************* Internal function below *******************************************/
    function _isUserClaimed(address _addr, uint8 _index)
        internal
        view
        returns (bool)
    {
        VestingHistory[] memory histories = vestingHistories[_addr];
        for (uint8 i = 0; i < histories.length; i++) {
            if (histories[i].index == _index) return false;
        }
        return true;
    }

    function _handleUnsoldToken(address _recipient) internal {
        uint256 remainCap = launchpadData.hardCap.sub(capacity);
        uint256 decimalsOfToken = launchpadData.payInToken.decimals();
        uint256 remainToken = remainCap.mul(launchpadData.presaleRate).div(
            10**decimalsOfToken
        );
        
        if (launchpadData.unsoldToken == SharedConstants.UnsoldToken.REFUND) {
            launchpadData.token.transfer(_recipient, remainToken);
        }

        if (launchpadData.unsoldToken == SharedConstants.UnsoldToken.BURN) {
            launchpadData.token.transfer(BURN_ADDRESS, remainToken);
        }
    }

    function _getBaseAllocation() internal view returns (uint256) {
        if (totalPoolWeight == 0) return launchpadData.hardCap.div(1);
        return launchpadData.hardCap.div(totalPoolWeight);
    }

    function _validateVestingTimeline(
        VestingTimeline memory _vestingTimeline,
        uint256 _endAt
    ) internal pure returns (bool) {
        uint256[] memory times = _vestingTimeline.timestamps;
        for (uint256 i = 0; i < times.length; i++) {
            if (times[i] < _endAt) {
                return false;
            }
        }
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Whitelist {
    mapping(address => bool) private whitelist;
    address[] private addresses;
    event AddedToWhitelist(address indexed account);
    event AddedMultiToWhitelist(address[] indexed accounts);
    event RemovedFromWhitelist(address indexed account);
    event RemovedMultiFromWhitelist(address[] indexed accounts);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "Whitelist: address does not exist");
        _;
    }

    // function add(address _address) public onlyOwner {
    //     whitelist[_address] = true;
    //     emit AddedToWhitelist(_address);
    // }

    function _addMulti(address[] memory _addresses) internal {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
            _removeAddress(_addresses[i]);
            addresses.push(_addresses[i]);
            emit AddedToWhitelist(_addresses[i]);
        }
        // emit AddedMultiToWhitelist(_addresses);
    }

    // function remove(address _address) public onlyOwner {
    //     whitelist[_address] = false;
    //     emit RemovedFromWhitelist(_address);
    // }

    function _removeMulti(address[] memory _addresses) internal {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = false;
            _removeAddress(_addresses[i]);
            emit RemovedFromWhitelist(_addresses[i]);
        }
        // emit RemovedMultiFromWhitelist(_addresses);
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelist[_address];
    }

    function getAddresses() public view returns (address[] memory) {
        return addresses;
    }

    function _removeAddress(address _address) internal {
        // Find index
        uint256 index;
        bool flag = false;
        for (uint256 i = 0; i < addresses.length; i++) {
            if(addresses[i] == _address) {
                index = i;
                flag = true;
                break;
            }
        }
        if(flag) {
            addresses[index] = addresses[addresses.length - 1];
            addresses.pop();
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library SafeArrayUint {

    function sum(
        uint256[] memory arr
    ) internal pure returns (uint256) {
        uint i;
        uint256 s = 0;   
        for(i = 0; i < arr.length; i++)
          s = s + arr[i];
        return s;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library SafeArrayAddress {
    function existed(address[] memory _addrs, address _addr)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            if (_addrs[i] == _addr) return true;
        }
        return false;
    }

    function removeAddress(address[] storage _addrs, address _addr)
        internal
        returns (address[] memory)
    {
        // Find index
        uint256 index;
        bool flag = false;
        for (uint256 i = 0; i < _addrs.length; i++) {
            if (_addrs[i] == _addr) {
                index = i;
                flag = true;
                break;
            }
        }
        if (flag) {
            _addrs[index] = _addrs[_addrs.length - 1];
            _addrs.pop();
            return _addrs;
        }
        return _addrs;
    }

    function addAddress(address[] storage _addrs, address _addr)
        internal
        returns (address[] memory)
    {
        _addrs.push(_addr);
        return _addrs;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./../../interfaces/IERC20Extented.sol";

interface SharedConstants {
    enum Statuses {
        COMMING,
        FINALIZE,
        CANCELLED,
        OPENING
    }

    enum UnsoldToken {
        BURN,
        REFUND
    }

    enum PresaleType {
        PUBLIC,
        WHITELIST,
        BLABLA
    }

    struct RegistrationInfo {
        string id;
        bool isRegister;
        uint256 poolWeight;
        string beneficiary; // address in Solona, Near, Ethereum ...
    }

    struct VestingTimeline {
        uint256[] percents;
        uint256[] timestamps; // seconds
    }

    struct VestingHistory {
        uint8 index; // index of vesting timeline
        uint256 amount;
        uint256 claimAt; // seconds
    }

    struct TimeRound {
        uint256 startAt;
        uint256 endAt; // seconds
    }

    struct LaunchpadData {
        /* Token */
        IERC20Extented token;
        IERC20Extented payInToken;
        UnsoldToken unsoldToken;
        PresaleType presaleType;
        /* Sorf and Hard cap */
        uint256 softCap;
        uint256 hardCap;
        /* Presale time */
        TimeRound register;
        TimeRound allocation;
        TimeRound fcfs;
        /* Rate */
        uint256 presaleRate;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IBHOStaking {
    function levelOf(address _addr)
        external
        view
        returns (
            string memory id,
            uint256 minAmount,
            uint256 poolWeight
        );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/IAccessControl.sol";

interface IAddressDecentralization is IAccessControl {
  function getRoleByString(string memory _str) view external returns (bytes32);
  function hasRoleV2(bytes32 _role, address _account) view external returns (bool);
}

import "@openzeppelin/contracts/token/erc20/IERC20.sol";
pragma solidity ^0.8.10;

interface IERC20Extented is IERC20 {
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}