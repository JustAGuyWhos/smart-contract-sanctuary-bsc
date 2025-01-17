/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

pragma solidity 0.8.17;

// SPDX-License-Identifier: MIT


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

interface IERC20 {
   
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector,spender,newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;
    using SafeERC20 for IERC20;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IWBNB is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

interface IThenaStrategyGaugeV2 {
    function deposit(uint depositAmount) external;
    function withdraw(uint withdrawAmount) external;
    function getReward() external;
    function balanceOf(address account) external view returns (uint256);

}

interface IPlanetRouter {
    struct Routes {
        address from;
        address to;
        bool stable;
    }
}

interface IPlanetRouter2 is IPlanetRouter {
    function SwapSolidlyToGamma(
        uint amountIn,
        uint amountOutMin,
        Routes[] calldata routes,
        address to,
        uint deadline,
        address solidlyRouterAddress
    ) external returns (uint[] memory amounts);

    function getAmountsOutSolidlyToGamma(
        uint256 amountIn,
        Routes[] memory routes,
        address solidlyRouterAddress
    ) external view returns (uint256[] memory amounts);
}

contract StratX2 is Ownable, ReentrancyGuard, IPlanetRouter {

    using SafeERC20 for IERC20;
    address public wantAddress;
    address public GAMMAAddress;
    address public THENAAddress;

    address public wbnbAddress;
    address public gammaFarmAddress;
    address public rewardsAddress;
    address public thenaStrategyAddress;
    address public planetRouterAddress;
    address public thenaRouterAddress;

    uint256 public wantLockedTotal;
    uint256 public sharesTotal;
    uint256 public pid; // pid of pool in farmContractAddress

    uint256 public entranceFeeFactor; 
    uint256 public constant entranceFeeFactorMax = 50;

    uint256 public withdrawFeeFactor;
    uint256 public constant withdrawFeeFactorMax = 200;

    uint256 public performanceFeeFactor; 
    uint256 public constant performanceFeeFactorMax = 2000;

    uint256 public slippageFactor = 990; // 1% default slippage tolerance
    uint256 public constant slippageFactorLL = 900;

    Routes[] public route;

    event SetSettings(uint _entranceFeeFactor, uint _withdrawFeeFactor, uint performanceFeeFactor, uint _slippageFactor);
    event SetRewardsAddress(address _rewardsAddress);
    event SetTHENAAddress(address _THENAAddress);
    event SetPlanetRouterAddress(address _planetRouterAddress);
    event SetThenaRouterAddress(address _thenaRouterAddress);
    event SetThenaStrategyAddress(address _thenaStrategyAddress);
    event SetTHENAToPlanetRoute(Routes[] _route);


    error Unauthorized(address caller);

    function checkForFarmAddressCall() private view  {
        if(msg.sender != gammaFarmAddress) 
        {
            revert Unauthorized(msg.sender);
        }
    }

    function earnGammaProfits() external returns (uint256){
        checkForFarmAddressCall();
        if(wantLockedTotal == 0){
            return 0;
        }
        IThenaStrategyGaugeV2(thenaStrategyAddress).getReward();
        uint256 earned = IERC20(THENAAddress).balanceOf(address(this));

        if (earned == 0){
            return 0;
        }

        IERC20(THENAAddress).safeIncreaseAllowance(
            planetRouterAddress,
            earned
        );

        _safeSwap(
            planetRouterAddress,
            earned,
            slippageFactor,
            route,
            address(this),
            (block.timestamp + 600),
            thenaRouterAddress
        );
        earned = IERC20(GAMMAAddress).balanceOf(address(this));

        uint256 performanceFee = (earned * performanceFeeFactor) / 10000;  
        earned = earned - performanceFee;

        IERC20(GAMMAAddress).safeTransfer(rewardsAddress, performanceFee);
        IERC20(GAMMAAddress).safeTransfer(address(msg.sender), earned);
	    
        return earned;
    }


    function _safeSwap(
        address _planetRouterAddress,
        uint256 _amountIn,
        uint256 _slippageFactor,
        Routes[] memory _route,
        address _to,
        uint256 _deadline,
        address _thenaRouterAddress) internal {
        uint256[] memory amounts =
            IPlanetRouter2(_planetRouterAddress).getAmountsOutSolidlyToGamma(_amountIn, _route, _thenaRouterAddress);
        uint256 amountOut = amounts[amounts.length - 1];

        IPlanetRouter2(_planetRouterAddress)
            .SwapSolidlyToGamma( 
            // This particular function on the router has to be checked, on the front end we use swapExactTokensForTokens
            _amountIn,
            (amountOut * _slippageFactor)/(1000),
            _route,
            _to,
            _deadline,
            _thenaRouterAddress
        );
    }


    // Receives new deposits from user
    function deposit(uint256 _wantAmt) external virtual nonReentrant returns (uint256) {
        checkForFarmAddressCall();

        uint256 depositFee = (_wantAmt * entranceFeeFactor)/ 10000;
        uint256 sharesAdded = _wantAmt - depositFee;
        wantLockedTotal = sharesTotal = sharesTotal + sharesAdded;

        if(depositFee != 0){
            IERC20(wantAddress).safeTransfer(rewardsAddress, depositFee);
        }
        IERC20(wantAddress).safeIncreaseAllowance(thenaStrategyAddress, sharesAdded);
        IThenaStrategyGaugeV2(thenaStrategyAddress).deposit(sharesAdded);

        return (sharesAdded);
    }


    function withdraw(uint256 _wantAmt) public virtual nonReentrant returns (uint256, uint256) {
        checkForFarmAddressCall();

        uint256 wantAmt = IThenaStrategyGaugeV2(thenaStrategyAddress).balanceOf(address(this));
        if (_wantAmt > wantAmt) {
            _wantAmt = wantAmt;
        }

        if (_wantAmt > sharesTotal) {
            _wantAmt = sharesTotal;
        }

        sharesTotal = wantLockedTotal = wantLockedTotal - _wantAmt;

        uint256 sharesRemoved = _wantAmt;
            
        IThenaStrategyGaugeV2(thenaStrategyAddress).withdraw(_wantAmt);
        sharesRemoved = _wantAmt = IERC20(wantAddress).balanceOf(address(this));

        uint256 withdrawFee = (_wantAmt*withdrawFeeFactor)/10000;
        _wantAmt = _wantAmt - withdrawFee;
	if(withdrawFee != 0){
        	IERC20(wantAddress).safeTransfer(rewardsAddress, withdrawFee);
	}
        IERC20(wantAddress).safeTransfer(gammaFarmAddress, _wantAmt);
        
	return (sharesRemoved, _wantAmt);
    }

    function emergencyWithdraw(uint256 _wantAmt) external virtual returns (uint256, uint256) {
        require(_wantAmt != 0, "_wantAmt <= 0");
        return withdraw(_wantAmt);
    }

    function getShares() external virtual view returns (uint256, uint256) {
        return (wantLockedTotal, sharesTotal);
    }

    function setSettings(uint256 _entranceFeeFactor, uint256 _withdrawFeeFactor, uint256 _performanceFeeFactor, uint256 _slippageFactor) external virtual onlyOwner {

        require(_entranceFeeFactor <= entranceFeeFactorMax, "_entranceFeeFactor too high");
        entranceFeeFactor = _entranceFeeFactor;

        require(_withdrawFeeFactor <= withdrawFeeFactorMax, "_withdrawFeeFactor too high");
        withdrawFeeFactor = _withdrawFeeFactor;

        require(_performanceFeeFactor <= performanceFeeFactorMax, "_performanceFeeFactor too high");
        performanceFeeFactor = _performanceFeeFactor;

        require(_slippageFactor >= slippageFactorLL, "_slippageFactor too low");
        slippageFactor = _slippageFactor;

        emit SetSettings(_entranceFeeFactor, _withdrawFeeFactor, _performanceFeeFactor, _slippageFactor);

    }

    function setRewardsAddress(address _rewardsAddress) external virtual onlyOwner {
        rewardsAddress = _rewardsAddress;
        emit SetRewardsAddress(_rewardsAddress);
    }

    function setTHENAAddress(address _THENAAddress) external virtual onlyOwner {
        THENAAddress = _THENAAddress;
        emit SetTHENAAddress(_THENAAddress);
    }

    function setThenaStrategyAddress(address _thenaStrategyAddress) external virtual onlyOwner {
        thenaStrategyAddress = _thenaStrategyAddress;
        emit SetThenaStrategyAddress(_thenaStrategyAddress);
    }

    function setPlanetRouterAddress(address _planetRouterAddress) external virtual onlyOwner {
        planetRouterAddress = _planetRouterAddress;
        emit SetPlanetRouterAddress(_planetRouterAddress);
    }

    function setThenaRouterAddress(address _thenaRouterAddress) external virtual onlyOwner {
        thenaRouterAddress = _thenaRouterAddress;
        emit SetThenaRouterAddress(_thenaRouterAddress);
    }

    function setTHENAToPlanetRoute(Routes[] memory _route) external virtual onlyOwner{
        delete route;

        uint len = _route.length;
        
        for (uint i = 0 ; i < len; ++i){
            route[i].from = _route[i].from;
            route[i].to= _route[i].to;
            route[i].stable= _route[i].stable;
        }
        
        emit SetTHENAToPlanetRoute(_route);
    }

    // why were these functions virtual in the normal strategy?

    function inCaseTokensGetStuck(address _token, uint256 _amount, address _to) external virtual onlyOwner {
        require(_token != wantAddress, "!safe");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function _wrapBNB() internal virtual {
        // BNB -> WBNB
        uint256 bnbBal = address(this).balance;
        if (bnbBal != 0) {
            IWBNB(wbnbAddress).deposit{value: bnbBal}(); // BNB -> WBNB
        }
    }

    function wrapBNB() external virtual onlyOwner {
        _wrapBNB();
    }
}

contract NormalStrategy_GAMMA is StratX2 {
    
    constructor(
        address[] memory _addresses,
        uint256 _pid,
        uint256 _entranceFeeFactor,
        uint256 _withdrawFeeFactor,
        uint256 _performanceFeeFactor
    ) {
        wbnbAddress = _addresses[0];
        gammaFarmAddress = _addresses[1];
        GAMMAAddress = _addresses[2];
        wantAddress = _addresses[3];
        rewardsAddress = _addresses[4];
        THENAAddress = _addresses[5];
        planetRouterAddress = _addresses[6];
        thenaRouterAddress = _addresses[7];
        thenaStrategyAddress = _addresses[8];
        
        pid = _pid;     

        entranceFeeFactor = _entranceFeeFactor;
        withdrawFeeFactor = _withdrawFeeFactor;
        performanceFeeFactor = _performanceFeeFactor;
    }
}