/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./Order.sol";

/**
 * @author Beanjoyer
 * @title Pod Marketplace v1
 **/
contract MarketplaceFacet is Order {
    using SafeMath for uint256;

    /*
     * Pod Listing
     */

    // Create
    // Note: pricePerPod is bounded by 16_777_215 Beans.
    function createPodListing(
        uint256 index,
        uint256 start,
        uint256 amount,
        uint24 pricePerPod,
        uint256 maxHarvestableIndex,
        bool toWallet
    ) external {
        _createPodListing(index, start, amount, pricePerPod, maxHarvestableIndex, toWallet);
    }

    // Fill
    function fillPodListing(PodListing calldata l, uint256 beanAmount) external {
        LibMarket.transferBeans(l.account, beanAmount, l.toWallet);
        _fillListing(l, beanAmount);
    }

    function claimAndFillPodListing(
        PodListing calldata l,
        uint256 beanAmount,
        LibClaim.Claim calldata claim
    ) external nonReentrant {
        allocateBeansToWallet(claim, beanAmount, l.account, l.toWallet);
        _fillListing(l, beanAmount);
        LibMarket.claimRefund(claim);
    }

    function buyBeansAndFillPodListing(
        PodListing calldata l,
        uint256 beanAmount,
        uint256 buyBeanAmount
    ) external payable nonReentrant {
        if (beanAmount > 0) LibMarket.transferBeans(l.account, beanAmount, l.toWallet);
        _buyBeansAndFillPodListing(l, beanAmount, buyBeanAmount);
    }

    function claimBuyBeansAndFillPodListing(
        PodListing calldata l,
        uint256 beanAmount,
        uint256 buyBeanAmount,
        LibClaim.Claim calldata claim
    ) external payable nonReentrant {
        allocateBeansToWallet(claim, beanAmount, l.account, l.toWallet);
        _buyBeansAndFillPodListing(l, beanAmount, buyBeanAmount);
    }

    // Cancel
    function cancelPodListing(uint256 index) external {
        _cancelPodListing(msg.sender, index);
    }

    // Get
    function podListing(uint256 index) external view returns (bytes32) {
        return s.podListings[index];
    }

    /*
     * Pod Orders
     */

    // Create
    // Note: pricePerPod is bounded by 16_777_215 Beans.
    function createPodOrder(
        uint256 beanAmount,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) external returns (bytes32 id) {
        bean().transferFrom(msg.sender, address(this), beanAmount);
        return _createPodOrder(beanAmount, pricePerPod, maxPlaceInLine);
    }

    function claimAndCreatePodOrder(
        uint256 beanAmount,
        uint24 pricePerPod,
        uint232 maxPlaceInLine,
        LibClaim.Claim calldata claim
    ) external nonReentrant returns (bytes32 id) {
        allocateBeans(claim, beanAmount, address(this));
        id = _createPodOrder(beanAmount, pricePerPod, maxPlaceInLine);
        LibMarket.claimRefund(claim);
    }

    function buyBeansAndCreatePodOrder(
        uint256 beanAmount,
        uint256 buyBeanAmount,
        uint24 pricePerPod,
        uint232 maxPlaceInLine
    ) external payable nonReentrant returns (bytes32 id) {
        if (beanAmount > 0) bean().transferFrom(msg.sender, address(this), beanAmount);
        return _buyBeansAndCreatePodOrder(beanAmount, buyBeanAmount, pricePerPod, maxPlaceInLine);
    }

    function claimBuyBeansAndCreatePodOrder(
        uint256 beanAmount,
        uint256 buyBeanAmount,
        uint24 pricePerPod,
        uint232 maxPlaceInLine,
        LibClaim.Claim calldata claim
    ) external payable nonReentrant returns (bytes32 id) {
        allocateBeans(claim, beanAmount, address(this));
        return _buyBeansAndCreatePodOrder(beanAmount, buyBeanAmount, pricePerPod, maxPlaceInLine);
    }

    // Fill
    function fillPodOrder(
        PodOrder calldata o,
        uint256 index,
        uint256 start,
        uint256 amount,
        bool toWallet
    ) external {
        _fillPodOrder(o, index, start, amount, toWallet);
    }

    // Cancel
    function cancelPodOrder(
        uint24 pricePerPod,
        uint256 maxPlaceInLine,
        bool toWallet
    ) external {
        _cancelPodOrder(pricePerPod, maxPlaceInLine, toWallet);
    }

    // Get

    function podOrder(
        address account,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) external view returns (uint256) {
        return s.podOrders[createOrderId(account, pricePerPod, maxPlaceInLine)];
    }

    function podOrderById(bytes32 id) external view returns (uint256) {
        return s.podOrders[id];
    }

    /*
     * Helpers
     */

    function allocateBeans(
        LibClaim.Claim calldata c,
        uint256 transferBeans,
        address to
    ) private {
        LibClaim.claim(c);
        LibMarket.allocateBeansTo(transferBeans, to);
    }

    function allocateBeansToWallet(
        LibClaim.Claim calldata c,
        uint256 transferBeans,
        address to,
        bool toWallet
    ) private {
        LibClaim.claim(c);
        LibMarket.allocateBeansToWallet(transferBeans, to, toWallet);
    }

    /*
     * Transfer Plot
     */

    function transferPlot(
        address sender,
        address recipient,
        uint256 id,
        uint256 start,
        uint256 end
    ) external nonReentrant {
        require(sender != address(0) && recipient != address(0), "Field: Transfer to/from 0 address.");
        uint256 amount = s.a[msg.sender].field.plots[id];
        require(amount > 0, "Field: Plot not owned by user.");
        require(end > start && amount >= end, "Field: Pod range invalid.");
        amount = end - start; // Note: SafeMath is redundant here.
        if (msg.sender != sender && allowancePods(sender, msg.sender) != uint256(-1)) {
            decrementAllowancePods(sender, msg.sender, amount);
        }

        if (s.podListings[id] != bytes32(0)) {
            _cancelPodListing(sender, id);
        }
        _transferPlot(sender, recipient, id, start, amount);
    }

    function approvePods(address spender, uint256 amount) external nonReentrant {
        require(spender != address(0), "Field: Pod Approve to 0 address.");
        setAllowancePods(msg.sender, spender, amount);
        emit PodApproval(msg.sender, spender, amount);
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "./Listing.sol";

/**
 * @author Beanjoyer
 * @title Pod Marketplace v1
 **/
contract Order is Listing {
    using SafeMath for uint256;

    struct PodOrder {
        address account;
        uint24 pricePerPod;
        uint256 maxPlaceInLine;
    }

    event PodOrderCreated(address indexed account, bytes32 id, uint256 amount, uint24 pricePerPod, uint256 maxPlaceInLine);
    event PodOrderFilled(address indexed from, address indexed to, bytes32 id, uint256 index, uint256 start, uint256 amount);
    event PodOrderCancelled(address indexed account, bytes32 id);

    /*
     * Create
     */
    /// @notice Internal function for buying beans on behalf of the pod orderer and then adding that bean amount to the created pod order.
    /// @param beanAmount amount of pods in beans for pod order
    /// @param buyBeanAmount amount of beans to buy and use for pod order
    /// @param pricePerPod price per pod
    /// @param maxPlaceInLine maximum place in pod line to place an order for
    /// @return id id of the newly created pod order
    function _buyBeansAndCreatePodOrder(
        uint256 beanAmount,
        uint256 buyBeanAmount,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) internal returns (bytes32 id) {
        uint256 boughtBeanAmount = LibMarket.buyExactTokens(buyBeanAmount, address(this));
        id = _createPodOrder(beanAmount + boughtBeanAmount, pricePerPod, maxPlaceInLine);
        LibMarket.refund();
    }

    /// @notice Internal function that handles the calculation of the pods to order amount and calls the internal function #__createPodOrder.
    /// @param beanAmount amount of pods in beans for pod order
    /// @param pricePerPod price per pod
    /// @param maxPlaceInLine maximum place in pod line to place an order for
    /// @return id id of the newly created pod order
    function _createPodOrder(
        uint256 beanAmount,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) internal returns (bytes32 id) {
        require(0 < pricePerPod, "Marketplace: Pod price must be greater than 0.");
        uint256 amount = (beanAmount * 1000000) / pricePerPod;
        return __createPodOrder(amount, pricePerPod, maxPlaceInLine);
    }

    /// @notice Internal function that handles the business logic of the creation and storage of a pod order within the Farmer ecosystem.
    /// @param amount amount of pods for pod order
    /// @param pricePerPod price per pod
    /// @param maxPlaceInLine maximum place in pod line to place an order for
    /// @return id id of the newly created pod order
    function __createPodOrder(
        uint256 amount,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) internal returns (bytes32 id) {
        require(amount > 0, "Marketplace: Order amount must be > 0.");
        id = createOrderId(msg.sender, pricePerPod, maxPlaceInLine);
        if (s.podOrders[id] > 0) _cancelPodOrder(pricePerPod, maxPlaceInLine, false);
        s.podOrders[id] = amount;
        emit PodOrderCreated(msg.sender, id, amount, pricePerPod, maxPlaceInLine);
    }

    /*
     * Fill
     */

    /// @notice Internal function that handles the business logic of the fill/completion of a Pod Order through the transfer of the payment in beans to the Pod Lister and the transfer in pods to the Pod Orderer.
    /// @param o Order object with inputs for a pod order fill
    /// @param index plot id index for the pod order to be filled with
    /// @param start  	starting pod plot spot for this order fill
    /// @param amount amount of pods to fill with
    /// @param toWallet optional boolean to transfer pods to wallet or keep as wrapped
    function _fillPodOrder(
        PodOrder calldata o,
        uint256 index,
        uint256 start,
        uint256 amount,
        bool toWallet
    ) internal {
        bytes32 id = createOrderId(o.account, o.pricePerPod, o.maxPlaceInLine);
        s.podOrders[id] = s.podOrders[id].sub(amount);
        require(s.a[msg.sender].field.plots[index] >= (start + amount), "Marketplace: Invalid Plot.");
        uint256 placeInLineEndPlot = index + start + amount - s.f.harvestable;
        require(placeInLineEndPlot <= o.maxPlaceInLine, "Marketplace: Plot too far in line.");
        uint256 costInBeans = (o.pricePerPod * amount) / 1000000;
        if (toWallet) bean().transfer(msg.sender, costInBeans);
        else s.a[msg.sender].wrappedBeans = s.a[msg.sender].wrappedBeans.add(costInBeans);
        if (s.podListings[index] != bytes32(0)) {
            _cancelPodListing(msg.sender, index);
        }
        _transferPlot(msg.sender, o.account, index, start, amount);
        if (s.podOrders[id] == 0) {
            delete s.podOrders[id];
        }
        emit PodOrderFilled(msg.sender, o.account, id, index, start, amount);
    }

    /*
     * Cancel
     */

    /// @notice Internal function for canceling the pod order and removing it from storage.
    /// @param pricePerPod price per pod
    /// @param maxPlaceInLine maximum place in pod line to of the order to cancel
    /// @param toWallet optional boolean to transfer pods to wallet or keep as wrapped
    function _cancelPodOrder(
        uint24 pricePerPod,
        uint256 maxPlaceInLine,
        bool toWallet
    ) internal {
        bytes32 id = createOrderId(msg.sender, pricePerPod, maxPlaceInLine);
        uint256 amountBeans = (pricePerPod * s.podOrders[id]) / 1000000;
        if (toWallet) bean().transfer(msg.sender, amountBeans);
        else s.a[msg.sender].wrappedBeans = s.a[msg.sender].wrappedBeans.add(amountBeans);
        delete s.podOrders[id];
        emit PodOrderCancelled(msg.sender, id);
    }

    /*
     * Helpers
     */

    /// @notice Internal function that hashes a Pod Order and thus creates a order id for it. This returns that bytes32 hash as an id.
    /// @param account address of the pod orderer account
    /// @param pricePerPod price per pod
    /// @param maxPlaceInLine maximum place in pod line for the order
    /// @return id of the newly created pod order 
    function createOrderId(
        address account,
        uint24 pricePerPod,
        uint256 maxPlaceInLine
    ) internal pure returns (bytes32 id) {
        id = keccak256(abi.encodePacked(account, pricePerPod, maxPlaceInLine));
    }
}

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "../../../libraries/LibMarket.sol";
import "../../../libraries/LibClaim.sol";
import "./PodTransfer.sol";

/**
 * @author Beanjoyer
 * @title Pod Marketplace v1
 **/
contract Listing is PodTransfer {
    using SafeMath for uint256;

    struct PodListing {
        address account;
        uint256 index;
        uint256 start;
        uint256 amount;
        uint24 pricePerPod;
        uint256 maxHarvestableIndex;
        bool toWallet;
    }

    event PodListingCreated(address indexed account, uint256 index, uint256 start, uint256 amount, uint24 pricePerPod, uint256 maxHarvestableIndex, bool toWallet);
    event PodListingFilled(address indexed from, address indexed to, uint256 index, uint256 start, uint256 amount);
    event PodListingCancelled(address indexed account, uint256 index);

    /*
     * Create
     */

    /// @notice Internal function for creating a pod listing and properly storing it securely within the beanstalk ecosystem.
    /// @param index plot id index for storage
    /// @param start starting pod plot spot for this listing
    /// @param amount  	amount of pods to list
    /// @param pricePerPod price per pod
    /// @param maxHarvestableIndex index for maximum amount that is harvestable
    /// @param toWallet optional boolean to transfer pods to wallet or keep as wrapped
    function _createPodListing(
        uint256 index,
        uint256 start,
        uint256 amount,
        uint24 pricePerPod,
        uint256 maxHarvestableIndex,
        bool toWallet
    ) internal {
        uint256 plotSize = s.a[msg.sender].field.plots[index];
        require(plotSize >= start.add(amount) && amount > 0, "Marketplace: Invalid Plot/Amount.");
        require(0 < pricePerPod, "Marketplace: Pod price must be greater than 0.");
        require(s.f.harvestable <= maxHarvestableIndex, "Marketplace: Expired.");

        if (s.podListings[index] != bytes32(0)) _cancelPodListing(msg.sender, index);

        s.podListings[index] = hashListing(start, amount, pricePerPod, maxHarvestableIndex, toWallet);

        emit PodListingCreated(msg.sender, index, start, amount, pricePerPod, maxHarvestableIndex, toWallet);
    }

    /*
     * Fill
     */

    /// @notice Internal function that handles the fill aka completion of pod listings through the transfer of the plots to the list buying account
    /// @param l listing object with the current parameters for this pod listing
    /// @param beanAmount amount of beans for pod listing
    /// @param buyBeanAmount amount of beans to buy and add in pods to pod listing
    function _buyBeansAndFillPodListing(
        PodListing calldata l,
        uint256 beanAmount,
        uint256 buyBeanAmount
    ) internal {
        uint256 boughtBeanAmount = LibMarket.buyExactTokensToWallet(buyBeanAmount, l.account, l.toWallet);
        _fillListing(l, beanAmount + boughtBeanAmount);
        LibMarket.refund();
    }

    /// @notice Internal function that handles the security checks for the list filling and calls the appropriate functions for the business logic of updating the storage of the plot listing and plot transferring.
    /// @param l listing object with the current parameters for this pod listing
    /// @param beanAmount amount of beans for pod listing fill
    function _fillListing(PodListing calldata l, uint256 beanAmount) internal {
        bytes32 lHash = hashListing(l.start, l.amount, l.pricePerPod, l.maxHarvestableIndex, l.toWallet);
        require(s.podListings[l.index] == lHash, "Marketplace: Listing does not exist.");
        uint256 plotSize = s.a[l.account].field.plots[l.index];
        require(plotSize >= (l.start + l.amount) && l.amount > 0, "Marketplace: Invalid Plot/Amount.");
        require(s.f.harvestable <= l.maxHarvestableIndex, "Marketplace: Listing has expired.");

        uint256 amount = (beanAmount * 1000000) / l.pricePerPod;
        amount = roundAmount(l, amount);

        __fillListing(msg.sender, l, amount);
        _transferPlot(l.account, msg.sender, l.index, l.start, amount);
    }

    /// @notice Private function that updates the storage of the pod listings to reflect this fill.
    /// @param to ()
    /// @param l listing object with the current parameters for this pod listing
    /// @param amount amount of beans for pod listing
      function __fillListing(
        address to,
        PodListing calldata l,
        uint256 amount
    ) private {
        require(l.amount >= amount, "Marketplace: Not enough pods in Listing.");

        if (l.amount > amount) s.podListings[l.index.add(amount).add(l.start)] = hashListing(0, l.amount.sub(amount), l.pricePerPod, l.maxHarvestableIndex, l.toWallet);
        emit PodListingFilled(l.account, to, l.index, l.start, amount);
        delete s.podListings[l.index];
    }


    /*
     * Cancel
     */

    /// @notice Internal function for removing and canceling a pod listing.
    /// @param index lplot id index for storage
    function _cancelPodListing(address account, uint256 index) internal {
        require(s.a[account].field.plots[index] > 0, "Marketplace: Listing not owned by sender.");
        delete s.podListings[index];
        emit PodListingCancelled(account, index);
    }

    /*
     * Helpers
     */

    // If remainder left (always <1 pod) that would otherwise be unpurchaseable
    // due to rounding from calculating amount, give it to last buyer
    /// @notice Private helper function to check if there is a listing remainder left (always <1 pod) that would otherwise be unpurchaseable. So due to rounding from calculating amount, we give it to last buyer. This returns that rounded amount.
    /// @param l listing object with the current parameters for this pod listing 	
    /// @param amount amount of beans for pod listing fill
    /// @return uint256 rounded amount of beans for pod listing fill
    function roundAmount(PodListing calldata l, uint256 amount) private pure returns (uint256) {
        uint256 remainingAmount = l.amount.sub(amount, "Marketplace: Not enough pods in Listing");
        if (remainingAmount < (1000000 / l.pricePerPod)) amount = l.amount;
        return amount;
    }

    /*
     * Helpers
     */
    /// @notice Internal function that hashes this listing for security purposes and double spending prevention. This returns the resulting hash.
    /// @param start starting pod plot spot for this listing	
    /// @param amount amount of pods to list
    /// @param pricePerPod price per pod
    /// @param maxHarvestableIndex index for maximum amount that is harvestable
    /// @param toWallet optional boolean to transfer pods to wallet or keep as wrapped	
    /// @return lHash hash of the pod listing
    function hashListing(
        uint256 start,
        uint256 amount,
        uint24 pricePerPod,
        uint256 maxHarvestableIndex,
        bool toWallet
    ) internal pure returns (bytes32 lHash) {
        lHash = keccak256(abi.encodePacked(start, amount, pricePerPod, maxHarvestableIndex, toWallet));
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

/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../AppStorage.sol";
import "../../../interfaces/IBean.sol";
import "../../../libraries/LibSafeMath32.sol";
import "../../ReentrancyGuard.sol";

/**
 * @author Publius
 * @title Pod Transfer
 **/
contract PodTransfer is ReentrancyGuard {
    using SafeMath for uint256;
    using LibSafeMath32 for uint32;

    event PlotTransfer(address indexed from, address indexed to, uint256 indexed id, uint256 pods);
    event PodApproval(address indexed owner, address indexed spender, uint256 pods);

    /**
     * Getters
     **/

    /// @notice Public function for granting allowance permissions for a spender for a particular owner's pods. ()
    /// @param owner address of the pods owner
    /// @param spender address of the account to grant allowance permissions
    /// @return uint256 allowance amount of pods for spender
    function allowancePods(address owner, address spender) public view returns (uint256) {
        return s.a[owner].field.podAllowances[spender];
    }

    /**
     * Internal
     **/

    /// @notice Internal function that handles the business logic for transferring plot of pods from one account to another using internal functions 
    /// @param from address of the pod sending account
    /// @param to address of the pod receiving account
    /// @param index plot id index for storage
    /// @param start starting pod plot spot for this plot transfer
    /// @param amount number of pods to transfer
    function _transferPlot(
        address from,
        address to,
        uint256 index,
        uint256 start,
        uint256 amount
    ) internal {
        require(from != to, "Field: Cannot transfer Pods to oneself.");
        insertPlot(to, index.add(start), amount);
        removePlot(from, index, start, amount.add(start));
        emit PlotTransfer(from, to, index.add(start), amount);
    }

    /// @notice Internal function that handles the adding of pods to a specified account's plot.
    /// @param account address of the account to add pods to
    /// @param id the id of the account plot to add pods to
    /// @param amount number of pods to add to a specified account's plot
    function insertPlot(
        address account,
        uint256 id,
        uint256 amount
    ) internal {
        s.a[account].field.plots[id] = amount;
    }

    /// @notice Internal function that handles the business logic of the removal of pods from a specified account's plot.
    /// @param account address of the account to remove pods from
    /// @param id the id of the account plot to add pods from
    /// @param start starting pod plot spot for this plot removal
    /// @param end ending pod plot spot for this plot removal
    function removePlot(
        address account,
        uint256 id,
        uint256 start,
        uint256 end
    ) internal {
        uint256 amount = s.a[account].field.plots[id];
        if (start == 0) delete s.a[account].field.plots[id];
        else s.a[account].field.plots[id] = start;
        if (end != amount) s.a[account].field.plots[id.add(end)] = amount.sub(end);
    }

    /// @notice Internal function for decreasing the allowance amount of pods of an account for a specified spender account.
    /// @param owner address of the pods owner
    /// @param spender address of the account with allowance permissions
    /// @param amount allowance number of pods for decrease
    function decrementAllowancePods(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowancePods(owner, spender);
        setAllowancePods(owner, spender, currentAllowance.sub(amount, "Field: Insufficient approval."));
    }

    /// @notice Internal function for setting the allowance amount of pods of an account for a specified spender account.
    /// @param owner address of the pods owner
    /// @param spender address of the account with allowance permissions
    /// @param amount allowance number of pods to set for spender
    function setAllowancePods(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        s.a[owner].field.podAllowances[spender] = amount;
    }

    /// @notice Internal function that returns the IBean object for the Popcorn stablecoin.
    /// @return IBean the IBean object of the Popcorn stablecoin
    function bean() internal view returns (IBean) {
        return IBean(s.c.bean);
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @author Publius
 * @title WETH Interface
 **/
interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
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

// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;
import "../libraries/LibInternal.sol";
import "./AppStorage.sol";

/**
 * @author Farmer Farms
 * @title Variation of Oepn Zeppelins reentrant guard to include Silo Update
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts%2Fsecurity%2FReentrancyGuard.sol
 **/
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    AppStorage internal s;

    modifier updateSilo() {
        LibInternal.updateSilo(msg.sender);
        _;
    }
    
    modifier updateSiloNonReentrant() {
        require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        s.reentrantStatus = _ENTERED;
        LibInternal.updateSilo(msg.sender);
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        s.reentrantStatus = _ENTERED;
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }
}