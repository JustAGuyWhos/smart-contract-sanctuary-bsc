/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.5.16;
pragma experimental ABIEncoderV2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

interface AggregatorV3Interface {
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

interface NFT {
    function mint(
        address to,
        uint256 seri,
        uint256 startTime,
        uint256 endTime,
        string calldata result,
        uint256 status,
        uint256 winTickets,
        address buyer,
        uint256 buyTickets,
        string calldata asset
    ) external returns (uint256);

    function metadatas(uint256 _tokenId)
        external
        view
        returns (
            uint256 seri,
            uint256 startTime,
            uint256 endTime,
            string memory result,
            uint256 status,
            uint256 winTickets,
            address buyer,
            uint256 buyTickets,
            string memory asset
        );

    function burn(uint256 tokenId) external;
}

interface Stake {
    function depositProfit(address _bep20, uint256 _amount) external;
}

contract Lottery is Ownable {
    using SafeMath for uint256;
    uint256 public constant MAX_LOOP = 100;

    uint256 public currentSignTime;
    string[] public priceFeeds = ["BNB", "BUSD", "BTCB", "USDT", "ETH", "USDC", "XRP"];
    struct asset {
        string symbol;
        address asset;
        AggregatorV3Interface priceFeed;
    }

    address public signer = 0x7a7f38737BFCD8a1301Dd262a226780350980eA3;

    address payable public postAddress = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    address payable public operator = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    address payable public affiliateAddress = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    address payable public stake = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    address payable public purchase = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    address payable public carryOver = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    IBEP20 public initCarryOverAsset = IBEP20(0x013345B20fe7Cf68184005464FBF204D9aB88227);
    uint256 public currentCarryOverSeri;
    NFT public nft = NFT(0x1CadF5af6d52Aa4397F8E6b94Da933cFF9Fdc284);

    uint256 public price = 100 ether; // number of token per 1 ether BUSD;
    uint256 public share2Stake = 2;
    uint256 public share2Purchase = 2;
    uint256 public share2affiliate = 40;
    uint256 public share2Operator = 16;
    uint256 public share2affiliateCO = 40;
    uint256 public share2OperatorCO = 20;
    uint256 public expiredPeriod = 259200;
    struct seri {
        uint256 price;
        uint256 soldTicket;
        uint256[] assetIndex;
        string result;
        uint256 status; // status - index 0 open; 1 close; 2 win; 3 lose
        uint256[] winners; // NFT token Id
        uint256 endTime;
        uint256[] prizetaked;
        bool takeAssetExpired;
        uint256 max2sale;
        uint256 totalWin;
        uint256 seriType; // 1 normal; 2 carryOver;
        uint256 initPrize;
        uint256 initPrizeTaken;
        uint256 winInitPrize;
        mapping(address => string[]) userTickets;
        // mapping(uint => mapping(address => ticket)) userTickets; // seri => timestamp => user => ticket
        mapping(uint256 => uint256) seriAssetRemain; // seri => asset index => remain
        mapping(uint256 => uint256) winAmount;
    }
    struct ticket {
        string[] number;
        uint256[] buyTicket;
    }
    mapping(uint256 => seri) public series;
    mapping(string => asset) assets;
    mapping(uint256 => uint256) public seriExpiredPeriod;
    mapping(uint256 => uint256) public postPrices;
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userTicketsWon; // seri => user => ticket id => token id
    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public userTicketsWonb; // seri => user => token id => ticket id

    event OpenSeri(uint256 _seri, uint256 _price);
    event CloseSeri(uint256 _seri, uint256 _endTime);
    event OpenResult(uint256 _seri, bool _isWin);
    modifier onlySigner() {
        require(signer == _msgSender(), "Signer: caller is not the signer");
        _;
    }

    function getMessageHash(uint256 timestamp, string memory result) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(timestamp, result));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function permit(
        uint256 timestamp,
        string memory result,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(timestamp, result)), v, r, s) == signer;
    }

    function getbytesDataSetWinners(
        uint256 timestamp,
        uint256 _seri,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        uint256 _totalTicket,
        string[] memory _assets
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(timestamp, abi.encode(_seri, _winners, _buyTickets, _totalTicket, _assets)));
    }

    function permitSetWinners(
        uint256 timestamp,
        uint256 _seri,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        uint256 _totalTicket,
        string[] memory _assets,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        bytes32 _messageHash = getbytesDataSetWinners(timestamp, _seri, _winners, _buyTickets, _totalTicket, _assets);
        return ecrecover(getEthSignedMessageHash(_messageHash), v, r, s) == signer;
    }

    constructor() public {
        assets["BNB"] = asset("BNB", address(0), AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526));
        assets["BUSD"] = asset("BUSD", 0x10297304eEA4223E870069325A2EEA7ca4Cd58b4, AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa));
        assets["BTCB"] = asset("BTCB", 0xf6f3F4f5d68Ddb61135fbbde56f404Ebd4b984Ee, AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C));
        assets["USDT"] = asset("USDT", 0x013345B20fe7Cf68184005464FBF204D9aB88227, AggregatorV3Interface(0xEca2605f0BCF2BA5966372C99837b1F182d3D620));
        assets["ETH"] = asset("ETH", 0x979Db64D8cD5Fed9f1B62558547316aFEdcf4dBA, AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7));
        assets["USDC"] = asset("USDC", 0xF53E2228ff7F680D4677878eeA2c7814a5233C85, AggregatorV3Interface(0x90c069C4538adAc136E051052E14c1cD799C41B7));
        assets["XRP"] = asset("XRP", 0xd2926D1f868Ba1E81325f0206A4449Da3fD8FB62, AggregatorV3Interface(0x4046332373C24Aed1dC8bAd489A04E187833B28d));
    }

    function getPriceFeeds() public view returns (string[] memory _symbols) {
        return priceFeeds;
    }

    function getAsset(string memory _symbol) public view returns (asset memory _asset) {
        return assets[_symbol];
    }

    function getSeriesAssets(uint256 _seri) public view returns (uint256[] memory) {
        return series[_seri].assetIndex;
    }

    function metadatas(uint256 _tokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            string memory,
            uint256,
            uint256,
            address,
            uint256,
            string memory
        )
    {
        return nft.metadatas(_tokenId);
    }

    function getSeriWinners(uint256 _seri) public view returns (uint256[] memory) {
        return series[_seri].winners;
    }

    function getUserTickets(uint256 _seri, address _user) public view returns (string[] memory) {
        return series[_seri].userTickets[_user];
    }

    function seriAssetRemain(uint256 _seri, uint256 _asset) public view returns (uint256) {
        return series[_seri].seriAssetRemain[_asset];
    }

    function getLatestPrice(string memory _symbol) public view returns (int256) {
        (, int256 _price, , , ) = assets[_symbol].priceFeed.latestRoundData();
        return _price * 10**10;
    }

    function asset2USD(string memory _symbol) public view returns (uint256 _amountUsd) {
        return uint256(getLatestPrice(_symbol));
    }

    function asset2USD(string memory _symbol, uint256 _amount) public view returns (uint256 _amountUsd) {
        return _amount.mul(uint256(getLatestPrice(_symbol))).div(1 ether);
    }

    function ticket2Asset(uint256 _seri, string memory _symbol) public view returns (uint256 _amountUsd) {
        uint256 expectedRate = asset2USD(_symbol);
        return series[_seri].price.mul(1 ether).div(expectedRate);
    }

    function openSeri(uint256 _seri, uint256 _price, uint256 _postPrice, uint256 _max2sale) public onlyOwner {
        require(series[_seri].price == 0, "seri existed");
        series[_seri].price = _price;
        series[_seri].max2sale = _max2sale;
        seriExpiredPeriod[_seri] = expiredPeriod;
        postPrices[_seri] = _postPrice;
        series[_seri].seriType = 1;
        emit OpenSeri(_seri, price);
    }

    function openSeriCarryOver(
        uint256 _seri,
        uint256 _max2sale,
        uint256 _price,
        uint256 _postPrice,
        uint256 _initPrize
    ) public onlyOwner {
        require(currentCarryOverSeri == 0 || series[currentCarryOverSeri].status != 0, "CarryOver Seri opening");
        require(series[_seri].price == 0, "seri existed");
        require(initCarryOverAsset.transferFrom(msg.sender, address(this), _initPrize), "insufficient-allowance");
        series[_seri].price = _price;
        postPrices[_seri] = _postPrice;
        series[_seri].max2sale = _max2sale;
        seriExpiredPeriod[_seri] = expiredPeriod;
        series[_seri].seriType = 2;
        series[_seri].initPrize = _initPrize;
        currentCarryOverSeri = _seri;
        emit OpenSeri(_seri, price);
    }

    function takeAsset2CarryOver(uint256 _seri) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]];
                if (series[_seri].assetIndex[i] == 0) carryOver.transfer(takeAmount);
                else {
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    IBEP20 _asset = IBEP20(assets[_symbol].asset);
                    require(_asset.transfer(carryOver, takeAmount), "insufficient-balance");
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = 0;
            }
        }
        if (series[_seri].seriType == 2) initCarryOverAsset.transfer(carryOver, series[_seri].initPrize);
    }

    function closeSeri(uint256 _seri) public onlyOwner {
        require(series[_seri].status == 0, "seri not open");
        require(series[_seri].soldTicket == series[_seri].max2sale, "Tickets are not sold out yet");
        series[_seri].status = 1;
        emit CloseSeri(_seri, now);
    }

    function openResult(
        uint256 _seri,
        bool _isWin,
        uint256 _totalWin,
        uint256 timestamp,
        string memory _result,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public onlyOwner {
        require(series[_seri].status == 1, "seri not close");
        require(currentSignTime < timestamp, "Invalid timestamp");
        require(permit(timestamp, _result, v, r, s), "Invalid signal");
        series[_seri].result = _result;
        if (_isWin) {
            series[_seri].status = 2;
            series[_seri].totalWin = _totalWin;
        } else {
            takeAsset2CarryOver(_seri);
            series[_seri].status = 3;
        }
        series[_seri].endTime = now;
        currentSignTime = timestamp;
        emit OpenResult(_seri, _isWin);
    }

    function sendNFT(
        uint256 _seri,
        uint256 startTime,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        string[] memory _assets
    ) internal {
        seri storage sr = series[_seri];
        require(sr.status == 2, "seri not winner");
        for (uint256 i = 0; i < _winners.length; i++) {
            for (uint256 j = 0; j < _buyTickets[i].length; j++) {
                uint256 tokenID = nft.mint(_winners[i], _seri, startTime, now, sr.result, 2, sr.totalWin, _winners[i], 1, _assets[i]);
                series[_seri].winners.push(tokenID);
                userTicketsWon[_seri][_winners[i]][_buyTickets[i][j]] = tokenID;
                userTicketsWonb[_seri][_winners[i]][tokenID] = _buyTickets[i][j];
            }
        }
    }

    function setWinners(
        uint256 _seri,
        uint256 startTime,
        address[] memory _winners,
        uint256[][] memory _buyTickets,
        uint256 _totalTicket,
        string[] memory _assets,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public onlyOwner {
        require(_winners.length <= MAX_LOOP, "Over max loop");
        require(currentSignTime < timestamp, "Invalid timestamp");
        require(permitSetWinners(timestamp, _seri, _winners, _buyTickets, _totalTicket, _assets, v, r, s), "Invalid signal");
        require(series[_seri].winners.length.add(_totalTicket) <= series[_seri].totalWin, "Invalid winners");
        sendNFT(_seri, startTime, _winners, _buyTickets, _assets);
        currentSignTime = timestamp;
    }

    function takeAsset(
        uint256 _seri,
        uint256 _winTickets,
        uint256 _buyTickets
    ) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].winAmount[series[_seri].assetIndex[i]];

                if (takeAmount == 0) {
                    takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]].mul(_buyTickets).div(_winTickets);
                    series[_seri].winAmount[series[_seri].assetIndex[i]] = takeAmount;
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]].sub(takeAmount);
                if (series[_seri].assetIndex[i] == 0) msg.sender.transfer(takeAmount);
                else {
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    IBEP20 _asset = IBEP20(assets[_symbol].asset);
                    require(_asset.transfer(msg.sender, takeAmount), "insufficient-allowance");
                }
            }
        }
        if (series[_seri].seriType == 2) {
            uint256 takeAssetInitAmount = series[_seri].winInitPrize;
            if (takeAssetInitAmount == 0) {
                takeAssetInitAmount = series[_seri].initPrize.mul(_buyTickets).div(_winTickets);
                series[_seri].winInitPrize = takeAssetInitAmount;
            }
            initCarryOverAsset.transfer(msg.sender, takeAssetInitAmount);
            series[_seri].initPrizeTaken += takeAssetInitAmount;
        }
    }

    function takePrize(uint256 _nftId) public {
        uint256 _seri;
        uint256 _winTickets;
        uint256 _buyTickets;
        address buyer;
        (_seri, , , , , _winTickets, buyer, _buyTickets, ) = nft.metadatas(_nftId);
        require(series[_seri].status == 2, "seri not winner");
        require(series[_seri].endTime.add(seriExpiredPeriod[_seri]) > now, "Ticket Expired");
        series[_seri].prizetaked.push(_nftId);
        takeAsset(_seri, _winTickets, _buyTickets);
        nft.burn(_nftId);
    }

    function totalPrize(uint256 _seri) public view returns (uint256 _prize) {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                string memory symbol = priceFeeds[series[_seri].assetIndex[i]];
                _prize += asset2USD(symbol, series[_seri].seriAssetRemain[series[_seri].assetIndex[i]]);
            }
        }
    }

    function _takePrizeExpired(uint256 _seri) internal {
        for (uint256 i = 0; i < series[_seri].assetIndex.length; i++) {
            if (series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] > 0) {
                uint256 takeAmount = series[_seri].seriAssetRemain[series[_seri].assetIndex[i]];
                if (series[_seri].assetIndex[i] == 0) carryOver.transfer(takeAmount);
                else {
                    string memory _symbol = priceFeeds[series[_seri].assetIndex[i]];
                    IBEP20 _asset = IBEP20(assets[_symbol].asset);
                    require(_asset.transfer(carryOver, takeAmount), "insufficient-allowance");
                }
                series[_seri].seriAssetRemain[series[_seri].assetIndex[i]] = 0;
            }
        }
        if (series[_seri].seriType == 2) {
            uint256 takeAssetInitRemain = series[_seri].initPrize.sub(series[_seri].initPrizeTaken);
            initCarryOverAsset.transfer(carryOver, takeAssetInitRemain);
            series[_seri].initPrizeTaken = series[_seri].initPrizeTaken;
        }
    }

    function takePrizeExpired(uint256 _seri) public onlyOwner {
        require(!series[_seri].takeAssetExpired, "Taked");
        require(series[_seri].endTime.add(seriExpiredPeriod[_seri]) < now, "Ticket not Expired");

        _takePrizeExpired(_seri);
        series[_seri].takeAssetExpired = true;
    }

    function buyCarryOver(
        uint256 _seri,
        string memory _numberInfo,
        uint256 _assetIndex,
        uint256 totalTicket
    ) public payable {
        uint256 assetPerTicket = ticket2Asset(_seri, priceFeeds[_assetIndex]);
        series[_seri].userTickets[msg.sender].push(_numberInfo);
        require(series[_seri].soldTicket + totalTicket <= series[_seri].max2sale, "over max2sale");
        uint256 assetAmount = assetPerTicket.mul(totalTicket);
        uint256 postAmount = assetAmount.mul(postPrices[_seri]).div(series[_seri].price);
        uint256 postRemain = assetAmount.sub(postAmount);
        uint256 shareAffiliateAmount = assetAmount.mul(share2affiliateCO).div(100);
        uint256 takeTokenAmount = assetAmount.mul(share2OperatorCO).div(100);
        if (_assetIndex == 0) {
            require(msg.value >= assetAmount, "insufficient-balance");
            postAddress.transfer(postRemain);
            affiliateAddress.transfer(shareAffiliateAmount);
            operator.transfer(takeTokenAmount);
        } else {
            string memory _symbol = priceFeeds[_assetIndex];
            IBEP20 _asset = IBEP20(assets[_symbol].asset);
            require(_asset.transferFrom(msg.sender, address(this), assetAmount), "insufficient-allowance");
            require(_asset.transfer(postAddress, postRemain), "insufficient-allowance");
            require(_asset.transfer(affiliateAddress, shareAffiliateAmount), "insufficient-balance");
            require(_asset.transfer(operator, takeTokenAmount), "insufficient-balance");
        }

        if (series[_seri].seriAssetRemain[_assetIndex] == 0) series[_seri].assetIndex.push(_assetIndex);
        uint256 assetRemain = assetAmount.sub(postRemain).sub(shareAffiliateAmount).sub(takeTokenAmount);
        series[_seri].seriAssetRemain[_assetIndex] += assetRemain;
        series[_seri].soldTicket += totalTicket;
    }

    function buy(
        uint256 _seri,
        string memory _numberInfo,
        uint256 _assetIndex,
        uint256 totalTicket
    ) public payable {
        uint256 assetPerTicket = ticket2Asset(_seri, priceFeeds[_assetIndex]);
        series[_seri].userTickets[msg.sender].push(_numberInfo);
        require(series[_seri].soldTicket + totalTicket <= series[_seri].max2sale, "over max2sale");
        uint256 assetAmount = assetPerTicket.mul(totalTicket);
        uint256 postAmount = assetAmount.mul(postPrices[_seri]).div(series[_seri].price);
        uint256 postRemain = assetAmount.sub(postAmount);
        uint256 shareStakeAmount = postAmount.mul(share2Stake).div(100);
        uint256 sharePurchaseAmount = postAmount.mul(share2Purchase).div(100);
        uint256 shareAffiliateAmount = postAmount.mul(share2affiliate).div(100);
        uint256 takeTokenAmount = postAmount.mul(share2Operator).div(100);
        if (_assetIndex == 0) {
            require(msg.value >= assetAmount, "insufficient-balance");
            postAddress.transfer(postRemain);
            stake.transfer(shareStakeAmount);
            purchase.transfer(sharePurchaseAmount);
            affiliateAddress.transfer(shareAffiliateAmount);
            operator.transfer(takeTokenAmount);
        } else {
            string memory _symbol = priceFeeds[_assetIndex];
            IBEP20 _asset = IBEP20(assets[_symbol].asset);
            require(_asset.transferFrom(msg.sender, address(this), assetAmount), "insufficient-allowance");
            require(_asset.transfer(postAddress, postRemain), "insufficient-allowance");
            require(_asset.transfer(stake, shareStakeAmount), "insufficient-allowance");
            require(_asset.transfer(purchase, sharePurchaseAmount), "insufficient-allowance");
            require(_asset.transfer(affiliateAddress, shareAffiliateAmount), "insufficient-allowance");
            require(_asset.transfer(operator, takeTokenAmount), "insufficient-allowance");
        }

        if (series[_seri].seriAssetRemain[_assetIndex] == 0) series[_seri].assetIndex.push(_assetIndex);
        uint256 assetRemain;
        {
            assetRemain = assetAmount.sub(shareStakeAmount).sub(sharePurchaseAmount).sub(shareAffiliateAmount).sub(takeTokenAmount);
            assetRemain = assetRemain.sub(postRemain);
        }        
        series[_seri].seriAssetRemain[_assetIndex] += assetRemain;
        series[_seri].soldTicket += totalTicket;
    }

    function setAssets(
        AggregatorV3Interface[] memory _priceFeeds,
        string[] memory _symbols,
        address[] memory _bep20s
    ) public onlyOwner {
        require(_priceFeeds.length == _symbols.length && _symbols.length == _bep20s.length, "invalid length");
        for (uint256 i = 0; i < _symbols.length; i++) {
            assets[_symbols[i]] = asset(_symbols[i], _bep20s[i], _priceFeeds[i]);
        }
        priceFeeds = _symbols;
    }

    function configSigner(address _signer) public onlySigner {
        signer = _signer;
    }

    function configAddress(
        address payable _stake,
        address payable _purchase,
        address payable _operator,
        address payable _affiliateAddress,
        address payable _postAddress,
        NFT _nft,
        address payable _carryOver,
        IBEP20 _initCarryOverAsset
    ) public onlyOwner {
        stake = _stake;
        purchase = _purchase;
        operator = _operator;
        affiliateAddress = _affiliateAddress;
        postAddress = _postAddress;
        nft = _nft;
        carryOver = _carryOver;
        initCarryOverAsset = _initCarryOverAsset;
    }

    function config(
        uint256 _expiredPeriod,
        uint256 _share2Stake,
        uint256 _share2Purchase,
        uint256 _share2affiliate,
        uint256 _share2Operator,
        uint256 _share2affiliateCO,
        uint256 _share2OperatorCO
    ) public onlyOwner {
        require(_share2Stake + _share2Purchase + _share2affiliate + _share2Operator < 100, "invalid percent");
        expiredPeriod = _expiredPeriod;
        share2Stake = _share2Stake;
        share2Purchase = _share2Purchase;
        share2affiliate = _share2affiliate;
        share2Operator = _share2Operator;
        share2affiliateCO = _share2affiliateCO;
        share2OperatorCO = _share2OperatorCO;
    }
}