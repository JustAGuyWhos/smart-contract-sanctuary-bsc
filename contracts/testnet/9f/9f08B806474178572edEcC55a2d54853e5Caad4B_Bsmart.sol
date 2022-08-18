/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

pragma solidity >=0.4.21 <=0.7.6;

contract Bsmart {
  address public ownerWallet;
  struct UserStruct {
    bool isExist;
    uint256 id;
    uint256 referrerID;
    address[] referral;
    mapping(uint256 => uint256) levelExpired;
  }
  uint256 REFERRER_1_LEVEL_LIMIT = 2;
  uint256 PERIOD_LENGTH = 100 days;

  mapping(uint256 => uint256) public LEVEL_PRICE;

  mapping(address => UserStruct) public users;
  mapping(uint256 => address) public userList;
  uint256 public currUserID = 0;

  event RegLevelEvent(
    address indexed _user,
    address indexed _referrer,
    uint256 _time
  );

  event BuyLevelEvent(address indexed _user, uint256 _level, uint256 _time);
  event ProlongateLevelEvent(
    address indexed _user,
    uint256 _level,
    uint256 _time
  );
  event GetMoneyForLevelEvent(
    address indexed _user,
    address indexed _referral,
    uint256 _level,
    uint256 _time
  );

  constructor() {
    ownerWallet = msg.sender;
    LEVEL_PRICE[1] = 0.03 ether;
    LEVEL_PRICE[2] = 0.05 ether;
    LEVEL_PRICE[3] = 0.10 ether;
    LEVEL_PRICE[4] = 0.40 ether;
    LEVEL_PRICE[5] = 1 ether;
    LEVEL_PRICE[6] = 2.5 ether;
    LEVEL_PRICE[7] = 5 ether;
    LEVEL_PRICE[8] = 10 ether;
    LEVEL_PRICE[9] = 20 ether;
    LEVEL_PRICE[10] = 40 ether;

    currUserID++;
    users[ownerWallet].isExist = true;
    users[ownerWallet].id = currUserID;
    users[ownerWallet].referrerID = 0;
    users[ownerWallet].referral = new address[](0);
    userList[currUserID] = ownerWallet;
    for (uint256 i = 1; i <= 10; i++) {
      users[ownerWallet].levelExpired[i] = 55555555555;
    }
  }

  fallback() external payable {
    uint256 level;

    if (msg.value == LEVEL_PRICE[1]) level = 1;
    else if (msg.value == LEVEL_PRICE[2]) level = 2;
    else if (msg.value == LEVEL_PRICE[3]) level = 3;
    else if (msg.value == LEVEL_PRICE[4]) level = 4;
    else if (msg.value == LEVEL_PRICE[5]) level = 5;
    else if (msg.value == LEVEL_PRICE[6]) level = 6;
    else if (msg.value == LEVEL_PRICE[7]) level = 7;
    else if (msg.value == LEVEL_PRICE[8]) level = 8;
    else if (msg.value == LEVEL_PRICE[9]) level = 9;
    else if (msg.value == LEVEL_PRICE[10]) level = 10;
    else revert("Incorrect Value send");

    if (users[msg.sender].isExist) buyLevel(level);
    else if (level == 1) {
      uint256 refId = 0;
      address referrer = bytesToAddress(msg.data);

      if (users[referrer].isExist) refId = users[referrer].id;
      else revert("Incorrect referrer");

      regUser(refId);
    } else revert("Please buy first level for 0.03 ETH");
  }

  receive() external payable {
    // custom function code
  }

  function regUser(uint256 _referrerID) public payable {
    require(!users[msg.sender].isExist, "User exist");
    require(
      _referrerID > 0 && _referrerID <= currUserID,
      string(abi.encodePacked("Incorrect referrer Id", _referrerID))
    );
    require(msg.value == LEVEL_PRICE[1], "Incorrect Value");
    if (
      users[userList[_referrerID]].referral.length >= REFERRER_1_LEVEL_LIMIT
    ) {
      _referrerID = users[findFreeReferrer(userList[_referrerID])].id;
    }

    currUserID++;
    users[msg.sender].isExist = true;
    users[msg.sender].id = currUserID;
    users[msg.sender].referrerID = _referrerID;
    users[msg.sender].referral = new address[](0);
    userList[currUserID] = msg.sender;

    users[msg.sender].levelExpired[1] = block.timestamp + PERIOD_LENGTH;

    users[userList[_referrerID]].referral.push(msg.sender);

    payForLevel(1, msg.sender);

    emit RegLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
  }

  function buyLevel(uint256 _level) public payable {
    require(users[msg.sender].isExist, "User not exist");
    require(_level > 0 && _level <= 10, "Incorrect level");

    if (_level == 1) {
      require(msg.value == LEVEL_PRICE[1], "Incorrect Value");
      users[msg.sender].levelExpired[1] += PERIOD_LENGTH;
    } else {
      require(msg.value == LEVEL_PRICE[_level], "Incorrect Value");

      for (uint256 l = _level - 1; l > 0; l--)
        require(
          users[msg.sender].levelExpired[l] >= block.timestamp,
          "Buy the previous level"
        );

      if (users[msg.sender].levelExpired[_level] == 0)
        users[msg.sender].levelExpired[_level] =
          block.timestamp +
          PERIOD_LENGTH;
      else users[msg.sender].levelExpired[_level] += PERIOD_LENGTH;
    }

    payForLevel(_level, msg.sender);

    emit BuyLevelEvent(msg.sender, _level, block.timestamp);
  }

  function payForLevel(uint256 _level, address _user) internal {
    address referer;
    address referer1;
    address referer2;
    address referer3;
    address referer4;

    if (_level == 1 || _level == 6) {
      referer = userList[users[_user].referrerID];
    } else if (_level == 2 || _level == 7) {
      referer1 = userList[users[_user].referrerID];
      referer = userList[users[referer1].referrerID];
    } else if (_level == 3 || _level == 8) {
      referer1 = userList[users[_user].referrerID];
      referer2 = userList[users[referer1].referrerID];
      referer = userList[users[referer2].referrerID];
    } else if (_level == 4 || _level == 9) {
      referer1 = userList[users[_user].referrerID];
      referer2 = userList[users[referer1].referrerID];
      referer3 = userList[users[referer2].referrerID];
      referer = userList[users[referer3].referrerID];
    } else if (_level == 5 || _level == 10) {
      referer1 = userList[users[_user].referrerID];
      referer2 = userList[users[referer1].referrerID];
      referer3 = userList[users[referer2].referrerID];
      referer4 = userList[users[referer3].referrerID];
      referer = userList[users[referer4].referrerID];
    }

    if (!users[referer].isExist) referer = userList[1];

    bool sent = false;
    if (users[referer].levelExpired[_level] >= block.timestamp) {
      sent = address(uint160(referer)).send(LEVEL_PRICE[_level]);

      if (sent) {
        emit GetMoneyForLevelEvent(
          msg.sender,
          referer,
          _level,
          block.timestamp
        );
      }
    }
    if (!sent) {
      // emit lostMoneyForLevelEvent(referer, msg.sender, _level, block.timestamp);

      payForLevel(_level, referer);
    }
  }

  function findFreeReferrer(address _user) public view returns (address) {
    if (users[_user].referral.length < REFERRER_1_LEVEL_LIMIT) return _user;
    address[] memory referrals = new address[](126);
    referrals[0] = users[_user].referral[0];
    referrals[1] = users[_user].referral[1];

    address freeReferrer;
    bool noFreeReferrer = true;

    for (uint256 i = 0; i < 126; i++) {
      if (users[referrals[i]].referral.length == REFERRER_1_LEVEL_LIMIT) {
        if (i < 62) {
          referrals[(i + 1) * 2] = users[referrals[i]].referral[0];
          referrals[(i + 1) * 2 + 1] = users[referrals[i]].referral[1];
        }
      } else {
        noFreeReferrer = false;
        freeReferrer = referrals[i];
        break;
      }
    }

    require(!noFreeReferrer, "No Free Referrer");

    return freeReferrer;
  }

  function viewUserReferral(address _user)
    public
    view
    returns (address[] memory)
  {
    return users[_user].referral;
  }

  function viewUserLevelExpired(address _user, uint256 _level)
    public
    view
    returns (uint256)
  {
    return users[_user].levelExpired[_level];
  }

  function bytesToAddress(bytes memory bys)
    private
    pure
    returns (address addr)
  {
    assembly {
      addr := mload(add(bys, 20))
    }
  }
}