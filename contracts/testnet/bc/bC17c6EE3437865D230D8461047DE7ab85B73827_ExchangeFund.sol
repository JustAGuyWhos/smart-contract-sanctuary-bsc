// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

//import "./libraries/Beneficiary.sol";
import {Governed} from "./Governance.sol";
import {Initializable} from "./libraries/Upgradability.sol";

interface ICore {
    /// @dev Thrown when trying to set fees that don't sum up to one.
    /// @param stabilizationFee The stabilization fee that was tried to set.
    /// @param exchangeFee The stabilization fee that was tried to set.
    /// @param developmentFee The stabilization fee that was tried to set.
    error BaksDAOFeesDontSumUpToOne(uint256 stabilizationFee, uint256 exchangeFee, uint256 developmentFee);

    error BaksDAOZeroAddress();

    event PriceOracleUpdated(address priceOracle, address newPriceOracle);

    event BaksUpdated(address baks, address newBaks);
    event VoiceUpdated(address voice, address newVoice);

    event BankUpdated(address bank, address newBank);
    event DepositaryUpdated(address depositary, address newDepositary);
    event ExchangeFundUpdated(address exchangeFund, address newExchangeFund);
    event DevelopmentFundUpdated(address developmentFund, address newDevelopmentFund);

    event OperatorUpdated(address operator, address newOperator);
    event LiquidatorUpdated(address liquidator, address newLiquidator);

    event InterestUpdated(uint256 interest, uint256 newInterest);
    event DiscountedInterestUpdated(uint256 discountedInterest, uint256 newInterest);
    event MinimumPrincipalAmountUpdated(uint256 minimumPrincipalAmount, uint256 newMinimumPrincipalAmount);
    event StabilityFeeUpdated(uint256 stabilityFee, uint256 newStabilityFee);
    event DiscountedStabilityFeeUpdated(uint256 discountedStabilityFee, uint256 newDiscountedStabilityFee);
    event ReferrerFeeUpdated(uint256 referrerFee, uint256 newReferrerFee);

    event RebalancingThresholdUpdated(uint256 rebalancingThreshold, uint256 newRebalancingThreshold);
    event PlatformFeesUpdated(
        uint256 stabilizationFee,
        uint256 newStabilizationFee,
        uint256 exchangeFee,
        uint256 newExchangeFee,
        uint256 developmentFee,
        uint256 newDevelopmentFee
    );
    event DepositFeesUpdated(
        uint256 stabilizationFee,
        uint256 newStabilizationFee,
        uint256 exchangeFee,
        uint256 newExchangeFee,
        uint256 developmentFee,
        uint256 newDevelopmentFee
    );
    event MarginCallLoanToValueRatioUpdated(uint256 marginCallLoanToValueRatio, uint256 newMarginCallLoanToValueRatio);
    event LiquidationLoanToValueRatioUpdated(
        uint256 liqudationLoanToValueRatio,
        uint256 newLiquidationLoanToValueRatio
    );

    event MinimumMagisterDepositAmountUpdated(
        uint256 minimumMagisterDepositAmount,
        uint256 newMinimumMagisterDepositAmount
    );
    event WorkFeeUpdated(uint256 workFee, uint256 newWorkFee);
    event EarlyWithdrawalPeriodUpdated(uint256 earlyWithdrawalPeriod, uint256 newEarlyWithdrawalPeriod);
    event EarlyWithdrawalFeeUpdated(uint256 earlyWithdrawalFee, uint256 newEarlyWithdrawalFee);

    event ServicingThresholdUpdated(uint256 servicingThreshold, uint256 newServicingThreshold);
    event MinimumLiquidityUpdated(uint256 minimumLiquidity, uint256 newMinimumLiquidity);

    function wrappedNativeCurrency() external view returns (address);

    function uniswapV2Router() external view returns (address);

    function priceOracle() external view returns (address);

    function baks() external view returns (address);

    function voice() external view returns (address);

    function bank() external view returns (address);

    function depositary() external view returns (address);

    function exchangeFund() external view returns (address);

    function developmentFund() external view returns (address);

    function operator() external view returns (address);

    function liquidator() external view returns (address);

    function interest() external view returns (uint256);

    function minimumPrincipalAmount() external view returns (uint256);

    function stabilityFee() external view returns (uint256);

    function stabilizationFee() external view returns (uint256);

    function exchangeFee() external view returns (uint256);

    function developmentFee() external view returns (uint256);

    function marginCallLoanToValueRatio() external view returns (uint256);

    function liquidationLoanToValueRatio() external view returns (uint256);

    function rebalancingThreshold() external view returns (uint256);

    function minimumMagisterDepositAmount() external view returns (uint256);

    function workFee() external view returns (uint256);

    function earlyWithdrawalPeriod() external view returns (uint256);

    function earlyWithdrawalFee() external view returns (uint256);

    function servicingThreshold() external view returns (uint256);

    function minimumLiquidity() external view returns (uint256);

    function voiceMintingSchedule() external view returns (uint256[] memory);

    function voiceTotalShares() external view returns (uint256);

    function voiceMintingBeneficiaries() external view returns (uint256[] memory);

    function isSuperUser(address account) external view returns (bool);

    function depositStabilizationFee() external view returns (uint256);

    function depositExchangeFee() external view returns (uint256);

    function depositDevelopmentFee() external view returns (uint256);

    //возвращает дисконтированную ставку на займ при оплате займа в BDV (3%).
    function discountedInterest() external view returns (uint256);

    function discountedStabilityFee() external view returns (uint256);

    function referrerFee() external view returns (uint256);
}

contract Core is Initializable, Governed, ICore {
    uint256 internal constant ONE = 100e16;

    address public override wrappedNativeCurrency;
    address public override uniswapV2Router;

    address public override priceOracle;

    address public override baks;
    address public override voice;

    address public override bank;
    address public override depositary;
    address public override exchangeFund;
    address public override developmentFund;

    // Roles
    address public override operator;
    address public override liquidator;

    // Bank parameters
    uint256 public override interest;
    uint256 public override minimumPrincipalAmount;
    uint256 public override stabilityFee;
    uint256 public override stabilizationFee;
    uint256 public override exchangeFee;
    uint256 public override developmentFee;
    uint256 public override marginCallLoanToValueRatio;
    uint256 public override liquidationLoanToValueRatio;
    uint256 public override rebalancingThreshold;

    // Depositary parameters
    uint256 public override minimumMagisterDepositAmount;
    uint256 public override workFee;
    uint256 public override earlyWithdrawalPeriod;
    uint256 public override earlyWithdrawalFee;

    // Exchange fund parameters
    uint256 public override servicingThreshold;
    uint256 public override minimumLiquidity;

    // Voice
    uint256[] internal _voiceMintingSchedule;
    uint256[] internal _voiceMintingBeneficiaries;
    uint256 public override voiceTotalShares;

    mapping(address => bool) public override isSuperUser;

    uint256 public override depositStabilizationFee;
    uint256 public override depositExchangeFee;
    uint256 public override depositDevelopmentFee;

    // Bank interest with discount for repaying in BDV
    uint256 public override discountedInterest;
    uint256 public override discountedStabilityFee;
    uint256 public override referrerFee;

    function initialize(
        address _wrappedNativeCurrency,
        address _uniswapV2Router,
        address _operator,
        address _liquidator
    ) external initializer {
        setGovernor(msg.sender);

        if (_wrappedNativeCurrency == address(0)) {
            revert BaksDAOZeroAddress();
        }
        wrappedNativeCurrency = _wrappedNativeCurrency;
        if (_uniswapV2Router == address(0)) {
            revert BaksDAOZeroAddress();
        }
        uniswapV2Router = _uniswapV2Router;

        if (_operator == address(0)) {
            revert BaksDAOZeroAddress();
        }
        operator = _operator;
        if (_liquidator == address(0)) {
            revert BaksDAOZeroAddress();
        }
        liquidator = _liquidator;

        interest = 11e16; // 11 %
        minimumPrincipalAmount = 50e18; // 50 BAKS
        stabilityFee = 15e15; // 1,5 %
        stabilizationFee = 85e16; // 85 %
        exchangeFee = 15e16; // 15 %
        developmentFee = 0;
        marginCallLoanToValueRatio = 75e16; // 75 %
        liquidationLoanToValueRatio = 83e16; // 83 %
        rebalancingThreshold = 1e16; // 1 %

        minimumMagisterDepositAmount = 50000e18; // 50000 BAKS
        workFee = 2e16; // 2 %
        earlyWithdrawalPeriod = 72 hours;
        earlyWithdrawalFee = 1e15; // 0,1 %

        servicingThreshold = 1e16; // 1%
        minimumLiquidity = 50000e18; // 50000 BAKS

        depositStabilizationFee = 15e16; // 15 %
        depositExchangeFee = 85e16; // 85 %
        depositDevelopmentFee = 0;

        _voiceMintingSchedule = [
            0x295be96e64066972000000,
            0x0422ca8b0a00a4250000000000000000295be96e64066972000000,
            0x084595161401484a000000000000000052b7d2dcc80cd2e4000000,
            0x108b2a2c28029094000000000000000052b7d2dcc80cd2e4000000,
            0x2116545850052128000000000000000052b7d2dcc80cd2e4000000,
            0x422ca8b0a00a4250000000000000000052b7d2dcc80cd2e4000000,
            0x84595161401484a0000000000000000052b7d2dcc80cd2e4000000,
            0x0108b2a2c280290940000000000000000052b7d2dcc80cd2e4000000,
            0x014adf4b7320334b90000000000000000052b7d2dcc80cd2e4000000,
            0x018d0bf423c03d8de0000000000000000052b7d2dcc80cd2e4000000,
            0x01cf389cd46047d030000000000000000052b7d2dcc80cd2e4000000,
            0x021165458500521280000000000000000052b7d2dcc80cd2e4000000,
            0x025391ee35a05c54d0000000000000000052b7d2dcc80cd2e4000000,
            0x0295be96e6406697200000000000000000a56fa5b99019a5c8000000,
            0x02d7eb3f96e070d9700000000000000000a56fa5b99019a5c8000000,
            0x031a17e847807b1bc00000000000000000a56fa5b99019a5c8000000,
            0x035c4490f820855e100000000000000000a56fa5b99019a5c8000000
        ];

        isSuperUser[msg.sender] = true;
        discountedInterest = 3e16; // 3 %
        discountedStabilityFee = 1e16; // 1 %
        referrerFee = 50e16; // 50 %
    }

    function setPriceOracle(address newPriceOracle) external onlyGovernor {
        if (newPriceOracle == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit PriceOracleUpdated(priceOracle, newPriceOracle);
        priceOracle = newPriceOracle;
    }

    function setBaks(address newBaks) external onlyGovernor {
        if (newBaks == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit BaksUpdated(baks, newBaks);
        baks = newBaks;
    }

    function setVoice(address newVoice) external onlyGovernor {
        if (newVoice == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit VoiceUpdated(voice, newVoice);
        voice = newVoice;
    }

    function setBank(address newBank) external onlyGovernor {
        if (newBank == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit BankUpdated(bank, newBank);
        bank = newBank;
    }

    function setDepositary(address newDepositary) external onlyGovernor {
        if (newDepositary == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit DepositaryUpdated(depositary, newDepositary);
        depositary = newDepositary;
    }

    function setExchangeFund(address newExchangeFund) external onlyGovernor {
        if (newExchangeFund == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit ExchangeFundUpdated(exchangeFund, newExchangeFund);
        exchangeFund = newExchangeFund;
    }

    function setDevelopmentFund(address newDevelopmentFund) external onlyGovernor {
        if (newDevelopmentFund == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit DevelopmentFundUpdated(developmentFund, newDevelopmentFund);
        developmentFund = newDevelopmentFund;
    }

    function setOperator(address newOperator) external onlyGovernor {
        if (newOperator == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit OperatorUpdated(operator, newOperator);
        operator = newOperator;
    }

    function setLiquidator(address newLiquidator) external onlyGovernor {
        if (newLiquidator == address(0)) {
            revert BaksDAOZeroAddress();
        }
        emit LiquidatorUpdated(liquidator, newLiquidator);
        liquidator = newLiquidator;
    }

    function setInterest(uint256 newInterest) external onlyGovernor {
        emit InterestUpdated(interest, newInterest);
        interest = newInterest;
    }

    function setDiscountedInterest(uint256 newInterest) external onlyGovernor {
        emit DiscountedInterestUpdated(discountedInterest, newInterest);
        discountedInterest = newInterest;
    }

    function setMinimumPrincipalAmount(uint256 newMinimumPrincipalAmount) external onlyGovernor {
        emit StabilityFeeUpdated(minimumPrincipalAmount, newMinimumPrincipalAmount);
        minimumPrincipalAmount = newMinimumPrincipalAmount;
    }

    function setStabilityFee(uint256 newStabilityFee) external onlyGovernor {
        emit StabilityFeeUpdated(stabilityFee, newStabilityFee);
        stabilityFee = newStabilityFee;
    }

    function setDiscountedStabilityFee(uint256 newDiscountedStabilityFee) external onlyGovernor {
        emit DiscountedStabilityFeeUpdated(discountedStabilityFee, newDiscountedStabilityFee);
        discountedStabilityFee = newDiscountedStabilityFee;
    }

    function setReferrerFee(uint256 newReferrerFee) external onlyGovernor {
        emit ReferrerFeeUpdated(referrerFee, newReferrerFee);
        referrerFee = newReferrerFee;
    }

    function setPlatformFees(
        uint256 newStabilizationFee,
        uint256 newExchangeFee,
        uint256 newDevelopmentFee
    ) external onlyGovernor {
        if (newStabilizationFee + newExchangeFee + newDevelopmentFee != ONE) {
            revert BaksDAOFeesDontSumUpToOne(newStabilizationFee, newExchangeFee, newDevelopmentFee);
        }
        emit PlatformFeesUpdated(
            stabilizationFee,
            newStabilizationFee,
            exchangeFee,
            newExchangeFee,
            developmentFee,
            newDevelopmentFee
        );
        stabilizationFee = newStabilizationFee;
        exchangeFee = newExchangeFee;
        developmentFee = newDevelopmentFee;
    }

    function setDepositFees(
        uint256 newDepositStabilizationFee,
        uint256 newDepositExchangeFee,
        uint256 newDepositDevelopmentFee
    ) external onlyGovernor {
        if (newDepositStabilizationFee + newDepositExchangeFee + newDepositDevelopmentFee != ONE) {
            revert BaksDAOFeesDontSumUpToOne(
                newDepositStabilizationFee,
                newDepositExchangeFee,
                newDepositDevelopmentFee
            );
        }
        emit DepositFeesUpdated(
            depositStabilizationFee,
            newDepositStabilizationFee,
            depositExchangeFee,
            newDepositExchangeFee,
            depositDevelopmentFee,
            newDepositDevelopmentFee
        );
        depositStabilizationFee = newDepositStabilizationFee;
        depositExchangeFee = newDepositExchangeFee;
        depositDevelopmentFee = newDepositDevelopmentFee;
    }

    function setMarginCallLoanToValueRatio(uint256 newMarginCallLoanToValueRatio) external onlyGovernor {
        emit MarginCallLoanToValueRatioUpdated(marginCallLoanToValueRatio, newMarginCallLoanToValueRatio);
        marginCallLoanToValueRatio = newMarginCallLoanToValueRatio;
    }

    function setLiquidationLoanToValueRatio(uint256 newLiquidationLoanToValueRatio) external onlyGovernor {
        emit LiquidationLoanToValueRatioUpdated(liquidationLoanToValueRatio, newLiquidationLoanToValueRatio);
        liquidationLoanToValueRatio = newLiquidationLoanToValueRatio;
    }

    function setRebalancingThreshold(uint256 newRebalancingThreshold) external onlyGovernor {
        emit RebalancingThresholdUpdated(rebalancingThreshold, newRebalancingThreshold);
        rebalancingThreshold = newRebalancingThreshold;
    }

    function setMinimumMagisterDepositAmount(uint256 newMinimumMagisterDepositAmount) external onlyGovernor {
        emit MinimumMagisterDepositAmountUpdated(minimumMagisterDepositAmount, newMinimumMagisterDepositAmount);
        minimumMagisterDepositAmount = newMinimumMagisterDepositAmount;
    }

    function setWorkFee(uint256 newWorkFee) external onlyGovernor {
        emit WorkFeeUpdated(workFee, newWorkFee);
        workFee = newWorkFee;
    }

    function setEarlyWithdrawalPeriod(uint256 newEarlyWithdrawalPeriod) external onlyGovernor {
        emit EarlyWithdrawalPeriodUpdated(earlyWithdrawalPeriod, newEarlyWithdrawalPeriod);
        earlyWithdrawalPeriod = newEarlyWithdrawalPeriod;
    }

    function setEarlyWithdrawalFee(uint256 newEarlyWithdrawalFee) external onlyGovernor {
        emit EarlyWithdrawalFeeUpdated(earlyWithdrawalFee, newEarlyWithdrawalFee);
        earlyWithdrawalFee = newEarlyWithdrawalFee;
    }

    function setServicingThreshold(uint256 newServicingThreshold) external onlyGovernor {
        emit ServicingThresholdUpdated(servicingThreshold, newServicingThreshold);
        servicingThreshold = newServicingThreshold;
    }

    function setMinimumLiquidity(uint256 newMinimumLiquidity) external onlyGovernor {
        emit MinimumLiquidityUpdated(minimumLiquidity, newMinimumLiquidity);
        minimumLiquidity = newMinimumLiquidity;
    }

    /*     function setVoiceMintingBeneficiaries(uint256[] calldata beneficiaries) external onlyGovernor {
        delete _voiceMintingBeneficiaries;
        _voiceMintingBeneficiaries = beneficiaries;
        uint256 _voiceTotalShares = 0;
        for (uint256 i = 0; i < _voiceMintingBeneficiaries.length; i++) {
            (, uint256 share) = Beneficiary.split(_voiceMintingBeneficiaries[i]);
            _voiceTotalShares += share;
        }
        voiceTotalShares = _voiceTotalShares;
    } */

    function addSuperUser(address account) external onlyGovernor {
        if (account == address(0)) {
            revert BaksDAOZeroAddress();
        }
        isSuperUser[account] = true;
    }

    function removeSuperUser(address account) external onlyGovernor {
        isSuperUser[account] = false;
    }

    function voiceMintingBeneficiaries() external view override returns (uint256[] memory) {
        return _voiceMintingBeneficiaries;
    }

    function voiceMintingSchedule() external view override returns (uint256[] memory) {
        return _voiceMintingSchedule;
    }
}

abstract contract CoreInside {
    ICore public core;

    error BaksDAOOnlyDepositaryAllowed();
    error BaksDAOOnlySuperUserAllowed();

    modifier onlyDepositary() {
        if (msg.sender != address(core.depositary())) {
            revert BaksDAOOnlyDepositaryAllowed();
        }
        _;
    }

    modifier onlySuperUser() {
        if (!core.isSuperUser(msg.sender)) {
            revert BaksDAOOnlySuperUserAllowed();
        }
        _;
    }

    function initializeCoreInside(ICore _core) internal {
        core = _core;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "./libraries/AmountNormalization.sol";
import "./libraries/EnumerableAddressSet.sol";
import "./libraries/FixedPointMath.sol";
import "./libraries/Math.sol";
import "./libraries/SafeERC20.sol";
import {CoreInside, ICore} from "./Core.sol";
import {Governed} from "./Governance.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {Initializable} from "./libraries/Upgradability.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {IUniswapV2Factory, IUniswapV2Router, IUniswapV2Pair} from "./interfaces/IUniswapV2.sol";

/// @dev Thrown when trying to list depositable token that has zero decimals.
/// @param token The address of the token contract.
error ExchangeFundDepositableTokenZeroDecimals(IERC20 token);

/// @dev Thrown when trying to list depositable token that has too large decimals.
/// @param token The address of the token contract.
error ExchangeFundDepositableTokenTooLargeDecimals(IERC20 token, uint8 decimals);

/// @dev Thrown when trying to list depositable token that's already listed.
/// @param token The address of the token contract.
error ExchangeFundDepositableTokenAlreadyListed(IERC20 token);

/// @dev Thrown when trying to unlist depositable token that's not listed.
/// @param token The address of the token contract.
error ExchangeFundDepositableTokenNotListed(IERC20 token);

/// @dev Thrown when interacting with a token that's not allowed to be deposited.
/// @param token The address of the token contract.
error ExchangeFundTokenNotAllowedToBeDeposited(IERC20 token);

/// @dev Thrown when interacting with a token that's not allowed to be withdrawn.
/// @param token The address of the token contract.
error ExchangeFundTokenNotAllowedToBeWithdrawn(IERC20 token);

/// @dev Thrown when trying to salvage one of depositable tokens or BAKS.
/// @param token The address of the token contract.
error ExchangeFundTokenNotAllowedToBeSalvaged(IERC20 token);

/// @dev Генерируется при нехватке депонированных средств суперпользователя.
error ExchangeFundInsufficientDeposits();

/// @dev Генерируется при нехватке LP-токенов суперпользователя.
error ExchangeFundInsufficientLiquidity();

/// @dev Генерируется при попытке обмена одинаковых токенов.
error ExchangeFundSameTokenSwap(IERC20 token);

/// @dev Thrown when trying to swap token that's not allowed to be swapped.
/// @param token The address of the token contract.
error ExchangeFundTokenNotAllowedToBeSwapped(IERC20 token);

/// @dev Thrown when there's no need to service the `token`/BAKS pair cause the difference between target and
/// pair price does not exceed servicing threshold.
/// @param token The address of the token contract.
error ExchangeFundNoNeedToService(IERC20 token);

error ExchangeFundTokenNotApproved();

/// @title Фонд обмена
/// @author BaksDAO
contract ExchangeFund is CoreInside, Governed, Initializable {
    using AmountNormalization for IERC20;
    using EnumerableAddressSet for EnumerableAddressSet.Set;
    using FixedPointMath for uint256;
    using SafeERC20 for IERC20;

    uint256 internal constant ONE = 100e16;
    uint8 internal constant DECIMALS = 18;

    /// @dev Допустимое проскальзывание при обмене
    uint256 public slippageTolerance;
    /// @dev Дедлайн обмена
    uint256 public swapDeadline;

    /// @dev Суммы вложенных средств по суперпользователю и пулу.
    mapping(address => mapping(IERC20 => uint256)) public deposits;
    /// @dev Суммы LP-токенов по суперпользователю и пулу.
    mapping(address => mapping(IERC20 => uint256)) public liquidity;

    /// @dev Информация о депонируемых токенах.
    mapping(IERC20 => bool) public depositableTokens;
    EnumerableAddressSet.Set internal depositableTokensSet;

    /// @dev Генерируется после добавления нового депонируемого токена.
    /// @param token Депонируемый токен.
    /// @param pair Адрес пары.
    event DepositableTokenListed(IERC20 indexed token, IUniswapV2Pair pair);
    /// @dev Генерируется после удаления депонируемого токена.
    /// @param token Депонируемый токен.
    event DepositableTokenUnlisted(IERC20 indexed token);

    /// @dev Генерируется после обновления значения допустимого проскальзывания.
    event SlippageToleranceUpdated(uint256 slippageTolerance, uint256 newSlippageTolerance);
    /// @dev Генерируется после обновления значения дедлайна.
    event SwapDeadlineUpdated(uint256 swapDeadline, uint256 newSwapDeadline);

    /// @dev Генерируется после депонирования средств в фонд обмена.
    /// @param account Адрес вкладчика.
    /// @param token Адрес депонируемого токена.
    /// @param amount Сумма депозита.
    event Deposit(address indexed account, IERC20 indexed token, uint256 amount);
    /// @dev Генерируется после произведённого обмена.
    event Swap(address indexed account, IERC20 indexed tokenA, IERC20 indexed tokenB, uint256 amountA, uint256 amountB);
    /// @dev Генерируется после добавления ликвидности из фонда обмена.
    event Invest(address indexed account, IERC20 indexed token, uint256 amount);
    /// @dev Генерируется после вывода ликвидности в фонд обмена.
    event Divest(address indexed account, IERC20 indexed token, uint256 amount);
    /// @dev Генерируется после вывода средств из фонда обмена.
    event Withdrawal(address indexed account, IERC20 indexed token, uint256 amount);
    /// @dev Генерируется после выравнивания курса / добавления ликвидности.
    event Service(address indexed account, IERC20 indexed token);

    modifier tokenAllowedToBeDeposited(IERC20 token) {
        if (!depositableTokensSet.contains(address(token))) {
            revert ExchangeFundTokenNotAllowedToBeDeposited(token);
        }
        _;
    }

    modifier tokenAllowedToBeSwapped(IERC20 token) {
        if (token != IERC20(core.baks()) && !depositableTokensSet.contains(address(token))) {
            revert ExchangeFundTokenNotAllowedToBeSwapped(token);
        }
        _;
    }

    function initialize(ICore _core) external initializer {
        initializeCoreInside(_core);
        setGovernor(msg.sender);

        slippageTolerance = 5e15; // 0.5 %
        swapDeadline = 20 minutes;

        IERC20 baks = IERC20(core.baks());
        IERC20 voice = IERC20(core.voice());

        if (!baks.approve(core.uniswapV2Router(), type(uint256).max)) {
            revert ExchangeFundTokenNotApproved();
        }
        if (!baks.approve(core.depositary(), type(uint256).max)) {
            revert ExchangeFundTokenNotApproved();
        }

        if (!voice.approve(core.uniswapV2Router(), type(uint256).max)) {
            revert ExchangeFundTokenNotApproved();
        }
        if (!voice.approve(core.depositary(), type(uint256).max)) {
            revert ExchangeFundTokenNotApproved();
        }
    }

    /// @dev Депонировать средства в фонд обмена.
    function deposit(IERC20 token, uint256 amount) external tokenAllowedToBeDeposited(token) onlySuperUser {
        token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 normalizedAmount = token.normalizeAmount(amount);
        deposits[msg.sender][token] += normalizedAmount;

        emit Deposit(msg.sender, token, normalizedAmount);
    }

    /// @dev Произвести обмен.
    /// @param tokenA Адрес токена А
    /// @param tokenB Адреса токена B
    /// @param amount Сумма обмена
    /// @param useWrappedNativeCurrencyAsIntermediateToken Использовать WBNB/WETH как промежуточный токен обмена.
    function swap(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amount,
        bool useWrappedNativeCurrencyAsIntermediateToken
    ) external tokenAllowedToBeSwapped(tokenA) tokenAllowedToBeSwapped(tokenB) onlySuperUser {
        uint256 normalizedAmount = tokenA.normalizeAmount(amount);
        if (normalizedAmount > deposits[msg.sender][tokenA]) {
            revert ExchangeFundInsufficientDeposits();
        }

        if (tokenA == tokenB) {
            revert ExchangeFundSameTokenSwap(tokenA);
        }

        IERC20[] memory path = new IERC20[](useWrappedNativeCurrencyAsIntermediateToken ? 3 : 2);
        path[0] = tokenA;
        path[1] = useWrappedNativeCurrencyAsIntermediateToken ? IERC20(core.wrappedNativeCurrency()) : tokenB;
        if (useWrappedNativeCurrencyAsIntermediateToken) {
            path[2] = tokenB;
        }

        IUniswapV2Router uniswapV2Router = IUniswapV2Router(core.uniswapV2Router());
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(amount, path);
        uint256 normalizedAmountOut = tokenB.normalizeAmount(amounts[amounts.length - 1]);

        amounts = uniswapV2Router.swapExactTokensForTokens(
            amount,
            tokenB.denormalizeAmount(normalizedAmountOut.mul(ONE - slippageTolerance)),
            path,
            address(this),
            block.timestamp + swapDeadline
        );

        uint256 normalizedTokenAAmount = tokenA.normalizeAmount(amounts[0]);
        uint256 normalizedTokenBAmount = tokenB.normalizeAmount(amounts[amounts.length - 1]);

        deposits[msg.sender][tokenA] -= normalizedTokenAAmount;
        deposits[msg.sender][tokenB] += normalizedTokenBAmount;

        emit Swap(msg.sender, tokenA, tokenB, normalizedTokenAAmount, normalizedTokenBAmount);
    }

    /// @dev Добавить ликвидность из фонда обмена.
    function invest(IERC20 token, uint256 amount) external onlySuperUser {
        uint256 normalizedAmount = token.normalizeAmount(amount);
        if (normalizedAmount > deposits[msg.sender][token]) {
            revert ExchangeFundInsufficientDeposits();
        }

        uint256 tokenValue = quote(token, amount);
        (, uint256 amountSent, uint256 liquidityMinted) = IUniswapV2Router(core.uniswapV2Router()).addLiquidity(
            IERC20(core.baks()),
            token,
            tokenValue,
            amount,
            tokenValue.mul(ONE - slippageTolerance),
            token.denormalizeAmount(normalizedAmount.mul(ONE - slippageTolerance)),
            address(this),
            block.timestamp + swapDeadline
        );

        deposits[msg.sender][token] -= token.normalizeAmount(amountSent);
        liquidity[msg.sender][token] += liquidityMinted;

        emit Invest(msg.sender, token, normalizedAmount);
    }

    /// @dev Вывести ликвидность в фонд обмена.
    function divest(IERC20 token, uint256 amount) external onlySuperUser {
        if (amount > liquidity[msg.sender][token]) {
            revert ExchangeFundInsufficientLiquidity();
        }

        (, uint256 amountReceived) = IUniswapV2Router(core.uniswapV2Router()).removeLiquidity(
            IERC20(core.baks()),
            token,
            amount,
            0,
            0,
            address(this),
            block.timestamp + swapDeadline
        );

        deposits[msg.sender][token] += token.normalizeAmount(amountReceived);
        liquidity[msg.sender][token] -= amount;

        emit Divest(msg.sender, token, amount);
    }

    /// @dev Вывести средства из фонда обмена.
    function withdraw(IERC20 token, uint256 amount) external onlySuperUser {
        if (token == IERC20(core.baks())) {
            revert ExchangeFundTokenNotAllowedToBeWithdrawn(token);
        }

        uint256 normalizedAmount = token.normalizeAmount(amount);
        if (normalizedAmount > deposits[msg.sender][token]) {
            revert ExchangeFundInsufficientDeposits();
        }

        deposits[msg.sender][token] -= normalizedAmount;
        token.safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, token, normalizedAmount);
    }

    /// @dev Добавить новый депонируемый токен.
    function listDepositableToken(IERC20 token) external onlyGovernor {
        if (depositableTokensSet.contains(address(token))) {
            revert ExchangeFundDepositableTokenAlreadyListed(token);
        }

        uint8 decimals = token.decimals();
        if (decimals == 0) {
            revert ExchangeFundDepositableTokenZeroDecimals(token);
        }
        if (decimals > DECIMALS) {
            revert ExchangeFundDepositableTokenTooLargeDecimals(token, decimals);
        }

        if (depositableTokensSet.add(address(token))) {
            IERC20 baks = IERC20(core.baks());
            IUniswapV2Router uniswapV2Router = IUniswapV2Router(core.uniswapV2Router());

            token.approve(address(uniswapV2Router), type(uint256).max);

            IUniswapV2Factory uniswapV2Factory = uniswapV2Router.factory();
            IUniswapV2Pair uniswapV2Pair = uniswapV2Factory.getPair(baks, token);
            if (address(uniswapV2Pair) == address(0)) {
                uniswapV2Pair = uniswapV2Factory.createPair(baks, token);
            }
            uniswapV2Pair.approve(address(uniswapV2Router), type(uint256).max);

            depositableTokens[token] = true;
            emit DepositableTokenListed(token, uniswapV2Pair);
        }
    }

    /// @dev Удалить депонируемый токен.
    function unlistDepositableToken(IERC20 token) external onlyGovernor {
        if (!depositableTokensSet.contains(address(token))) {
            revert ExchangeFundDepositableTokenNotListed(token);
        }

        if (depositableTokensSet.remove(address(token))) {
            IUniswapV2Router uniswapV2Router = IUniswapV2Router(core.uniswapV2Router());

            token.approve(address(uniswapV2Router), 0);

            IUniswapV2Factory uniswapV2Factory = uniswapV2Router.factory();
            IUniswapV2Pair uniswapV2Pair = uniswapV2Factory.getPair(IERC20(core.baks()), token);
            if (address(uniswapV2Pair) != address(0)) {
                uniswapV2Pair.approve(address(uniswapV2Router), 0);
            }

            delete depositableTokens[token];
            emit DepositableTokenUnlisted(token);
        }
    }

    /// @dev Установить допустимое проскальзывание.
    function setSlippageTolerance(uint256 newSlippageTolerance) external onlyGovernor {
        emit SlippageToleranceUpdated(slippageTolerance, newSlippageTolerance);
        slippageTolerance = newSlippageTolerance;
    }

    /// @dev Установить дедлайн обмена.
    function setSwapDeadline(uint256 newSwapDeadline) external onlyGovernor {
        emit SwapDeadlineUpdated(swapDeadline, newSwapDeadline);
        swapDeadline = newSwapDeadline;
    }

    function salvage(IERC20 token) external onlyGovernor {
        address tokenAddress = address(token);
        if (token == IERC20(core.baks()) || depositableTokensSet.contains(tokenAddress)) {
            revert ExchangeFundTokenNotAllowedToBeSalvaged(token);
        }
        token.safeTransfer(core.operator(), token.balanceOf(address(this)));
    }

    function approveVoice() external onlyGovernor {
        IERC20 voice = IERC20(core.voice());
        if (!voice.approve(core.uniswapV2Router(), type(uint256).max)) {
            revert ExchangeFundTokenNotApproved();
        }
        if (!voice.approve(core.depositary(), type(uint256).max)) {
            revert ExchangeFundTokenNotApproved();
        }
    }

    /// @dev Привести курс к рыночному / добавить ликвидность до минимального порогового уровня.
    function service(IERC20 token) external {
        (uint256 baksReserve, uint256 tokenReserve) = getReserves(token);
        tokenReserve = token.normalizeAmount(tokenReserve);

        bool isService;

        uint256 targetPrice = IPriceOracle(core.priceOracle()).getNormalizedPrice(token);
        uint256 price = baksReserve.div(tokenReserve);
        int256 delta = int256(price.div(targetPrice)) - int256(ONE);
        if (Math.abs(delta) >= core.servicingThreshold()) {
            int256 amountOut;
            IERC20[] memory path = new IERC20[](2);
            if (price > targetPrice) {
                amountOut = int256(Math.fpsqrt(baksReserve.mul(tokenReserve).mul(targetPrice))) - int256(baksReserve);
                path[0] = token;
                path[1] = IERC20(core.baks());
            } else {
                amountOut = int256(Math.fpsqrt(baksReserve.mulDiv(tokenReserve, targetPrice))) - int256(tokenReserve);
                path[0] = IERC20(core.baks());
                path[1] = token;
            }

            // NOTE: using this instead of `swapExactTokensForTokens` to shift responsibility for calculating fees to
            // *swap itself.
            IUniswapV2Router(core.uniswapV2Router()).swapTokensForExactTokens(
                Math.abs(amountOut),
                type(uint256).max,
                path,
                address(this),
                block.timestamp + swapDeadline
            );

            isService = true;
        }

        if (!(isService || topUpLiquidity(token))) {
            revert ExchangeFundNoNeedToService(token);
        }

        emit Service(msg.sender, token);
    }

    /// @dev Перевести BAKS в фонд стабилизации.
    function transferBaksToBank(uint256 amount) external onlySuperUser {
        IERC20(core.baks()).safeTransfer(core.bank(), amount);
    }

    /// @dev Получить депонируемые токены.
    function getDepositableTokens() external view returns (IERC20[] memory tokens) {
        uint256 length = depositableTokensSet.elements.length;
        tokens = new IERC20[](length);

        for (uint256 i = 0; i < length; ) {
            tokens[i] = IERC20(depositableTokensSet.elements[i]);
            unchecked {
                i++;
            }
        }
    }

    /// @dev Рассчитать сумму обмена токена на BAKS.
    function quote(IERC20 token, uint256 amount) public view returns (uint256 baksAmount) {
        IERC20 baks = IERC20(core.baks());
        IUniswapV2Router uniswapV2Router = IUniswapV2Router(core.uniswapV2Router());

        IUniswapV2Pair uniswapV2Pair = uniswapV2Router.factory().getPair(baks, token);

        (uint256 reserveA, uint256 reserveB, ) = uniswapV2Pair.getReserves();
        if (reserveA == 0 || reserveB == 0) {
            baksAmount = token.normalizeAmount(amount).mul(IPriceOracle(core.priceOracle()).getNormalizedPrice(token));
            return baksAmount;
        }

        baksAmount = address(baks) < address(token)
            ? uniswapV2Router.quote(amount, reserveB, reserveA)
            : uniswapV2Router.quote(amount, reserveA, reserveB);
    }

    function topUpLiquidity(IERC20 token) internal returns (bool isTopUpped) {
        (uint256 baksReserve, uint256 tokenReserve) = getReserves(token);
        tokenReserve = token.normalizeAmount(tokenReserve);

        uint256 minimumLiquidity = core.minimumLiquidity();
        if (baksReserve < minimumLiquidity) {
            uint256 amountADesired = minimumLiquidity - baksReserve;
            uint256 amountBDesired = token.denormalizeAmount(amountADesired.div(baksReserve.div(tokenReserve)));
            IUniswapV2Router(core.uniswapV2Router()).addLiquidity(
                IERC20(core.baks()),
                token,
                amountADesired,
                amountBDesired,
                amountADesired.mul(ONE - slippageTolerance),
                token.denormalizeAmount(amountBDesired.mul(ONE - slippageTolerance)),
                address(this),
                block.timestamp + swapDeadline
            );

            isTopUpped = true;
        }
    }

    function getReserves(IERC20 token) internal view returns (uint256 baksReserve, uint256 tokenReserve) {
        IERC20 baks = IERC20(core.baks());
        IUniswapV2Pair uniswapV2Pair = IUniswapV2Router(core.uniswapV2Router()).factory().getPair(baks, token);

        (uint256 reserveA, uint256 reserveB, ) = uniswapV2Pair.getReserves();
        if (address(baks) < address(token)) {
            baksReserve = reserveA;
            tokenReserve = reserveB;
        } else {
            tokenReserve = reserveA;
            baksReserve = reserveB;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

error GovernedOnlyGovernorAllowedToCall();
error GovernedOnlyPendingGovernorAllowedToCall();
error GovernedGovernorZeroAddress();
error GovernedCantGoverItself();

abstract contract Governed {
    address public governor;
    address public pendingGovernor;

    event PendingGovernanceTransition(address indexed governor, address indexed newGovernor);
    event GovernanceTransited(address indexed governor, address indexed newGovernor);

    modifier onlyGovernor() {
        if (msg.sender != governor) {
            revert GovernedOnlyGovernorAllowedToCall();
        }
        _;
    }

    function transitGovernance(address newGovernor, bool force) external onlyGovernor {
        if (newGovernor == address(0)) {
            revert GovernedGovernorZeroAddress();
        }
        if (newGovernor == address(this)) {
            revert GovernedCantGoverItself();
        }

        pendingGovernor = newGovernor;
        if (!force) {
            emit PendingGovernanceTransition(governor, newGovernor);
        } else {
            setGovernor(newGovernor);
        }
    }

    function acceptGovernance() external {
        if (msg.sender != pendingGovernor) {
            revert GovernedOnlyPendingGovernorAllowedToCall();
        }

        governor = pendingGovernor;
        emit GovernanceTransited(governor, pendingGovernor);
    }

    function setGovernor(address newGovernor) internal {
        governor = newGovernor;
        emit GovernanceTransited(governor, newGovernor);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IMintableAndBurnableERC20 is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./IERC20.sol";
//import "./../libraries/FixedPointMath.sol";

/// @notice Thrown when oracle doesn't provide price for `token` token.
/// @param token The address of the token contract.
error PriceOracleTokenUnknown(IERC20 token);
/// @notice Thrown when oracle provide stale price `price` for `token` token.
/// @param token The address of the token contract.
/// @param price Provided price.
error PriceOracleStalePrice(IERC20 token, uint256 price);
/// @notice Thrown when oracle provide negative, zero or in other ways invalid price `price` for `token` token.
/// @param token The address of the token contract.
/// @param price Provided price.
error PriceOracleInvalidPrice(IERC20 token, int256 price);

interface IPriceOracle {
    /// @notice Gets normalized to 18 decimals price for the `token` token.
    /// @param token The address of the token contract.
    /// @return normalizedPrice Normalized price.
    function getNormalizedPrice(IERC20 token) external view returns (uint256 normalizedPrice);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {IERC20} from "./IERC20.sol";

interface IUniswapV2Pair is IERC20 {
    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IUniswapV2Factory {
    function createPair(IERC20 tokenA, IERC20 tokenB) external returns (IUniswapV2Pair pair);

    function getPair(IERC20 tokenA, IERC20 tokenB) external view returns (IUniswapV2Pair pair);
}

interface IUniswapV2Router {
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, IERC20[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, IERC20[] calldata path) external view returns (uint256[] memory amounts);

    function factory() external view returns (IUniswapV2Factory);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

error CallToNonContract(address target);

library Address {
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        if (!isContract(target)) {
            revert CallToNonContract(target);
        }

        (bool success, bytes memory returnData) = target.call(data);
        return verifyCallResult(success, returnData, errorMessage);
    }

    function delegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        if (!isContract(target)) {
            revert CallToNonContract(target);
        }

        (bool success, bytes memory returnData) = target.delegatecall(data);
        return verifyCallResult(success, returnData, errorMessage);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(account)
        }

        return codeSize > 0;
    }

    function verifyCallResult(
        bool success,
        bytes memory returnData,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returnData;
        } else {
            if (returnData.length > 0) {
                assembly {
                    let returnDataSize := mload(returnData)
                    revert(add(returnData, 32), returnDataSize)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./../interfaces/IERC20.sol";

library AmountNormalization {
    uint8 internal constant DECIMALS = 18;

    function normalizeAmount(IERC20 self, uint256 denormalizedAmount) internal view returns (uint256 normalizedAmount) {
        uint256 scale = 10**(DECIMALS - self.decimals());
        if (scale != 1) {
            return denormalizedAmount * scale;
        }
        return denormalizedAmount;
    }

    function denormalizeAmount(IERC20 self, uint256 normalizedAmount)
        internal
        view
        returns (uint256 denormalizedAmount)
    {
        uint256 scale = 10**(DECIMALS - self.decimals());
        if (scale != 1) {
            return normalizedAmount / scale;
        }
        return normalizedAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

library EnumerableAddressSet {
    struct Set {
        address[] elements;
        mapping(address => uint256) indexes;
        uint256 activeCount;
    }

    function add(Set storage self, address element) internal returns (bool) {
        if (contains(self, element)) {
            return false;
        }

        self.elements.push(element);
        self.indexes[element] = self.elements.length;

        return true;
    }

    function remove(Set storage self, address element) internal returns (bool) {
        uint256 elementIndex = indexOf(self, element);
        if (elementIndex == 0) {
            return false;
        }

        uint256 indexToRemove = elementIndex - 1;
        uint256 lastIndex = count(self) - 1;
        if (indexToRemove != lastIndex) {
            address lastElement = self.elements[lastIndex];
            self.elements[indexToRemove] = lastElement;
            self.indexes[lastElement] = elementIndex;
        }
        self.elements.pop();
        delete self.indexes[element];

        return true;
    }

    function indexOf(Set storage self, address element) internal view returns (uint256) {
        return self.indexes[element];
    }

    function contains(Set storage self, address element) internal view returns (bool) {
        return indexOf(self, element) != 0;
    }

    function count(Set storage self) internal view returns (uint256) {
        return self.elements.length;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./Math.sol";

error FixedPointMathMulDivOverflow(uint256 prod1, uint256 denominator);
error FixedPointMathExpArgumentTooBig(uint256 a);
error FixedPointMathExp2ArgumentTooBig(uint256 a);
error FixedPointMathLog2ArgumentTooBig(uint256 a);

/// @title Fixed point math implementation
library FixedPointMath {
    uint256 internal constant SCALE = 1e18;
    uint256 internal constant HALF_SCALE = 5e17;
    /// @dev Largest power of two divisor of scale.
    uint256 internal constant SCALE_LPOTD = 262144;
    /// @dev Scale inverted mod 2**256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661508869554232690281;
    uint256 internal constant LOG2_E = 1_442695040888963407;

    function mul(uint256 a, uint256 b) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert FixedPointMathMulDivOverflow(prod1, SCALE);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(a, b, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            assembly {
                result := add(div(prod0, SCALE), roundUpUnit)
            }
            return result;
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 result) {
        result = mulDiv(a, SCALE, b);
    }

    /// @notice Calculates ⌊a × b ÷ denominator⌋ with full precision.
    /// @dev Credit to Remco Bloemen under MIT license https://2π.com/21/muldiv.
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= denominator) {
            revert FixedPointMathMulDivOverflow(prod1, denominator);
        }

        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)

            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        unchecked {
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, lpotdod)
                prod0 := div(prod0, lpotdod)
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }
            prod0 |= prod1 * lpotdod;

            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = prod0 * inverse;
        }
    }

    function exp2(uint256 x) internal pure returns (uint256 result) {
        if (x >= 192e18) {
            revert FixedPointMathExp2ArgumentTooBig(x);
        }

        unchecked {
            x = (x << 64) / SCALE;

            result = 0x800000000000000000000000000000000000000000000000;
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (x == 0) {
            result = y == 0 ? SCALE : uint256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    function log2(uint256 x) internal pure returns (uint256 result) {
        if (x < SCALE) {
            revert FixedPointMathLog2ArgumentTooBig(x);
        }
        unchecked {
            uint256 n = Math.mostSignificantBit(x / SCALE);

            result = n * SCALE;

            uint256 y = x >> n;

            if (y == SCALE) {
                return result;
            }

            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                if (y >= 2 * SCALE) {
                    result += delta;

                    y >>= 1;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function abs(int256 a) internal pure returns (uint256) {
        return a >= 0 ? uint256(a) : uint256(-a);
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }
        uint256 xAux = x;
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        uint256 repeat = 7;
        while (repeat > 0) {
            result = (result + x / result) >> 1;
            repeat--;
        }
        uint256 roundedDownResult = x / result;

        return result >= roundedDownResult ? roundedDownResult : result;
    }

    function fpsqrt(uint256 a) internal pure returns (uint256 result) {
        if (a == 0) result = 0;
        else result = sqrt(a) * 1e9;
    }

    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./../interfaces/IERC20.sol";
import "./Address.sol";

error SafeERC20NoReturnData();

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        callWithOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, amount));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        callWithOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, amount));
    }

    function callWithOptionalReturn(IERC20 token, bytes memory data) internal {
        address tokenAddress = address(token);

        bytes memory returnData = tokenAddress.functionCall(data, "SafeERC20: low-level call failed");
        if (returnData.length > 0) {
            if (!abi.decode(returnData, (bool))) {
                revert SafeERC20NoReturnData();
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./Address.sol";

error EIP1967ImplementationIsNotContract(address implementation);
error ContractAlreadyInitialized();
error OnlyProxyCallAllowed();
error OnlyCurrentImplementationAllowed();

library EIP1967 {
    using Address for address;

    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed newImplementation);

    function upgradeTo(address newImplementation) internal {
        if (!newImplementation.isContract()) {
            revert EIP1967ImplementationIsNotContract(newImplementation);
        }

        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }

        emit Upgraded(newImplementation);
    }

    function getImplementation() internal view returns (address implementation) {
        assembly {
            implementation := sload(IMPLEMENTATION_SLOT)
        }
    }
}

contract Proxy {
    using Address for address;

    constructor(address implementation, bytes memory data) {
        EIP1967.upgradeTo(implementation);
        implementation.delegateCall(data, "Proxy: construction failed");
    }

    receive() external payable {
        delegateCall();
    }

    fallback() external payable {
        delegateCall();
    }

    function delegateCall() internal {
        address implementation = EIP1967.getImplementation();

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

abstract contract Upgradeable {
    address private immutable self = address(this);

    modifier onlyProxy() {
        if (address(this) == self) {
            revert OnlyProxyCallAllowed();
        }
        if (EIP1967.getImplementation() != self) {
            revert OnlyCurrentImplementationAllowed();
        }
        _;
    }

    function upgradeTo(address newImplementation) public virtual onlyProxy {
        EIP1967.upgradeTo(newImplementation);
    }
}

abstract contract Initializable {
    bool private initializing;
    bool private initialized;

    modifier initializer() {
        if (!initializing && initialized) {
            revert ContractAlreadyInitialized();
        }

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }
}