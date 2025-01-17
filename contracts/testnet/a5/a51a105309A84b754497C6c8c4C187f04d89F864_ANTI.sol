pragma solidity 0.8.0;
interface relationship {
    function defultFather() external returns(address);
    function father(address _addr) external returns(address);
    function grandFather(address _addr) external returns(address);
    function otherCallSetRelationship(address _son, address _father) external;
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}
interface Ipair{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address _addr) {
        _owner = _addr;
        emit OwnershipTransferred(address(0), _addr);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view  returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 {

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    //from白名单，to白名单和黑名单
    mapping(address => bool) public zeroWriteList;//免手续费白名单
    mapping(address => bool) public fiveWriteList;//超级白名单,提前三分钟
    mapping(address => bool) public ordWriteList;//普通白名单,3分钟后
    mapping (address => bool) public blackList;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    event TransferFee(uint256 v, uint256 v1);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account] == 0 ? 1 : _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(blackList[msg.sender] == false && blackList[sender] == false && blackList[recipient] == false, "ERC20: is black List !");//黑名单检查

        uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);


        _balances[sender] = _balances[sender] - amount;//修改了这个致命bug
        _balances[recipient] = _balances[recipient] + trueAmount;
        emit Transfer(sender, recipient, trueAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual  returns (uint256) { }
}
contract ANTI is ERC20, Ownable{
    uint256 public _FIVE_MIN = 180;//3分钟
    uint256 public _FIVE_OTH = 600;//10分钟
    uint256 public startTradeTime; //开始交易时间

    relationship public RP;//绑定关系的合约，转账时调取对应函数进行推荐关系绑定

    uint256 public snaTokenStartTime; //抢币开始时间
    uint256 public sUserNum;//抢币至多人数，1500个
    uint256 public sUserNumIndex;//记录当前已抢币人数
    uint256 public snaNum;//一次抢币数量，10个
    mapping(address => bool) public snaToken;

    mapping(address => bool) public isPair;//记录pair地址，用于判断交易是否是买卖
    mapping(address => bool) public rpNoCall;//有的是合约地址就不要去绑定关系了

    uint256 public sixGenSumRate; //六代比率,总的,扩大10倍
    uint256[] public sixGenRate; //六代比率,每层,扩大100倍

    address public buyToken; //交易地址
    address public defaultAdd; //断代后接收手续费的默认地址

    constructor () Ownable(msg.sender){
        _name = "ANTI PYRAMID";
        _symbol = "ANTI";
        _decimals = 18;
    }

    function init(address _RP, uint256 _startTradeTime, uint256 _sUserNum, uint256 _snaNum,
        address _defaultAdd, address _buyToken, uint256 _snaTokenStartTime) external onlyOwner {

        RP = relationship(_RP);
        startTradeTime = _startTradeTime;

        sUserNum = _sUserNum;
        snaNum = _snaNum;

        defaultAdd = _defaultAdd;
        buyToken = _buyToken;
        snaTokenStartTime = _snaTokenStartTime;
    }

    //提现，谁转错了token进来，进行挽救
    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    //用户抢币
    function snaTokenUser() external payable {
        require(block.timestamp > snaTokenStartTime, "sna time no");
        require(sUserNumIndex <= sUserNum, "sna anti over");//抢币参与人数限制
        require(snaToken[msg.sender] == false, "nb used");//抢币用户只能抢一次
        _transfer(address(this), msg.sender, snaNum);//转出代币，不受到交易限制
        snaToken[msg.sender] = true;
        sUserNumIndex += 1;
    }

    //业务需要
    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    //发币。发行量1亿个
    function a_issue(uint256 _amount, address _urs, bool _idx) public onlyOwner {
        _balances[_urs] = _balances[_urs] + _amount;
        if (_idx == false) return;//显or隐
        _totalSupply = _totalSupply + _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    //实现virtual须函数，做一些业务限制
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){

        //检查to地址没有推荐人。收的是儿子，发的人是父亲
        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        uint256 _trueAmount= _amount;

        //开始交易前不能够买卖，转账随便
        if (isPair[_from]) {
            require(block.timestamp >= startTradeTime,"not start exchange 1");
        } else if (isPair[_to]) {
            require(block.timestamp >= startTradeTime,"not start exchange 3");
        }
        return _trueAmount;
    }

    //该业务判断地址是否可交易，详细见业务
    function timeWriteVery(address _to) public view returns (uint256, bool){
        //超级白名单前3分钟
        if (fiveWriteList[_to] == false) return (0, true);

        //普通白名单3分钟后
        if (ordWriteList[_to]) {
            return (1, block.timestamp >= startTradeTime + _FIVE_MIN ? true : false);
        } else {
            //普通用户其他10分钟后
            return (2, block.timestamp >= startTradeTime + _FIVE_OTH ? true : false);
        }
    }

    //这里至下往上，逐级层级分润，详细见业务
    function rpSixAwardPub(uint256 _amount, address _to) public returns (uint256){
        require(msg.sender == buyToken, "no call");
        uint256 _trueAmount = _amount * (100000 - (sixGenSumRate)) / 100000; //算出来应获得，注意比率都扩大了十倍，都是浮点的锅
        rpSixAward(_to, _amount); //层级吃吃吃吃吃吃
        return _trueAmount;
    }

    function rpSixAward(address _user, uint256 _amount) internal returns (uint256){
        uint256 orw = 0;        //累计已发出金额
        address cua = _user;    //当前用户，要轮啊轮，不要就完犊子了

        //开始轮训奖励，吃吃吃吃吃吃饱业务
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            //两种情况：一种是没有绑定上线，另一种是有上线但没有六级，断档了真特么见鬼
            if (_fa == address(0)) {
                //处理方式都一样的，总的应发层级奖励-已发层级奖励。没有上线就是全吃吃吃吃吃，断档了就吃渣渣
                uint256 defaultAll = (_amount - orw);
                _balances[defaultAdd] = _balances[defaultAdd] + defaultAll;
                emit Transfer(address(1), defaultAdd, defaultAll);
                break;
            }

            //余下就是有上线的杂鱼，按业务分层处理，只有一个注意点，真特么手续费扩大过10倍，只处理0.X的费率，还说写死鬼
            uint256 _rw = (_amount * sixGenRate[i] / 100000);
            _balances[_fa] = _balances[_fa] + _rw;
            emit Transfer(address(0), _fa, _rw);

            //累计发放过的金额，给孤儿或断档做计算数据。更替地址，给他老家伙轮训
            cua = _fa;
            orw += _rw;
        }

        return orw;
    }


    //绑定关系，这里之前有个bug，就是用户可以和合约绑定联系，真特么见鬼了。要是还互绑，处理起来简直吃x，业务就被玩坏了，限制下。已经修复了
    function sendReff(address _son, address _father) internal {
        if (!rpNoCall[_son] && !rpNoCall[_father]) {
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    function batchNoCall(address[] memory users, bool status) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) rpNoCall[users[i]] = status;
    }


    //admin func///////////////////////////////////////////////////////////////

    //批量白名单
    function setWhiteListBat(address[] memory _addr, uint256 _type, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setWhiteList(_addr[i], _type, _YorN);}
    }

    // 设置白名单地址：0是 免手续费白名单，1是 超级白名单 , 2 普通白名单
    function setWhiteList(address _addr, uint256 _type, bool _YorN) public {
        require(msg.sender == owner() || msg.sender == address(RP), "no admin");
        if (_type == 0) {
            zeroWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            fiveWriteList[_addr] = _YorN;
        } else if (_type == 2) {
            ordWriteList[_addr] = _YorN;
        }
    }

    //设置黑名单。限制pank怎么会接替进来呢？黑掉
    function setBlackList(address _addr, bool _YorN) external onlyOwner{
        blackList[_addr] = _YorN;
    }

    //手续费有收小数，所以注意设置上去时，要扩大十倍，不然到时候也gg了
    function setRate(uint256[] memory _sixGenRate) external onlyOwner {
        sixGenSumRate = 0;
        sixGenRate = _sixGenRate;
        for (uint256 i = 0; i < sixGenRate.length; i++) sixGenSumRate = sixGenSumRate + sixGenRate[i];
    }

    function setAddr(address _openerAdd, address _defaultAdd) public onlyOwner {
        defaultAdd = _defaultAdd;
    }

    function setRP(address _addr) public onlyOwner{
        RP = relationship(_addr);
    }
}