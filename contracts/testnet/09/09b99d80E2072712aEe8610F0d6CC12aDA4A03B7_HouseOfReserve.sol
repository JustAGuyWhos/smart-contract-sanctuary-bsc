// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

/**
 * @title The house of reserves contract.
 * @author daigaro.eth
 * @notice Custodies all deposits, to allow minting of the backedAsset.
 * @notice Users can only deposit and withdraw from this contract.
 * @dev  Contracts are split into state and functionality.
 * @dev A HouseOfReserve is required to back a specific backedAsset.
 */

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IAssetsAccountant.sol";
import "./abstract/OracleHouse.sol";

contract HouseOfReserveState {
    // HouseOfReserve Events

    /**
     * @dev Emit when user makes an asset deposit in this contract.
     * @param user Address of depositor.
     * @param asset ERC20 address of the reserve asset.
     * @param amount deposited.
     */
    event UserDeposit(
        address indexed user,
        address indexed asset,
        uint256 amount
    );
    /**
     * @dev Emit when user makes an asset withdrawal from this HouseOfReserve
     * @param user Address of user withdrawing.
     * @param asset ERC20 address of the reserve asset.
     * @param amount withraw.
     */
    event UserWithdraw(
        address indexed user,
        address indexed asset,
        uint256 amount
    );
    /**
     * @dev Emit when user DEFAULT_ADMIN changes the collateralization factor of this HouseOfReserve
     * @param newFactor New struct indicating the factor values.
     */
    event CollateralRatioChanged(Factor newFactor);
    /**
     * @dev Emit when user DEFAULT_ADMIN changes the 'depositLimit' of HouseOfReserve
     * @param newLimit uint256
     */
    event DepositLimitChanged(uint256 newLimit);

    struct Factor {
        uint256 numerator;
        uint256 denominator;
    }

    address public WETH;

    address public reserveAsset;

    address public backedAsset;

    uint256 public reserveTokenID;

    uint256 public backedTokenID;

    Factor public collateralRatio;

    uint256 public totalDeposits;

    uint256 public depositLimit;

    IAssetsAccountant public assetsAccountant;

    bytes32 public constant HOUSE_TYPE = keccak256("RESERVE_HOUSE");
}

contract HouseOfReserve is
    Initializable,
    AccessControl,
    OracleHouse,
    HouseOfReserveState
{
    /**
     * @dev Initializes this contract by setting:
     * @param _reserveAsset ERC20 address of reserve asset handled in this contract.
     * @param _backedAsset ERC20 address of the asset type of coin that can be backed with this reserves.
     * @param _assetsAccountant Address of the {AssetsAccountant} contract.
     */
    function initialize(
        address _reserveAsset,
        address _backedAsset,
        address _assetsAccountant,
        string memory tickerUsdFiat_,
        string memory tickerReserveAsset_,
        address _WETH
    ) public initializer {
        reserveAsset = _reserveAsset;
        backedAsset = _backedAsset;
        WETH = _WETH;
        reserveTokenID = uint256(
            keccak256(abi.encodePacked(reserveAsset, backedAsset, "collateral"))
        );
        backedTokenID = uint256(
            keccak256(
                abi.encodePacked(reserveAsset, backedAsset, "backedAsset")
            )
        );
        collateralRatio.numerator = 150;
        collateralRatio.denominator = 100;
        assetsAccountant = IAssetsAccountant(_assetsAccountant);
        _oracleHouse_init();
        _setTickers(tickerUsdFiat_, tickerReserveAsset_);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /** see {OracleHouse-activeOracle}*/
    function activeOracle() external view override returns (uint256) {
        return _activeOracle;
    }

    /**
     * @notice  See '_setActiveOracle()' in {OracleHouse}.
     * @dev restricted to admin only.
     */
    function setActiveOracle(OracleIds id_)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setActiveOracle(id_);
    }

    /**
     * @notice  See '_setTickers()' in {OracleHouse}.
     * @dev restricted to admin only.
     */
    function setTickers(
        string memory tickerUsdFiat_,
        string memory tickerReserveAsset_
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTickers(tickerUsdFiat_, tickerReserveAsset_);
    }

    /**
     * @notice  See '_authorizeSigner()' in {OracleHouse}
     * @dev  Restricted to admin only.
     */
    function authorizeSigner(address newtrustedSigner)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _authorizeSigner(newtrustedSigner);
    }

    /**
     * @notice  See '_setUMAOracleHelper()' in {OracleHouse}
     * @dev  Restricted to admin only.
     */
    function setUMAOracleHelper(address newAddress)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setUMAOracleHelper(newAddress);
    }

    /**
     * @notice  See '_setChainlinkAddrs()' in {OracleHouse}
     * @dev  Restricted to admin only.
     */
    function setChainlinkAddrs(address addrUsdFiat_, address addrReserveAsset_)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setChainlinkAddrs(addrUsdFiat_, addrReserveAsset_);
    }

    /**
     * @dev Call latest price according to activeOracle
     * @dev See _getLatestPrice() in {OracleHouse}.
     * @dev override _getLatestPrice() as required.
     */
    function getLatestPrice() public view returns (uint256 price) {
        price = _getLatestPrice(address(0));
    }

    /**
     * @notice Function to deposit reserves in this contract.
     * @notice DO NOT!! send direct ERC20 transfers to this contract.
     * @dev Requires user's ERC20 approval prior to calling.
     * @param amount To deposit.
     * Emits a {UserDeposit} event.
     */
    function deposit(uint256 amount) public {
        // Validate input amount.
        require(amount > 0, "Zero input amount!");

        // Check ERC20 approval of msg.sender.
        require(
            IERC20(reserveAsset).allowance(msg.sender, address(this)) >= amount,
            "Not enough ERC20 allowance!"
        );
        // Check that deposit limit for this reserve has not been reached.
        require(
            amount + totalDeposits <= depositLimit,
            "Deposit limit reached!"
        );

        // Transfer reserveAsset amount to this contract.
        IERC20(reserveAsset).transferFrom(msg.sender, address(this), amount);

        // Continue deposit in internal function
        _deposit(msg.sender, amount);
    }

    /**
     * @notice Function to withdraw reserves in this contract.
     * @dev Function checks if user can withdraw specified amount.
     * @param amount To withdraw.
     * Emits a {UserWitdhraw} event.
     */
    function withdraw(uint256 amount) public {
        uint256 price = getLatestPrice();
        _withdraw(amount, price);
    }

    /**
     * @notice Function to set the collateralization ration of this contract.
     * @dev Numerator and denominator should be > 0, and numerator > denominator
     * @param numerator of new collateralization factor.
     * @param denominator of new collateralization factor.
     * Emits a {CollateralRatioChanged} event.
     */
    function setCollateralRatio(uint256 numerator, uint256 denominator)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // Check inputs
        require(
            numerator > 0 && denominator > 0 && numerator > denominator,
            "Invalid inputs!"
        );

        // Set new collateralization ratio
        collateralRatio.numerator = numerator;
        collateralRatio.denominator = denominator;

        // Emit event
        emit CollateralRatioChanged(collateralRatio);
    }

    /**
     * @notice Function to set the limit of deposits in this HouseOfReserve.
     * @param newLimit uint256, must be greater than zero.
     * Emits a {DepositLimitChanged} event.
     */
    function setDepositLimit(uint256 newLimit)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newLimit > 0, "Invalid inputs!");
        depositLimit = newLimit;
        emit DepositLimitChanged(newLimit);
    }

    /**
     * @notice Function to calculate the max reserves user can withdraw from contract.
     * @param user Address to check.
     */
    function checkMaxWithdrawal(address user)
        external
        view
        returns (uint256 max)
    {
        uint256 price = getLatestPrice();
        // Need balances for tokenIDs of both reserves and backed asset in {AssetsAccountant}
        (uint256 reserveBal, uint256 mintedCoinBal) = _checkBalances(
            user,
            reserveTokenID,
            backedTokenID
        );
        max = reserveBal == 0
            ? 0
            : _checkMaxWithdrawal(reserveBal, mintedCoinBal, price);
    }

    /**
     * @dev  Internal function to withdrawal an amount given oracle price.
     */
    function _withdraw(uint256 amount, uint256 price) internal {
        // Need balances for tokenIDs of both reserves and backed asset in {AssetsAccountant}
        (uint256 reserveBal, uint256 mintedCoinBal) = _checkBalances(
            msg.sender,
            reserveTokenID,
            backedTokenID
        );

        // Validate user has reserveBal, and input amount is greater than zero, and less than msg.sender reserves deposits.
        require(
            reserveBal > 0 && amount > 0 && amount <= reserveBal,
            "Invalid input amount!"
        );

        // Get max withdrawal amount
        uint256 maxWithdrawal = _checkMaxWithdrawal(
            reserveBal,
            mintedCoinBal,
            price
        );

        // Check maxWithdrawal is greater than or equal to the withdraw amount.
        require(maxWithdrawal >= amount, "Invalid input amount!");

        // Burn at AssetAccountant withdrawal amount.
        assetsAccountant.burn(msg.sender, reserveTokenID, amount);

        // Transfer Asset to msg.sender
        IERC20(reserveAsset).transfer(msg.sender, amount);

        // Emit withdraw event.
        emit UserWithdraw(msg.sender, reserveAsset, amount);
    }

    // Internal Functions

    /**
     * @dev Internal function that completes the 'deposit' function.
     */
    function _deposit(address user, uint256 amount) internal {
        // Mint in AssetsAccountant received amount.
        assetsAccountant.mint(user, reserveTokenID, amount, "");

        // Increase totalDeposits
        totalDeposits += amount;

        // Emit deposit event.
        emit UserDeposit(user, reserveAsset, amount);
    }

    /**
     * @dev  Internal function to check max withdrawal amount.
     */
    function _checkMaxWithdrawal(
        uint256 _reserveBal,
        uint256 _mintedCoinBal,
        uint256 price
    ) internal view returns (uint256) {
        // Check if msg.sender has minted backedAsset, if yes compute:
        // The minimum required balance to back 100% all minted coins of backedAsset.
        // Else, return 0.
        uint256 minReqReserveBal = _mintedCoinBal > 0
            ? (_mintedCoinBal * 1e8) / price
            : 0;

        // Apply Collateralization Factors to MinReqReserveBal
        minReqReserveBal =
            (minReqReserveBal * collateralRatio.numerator) /
            collateralRatio.denominator;

        if (minReqReserveBal > _reserveBal) {
            // Return zero if undercollateralized or insolvent
            return 0;
        } else if (minReqReserveBal > 0 && minReqReserveBal <= _reserveBal) {
            // Return the max withrawal amount, if msg.sender has mintedCoin balance and in healthy collateralized
            return (_reserveBal - minReqReserveBal);
        } else {
            // Return _reserveBal if msg.sender has no minted coin.
            return _reserveBal;
        }
    }

    /**
     * @dev  Internal function to query balances in {AssetsAccountant}
     */
    function _checkBalances(
        address user,
        uint256 _reservesTokenID,
        uint256 _bAssetRTokenID
    ) internal view returns (uint256 reserveBal, uint256 mintedCoinBal) {
        reserveBal = IERC1155(address(assetsAccountant)).balanceOf(
            user,
            _reservesTokenID
        );
        mintedCoinBal = IERC1155(address(assetsAccountant)).balanceOf(
            user,
            _bAssetRTokenID
        );
    }

    /**
     * @dev  Handle direct sending of native-token.
     */
    receive() external payable {
        uint256 preBalance = IERC20(WETH).balanceOf(address(this));
        if (reserveAsset == WETH) {
            // Check that deposit limit for this reserve has not been reached.
            require(
                msg.value + totalDeposits <= depositLimit,
                "Deposit limit reached!"
            );
            IWETH(WETH).deposit{value: msg.value}();
            require(
                IERC20(WETH).balanceOf(address(this)) == preBalance + msg.value,
                "deposit failed!"
            );
            _deposit(msg.sender, msg.value);
        } else {
            revert("Wrong reserveAsset!");
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IAssetsAccountant is IERC1155 {
    
    /**
     * @dev Registers a HouseOfReserve or HouseOfCoinMinting contract address in AssetsAccountant.
     * grants MINTER_ROLE and BURNER_ROLE to House
     * Requirements:
     * - the caller must have ADMIN_ROLE.
     */
    function registerHouse(address houseAddress, address asset) external;
    
    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     * See {ERC1155-_mint}.
     * Requirements:
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

    /**
     * @dev Burns `amount` of tokens from `to`, of token type `id`.
     * See {ERC1155-_burn}.
     * Requirements:
     * - the caller must have the `BURNER_ROLE`.
     */
    function burn(address account, uint256 id, uint256 value) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {burn}.
     */
    function burnBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;



}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "../utils/redstone/PriceAware.sol";
import "../interfaces/chainlink/IAggregatorV3.sol";
import "../utils/uma/UMAOracleHelper.sol";
import "../interfaces/uma/IOptimisticOracleV2.sol";

abstract contract OracleHouse is PriceAware {
    /**
     * @dev emitted after activeOracle is changed.
     * @param newOracleNumber uint256 oracle id.
     **/
    event ActiveOracleChanged(uint256 newOracleNumber);

    /// Custom errors

    /** Wrong or invalid input*/
    error OracleHouse_invalidInput();

    /** Not initialized*/
    error OracleHouse_notInitialized();

    /** No valid value returned*/
    error OracleHouse_noValue();

    enum OracleIds {
        redstone,
        uma,
        chainlink
    }

    /** @dev OracleIds: 0 = redstone, 1 = uma, 2 = chainlink */
    uint256 internal _activeOracle;

    /// redstone required state variables
    bytes32 private _tickerUsdFiat;
    bytes32 private _tickerReserveAsset;
    bytes32[] private _tickers;
    address private _trustedSigner;

    /// uma required state variables
    UMAOracleHelper private _umaOracleHelper;

    /// chainlink required state variables
    IAggregatorV3 private _addrUsdFiat;
    IAggregatorV3 private _addrReserveAsset;

    // solhint-disable-next-line func-name-mixedcase
    function _oracleHouse_init() internal {
        _oracle_redstone_init();
    }

    /**
     * @notice Returns the active oracle from House of Reserve.
     * @dev Must be implemented in House Of Reserve ONLY.
     */
    function activeOracle() external view virtual returns (uint256);

    /** @dev Override for House of Coin with called inputs from House Of Reserve. */
    function _getLatestPrice(address)
        internal
        view
        virtual
        returns (uint256 price)
    {
        if (_activeOracle == 0) {
            price = _getLatestPriceRedstone(_tickers);
        } else if (_activeOracle == 1) {
            price = _getLatestPriceUMA();
        } else if (_activeOracle == 2) {
            price = _getLatestPriceChainlink(_addrUsdFiat, _addrReserveAsset);
        }
    }

    /**
     * @dev Must be implemented in House of Reserve ONLY with admin restriction and call _setActiveOracle().
     * Must call _setActiveOracle().
     */
    function setActiveOracle(OracleIds id_) external virtual;

    /**
     * @notice Sets the activeOracle.
     * @dev  Restricted to admin only.
     * @param id_ restricted to enum OracleIds
     * Emits a {ActiveOracleChanged} event.
     */

    function _setActiveOracle(OracleIds id_) internal {
        _activeOracle = uint256(id_);
        emit ActiveOracleChanged(_activeOracle);
    }

    ///////////////////////////////
    /// Redstone oracle methods ///
    ///////////////////////////////

    /**
     * @dev emitted after the owner updates trusted signer
     * @param newSigner the address of the new signer
     **/
    event TrustedSignerChanged(address newSigner);

    /**
     * @dev emitted after tickers for Redstone-evm-connector change.
     * @param newtickerUsdFiat short string
     * @param newtickerReserveAsset short string
     **/
    event TickersChanged(
        bytes32 newtickerUsdFiat,
        bytes32 newtickerReserveAsset
    );

    // solhint-disable-next-line func-name-mixedcase
    function _oracle_redstone_init() private {
        _tickers.push(bytes32(0));
        _tickers.push(bytes32(0));
    }


    /**
     * Returns price in 8 decimal places.
     */
    function _getLatestPriceRedstone(bytes32[] memory tickers_)
        internal
        view
        virtual
        returns (uint256 price)
    {
        uint256[] memory oraclePrices = _getPricesFromMsg(tickers_);
        uint256 usdfiat = oraclePrices[0];
        uint256 usdReserveAsset = oraclePrices[1];
        if (usdfiat == 0 || usdReserveAsset == 0) {
            revert OracleHouse_noValue();
        }
        price = (usdReserveAsset * 1e8) / usdfiat;
    }

    /**
     * @notice Returns the state data of Redstone oracle.
     */
    function getRedstoneData()
        external
        view
        virtual
        returns (
            bytes32 tickerUsdFiat_,
            bytes32 tickerReserveAsset_,
            bytes32[] memory tickers_,
            address trustedSigner_
        )
    {
        tickerUsdFiat_ = _tickerUsdFiat;
        tickerReserveAsset_ = _tickerReserveAsset;
        tickers_ = _tickers;
        trustedSigner_ = _trustedSigner;
    }

    /**
     * @notice Checks that signer is authorized
     * @dev  Required by Redstone-evm-connector.
     * @param _receviedSigner address
     */
    function isSignerAuthorized(address _receviedSigner)
        public
        view
        override
        returns (bool)
    {
        return _receviedSigner == _trustedSigner;
    }

    /**
     * @dev See '_setTickers()'.
     * Must be implemented in House of Reserve ONLY with admin restriction.
     * Must call _setTickers().
     */
    function setTickers(
        string calldata tickerUsdFiat_,
        string calldata tickerReserveAsset_
    ) external virtual;

    /**
     * @notice  Sets the tickers required in '_getLatestPriceRedstone()'.
     * @param tickerUsdFiat_ short string (less than 32 characters)
     * @param tickerReserveAsset_ short string (less than 32 characters)
     * Emits a {TickersChanged} event.
     */
    function _setTickers(
        string memory tickerUsdFiat_,
        string memory tickerReserveAsset_
    ) internal {
        if (_tickers.length != 2) {
            revert OracleHouse_notInitialized();
        }
        bytes32 ticker1;
        bytes32 ticker2;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ticker1 := mload(add(tickerUsdFiat_, 32))
            ticker2 := mload(add(tickerReserveAsset_, 32))
        }
        _tickerUsdFiat = ticker1;
        _tickerReserveAsset = ticker2;

        _tickers[0] = _tickerUsdFiat;
        _tickers[1] = _tickerReserveAsset;

        emit TickersChanged(_tickerUsdFiat, _tickerReserveAsset);
    }

    /**
     * @dev See '_setTickers()'.
     * Must be implemented both in House of Reserve and Coin with admin restriction.
     */
    function authorizeSigner(address _trustedSigner) external virtual;

    /**
     * @notice  Authorize signer for price feed provider.
     * @dev  Restricted to admin only. Function required by Redstone-evm-connector.
     * @param newtrustedSigner address
     * Emits a {TrustedSignerChanged} event.
     */
    function _authorizeSigner(address newtrustedSigner) internal {
        if (newtrustedSigner == address(0)) {
            revert OracleHouse_invalidInput();
        }
        _trustedSigner = newtrustedSigner;
        emit TrustedSignerChanged(_trustedSigner);
    }

    //////////////////////////
    /// UMA oracle methods ///
    //////////////////////////

    /**
     * @dev emitted after the address for UMAHelper changes
     * @param newAddress of UMAHelper
     **/
    event UMAHelperAddressChanged(address newAddress);


    /**
     * Returns price in 8 decimal places.
     */
    function _getLatestPriceUMA() internal view returns (uint256 price) {
        price = _umaOracleHelper.getLastRequest(address(_addrReserveAsset));
    }

    /**
     * @dev See '_setUMAOracleHelper()'.
     * Must be implemented in House of Reserve with admin restriction.
     */
    function setUMAOracleHelper(address newAddress) external virtual;

    /**
     * @notice Sets a new address for the UMAOracleHelper
     * @dev Restricted to admin only.
     * @param newAddress for UMAOracleHelper.
     * Emits a {UMAHelperAddressChanged} event.
     */
    function _setUMAOracleHelper(address newAddress) internal {
        if (newAddress == address(0)) {
            revert OracleHouse_invalidInput();
        }
        _umaOracleHelper = UMAOracleHelper(newAddress);
        emit UMAHelperAddressChanged(newAddress);
    }

    ////////////////////////////////
    /// Chainlink oracle methods ///
    ////////////////////////////////

    /**
     * @dev emitted after chainlink addresses change.
     * @param _newAddrUsdFiat from chainlink.
     * @param _newAddrReserveAsset from chainlink.
     **/
    event ChainlinkAddressChange(
        address _newAddrUsdFiat,
        address _newAddrReserveAsset
    );


    /**
     * Returns price in 8 decimal places.
     */
    function _getLatestPriceChainlink(
        IAggregatorV3 addrUsdFiat_,
        IAggregatorV3 addrReserveAsset_
    ) internal view returns (uint256 price) {
        if (
            address(addrUsdFiat_) == address(0) ||
            address(addrReserveAsset_) == address(0)
        ) {
            revert OracleHouse_notInitialized();
        }
        (, int256 usdfiat, , , ) = addrUsdFiat_.latestRoundData();
        (, int256 usdreserve, , , ) = addrReserveAsset_.latestRoundData();
        if (usdfiat <= 0 || usdreserve <= 0) {
            revert OracleHouse_noValue();
        }
        price = (uint256(usdreserve) * 1e8) / uint256(usdfiat);
    }

    /**
     * @notice Returns the state data of Chainlink oracle.
     */
    function getChainlinkData()
        external
        view
        virtual
        returns (address addrUsdFiat_, address addrReserveAsset_)
    {
        addrUsdFiat_ = address(_addrUsdFiat);
        addrReserveAsset_ = address(_addrReserveAsset);
    }

    /**
     * @dev Must be implemented with admin restriction and call _setChainlinkAddrs().
     */
    function setChainlinkAddrs(address addrUsdFiat_, address addrReserveAsset_)
        external
        virtual;

    /**
     * @notice  Sets the chainlink addresses required in '_getLatestPriceChainlink()'.
     * @param addrUsdFiat_ address from chainlink.
     * @param addrReserveAsset_ address from chainlink.
     * Emits a {ChainlinkAddressChange} event.
     */
    function _setChainlinkAddrs(address addrUsdFiat_, address addrReserveAsset_)
        internal
    {
        if (addrUsdFiat_ == address(0) || addrReserveAsset_ == address(0)) {
            revert OracleHouse_invalidInput();
        }
        _addrUsdFiat = IAggregatorV3(addrUsdFiat_);
        _addrReserveAsset = IAggregatorV3(addrReserveAsset_);
        emit ChainlinkAddressChange(addrUsdFiat_, addrReserveAsset_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

/// Contract taken from redstone-evm-connector package; 
/// Refer to: https://github.com/redstone-finance/redstone-evm-connector
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract PriceAware {
  using ECDSA for bytes32;

  uint256 constant internal _MAX_DATA_TIMESTAMP_DELAY = 3 * 60; // 3 minutes
  uint256 constant internal _MAX_BLOCK_TIMESTAMP_DELAY = 15; // 15 seconds

  /* ========== VIRTUAL FUNCTIONS (MAY BE OVERRIDEN IN CHILD CONTRACTS) ========== */

  function getMaxDataTimestampDelay() public virtual view returns (uint256) {
    return _MAX_DATA_TIMESTAMP_DELAY;
  }

  function getMaxBlockTimestampDelay() public virtual view returns (uint256) {
    return _MAX_BLOCK_TIMESTAMP_DELAY;
  }

  function isSignerAuthorized(address _receviedSigner) public virtual view returns (bool);

  function isTimestampValid(uint256 _receivedTimestamp) public virtual view returns (bool) {
    // Getting data timestamp from future seems quite unlikely
    // But we've already spent too much time with different cases
    // Where block.timestamp was less than dataPackage.timestamp.
    // Some blockchains may case this problem as well.
    // That's why we add MAX_BLOCK_TIMESTAMP_DELAY
    // and allow data "from future" but with a small delay
    
    require(
      (block.timestamp + getMaxBlockTimestampDelay()) > _receivedTimestamp,
      "Data with future timestamps is not allowed");

    return block.timestamp < _receivedTimestamp
      || block.timestamp - _receivedTimestamp < getMaxDataTimestampDelay();
  }

  /* ========== FUNCTIONS WITH IMPLEMENTATION (CAN NOT BE OVERRIDEN) ========== */

  function _getPriceFromMsg(bytes32 symbol) internal view returns (uint256) {bytes32[] memory symbols = new bytes32[](1); symbols[0] = symbol;
    return _getPricesFromMsg(symbols)[0];
  }

  function _getPricesFromMsg(bytes32[] memory symbols) internal view returns (uint256[] memory) {
    // The structure of calldata witn n - data items:
    // The data that is signed (symbols, values, timestamp) are inside the {} brackets
    // [origina_call_data| ?]{[[symbol | 32][value | 32] | n times][timestamp | 32]}[size | 1][signature | 65]

    // 1. First we extract dataSize - the number of data items (symbol,value pairs) in the message
    uint8 dataSize; //Number of data entries
    // solhint-disable-next-line
    assembly {
      // Calldataload loads slots of 32 bytes
      // The last 65 bytes are for signature
      // We load the previous 32 bytes and automatically take the 2 least significant ones (casting to uint16)
      dataSize := calldataload(sub(calldatasize(), 97))
    }

    // 2. We calculate the size of signable message expressed in bytes
    // ((symbolLen(32) + valueLen(32)) * dataSize + timeStamp length
    uint16 messageLength = uint16(dataSize) * 64 + 32; //Length of data message in bytes

    // 3. We extract the signableMessage

    // (That's the high level equivalent 2k gas more expensive)
    // bytes memory rawData = msg.data.slice(msg.data.length - messageLength - 65, messageLength);

    bytes memory signableMessage;
    // solhint-disable-next-line
    assembly {
      signableMessage := mload(0x40)
      mstore(signableMessage, messageLength)
      // The starting point is callDataSize minus length of data(messageLength), signature(65) and size(1) = 66
      calldatacopy(
        add(signableMessage, 0x20),
        sub(calldatasize(), add(messageLength, 66)),
        messageLength
      )
      mstore(0x40, add(signableMessage, 0x20))
    }

    // 4. We first hash the raw message and then hash it again with the prefix
    // Following the https://github.com/ethereum/eips/issues/191 standard
    bytes32 hash = keccak256(signableMessage);
    bytes32 hashWithPrefix = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );

    // 5. We extract the off-chain signature from calldata

    // (That's the high level equivalent 2k gas more expensive)
    // bytes memory signature = msg.data.slice(msg.data.length - 65, 65);
    bytes memory signature;
    // solhint-disable-next-line
    assembly {
      signature := mload(0x40)
      mstore(signature, 65)
      calldatacopy(add(signature, 0x20), sub(calldatasize(), 65), 65)
      mstore(0x40, add(signature, 0x20))
    }

    // 6. We verify the off-chain signature against on-chain hashed data

    address signer = hashWithPrefix.recover(signature);
    require(isSignerAuthorized(signer), "Signer not authorized");

    // 7. We extract timestamp from callData

    uint256 dataTimestamp;
    // solhint-disable-next-line
    assembly {
      // Calldataload loads slots of 32 bytes
      // The last 65 bytes are for signature + 1 for data size
      // We load the previous 32 bytes
      dataTimestamp := calldataload(sub(calldatasize(), 98))
    }

    // 8. We validate timestamp
    //require(isTimestampValid(dataTimestamp), "Data timestamp is invalid");

    return _readFromCallData(symbols, uint256(dataSize), messageLength);
  }

  function _readFromCallData(bytes32[] memory symbols, uint256 dataSize, uint16 messageLength) private pure returns (uint256[] memory) {
    uint256[] memory values;
    uint256 i;
    uint256 j;
    uint256 readyAssets;
    bytes32 currentSymbol;

    // We iterate directly through call data to extract the values for symbols
    // solhint-disable-next-line
    assembly {
      let start := sub(calldatasize(), add(messageLength, 66))

      values := msize()
      mstore(values, mload(symbols))
      mstore(0x40, add(add(values, 0x20), mul(mload(symbols), 0x20)))

      for { i := 0 } lt(i, dataSize) { i := add(i, 1) } {
        currentSymbol := calldataload(add(start, mul(i, 64)))

        for { j := 0 } lt(j, mload(symbols)) { j := add(j, 1) } {
          if eq(mload(add(add(symbols, 32), mul(j, 32))), currentSymbol) {
            mstore(
              add(add(values, 32), mul(j, 32)),
              calldataload(add(add(start, mul(i, 64)), 32))
            )
            readyAssets := add(readyAssets, 1)
          }

          if eq(readyAssets, mload(symbols)) {
            i := dataSize
          }
        }
      }
    }

    return (values);
  }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.9;

interface IAggregatorV3 {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "../../interfaces/uma/IOptimisticOracleV2.sol";
import "../../interfaces/uma/IdentifierWhitelistInterface.sol";
import "../../interfaces/uma/IUMAFinder.sol";
import "../../interfaces/uma/IAddressWhitelist.sol";
import "./UMAOracleInterfaces.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/chainlink/IAggregatorV3.sol";

contract UMAOracleHelper {
    /**
     * @dev emitted after the {acceptableUMAPriceObsolence} changes
     * @param newTime of acceptable UMA price obsolence
     **/
    event AcceptableUMAPriceTimeChange(uint256 newTime);

    struct LastRequest {
        uint256 timestamp;
        IOptimisticOracleV2.State state;
        uint256 resolvedPrice;
        address proposer;
    }

    // Finder for UMA contracts.
    IUMAFinder public finder;

    // Unique identifier for price feed ticker.
    bytes32 private priceIdentifier;

    // The collateral currency used to back the positions in this contract.
    IERC20 public stakeCollateralCurrency;
    
    uint256 public acceptableUMAPriceObselence;

    LastRequest internal _lastRequest;

    constructor(
        address _stakeCollateralCurrency,
        address _finderAddress,
        bytes32 _priceIdentifier,
        uint256 _acceptableUMAPriceObselence
    ) {
        finder = IUMAFinder(_finderAddress);
        require(
            _getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier),
            "Unsupported price identifier"
        );
        require(
            _getAddressWhitelist().isOnWhitelist(_stakeCollateralCurrency),
            "Unsupported collateral type"
        );
        stakeCollateralCurrency = IERC20(_stakeCollateralCurrency);
        priceIdentifier = _priceIdentifier;
        setAcceptableUMAPriceObsolence(_acceptableUMAPriceObselence);
    }

    /**
     * Returns computed price in 8 decimal places.
     * @dev Requires chainlink price feed address for reserve asset.
     * Requires:
     * - price settled time is not greater than acceptableUMAPriceObselence.
     * - last request proposed price is settled according to UMA process: 
     *   https://docs.umaproject.org/protocol-overview/how-does-umas-oracle-work
     */
    function getLastRequest(address addrChainlinkReserveAsset_)
        external
        view
        returns (
            uint256 computedPrice
        )
    {
        uint256 priceObsolence = block.timestamp > _lastRequest.timestamp
            ? block.timestamp - _lastRequest.timestamp
            : type(uint256).max;
        require(_lastRequest.state == IOptimisticOracleV2.State.Settled, "Not settled!");
        require(
            priceObsolence < acceptableUMAPriceObselence,
            "Price too old!"
        );
        (, int256 usdreserve, , , ) = IAggregatorV3(addrChainlinkReserveAsset_).latestRoundData();
        computedPrice = uint256(usdreserve) * 1e18  / _lastRequest.resolvedPrice;
    }

    // Requests a price for `priceIdentifier` at `requestedTime` from the Optimistic Oracle.
    function requestPrice() external {
        _checkLastRequest();

        uint256 requestedTime = block.timestamp;
        IOptimisticOracleV2 oracle = _getOptimisticOracle();
        oracle.requestPrice(
            priceIdentifier,
            requestedTime,
            "",
            IERC20(stakeCollateralCurrency),
            0
        );
        _resetLastRequest(requestedTime, IOptimisticOracleV2.State.Requested);
    }

    function requestPriceWithReward(uint256 rewardAmount) external {
        _checkLastRequest();
        require(
            stakeCollateralCurrency.allowance(msg.sender, address(this)) >=
                rewardAmount,
            "No erc20-approval"
        );
        IOptimisticOracleV2 oracle = _getOptimisticOracle();

        stakeCollateralCurrency.approve(address(oracle), rewardAmount);

        uint256 requestedTime = block.timestamp;

        oracle.requestPrice(
            priceIdentifier,
            requestedTime,
            "",
            IERC20(stakeCollateralCurrency),
            rewardAmount
        );

        _resetLastRequest(requestedTime, IOptimisticOracleV2.State.Requested);
    }

    function setCustomLivenessLastRequest(uint256 time) external {
        IOptimisticOracleV2 oracle = _getOptimisticOracle();
        oracle.setCustomLiveness(
            priceIdentifier,
            _lastRequest.timestamp,
            "",
            time
        );
    }

    function changeBondLastPriceRequest(uint256 bond) external {
        IOptimisticOracleV2 oracle = _getOptimisticOracle();
        oracle.setBond(priceIdentifier, _lastRequest.timestamp, "", bond);
    }

    function computeTotalBondLastRequest()
        public
        view
        returns (uint256 totalBond)
    {
        IOptimisticOracleV2 oracle = _getOptimisticOracle();
        IOptimisticOracleV2.Request memory request = oracle.getRequest(
            address(this),
            priceIdentifier,
            _lastRequest.timestamp,
            ""
        );
        totalBond = request.requestSettings.bond + request.finalFee;
    }

    /**
     * @dev Proposed price should be in 18 decimals per specification: 
     * https://github.com/UMAprotocol/UMIPs/blob/master/UMIPs/umip-139.md
     */
    function proposePriceLastRequest(uint256 proposedPrice) external {
        uint256 totalBond = computeTotalBondLastRequest();
        require(
            stakeCollateralCurrency.allowance(msg.sender, address(this)) >=
                totalBond,
            "No allowance for propose bond"
        );
        stakeCollateralCurrency.transferFrom(msg.sender, address(this), totalBond);
        IOptimisticOracleV2 oracle = _getOptimisticOracle();
        stakeCollateralCurrency.approve(address(oracle), totalBond);
        oracle.proposePrice(
            address(this),
            priceIdentifier,
            _lastRequest.timestamp,
            "",
            int256(proposedPrice)
        );
        _lastRequest.proposer = msg.sender;
        _lastRequest.state = IOptimisticOracleV2.State.Proposed;
    }

    function settleLastRequestAndGetPrice() external returns (uint256 price) {
        IOptimisticOracleV2 oracle = _getOptimisticOracle();
        int256 settledPrice = oracle.settleAndGetPrice(
            priceIdentifier,
            _lastRequest.timestamp, 
            ""
        );
        require(settledPrice > 0, "Settle Price Error!");
        _lastRequest.resolvedPrice = uint256(settledPrice);
        _lastRequest.state = IOptimisticOracleV2.State.Settled;
        stakeCollateralCurrency.transfer(
            _lastRequest.proposer,
            computeTotalBondLastRequest()
        );
        price = uint256(settledPrice);
    }

    /**
     * @notice Sets a new acceptable UMA price feed obsolence time.
     * @dev Restricted to admin only.
     * @param _newTime for acceptable UMA price feed obsolence.
     * Emits a {AcceptableUMAPriceTimeChange} event.
     */
    function setAcceptableUMAPriceObsolence(uint256 _newTime) public {
        if (_newTime < 10 minutes) {
            // NewTime is too small
            revert("Invalid input");
        }
        acceptableUMAPriceObselence = _newTime;
        emit AcceptableUMAPriceTimeChange(_newTime);
    }

    function _checkLastRequest() internal view {
        if (_lastRequest.timestamp != 0) {
            require(
                _lastRequest.state == IOptimisticOracleV2.State.Settled,
                "Last request not settled!"
            );
        }
    }

    function _resetLastRequest(
        uint256 requestedTime,
        IOptimisticOracleV2.State state
    ) internal {
        _lastRequest.timestamp = requestedTime;
        _lastRequest.state = state;
        _lastRequest.resolvedPrice = 0;
        _lastRequest.proposer = address(0);
    }

    function _getIdentifierWhitelist()
        internal
        view
        returns (IdentifierWhitelistInterface)
    {
        return
            IdentifierWhitelistInterface(
                finder.getImplementationAddress(
                    UMAOracleInterfaces.IdentifierWhitelist
                )
            );
    }

    function _getAddressWhitelist() internal view returns (IAddressWhitelist) {
        return
            IAddressWhitelist(
                finder.getImplementationAddress(
                    UMAOracleInterfaces.CollateralWhitelist
                )
            );
    }

    function _getOptimisticOracle()
        internal
        view
        returns (IOptimisticOracleV2)
    {
        return
            IOptimisticOracleV2(
                finder.getImplementationAddress("OptimisticOracleV2")
            );
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUMAFinder.sol";

/**
 * @title Simplified interface for UMA Optimistic V2 oracle interface.
 */
interface IOptimisticOracleV2 {
    // Struct representing the state of a price request.
    enum State {
        Invalid, // Never requested.
        Requested, // Requested, no other actions taken.
        Proposed, // Proposed, but not expired or disputed yet.
        Expired, // Proposed, not disputed, past liveness.
        Disputed, // Disputed, but no DVM price returned yet.
        Resolved, // Disputed and DVM price is available.
        Settled // Final price has been set in the contract (can get here from Expired or Resolved).
    }

    struct RequestSettings {
        bool eventBased; // True if the request is set to be event-based.
        bool refundOnDispute; // True if the requester should be refunded their reward on dispute.
        bool callbackOnPriceProposed; // True if callbackOnPriceProposed callback is required.
        bool callbackOnPriceDisputed; // True if callbackOnPriceDisputed callback is required.
        bool callbackOnPriceSettled; // True if callbackOnPriceSettled callback is required.
        uint256 bond; // Bond that the proposer and disputer must pay on top of the final fee.
        uint256 customLiveness; // Custom liveness value set by the requester.
    }

    // Struct representing a price request.
    struct Request {
        address proposer; // Address of the proposer.
        address disputer; // Address of the disputer.
        IERC20 currency; // ERC20 token used to pay rewards and fees.
        bool settled; // True if the request is settled.
        RequestSettings requestSettings; // Custom settings associated with a request.
        int256 proposedPrice; // Price that the proposer submitted.
        int256 resolvedPrice; // Price resolved once the request is settled.
        uint256 expirationTime; // Time at which the request auto-settles without a dispute.
        uint256 reward; // Amount of the currency to pay to the proposer on settlement.
        uint256 finalFee; // Final fee to pay to the Store upon request to the DVM.
    }

    function defaultLiveness() external view  returns (uint256);

    function finder() external view  returns (IUMAFinder);

    function getCurrentTime() external view  returns (uint256);

    /**
     * @notice Requests a new price.
     * @param identifier price identifier being requested.
     * @param timestamp timestamp of the price being requested.
     * @param ancillaryData ancillary data representing additional args being passed with the price request.
     * @param currency ERC20 token used for payment of rewards and fees. Must be approved for use with the DVM.
     * @param reward reward offered to a successful proposer. Will be pulled from the caller. Note: this can be 0,
     *               which could make sense if the contract requests and proposes the value in the same call or
     *               provides its own reward system.
     * @return totalBond default bond (final fee) + final fee that the proposer and disputer will be required to pay.
     * This can be changed with a subsequent call to setBond().
     */
    function requestPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward
    ) external  returns (uint256 totalBond);

    /**
     * @notice Set the proposal bond associated with a price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @param bond custom bond amount to set.
     * @return totalBond new bond + final fee that the proposer and disputer will be required to pay. This can be
     * changed again with a subsequent call to setBond().
     */
    function setBond(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 bond
    ) external  returns (uint256 totalBond);

    /**
     * @notice Sets the request to refund the reward if the proposal is disputed. This can help to "hedge" the caller
     * in the event of a dispute-caused delay. Note: in the event of a dispute, the winner still receives the other's
     * bond, so there is still profit to be made even if the reward is refunded.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     */
    function setRefundOnDispute(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external ;

    /**
     * @notice Sets a custom liveness value for the request. Liveness is the amount of time a proposal must wait before
     * being auto-resolved.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @param customLiveness new custom liveness.
     */
    function setCustomLiveness(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 customLiveness
    ) external ;

    /**
     * @notice Sets the request to be an "event-based" request.
     * @dev Calling this method has a few impacts on the request:
     *
     * 1. The timestamp at which the request is evaluated is the time of the proposal, not the timestamp associated
     *    with the request.
     *
     * 2. The proposer cannot propose the "too early" value (TOO_EARLY_RESPONSE). This is to ensure that a proposer who
     *    prematurely proposes a response loses their bond.
     *
     * 3. RefundoOnDispute is automatically set, meaning disputes trigger the reward to be automatically refunded to
     *    the requesting contract.
     *
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     */
    function setEventBased(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external ;

    /**
     * @notice Sets which callbacks should be enabled for the request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @param callbackOnPriceProposed whether to enable the callback onPriceProposed.
     * @param callbackOnPriceDisputed whether to enable the callback onPriceDisputed.
     * @param callbackOnPriceSettled whether to enable the callback onPriceSettled.
     */
    function setCallbacks(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        bool callbackOnPriceProposed,
        bool callbackOnPriceDisputed,
        bool callbackOnPriceSettled
    ) external ;

    /**
     * @notice Proposes a price value on another address' behalf. Note: this address will receive any rewards that come
     * from this proposal. However, any bonds are pulled from the caller.
     * @param proposer address to set as the proposer.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @param proposedPrice price being proposed.
     * @return totalBond the amount that's pulled from the caller's wallet as a bond. The bond will be returned to
     * the proposer once settled if the proposal is correct.
     */
    function proposePriceFor(
        address proposer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) external  returns (uint256 totalBond);

    /**
     * @notice Proposes a price value for an existing price request.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @param proposedPrice price being proposed.
     * @return totalBond the amount that's pulled from the proposer's wallet as a bond. The bond will be returned to
     * the proposer once settled if the proposal is correct.
     */
    function proposePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) external  returns (uint256 totalBond);

    /**
     * @notice Disputes a price request with an active proposal on another address' behalf. Note: this address will
     * receive any rewards that come from this dispute. However, any bonds are pulled from the caller.
     * @param disputer address to set as the disputer.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return totalBond the amount that's pulled from the caller's wallet as a bond. The bond will be returned to
     * the disputer once settled if the dispute was value (the proposal was incorrect).
     */
    function disputePriceFor(
        address disputer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external  returns (uint256 totalBond);

    /**
     * @notice Disputes a price value for an existing price request with an active proposal.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return totalBond the amount that's pulled from the disputer's wallet as a bond. The bond will be returned to
     * the disputer once settled if the dispute was valid (the proposal was incorrect).
     */
    function disputePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external  returns (uint256 totalBond);

    /**
     * @notice Retrieves a price that was previously requested by a caller. Reverts if the request is not settled
     * or settleable. Note: this method is not view so that this call may actually settle the price request if it
     * hasn't been settled.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return resolved price.
     */
    function settleAndGetPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external  returns (int256);

    /**
     * @notice Attempts to settle an outstanding price request. Will revert if it isn't settleable.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return payout the amount that the "winner" (proposer or disputer) receives on settlement. This amount includes
     * the returned bonds as well as additional rewards.
     */
    function settle(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external  returns (uint256 payout);

    /**
     * @notice Gets the current data structure containing all information about a price request.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return the Request data structure.
     */
    function getRequest(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external view  returns (Request memory);

    /**
     * @notice Returns the state of a price request.
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return the State enum value.
     */
    function getState(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external view  returns (State);

    /**
     * @notice Checks if a given request has resolved or been settled (i.e the optimistic oracle has a price).
     * @param requester sender of the initial price request.
     * @param identifier price identifier to identify the existing request.
     * @param timestamp timestamp to identify the existing request.
     * @param ancillaryData ancillary data of the price being requested.
     * @return true if price has resolved or settled, false otherwise.
     */
    function hasPrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external view  returns (bool);

    function stampAncillaryData(bytes memory ancillaryData, address requester)
        external
        view
        returns (bytes memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

/**
 * @title Interface for whitelists of supported identifiers that the oracle can provide prices for.
 */
interface IdentifierWhitelistInterface {
    /**
     * @notice Adds the provided identifier as a supported identifier.
     * @dev Price requests using this identifier will succeed after this call.
     * @param identifier bytes32 encoding of the string identifier. Eg: BTC/USD.
     */
    function addSupportedIdentifier(bytes32 identifier) external;

    /**
     * @notice Removes the identifier from the whitelist.
     * @dev Price requests using this identifier will no longer succeed after this call.
     * @param identifier bytes32 encoding of the string identifier. Eg: BTC/USD.
     */
    function removeSupportedIdentifier(bytes32 identifier) external;

    /**
     * @notice Checks whether an identifier is on the whitelist.
     * @param identifier bytes32 encoding of the string identifier. Eg: BTC/USD.
     * @return bool if the identifier is supported (or not).
     */
    function isIdentifierSupported(bytes32 identifier) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

/**
 * @title Provides addresses of the live contracts implementing certain interfaces.
 * @dev Examples are the Oracle or Store interfaces.
 */
interface IUMAFinder {
    /**
     * @notice Updates the address of the contract that implements `interfaceName`.
     * @param interfaceName bytes32 encoding of the interface name that is either changed or registered.
     * @param implementationAddress address of the deployed contract that implements the interface.
     */
    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;

    /**
     * @notice Gets the address of the contract that implements the given `interfaceName`.
     * @param interfaceName queried interface.
     * @return implementationAddress address of the deployed contract that implements the interface.
     */
    function getImplementationAddress(bytes32 interfaceName) external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

interface IAddressWhitelist {
    function addToWhitelist(address newElement) external;

    function removeFromWhitelist(address newElement) external;

    function isOnWhitelist(address newElement) external view returns (bool);

    function getWhitelist() external view returns (address[] memory);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

/**
 * @title Stores common interface names used throughout the DVM by registration in the Finder.
 */
library UMAOracleInterfaces {
    bytes32 public constant Oracle = "Oracle";
    bytes32 public constant IdentifierWhitelist = "IdentifierWhitelist";
    bytes32 public constant Store = "Store";
    bytes32 public constant FinancialContractsAdmin = "FinancialContractsAdmin";
    bytes32 public constant Registry = "Registry";
    bytes32 public constant CollateralWhitelist = "CollateralWhitelist";
    bytes32 public constant OptimisticOracle = "OptimisticOracle";
    bytes32 public constant Bridge = "Bridge";
    bytes32 public constant GenericHandler = "GenericHandler";
    bytes32 public constant SkinnyOptimisticOracle = "SkinnyOptimisticOracle";
    bytes32 public constant ChildMessenger = "ChildMessenger";
    bytes32 public constant OracleHub = "OracleHub";
    bytes32 public constant OracleSpoke = "OracleSpoke";
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