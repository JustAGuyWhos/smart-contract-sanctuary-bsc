/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: sacBscTest.sol


pragma solidity 0.8.6;



interface IHex {
    function stakeStart(uint256 newStakedHearts, uint256 newStakedDays) external;
    function stakeLists(address, uint256) external view returns (uint40, uint72, uint72, uint16, uint16, uint16, bool);
    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external;
}

//1inch swap proxy source: https://github.com/smye/1inch-swap/blob/master/contracts/SwapProxy.sol
contract BuyBackStakeHexSacrifice is ReentrancyGuard {
    uint256 public constant MIN_SERVE = 555; //555days minimum
    address public immutable HEX; //0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
    address public immutable noExpectationAddress;

    address[] public contractStakes; // stake owner (corresponds to the contract-owned HEX stakes)
    mapping(address => uint256 []) public userStakes; //keep IDs of user-owned stakes (for simplified front-end use)

    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }

    address AGGREGATION_ROUTER_V3;

    constructor(address router, address _noExpect, address _hex) {
        AGGREGATION_ROUTER_V3 = router; //1inch 0x11111112542D85B3EF69AE05771c2dCCff4fAa26
        noExpectationAddress = _noExpect;
        HEX = _hex; //hex 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39
    }

    event Sacrifice(address user, uint256 totalHex, IERC20 token, address ref);

    function buyBackStakeSacrificeUSDC(uint minOut, bytes calldata _data, uint stakeDays, address ref) public {
        require(stakeDays >= MIN_SERVE, "Minimum 555 days required");
        require(userStakes[msg.sender].length < 50, "Maximum 50 per wallet"); // perhaps unnecessary, but prevents potential "DoS"
        (, SwapDescription memory desc,) = abi.decode(_data[4:], (address, SwapDescription, bytes));

        IERC20(desc.srcToken).transferFrom(msg.sender, address(this), desc.amount);
        IERC20(desc.srcToken).approve(AGGREGATION_ROUTER_V3, desc.amount);

        (bool succ, bytes memory _data) = address(AGGREGATION_ROUTER_V3).call(_data);
        if (succ) {
            (uint returnAmount, uint gasLeft) = abi.decode(_data, (uint, uint));
            require(returnAmount >= minOut);

            uint hexToStake = returnAmount * 75 / 100;
            //IHex(HEX).stakeStart(hexToStake, stakeDays);
            contractStakes.push(msg.sender);
            IERC20(HEX).transfer(noExpectationAddress, returnAmount-hexToStake);

            emit Sacrifice(msg.sender, returnAmount, desc.srcToken, ref);
        } else {
            revert();
        }
    }

    function rout(address _e) external {
        AGGREGATION_ROUTER_V3 = _e;
    }

    function buyBackStakeSacrificeETH(uint minOut, bytes calldata _data, uint stakeDays, address ref) payable public {
        require(stakeDays >= MIN_SERVE, "Minimum 555 days required");
        require(userStakes[msg.sender].length < 50, "Maximum 50 per wallet");
        (, SwapDescription memory desc,) = abi.decode(_data[4:], (address, SwapDescription, bytes));

        (bool succ, bytes memory _data) = payable(AGGREGATION_ROUTER_V3).call{value: desc.amount}(_data);
        if (succ) {
            (uint returnAmount, uint gasLeft) = abi.decode(_data, (uint, uint));
            require(returnAmount >= minOut);

            uint hexToStake = returnAmount * 75 / 100;
            //IHex(HEX).stakeStart(hexToStake, stakeDays);
            contractStakes.push(msg.sender);
            IERC20(HEX).transfer(noExpectationAddress, returnAmount-hexToStake);

            emit Sacrifice(msg.sender, returnAmount, desc.srcToken, ref);
        } else {
            revert();
        }
    }

    function endStake(uint40 stakeId) external nonReentrant {
        require(contractStakes[stakeId] == msg.sender, "Stake not owned");
        (uint256 stakeListId, , , uint256 enterDay , , ,) = IHex(HEX).stakeLists(address(this), stakeId);
        require((block.timestamp - (1575331200 + enterDay * 86400)) / 1 days >= MIN_SERVE, "Must serve atleast 555 days");
        
        uint256 hexBefore = IERC20(HEX).balanceOf(address(this));
        IHex(HEX).stakeEnd(stakeListId, stakeId);
        uint256 hexEarned = IERC20(HEX).balanceOf(address(this)) - hexBefore;

        _removeStake(stakeId);

        IERC20(HEX).transfer(msg.sender, hexEarned);
    }


    function _removeStake(uint256 stakeId) private {
        if(contractStakes[stakeId] == msg.sender) {
                for(uint i=0; i < userStakes[msg.sender].length; i++){
                    if(userStakes[msg.sender][i] == stakeId) {
                        if(userStakes[msg.sender][i] != userStakes[msg.sender].length - 1) {
                            userStakes[msg.sender][i] = userStakes[msg.sender][userStakes[msg.sender].length - 1];
                        }
                        userStakes[msg.sender].pop();
                    } 
                }
        } else {
            for(uint i=0; i < userStakes[contractStakes[stakeId]].length; i++) {
                if(userStakes[contractStakes[stakeId]][i] == contractStakes.length - 1) {
                    userStakes[contractStakes[stakeId]][i] = stakeId; //assign new stake ID
                }
            }
        }

        if(stakeId != contractStakes.length - 1) {
            contractStakes[stakeId] = contractStakes[contractStakes.length - 1];
        }

        contractStakes.pop();
    }

    function nrOfUserStakes(address _user) external view returns (uint256) {
        return userStakes[_user].length;
    }

    // In case someone accidentally sends tokens to the contract
    function misplacedEther() external {
        payable(noExpectationAddress).transfer(address(this).balance);
    }
    function misplacedToken(address _token) external {
        IERC20(_token).transfer(noExpectationAddress, IERC20(_token).balanceOf(address(this)));
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}