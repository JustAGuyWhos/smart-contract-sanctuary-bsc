/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

/**
 *Submitted for verification at hecoinfo.com on 2022-06-24
*/

pragma solidity ^0.5.17;


interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
  address payable public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);




  modifier onlyOwner() {
    require(msg.sender == owner,'Must contract owner');
    _;
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0),'Must contract owner');
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }


  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;
  }


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract PlayerFactory is Ownable {

  using SafeMath for uint256;

  event NewHunter(uint hunterId, string name,uint256 types,uint256 level,uint256 battle);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;
  uint public hunterPrice = 0.01 ether;
  uint public hunterCount = 0;
  IERC20 usdt ;
  uint256 public decimals=18;
  uint256 public HunterPrice=100;


  struct Player {
    string name;//名字
    uint256 types;//类型：1球员./,2.
    uint256 level;//级别
    string level_name;//级别名称
    uint256 battle;//战斗力
    uint256 dna;//容量

    uint256 status;//状态：1正常./,2.已经加入球队/3.已经在挂卖状态/4.死了
    uint256 shoes;//鞋子
    uint256 Jersey;//上衣
    uint256 trousers;//裤子. 
    uint256 isTeam;//是否在球队0，1
    uint256 readyTime;
  }

  Player[] public players;

  mapping (uint => address) public playerToOwner;
  mapping (address => uint256) ownerPlayerCount;
  mapping (uint => uint) public playerFeedTimes;

  mapping (address => address) public inviter;
  mapping(address => uint256) public mybonus;
  mapping(address => uint256) public tixiantime;
  
  mapping(address => uint256) public userstatus;
  mapping(address => uint256) public usersbouns;
  mapping(address => uint256) public usersbat;
  mapping(address => uint256) public teamnum;


    mapping (uint => address) public touziToOwner;
    mapping (address => uint256) ownerTouziCount;

    mapping (address => uint256) public pktime1;
    mapping (address => uint256) public pknum1;//pknum; pktime;

    mapping (address => uint256) public pktime2;
    mapping (address => uint256) public pknum2;//pknum; pktime;

    mapping (address => uint256) public pktime3;
    mapping (address => uint256) public pknum3;//pknum; pktime;


  function _createPlayer( ) internal {
    uint256 randGailvs = _generateRandomDnanum(6);
    string memory name= "C";
    uint256 randGailv = _generateRandomDnanum(randGailvs);
    randGailv = randGailv % 1000000;
    uint256 _level = 1;
    uint256 types = 1;
    uint256 battle = 40;
    uint256 id = players.push(Player(name, types, 1,'mingzi', battle, randGailv,1,0,0,0,0,uint32(block.timestamp))) - 1;
    playerToOwner[id] = msg.sender;
    ownerPlayerCount[msg.sender] = ownerPlayerCount[msg.sender].add(1);
    //userstatus[msg.sender] = userstatus[msg.sender].add(1);
    hunterCount = hunterCount.add(1);
    emit NewHunter(id, name,types,_level,battle);
  }
//普通开盲盒
  function createPlayer(uint256 timenum,address fatheraddr) public{
    //
//    require(usdt.balanceOf(msg.sender)>=HunterPrice*10**decimals,"USDT balance too low");
 //   usdt.transferFrom(msg.sender,address(this), HunterPrice*10**decimals);
  //  require(fatheraddr!=msg.sender,"Can't do it yourself");
  //  if (inviter[msg.sender] == address(0)) {
  //      inviter[msg.sender] = fatheraddr;
  //  }
    uint256 randGailvs = _generateRandomDnanum(timenum);
    for (uint i = 0; i < timenum; i++) {
        //mybonus[fatheraddr]=mybonus[fatheraddr]+HunterPrice/10;
       // usersbouns[fatheraddr] = usersbouns[fatheraddr].add(1);
        _createPlayer();
        randGailvs++;
    }
  }

//加入球队
  function joinTeam(uint256[] memory _hunterId) public{
    //,address fatheraddr
  //  require(fatheraddr!=msg.sender,"Can't do it yourself");
  //  if (inviter[msg.sender] == address(0)) {
  //      inviter[msg.sender] = fatheraddr;
  //  }
  
      uint counteruser = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (playerToOwner[_hunterId[i]] != msg.sender) {
          counteruser++;
        }
      }
      require(counteruser<=0,"it not is yours");
      uint counteristeam = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (players[_hunterId[i]].isTeam != 0) {
          counteristeam++;
        }
      }
      require(counteristeam<=0,"isteam it is not 0");
      uint counterstatus = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (players[_hunterId[i]].status != 1) {
          counterstatus++;
        }
      }
      require(counterstatus<=0,"isteam it is not 0");
      uint counterzong = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (playerToOwner[_hunterId[i]] == msg.sender) {
          counterzong++;
        }
      }
      require(counterzong<=11,">11");
      for (uint i = 0; i < _hunterId.length; i++) {
        if (playerToOwner[_hunterId[i]] == msg.sender) {
          require(teamnum[msg.sender] <= 11,">11");
          players[_hunterId[i]].isTeam = 1;
          players[_hunterId[i]].status = 2;
          usersbat[msg.sender] = usersbat[msg.sender]+players[_hunterId[i]].battle;
          teamnum[msg.sender] = teamnum[msg.sender]+1;
      }
    }
  }

  //离开球队
  function outTeam(uint256[] memory _hunterId,address fatheraddr) public{
 //,address fatheraddr
  //  require(fatheraddr!=msg.sender,"Can't do it yourself");
  //  if (inviter[msg.sender] == address(0)) {
  //      inviter[msg.sender] = fatheraddr;
  //  }
  
      uint counteruser = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (playerToOwner[_hunterId[i]] != msg.sender) {
          counteruser++;
        }
      }
      require(counteruser<=0,"it not is yours");
      uint counteristeam = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (players[_hunterId[i]].isTeam != 1) {
          counteristeam++;
        }
      }
      require(counteristeam<=0,"isteam it is not 0");
      uint counterstatus = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (players[_hunterId[i]].status != 2) {
          counterstatus++;
        }
      }
      require(counterstatus<=0,"isteam it is not 1");
      uint counterzong = 0;
      for (uint i = 0; i < _hunterId.length; i++) {
        if (playerToOwner[_hunterId[i]] == msg.sender) {
          counterzong++;
        }
      }
      require(counterzong<=11,">11");
      for (uint i = 0; i < _hunterId.length; i++) {
        if (playerToOwner[_hunterId[i]] == msg.sender) {
          require(teamnum[msg.sender] <= 11,">11");
          players[_hunterId[i]].isTeam = 0;
          players[_hunterId[i]].status = 1;
          usersbat[msg.sender] = usersbat[msg.sender]-players[_hunterId[i]].battle;
          teamnum[msg.sender] = teamnum[msg.sender]-1;
      }
    }
    
  }

  //合成nft球员
  function syn(uint256 playid1,uint256 playid2) public{
        require(players[playid1].level == players[playid2].level,"结果未知");
        require(playerToOwner[playid1] == msg.sender,"不是你的");
        require(playerToOwner[playid2] ==msg.sender,"不是你的");
        string memory name="C";
        uint256 _level;
        uint256 battle;
            
        if(players[playid1].level==1){//level_name
            _level=2;
            battle=40;
            name="B";
        }
        if(players[playid1].level==2){
            _level=3;
            battle=50;
            name="A";
        }
        if(players[playid1].level==3){
            _level=4;
            battle=60;
            name="S";
        }
        if(players[playid1].level==4){
            _level=5;
            battle=70;
            name="SS";
        }
        if(players[playid1].level==5){
            _level=6;
            battle=80;
            name="SSS";
        }
        if(players[playid1].level==6){
            _level=7;
            battle=100;
            name="SSR";
        }
        uint256 randGailv = _generateRandomDnanum(playid1);
        randGailv = randGailv % 1000000;
        uint256 id = players.push(Player(name, 1, _level,name, battle, randGailv,1,0,0,0,0,uint32(block.timestamp))) - 1;
        playerToOwner[id] = msg.sender;
        ownerPlayerCount[msg.sender] = ownerPlayerCount[msg.sender].add(1);
        //userstatus[msg.sender] = userstatus[msg.sender].add(1);
        hunterCount = hunterCount.add(1);
        emit NewHunter(id, name,1,_level,battle);
  }
//合成结果查询
  function gatsyn(uint256 playid1,uint256 playid2) external view returns(string memory level_name,uint256 level) {
        require(players[playid1].level == players[playid2].level,"结果未知");
        require(playerToOwner[playid1] == msg.sender,"不是你的");
        require(playerToOwner[playid2] ==msg.sender,"不是你的");
        string memory back_name;
        uint256 back_level;
        if(players[playid1].level==1){//level_name
            back_name = 'C';
            back_level = 2;
        }
        if(players[playid1].level==2){
            back_name = 'B';
            back_level = 3;
        }
        if(players[playid1].level==3){
            back_name = 'A';
            back_level = 4;
        }
        if(players[playid1].level==4){
            back_name = 'S';
            back_level = 5;
        }
        if(players[playid1].level==5){
            back_name = 'SS';
            back_level = 6;
        }
        if(players[playid1].level==6){
            back_name = 'SSR';
            back_level = 7;
        }
        level_name=back_name;
        level=back_level;
  }







 
  function getHuntershertneed(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerPlayerCount[_owner]);
    counter = 0;
    for (uint i = 0; i < players.length; i++) {
      if (playerToOwner[i] == _owner&&players[i].dna<100&&players[i].types!=3) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }



  function _generateRandomDna(string memory _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }
  function _generateRandomDnanum(uint256 _num) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_num,now))) % dnaModulus;
  }

  function setHunterPrice(uint256 _price) external onlyOwner {
    hunterPrice = _price;
  }

  
//设置usdt合约地址
    function setusdtaddress(IERC20 address3,uint256 _decimals) public onlyOwner(){
        usdt = address3;
        decimals=_decimals;
    }
    

//管理员usdt提现
    function  transferOutusdt(address toaddress,uint256 amount,uint256 decimals2)  external onlyOwner {
        usdt.transfer(toaddress, amount*10**decimals2);
    }
    
 //会员的余额提现方法   
    function  tixian(uint256 num)  external returns (bool) {
        bool Limited = tixiantime[msg.sender] !=0;
        require(Limited,"Exchange interval is too short.");
        uint256 lasttimehei = uint32((block.timestamp - tixiantime[msg.sender])/86400 );   
        if(lasttimehei<1){
            lasttimehei=1;
        }  
        uint256 shui;
        if(lasttimehei<=15){
            shui = 30-(lasttimehei*2);
        }else{
            shui = 0;
        }
        mybonus[msg.sender]=mybonus[msg.sender]-num;//
        tixiantime[msg.sender] = block.timestamp;
        usdt.transferFrom(msg.sender,msg.sender, num*10**18);//基金钱包
        return true;
    }


}


contract ClothingFactory is PlayerFactory {
    using SafeMath for uint256;

    event NewClothing(uint clothingId, string name, uint256 ctype,uint256 status,uint256 uid,uint256 nda);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint public cooldownTime = 1 days;
    //uint public clothingPrice = 0.01 ether;
    uint public clothingCount = 0;

    struct Clothing {
        string name;//名字 shoes Jersey trousers
        uint256 ctype;//1鞋子 shoes 2衣服 Jersey 3 裤子 trousers
        uint256 status;//状态：1正常./,2.已经加入部落/3.已经在挂卖状态
        uint256 uid;//会员ID
        uint256 nda;
        uint256 cbat;
        uint256 readyTime;
    }
    Clothing[] public clothings;
    mapping (uint => address) public clothingToOwner;
    mapping (address => uint) ownerClothingCount;
    mapping (uint => uint) public clothingFeedTimes;


    function _generateRandomDnanums(uint256 _num) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(_num,now))) % dnaModulus;
    }

    function _createClothing(uint256 time) internal {
        uint256 ctypes = _generateRandomDnanums(6);
        uint256 ctype;
        ctype = ctypes % 3;
        //uint256 ctype = 12;
        string memory name;
        if(ctype==1){
             name='shoes';
        }
        if(ctype==2){
             name='Jersey';
        }
        if(ctype==3){
             name='trousers';
        }
        uint256 dna = ctypes % 1000000;
        uint id = clothings.push(Clothing(name, ctype, 1,0,dna,5,uint32(block.timestamp)))-1 ;
        clothingToOwner[id] = msg.sender;
        ownerClothingCount[msg.sender] = ownerClothingCount[msg.sender].add(1);
        clothingCount = clothingCount.add(1);
        emit NewClothing(id, name, ctype, 1,0,0);
    }
//创建道具nft
    function createClothing(uint256 time,address fatheraddr) public {
        require(fatheraddr!=msg.sender,"The recommended address cannot be your own");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
        }
        //require(tokenn.balanceOf(msg.sender)>=TribePrice/getprice()*10**decimals,"USDT balance too low");

        //tokenn.transferFrom(msg.sender,address(this), TribePrice/getprice()*10**decimals);
        //mybonus[fatheraddr]=mybonus[fatheraddr]+HorsePrice*10**decimals/(getprice()*10);
        for (uint i = 0; i < time; i++) {
        //mybonus[fatheraddr]=mybonus[fatheraddr]+HunterPrice/10;
        //usersbouns[fatheraddr] = usersbouns[fatheraddr].add(1);
            _createClothing(time);
    }
  }

//穿上装备
  function puton(uint256 yifuid,uint256 playerid) public{
        require(clothingToOwner[yifuid] == msg.sender,"buy can not myself");
        require(teamnum[msg.sender] >0,"==0");
        clothings[yifuid].status = 2;
        if(clothings[yifuid].ctype==1){
            players[playerid].shoes=yifuid;
        }
        if(clothings[yifuid].ctype==2){
            players[playerid].Jersey=yifuid;
        }
        if(clothings[yifuid].ctype==3){
            players[playerid].trousers=yifuid;
        }
        players[playerid].battle = players[playerid].battle+clothings[yifuid].cbat;
        usersbat[msg.sender] = usersbat[msg.sender]+clothings[yifuid].cbat;
        //teamnum[msg.sender] = teamnum[msg.sender]-1;
  }

  /*
      string name;//名字
    uint256 types;//类型：1球员./,2.
    uint256 level;//级别
    string level_name;//级别名称
    uint256 battle;//战斗力
    uint256 dna;//容量

    uint256 status;//状态：1正常./,2.已经加入球队/3.已经在挂卖状态/4.死了
    uint256 shoes;//鞋子
    uint256 Jersey;//上衣
    uint256 trousers;//裤子. 
    uint256 isTeam;//是否在球队0，1
    uint256 readyTime;
  
  */
//脱下装备
  function takeoff (uint256 yifuid,uint256 playerid) public{
        require(clothingToOwner[yifuid] == msg.sender,"buy can not myself");
        require(teamnum[msg.sender] >0,"==0");
        clothings[yifuid].status = 1;
        if(clothings[yifuid].ctype==1){
            players[yifuid].shoes=0;
        }
        if(clothings[yifuid].ctype==2){
            players[playerid].Jersey=0;
        }
        if(clothings[yifuid].ctype==3){
            players[playerid].trousers=0;
        }
        //players[yifuid].trousers=0;
        players[playerid].battle = players[playerid].battle-clothings[yifuid].cbat;
        usersbat[msg.sender] = usersbat[msg.sender]-clothings[yifuid].cbat;
        //teamnum[msg.sender] = teamnum[msg.sender]-1;
  }


//获取会员的英雄
  function getClothingsByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](getClothingsByOwnergeshu(_owner));
    //uint[] memory result;
    uint counter = 0;
    for (uint i = 0; i < clothings.length; i++) {
      if (clothingToOwner[i] == _owner&&clothings[i].status==1&&clothings[i].ctype==1) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  
  function getClothingsByOwnergeshu(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerClothingCount[_owner]);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < clothings.length; i++) {
      if (clothingToOwner[i] == _owner&&clothings[i].status==1&&clothings[i].ctype==1) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }






}
 
contract HunterHelper is ClothingFactory {

  uint public levelUpFee = 0.001 ether;
  uint public day_price =  5;
  uint public day10_price = 40;
  uint public join_price = 40;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(players[_zombieId].level >= _level,'Level is not sufficient');
    _;
  }
  modifier onlyOwnerOf(uint _hunterId) {
    require(msg.sender == playerToOwner[_hunterId],'Zombie is not yours');
    _;
  }

  modifier onlyOwnerOfTribe(uint _hunterId) {
    require(msg.sender == clothingToOwner[_hunterId],'Zombie is not yours');
    _;
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }


  function setLluck1100(uint _fee) external onlyOwner {
  //  luck1100 = _fee;//0-100
  }

//获取在球队里面的球员
  function getTribesByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](getTribesByOwnershu(_owner));
    uint counter = 0;
    for (uint i = 0; i < players.length; i++) {
      if (playerToOwner[i] == _owner&&players[i].status==2&&players[i].types==1&&players[i].isTeam==1) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  //获取在球队里面的球员人数
  function getTribesByOwnershu(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerPlayerCount[_owner]);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < players.length; i++) {
      if (playerToOwner[i] == _owner&&players[i].status==2&&players[i].types==1&&players[i].isTeam==1) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }


//获取球员的英雄
  function getHuntersByOwner(address  _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](getHuntersByOwnergeshu(_owner));
    //uint[] memory result;
    uint counter = 0;
    for (uint i = 0; i < players.length; i++) {
      if (playerToOwner[i] == _owner&&players[i].status==1&&players[i].types==1&&players[i].isTeam==0) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  //获取球员的人数
  function getHuntersByOwnergeshu(address  _owner) public view returns(uint counter) {
    uint[] memory result = new uint[](ownerPlayerCount[_owner]);
    //uint[] memory result;
      counter = 0;
    for (uint i = 0; i < players.length; i++) {
      if (playerToOwner[i] == _owner&&players[i].status==1&&players[i].types==1&&players[i].isTeam==0) {
        result[counter] = i;
        counter++;
      }
    }
    return counter;
  }



  function _triggerCooldown(Player storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
  }



}


contract HunterFeeding is HunterHelper {

  function feed(uint _zombieId) public onlyOwnerOf(_zombieId){
    Player storage myZombie = players[_zombieId];
//    require(_isReady(myZombie));
    playerFeedTimes[_zombieId] = playerFeedTimes[_zombieId].add(1);
    _triggerCooldown(myZombie);
    if(playerFeedTimes[_zombieId] % 10 == 0){
//        uint newDna = myZombie.dna - myZombie.dna % 10 + 8;
 //       _createZombie("zombie's son", newDna);
    }
  }
}

contract HunterAttack is HunterHelper{
    using SafeMath for uint256;
    event NewTouzi(uint256 taocan_type, uint256 amount,uint256 status);
    uint randNonce = 0;
    uint public attackVictoryProbability = 70;
    uint public jianshao = 2;
    mapping(address => uint256) public mybonus;

    string[] Monster = ['乙级联赛','甲级联赛','顶级联赛'];
    uint[] bililow = [1,5,20];
    uint[] bilihight = [60,55,60];
    uint[] bonus = [30,70,100];

    mapping(address => uint256) public daoqitime;
    uint[] touzi_taocan = [3,6,12,36];//投资套餐
    uint[] touzi_shouyi = [7,9,15,30];//投资收益
    uint[] touzi_time = [90,180,360,1080];//投资时间

    struct Touzi {
        uint256 taocan_type;//类型：
        uint256 amount;//金额
        uint256 status;//状态：1正常./,2.已到期/3.已领取
        uint256 readyTime;
    }
    Touzi[] public touzis;
/*

    event NewDianji(uint256 dianji_type, uint256 amount,uint256 readyTime);
    struct Dianji {
        uint256 dianji_type;//类型：123
        uint256 amount;//金额
        uint256 readyTime;
    }
    Dianji[] public dianjis;
    mapping (uint => address) public dianjiToOwner;
    mapping (address => uint256) ownerDianjiCount;
*/


//创建投资
    function createTouzi(uint256 amount,uint256 taocan_type,address fatheraddr) public{
        require(fatheraddr!=msg.sender,"Can't do it yourself");
        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = fatheraddr;
        }
        uint256 id = touzis.push(Touzi(taocan_type, amount, 1,uint32(block.timestamp)+86400*touzi_time[taocan_type])) - 1;
        touziToOwner[id] = msg.sender;
        ownerTouziCount[msg.sender] = ownerTouziCount[msg.sender].add(1);
    }

    //提取投资
    function tiquTouzi(uint256 id) public{
        require(uint32(block.timestamp)>touzis[id].readyTime,"it is not time");
        require(touziToOwner[id]==msg.sender,"it is not yours");
        //require(touzis[id].status==2,"it is not time status");
        touzis[id].status==3;
        //usersbouns
        usersbouns[msg.sender]==usersbouns[msg.sender]+touzis[id].amount+touzi_shouyi[touzis[id].taocan_type]*touzis[id].amount;
    }


    
    function randMod(uint _modulus) internal returns(uint){
        randNonce++;
        return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
    }
    
    function setAttackVictoryProbability(uint _attackVictoryProbability)public onlyOwner{
        attackVictoryProbability = _attackVictoryProbability;
    }
//获取某人的投资列表
    function gettouziList(address  _owner) external view returns(uint[] memory) {
        
        uint[] memory result = new uint[](gettouziListshu(_owner));
        uint counter = 0;
        for (uint i = 0; i < touzis.length; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }

    function gettouziListshu(address  _owner) public  view returns(uint counter) {
        uint[] memory result = new uint[](ownerTouziCount[_owner]);
        
         counter = 0;
        for (uint i = 0; i < touzis.length; i++) {
                result[counter] = i;
                counter++;
        }
        return counter;
    }


    //获取可以买的投资列表
    function gettouziListall() external view returns(uint[] memory) {
        uint[] memory result = new uint[](4);
        uint counter = 0;
        for (uint i = 0; i < 4; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }
    

    

       //获取投资详情
  function gettouziOne(uint id) external view returns(uint taocan,uint shouyi) {
    taocan=touzi_taocan[id];
    shouyi=touzi_time[id];
  }

        //获取投资是否到期
  function gettouzidaoqi(uint id) external view returns(uint256 readyTime) {
      readyTime=touzis[id].readyTime;
  }






    
//获取比赛列表
    function getPktsList() external view returns(uint[] memory) {
        uint[] memory result = new uint[](5);
        uint counter = 0;
        for (uint i = 0; i < 5; i++) {
                result[counter] = i;
                counter++;
        }
        return result;
    }

    
    //获取比赛详情
  function getPkOne(uint id) external view returns(string memory a,uint b) {
    a=Monster[id];
    b=bililow[id];
  //  c=bilihight[id];
  //  d=bonus[id];

  }

    //比赛. pknum; pktime;
    function attackMonster(uint _pkId)external  {
      if(_pkId==1){
        require(pknum1[msg.sender]<5,'>5');
        _attackMonster1();
      }
      if(_pkId==2){
        require(pknum2[msg.sender]<5,'>5');
        _attackMonster2();
      }
      if(_pkId==3){
        require(pknum3[msg.sender]<5,'>5');
        _attackMonster3();
      }
    }

    //比赛1. 
    function _attackMonster1()internal{
      require(pknum1[msg.sender]<5,'>5');
      if(pktime1[msg.sender]<block.timestamp){
        pknum1[msg.sender]=1;
        pktime1[msg.sender]=uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
      }else{
        pknum1[msg.sender]=pknum1[msg.sender]+1;
        usersbouns[msg.sender]=usersbouns[msg.sender]+1;
      }
    }
    //比赛2. 
    function _attackMonster2()internal{
      require(pknum2[msg.sender]<5,'>5');
      if(pktime2[msg.sender]<block.timestamp){
        pknum2[msg.sender]=1;
        pktime2[msg.sender]=uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
      }else{
        pknum2[msg.sender]=pknum2[msg.sender]+1;
        usersbouns[msg.sender]=usersbouns[msg.sender]+1;
      }
    }
    //比赛3. 
    function _attackMonster3()internal{
      require(pknum3[msg.sender]<5,'>5');
      if(pktime3[msg.sender]<block.timestamp){
        pknum3[msg.sender]=1;
        pktime3[msg.sender]=uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
      }else{
        pknum3[msg.sender]=pknum3[msg.sender]+1;
        usersbouns[msg.sender]=usersbouns[msg.sender]+1;
      }
    }
    
    
 
}
contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
}

contract HunterOwnership is HunterHelper, ERC721 {

  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerPlayerCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return playerToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownerPlayerCount[_to] = ownerPlayerCount[_to].add(1);
    ownerPlayerCount[_from] = ownerPlayerCount[_from].sub(1);
    playerToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    zombieApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }

  function takeOwnership(uint256 _tokenId) public {
    require(zombieApprovals[_tokenId] == msg.sender);
    address owner = ownerOf(_tokenId);
    _transfer(owner, msg.sender, _tokenId);
  }
}




contract HunterMarket is HunterOwnership {
    struct hunterSales{
        address payable seller;
        uint price;
    }
    mapping(uint=>hunterSales) public hunterShop;
    uint shopHunterCount;
    uint shopHorseCount;
    uint public tax = 1 finney;
    uint public minPrice = 1 finney;

    event SaleHunter(uint indexed hunterId,address indexed seller);
    event BuyShopHunter(uint indexed hunterId,address indexed buyer,address indexed seller);

//Clothing clothing clothings
    struct clothingSales{
        address payable seller;
        uint price;
    }
    uint shopClothingCount;
    mapping(uint=>clothingSales) public clothingShop;

    event SaleClothing(uint indexed clothingId,address indexed seller);
    event BuyShopClothing(uint indexed clothingId,address indexed buyer,address indexed seller);

//购买市场的衣服
    function buyShopClothing(uint _hunterId)public {
        require(usdt.balanceOf(msg.sender)>=hunterShop[_hunterId].price,"USDT balance too low");
        usdt.transferFrom(msg.sender,address(this), hunterShop[_hunterId].price);
        _transfer(hunterShop[_hunterId].seller,msg.sender, _hunterId);
        delete hunterShop[_hunterId];
        if(players[_hunterId].types == 1){
            shopHunterCount = shopHunterCount.sub(1);
        }else{
            shopHorseCount = shopHorseCount.sub(1);
        }
        players[_hunterId].status=1;
    }
    //获取市场在售Clothing
    function getShopClothing() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopClothingCount);
        uint counter = 0;
        for (uint i = 0; i < clothings.length; i++) {
            if (clothingShop[i].price != 0&&clothings[i].ctype==1&&clothings[i].status==3) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    //出售衣服
    function SaleMyClothing(uint _clothingId,uint _price)public onlyOwnerOf(_clothingId){
      require(players[_clothingId].status == 1,"pople is already online");
      clothingShop[_clothingId] = clothingSales(msg.sender,_price);
      clothings[_clothingId].status=3;
      if(clothings[_clothingId].ctype == 1){
        shopClothingCount = shopHunterCount.add(1);
      }else{
        shopClothingCount = shopClothingCount.add(1);
      }
      emit SaleHunter(_clothingId,msg.sender);
    }
    //获取市场在售猎人
    function getShopClothings() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopClothingCount);
        uint counter = 0;
        for (uint i = 0; i < clothings.length; i++) {
            if (clothingShop[i].price != 0&&clothings[i].ctype==1&&clothings[i].status==3) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }



    function getShopHunteryesno(uint _hunterId) public view returns(uint yesno) {
        uint counter = 0;
        for (uint i = 0; i < players.length; i++) {
            if (hunterShop[i].price != 0 && i==_hunterId) {
                counter=1;
                break;
            }
        }
        return counter;
    }

    function saleMyHunter(uint _hunterId,uint _price)public onlyOwnerOf(_hunterId){
        require(players[_hunterId].status == 1,"pople is already online");
        hunterShop[_hunterId] = hunterSales(msg.sender,_price);
        players[_hunterId].status=3;
        if(players[_hunterId].types == 1){
            shopHunterCount = shopHunterCount.add(1);
        }else{
          shopHorseCount = shopHorseCount.add(1);
        }
        emit SaleHunter(_hunterId,msg.sender);
    }
    function buyShopHunter(uint _hunterId)public {
        require(usdt.balanceOf(msg.sender)>=hunterShop[_hunterId].price,"USDT balance too low");
        usdt.transferFrom(msg.sender,address(this), hunterShop[_hunterId].price);
        _transfer(hunterShop[_hunterId].seller,msg.sender, _hunterId);
        delete hunterShop[_hunterId];
        if(players[_hunterId].types == 1){
            shopHunterCount = shopHunterCount.sub(1);
        }else{
            shopHorseCount = shopHorseCount.sub(1);
        }
        players[_hunterId].status=1;
    }
    //获取市场在售猎人
    function getShopHunters() external view returns(uint[] memory) {
        uint[] memory result = new uint[](shopHunterCount);
        uint counter = 0;
        for (uint i = 0; i < players.length; i++) {
            if (hunterShop[i].price != 0&&players[i].types==1&&players[i].status==3) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }



    function setTax(uint _value)public onlyOwner{
        tax = _value;
    }
    function setMinPrice(uint _value)public onlyOwner{
        minPrice = _value;
    }
}



contract HunterCore is HunterMarket,HunterFeeding,HunterAttack {

    string public constant name = "ZIS";
    string public constant symbol = "ZIS";

    function() external payable {
    }
    
    constructor() public {
      //IERC20 _usdt,uint256 _decimals
     //   usdt=_usdt;
    //    decimals=_decimals;
       owner = msg.sender;
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function checkBalance() external view onlyOwner returns(uint) {
        return address(this).balance;
    }

}