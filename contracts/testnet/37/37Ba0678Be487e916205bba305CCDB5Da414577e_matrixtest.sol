/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract matrixtest is Ownable {
  using SafeMath for uint256;

  /* # structure of users.data #
  users.data[0] = ref reward from direct partner 40%
  users.data[1] = ref reward from member level 1 10%
  users.data[2] = ref reward from member level 2 10%
  users.data[3] = ref reward from member level 3 10%
  users.data[4] = ref reward from member level 4 25%
  users.data[5] = total account spender on contract
  */

  struct User {
    bool registered;
    address referral;
    mapping(uint256 => bool) activeLevels;
    mapping(uint256 => uint256) data;
  }

  struct Matrix {
    address currentreferral;
    address[] reffereeLv1;
    address[] reffereeLv2;
    address closepart;
    uint256 partnercount;
    uint256 reinvest;
  }

  mapping(address => User) private users;
  mapping(address => mapping(uint256 => Matrix)) private matrix;

  mapping(address => mapping(uint256 => address[])) public matrix32;
  
  uint256 private registered;
  uint256 private denominator;
  bool private ispause;
  bool private finalize;
  bool private reentrantcy;

  mapping(address => uint256) private getidfromaddress;
  mapping(uint256 => address) private getaddressfromid;

  mapping(uint256 => uint256) private refdividend;
  mapping(uint256 => uint256) private levelprice;



  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor() Ownable(msg.sender) {

    refdividend[0] = 400;
    refdividend[1] = 100;
    refdividend[2] = 110;
    refdividend[3] = 120;
    refdividend[4] = 250;

    denominator = 1000;

    levelprice[0] = 100;
    levelprice[1] = 200;
    levelprice[2] = 400;
    levelprice[3] = 800;
    levelprice[4] = 1600;
    levelprice[5] = 3200;
    levelprice[6] = 6400;
    levelprice[7] = 12800;
    levelprice[8] = 25000;
    levelprice[9] = 50000;
    levelprice[10] = 100000;
    levelprice[11] = 200000;
    levelprice[12] = 400000;
    levelprice[13] = 800000;
    levelprice[14] = 1500000;
    levelprice[15] = 3000000;

  }

  function totaluser() external view returns (uint256) {
    return registered;
  }

  function isRegistered(address account) external view returns (bool) {
    return users[account].registered;
  }

  function isActiveLevels(address account,uint256 level) external view returns (bool) {
    return users[account].activeLevels[level];
  }

  function getUsersData(address account,uint256 index) external view returns (uint256) {
    return users[account].data[index];
  }

  function refertoaddress(address account) external view returns (address) {
    return users[account].referral;
  }

  function isPause() external view returns (bool) {
    return ispause;
  }

  function getRefDividend(uint256 level) external view returns (uint256) {
    return refdividend[level];
  }

  function getLevelPrice(uint256 level) external view returns (uint256) {
    return levelprice[level];
  }

  function id2address(uint256 id) external view returns (address) {
    return getaddressfromid[id];
  }

  function address2id(address account) external view returns (uint256) {
    return getidfromaddress[account];
  }

  function switchSystem() external onlyOwner() returns (bool) {
    ispause = !ispause;
    return true;
  }

  function getMatrix(uint256 id,uint256 level) external view returns
    (
    address,
    address[] memory,
    address[] memory,
    address,
    uint256,
    uint256
    ) {
    address account = getaddressfromid[id];
    return (
      matrix[account][level].currentreferral,
      matrix[account][level].reffereeLv1,
      matrix[account][level].reffereeLv2,
      matrix[account][level].closepart,
      matrix[account][level].partnercount,
      matrix[account][level].reinvest
    );
  }
  function getMatrix32Address(address viewer,uint256 level) external view returns (address[] memory){
    return getMatrix32(viewer,level);
  }

  function getMatrix32(address viewer,uint256 level) internal view returns (address[] memory){
    address[] memory path = new address[](32);
    path[0] = address(0);
    path[1] = viewer;
    path[2] = getMatrixTree(viewer,level,1);
    path[3] = getMatrixTree(viewer,level,2);
    path[4] = getMatrixTree(viewer,level,3);
    path[5] = getMatrixTree(viewer,level,4);
    path[6] = getMatrixTree(viewer,level,5);
    path[7] = getMatrixTree(viewer,level,6);
    address branch4  = path[4];
    address branch5  = path[5];
    address branch6  = path[6];
    address branch7  = path[7];
    path[8] = getMatrixTree(branch4,level,1);
    path[9] = getMatrixTree(branch4,level,2);
    path[10] = getMatrixTree(branch5,level,1);
    path[11] = getMatrixTree(branch5,level,2);
    path[12] = getMatrixTree(branch6,level,1);
    path[13] = getMatrixTree(branch6,level,2);
    path[14] = getMatrixTree(branch7,level,1);
    path[15] = getMatrixTree(branch7,level,2);
    path[16] = getMatrixTree(branch4,level,3);
    path[17] = getMatrixTree(branch4,level,4);
    path[18] = getMatrixTree(branch4,level,5);
    path[19] = getMatrixTree(branch4,level,6);
    path[20] = getMatrixTree(branch5,level,3);
    path[21] = getMatrixTree(branch5,level,4);
    path[22] = getMatrixTree(branch5,level,5);
    path[23] = getMatrixTree(branch5,level,6);
    path[24] = getMatrixTree(branch6,level,3);
    path[25] = getMatrixTree(branch6,level,4);
    path[26] = getMatrixTree(branch6,level,5);
    path[27] = getMatrixTree(branch6,level,6);
    path[28] = getMatrixTree(branch7,level,3);
    path[29] = getMatrixTree(branch7,level,4);
    path[30] = getMatrixTree(branch7,level,5);
    path[31] = getMatrixTree(branch7,level,6);
    return path;
  }

  function getMatrixTree(address account,uint256 level,uint256 branch) internal view returns (address) {
    if(branch==1 && matrix[account][level].reffereeLv1.length>0){
      return matrix[account][level].reffereeLv1[0];
    }else if(branch==2 && matrix[account][level].reffereeLv1.length>1){
      return matrix[account][level].reffereeLv1[1];
    }else if(branch==3 && matrix[account][level].reffereeLv2.length>0){
      return matrix[account][level].reffereeLv2[0];
    }else if(branch==4 && matrix[account][level].reffereeLv2.length>1){
      return matrix[account][level].reffereeLv2[1];
    }else if(branch==5 && matrix[account][level].reffereeLv2.length>2){
      return matrix[account][level].reffereeLv2[2];
    }else if(branch==6 && matrix[account][level].reffereeLv2.length>3){
      return matrix[account][level].reffereeLv2[3];
    }else{
      return address(0);
    }
  }

  function isColor(address account,address viewer,uint256 level) external view returns (uint256) {
    if(users[account].referral == address(0) ){
      return 1; //free partner
    }else if(users[account].referral == viewer){
      return 2; //direct partner
    }else if(
      users[account].referral == getRecycleMatrix(viewer,level,1)
      || users[account].referral == getRecycleMatrix(viewer,level,2)
      || users[account].referral == getRecycleMatrix(viewer,level,3)
      || users[account].referral == getRecycleMatrix(viewer,level,4)
    ){
      return 3; //spill from over
    }else{
      return 4; // spill from below
    }
  }

  function finalization(address[] memory triangles) external onlyOwner() returns (bool) {
    require(!finalize,"finalize fail : already finalized");
    require(triangles.length==7,"finalize fail : triangles tree length revert");

    finalize = true;

    registeration(triangles[0],address(0));
    registeration(triangles[1],triangles[0]);
    registeration(triangles[2],triangles[0]);
    registeration(triangles[3],triangles[1]);
    registeration(triangles[4],triangles[1]);
    registeration(triangles[5],triangles[2]);
    registeration(triangles[6],triangles[2]);

    return true;
  }

  function registerationExt(address account,address ref) external payable noReentrant() returns (bool) {
    require(finalize,"registeration fail : waiting project finalize");
    require(!ispause,"registeration fail : contract was temporary pause");
    require(!users[account].registered,"registeration fail : already registered");
    require(users[ref].registered,"registeration fail : not found reference in matrix");
    require(msg.value>=levelprice[1],"registeration fail : ext not enought fund");

    registeration(account,ref);
    users[account].data[5] = users[account].data[5].add(msg.value);

    return true;
  }

  function registerationFor(address account,address ref) external onlyOwner() returns (bool) {
    require(finalize,"registeration fail : waiting project finalize");
    require(!ispause,"registeration fail : contract was temporary pause");
    require(!users[account].registered,"registeration fail : already registered");
    require(users[ref].registered,"registeration fail : not found reference in matrix");

    registeration(account,ref);

    return true;
  }

  function buynewslotExt(address account,uint256 level) external payable noReentrant() returns (bool) {
    require(finalize,"upgrade fail : waiting project finalize");
    require(!ispause,"upgrade fail : contract was temporary pause");
    require(users[account].activeLevels[level.sub(1)],"upgrade fail : buy previous level first");
    require(!users[account].activeLevels[level],"upgrade fail : already in current level");
    require(msg.value>=levelprice[level],"upgrade fail : ext not enought fund");
    require(level>1 && level<15,"upgrade fail : buy level is out of range");
    
    users[account].activeLevels[level] = true;

    users[account].data[5] = users[account].data[5].add(msg.value);

    address ref = findFreeReferral(account,level);
    address directpartner = users[account].referral;
    signMatrix(account,ref,level);
    payment(account,directpartner,level);

    return true;
  }

  function buynewslotFor(address account,uint256 level) external onlyOwner() returns (bool) {
    require(finalize,"upgrade fail : waiting project finalize");
    require(!ispause,"upgrade fail : contract was temporary pause");
    require(users[account].activeLevels[level.sub(1)],"upgrade fail : buy previous level first");
    require(!users[account].activeLevels[level],"upgrade fail : already in current level");
    require(level>1 && level<15,"upgrade fail : buy level is out of range");
    
    users[account].activeLevels[level] = true;

    address ref = findFreeReferral(account,level);
    signMatrix(account,ref,level);

    return true;
    
  }

  function batchregister(address[] memory accounts,address ref) external returns (bool) {
    require(users[ref].registered,"registeration fail : not found reference in matrix");

    uint256 i = 0;
    do{
      require(!users[accounts[i]].registered,"registeration fail : already registered");
      registeration(accounts[i],ref);
      i++;
    }while(i<accounts.length);

    return true;
  }

  function registeration(address register,address ref) internal {
    registered = registered.add(1);
    getidfromaddress[register] = registered;
    getaddressfromid[registered] = register;
    users[register].registered = true;
    users[register].referral = ref;
    users[register].activeLevels[1] = true;

    signMatrix(register,ref,1);
    payment(register,ref,1);

  }

  function payment(address register,address directref,uint256 level) internal {
      uint256 amount = levelprice[level];
      address[] memory receiver = new address[](5);
      uint256[] memory sendValue = new uint256[](5);
      receiver[0] = safeRecaiver(directref);
      receiver[1] = safeRecaiver(getRecycleMatrix(register,1,1));
      receiver[2] = safeRecaiver(getRecycleMatrix(register,1,2));
      receiver[3] = safeRecaiver(getRecycleMatrix(register,1,3));
      receiver[4] = safeRecaiver(getRecycleMatrix(register,1,4));
      sendValue[0] = amount.mul(refdividend[0]).div(denominator);
      sendValue[1] = amount.mul(refdividend[1]).div(denominator);
      sendValue[2] = amount.mul(refdividend[2]).div(denominator);
      sendValue[3] = amount.mul(refdividend[3]).div(denominator);
      sendValue[4] = amount.mul(refdividend[4]).div(denominator);
      safeTransfer(receiver[0],sendValue[0]);
      safeTransfer(receiver[1],sendValue[1]);
      safeTransfer(receiver[2],sendValue[2]);
      safeTransfer(receiver[3],sendValue[3]);
      users[receiver[0]].data[0] = users[receiver[0]].data[0].add(sendValue[0]);
      users[receiver[1]].data[1] = users[receiver[1]].data[1].add(sendValue[1]);
      users[receiver[2]].data[2] = users[receiver[2]].data[2].add(sendValue[2]);
      users[receiver[3]].data[3] = users[receiver[3]].data[3].add(sendValue[3]);
      if( matrix[receiver[4]][level].closepart != receiver[2] ){
        safeTransfer(receiver[4],sendValue[4]);
        users[receiver[4]].data[4] = users[receiver[4]].data[4].add(sendValue[4]);
      }
  }

  function signMatrix(address register,address ref,uint256 level) internal {
    updateMatrixFirst(register,ref,level);
    if(shouldUpdateCycle(register,level)){      
      address reinvestaddress = getRecycleMatrix(register,level,4);
      uint256 previous = matrix[reinvestaddress][level].reinvest;
      matrix32[reinvestaddress][previous] = getMatrix32(register,level);
      matrix[reinvestaddress][level].reffereeLv1 = new address[](0);
      matrix[reinvestaddress][level].reffereeLv2 = new address[](0);
      matrix[reinvestaddress][level].closepart = address(0);
      matrix[reinvestaddress][level].reinvest++;
      signMatrix(reinvestaddress,matrix[reinvestaddress][level].currentreferral,level);
      payment(reinvestaddress,users[reinvestaddress].referral,level);
    }
  }

  function updateMatrixFirst(address register,address ref,uint256 level) internal {
    if(matrix[ref][level].reffereeLv1.length<2){

      matrix[ref][level].reffereeLv1.push(register);
      matrix[matrix[ref][level].currentreferral][level].reffereeLv2.push(register);
      matrix[register][level].currentreferral = ref;
      matrix[ref][level].partnercount++;

    }else{

      address branch_left = matrix[ref][level].reffereeLv1[0];
      address branch_right = matrix[ref][level].reffereeLv1[1];

      if(matrix[branch_left][level].reffereeLv1.length<2){

        matrix[branch_left][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_left;
        matrix[branch_left][level].partnercount++;
        matrix[ref][level].partnercount++;

      }else if(matrix[branch_right][level].reffereeLv1.length<2){

        matrix[branch_right][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_right;
        matrix[branch_right][level].partnercount++;
        matrix[ref][level].partnercount++;

        if(matrix[branch_right][level].reffereeLv1.length==2){
        matrix[ref][level].closepart = register;
        }

      }else{

        if(matrix[branch_left][level].reffereeLv2.length<4){
          
          updateMatrixSecond(register,branch_left,level);
          if(matrix[branch_left][level].reffereeLv2.length==4){
            matrix[branch_left][level].closepart = register;
          }

        }else if(matrix[branch_right][level].reffereeLv2.length<4){

          updateMatrixSecond(register,branch_right,level);
          if(matrix[branch_right][level].reffereeLv2.length==4){
            matrix[branch_right][level].closepart = register;
          }

        }else{

          address sub_branch_0 = matrix[ref][level].reffereeLv2[0];
          address sub_branch_1 = matrix[ref][level].reffereeLv2[1];
          address sub_branch_2 = matrix[ref][level].reffereeLv2[2];
          address sub_branch_3 = matrix[ref][level].reffereeLv2[3];

          if(matrix[sub_branch_0][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_0,level);
            if(matrix[sub_branch_0][level].reffereeLv2.length==4){
            matrix[sub_branch_0][level].closepart = register;
            }

          }else if(matrix[sub_branch_1][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_1,level);
            if(matrix[sub_branch_1][level].reffereeLv2.length==4){
            matrix[sub_branch_1][level].closepart = register;
            }

          }else if(matrix[sub_branch_2][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_2,level);
            if(matrix[sub_branch_2][level].reffereeLv2.length==4){
            matrix[sub_branch_2][level].closepart = register;
            }

          }else if(matrix[sub_branch_3][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_3,level);
            if(matrix[sub_branch_3][level].reffereeLv2.length==4){
            matrix[sub_branch_3][level].closepart = register;
            }

          }else{
            revert();
          }

        }

      }
    }
  }

  function updateMatrixSecond(address register,address ref,uint256 level) internal {
    if(matrix[ref][level].reffereeLv1.length<2){

      matrix[ref][level].reffereeLv1.push(register);
      matrix[matrix[ref][level].currentreferral][level].reffereeLv2.push(register);
      matrix[register][level].currentreferral = ref;
      matrix[ref][level].partnercount++;

    }else{

      address branch_left = matrix[ref][level].reffereeLv1[0];
      address branch_right = matrix[ref][level].reffereeLv1[1];

      if(matrix[branch_left][level].reffereeLv1.length<2){

        matrix[branch_left][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_left;
        matrix[branch_left][level].partnercount++;
        matrix[ref][level].partnercount++;

      }else if(matrix[branch_right][level].reffereeLv1.length<2){

        matrix[branch_right][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_right;
        matrix[branch_right][level].partnercount++;
        matrix[ref][level].partnercount++;

        if(matrix[branch_right][level].reffereeLv1.length==2){
        matrix[ref][level].closepart = register;
        }

      }

    }
  }

  function shouldUpdateCycle(address account,uint256 level) internal view returns (bool) {
    address upperMatrix = matrix[account][level].currentreferral;
    address checkerMatrix = matrix[upperMatrix][level].currentreferral;
    address minorMatrix = matrix[checkerMatrix][level].currentreferral;
    address alphaMatrix = matrix[minorMatrix][level].currentreferral;

    address[] memory sub_branch = matrix[alphaMatrix][level].reffereeLv2;

    if(
      alphaMatrix != address(0) &&
      matrix[sub_branch[0]][level].closepart != address(0) &&
      matrix[sub_branch[1]][level].closepart != address(0) &&
      matrix[sub_branch[2]][level].closepart != address(0) &&
      matrix[sub_branch[3]][level].closepart != address(0)
    ){
      return true;
    }else{
      return false;
    }

  }

  function getRecycleMatrix(address account,uint256 level,uint256 upline) internal view returns (address) {
    address upperMatrix = matrix[account][level].currentreferral;
    address checkerMatrix = matrix[upperMatrix][level].currentreferral;
    address minorMatrix = matrix[checkerMatrix][level].currentreferral;
    address alphaMatrix = matrix[minorMatrix][level].currentreferral;
    if(upline==1){
    return upperMatrix;
    }else if(upline==2){
    return checkerMatrix;
    }else if(upline==3){
    return minorMatrix;
    }else if(upline==4){
    return alphaMatrix;
    }else{
    return owner;
    }
  }

  function findFreeReferral(address account,uint256 level) public view returns (address) {
    do{
      if(users[users[account].referral].activeLevels[level]){
        return users[account].referral;
      }
      account = users[account].referral;
    }while(true);
    return address(0);
  }

  function safeRecaiver(address account) internal view returns (address) {
    if(account==address(0)){
      return owner;
    }else{
      return account;
    }
  }

  function safeTransfer(address recipient,uint256 amount) internal returns (bool) {
    (bool success, ) = recipient.call{ value : amount }("");
    require(success,"safe transfer fail!");
    return true;
  }

  receive() external payable { }
}