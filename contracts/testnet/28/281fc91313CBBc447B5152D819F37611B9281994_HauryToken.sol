/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: Unlicensed
// File: @openzeppelin/contracts/utils/Context.sol
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
        return 18;
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
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// File: contracts/HauryToken.sol

// File: contracts/VESTATToken.sol

pragma solidity 0.8.4;


/**
    @title An ERC20 token
    @author Futira coin 
*/
contract HauryToken is ERC20 {
    mapping(address => bool) public signers;
    uint64 private pendingTransactionID = 1;
    uint64 public TransactionsCount = 0;
    uint64[] public PendingTransactionList;
    uint256 public currentTotalSupply;
    address public owner;
    address public VestingWallet;  
    mapping(uint128 => VestingTransaction) public VestingTransactions;

    struct VestingTransaction 
    {
        address to;
        uint256 amount;
        string status;
        uint256 ExecuteDate;
        uint256 DueDate;
    }

    event ClaimedToken(address from, address to, uint256 amount);   
    event ApprovedVestingTransaction(address from, address to, uint256 amount);
    event CreatedVestingTransaction(address _to, uint256 _amount, string status, uint256 executeDate, uint256 Due_Date);
    event UpdatedTotalSUpply(string operation, uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Error. Contact [email protected] for help.");
        _;    }

    modifier onlyVestingWallet {
        require(msg.sender == VestingWallet, "Error. Contact [email protected] for help.");
        _;    }

    modifier onlySigner {
        require(signers[msg.sender] == true, "Error. Contact [email protected] for help.");
        _;    }

    constructor() ERC20("HauryToken", "HRY") {
        VestingWallet = address(this) ;
        _mint(msg.sender, 2e10 * 10 ** 18);
        owner = msg.sender;
        signers[0x0012783EE711551526d5753B1B7c925fF7dEB3F5] = true;
        signers[0x36498AA0E72A191364Df0c6246BF500f850041C7] = true;
        currentTotalSupply = totalSupply();
    }

    /** 
        @notice Return detail about a pending transaction
        @param _id for the vested transaction
        @return Return address of vested token recipient, amount of vested token, status of the vested token, the due date for the vested token
    */
    function getVestingTransaction(uint128 _id) external view returns(address, uint, string memory, uint) {
        return (VestingTransactions[_id].to, VestingTransactions[_id].amount, VestingTransactions[_id].status, VestingTransactions[_id].DueDate);
    }   

    /** 
        @notice To get number of last pending transaction and count of not signed
        @return the first transaction, the count, the last transaction
    */
   function getcurrentPendingTransactions() external view returns( uint, uint, uint){
        uint count = 0;
        uint FirstTRX = 0;
        uint LastTRX = 0;
        bool setFirst = false;
        for(uint128 i = 0; i<TransactionsCount; i++){
        if( keccak256(abi.encodePacked((VestingTransactions[i].status))) == keccak256(abi.encodePacked(("pending")))){   
            count++;
            LastTRX=i;
            if(FirstTRX ==0 && !setFirst){
                FirstTRX=i; 
                setFirst = true;
            }
        }    
        }
        return (FirstTRX,count,LastTRX);
    }

    /**
        @notice To get number of last pending transaction and count of not signed
        @param account of the wallet
        @return Return total amount of vested token, number of transaction
    */
    function getWalletVests(address account) external view virtual  returns (uint, uint) 
    { 
        uint256 numberofTRX = 0;
        uint256 Total_amount = 0;
       for(uint128 i = 0; i < TransactionsCount; i++)
        {
                if( VestingTransactions[i].to == account && keccak256(abi.encodePacked((VestingTransactions[i].status))) != keccak256(abi.encodePacked(("successful"))))
                {
                   Total_amount=Total_amount+VestingTransactions[i].amount;
                   numberofTRX=numberofTRX+1;
                }  }
        return (Total_amount , numberofTRX);
    }
 
    /**
        @notice To check whether an ID is in the PendingTransactionList
        @param _id of the vested transaction list
        @return boolean 
    */
    function checkVestingTransactionList(uint128 _id) internal view returns(bool)
    {

            if(keccak256(abi.encodePacked((VestingTransactions[_id].status))) == keccak256(abi.encodePacked(("pending"))))
            {  return true; }
        return false;
    }

    /**
        @notice To approve all pending transaction
        @return boolean
    */
    function approvePendingVestingTransactions() onlySigner external returns(bool)
    {
        uint128 i;
        for( i = 0; i < TransactionsCount; i++)
        {   
                if(keccak256(abi.encodePacked((VestingTransactions[i].status))) == keccak256(abi.encodePacked(("pending"))))
                {
                    approvePendingVestingTransaction(i);
                }
            
        }
        if(i > 0){
            return true;
        } 
        else{
            return false;
       }    
    }
    
    /**
        @notice To approve a pending transaction
        @param _id of the transaction
        @return booelan
    */
    function approvePendingVestingTransaction(uint128 _id) onlySigner public returns(bool)
    {
       
        bool check = checkVestingTransactionList(_id);
        if(check || _id==0)
        {
            if(block.timestamp < VestingTransactions[_id].ExecuteDate + 3600 && keccak256(abi.encodePacked((VestingTransactions[_id].status))) == keccak256(abi.encodePacked(("pending"))))
            {
                if(VestingTransactions[_id].DueDate < block.timestamp ){
                    VestingTransactions[_id].status ="successful";
                    _transfer(owner, VestingTransactions[_id].to, VestingTransactions[_id].amount);
                    
                    emit ApprovedVestingTransaction(owner, VestingTransactions[_id].to, VestingTransactions[_id].amount);
                    PendingTransactionList[_id]=0;
                }
                else {
                VestingTransactions[_id].status ="approved";
                    _transfer(owner, VestingWallet, VestingTransactions[_id].amount);

                    emit ApprovedVestingTransaction(owner, VestingWallet, VestingTransactions[_id].amount);
                    PendingTransactionList[_id]=0;
                }

                
                return true;
            }
            else if (block.timestamp > VestingTransactions[_id].ExecuteDate + 3600 && keccak256(abi.encodePacked((VestingTransactions[_id].status))) == keccak256(abi.encodePacked(("pending")))){
                VestingTransactions[_id].status ="failed";
                PendingTransactionList[_id]=0;
                    return false;
            }   
        }

        return false; 
    }

    /**
        @notice This function will create a pending transaction for signer to sign
        @param _to address of the recipient, _amount to transfer, Due_Date for the transaction apporval
        @return the id of the pending transaction
    */
    function createVestingTransaction(address _to, uint256 _amount, uint256 Due_Date) public onlyOwner returns(uint)
    {
        require(_to != address(0), "invalid address");

        uint64 id =  TransactionsCount;

        VestingTransactions[id] = VestingTransaction(_to, _amount, "pending",block.timestamp, Due_Date);
        PendingTransactionList.push(id+1);
        pendingTransactionID = pendingTransactionID + 1;
        TransactionsCount = TransactionsCount +1;

        emit CreatedVestingTransaction(_to, _amount, "pending", block.timestamp, Due_Date);
        return id;
    }

    /**
        @notice To collect their token
        @return boolean
    */
    function Claim() external returns (bool)
    {
        bool status = false;
        for(uint128 i = 0; i<TransactionsCount; i++)
        {
            if(VestingTransactions[i].DueDate <= block.timestamp && VestingTransactions[i].to == _msgSender() )
            {
                status = true;
                if(keccak256(abi.encodePacked((VestingTransactions[i].status))) == keccak256(abi.encodePacked(("approved"))))
                {
                    address _to = VestingTransactions[i].to;
                    uint256 _amount = VestingTransactions[i].amount;
                    _transfer(VestingWallet, msg.sender, _amount);   
                    VestingTransactions[i].status = "successful";

                    emit ClaimedToken(VestingWallet, _to, _amount);
                }  
            }  
        }
        if (!status)
        {
            revert("Error. Contact [email protected] for help.");
        }
        return status;
    }

    /**
        @notice For owner to set the total supply
        @param operation (add/delete), _amount to mint or burn
        @return the total supply
    */
    function setTotalSupply(string memory operation, uint256 _amount) onlyOwner external returns(uint) 
    {
        if(keccak256(abi.encodePacked((operation))) == keccak256(abi.encodePacked(("add"))))
        {
            _mint(msg.sender, _amount);
            currentTotalSupply += _amount;
        }
        else if(keccak256(abi.encodePacked((operation))) == keccak256(abi.encodePacked(("delete"))))
        {
            require(currentTotalSupply >= _amount, "Error. Contact [email protected] for help.");
            _burn(msg.sender, _amount);
            currentTotalSupply -= _amount;
        }
        else
        {
            revert("Error. Contact [email protected] for help.");
        }  

        emit UpdatedTotalSUpply(operation, _amount);
        return totalSupply();
    }

    /**
        @notice to transfer the token from one address to another
        @param recipient address, amount to transfer
        @return boolean
    */
    function transfer(address recipient, uint256 amount) override public returns (bool) {
         require(recipient != address(0), "invalid address");
         if(msg.sender==owner){
             createVestingTransaction( recipient, amount, block.timestamp);
            return true;
         }    
         _transfer(_msgSender(), recipient, amount);
        return true;
    }   
    
}