/*
 * SPDX-License-Identifier: MIT
 */

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "./BeanSilo.sol";
import "../../../libraries/LibClaim.sol";
import "../../../libraries/LibMarket.sol";

/*
 * @author Publius
 * @title Silo handles depositing and withdrawing Beans and LP, and updating the Silo.
 */
contract SiloFacet is BeanSilo {
    event BeanAllocation(address indexed account, uint256 beans);

    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    /*
     * Popcorn
     */

    // Deposit
    function claimAndDepositBeans(uint256 amount, LibClaim.Claim calldata claim) external siloNonReentrant {
        allocateBeans(claim, amount);
        _depositBeans(amount);
        LibMarket.claimRefund(claim);
    }

    function claimBuyAndDepositBeans(
        uint256 amount,
        uint256 buyAmount,
        LibClaim.Claim calldata claim
    ) external payable siloNonReentrant {
        allocateBeans(claim, amount);
        uint256 boughtAmount = LibMarket.buyAndDeposit(buyAmount);
        _depositBeans(boughtAmount.add(amount));
    }

    function depositBeans(uint256 amount) external silo {
        bean().transferFrom(msg.sender, address(this), amount);
        _depositBeans(amount);
    }

    function buyAndDepositBeans(uint256 amount, uint256 buyAmount) external payable siloNonReentrant {
        uint256 boughtAmount = LibMarket.buyAndDeposit(buyAmount);
        if (amount > 0) bean().transferFrom(msg.sender, address(this), amount);
        _depositBeans(boughtAmount.add(amount));
    }

    // Withdraw

    function withdrawBeans(uint32[] calldata crates, uint256[] calldata amounts) external silo {
        _withdrawBeans(crates, amounts);
    }

    function claimAndWithdrawBeans(
        uint32[] calldata crates,
        uint256[] calldata amounts,
        LibClaim.Claim calldata claim
    ) external siloNonReentrant {
        LibClaim.claim(claim);
        _withdrawBeans(crates, amounts);
        LibMarket.claimRefund(claim);
    }

    /*
     * LP
     */

    function claimAndDepositLP(uint256 amount, LibClaim.Claim calldata claim) external siloNonReentrant {
        LibClaim.claim(claim);
        pair().transferFrom(msg.sender, address(this), amount);
        _depositLP(amount);
        LibMarket.claimRefund(claim);
    }

    function claimAddAndDepositLP(
        uint256 lp,
        uint256 buyBeanAmount,
        uint256 buyEthAmount,
        LibMarket.AddLiquidity calldata al,
        LibClaim.Claim calldata claim
    ) external payable siloNonReentrant {
        LibClaim.claim(claim);
        _addAndDepositLP(lp, buyBeanAmount, buyEthAmount, al);
    }

    function depositLP(uint256 amount) external siloNonReentrant {
        pair().transferFrom(msg.sender, address(this), amount);
        _depositLP(amount);
    }

    function addAndDepositLP(
        uint256 lp,
        uint256 buyBeanAmount,
        uint256 buyEthAmount,
        LibMarket.AddLiquidity calldata al
    ) external payable siloNonReentrant {
        require(buyBeanAmount == 0 || buyEthAmount == 0, "Silo: Silo: Cant buy Ether and Beans.");
        _addAndDepositLP(lp, buyBeanAmount, buyEthAmount, al);
    }

    function _addAndDepositLP(
        uint256 lp,
        uint256 buyBeanAmount,
        uint256 buyEthAmount,
        LibMarket.AddLiquidity calldata al
    ) internal {
        uint256 boughtLP = LibMarket.swapAndAddLiquidity(buyBeanAmount, buyEthAmount, al);
        if (lp > 0) pair().transferFrom(msg.sender, address(this), lp);
        _depositLP(lp.add(boughtLP));
        LibMarket.refund();
    }

    /*
     * Withdraw
     */

    function claimAndWithdrawLP(
        uint32[] calldata crates,
        uint256[] calldata amounts,
        LibClaim.Claim calldata claim
    ) external siloNonReentrant {
        LibClaim.claim(claim);
        _withdrawLP(crates, amounts);
        LibMarket.claimRefund(claim);
    }

    function withdrawLP(uint32[] calldata crates, uint256[] calldata amounts) external silo {
        _withdrawLP(crates, amounts);
    }

    function allocateBeans(LibClaim.Claim calldata c, uint256 transferBeans) private {
        LibClaim.claim(c);
        LibMarket.allocateBeans(transferBeans);
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "./LPSilo.sol";

/**
 * @author Publius
 * @title Popcorn Silo
 **/
contract BeanSilo is LPSilo {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    event BeanDeposit(address indexed account, uint256 season, uint256 beans);
    event BeanRemove(address indexed account, uint32[] crates, uint256[] crateBeans, uint256 beans);
    event BeanWithdraw(address indexed account, uint256 season, uint256 beans);

    /**
     * Getters
     **/

    function totalDepositedBeans() public view returns (uint256) {
        return s.bean.deposited;
    }

    function totalWithdrawnBeans() public view returns (uint256) {
        return s.bean.withdrawn;
    }

    function beanDeposit(address account, uint32 id) public view returns (uint256) {
        return s.a[account].bean.deposits[id];
    }

    function beanWithdrawal(address account, uint32 i) public view returns (uint256) {
        return s.a[account].bean.withdrawals[i];
    }

    /**
     * Internal
     **/

    function _depositBeans(uint256 amount) internal {
        require(amount > 0, "Silo: No beans.");
        LibBeanSilo.incrementDepositedBeans(amount);
        LibSilo.depositSiloAssets(msg.sender, amount.mul(C.getSeedsPerBean()), amount.mul(C.getStalkPerBean()));
        LibBeanSilo.addBeanDeposit(msg.sender, season(), amount);
    }

    function _withdrawBeans(uint32[] calldata crates, uint256[] calldata amounts) internal {
        require(crates.length == amounts.length, "Silo: Crates, amounts are diff lengths.");
        (uint256 beansRemoved, uint256 stalkRemoved) = removeBeanDeposits(crates, amounts);
        addBeanWithdrawal(msg.sender, season() + s.season.withdrawSeasons, beansRemoved);
        LibBeanSilo.decrementDepositedBeans(beansRemoved);
        LibSilo.withdrawSiloAssets(msg.sender, beansRemoved.mul(C.getSeedsPerBean()), stalkRemoved);
        LibSilo.updateBalanceOfRainStalk(msg.sender);
        LibCheck.beanBalanceCheck();
    }

    function removeBeanDeposits(uint32[] calldata crates, uint256[] calldata amounts) private returns (uint256 beansRemoved, uint256 stalkRemoved) {
        for (uint256 i; i < crates.length; i++) {
            uint256 crateBeans = LibBeanSilo.removeBeanDeposit(msg.sender, crates[i], amounts[i]);
            beansRemoved = beansRemoved.add(crateBeans);
            stalkRemoved = stalkRemoved.add(crateBeans.mul(C.getStalkPerBean()).add(LibSilo.stalkReward(crateBeans.mul(C.getSeedsPerBean()), season() - crates[i])));
        }
        emit BeanRemove(msg.sender, crates, amounts, beansRemoved);
    }

    function addBeanWithdrawal(
        address account,
        uint32 arrivalSeason,
        uint256 amount
    ) private {
        s.a[account].bean.withdrawals[arrivalSeason] = s.a[account].bean.withdrawals[arrivalSeason].add(amount);
        s.bean.withdrawn = s.bean.withdrawn.add(amount);
        emit BeanWithdraw(msg.sender, arrivalSeason, amount);
    }

    function bean() internal view returns (IBean) {
        return IBean(s.c.bean);
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./LibCheck.sol";
import "./LibInternal.sol";
import "./LibMarket.sol";
import "./LibAppStorage.sol";
import "./LibSafeMath32.sol";
import "../interfaces/IWETH.sol";

/**
 * @author Publius
 * @title Claim Library handles claiming Popcorn and LP withdrawals, harvesting plots and claiming Ether.
 **/
library LibClaim {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    event BeanClaim(address indexed account, uint32[] withdrawals, uint256 beans);
    event LPClaim(address indexed account, uint32[] withdrawals, uint256 lp);
    event BnbClaim(address indexed account, uint256 bnb);
    event Harvest(address indexed account, uint256[] plots, uint256 beans);
    event PodListingCancelled(address indexed account, uint256 indexed index);

    struct Claim {
        uint32[] beanWithdrawals;
        uint32[] lpWithdrawals;
        uint256[] plots;
        bool claimBnb;
        bool convertLP;
        uint256 minBeanAmount;
        uint256 minEthAmount;
        bool toWallet;
    }

    function claim(Claim calldata c) public returns (uint256 beansClaimed) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (c.beanWithdrawals.length > 0) beansClaimed = beansClaimed.add(claimBeans(c.beanWithdrawals));
        if (c.plots.length > 0) beansClaimed = beansClaimed.add(harvest(c.plots));
        if (c.lpWithdrawals.length > 0) {
            if (c.convertLP) {
                if (!c.toWallet) beansClaimed = beansClaimed.add(removeClaimLPAndWrapBeans(c.lpWithdrawals, c.minBeanAmount, c.minEthAmount));
                else removeAndClaimLP(c.lpWithdrawals, c.minBeanAmount, c.minEthAmount);
            } else claimLP(c.lpWithdrawals);
        }
        if (c.claimBnb) claimBnb();

        if (beansClaimed > 0) {
            if (c.toWallet) IBean(s.c.bean).transfer(msg.sender, beansClaimed);
            else s.a[msg.sender].wrappedBeans = s.a[msg.sender].wrappedBeans.add(beansClaimed);
        }
    }

    // Claim Beans

    function claimBeans(uint32[] calldata withdrawals) public returns (uint256 beansClaimed) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint256 i; i < withdrawals.length; i++) {
            require(withdrawals[i] <= s.season.current, "Claim: Withdrawal not recievable.");
            beansClaimed = beansClaimed.add(claimBeanWithdrawal(msg.sender, withdrawals[i]));
        }
        emit BeanClaim(msg.sender, withdrawals, beansClaimed);
    }

    function claimBeanWithdrawal(address account, uint32 _s) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 amount = s.a[account].bean.withdrawals[_s];
        require(amount > 0, "Claim: Popcorn withdrawal is empty.");
        delete s.a[account].bean.withdrawals[_s];
        s.bean.withdrawn = s.bean.withdrawn.sub(amount);
        return amount;
    }

    // Claim LP

    function claimLP(uint32[] calldata withdrawals) public {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 lpClaimed = _claimLP(withdrawals);
        IPancakePair(s.c.pair).transfer(msg.sender, lpClaimed);
    }

    function removeAndClaimLP(
        uint32[] calldata withdrawals,
        uint256 minBeanAmount,
        uint256 minEthAmount
    ) public returns (uint256 beans) {
        uint256 lpClaimd = _claimLP(withdrawals);
        (beans, ) = LibMarket.removeLiquidity(lpClaimd, minBeanAmount, minEthAmount);
    }

    function removeClaimLPAndWrapBeans(
        uint32[] calldata withdrawals,
        uint256 minBeanAmount,
        uint256 minEthAmount
    ) private returns (uint256 beans) {
        uint256 lpClaimd = _claimLP(withdrawals);
        (beans, ) = LibMarket.removeLiquidityWithBeanAllocation(lpClaimd, minBeanAmount, minEthAmount);
    }

    function _claimLP(uint32[] calldata withdrawals) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 lpClaimd = 0;
        for (uint256 i; i < withdrawals.length; i++) {
            require(withdrawals[i] <= s.season.current, "Claim: Withdrawal not recievable.");
            lpClaimd = lpClaimd.add(claimLPWithdrawal(msg.sender, withdrawals[i]));
        }
        emit LPClaim(msg.sender, withdrawals, lpClaimd);
        return lpClaimd;
    }

    function claimLPWithdrawal(address account, uint32 _s) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 amount = s.a[account].lp.withdrawals[_s];
        require(amount > 0, "Claim: LP withdrawal is empty.");
        delete s.a[account].lp.withdrawals[_s];
        s.lp.withdrawn = s.lp.withdrawn.sub(amount);
        return amount;
    }

    // Season of Plenty

    function claimBnb() public {
        LibInternal.updateSilo(msg.sender);
        uint256 bnb = claimPlenty(msg.sender);
        emit BnbClaim(msg.sender, bnb);
    }

    function claimPlenty(address account) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.sop.base == 0) return 0;
        uint256 eth = s.a[account].sop.base.mul(s.sop.weth).div(s.sop.base);
        s.sop.weth = s.sop.weth.sub(eth);
        s.sop.base = s.sop.base.sub(s.a[account].sop.base);
        s.a[account].sop.base = 0;
        IWETH(s.c.weth).withdraw(eth);
        (bool success, ) = account.call{value: eth}("");
        require(success, "WETH: BNB transfer failed");
        return eth;
    }

    // Harvest

    function harvest(uint256[] calldata plots) public returns (uint256 beansHarvested) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint256 i; i < plots.length; i++) {
            require(plots[i] < s.f.harvestable, "Claim: Plot not harvestable.");
            require(s.a[msg.sender].field.plots[plots[i]] > 0, "Claim: Plot not harvestable.");
            uint256 harvested = harvestPlot(msg.sender, plots[i]);
            beansHarvested = beansHarvested.add(harvested);
        }
        require(s.f.harvestable.sub(s.f.harvested) >= beansHarvested, "Claim: Not enough Harvestable.");
        s.f.harvested = s.f.harvested.add(beansHarvested);
        emit Harvest(msg.sender, plots, beansHarvested);
    }

    function harvestPlot(address account, uint256 plotId) private returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 pods = s.a[account].field.plots[plotId];
        require(pods > 0, "Claim: Plot is empty.");
        uint256 harvestablePods = s.f.harvestable.sub(plotId);
        delete s.a[account].field.plots[plotId];
        if (s.podListings[plotId] > 0) {
            cancelPodListing(plotId);
        }
        if (harvestablePods >= pods) return pods;
        s.a[account].field.plots[plotId.add(harvestablePods)] = pods.sub(harvestablePods);
        return harvestablePods;
    }

    function cancelPodListing(uint256 index) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        delete s.podListings[index];
        emit PodListingCancelled(msg.sender, index);
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/pancake/IPancakeRouter02.sol";
import "../interfaces/IBean.sol";
import "../interfaces/IWETH.sol";
import "./LibAppStorage.sol";
import "./LibClaim.sol";

/**
 * @author Publius
 * @title Market Library handles swapping, addinga and removing LP on Pancake for Farmer.
 **/
library LibMarket {
    event BeanAllocation(address indexed account, uint256 beans);

    struct DiamondStorage {
        address bean;
        address weth;
        address router;
    }

    struct AddLiquidity {
        uint256 beanAmount;
        uint256 minBeanAmount;
        uint256 minEthAmount;
    }

    using SafeMath for uint256;

    bytes32 private constant MARKET_STORAGE_POSITION = keccak256("diamond.standard.market.storage");

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = MARKET_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function initMarket(
        address bean,
        address weth,
        address router
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        ds.bean = bean;
        ds.weth = weth;
        ds.router = router;
    }

    /**
     * Swap
     **/

    function buy(uint256 buyBeanAmount) internal returns (uint256 amount) {
        (, amount) = _buy(buyBeanAmount, msg.value, msg.sender);
    }

    function buyAndDeposit(uint256 buyBeanAmount) internal returns (uint256 amount) {
        (, amount) = _buy(buyBeanAmount, msg.value, address(this));
    }

    function buyExactTokensToWallet(
        uint256 buyBeanAmount,
        address to,
        bool toWallet
    ) internal returns (uint256 amount) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (toWallet) amount = buyExactTokens(buyBeanAmount, to);
        else {
            amount = buyExactTokens(buyBeanAmount, address(this));
            s.a[to].wrappedBeans = s.a[to].wrappedBeans.add(amount);
        }
    }

    function buyExactTokens(uint256 buyBeanAmount, address to) internal returns (uint256 amount) {
        (uint256 ethAmount, uint256 beanAmount) = _buyExactTokens(buyBeanAmount, msg.value, to);
        allocateEthRefund(msg.value, ethAmount, false);
        return beanAmount;
    }

    function buyAndSow(uint256 buyBeanAmount, uint256 buyEthAmount) internal returns (uint256 amount) {
        if (buyBeanAmount == 0) {
            allocateEthRefund(msg.value, 0, false);
            return 0;
        }
        (uint256 ethAmount, uint256 beanAmount) = _buyExactTokensWETH(buyBeanAmount, buyEthAmount, address(this));
        allocateEthRefund(msg.value, ethAmount, false);
        amount = beanAmount;
    }

    function sellToWETH(uint256 sellBeanAmount, uint256 minBuyEthAmount) internal returns (uint256 amount) {
        (, uint256 outAmount) = _sell(sellBeanAmount, minBuyEthAmount, address(this));
        return outAmount;
    }

    /**
     *  Liquidity
     **/

    function removeLiquidity(
        uint256 liqudity,
        uint256 minBeanAmount,
        uint256 minEthAmount
    ) internal returns (uint256 beanAmount, uint256 ethAmount) {
        DiamondStorage storage ds = diamondStorage();
        return IPancakeRouter02(ds.router).removeLiquidityETH(ds.bean, liqudity, minBeanAmount, minEthAmount, msg.sender, block.timestamp);
    }

    function removeLiquidityWithBeanAllocation(
        uint256 liqudity,
        uint256 minBeanAmount,
        uint256 minEthAmount
    ) internal returns (uint256 beanAmount, uint256 ethAmount) {
        DiamondStorage storage ds = diamondStorage();
        (beanAmount, ethAmount) = IPancakeRouter02(ds.router).removeLiquidity(ds.bean, ds.weth, liqudity, minBeanAmount, minEthAmount, address(this), block.timestamp);
        allocateEthRefund(ethAmount, 0, true);
    }

    function addAndDepositLiquidity(AddLiquidity calldata al) internal returns (uint256) {
        allocateBeans(al.beanAmount);
        (, uint256 liquidity) = addLiquidity(al);
        return liquidity;
    }

    function addLiquidity(AddLiquidity calldata al) internal returns (uint256, uint256) {
        (uint256 beansDeposited, uint256 ethDeposited, uint256 liquidity) = _addLiquidity(msg.value, al.beanAmount, al.minEthAmount, al.minBeanAmount);
        allocateEthRefund(msg.value, ethDeposited, false);
        allocateBeanRefund(al.beanAmount, beansDeposited);
        return (beansDeposited, liquidity);
    }

    function swapAndAddLiquidity(
        uint256 buyBeanAmount,
        uint256 buyEthAmount,
        LibMarket.AddLiquidity calldata al
    ) internal returns (uint256) {
        uint256 boughtLP;
        if (buyBeanAmount > 0) boughtLP = LibMarket.buyBeansAndAddLiquidity(buyBeanAmount, al);
        else if (buyEthAmount > 0) boughtLP = LibMarket.buyEthAndAddLiquidity(buyEthAmount, al);
        else boughtLP = LibMarket.addAndDepositLiquidity(al);
        return boughtLP;
    }

    // al.buyBeanAmount is the amount of beans the user wants to add to LP
    // buyBeanAmount is the amount of beans the person bought to contribute to LP. Note that
    // buyBean amount will AT BEST be equal to al.buyBeanAmount because of slippage.
    // Otherwise, it will almost always be less than al.buyBean amount
    function buyBeansAndAddLiquidity(uint256 buyBeanAmount, AddLiquidity calldata al) internal returns (uint256 liquidity) {
        DiamondStorage storage ds = diamondStorage();
        IWETH(ds.weth).deposit{value: msg.value}();

        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;
        uint256[] memory amounts = IPancakeRouter02(ds.router).getAmountsIn(buyBeanAmount, path);
        (uint256 ethSold, uint256 beans) = _buyWithWETH(buyBeanAmount, amounts[0], address(this));

        // If beans bought does not cover the amount of money to move to LP
        if (al.beanAmount > buyBeanAmount) {
            uint256 newBeanAmount = al.beanAmount - buyBeanAmount;
            allocateBeans(newBeanAmount);
            beans = beans.add(newBeanAmount);
        }
        uint256 ethAdded;
        (beans, ethAdded, liquidity) = _addLiquidityWETH(msg.value.sub(ethSold), beans, al.minEthAmount, al.minBeanAmount);

        allocateBeanRefund(al.beanAmount, beans);
        allocateEthRefund(msg.value, ethAdded.add(ethSold), true);
        return liquidity;
    }

    // This function is called when user sends more value of POPCORN than BNB to LP.
    // Value of POPCORN is converted to equivalent value of BNB.
    function buyEthAndAddLiquidity(uint256 buyWethAmount, AddLiquidity calldata al) internal returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        uint256 sellBeans = _amountIn(buyWethAmount);
        allocateBeans(al.beanAmount.add(sellBeans));
        (uint256 beansSold, uint256 wethBought) = _sell(sellBeans, buyWethAmount, address(this));
        if (msg.value > 0) IWETH(ds.weth).deposit{value: msg.value}();
        (uint256 beans, uint256 ethAdded, uint256 liquidity) = _addLiquidityWETH(msg.value.add(wethBought), al.beanAmount, al.minEthAmount, al.minBeanAmount);

        allocateBeanRefund(al.beanAmount.add(sellBeans), beans.add(beansSold));
        allocateEthRefund(msg.value.add(wethBought), ethAdded, true);
        return liquidity;
    }

    /**
     *  Shed
     **/

    function _sell(
        uint256 sellBeanAmount,
        uint256 minBuyEthAmount,
        address to
    ) internal returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.bean;
        path[1] = ds.weth;
        uint256[] memory amounts = IPancakeRouter02(ds.router).swapExactTokensForTokens(sellBeanAmount, minBuyEthAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _buy(
        uint256 beanAmount,
        uint256 ethAmount,
        address to
    ) private returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;

        uint256[] memory amounts = IPancakeRouter02(ds.router).swapExactETHForTokens{value: ethAmount}(beanAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _buyExactTokens(
        uint256 beanAmount,
        uint256 ethAmount,
        address to
    ) private returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;

        uint256[] memory amounts = IPancakeRouter02(ds.router).swapETHForExactTokens{value: ethAmount}(beanAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _buyExactTokensWETH(
        uint256 beanAmount,
        uint256 ethAmount,
        address to
    ) private returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;
        IWETH(ds.weth).deposit{value: ethAmount}();
        uint256[] memory amounts = IPancakeRouter02(ds.router).swapTokensForExactTokens(beanAmount, ethAmount, path, to, block.timestamp);
        IWETH(ds.weth).withdraw(ethAmount - amounts[0]);
        return (amounts[0], amounts[1]);
    }

    function _buyWithWETH(
        uint256 beanAmount,
        uint256 ethAmount,
        address to
    ) internal returns (uint256 inAmount, uint256 outAmount) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.weth;
        path[1] = ds.bean;

        uint256[] memory amounts = IPancakeRouter02(ds.router).swapExactTokensForTokens(ethAmount, beanAmount, path, to, block.timestamp);
        return (amounts[0], amounts[1]);
    }

    function _addLiquidity(
        uint256 ethAmount,
        uint256 beanAmount,
        uint256 minEthAmount,
        uint256 minBeanAmount
    )
        private
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        DiamondStorage storage ds = diamondStorage();
        return IPancakeRouter02(ds.router).addLiquidityETH{value: ethAmount}(ds.bean, beanAmount, minBeanAmount, minEthAmount, address(this), block.timestamp);
    }

    function _addLiquidityWETH(
        uint256 wethAmount,
        uint256 beanAmount,
        uint256 minWethAmount,
        uint256 minBeanAmount
    )
        internal
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        DiamondStorage storage ds = diamondStorage();
        return IPancakeRouter02(ds.router).addLiquidity(ds.bean, ds.weth, beanAmount, wethAmount, minBeanAmount, minWethAmount, address(this), block.timestamp);
    }

    function _amountIn(uint256 buyWethAmount) internal view returns (uint256) {
        DiamondStorage storage ds = diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.bean;
        path[1] = ds.weth;
        uint256[] memory amounts = IPancakeRouter02(ds.router).getAmountsIn(buyWethAmount, path);
        return amounts[0];
    }

    function allocateBeansToWallet(
        uint256 amount,
        address to,
        bool toWallet
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (toWallet) LibMarket.allocateBeansTo(amount, to);
        else {
            LibMarket.allocateBeansTo(amount, address(this));
            s.a[to].wrappedBeans = s.a[to].wrappedBeans.add(amount);
        }
    }

    function transferBeans(
        address to,
        uint256 amount,
        bool toWallet
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (toWallet) IBean(s.c.bean).transferFrom(msg.sender, to, amount);
        else {
            IBean(s.c.bean).transferFrom(msg.sender, address(this), amount);
            s.a[to].wrappedBeans = s.a[to].wrappedBeans.add(amount);
        }
    }

    function allocateBeans(uint256 amount) internal {
        allocateBeansTo(amount, address(this));
    }

    function allocateBeansTo(uint256 amount, address to) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint256 wrappedBeans = s.a[msg.sender].wrappedBeans;
        uint256 remainingBeans = amount;
        if (wrappedBeans > 0) {
            if (remainingBeans > wrappedBeans) {
                s.a[msg.sender].wrappedBeans = 0;
                remainingBeans = remainingBeans - wrappedBeans;
            } else {
                s.a[msg.sender].wrappedBeans = wrappedBeans - remainingBeans;
                remainingBeans = 0;
            }
            uint256 fromWrappedBeans = amount - remainingBeans;
            emit BeanAllocation(msg.sender, fromWrappedBeans);
            if (to != address(this)) IBean(s.c.bean).transfer(to, fromWrappedBeans);
        }
        if (remainingBeans > 0) IBean(s.c.bean).transferFrom(msg.sender, to, remainingBeans);
    }

    // Allocate Popcorn Refund stores the Popcorn refund amount in the state to be refunded at the end of the transaction.
    function allocateBeanRefund(uint256 inputAmount, uint256 amount) internal {
        if (inputAmount > amount) {
            AppStorage storage s = LibAppStorage.diamondStorage();
            if (s.refundStatus % 2 == 1) {
                s.refundStatus += 1;
                s.beanRefundAmount = inputAmount - amount;
            } else s.beanRefundAmount = s.beanRefundAmount.add(inputAmount - amount);
        }
    }

    // Allocate BNB Refund stores the BNB refund amount in the state to be refunded at the end of the transaction.
    function allocateEthRefund(
        uint256 inputAmount,
        uint256 amount,
        bool weth
    ) internal {
        if (inputAmount > amount) {
            AppStorage storage s = LibAppStorage.diamondStorage();
            if (weth) IWETH(s.c.weth).withdraw(inputAmount - amount);
            if (s.refundStatus < 3) {
                s.refundStatus += 2;
                s.ethRefundAmount = inputAmount - amount;
            } else s.ethRefundAmount = s.ethRefundAmount.add(inputAmount - amount);
        }
    }

    function claimRefund(LibClaim.Claim calldata c) internal {
        // The only case that a Claim triggers an BNB refund is
        // if the farmer claims LP, removes the LP and wraps the underlying Beans
        if (c.convertLP && !c.toWallet && c.lpWithdrawals.length > 0) refund();
    }

    function refund() internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // If Refund state = 1 -> No refund
        // If Refund state is even -> Refund Beans
        // if Refund state > 2 -> Refund BNB

        uint256 rs = s.refundStatus;
        if (rs > 1) {
            if (rs > 2) {
                (bool success, ) = msg.sender.call{value: s.ethRefundAmount}("");
                require(success, "Market: Refund failed.");
                rs -= 2;
                s.ethRefundAmount = 1;
            }
            if (rs == 2) {
                IBean(s.c.bean).transfer(msg.sender, s.beanRefundAmount);
                s.beanRefundAmount = 1;
            }
            s.refundStatus = 1;
        }
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "./UpdateSilo.sol";
import "../../../libraries/Silo/LibLPSilo.sol";
import "../../../libraries/LibBeanBnb.sol";

/**
 * @author Publius
 * @title LP Silo
 **/
contract LPSilo is UpdateSilo {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    event LPDeposit(address indexed account, uint256 season, uint256 lp, uint256 seeds);
    event LPRemove(address indexed account, uint32[] crates, uint256[] crateLP, uint256 lp);
    event LPWithdraw(address indexed account, uint256 season, uint256 lp);

    /**
     * Getters
     **/

    function totalDepositedLP() public view returns (uint256) {
        return s.lp.deposited;
    }

    function totalWithdrawnLP() public view returns (uint256) {
        return s.lp.withdrawn;
    }

    function lpDeposit(address account, uint32 id) public view returns (uint256, uint256) {
        return (s.a[account].lp.deposits[id], s.a[account].lp.depositSeeds[id]);
    }

    function lpWithdrawal(address account, uint32 i) public view returns (uint256) {
        return s.a[account].lp.withdrawals[i];
    }

    /**
     * Internal
     **/

    function _depositLP(uint256 amount) internal {
        uint256 lpb = LibBeanBnb.lpToLPBeans(amount);
        require(lpb > 0, "Silo: No Beans under LP.");
        LibLPSilo.incrementDepositedLP(amount);
        uint256 seeds = lpb.mul(C.getSeedsPerLPBean());
        LibSilo.depositSiloAssets(msg.sender, seeds, lpb.mul(C.getStalkPerBean()));
        LibLPSilo.addLPDeposit(msg.sender, season(), amount, seeds);

        LibCheck.lpBalanceCheck();
    }

    function _withdrawLP(uint32[] calldata crates, uint256[] calldata amounts) internal {
        require(crates.length == amounts.length, "Silo: Crates, amounts are diff lengths.");
        (uint256 lpRemoved, uint256 stalkRemoved, uint256 seedsRemoved) = removeLPDeposits(crates, amounts);
        uint32 arrivalSeason = season() + s.season.withdrawSeasons;
        addLPWithdrawal(msg.sender, arrivalSeason, lpRemoved);
        LibLPSilo.decrementDepositedLP(lpRemoved);
        LibSilo.withdrawSiloAssets(msg.sender, seedsRemoved, stalkRemoved);
        LibSilo.updateBalanceOfRainStalk(msg.sender);

        LibCheck.lpBalanceCheck();
    }

    function removeLPDeposits(uint32[] calldata crates, uint256[] calldata amounts)
        private
        returns (
            uint256 lpRemoved,
            uint256 stalkRemoved,
            uint256 seedsRemoved
        )
    {
        for (uint256 i; i < crates.length; i++) {
            (uint256 crateBeans, uint256 crateSeeds) = LibLPSilo.removeLPDeposit(msg.sender, crates[i], amounts[i]);
            lpRemoved = lpRemoved.add(crateBeans);
            stalkRemoved = stalkRemoved.add(crateSeeds.mul(C.getStalkPerLPSeed()).add(LibSilo.stalkReward(crateSeeds, season() - crates[i])));
            seedsRemoved = seedsRemoved.add(crateSeeds);
        }
        emit LPRemove(msg.sender, crates, amounts, lpRemoved);
    }

    function addLPWithdrawal(
        address account,
        uint32 arrivalSeason,
        uint256 amount
    ) private {
        s.a[account].lp.withdrawals[arrivalSeason] = s.a[account].lp.withdrawals[arrivalSeason].add(amount);
        s.lp.withdrawn = s.lp.withdrawn.add(amount);
        emit LPWithdraw(msg.sender, arrivalSeason, amount);
    }

    function pair() internal view returns (IPancakePair) {
        return IPancakePair(s.c.pair);
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "./SiloExit.sol";
import "../../../libraries/LibCheck.sol";
import "../../../libraries/LibInternal.sol";
import "../../../libraries/LibMarket.sol";
import "../../../libraries/Silo/LibSilo.sol";
import "../../../libraries/Silo/LibBeanSilo.sol";

/**
 * @author Publius
 * @title Silo Entrance
 **/
contract UpdateSilo is SiloExit {
    using SafeMath for uint256;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status = 1;

    /**
     * Update
     **/

    function updateSilo(address account) public payable {
        uint32 update = lastUpdate(account);
        if (update >= season()) return;
        uint256 grownStalk;
        if (s.a[account].s.seeds > 0) grownStalk = balanceOfGrownStalk(account);
        if (s.a[account].roots > 0) {
            farmSops(account, update);
            farmLegacyBeans(account, update);
            farmBeans(account, update);
        } else {
            s.a[account].lastSop = s.r.start;
            s.a[account].lastRain = 0;
            s.a[account].lastSIs = s.season.sis;
        }
        if (grownStalk > 0) LibSilo.incrementBalanceOfStalk(account, grownStalk);
        s.a[account].lastUpdate = season();
    }

    function migrateBip0(address account) private returns (uint32) {
        uint32 update = s.bip0Start;

        s.a[account].lastUpdate = update;
        s.a[account].roots = balanceOfMigrationRoots(account);

        delete s.a[account].sop;
        delete s.a[account].lastSop;
        delete s.a[account].lastRain;

        return update;
    }

    function farmBeans(address account, uint32 update) private {
        if (s.a[account].lastSIs < s.season.sis) {
            farmLegacyBeans(account, update);
        }

        uint256 accountStalk = s.a[account].s.stalk;
        uint256 beans = balanceOfFarmableBeansV3(account, accountStalk);
        if (beans > 0) {
            s.si.beans = s.si.beans.sub(beans);
            uint256 seeds = beans.mul(C.getSeedsPerBean());
            Account.State storage a = s.a[account];
            s.a[account].s.seeds = a.s.seeds.add(seeds);
            s.a[account].s.stalk = accountStalk.add(beans.mul(C.getStalkPerBean()));
            LibBeanSilo.addBeanDeposit(account, season(), beans);
        }
    }

    function farmLegacyBeans(address account, uint32 update) private {
        uint256 beans;
        if (update < s.hotFix3Start) {
            beans = balanceOfFarmableBeansV1(account);
            if (beans > 0) s.v1SI.beans = s.v1SI.beans.sub(beans);
        }

        uint256 unclaimedRoots = balanceOfUnclaimedRoots(account);
        uint256 beansV2 = balanceOfFarmableBeansV2(unclaimedRoots);
        beans = beans.add(beansV2);
        if (beansV2 > 0) s.v2SIBeans = s.v2SIBeans.sub(beansV2);
        s.unclaimedRoots = unclaimedRoots < s.unclaimedRoots ? s.unclaimedRoots - unclaimedRoots : 0;
        s.a[account].lastSIs = s.season.sis;

        uint256 seeds = beans.mul(C.getSeedsPerBean());
        s.a[account].s.seeds = s.a[account].s.seeds.add(seeds);
        s.a[account].s.stalk = s.a[account].s.stalk.add(beans.mul(C.getStalkPerBean()));
        LibBeanSilo.addBeanDeposit(account, season(), beans);
    }

    function farmSops(address account, uint32 update) internal {
        if (s.sop.last > update || s.sops[s.a[account].lastRain] > 0) {
            s.a[account].sop.base = balanceOfPlentyBase(account);
            s.a[account].lastSop = s.sop.last;
        }
        if (s.r.raining) {
            if (s.r.start > update) {
                s.a[account].lastRain = s.r.start;
                s.a[account].sop.roots = s.a[account].roots;
            }
            if (s.sop.last == s.r.start) s.a[account].sop.basePerRoot = s.sops[s.sop.last];
        } else if (s.a[account].lastRain > 0) {
            s.a[account].lastRain = 0;
        }
    }

    // Variation of Oepn Zeppelins reentrant guard.
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts%2Fsecurity%2FReentrancyGuard.sol
    modifier siloNonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        updateSilo(msg.sender);
        _;
        _status = _NOT_ENTERED;
    }

    modifier silo() {
        updateSilo(msg.sender);
        _;
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import "../../interfaces/pancake/IPancakePair.sol";
import "../LibAppStorage.sol";

/**
 * @author Publius
 * @title Lib LP Silo
 **/
library LibLPSilo {
    using SafeMath for uint256;

    uint256 private constant TWO_TO_THE_112 = 2**112;

    event LPDeposit(address indexed account, uint256 season, uint256 lp, uint256 seeds);

    function incrementDepositedLP(uint256 amount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.lp.deposited = s.lp.deposited.add(amount);
    }

    function decrementDepositedLP(uint256 amount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.lp.deposited = s.lp.deposited.sub(amount);
    }

    function addLPDeposit(
        address account,
        uint32 _s,
        uint256 amount,
        uint256 seeds
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.a[account].lp.deposits[_s] += amount;
        s.a[account].lp.depositSeeds[_s] += seeds;
        emit LPDeposit(msg.sender, _s, amount, seeds);
    }

    function removeLPDeposit(
        address account,
        uint32 id,
        uint256 amount
    ) internal returns (uint256, uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(id <= s.season.current, "Silo: Future crate.");
        (uint256 crateAmount, uint256 crateBase) = lpDeposit(account, id);
        require(crateAmount >= amount, "Silo: Crate balance too low.");
        require(crateAmount > 0, "Silo: Crate empty.");
        if (amount < crateAmount) {
            uint256 base = amount.mul(crateBase).div(crateAmount);
            s.a[account].lp.deposits[id] -= amount;
            s.a[account].lp.depositSeeds[id] -= base;
            return (amount, base);
        } else {
            delete s.a[account].lp.deposits[id];
            delete s.a[account].lp.depositSeeds[id];
            return (crateAmount, crateBase);
        }
    }

    function lpDeposit(address account, uint32 id) private view returns (uint256, uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return (s.a[account].lp.deposits[id], s.a[account].lp.depositSeeds[id]);
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import "./LibAppStorage.sol";
import "./PancakeOracleLibrary.sol";

/**
 * @author Publius
 * @title Lib Popcorn BNB V2 Silo
 **/
library LibBeanBnb {
    using SafeMath for uint256;

    uint256 private constant TWO_TO_THE_112 = 2**112;

    function lpToLPBeans(uint256 amount) internal view returns (uint256 beans) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        (uint112 reserve0, uint112 reserve1, uint32 lastTimestamp) = IPancakePair(s.c.pair).getReserves();

        uint256 beanReserve;

        // Check the last timestamp in the Pancake Pair to see if anyone has interacted with the pair this block.
        // If so, use current Season TWAP to calculate Popcorn Reserves for flash loan protection
        // If not, we can use the current reserves with the assurance that there is no active flash loan
        if (lastTimestamp == uint32(block.timestamp % 2**32)) beanReserve = twapBeanReserve(reserve0, reserve1, lastTimestamp);
        else beanReserve = s.index == 0 ? reserve0 : reserve1;
        beans = amount.mul(beanReserve).mul(2).div(IPancakePair(s.c.pair).totalSupply());
    }

    function twapBeanReserve(
        uint112 reserve0,
        uint112 reserve1,
        uint32 lastTimestamp
    ) internal view returns (uint256 beans) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = PancakeOracleLibrary.currentCumulativePricesWithReserves(s.c.pair, reserve0, reserve1, lastTimestamp);
        uint256 priceCumulative = s.index == 0 ? price0Cumulative : price1Cumulative;
        uint32 deltaTimestamp = uint32(blockTimestamp - s.o.timestamp);
        require(deltaTimestamp > 0, "Silo: Oracle same Season");
        uint256 price = (priceCumulative - s.o.cumulative) / deltaTimestamp;
        price = price.div(TWO_TO_THE_112);
        beans = sqrt(uint256(reserve0).mul(uint256(reserve1)).div(price));
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../../interfaces/pancake/IPancakePair.sol";
import "../../../interfaces/IWETH.sol";
import "../../../interfaces/IBean.sol";
import "../../../libraries/LibCheck.sol";
import "../../../libraries/LibInternal.sol";
import "../../../libraries/LibMarket.sol";
import "../../../libraries/Silo/LibSilo.sol";
import "../../../C.sol";

/**
 * @author Publius
 * @title Silo Exit
 **/
contract SiloExit {
    AppStorage internal s;

    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    /**
     * Contracts
     **/

    function weth() public view returns (IWETH) {
        return IWETH(s.c.weth);
    }

    /**
     * Silo
     **/

    function totalStalk() public view returns (uint256) {
        return s.s.stalk;
    }

    function totalRoots() public view returns (uint256) {
        return s.s.roots;
    }

    function totalSeeds() public view returns (uint256) {
        return s.s.seeds;
    }

    function totalFarmableBeans() public view returns (uint256) {
        return s.si.beans.add(s.v1SI.beans).add(s.v2SIBeans);
    }

    function balanceOfSeeds(address account) public view returns (uint256) {
        return s.a[account].s.seeds.add(balanceOfFarmableBeans(account).mul(C.getSeedsPerBean()));
    }

    function balanceOfStalk(address account) public view returns (uint256) {
        return s.a[account].s.stalk.add(balanceOfFarmableStalk(account));
    }

    function balanceOfRoots(address account) public view returns (uint256) {
        return s.a[account].roots;
    }

    function balanceOfGrownStalk(address account) public view returns (uint256) {
        return LibSilo.stalkReward(s.a[account].s.seeds, season() - lastUpdate(account));
    }

    function balanceOfFarmableBeans(address account) public view returns (uint256 beans) {
        beans = beans.add(balanceOfFarmableBeansV1(account));
        beans = beans.add(balanceOfFarmableBeansV2(balanceOfUnclaimedRoots(account)));
        uint256 stalk = s.a[account].s.stalk.add(beans.mul(C.getStalkPerBean()));
        beans = beans.add(balanceOfFarmableBeansV3(account, stalk));
    }

    function balanceOfFarmableBeansV3(address account, uint256 accountStalk) public view returns (uint256 beans) {
        if (s.s.roots == 0) return 0;
        uint256 stalk = s.s.stalk.mul(balanceOfRoots(account)).div(s.s.roots);
        if (stalk <= accountStalk) return 0;
        beans = (stalk - accountStalk).div(C.getStalkPerBean()); // Note: SafeMath is redundant here.
        if (beans > s.si.beans) return s.si.beans;
        return beans;
    }

    function balanceOfFarmableBeansV2(uint256 roots) public view returns (uint256 beans) {
        if (s.unclaimedRoots == 0 || s.v2SIBeans == 0) return 0;
        beans = roots.mul(s.v2SIBeans).div(s.unclaimedRoots);
        if (beans > s.v2SIBeans) beans = s.v2SIBeans;
    }

    function balanceOfFarmableBeansV1(address account) public view returns (uint256 beans) {
        if (s.s.roots == 0 || s.v1SI.beans == 0 || lastUpdate(account) >= s.hotFix3Start) return 0;
        uint256 stalk = s.v1SI.stalk.mul(balanceOfRoots(account)).div(s.v1SI.roots);
        if (stalk <= s.a[account].s.stalk) return 0;
        beans = (stalk - s.a[account].s.stalk).div(C.getStalkPerBean()); // Note: SafeMath is redundant here.
        if (beans > s.v1SI.beans) return s.v1SI.beans;
        return beans;
    }

    function balanceOfUnclaimedRoots(address account) public view returns (uint256 uRoots) {
        uint256 sis = s.season.sis.sub(s.a[account].lastSIs);
        uRoots = balanceOfRoots(account).mul(sis);
        if (uRoots > s.unclaimedRoots) uRoots = s.unclaimedRoots;
    }

    function balanceOfFarmableStalk(address account) public view returns (uint256) {
        return balanceOfFarmableBeans(account).mul(C.getStalkPerBean());
    }

    function balanceOfFarmableSeeds(address account) public view returns (uint256) {
        return balanceOfFarmableBeans(account).mul(C.getSeedsPerBean());
    }

    function lastUpdate(address account) public view returns (uint32) {
        return s.a[account].lastUpdate;
    }

    function lastSupplyIncreases(address account) public view returns (uint32) {
        return s.a[account].lastSIs;
    }

    function supplyIncreases() external view returns (uint32) {
        return s.season.sis;
    }

    function unclaimedRoots() external view returns (uint256) {
        return s.unclaimedRoots;
    }

    function legacySupplyIncrease() external view returns (Storage.V1IncreaseSilo memory) {
        return s.v1SI;
    }

    /**
     * Season Of Plenty
     **/

    function lastSeasonOfPlenty() public view returns (uint32) {
        return s.sop.last;
    }

    function seasonsOfPlenty() public view returns (Storage.SeasonOfPlenty memory) {
        return s.sop;
    }

    function balanceOfEth(address account) public view returns (uint256) {
        if (s.sop.base == 0) return 0;
        return balanceOfPlentyBase(account).mul(s.sop.weth).div(s.sop.base);
    }

    function balanceOfPlentyBase(address account) public view returns (uint256) {
        uint256 plenty = s.a[account].sop.base;
        uint32 endSeason = s.a[account].lastSop;
        uint256 plentyPerRoot;
        uint256 rainSeasonBase = s.sops[s.a[account].lastRain];
        if (rainSeasonBase > 0) {
            if (endSeason == s.a[account].lastRain) {
                plentyPerRoot = rainSeasonBase.sub(s.a[account].sop.basePerRoot);
            } else {
                plentyPerRoot = rainSeasonBase.sub(s.sops[endSeason]);
                endSeason = s.a[account].lastRain;
            }
            if (plentyPerRoot > 0) plenty = plenty.add(plentyPerRoot.mul(s.a[account].sop.roots));
        }

        if (s.sop.last > lastUpdate(account)) {
            plentyPerRoot = s.sops[s.sop.last].sub(s.sops[endSeason]);
            plenty = plenty.add(plentyPerRoot.mul(balanceOfRoots(account)));
        }
        return plenty;
    }

    function balanceOfRainRoots(address account) public view returns (uint256) {
        return s.a[account].sop.roots;
    }

    /**
     * Governance
     **/

    function votedUntil(address account) public view returns (uint32) {
        if (voted(account)) {
            return s.a[account].votedUntil;
        }
        return 0;
    }

    function proposedUntil(address account) public view returns (uint32) {
        return s.a[account].proposedUntil;
    }

    function voted(address account) public view returns (bool) {
        if (s.a[account].votedUntil >= season()) {
            uint256 numberOfActiveBips = s.g.activeBips.length;
            for (uint256 i; i < numberOfActiveBips; i++) {
                uint32 activeBip = s.g.activeBips[i];
                if (s.g.voted[activeBip][account]) return true;
            }
        }
        return false;
    }

    /**
     * Migration
     **/

    function balanceOfMigrationRoots(address account) internal view returns (uint256) {
        return balanceOfMigrationStalk(account).mul(C.getRootsBase());
    }

    function balanceOfMigrationStalk(address account) private view returns (uint256) {
        return s.a[account].s.stalk.add(LibSilo.stalkReward(s.a[account].s.seeds, s.bip0Start - lastUpdate(account)));
    }

    /**
     * Internal
     **/

    function season() internal view returns (uint32) {
        return s.season.current;
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/pancake/IPancakePair.sol";
import "./LibAppStorage.sol";
import "./LibSafeMath32.sol";
import "../interfaces/IBean.sol";

/**
 * @author Publius
 * @title Check Library verifies Farmer's balances are correct.
 **/
library LibCheck {
    using SafeMath for uint256;

    function beanBalanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(IBean(s.c.bean).balanceOf(address(this)) >= s.f.harvestable.sub(s.f.harvested).add(s.bean.deposited).add(s.bean.withdrawn), "Check: Popcorn balance fail.");
    }

    function lpBalanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(IPancakePair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited.add(s.lp.withdrawn), "Check: LP balance fail.");
    }

    function balanceCheck() internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(IBean(s.c.bean).balanceOf(address(this)) >= s.f.harvestable.sub(s.f.harvested).add(s.bean.deposited).add(s.bean.withdrawn), "Check: Popcorn balance fail.");
        require(IPancakePair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited.add(s.lp.withdrawn), "Check: LP balance fail.");
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

/**
 * @author Publius
 * @title Internal Library handles gas efficient function calls between facets.
 **/

interface ISiloUpdate {
    function updateSilo(address account) external payable;
}

library LibInternal {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function updateSilo(address account) internal {
        DiamondStorage storage ds = diamondStorage();
        address facet = ds.selectorToFacetAndPosition[ISiloUpdate.updateSilo.selector].facetAddress;
        bytes memory myFunctionCall = abi.encodeWithSelector(ISiloUpdate.updateSilo.selector, account);
        (bool success, ) = address(facet).delegatecall(myFunctionCall);
        require(success, "Silo: updateSilo failed.");
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import "../../C.sol";
import "../LibAppStorage.sol";

/**
 * @author Publius
 * @title Lib Silo
 **/
library LibSilo {
    using SafeMath for uint256;
    using Decimal for Decimal.D256;

    event BeanDeposit(address indexed account, uint256 season, uint256 beans);

    /**
     * Silo
     **/

    function depositSiloAssets(
        address account,
        uint256 seeds,
        uint256 stalk
    ) internal {
        incrementBalanceOfStalk(account, stalk);
        incrementBalanceOfSeeds(account, seeds);
    }

    function withdrawSiloAssets(
        address account,
        uint256 seeds,
        uint256 stalk
    ) internal {
        decrementBalanceOfStalk(account, stalk);
        decrementBalanceOfSeeds(account, seeds);
    }

    function incrementBalanceOfSeeds(address account, uint256 seeds) private {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.s.seeds = s.s.seeds.add(seeds);
        s.a[account].s.seeds = s.a[account].s.seeds.add(seeds);
    }

    function incrementBalanceOfStalk(address account, uint256 stalk) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 roots;
        if (s.s.roots == 0) roots = stalk.mul(C.getRootsBase());
        else roots = s.s.roots.mul(stalk).div(s.s.stalk);

        s.s.stalk = s.s.stalk.add(stalk);
        s.a[account].s.stalk = s.a[account].s.stalk.add(stalk);

        s.s.roots = s.s.roots.add(roots);
        s.a[account].roots = s.a[account].roots.add(roots);

        incrementBipRoots(account, roots);
    }

    function decrementBalanceOfSeeds(address account, uint256 seeds) private {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.s.seeds = s.s.seeds.sub(seeds);
        s.a[account].s.seeds = s.a[account].s.seeds.sub(seeds);
    }

    function decrementBalanceOfStalk(address account, uint256 stalk) private {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (stalk == 0) return;
        uint256 roots = s.a[account].roots.mul(stalk).sub(1).div(s.a[account].s.stalk).add(1);

        s.s.stalk = s.s.stalk.sub(stalk);
        s.a[account].s.stalk = s.a[account].s.stalk.sub(stalk);

        s.s.roots = s.s.roots.sub(roots);
        s.a[account].roots = s.a[account].roots.sub(roots);

        decrementBipRoots(account, roots);
    }

    function updateBalanceOfRainStalk(address account) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (!s.r.raining) return;
        if (s.a[account].roots < s.a[account].sop.roots) {
            s.r.roots = s.r.roots.sub(s.a[account].sop.roots - s.a[account].roots); // Note: SafeMath is redundant here.
            s.a[account].sop.roots = s.a[account].roots;
        }
    }

    function incrementBipRoots(address account, uint256 roots) private {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.a[account].votedUntil >= season()) {
            uint256 numberOfActiveBips = s.g.activeBips.length;
            for (uint256 i; i < numberOfActiveBips; i++) {
                uint32 bip = s.g.activeBips[i];
                if (s.g.voted[bip][account]) s.g.bips[bip].roots = s.g.bips[bip].roots.add(roots);
            }
        }
    }

    /// @notice Decrements the given amount of roots from bips that have been voted on by a given account and
    /// checks whether the account is a proposer and if he/she are then they need to have the min roots required
    /// @param account The address of the account to have their bip roots decremented
    /// @param roots The amount of roots for the given account to be decremented from
    function decrementBipRoots(address account, uint256 roots) private {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.a[account].votedUntil >= season()) {
            require(s.a[account].proposedUntil < season() || canPropose(account), "Silo: Proposer must have min Stalk.");
            uint256 numberOfActiveBips = s.g.activeBips.length;
            for (uint256 i; i < numberOfActiveBips; i++) {
                uint32 bip = s.g.activeBips[i];
                if (s.g.voted[bip][account]) s.g.bips[bip].roots = s.g.bips[bip].roots.sub(roots);
            }
        }
    }

    /// @notice Checks whether the account have the min roots required for a BIP
    /// @param account The address of the account to check roots balance
    function canPropose(address account) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Decimal.D256 memory stake = Decimal.ratio(s.a[account].roots, s.s.roots);
        return stake.greaterThan(C.getGovernanceProposalThreshold());
    }

    function stalkReward(uint256 seeds, uint32 seasons) internal pure returns (uint256) {
        return seeds.mul(seasons);
    }

    function season() internal view returns (uint32) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.season.current;
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import "../LibAppStorage.sol";

/**
 * @author Publius
 * @title Lib Popcorn Silo
 **/
library LibBeanSilo {
    using SafeMath for uint256;

    event BeanDeposit(address indexed account, uint256 season, uint256 beans);

    function addBeanDeposit(
        address account,
        uint32 _s,
        uint256 amount
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.a[account].bean.deposits[_s] += amount;
        emit BeanDeposit(account, _s, amount);
    }

    function removeBeanDeposit(
        address account,
        uint32 id,
        uint256 amount
    ) internal returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(id <= s.season.current, "Silo: Future crate.");
        uint256 crateAmount = s.a[account].bean.deposits[id];
        require(crateAmount >= amount, "Silo: Crate balance too low.");
        require(crateAmount > 0, "Silo: Crate empty.");
        s.a[account].bean.deposits[id] -= amount;
        return amount;
    }

    function incrementDepositedBeans(uint256 amount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.bean.deposited = s.bean.deposited.add(amount);
    }

    function decrementDepositedBeans(uint256 amount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.bean.deposited = s.bean.deposited.sub(amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

pragma solidity >=0.5.16;

/**
 * @author Stanislav
 * @title Pancake Pair Interface
 **/
interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title WETH Interface
 **/
interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title Popcorn Interface
 **/
abstract contract IBean is IERC20 {
    function burn(uint256 amount) public virtual;

    function burnFrom(address account, uint256 amount) public virtual;

    function mint(address account, uint256 amount) public virtual returns (bool);
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "./interfaces/pancake/IPancakePair.sol";
import "./interfaces/IBean.sol";
import "./libraries/Decimal.sol";

/**
 * @author Publius
 * @title C holds the contracts for Farmer.
 **/
library C {
    using Decimal for Decimal.D256;
    using SafeMath for uint256;

    // Constants
    uint256 private constant PERCENT_BASE = 1e18; // BSC

    // Chain
    uint256 private constant CHAIN_ID = 56; // BSC

    // Season
    uint256 private constant CURRENT_SEASON_PERIOD = 3600; // 1 hour
    uint256 private constant REWARD_MULTIPLIER = 1;
    uint256 private constant MAX_TIME_MULTIPLIER = 300; // seconds

    // Sun
    uint256 private constant HARVESET_PERCENTAGE = 0.5e18; // 50%

    // Weather
    uint256 private constant POD_RATE_LOWER_BOUND = 0.05e18; // 5%
    uint256 private constant OPTIMAL_POD_RATE = 0.15e18; // 15%
    uint256 private constant POD_RATE_UPPER_BOUND = 0.25e18; // 25%

    uint256 private constant DELTA_POD_DEMAND_LOWER_BOUND = 0.95e18; // 95%
    uint256 private constant DELTA_POD_DEMAND_UPPER_BOUND = 1.05e18; // 105%

    uint32 private constant STEADY_SOW_TIME = 60; // 1 minute
    uint256 private constant RAIN_TIME = 24; // 24 seasons = 1 day

    // Governance
    uint32 private constant GOVERNANCE_PERIOD = 168; // 168 seasons = 7 days
    uint32 private constant GOVERNANCE_EMERGENCY_PERIOD = 86400; // 1 day
    uint256 private constant GOVERNANCE_PASS_THRESHOLD = 5e17; // 1/2
    uint256 private constant GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR = 2; // 2/3
    uint256 private constant GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR = 3; // 2/3
    uint32 private constant GOVERNANCE_EXPIRATION = 24; // 24 seasons = 1 day
    uint256 private constant GOVERNANCE_PROPOSAL_THRESHOLD = 0.001e18; // 0.1%
    uint256 private constant BASE_COMMIT_INCENTIVE = 100e6; // 100 beans
    uint256 private constant MAX_PROPOSITIONS = 5;

    // Silo
    uint256 private constant BASE_ADVANCE_INCENTIVE = 100e6; // 100 beans
    uint32 private constant WITHDRAW_TIME = 25; // 24 + 1 seasons
    uint256 private constant SEEDS_PER_BEAN = 2;
    uint256 private constant SEEDS_PER_LP_BEAN = 4;
    uint256 private constant STALK_PER_BEAN = 10000;
    uint256 private constant ROOTS_BASE = 1e12;

    // Field
    uint256 private constant MAX_SOIL_DENOMINATOR = 4; // 25%
    uint256 private constant COMPLEX_WEATHER_DENOMINATOR = 1000; // 0.1%

    // Bsc contracts
    address private constant FACTORY = address(0x6725F303b657a9451d8BA641348b6761A6CC7a17);
    address private constant ROUTER = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    address private constant PEG_PAIR = address(0x575Cb459b6E6B8187d3Ef9a25105D64011874820);

    /**
     * Getters
     **/

    function getSeasonPeriod() internal pure returns (uint256) {
        return CURRENT_SEASON_PERIOD;
    }

    function getGovernancePeriod() internal pure returns (uint32) {
        return GOVERNANCE_PERIOD;
    }

    function getGovernanceEmergencyPeriod() internal pure returns (uint32) {
        return GOVERNANCE_EMERGENCY_PERIOD;
    }

    function getGovernanceExpiration() internal pure returns (uint32) {
        return GOVERNANCE_EXPIRATION;
    }

    function getGovernancePassThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: GOVERNANCE_PASS_THRESHOLD});
    }

    function getGovernanceEmergencyThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR, GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR);
    }

    function getGovernanceProposalThreshold() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: GOVERNANCE_PROPOSAL_THRESHOLD});
    }

    function getAdvanceIncentive() internal pure returns (uint256) {
        return BASE_ADVANCE_INCENTIVE;
    }

    function getCommitIncentive() internal pure returns (uint256) {
        return BASE_COMMIT_INCENTIVE;
    }

    function getSiloWithdrawSeasons() internal pure returns (uint32) {
        return WITHDRAW_TIME;
    }

    function getComplexWeatherDenominator() internal pure returns (uint256) {
        return COMPLEX_WEATHER_DENOMINATOR;
    }

    function getMaxSoilDenominator() internal pure returns (uint256) {
        return MAX_SOIL_DENOMINATOR;
    }

    function getHarvestPercentage() internal pure returns (uint256) {
        return HARVESET_PERCENTAGE;
    }

    function getChainId() internal pure returns (uint256) {
        return CHAIN_ID;
    }

    function getOptimalPodRate() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(OPTIMAL_POD_RATE, PERCENT_BASE);
    }

    function getUpperBoundPodRate() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(POD_RATE_UPPER_BOUND, PERCENT_BASE);
    }

    function getLowerBoundPodRate() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(POD_RATE_LOWER_BOUND, PERCENT_BASE);
    }

    function getUpperBoundDPD() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(DELTA_POD_DEMAND_UPPER_BOUND, PERCENT_BASE);
    }

    function getLowerBoundDPD() internal pure returns (Decimal.D256 memory) {
        return Decimal.ratio(DELTA_POD_DEMAND_LOWER_BOUND, PERCENT_BASE);
    }

    function getSteadySowTime() internal pure returns (uint32) {
        return STEADY_SOW_TIME;
    }

    function getRainTime() internal pure returns (uint256) {
        return RAIN_TIME;
    }

    function getMaxPropositions() internal pure returns (uint256) {
        return MAX_PROPOSITIONS;
    }

    function getSeedsPerBean() internal pure returns (uint256) {
        return SEEDS_PER_BEAN;
    }

    function getSeedsPerLPBean() internal pure returns (uint256) {
        return SEEDS_PER_LP_BEAN;
    }

    function getStalkPerBean() internal pure returns (uint256) {
        return STALK_PER_BEAN;
    }

    function getStalkPerLPSeed() internal pure returns (uint256) {
        return STALK_PER_BEAN / SEEDS_PER_LP_BEAN;
    }

    function getRootsBase() internal pure returns (uint256) {
        return ROOTS_BASE;
    }

    function getFactory() internal pure returns (address) {
        return FACTORY;
    }

    function getRouter() internal pure returns (address) {
        return ROUTER;
    }

    function getPegPair() internal pure returns (address) {
        return PEG_PAIR;
    }

    function getRewardMultiplier() internal pure returns (uint256) {
        return REWARD_MULTIPLIER;
    }

    function getMaxTimeMultiplier() internal pure returns (uint256) {
        return MAX_TIME_MULTIPLIER;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "../farm/AppStorage.sol";

/**
 * @author Publius
 * @title App Storage Library allows libaries to access Farmer's state.
 **/
library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @author Publius
 * @title LibSafeMath32 is a uint32 variation of Open Zeppelin's Safe Math library.
 **/
library LibSafeMath32 {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        uint32 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint32 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint32 a, uint32 b) internal pure returns (bool, uint32) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) return 0;
        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint32 a,
        uint32 b,
        string memory errorMessage
    ) internal pure returns (uint32) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "../interfaces/IDiamondCut.sol";

/**
 * @author Publius
 * @title App Storage defines the state object for Farmer.
 **/
contract Account {
    // Field stores a Farmer's Plots and Pod allowances.
    struct Field {
        mapping(uint256 => uint256) plots; // A Farmer's Plots. Maps from Plot index to Pod amount.
        mapping(address => uint256) podAllowances; // An allowance mapping for Pods similar to that of the ERC-20 standard. Maps from spender address to allowance amount.
    }

    // Asset Silo is a struct that stores Deposits and Seeds per Deposit, and formerly stored Withdrawals.
    // Asset Silo currently stores Unripe Bean and Unripe LP Deposits.
    struct AssetSilo {
        mapping(uint32 => uint256) withdrawals;
        mapping(uint32 => uint256) deposits;
        mapping(uint32 => uint256) depositSeeds;
    }

    // Deposit represents a Deposit in the Silo of a given Token at a given Season.
    // Stored as two uint128 state variables to save gas.
    struct Deposit {
        uint128 amount;
        uint128 bdv;
    }

    // Silo stores Silo-related balances
    struct Silo {
        uint256 stalk; // Balance of the Farmer's normal Stalk.
        uint256 seeds; // Balance of the Farmer's normal Seeds.
    }

    // Season Of Plenty stores Season of Plenty (SOP) related balances
    struct SeasonOfPlenty {
        uint256 base;
        uint256 roots; // The number of Roots a Farmer had when it started Raining.
        uint256 basePerRoot;
    }

    // The Account level State stores all of the Farmer's balances in the contract.
    struct State {
        Field field; // A Farmer's Field storage.
        AssetSilo bean;
        AssetSilo lp;
        Silo s; // A Farmer's Silo storage.
        uint32 votedUntil;
        uint32 lastUpdate; // The Season in which the Farmer last updated their Silo.
        uint32 lastSop; // The last Season that a SOP occured at the time the Farmer last updated their Silo.
        uint32 lastRain; // The last Season that it started Raining at the time the Farmer last updated their Silo.
        uint32 lastSIs;
        uint32 proposedUntil;
        SeasonOfPlenty sop; // A Farmer's Season Of Plenty storage.
        uint256 roots; // A Farmer's Root balance.
        uint256 wrappedBeans;
        mapping(address => mapping(uint32 => Deposit)) deposits;  // A Farmer's Silo Deposits stored as a map from Token address to Season of Deposit to Deposit.
        mapping(address => mapping(uint32 => uint256)) withdrawals;  // A Farmer's Withdrawals from the Silo stored as a map from Token address to Season the Withdrawal becomes Claimable to Withdrawn amount of Tokens.
    }
}

contract Storage {
    // Contracts stored the contract addresses of various important contracts to Beanstalk.
    struct Contracts {
        address bean;
        address pair;
        address pegPair;
        address weth;
    }

    // Field stores global Field balances.
    struct Field {
        uint256 soil; // The number of Soil currently available.
        uint256 pods; // The pod index; the total number of Pods ever minted.
        uint256 harvested; // The harvested index; the total number of Pods that have ever been Harvested.
        uint256 harvestable; // The harvestable index; the total number of Pods that have ever been Harvestable. Included previously Harvested Beans.
    }

    // Governance
    struct Bip {
        address proposer;
        uint32 start;
        uint32 period;
        bool executed;
        int256 pauseOrUnpause;
        uint128 timestamp;
        uint256 roots;
        uint256 endTotalRoots;
    }

    struct DiamondCut {
        IDiamondCut.FacetCut[] diamondCut;
        address initAddress;
        bytes initData;
    }

    struct Governance {
        uint32[] activeBips;
        uint32 bipIndex;
        mapping(uint32 => DiamondCut) diamondCuts;
        mapping(uint32 => mapping(address => bool)) voted;
        mapping(uint32 => Bip) bips;
    }

    // Silo
    struct AssetSilo {
        uint256 deposited; // The total number of a given Token currently Deposited in the Silo.
        uint256 withdrawn; // The total number of a given Token currently Withdrawn From the Silo but not Claimed.
    }

    struct IncreaseSilo {
        uint256 beans;
    }

    struct V1IncreaseSilo {
        uint256 beans;
        uint256 stalk;
        uint256 roots;
    }

    struct SeasonOfPlenty {
        uint256 weth;
        uint256 base;
        uint32 last;
    }

    struct Silo {
        uint256 stalk;
        uint256 seeds;
        uint256 roots;
    }

    // Oracle stores global level Oracle balances.
    // Currently the oracle refers to the time weighted average price calculated from the Bean:weth - usdc:weth.
    struct Oracle {
        bool initialized;  // True if the Oracle has been initialzed. It needs to be initialized on Deployment and re-initialized each Unpause.
        uint256 cumulative;
        uint256 pegCumulative;
        uint32 timestamp;  // The timestamp of the start of the current Season.
        uint32 pegTimestamp;
    }

    // Rain stores global level Rain balances. (Rain is when P > 1, Pod rate Excessively Low).
    struct Rain {
        uint32 start;
        bool raining;
        uint256 pods; // The number of Pods when it last started Raining.
        uint256 roots; // The number of Roots when it last started Raining.
    }

    // Sesaon stores global level Season balances.
    struct Season {
        // The first storage slot in Season is filled with a variety of somewhat unrelated storage variables.
        // Given that they are all smaller numbers, they are stored together for gas efficient read/write operations. 
        // Apologies if this makes it confusing :(
        uint32 current; // The current Season in Beanstalk.
        uint32 sis;
        uint8 withdrawSeasons; // The number of seasons required to Withdraw a Deposit.
        uint256 start; // The timestamp of the Beanstalk deployment rounded down to the nearest hour.
        uint256 period; // The length of each season in Beanstalk.
        uint256 timestamp; // The timestamp of the start of the current Season.
        uint256 rewardMultiplier;
        uint256 maxTimeMultiplier;
        uint256 costSunrice;
    }

    // Weather stores global level Weather balances.
    struct Weather {
        uint256 startSoil; // The number of Soil at the start of the current Season.
        uint256 lastDSoil; // Delta Soil; the number of Soil purchased last Season.
        uint32 lastSowTime; // The number of seconds it took for all but at most 1 Soil to sell out last Season.
        uint32 nextSowTime; // The number of seconds it took for all but at most 1 Soil to sell out this Season
        uint32 yield; // Weather; the interest rate for sowing Beans in Soil.
    }

    // Fundraiser stores Fundraiser data for a given Fundraiser.
    struct Fundraiser {
        address payee; // The address to be paid after the Fundraiser has been fully funded.
        address token; // The token address that used to raise funds for the Fundraiser.
        uint256 total; // The total number of Tokens that need to be raised to complete the Fundraiser.
        uint256 remaining; // The remaining number of Tokens that need to to complete the Fundraiser.
        uint256 start; // The timestamp at which the Fundraiser started (Fundraisers cannot be started and funded in the same block).
    }

    // SiloSettings stores the settings for each Token that has been Whitelisted into the Silo.
    // A Token is considered whitelisted in the Silo if there exists a non-zero SiloSettings selector.
    struct SiloSettings {
        bytes4 selector; // The encoded BDV function selector for the Token.
        uint32 seeds; // The Seeds Per BDV that the Silo mints in exchange for Depositing this Token.
        uint32 stalk; // The Stalk Per BDV that the Silo mints in exchange for Depositing this Token.
    }
}

struct AppStorage {
    uint8 index; // The index of the Bean token in the Bean:Eth Uniswap v2 pool
    int8[32] cases; // The 24 Weather cases (array has 32 items, but caseId = 3 (mod 4) are not cases).
    bool paused; // True if Beanstalk is Paused.
    uint128 pausedAt; // The timestamp at which Beanstalk was last paused. 
    Storage.Season season; // The Season storage struct found above.
    Storage.Contracts c;
    Storage.Field f; // The Field storage struct found above.
    Storage.Governance g; // The Governance storage struct found above.
    Storage.Oracle o; // The Oracle storage struct found above.
    Storage.Rain r; // The Rain storage struct found above.
    Storage.Silo s; // The Silo storage struct found above.
    uint256 reentrantStatus; // An intra-transaction state variable to protect against reentrance
    Storage.Weather w; // The Weather storage struct found above.
    Storage.AssetSilo bean;
    Storage.AssetSilo lp;
    Storage.IncreaseSilo si;
    Storage.SeasonOfPlenty sop;
    Storage.V1IncreaseSilo v1SI;
    uint256 unclaimedRoots;
    uint256 v2SIBeans;
    mapping(uint32 => uint256) sops; // A mapping from Season to Plenty Per Root (PPR) in that Season. Plenty Per Root is 0 if a Season of Plenty did not occur.
    mapping(address => Account.State) a; // A mapping from Farmer address to Account state.
    uint32 bip0Start;
    uint32 hotFix3Start;
    mapping(uint32 => Storage.Fundraiser) fundraisers; // A mapping from Fundraiser Id to Fundraiser storage.
    uint32 fundraiserIndex; // The number of Fundraisers that have occured.
    mapping(uint256 => bytes32) podListings; // A mapping from Plot Index to the hash of the Pod Listing.
    mapping(bytes32 => uint256) podOrders; // A mapping from the hash of a Pod Order to the amount of Pods that the Pod Order is still willing to buy.
    mapping(address => Storage.AssetSilo) siloBalances; // A mapping from Token address to Silo Balance storage (amount deposited and withdrawn).
    mapping(address => Storage.SiloSettings) ss;  // A mapping from Token address to Silo Settings for each Whitelisted Token. If a non-zero storage exists, a Token is whitelisted.
    // These refund variables are intra-transaction state varables use to store refund amounts
    uint256 refundStatus;
    uint256 beanRefundAmount;
    uint256 ethRefundAmount;
}

// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity =0.7.6;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

pragma solidity >=0.6.2;

import { IPancakeRouter01 } from "./IPancakeRouter01.sol";

/**
 * @author Stanislav
 * @title Pancake Router02 Interface
 **/
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

/**
 * @author Stanislav
 * @title Pancake Router01 Interface
 **/
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title Decimal
 * @author dYdX
 *
 * Library that defines a fixed-point number with 18 decimal places.
 */
library Decimal {
    using SafeMath for uint256;

    // ============ Constants ============

    uint256 constant BASE = 10**18;

    // ============ Structs ============

    struct D256 {
        uint256 value;
    }

    // ============ Static Functions ============

    function zero() internal pure returns (D256 memory) {
        return D256({value: 0});
    }

    function one() internal pure returns (D256 memory) {
        return D256({value: BASE});
    }

    function from(uint256 a) internal pure returns (D256 memory) {
        return D256({value: a.mul(BASE)});
    }

    function ratio(uint256 a, uint256 b) internal pure returns (D256 memory) {
        return D256({value: getPartial(a, BASE, b)});
    }

    // ============ Self Functions ============

    function add(D256 memory self, uint256 b) internal pure returns (D256 memory) {
        return D256({value: self.value.add(b.mul(BASE))});
    }

    function sub(D256 memory self, uint256 b) internal pure returns (D256 memory) {
        return D256({value: self.value.sub(b.mul(BASE))});
    }

    function sub(
        D256 memory self,
        uint256 b,
        string memory reason
    ) internal pure returns (D256 memory) {
        return D256({value: self.value.sub(b.mul(BASE), reason)});
    }

    function mul(D256 memory self, uint256 b) internal pure returns (D256 memory) {
        return D256({value: self.value.mul(b)});
    }

    function div(D256 memory self, uint256 b) internal pure returns (D256 memory) {
        return D256({value: self.value.div(b)});
    }

    function pow(D256 memory self, uint256 b) internal pure returns (D256 memory) {
        if (b == 0) {
            return one();
        }

        D256 memory temp = D256({value: self.value});
        for (uint256 i = 1; i < b; i++) {
            temp = mul(temp, self);
        }

        return temp;
    }

    function add(D256 memory self, D256 memory b) internal pure returns (D256 memory) {
        return D256({value: self.value.add(b.value)});
    }

    function sub(D256 memory self, D256 memory b) internal pure returns (D256 memory) {
        return D256({value: self.value.sub(b.value)});
    }

    function sub(
        D256 memory self,
        D256 memory b,
        string memory reason
    ) internal pure returns (D256 memory) {
        return D256({value: self.value.sub(b.value, reason)});
    }

    function mul(D256 memory self, D256 memory b) internal pure returns (D256 memory) {
        return D256({value: getPartial(self.value, b.value, BASE)});
    }

    function div(D256 memory self, D256 memory b) internal pure returns (D256 memory) {
        return D256({value: getPartial(self.value, BASE, b.value)});
    }

    function equals(D256 memory self, D256 memory b) internal pure returns (bool) {
        return self.value == b.value;
    }

    function greaterThan(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) == 2;
    }

    function lessThan(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) == 0;
    }

    function greaterThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) > 0;
    }

    function lessThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
        return compareTo(self, b) < 2;
    }

    function isZero(D256 memory self) internal pure returns (bool) {
        return self.value == 0;
    }

    function asUint256(D256 memory self) internal pure returns (uint256) {
        return self.value.div(BASE);
    }

    // ============ Core Methods ============

    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    ) private pure returns (uint256) {
        return target.mul(numerator).div(denominator);
    }

    function compareTo(D256 memory a, D256 memory b) private pure returns (uint256) {
        if (a.value == b.value) {
            return 1;
        }
        return a.value > b.value ? 2 : 0;
    }
}

/*
 SPDX-License-Identifier: MIT
*/

pragma solidity >=0.5.16;

import '../interfaces/pancake/IPancakePair.sol';
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";

// library with helper methods for oracles that are concerned with computing average prices
library PancakeOracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(address pair)
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IPancakePair(pair).getReserves();
        return currentCumulativePricesWithReserves(pair, reserve0, reserve1, blockTimestampLast);
    }

    function currentCumulativePricesWithReserves(
        address pair,
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    )
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IPancakePair(pair).price0CumulativeLast();
        price1Cumulative = IPancakePair(pair).price1CumulativeLast();

        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint256(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint256(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

import './Babylonian.sol';

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // take the reciprocal of a UQ112x112
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    // square root of a UQ112x112
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method
library Babylonian {
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0
    }
}