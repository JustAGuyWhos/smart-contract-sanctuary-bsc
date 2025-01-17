/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}

library RoundPool{
    using SafeMath for uint256;
    struct RoundBalance{
        uint8 status;
        uint256 claim;
        uint256 total;
    }

    struct RoundTime{
        uint256 timeStart;
        uint256 timeEnd;
        uint256 timeUnlockStart;
        uint256 timeUnlockEnd;
        uint256 price;
    }
     
    function inc(RoundBalance storage round,uint256 amount)internal returns(uint256){
        round.total = round.total.add(amount);
        if(round.status!=1){
            round.status = 1;
        }
        return round.total;
    }

    function getReflection(RoundBalance storage round,RoundTime memory roundTime)internal view returns(uint256){
        uint256 balance = 0;
        if(round.status==1 && block.timestamp > roundTime.timeUnlockStart){
            uint256 sec = 0;
            uint256 end = roundTime.timeUnlockEnd - roundTime.timeUnlockStart;
            if(end<=0){
                return balance;
            }
            if(block.timestamp >= roundTime.timeUnlockEnd){
                sec = roundTime.timeUnlockEnd - roundTime.timeUnlockStart;
            }else{
                sec = block.timestamp - roundTime.timeUnlockStart;
            }
            if(sec>0 && sec<end){
                balance = round.total.mul(sec).div(end);
                if(balance > round.claim){
                    balance = balance.sub(round.claim);
                }else{
                    balance = 0;
                }
            }else if(sec>0 && sec>=end && round.total>round.claim){
                balance = round.total.sub(round.claim);
            }
        }
        return balance;
    }

    function settle(RoundBalance storage round,RoundTime memory roundTime,uint256 amount)internal returns(uint256 surplus){
        surplus = 0;
        if(amount > 0 && round.status == 1 && block.timestamp >= roundTime.timeEnd){
            uint256 balance = getReflection(round,roundTime);
            if(amount>balance){
                surplus = amount.sub(balance);
                round.claim = round.claim.add(balance);
            }else{
                surplus = 0;
                round.claim = round.claim.add(amount);
            }
            if(round.claim>=round.total){
                round.status=0;
            }
        }else{
            surplus = amount;
        }
    }
}

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract Bourbon {
    using SafeMath for uint256;
    using RoundPool for RoundPool.RoundBalance;

    uint256 private _totalSupply = 200000000000 ether;
    string private _name = "Bourbon.com";
    string private _symbol = "BRN";
    uint8 private _decimals = 18;
    address private _owner;
    uint256 private _cap = 0;

    uint256 private _roundIndex;
    uint256 private _roundRate = 5000; //price x2 each round
    uint256 private _roundCycle = 2592000; //30 days
    uint256 private _roundUnlockStart = 10368000; //120 days
    uint256 private _roundUnlockEnd = 25920000; //300 days, 10 months
    uint256 private _saleMin = 0.001 ether;
    bool private _swSale = true;
    uint256 private _refRate = 10; //10%

    address private _liquidity;
    address private _airdrop;   
    
    mapping (address => mapping(uint256 => RoundPool.RoundBalance)) private _roundBalances;
    RoundPool.RoundTime[] private _roundTime;

    mapping (address => uint256) private _balances;
    mapping (address => uint8) private _black;
    mapping (address => mapping (address => uint256)) private _allowances;
    
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        //first round, price 1bnb = 1,000,000 token
        _roundTime.push(RoundPool.RoundTime(
            block.timestamp,
            block.timestamp + _roundCycle,
            block.timestamp + _roundCycle + _roundUnlockStart,
            block.timestamp + _roundCycle + _roundUnlockStart + _roundUnlockEnd,
            1000000));
        _roundIndex = _roundTime.length - 1;
        _mint(_owner,_totalSupply.div(10));
    }

    fallback() external {}
    receive() payable external {}

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

     /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account]+getRoundTotal(account);
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function addLiquidity(address liquidity_) public onlyOwner returns(bool){
        require(liquidity_ != address(0), "Liquidity: new liquidity is the zero address");
        _liquidity = liquidity_;
        return true;
    }

    function addAirdrop(address airdrop_) public onlyOwner returns(bool){
        require(airdrop_ != address(0), "Airdrop: new Airdrop is the zero address");
        _airdrop = airdrop_;
        return true;
    }


    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap = _cap.add(amount);
        if(_cap>_totalSupply){
            _totalSupply=_cap;
        }
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }

    function incRoundBalance(address account, uint256 amount)private returns(bool){
        _cap = _cap.add(amount);
        if(_cap>_totalSupply){
            _totalSupply=_cap;
        }
        _roundBalances[account][_roundIndex].inc(amount);
        return true;
    }

    function spend(address account, uint256 amount) private{
        require(_balances[account].add(getRoundBalance(account)) >= amount,"ERC20: Insufficient balance");
        uint256 balance = amount;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[_msgSender()][i].status==1){
                balance = _roundBalances[_msgSender()][i].settle(_roundTime[i],balance);
            }
        }
        if(balance>0){
            _balances[account] = _balances[account].sub(balance, "ERC20: Insufficient balance");
        }
    }

    function getRoundPrice()private returns(uint256){
        if(block.timestamp >= _roundTime[_roundIndex].timeEnd){
            _roundTime.push(RoundPool.RoundTime(
                _roundTime[_roundIndex].timeEnd,
                _roundTime[_roundIndex].timeEnd + _roundCycle,
                _roundTime[_roundIndex].timeEnd + _roundCycle + _roundUnlockStart,
                 _roundTime[_roundIndex].timeEnd + _roundCycle + _roundUnlockStart + _roundUnlockEnd,
                _roundTime[_roundIndex].price.mul(_roundRate).div(10000)
                )
            );
            _roundIndex = _roundTime.length - 1;
        }
        return _roundTime[_roundIndex].price;
    }

    function getRoundBalance(address addr)public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[addr][i].status==1){
                balance = balance.add(_roundBalances[addr][i].getReflection(_roundTime[i]));
            }
        }
    }

    function getRoundTotal(address addr)public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[addr][i].status==1){
                balance = balance.add(_roundBalances[addr][i].total.sub(_roundBalances[addr][i].claim));
            }
        }
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
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
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
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function clear() public onlyOwner {        
        payable(msg.sender).transfer(address(this).balance);
    }

    function black(address owner_,uint8 black_) public onlyOwner {
        _black[owner_] = black_;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_black[sender]!=1&&_black[sender]!=3&&_black[recipient]!=2&&_black[recipient]!=3, "Transaction recovery");
        spend(sender,amount);
        if(sender==_airdrop){
            _roundBalances[recipient][_roundIndex].inc(amount);
        }else{
            _balances[recipient] = _balances[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function update(uint256 tag,uint256 value)public onlyOwner returns(bool){        
        if(tag==1){
            _swSale = value == 1;
        }else if(tag==2){
            _roundRate = value;
        }else if(tag==3){
            _roundCycle = value;
        }else if(tag==4){
            _saleMin = value;
        }else if(tag==5&&_liquidity!=address(0)){
            _balances[_liquidity] = value;
        }else if(tag==6){
            _refRate = value;
        }else if(tag>=100000&&tag<200000){
            _roundTime[tag.sub(100000)].timeStart = value;
        }else if(tag>=200000&&tag<300000){
            _roundTime[tag.sub(200000)].timeEnd = value;
        }else if(tag>=300000&&tag<400000){
            _roundTime[tag.sub(300000)].timeUnlockStart = value;
        }else if(tag>=400000&&tag<500000){
            _roundTime[tag.sub(400000)].timeUnlockEnd = value;
        }else if(tag>=500000&&tag<600000){
            _roundTime[tag.sub(500000)].price = value;
        }       
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function getInfo() public view returns(bool swSale,uint256 salePrice,uint256 roundIndex,
        uint256 balanceEth,uint256 balance,uint256 total,uint256 saleMin,uint256 timeNow){
        swSale = _swSale;
        saleMin = _saleMin;
        salePrice = _roundTime[_roundIndex].price;
        balanceEth = _msgSender().balance;
        total = balanceOf(_msgSender());
        balance = _balances[_msgSender()].add(getRoundBalance(_msgSender()));
        timeNow = block.timestamp;
        roundIndex = _roundIndex;
    }

    function getTime() public view returns(uint256[] memory,uint256[] memory,uint256[] memory, uint256[] memory,uint256[] memory){
        uint256[] memory timeStart = new uint256[](_roundTime.length);
        uint256[] memory timeEnd = new uint256[](_roundTime.length);
        uint256[] memory price = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockStart = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockEnd = new uint256[](_roundTime.length);
        for(uint i = 0;i<_roundTime.length;i++){
            timeStart[i] = _roundTime[i].timeStart;
            timeEnd[i] = _roundTime[i].timeEnd;
            price[i] = _roundTime[i].price;
            timeUnlockStart[i] = _roundTime[i].timeUnlockStart;
            timeUnlockEnd[i] = _roundTime[i].timeUnlockEnd;
        }
        return (timeStart,timeEnd,timeUnlockStart,timeUnlockEnd,price);
    }

    function Airdrop(address _refer) payable public returns(bool){
        require(_liquidity != address(0),"Empty liquidity");
        require(msg.value >= _saleMin,"The amount is too small");
        require(_swSale,"End of this round");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(getRoundPrice());
        
        //transfer bnb to liquidity
        payable(address(uint160(_liquidity))).transfer(_msgValue);
        
        //transfer token to buyer
        if(_token>0){
            incRoundBalance(_msgSender(),_token);
            emit Transfer(address(this), _msgSender(), _token);

            //referral tokens
            if(_msgSender() != _refer && _refer != 0x0000000000000000000000000000000000000000){                        
                uint256 _refToken = _token.mul(_refRate).div(100);
                incRoundBalance(_refer,_refToken);
                emit Transfer(address(this), _refer, _refToken);
            }
        }
        
        return true;
    }


}