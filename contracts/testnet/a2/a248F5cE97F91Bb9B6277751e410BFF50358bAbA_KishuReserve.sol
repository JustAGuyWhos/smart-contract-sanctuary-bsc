/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-09
*/

/**
 *Submitted for verification at BscScan.com on 2021-09-30
*/


pragma solidity ^0.8.4;

// SPDX-License-Identifier: UNLICENSED



interface ERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

interface MKEcosystemContract{
    function isEngineContract( address _address ) external returns (bool);
    function returnAddress ( string memory _contractName ) external returns ( address );
}


contract KishuReserve is Ownable {
    
   
    address payable public teamWallet;

    MKEcosystemContract public engineecosystem;
    
    constructor( address _ecosystem) {
       
       engineecosystem = MKEcosystemContract (_ecosystem);

        teamWallet = payable(msg.sender);
    }
    
    receive ()external payable {}

    
    
    function setTeamWallet ( address payable _wallet ) public onlyOwner {
        teamWallet = _wallet;
    }
    
    function approve ( address _token, address _spender, uint256 _amount ) public onlyOwner {
        ERC20 _erc20 = ERC20 ( _token );
        _erc20.approve ( _spender, _amount );
    }
    
    function kishGoldBalance() public  returns ( uint256) {
        ERC20 _erc20 = ERC20 ( engineecosystem.returnAddress("KishuGold") );
        return _erc20.balanceOf ( address(this));
    }
    
    function withdrawBNB () public onlyOwner {
       payable(teamWallet).transfer( address(this).balance );
    }
    
    function sendKishuGold ( address _to, uint256 _amount ) public onlyOwner {
         ERC20 _erc20 = ERC20 ( engineecosystem.returnAddress("KishuGold") );
        _erc20.transfer ( _to , _amount );
    }
    
    function emergencyWithdrawalKishuGold () public onlyOwner {
         ERC20 _erc20 = ERC20 ( engineecosystem.returnAddress("KishuGold") );
        uint256 _balance = _erc20.balanceOf( address(this));
        _erc20.transfer ( teamWallet , _balance );
    }

    function emergencyWithdrawalAnyToken ( address _token ) public onlyOwner {
         ERC20 _erc20 = ERC20 ( _token );
        uint256 _balance = _erc20.balanceOf( address(this));
        _erc20.transfer ( teamWallet , _balance );
    }

    modifier onlyEcosystem() {
        require ( engineecosystem.isEngineContract(msg.sender), "Not an Engine Contract");
         _;
    }
    
    
}