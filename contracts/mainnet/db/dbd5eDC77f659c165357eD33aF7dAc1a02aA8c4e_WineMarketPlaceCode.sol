// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./interfaces/IWineManager.sol";
import "./interfaces/IWinePoolFull.sol";
import "./interfaces/IWineMarketPlace.sol";
import "./vendors/access/ManagerLikeOwner.sol";
import "./vendors/utils/ERC721OnlySelfInitHolder.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./WineBordeauxCityBondHelper/BordeauxCityBondTransferHelper.sol";

contract WineMarketPlaceCode is
    ManagerLikeOwner,
    Initializable,
    ERC721OnlySelfInitHolder,
    BordeauxCityBondTransferHelper,
    IWineMarketPlace
{
    using SafeERC20 for IERC20;

    mapping (address => bool) public marketPlaceCurrencyIsAllowed;
    uint256 public marketPlaceOrderFeeInPromille;

    uint256 public BCBFixedFee;
    uint256 public BCBFlexedFee;

    function initialize(
        address manager_,
        address[] memory allowedCurrencies_,
        uint256 orderFeeInPromille_
    )
        override
        public
        initializer
    {
        _initializeManager(manager_);

        for (uint256 i = 0; i < allowedCurrencies_.length; i++) {
            _editAllowedCurrency(allowedCurrencies_[i], true);
        }
        _editOrderFeeInPromille(orderFeeInPromille_);
    }

//////////////////////////////////////// Settings

    function _editAllowedCurrency(
        address currency_,
        bool value
    )
        override
        public
        onlyManager
    {
        marketPlaceCurrencyIsAllowed[currency_] = value;
    }

    function _editOrderFeeInPromille(
        uint256 orderFeeInPromille_
    )
        override
        public
        onlyManager
    {
        require(orderFeeInPromille_ < 1000, "MarketPlace::_editOrderFeeInPromille - max");
        marketPlaceOrderFeeInPromille = orderFeeInPromille_;
    }

//////////////////////////////////////// Orders

    enum OrderStatus {
        Open,
        Canceled,
        Executed
    }

    struct Order{
        bool exists;
        uint256 poolId;
        uint256 tokenId;
        address currency;
        uint256 price;
        uint256 fee;
        address seller;
        address buyer;
        OrderStatus status;
    }

    mapping(uint256 => bool) private orderLock;
    mapping(uint256 => Order) public orders;
    uint256 public ordersCount;

    modifier orderExistsAndOpen(uint256 orderId) {
        require(orders[orderId].exists, "Order not exists");
        require(orders[orderId].status == OrderStatus.Open, "Order is Finished");
        _;
    }
    modifier orderOwner(uint256 orderId) {
        require(orders[orderId].seller == _msgSender(), "order.seller != _msgSender");
        _;
    }
    modifier lockOrder(uint256 orderId) {
        require(orderLock[orderId] == false, "order locked");
        orderLock[orderId] = true;
        _;
        orderLock[orderId] = false;
    }

    function createOrder(
        uint256 poolId,
        uint256 tokenId,
        address currency,
        uint256 price
    )
        override
        public
        returns (uint256 orderId)
    {
        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(poolId);
        require(pool.getWinePrice() < price, 'MarketPlace::_createOrder - price should be more then firstSale price');
        require(marketPlaceCurrencyIsAllowed[currency], 'MarketPlace::_createOrder - currency is not allowed');
        address seller = _msgSender();

        pool.safeTransferFrom(seller, address(this), tokenId);

        ordersCount++;
        orderId = ordersCount - 1;

        Order memory order = Order({
            exists: true,
            poolId: poolId,
            tokenId: tokenId,
            currency: currency,
            price: price,
            fee: price * marketPlaceOrderFeeInPromille / 1000,
            seller: seller,
            buyer: address(0),
            status: OrderStatus.Open
        });

        orders[orderId] = order;
        emit CreateOrder(
            seller,
            poolId,
            tokenId,
            currency,
            price,
            orderId
        );
    }

    function getOpenOrderIds()
        public
        view
        returns (uint256[] memory)
    {
        uint256 openOrdersCount = 0;
        for (uint256 i = 0; i < ordersCount; i++) {
            if (orders[i].status == OrderStatus.Open) {
                openOrdersCount++;
            }
        }

        uint256[] memory openOrderIds = new uint256[](openOrdersCount);
        uint256 currentOpenIndex = 0;
        for (uint256 i = 0; i < ordersCount; i++) {
            if (orders[i].status == OrderStatus.Open) {
                openOrderIds[currentOpenIndex] = i;
                currentOpenIndex++;
            }
        }
        return openOrderIds;
    }

    function getOrders(bool onlyOpen)
        public
        view
        returns (Order[] memory)
    {
        if (onlyOpen == false) {
            return _getAllOrders();
        }

        uint256 openOrdersCount = 0;
        for (uint256 i = 0; i < ordersCount; i++) {
            if (orders[i].status == OrderStatus.Open) {
                openOrdersCount++;
            }
        }

        Order[] memory openOrders = new Order[](openOrdersCount);
        uint256 currentOpenIndex = 0;
        for (uint256 i = 0; i < ordersCount; i++) {
            if (orders[i].status == OrderStatus.Open) {
                openOrders[currentOpenIndex] = orders[i];
                currentOpenIndex++;
            }
        }
        return openOrders;
    }

    function _getAllOrders()
        internal
        view
        returns (Order[] memory)
    {
        Order[] memory allOrders = new Order[](ordersCount);

        for (uint256 i = 0; i < ordersCount; i++) {
            allOrders[i] = orders[i];
        }

        return allOrders;
    }

    function cancelOrder(uint256 orderId)
        override
        public
        orderExistsAndOpen(orderId) orderOwner(orderId) lockOrder(orderId)
    {
        Order storage order = orders[orderId];
        order.status = OrderStatus.Canceled;

        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(order.poolId);
        pool.safeTransferFrom(address(this), order.seller, order.tokenId);
        emit CancelOrder(
            orderId
        );
    }

    function executeOrder(uint256 orderId)
        override
        public
        orderExistsAndOpen(orderId) lockOrder(orderId)
    {
        Order storage order = orders[orderId];
        require(order.seller != _msgSender(), "order.seller == _msgSender");

        order.status = OrderStatus.Executed;
        order.buyer = _msgSender();

        IWinePoolFull pool = IWineManager(manager()).getPoolAsContract(order.poolId);
        IERC20 currency = IERC20(order.currency);

        currency.safeTransferFrom(order.buyer, address(this), order.price);
        uint256 storagePrice = onOrderExecute(manager(), order.poolId, order.tokenId);
        currency.safeTransfer(order.seller, order.price - order.fee - storagePrice);

        pool.safeTransferFrom(address(this), order.buyer, order.tokenId);
        emit ExecuteOrder(
            order.buyer,
            orderId,
            order.fee,
            storagePrice
        );
    }

//////////////////////////////////////// Owner

    function withdrawFee(address currencyAddress, address to, uint256 amount)
        override
        public
        onlyManager()
    {
        IERC20 currency = IERC20(currencyAddress);
        uint256 balance = currency.balanceOf(address(this));
        if (amount == 0) {
            amount = balance;
            require(amount > 0, "Balance is empty");
        } else {
            require(amount <= balance, "Balance not enough");
        }

        currency.safeTransfer(to, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts only self initiated token transfers.
 */
abstract contract ERC721OnlySelfInitHolder is IERC721Receiver {

    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        if (operator == address(this)) {
            return this.onERC721Received.selector;
        }
        return bytes4(0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an manager) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the manager account will be the one that deploys the contract. This
 * can later be changed with {transferManagership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyManager`, which can be applied to your functions to restrict their use to
 * the manager.
 */
contract ManagerLikeOwner is Context {
    address private _manager;

    event ManagershipTransferred(address indexed previousManager, address indexed newManager);

    /**
     * @dev Initializes the contract setting the deployer as the initial manager.
     */
    function _initializeManager(address manager_)
        internal
    {
        _transferManagership(manager_);
    }

    /**
     * @dev Returns the address of the current manager.
     */
    function manager()
        public view
        returns (address)
    {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the manager.
     */
    modifier onlyManager() {
        require(_manager == _msgSender(), "ManagerIsOwner: caller is not the manager");
        _;
    }

    /**
     * @dev Leaves the contract without manager. It will not be possible to call
     * `onlyManager` functions anymore. Can only be called by the current manager.
     *
     * NOTE: Renouncing managership will leave the contract without an manager,
     * thereby removing any functionality that is only available to the manager.
     */
    function renounceManagership()
        virtual
        public
        onlyManager
    {
        _beforeTransferManager(address(0));

        emit ManagershipTransferred(_manager, address(0));
        _manager = address(0);
    }

    /**
     * @dev Transfers managership of the contract to a new account (`newManager`).
     * Can only be called by the current manager.
     */
    function transferManagership(address newManager)
        virtual
        public
        onlyManager
    {
        _transferManagership(newManager);
    }

    function _transferManagership(address newManager)
        virtual
        internal
    {
        require(newManager != address(0), "ManagerIsOwner: new manager is the zero address");
        _beforeTransferManager(newManager);

        emit ManagershipTransferred(_manager, newManager);
        _manager = newManager;
    }

    /**
     * @dev Hook that is called before manger transfer. This includes initialize and renounce
     */
    function _beforeTransferManager(address newManager)
        virtual
        internal
    {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWinePool.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";


interface IWinePoolFull is IERC165, IERC721, IERC721Metadata, IWinePool
{
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWinePool
{
//////////////////////////////////////// DescriptionFields

    function updateAllDescriptionFields(
        string memory wineName,
        string memory wineProductionCountry,
        string memory wineProductionRegion,
        string memory wineProductionYear,
        string memory wineProducerName,
        string memory wineBottleVolume,
        string memory linkToDocuments
    ) external;
    function editDescriptionField(bytes32 param, string memory value) external;

//////////////////////////////////////// System fields

    function getPoolId() external view returns (uint256);
    function getMaxTotalSupply() external view returns (uint256);
    function getWinePrice() external view returns (uint256);

    function editMaxTotalSupply(uint256 value) external;
    function editWinePrice(uint256 value) external;

//////////////////////////////////////// Pausable

    function pause() external;
    function unpause() external;

//////////////////////////////////////// Initialize

    function initialize(
        string memory name,
        string memory symbol,

        address manager,

        uint256 poolId,
        uint256 maxTotalSupply,
        uint256 winePrice
    ) external payable returns (bool);

//////////////////////////////////////// Disable

    function disabled() external view returns (bool);

    function disablePool() external;

//////////////////////////////////////// default methods

    function tokensCount() external view returns (uint256);

    function burn(uint256 tokenId) external;

    function mint(address to) external;

//////////////////////////////////////// internal users and tokens


    event WinePoolMintToken(address indexed to, uint256 tokenId);
    event WinePoolMintTokenToInternal(address indexed to, uint256 tokenId);
    event OuterToInternalTransfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event InternalToInternalTransfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event InternalToOuterTransfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function internalUsersExists(address) external view returns (bool);
    function internalOwnedTokens(uint256) external view returns (address);

    function mintToInternalUser(address internalUser) external;

    function transferInternalToInternal(address internalFrom, address internalTo, uint256 tokenId) external;

    function transferOuterToInternal(address outerFrom, address internalTo, uint256 tokenId) external;

    function transferInternalToOuter(address internalFrom, address outerTo, uint256 tokenId) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineMarketPlace {

    function initialize(
        address manager_,
        address[] memory allowedCurrencies_,
        uint256 orderFeeInPromille_
    ) external;

//////////////////////////////////////// Settings

    function _editAllowedCurrency(address currency_, bool value) external;

    function _editOrderFeeInPromille(uint256 orderFeeInPromille_) external;

//////////////////////////////////////// Owner

    event CreateOrder(
        address seller,
        uint256 poolId,
        uint256 tokenId,
        address currency,
        uint256 price,
        uint256 orderId
    );
    event CancelOrder(
        uint256 orderId
    );

    event ExecuteOrder(
        address buyer,
        uint256 orderId,
        uint256 orderFee,
        uint256 storageFee
    );

    function createOrder(
        uint256 poolId,
        uint256 tokenId,
        address currency,
        uint256 price
    ) external returns (uint256 orderId);

    function cancelOrder(uint256 orderId) external;

    function executeOrder(uint256 orderId) external;

//////////////////////////////////////// Owner

    function withdrawFee(address currencyAddress, address to, uint256 amount) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerPoolIntegration {

    function allowMint(address) external view returns (bool);
    function allowInternalTransfers(address) external view returns (bool);
    function allowBurn(address) external view returns (bool);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerMarketPlaceIntegration {

    function marketPlace() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerFirstSaleMarketIntegration {

    function firstSaleMarket() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWinePoolFull.sol";

interface IWineManagerFactoryIntegration {

    event WinePoolCreated(uint256 poolId, address winePool);

    function factory() external view returns (address);

    function getPoolAddress(uint256 poolId) external view returns (address);

    function getPoolAsContract(uint256 poolId) external view returns (IWinePoolFull);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerDeliveryServiceIntegration {

    function deliveryService() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWineManagerBordeauxCityBondIntegration {

    function bordeauxCityBond() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IWineManagerFactoryIntegration.sol";
import "./IWineManagerFirstSaleMarketIntegration.sol";
import "./IWineManagerMarketPlaceIntegration.sol";
import "./IWineManagerDeliveryServiceIntegration.sol";
import "./IWineManagerPoolIntegration.sol";
import "./IWineManagerBordeauxCityBondIntegration.sol";

interface IWineManager is
    IWineManagerFactoryIntegration,
    IWineManagerFirstSaleMarketIntegration,
    IWineManagerMarketPlaceIntegration,
    IWineManagerDeliveryServiceIntegration,
    IWineManagerPoolIntegration,
    IWineManagerBordeauxCityBondIntegration
{

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBordeauxCityBondIntegration {

    function BCBOutFee() external view returns (uint256);
    function BCBFixedFee() external view returns (uint256);
    function BCBFlexedFee() external view returns (uint256);

    function initialize(
        address manager_,
        uint256 BCBOutFee_,
        uint256 BCBFixedFee_,
        uint256 BCBFlexedFee_
    ) external;

//////////////////////////////////////// Settings
    function _editBCBOutFee(uint256 BCBOutFee_) external;

    function _editBCBFixedFee(uint256 BCBFixedFee_) external;

    function _editBCBFlexedFee(uint256 BCBFlexedFee_) external;

//////////////////////////////////////// Owner

    function getCurrency() external view returns (IERC20);

    function calculateStoragePrice(uint256 poolId, uint256 tokenId, bool withBCBOut) external view returns (uint256);

    function onMint(uint256 poolId, uint256 tokenId) external;

    function onOrderExecute(uint256 poolId, uint256 tokenId) external;

    function onRequestDelivery(uint256 poolId, uint256 tokenId) external;

//////////////////////////////////////// Owner

    function withdrawBCBFee(address to, uint256 amount) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../interfaces/IWineManager.sol";
import "../interfaces/IBordeauxCityBondIntegration.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract BordeauxCityBondTransferHelper
{
    using SafeERC20 for IERC20;

    function onOrderExecute(
        address manager,
        uint256 poolId,
        uint256 tokenId
    )
        internal
        returns (uint256 storagePrice)
    {
        IBordeauxCityBondIntegration bordeauxCityBond = __getIBordeauxCityBondIntegration(manager);
        storagePrice = bordeauxCityBond.calculateStoragePrice(poolId, tokenId, false);
        if (storagePrice > 0) {
            bordeauxCityBond.getCurrency().safeTransfer(address(bordeauxCityBond), storagePrice);
        }
    }

    function onRequestDelivery(
        address msgSender,
        address manager,
        uint256 poolId,
        uint256 tokenId
    )
        internal
        returns (uint256 storagePrice)
    {
        IBordeauxCityBondIntegration bordeauxCityBond = __getIBordeauxCityBondIntegration(manager);
        storagePrice = bordeauxCityBond.calculateStoragePrice(poolId, tokenId, true);

        if (storagePrice > 0 && msgSender != address(0)) {
            bordeauxCityBond.getCurrency().safeTransferFrom(msgSender, address(bordeauxCityBond), storagePrice);
        }
    }

    function __getIBordeauxCityBondIntegration(address manager)
        private
        view
        returns (IBordeauxCityBondIntegration)
    {
        return IBordeauxCityBondIntegration(IWineManager(manager).bordeauxCityBond());
    }


}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}