/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// File: contracts/BSCBridge.sol


pragma solidity ^0.8.0;

//Remix style import


//Brownie style import
// import { IERC20 } from "OpenZeppelin/[email protected]/contracts/token/ERC20/IERC20.sol";


contract BscBridge {

    IERC20 private mainToken;

    address gateway;
    address tokenWallet;

    event TransferOut(address indexed requester, bytes32 indexed mainDepositHash, uint amount, uint timestamp);
    event TransferIn(address indexed requester, bytes32 indexed sideDepositHash, uint amount, uint timestamp);

    constructor (address _mainToken, address _gateway, address _tokenWallet) {
        mainToken = IERC20(_mainToken);
        gateway = _gateway;
        tokenWallet = _tokenWallet;
    }

    function TransferToBridge(address _requester, uint _bridgedAmount, bytes32 _mainDepositHash) onlyGateway external {
        emit TransferOut(_requester, _mainDepositHash, _bridgedAmount, block.timestamp);
    }

    function TransferFromBridge(address _requester, uint _bridgedAmount, bytes32 _sideDepositHash) onlyGateway external {
        mainToken.transferFrom(tokenWallet, _requester, _bridgedAmount);
        emit TransferIn(_requester, _sideDepositHash, _bridgedAmount, block.timestamp);
    }

    modifier onlyGateway {
      require(msg.sender == gateway, "only gateway can execute this function");
      _;
    }
    

}