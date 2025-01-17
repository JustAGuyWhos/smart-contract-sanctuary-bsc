// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import "./interfaces/IUniswapV2Router.sol";
import {IDynaset} from "./interfaces/IDynaset.sol";
import "./interfaces/IDynasetTvlOracle.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BscForgeV1 is AccessControl , ReentrancyGuard {
    using SafeERC20 for IERC20;
    /* ==========  Structs  ========== */

    struct ForgeInfo {
        bool isEth;
        address contributionToken;
        uint256 dynasetLp;
        uint256 totalContribution;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 maxCap;
        uint256 contributionPeriod;
        bool withdrawEnabled;
        bool depositEnabled;
        bool forging;
        uint256 nextForgeContributorIndex;
    }

    struct UserInfo {
        uint256 depositAmount;
        uint256 dynasetsOwed;
    }

    struct Contributor {
        address contributorAddress;
        uint256 contributedAmount;
    }

    /* ==========  Constants  ========== */
    bytes32 public constant BLACK_SMITH = keccak256(abi.encode("BLACK_SMITH"));

    address public constant USDC = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
    address public constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB

    uint256 public constant USDC_DECIMALS = 18; // BUSD = 18 decimals
    uint256 public constant DYNASET_DECIMALS = 18;

    uint256 public constant SLIPPAGE_FACTOR = 1000;
    uint256 public constant WITHDRAW_FEE_FACTOR = 10000;
    uint256 public constant WITHDRAW_FEE_5_PERCENT = 500;
    uint256 public constant WITHDRAW_FEE_4_PERCENT = 400;
    uint256 public constant WITHDRAW_FEE_2_5_PERCENT = 250;

    uint256 public constant WITHDRAW_FEE_5_PERCENT_PERIOD = 30 days;
    uint256 public constant WITHDRAW_FEE_4_PERCENT_PERIOD = 60 days;
    uint256 public constant WITHDRAW_FEE_2_5_PERCENT_PERIOD = 90 days;

    /* ==========  State  ========== */
    
    // forgeID => Contributor
    mapping(uint256 => Contributor[]) public contributors; 
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    ForgeInfo[] public forgeInfo;

    IDynaset public dynaset;
    IDynasetTvlOracle public dynasetTvlOracle;
    address public uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // pancakeswap v2

    uint256 public totalForges;
    uint256 public slippage = 50;
    uint256 public totalFee;
    bool    public lpWithdraw;

    uint256 public deadline;

    /* ==========  Events  ========== */

    event LogForgeAddition(uint256 indexed forgeId, address indexed contributionToken);
    event Deposited(address indexed caller, address indexed user, uint256 amount);
    event ForgingStarted(uint256 indexed forgeId, uint256 indexed nextForgeContributorIndex);
    event DepositedLP(address indexed user, uint256 indexed forgeId, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Redeemed(address indexed user, uint256 amount);
    event Forged(address indexed user, uint256 indexed amount, uint256 price);
    event SetlpWithdraw(bool lpWithdraw);
    event ForgeWithdrawEnabled(bool status, uint256 forgeId);
    event ForgeDepositEnabled(bool status, uint256 forgeId);
    event OracleUpdated(address oracle);
    event RouterUpgraded(address router);

    /* ==========  Constructor  ========== */

    constructor(
        address _blacksmith,
        address _dynaset,
        address _dynasetTvlOracle
    ) {
        require(
            _blacksmith != address(0)
            && _dynaset != address(0)
            && _dynasetTvlOracle != address(0),
            "ERR_ZERO_ADDRESS"
        );
        dynaset = IDynaset(_dynaset);
        dynasetTvlOracle = IDynasetTvlOracle(_dynasetTvlOracle);
        _setupRole(BLACK_SMITH, _blacksmith);
    }

    /* ==========  External Functions  ========== */

    function createForge(
        bool isEth,
        address contributionToken,
        uint256 mincontrib,
        uint256 maxcontrib,
        uint256 maxcapital
    ) external onlyRole(BLACK_SMITH) {
        require(
            mincontrib > 0 && maxcontrib > 0 && maxcapital > 0,
            "PRICE_ERROR"
        );
        if(isEth) {
            require(contributionToken == WETH, "INCORRECT_CONTRIBUTION_TOKEN");
        }
        forgeInfo.push(
            ForgeInfo({
                isEth: isEth,
                dynasetLp: 0,
                contributionToken: contributionToken,
                totalContribution: 0,
                minContribution: mincontrib,
                maxContribution: maxcontrib,
                maxCap: maxcapital,
                contributionPeriod: block.timestamp,
                withdrawEnabled: false,
                depositEnabled: false,
                forging: false,
                nextForgeContributorIndex: 0
            })
        );
        totalForges = totalForges + 1;
        emit LogForgeAddition(forgeInfo.length - 1, contributionToken);
    }

    function startForging(uint256 forgeId) external onlyRole(BLACK_SMITH) {
        ForgeInfo memory forge = forgeInfo[forgeId];
        require(!forge.forging, "ERR_FORGING_STARTED");
        require(
            forge.nextForgeContributorIndex < contributors[forgeId].length,
            "ERR_NO_DEPOSITORS"
        );
        forge.forging = true;
        forge.depositEnabled = false;
        forgeInfo[forgeId] = forge;
        emit ForgingStarted(forgeId, forge.nextForgeContributorIndex);
    }

    //select forge to mint to assign the dynaset tokens to it
    //mint from the contributions set to that forge
    function forgeFunction(
        uint256 forgeId,
        uint256 contributorsToMint,
        uint256 minimumAmountOut
    ) external nonReentrant onlyRole(BLACK_SMITH) {
        uint256 _forgeId = forgeId; // avoid stack too deep
        ForgeInfo memory forge = forgeInfo[_forgeId];
        require(forge.forging, "ERR_FORGING_NOT_STARTED");
        require(!forge.depositEnabled, "ERR_DEPOSITS_NOT_DISABLED");

        require(contributorsToMint > 0, "CONTRIBUTORS_TO_MINT_IS_ZERO");
        uint256 finalIndex = forge.nextForgeContributorIndex + (contributorsToMint - 1);
        uint256 totalContributors = contributors[_forgeId].length;
        forge.forging = (finalIndex < totalContributors - 1);
        if (finalIndex >= totalContributors) {
            finalIndex = totalContributors - 1;
        }

        uint256 forgedAmount;
        uint256 amountToForge;
        uint256 i;

        for (i = forge.nextForgeContributorIndex; i <= finalIndex; i++) {
            amountToForge += contributors[_forgeId][i].contributedAmount;
        }
        require(amountToForge > 0, "ERR_AMOUNT_TO_FORGE_ZERO");
        uint256 tokensMinted = _mintDynaset(forge.contributionToken, amountToForge);
        require(tokensMinted >= minimumAmountOut, "ERR_MINIMUM_AMOUNT_OUT");
        
        for (i = forge.nextForgeContributorIndex; i <= finalIndex && forgedAmount < amountToForge; i++) {
            address contributorAddress = contributors[_forgeId][i].contributorAddress;
            UserInfo storage user = userInfo[_forgeId][contributorAddress];
            uint256 userContributedAmount = contributors[_forgeId][i].contributedAmount;
            
            forgedAmount += userContributedAmount;
            user.depositAmount = user.depositAmount - userContributedAmount;
            uint256 userTokensMinted = tokensMinted * userContributedAmount / amountToForge;
            user.dynasetsOwed += userTokensMinted;
            emit Forged(
                contributorAddress,
                userTokensMinted,
                userContributedAmount
            );
        }
        forge.nextForgeContributorIndex = finalIndex + 1;
        forge.totalContribution = forge.totalContribution - forgedAmount;
        forge.dynasetLp += tokensMinted;
        forgeInfo[_forgeId] = forge;
    }

    // deposits funds to the forge and the contribution is added to the to address.
    // the to address will receive the dynaset LPs.
    function deposit(
        uint256 forgeId,
        uint256 amount,
        address to
    ) external nonReentrant payable {
        require(to != address(0), "ERR_ZERO_ADDRESS");
        ForgeInfo memory forge = forgeInfo[forgeId];
        require(forge.depositEnabled, "ERR_DEPOSIT_DISABLED");

        UserInfo storage user = userInfo[forgeId][to];
        if (forge.isEth) {
            require(amount == msg.value, "ERR_INVALID_AMOUNT_VALUE");

            uint256 totalContribution = user.depositAmount + msg.value;

            require(
                forge.minContribution <= amount,
                "ERR_AMOUNT_BELOW_MINCONTRIBUTION"
            );

            require(
                totalContribution <= forge.maxContribution,
                "ERR_AMOUNT_ABOVE_MAXCONTRIBUTION"
            );

            //3. `forge.maxCap` limit may be exceeded if `forge.isEth` flag is `true`.
            require(
                (forge.totalContribution + msg.value) <= forge.maxCap,
                "MAX_CAP"
            );
            //convert to weth the eth deposited to the contract
            //comment to run tests
            user.depositAmount = (user.depositAmount + msg.value);
            forge.totalContribution = (forge.totalContribution + msg.value);
            forgeInfo[forgeId] = forge;
            contributors[forgeId].push(Contributor(to, msg.value));

            IWETH(WETH).deposit{value: msg.value}();
            emit Deposited(msg.sender, to, amount);
        } else {
            require(
                (forge.totalContribution + amount) <= forge.maxCap,
                "MAX_CAP"
            );
            IERC20 tokenContribution = IERC20(forge.contributionToken);
            require(
                tokenContribution.balanceOf(msg.sender) >= amount,
                "ERR_NOT_ENOUGH_TOKENS"
            );
            require(
                tokenContribution.allowance(msg.sender, address(this)) >=
                    amount,
                "ERR_INSUFFICIENT_ALLOWANCE"
            );

            uint256 contribution = user.depositAmount + amount;

            require(
                forge.minContribution <= contribution,
                "ERR_AMOUNT_BELOW_MINCONTRIBUTION"
            );

            require(
                contribution <= forge.maxContribution,
                "ERR_AMOUNT_ABOVE_MAXCONTRIBUTION"
            );
            require(
                tokenContribution.balanceOf(address(this)) <= forge.maxCap,
                "MAX_CAP"
            );
            user.depositAmount = contribution;
            forge.totalContribution = forge.totalContribution + amount;
            forgeInfo[forgeId] = forge;
            contributors[forgeId].push(Contributor(to, amount));
            tokenContribution.safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            emit Deposited(msg.sender, to, amount);
        }
    }

    function redeem(
        uint256 forgeId,
        uint256 amount,
        address redeemToken,
        uint256 minimumAmountOut
    ) public nonReentrant {
        ForgeInfo memory forge = forgeInfo[forgeId];
        require(forge.withdrawEnabled, "ERR_WITHDRAW_DISABLED");

        UserInfo storage user = userInfo[forgeId][msg.sender];
        //require(userbalance on dynaset)
        require(user.dynasetsOwed >= amount, "ERR_INSUFFICIENT_USER_BALANCE");

        uint256 dynasetBalance = dynaset.balanceOf(
            address(this)
        );
        require(dynasetBalance >= amount, "ERR_FORGE_BALANCE_INSUFFICIENT");
        uint256 startTime = forge.contributionPeriod;
        uint256 amountSlashed = capitalSlash(amount, startTime);
        totalFee = totalFee + (amount - amountSlashed);
        (address[] memory tokens, uint256[] memory amounts) = dynaset.calcTokensForAmount(amountSlashed);
        address _redeemToken = redeemToken; // avoid stack too deep
        require(
            _checkValidToken(tokens, _redeemToken),
            "ERR_INVALID_REDEEM_TOKEN"
        );

        uint256 initialRedeemTokenBalance = IERC20(_redeemToken).balanceOf(
            address(this)
        );
        forge.dynasetLp = forge.dynasetLp - amount;
        forgeInfo[forgeId] = forge;
        user.dynasetsOwed = user.dynasetsOwed - amount;
        userInfo[forgeId][msg.sender] = user;
        dynaset.exitDynaset(amountSlashed);
        uint256 amountOut = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            address tokenOut = tokens[i];
            uint256 amountIn = amounts[i];
            require(
                IERC20(tokenOut).balanceOf(address(this)) >= amountIn,
                "ERR_INSUFFICIENT_FUNDS_MINT"
            );
            // for all tokens execpt the redeem token Swap the tokens and
            // send them to the user address
            // if the tokenOut == redeemToken the funds will be transfered outsede this for loop
            if (tokenOut != _redeemToken) {
                IERC20(tokenOut).safeIncreaseAllowance(
                    uniswapV2Router,
                    amountIn
                );
                address wethAddress = WETH;
                uint256 pathLength;
                if (tokenOut != wethAddress && _redeemToken != wethAddress) {
                    pathLength = 3;
                } else {
                    pathLength = 2;
                }
                address[] memory path;
                path = new address[](pathLength);
                path[0] = tokenOut;
                if (tokenOut != wethAddress && _redeemToken != wethAddress) {
                    path[1] = wethAddress;
                    path[2] = _redeemToken;
                } else {
                    path[1] = _redeemToken;
                }
                uint256[] memory uniAmountsOut = IUniswapV2Router(uniswapV2Router).getAmountsOut(amountIn, path);
                uint256 minimumAmountOut_ = uniAmountsOut[pathLength - 1] 
                                            * (SLIPPAGE_FACTOR - slippage) / SLIPPAGE_FACTOR;
                //then we will call swapExactTokensForTokens
                //for the deadline we will pass in block.timestamp + deadline
                //the deadline is the latest time the trade is valid for
                uint256[] memory amountsOut = IUniswapV2Router(uniswapV2Router)
                    .swapExactTokensForTokens(
                        amountIn,
                        minimumAmountOut_,
                        path,
                        msg.sender,
                        block.timestamp + deadline
                    );
                require(amountsOut.length == path.length, "ERR_SWAP_FAILED");
                amountOut += amountsOut[amountsOut.length - 1];
            } else {
                amountOut += amountIn;
            }
        }
        require(amountOut >= minimumAmountOut, "ERR_MINIMUM_AMOUNT_OUT");
        uint256 amountToTransfer = (IERC20(_redeemToken).balanceOf(address(this)) - initialRedeemTokenBalance);
        IERC20(_redeemToken).safeTransfer(msg.sender, amountToTransfer);
        emit Redeemed(msg.sender, amount);
    }

    function setlpWithdraw(bool status) external onlyRole(BLACK_SMITH) {
        lpWithdraw = status;
        emit SetlpWithdraw(lpWithdraw);
    }

    function withdrawFee() external nonReentrant onlyRole(BLACK_SMITH) {
        require(dynaset.balanceOf(address(this)) >= totalFee, "ERR_INSUFFICIENT_BALANCE");
        uint256 feeToRedeem = totalFee;
        totalFee = 0;
        require(dynaset.transfer(msg.sender, feeToRedeem), "ERR_TRANSFER_FAILED");
    }

    function setWithdraw(bool status, uint256 forgeId) external onlyRole(BLACK_SMITH) {
        require(forgeId < totalForges, "ERR_NONEXISTENT_FORGE");
        ForgeInfo memory forge = forgeInfo[forgeId];
        forge.withdrawEnabled = status;
        forgeInfo[forgeId] = forge;
        emit ForgeWithdrawEnabled(status, forgeId);
    }

    function setDeposit(bool status, uint256 forgeId) external onlyRole(BLACK_SMITH) {
        require(forgeId < totalForges, "ERR_NONEXISTENT_FORGE");
        ForgeInfo memory forge = forgeInfo[forgeId];
        forge.depositEnabled = status;
        forgeInfo[forgeId] = forge;
        emit ForgeDepositEnabled(status, forgeId);
    }

    function setDeadline(uint256 newDeadline) external onlyRole(BLACK_SMITH) {
        deadline = newDeadline;
    }

    function upgradeUniswapV2Router(address newUniswapV2Router) external onlyRole(BLACK_SMITH) {
        require(newUniswapV2Router != address(0), "ERR_ADDRESS_ZERO");
        uniswapV2Router = newUniswapV2Router;
        emit RouterUpgraded(newUniswapV2Router);
    }

    function depositOutput(uint256 forgeId, uint256 amount) public nonReentrant {
        ForgeInfo memory forge = forgeInfo[forgeId];
        UserInfo storage user = userInfo[forgeId][msg.sender];

        require(dynaset.balanceOf(msg.sender) >= amount, "ERR_INSUFFICIENT_DEPOSITOR_BALANCE");

        user.dynasetsOwed = user.dynasetsOwed + amount;
        userInfo[forgeId][msg.sender] = user;

        forge.dynasetLp = forge.dynasetLp + amount;
        forgeInfo[forgeId] = forge;

        require(dynaset.transferFrom(msg.sender, address(this), amount), "ERR_TRANSFER_FAILED");
        emit DepositedLP(msg.sender, forgeId, amount);
    }

    function withdrawOutput(uint256 forgeId, uint256 amount) external nonReentrant {
        ForgeInfo memory forge = forgeInfo[forgeId];
        UserInfo storage user = userInfo[forgeId][msg.sender];

        require(lpWithdraw, "ERR_WITHDRAW_DISABLED");
        require(dynaset.balanceOf(address(this)) >= user.dynasetsOwed, "ERR_INSUFFICIENT_CONTRACT_BALANCE");
        require(user.dynasetsOwed >= amount, "ERR_INSUFFICIENT_USER_BALANCE");
        
        user.dynasetsOwed = user.dynasetsOwed - (amount);
        userInfo[forgeId][msg.sender] = user;

        forge.dynasetLp = forge.dynasetLp - (amount);
        forgeInfo[forgeId] = forge;

        require(dynaset.transfer(msg.sender, amount), "ERR_TRANSFER_FAILED");
        emit Withdraw(msg.sender, amount);
    }

    // the dynaset tokens are transfered from wallet to forgeContract
    // which are then redeemed to desired redeemToken
    // Did not add reEntrency Guard because both depositOutput and
    // redeem are nonReentrant 
    function redeemFromWallet(
        uint256 forgeId,
        uint256 amount,
        address redeemToken,
        uint256 minimumAmountOut
    ) external {
        depositOutput(forgeId, amount);
        redeem(forgeId, amount, redeemToken, minimumAmountOut);
    }

    function setSlippage(uint256 newSlippage) external onlyRole(BLACK_SMITH) {
        require(newSlippage < (SLIPPAGE_FACTOR / 2), "SLIPPAGE_TOO_HIGH");
        slippage = newSlippage;
    }
    
    function updateOracle(address newDynasetTvlOracle) external onlyRole(BLACK_SMITH) {
        dynasetTvlOracle = IDynasetTvlOracle(newDynasetTvlOracle);
        emit OracleUpdated(newDynasetTvlOracle);
    }

    function getUserDynasetsOwned(uint256 forgeId, address user) external view returns (uint256) {
        return userInfo[forgeId][user].dynasetsOwed;
    }

    function getUserContribution(uint256 forgeId, address user) external view returns (uint256) {
        return userInfo[forgeId][user].depositAmount;
    }

    function getForgeBalance(uint256 forgeId) external view returns (uint256) {
        return forgeInfo[forgeId].totalContribution;
    }

    function getContributor(uint256 id, uint256 index) external view returns (address) {
        return contributors[id][index].contributorAddress;
    }

    /* ==========  Public Functions  ========== */

    function calculateContributionUsdc(uint256 forgeId) public view returns (uint256 contrib) {
        ForgeInfo memory forge = forgeInfo[forgeId];
        uint256 contributionAmount = forge.totalContribution;
        address contributionToken = forge.contributionToken;
        if (contributionToken == USDC) {
            return contributionAmount;
        } else {
            return dynasetTvlOracle.tokenUsdcValue(contributionToken, contributionAmount);
        }
    }

    // withdrawal fee calculation based on contribution time
    // 0-30 days 5%
    // 31-60 days 4%
    // 61 - 90 days 2.5%
    // above 91 days 0%
    function capitalSlash(uint256 amount, uint256 contributionTime) public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        if ((contributionTime <= currentTime)
        && (currentTime < contributionTime + WITHDRAW_FEE_5_PERCENT_PERIOD)) {
            return amount * (WITHDRAW_FEE_FACTOR - WITHDRAW_FEE_5_PERCENT) / WITHDRAW_FEE_FACTOR;
        }
        if ((contributionTime + WITHDRAW_FEE_5_PERCENT_PERIOD <= currentTime) 
        && (currentTime < contributionTime + WITHDRAW_FEE_4_PERCENT_PERIOD)) {
            return amount * (WITHDRAW_FEE_FACTOR - WITHDRAW_FEE_4_PERCENT) / WITHDRAW_FEE_FACTOR;
        }
        if ((contributionTime + WITHDRAW_FEE_4_PERCENT_PERIOD <= currentTime) 
        && (currentTime < contributionTime + WITHDRAW_FEE_2_5_PERCENT_PERIOD)) {
            return amount * (WITHDRAW_FEE_FACTOR - WITHDRAW_FEE_2_5_PERCENT) / WITHDRAW_FEE_FACTOR;
        }
        return amount;
    }
  
    // ! Keeping it commented to verify it is not used anywhere.
    // function getDepositors(uint256 forgeId) external view returns (address[] memory depositors) {
    //     uint256 length = contributors[forgeId].length;
    //     depositors = new address[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         depositors[i] = contributors[forgeId][i].contributorAddress;
    //     }
    // }

    // This method should multiply by 18 decimals before doing division 
    // to be sure that the outputAmount has 18 decimals precision
    function getOutputAmount(uint256 forgeId) public view returns (uint256 amount) {
        uint256 contributionUsdcValue = calculateContributionUsdc(forgeId);
        uint256 output = (contributionUsdcValue * (10**(DYNASET_DECIMALS + DYNASET_DECIMALS - USDC_DECIMALS)))
                         / dynasetTvlOracle.dynasetUsdcValuePerShare();
        return output;
    }

    /* ==========  Internal Functions  ========== */


    function _mintDynaset(address _contributionToken, uint256 contributionAmount) internal returns (uint256) {
        uint256 contributionUsdcValue = dynasetTvlOracle.tokenUsdcValue(_contributionToken, contributionAmount);
        address[] memory tokens;
        uint256[] memory ratios;
        uint256 totalUSDC;
        (tokens, ratios, totalUSDC) = dynasetTvlOracle.dynasetTokenUsdcRatios();
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 amountIn = contributionAmount * ratios[i] / 1e18;
            uint256 amountOut;
            if (token == _contributionToken) {
                amountOut = amountIn;
            } else {
                address contributionToken = _contributionToken;
                bool routeOverWeth = (contributionToken != WETH && token != WETH);
                uint256 pathLength = routeOverWeth ? 3 : 2;
                address[] memory path = new address[](pathLength);
                path[0] = contributionToken;
                if (routeOverWeth) {
                    path[1] = WETH;
                }
                path[pathLength - 1] = token;

                uint256[] memory amountsOut = IUniswapV2Router(uniswapV2Router).getAmountsOut(amountIn, path);
                amountOut = amountsOut[pathLength - 1];

                IERC20(contributionToken).safeIncreaseAllowance(uniswapV2Router, amountIn);
                require(
                    IUniswapV2Router(uniswapV2Router)
                        .swapExactTokensForTokens(
                            amountIn,
                            amountOut * (SLIPPAGE_FACTOR - slippage) / SLIPPAGE_FACTOR,
                            path,
                            address(this),
                            block.timestamp + deadline
                        )
                        .length == path.length,
                    "ERR_SWAP_FAILED"
                );
            }
            IERC20(token).safeIncreaseAllowance(address(dynaset), amountOut);
        }
        uint256 totalSupply = dynaset.totalSupply();
        uint256 sharesToMint = contributionUsdcValue * totalSupply / totalUSDC;
        return dynaset.joinDynaset(sharesToMint);
    }

    function _checkValidToken(address[] memory tokens, address redeemToken) internal pure returns (bool valid) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == redeemToken) {
                valid = true;
                break;
            }
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "./IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        //amount of tokens we are sending in
        uint256 amountIn,
        //the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
        //list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
        //this is the address we are going to send the output tokens to
        address to,
        //the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "./IERC20.sol";

interface IDynaset is IERC20 {
    function joinDynaset(uint256 _amount) external returns (uint256);

    function exitDynaset(uint256 _amount) external;

    function calcTokensForAmount(uint256 _amount)
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);
        
    function getTokenAmounts()
        external
        view
        returns (address[] memory tokens, uint256[] memory amounts);

    function getCurrentTokens() external view returns (address[] memory tokens);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IDynasetTvlOracle {
    function dynasetTvlUsdc() external view returns (uint256 total_usd);

    function tokenUsdcValue(address _tokenIn, uint256 _amount) external view returns (uint256);

    function dynasetUsdcValuePerShare() external view returns (uint256);

    function dynasetTokenUsdcRatios() external view returns (address[] memory, uint256[] memory, uint256);
    
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IERC20 {
    event Approval(address indexed _src, address indexed _dst, uint256 _amount);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _whom) external view returns (uint256);

    function allowance(address _src, address _dst)
        external
        view
        returns (uint256);

    function approve(address _dst, uint256 _amount) external returns (bool);

    function transfer(address _dst, uint256 _amount) external returns (bool);

    function transferFrom(
        address _src,
        address _dst,
        uint256 _amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}