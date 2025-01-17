// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "./interfaces/IDistributor.sol";
import "./interfaces/IDistributorFactory.sol";
import "./interfaces/ITokenSale.sol";
import "./distributor/MixDistributor.sol";
import "./utils/Operators.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DistributorFactory is Operators, IDistributorFactory {
    ITokenSalePool public tokenSalePool;

    constructor(ITokenSalePool _tokenSalePool) {
        tokenSalePool = _tokenSalePool;
    }

    mapping(string => IDistributor) distributors;

    function setTokenSalePool(ITokenSalePool _tokenSalePool)
        external
        override
        onlyOperator
    {
        tokenSalePool = _tokenSalePool;
    }

    function createDistributor(string calldata _poolID)
        public
        override
        onlyOperator
    {
        IDistributor distributor;

        distributor = new MixDistributor(
            ITokenSale(tokenSalePool.getTokenSaleContractAddress(_poolID))
        );

        distributors[_poolID] = distributor;
        tokenSalePool.setDistributor(_poolID, distributor);
    }

    function createStandaloneDistributor(string calldata _poolID)
        public
        override
        onlyOperator
    {
        IDistributor distributor;

        distributor = new MixDistributor(ITokenSale(address(0)));

        distributors[_poolID] = distributor;
    }

    function createDistributorWithReleaseInfo(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) external override onlyOperator {
        createDistributor(_poolID);
        setReleaseInfoSameInManyCampaigns(
            _poolID,
            _campaignIDs,
            _trancheStartTimestamps,
            _trancheEndTimestamps,
            _percentageOfTranches,
            _trancheTypes
        );
    }

    function createStandaloneDistributorWithReleaseInfo(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) external override onlyOperator {
        createStandaloneDistributor(_poolID);
        setReleaseInfoSameInManyCampaigns(
            _poolID,
            _campaignIDs,
            _trancheStartTimestamps,
            _trancheEndTimestamps,
            _percentageOfTranches,
            _trancheTypes
        );
    }

    function emergencyWithdraw(
        string calldata _poolID,
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external override onlyOwner {
        distributors[_poolID].emergencyWithdraw(_token, _to, _amount);
    }

    function withdraw(string calldata _poolID, string calldata _campaignID)
        external
        override
    {
        distributors[_poolID].withdraw(_campaignID);
    }

    function withdrawManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs
    ) external override {
        uint256 total = 0;
        for (uint32 i = 0; i < _campaignIDs.length; i++) {
            uint256 cWithdrawable = distributors[_poolID].getWithdrawableAmount(
                _campaignIDs[i],
                tx.origin
            );
            total += cWithdrawable;
            if (cWithdrawable > 0)
                distributors[_poolID].withdraw(_campaignIDs[i]);
        }
        if (total == 0) {
            revert("nothing to withdraw");
        }
    }

    function withdrawWithProof(
        string calldata _poolID,
        string calldata _campaignID,
        uint256 _totalAmount,
        bytes32[] calldata _merkleProof
    ) external override {
        distributors[_poolID].withdrawWithProof(
            _campaignID,
            _totalAmount,
            _merkleProof
        );
    }

    function setAdditionalAmountEachCampaign(
        string calldata _poolID,
        address _account,
        uint256 _additionalAmount
    ) external override onlyOperator {
        distributors[_poolID].setAdditionalAmountEachCampaign(
            _account,
            _additionalAmount
        );
    }

    function getAdditionalAmountEachCampaign(
        string calldata _poolID,
        address _account
    ) external view returns (uint256) {
        return distributors[_poolID].getAdditionalAmountEachCampaign(_account);
    }

    function setCampaignClaimData(
        string calldata _poolID,
        string calldata _campaignID,
        bytes32 _merkleTreeRoot,
        IERC20 _token
    ) public override onlyOperator {
        distributors[_poolID].setCampaignClaimData(
            _campaignID,
            _merkleTreeRoot,
            _token
        );
    }

    function setReleaseInfo(
        string calldata _poolID,
        string calldata _campaignID,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) public override onlyOperator {
        distributors[_poolID].setReleaseInfo(
            _campaignID,
            _trancheStartTimestamps,
            _trancheEndTimestamps,
            _percentageOfTranches,
            _trancheTypes
        );
    }

    function setReleaseInfoSameInManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) public override onlyOperator {
        for (uint32 i = 0; i < _campaignIDs.length; i++) {
            setReleaseInfo(
                _poolID,
                _campaignIDs[i],
                _trancheStartTimestamps,
                _trancheEndTimestamps,
                _percentageOfTranches,
                _trancheTypes
            );
        }
    }

    function getWithdrawableAmount(
        string calldata _poolID,
        string calldata _campaignID,
        address _user
    ) external view override returns (uint256) {
        return distributors[_poolID].getWithdrawableAmount(_campaignID, _user);
    }

    function getWithdrawableWithTotalAmount(
        string calldata _poolID,
        string calldata _campaignID,
        address _user,
        uint256 _totalAmount
    ) external view override returns (uint256) {
        return
            distributors[_poolID].getWithdrawableWithTotalAmount(
                _campaignID,
                _user,
                _totalAmount
            );
    }

    function getWithdrawableAmountManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        address _user
    ) external view override returns (uint256) {
        uint256 withdrawable = 0;
        for (uint32 i = 0; i < _campaignIDs.length; i++) {
            withdrawable += distributors[_poolID].getWithdrawableAmount(
                _campaignIDs[i],
                _user
            );
        }
        return withdrawable;
    }

    function getWithdrawedAmount(
        string calldata _poolID,
        string calldata _campaignID,
        address _user
    ) external view override returns (uint256) {
        return distributors[_poolID].getWithdrawedAmount(_campaignID, _user);
    }

    function getWithdrawedAmountManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        address _user
    ) external view override returns (uint256) {
        uint256 withdrawed = 0;
        for (uint32 i = 0; i < _campaignIDs.length; i++) {
            withdrawed += distributors[_poolID].getWithdrawedAmount(
                _campaignIDs[i],
                _user
            );
        }
        return withdrawed;
    }

    function getDistributorAddress(string calldata _poolID)
        external
        view
        override
        returns (address)
    {
        return address(distributors[_poolID]);
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IDistributor {
    enum TrancheType {
        ONCE,
        LINEAR
    }

    struct CampaignClaimData {
        bytes32 merkleRoot;
        IERC20 token;
    }

    function setAdditionalAmountEachCampaign(
        address _account,
        uint256 _additionalAmount
    ) external;

    function getAdditionalAmountEachCampaign(address _account)
        external
        view
        returns (uint256);

    function setReleaseInfo(
        string calldata _campaignID,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        TrancheType[] calldata _trancheTypes
    ) external;

    function withdraw(string calldata _campaignID) external;

    function setCampaignClaimData(
        string calldata _campaignID,
        bytes32 _merkleTreeRoot,
        IERC20 _token
    ) external;

    function withdrawWithProof(
        string calldata _campaignID,
        uint256 _totalAmount,
        bytes32[] calldata _merkleProof
    ) external;

    function emergencyWithdraw(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

    function getWithdrawableAmount(string calldata _campaignID, address _user)
        external
        view
        returns (uint256);

    function getWithdrawableWithTotalAmount(
        string calldata _campaignID,
        address _user,
        uint256 _totalAmount
    ) external view returns (uint256);

    function getWithdrawedAmount(string calldata _campaignID, address _user)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./IDistributor.sol";
import "./ITokenSalePool.sol";

interface IDistributorFactory {
    function setTokenSalePool(ITokenSalePool _tokenSalePool) external;

    function createDistributor(string calldata _poolID) external;

    function createStandaloneDistributor(string calldata _poolID) external;

    function createDistributorWithReleaseInfo(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) external;

    function createStandaloneDistributorWithReleaseInfo(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) external;

    function emergencyWithdraw(
        string calldata _poolID,
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

    function withdraw(string calldata _poolID, string calldata _campaignID)
        external;

    function withdrawManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs
    ) external;

    function setAdditionalAmountEachCampaign(
        string calldata _poolID,
        address _account,
        uint256 _additionalAmount
    ) external;

    function getAdditionalAmountEachCampaign(
        string calldata _poolID,
        address _account
    ) external view returns (uint256);

    function setCampaignClaimData(
        string calldata _poolID,
        string calldata _campaignID,
        bytes32 _merkleTreeRoot,
        IERC20 _token
    ) external;

    function withdrawWithProof(
        string calldata _poolID,
        string calldata _campaignID,
        uint256 _totalAmount,
        bytes32[] calldata _merkleProof
    ) external;

    function setReleaseInfo(
        string calldata _poolID,
        string calldata _campaignID,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) external;

    function setReleaseInfoSameInManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        IDistributor.TrancheType[] calldata _trancheTypes
    ) external;

    function getWithdrawableAmount(
        string calldata _poolID,
        string calldata _campaignID,
        address _user
    ) external view returns (uint256);

    function getWithdrawableWithTotalAmount(
        string calldata _poolID,
        string calldata _campaignID,
        address _user,
        uint256 _totalAmount
    ) external view returns (uint256);

    function getWithdrawableAmountManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        address _user
    ) external view returns (uint256);

    function getWithdrawedAmount(
        string calldata _poolID,
        string calldata _campaignID,
        address _user
    ) external view returns (uint256);

    function getWithdrawedAmountManyCampaigns(
        string calldata _poolID,
        string[] calldata _campaignIDs,
        address _user
    ) external view returns (uint256);

    function getDistributorAddress(string calldata _poolID)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface ITokenSale {
    struct Campaign {
        bytes32 merkleRoot;
        uint64 startTime;
        uint64 endTime;
        uint256 srcCap;
        uint256 rate;
        uint256 totalSource;
        uint256 totalDest;
        bool isFundWithdraw;
        IERC20 token;
        IERC20 acceptToken;
    }

    struct UserInfo {
        uint256 allocation;
        uint256 contribute;
    }

    function setCampaign(
        string calldata _campaignID,
        bytes32 _merkleRoot,
        uint64 _startTime,
        uint64 _endTime,
        uint256 _srcCap,
        uint256 _dstCap,
        IERC20 _acceptToken,
        IERC20 _token
    ) external;

    function setCampaignToken(
        string calldata _campaignID,
        IERC20 _token
    ) external;

    function buy(
        string calldata _campaignID,
        uint128 _index,
        uint256 _maxCap,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) external payable;

    function withdrawSaleFund(string calldata _campaignID, address _to)
        external;

    function emergencyWithdraw(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

    function getUserInfo(string calldata _campaignID, address _user)
        external
        view
        returns (UserInfo memory);

    function getCampaign(string calldata _campaignID)
        external
        view
        returns (Campaign memory);

    function getCampaignIds() external view returns (string[] memory);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./BaseDistributor.sol";

contract MixDistributor is ReentrancyGuard, BaseDistributor {
    using SafeERC20 for IERC20;

    struct ReleaseInfo {
        uint256[] trancheStartTimestamps;
        uint256[] trancheEndTimestamps;
        uint32[] percentageOfTranches;
        TrancheType[] trancheTypes;
    }

    mapping(string => mapping(address => uint256)) claimedAmount;
    mapping(string => ReleaseInfo) releaseInfo;
    mapping(string => CampaignClaimData) campaignStandaloneClaimData;
    mapping(address => uint256) additionalAmountEachCampaign;

    ITokenSale public tokenSale;
    // to be more precise, instead 1/100 use 1/MILLION
    uint32 private constant MILLION = 10**6;

    constructor(ITokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    function setAdditionalAmountEachCampaign(
        address _account,
        uint256 _additionalAmount
    ) external override onlyOwner {
        additionalAmountEachCampaign[_account] = _additionalAmount;
    }

    function getAdditionalAmountEachCampaign(address _account)
        external
        view
        returns (uint256)
    {
        return additionalAmountEachCampaign[_account];
    }

    function setCampaignClaimData(
        string calldata _campaignID,
        bytes32 _merkleTreeRoot,
        IERC20 _token
    ) external override onlyOwner {
        CampaignClaimData storage cd = campaignStandaloneClaimData[_campaignID];
        cd.merkleRoot = _merkleTreeRoot;
        cd.token = _token;
    }

    function setReleaseInfo(
        string calldata _campaignID,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        TrancheType[] calldata _trancheTypes
    ) external override onlyOwner {
        ReleaseInfo storage info = releaseInfo[_campaignID];
        // require(
        //     info.trancheStartTimestamps.length == 0,
        //     "already set tranches"
        // );
        uint32 i;
        uint32 percentageSum = 0;
        require(
            (_trancheStartTimestamps.length == _percentageOfTranches.length) &&
                (_trancheStartTimestamps.length ==
                    _trancheEndTimestamps.length) &&
                (_trancheStartTimestamps.length == _trancheTypes.length),
            "number of timestamps must be equal to number of tranches"
        );
        for (i = 0; i < _percentageOfTranches.length; i++)
            percentageSum += _percentageOfTranches[i];
        require(
            percentageSum == MILLION,
            "total percentage of claiming token must be must be equal to 1000000, since using 4 digits for precision"
        );
        info.trancheStartTimestamps = _trancheStartTimestamps;
        info.trancheEndTimestamps = _trancheEndTimestamps;
        info.percentageOfTranches = _percentageOfTranches;
        info.trancheTypes = _trancheTypes;
        emit ReleaseInfoSet(
            _campaignID,
            _trancheStartTimestamps,
            _trancheEndTimestamps,
            _percentageOfTranches,
            _trancheTypes
        );
    }

    function getWithdrawableAmount(string calldata _campaignID, address _user)
        external
        view
        override
        returns (uint256)
    {
        return _getWithdrawableAmount(_campaignID, _user);
    }

    function getWithdrawableWithTotalAmount(
        string calldata _campaignID,
        address _user,
        uint256 _totalAmount
    ) external view override returns (uint256) {
        return
            _getWithdrawableWithTotalAmount(_campaignID, _user, _totalAmount);
    }

    function getWithdrawedAmount(string calldata _campaignID, address _user)
        external
        view
        override
        returns (uint256)
    {
        return claimedAmount[_campaignID][_user];
    }

    function withdraw(string calldata _campaignID)
        external
        override
        nonReentrant
    {
        address _user = tx.origin;
        uint256 _amount = _getWithdrawableAmount(_campaignID, _user);
        ITokenSale.Campaign memory campaign = tokenSale.getCampaign(
            _campaignID
        );
        claimedAmount[_campaignID][_user] += _amount;

        uint64 decimals = (ERC20(address(campaign.token))).decimals();

        uint256 amount;
        if (decimals < 18) {
            amount = _amount / (10**18 / 10**decimals);
        } else {
            amount = _amount * (10**decimals / 10**18);
        }
        _safeTransfer(campaign.token, _user, amount);
        emit Withdraw(_user, _campaignID, amount);
    }

    function withdrawWithProof(
        string calldata _campaignID,
        uint256 _totalAmount,
        bytes32[] calldata _merkleProof
    ) external override nonReentrant {
        address _user = tx.origin;

        bytes32 leaf = keccak256(
            abi.encodePacked(_campaignID, _user, _totalAmount)
        );
        CampaignClaimData
            memory campaignClaimData = campaignStandaloneClaimData[_campaignID];
        require(
            MerkleProof.verify(
                _merkleProof,
                campaignClaimData.merkleRoot,
                leaf
            ),
            "Invalid withdraw proof"
        );

        uint256 _amount = _getWithdrawableWithTotalAmount(
            _campaignID,
            _user,
            _totalAmount
        );
        require(
            _amount <= _totalAmount - claimedAmount[_campaignID][_user],
            "Exceed max amount of withdraw."
        );
        claimedAmount[_campaignID][_user] += _amount;

        uint64 decimals = (ERC20(address(campaignClaimData.token))).decimals();

        uint256 amount;
        if (decimals < 18) {
            amount = _amount / (10**18 / 10**decimals);
        } else {
            amount = _amount * (10**decimals / 10**18);
        }
        _safeTransfer(campaignClaimData.token, _user, amount);
        emit Withdraw(_user, _campaignID, amount);
    }

    function _getWithdrawableAmount(string calldata _campaignID, address _user)
        internal
        view
        returns (uint256)
    {
        ITokenSale.UserInfo memory userInfo = tokenSale.getUserInfo(
            _campaignID,
            _user
        );
        return _getWithdrawable(_campaignID, _user, userInfo.allocation);
    }

    function _getWithdrawableWithTotalAmount(
        string calldata _campaignID,
        address _user,
        uint256 _totalAmount
    ) internal view returns (uint256) {
        return _getWithdrawable(_campaignID, _user, _totalAmount);
    }

    function _getWithdrawable(
        string calldata _campaignID,
        address _user,
        uint256 _baseTotalAmount
    ) internal view returns (uint256) {
        uint256 _totalAmount = _baseTotalAmount +
            additionalAmountEachCampaign[_user];
        ReleaseInfo memory _info = releaseInfo[_campaignID];
        if (block.timestamp < _info.trancheStartTimestamps[0]) {
            return 0;
        }
        uint256 totalClaimable = 0;
        for (uint32 i = 0; i < _info.trancheStartTimestamps.length; i++) {
            if (block.timestamp >= _info.trancheStartTimestamps[i]) {
                if (_info.trancheTypes[i] == TrancheType.ONCE) {
                    totalClaimable +=
                        (_info.percentageOfTranches[i] * _totalAmount) /
                        MILLION;
                } else if (_info.trancheTypes[i] == TrancheType.LINEAR) {
                    uint256 timestamp = _min(
                        block.timestamp,
                        _info.trancheEndTimestamps[i]
                    );
                    totalClaimable +=
                        (((_totalAmount *
                            (timestamp - _info.trancheStartTimestamps[i])) /
                            (_info.trancheEndTimestamps[i] -
                                _info.trancheStartTimestamps[i])) *
                            _info.percentageOfTranches[i]) /
                        MILLION;
                }
            }
        }

        return totalClaimable - claimedAmount[_campaignID][_user];
    }

    function _min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a < _b) return _a;
        return _b;
    }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Operators is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet operators;

    event OperatorsAdded(address[] _operators);
    event OperatorsRemoved(address[] _operators);

    constructor() {}

    modifier onlyOperator() {
        require(
            isOperator(_msgSender()) || (owner() == _msgSender()),
            "caller is not operator"
        );
        _;
    }

    function addOperators(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators.add(_operators[i]);
        }
        emit OperatorsAdded(_operators);
    }

    function removeOperators(address[] calldata _operators) external onlyOwner {
        for (uint256 i = 0; i < _operators.length; i++) {
            operators.remove(_operators[i]);
        }
        emit OperatorsRemoved(_operators);
    }

    function isOperator(address _operator) public view returns (bool) {
        return operators.contains(_operator);
    }

    function numberOperators() external view returns (uint256) {
        return operators.length();
    }

    function operatorAt(uint256 i) external view returns (address) {
        return operators.at(i);
    }

    function getAllOperators()
        external
        view
        returns (address[] memory _operators)
    {
        _operators = new address[](operators.length());
        for (uint256 i = 0; i < _operators.length; i++) {
            _operators[i] = operators.at(i);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./ITokenSale.sol";
import "./IDistributor.sol";

interface ITokenSalePool {
    struct Pool {
        string poolID;
        string poolName;
        uint256 poolCreationTime;
        ITokenSale tokenSale;
        IDistributor distributor;
    }

    function createPool(
        string calldata _poolID,
        string calldata _poolName,
        uint256 _poolCreationTime
    ) external;

    function setDistributor(string calldata _poolID, IDistributor _distributor)
        external;

    function setCampaign(
        string calldata _poolID,
        string calldata _campaignID,
        bytes32 _merkleRoot,
        uint64 _startTime,
        uint64 _endTime,
        uint256 _srcCap,
        uint256 _dstCap,
        IERC20 _acceptToken,
        IERC20 _token
    ) external;

    function setCampaignToken(
        string calldata _poolID,
        string calldata _campaignID,
        IERC20 _token
    ) external;

    function setCampaignTokenOfPool(string calldata _poolID, IERC20 _token)
        external;

    function buy(
        string calldata _poolID,
        string calldata _campaignID,
        uint128 _index,
        uint256 _maxCap,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) external payable;

    function withdrawSaleFund(
        string calldata _poolID,
        string calldata _campaignID,
        address _to
    ) external;

    function withdrawSaleFundOfPool(string calldata _poolID, address _to)
        external;

    function emergencyWithdraw(
        string calldata _poolID,
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

    function getUserInfo(
        string calldata _poolID,
        string calldata _campaignID,
        address _user
    ) external view returns (ITokenSale.UserInfo memory);

    function getCampaignIds(string calldata _poolID)
        external
        view
        returns (string[] memory);

    function getCampaign(string calldata _poolID, string calldata _campaignID)
        external
        view
        returns (ITokenSale.Campaign memory);

    function getTokenSaleContractAddress(string calldata _poolID)
        external
        view
        returns (address);

    function getDistributorAddress(string calldata _poolID)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
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

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/ITokenSale.sol";
import "../interfaces/IDistributor.sol";

abstract contract BaseDistributor is IDistributor, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    event ReleaseInfoSet(
        string _campaignID,
        uint256[] trancheStartTimestamps,
        uint256[] trancheEndTimestamps,
        uint32[] percentageOfTranches,
        TrancheType[] trancheTypes
    );

    event Withdraw(address user, string _campaignID, uint256 _amount);

    constructor() {}

    function setAdditionalAmountEachCampaign(
        address _account,
        uint256 _additionalAmount
    ) external virtual override {}

    function emergencyWithdraw(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external override onlyOwner {
        _safeTransfer(_token, _to, _amount);
    }

    function _safeTransfer(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) internal {
        if (_token == IERC20(address(0))) {
            (bool success, ) = _to.call{value: _amount}("");
            require(success, "transfer failed");
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

    function withdraw(string calldata _campaignID) external virtual override {}

    function withdrawWithProof(
        string calldata _campaignID,
        uint256 _totalAmount,
        bytes32[] calldata _merkleProof
    ) external virtual override {}

    function setCampaignClaimData(
        string calldata _campaignID,
        bytes32 _merkleTreeRoot,
        IERC20 _token
    ) external virtual override;

    function setReleaseInfo(
        string calldata _campaignID,
        uint256[] calldata _trancheStartTimestamps,
        uint256[] calldata _trancheEndTimestamps,
        uint32[] calldata _percentageOfTranches,
        TrancheType[] calldata _trancheTypes
    ) external virtual override onlyOwner {}

    function getWithdrawableAmount(string calldata _campaignID, address _user)
        external
        view
        virtual
        override
        returns (uint256)
    {}

    function getWithdrawableWithTotalAmount(
        string calldata _campaignID,
        address _user,
        uint256 _totalAmount
    ) external view virtual override returns (uint256) {}

    function getWithdrawedAmount(string calldata _campaignID, address _user)
        external
        view
        virtual
        override
        returns (uint256)
    {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}