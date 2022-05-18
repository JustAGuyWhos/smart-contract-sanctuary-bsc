/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-27
*/

pragma solidity 0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity 0.6.12;

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



pragma solidity ^0.6.2;


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity 0.6.12;

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
        require(c >= a, "SafeMath: addition overflow anananan");

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}





contract ERC20 is Context, IERC20,Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public  _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_,uint8 decimals_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals =decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual  returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual  returns (uint8) {
        return _decimals;
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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
     
        function _transferfather(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
     
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

        function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
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


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}



// SPDX-License-Identifier: MIT

//
// $FUCKBABY proposes an innovative feature in its contract.
//

pragma solidity 0.6.12;



contract  LunasDao is ERC20 {
    using SafeMath for uint256;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public LunaAdr = 0x156ab3346823B651294766e23e6Cf87254d68962;
    //0xa8Dc518828505301BB208bFe72a66f3034540c04
    uint256 private txone = 3;
    mapping(address => bool) public isClaim;
    mapping(address => address) public invter;
    mapping(address => uint) public oneList;
    mapping(address => uint) public manyList;
    mapping(address => uint) public starList;
    mapping(address => address[10]) public userOneList;
    uint16 public abiT = 100;
    uint8 public sharePV1 = 5;
    uint8 public sharePV2 = 7;
    uint8 public sharePV3 = 9;
    uint8 public sharePV4 = 11;
    uint8 public sharePV5 = 3;
    uint48 public sharePV1Amount = 100;
    uint48 public oneAmount = 10;
    uint8 public  oneAmountShV1 = 10;
    uint8 public  oneAmountShV2 = 6;
    uint8 public  oneAmountShV3 = 4;
    uint256 public airdropAmount = 56 * 10**6*(10**9);
    uint256 public maxSupply = 59 * 10**11 * 10**9;
    uint256 public bnbAmount = 0.1 ether;
    address public own;
    constructor() public ERC20("LUNAS", "LUNAS",9) {
        _mint(owner(),3 * 10**11 * 10**9);
        own = owner();
    }

    receive() external payable {

  	}


    function claim(address adr) public payable {
        require(!isClaim[msg.sender],"account is not claim success");
        require(msg.value == bnbAmount,"bnb is not success");
        uint256 claimAmounts = airdropAmount;
        if(isHaveLuna(msg.sender)){
            claimAmounts = claimAmounts.mul(2);
        }
        require(totalSupply().add(claimAmounts) <= maxSupply,"maxSupply is too big");
        isClaim[msg.sender] = true;
        //inver is  address(0)
        require(msg.sender != adr && invter[adr] != msg.sender,"invter is not success");
        if(invter[msg.sender] == address(0)){
            invter[msg.sender] = adr;
        }
        //max oneList
        if(adr != own){
        require(oneList[adr]<oneAmount,"oneList is too big");
        }
        userOneList[adr][oneList[adr]] = msg.sender;
        oneList[adr] = oneList[adr].add(1);
        
        _mint(msg.sender,claimAmounts);
        //todos v1 v2 v3
        _mint(adr,claimAmounts.mul(oneAmountShV1).div(100));
        address adrTest = adr;
        // 1 2 3 rewards
        for(uint j = 0;j<2;j++){
             if(invter[adrTest] == address(0)){
                break;
            }
             adrTest = invter[adrTest];
            if(j == 0){
                _mint(adrTest,claimAmounts.mul(oneAmountShV2).div(100)); 
            }else{
                _mint(adrTest,claimAmounts.mul(oneAmountShV3).div(100)); 
            }
        }

        uint peopleLevel = 1000;
        address inverAdr = msg.sender;
        for(uint i = 0;i<peopleLevel;i++){
            if(invter[inverAdr] == address(0)){
                break;
            }
            inverAdr = invter[inverAdr];
            manyList[inverAdr] = manyList[inverAdr].add(1);
            if(isAddManyV1(inverAdr)){
                setStarLevel(inverAdr);
                _mint(inverAdr,claimAmounts.mul(sanHandle(inverAdr)).div(100));
            }
        }  
    }

    function setStarLevel(address adr) internal {
        if(starList[adr] == 0){
            starList[adr] = 1;
            return;
        }else if(starList[adr] == 1 && manyList[adr] > abiT * 2 ** starList[adr]){
           uint starUnit = findStar(adr,starList[adr]);
           if(starUnit>1){
               starList[adr] = 2;
           }
        }else if(starList[adr] == 2 && manyList[adr] > abiT * 2 ** starList[adr]){
           uint starUnit = findStar(adr,starList[adr]);
           if(starUnit>1){
               starList[adr] = 3;
           }
        }else if(starList[adr] == 3 && manyList[adr] > abiT * 2 ** starList[adr]){
           uint starUnit = findStar(adr,starList[adr]);
           if(starUnit>1){
               starList[adr] = 4;
           }
        }else if(starList[adr] == 4 && manyList[adr] > abiT * 2 ** starList[adr]){
           uint starUnit = findStar(adr,starList[adr]);
           if(starUnit>1){
               starList[adr] = 5;
           }
        }
        
    }

    function findStar(address adr,uint star) public view returns(uint){
        uint  amount;
        for(uint i = 0; i<oneAmount;i++){
            address adrn = userOneList[adr][i];
            if(starList[adrn] == star){
                amount++;
            }
        }
        return amount;
    }
    
    function setOwn(address adr) public onlyOwner {
        own = adr;
    }
    function setAbiT(uint16 amount) public onlyOwner{
            abiT =amount;
    }
    function star5Reward(address adr,uint amount) public onlyOwner{
        require(totalSupply().add(amount) <= maxSupply,"maxSupply is too big");
        require(starList[adr] == 5,"adr is not 5");
        _mint(adr,amount);
    }

    function setOneAmount(uint48 amount)public onlyOwner{
        oneAmount = amount;
    }
    function setLunaAdr(address adr) public onlyOwner{
        LunaAdr = adr;
    }
    
    function getBnb() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }
    
    function isAddManyV1(address adr) public view returns(bool) {
        if(oneList[adr] >= oneAmount && manyList[adr] >= sharePV1Amount ){
            return true;
        }else{
            return false;
        }
    }


    function sanHandle(address adr) public view returns(uint8) {
        if(starList[adr] == 0){
            return 0;
        }
        if(starList[adr] == 1){
            return sharePV1;
        }else if(starList[adr] == 2){
            return sharePV2;
        }else if(starList[adr] == 3){
            return sharePV3;
        }else if(starList[adr] == 4){
            return sharePV4;
        }else{
            return sharePV4;
        }
    }

    function isHaveLuna(address adr) public view returns(bool){
            if(IERC20(LunaAdr).balanceOf(adr) >= 1 * 10**10){
                
                return true;
            } else{
                return false;
            }

        // return false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 feesa = txone;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        	uint256 fbbs = amount.mul(feesa).div(100);
        	amount = amount.sub(fbbs);
             super._transfer(from, deadWallet, fbbs);
        super._transfer(from, to, amount);
    }
}