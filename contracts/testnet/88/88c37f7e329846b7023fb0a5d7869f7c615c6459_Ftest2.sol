/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
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
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library SafeMathInt {
	int256 private constant MIN_INT256 = int256(1) << 255;
	int256 private constant MAX_INT256 = ~(int256(1) << 255);

	function mul(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a * b;

		// Detect overflow when multiplying MIN_INT256 with -1
		require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
		require((b == 0) || (c / b == a));
		return c;
	}
	function div(int256 a, int256 b) internal pure returns (int256) {
		// Prevent overflow when dividing MIN_INT256 by -1
		require(b != -1 || a != MIN_INT256);

		// Solidity already throws when dividing by 0.
		return a / b;
	}
	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));
		return c;
	}
	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));
		return c;
	}
	function abs(int256 a) internal pure returns (int256) {
		require(a != MIN_INT256);
		return a < 0 ? -a : a;
	}
	function toUint256Safe(int256 a) internal pure returns (uint256) {
		require(a >= 0);
		return uint256(a);
	}
}

library SafeMathUint {
	function toInt256Safe(uint256 a) internal pure returns (int256) {
		int256 b = int256(a);
		require(b >= 0);
		return b;
	}
}

library IterableMapping {
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface IERC20Metadata is IERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
	using SafeMath for uint256;

	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;
	string private _name;
	string private _symbol;

	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}

	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns (uint8) {
		return 5;
	}

	function totalSupply() public view virtual override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view virtual override returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public virtual override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
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

	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");
		_beforeTokenTransfer(address(0), account, amount);
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");
		_beforeTokenTransfer(account, address(0), amount);
		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

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

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns(uint256,uint256);
    function withdrawDividend() external;
  
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount,
        bool isBNB
    );
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount,
        bool isBNB
    );
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns(uint256,uint256);
    function withdrawnDividendOf(address _owner) external view returns(uint256,uint256);
    function accumulativeDividendOf(address _owner) external view returns(uint256,uint256);
}

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 constant internal magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
    uint256 public totalDividendsDistributed;

    uint256 internal magnifiedDividendPerShareForBNB;
    uint256 public totalDividendsDistributedForBNB;
    
    address public immutable rewardToken;
    
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    mapping(address => int256) internal magnifiedDividendCorrectionsForBNB;
    mapping(address => uint256) internal withdrawnDividendsForBNB;

    constructor(string memory _name, string memory _symbol, address _rewardToken) ERC20(_name, _symbol) { 
        rewardToken = _rewardToken;
    }

    receive() external payable {
        require(totalSupply() > 0);

        uint256 amount = msg.value;
        if (amount > 0) {
            magnifiedDividendPerShareForBNB = magnifiedDividendPerShareForBNB.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount, true);

            totalDividendsDistributedForBNB = totalDividendsDistributedForBNB.add(amount);
        }
    }


    function distributeDividends(uint256 amount) public onlyOwner{
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount, false);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256,uint256) {
        (uint256 _withdrawableDividend, uint256 _withdrawableDividendForBNB) = withdrawableDividendOf(user);
        uint256 resultToken = _withdrawableDividend;
        uint256 resultBNB = _withdrawableDividendForBNB;
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend,false);
            bool success = IERC20(rewardToken).transfer(user, _withdrawableDividend);
            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                resultToken = 0;
            }
        }
        if (_withdrawableDividendForBNB > 0) {
            withdrawnDividendsForBNB[user] = withdrawnDividendsForBNB[user].add(_withdrawableDividendForBNB);
            emit DividendWithdrawn(user, _withdrawableDividendForBNB,true);
            (bool success,) = user.call{value: _withdrawableDividendForBNB, gas: 3000}("");
            if(!success) {
                withdrawnDividendsForBNB[user] = withdrawnDividendsForBNB[user].sub(_withdrawableDividendForBNB);
                resultBNB = 0;
            }
        }
        return (resultToken,resultBNB);
    }

    function dividendOf(address _owner) public view override returns(uint256, uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view override returns(uint256, uint256) {
        (uint256 _withdrawableDividend, uint256 _withdrawableDividendForBNB ) = accumulativeDividendOf(_owner);
        return (_withdrawableDividend.sub(withdrawnDividends[_owner]),
         _withdrawableDividendForBNB.sub(withdrawnDividendsForBNB[_owner]));
    }

    function withdrawnDividendOf(address _owner) public view override returns(uint256,uint256) {
        return (withdrawnDividends[_owner], withdrawnDividendsForBNB[_owner]);
    }

    function accumulativeDividendOf(address _owner) public view override returns(uint256, uint256) {
        return (magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude ,
        magnifiedDividendPerShareForBNB.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedDividendCorrectionsForBNB[_owner]).toUint256Safe() / magnitude);
    }

    function _transfer(address , address , uint256 ) internal virtual override {
        require(false);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );

        magnifiedDividendCorrectionsForBNB[account] = magnifiedDividendCorrectionsForBNB[account]
        .sub((magnifiedDividendPerShareForBNB.mul(value)).toInt256Safe());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );

        magnifiedDividendCorrectionsForBNB[account] = magnifiedDividendCorrectionsForBNB[account]
        .add((magnifiedDividendPerShareForBNB.mul(value)).toInt256Safe());
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

contract DividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(uint256 minBalance, address _rewardToken) DividendPayingToken("Reward Tracker", "DividendTracker", _rewardToken) {
    	claimWait = 3600;
        minimumTokenBalanceForDividends = minBalance * 10 ** 5;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }

    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance;
    }

    function excludeFromDividends(address account) external onlyOwner {
    	require(!excludedFromDividends[account]);
    	excludedFromDividends[account] = true;

    	_setBalance(account, 0);
    	tokenHoldersMap.remove(account);

    	emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
    	lastProcessedIndex = index;
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 withdrawableDividendsForBNB,
            uint256 totalDividendsForBNB,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        (withdrawableDividends,withdrawableDividendsForBNB) = withdrawableDividendOf(account);
        (totalDividends,totalDividendsForBNB) = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(excludedFromDividends[account]) {
    		return;
    	}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        (uint256 amount, uint256 amountBNB) = _withdrawDividendOfUser(account);

    	if(amount > 0 || amountBNB > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}

    	return false;
    }
}

contract Ftest2 is ERC20, Ownable {
    mapping (address => uint256) _rBalance;
    mapping (address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFees;


    uint256 public liquidityFeeonBuy;
    uint256 public liquidityFeeonSell;

    uint256 public treasuryFeeonBuy;
    uint256 public treasuryFeeonSell;

    uint256 public rewardFeeonBuy;
    uint256 public rewardFeeonSell;

    uint256 public rewardFeeBNBonBuy;
    uint256 public rewardFeeBNBonSell;

    uint256 public insuranceFeeonBuy;
    uint256 public insuranceFeeonSell;

    uint256 public burnFeeonBuy;
    uint256 public burnFeeonSell;

    uint256 public totalFeeonBuy;
    uint256 public totalFeeonSell;


    bool    public walletToWalletTransferWithoutFee;

    address public insuranceWallet;
    address public treasuryWallet;

    address private immutable DEAD = 0x000000000000000000000000000000000000dEaD;
    

    DividendTracker public dividendTracker;
    address public immutable rewardToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; 
    address public immutable rewardTokenII = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    uint256 public gasForProcessing = 400000;
    
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 private immutable initialSupply;
    uint256 private immutable rSupply;
    uint256 private constant MAX = type(uint256).max;
    uint256 private maxSupply;
    uint256 private _totalSupply;
    
    bool    public swapEnabled = true;
    bool    private inSwap = false;
    uint256 private swapThreshold;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    uint256 private rate;
    uint256 private balanceRate;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);    
    event UpdateBuyFees(uint256 liquidityFeeonBuy, uint256 treasuryFeeonBuy, uint256 rewardFeeonBuy, uint256 rewardFee2onBuy, uint256 insuranceFeeonBuy, uint256 burnFeeonBuy);
    event UpdateSellFees(uint256 liquidityFeeonSell, uint256 treasuryFeeonSell, uint256 rewardFeeonSell, uint256 rewardFee2onSell, uint256 insuranceFeeonSell, uint256 burnFeeonSell);
    event TreasuryWalletChanged(address marketingWallet);
    event InsuranceWalletChanged(address insuranceWallet);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 amount, bool isBNB);
    event SwapTokensAtAmountUpdated(bool swapEnabled, uint256 swapThreshold);
    event WalletToWalletTransferWithoutFeeEnabled(bool enabled);
    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );
    constructor() ERC20("Ftest2", "FT2") 
    {          
        liquidityFeeonBuy = 10;
        liquidityFeeonSell = 10;

        treasuryFeeonBuy = 10;
        treasuryFeeonSell = 10;

        rewardFeeonBuy = 10;
        rewardFeeonSell = 10;

        rewardFeeBNBonBuy = 10;
        rewardFeeBNBonSell = 10;

        insuranceFeeonBuy = 10;
        insuranceFeeonSell = 10;

        burnFeeonBuy = 5;
        burnFeeonSell = 5;

        totalFeeonBuy = liquidityFeeonBuy + treasuryFeeonBuy + rewardFeeonBuy + rewardFeeBNBonBuy + insuranceFeeonBuy + burnFeeonBuy;
        totalFeeonSell = liquidityFeeonSell + treasuryFeeonSell + rewardFeeonSell + rewardFeeBNBonSell + insuranceFeeonSell + burnFeeonSell;

        treasuryWallet = 0x29d64BEeB2d0e78A4fE80638762F55e55F752D26;
        insuranceWallet  = 0x29e18e019bee6D2fd3BCebA36377f72932BFeb5b;     

        walletToWalletTransferWithoutFee = true;
        dividendTracker = new DividendTracker(2, rewardToken);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _allowances[address(this)][address(uniswapV2Router)] = MAX;

        address newOwner=0x43aF4a48120cfA9c1F244BBc16a1069aFA3975fA;
        _mint(owner(), 10_000_000_000 * (10 ** 5));

        initialSupply = 10_000_000_000 * (10 ** 5);
        _totalSupply  = initialSupply;
        
        maxSupply = 10_000_000_000 * (10 ** 5);
        rSupply = MAX - (MAX % initialSupply);
        rate    = rSupply / _totalSupply;

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        swapThreshold = rSupply / 100000;
        _rBalance[owner()] = rSupply;
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function manualSync() external {
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            try dividendTracker.excludeFromDividends(pair) {} catch {}
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    //=======BEP20=======//
    function approve(address spender, uint256 value) public override returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256){
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue - subtractedValue;
        }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender] + addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account] / rate;
    }

    function transfer(address to, uint256 value)
        public
        override
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        
        if (_allowances[from][msg.sender] != MAX) {
            _allowances[from][msg.sender] = _allowances[from][msg.sender] - value;
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 rAmount = amount * rate;
        _rBalance[from] = _rBalance[from] - rAmount;
        _rBalance[to] = _rBalance[to] + rAmount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
		require(recipient != address(0), "ERC20: transfer to the zero address");
        if (inSwap) { return _basicTransfer(sender, recipient, amount); }
        
        uint256 rAmount = amount * rate;

        if (shouldSwapBack(recipient)) { swapBack(); }

        _rBalance[sender] = _rBalance[sender] - rAmount;

        bool wtoWoFee = walletToWalletTransferWithoutFee && sender != uniswapV2Pair && recipient != uniswapV2Pair;
        uint256 amountReceived = (_isExcludedFromFees[sender] || _isExcludedFromFees[recipient] || wtoWoFee) ? rAmount : takeFee(sender, rAmount);
        _rBalance[recipient] = _rBalance[recipient] + amountReceived;


        try dividendTracker.setBalance(payable(sender), _rBalance[sender]/balanceRate) {} catch {}
        try dividendTracker.setBalance(payable(recipient), _rBalance[recipient]/balanceRate) {} catch {}
        if(!inSwap) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {

	    	}  
        }
        emit Transfer(sender, recipient, amountReceived / rate);
        return true;
    }
    function getCirculatingSupply() public view returns (uint256) {
        return (rSupply - (_rBalance[address(0)]+ _rBalance[DEAD])) / rate;
    }

    function takeFee(address sender, uint256 rAmount) internal returns (uint256) {
        uint256 _finalFee;
        uint256 _burnFee;
        if(uniswapV2Pair == sender){
            _burnFee = burnFeeonBuy;
            _finalFee = totalFeeonBuy - _burnFee;
            
        } else{
            _burnFee = burnFeeonSell;
            _finalFee = totalFeeonSell-_burnFee;
        }

        uint256 feeAmount = (rAmount * _finalFee)/ 1000;
        uint256 burnAmount = (rAmount * _burnFee)/ 1000;

        if(feeAmount>0){
            _rBalance[address(this)] = _rBalance[address(this)] + feeAmount;
            emit Transfer(sender, address(this), (feeAmount-burnAmount) / rate);
        }
        if(burnAmount>0){
            _rBalance[DEAD] = _rBalance[DEAD] + burnAmount;
            emit Transfer(sender, DEAD, burnAmount / rate);
        }
        return (rAmount - feeAmount) - burnAmount;
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account) external onlyOwner {
        require(!_isExcludedFromFees[account],"Account is already the value of true");
        _isExcludedFromFees[account] = true;
        emit ExcludeFromFees(account,true);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }
        
    function updateBuyFees(uint256 _liquidityFeeonBuy, uint256 _treasuryFeeonBuy,uint256 _insuranceFeeonBuy, uint256 _rewardFeeonBuy, uint256 _rewardFeeBNBonBuy, uint256 _burnFeeonBuy) external onlyOwner{
        liquidityFeeonBuy = _liquidityFeeonBuy;
        treasuryFeeonBuy = _treasuryFeeonBuy;
        insuranceFeeonBuy = _insuranceFeeonBuy;
        rewardFeeonBuy = _rewardFeeonBuy;
        rewardFeeBNBonBuy = _rewardFeeBNBonBuy;
        burnFeeonBuy = _burnFeeonBuy;
        totalFeeonBuy = _liquidityFeeonBuy + _treasuryFeeonBuy + _insuranceFeeonBuy + _rewardFeeBNBonBuy + _rewardFeeonBuy + _burnFeeonBuy;
        require(totalFeeonBuy + totalFeeonSell <= 100, "Total fees can't be more than 10%");
        emit UpdateBuyFees(_liquidityFeeonBuy, _treasuryFeeonBuy, _insuranceFeeonBuy, _rewardFeeonBuy, _rewardFeeBNBonBuy, _burnFeeonBuy);
    }

    function updateSellFees(uint256 _liquidityFeeonSell, uint256 _treasuryFeeonSell,uint256 _insuranceFeeonSell, uint256 _rewardFeeonSell, uint256 _rewardFeeBNBonSell, uint256 _burnFeeonSell) external onlyOwner{
        liquidityFeeonSell = _liquidityFeeonSell;
        treasuryFeeonSell = _treasuryFeeonSell;
        insuranceFeeonSell = _insuranceFeeonSell;
        rewardFeeonSell = _rewardFeeonSell;
        rewardFeeBNBonSell = _rewardFeeBNBonSell;
        burnFeeonSell = _burnFeeonSell;
        totalFeeonSell = _liquidityFeeonSell + _treasuryFeeonSell + _insuranceFeeonSell + _rewardFeeBNBonSell + _rewardFeeonSell + _burnFeeonSell;
        require(totalFeeonBuy + totalFeeonSell <= 100, "Total fees can't be more than 10%");
        emit UpdateSellFees(_liquidityFeeonSell, _treasuryFeeonSell, _insuranceFeeonSell, _rewardFeeonSell, _rewardFeeBNBonSell, _burnFeeonSell);
    }

    function enableWalletToWalletTransferWithoutFee(bool enable) external onlyOwner {
        require(walletToWalletTransferWithoutFee != enable, "Wallet to wallet transfer without fee is already set to that value");
        walletToWalletTransferWithoutFee = enable;
        emit WalletToWalletTransferWithoutFeeEnabled(enable);
    }

    function changeTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != treasuryWallet, "Treasury wallet is already that address");
        require(!isContract(_treasuryWallet), "Treasury wallet cannot be a contract");
        treasuryWallet = _treasuryWallet;
        emit TreasuryWalletChanged(treasuryWallet);
    }
        
    function changeInsurancemWallet(address _insuranceWallet) external onlyOwner {
        require(_insuranceWallet != insuranceWallet, "Insurance wallet is already that address");
        require(!isContract(_insuranceWallet), "Insurance wallet cannot be a contract");
        insuranceWallet = _insuranceWallet;  
        emit InsuranceWalletChanged(insuranceWallet);
    }

    //=======Swap=======//
    function shouldSwapBack(address _recipient) internal view returns (bool) {
        return automatedMarketMakerPairs[_recipient]
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        
        uint256 liquidityShare = liquidityFeeonBuy + liquidityFeeonSell;
        uint256 treasuryShare = treasuryFeeonBuy + treasuryFeeonSell;
        uint256 insuranceShare = insuranceFeeonBuy + insuranceFeeonSell;
        uint256 rewardShare = rewardFeeonBuy + rewardFeeonSell;
        uint256 rewardBNBShare = rewardFeeBNBonBuy + rewardFeeBNBonSell;
        uint256 totalFee = liquidityShare + treasuryShare + insuranceShare + rewardShare + rewardBNBShare;

        if(contractTokenBalance > 0){
        
            uint256 liquidityTokens;

            if(liquidityShare > 0) {
                liquidityTokens = (contractTokenBalance * liquidityShare) / totalFee;
                swapAndLiquify(liquidityTokens);
            }

            contractTokenBalance = contractTokenBalance - liquidityTokens;
            uint256 bnbShare = treasuryShare + insuranceShare + rewardShare + rewardBNBShare;

            if(contractTokenBalance > 0 && bnbShare > 0) {
                uint256 initialBalance = address(this).balance;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();

                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0,
                    path,
                    address(this),
                    block.timestamp);
                
                uint256 newBalance = address(this).balance - initialBalance;

                if(treasuryShare > 0) {
                    uint256 treasuryBNB = (newBalance * treasuryShare) / bnbShare;
                    sendBNB(payable(treasuryWallet), treasuryBNB);
                }

                if(insuranceShare > 0) {
                    uint256 insuranceBNB = (newBalance * insuranceShare) / bnbShare;
                    sendBNB(payable(insuranceWallet), insuranceBNB);
                }

                if(rewardShare > 0) {
                    uint256 rewardBNB = (newBalance * rewardShare) / bnbShare;
                    swapAndSendDividends(rewardBNB);
                }
                if(rewardBNBShare > 0) {
                    uint256 rewardBNB = (newBalance * rewardBNBShare) / bnbShare;
                    sendBNB(payable(dividendTracker),rewardBNB);
                    emit SendDividends(rewardBNB,true);
                }
            }
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp);
        
        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendDividends(uint256 amount) private{  
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = rewardToken;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp);
        
        uint256 balanceRewardToken = IERC20(rewardToken).balanceOf(address(this));
        bool success = IERC20(rewardToken).transfer(address(dividendTracker), balanceRewardToken);

        if (success) {
            dividendTracker.distributeDividends(balanceRewardToken);
            emit SendDividends(balanceRewardToken,false);
        }
       
    }
    
    function setSwapTokensAtAmount(bool _swapEnabled,uint256 newAmount) external onlyOwner{
        require(newAmount > rSupply / 100000, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapThreshold = newAmount;
        swapEnabled = _swapEnabled;
        emit SwapTokensAtAmountUpdated(_swapEnabled,newAmount);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 800000, "gasForProcessing must be between 200,000 and 800,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256,uint256) {
        return (dividendTracker.totalDividendsDistributed(),dividendTracker.totalDividendsDistributedForBNB());
    }

    function withdrawableDividendOf(address account) public view returns(uint256,uint256) {
        return dividendTracker.withdrawableDividendOf(account);

  	}

	function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);

	}

    function totalRewardsEarned(address account) public view returns (uint256,uint256) {
        return dividendTracker.accumulativeDividendOf(account);
    }
    
	function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(address(account));
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimAddress(address claimee) external onlyOwner {
        dividendTracker.processAccount(payable(claimee), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    
}