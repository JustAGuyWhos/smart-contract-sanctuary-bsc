/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );

    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// File: contracts/getprice.sol


pragma solidity ^0.8.0;


/*
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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract Reward is Context, Ownable {


    AggregatorV3Interface internal priceFeed;
    uint256 periodNumber; //即将到来的一期
    address asset;
    uint256 fee;
    uint256 times5;
    uint256 times3;
    uint256 times2;
    uint256 base5;
    uint256 baseFee;
    uint256 baseTimeOut;
    uint256 public limitAmount;
    uint256 public basePay;

    bool public isSale;
    bool public isSaleActive;
    bool public isSaleActiveFree;


    mapping(address => uint256) private newstId; // address 101 地址 + 期
    mapping(address => uint256[]) private personHistory;// 投单记录
    mapping(uint256 => uint256) private rewardHistoryTime;// 开奖时间
    mapping(uint256 => mapping(address => uint256)) private maxPerson; //每一期的 最大的中奖者
    // 开奖记录
    mapping(uint256 => uint256[]) private rewardHistory;                     //地址  期 类型(0单，1双，2号)）金额 号码   0未兑奖 1 已兑奖
    // 投单详情
    mapping(address => mapping(uint256 => uint256[])) private SeveralIssues; // 0xaaa 1  2,               100, 0,0,0,0,0,1
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor () {
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        asset = 0x851d1312A6Bcb845C0E60470C3E440faAadF298F;
        periodNumber = 1;
        fee = 99;
        baseFee = 100;
        times5 = 200;
        times3 = 15;
        times2 = 2;
        base5 =5;
        baseTimeOut = 300;
        limitAmount = 10;
        basePay =1 * 10 ** 15;
    }
    // 这是个开关
    function flipSaleState() public onlyOwner {
        isSaleActive = !isSaleActive;
    }
    function flipSale() public onlyOwner {
        isSale = !isSale;
    }


    function flipSaleStateFree() public onlyOwner {
        isSaleActiveFree = !isSaleActiveFree;
    }

    function getFlipSaleState() public view  returns(bool) {
        return isSaleActive;
    }

    function getFlipSaleStateFree() public view  returns(bool) {
        return isSaleActiveFree;
    }

    function setBasePay(uint256 basePayOne) public onlyOwner() {
        basePay = basePayOne * 10 ** 14;
    }

    function setAsset(address assetOne) public onlyOwner() {
        asset = assetOne;
    }
    function setLimit(uint256 limitOne) public onlyOwner() {
        limitAmount = limitOne;
    }

    function setBase5(uint256 base5One) public onlyOwner() {
        base5 = base5One;
    }
    function setFee(uint256 feeOne) public onlyOwner() {
        fee = feeOne;
    }

    function setBaseTimeOut(uint256 baseTimeOutOne) public onlyOwner() {
        baseTimeOut = baseTimeOutOne;
    }


    function setTimes5(uint256 times5One) public onlyOwner() {
        times5 = times5One;
    }

    function setTimes3(uint256 times3One) public onlyOwner() {
        times3 = times3One;
    }

    function setTimes2(uint256 times2One) public onlyOwner() {
        times2 = times2One;
    }


    function testAll() public onlyOwner() {
        rewardHistory[periodNumber].push(1);
        rewardHistory[periodNumber].push(2);
        rewardHistory[periodNumber].push(3);
        rewardHistory[periodNumber].push(4);
        rewardHistory[periodNumber].push(5);
        rewardHistoryTime[periodNumber] = block.timestamp;
        periodNumber += 1;
    }

    function doNext() public returns (uint256[] memory) {
        require(isSale, "Sale is not active");
        (
        /*uint80 roundID*/,
        int price,
        /*uint startedAt*/,
        /*uint timeStamp*/,
        /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        // 生成一个0到100的随机数:

        //uint256[] ls = new uint256[](5);
        for (uint i = periodNumber; i < periodNumber + 5; i++) {
            uint random = uint(keccak256(abi.encode(block.timestamp, msg.sender, i, price))) % 10;
            //ls.push(random);
            rewardHistory[periodNumber].push(random);
        }
        rewardHistoryTime[periodNumber] = block.timestamp;
        periodNumber += 1;
        return rewardHistory[periodNumber - 1];
    }

    function getRewardHistory(uint256 i) public view returns (uint256[] memory) {
        return rewardHistory[i];
    }

    function getSeveralIssues(uint256 i) public view returns (uint256[] memory) {
        return SeveralIssues[msg.sender][i];
    }


    function getPersonHistoryAll() public view returns (uint256[] memory) {
        return personHistory[msg.sender];
    }

    function getPersonHistoryAllLength() public view returns (uint256) {
        return personHistory[msg.sender].length;
    }

    function getPersonHistoryIndex(uint256 begin, uint256 end) public view returns (uint256[] memory) {
        uint256 sizeA = end - begin + 1;
        uint256[] memory indexH = new uint256[](sizeA);
        uint256 i = 0;
        for (uint256 i = begin; i <= end; i++) {
            indexH[i] = personHistory[msg.sender][i];
            i++;
        }
        return indexH;
    }


    function getPeriodNumber() public view returns (uint256) {
        return periodNumber;
    }

    // 查询奖池
    function balanceOfTotal() public view returns (uint256){
        IERC20 token = IERC20(asset);
        return token.balanceOf(address(this));
    }

    //投注
    function doPer(uint256 aType, uint256 aAmount, uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) public {
        require(aAmount>=limitAmount, "aAmount less than limitAmount");
        require(isSaleActiveFree, "Sale is not active");

        if (periodNumber != 1) {
            require(block.timestamp >= rewardHistoryTime[periodNumber - 1] && block.timestamp <= rewardHistoryTime[periodNumber - 1] + baseTimeOut, "time out");
        }
        if (balanceOfOne() > 0) {
            doClaim();
            //先完成提现
        }

        require(getIsPle(), "already ple");
        IERC20 token = IERC20(asset);
        token.transferFrom(msg.sender, address(this), aAmount * 10 ** 18);
        SeveralIssues[msg.sender][periodNumber] = [aType, aAmount, a, b, c, d, e, 0];
        newstId[msg.sender] = periodNumber;
        personHistory[msg.sender].push(periodNumber);
    }
    //投注
    function doPerPay(uint256 aType, uint256 aAmount, uint256 a, uint256 b, uint256 c, uint256 d, uint256 e)  payable public {
        require(aAmount>=limitAmount, "aAmount less than limitAmount");
        require(isSaleActive, "Sale is not active");

        if (periodNumber != 1) {
            require(block.timestamp >= rewardHistoryTime[periodNumber - 1] && block.timestamp <= rewardHistoryTime[periodNumber - 1] + baseTimeOut, "time out");
        }
        if (balanceOfOne() > 0) {
            doClaim();
            //先完成提现
        }
        require(basePay <= msg.value, "Ether value is not correct");
        payable(owner()).transfer(msg.value);

        require(getIsPle(), "already ple");
        IERC20 token = IERC20(asset);
        token.transferFrom(msg.sender, address(this), aAmount * 10 ** 18);
        SeveralIssues[msg.sender][periodNumber] = [aType, aAmount, a, b, c, d, e, 0];
        newstId[msg.sender] = periodNumber;
        personHistory[msg.sender].push(periodNumber);
    }


    // 目前 1 需要先授权 2 这个判读最新的逻辑有点问题需要查询
    function getNewsId() public view returns (uint256){
        return newstId[msg.sender];
    }


    // true  can buy ; false not can buy
    function getIsPle() public view returns (bool){
        return newstId[msg.sender] != periodNumber;
    }

    // 提现
    function doClaim() public {
        IERC20 token = IERC20(asset);
        uint256 reward = balanceOfOne();
        require(reward != 0, "reward is 0");
        uint256 toTalBalance = token.balanceOf(address(this));
        if (reward * 10 ** 18 >= toTalBalance) {
            token.transfer(msg.sender, toTalBalance * fee / baseFee);
        } else {
            token.transfer(msg.sender, reward * 10 ** 18);
        }
        uint256 iss = newstId[msg.sender];

        SeveralIssues[msg.sender][iss][3] = 1;
        // 兑奖状态修改
    }

    // whithdraw owner
    function withDraw(uint256 amount) public onlyOwner {
        IERC20 token = IERC20(asset);
        token.transfer(owner(), amount * 10 ** 18);
    }

    // 查询某个人的当前奖金
    function balanceOfOne() public view returns (uint256){
        uint256 iss = newstId[msg.sender];
        if (iss == 0) {
            return 0;
        }
        uint256[] memory pushOne = SeveralIssues[msg.sender][iss];
        uint256[] memory nums = rewardHistory[iss];
        if (newstId[msg.sender] == periodNumber) {// 当前投注的这一期 是即将到来的一期即还未开奖的一期
            return 0;
        }
        uint sig;
        uint dou;
        for (uint i = 0; i < 5; i++) {
            uint numone = rewardHistory[iss][i];
            if (numone == 0 || numone == 2 || numone == 4 || numone == 6 || numone == 8) {
                dou++;
            } else {
                sig++;
            }
        }
        if (pushOne[3] == 1) {// 已兑奖
            return 0;
        } else {// 未兑奖
            if (pushOne[0] == 0) {//单
                if (sig > dou) {// 中奖
                    return pushOne[1] * 2 * fee / baseFee;
                } else {
                    return 0;
                }

            } else if (pushOne[0] == 1) {// 双
                if (dou > sig) {// 中奖
                    return pushOne[1] * 2 * fee / baseFee;
                } else {
                    return 0;
                }

            } else if (pushOne[0] == 2) {// 选号
                //uint256[] memory numsls = pushOne[2];
                if (pushOne[2] == rewardHistory[iss][0] && pushOne[3] == rewardHistory[iss][1] && pushOne[4] == rewardHistory[iss][2] && pushOne[5] == rewardHistory[iss][3] && pushOne[6] == rewardHistory[iss][4]) {
                    return pushOne[1] * times5 * fee / baseFee ;
                } else if ((pushOne[2] == rewardHistory[iss][0] && pushOne[3] == rewardHistory[iss][1] && pushOne[4] == rewardHistory[iss][2]) || (pushOne[4] == rewardHistory[iss][2] && pushOne[5] == rewardHistory[iss][3] && pushOne[6] == rewardHistory[iss][4])) {
                    return pushOne[1] * times3 * fee / baseFee ;
                } else if ((pushOne[2] == rewardHistory[iss][0] && pushOne[3] == rewardHistory[iss][1]) || (pushOne[5] == rewardHistory[iss][3] && pushOne[6] == rewardHistory[iss][4])) {
                    return pushOne[1] * times2 * fee / baseFee;
                } else {
                    return 0;
                }
            }
        }
        return 0;
    }
}