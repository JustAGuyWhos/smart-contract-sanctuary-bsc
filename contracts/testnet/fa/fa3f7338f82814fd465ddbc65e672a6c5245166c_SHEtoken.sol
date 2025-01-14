/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: SimPL-2.0
// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
        }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
        }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
        }   
    }


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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
contract ERC20 is Context,Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    //发送免手续费
    mapping(address => bool) private sendExcludeFee;
    //收币免手续费
    mapping(address => bool) private receiveExcludeFee;
    //底池白名单
    mapping(address => bool) private poolExcludes;
    //推荐人地址
    mapping(address => address) private inviterMap;
    //推荐人数
    mapping(address => uint256) private memberAmount;
    //百分比精度
    uint256 private rateDecimal = 10 ** 18;
    //总发行量
    uint256 private _totalSupply;
    //总份额
    uint256 private _totalAmount;
    //社区DAO
    address public foundation;
    //社区DAO比例
    uint256 public _taxFoundation;
    //销毁比例
    uint256 public _taxBurn;
    uint256 public _numLevel;
    uint256 public _oneLevel;
    uint256 public _twoLevel;
    uint256 public _otherLevel;
    //默认推荐人
    address public defaultInviter;
    //默认节点
    address public defaultNode;
    uint256 private registerFee;
    //底池开关
    bool private poolEanble;
    //回流底池费率
    uint256 private lpFee;
    //底池地址
    address public lpAddress;
    //通缩最小值
    uint256 public MIN_AMOUNT;
    address payable private senderAddress;
    //检测是否是例外账户，不进行10%分账
    mapping(address => bool) private executors;

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
        senderAddress = payable(msg.sender);
        executors[msg.sender] = true;
        defaultInviter = address(0xd8ba1AB41C04F3d8caC4F0f30B27a11B596309Ff);
        foundation = address(0x64210f57dd9BdA233A1e597B53F85C9158Fae7ff);
        defaultNode = address(0xa740aE6bAa623D85342F9585F16ca6E8B19F5eda);
        MIN_AMOUNT = 21000 * 10 ** 6;
        inviterMap[defaultInviter] = defaultInviter;
        registerFee = 10 ** 6;
        _taxFoundation = 2;
        _taxBurn = 2;
        _numLevel = 8;
        _oneLevel = 10;
        _twoLevel = 6;
        _otherLevel = 4;
        lpFee = 4;
        poolEanble = false;
        lpAddress = msg.sender;
    }



    function updateExecutors(address executor, bool status) public onlyOwner {
        executors[executor] = status;
    }

    function updateSendExclude(address sender, bool isExclude) public onlyOwner {
        sendExcludeFee[sender] = isExclude;
    }

    function updatePoolExclude(address sender, bool isExclude) public onlyOwner {
        poolExcludes[sender] = isExclude;
    }

    function updatePoolEable(bool isExclude) public onlyOwner {
        poolEanble = isExclude;
    }

    function updateReceiveExclude(address receiver, bool isExclude) public onlyOwner {
        receiveExcludeFee[receiver] = isExclude;
    }

     function updateLpAddress(address setAdress) public onlyOwner {
        lpAddress = setAdress;
    }

    function updateMinAmount(uint256 newMin) public onlyOwner {
        MIN_AMOUNT = newMin;
    }


    function updateFoundationAddress(address newAddress) public onlyOwner {
        foundation = newAddress;
    }

    function updateNodeAddress(address newAddress) public onlyOwner {
        defaultNode = newAddress;
    }

    function updateInviterAddress(address newAddress) public onlyOwner {
        defaultInviter = newAddress;
    }

    function updateLpFee(uint256 newLpFee) public onlyOwner {
        lpFee = newLpFee;
    }

    function updateTaxFoundation(uint256 newTaxFoundation) public onlyOwner {
        _taxFoundation = newTaxFoundation;
    }

    function updateTaxBurn(uint256 newTaxBurn) public onlyOwner {
        _taxBurn = newTaxBurn;
    }

    function updateNumLevel(uint256 newNumLevel) public onlyOwner {
        _numLevel = newNumLevel;
    }

    function updateOneLevel(uint256 newOneLevel) public onlyOwner {
        _oneLevel = newOneLevel;
    }

    function updateTwoLevel(uint256 newTwoLevel) public onlyOwner {
        _twoLevel = newTwoLevel;
    }

    function updateOtherLevel(uint256 newOtherLevel) public onlyOwner {
        _otherLevel = newOtherLevel;
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
        return 6;
    }



    function getMemberAmount(address account) public view returns (uint256){
        return memberAmount[account];
    }

    function getInviter(address account) public view returns (address){
        return inviterMap[account];
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

        if (sendExcludeFee[sender] || receiveExcludeFee[recipient]) {
            //设置交易所地址为交易地址  交易地址进出需收取手续费
            if(poolEanble == false){
                require(poolExcludes[recipient] == true,"ERC20: recipient not in list");
            }
            _transferIncludeFee(sender, recipient, amount);
        } else {
            //正常地址转账，不收手续费
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);

           _afterTokenTransfer(sender, recipient, amount);
        }

        if(inviterMap[recipient] == address(0x0))
        {
            inviterMap[recipient] = sender;
            memberAmount[sender] = memberAmount[sender].add(1);
        }



    }



    function _transferIncludeFee(address sender, address recipient, uint256 amount) internal {

        _balances[sender] = _balances[sender].sub(amount); 
        uint256 taxfee ;
        taxfee = _maxTaxFee();
        uint256 xtemp = 1000;
        uint256 addRate = amount.mul(xtemp.sub(taxfee)).div(1000);
        _balances[recipient] = _balances[recipient].add(addRate);
        emit Transfer(sender, recipient, addRate);
  

        _burnFee(sender,amount);


        _inviterFee(sender,recipient,amount,taxfee);



        //Dao
        uint256 temp = amount.mul(_taxFoundation).div(100);
        if(temp > 0)
        {
        _balances[foundation] = _balances[foundation].add(temp);
        emit Transfer(sender, foundation, temp);
        }

        //LP
         temp = amount.mul(lpFee).div(100);
        if(temp > 0)
        {
        _balances[lpAddress] = _balances[lpAddress].add(temp);
        emit Transfer(sender, lpAddress, temp);
        }

    }


    function _maxTaxFee() public view returns (uint256){
        uint256 taxfee ;
        uint256 levelfee ;
        taxfee = _taxBurn.add(_taxFoundation).add(lpFee).mul(10);

        if(_numLevel == 1){
            taxfee = taxfee.add(_oneLevel);
        }

        if(_numLevel >= 2){
            levelfee = _oneLevel.add(_twoLevel).add(_otherLevel.mul(_numLevel.sub(2)));
            taxfee = taxfee.add(levelfee);
        }            
        return taxfee;
    }

    function _inviterTaxFee(address recipient,uint256 taxfee) public view returns (uint256,uint256){
        uint256 addLevel;
        uint256 leftFee;
        address cur;
        uint256 rateSum;
        cur = recipient;
        leftFee = taxfee.sub(_taxBurn.add(_taxFoundation).add(lpFee).mul(10));
        for (uint256 i = 0; i < _numLevel; i++) {
            uint256 rate;
            if (i == 0) {
                rate = _oneLevel;
            } else if (i == 1) {
                rate = _twoLevel;
            } else {
                rate = _otherLevel;
            }
            cur = inviterMap[cur];
            if (cur == address(0x0)) {

                if(i == 0){
                    addLevel = 0;
                    return(0,leftFee);
                }
                if(i < _numLevel){
                    leftFee = leftFee.sub(rateSum);
                    addLevel = i;
                    return(i,leftFee);
                }
            } else {
                rateSum = rateSum.add(rate);
            }
        }            
        return (_numLevel,0);
    }

    function _burnFee(address sender, uint256 amount) public virtual {
        uint256 burnAmount = amount.mul(_taxBurn).div(100);
        if (_totalSupply.sub(burnAmount) <= MIN_AMOUNT) {
            burnAmount = 0;
        } 
        //销毁
        if (burnAmount > 0) {
            _totalSupply = _totalSupply.sub(burnAmount);
            _balances[address(0x0)] = _balances[address(0x0)].add(burnAmount);
            emit Transfer(sender, address(0), burnAmount);
        }            
    }

    function _inviterFee(address sender,address recipient, uint256 amount,uint256 taxfee) public virtual {
        uint256 recipientLevel;
        uint256 leftAmount;
        (recipientLevel , leftAmount) = _inviterTaxFee(recipient,taxfee);
        address cur;
        cur = recipient;
        for (uint256 i = 0; i < recipientLevel; i++) {
            uint256 rate;
            if (i == 0) {
                rate = _oneLevel;
            } else if (i == 1) {
                rate = _twoLevel;
            } else {
                rate = _otherLevel;
            }
            cur = inviterMap[cur];
            uint256 curAmount = amount.div(1000).mul(rate);
            _balances[cur] = _balances[cur].add(curAmount);
            emit Transfer(sender, cur, curAmount);            
        }  
        if(leftAmount > 0){
            uint256 curAmount = amount.div(1000).mul(leftAmount);
            _balances[defaultInviter] = _balances[defaultInviter].add(curAmount);
            emit Transfer(sender, defaultInviter, curAmount);
        }        
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

// File: BMVToken.sol



pragma solidity ^0.8.0;



contract SHEtoken is ERC20 {

    mapping(address => bool) public blacklist;
    
    constructor() ERC20("GAMEFI WORD SHARE", "SHE") {
        
        _mint(msg.sender,210000 * 10 ** 6);
        //updateSendExclude(msg.sender, true);
        //updateReceiveExclude(msg.sender, true);
        
    }
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    function addBlacklist(address user) public onlyOwner {       
        blacklist[user] = true;    
    }
    
    function removeBlacklist(address user) public onlyOwner {        
        blacklist[user] = false;  
    }

    function ownerWithdrew(uint256 amount) public onlyOwner{
        
        amount = amount * 10 **6;
        
        uint256 dexBalance = balanceOf(address(this));
        
        require(amount > 0, "You need to send some tokens");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        _transfer(address(this), msg.sender, amount);
    }
    
    function ownerDeposit( uint256 amount ) public onlyOwner {
        
        amount = amount * 10 **6;

        uint256 dexBalance = balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some tokens");
        
        require(amount <= dexBalance, "Dont hava enough tokens");

        _transfer(msg.sender, address(this), amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!blacklist[sender] && !blacklist[recipient], "ERC20: user in the blacklist");

        return super._transfer(sender, recipient, amount);

    }
    
}