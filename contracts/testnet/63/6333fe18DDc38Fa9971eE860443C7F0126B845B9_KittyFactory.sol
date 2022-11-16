pragma solidity >=0.5.0 <0.6.0;

import "./SafeMath.sol";
import "./KittyContract.sol";
import "./KittyAdmin.sol";

contract KittyFactory is KittyContract, KittyAdmin {
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint256 public constant CREATION_LIMIT_GEN0 = 65535;
    uint256 public constant NUM_CATTRIBUTES = 10;
    uint256 public constant DNA_LENGTH = 16;
    uint256 public constant RANDOM_DNA_THRESHOLD = 7;
    uint256 internal _gen0Counter;

    // tracks approval for a kittyId in sire market offers
    mapping(uint256 => address) sireAllowedToAddress;

    event Birth(
        address owner,
        uint256 kittyId,
        uint256 mumId,
        uint256 dadId,
        uint256 genes
    );

    /// @dev cooldown duration after breeding
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];

    function kittiesOf(address _owner) public view returns (uint256[] memory) {
        // get the number of kittes owned by _owner
        uint256 ownerCount = ownerKittyCount[_owner];
        if (ownerCount == 0) {
            return new uint256[](0);
        }

        // iterate through each kittyId until we find all the kitties
        // owned by _owner
        uint256[] memory ids = new uint256[](ownerCount);
        uint256 i = 1;
        uint256 count = 0;
        while (count < ownerCount || i < kitties.length) {
            if (kittyToOwner[i] == _owner) {
                ids[count] = i;
                count = count.add(1);
            }
            i = i.add(1);
        }

        return ids;
    }

    function getGen0Count() public view returns (uint256) {
        return _gen0Counter;
    }

    function createKittyGen0(uint256 _genes)
        public
        onlyKittyCreator
        returns (uint256)
    {
        require(_gen0Counter < CREATION_LIMIT_GEN0, "gen0 limit exceeded");

        _gen0Counter = _gen0Counter.add(1);
        return _createKitty(0, 0, 0, _genes, msg.sender);
    }

    function _createKitty(
        uint256 _mumId,
        uint256 _dadId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) internal returns (uint256) {
        // cooldownIndex should cap at 13
        // otherwise it's half the generation
        uint16 cooldown = uint16(_generation / 2);
        if (cooldown >= cooldowns.length) {
            cooldown = uint16(cooldowns.length - 1);
        }

        Kitty memory kitty = Kitty({
            genes: _genes,
            birthTime: uint64(now),
            cooldownEndTime: uint64(now),
            mumId: uint32(_mumId),
            dadId: uint32(_dadId),
            generation: uint16(_generation),
            cooldownIndex: cooldown
        });

        uint256 newKittenId = kitties.push(kitty) - 1;
        emit Birth(_owner, newKittenId, _mumId, _dadId, _genes);

        _transfer(address(0), _owner, newKittenId);

        return newKittenId;
    }

    function breed(uint256 _dadId, uint256 _mumId)
        public
        returns (uint256)
    {
        require(_eligibleToBreed(_dadId, _mumId), "kitties not eligible");

        Kitty storage dad = kitties[_dadId];
        Kitty storage mum = kitties[_mumId];

        // set parent cooldowns
        _setBreedCooldownEnd(dad);
        _setBreedCooldownEnd(mum);
        _incrementBreedCooldownIndex(dad);
        _incrementBreedCooldownIndex(mum);

        // reset sire approval to fase
        _sireApprove(_dadId, _mumId, false);
        _sireApprove(_mumId, _dadId, false);

        // get kitten attributes
        uint256 newDna = _mixDna(dad.genes, mum.genes, now);
        uint256 newGeneration = _getKittenGeneration(dad, mum);

        return _createKitty(_mumId, _dadId, newGeneration, newDna, msg.sender);
    }

    function _eligibleToBreed(uint256 _dadId, uint256 _mumId)
        internal
        view
        onlyApproved(_mumId)
        returns (bool)
    {
        // require(isKittyOwner(_mumId), "not owner of _mumId");
        require(
            isKittyOwner(_dadId) ||
            isApprovedForSiring(_dadId, _mumId),
            "not owner of _dadId or sire approved"
        );
        require(readyToBreed(_dadId), "dad on cooldown");
        require(readyToBreed(_mumId), "mum on cooldown");

        return true;
    }

    function readyToBreed(uint256 _kittyId) public view returns (bool) {
        return kitties[_kittyId].cooldownEndTime <= now;
    }

    function _setBreedCooldownEnd(Kitty storage _kitty) internal {
        _kitty.cooldownEndTime = uint64(
            now.add(cooldowns[_kitty.cooldownIndex])
        );
    }

    function _incrementBreedCooldownIndex(Kitty storage _kitty) internal {
        // only increment cooldown if not at the cap
        if (_kitty.cooldownIndex < cooldowns.length - 1) {
            _kitty.cooldownIndex = _kitty.cooldownIndex.add(1);
        }
    }

    function _getKittenGeneration(Kitty storage _dad, Kitty storage _mum)
        internal
        view
        returns (uint256)
    {
        // generation is 1 higher than max of parents
        if (_dad.generation > _mum.generation) {
            return _dad.generation.add(1);
        }

        return _mum.generation.add(1);
    }

    function _mixDna(
        uint256 _dadDna,
        uint256 _mumDna,
        uint256 _seed
    ) internal pure returns (uint256) {
        (
            uint16 dnaSeed,
            uint256 randomSeed,
            uint256 randomValues
        ) = _getSeedValues(_seed);
        uint256[10] memory geneSizes = [uint256(2), 2, 2, 2, 1, 1, 2, 2, 1, 1];
        uint256[10] memory geneArray;
        uint256 mask = 1;
        uint256 i;

        for (i = NUM_CATTRIBUTES; i > 0; i--) {
            /*
            if the randomSeed digit is >= than the RANDOM_DNA_THRESHOLD
            of 7 choose the random value instead of a parent gene

            Use dnaSeed with bitwise AND (&) and a mask to choose parent gene
            if 0 then Mum, if 1 then Dad

            randomSeed:    8  3  8  2 3 5  4  3 9 8
            randomValues: 62 77 47 79 1 3 48 49 2 8
                           *     *              * *

            dnaSeed:       1  0  1  0 1 0  1  0 1 0
            mumDna:       11 22 33 44 5 6 77 88 9 0
            dadDna:       99 88 77 66 0 4 33 22 1 5
                              M     M D M  D  M                         
            
            childDna:     62 22 47 44 0 6 33 88 2 8

            mask:
            00000001 = 1
            00000010 = 2
            00000100 = 4
            etc
            */
            uint256 randSeedValue = randomSeed % 10;
            uint256 dnaMod = 10**geneSizes[i - 1];
            if (randSeedValue >= RANDOM_DNA_THRESHOLD) {
                // use random value
                geneArray[i - 1] = uint16(randomValues % dnaMod);
            } else if (dnaSeed & mask == 0) {
                // use gene from Mum
                geneArray[i - 1] = uint16(_mumDna % dnaMod);
            } else {
                // use gene from Dad
                geneArray[i - 1] = uint16(_dadDna % dnaMod);
            }

            // slice off the last gene to expose the next gene
            _mumDna = _mumDna / dnaMod;
            _dadDna = _dadDna / dnaMod;
            randomValues = randomValues / dnaMod;
            randomSeed = randomSeed / 10;

            // shift the DNA mask LEFT by 1 bit
            mask = mask * 2;
        }

        // recombine DNA
        uint256 newGenes = 0;
        for (i = 0; i < NUM_CATTRIBUTES; i++) {
            // add gene
            newGenes = newGenes + geneArray[i];

            // shift dna LEFT to make room for next gene
            if (i != NUM_CATTRIBUTES - 1) {
                uint256 dnaMod = 10**geneSizes[i + 1];
                newGenes = newGenes * dnaMod;
            }
        }

        return newGenes;
    }

    function _getSeedValues(uint256 _masterSeed)
        internal
        pure
        returns (
            uint16 dnaSeed,
            uint256 randomSeed,
            uint256 randomValues
        )
    {
        uint256 mod = 2**NUM_CATTRIBUTES - 1;
        dnaSeed = uint16(_masterSeed % mod);

        uint256 randMod = 10**NUM_CATTRIBUTES;
        randomSeed =
            uint256(keccak256(abi.encodePacked(_masterSeed))) %
            randMod;

        uint256 valueMod = 10**DNA_LENGTH;
        randomValues =
            uint256(keccak256(abi.encodePacked(_masterSeed, DNA_LENGTH))) %
            valueMod;
    }

    function isApprovedForSiring(uint256 _dadId, uint256 _mumId)
        public
        view
        returns (bool)
    {
        return sireAllowedToAddress[_dadId] == kittyToOwner[_mumId];
    }

    function sireApprove(
        uint256 _dadId,
        uint256 _mumId,
        bool _isApproved
    ) external onlyApproved(_dadId) {
        _sireApprove(_dadId, _mumId, _isApproved);
    }

    function _sireApprove(
        uint256 _dadId,
        uint256 _mumId,
        bool _isApproved
    ) internal {
        if (_isApproved) {
            sireAllowedToAddress[_dadId] = kittyToOwner[_mumId];
        } else {
            delete sireAllowedToAddress[_dadId];
        }
    }
}

pragma solidity >=0.5.0 <0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath32
 * @dev SafeMath library implemented for uint32
 */
library SafeMath32 {

  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath16
 * @dev SafeMath library implemented for uint16
 */
library SafeMath16 {

  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    if (a == 0) {
      return 0;
    }
    uint16 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint16 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    assert(b <= a);
    return a - b;
  }

  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
  }
}

pragma solidity >=0.5.0 <0.6.0;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(isOwner(), "only owner");
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

pragma solidity ^0.5.12;
import "./SafeMath.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";

contract KittyContract is IERC721 {
    using SafeMath for uint256;

    struct Kitty {
        uint256 genes;
        uint64 birthTime;
        uint64 cooldownEndTime;
        uint32 mumId;
        uint32 dadId;
        uint16 generation;
        uint16 cooldownIndex;
    }

    Kitty[] internal kitties;
    string _tokenName = "New York Cat Game";
    string _tokenSymbol = "NYCG";

    bytes4 internal constant MAGIC_ERC721_RECEIVED = bytes4(
        keccak256("onERC721Received(address,address,uint256,bytes)")
    );
    bytes4 _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 _INTERFACE_ID_ERC721 = 0x80ac58cd;

    mapping(uint256 => address) internal kittyToOwner;
    mapping(address => uint256) internal ownerKittyCount;
    mapping(uint256 => address) public kittyToApproved;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor() public {
        kitties.push(
            Kitty({
                genes: 0,
                birthTime: 0,
                cooldownEndTime: 0,
                mumId: 0,
                dadId: 0,
                generation: 0,
                cooldownIndex: 0
            })
        );
    }

    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool)
    {
        return (_interfaceId == _INTERFACE_ID_ERC165 ||
            _interfaceId == _INTERFACE_ID_ERC721);
    }

    /// @dev throws if @param _address is the zero address
    modifier notZeroAddress(address _address) {
        require(_address != address(0), "zero address");
        _;
    }

    /// @dev throws if @param _kittyId has not been created
    modifier validKittyId(uint256 _kittyId) {
        require(_kittyId < kitties.length, "invalid kittyId");
        _;
    }

    /// @dev throws if msg.sender does not own @param _kittyId
    modifier onlyKittyOwner(uint256 _kittyId) {
        require(isKittyOwner(_kittyId), "sender not kitty owner");
        _;
    }

    /// @dev throws if msg.sender is not the kitty owner,
    /// approved, or an approved operator
    modifier onlyApproved(uint256 _kittyId) {
        require(
            isKittyOwner(_kittyId) ||
                isApproved(_kittyId) ||
                isApprovedOperatorOf(_kittyId),
            "sender not kitty owner OR approved"
        );
        _;
    }

    /**
     * @dev Returns the Kitty for the given kittyId
     */
    function getKitty(uint256 _kittyId)
        external
        view
        returns (
            uint256 kittyId,
            uint256 genes,
            uint64 birthTime,
            uint64 cooldownEndTime,
            uint32 mumId,
            uint32 dadId,
            uint16 generation,
            uint16 cooldownIndex,
            address owner
        )
    {
        Kitty storage kitty = kitties[_kittyId];
        
        kittyId = _kittyId;
        genes = kitty.genes;
        birthTime = kitty.birthTime;
        cooldownEndTime = kitty.cooldownEndTime;
        mumId = kitty.mumId;
        dadId = kitty.dadId;
        generation = kitty.generation;
        cooldownIndex = kitty.cooldownIndex;
        owner = kittyToOwner[_kittyId];
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance) {
        return ownerKittyCount[owner];
    }

    /*
     * @dev Returns the total number of tokens in circulation.
     */
    function totalSupply() external view returns (uint256 total) {
        // is the Unkitty considered part of the supply?
        return kitties.length - 1;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory tokenName) {
        return _tokenName;
    }

    /*
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory tokenSymbol) {
        return _tokenSymbol;
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 _tokenId)
        external
        view
        validKittyId(_tokenId)
        returns (address owner)
    {
        return _ownerOf(_tokenId);
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address owner) {
        return kittyToOwner[_tokenId];
    }

    function isKittyOwner(uint256 _kittyId) public view returns (bool) {
        return msg.sender == _ownerOf(_kittyId);
    }

    /** @dev Transfers `tokenId` token from `msg.sender` to `to`.
     *
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `to` can not be the contract address.
     * - `tokenId` token must be owned by `msg.sender`.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _tokenId)
        external
        onlyApproved(_tokenId)
        notZeroAddress(_to)
    {
        require(_to != address(this), "to contract address");

        _transfer(msg.sender, _to, _tokenId);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        // assign new owner
        kittyToOwner[_tokenId] = _to;

        //update token counts
        ownerKittyCount[_to] = ownerKittyCount[_to].add(1);

        if (_from != address(0)) {
            ownerKittyCount[_from] = ownerKittyCount[_from].sub(1);
        }

        // emit Transfer event
        emit Transfer(_from, _to, _tokenId);
    }

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId)
        external
        onlyApproved(_tokenId)
    {
        kittyToApproved[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function isApproved(uint256 _kittyId) public view returns (bool) {
        return msg.sender == kittyToApproved[_kittyId];
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId)
        external
        view
        validKittyId(_tokenId)
        returns (address)
    {
        return kittyToApproved[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return _isApprovedForAll(_owner, _operator);
    }

    function _isApprovedForAll(address _owner, address _operator)
        internal
        view
        returns (bool)
    {
        return _operatorApprovals[_owner][_operator];
    }

    /// @return True if msg.sender is the owner, approved,
    /// or an approved operator for the kitty
    /// @param _kittyId id of the kitty
    function isApprovedOperatorOf(uint256 _kittyId) public view returns (bool) {
        return _isApprovedForAll(kittyToOwner[_kittyId], msg.sender);
    }

    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal {
        _transfer(_from, _to, _tokenId);
        require(_checkERC721Support(_from, _to, _tokenId, _data));
    }

    function _checkERC721Support(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal returns (bool) {
        if (!_isContract(_to)) {
            return true;
        }

        //call onERC721Recieved in the _to contract
        bytes4 result = IERC721Receiver(_to).onERC721Received(
            msg.sender,
            _from,
            _tokenId,
            _data
        );

        //check return value
        return result == MAGIC_ERC721_RECEIVED;
    }

    function _isContract(address _to) internal view returns (bool) {
        // wallets will not have any code but contract must have some code
        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        return size > 0;
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param _data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external onlyApproved(_tokenId) notZeroAddress(_to) {
        require(_from == _ownerOf(_tokenId), "from address not kitty owner");
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyApproved(_tokenId) notZeroAddress(_to) {
        require(_from == _ownerOf(_tokenId), "from address not kitty owner");
        _safeTransfer(_from, _to, _tokenId, bytes(""));
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyApproved(_tokenId) notZeroAddress(_to) {
        require(
            _from == kittyToOwner[_tokenId],
            "from address not kitty owner"
        );
        _transfer(_from, _to, _tokenId);
    }
}

pragma solidity >=0.5.0 <0.6.0;
import "./Ownable.sol";

contract KittyAdmin is Ownable {
    mapping(address => uint256) addressToKittyCreatorId;
    address[] kittyCreators;

    event KittyCreatorAdded(address creator);
    event KittyCreatorRemoved(address creator);

    constructor() public {
        // placeholder to reserve ID zero as an invalid value
        _addKittyCreator(address(0));

        // the owner should be allowed to create kitties
        _addKittyCreator(owner());
    }

    modifier onlyKittyCreator() {
        require(isKittyCreator(msg.sender), "must be a kitty creator");
        _;
    }

    function isKittyCreator(address _address) public view returns (bool) {
        return addressToKittyCreatorId[_address] != 0;
    }

    function addKittyCreator(address _address) external onlyOwner {
        require(_address != address(this), "contract address");
        require(_address != address(0), "zero address");

        _addKittyCreator(_address);
    }

    function _addKittyCreator(address _address) internal {
        addressToKittyCreatorId[_address] = kittyCreators.length;
        kittyCreators.push(_address);

        emit KittyCreatorAdded(_address);
    }

    function removeKittyCreator(address _address) external onlyOwner {
        uint256 id = addressToKittyCreatorId[_address];
        delete addressToKittyCreatorId[_address];
        delete kittyCreators[id];

        emit KittyCreatorRemoved(_address);
    }

    function getKittyCreators() external view returns (address[] memory) {
        return kittyCreators;
    }
}

pragma solidity ^0.5.12;

interface IERC721Receiver {
    function onERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

pragma solidity ^0.5.0;
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
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

    /*
     * @dev Returns the total number of tokens in circulation.
     */
    function totalSupply() external view returns (uint256 total);

    /*
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory tokenName);

    /*
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory tokenSymbol);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);


     /* @dev Transfers `tokenId` token from `msg.sender` to `to`.
     *
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `to` can not be the contract address.
     * - `tokenId` token must be owned by `msg.sender`.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 tokenId) external;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev Emits the Approval event. The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
}