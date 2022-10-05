// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '../interfaces/IPancakePair.sol';
import '../interfaces/IPancakeFactory.sol';
import '../interfaces/IPancakeRouter.sol';
import '../interfaces/IPRC20.sol';
import '../interfaces/IBNBP.sol';

// File: PotContract.sol

contract PotLotteryv2 is Initializable, ReentrancyGuardUpgradeable {
    /*
     ***Start of function, Enum, Variables, array and mappings to set and edit the Pot State such that accounts can enter the pot
     */
    using SafeMath for uint256;
    using SafeMath for uint256;

    struct Token {
        address tokenAddress;
        bool swapToBNB;
        bool isStable;
        string tokenSymbol;
        uint256 tokenDecimal;
    }

    enum POT_STATE {
        WAITING,
        STARTED,
        LIVE,
        CALCULATING_WINNER
    }

    address public owner;
    address public admin;

    // This is for bnb testnet
    address public wbnbAddr;
    address public busdAddr;
    address public pancakeswapV2FactoryAddr;
    IPancakeRouter02 public router;

    POT_STATE public pot_state;

    mapping(string => Token) public tokenWhiteList;
    string[] public tokenWhiteListNames;
    uint256 public minEntranceInUsd;
    uint256 public potCount;
    uint256 public potDuration;
    uint256 public percentageFee;
    uint256 public PotEntryCount;
    uint256 public entriesCount;
    address public BNBP_Address;
    uint256 public BNBP_Standard;

    mapping(string => uint256) public tokenLatestPriceFeed;

    uint256 public potLiveTime;
    uint256 public potStartTime;
    uint256 public timeBeforeRefund;
    uint256 public participantCount;
    address[] public participants;
    string[] public tokensInPotNames;
    uint256 public totalPotUsdValue;
    address[] public entriesAddress;
    uint256[] public entriesUsdValue;
    address public LAST_POT_WINNER;

    // Tokenomics
    uint256 public airdropInterval;
    uint256 public burnInterval;
    uint256 public lotteryInterval;

    uint8 public airdropPercentage;
    uint8 public burnPercentage;
    uint8 public lotteryPercentage;

    uint256 public airdropPool;
    uint256 public burnPool;
    uint256 public lotteryPool;

    uint256 public stakingMinimum;
    uint256 public minimumStakingTime;

    string[] public adminFeeToken;
    mapping(string => uint256) public adminFeeTokenValues;

    mapping(address => uint256) public participantsTotalEntryInUsd;
    mapping(string => uint256) public tokenTotalEntry;
    mapping(address => mapping(string => uint256)) public participantsTokenEntries;

    address hotWalletAddress;
    uint256 hotWalletMinBalance;
    uint256 hotWalletMaxBalance;

    function initialize(address _owner) public initializer {
        owner = _owner;
        admin = _owner;
        pot_state = POT_STATE.WAITING;
        potDuration = 300; // 5 minutes
        minEntranceInUsd = 9000000000; //9900000000 cents ~ 1$
        percentageFee = 3;
        potCount = 1;
        timeBeforeRefund = 900; //24 hours
        PotEntryCount = 0;
        entriesCount = 0;

        // Need to change
        airdropInterval = 86400*2;
        burnInterval = 86400;
        lotteryInterval = 86400;

        airdropPercentage = 75;
        burnPercentage = 20;
        lotteryPercentage = 5;

        stakingMinimum = 5 * 10**18; // 5 BNBP
        minimumStakingTime = 100 * 24 * 36; // 100 days

        wbnbAddr = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        busdAddr = 0x7D7dA1FC0DDb5c5Cb9EE194FF3dC3309E29a6F8d;
        pancakeswapV2FactoryAddr = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;
        router = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        __ReentrancyGuard_init();
    }

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == owner, '!admin');
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, '!owner');
        _;
    }

    modifier validBNBP() {
        require(BNBP_Address != address(0), '!BNBP Addr');
        _;
    }

    //-----I added a new event
    event BalanceNotEnough(address indexed userAddress, string tokenName);

    event EnteredPot(
        string tokenName, //
        address indexed userAddress, //
        uint256 indexed potRound,
        uint256 usdValue,
        uint256 amount,
        uint256 indexed enteryCount, //
        bool hasEntryInCurrentPot
    );

    event CalculateWinner(
        address indexed winner,
        uint256 indexed potRound,
        uint256 potValue,
        uint256 amount,
        uint256 amountWon,
        uint256 participants
    );

    event TokenSwapFailedString(string tokenName, string reason);
    event TokenSwapFailedBytes(string tokenName, bytes reason);
    event BurnSuccess(uint256 amount);
    event AirdropSuccess(uint256 amount);
    event LotterySuccess(address indexed winner);
    event HotWalletSupplied(address addr, uint256 amount);

    /**   @dev returns the usd value of a token amount
     * @param _tokenName the name of the token
     * @param _amount the amount of the token
     * @return usdValue usd value of the token amount
     */
    function getTokenUsdValue(string memory _tokenName, uint256 _amount) public view returns (uint256) {
        return ((tokenLatestPriceFeed[_tokenName] * _amount) / 10**tokenWhiteList[_tokenName].tokenDecimal);
    }

    /**   @dev attempt to transfer token from user address to contract address
     * @param _tokenName the name of the token
     * @param _userAddress the user address
     * @param _amount the token amount to transfer
     * @return success status of the TransferFrom call
     */
    function attemptTransferFrom(
        string memory _tokenName,
        address _userAddress,
        uint256 _amount
    ) public returns (bool) {
        try IPRC20(tokenWhiteList[_tokenName].tokenAddress).transferFrom(_userAddress, address(this), _amount) returns (
            bool
        ) {
            return true;
        } catch (
            bytes memory 
        ) {
            return false;
        }
    }

    /**   @dev changes contract owner address
     * @param _owner the new owner
     * @notice only the owner can call this function
     */
    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    /**   @dev changes contract admin address
     * @param _adminAddress the new admin
     * @notice only the owner can call this function
     */
    function changeAdmin(address _adminAddress) public onlyOwner {
        admin = _adminAddress;
    }

    /**   @dev set the BNBP address
     * @param _address the BNBP address
     * @notice only the admin or owner can call this function
     */
    function setBNBPAddress(address _address) public onlyAdmin {
        BNBP_Address = _address;
    }

    /**   @dev set the BNBP minimum balance to get 50% reduction in fee
     * @param _amount the BNBP minimum balance for 50% reduction in fee
     * @notice only the admin or owner can call this function
     */
    function setBNBP_Standard(uint256 _amount) public onlyAdmin {
        BNBP_Standard = _amount;
    }

    /**   @dev add token to list of white listed token
     * @param _tokenName the name of the token
     * @param _tokenSymbol the symbol of the token
     * @param _tokenAddress the address of the token
     * @param _decimal the token decimal
     * @notice only the admin or owner can call this function
     */
    function addToken(
        string memory _tokenName,
        string memory _tokenSymbol,
        address _tokenAddress,
        bool _swapToBNB,
        bool _isStable,
        uint256 _decimal
    ) public onlyAdmin {
        require(_tokenAddress != address(0), "0x");
        if (tokenWhiteList[_tokenName].tokenAddress == address(0)) {
            tokenWhiteListNames.push(_tokenName);
        }
        tokenWhiteList[_tokenName] = Token(_tokenAddress, _swapToBNB, _isStable, _tokenSymbol, _decimal);
        if(_isStable){
             updateTokenUsdValue(_tokenName, 10**10) ;
        }
    }

    /**   @dev remove token from the list of white listed token
     * @param _tokenName the name of the token
     * @notice only the admin or owner can call this function
     */
    function removeToken(string memory _tokenName) public onlyAdmin {
        for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
            if (keccak256(bytes(_tokenName)) == keccak256(bytes(tokenWhiteListNames[index]))) {
                delete tokenWhiteList[_tokenName];
                delete tokenLatestPriceFeed[_tokenName];
                tokenWhiteListNames[index] = tokenWhiteListNames[tokenWhiteListNames.length - 1];
                tokenWhiteListNames.pop();
            }
        }
    }

    /**   @dev set token usd value
     * @param _tokenName the name of the token
     * @param _valueInUsd the usd value to set token price to
     * @notice set BNBP price to 30usd when price is below 30usd on dex
     * @notice add extra 10% to price of BNBP when price above 30usd on dex
     */
    function updateTokenUsdValue(string memory _tokenName, uint256 _valueInUsd) internal tokenInWhiteList(_tokenName) {
        if (keccak256(bytes(_tokenName)) == keccak256(bytes('BNBP'))) {
            tokenLatestPriceFeed[_tokenName] = _valueInUsd < 30 * 10**10 ? 30 * 10**10 : (_valueInUsd * 11) / 10;
        } else {
            tokenLatestPriceFeed[_tokenName] = _valueInUsd;
        }
    }

    modifier tokenInWhiteList(string memory _tokenName) {
        bool istokenWhiteListed = false;
        for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
            if (keccak256(bytes(tokenWhiteListNames[index])) == keccak256(bytes(_tokenName))) {
                istokenWhiteListed = true;
            }
        }
        require(istokenWhiteListed, '!supp');
        _;
    }

    /**   @dev Attempts to enter pot with an array of values
     * @param _tokenNames an array of token names to enter pot with
     * @param _amounts an array of token amount to enter pot with
     * @param _participants an array of participant address to enter pot with
     * @notice attempts to calculate winner firstly if pot duration is over
     * @notice only callable by the admin or owner account
     * @notice entry will not be allowed if contract token balance is not enough or entry is less than minimum usd value
     * @notice entry with native token is not allowed
     */
    ///This is the Centralized enterPot function
    function EnterPot(
        string[] memory _tokenNames,
        uint256[] memory _amounts,
        address[] memory _participants
    ) public onlyAdmin {
        for (uint256 index = 0; index < _tokenNames.length; index++) {
            if ((keccak256(bytes(_tokenNames[index])) == keccak256(bytes('BNB'))) || (getTokenUsdValue(_tokenNames[index], _amounts[index]) < minEntranceInUsd)) {
                continue;
            }
            if (
                IPRC20(tokenWhiteList[(_tokenNames[index])].tokenAddress).balanceOf(address(this)) <
                (_amounts[index] + adminFeeTokenValues[_tokenNames[index]]) + tokenTotalEntry[_tokenNames[index]]
            ) {
                emit BalanceNotEnough(_participants[index], _tokenNames[index]);
                continue;
            }
            _EnterPot(_tokenNames[index], _amounts[index], _participants[index]);
        }
    }

    /**   @dev Attempts to enter pot with an array of values
     * @param _tokenNames an array of token names to enter pot with
     * @param _amounts an array of token amount to enter pot with
     * @param _participants an array of participant address to enter pot with
     * @notice attempts to calculate winner firstly if pot duration is over
     * @notice publicly callable by any address
     * @notice entry will not be allowed if approved value is less than _amounts or entry is less than minimum usd value
     * @notice entry with native token is not allowed
     */
    ///This is the Decentralized enterPot function
    function enterPot(
        string[] memory _tokenNames,
        uint256[] memory _amounts,
        address[] memory _participants
    ) public {
        for (uint256 index = 0; index < _tokenNames.length; index++) {
            if ((keccak256(bytes(_tokenNames[index])) == keccak256(bytes('BNB'))) || (getTokenUsdValue(_tokenNames[index], _amounts[index]) < minEntranceInUsd) || !attemptTransferFrom(_tokenNames[index], _participants[index], _amounts[index])) {
                continue;
            }
            _EnterPot(_tokenNames[index], _amounts[index], _participants[index]);
        }
    }

    /**   @dev Attempts to enter a single pot entry
     * @param _tokenName token name to enter pot with
     * @param _amount token amount to enter pot with
     * @param _participant participant address to enter pot with
     */
    function _EnterPot(
        string memory _tokenName,
        uint256 _amount,
        address _participant
    ) internal {

        if ((potLiveTime + potDuration) <= block.timestamp && (participantCount > 1)) {
            calculateWinner();
        }
        if (participantCount == 0) {
            UpdatePrice();
        }
        participantsTokenEntries[_participant][_tokenName] += _amount;
        participantsTotalEntryInUsd[_participant] += getTokenUsdValue(_tokenName, _amount);

        tokenTotalEntry[_tokenName] += _amount;
        if (participantsTotalEntryInUsd[_participant] == 0) {
            _addToParticipants(_participant);
        }
        if (tokenTotalEntry[_tokenName] == 0) {
            tokensInPotNames.push(_tokenName);
        }
        totalPotUsdValue += getTokenUsdValue(_tokenName, _amount);

        //@optimize
        if (entriesAddress.length == PotEntryCount) {
            entriesAddress.push(_participant);
            entriesUsdValue.push(getTokenUsdValue(_tokenName, _amount));
        } else {
            entriesAddress[PotEntryCount] = _participant;
            entriesUsdValue[PotEntryCount] = getTokenUsdValue(_tokenName, _amount);
        }

        if (participantCount == 2 && pot_state != POT_STATE.LIVE) {
            potLiveTime = block.timestamp;
            pot_state = POT_STATE.LIVE;
        }
        if (PotEntryCount == 0) {
            pot_state = POT_STATE.STARTED;
            potStartTime = block.timestamp;
        }
        PotEntryCount++;
        entriesCount++;
        emit EnteredPot(
            _tokenName,
            _participant,
            potCount,
            getTokenUsdValue(_tokenName, _amount),
            _amount,
            entriesCount,
            participantsTotalEntryInUsd[_participant] == 0
        );
    }

    /**   @dev Attempts to calculate pot round winner
     */
    function calculateWinner() public nonReentrant {
        if ((potLiveTime + potDuration) <= block.timestamp && (participantCount > 1) && (potStartTime != 0)) {
            address pot_winner = determineWinner();
            if (getAmountToPayAsFees(pot_winner) > 0) {
                deductAmountToPayAsFees(getPotTokenWithHighestValue(), getAmountToPayAsFees(pot_winner));
            }

            tokenTotalEntry[getPotTokenWithHighestValue()] =
                tokenTotalEntry[getPotTokenWithHighestValue()] -
                getAmountToPayAsFees(pot_winner);
            for (uint256 index = 0; index < tokensInPotNames.length; index++) {
                _payAccount(tokensInPotNames[index], pot_winner, tokenTotalEntry[tokensInPotNames[index]]);
            } //Transfer all required tokens to the Pot winner
            LAST_POT_WINNER = pot_winner;

            emit CalculateWinner(
                pot_winner,
                potCount,
                totalPotUsdValue,
                participantsTotalEntryInUsd[pot_winner],
                (totalPotUsdValue * (100 - percentageFee)) / 100,
                participantCount
            );
            startNewPot();
            //Start the new Pot and set calculating winner to true
            //After winner has been sent the token then set calculating winner to false
        }
    }

    /**   @dev Attempts to select a random winner
     */
    function determineWinner() internal view returns (address winner) {
        int256 winning_point = int256(fullFillRandomness() % totalPotUsdValue);
        for (uint256 index = 0; index < PotEntryCount; index++) {
            winning_point -= int256(entriesUsdValue[index]);
            if (winning_point <= 0) {
                //That means that the winner has been found here
                winner = entriesAddress[index];
            }
        }
    }

    /**   @dev process a refund for user if there is just one participant for 24 hrs
     */
    function getRefund() public nonReentrant {
        if (timeBeforeRefund + potStartTime < block.timestamp && participantCount == 1 && (potStartTime != 0)) {
            deductAmountToPayAsFees(getPotTokenWithHighestValue(), getAmountToPayAsFees(participants[0]));

            tokenTotalEntry[getPotTokenWithHighestValue()] -= getAmountToPayAsFees(participants[0]);
            for (uint256 index = 0; index < tokensInPotNames.length; index++) {
                _payAccount(tokensInPotNames[index], participants[0], tokenTotalEntry[tokensInPotNames[index]]);
            }
            startNewPot();
        }
    }

    /**   @dev remove the amount to pay as fee
     * @param _tokenName the name of the token to remove the fee from
     * @param _value the amount to remove as fee
     */
    function deductAmountToPayAsFees(string memory _tokenName, uint256 _value) internal {
        bool tokenInFee = false;
        for (uint256 index = 0; index < adminFeeToken.length; index++) {
            if (keccak256(bytes(_tokenName)) == keccak256(bytes(adminFeeToken[index]))) {
                tokenInFee = true;
            }
        }
        if (!tokenInFee) {
            adminFeeToken.push(_tokenName);
        }
        adminFeeTokenValues[_tokenName] += _value;
        if (keccak256(bytes(_tokenName)) == keccak256(bytes('BNBP'))) {
            _distributeToTokenomicsPools(_value);
        }
    }

    /**   @dev remove the amount to pay as fee
     * @param _address the name of the token to remove the fee from
     * @return amountToPay the amount to remove as fee
     * @notice _address current BNBP holding determine how much fee reduction you get
     */
    function getAmountToPayAsFees(address _address) internal view returns (uint256 amountToPay) {
        uint256 baseFee = (
            (percentageFee * totalPotUsdValue * 10**tokenWhiteList[getPotTokenWithHighestValue()].tokenDecimal) /
                (100 * tokenLatestPriceFeed[getPotTokenWithHighestValue()]) >=
                tokenTotalEntry[getPotTokenWithHighestValue()]
                ? tokenTotalEntry[getPotTokenWithHighestValue()]
                : (percentageFee * totalPotUsdValue * 10**tokenWhiteList[getPotTokenWithHighestValue()].tokenDecimal) /
                    (100 * tokenLatestPriceFeed[getPotTokenWithHighestValue()])
        );
        amountToPay = ((IPRC20(BNBP_Address).balanceOf(_address) / BNBP_Standard) >= 1)
            ? baseFee / 2
            : (baseFee - ((IPRC20(BNBP_Address).balanceOf(_address) / BNBP_Standard) * baseFee) / 2);
    }

    /**   @dev attempt to update token price from dex
          @notice price is only updated when there are no participant in pot
    */
    function UpdatePrice() public nonReentrant {
        if (participantCount == 0) {
            for (uint256 index = 0; index < tokenWhiteListNames.length; index++) {
                if(tokenWhiteList[tokenWhiteListNames[index]].isStable){
                    continue ;
                }
                (uint256 Res0, uint256 Res1) = _getTokenReserves(
                    tokenWhiteList[tokenWhiteListNames[index]].tokenAddress,
                    busdAddr
                );
                if (Res0 == 0 && Res1 == 0) {
                    (Res0, Res1) = _getTokenReserves(tokenWhiteList[tokenWhiteListNames[index]].tokenAddress, wbnbAddr);
                    uint256 res1 = Res1 * (10**tokenWhiteList[tokenWhiteListNames[index]].tokenDecimal);
                    uint256 price = res1 / Res0;
                    updateTokenUsdValue(
                        tokenWhiteListNames[index],
                        ((price * 10**10) * getBNBPrice()) /
                            10**(tokenWhiteList['BNB'].tokenDecimal + tokenWhiteList['BUSD'].tokenDecimal)
                    );
                } else {
                    uint256 res1 = Res1 * (10**tokenWhiteList[tokenWhiteListNames[index]].tokenDecimal);
                    uint256 price = res1 / Res0;
                    updateTokenUsdValue(
                        tokenWhiteListNames[index],
                        (price * 10**10) / 10**tokenWhiteList['BUSD'].tokenDecimal
                    );
                }
            }
            updateTokenUsdValue('BUSD', 10**10);
        }
    }

    /**
     * @dev gets token reserves for given token pair
     */
    function _getTokenReserves(address token0, address token1) internal view returns (uint256, uint256) {
        IPancakePair pair = IPancakePair(IPancakeFactory(pancakeswapV2FactoryAddr).getPair(token0, token1));

        if (address(pair) == address(0)) {
            return (0, 0);
        }

        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        if (token0 == pair.token0()) {
            return (Res0, Res1);
        }
        return (Res1, Res0);
    }

    /**   @dev returns the token name with the highest usd value in pot
          @return tokenWithHighestValue price is only updated when there are no participant in pot
    */
    function getPotTokenWithHighestValue() internal view returns (string memory tokenWithHighestValue) {
        tokenWithHighestValue = tokensInPotNames[0];
        for (uint256 index = 0; index < tokensInPotNames.length - 1; index++) {
            if (
                tokenTotalEntry[tokensInPotNames[index + 1]] * tokenLatestPriceFeed[tokensInPotNames[index + 1]] >=
                tokenTotalEntry[tokensInPotNames[index]] * tokenLatestPriceFeed[tokensInPotNames[index]]
            ) {
                tokenWithHighestValue = tokensInPotNames[index + 1];
            }
        }
    }

    /**   @dev reset the pot round
          @notice should be removed on launch on bsc
    */
    function resetPot() public onlyAdmin {
        startNewPot();
    }

    /**   @dev reset pot state to start a new round
     */
    function startNewPot() internal {
        for (uint256 index = 0; index < participantCount; index++) {
            delete participantsTotalEntryInUsd[participants[index]];
            for (uint256 index2 = 0; index2 < tokensInPotNames.length; index2++) {
                delete tokenTotalEntry[tokensInPotNames[index2]];
                delete participantsTokenEntries[participants[index]][tokensInPotNames[index2]];
            }
        }
        //@optimize
        // delete participants;
        delete participantCount;
        delete tokensInPotNames;
        delete totalPotUsdValue;

        // @optimize
        // delete entriesAddress;
        // delete entriesUsdValue;
        delete PotEntryCount;

        pot_state = POT_STATE.WAITING;
        delete potLiveTime;
        delete potStartTime;
        potCount++;
    }

    /**   @dev pays a specify address the specified token
          @param _tokenName name of the token to send
          @param _accountToPay address of the account to send token to
          @param _tokenValue the token value to send
    */
    function _payAccount(
        string memory _tokenName,
        address _accountToPay,
        uint256 _tokenValue
    ) internal returns(bool paid){
        if (_tokenValue <= 0) return paid;
        if (keccak256(bytes(_tokenName)) == keccak256(bytes('BNB'))) {
          paid = payable(_accountToPay).send(_tokenValue);
        } else {
          paid = IPRC20(tokenWhiteList[_tokenName].tokenAddress).transfer(_accountToPay, _tokenValue);
        }
    }

    /**   @dev generates a random number
     */
    function fullFillRandomness() public view returns (uint256) {
        return uint256(uint128(bytes16(keccak256(abi.encodePacked(getBNBPrice(), block.difficulty, block.timestamp)))));
    }

    /**
     * @dev add new particiant to particiants list, optimzing gas fee
     */
    function _addToParticipants(address participant) internal {
        if (participantCount == participants.length) {
            participants.push(participant);
        } else {
            participants[participantCount] = participant;
        }
        participantCount++;
    }

    /**
     * @dev Gets current BNB price in comparison with BNB and USDT
     */
    function getBNBPrice() public view returns (uint256 price) {
        (uint256 Res0, uint256 Res1) = _getTokenReserves(wbnbAddr, busdAddr);
        uint256 res1 = Res1 * (10**IPRC20(wbnbAddr).decimals());
        price = res1 / Res0;
    }

    /**
     * @dev Swaps accumulated fees into BNB, or BUSD first, and then to BNBP
     */
    function swapAccumulatedFees() external validBNBP nonReentrant {
        require(tokenWhiteListNames.length > 0, 'no wht-lst');

        address[] memory path = new address[](2);

        // Swap each token to BNB
        for (uint256 i = 0; i < adminFeeToken.length; i++) {
            string storage tokenName = adminFeeToken[i];
            Token storage tokenInfo = tokenWhiteList[tokenName];
            ERC20 token = ERC20(tokenInfo.tokenAddress);
            uint256 balance = adminFeeTokenValues[tokenName];

            if (keccak256(bytes(tokenName)) == keccak256(bytes('BNB'))) continue;
            if (keccak256(bytes(tokenName)) == keccak256(bytes('BUSD'))) continue;
            if (tokenInfo.tokenAddress == BNBP_Address) continue;

            if (balance > 0) {
                path[0] = tokenInfo.tokenAddress;
                token.approve(address(router), balance);

                if (tokenInfo.swapToBNB) {
                    path[1] = router.WETH();

                    try router.swapExactTokensForETH(balance, 0, path, address(this), block.timestamp) returns (
                        uint256[] memory swappedAmounts
                    ) {
                        adminFeeTokenValues[tokenName] -= swappedAmounts[0];
                        adminFeeTokenValues['BNB'] += swappedAmounts[1];
                    } catch Error(string memory reason) {
                        emit TokenSwapFailedString(tokenName, reason);
                    } catch (bytes memory reason) {
                        emit TokenSwapFailedBytes(tokenName, reason);
                    }
                } else {
                    path[1] = busdAddr;

                    try router.swapExactTokensForTokens(balance, 0, path, address(this), block.timestamp) returns (
                        uint256[] memory swappedAmounts
                    ) {
                        adminFeeTokenValues[tokenName] -= swappedAmounts[0];
                        adminFeeTokenValues['BUSD'] += swappedAmounts[1];
                    } catch Error(string memory reason) {
                        emit TokenSwapFailedString(tokenName, reason);
                    } catch (bytes memory reason) {
                        emit TokenSwapFailedBytes(tokenName, reason);
                    }
                }
            }
        }

        // Swap converted BNB to BNBP
        path[1] = BNBP_Address;
        uint256 BNBFee = adminFeeTokenValues['BNB'];
        uint256 BUSDFee = adminFeeTokenValues['BUSD'];
        uint256 hotWalletFee;

        if (hotWalletAddress != address(0)) {
            uint256 hotWalletBalance = hotWalletAddress.balance;
            if (hotWalletBalance <= hotWalletMinBalance) {
                hotWalletFee = hotWalletMaxBalance - hotWalletBalance;
                if (hotWalletFee > (BNBFee * 8) / 10) {
                    hotWalletFee = (BNBFee * 8) / 10;
                }
            }
            bool sent = payable(hotWalletAddress).send(hotWalletFee);
            if (!sent) {
                hotWalletFee = 0;
            } else {
                emit HotWalletSupplied(hotWalletAddress, hotWalletFee);
            }
        }

        if (adminFeeTokenValues['BNB'] > 0) {
            path[0] = router.WETH();
            uint256[] memory bnbSwapAmounts = router.swapExactETHForTokens{ value: BNBFee - hotWalletFee }(
                0,
                path,
                address(this),
                block.timestamp
            );
            adminFeeTokenValues['BNB'] -= (bnbSwapAmounts[0] + hotWalletFee);
            adminFeeTokenValues['BNBP'] += bnbSwapAmounts[1];
            _distributeToTokenomicsPools(bnbSwapAmounts[1]);
        }
        if (BUSDFee > 0) {
            IPRC20 busdToken = IPRC20(busdAddr);
            busdToken.approve(address(router), BUSDFee);

            path[0] = busdAddr;
            uint256[] memory busdSwapAmounts = router.swapExactTokensForTokens(
                BUSDFee,
                0,
                path,
                address(this),
                block.timestamp
            );
            adminFeeTokenValues['BUSD'] -= busdSwapAmounts[0];
            adminFeeTokenValues['BNBP'] += busdSwapAmounts[1];
            _distributeToTokenomicsPools(busdSwapAmounts[1]);
        }
    }

    /**
     * @dev sets hot wallet address
     */
    function setHotWalletAddress(address addr) external onlyAdmin {
        hotWalletAddress = addr;
    }

    /**
     * @dev sets hot wallet min and max balance
     */
    function setHotWalletSettings(uint256 min, uint256 max) external onlyAdmin {
        require(min < max, 'Min !< Max');
        hotWalletMinBalance = min;
        hotWalletMaxBalance = max;
    }

    /**
     * @dev Burns accumulated BNBP fees
     *
     * NOTE can't burn before the burn interval
     */
    function burnAccumulatedBNBP() external validBNBP {
        IBNBP BNBPToken = IBNBP(BNBP_Address);
        uint256 BNBP_Balance = BNBPToken.balanceOf(address(this));

        require(BNBP_Balance > 0, 'No BNBP');
        require(burnPool > 0, 'No burn amt');
        require(burnPool <= BNBP_Balance, 'Wrong BNBP Fee');

        BNBPToken.performBurn();
        adminFeeTokenValues['BNBP'] -= burnPool;
        burnPool = 0;
        emit BurnSuccess(burnPool);
    }

    /**
     * @dev call for an airdrop on the BNBP token contract
     */
    function airdropAccumulatedBNBP() external validBNBP returns (uint256) {
        IBNBP BNBPToken = IBNBP(BNBP_Address);
        uint256 amount = BNBPToken.performAirdrop();

        airdropPool -= amount;
        adminFeeTokenValues['BNBP'] -= amount;

        emit AirdropSuccess(amount);
        return amount;
    }

    /**
     * @dev call for an airdrop on the BNBP token contract
     */
    function lotteryAccumulatedBNBP() external validBNBP returns (address) {
        IBNBP BNBPToken = IBNBP(BNBP_Address);
        uint256 BNBP_Balance = BNBPToken.balanceOf(address(this));

        require(BNBP_Balance > 0, 'No BNBP');
        require(lotteryPool > 0, 'No lott amt');
        require(lotteryPool <= BNBP_Balance, 'Wrg BNBP Fee');

        address winner = BNBPToken.performLottery();
        adminFeeTokenValues['BNBP'] -= lotteryPool;
        lotteryPool = 0;

        emit LotterySuccess(winner);
        return winner;
    }

    /**
     * @dev updates percentages for airdrop, lottery, and burn
     *
     * NOTE The sum of 3 params should be 100, otherwise it reverts
     */
    function setTokenomicsPercentage(
        uint8 _airdrop,
        uint8 _lottery,
        uint8 _burn
    ) external onlyAdmin {
        require(_airdrop + _lottery + _burn == 100, 'Shld be 100');

        airdropPercentage = _airdrop;
        lotteryPercentage = _lottery;
        burnPercentage = _burn;
    }

    /**
     * @dev distribute BNBP balance changes to tokenomics pools
     *
     */
    function _distributeToTokenomicsPools(uint256 value) internal {
        uint256 deltaAirdropAmount = (value * airdropPercentage) / 100;
        uint256 deltaLotteryAmount = (value * lotteryPercentage) / 100;
        uint256 deltaBurnAmount = value - deltaAirdropAmount - deltaLotteryAmount;

        airdropPool += deltaAirdropAmount;
        lotteryPool += deltaLotteryAmount;
        burnPool += deltaBurnAmount;
    }

    /**
     * @dev Sets Airdrop interval
     *
     */
    function setAirdropInterval(uint256 interval) external onlyAdmin {
        airdropInterval = interval;
    }

    /**
     * @dev Sets Burn interval
     *
     */
    function setBurnInterval(uint256 interval) external onlyAdmin {
        burnInterval = interval;
    }

    /**
     * @dev Sets Lottery interval
     *
     */
    function setLotteryInterval(uint256 interval) external onlyAdmin {
        lotteryInterval = interval;
    }

    /**
     * @dev Sets minimum BNBP value to get airdrop and lottery
     *
     */
    function setStakingMinimum(uint256 value) external onlyAdmin {
        stakingMinimum = value;
    }

    /**
     * @dev Sets minimum BNBP value to get airdrop and lottery
     *
     */
    function setMinimumStakingTime(uint256 value) external onlyAdmin {
        minimumStakingTime = value;
    }

    receive() external payable {
        if (msg.sender == address(router)) return;

        require((tokenLatestPriceFeed['BNB'] * msg.value) / 10**18 >= minEntranceInUsd, '< min');
        _EnterPot('BNB', msg.value, msg.sender);
    }

    function sendBNBForTransactionFees() public payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

interface IBNBP {
    error AirdropTimeError();

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function isUserAddress(address addr) external view returns (bool);

    function calculatePairAddress() external view returns (address);

    function performAirdrop() external returns (uint256);

    function performBurn() external returns (uint256);

    function performLottery() external returns (address);

    function setPotContractAddress(address addr) external;

    function setAirdropPercentage(uint8 percentage) external;

    function setAirdropInterval(uint256 interval) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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