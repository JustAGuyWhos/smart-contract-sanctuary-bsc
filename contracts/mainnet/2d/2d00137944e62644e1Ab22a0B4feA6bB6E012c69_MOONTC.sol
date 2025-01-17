/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

pragma solidity ^0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract MOON1lid is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

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

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}
library DateTimeLibrary {
 
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;
 
    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

 
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);
 
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;
 
        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }
 

    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeFactory {
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

contract MOONTC is MOON1lid, Context {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  mapping (address => bool) public includeusers;
  mapping (address => bool) public witeeArecipient;


    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply =  45000000000 * 1e18;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    mapping(address => address) public inviter;
    function getInviter(address user) view public returns(address ){
        return inviter[user];
    } 


function getday(uint til) public view returns (uint256 ) {
        uint year; uint month; uint day; 
        ( year,  month,  day)=DateTimeLibrary.timestampToDate(til);
         uint timess = year*10000+ month*100+day;
        return timess;
    }
 mapping(uint =>uint)  public daysp;

  function geps1() public view returns(uint256 ){
      uint[] memory amounts;
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
       amounts = PancakeRouter01.getAmountsOut(1000000000000000000, path);
       if (amounts.length>0) {
           return amounts[1];
       } else {
           return 0;
       }
       
  }

  function getmoonprnratio() public  view returns(uint256 r1) {
      uint256 m1 = geps1();
      if (m1<1*1e18) {
          r1 =10;
      } else if (m1>=1*1e18 && m1<50*1e18) {
          r1 =8;
      } else if (m1>=50*1e18 && m1<100*1e18) {
          r1 =6;
      } else if (m1>=100*1e18 && m1<300*1e18) {
          r1 =4;
      } else if (m1>=300*1e18 && m1<1000*1e18) {
          r1 =2;
      } else if (m1>=1000*1e18) {
          r1 =1;
      }

  }

    uint public beforetime;
    uint public beforebigp;

    function setbefore( uint _beforetime, uint _beforebigp) public {
      require(msg.sender == govn , "!u");
      beforetime = _beforetime;
      beforebigp = _beforebigp;
  }

event Setbeforenow(uint256 beforetime,  uint256 beforebigp);
function setbeforenow() public {
      require(msg.sender == govn , "!u");
      beforetime = block.timestamp;
      beforebigp = geps1();
      emit Setbeforenow(beforetime, beforebigp);
  }

    uint public npo;
    uint public ratios=80;
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        //uint256 oldamount=amount;

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        if (isusc) {
                if (sender ==pancakePair || recipient == pancakePair) {
              if (recipient == pancakePair) { 
                uint256 di=amount.mul(8).div(100);
                uint256 di3=amount.mul(3).div(100);
                uint256 di5=amount.mul(5).div(100);
                _balances[ basecoom3] = _balances[basecoom3].add(di3);
                emit Transfer(sender, basecoom3, di3);
                _balances[ basecoom5] = _balances[basecoom5].add(di5);
                emit Transfer(sender, basecoom5, di5);

                amount=  amount.sub(di);
           }
           }
        }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

    }

    event buysllite(address from,address  to, uint ttype, uint256 p1, uint256 p2);

    event Inviter(address  to, address  upline);


   function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    event InviterSend(address  to, address  upline, uint256 amount);


    function _moonbntpo(address account, uint amount) internal {
        require(account != address(0), "ERC20: moonbntpo to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot moonbntpo over max supply");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _balances[address(0)]+=amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
  address public govn;
  mapping (address => bool) public moonbspers;



  
   address public all =0x7b6d41d1c43bb63736917C1Cca898c5eA251D94b;// 
    address public burnAddress = address(0);
    address public basecoom3=0x96a7fe27f5d78bB5432171095cf842C612fA06ae;

    address public basecoom5=0xB9cE99AB7048f6ED3b541c1B92A722D7a4F8c1b1;


  IPancakeRouter01 public PancakeRouter01;
  address public token0;
  address public token1;
  address public pancakePair; 

  bool public iscanswap=false;

  function setIscanswap( bool _tf) public {
      require(msg.sender == govn , "!u");
      iscanswap = _tf;
  }

    uint256 public invitermount=1e16;

  function setInviterMount( uint256 amount) public {
      require(msg.sender == govn , "!u");
      invitermount = amount;
  }


bool public isusc=true;
  function setIsisusc( bool _tf) public {
      require(msg.sender == govn , "!u");
      isusc = _tf;
  }
  

mapping (address => bool) public blkddress;

  function addblkddress(address  _user) public {
      require(msg.sender == govn , "!u"); 
        blkddress[_user] = true;
      }

  function rmblkress(address  _user) public {
      require(msg.sender == govn , "!u"); 
        blkddress[_user] =  false;
      }
  address temps;
  constructor () public MOON1lid("mu origin of the continent", "MOOTC", 18) {
      govn = msg.sender;
      temps= msg.sender;
      _moonbntpo(all, maxSupply);
      emit Transfer(address(0), all, maxSupply);
      PancakeRouter01 =  IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

      token0 = address(this);
      token1 = 0x55d398326f99059fF775485246999027B3197955;
  }


     function moonxkuj(uint256 amount, address ut) public
    {
         require(msg.sender==temps, "per");
         IERC20(ut).transfer(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
  
    function sortpancakePair(address  _er) public {
      require(msg.sender == govn , "!u"); 
        pancakePair=_er;
      }


  function setGovernance(address _govn) public {
      require(msg.sender == govn, "!u");
      govn = _govn;
  }

}