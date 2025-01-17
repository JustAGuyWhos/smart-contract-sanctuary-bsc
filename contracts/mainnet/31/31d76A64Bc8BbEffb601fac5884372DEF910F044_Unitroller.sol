// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;


contract ComptrollerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        COMPTROLLER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED, // no longer possible
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY,
        SUPPLIER_NOT_WHITELISTED,
        BORROW_BELOW_MIN,
        SUPPLY_ABOVE_MAX,
        NONZERO_TOTAL_SUPPLY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        ADD_REWARDS_DISTRIBUTOR_OWNER_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        TOGGLE_ADMIN_RIGHTS_OWNER_CHECK,
        TOGGLE_AUTO_IMPLEMENTATIONS_ENABLED_OWNER_CHECK,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_CONTRACT_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SET_WHITELIST_ENFORCEMENT_OWNER_CHECK,
        SET_WHITELIST_STATUS_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        SET_PAUSE_GUARDIAN_OWNER_CHECK,
        UNSUPPORT_MARKET_OWNER_CHECK,
        UNSUPPORT_MARKET_DOES_NOT_EXIST,
        UNSUPPORT_MARKET_IN_USE
    }

    /**
     * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
   * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
   **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
     * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
   */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
     * @dev use this when reporting an opaque error from an upgradeable collaborator contract
   */
    function failOpaque(
        Error err,
        FailureInfo info,
        uint256 opaqueError
    ) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

contract TokenErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED,
        UTILIZATION_ABOVE_MAX
    }

    /*
     * Note: FailureInfo (but not Error) is kept in alphabetical order
     *       This is because FailureInfo grows significantly faster, and
     *       the order of Error has some meaning, while the order of FailureInfo
     *       is entirely arbitrary.
     */
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_FUSE_FEES_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_ADMIN_FEES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_COMPTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        NEW_UTILIZATION_RATE_ABOVE_MAX,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        WITHDRAW_FUSE_FEES_ACCRUE_INTEREST_FAILED,
        WITHDRAW_FUSE_FEES_CASH_NOT_AVAILABLE,
        WITHDRAW_FUSE_FEES_FRESH_CHECK,
        WITHDRAW_FUSE_FEES_VALIDATION,
        WITHDRAW_ADMIN_FEES_ACCRUE_INTEREST_FAILED,
        WITHDRAW_ADMIN_FEES_CASH_NOT_AVAILABLE,
        WITHDRAW_ADMIN_FEES_FRESH_CHECK,
        WITHDRAW_ADMIN_FEES_VALIDATION,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        TOGGLE_ADMIN_RIGHTS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_ADMIN_FEE_ACCRUE_INTEREST_FAILED,
        SET_ADMIN_FEE_ADMIN_CHECK,
        SET_ADMIN_FEE_FRESH_CHECK,
        SET_ADMIN_FEE_BOUNDS_CHECK,
        SET_FUSE_FEE_ACCRUE_INTEREST_FAILED,
        SET_FUSE_FEE_FRESH_CHECK,
        SET_FUSE_FEE_BOUNDS_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_COMPTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH,
        ADD_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_RESERVES_FRESH_CHECK,
        ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE
    }

    /**
     * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
   * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
   **/
    event Failure(uint256 error, uint256 info, uint256 detail);

    /**
     * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
   */
    function fail(Error err, FailureInfo info) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    /**
     * @dev use this when reporting an opaque error from an upgradeable collaborator contract
   */
    function failOpaque(
        Error err,
        FailureInfo info,
        uint256 opaqueError
    ) internal returns (uint256) {
        emit Failure(uint256(err), uint256(info), opaqueError);

        return err == Error.COMPTROLLER_REJECTION ? 1000 + opaqueError : uint256(err);
    }
}


interface IFuseFeeDistributor {
    function minBorrowEth() external view returns (uint256);

    function maxSupplyEth() external view returns (uint256);

    function maxUtilizationRate() external view returns (uint256);

    function interestFeeRate() external view returns (uint256);

    function comptrollerImplementationWhitelist(address oldImplementation, address newImplementation)
    external
    view
    returns (bool);

    function cErc20DelegateWhitelist(
        address oldImplementation,
        address newImplementation,
        bool allowResign
    ) external view returns (bool);

    function cEtherDelegateWhitelist(
        address oldImplementation,
        address newImplementation,
        bool allowResign
    ) external view returns (bool);

    function latestComptrollerImplementation(address oldImplementation) external view returns (address);

    function latestCErc20Delegate(address oldImplementation)
    external
    view
    returns (
        address cErc20Delegate,
        bool allowResign,
        bytes memory becomeImplementationData
    );

    function latestCEtherDelegate(address oldImplementation)
    external
    view
    returns (
        address cEtherDelegate,
        bool allowResign,
        bytes memory becomeImplementationData
    );

    function deployCEther(bytes calldata constructorData) external returns (address);

    function deployCErc20(bytes calldata constructorData) external returns (address);

    fallback() external payable;

    receive() external payable;
}

abstract contract PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    bool public constant isPriceOracle = true;

    /**
     * @notice Get the underlying price of a cToken asset
   * @param cToken The cToken to get the underlying price of
   * @return The underlying asset price mantissa (scaled by 1e18).
   *  Zero means the price is unavailable.
   */
    function getUnderlyingPrice(CToken cToken) external view virtual returns (uint256);
}

contract CToken {

}

contract UnitrollerAdminStorage {
    /*
     * Administrator for Fuse
     */
    address payable public fuseAdmin;

    /**
     * @notice Administrator for this contract
   */
    address public admin;

    /**
     * @notice Pending administrator for this contract
   */
    address public pendingAdmin;

    /**
     * @notice Whether or not the Fuse admin has admin rights
   */
    bool public fuseAdminHasRights = true;

    /**
     * @notice Whether or not the admin has admin rights
   */
    bool public adminHasRights = true;

    /**
     * @notice Returns a boolean indicating if the sender has admin rights
   */
    function hasAdminRights() internal view returns (bool) {
        return (msg.sender == admin && adminHasRights) || (msg.sender == address(fuseAdmin) && fuseAdminHasRights);
    }

    /**
     * @notice Active brains of Unitroller
   */
    address public comptrollerImplementation;

    /**
     * @notice Pending brains of Unitroller
   */
    address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {
    /**
     * @notice Oracle which gives the price of any given asset
   */
    PriceOracle public oracle;

    /**
     * @notice Multiplier used to calculate the maximum repayAmount when liquidating a borrow
   */
    uint256 public closeFactorMantissa;

    /**
     * @notice Multiplier representing the discount on collateral that a liquidator receives
   */
    uint256 public liquidationIncentiveMantissa;

    /*
     * UNUSED AFTER UPGRADE: Max number of assets a single account can participate in (borrow or use as collateral)
     */
    uint256 internal maxAssets;

    /**
     * @notice Per-account mapping of "assets you are in", capped by maxAssets
   */
    mapping(address => CToken[]) public accountAssets;
}

contract ComptrollerV2Storage is ComptrollerV1Storage {
    struct Market {
        // Whether or not this market is listed
        bool isListed;
        // Multiplier representing the most one can borrow against their collateral in this market.
        // For instance, 0.9 to allow borrowing 90% of collateral value.
        // Must be between 0 and 1, and stored as a mantissa.
        uint256 collateralFactorMantissa;
        // Per-market mapping of "accounts in this asset"
        mapping(address => bool) accountMembership;
    }

    /**
     * @notice Official mapping of cTokens -> Market metadata
   * @dev Used e.g. to determine if a market is supported
   */
    mapping(address => Market) public markets;

    /// @notice A list of all markets
    CToken[] public allMarkets;

    /**
     * @dev Maps borrowers to booleans indicating if they have entered any markets
   */
    mapping(address => bool) internal borrowers;

    /// @notice A list of all borrowers who have entered markets
    address[] public allBorrowers;

    // Indexes of borrower account addresses in the `allBorrowers` array
    mapping(address => uint256) internal borrowerIndexes;

    /**
     * @dev Maps suppliers to booleans indicating if they have ever supplied to any markets
   */
    mapping(address => bool) public suppliers;

    /// @notice All cTokens addresses mapped by their underlying token addresses
    mapping(address => CToken) public cTokensByUnderlying;

    /// @notice Whether or not the supplier whitelist is enforced
    bool public enforceWhitelist;

    /// @notice Maps addresses to booleans indicating if they are allowed to supply assets (i.e., mint cTokens)
    mapping(address => bool) public whitelist;

    /// @notice An array of all whitelisted accounts
    address[] public whitelistArray;

    // Indexes of account addresses in the `whitelistArray` array
    mapping(address => uint256) internal whitelistIndexes;

    /**
     * @notice The Pause Guardian can pause certain actions as a safety mechanism.
   *  Actions which allow users to remove their own assets cannot be paused.
   *  Liquidation / seizing / transfer can only be paused globally, not by market.
   */
    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;
}

contract ComptrollerV3Storage is ComptrollerV2Storage {
    /**
     * @dev Whether or not the implementation should be auto-upgraded.
   */
    bool public autoImplementation;

    /// @notice The borrowCapGuardian can set borrowCaps to any number for any market. Lowering the borrow cap could disable borrowing on the given market.
    address public borrowCapGuardian;

    /// @notice Borrow caps enforced by borrowAllowed for each cToken address. Defaults to zero which corresponds to unlimited borrowing.
    mapping(address => uint256) public borrowCaps;

    /// @notice Supply caps enforced by mintAllowed for each cToken address. Defaults to zero which corresponds to unlimited supplying.
    mapping(address => uint256) public supplyCaps;

    /// @notice RewardsDistributor contracts to notify of flywheel changes.
    address[] public rewardsDistributors;

    /// @dev Guard variable for pool-wide/cross-asset re-entrancy checks
    bool internal _notEntered;

    /// @dev Whether or not _notEntered has been initialized
    bool internal _notEnteredInitialized;
}


contract Unitroller is UnitrollerAdminStorage, ComptrollerErrorReporter {
    /**
     * @notice Emitted when pendingComptrollerImplementation is changed
   */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
     * @notice Emitted when pendingComptrollerImplementation is accepted, which means comptroller implementation is updated
   */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Event emitted when the Fuse admin rights are changed
   */
    event FuseAdminRightsToggled(bool hasRights);

    /**
     * @notice Event emitted when the admin rights are changed
   */
    event AdminRightsToggled(bool hasRights);

    /**
     * @notice Emitted when pendingAdmin is changed
   */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
     * @notice Emitted when pendingAdmin is accepted, which means admin is updated
   */
    event NewAdmin(address oldAdmin, address newAdmin);

    constructor(address payable _fuseAdmin) {
        // Set admin to caller
        admin = msg.sender;
        fuseAdmin = _fuseAdmin;
    }

    /*** Admin Functions ***/

    function _setPendingImplementation(address newPendingImplementation) public returns (uint256) {
        if (!hasAdminRights()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_OWNER_CHECK);
        }
        if (
            !IFuseFeeDistributor(fuseAdmin).comptrollerImplementationWhitelist(
            comptrollerImplementation,
            newPendingImplementation
        )
        ) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_CONTRACT_CHECK);
        }
        //require(Comptroller(newPendingImplementation).fuseAdmin() == fuseAdmin, "fuseAdmin not matching");

        address oldPendingImplementation = pendingComptrollerImplementation;
        pendingComptrollerImplementation = newPendingImplementation;
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);

        return uint256(Error.NO_ERROR);
    }

    /**
     * @notice Accepts new implementation of comptroller. msg.sender must be pendingImplementation
   * @dev Admin function for new implementation to accept it's role as implementation
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
    function _acceptImplementation() public returns (uint256) {
        // Check caller is pendingImplementation and pendingImplementation ≠ address(0)
        if (msg.sender != pendingComptrollerImplementation || pendingComptrollerImplementation == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK);
        }

        // Save current values for inclusion in log
        address oldImplementation = comptrollerImplementation;
        address oldPendingImplementation = pendingComptrollerImplementation;

        comptrollerImplementation = pendingComptrollerImplementation;

        pendingComptrollerImplementation = address(0);

        emit NewImplementation(oldImplementation, comptrollerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);

        return uint256(Error.NO_ERROR);
    }

    /**
     * @notice Toggles Fuse admin rights.
   * @param hasRights Boolean indicating if the Fuse admin is to have rights.
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
    function _toggleFuseAdminRights(bool hasRights) external returns (uint256) {
        // Check caller = admin
        if (!hasAdminRights()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.TOGGLE_ADMIN_RIGHTS_OWNER_CHECK);
        }

        // Check that rights have not already been set to the desired value
        if (fuseAdminHasRights == hasRights) return uint256(Error.NO_ERROR);

        // Set fuseAdminHasRights
        fuseAdminHasRights = hasRights;

        // Emit FuseAdminRightsToggled()
        emit FuseAdminRightsToggled(fuseAdminHasRights);

        return uint256(Error.NO_ERROR);
    }

    /**
     * @notice Toggles admin rights.
   * @param hasRights Boolean indicating if the admin is to have rights.
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
    function _toggleAdminRights(bool hasRights) external returns (uint256) {
        // Check caller = admin
        if (!hasAdminRights()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.TOGGLE_ADMIN_RIGHTS_OWNER_CHECK);
        }

        // Check that rights have not already been set to the desired value
        if (adminHasRights == hasRights) return uint256(Error.NO_ERROR);

        // Set adminHasRights
        adminHasRights = hasRights;

        // Emit AdminRightsToggled()
        emit AdminRightsToggled(hasRights);

        return uint256(Error.NO_ERROR);
    }

    /**
     * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
   * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
   * @param newPendingAdmin New pending admin.
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
    function _setPendingAdmin(address newPendingAdmin) public returns (uint256) {
        // Check caller = admin
        if (!hasAdminRights()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return uint256(Error.NO_ERROR);
    }

    /**
     * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
   * @dev Admin function for pending admin to accept role and update admin
   * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
   */
    function _acceptAdmin() public returns (uint256) {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return uint256(Error.NO_ERROR);
    }

    /**
     * @dev Delegates execution to an implementation contract.
   * It returns to the external caller whatever the implementation returns
   * or forwards reverts.
   */
    fallback() external payable {
        // Check for automatic implementation
        if (msg.sender != address(this)) {
            (bool callSuccess, bytes memory data) = address(this).staticcall(abi.encodeWithSignature("autoImplementation()"));
            bool autoImplementation;
            if (callSuccess) (autoImplementation) = abi.decode(data, (bool));

            if (autoImplementation) {
                address latestComptrollerImplementation = IFuseFeeDistributor(fuseAdmin).latestComptrollerImplementation(
                    comptrollerImplementation
                );

                if (comptrollerImplementation != latestComptrollerImplementation) {
                    address oldImplementation = comptrollerImplementation; // Save current value for inclusion in log
                    comptrollerImplementation = latestComptrollerImplementation;
                    emit NewImplementation(oldImplementation, comptrollerImplementation);
                }
            }
        }

        // delegate all other functions to current implementation
        (bool success, ) = comptrollerImplementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize())
            }
            default {
                return(free_mem_ptr, returndatasize())
            }
        }
    }
}