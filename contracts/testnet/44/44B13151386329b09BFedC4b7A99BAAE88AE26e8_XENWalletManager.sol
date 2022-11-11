// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IXENCrypto.sol";
import "./XENWallet.sol";
import "./YENCrypto.sol";

contract XENWalletManager is Ownable {
    using Clones for address;

    address public feeReceiver;
    address internal immutable implementation;
    address public immutable XENCrypto;
    uint256 public immutable deployTimestamp;
    YENCrypto public immutable ownToken;

    uint256 public totalWallets;
    uint256 public activeWallets;
    mapping(address => address[]) internal unmintedWallets;

    uint32[250] internal weeklyRewardMultiplier;

    uint256 internal constant SECONDS_IN_DAY = 3_600 * 24;
    uint256 internal constant SECONDS_IN_WEEK = SECONDS_IN_DAY * 7;
    uint256 internal constant MIN_TOKEN_MINT_TERM = 50;
    uint256 internal constant MIN_REWARD_LIMIT = SECONDS_IN_DAY * 2;
    uint256 internal constant RESCUE_FEE = 4700; // 47%
    uint256 internal constant MINT_FEE = 500; // 5%

    constructor(
        address xenCrypto,
        address walletImplementation,
        address feeAddress
    ) {
        XENCrypto = xenCrypto;
        implementation = walletImplementation;
        feeReceiver = feeAddress;
        ownToken = new YENCrypto(address(this));
        deployTimestamp = block.timestamp;

        populateRates();
    }

    //////////////////  VIEWS

    function getSalt(uint256 _id) public view returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender, _id));
    }

    function getDeterministicAddress(bytes32 salt)
        public
        view
        returns (address)
    {
        return implementation.predictDeterministicAddress(salt);
    }

    /// @notice Number of elapsed weeks after deployment
    function getElapsedWeeks() public view returns (uint256) {
        return (block.timestamp - deployTimestamp) / SECONDS_IN_WEEK;
    }

    /// @dev Get number of active mint wallets
    function getActiveWallets() external view returns (uint256) {
        return activeWallets;
    }

    /// @dev Get number of wallets that have batch minted
    function getTotalWallets() external view returns (uint256) {
        return totalWallets;
    }

    /// @dev Get wallet count for a wallet owner
    function getWalletCount(address _owner) public view returns (uint256) {
        return unmintedWallets[_owner].length;
    }

    /// @dev Get wallets using pagination approach
    function getWallets(
        address _owner,
        uint256 _startId,
        uint256 _endId
    ) external view returns (address[] memory) {
        uint256 size = _endId - _startId + 1;
        address[] memory wallets = new address[](size);
        for (uint256 id = _startId; id <= _endId; id++) {
            wallets[id - _startId] = unmintedWallets[_owner][id];
        }
        return wallets;
    }

    /// @notice Mint infos for an array of addresses
    function getUserInfos(address[] calldata owners)
        external
        view
        returns (IXENCrypto.MintInfo[] memory infos)
    {
        infos = new IXENCrypto.MintInfo[](owners.length);
        for (uint256 i = 0; i < owners.length; ++i) {
            infos[i] = XENWallet(owners[i]).getUserMint();
        }
    }

    /// @notice Limits range for reward multiplier
    /// @return Returns weekly reward multiplier at specific week
    function getWeeklyRewardMultiplier(int256 _index)
        internal
        view
        virtual
        returns (uint256)
    {
        if (_index < 0) return 0;
        if (_index >= int256(weeklyRewardMultiplier.length))
            return weeklyRewardMultiplier[249];
        return weeklyRewardMultiplier[uint256(_index)];
    }

    /// @notice Calculates reward multiplier
    /// @dev Exposes reward multiplier to frontend
    /// @param _elapsedWeeks The number of weeks that has elapsed
    /// @param _termWeeks The term limit in weeks
    function getRewardMultiplier(uint256 _elapsedWeeks, uint256 _termWeeks)
        public
        view
        returns (uint256)
    {
        require(_elapsedWeeks >= _termWeeks, "Incorrect term format");
        return
            getWeeklyRewardMultiplier(int256(_elapsedWeeks)) -
            getWeeklyRewardMultiplier(int256(_elapsedWeeks - _termWeeks) - 1);
    }

    /// @notice Get adjusted mint amount based on reward multiplier
    /// @param _originalAmount The original mint amount without adjustment
    /// @param _termSeconds The term limit in seconds
    function getAdjustedMintAmount(
        uint256 _originalAmount,
        uint256 _termSeconds
    ) internal view virtual returns (uint256) {
        uint256 elapsedWeeks = getElapsedWeeks();
        uint256 termWeeks = _termSeconds / SECONDS_IN_WEEK;
        return
            (_originalAmount * getRewardMultiplier(elapsedWeeks, termWeeks)) /
            1_000_000_000;
    }

    ////////////////// STATE CHANGING FUNCTIONS

    // Create wallets
    function createWallet(uint256 _id, uint256 term) internal {
        bytes32 salt = getSalt(_id);
        XENWallet clone = XENWallet(implementation.cloneDeterministic(salt));

        clone.initialize(XENCrypto, address(this));
        clone.claimRank(term);

        unmintedWallets[msg.sender].push(address(clone));
    }

    function batchCreateWallets(uint256 amount, uint256 term) external {
        require(term >= MIN_TOKEN_MINT_TERM, "Too short term");

        uint256 existing = unmintedWallets[msg.sender].length;
        for (uint256 id = 0; id < amount; id++) {
            createWallet(id + existing, term);
        }

        totalWallets += amount;
        activeWallets += amount;
    }

    // Claims rewards and sends them to the wallet owner
    function batchClaimAndTransferMintReward(uint256 _startId, uint256 _endId)
        external
    {
        require(_endId >= _startId, "Forward ordering");

        uint256 claimed = 0;
        uint256 averageTerm = 0;
        uint256 walletRange = _endId - _startId + 1;

        for (uint256 id = _startId; id <= _endId; id++) {
            address proxy = unmintedWallets[msg.sender][id];

            IXENCrypto.MintInfo memory info = XENWallet(proxy).getUserMint();
            averageTerm += info.term;

            claimed += XENWallet(proxy).claimAndTransferMintReward(msg.sender);
            unmintedWallets[msg.sender][id] = address(0x0);
        }

        averageTerm = averageTerm / walletRange;
        activeWallets -= walletRange;

        if (claimed > 0) {
            uint256 toBeMinted = getAdjustedMintAmount(claimed, averageTerm);
            uint256 fee = (toBeMinted * MINT_FEE) / 10_000; // reduce minting fee
            ownToken.mint(msg.sender, toBeMinted - fee);
            ownToken.mint(feeReceiver, fee);
        }
    }

    function batchClaimMintRewardRescue(
        address walletOwner,
        uint256 _startId,
        uint256 _endId
    ) external onlyOwner {
        require(_endId >= _startId, "Forward ordering");

        IXENCrypto xenCrypto = IXENCrypto(XENCrypto);
        uint256 rescued = 0;
        uint256 averageTerm = 0;
        uint256 walletRange = _endId - _startId + 1;

        for (uint256 id = _startId; id <= _endId; id++) {
            address proxy = unmintedWallets[walletOwner][id];

            IXENCrypto.MintInfo memory info = XENWallet(proxy).getUserMint();
            averageTerm += info.term;

            if (block.timestamp > info.maturityTs + MIN_REWARD_LIMIT) {
                rescued += XENWallet(proxy).claimAndTransferMintReward(
                    address(this)
                );
                unmintedWallets[walletOwner][id] = address(0x0);
            }
        }

        averageTerm = averageTerm / walletRange;
        activeWallets -= walletRange;

        if (rescued > 0) {
            uint256 toBeMinted = getAdjustedMintAmount(rescued, averageTerm);

            uint256 xenFee = (rescued * RESCUE_FEE) / 10_000;
            uint256 mintFee = (toBeMinted * (RESCUE_FEE + MINT_FEE)) / 10_000;

            // Transfer XEN and own token

            ownToken.mint(walletOwner, toBeMinted - mintFee);
            ownToken.mint(feeReceiver, mintFee);

            xenCrypto.transfer(walletOwner, rescued - xenFee);
            xenCrypto.transfer(feeReceiver, xenFee);
        }
    }

    function changeFeeReceiver(address newReceiver) external onlyOwner {
        feeReceiver = newReceiver;
    }

    function populateRates() internal virtual {
        /*
        Precalculated values for the formula:
        // integrate 0.102586724 * 0.95^x from 0 to index
        // Calculate 5% weekly decline and compound rewards
        let _current = _precisionMultiplier * 0.102586724;
        let _cumulative = _current;
        for (let i = 0; i < _elapsedWeeks; ++i) {
            _current = (_current * 95) / 100;
            _cumulative += _current;
        }
        return _cumulative;
        */
        weeklyRewardMultiplier[0] = 102586724;
        weeklyRewardMultiplier[1] = 200044111;
        weeklyRewardMultiplier[2] = 292628630;
        weeklyRewardMultiplier[3] = 380583922;
        weeklyRewardMultiplier[4] = 464141450;
        weeklyRewardMultiplier[5] = 543521102;
        weeklyRewardMultiplier[6] = 618931770;
        weeklyRewardMultiplier[7] = 690571906;
        weeklyRewardMultiplier[8] = 758630035;
        weeklyRewardMultiplier[9] = 823285257;
        weeklyRewardMultiplier[10] = 884707718;
        weeklyRewardMultiplier[11] = 943059056;
        weeklyRewardMultiplier[12] = 998492827;
        weeklyRewardMultiplier[13] = 1051154910;
        weeklyRewardMultiplier[14] = 1101183888;
        weeklyRewardMultiplier[15] = 1148711418;
        weeklyRewardMultiplier[16] = 1193862571;
        weeklyRewardMultiplier[17] = 1236756166;
        weeklyRewardMultiplier[18] = 1277505082;
        weeklyRewardMultiplier[19] = 1316216552;
        weeklyRewardMultiplier[20] = 1352992448;
        weeklyRewardMultiplier[21] = 1387929550;
        weeklyRewardMultiplier[22] = 1421119796;
        weeklyRewardMultiplier[23] = 1452650530;
        weeklyRewardMultiplier[24] = 1482604728;
        weeklyRewardMultiplier[25] = 1511061216;
        weeklyRewardMultiplier[26] = 1538094879;
        weeklyRewardMultiplier[27] = 1563776859;
        weeklyRewardMultiplier[28] = 1588174740;
        weeklyRewardMultiplier[29] = 1611352727;
        weeklyRewardMultiplier[30] = 1633371814;
        weeklyRewardMultiplier[31] = 1654289948;
        weeklyRewardMultiplier[32] = 1674162174;
        weeklyRewardMultiplier[33] = 1693040790;
        weeklyRewardMultiplier[34] = 1710975474;
        weeklyRewardMultiplier[35] = 1728013424;
        weeklyRewardMultiplier[36] = 1744199477;
        weeklyRewardMultiplier[37] = 1759576227;
        weeklyRewardMultiplier[38] = 1774184140;
        weeklyRewardMultiplier[39] = 1788061657;
        weeklyRewardMultiplier[40] = 1801245298;
        weeklyRewardMultiplier[41] = 1813769757;
        weeklyRewardMultiplier[42] = 1825667993;
        weeklyRewardMultiplier[43] = 1836971317;
        weeklyRewardMultiplier[44] = 1847709476;
        weeklyRewardMultiplier[45] = 1857910726;
        weeklyRewardMultiplier[46] = 1867601913;
        weeklyRewardMultiplier[47] = 1876808542;
        weeklyRewardMultiplier[48] = 1885554839;
        weeklyRewardMultiplier[49] = 1893863821;
        weeklyRewardMultiplier[50] = 1901757354;
        weeklyRewardMultiplier[51] = 1909256210;
        weeklyRewardMultiplier[52] = 1916380123;
        weeklyRewardMultiplier[53] = 1923147841;
        weeklyRewardMultiplier[54] = 1929577173;
        weeklyRewardMultiplier[55] = 1935685038;
        weeklyRewardMultiplier[56] = 1941487510;
        weeklyRewardMultiplier[57] = 1946999859;
        weeklyRewardMultiplier[58] = 1952236590;
        weeklyRewardMultiplier[59] = 1957211484;
        weeklyRewardMultiplier[60] = 1961937634;
        weeklyRewardMultiplier[61] = 1966427476;
        weeklyRewardMultiplier[62] = 1970692827;
        weeklyRewardMultiplier[63] = 1974744909;
        weeklyRewardMultiplier[64] = 1978594388;
        weeklyRewardMultiplier[65] = 1982251392;
        weeklyRewardMultiplier[66] = 1985725547;
        weeklyRewardMultiplier[67] = 1989025993;
        weeklyRewardMultiplier[68] = 1992161418;
        weeklyRewardMultiplier[69] = 1995140071;
        weeklyRewardMultiplier[70] = 1997969791;
        weeklyRewardMultiplier[71] = 2000658026;
        weeklyRewardMultiplier[72] = 2003211848;
        weeklyRewardMultiplier[73] = 2005637980;
        weeklyRewardMultiplier[74] = 2007942805;
        weeklyRewardMultiplier[75] = 2010132389;
        weeklyRewardMultiplier[76] = 2012212493;
        weeklyRewardMultiplier[77] = 2014188592;
        weeklyRewardMultiplier[78] = 2016065887;
        weeklyRewardMultiplier[79] = 2017849316;
        weeklyRewardMultiplier[80] = 2019543575;
        weeklyRewardMultiplier[81] = 2021153120;
        weeklyRewardMultiplier[82] = 2022682188;
        weeklyRewardMultiplier[83] = 2024134802;
        weeklyRewardMultiplier[84] = 2025514786;
        weeklyRewardMultiplier[85] = 2026825771;
        weeklyRewardMultiplier[86] = 2028071206;
        weeklyRewardMultiplier[87] = 2029254370;
        weeklyRewardMultiplier[88] = 2030378375;
        weeklyRewardMultiplier[89] = 2031446181;
        weeklyRewardMultiplier[90] = 2032460596;
        weeklyRewardMultiplier[91] = 2033424290;
        weeklyRewardMultiplier[92] = 2034339799;
        weeklyRewardMultiplier[93] = 2035209533;
        weeklyRewardMultiplier[94] = 2036035781;
        weeklyRewardMultiplier[95] = 2036820716;
        weeklyRewardMultiplier[96] = 2037566404;
        weeklyRewardMultiplier[97] = 2038274808;
        weeklyRewardMultiplier[98] = 2038947791;
        weeklyRewardMultiplier[99] = 2039587126;
        weeklyRewardMultiplier[100] = 2040194493;
        weeklyRewardMultiplier[101] = 2040771493;
        weeklyRewardMultiplier[102] = 2041319642;
        weeklyRewardMultiplier[103] = 2041840384;
        weeklyRewardMultiplier[104] = 2042335089;
        weeklyRewardMultiplier[105] = 2042805058;
        weeklyRewardMultiplier[106] = 2043251529;
        weeklyRewardMultiplier[107] = 2043675677;
        weeklyRewardMultiplier[108] = 2044078617;
        weeklyRewardMultiplier[109] = 2044461410;
        weeklyRewardMultiplier[110] = 2044825063;
        weeklyRewardMultiplier[111] = 2045170534;
        weeklyRewardMultiplier[112] = 2045498732;
        weeklyRewardMultiplier[113] = 2045810519;
        weeklyRewardMultiplier[114] = 2046106717;
        weeklyRewardMultiplier[115] = 2046388105;
        weeklyRewardMultiplier[116] = 2046655424;
        weeklyRewardMultiplier[117] = 2046909377;
        weeklyRewardMultiplier[118] = 2047150632;
        weeklyRewardMultiplier[119] = 2047379824;
        weeklyRewardMultiplier[120] = 2047597557;
        weeklyRewardMultiplier[121] = 2047804403;
        weeklyRewardMultiplier[122] = 2048000907;
        weeklyRewardMultiplier[123] = 2048187585;
        weeklyRewardMultiplier[124] = 2048364930;
        weeklyRewardMultiplier[125] = 2048533408;
        weeklyRewardMultiplier[126] = 2048693461;
        weeklyRewardMultiplier[127] = 2048845512;
        weeklyRewardMultiplier[128] = 2048989961;
        weeklyRewardMultiplier[129] = 2049127186;
        weeklyRewardMultiplier[130] = 2049257551;
        weeklyRewardMultiplier[131] = 2049381398;
        weeklyRewardMultiplier[132] = 2049499052;
        weeklyRewardMultiplier[133] = 2049610823;
        weeklyRewardMultiplier[134] = 2049717006;
        weeklyRewardMultiplier[135] = 2049817880;
        weeklyRewardMultiplier[136] = 2049913710;
        weeklyRewardMultiplier[137] = 2050004748;
        weeklyRewardMultiplier[138] = 2050091235;
        weeklyRewardMultiplier[139] = 2050173397;
        weeklyRewardMultiplier[140] = 2050251451;
        weeklyRewardMultiplier[141] = 2050325602;
        weeklyRewardMultiplier[142] = 2050396046;
        weeklyRewardMultiplier[143] = 2050462968;
        weeklyRewardMultiplier[144] = 2050526544;
        weeklyRewardMultiplier[145] = 2050586940;
        weeklyRewardMultiplier[146] = 2050644317;
        weeklyRewardMultiplier[147] = 2050698825;
        weeklyRewardMultiplier[148] = 2050750608;
        weeklyRewardMultiplier[149] = 2050799802;
        weeklyRewardMultiplier[150] = 2050846536;
        weeklyRewardMultiplier[151] = 2050890933;
        weeklyRewardMultiplier[152] = 2050933110;
        weeklyRewardMultiplier[153] = 2050973179;
        weeklyRewardMultiplier[154] = 2051011244;
        weeklyRewardMultiplier[155] = 2051047405;
        weeklyRewardMultiplier[156] = 2051081759;
        weeklyRewardMultiplier[157] = 2051114395;
        weeklyRewardMultiplier[158] = 2051145399;
        weeklyRewardMultiplier[159] = 2051174853;
        weeklyRewardMultiplier[160] = 2051202835;
        weeklyRewardMultiplier[161] = 2051229417;
        weeklyRewardMultiplier[162] = 2051254670;
        weeklyRewardMultiplier[163] = 2051278660;
        weeklyRewardMultiplier[164] = 2051301451;
        weeklyRewardMultiplier[165] = 2051323103;
        weeklyRewardMultiplier[166] = 2051343672;
        weeklyRewardMultiplier[167] = 2051363212;
        weeklyRewardMultiplier[168] = 2051381775;
        weeklyRewardMultiplier[169] = 2051399411;
        weeklyRewardMultiplier[170] = 2051416164;
        weeklyRewardMultiplier[171] = 2051432080;
        weeklyRewardMultiplier[172] = 2051447200;
        weeklyRewardMultiplier[173] = 2051461564;
        weeklyRewardMultiplier[174] = 2051475210;
        weeklyRewardMultiplier[175] = 2051488173;
        weeklyRewardMultiplier[176] = 2051500488;
        weeklyRewardMultiplier[177] = 2051512188;
        weeklyRewardMultiplier[178] = 2051523303;
        weeklyRewardMultiplier[179] = 2051533861;
        weeklyRewardMultiplier[180] = 2051543892;
        weeklyRewardMultiplier[181] = 2051553422;
        weeklyRewardMultiplier[182] = 2051562475;
        weeklyRewardMultiplier[183] = 2051571075;
        weeklyRewardMultiplier[184] = 2051579245;
        weeklyRewardMultiplier[185] = 2051587007;
        weeklyRewardMultiplier[186] = 2051594380;
        weeklyRewardMultiplier[187] = 2051601385;
        weeklyRewardMultiplier[188] = 2051608040;
        weeklyRewardMultiplier[189] = 2051614362;
        weeklyRewardMultiplier[190] = 2051620368;
        weeklyRewardMultiplier[191] = 2051626073;
        weeklyRewardMultiplier[192] = 2051631494;
        weeklyRewardMultiplier[193] = 2051636643;
        weeklyRewardMultiplier[194] = 2051641535;
        weeklyRewardMultiplier[195] = 2051646182;
        weeklyRewardMultiplier[196] = 2051650597;
        weeklyRewardMultiplier[197] = 2051654791;
        weeklyRewardMultiplier[198] = 2051658776;
        weeklyRewardMultiplier[199] = 2051662561;
        weeklyRewardMultiplier[200] = 2051666157;
        weeklyRewardMultiplier[201] = 2051669573;
        weeklyRewardMultiplier[202] = 2051672818;
        weeklyRewardMultiplier[203] = 2051675901;
        weeklyRewardMultiplier[204] = 2051678830;
        weeklyRewardMultiplier[205] = 2051681613;
        weeklyRewardMultiplier[206] = 2051684256;
        weeklyRewardMultiplier[207] = 2051686767;
        weeklyRewardMultiplier[208] = 2051689153;
        weeklyRewardMultiplier[209] = 2051691419;
        weeklyRewardMultiplier[210] = 2051693572;
        weeklyRewardMultiplier[211] = 2051695617;
        weeklyRewardMultiplier[212] = 2051697561;
        weeklyRewardMultiplier[213] = 2051699407;
        weeklyRewardMultiplier[214] = 2051701160;
        weeklyRewardMultiplier[215] = 2051702826;
        weeklyRewardMultiplier[216] = 2051704409;
        weeklyRewardMultiplier[217] = 2051705912;
        weeklyRewardMultiplier[218] = 2051707341;
        weeklyRewardMultiplier[219] = 2051708698;
        weeklyRewardMultiplier[220] = 2051709987;
        weeklyRewardMultiplier[221] = 2051711211;
        weeklyRewardMultiplier[222] = 2051712375;
        weeklyRewardMultiplier[223] = 2051713480;
        weeklyRewardMultiplier[224] = 2051714530;
        weeklyRewardMultiplier[225] = 2051715527;
        weeklyRewardMultiplier[226] = 2051716475;
        weeklyRewardMultiplier[227] = 2051717375;
        weeklyRewardMultiplier[228] = 2051718230;
        weeklyRewardMultiplier[229] = 2051719043;
        weeklyRewardMultiplier[230] = 2051719815;
        weeklyRewardMultiplier[231] = 2051720548;
        weeklyRewardMultiplier[232] = 2051721245;
        weeklyRewardMultiplier[233] = 2051721906;
        weeklyRewardMultiplier[234] = 2051722535;
        weeklyRewardMultiplier[235] = 2051723132;
        weeklyRewardMultiplier[236] = 2051723700;
        weeklyRewardMultiplier[237] = 2051724239;
        weeklyRewardMultiplier[238] = 2051724751;
        weeklyRewardMultiplier[239] = 2051725237;
        weeklyRewardMultiplier[240] = 2051725699;
        weeklyRewardMultiplier[241] = 2051726138;
        weeklyRewardMultiplier[242] = 2051726555;
        weeklyRewardMultiplier[243] = 2051726951;
        weeklyRewardMultiplier[244] = 2051727328;
        weeklyRewardMultiplier[245] = 2051727685;
        weeklyRewardMultiplier[246] = 2051728025;
        weeklyRewardMultiplier[247] = 2051728348;
        weeklyRewardMultiplier[248] = 2051728654;
        weeklyRewardMultiplier[249] = 2051728946;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract IXENCrypto is IERC20 {
    struct MintInfo {
        address user;
        uint256 term;
        uint256 maturityTs;
        uint256 rank;
        uint256 amplifier;
        uint256 eaaRate;
    }

    mapping(address => MintInfo) public userMints;

    function claimRank(uint256 term) external virtual;

    function claimMintReward() external virtual;

    function claimMintRewardAndShare(address other, uint256 pct)
        external
        virtual;

    function getUserMint() external view virtual returns (MintInfo memory);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// import "hardhat/console.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IXENCrypto.sol";

contract XENWallet is Initializable {
    IXENCrypto public XENCrypto;
    address public manager;

    function initialize(address xenAddress, address managerAddress)
        public
        initializer
    {
        XENCrypto = IXENCrypto(xenAddress);
        manager = managerAddress;
    }

    function getUserMint() external view returns (IXENCrypto.MintInfo memory) {
        return XENCrypto.getUserMint();
    }

    // Claim ranks
    function claimRank(uint256 _term) public {
        require(msg.sender == manager, "No access");

        XENCrypto.claimRank(_term);
    }

    // Claim mint reward
    function claimAndTransferMintReward(address target)
        external
        returns (uint256 reward)
    {
        require(msg.sender == manager, "No access");

        uint256 balanceBefore = XENCrypto.balanceOf(target);
        XENCrypto.claimMintRewardAndShare(target, 100);
        reward = XENCrypto.balanceOf(target) - balanceBefore;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YENCrypto is ERC20 {
    address public minter;
    uint256 internal constant LAUNCH_TIME = 1_666_521_063;
    uint256 internal constant LAUNCH_PHASE = 1_000_000;

    constructor(address _minter) ERC20("YEN", "YEN") {
        minter = _minter;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == minter, "No access");
        _mint(account, amount);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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