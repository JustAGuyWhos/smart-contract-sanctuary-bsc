/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: BUSL-1.1

// File contracts/interfaces/IERC165.sol


pragma solidity ^0.8.9;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File contracts/interfaces/IERC721.sol


pragma solidity ^0.8.9;
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File contracts/interfaces/IERC721Receiver.sol


pragma solidity ^0.8.9;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File contracts/interfaces/IERC721Metadata.sol


pragma solidity ^0.8.9;
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File contracts/utils/Address.sol


pragma solidity ^0.8.9;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}


// File contracts/utils/Context.sol


pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File contracts/utils/ERC165.sol


pragma solidity ^0.8.9;
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File contracts/extensions/ERC721Single.sol


pragma solidity ^0.8.9;
contract ERC721Single is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;

    string public hash;
    string private _name;
    string private _symbol;
    string private _tokenURI;

    uint256 private constant TOKEN_ID = 0;

    address internal _owner;
    address private _approval;

    mapping(address => bool) private _operators;

    modifier validTokenId(uint256 tokenId) {
        require(tokenId == TOKEN_ID, "Invalid tokenId");
        _;
    }

    modifier onlyOwner {
        require(_owner == _msgSender(), "Only owner can call this function");
        _;
    }

    modifier validOwner(address owner) {
        require(owner == _owner, "Invalid owner");
        _;
    }

    modifier approvedOrOwned {
        require(
            _msgSender() == _owner ||
            isApprovedForAll(_owner, _msgSender()) ||
            getApproved(TOKEN_ID) == _msgSender(),

            "Only owner, approved or operator can call this function"
        );

        _;
    }

    constructor(string memory hash_, string memory name_, string memory symbol_, string memory tokenURI_) {
        hash = hash_;
        _name = name_;
        _symbol = symbol_;
        _tokenURI = tokenURI_;

        _owner = _msgSender();
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public override validTokenId(tokenId) view returns (string memory) {
        return _tokenURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == _owner) {
            return 1;
        }

        return 0;
    }

    function ownerOf(uint256 tokenId) public validTokenId(tokenId) view virtual override returns (address) {
        return _owner;
    }

    function approve(
        address to,
        uint256 tokenId
    ) public validTokenId(tokenId) virtual override {
        require(to != _owner, "ERC721: approval to current owner");

        require(
            _msgSender() == _owner || isApprovedForAll(_owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to);
    }

    function getApproved(uint256 tokenId) public validTokenId(tokenId) view virtual override returns (address) {
        return _approval;
    }

    function setApprovalForAll(address operator, bool approved) public onlyOwner virtual override {
        require(_msgSender() != operator, "ERC721: approve to caller");

        _operators[operator] = approved;
        emit ApprovalForAll(_owner, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public validOwner(owner) view virtual override returns (bool) {
        return _operators[operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public validTokenId(tokenId) virtual override {
        _transfer(from, to);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public validTokenId(tokenId) virtual override {
        _transfer(from, to);

        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _transfer(
        address from,
        address to
    ) internal approvedOrOwned validOwner(from) virtual {
        require(_owner == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        require(from != to, "ERC721: transfer from same to same address");

        _beforeTokenTransfer(from, to);

        _approve(address(0));

        _owner = to;

        emit Transfer(from, to, TOKEN_ID);

        _afterTokenTransfer(from, to);
    }

    function _approve(address to) internal virtual {
        _approval = to;
        emit Approval(_owner, to, TOKEN_ID);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to
    ) internal virtual {}
}


// File contracts/tokens/Endorsable/IERC721Endorsable.sol


pragma solidity ^0.8.9;
interface IERC721Endorsable is IERC721 {
    function getEndorsementInfo() external view returns (address seal, uint8 sealCorner);
    function isEndorsed() external view returns (bool);
    function endorse(address seal) external;

    function getTimeLimitedEndorsementInfo(address seal) external view returns (uint32 expirationTime);
    function endorseTimeLimited(address seal) external;

    function isCrossEndorsedBy(address endorsable) external view returns (bool);
    function hasCrossEndorsedForeign(address endorsable) external view returns (bool);
    function getCrossEndorsementInfo() external view returns (address endorsable);
    function isCrossEndorsed() external view returns (bool);
    function markAsCrossEndorsed(address foreignEndorsable) external;
    function endorseCross(address endorsable) external;

    function setDraftForever(address draftForever) external;
    function resetDraftForever() external;

    function getForever() external view returns (address forever);
    function commitForever() external;
}


// File contracts/tokens/Seal/IERC721Seal.sol


pragma solidity ^0.8.9;
interface IERC721Seal is IERC721 {
    function getEndorsementInfo(
        address endorsableToken
    ) external view returns (bool isEndorsed, uint8 sealCorner);

    function getTimeLimitedEndorsementInfo(
        address endorsableToken
    ) external view returns (bool isEndorsed, uint32 endTime);

    function markAsEndorsed(address endorsableToken, uint8 sealCorner) external;
    function markAsEndorsedTimeLimited(address endorsableToken, uint32 endTime) external;
}


// File contracts/tokens/Endorsable/ERC721Endorsable.sol


pragma solidity ^0.8.9;
contract ERC721Endorsable is ERC721Single, IERC721Endorsable {
    address private _seal;
    uint8 private _sealCorner;

    mapping(address => uint32) private _timeLimitedEndorsements;

    mapping(address => address) private _foreignCrossEndorsements;
    address private _crossEndorsementBy;

    address private _draftForever;
    address private _forever;

    modifier onlyDraftForever {
        require(_draftForever != address(0), "Draft forever is zero address");
        require(_draftForever == _msgSender(), "Only draft forever can call this function");
        _;
    }

    modifier isNotInForever {
        require(_draftForever == address(0), "Token is in draft forever");
        require(_forever == address(0), "Token is in forever");
        _;
    }

    constructor(
        string memory hash_,
        string memory name_,
        string memory symbol_,
        string memory tokenURI_
    ) ERC721Single(hash_, name_, symbol_, tokenURI_) { }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721Single) returns (bool) {
        return interfaceId == type(IERC721Endorsable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getEndorsementInfo() public override view returns (address seal, uint8 sealCorner) {
        return (_seal, _sealCorner);
    }

    function isEndorsed() public override view returns (bool) {
        return _seal != address(0);
    }

    function endorse(address seal) public override approvedOrOwned isNotInForever {
        require(seal != address(0), "Seal is zero address");
        require(_seal == address(0), "Seal is already set");

        (bool isSuccess, uint8 sealCorner) = IERC721Seal(seal).getEndorsementInfo(address(this));
        require(isSuccess, "Seal has not endorsed this token");

        _seal = seal;
        _sealCorner = sealCorner;
    }

    function getTimeLimitedEndorsementInfo(address seal) public override view returns (uint32 endTime) {
        return _timeLimitedEndorsements[seal];
    }

    function endorseTimeLimited(address seal) public override approvedOrOwned isNotInForever {
        require(seal != address(0), "Seal is zero address");

        (bool isSuccess, uint32 endTime) = IERC721Seal(seal).getTimeLimitedEndorsementInfo(
            address(this)
        );

        require(isSuccess, "Seal has not endorsed this token");

        _timeLimitedEndorsements[seal] = endTime;
    }

    function isCrossEndorsedBy(address endorsable) public override view returns (bool) {
        return _crossEndorsementBy == endorsable;
    }

    function hasCrossEndorsedForeign(address endorsable) public override view returns (bool) {
        return _foreignCrossEndorsements[endorsable] != address(0);
    }

    function getCrossEndorsementInfo() public override view returns (address endorsable) {
        return _crossEndorsementBy;
    }

    function isCrossEndorsed() public override view returns (bool) {
        return _crossEndorsementBy != address(0);
    }

    function markAsCrossEndorsed(address foreignEndorsable) public override approvedOrOwned isNotInForever {
        require(foreignEndorsable != address(0), "Endorsable is zero address");
        require(_foreignCrossEndorsements[foreignEndorsable] == address(0), "Endorsable is already endorsed");

        _foreignCrossEndorsements[foreignEndorsable] = foreignEndorsable;
    }

    function endorseCross(address endorsable) public override approvedOrOwned isNotInForever {
        require(endorsable != address(0), "Endorsable is zero address");
        require(_crossEndorsementBy == address(0), "Cross endorsement is already set");

        require(
            IERC721Endorsable(endorsable).isCrossEndorsedBy(address(this)),
            "Endorsable has not endorsed this token"
        );

        _crossEndorsementBy = endorsable;
    }

    function setDraftForever(address draftForever) public override approvedOrOwned isNotInForever {
        require(draftForever != address(0), "Draft forever is zero address");
        _draftForever = draftForever;
    }

    function resetDraftForever() public override onlyDraftForever {
        require(_draftForever != address(0), "Draft forever is already zero address");
        _draftForever = address(0);
    }

    function getForever() public override view returns (address forever) {
        return _forever;
    }

    function commitForever() public override onlyDraftForever {
        require(_seal != address(0), "Seal is zero address");

        _forever = _draftForever;
        _draftForever = address(0);
    }

    function _beforeTokenTransfer(address from, address to) internal override isNotInForever {}
}


// File contracts/tokens/Forever/IERC721Forever.sol


pragma solidity ^0.8.9;
interface IERC721Forever is IERC721 {
    struct EndorsableTokenInfo {
        address endorsable;
        address owner;
        address seal;
        uint8 sealCorner;
    }

    function getEndorsableTokens() external view returns (address[] memory endorsableTokens);
    function addEndorsableToken(address endorsable) external;
}


// File contracts/tokens/Forever/ERC721Forever.sol


pragma solidity ^0.8.9;
contract ERC721Forever is ERC721Single, IERC721Forever {
    EndorsableTokenInfo[] private _endorsableTokens;

    constructor(
        string memory hash_,
        string memory name_,
        string memory symbol_,
        string memory tokenURI_
    ) ERC721Single(hash_, name_, symbol_, tokenURI_) { }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721Single) returns (bool) {
        return interfaceId == type(IERC721Forever).interfaceId || super.supportsInterface(interfaceId);
    }

    function getEndorsableTokens() public override view returns (address[] memory endorsableTokens) {
        for (uint i = 0; i < _endorsableTokens.length; i++) {
            endorsableTokens[i] = _endorsableTokens[i].endorsable;
        }
    }

    function addEndorsableToken(address endorsable) public override approvedOrOwned {
        if (_endorsableTokens.length < 4) {
            address owner = IERC721(endorsable).ownerOf(0);
            (address seal, uint8 sealCorner) = IERC721Endorsable(endorsable).getEndorsementInfo();

            _endorsableTokens.push(
                EndorsableTokenInfo({
                    endorsable: endorsable,
                    owner: owner,
                    seal: seal,
                    sealCorner: sealCorner
                })
            );

            if (_endorsableTokens.length == 4) {
                uint8 pos = _endorsableTokens[0].sealCorner;
                bool bError = false;

                for (uint i = 1; i < 4; i++) {
                    pos = pos | _endorsableTokens[i].sealCorner;

                    if (
                        _endorsableTokens[i].owner != _endorsableTokens[0].owner ||
                        _endorsableTokens[i].seal  != _endorsableTokens[0].seal
                    ) {
                        bError = true;
                        break;
                    }
                }

                if (bError || pos != 15) {
                    IERC721Endorsable(_endorsableTokens[0].endorsable).resetDraftForever();
                    IERC721Endorsable(_endorsableTokens[1].endorsable).resetDraftForever();
                    IERC721Endorsable(_endorsableTokens[2].endorsable).resetDraftForever();
                    IERC721Endorsable(_endorsableTokens[3].endorsable).resetDraftForever();

                    selfdestruct(payable(_owner));
                } else {
                    IERC721Endorsable(_endorsableTokens[0].endorsable).commitForever();
                    IERC721Endorsable(_endorsableTokens[1].endorsable).commitForever();
                    IERC721Endorsable(_endorsableTokens[2].endorsable).commitForever();
                    IERC721Endorsable(_endorsableTokens[3].endorsable).commitForever();
                }
            }
        }
    }
}


// File contracts/tokens/Seal/ERC721Seal.sol


pragma solidity ^0.8.9;
contract ERC721Seal is ERC721Single, IERC721Seal {
    struct EndorsedEntry {
        address endorsable;
        uint8 sealCorner;
    }

    struct EndorsedTimeLimitedEntry {
        address endorsable;
        uint32 endTime;
    }

    mapping(address => EndorsedEntry) private _endorsed;
    mapping(address => EndorsedTimeLimitedEntry) private _endorsedTimeLimited;

    constructor(
        string memory hash_,
        string memory name_,
        string memory symbol_,
        string memory tokenURI_
    ) ERC721Single(hash_, name_, symbol_, tokenURI_) { }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721Single) returns (bool) {
        return interfaceId == type(IERC721Seal).interfaceId || super.supportsInterface(interfaceId);
    }

    function getEndorsementInfo(
        address endorsable
    ) public override view returns (bool isEndorsed, uint8 sealCorner) {
        EndorsedEntry memory entry = _endorsed[endorsable];

        return (
            entry.endorsable != address(0),
            entry.sealCorner
        );
    }

    function getTimeLimitedEndorsementInfo(
        address endorsable
    ) public override view returns (bool isEndorsed, uint32 endTime) {
        EndorsedTimeLimitedEntry storage entry = _endorsedTimeLimited[endorsable];

        return (
            entry.endTime >= block.timestamp,
            entry.endTime
        );
    }

    function markAsEndorsed(address endorsable, uint8 sealCorner) public override approvedOrOwned {
        require(endorsable != address(0), "Endorsable token is zero address");
        require(_endorsed[endorsable].endorsable == address(0), "Endorsable token is already endorsed");

        _endorsed[endorsable] = EndorsedEntry(endorsable, sealCorner);
    }

    function markAsEndorsedTimeLimited(address endorsable, uint32 endTime) public override approvedOrOwned {
        require(endorsable != address(0), "Endorsable token is zero address");

        require(
            endTime > _endorsedTimeLimited[endorsable].endTime,
            "End time is not greater than current end time"
        );

        _endorsedTimeLimited[endorsable] = EndorsedTimeLimitedEntry(endorsable, endTime);
    }
}


// File contracts/tokens/Deployer.sol


pragma solidity ^0.8.9;
contract Deployer {
    struct CreateTokenParams {
        string hash;
        string name;
        string symbol;
        string tokenURI;
    }

    event Endorsable(address token, CreateTokenParams params);
    event Forever(address token, CreateTokenParams params);
    event Seal(address token, CreateTokenParams params);

    function createEndorsable(CreateTokenParams memory params) public returns (address) {
        ERC721Endorsable token = new ERC721Endorsable(
            params.hash, params.name, params.symbol, params.tokenURI
        );

        emit Endorsable(address(token), params);
        return address(token);
    }

    function createForever(CreateTokenParams memory params) public returns (address) {
        ERC721Forever token = new ERC721Forever(
            params.hash, params.name, params.symbol, params.tokenURI
        );

        emit Forever(address(token), params);
        return address(token);
    }

    function createSeal(CreateTokenParams memory params) public returns (address) {
        ERC721Seal token = new ERC721Seal(
            params.hash, params.name, params.symbol, params.tokenURI
        );

        emit Seal(address(token), params);
        return address(token);
    }
}


// File contracts/utils/Ownable.sol


pragma solidity ^0.8.9;
abstract contract Ownable is Context {
    address private _owner;

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
    }
}


// File contracts/utils/ERC165Checker.sol


pragma solidity ^0.8.9;
library ERC165Checker {
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (uint256)) > 0;
    }
}


// File contracts/transactions/Ask.sol


pragma solidity ^0.8.9;
contract Ask is Ownable {
    struct AskInfo {
        bool isActive;
        address token;
        uint256 price;
        address payable owner;
        uint expirationTime;
    }

    mapping(address => AskInfo) public _asks;

    modifier assertTokenOwner(address tokenAddress) {
        require(IERC721(tokenAddress).ownerOf(0) == _msgSender(), "You are not the owner of the token");
        _;
    }

    modifier activeAsk(address tokenAddress) {
        require(_asks[tokenAddress].isActive, "There is no active ask for this token");
        require(_asks[tokenAddress].expirationTime > block.timestamp, "The ask has expired");
        _;
    }

    function createAsk(address token, uint256 price, uint32 expirationTime) public assertTokenOwner(token) {
        require(price > 0, "Invalid price");
        require(_asks[token].isActive == false, "You have already created an ask for this token");

        require(
            ERC165Checker.supportsInterface(token, type(IERC721).interfaceId),
            "The given address does not support the IERC721 interface"
        );

        _asks[token] = AskInfo({
            isActive: true,
            token: token,
            price: price,
            owner: payable(_msgSender()),
            expirationTime: expirationTime
        });
    }

    function changePrice(address token, uint256 price) public assertTokenOwner(token) activeAsk(token) {
        require(price > 0, "Invalid price");
        _asks[token].price = price;
    }

    function cancelAsk(address token) public assertTokenOwner(token) activeAsk(token) {
        _asks[token].isActive = false;
    }

    function purchase(address token) public payable activeAsk(token) {
        AskInfo storage ask = _asks[token];

        require(ask.isActive == true, "There is no active ask for this token");
        require(ask.price <= msg.value, "Invalid value");
        require(ask.owner != _msgSender(), "You are the owner of the token");

        IERC721(token).safeTransferFrom(ask.owner, _msgSender(), 0);

        ask.owner.transfer(ask.price);

        ask.isActive = false;
    }
}


// File contracts/transactions/Endorsement.sol


pragma solidity ^0.8.9;
contract Endorsement is Ownable {
    struct EndorseRequest {
        bool isActive;
        address endorsable;
        address seal;
        uint8 sealPossibleCorners;
        uint256 price;
    }

    mapping(address => mapping(address => EndorseRequest)) public _requests;

    modifier assertTokenOwner(address tokenAddress) {
        require(IERC721(tokenAddress).ownerOf(0) == _msgSender(), "You are not the owner of the token");
        _;
    }

    function requestEndorse(
        address endorsable,
        address seal,
        uint8 sealPossibleCorners,
        uint64 price
    ) public payable assertTokenOwner(endorsable) {
        require(msg.value >= price, "Invalid value");

        require(
            _requests[seal][endorsable].isActive == false,
            "You have already requested an endorsement for this token"
        );

        require(
            ERC165Checker.supportsInterface(seal, type(IERC721Seal).interfaceId),
            "The given seal does not support the IERC721Seal interface"
        );

        require(
            ERC165Checker.supportsInterface(endorsable, type(IERC721Endorsable).interfaceId),
            "The given endorsable does not support the IERC721Endorsable interface"
        );

        require(!IERC721Endorsable(endorsable).isEndorsed(), "The given endorsable is already endorsed");

        _requests[seal][endorsable] = EndorseRequest({
            isActive: true,
            endorsable: endorsable,
            seal: seal,
            sealPossibleCorners: sealPossibleCorners,
            price: price
        });
    }

    function cancelEndorse(
        address endorsable, address seal
    ) public assertTokenOwner(endorsable) {
        EndorseRequest storage request = _requests[seal][endorsable];

        require(
            request.isActive == true,
            "You have not requested an endorsement for this token"
        );

        request.isActive = false;
    }

    function endorse(
        address endorsable, address seal, uint8 sealCorner
    ) public assertTokenOwner(seal) {
        EndorseRequest storage request = _requests[seal][endorsable];

        require(request.isActive == true, "There is no an endorsement for this token");

        uint8 possibleCorners = request.sealPossibleCorners;

        require(
            (possibleCorners & sealCorner) != 0,
            "The given seal corner is not possible for this token"
        );

        IERC721Seal(seal).markAsEndorsed(
            endorsable,
            sealCorner
        );

        IERC721Endorsable(endorsable).endorse(seal);

        payable(IERC721(seal).ownerOf(0)).transfer(request.price);

        request.isActive = false;
    }
}


// File contracts/transactions/EndorsementCross.sol


pragma solidity ^0.8.9;
contract EndorsementCross is Ownable {
    struct EndorseRequest {
        bool isActive;
        address endorsable1;
        address endorsable2;
        uint256 price;
    }

    mapping(address => mapping(address => EndorseRequest)) public _requests;

    modifier assertTokenOwner(address tokenAddress) {
        require(IERC721(tokenAddress).ownerOf(0) == _msgSender(), "You are not the owner of the token");
        _;
    }

    function requestEndorseCross(
        address endorsable1,
        address endorsable2,
        uint256 price
    ) public payable assertTokenOwner(endorsable1) {
        require(msg.value >= price, "Invalid value");

        require(
            _requests[endorsable1][endorsable2].isActive == false,
            "You have already requested an endorsement for this token"
        );

        require(
            ERC165Checker.supportsInterface(endorsable1, type(IERC721Endorsable).interfaceId),
            "The given endorsable1 does not support the IERC721Endorsable interface"
        );

        require(
            ERC165Checker.supportsInterface(endorsable2, type(IERC721Endorsable).interfaceId),
            "The given endorsable2 does not support the IERC721Endorsable interface"
        );

        require(!IERC721Endorsable(endorsable1).isCrossEndorsed(), "The given endorsable is already endorsed");

        _requests[endorsable1][endorsable2] = EndorseRequest({
            isActive: true,
            endorsable1: endorsable1,
            endorsable2: endorsable2,
            price: price
        });
    }

    function cancelEndorseCross(
        address endorsable1,
        address endorsable2
    ) public {
        EndorseRequest storage request = _requests[endorsable1][endorsable2];

        require(request.isActive, "You have not requested an endorsement for this token");

        request.isActive = false;
    }

    function endorseCross(
        address endorsable1,
        address endorsable2
    ) public assertTokenOwner(endorsable2) {
        EndorseRequest storage request = _requests[endorsable1][endorsable2];

        require(request.isActive, "You have not requested an endorsement for this token");

        IERC721Endorsable(endorsable2).markAsCrossEndorsed(endorsable1);
        IERC721Endorsable(endorsable2).endorseCross(endorsable1);

        payable(IERC721(endorsable2).ownerOf(0)).transfer(request.price);

        request.isActive = false;
    }
}


// File contracts/transactions/EndorsementTimeLimited.sol


pragma solidity ^0.8.9;
contract EndorsementTimeLimited is Ownable {
    struct EndorseRequest {
        bool isActive;
        address endorsable;
        address seal;
        uint256 price;
        uint32 endTime;
    }

    mapping(address => mapping(address => EndorseRequest)) public _requests;

    modifier assertTokenOwner(address tokenAddress) {
        require(IERC721(tokenAddress).ownerOf(0) == _msgSender(), "You are not the owner of the token");
        _;
    }

    function requestEndorseTimeLimited(
        address endorsable,
        address seal,
        uint256 price,
        uint32 endTime
    ) public payable assertTokenOwner(endorsable) {
        require(msg.value >= price, "Invalid value");

        require(endTime > block.timestamp, "Invalid end time");

        require(
            _requests[seal][endorsable].isActive == false,
            "You have already requested an endorsement for this token"
        );

        require(
            ERC165Checker.supportsInterface(seal, type(IERC721Seal).interfaceId),
            "The given seal does not support the IERC721Seal interface"
        );

        require(
            ERC165Checker.supportsInterface(endorsable, type(IERC721Endorsable).interfaceId),
            "The given endorsable does not support the IERC721Endorsable interface"
        );

        _requests[seal][endorsable] = EndorseRequest({
            isActive: true,
            endorsable: endorsable,
            seal: seal,
            price: price,
            endTime: endTime
        });
    }

    function cancelEndorseTimeLimited(
        address endorsable, address seal
    ) public assertTokenOwner(endorsable) {
        EndorseRequest storage request = _requests[seal][endorsable];

        require(request.isActive, "You have not requested an endorsement for this token");

        request.isActive = false;
    }

    function endorseTimeLimited(
        address endorsable,
        address seal
    ) public assertTokenOwner(seal) {
        EndorseRequest storage request = _requests[seal][endorsable];

        require(
            request.isActive == true,
            "You have not requested an endorsement for this token"
        );

        require(
            request.endTime >= block.timestamp,
            "The endorsement request has expired"
        );

        IERC721Seal(seal).markAsEndorsedTimeLimited(endorsable, request.endTime);
        IERC721Endorsable(endorsable).endorseTimeLimited(seal);

        payable(IERC721(seal).ownerOf(0)).transfer(request.price);

        request.isActive = false;
    }
}