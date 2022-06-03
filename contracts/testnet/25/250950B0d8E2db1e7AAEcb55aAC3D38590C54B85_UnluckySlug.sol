// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @author TheSlugPrince (you can find me on Telegram and Twitter)
/// @title Unlucky Slug Lottery
/// @notice An automated lottery which gives away NFTs of different categories depending on their prize,
///         and a Jackpot which has been accumulated. The lottery uses Chainlink VRF v2 to generate
///         verifiable Random Numbers.
contract UnluckySlug is VRFConsumerBaseV2, ERC721, IERC721Receiver, Ownable, Pausable, ReentrancyGuard {
    // to Increment the tokenId of the goldenTicket
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    Counters.Counter private _tokenIds;
    uint256 constant LIMIT_GOLDEN_TICKETS = 10 * 10**3;
    // Chainlink VRF v2 Variables
    VRFCoordinatorV2Interface COORDINATOR;
    address constant VRF_COORDINATOR = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
    bytes32 keyHash = 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92;
    uint32 constant callbackGasLimit = 10 * 10**5;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords =  2;
    uint64 subscriptionID;

    mapping(uint256 => address payable) public requestIdToAddress;
    mapping(uint256 => uint256[]) public requestIdToRandomWords;

    mapping(address => address) public referralToReferrer;
    mapping(address => uint256) public moneySpent;
    mapping(address => uint256) public unluckyThrows;

    uint256 public jackPotBalance;

    struct NFTs {
        address contractAddress;
        uint256 tokenID;
        uint256 weiCost;
        uint256 probability;
    }

    NFTs[] public topNFTs;
    NFTs[] public mediumNFTs;
    NFTs[] public normalNFTs;

    // @dev Helpers to calculate probability of each NFT
    uint256 public averageWeiCostTopNFTs;
    uint256 public sumWeiCostTopNFTs;
    uint256 public averageWeiCostMediumNFTs;
    uint256 public sumWeiCostMediumNFTs;
    uint256 public averageWeiCostNormalNFTs;
    uint256 public sumWeiCostNormalNFTs;

    uint256 public topGroupProbability;
    uint256 public mediumGroupProbability;
    uint256 public normalGroupProbability;
    uint256 public refundHundredTicketProbability;
    uint256 public refundTenTicketProbability;
    uint256 public refundOneTicketProbability;
    uint256 public noneGroupProbability;

    uint256[8] public groupCumValues;
    uint256[] public topNFTsCumValues;
    uint256[] public mediumNFTsCumValues;
    uint256[] public normalNFTsCumValues;

    // @dev The cost for 1 ticket in the loterry.
    uint256 public ticketCost = .005 ether;
    // @dev Variable used to calculate the Probabilities of the groups. Tweaking this variable,
    //      and adjusting the average group cost, it gives the flexibility to approximate a Margin
    //      for the lottery. This number has been adjusted to give a value of 1.65 for the ratio
    //      of (revenueForTheProject / CostOfNFTsGivenAway).
    //      Note: Is difficult to estimate this ratio since variables are dynamic (LINK and ETH
    //            price, gasFees, ChainLink Premium Fee, gasUsage, distribution of throws per
    //            player which affects the slugMeter multiplier, throws with referrals, etc...)
    uint256 public constantProbability = 35;
    // @dev There is a 6 decimals precision for the Probabilities. In solidity, currently there is
    //      no float available, so must represent the probabilities as integers. In this code, a
    //      probability of 1 is equivalent to probabilityEquivalentToOne.
    uint256 public constant probabilityEquivalentToOne = 10 * 10**6;
    // @dev Probability of JackPot is 1/probabilityEquivalentToOne which is equivalent to 0.000001
    uint256 public jackPotProbability = 1;
    // @dev Probability of GoldenTicket initially is 19683/probabilityEquivalentToOne which is
    //      equivalent to 0.019683. Every 2000 mints, the probability is divided by 3... so the
    //      sequence of probabilities are 196830 -> 65610 -> 21870 -> 7290 -> 2430
    //      It takes approximately 15,000,000 throws to mint all of the collection
    uint256 public goldenTicketProbability = 196830;
    // @dev Percentage of the value of the ticket which go to the JackPot
    uint8 public constant valuePercentageToJackpot = 5;
    // @dev Percentage of the value of the ticket which go to the Referrer if the player has one
    uint8 public constant referrerCommisionPercentage = 2;
    // @dev Percentage value of the ticket which go to the player if the player has a referrer
    uint8 public constant cashbackIncentivePercentage = 2;
    event JackPot(address indexed _to, uint256 _value);
    event TicketRepayment(address indexed _to, uint256 _value);
    event DepositNFT(address contractAddress, uint256 tokenID, uint256 WeiCost);
    event WithdrawTopNFT(address indexed player, address contractAddress, uint256 tokenID);
    event WithdrawMediumNFT(address indexed player, address contractAddress, uint256 tokenID);
    event WithdrawNormalNFT(address indexed player, address contractAddress, uint256 tokenID);
    event GoldenTicket(address indexed player, uint256 tokenID);

    // @dev Constructor to set up the VRF Consumer
    // @param subscriptionId Identifier of the VRF Subscription
    constructor(uint64 _subscriptionID) VRFConsumerBaseV2(VRF_COORDINATOR) ERC721("UnluckySlug", "SLUG") {
        COORDINATOR = VRFCoordinatorV2Interface(VRF_COORDINATOR);
        subscriptionID = _subscriptionID;
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
    }

    // @dev Function to pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    // @dev Function to unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }

    // @dev Function to be able to receive and send NFTs from the smart contract
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        public
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }

    // @dev Function to set a the Gas limit key Hash for the callback of ChainLink VRF
    // @param _keyHash New Gas Limit key Hash
    function setKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash= _keyHash;
    }

    // @dev Function to set a subscription ID for ChainLink VRF
    // @param _subscriptionID New subscription ID
    function setSubscriptionID(uint64 _subscriptionID) external onlyOwner {
        subscriptionID = _subscriptionID;
    }

    // @dev Function to set a referrer so you can get cashback and the referrer earns commisions.
    // @param referrerAddress Address of the referrer
    function setReferrer(address referrerAddress) external whenNotPaused {
        require(moneySpent[referrerAddress] >= .01 ether , "The referrer must spend more than 0.1ETH in the lottery");
        referralToReferrer[msg.sender] = referrerAddress;
    }

    // @dev Function to be able to modify the constantProbability in case of some dynamic variables go out of control
    // @param _constantProbability New constant Probability to adjust margin
    function setconstantProbability(uint256 _constantProbability) external onlyOwner {
        constantProbability = _constantProbability;
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
    }

    // @dev Function to be able to modify the ticketCost in case of gasFees are more favorable, or unfavorable
    // @param ticketCostWei New ticket cost
    function setTicketCost(uint256 ticketCostWei) external onlyOwner {
        ticketCost = ticketCostWei;
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
    }

    // @dev Function to be able to modify the jackPot Probability in case of no winners in long time
    // @param _jackPotProbability New JackPot Probability
    function setJackPotProbability(uint256 _jackPotProbability) external onlyOwner {
        jackPotProbability = _jackPotProbability;
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
    }

    // @dev Function to withdraw the funds to buy more NFTs, and for the project.
    //      Notice that the jackPotBalance cannot be withdraw from this contract.
    // @param _to Address to send the funds
    function withdrawFunds(address payable _to, uint256 amount) external onlyOwner {
        uint256 balanceAvailableToTransfer = address(this).balance - jackPotBalance;
        require(amount <= balanceAvailableToTransfer, "The amount exceeds the available balance");
        _to.transfer(amount);
    }

    // @dev Function to withdraw all the NFTs deposited from the smart contract
    // @param _to Address to send the funds
    function withdrawAllNFTs(address _to) external onlyOwner {
        for (uint i=0; i<topNFTs.length; i++) {
            ERC721(topNFTs[i].contractAddress).safeTransferFrom(address(this), _to, topNFTs[i].tokenID);
        }
        for (uint i=0; i<mediumNFTs.length; i++) {
            ERC721(mediumNFTs[i].contractAddress).safeTransferFrom(address(this), _to, mediumNFTs[i].tokenID);
        }
        for (uint i=0; i<normalNFTs.length; i++) {
            ERC721(normalNFTs[i].contractAddress).safeTransferFrom(address(this), _to, normalNFTs[i].tokenID);
        }
        delete topNFTs;
        delete mediumNFTs;
        delete normalNFTs;
        delete averageWeiCostTopNFTs;
        delete sumWeiCostTopNFTs;
        delete averageWeiCostMediumNFTs;
        delete sumWeiCostMediumNFTs;
        delete averageWeiCostNormalNFTs;
        delete sumWeiCostNormalNFTs;
        delete topGroupProbability;
        delete mediumGroupProbability;
        delete normalGroupProbability;
        delete noneGroupProbability;
        delete groupCumValues;
        delete topNFTsCumValues;
        delete mediumNFTsCumValues;
        delete normalNFTsCumValues;
    }

    // @dev Function to be able to withdraw any ERC20 token in case of receiving some (you never know)
    // @param _tokenContract The contract address of the token to be withdrawn
    // @param _amount Amount of the token to be withdrawn
    function withdrawERC20(IERC20 _tokenContract, uint256 _amount) external onlyOwner {
        _tokenContract.safeTransfer(msg.sender, _amount);
    }

    // @dev Function to enter 1 ticket of the lottery and transfer some of the value of the ticket to refferrals and cashback
    // @return requestId requestId generated by ChainLink VRF to identity different requests
    function enterThrow() external payable whenNotPaused nonReentrant returns (uint256){
        require(msg.value == ticketCost , "Not exact Value...  Send exactly the ticket cost amount");
        uint256 requestId = requestRandomWords();
        unchecked { jackPotBalance += msg.value * valuePercentageToJackpot / 100; }

        address referrerAddress = referralToReferrer[msg.sender];
        if (referrerAddress != address(0)) {
            unchecked { payable(referrerAddress).transfer(msg.value * referrerCommisionPercentage / 100); }
            unchecked { payable(msg.sender).transfer(msg.value * cashbackIncentivePercentage / 100); }
        }
        moneySpent[msg.sender] += msg.value;
        return requestId;
    }

    // @dev Function for the owner to be able to deposit Funds for the repayment of tickets
    function depositFunds() external payable onlyOwner {

    }

    // @dev Function for the owner to be able to deposit TOP NFTs. The estimated cost is 100ETH per NFT in this group.
    // @param contractAddress The contract address of the NFT to be deposited
    // @param tokenID The token ID of the NFT to be deposited
    // @param WeiCost Estimated cost of the NFT in Wei
    function depositTopNFT(address contractAddress, uint256 tokenID, uint256 WeiCost)
        external
        onlyOwner
    {
        ERC721 NFTContract = ERC721(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenID);
        topNFTs.push(NFTs(contractAddress, tokenID, WeiCost, 0));
        sumWeiCostTopNFTs += WeiCost;
        averageWeiCostTopNFTs = sumWeiCostTopNFTs / topNFTs.length;
        recalculateTopProbabilities();
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
        emit DepositNFT(contractAddress, tokenID, WeiCost);
    }

    // @dev Function for the owner to be able to deposit MEDIUM NFTs. The estimated cost is 10ETH per NFT in this group.
    // @param contractAddress The contract address of the NFT to be deposited
    // @param tokenID The token ID of the NFT to be deposited
    // @param WeiCost Estimated cost of the NFT in Wei
    function depositMediumNFT(address contractAddress, uint256 tokenID, uint256 WeiCost)
        external
        onlyOwner
    {
        ERC721 NFTContract = ERC721(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenID);
        mediumNFTs.push(NFTs(contractAddress, tokenID, WeiCost, 0));
        sumWeiCostMediumNFTs += WeiCost;
        averageWeiCostMediumNFTs = sumWeiCostMediumNFTs / mediumNFTs.length;
        recalculateMediumProbabilities();
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
        emit DepositNFT(contractAddress, tokenID, WeiCost);
    }

    // @dev Function for the owner to be able to deposit NORMAL NFTs. The estimated cost is 1ETH per NFT in this group.
    // @param contractAddress The contract address of the NFT to be deposited
    // @param tokenID The token ID of the NFT to be deposited
    // @param WeiCost Estimated cost of the NFT in Wei
    function depositNormalNFT(address contractAddress, uint256 tokenID, uint256 WeiCost)
        external
        onlyOwner
    {
        ERC721 NFTContract = ERC721(contractAddress);
        NFTContract.safeTransferFrom(msg.sender, address(this), tokenID);
        normalNFTs.push(NFTs(contractAddress, tokenID, WeiCost, 0));
        sumWeiCostNormalNFTs += WeiCost;
        averageWeiCostNormalNFTs = sumWeiCostNormalNFTs / normalNFTs.length;
        recalculateNormalProbabilities();
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
        emit DepositNFT(contractAddress, tokenID, WeiCost);
    }

    // @dev Function to withdraw TOP NFTs. This function is internally called after receiving the random numbers
    //      from ChainLink VRF
    // @param index Index in the TopNFTs array to be withdrawn
    // @param requestId requestId generated by ChainLink VRF to identity different requests
    function withdrawTopNFT(uint256 index, address player) internal {
        NFTs memory NFTPrize = topNFTs[index];
        ERC721 NFTContract = ERC721(NFTPrize.contractAddress);
        NFTContract.safeTransferFrom(address(this), player, NFTPrize.tokenID);
        topNFTs[index] = topNFTs[topNFTs.length - 1];
        topNFTs.pop();
        sumWeiCostTopNFTs -= NFTPrize.weiCost;
        if (topNFTs.length == 0) {
            averageWeiCostTopNFTs = 0;
        } else {
            averageWeiCostTopNFTs = sumWeiCostTopNFTs / topNFTs.length;
            recalculateTopProbabilities();
        }
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
        emit WithdrawTopNFT(player, NFTPrize.contractAddress, NFTPrize.tokenID);
    }

    // @dev Function to withdraw MEDIUM NFTs. This function is internally called after receiving the random numbers
    //      from ChainLink VRF
    // @param index Index in the TopNFTs array to be withdrawn
    // @param requestId requestId generated by ChainLink VRF to identity different requests
    function withdrawMediumNFT(uint256 index, address player) internal {
        NFTs memory NFTPrize = mediumNFTs[index];
        ERC721 NFTContract = ERC721(NFTPrize.contractAddress);
        NFTContract.safeTransferFrom(address(this), player, NFTPrize.tokenID);
        mediumNFTs[index] = mediumNFTs[mediumNFTs.length - 1];
        mediumNFTs.pop();
        sumWeiCostMediumNFTs -= NFTPrize.weiCost;
        if (mediumNFTs.length == 0) {
            averageWeiCostMediumNFTs = 0;
        } else {
            averageWeiCostMediumNFTs = sumWeiCostMediumNFTs / mediumNFTs.length;
            recalculateMediumProbabilities();
        }
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
        emit WithdrawMediumNFT(player, NFTPrize.contractAddress, NFTPrize.tokenID);
    }

    // @dev Function to withdraw NORMAL NFTs. This function is internally called after receiving the random numbers
    //      from ChainLink VRF
    // @param index Index in the TopNFTs array to be withdrawn
    // @param requestId requestId generated by ChainLink VRF to identity different requests
    function withdrawNormalNFT(uint256 index, address player) internal {
        NFTs memory NFTPrize = normalNFTs[index];
        ERC721 NFTContract = ERC721(NFTPrize.contractAddress);
        NFTContract.safeTransferFrom(address(this), player, NFTPrize.tokenID);
        normalNFTs[index] = normalNFTs[normalNFTs.length - 1];
        normalNFTs.pop();
        sumWeiCostNormalNFTs -= NFTPrize.weiCost;
        if (normalNFTs.length == 0) {
            averageWeiCostNormalNFTs = 0;
        } else {
            averageWeiCostNormalNFTs = sumWeiCostNormalNFTs / normalNFTs.length;
            recalculateNormalProbabilities();
        }
        recalculateGroupProbabilities();
        recalulateCumGroupProb();
        emit WithdrawNormalNFT(player, NFTPrize.contractAddress, NFTPrize.tokenID);
    }

    // @dev Helper function to recalculate the probabilities of the different groups.
    //      Notice that noneGroupProbability is calculated from substracting the other probabilities, which is
    //      not a problem since the probabilities are very small.
    function recalculateGroupProbabilities() internal {
        if (averageWeiCostTopNFTs == 0) {
            topGroupProbability = 0;
        } else {
            topGroupProbability = probabilityEquivalentToOne / 9;
        }

        if (averageWeiCostMediumNFTs == 0) {
            mediumGroupProbability = 0;
        } else {
            mediumGroupProbability = probabilityEquivalentToOne / 9;
        }

        if (averageWeiCostNormalNFTs == 0) {
            normalGroupProbability = 0;
        } else {
            normalGroupProbability = probabilityEquivalentToOne / 9;
        }

        refundHundredTicketProbability = probabilityEquivalentToOne / 9;
        refundTenTicketProbability = probabilityEquivalentToOne / 9;
        refundOneTicketProbability = probabilityEquivalentToOne / 9;
        
        jackPotProbability = probabilityEquivalentToOne - (topGroupProbability + mediumGroupProbability +
             normalGroupProbability + refundHundredTicketProbability + refundTenTicketProbability + refundOneTicketProbability);

        noneGroupProbability = 0;
    }

    // @dev Helper function to recalculate the cumulative values of the different groups, which is very useful to determine
    //      if a player has won a prize.
    function recalulateCumGroupProb() internal {
        uint256[8] memory groupProbabilities = [
            jackPotProbability,
            topGroupProbability,
            mediumGroupProbability,
            normalGroupProbability,
            refundHundredTicketProbability,
            refundTenTicketProbability,
            refundOneTicketProbability,
            noneGroupProbability
        ];

        uint256 sum_cum = 0;
        for (uint i=0; i<groupProbabilities.length; i++) {
            sum_cum += groupProbabilities[i];
            groupCumValues[i] = sum_cum;
        }
    }

    // @dev Helper function to normalize the TOP NFTs Probabilities based on their cost
    function recalculateTopProbabilities() internal {
        delete topNFTsCumValues;
        uint256 cumValue;
        for (uint i=0; i<topNFTs.length; i++) {
            topNFTs[i].probability = topNFTs[i].weiCost * probabilityEquivalentToOne / sumWeiCostTopNFTs;
            cumValue += topNFTs[i].probability;
            topNFTsCumValues.push(cumValue);
        }
    }

    // @dev Helper function to normalize the MEDIUM NFTs Probabilities based on their cost
    function recalculateMediumProbabilities() internal {
        delete mediumNFTsCumValues;
        uint256 cumValue;
        for (uint i=0; i<mediumNFTs.length; i++) {
            mediumNFTs[i].probability = mediumNFTs[i].weiCost * probabilityEquivalentToOne / sumWeiCostMediumNFTs;
            cumValue += mediumNFTs[i].probability;
            mediumNFTsCumValues.push(cumValue);
        }
    }

    // @dev Helper function to normalize the NORMAL NFTs Probabilities based on their cost
    function recalculateNormalProbabilities() internal {
        delete normalNFTsCumValues;
        uint256 cumValue;
        for (uint i=0; i<normalNFTs.length; i++) {
            normalNFTs[i].probability = normalNFTs[i].weiCost * probabilityEquivalentToOne / sumWeiCostNormalNFTs;
            cumValue += normalNFTs[i].probability;
            normalNFTsCumValues.push(cumValue);
        }
    }

    // @dev Function to request the random numbers from Chainlink VRF
    // @return requestId requestId generated by ChainLink VRF to identity different requests
    function requestRandomWords() internal returns (uint256){
        // Will revert if subscription is not set and funded.
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionID,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        requestIdToAddress[requestId] = payable(msg.sender);
        return requestId;
    }

    // @dev Function to receive the random numbers from Chainlink VRF, and then executes logic to
    //      determine if the player has won any prize
    // @param requestId requestId generated by ChainLink VRF to identity different requests
    // @param randomWords Randomwords generated from ChainLink VRF
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        //Saving just in case
        requestIdToRandomWords[requestId] = randomWords;
        checkIfWinner(requestId, randomWords);
    }

    // @dev Function to check if the requestId from a player gives any prize, and if yes proceeds to send it.
    //      This function is internally called after fulfillRandomWords is called by Chainlink VRF
    // @param requestId requestId generated by ChainLink VRF to identity different requests
    function checkIfWinner(uint256 requestId, uint256[] memory randomWords) internal {
        address player = requestIdToAddress[requestId];
        uint256 groupRandomRange = (randomWords[0] % probabilityEquivalentToOne) + 1;
        uint256 nftRandomRange = (randomWords[1] % probabilityEquivalentToOne) + 1;
        uint8 slugMultiplier = getSlugmeterMultiplier(player);
        if (groupRandomRange <= groupCumValues[0] * slugMultiplier){
            // JackPot Prize
            sendJackPot(player);
            unluckyThrows[player] = 0;
        } else if (groupRandomRange <= groupCumValues[1] * slugMultiplier) {
            // Top NFT Prize
            uint256 index = checkNFTPrize(nftRandomRange, 1);
            withdrawTopNFT(index, player);
            unluckyThrows[player] = 0;
        } else if (groupRandomRange <= groupCumValues[2] * slugMultiplier) {
            // Medium NFT Prize
            uint256 index = checkNFTPrize(nftRandomRange, 2);
            withdrawMediumNFT(index, player);
            unluckyThrows[player] = 0;
        } else if (groupRandomRange <= groupCumValues[3] * slugMultiplier) {
            // Normal NFT Prize
            uint256 index = checkNFTPrize(nftRandomRange, 3);
            withdrawNormalNFT(index, player);
            unluckyThrows[player] = 0;
        } else if (groupRandomRange <= groupCumValues[4] * slugMultiplier) {
            // Refund x100 Ticket Prize
            payable(player).transfer(100 * ticketCost);
            emit TicketRepayment(player, 100 * ticketCost);
            unluckyThrows[player] = 0;
        } else if (groupRandomRange <= groupCumValues[5] * slugMultiplier) {
            // Refund x10 Ticket Prize
            payable(player).transfer(10 * ticketCost);
            emit TicketRepayment(player, 10 * ticketCost);
            unluckyThrows[player] = 0;
        } else if (groupRandomRange <= groupCumValues[6] * slugMultiplier) {
            // Refund x1 Ticket Prize
            payable(player).transfer(ticketCost);
            emit TicketRepayment(player, ticketCost);
            unluckyThrows[player] = 0;
        } else {
            if (nftRandomRange <= goldenTicketProbability) {
                mintGoldenTicket(player);
            }
            unluckyThrows[player] += 1;
        }
    }

    // @dev Function to send the jackpot to the player who won the prize
    //      This function is internally called after fulfillRandomWords is called by Chainlink VRF
    // @param player Address of the player
    function sendJackPot(address player) internal {
        payable(player).transfer(jackPotBalance);
        emit JackPot(player, jackPotBalance);
        jackPotBalance = 0;
    }

    // @dev Function to mint a GoldenTicket for the players who have not won any 'prize' but at least the bastards had a little bit of luck
    // @param player Address of the player
    function mintGoldenTicket(address player) internal {
        uint256 newItemId;
        _tokenIds.increment();
        newItemId = _tokenIds.current();
        if (newItemId <= LIMIT_GOLDEN_TICKETS) {
            _mint(player, newItemId);
            emit GoldenTicket(player, newItemId);
            if (newItemId % 2000 == 0) {
                goldenTicketProbability /= 3;
            }
        }
    }

    // @dev Function to get the SlugMeter multiplier based on the unlucky throws
    // @param player Address of the player
    // @return slugMultiplier The amount of multiplier of Probability. If a multiplier of 2, and a probability
    //         of 0.1, then now you have a probability of 0.2
    function getSlugmeterMultiplier(address player) internal view returns (uint8) {
        uint256 _unluckyThrows = unluckyThrows[player];
        uint8 slugMultiplier;
        if (_unluckyThrows < 5) {
            slugMultiplier = 1;
        } else if (_unluckyThrows < 20) {
            slugMultiplier = 2;
        } else {
            slugMultiplier = 3;
        }
        return slugMultiplier;
    }

    // @dev Function to get the index of the NFT to be sent from a group.
    // @param nftRandomRange Random Number which determines which of the NFT prize is
    // @param group Group to be calculated the index
    // @return index Index in the TopNFTs array to be withdrawn
    function checkNFTPrize(uint256 nftRandomRange, uint8 group) internal view returns (uint256) {
        uint256 index;
        uint256[] memory NFTarray;
        if (group == 1) {
            NFTarray = topNFTsCumValues;
        } else if (group == 2) {
            NFTarray = mediumNFTsCumValues;
        } else {
            NFTarray = normalNFTsCumValues;
        }
        if (nftRandomRange <= NFTarray[0]) {
            index = 0;
        } else if (nftRandomRange >= NFTarray[NFTarray.length - 1]) {
            index = NFTarray.length - 1;
        } else {
            for (uint i=0; i<NFTarray.length - 1; i++) {
                if (NFTarray[i] < nftRandomRange && nftRandomRange <= NFTarray[i+1]) {
                    index = i;
                }
            }
        }
        return index;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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