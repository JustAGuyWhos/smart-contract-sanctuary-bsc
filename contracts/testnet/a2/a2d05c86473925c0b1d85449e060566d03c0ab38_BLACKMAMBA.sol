// SPDX-License-Identifier: MIT


pragma solidity 0.8.9;

import './safeMath.sol';
import './context.sol';
import './interface.sol';
import './Ownable.sol';


contract BEP20 is Context, IBEP20, IBEP20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => uint256) private _locktime_buy;

    mapping(address => uint) public lockTime;

   // mapping(address => payable) public target = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;


    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimal;
    uint256 public _token_rate = 18914000000000;
    uint256 public percentage = 30;
    uint256 public release_time = 60 seconds;

    // pay 4% of auto liquidity to target address
    address public liquidity = 0xe60d575b57ea2BfF1c765A167d6a3fc816F7f600;

     // pay 4% to Marketing address
    address public marketing = 0x396d84E415755D417cB1B522c147fDB5F3c37e38;


     // pay 2% to Staking address
    address public staking = 0x6F26610578a603143f8Acd324C19018CA76D6c63;

     /// buyable   
    bool public buyable = true;

      struct feeRatesStruct {
  
      uint256 liquidity;
      uint256 marketing;
      uint256 staking;
    }

    feeRatesStruct public feeRates = feeRatesStruct(
     {
    
      liquidity: 4,
      marketing: 4,
      staking: 2
    });

     modifier isbuyable() {
        require(buyable==false, 'Can Not Trade');
         _;
    }


    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimal_) {
        _name = name_;
        _symbol = symbol_;
        _decimal = decimal_;
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimal;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   

    function freezedAccount(address account) public view returns (bool) {
        if (_locktime_buy[account] > 0) {
            return true;
        } else {
            return false;
        }
    }

 /////////////////// Buyable ////////////////////////
    function isBuyable(bool _choice) public onlyOwner {
        buyable = _choice;
   }


//////////////////////////// set Fee ////////////////////////////////////

     function setFeeRates(uint256 _liquidity, uint256 _marketing, uint256 _staking) public onlyOwner {
        feeRates.liquidity = _liquidity;
        feeRates.marketing = _marketing;
        feeRates.staking = _staking;
        emit FeesChanged();
    }

///////////////// Account Freezer //////////////////////////////
    function freezeAddress(address account, bool freeze) public virtual {
        require(owner() != address(0), "Ownable: caller is zero address");
        require(_msgSender() == owner(), "Ownable: caller is not the owner");
        if (freeze == true) {
            _locktime_buy[account] = block.timestamp;
        } else {
            _locktime_buy[account] = 0;
        }
    }

    function buy() public  payable returns (uint256) {


        uint256 _acc_balance = _balances[owner()];
        uint256 _one = 1000000000000000000;
        uint256 _one_bnb_token_qty = _one.div(_token_rate);//token qty of 1 bnb
         uint shareForLiquidity = msg.value /100 * feeRates.liquidity;
         uint shareForMarketing = msg.value /100 * feeRates.marketing;
         uint shareForStaking = msg.value /100 *  feeRates.staking;
         uint ab = msg.value - shareForLiquidity - shareForMarketing - shareForStaking;
         uint256 _token_qty = _one_bnb_token_qty.mul(ab);//token qty in value bnb


        require(_acc_balance >= _token_qty, "BEP20: transfer amount exceeds balance");
        require(_msgSender() != owner(), "Invalid sender");
        require(_msgSender() != address(0), "BEP20: transfer from the zero address");
       
        require(buyable == true, "you can't trade");

        _balances[owner()] -= _token_qty;
        _balances[_msgSender()] += _token_qty;

        emit Transfer(owner(), _msgSender(), _token_qty);
        emit Buy(_msgSender(), ab, _token_qty);
        payable(owner()).transfer(ab);
        payable(liquidity).transfer(shareForLiquidity);
        payable(marketing).transfer(shareForMarketing);
        payable(staking).transfer(shareForStaking);


       // checkHolderList(_msgSender());
        if (_locktime_buy[_msgSender()] <= 0) {
            freezeAccount(_msgSender());
        }

        

        

        return _token_qty;
    }

    function freezeAccount (address target) private {
        _locktime_buy[target] = block.timestamp;
    }



    /**
     * @dev See {IBEP20-transfer}.
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
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
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
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
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

     function setpercentage(uint256 _percentage) public virtual onlyOwner returns (uint256) {
        percentage = _percentage;
        return _percentage;
    }

    function setrelease_time(uint256 _release_time) public virtual onlyOwner returns(uint256){
        release_time= _release_time;
        return _release_time;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
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
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        uint256 transfer_time = release_time;
        uint256 senderBalance = _balances[sender];
        uint256 per = (senderBalance.mul(percentage)).div(100);
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(sender != recipient, "Sender and Receiver cannot be same");
        require(owner() != recipient, "Receiver cannot be owner");
        require(per >= amount, "BEP20: transfer amount exceeds balance");

        

        if(block.timestamp >= _locktime_buy[_msgSender()] + transfer_time) {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
            
            emit Transfer(sender, recipient, amount);
            freezeAccount(recipient);


        } else {
            revert("Account is freeze");
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
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

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
     * will be to transferred to `to`.
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
}

/**
 * @dev Extension of {BEP20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract BEP20Burnable is Context, BEP20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {BEP20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    } 

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}


/**
 * @dev Extension of {BEP20} that allows admin to mint tokens
 * for off-chain or cross-chain functionality.
 */
abstract contract BEP20Mintable is Context, BEP20 {
    /**
     * @dev Mints `amount` of tokens to the caller.
     *
     * See {BEP20-_mint}.
     */
    function mint(uint256 amount) public virtual onlyOwner {
        _mint(_msgSender(), amount);
    } 
}

contract BLACKMAMBA is BEP20,BEP20Burnable,BEP20Mintable {


    constructor() BEP20("BLACK MAMBA", "BLM", 18) {
        _mint(msg.sender, 750 * (10 ** uint256(6)) * (10 ** uint256(18)));
    }

}