// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC20.sol";
import "../Interfaces/IPool721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Pool721 is IERC721Receiver, IPool721, ReentrancyGuard{

    using SafeMath for uint256;
    address private poolOwner;
    address private rewardAddress;
    uint8 private isToken = 0;
    uint8 private isfinalize = 0;
    uint256 private rewardAmount = 0;
    uint256 private tokenDecimal = 0;
    uint16 private tokenRewardType = 0;
    uint256 private taxAmount = 0;

    struct poolDetails721 {
        uint256 start;
        uint256 stakingEndDate;
        uint256 end;
        uint16 minimumStakers;
        uint16 maximumStakers;
        uint16 tax;
        address nftAddress;
        PoolStatus status;
        bytes projectName;
    }
    mapping(address => poolDetails721) private mapPoolDetails721;

    enum PoolStatus {
        Active,
        Cancel
    }

    enum StakeStatus {
        Active,
        Unstake,
        Claim
    }

    enum RewardStatus {
        Available,
        Claim
    }

    struct Stake {
        uint256 index;
        address stakers;
        uint256 tokenId;
        uint256 stakeTime;
        bool isWinner;
        uint256 nftReward;
        StakeStatus status;
    }
    mapping(address => mapping(uint256 => Stake)) private mapStakes;
    mapping(address => Stake[]) private stakerTokens;
    Stake[] private arrStakes;

    struct Reward {
        uint256 index;
        uint256 tokenId;
        address from;
        RewardStatus status;
    }
    mapping(uint256 => Reward) private mapReward;
    Reward[] private arrRewards;

    modifier onlyPoolOwner(address _caller) {
        require(poolOwner == _caller, "Caller is not the owner");
        _;
    }

    /*
        events
    */
    event claimNftRewardEVT(address by, uint256 tokenId, uint256 time);
    event claimTokenRewardEVT(address by, uint256 amount, uint256 time);
    event claimNftEVT(address owner, uint256 tokenId, uint256 time);
    event addTokenRewardEVT(address tokenAddress, uint256 amount, uint256 time);
    event addNftRewardEVT(address nftAddress, uint256 tokenId, uint256 time);

    function setPoolDetails(
        uint256[] memory _dates,
        uint16[] memory _data,
        address _nftAddress,
        address _poolOwner,
        bytes memory _projectName
    ) external virtual override {
        require(
            _dates[0] <= _dates[1] && _dates[0] >= block.timestamp,
            "Invalid date"
        );
        require(poolOwner == address(0), "POOL721: Pool already initialize");

        poolDetails721 memory pool = poolDetails721(
            _dates[0],
            _dates[1],
            _dates[2],
            _data[0],
            _data[1],
            _data[2],
            _nftAddress,
            PoolStatus.Active,
            _projectName
        );
        poolOwner = _poolOwner;
        mapPoolDetails721[address(this)] = pool;
    }

    function getPoolDetails() external view returns (poolDetails721 memory, address, uint8, uint256, uint16, uint256, address, uint256, uint256) {
        IERC20 _rewardToken = IERC20(rewardAddress);

        return (mapPoolDetails721[address(this)], rewardAddress, 
        isfinalize, _rewardToken.balanceOf(address(this)), tokenRewardType, taxAmount, address(this), tokenDecimal, arrStakes.length);
    }

    /* 
        cancel part
    */

    function cancelPool721() external onlyPoolOwner(msg.sender) {
        poolDetails721 storage _poolDetails = mapPoolDetails721[address(this)];
        require(
            _poolDetails.minimumStakers > arrStakes.length &&
                _poolDetails.stakingEndDate < block.timestamp,
            "Pool721: Minimum requirement is already achieved or staking time is not done"
        );

        if (isToken == 1) {
            IERC20(rewardAddress).transfer(
                poolOwner,
                IERC20(rewardAddress).balanceOf(address(this))
            );
        } else if (isToken == 2) {}
        _poolDetails.status = PoolStatus.Cancel;
        for (uint256 _index = 0; _index < arrStakes.length; _index++) {
            IERC721(_poolDetails.nftAddress).safeTransferFrom(
                address(this),
                arrStakes[_index].stakers,
                arrStakes[_index].tokenId,
                "claimSTK"
            );
        }
    }

    /* 
        reward part
    */

    function addTokenRewards(
        uint256 _amount,
        address _rewardAddress,
        uint16 _tokenRewardType,
        uint16 _tokenDecimal
    ) external {
        
        require(IERC20(_rewardAddress).transferFrom(msg.sender, address(this), _amount),"POOL721: Transaction failed");
        // IERC20(_rewardAddress).transferFrom(msg.sender, address(this), _amount);
        tokenRewardType = _tokenRewardType;
        rewardAddress = _rewardAddress;
        tokenDecimal = _tokenDecimal;
        isToken = 1;
        emit addTokenRewardEVT(_rewardAddress, _amount, block.timestamp);
    }

    function addNftRewards(uint256 _tokenId) external{
        address _nftAddress = mapPoolDetails721[address(this)].nftAddress;
        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == msg.sender, "Token not found");
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId, "reward");
    }

    function _nftReward(uint256 _tokenId, address _from) private {
        address _nftAddress = mapPoolDetails721[address(this)].nftAddress;
        Reward memory _reward = Reward(
            arrRewards.length,
            _tokenId,
            _from,
            RewardStatus.Available
        );
        mapReward[_tokenId] = _reward;
        arrRewards.push(_reward);
        isToken = 2;
        emit addNftRewardEVT(_nftAddress, _tokenId, block.timestamp);
    }

    function getTokenBalance() external view returns (uint256) {
        return IERC20(rewardAddress).balanceOf(address(this));
    }

    function getNFTReward() external view returns (Reward[] memory) {
        return arrRewards;
    }

    /* 
        staking part
    */

    function onERC721Received(
        address to,
        address from,
        uint256 tokenId,
        bytes calldata _data
    ) external virtual override returns (bytes4) {
        if (keccak256(bytes("reward")) == keccak256(_data)) {
            _nftReward(tokenId, from);
        } else if (keccak256(bytes("stake")) == keccak256(_data)) {
            _stakeNft(tokenId, from);
        } else if (keccak256(bytes("claimRWD")) == keccak256(_data)) {
            _claimRewardNft(to, tokenId);
        } else if (keccak256(bytes("claimSTK")) == keccak256(_data)) {
            _claimStakeNft(to, tokenId);
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function _stakeNft(uint256 _tokenId, address _owner) private {
        Stake memory _stake = Stake(
            arrStakes.length,
            _owner,
            _tokenId,
            block.timestamp,
            false,
            0,
            StakeStatus.Active
        );
        mapStakes[_owner][_tokenId] = _stake;
        stakerTokens[_owner].push(_stake);
        arrStakes.push(_stake);
    }

    function stake(uint256 _tokenId) external {
        poolDetails721 memory _poolDetails = mapPoolDetails721[address(this)];
        require(_poolDetails.start <= block.timestamp, "POOL721: Staking is not start");

        if (tokenRewardType == 1) {
            require(_poolDetails.stakingEndDate >= block.timestamp, "POOL721: Staking time is over");
        }

        if (tokenRewardType == 2) {
            require(isfinalize == 1, "POOL721: Pool is reward is not finalize");
        }

        require(isToken != 0, "POOL721: No reward set");
        address _nftAddress = mapPoolDetails721[address(this)].nftAddress;
        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == msg.sender, "Token not found");
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId, "stake");
    }

    function getAllstakers() external view returns (Stake[] memory) {
        return arrStakes;
    }

    /* 
        finalizing part
    */
    function finalize() onlyPoolOwner(msg.sender) external {
      if(isToken == 1){
        if(tokenRewardType == 1){
          _finalizeLockTokenRewardType();
        } else if (tokenRewardType == 2) {
          _finalizePerDayTokenRewardType();
        }
      }else{
        _finalizeNFTReward();
      }
    }

    function _finalizeNFTReward() private{
      for (uint256 i = 0; i < arrRewards.length; i++) {
        uint _random = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, i)));
        uint _index = _random % arrStakes.length;
        Stake storage _arrStaker = arrStakes[_index];
        Stake storage _staker = mapStakes[_arrStaker.stakers][_arrStaker.tokenId];
        Reward storage _arrReward = arrRewards[i];
        _arrStaker.isWinner = true;
        _arrStaker.nftReward = _arrReward.tokenId;
        _staker.isWinner = true;
        _staker.nftReward = _arrReward.tokenId;
      }
      isfinalize = 1;
    }

    function _finalizeLockTokenRewardType() private{
      poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[address(this)];
      require(_mapPoolDetails721.stakingEndDate < block.timestamp, "POOL721: Staking time is not over");
      IERC20 _rewardToken = IERC20(rewardAddress);
      rewardAmount = _rewardToken.balanceOf(address(this)).div(arrStakes.length);
      if (_mapPoolDetails721.tax > 0) {
        taxAmount = (_mapPoolDetails721.tax / 100) * rewardAmount;
      }
      isfinalize = 1;
    }

    function _finalizePerDayTokenRewardType() private{
      poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[address(this)];
      IERC20 _rewardToken = IERC20(rewardAddress);
      uint256 _totalStakingDays = (_mapPoolDetails721.end.sub(_mapPoolDetails721.start)).div(86400);
      rewardAmount = ( _rewardToken.balanceOf(address(this)).div(_totalStakingDays)).div(_mapPoolDetails721.maximumStakers);
      if (_mapPoolDetails721.tax > 0) {
        taxAmount = (_mapPoolDetails721.tax / 100) * rewardAmount;
      }
      isfinalize = 1;
    }

    /* 
        claiming part
    */

    function unStakeTokenReward(uint256 _tokenId) nonReentrant external {
      if (tokenRewardType == 1) {
          _lockTokenRewardType(_tokenId);
      } else if (tokenRewardType == 2) {
          _perDayTokenRewardType(_tokenId);
      }
    }

    function _lockTokenRewardType(uint256 _tokenId) private {
      poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[
          address(this)
      ];
      Stake memory _staker = mapStakes[msg.sender][_tokenId];
      require(
          _staker.stakers == msg.sender,
          "ERC721: claim caller is not owner nor approved"
      );
      require(
          _mapPoolDetails721.end <= block.timestamp,
          "ERC721: invalid claim date"
      );
      require(
          isfinalize == 1,
          "POOL721: Pool not finalize"
      );

      IERC721 _nft = IERC721(_mapPoolDetails721.nftAddress);
      IERC20 _rewardToken = IERC20(rewardAddress);

      uint256 _reward = rewardAmount.sub(taxAmount);

      _rewardToken.transfer(_staker.stakers, _reward);
      _nft.safeTransferFrom(
          address(this),
          _staker.stakers,
          _tokenId,
          "claimSTK"
      );

      emit claimTokenRewardEVT(msg.sender, _reward, block.timestamp);
    }

    function _perDayTokenRewardType(uint256 _tokenId) private {
      poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[
          address(this)
      ];

      Stake memory _staker = mapStakes[msg.sender][_tokenId];
      require(_staker.stakers == msg.sender, "ERC721: claim caller is not owner nor approved");

      IERC721 _nft = IERC721(_mapPoolDetails721.nftAddress);
      IERC20 _rewardToken = IERC20(rewardAddress);

      uint256 _numberDays = (block.timestamp.sub(_staker.stakeTime)).div(86400);
      uint256 _totalRewards = (rewardAmount.mul(_numberDays)).sub((taxAmount).mul(_numberDays));

      _rewardToken.transfer(_staker.stakers, _totalRewards);
      _nft.safeTransferFrom(
          address(this),
          _staker.stakers,
          _tokenId,
          "claimSTK"
      );

      emit claimTokenRewardEVT(msg.sender, _totalRewards, block.timestamp);
    }

    function unStakeNftReward(uint256 _tokenId, bool _iswinner, uint256 _rewardId) nonReentrant external {
      poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[address(this)];
      Stake memory _staker = mapStakes[msg.sender][_tokenId];

      require(_staker.stakers == msg.sender, "ERC721: claim caller is not owner nor approved");
      require(_mapPoolDetails721.end <= block.timestamp, "ERC721: invalid claim date");

      Reward memory _reward = mapReward[_rewardId];
      IERC721 _nft = IERC721(_mapPoolDetails721.nftAddress);

      if (_iswinner == true) {
          require(_reward.status == RewardStatus.Available, "ERC721: reward already claim");
          _nft.safeTransferFrom(
              address(this),
              _staker.stakers,
              _rewardId,
              "claimRWD"
          );
      }
      _nft.safeTransferFrom(
          address(this),
          _staker.stakers,
          _tokenId,
          "claimSTK"
      );
    }

    function _claimStakeNft(address _to, uint256 _tokenId) private {
        Stake storage _staker = mapStakes[_to][_tokenId];
        Stake storage _arrStaker = arrStakes[_staker.index];
        _staker.status = StakeStatus.Claim;
        _arrStaker.status = StakeStatus.Claim;

        emit claimNftEVT(_to, _tokenId, block.timestamp);
    }

    function _claimRewardNft(address _to, uint256 _tokenId) private {
        Reward storage _reward = mapReward[_tokenId];
        Reward storage _arrReward = arrRewards[_reward.index];
        _reward.status = RewardStatus.Claim;
        _arrReward.status = RewardStatus.Claim;
        emit claimNftRewardEVT(_to, _tokenId, block.timestamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

import "./IERC165.sol";

interface IERC721 is IERC165 {
  
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPool721{
    function setPoolDetails(uint256[] memory _dates, uint16[] memory _data, address _nftAddress, address _poolOwner, bytes memory _projectName) external;
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

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}