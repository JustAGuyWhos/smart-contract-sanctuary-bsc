// SPDX-License-Identifier: AGPL-3.0-or-later

/// @title RipProtocol V2 Zap In
/// @author Zapper, Cryptonomik, Dionysus
/// Review by: ZayenX
/// Copyright (C) 2021 Zapper
/// Copyright (C) 2022 RipProtocolDAO

pragma solidity 0.8.4;

import "./interfaces/IBondDepoV2.sol";
import "./interfaces/IStakingV2.sol";
import "./interfaces/IsRIP.sol";
import "./interfaces/IgRIP.sol";
import "./libraries/ZapBaseV3.sol";

contract RipProtocol_V2_Zap_In is ZapBaseV3 {
    using SafeERC20 for IERC20;

    ////////////////////////// STORAGE //////////////////////////

    address public depo;

    address public staking;

    address public immutable RIP;

    address public immutable sRIP;

    address public immutable gRIP;

    ////////////////////////// EVENTS //////////////////////////

    // Emitted when `sender` successfully calls ZapStake
    event zapStake(address sender, address token, uint256 tokensRec, address referral);

    // Emitted when `sender` successfully calls ZapBond
    event zapBond(address sender, address token, uint256 tokensRec, address referral);

    ////////////////////////// CONSTRUCTION //////////////////////////
    constructor(
        address _depo,
        address _staking,
        address _RIP,
        address _sRIP,
        address _gRIP
    ) ZapBaseV3(0, 0) {
        // 0x Proxy
        approvedTargets[0xDef1C0ded9bec7F1a1670819833240f027b25EfF] = true;
        depo = _depo;
        staking = _staking;
        RIP = _RIP;
        sRIP = _sRIP;
        gRIP = _gRIP;
    }

    ////////////////////////// PUBLIC //////////////////////////

    /// @notice This function acquires RIP with ETH or ERC20 tokens and stakes it for sRIP/gRIP
    /// @param fromToken The token used for entry (address(0) if ether)
    /// @param amountIn The quantity of fromToken being sent
    /// @param toToken The token fromToken is being converted to (i.e. sRIP or gRIP)
    /// @param minToToken The minimum acceptable quantity sRIP or gRIP to receive. Reverts otherwise
    /// @param swapTarget Excecution target for the swap
    /// @param swapData DEX swap data
    /// @param referral The front end operator address
    /// @return RIPRec The quantity of sRIP or gRIP received (depending on toToken)
    function ZapStake(
        address fromToken,
        uint256 amountIn,
        address toToken,
        uint256 minToToken,
        address swapTarget,
        bytes calldata swapData,
        address referral
    ) external payable pausable returns (uint256 RIPRec) {
        // pull users fromToken
        uint256 toInvest = _pullTokens(fromToken, amountIn, referral, true);

        // approve "swapTarget" to spend this contracts "fromToken" if needed
        _approveToken(fromToken, swapTarget, toInvest);

        // swap fromToken -> RIP
        uint256 tokensBought = _fillQuote(fromToken, RIP, toInvest, swapTarget, swapData);

        // stake RIP for sRIP or gRIP
        RIPRec = _stake(tokensBought, toToken);

        // Slippage check
        require(RIPRec > minToToken, "High Slippage");

        emit zapStake(msg.sender, toToken, RIPRec, referral);
    }

    /// @notice This function acquires RipProtocol bonds with ETH or ERC20 tokens
    /// @param fromToken The token used for entry (address(0) if ether)
    /// @param amountIn The quantity of fromToken being sent
    /// @param principal The token fromToken is being converted to (i.e. token or LP to bond)
    /// @param swapTarget Excecution target for the swap or Zap
    /// @param swapData DEX or Zap data
    /// @param referral The front end operator address
    /// @param maxPrice The maximum price at which to buy the bond
    /// @param bondId The ID of the market
    /// @return RIPRec The quantity of gRIP due
    function ZapBond(
        address fromToken,
        uint256 amountIn,
        address principal,
        address swapTarget,
        bytes calldata swapData,
        address referral,
        uint256 maxPrice,
        uint256 bondId
    ) external payable pausable returns (uint256 RIPRec) {
        // pull users fromToken
        uint256 toInvest = _pullTokens(fromToken, amountIn, referral, true);

        // make sure "swapTarget" is approved to spend this contracts "fromToken"
        _approveToken(fromToken, swapTarget, toInvest);
        // swap fromToken -> bond principal
        uint256 tokensBought = _fillQuote(
            fromToken,
            principal, // to token
            toInvest,
            swapTarget,
            swapData
        );

        // make sure bond depo is approved to spend this contracts "principal"
        _approveToken(principal, depo, tokensBought);

        // purchase bond
        (RIPRec, , ) = IBondDepoV2(depo).deposit(
            bondId,
            tokensBought,
            maxPrice,
            msg.sender, // depositor
            referral
        );

        emit zapBond(msg.sender, principal, RIPRec, referral);
    }

    ////////////////////////// INTERNAL //////////////////////////

    /// @param amount The quantity of RIP being staked
    /// @param toToken Either sRIP or gRIP
    /// @return RIPRec quantity of sRIP or gRIP  received (depending on toToken)
    function _stake(uint256 amount, address toToken) internal returns (uint256) {
        uint256 claimedTokens;
        // approve staking for RIP if needed
        _approveToken(RIP, staking, amount);

        if (toToken == gRIP) {
            // stake RIP -> gRIP
            claimedTokens = IStaking(staking).stake(address(this), amount, false, true);

            IERC20(toToken).safeTransfer(msg.sender, claimedTokens);

            return claimedTokens;
        }
        // stake RIP -> sRIP
        claimedTokens = IStaking(staking).stake(address(this), amount, true, true);

        IERC20(toToken).safeTransfer(msg.sender, claimedTokens);

        return claimedTokens;
    }

    ////////////////////////// RIPPROTOCOL ONLY //////////////////////////
    /// @notice update state for staking
    function update_Staking(address _staking) external onlyOwner {
        staking = _staking;
    }

    /// @notice update state for depo
    function update_Depo(address _depo) external onlyOwner {
        depo = _depo;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

interface IBondDepoV2 {
    /**
     * @notice deposit bond
     * @param _bid uint256
     * @param _amount uint256
     * @param _maxPrice uint256
     * @param _depositor address
     * @param _feo address
     * @return payout_ uint256
     * @return expiry_ uint256
     * @return index_ uint256
     */
    function deposit(
        uint256 _bid,
        uint256 _amount,
        uint256 _maxPrice,
        address _depositor,
        address _feo
    )
        external
        returns (
            uint256 payout_,
            uint256 expiry_,
            uint16 index_
        );

    function marketPrice(uint256 _id) external view returns (uint256);

    function bondPriceInUSD(uint16 _bid) external view returns (uint256);

    /**
     * @notice returns data about a bond type
     * @param _BID uint
     * @return principal_ address
     * @return calculator_ address
     * @return totalDebt_ uint
     * @return lastBondCreatedAt_ uint
     */
    function bondInfo(uint256 _BID)
        external
        view
        returns (
            address principal_,
            address calculator_,
            uint256 totalDebt_,
            uint256 lastBondCreatedAt_
        );

    /**
     * @notice returns terms for a bond type
     * @param _BID uint
     * @return controlVariable_ uint
     * @return vestingTerm_ uint
     * @return minimumPrice_ uint
     * @return maxPayout_ uint
     * @return maxDebt_ uint
     */
    function bondTerms(uint256 _BID)
        external
        view
        returns (
            uint256 controlVariable_,
            uint256 vestingTerm_,
            uint256 minimumPrice_,
            uint256 maxPayout_,
            uint256 maxDebt_
        );

    function indexesFor(address _user) external view returns (uint256[] memory);

    function liveMarkets() external view returns (uint256[] memory);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IStaking {
    function stake(
        address _to,
        uint256 _amount,
        bool _rebasing,
        bool _claim
    ) external returns (uint256);

    function claim(address _recipient, bool _rebasing) external returns (uint256);

    function forfeit() external returns (uint256);

    function toggleLock() external;

    function unstake(
        address _to,
        uint256 _amount,
        bool _trigger,
        bool _rebasing
    ) external returns (uint256);

    function wrap(address _to, uint256 _amount) external returns (uint256 gBalance_);

    function unwrap(address _to, uint256 _amount) external returns (uint256 sBalance_);

    function rebase() external;

    function index() external view returns (uint256);

    function contractBalance() external view returns (uint256);

    function totalStaked() external view returns (uint256);

    function supplyInWarmup() external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IsRIP is IERC20 {
    function rebase(uint256 ripProfit_, uint256 epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function gonsForBalance(uint256 amount) external view returns (uint256);

    function balanceForGons(uint256 gons) external view returns (uint256);

    function index() external view returns (uint256);

    function toG(uint256 amount) external view returns (uint256);

    function fromG(uint256 amount) external view returns (uint256);

    function changeDebt(
        uint256 amount,
        address debtor,
        bool add
    ) external;

    function debtBalances(address _address) external view returns (uint256);
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IgRIP is IERC20 {
    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;

    function index() external view returns (uint256);

    function balanceFrom(uint256 _amount) external view returns (uint256);

    function balanceTo(uint256 _amount) external view returns (uint256);

    function migrate(address _staking, address _sRIP) external;
}

// ███████╗░█████╗░██████╗░██████╗░███████╗██████╗░░░░███████╗██╗
// ╚════██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗░░░██╔════╝██║
// ░░███╔═╝███████║██████╔╝██████╔╝█████╗░░██████╔╝░░░█████╗░░██║
// ██╔══╝░░██╔══██║██╔═══╝░██╔═══╝░██╔══╝░░██╔══██╗░░░██╔══╝░░██║
// ███████╗██║░░██║██║░░░░░██║░░░░░███████╗██║░░██║██╗██║░░░░░██║
// ╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝
// Copyright (C) 2021 zapper

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//

/// @author Zapper
/// @notice This abstract contract, which is inherited by Zaps,
/// provides utility functions for moving tokens, checking allowances
/// and balances, performing swaps and other Zaps, and accounting
/// for fees.

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Metadata.sol";
import "../interfaces/IWETH.sol";

import "./Context.sol";
import "./Address.sol";
import "./SafeERC20.sol";

// Ownable left here as not to confuse RipProtocol's Ownable
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ZapBaseV3 is Ownable {
    using SafeERC20 for IERC20;
    bool public stopped;

    address private constant wethTokenAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // if true, goodwill is not deducted
    mapping(address => bool) public feeWhitelist;

    uint256 public goodwill;
    // % share of goodwill (0-100 %)
    uint256 affiliateSplit;
    // restrict affiliates
    mapping(address => bool) public affiliates;
    // affiliate => token => amount
    mapping(address => mapping(address => uint256)) public affiliateBalance;
    // token => amount
    mapping(address => uint256) public totalAffiliateBalance;
    // swapTarget => approval status
    mapping(address => bool) public approvedTargets;

    address internal constant ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    modifier pausable() {
        require(!stopped, "Paused");
        _;
    }

    constructor(uint256 _goodwill, uint256 _affiliateSplit) {
        goodwill = _goodwill;
        affiliateSplit = _affiliateSplit;
    }

    /**
    @dev Transfers tokens (including ETH) from msg.sender to this contract
    @dev For use with Zap Ins (takes fee from input if > 0)
    @param token The ERC20 token to transfer to this contract (0 address if ETH)
    @return Quantity of tokens transferred to this contract
     */
    function _pullTokens(
        address token,
        uint256 amount,
        address affiliate,
        bool enableGoodwill
    ) internal virtual returns (uint256) {
        uint256 totalGoodwillPortion;

        if (token == address(0)) {
            require(msg.value > 0, "No ETH sent");

            totalGoodwillPortion = _subtractGoodwill(
                ETHAddress,
                msg.value,
                affiliate,
                enableGoodwill
            );

            return msg.value - totalGoodwillPortion;
        }

        require(amount > 0, "Invalid token amount");
        require(msg.value == 0, "ETH sent with token");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        totalGoodwillPortion = _subtractGoodwill(token, amount, affiliate, enableGoodwill);

        return amount - totalGoodwillPortion;
    }

    /**
    @dev Transfers tokens from msg.sender to this contract
    @dev For use with Zap Outs (does not transfer ETH)
    @param token The ERC20 token to transfer to this contract
    @return Quantity of tokens transferred to this contract
     */
    function _pullTokens(address token, uint256 amount) internal virtual returns (uint256) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        return amount;
    }

    /**
    @dev Fulfills an encoded swap or Zap if the target is approved
    @param fromToken The sell token
    @param toToken The buy token
    @param amount The quantity of fromToken to sell
    @param swapTarget The execution target for the swapData
    @param swapData The swap data encoding the swap or Zap
    @return amountBought Quantity of tokens toToken acquired
     */
    function _fillQuote(
        address fromToken,
        address toToken,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) internal virtual returns (uint256 amountBought) {
        if (fromToken == toToken) {
            return amount;
        }

        if (fromToken == address(0) && toToken == wethTokenAddress) {
            IWETH(wethTokenAddress).deposit{ value: amount }();
            return amount;
        }

        if (fromToken == wethTokenAddress && toToken == address(0)) {
            IWETH(wethTokenAddress).withdraw(amount);
            return amount;
        }

        uint256 valueToSend;
        if (fromToken == address(0)) {
            valueToSend = amount;
        } else {
            _approveToken(fromToken, swapTarget, amount);
        }

        uint256 initialBalance = _getBalance(toToken);

        require(approvedTargets[swapTarget], "Target not Authorized");
        (bool success, ) = swapTarget.call{ value: valueToSend }(swapData);
        require(success, "Error Swapping Tokens");

        amountBought = _getBalance(toToken) - initialBalance;

        require(amountBought > 0, "Swapped To Invalid Token");
    }

    /**
    @notice Gets this contract's balance of a token
    @param token The ERC20 token to check the balance of (0 address if ETH)
    @return balance This contract's token balance
     */
    function _getBalance(address token) internal view returns (uint256 balance) {
        if (token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(token).balanceOf(address(this));
        }
    }

    /**
    @notice Approve a token for spending with infinite allowance
    @param token The ERC20 token to approve
    @param spender The spender of the token
     */
    function _approveToken(address token, address spender) internal {
        if (token == address(0) || spender == address(0)) return;
        IERC20 _token = IERC20(token);
        if (_token.allowance(address(this), spender) > 0) return;
        else {
            _token.safeApprove(spender, type(uint256).max);
        }
    }

    /**
    @notice Approve a token for spending with finite allowance
    @param token The ERC20 token to approve
    @param spender The spender of the token
    @param amount The allowance to grant to the spender
     */
    function _approveToken(
        address token,
        address spender,
        uint256 amount
    ) internal {
        if (token == address(0) || spender == address(0)) return;
        IERC20(token).safeApprove(spender, 0);
        IERC20(token).safeApprove(spender, amount);
    }

    /**
    @notice Set address to true to bypass fees when calling this contract
    @param zapAddress The Zap caller which is allowed to bypass fees (if > 0)
    @param status The whitelisted status (true if whitelisted)
     */
    function set_feeWhitelist(address zapAddress, bool status) external onlyOwner {
        feeWhitelist[zapAddress] = status;
    }

    /** 
    @notice Sets a goodwill amount
    @param _new_goodwill The new goodwill amount between 0-1%
     */
    function set_new_goodwill(uint256 _new_goodwill) public onlyOwner {
        require(_new_goodwill >= 0 && _new_goodwill <= 100, "GoodWill Value not allowed");
        goodwill = _new_goodwill;
    }

    /** 
    @notice Sets the percentage to split the goodwill by to distribute
    * to affiliates
    @param _new_affiliateSplit The new affiliate split between 0-1%
     */
    function set_new_affiliateSplit(uint256 _new_affiliateSplit) external onlyOwner {
        require(_new_affiliateSplit <= 100, "Affiliate Split Value not allowed");
        affiliateSplit = _new_affiliateSplit;
    }

    /** 
    @notice Adds or removes an affiliate
    @param _affiliate The  affiliate's address
    @param _status The affiliate's approval status
     */
    function set_affiliate(address _affiliate, bool _status) external onlyOwner {
        affiliates[_affiliate] = _status;
    }

    /** 
    @notice Withdraws goodwill share, retaining affilliate share
    @param tokens An array of the tokens to withdraw (0xeee address if ETH)
     */
    function withdrawTokens(address[] calldata tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 qty;

            if (tokens[i] == ETHAddress) {
                qty = address(this).balance - totalAffiliateBalance[tokens[i]];

                Address.sendValue(payable(owner()), qty);
            } else {
                qty = IERC20(tokens[i]).balanceOf(address(this)) - totalAffiliateBalance[tokens[i]];
                IERC20(tokens[i]).safeTransfer(owner(), qty);
            }
        }
    }

    /** 
    @notice Withdraws the affilliate share, retaining goodwill share
    @param tokens An array of the tokens to withdraw (0xeee address if ETH)
     */
    function affilliateWithdraw(address[] calldata tokens) external {
        uint256 tokenBal;
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenBal = affiliateBalance[msg.sender][tokens[i]];
            affiliateBalance[msg.sender][tokens[i]] = 0;
            totalAffiliateBalance[tokens[i]] = totalAffiliateBalance[tokens[i]] - tokenBal;

            if (tokens[i] == ETHAddress) {
                Address.sendValue(payable(msg.sender), tokenBal);
            } else {
                IERC20(tokens[i]).safeTransfer(msg.sender, tokenBal);
            }
        }
    }

    /**
    @dev Adds or removes an approved swapTarget
    * swapTargets should be Zaps and must not be tokens!
    @param targets An array of addresses of approved swapTargets
    */
    function setApprovedTargets(address[] calldata targets, bool[] calldata isApproved)
        external
        onlyOwner
    {
        require(targets.length == isApproved.length, "Invalid Input length");

        for (uint256 i = 0; i < targets.length; i++) {
            approvedTargets[targets[i]] = isApproved[i];
        }
    }

    /** 
    @dev Subtracts the goodwill amount from the `amount` param
    @param token The ERC20 token being sent (0 address if ETH)
    @param amount The quantity of the token being sent
    @param affiliate The  affiliate's address
    @param enableGoodwill True if bypassing goodwill, false otherwise
    @return totalGoodwillPortion The quantity of `token` that should be
    * subtracted from `amount`
     */
    function _subtractGoodwill(
        address token,
        uint256 amount,
        address affiliate,
        bool enableGoodwill
    ) internal returns (uint256 totalGoodwillPortion) {
        bool whitelisted = feeWhitelist[msg.sender];
        if (goodwill > 0 && enableGoodwill && !whitelisted) {
            totalGoodwillPortion = (amount * goodwill) / 10000;

            if (affiliates[affiliate]) {
                if (token == address(0)) {
                    token = ETHAddress;
                }

                uint256 affiliatePortion = (totalGoodwillPortion * affiliateSplit) / 100;
                affiliateBalance[affiliate][token] += affiliatePortion;
                totalAffiliateBalance[token] += affiliatePortion;
            }
        }
    }

    /**
    @dev Toggles the contract's active state
     */
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    receive() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}

// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) =
            target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Address.sol";

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}