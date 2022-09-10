/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract ECVerify {

    /// signature methods.
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        // bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);

        return ecrecover(hash, v, r, s);
    }

    function toString(address account) public pure returns (string memory) {
        return toString(abi.encodePacked(account));
    }

    function toString(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}

contract depositWithdraw is  ECVerify {
    
    using SafeMath for uint256;
       
    address payable owner;
    
    IERC20 erc20;
    
    address public signer;

    mapping(address => uint) balance;
    
    mapping (bytes32 => bool) public usedHash;
    
    event Deposit(address  User, uint256 Amount, uint256 Timestamp);

    event DepositToken(address  User, address Token, uint256 Amount, uint256 Timestamp);
    
    event Withdraw(address  User, address Token, uint256 Amount, uint256 Timestamp);
    
    constructor(address _signer) {
        owner = msg.sender;
        signer = _signer;
    }
 
    function depositToken(address _token,uint _amount) public {
        IERC20(_token).approve(address(this), _amount);
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        emit DepositToken(msg.sender, _token, _amount, block.timestamp);
    }

    function getTokenBalance(address _token) public view returns(uint){
     return IERC20(_token).balanceOf(address(this)); 
    }
    
    function withdraw(address _token, uint256 _amount, uint8 _nonce, bytes memory signature) external {
        bytes32 hash = keccak256(
            abi.encodePacked(
                toString(address(this)),
                toString(msg.sender),
                _amount,
                _nonce
            )
        );
        
        require(!usedHash[hash], "Invalid Hash");
        
        require(recoverSigner(hash, signature) == signer, "Signature Failed");
        
        usedHash[hash] = true;
        
        require(IERC20(_token).transfer(msg.sender, _amount));
        
        emit Withdraw(msg.sender, _token, _amount, block.timestamp);
    }

    function exitBalance(address _token) public returns (bool) {
        uint256 balanceToken = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner, balanceToken);
        return true;
    }

    function withdrawEth(uint256 amount) payable public{
      require(msg.sender == owner, "OnlyOwner");
      require(balance[address(this)] > amount, "Invalid amount");
      balance[address(this)] -= amount;
      owner.transfer(amount);
    }

    function changeSignatureAddress(address _signer) public {
        require(msg.sender == owner, "OnlyOwner");
        signer = _signer;
    }
    
}