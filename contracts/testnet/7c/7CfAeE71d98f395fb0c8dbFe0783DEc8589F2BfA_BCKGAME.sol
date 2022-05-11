// SPDX-License-Identifier: MIT
pragma solidity >=0.8.12;

interface INFT {
    function nftTemp(uint256 tokenId) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IBCKS {
    function burn(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface Game {
    struct GameInfo {
        uint256 id;
        bool status; //游戏状态
        address master; //管理者
        bool isTemp; //是否临时
        uint256 level; //等级
        uint256 exp; //经验
        uint256 upgrade; //升级经验
        uint256 upgradeTime; //升级时间
        uint8 lands; //土地数量
        uint256 nextHarvestAt; //下一次收获时间
    }

    struct LandInfo {
        bool status; //是否激活
        uint256 nextHarvestAt; //下一次收获时间
        uint8 times; //收获次数
        uint256 steal; //被偷菜次数
        uint256 effectiveAt; //有效期
    }
}

interface IGAME is Game {
    function gameInfo(uint256 _tokenId)
        external
        view
        returns (GameInfo memory game);

    function landInfo(uint256 _tokenId, uint8 _position)
        external
        view
        returns (LandInfo memory land);
}

contract BCKGAME is Game, IERC721Receiver {
    string public name = "BCKGAME";
    string public symbol = "BCKGAME";
    address public owner;

    uint256 public baseBck = 1e18; //基础BCK
    uint256 public landRequried = 2000000 * baseBck; //土地需求
    uint256 public seedRequried = 10000000 * baseBck; //种子需求
    uint256 public baseUpgradeTime = 300; //基础升级时间 3600
    uint256 public epoch = 120; //周期 86400
    uint256 public seedEffective = 10 * epoch; //种子有效期 40days
    uint256 public rewardRate = 8; //奖励比例 level*8

    address public depositAddress;
    address public bcksAddress;
    address public bckAddress;
    address public fertAddress;
    address public nftAddress;
    address public upgradeGameAddress;

    mapping(uint256 => GameInfo) public gameInfo; // 游戏信息
    mapping(uint256 => mapping(uint8 => LandInfo)) public landInfo; // 土地信息
    mapping(uint256 => mapping(uint256 => mapping(uint8 => uint256)))
        public stealInfo; // 偷菜信息 tokenid, tokenid, position, date

    uint256 public totalReward; //总奖励
    uint256 public totalUsers; //总用户数
    bool public isSteal = true; //是否开启偷菜

    mapping(address => uint256) public userInfo; // 用户信息
    mapping(address => uint256) public userReward; // 用户奖励
    mapping(address => address) public invite; // 邀请人
    mapping(address => uint256) public inviteCount; // 邀请人数
    mapping(address => uint256) public inviteReward; // 邀请奖励

    event StartGame(address indexed _master, uint256 _tokenId);
    event GameOver(address indexed _master, uint256 _tokenId);
    event OpenLand(address indexed _master, uint8 _position);
    event Harvest(address indexed _master, uint256 _amount);
    event Upgrade(uint256 _tokenId, uint256 _level);
    event Plant(uint256 _tokenId, uint8 _position);
    event Steal(
        address indexed _user,
        address indexed _master,
        uint8 _position,
        uint256 _amount
    );
    event InviteReward(address indexed _user, uint256 _amount);
    event BindInviter(address indexed _user, address indexed _inviter);

    constructor(address _upgradeGame) {
        owner = msg.sender;
        upgradeGameAddress = _upgradeGame;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    modifier onlyLandOwner(uint256 _tokenId) {
        require(
            INFT(nftAddress).ownerOf(_tokenId) == msg.sender,
            "Error: not land owner"
        );
        _;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setRequried(uint256 _landRequried, uint256 _seedRequried)
        public
        onlyOwner
    {
        landRequried = _landRequried;
        seedRequried = _seedRequried;
    }

    function setEpoch(uint256 _epoch) public onlyOwner {
        epoch = _epoch;
    }

    function setUpgradeTime(uint256 _upgradeTime) public onlyOwner {
        baseUpgradeTime = _upgradeTime;
    }

    function setSeedEffective(uint256 _seedEffective) public onlyOwner {
        seedEffective = _seedEffective;
    }

    function setIsSteal(bool _isSteal) public onlyOwner {
        isSteal = _isSteal;
    }

    function setGameAddress(
        address _depositAddress,
        address _bckAddress,
        address _bcksAddress,
        address _fertAddress,
        address _nftAddress
    ) public onlyOwner {
        depositAddress = _depositAddress;
        bckAddress = _bckAddress;
        bcksAddress = _bcksAddress;
        fertAddress = _fertAddress;
        nftAddress = _nftAddress;
    }

    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
    }

    function getGameInfo(address _master)
        public
        view
        returns (GameInfo memory game, LandInfo[] memory landInfos)
    {
        uint256 _tokenId = userInfo[_master];
        game = gameInfo[_tokenId];
        landInfos = new LandInfo[](game.lands);
        for (uint8 i = 1; i <= game.lands; i++) {
            landInfos[i - 1] = landInfo[_tokenId][i];
        }

        return (game, landInfos);
    }

    function getMyGame(address _master)
        public
        view
        returns (GameInfo memory game)
    {
        uint256 _tokenId = userInfo[_master];
        game = gameInfo[_tokenId];
        return game;
    }

    // 升级游戏
    function upgradeGame(uint256 _tokenId) public {
        require(userInfo[msg.sender] == 0, "already start game");
        GameInfo storage newGame = gameInfo[_tokenId];
        require(newGame.id == 0 && !newGame.status, "game is already started");

        GameInfo memory game = IGAME(upgradeGameAddress).gameInfo(_tokenId);
        require(game.status, "game is not started");
        require(game.master == msg.sender, "not the master");

        INFT(nftAddress).safeTransferFrom(
            upgradeGameAddress,
            address(this),
            _tokenId
        );

        gameInfo[_tokenId] = GameInfo({
            id: game.id,
            status: game.status,
            master: game.master,
            isTemp: game.isTemp,
            level: game.level,
            exp: (game.level + 1)**2 * 25,
            upgrade: game.upgrade,
            upgradeTime: game.upgradeTime,
            lands: game.lands,
            nextHarvestAt: game.nextHarvestAt
        });

        gameInfo[_tokenId].lands = getMaxLand(_tokenId);

        for (uint8 i = 1; i <= game.lands; i++) {
            LandInfo memory land = IGAME(upgradeGameAddress).landInfo(
                _tokenId,
                i
            );
            landInfo[_tokenId][i] = LandInfo({
                status: land.status,
                nextHarvestAt: land.nextHarvestAt,
                times: land.times,
                steal: land.steal,
                effectiveAt: land.effectiveAt
            });
        }

        totalUsers += 1;
        userInfo[msg.sender] = _tokenId;
        emit StartGame(msg.sender, _tokenId);
    }

    // 开始游戏
    function startGame(uint256 _tokenId) public onlyLandOwner(_tokenId) {
        require(userInfo[msg.sender] == 0, "already start game");
        GameInfo storage game = gameInfo[_tokenId];
        require(!game.status, "game is already started");

        bool isTemp = INFT(nftAddress).nftTemp(_tokenId);
        totalUsers += 1;
        game.status = true; //激活
        game.id = _tokenId;
        INFT(nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        if (game.level == 0) {
            game.lands = 1; //初始化土地数量
        }

        if (isTemp) {
            game.isTemp = isTemp; //是否临时
            game.lands = 3; //初始化土地数量
        }

        game.upgrade = (game.level + 1)**2 * 25; //升级所需经验
        userInfo[msg.sender] = _tokenId;
        game.master = msg.sender; //管理者

        emit StartGame(msg.sender, _tokenId);
    }

    // 关闭游戏
    function gameOver() public {
        uint256 _tokenId = userInfo[msg.sender];
        require(userInfo[msg.sender] > 0, "not start game");

        GameInfo storage game = gameInfo[_tokenId];
        require(game.status, "game is not started");

        game.status = false; //关闭
        game.master = address(0); //管理者
        userInfo[msg.sender] = 0;
        totalUsers -= 1;
        INFT(nftAddress).safeTransferFrom(address(this), msg.sender, _tokenId);

        emit GameOver(msg.sender, _tokenId);
    }

    // 开辟土地
    function openLand(uint8 _position) public {
        uint256 _tokenId = userInfo[msg.sender];
        require(userInfo[msg.sender] > 0, "not start game");

        GameInfo storage game = gameInfo[_tokenId];
        require(game.status, "game is not started");

        require(
            _position > 0 && _position <= game.lands,
            "position is not valid"
        );

        LandInfo storage land = landInfo[_tokenId][_position];
        require(!land.status, "land is already open");

        TransferHelper.safeTransferFrom(
            bckAddress,
            msg.sender,
            depositAddress,
            landRequried
        );
        land.status = true;
        emit OpenLand(msg.sender, _position);
    }

    // 升级土地
    function upgradeLand() public {
        uint256 _tokenId = userInfo[msg.sender];
        require(userInfo[msg.sender] > 0, "not start game");

        GameInfo storage game = gameInfo[_tokenId];
        require(game.status, "game is not started");
        require(game.level < 100, "game level is max");
        require(!game.isTemp, "game is temp");
        require(block.timestamp > game.upgradeTime, "not upgrade time");

        TransferHelper.safeTransferFrom(
            fertAddress,
            msg.sender,
            depositAddress,
            game.upgrade * baseBck
        );

        game.exp = game.upgrade;
        game.upgrade = (game.level + 1) * 50 + game.exp - 25; //升级所需经验
        game.level += 1; //升级
        game.upgradeTime = block.timestamp + game.level * baseUpgradeTime; //升级时间
        game.lands = getMaxLand(_tokenId); //土地数量
        emit Upgrade(_tokenId, game.level);
    }

    // 土地种植
    function plant(uint8 _position) public {
        uint256 _tokenId = userInfo[msg.sender];
        require(userInfo[msg.sender] > 0, "not start game");

        GameInfo storage game = gameInfo[_tokenId];
        require(game.status, "game is not started");
        require(
            _position > 0 && _position <= game.lands,
            "position is not valid"
        );

        LandInfo storage land = landInfo[_tokenId][_position];
        require(land.status, "land is not open");
        require(
            block.timestamp > land.effectiveAt || land.times == 0,
            "land is already planted"
        );

        if (game.isTemp) {
            require(land.nextHarvestAt == 0, "game is temp");
        }

        TransferHelper.safeTransferFrom(
            bckAddress,
            msg.sender,
            depositAddress,
            seedRequried
        );
        land.times = 30;
        land.effectiveAt = block.timestamp + seedEffective;
        land.nextHarvestAt = block.timestamp + epoch;
        _updateGameHarvest(_tokenId);

        emit Plant(_tokenId, _position);
    }

    // 偷菜
    function steal(uint256 _tokenId, uint8 _position) public {
        require(isSteal, "steal is not open");

        uint256 myToken = userInfo[msg.sender];
        require(myToken != _tokenId, "can not steal yourself");

        GameInfo storage myGame = gameInfo[myToken];
        GameInfo storage game = gameInfo[_tokenId];

        require(game.status && myGame.status, "game is not started");
        require(myGame.level > game.level, "game level is not enough");

        uint256 reward = rewardAmount(_tokenId, _position);
        require(reward > 0, "land is not ready");

        LandInfo storage land = landInfo[_tokenId][_position];
        require(land.steal < 2, "steal is max");

        uint256 stealDay = stealInfo[myToken][_tokenId][_position];
        require(land.nextHarvestAt > stealDay, "steal is not ready");
        stealInfo[myToken][_tokenId][_position] = block.timestamp;

        land.steal += 1;
        reward = (reward * 5) / 100;
        userReward[msg.sender] += reward;
        totalReward += reward;

        TransferHelper.safeTransferFrom(
            bckAddress,
            depositAddress,
            msg.sender,
            reward
        );

        emit Steal(msg.sender, game.master, _position, reward);
    }

    // 收获
    function harvest(uint8 _position) public {
        uint256 _tokenId = userInfo[msg.sender];
        require(userInfo[msg.sender] > 0, "not start game");

        LandInfo storage land = landInfo[_tokenId][_position];
        require(land.status, "land is not open");
        require(land.times > 0, "land is not ready");
        require(land.effectiveAt > block.timestamp, "effectiveAt error");
        require(
            block.timestamp > land.nextHarvestAt,
            "Error: nextHarvestAt epoch"
        );
        _harvest(_tokenId, _position);
        _updateGameHarvest(_tokenId);
    }

    // 一键收菜
    function harvestAll() public {
        uint256 _tokenId = userInfo[msg.sender];
        require(userInfo[msg.sender] > 0, "not start game");

        GameInfo storage game = gameInfo[_tokenId];
        require(game.status, "game is not started");
        require(
            block.timestamp > game.nextHarvestAt,
            "Error: nextHarvestAt epoch"
        );

        for (uint8 i = 1; i <= game.lands; i++) {
            LandInfo storage land = landInfo[_tokenId][i];
            if (
                land.status &&
                land.times > 0 &&
                land.effectiveAt > block.timestamp
            ) {
                _harvest(_tokenId, i);
            }
        }
        _updateGameHarvest(_tokenId);
    }

    function _harvest(uint256 _tokenId, uint8 _position) private {
        uint256 reward = rewardAmount(_tokenId, _position);
        if (reward > 0) {
            LandInfo storage land = landInfo[_tokenId][_position];
            if (land.times > 0) {
                land.times -= 1;
                land.nextHarvestAt = block.timestamp + epoch;
                userReward[msg.sender] += reward;
                totalReward += reward;

                uint256 _lv = getGameLevel(_tokenId);
                uint256 bcks = 1 * baseBck;
                bcks += (_lv * 5 * baseBck) / 10;
                IBCKS(bcksAddress).mint(msg.sender, bcks);
                reward -= (reward * 5 * land.steal) / 100; //被偷菜次数
                TransferHelper.safeTransferFrom(
                    bckAddress,
                    depositAddress,
                    msg.sender,
                    reward
                );
                land.steal = 0;

                takeInviteReward(msg.sender, reward);

                emit Harvest(msg.sender, reward);
            }
        }
    }

    function _updateGameHarvest(uint256 _tokenId) private {
        GameInfo storage game = gameInfo[_tokenId];
        uint256 maxNextAt = block.timestamp + epoch;
        uint256 _nextHarvestAt = maxNextAt;
        for (uint8 i = 1; i <= game.lands; i++) {
            LandInfo memory land = landInfo[_tokenId][i];
            if (land.status && land.times > 0) {
                if (land.nextHarvestAt < _nextHarvestAt) {
                    _nextHarvestAt = land.nextHarvestAt;
                }
            }
        }
        game.nextHarvestAt = _nextHarvestAt;
    }

    // 拿邀请奖励
    function takeInviteReward(address _user, uint256 _reward) private {
        address inviter1 = invite[_user];
        if (inviter1 != address(0)) {
            (uint256 reward1, ) = getInviteReward(inviter1, _reward);

            inviteReward[inviter1] += reward1;
            totalReward += reward1;
            TransferHelper.safeTransferFrom(
                bckAddress,
                depositAddress,
                inviter1,
                reward1
            );

            address inviter2 = invite[inviter1];
            if (inviter2 != address(0)) {
                (, uint256 reward2) = getInviteReward(inviter2, _reward);
                inviteReward[inviter2] += reward2;
                totalReward += reward2;
                TransferHelper.safeTransferFrom(
                    bckAddress,
                    depositAddress,
                    inviter2,
                    reward2
                );
            }
        }
    }

    function getInviteReward(address _inviter, uint256 _reward)
        public
        view
        returns (uint256, uint256)
    {
        uint256 _tokenId = userInfo[_inviter];
        if (_tokenId > 0) {
            GameInfo storage game = gameInfo[_tokenId];
            uint256 _lv = getGameLevel(_tokenId);
            if (game.status && _lv > 0) {
                uint256 reward1;
                if (_lv >= 25) {
                    reward1 = (_reward * 7) / 100;
                } else {
                    reward1 = ((_lv / 5 + 2) * _reward) / 100;
                }

                uint256 rate2 = 20;
                if (_lv < 5) {
                    rate2 = 5;
                } else if (_lv < 10) {
                    rate2 = 10;
                } else if (_lv < 15) {
                    rate2 = 15;
                }

                return (reward1, (_reward * rate2) / 1000);
            }
        }
        return (0, 0);
    }

    function rewardAmount(uint256 _tokenId, uint8 _position)
        public
        view
        returns (uint256)
    {
        LandInfo storage land = landInfo[_tokenId][_position];
        if (block.timestamp > land.nextHarvestAt && land.times > 0) {
            return (getGameLevel(_tokenId) * rewardRate + 35) * 10000 * baseBck;
        }
        return 0;
    }

    function getGameLevel(uint256 _tokenId) public view returns (uint256) {
        GameInfo storage game = gameInfo[_tokenId];
        if (block.timestamp > game.upgradeTime) {
            return game.level;
        } else {
            return game.level - 1;
        }
    }

    function getMaxLand(uint256 _tokenId) public view returns (uint8) {
        uint8 maxLand = 1;
        GameInfo storage game = gameInfo[_tokenId];
        uint256 _lv = game.level;
        if (_lv >= 20) {
            maxLand = 9;
        } else if (_lv >= 10) {
            maxLand = 6;
        } else if (_lv >= 5) {
            maxLand = 3;
        }

        return maxLand;
    }

    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) public onlyOwner {
        TransferHelper.safeTransfer(token, to, amount);
    }

    // 绑定邀请人
    function setInviter(address inviter_) external virtual returns (bool) {
        require(invite[msg.sender] == address(0));
        require(msg.sender != inviter_);
        // 上级必须已经绑定过邀请人或者绑定管理员帐号
        require(
            inviter_ == owner || invite[inviter_] != address(0),
            "inviter must be binded"
        );

        invite[msg.sender] = inviter_;
        inviteCount[inviter_] += 1;
        emit BindInviter(msg.sender, inviter_);
        return true;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}