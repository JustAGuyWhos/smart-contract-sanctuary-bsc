// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

import "./utils/FactoryOwnable.sol";
import "./Erc20Bond.sol";
import "./BondCalculator.sol";
import "./Treasury.sol";

contract BondFactory is FactoryOwnable {

/*
  BondCalculator calculator;
  BondCalculator [] public list_of_calculators;

  Treasury treasury;
  Treasury[] public list_of_treasuries;

  Erc20Bond bond;
  Erc20Bond[] public list_of_bonds;
  */
    /* ======== STATE VARIABLS ======== */
address public mizuTreasury;

    /* ======== CONSTRUCTION ======== */
    
    constructor(address _mizuTreasury) {
        require( _mizuTreasury != address(0) );
        _mizuTreasury = mizuTreasury;
        }

    /* ======== OWNER FUNCTIONS ======== */
    
    /**
        @notice deploys custom treasury and custom bond contracts and returns address of both
        @param _payoutToken address
        @param _principleToken address
        @param _scholar address
        @param _foundation address
        @param _dao address
        @param _limitAmount address
        @param _Zap address
        @param _initialAdmin address
        @return _calculator address
        @return _treasury address
        @return _bond address
     */
    function createBondTreasuryCalc(address _payoutToken,
     address _principleToken,
     address _scholar,
     address _foundation,
     address _dao,
     uint256 _limitAmount,
     address _Zap,
     address _initialAdmin,
     address _LP
        ) external onlyOwner() returns(address _calculator, address _treasury, address _bond) {

        BondCalculator calculator = new BondCalculator(_payoutToken);
        //list_of_calculators.push(calculator);

        Treasury treasury = new Treasury(_payoutToken, _principleToken, _scholar, _foundation,
         _dao, _limitAmount, _Zap, _initialAdmin);
        //list_of_treasuries.push(treasury);

        Erc20Bond bond = new Erc20Bond(_payoutToken, _principleToken, address(treasury), _dao,
         address(calculator), _LP, _initialAdmin);
        //list_of_bonds.push(bond);


        /* 
        return IOlympusProFactoryStorage(olympusProFactoryStorage).pushBond(
            _payoutToken, _principleToken, address(treasury), address(bond), _initialAdmin, _tierCeilings, _fees
        ); 
        */
    }

    /**
        @notice deploys custom treasury and custom bond contracts and returns address of both
        @param _payoutToken address
        @param _payinToken address
        @param _treasury address
        @param _DAO address
        @param _bondCalculator address
        @param _LP address
        @param _initialAdmin address
        @return _treasury address
        @return _bond address
     */
    function createBond(address _payoutToken,
        address _payinToken,
        address _treasuryAddr,
        address _DAO,
        address _bondCalculator,
        address _LP,
        address _initialAdmin) external onlyOwner() returns(address _treasury, address _bond) {

        Erc20Bond bond = new Erc20Bond(_payoutToken, _payinToken, _treasuryAddr, _DAO,
         _bondCalculator, _LP, _initialAdmin);
        //list_of_bonds.push(bond);

        /* 
        return IOlympusProFactoryStorage(olympusProFactoryStorage).pushBond(
            _payoutToken, _principleToken, _customTreasury, address(bond), _initialAdmin, _tierCeilings, _fees
        );
        */
    }
    
    function createCalculator(address _payoutToken) external onlyOwner() returns(address _calculator) {
        BondCalculator calculator = new BondCalculator(_payoutToken);
        //list_of_calculators.push(calculator);
    }

}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

import "./utils/SafeMath.sol";
import "./utils/SafeERC20.sol";
import "./utils/LowGasSafeMath.sol";
import "./utils/BondOwnable.sol";
import "./utils/Address.sol";
import "./utils/interfaces/IERC20.sol";
import "./zap/interfaces/IZap.sol";

contract Treasury is BondOwnable {

    using LowGasSafeMath for uint;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;

    event Deposit( address indexed token, uint amount, uint value );
    event BondContractToggled(address bondContract, bool approved);
    event Withdraw(address token, address destination, uint amount);
    //event ClaimAirdrop(address airdropToken, uint airdropAmount);
    event ReservesManaged( address indexed token, uint amount );
    event ReservesUpdated( uint indexed totalReserves );
    event ReservesAudited( uint indexed totalReserves );
    event RewardsMinted( address indexed caller, address indexed recipient, uint amount );
    event ChangeLimitAmount( uint256 amount );

    address public immutable payoutToken;
    mapping(address => bool) public bondContract; 
    address[] public reserveTokens; // Push only, beware false-positives.
    mapping( address => bool ) public isReserveToken;
    address[] public liquidityTokens; // Push only, beware false-positives.
    mapping( address => bool ) public isLiquidityToken;
    mapping( address => uint256 ) public hourlyLimitAmounts; // tracks amounts
    mapping( address => uint32 ) public hourlyLimitQueue; // Delays changes to mapping.

    uint256 public limitAmount;
    //address public immutable airdropToken;
    //uint    public immutable airdropRatio; // int
    address public immutable scholar;
    address public immutable foundation;
    address public immutable dao;
    bool public immutable isZap;
    address public immutable initialOwner; // address of contract creator


    uint public totalReserves; // Risk-free value of all assets
    uint public totalDebt;
    IZap public immutable Zap;

    constructor (
        address _payoutToken, // to payoutToken
        address _principle, // liquidityToken (payment)
        //address _airdropToken, // address token
        //uint _airdropRatio, // payout / airdrop ratio
        address _scholar, 
        address _foundation, 
        address _dao,
        uint256 _limitAmount,
        address _Zap,
        address _initialOwner
    ) BondOwnable(_initialOwner){
        require( _payoutToken != address(0) );
        payoutToken = _payoutToken;
        isReserveToken[ _payoutToken ] = true;
        reserveTokens.push( _payoutToken );
        isLiquidityToken[ _principle ] = true;
        liquidityTokens.push( _principle );
        //require( _airdropToken != address(0) );
        //airdropToken = _airdropToken;
        //airdropRatio = _airdropRatio;
        require( _scholar != address(0) );
        scholar = _scholar;
        require( _foundation != address(0) );
        foundation = _foundation;
        require( _dao != address(0) );
        dao = _dao;
        limitAmount = _limitAmount;
        Zap = IZap(_Zap);
        isZap = (_Zap != address(0));
        require( _initialOwner != address(0) );
        initialOwner = _initialOwner;
    }

    function setLimitAmount(uint amount) external onlyAdmin {
        limitAmount = amount;
        emit ChangeLimitAmount(limitAmount);
    }

    /* ======== BOND CONTRACT FUNCTION ======== */

    function deposit(address _principleTokenAddress, 
    uint _amountPrincipleToken, 
    uint _amountPayoutToken, 
    address _LP) external {
        require(bondContract[msg.sender], "msg.sender is not a bond contract");

        //uint toFoundation = _amountPrincipleToken.div(100).mul(25);
        //uint toScholar = _amountPrincipleToken.div(100).mul(10);
        //uint toDao = _amountPrincipleToken.div(100).mul(65);

        //Integrate IZap to convert payin in LP
        if (isZap) {
            //IERC20(_principleTokenAddress).approve(address(Zap), _amountPrincipleToken);
            Zap.zapInToken(_principleTokenAddress, _amountPrincipleToken, _LP );
            IERC20(_LP).safeTransferFrom(msg.sender, address(dao), _amountPrincipleToken);
        
        } else {
            IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(dao), _amountPrincipleToken);
        }

        //IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(scholar), toScholar);
        //IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(foundation), toFoundation);
        //IERC20(_principleTokenAddress).safeTransferFrom(msg.sender, address(dao), toDao);

        IERC20(payoutToken).safeTransfer(msg.sender, _amountPayoutToken);
        
        emit Deposit( _principleTokenAddress, _amountPrincipleToken, _amountPayoutToken );
    }

    /* ======== VIEW FUNCTION ======== */
    
    function valueOf( address _principleTokenAddress, uint _amount ) public view returns ( uint value_ ) {
        // convert amount to match payout token decimals
        value_ = _amount.mul(
             10 ** IERC20( payoutToken ).decimals() ).div( 10 ** IERC20( _principleTokenAddress ).decimals() );
    }

    /* ======== POLICY FUNCTIONS ======== */

    function withdraw(address _token, address _destination, uint _amount) external onlyAdmin(){
        IERC20(_token).safeTransfer(_destination, _amount);

        emit Withdraw(_token, _destination, _amount);
    }

    /* function claimAirdrop(address _airdropToken, uint _airdropAmount) external {
        require(bondContract[msg.sender], "msg.sender is not a bond contract");
            IERC20(_airdropToken).safeTransfer(msg.sender, _airdropAmount);

            emit ClaimAirdrop(_airdropToken, _airdropAmount);
    } */

    function recoverLostETH() external onlyAdmin() returns ( bool ) {
        if (address(this).balance > 0) safeTransferETH(dao, address(this).balance);
        return true;
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }

    function toggleBondContract(address _bondContract) external onlyAdmin() {
        bondContract[_bondContract] = !bondContract[_bondContract];

        emit BondContractToggled(_bondContract, bondContract[_bondContract]);
    }

    function auditReserves() external onlyAdmin {
        uint reserves;
        for( uint i = 0; i < reserveTokens.length; i++ ) {
            reserves = reserves.add ( 
                valueOf( reserveTokens[ i ], IERC20( reserveTokens[ i ] ).balanceOf( address(this) ) )
            );
        }
        for( uint i = 0; i < liquidityTokens.length; i++ ) {
            reserves = reserves.add (
                valueOf( liquidityTokens[ i ], IERC20( liquidityTokens[ i ] ).balanceOf( address(this) ) )
            );
        }
        totalReserves = reserves;
        emit ReservesUpdated( reserves );
        emit ReservesAudited( reserves );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

import "./utils/FullMath.sol";
import "./utils/Babylonian.sol";
import "./utils/BitMath.sol";
import "./utils/FixedPoint.sol";
import "./utils/SafeMath.sol";
import "./utils/interfaces/IERC20.sol";
import "./utils/interfaces/IUniswapV2Pair.sol";

interface IBondCalculatorVal {
  function valuation( address pair_, uint amount_ ) external view returns ( uint _value );
}

contract BondCalculator is IBondCalculatorVal {

    using FixedPoint for *;
    using SafeMath for uint;
    using SafeMath for uint112;

    address public immutable PAYOUT_TOKEN;

    constructor( address _PAYOUT_TOKEN ) {
        require( _PAYOUT_TOKEN != address(0) );
        PAYOUT_TOKEN = _PAYOUT_TOKEN;
    }

    function getKValue( address _pair ) public view returns( uint k_ ) {
        uint token0 = IERC20( IUniswapV2Pair( _pair ).token0() ).decimals();
        uint token1 = IERC20( IUniswapV2Pair( _pair ).token1() ).decimals();
        uint decimals = token0.add( token1 ).sub( IERC20( _pair ).decimals() );

        (uint reserve0, uint reserve1, ) = IUniswapV2Pair( _pair ).getReserves();
        k_ = reserve0.mul(reserve1).div( 10 ** decimals );
    }
    
    function ratioCalc( address _pair ) public view returns( uint kRatio_ ) {
        uint token0 = IERC20( IUniswapV2Pair( _pair ).token0() ).decimals();
        uint token1 = IERC20( IUniswapV2Pair( _pair ).token1() ).decimals();
        uint decimals = token0.add( token1 ).sub( IERC20( _pair ).decimals() );

        (uint reserve0, uint reserve1, ) = IUniswapV2Pair( _pair ).getReserves();
        kRatio_ = reserve0.div(reserve1).mul( 10 ** 18 ).div( 10 ** decimals );
    }

    function getTotalValue( address _pair ) public view returns ( uint _value ) {
        _value = getKValue( _pair ).sqrrt().mul(2);
    }

    function valuation( address _pair, uint amount_ ) external view override returns ( uint _value ) {
        uint totalValue = getTotalValue( _pair );
        uint totalSupply = IUniswapV2Pair( _pair ).totalSupply();

        _value = totalValue.mul( FixedPoint.fraction( amount_, totalSupply ).decode112with18() ).div( 1e18 );
    }

    function markdown( address _pair ) external view returns ( uint ) {
        ( uint reserve0, uint reserve1, ) = IUniswapV2Pair( _pair ).getReserves();

        uint reserve;
        if ( IUniswapV2Pair( _pair ).token0() == PAYOUT_TOKEN ) {
            reserve = reserve1;
        } else {
            reserve = reserve0;
        }
        return reserve.mul( 2 * ( 10 ** IERC20( PAYOUT_TOKEN ).decimals() ) ).div( getTotalValue( _pair ) );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;
pragma abicoder v2;

import "./utils/interfaces/IOwnable.sol";
import "./utils/BondOwnable.sol";
import "./utils/LowGasSafeMath.sol";
import "./utils/Address.sol";
import "./utils/interfaces/IERC20.sol";
import "./utils/SafeERC20.sol";
import "./utils/FullMath.sol";
import "./utils/FixedPoint.sol";
import "./utils/interfaces/ITreasury.sol";
import "./utils/interfaces/IWETH.sol";

interface IBondCalculator {
    function markdown(address _pair) external view returns (uint256);
    function ratioCalc(address _pair) external view returns (uint256);
    function valuation(address _pair, uint256 _amount) external view returns (uint256);
}

contract Erc20Bond is BondOwnable {
    using FixedPoint for *;
    using SafeERC20 for IERC20;
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for uint32;

    /* ======== EVENTS ======== */

    event BondCreated(
        uint256 deposit,
        uint256 indexed payout,
        uint256 indexed expires,
        uint256 indexed priceInUSD
    );
    event BondRedeemed(
        address indexed recipient,
        uint256 payout,
        uint256 remaining
    );
    event BondPriceChanged(
        uint256 indexed priceInUSD,
        uint256 indexed internalPrice,
        uint256 indexed debtRatio
    );
    event ControlVariableAdjustment(
        uint256 initialBCV,
        uint256 newBCV,
        uint256 adjustment,
        bool addition
    );
    event InitTerms(Terms terms);
    event LogSetTerms(PARAMETER param, uint256 value);
    event LogSetAdjustment(Adjust adjust);
    event LogRecoverLostToken(address indexed tokenToRecover, uint256 amount);

    /* ======== STATE VARIABLES ======== */

    IERC20 public immutable payoutToken; // token given as payment for bond
    IERC20 public immutable payinToken; // token used to create bond
    ITreasury public immutable treasury; // mints payoutToken when receives payinToken
    address public immutable DAO; // receives profit share from bond
    IERC20 public immutable LP;
    address public immutable initialOwner; // address of contract creator

    bool public immutable isLiquidityBond;
    bool public immutable isLP; // LP and Reserve bonds are treated slightly different
    IBondCalculator public immutable bondCalculator; // calculates value of LP tokens

    Terms public terms; // stores terms for new bonds
    Adjust public adjustment; // stores adjustment to BCV data

    mapping(address => Bond) public bondInfo; // stores bond information for depositors

    uint256 public totalDebt; // total value of outstanding bonds; used for pricing
    uint32 public lastDecay; // reference time for debt decay

    mapping(address => bool) public allowedZappers;

    /* ======== STRUCTS ======== */

    // Info for creating new bonds
    struct Terms {
        uint256 controlVariable; // scaling variable for price
        uint256 minimumPrice; // vs payinToken value
        uint256 maxPayout; // in thousandths of a %. i.e. 500 = 0.5%
        uint256 fee; // as % of bond payout, in hundreths. ( 500 = 5% = 0.05 for every 1 paid)
        uint256 maxDebt; // 9 decimal debt ratio, max % total supply created as debt
        uint256 ratio;
        uint32 vestingTerm; // in seconds
    }

    // Info for bond holder
    struct Bond {
        uint256 payout; // payoutToken remaining to be paid
        uint256 pricePaid; // In DAI, for front end viewing
        uint32 lastTime; // Last interaction
        uint32 vesting; // Seconds left to vest
    }

    // Info for incremental adjustments to control variable
    struct Adjust {
        bool add; // addition or subtraction
        uint256 rate; // increment
        uint256 target; // BCV when adjustment finished
        uint32 buffer; // minimum length (in seconds) between adjustments
        uint32 lastTime; // time when last adjustment made
    }

    /* ======== INITIALIZATION ======== */

    constructor(
        address _payoutToken,
        address _payinToken,
        address _treasury,
        address _DAO,
        address _bondCalculator,
        address _LP,
        address _initialOwner
    ) BondOwnable(_initialOwner){
        require(_payoutToken != address(0));
        payoutToken = IERC20(_payoutToken);
        require(_payinToken != address(0));
        payinToken = IERC20(_payinToken);
        require(_treasury != address(0));
        treasury = ITreasury(_treasury);
        require(_DAO != address(0));
        DAO = _DAO;
        // bondCalculator should be address(0) if not LP bond
        bondCalculator = IBondCalculator(_bondCalculator);
        isLiquidityBond = (_bondCalculator != address(0));
        LP = IERC20(_LP);
        isLP = (_LP != address(0));
        require( _initialOwner != address(0) );
        initialOwner = _initialOwner;
    }

    function initializeBondTerms(
        uint256 _controlVariable,
        uint256 _minimumPrice,
        uint256 _maxPayout,
        uint256 _fee,
        //uint _airdropRatio,
        uint256 _maxDebt,
        uint256 _ratio,
        uint32 _vestingTerm
    ) external onlyAdmin {
        require(terms.controlVariable == 0, "Bonds must be initialized from 0");
        require(_controlVariable >= 40, "Can lock adjustment");
        terms = Terms({
            controlVariable: _controlVariable,
            minimumPrice: _minimumPrice,
            maxPayout: _maxPayout,
            fee: _fee,
            //airdropRatio: _airdropRatio,
            maxDebt: _maxDebt,
            ratio: _ratio,
            vestingTerm: _vestingTerm
        });
        lastDecay = uint32(block.timestamp);
        emit InitTerms(terms);
    }

    /* ======== POLICY FUNCTIONS ======== */

    enum PARAMETER {
        VESTING,
        PAYOUT,
        FEE,
        DEBT,
        MINPRICE,
        RATIO,
        AIRDROPRATIO
    }

    function setBondTerms(PARAMETER _parameter, uint256 _input)
        external
        onlyAdmin
    {
        if (_parameter == PARAMETER.VESTING) {
            // 0
            require(_input >= 86400, "Vesting must be longer than 24 hours");
            terms.vestingTerm = uint32(_input);
        } else if (_parameter == PARAMETER.PAYOUT) {
            // 1
            terms.maxPayout = _input;
        } else if (_parameter == PARAMETER.FEE) {
            // 2
            terms.fee = _input;
        } else if (_parameter == PARAMETER.DEBT) {
            // 3
            terms.maxDebt = _input;
        } else if (_parameter == PARAMETER.MINPRICE) {
            // 4
            terms.minimumPrice = _input;
        } else if (_parameter == PARAMETER.RATIO) {
            // 5
            terms.ratio = _input;
            /* } else if ( _parameter == PARAMETER.AIRDROPRATIO ) { // 6
            terms.airdropRatio = _input; */
        }
        emit LogSetTerms(_parameter, _input);
    }

    function setAdjustment(
        bool _addition,
        uint256 _increment,
        uint256 _target,
        uint32 _buffer
    ) external onlyAdmin {
        require(
            _increment <= terms.controlVariable.mul(25) / 1000,
            "Increment too large"
        );
        require(_target >= 40, "Next Adjustment could be locked");
        adjustment = Adjust({
            add: _addition,
            rate: _increment,
            target: _target,
            buffer: _buffer,
            lastTime: uint32(block.timestamp)
        });
        emit LogSetAdjustment(adjustment);
    }

    function allowZapper(address zapper) external onlyAdmin {
        require(zapper != address(0), "ZNA");

        allowedZappers[zapper] = true;
    }

    function removeZapper(address zapper) external onlyAdmin {
        allowedZappers[zapper] = false;
    }

    /* ======== USER FUNCTIONS ======== */

    function deposit(
        uint256 _amount,
        uint256 _maxPrice,
        address _depositor
    ) external payable returns (uint256) {
        require(_depositor != address(0), "Invalid address");
        require(msg.sender == _depositor || allowedZappers[msg.sender], "LFNA");
        decayDebt();

        uint256 nativePrice = _bondPrice();

        require(
            _maxPrice >= nativePrice,
            "Slippage limit: more than max price"
        ); // slippage protection

        uint256 value;
        uint256 payout;

        //require( payout >= 1500000000000000000000, "Bond too small" ); // 15kk
        //require( payout <= 15000000000000000000000000, "Bond too large"); // 1500

        if (isLiquidityBond) {
            value = _amount.mul(ratioLP());
            payout = payoutFor(value);
        } else {
            value = _amount.mul(terms.ratio);
            payout = payoutFor(value);
        }

        require(totalDebt <= terms.maxDebt, "Max capacity reached");

        payinToken.safeTransferFrom(msg.sender, address(this), _amount);
        payinToken.approve(address(treasury), _amount);
        treasury.deposit(address(payinToken), _amount, payout, address(LP));

        totalDebt = totalDebt.add(value);

        bondInfo[_depositor] = Bond({
            payout: bondInfo[_depositor].payout.add(payout),
            vesting: terms.vestingTerm,
            lastTime: uint32(block.timestamp),
            pricePaid: value
        });

        emit BondCreated(
            _amount,
            payout,
            block.number.add(terms.vestingTerm),
            value
        );
        //emit BondPriceChanged( bondPriceInUSD(), _bondPrice(), debtRatio() );

        adjust(); // control variable is adjusted
        return payout;
    }

    function redeem(address _recipient) external returns (uint256) {
        require(msg.sender == _recipient, "NA");
        Bond memory info = bondInfo[_recipient];
        // (seconds since last interaction / vesting term remaining)
        uint256 percentVested = percentVestedFor(_recipient);

        if (percentVested >= 10000) {
            // if fully vested
            delete bondInfo[_recipient]; // delete user info
            emit BondRedeemed(_recipient, info.payout, 0); // emit bond data
            //return stakeOrSend( _recipient, _stake, info.payout ); // pay user everything due
            payoutToken.transfer(_recipient, info.payout);
            return info.payout;
        } else {
            // if unfinished
            // calculate payout vested
            uint256 payout = info.payout.mul(percentVested) / 10000;
            // store updated deposit info
            bondInfo[_recipient] = Bond({
                payout: info.payout.sub(payout),
                vesting: info.vesting.sub32(
                    uint32(block.timestamp).sub32(info.lastTime)
                ),
                lastTime: uint32(block.timestamp),
                pricePaid: info.pricePaid
            });

            emit BondRedeemed(_recipient, payout, bondInfo[_recipient].payout);
            //return stakeOrSend( _recipient, _stake, payout );
            payoutToken.transfer(_recipient, payout);
            return payout;
        }
    }

    /* ======== INTERNAL HELPER FUNCTIONS ======== */

    function adjust() internal {
        uint256 timeCanAdjust = adjustment.lastTime.add32(adjustment.buffer);
        if (adjustment.rate != 0 && block.timestamp >= timeCanAdjust) {
            uint256 initial = terms.controlVariable;
            uint256 bcv = initial;
            if (adjustment.add) {
                bcv = bcv.add(adjustment.rate);
                if (bcv >= adjustment.target) {
                    adjustment.rate = 0;
                    bcv = adjustment.target;
                }
            } else {
                bcv = bcv.sub(adjustment.rate);
                if (bcv <= adjustment.target) {
                    adjustment.rate = 0;
                    bcv = adjustment.target;
                }
            }
            terms.controlVariable = bcv;
            adjustment.lastTime = uint32(block.timestamp);
            emit ControlVariableAdjustment(
                initial,
                bcv,
                adjustment.rate,
                adjustment.add
            );
        }
    }

    function decayDebt() internal {
        totalDebt = totalDebt.sub(debtDecay());
        lastDecay = uint32(block.timestamp);
    }

    /* ======== VIEW FUNCTIONS ======== */
    function ratioLP() public view returns (uint256) {
        return bondCalculator.ratioCalc(address(LP));
    }

    function maxPayout() public view returns (uint256) {
        return terms.maxPayout;
    }

    function maxDebt() public view returns (uint256) {
        return terms.maxDebt;
    }

    function payoutFor(uint256 _value) public view returns (uint256) {
        return
            FixedPoint.fraction(_value, bondPrice()).decode112with18() / 1e16; /* * terms.ratio */
    }

    //////////////TO_TEST
    /* function payoutForInUsd( uint _value ) public view returns ( uint ) {
        return FixedPoint.fraction( _value, bondPriceInUSD() ).decode112with18() / 1e16 * terms.ratio;
    } */

    function bondPrice() public view returns (uint256 price_) {
        price_ = terms.controlVariable.mul(debtRatio()).add(1000000000) / 1e7;
        if (price_ < terms.minimumPrice) {
            price_ = terms.minimumPrice;
        }
    }

    function _bondPrice() internal returns (uint256 price_) {
        price_ = terms.controlVariable.mul(debtRatio()).add(1000000000) / 1e7;
        if (price_ < terms.minimumPrice) {
            price_ = terms.minimumPrice;
        } else if (terms.minimumPrice != 0) {
            terms.minimumPrice = 0;
        }
    }

    function bondPriceInUSD() public view returns (uint256 price_) {
        if (isLiquidityBond) {
            price_ =
                bondPrice().mul(bondCalculator.ratioCalc(address(LP))) /
                100;
        } else {
            price_ = bondPrice().mul(10**payinToken.decimals()) / 100;
        }
    }

    function debtRatio() public view returns (uint256 debtRatio_) {
        uint256 supply = payoutToken.totalSupply();
        debtRatio_ =
            FixedPoint
                .fraction(currentDebt().mul(1e9), supply)
                .decode112with18() /
            1e18;
    }

    /* function standardizedDebtRatio() external view returns ( uint ) {
        if ( isLiquidityBond ) {
            return debtRatio().mul( bondCalculator.markdown( address(LP) ) ) / 1e9;
        } else {
            return debtRatio();
        }
    } */

    function currentDebt() public view returns (uint256) {
        return totalDebt.sub(debtDecay()) * terms.ratio;
    }

    function debtDecay() public view returns (uint256 decay_) {
        uint32 timeSinceLast = uint32(block.timestamp).sub32(lastDecay);
        decay_ = totalDebt.mul(timeSinceLast) / terms.vestingTerm;
        if (decay_ > totalDebt) {
            decay_ = totalDebt;
        }
    }

    function percentVestedFor(address _depositor)
        public
        view
        returns (uint256 percentVested_)
    {
        Bond memory bond = bondInfo[_depositor];
        uint256 secondsSinceLast = uint32(block.timestamp).sub32(bond.lastTime);
        uint256 vesting = bond.vesting;

        if (vesting > 0) {
            percentVested_ = secondsSinceLast.mul(10000) / vesting;
        } else {
            percentVested_ = 0;
        }
    }

    function pendingPayoutFor(address _depositor)
        external
        view
        returns (uint256 pendingPayout_)
    {
        uint256 percentVested = percentVestedFor(_depositor);
        uint256 payout = bondInfo[_depositor].payout;

        if (percentVested >= 10000) {
            pendingPayout_ = payout;
        } else {
            pendingPayout_ = payout.mul(percentVested) / 10000;
        }
    }

    /* ======= AUXILLIARY ======= */

    function recoverLostToken(IERC20 _token) external returns (bool) {
        require(_token != payoutToken, "NAT");
        require(_token != payinToken, "NAP");
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(DAO, balance);
        emit LogRecoverLostToken(address(_token), balance);
        return true;
    }

    function emergency(IERC20 _token) external onlyAdmin returns (bool) {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(DAO, balance);
        return true;
    }
}

pragma solidity 0.7.5;

contract FactoryOwnable {

    address public owner;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require( owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }
    
    function transferManagment(address _newOwner) external onlyOwner() {
        require( _newOwner != address(0) );
        owner = _newOwner;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

contract BondOwnable {

    address public admin;

    constructor (address _initialAdmin) {
        admin = _initialAdmin;
    }

    modifier onlyAdmin() {
        require( admin == msg.sender, "Ownable: caller is not the owner" );
        _;
    }
    
    function transferManagment(address _newOwner) external onlyAdmin() {
        require( _newOwner != address(0) );
        admin = _newOwner;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

library LowGasSafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function add32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require((z = x + y) >= x);
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function sub32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require((z = x - y) <= x);
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    function mul32(uint32 x, uint32 y) internal pure returns (uint32 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice Returns x + y, reverts if overflows or underflows
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice Returns x - y, reverts if overflows or underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }

    function div(uint256 x, uint256 y) internal pure returns(uint256 z){
        require(y > 0);
        z=x/y;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

library Address {

  function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function functionCall(
        address target, 
        bytes memory data, 
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(
        address target, 
        bytes memory data, 
        uint256 weiValue, 
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

    function _verifyCallResult(
        bool success, 
        bytes memory returndata, 
        string memory errorMessage
    ) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

import "./LowGasSafeMath.sol";
import "./Address.sol";
import "./interfaces/IERC20.sol";

library SafeERC20 {
    using LowGasSafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.5;

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IZap {
    function zapOut(address _from, uint amount) external;
    function zapIn(address _to) external payable;
    function zapInToken(address _from, uint amount, address _to) external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

library FullMath {
    function fullMul(uint256 x, uint256 y) private pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, uint256(-1));
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & -d;
        d /= pow2;
        l /= pow2;
        l += h * ((-pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        require(h < d, 'FullMath::mulDiv: overflow');
        return fullDiv(l, h, d);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, 'BitMath::mostSignificantBit: zero');

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

import "./FullMath.sol";
import "./Babylonian.sol";
import "./BitMath.sol";

library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = 0x10000000000000000000000000000;
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000;
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a uq112x112 into a uint with 18 decimals of precision
    function decode112with18(uq112x112 memory self) internal pure returns (uint) {
        return uint(self._x) / 5192296858534827;
    }

    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, 'FixedPoint::fraction: division by zero');
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= uint144(-1)) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= uint224(-1), 'FixedPoint::fraction: overflow');
            return uq112x112(uint224(result));
        }
    }

    // square root of a UQ112x112
    // lossy between 0/1 and 40 bits
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        if (self._x <= uint144(-1)) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

interface IUniswapV2ERC20 {
    function totalSupply() external view returns (uint);
}

interface IUniswapV2Pair is IUniswapV2ERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns ( address );
    function token1() external view returns ( address );
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

interface IOwnable {
  function policy() external view returns (address);

  function renounceManagement() external;
  
  function pushManagement( address newOwner_ ) external;
  
  function pullManagement() external;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

import "./IERC20.sol";

interface IWETH9 is IERC20 {
    function deposit() external payable;
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.5;

interface ITreasury {
    function deposit(address _principleTokenAddress, uint _amountPrincipleToken, uint _amountPayoutToken, address _LP) external;
    function claimAirdrop(address _airdropToken, uint _airdropAmount) external;
    function valueOf( address _principleTokenAddress, uint _amount ) external view returns ( uint value_ );
}