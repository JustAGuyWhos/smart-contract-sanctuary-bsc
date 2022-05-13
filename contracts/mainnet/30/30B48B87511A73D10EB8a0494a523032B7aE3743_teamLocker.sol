/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity ^0.8.13;
// SPDX-License-Identifier: UNLICENSED


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

contract teamLocker{
    bool  private _rentrenceLock = true;
    mapping (address => bool) private _claimer;
    mapping (address => uint256) private _locked;

    uint256 unlocktime = 0;

    constructor() {
     _claimer[msg.sender] = true;
     unlocktime = block.timestamp + 31556926;
    }

    address private _activeTokenAddress;

    modifier onlyClaimers() {
        require(_claimer[msg.sender], "Claimer: caller is not the allowed list of claimer");
        _;
    }
    modifier lock(){
        require(_rentrenceLock,"Reentrency protection hit");
        _rentrenceLock = false;
        _;
        _rentrenceLock = true;
    }

    function setAddress(address tokenAddress) public onlyClaimers{
        _activeTokenAddress = tokenAddress;
    }
    function sync() external onlyClaimers{
        _locked[_activeTokenAddress] = IERC20(_activeTokenAddress).balanceOf(address(this));
    }

    function addTeamTokens(uint256 amount) external lock{
        uint256 beforetx = IERC20(_activeTokenAddress).balanceOf(address(this));
        bool xfer = IERC20(_activeTokenAddress).transferFrom(address(msg.sender), address(this), amount);
        require(xfer, "ERR_ERC20_FALSE");
        uint256 aftertx = IERC20(_activeTokenAddress).balanceOf(address(this));
        _locked[_activeTokenAddress] = _locked[_activeTokenAddress] + (aftertx-beforetx);
    }
    function availableReflection() external view returns(uint256){
        return IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked[_activeTokenAddress];
    }
    function lockedToken(address tokenAddress) view external returns(uint256){
        return _locked[tokenAddress];
    }
    function getReflections() external lock onlyClaimers{
        uint256 amt = IERC20(_activeTokenAddress).balanceOf(address(this)) - _locked[_activeTokenAddress];
        bool xfer = IERC20(_activeTokenAddress).transfer(msg.sender, amt);
        require(xfer, "ERR_ERC20_FALSE");

    }
    function currentActiveAddress() external view returns(address){
        return _activeTokenAddress;
    }

    function isClaimer(address toCheck) external view returns(bool){
        return _claimer[toCheck];
    }
    function addClaimer(address toAdd) external onlyClaimers{
        _claimer[toAdd] = true;
    }
    function removeClaimer(address toRemove) external onlyClaimers{
        _claimer[toRemove] = false;
    }

    function reaminingTime() external view returns(uint256){
        if(block.timestamp > unlocktime){
            return 0;
        }
        else{
            return unlocktime - block.timestamp;
        }
    }

    function increaseLockByDays(uint256 amount) external onlyClaimers {
        unlocktime += 86400*amount;
    }

    function unlock() external {
        require(block.timestamp > unlocktime,"1 year hasn't passed");
        _locked[_activeTokenAddress] = 0;
    }
}