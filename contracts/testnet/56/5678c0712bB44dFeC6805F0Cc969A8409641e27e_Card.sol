// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Card is ERC721, ERC2981, Pausable, Ownable {
    /* ==================== VARIABLES SECTION ==================== */
    /**
    * @notice Maximum NFT supply
    *
    * @dev Maximum NFT that can be minted
    */
    // **NOTE: MAX_SUPPLY value should be change to 10000 before mainnet deployment
    uint256 public constant MAX_SUPPLY = 10000;

    /**
    * @notice Total supply
    *
    * @dev Total minted tokens
    */
    uint256 public totalSupply = 0;

    /**
    * @notice Maximum Mint Per Transaction
    *
    * @dev Maximum NFT that can be minted per transaction. Avoiding Gas Limit error
    */
    uint256 public maxMintPerTransaction = 5;

    /**
    * @notice Minting prices
    *
    * @dev Minting price in ether and it is an array
    * @dev Should hold 4 objects represent the price of tiers via index
    */
    uint256[] public mintPrices;

    /**
    * @notice Minting Limit
    *
    * @dev values that will represent the mint limit for each tier
    * @dev Should hold 4 objects represent the limit of tiers via index
    */
    uint256[] public mintLimit;

    /**
    * @dev this is the temporary metadata for all NFTs.
    */
    // **NOTE: previewURI value should be change before mainnet deployment
    // **NOTE: replace the value once you created the hidden metadata
     // **NOTE: example value: ipfs://QmUfkXJHASK1fxb9hRyc6Ez2pJMpic7Nwkkay8TSaGDj3D/
    string public previewURI = "";  

    /**
    * @notice Base token URI of token
    *
    * @dev This will hold the base uri for token metadata
    */
    // **NOTE: example value: https://www.ipfs.io/nft/
    string public baseURI = "";

    /**
    * @notice Contract-level metadata
    * 
    * @dev variable is declared for opensea contract-level metadata 
    *      for on-chain royalty see https://docs.opensea.io/docs/contract-level-metadata
    */
    string public contractURI = "";

    /**
    * @notice Suffix of baseTokenURI    
    */
    string tokenURISuffix = ".json";

    /**
    * @notice Withdrawal recipient address
    *
    * @dev Address that is capable to withdraw contract's balance
    *
    */
    // **NOTE: withdrawalAddress value should be change before mainnet deployment
    address public withdrawalAddress = 0x1BA8f5D548Bf698d5b33d0BD5628C2EB76253264;

    /**
    * @notice Wallet Address to receive EIP-2981 royalties from secondary sales
    *         see https://eips.ethereum.org/EIPS/eip-2981
    *
    * @dev The wallet address here is a EOA
    */
    // **NOTE: royaltyReceiverAddress value should be replace before mainnet deployment
    address public royaltyReceiverAddress = 0x1BA8f5D548Bf698d5b33d0BD5628C2EB76253264;

    /**
    * @notice Percentage of token sale price to be used for EIP-2981 royalties from secondary sales
    *         see https://eips.ethereum.org/EIPS/eip-2981
    *
    * @dev Has 2 decimal precision. E.g. a value of 100 would result in a 1% royalty fee    
    */
    // **NOTE: royaltyFeesInBips value should be replace before mainnet deployment
    uint96 public royaltyFeesInBips = 100; // equivalent to 1%

    /**
    * @notice Mode to determine if tokenURI will return tokenIdURI or previewURI
    *
    * @dev Should be set to true after all nft is minted and migrated to ipfs
    */
    bool public revealURIMode = false;

    /**
    * @notice Mode to determine if presale is enabled or not
    *
    * @dev Should be set to true if presale started
    */
    bool public presaleMode = false;

    /**
    * @notice Merkle root
    *
    * @dev Should be set by owner after whitelising
    *
    */
    // **NOTE: merkleRoot value should be change before mainnet deployment
    // **NOTE: example value: 0xab4d968681a24299539b94c79362293790048a52eb4126b730e7f7cc36b35c2c
    bytes32 public merkleRoot;
    /* ==================== VARIABLES SECTION ==================== */

    /* ==================== MAPPING SECTION ==================== */
    /**
    * @notice Maps key => pair value
    *
    * @dev use token id to fetch the tier value
    */
    mapping(uint256 => uint256) public tiers;

    /**
    * @notice Maps key => pair value
    *
    * @dev use token id to fetch the token uri
    */
    mapping(uint256 => string) public tokenURIOfIds;

    mapping(uint256 => uint256) public tierSupply;
    /* ==================== MAPPING SECTION ==================== */

    /* ==================== EVENTS SECTION ==================== */
    /**
    * @dev Called in `safeMint()` when we minted a token
    * 
    * @param _account owner of the token
    * @param _id token id of minted token
    * @param _tier category of the token's corresponding tier (0-Silver, 1-Gold, 2-Diamond, 3-Platinum)
    */
    event MintNFT(address _account, uint256 _id, uint256 _tier);

    /**
    * @dev Called in `_withdraw()` when widthdrawing from contract balance
    * 
    * @param _withdrawalAddress address of calling the `_withdraw()`
    * @param _amount amount withdrawn
    */
    event Withdraw(address _withdrawalAddress, uint256 _amount);

    /**
    * @dev Called in `setRoyaltyInfo()` when update royalty info
    * 
    * @param _royaltyReceiverAddress address to receive EIP-2981 royalties from secondary sales 
    * @param royaltyFeesInBips has 2 decimal precision. E.g. a value of 100 would result in a 1% royalty fee
    */
    event SetRoyaltyInfo(address _royaltyReceiverAddress, uint96 royaltyFeesInBips);

    /**
    * @dev Fired in `setPreviewURI()` when update the previewURI
    * 
    * @param _previewURI new preview URI for nft
    */
    event SetPreviewURI(string _previewURI);

    /**
    * @dev Fired in `setBaseURI()` when update the baseURI
    * 
    * @param _baseURI new base URI for nft
    */
    event SetBaseURI(string _baseURI);

    /**
    * @dev Fired in `enableURIMode()` and `disableURIMode()` when update the revealURIMode
    * 
    * @param _uriMode mode for revealURIMode (true or false)
    */
    event SetBaseURIMode(bool _uriMode);

    /**
    * @dev Called in `setContractURI()` when update the contractURI
    * 
    * @param _contractURI new contractURI
    */
    event SetContractURI(string _contractURI);

    /**
    * @dev Called in `setTokenURI()` when update the tokenURIOfIds
    * 
    * @param _id of the token
    * @param _uri metadata of the token
    */
    event SetTokenURI(uint256 _id, string _uri);

    /**
    * @dev Called in `setWithdrawalRecipient()` when update withdrawalAddress
    * 
    * @param _withdrawalAddress new withdrawal address
    */
    event SetWithdrawalRecipient(address _withdrawalAddress);

    /**
    * @dev Called in `setMintPrices()` when update mintPrices
    * 
    * @param _prices new mintPrices
    */
    event SetMintPrices(uint256[] _prices);

    /**
    * @dev Called in `setMintLimit()` when update mintLimit
    * 
    * @param _limits new mintLimit per tier
    */
    event SetMintLimit(uint256[] _limits);

    /**
    * @dev Called in `setPresaleMode()` when update presaleMode
    * 
    * @param _mode new value of presaleMode
    */
    event SetPresaleMode(bool _mode);

    /**
    * @dev Fired in `setMerkleRoot()` when update merkleRoot
    * 
    * @param _merkleRoot value of new merkleRoot
    */
    event SetMerkleRoot(bytes32 _merkleRoot);
    /* ==================== EVENTS SECTION ==================== */

    /* ==================== MODIFIERS SECTION ==================== */
    /**
    * @dev Reverts if the caller is not an EOA of not the owner    
    */
    modifier isCallerAllowed() {
        require(tx.origin == msg.sender || owner() == msg.sender, "IC"); // Invalid Caller
        _;
    }

    /**
    * @dev Reverts if the totalSupply plus the id is greater than max supply
    * @dev Reverts if the id is greater than max mint per transaction
    * @dev Reverts if the id and tier is not same length
    */
    modifier isIdAndTierPassed1(uint256 _id, uint256 _tier) {               
        require((totalSupply + _id) <= MAX_SUPPLY, "MR"); // Max Reached
        require(_id <= maxMintPerTransaction, "MI"); // Max Invalid 
        require(_id == _tier, "NSL"); // Not Same Length        
        _;
    }

    /**
    * @dev Reverts if tier is out of range in mint prices
    * @dev Reverts if tiers quantity plus tier supply per tier is greater than set mint limit per tier
    * @dev Reverts if token id is out of range front required id range per tier
    * @dev Reverts if the payment is not equal to the mint price for tier
    */
    modifier isIdAndTierPassed2(uint256[] memory _ids, uint256[] memory _tiers) {
        uint8[4] memory _quantity = [0,0,0,0];
        uint256 _correctPayment;
        for (uint256 x = 0; x <= (_ids.length - 1); x++) {
            _quantity[_tiers[x]]++;
            require(_tiers[x] >= 0 && _tiers[x] <= (mintPrices.length - 1), "ITP"); // Incorrect Tier Price
            require((_quantity[_tiers[x]] + tierSupply[_tiers[x]]) <= mintLimit[_tiers[x]], "MLR"); // Max Limit Reached
            require(isTokenIdHaveCorrectTier(_ids[x], _tiers[x]) == true, "TIN"); // Token Id Not Allowed
            _correctPayment += mintPrices[ _tiers[x]];
        }
        require(msg.value == _correctPayment, "IP"); // Incorrect Payment
        _;
    }

    /**
    * @dev called in `mintByOwner()`
    * @dev Reverts if token id is out of range front required id range per tier
    */
    modifier isOwnerIdAndTierPassed(uint256[] memory _ids, uint256[] memory _tiers) {        
        for (uint256 x = 0; x <= (_ids.length - 1); x++) {
            require(isTokenIdHaveCorrectTier(_ids[x], _tiers[x]) == true, "TIN"); // Token Id Not Allowed
        }
        _;
    }

    /**
    * @dev Reverts if the token id is not existing
    */
    modifier isTokenExists(uint256 _id) {
        require(_exists(_id), "TNE"); // Token Not Exist
        _;
    }    

    /* ==================== MODIFIERS SECTION ==================== */

    /* ==================== CONSTRUCTOR SECTION ==================== */
    /**
    * @param _name name of the nft collection
    * @param _symbol symbol of the nft collection
    *
    */
    constructor(string memory _name, string memory _symbol, uint256[] memory _prices) ERC721(_name, _symbol) {
        setRoyaltyInfo(royaltyReceiverAddress, royaltyFeesInBips);
        mintPrices = _prices;
        pause();
    }
    /* ==================== CONSTRUCTOR SECTION ==================== */

    /* ==================== PAUSABLE SECTION ==================== */
    /**
    * @dev Pause the contract. This will disallowed to execute `mint()`   
    */
    function pause() public onlyOwner {
        _pause();
    }

    /**
    * @dev Unpause the contract. This will allow to execute `mint()`
    */
    function unpause() public onlyOwner {
        _unpause();
    }
    /* ==================== PAUSABLE SECTION ==================== */

    /* ==================== REVEAL SECTION ==================== */
    /**
    * @dev update the revealURIMode value.
    * @dev it will allow to reveal the final metadata    
    */
    function setURIMode(bool _mode) external 
        onlyOwner 
    {
        revealURIMode = _mode;

        emit SetBaseURIMode(_mode);
    }
    /* ==================== REVEAL SECTION ==================== */

    /* ==================== SETTERS SECTION ==================== */
    /**
    * @dev update the presaleMode value.
    * @dev it will allow to activate presale   
    */
    function setPresaleMode(bool _mode)
        external 
        onlyOwner
    {
        presaleMode = _mode;

        emit SetPresaleMode(_mode);
    }
    /**
    * @dev Set new Preview URI for tokens
    *
    * @param _previewURI new preview URI for tokens
    */
    function setPreviewURI(string memory _previewURI)
        external
        onlyOwner
    {
        previewURI = _previewURI;

        emit SetPreviewURI(_previewURI);
    }

    /**
    * @dev Set new Base URI for tokens
    *
    * @param _newBaseURI new base URI for tokens
    */
    function setBaseURI(string memory _newBaseURI) 
        external
        onlyOwner 
    {
        baseURI = _newBaseURI;

        emit SetBaseURI(_newBaseURI);
    }

    /**
    * @dev Set new contract URI
    *
    * @param _uri new contract URI
    */
    function setContractURI(string memory _uri) 
        external 
        onlyOwner
    {
        contractURI = _uri;

        emit SetContractURI(_uri);
    }

    /**
    * @dev Set Token URI
    *
    * @param _id of the token
    * @param _uri metadata of the token
    */
    function setTokenURI(uint256 _id, string memory _uri)
        external
        onlyOwner
        isTokenExists(_id)
    {
        tokenURIOfIds[_id] = _uri;

        emit SetTokenURI(_id, _uri);
    }

    /**
    * @dev Set withdrawal address
    *
    * @param _recipient address that can withdraw the contract balance
    */
    function setWithdrawalRecipient(address _recipient)
        external        
        onlyOwner
    {
        require(_recipient != address(0),"ZA"); // Zero Address
        withdrawalAddress = _recipient;

        emit SetWithdrawalRecipient(_recipient);
    }

    /**
    * @dev Set merkleroot
    *
    * @param _root Merkleroot hash
    */
    function setMerkleRoot(bytes32 _root)
        external        
        onlyOwner
    {
        merkleRoot = _root;

        emit SetMerkleRoot(_root);
    }

    /**
    * @dev Set Mint Prices
    *
    * @param _prices array for prices. the value will be fetched via indexes
    */
    function setMintPrices(uint256[] memory _prices)
        external
        onlyOwner
    {
        mintPrices = _prices;

        emit SetMintPrices(_prices);
    }

    function setMintLimit(uint256[] memory _limit)
        external 
        onlyOwner
    {
        mintLimit = _limit;

        emit SetMintLimit(_limit);
    }

    /**
    * @dev Set new royalty info
    *
    * @param _royaltyReceiverAddress address to receive royalty fee
    * @param _royaltyFeesInBips Percentage of token sale price to be used for
    *                                 EIP-2981 royalties from secondary sales
    *                                 Has 2 decimal precision. E.g. a value of 100 would result in a 1% royalty fee
    *                                 value should be replace before mainnet deployment
    */
    function setRoyaltyInfo(address _royaltyReceiverAddress, uint96 _royaltyFeesInBips)
        public 
        onlyOwner 
    {
        require(_royaltyReceiverAddress != address(0),"ZA"); // Zero Address
        royaltyReceiverAddress = _royaltyReceiverAddress;
        royaltyFeesInBips = _royaltyFeesInBips;
        _setDefaultRoyalty(_royaltyReceiverAddress, _royaltyFeesInBips);

        emit SetRoyaltyInfo(_royaltyReceiverAddress, _royaltyFeesInBips);
    }
    /* ==================== SETTERS SECTION ==================== */

    /* ==================== (EXTERNAL) SECTION ==================== */    
    /**
    * @dev Call the `safeBatchMint()`
    * @dev Mint multiple tokens if whitelisted
    * @dev reverts if presale mode is false
    * @dev reverts if caller is not part of whitelist
    *
    * @param _to address of the token owner
    * @param _ids id of the tokens
    * @param _tiers which tiers they want to use
    * @param _uris metadata for each token
    * @param _merkleproof proof that the address is part of merkletree
    */   
    function mintByWhitelist
        (
            address _to, 
            uint256[] calldata _ids, 
            uint256[] calldata _tiers, 
            string[] calldata _uris, 
            bytes32[] memory _merkleproof
        )
            external 
            payable
            isCallerAllowed
            isIdAndTierPassed1(_ids.length, _tiers.length) 
            isIdAndTierPassed2(_ids, _tiers)
    {        
        require(presaleMode == true, "PI"); // Presale Inactive
        require(isValidMerkleProof(_merkleproof, keccak256(abi.encodePacked(msg.sender))), "NW"); // Not Whitelisted
        safeBatchMint(_to, _ids, _tiers, _uris); 
    }

    /**
    * @dev Call the `safeBatchMint()`
    * @dev Mint multiple tokens
    *
    * @param _to address of the token owner
    * @param _ids id of the tokens
    * @param _tiers which tiers they want to use
    * @param _uris metadata for each token
    */
    function mint
        (
            address _to, 
            uint256[] calldata _ids, 
            uint256[] calldata _tiers, 
            string[] calldata _uris
        )
            external 
            payable
            whenNotPaused
            isCallerAllowed
            isIdAndTierPassed1(_ids.length, _tiers.length)
            isIdAndTierPassed2(_ids, _tiers)     
    {   
        safeBatchMint(_to, _ids, _tiers, _uris);        
    }

    /**
    * @dev Call the `safeBatchMint()`
    * @dev Mint multiple tokens if owner
    *
    * @param _to owner of the tokens
    * @param _ids ids of the tokens
    * @param _tiers which tiers they want to use
    * @param _uris metadata for each token
    */
    function mintByOwner
        (
            address _to, 
            uint256[] calldata _ids, 
            uint256[] calldata _tiers,
            string[] calldata _uris
        )
            external
            onlyOwner
            isIdAndTierPassed1(_ids.length, _tiers.length)
            isOwnerIdAndTierPassed(_ids, _tiers)
    {       
        safeBatchMint(_to, _ids, _tiers, _uris);
    }

    /**
    * @dev send the entire contract balance to withdrawal address
    * @dev reverts if withdrawal address is incorrect
    * @dev reverts if contract balance is zero
    */
    function withdrawAll() 
        external
    {
        require(withdrawalAddress == msg.sender, "IR"); // Invalid Recipient
        require((address(this).balance) > 0, "NB"); // No Balance
        uint256 balance = address(this).balance;
        _withdraw(balance);
    }
    /* ==================== (EXTERNAL) SECTION ==================== */

    /* ==================== (PRIVATE) SECTION ==================== */
    /**
    * @dev Call the `safeBatchMint()`
    * @dev Mint a token
    * @dev Assign th token its corresponding tier (0-Silver, 1-Gold, 2-Diamond, 3-Platinum)
    *
    * @param _to owner of the token
    * @param _tokenId id of the token
    * @param _tier index for tier level (0-3, Silver, Gold, Diamond, Platinum)
    * @param _uri metadata of token
    */
    function safeMint(address _to, uint256 _tokenId, uint256 _tier, string memory _uri)
        private
    {
        _safeMint(_to, _tokenId);
        totalSupply++;
        tiers[_tokenId] = _tier;
        tokenURIOfIds[_tokenId] = _uri;
        tierSupply[_tier] += 1;

        emit MintNFT(_to, _tokenId, _tier);
    }

    /**
    * @dev Call the `mint()` and `mintByOwner()`
    * @dev Mint multiple tokens by owner
    * @dev Assign the token its corresponding tier (0-Silver, 1-Gold, 2-Diamond, 3-Platinum)
    *
    * @param _to owner of the token
    * @param _ids ids of the tokens
    * @param _tiers indexes for tier level (0-3, Silver, Gold, Diamond, Platinum)
    * @param _uris metadata for each token
    */
    function safeBatchMint
        (
            address _to, 
            uint256[] calldata _ids, 
            uint256[] calldata _tiers, 
            string[] memory _uris
        )
            private
    {
        for(uint256 x; x < _ids.length; x++) {
            uint256 _id = _ids[x];
            uint256 _tier = _tiers[x];
            string memory _uri = _uris[x];
            safeMint(_to, _id, _tier, _uri);
        }
    }
    
    /**
    * @dev Private function called in `withdraw()` and `withdrawAll()`
    *
    * @param _amount amount to withdraw
    */
    function _withdraw(uint256 _amount) 
        private
    {
        (bool success, ) = (msg.sender).call{value: _amount}("");
        require(success, ": WF"); // Withdraw Failed

        emit Withdraw(msg.sender, _amount);    
    }

    /**
    * @dev Private function called in modifier `isIdAndTierPassed2()`
    * @dev check if the token id is within the range assigned per tier
    * @dev 0-Silver, 1-Gold, 2-Diamond, 3-Platinum
    * @dev ID structure:
    *
    * @dev reserved for airdrop
    * @dev id range (1 - 500)
    * @dev 301 - 500 for Silver
    * @dev 151 - 300 for Gold
    * @dev 51 - 150 for Diamond
    * @dev 1 - 50 for Platinum
    *
    * @dev reserved for presale/public sale
    * @dev id range (501 - 10000)
    * @dev 6201 - 10000 for Silver
    * @dev 3351 - 6200 for Gold
    * @dev 1451 - 3350 for Diamond
    * @dev 501 - 1450 for Platinum
    *
    
    * @param _id token id
    * @param _tier tier of token
    */
    function isTokenIdHaveCorrectTier(uint256 _id, uint256 _tier)
        private
        view          
        returns (bool)
    {

        if (msg.sender == owner() && (_id >= 1 && _id <= 500)) {
            if (_tier == 0) {
                if (_id >= 301 && _id <= 500) {
                    return true;
                } else {
                    return false;
                }
            } else if (_tier == 1) {
                if (_id >= 151 && _id <= 300) {
                    return true;
                } else {
                    return false;
                }
            } else if (_tier == 2) {
                if (_id >= 51 && _id <= 150) {
                    return true;
                } else {
                    return false;
                }
            } else if (_tier == 3) {
                if (_id >= 1 && _id <= 50) {
                    return true;
                } else {
                    return false;
                }
            }
        }

        if (_id >= 501 && _id <= 10000) {
            if (_tier == 0) {
                if (_id >= 6201 && _id <= 10000) {
                    return true;
                } else {
                    return false;
                }
            } else if (_tier == 1) {
                if (_id >= 3351 && _id <= 6200) {
                    return true;
                } else {
                    return false;
                }
            } else if (_tier == 2) {
                if (_id >= 1451 && _id <= 3350) {
                    return true;
                } else {
                    return false;
                }
            } else if (_tier == 3) {
                if (_id >= 501 && _id <= 1450) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }    

        return false;    
    }
    
    /**
    * @dev Check if merkle proof is valid
    *
    * @param _merkleProof proof address that address is whitelisted
    * @param _merkleLeaf validate the proof by address (EOA or Contract Address)
    */
    function isValidMerkleProof(bytes32[] memory _merkleProof, bytes32 _merkleLeaf) 
        private 
        view 
        returns (bool)
    {
        return MerkleProof.verify(_merkleProof, merkleRoot, _merkleLeaf);
    }
    /* ==================== (PRIVATE) SECTION ==================== */

    /* ==================== (OVERRIDES) SECTION ==================== */
    /**        
    * @dev Check if the nft is allowed to transfer to the receiver address.
    * @dev Hook that is called before any token transfer.
    *      see https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721-_beforeTokenTransfer-address-address-uint256-
    *      for more details.
    *
    * @param from wallet address of sender
    * @param to wallet address of receiver
    * @param tokenId id of the token
    */
    

    // NOTE: The following functions are overrides required by Solidity.

    /**
    * @dev ERC721 token with storage based token URI management.
    *      see https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721URIStorage
    *      for more details
    *
    * @param tokenId id that hold the uri (points to the metadata) of the token
    */
    function tokenURI(uint256 tokenId)
        public
        view
        isTokenExists(tokenId)
        override(ERC721)
        returns (string memory)
    {
        string memory _tokenBaseURI = baseURI;

        if (revealURIMode == true) {
            return 
                bytes(_tokenBaseURI).length > 0 ? 
                string(abi.encodePacked(_tokenBaseURI, Strings.toString(tokenId), tokenURISuffix)) 
                : "";
        }

        return 
            bytes(tokenURIOfIds[tokenId]).length > 0
                ? tokenURIOfIds[tokenId]
                : string(abi.encodePacked(previewURI, "hidden", tokenURISuffix));
    }

    /**
    * @inheritdoc ERC2981
    */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    /* ==================== (OVERRIDES) SECTION ==================== */
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

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
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

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
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/common/ERC2981.sol)

pragma solidity ^0.8.0;

import "../../interfaces/IERC2981.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 *
 * Royalty information can be specified globally for all token ids via {_setDefaultRoyalty}, and/or individually for
 * specific token ids via {_setTokenRoyalty}. The latter takes precedence over the first.
 *
 * Royalty is specified as a fraction of sale price. {_feeDenominator} is overridable but defaults to 10000, meaning the
 * fee is specified in basis points by default.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 *
 * _Available since v4.5._
 */
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) / _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev The denominator with which to interpret the fee set in {_setTokenRoyalty} and {_setDefaultRoyalty} as a
     * fraction of the sale price. Defaults to 10000 so fees are expressed in basis points, but may be customized by an
     * override.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Removes default royalty information.
     */
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `feeNumerator` cannot be greater than the fee denominator.
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Resets royalty information for the token id back to the global default.
     */
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be proved to be a part of a Merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and the sibling nodes in `proof`,
     * consuming from one or the other at each step according to the instructions given by
     * `proofFlags`.
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}