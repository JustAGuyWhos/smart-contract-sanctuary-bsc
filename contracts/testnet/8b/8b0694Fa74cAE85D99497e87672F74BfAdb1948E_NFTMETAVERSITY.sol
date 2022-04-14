// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface INFTMETAVERSITY is IBEP165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}

interface INFTMETAVERSITYReceiver {
    function onNFTMETAVERSITYReceived(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}

interface INFTMETAVERSITYMetadata is INFTMETAVERSITY {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

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

abstract contract Context {
    function _msgSender() internal view  returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure  returns (bytes calldata) {
        return msg.data;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

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

abstract contract BEP165 is IBEP165 {
    
    function supportsInterface(bytes4 interfaceId) public pure  returns (bool) {
        return interfaceId == type(IBEP165).interfaceId;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view  returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal  {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract NFTMETAVERSITY is Context, BEP165, INFTMETAVERSITY, INFTMETAVERSITYMetadata , Ownable{
    using Strings for uint256;
    using Address for address;
    using Strings for uint256;

    IBEP20 public _stakeToken;
    IBEP20 public _RewardToken = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    uint256 private stakeduration = 14 minutes;

    uint256 public constant tokenPerTier = 1;

    uint256 private claimable;

    uint256 minimumtransferlimit = 10 ether;

    string private _name;

    string private _symbol;

    uint256 private _maxSupply = 10000;

    bool public _pausedCommon;
    bool public _pausedRare;
    bool public _pausedEpic;
    bool public _pausedLegendary;
    bool public _tokenMinting;

    struct Rarity{
        string  NFT;
        uint256 currentid;
        uint256 startindex;
        uint256 endindex;
        uint256 ethFee;
        uint256 tokenFee;
    }
    struct Stake{
        uint256 amount;
        uint256 withdrawTime;
    }
    struct OwnedTireInfo{
        uint256 [] common;
        uint256 []  rare;
        uint256 [] epic;
        uint256 [] legendary;
    }
    
    Rarity public Common;
    Rarity public Rare;
    Rarity public Epic;
    Rarity public Legendary;

    mapping(uint256 => string) public _tokenURIs;

    mapping(uint256 => address) public _owners;

    mapping(address => OwnedTireInfo) private _ownerId;

    mapping(address => uint256) public claimedRewards;

    mapping(address => uint256) public _balances;

    mapping(uint256 => address) public _tokenApprovals;

    mapping (address =>mapping(uint256 =>Stake)) public StakeDetails;



    mapping(address => mapping(address => bool)) public _operatorApprovals;

    uint256[] private _allTokens;

    modifier pausedCommom() {
        require(!_pausedCommon, "Paused: common");
        _;
    }
    modifier pausedRare() {
        require(!_pausedRare, "Paused: rare");
        _;
    }
    modifier pausedEpic() {
        require(!_pausedEpic, "Paused: epic");
        _;
    }
    modifier pausedLegendary() {
        require(!_pausedLegendary, "Paused: legendary");
        _;
    }


    constructor() {
        _name = "METAPEOPLE-NFT";
        _symbol = "METAPEOPLE";

        Common.NFT = "Common";
        Rare.NFT = "Rare";
        Epic.NFT = "Epic";
        Legendary.NFT = "Legendary";

        Common.ethFee = 0.3 ether;
        Rare.ethFee = 0.82 ether;
        Epic.ethFee = 1.75 ether;
        Legendary.ethFee = 5 ether;

        Common.tokenFee = 27_000_000 ether;
        Rare.tokenFee = 54_000_000 ether;
        Epic.tokenFee = 100_000_000 ether;
        Legendary.tokenFee = 200_000_000 ether;

        Common.startindex = 1;
        Rare.startindex = 6251;
        Epic.startindex = 8501;
        Legendary.startindex = 9501;
        
        Common.endindex = 6250;
        Rare.endindex = 8500;
        Epic.endindex = 9500;
        Legendary.endindex = 10000;

        Common.currentid = Common.startindex;
        Rare.currentid = Rare.startindex;
        Epic.currentid = Epic.startindex;
        Legendary.currentid =  Legendary.startindex;

        _pausedCommon = false;
        _pausedRare = false;
        _pausedEpic = false;
        _pausedLegendary = false;
        _tokenMinting = true;

    }

    //public functions

    function MintCommon( string memory uri,bool eth) public payable pausedCommom {
        require(Common.currentid <= Common.endindex, "Common: Minting limit reached");
        require(_comonLength(msg.sender) < tokenPerTier, "Common: You have already minted a Common NFT");
        if(eth){
            require(msg.value == Common.ethFee, "Common: Minting ETH");
        }else{
            require(_tokenMinting, "Common: minting disabled");
            require(_stakeToken.transferFrom(msg.sender,address(this),Common.tokenFee), "Common: Minting NFTMETAVERSITY");
            StakeDetails[msg.sender][0].amount = Common.tokenFee;
            StakeDetails[msg.sender][0].withdrawTime = block.timestamp + stakeduration;
            claimable = claimable + Common.tokenFee;
        }
        _safeMint(msg.sender, Common.currentid,bytes(uri));
        _setTokenURI(Common.currentid,uri);
        _ownerId[msg.sender].common.push(Common.currentid);
        _allTokens.push(Common.currentid);
        Common.currentid++;
    }
    function MintRare( string memory uri,bool eth) public payable pausedRare {
        require(Rare.currentid <= Rare.endindex, "Rare: Minting limit reached");
        require(_rareLength(msg.sender) < tokenPerTier, "Rare: You have already minted a Rare NFT");
        if(eth){
            require(msg.value == Rare.ethFee, "Rare: Minting ETH");
        }else{
            require(_tokenMinting, "Rare: minting disabled");
            require(_stakeToken.transferFrom(msg.sender,address(this),Rare.tokenFee), "Rare: Minting NFTMETAVERSITY");
            StakeDetails[msg.sender][1].amount = Rare.tokenFee;
            StakeDetails[msg.sender][1].withdrawTime = block.timestamp + stakeduration;
            claimable = claimable + Rare.tokenFee;
        }
        _safeMint(msg.sender, Rare.currentid,bytes(uri));
        _setTokenURI(Rare.currentid,uri);
        _ownerId[msg.sender].rare.push(Rare.currentid);
        _allTokens.push(Rare.currentid);
        Rare.currentid++;

    }
    function MintEpic( string memory uri,bool eth) public payable pausedEpic {
        require(Epic.currentid <= Epic.endindex, "Epic: Minting limit reached");
        require(_epicLength(msg.sender) < tokenPerTier, "Epic: You have already minted a Epic NFT");
        if(eth){
            require(msg.value == Epic.ethFee, "Epic: Minting ETH");
        }else{
            require(_tokenMinting, "Epic: minting disabled");
            require(_stakeToken.transferFrom(msg.sender,address(this),Epic.tokenFee), "Epic: Minting NFTMETAVERSITY");
            StakeDetails[msg.sender][2].amount = Epic.tokenFee;
            StakeDetails[msg.sender][2].withdrawTime = block.timestamp + stakeduration;
            claimable = claimable + Epic.tokenFee;
        }
        _safeMint(msg.sender, Epic.currentid,bytes(uri));
        _setTokenURI(Epic.currentid,uri);
        _ownerId[msg.sender].epic.push(Epic.currentid);
        _allTokens.push(Epic.currentid);
        Epic.currentid++;
    }
    function MintLegendary( string memory uri,bool eth) public payable pausedLegendary {
        require(Legendary.currentid <= Legendary.endindex, "Legendary: Minting limit reached");
        require(_legendaryLength(msg.sender) < tokenPerTier, "Legendary: You have already minted a Legendary NFT");
        if(eth){
            require(msg.value == Legendary.ethFee, "Legendary: Minting ETH");
        }else{
            require(_tokenMinting, "Legendary: minting disabled");
            require(_stakeToken.transferFrom(msg.sender,address(this),Legendary.tokenFee), "Legendary: Minting NFTMETAVERSITY");
            StakeDetails[msg.sender][3].amount = Legendary.tokenFee;
            StakeDetails[msg.sender][3].withdrawTime = block.timestamp + stakeduration;
            claimable = claimable + Legendary.tokenFee;
        }
        _safeMint(msg.sender, Legendary.currentid,bytes(uri));
        _setTokenURI(Legendary.currentid,uri);
        _ownerId[msg.sender].legendary.push(Legendary.currentid);
        _allTokens.push(Legendary.currentid);
        Legendary.currentid++;
    }

    function Claim(uint256 rarity) public{
        require(block.timestamp >= StakeDetails[msg.sender][rarity].withdrawTime, "claim time has not started");
        require(StakeDetails[msg.sender][rarity].amount > 0, "You need to stake before claiming");
        _stakeToken.transfer(msg.sender,StakeDetails[msg.sender][rarity].amount);
        claimable = claimable - StakeDetails[msg.sender][rarity].amount;
        StakeDetails[msg.sender][rarity].amount = 0;
    }
    function sendtoDividends() external onlyOwner{
        uint256 availablebalance = _RewardToken.balanceOf(address(this));
        if(availablebalance > minimumtransferlimit){
            uint256 parts;
            uint256 _common ;
            uint256 _rare ;
            uint256 _epic ;
            uint256 _legendary ;
            if(Common.currentid > Common.startindex){
                parts++;
            }
            if(Rare.currentid > Rare.startindex){
                parts++;
            }
            if(Epic.currentid > Epic.startindex){
                parts++;
            }
            if(Legendary.currentid > Legendary.startindex){
                parts++;
            }
            if(Common.currentid > Common.startindex){
                _common = availablebalance / parts;
                _common = _common /((Common.currentid) - Common.startindex);
            }
            if(Rare.currentid > Rare.startindex){
                _rare = availablebalance / parts;
                _rare = _rare /((Rare.currentid ) - Rare.startindex);
            }
            if(Epic.currentid > Epic.startindex){
                _epic = availablebalance / parts;
                _epic = _epic /((Epic.currentid ) - Epic.startindex);
            }
            if(Legendary.currentid > Legendary.startindex){
                _legendary = availablebalance / parts;
                _legendary = _legendary /((Legendary.currentid ) - Legendary.startindex);
            }
            
            for(uint256 i = Common.startindex; i <= Common.currentid; i++){
                if(i >= Common.startindex && i <= Common.endindex){
                    if(_owners[i] != address(0) && _common > 0){
                        _RewardToken.transfer(_owners[i],_common);
                    }
                }
            }
            for(uint256 i = Rare.startindex; i <= Rare.currentid; i++){
                if(i >= Rare.startindex && i <= Rare.endindex){
                    if(_owners[i] != address(0) && _rare > 0){
                        _RewardToken.transfer(_owners[i],_rare);
                    }
                }
            }
            for(uint256 i = Epic.startindex; i <= Epic.currentid; i++){
                if(i >= Epic.startindex && i <= Epic.endindex){
                    if(_owners[i] != address(0) && _epic > 0){
                        _RewardToken.transfer(_owners[i],_epic);
                    }
                }
            }
            for(uint256 i = Legendary.startindex; i <= Legendary.currentid; i++){
                if(i >= Legendary.startindex && i <= Legendary.endindex){
                    if(_owners[i] != address(0) && _legendary > 0){
                        _RewardToken.transfer(_owners[i],_legendary);
                    }
                }
            }
        }

    }
    function setPause(bool common,bool rare,bool epic,bool legendary) external onlyOwner{
        _pausedCommon = common;
        _pausedRare = rare;
        _pausedEpic = epic;
        _pausedLegendary = legendary;
    }
    function setTokenMinting(bool tokenMinting) external onlyOwner{
        _tokenMinting = tokenMinting;
    }
    function approve(address to, uint256 tokenId) public  {
        address owner = NFTMETAVERSITY.ownerOf(tokenId);
        require(to != owner, "NFTMETAVERSITY: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "NFTMETAVERSITY: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }
    function _checkCommon(uint256 tokenId,address _user) internal view returns (uint256){
        for(uint256 i = 0; i < _ownerId[_user].common.length; i++){
            if(_ownerId[_user].common[i] == tokenId){
                return i;
            }
        }
        return 0;
    }
    function _checkRare(uint256 tokenId,address _user) internal view returns (uint256){
        for(uint256 i = 0; i < _ownerId[_user].rare.length; i++){
            if(_ownerId[_user].rare[i] == tokenId){
                return i;
            }
        }
        return 0;
    }
    function _checkEpic(uint256 tokenId,address _user) internal view returns (uint256){
        for(uint256 i = 0; i < _ownerId[_user].epic.length; i++){
            if(_ownerId[_user].epic[i] == tokenId){
                return i;
            }
        }
        return 0;
    }
    function _checkLegendary(uint256 tokenId,address _user) internal view returns (uint256){
        for(uint256 i = 0; i < _ownerId[_user].legendary.length; i++){
            if(_ownerId[_user].legendary[i] == tokenId){
                return i;
            }
        }
        return 0;
    }
    function _comonLength(address _user) internal view returns (uint256){
        return _ownerId[_user].common.length;
    }
    function _rareLength(address _user) internal view returns (uint256){
        return _ownerId[_user].rare.length;
    }
    function _epicLength(address _user) internal view returns (uint256){
        return _ownerId[_user].epic.length;
    }
    function _legendaryLength(address _user) internal view returns (uint256){
        return _ownerId[_user].legendary.length;
    }

    function setApprovalForAll(address operator, bool approved) public  {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public  {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "NFTMETAVERSITY: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public  {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public  {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "NFTMETAVERSITY: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

//private functions
    function _checkOnNFTMETAVERSITYReceived(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try INFTMETAVERSITYReceiver(to).onNFTMETAVERSITYReceived(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == INFTMETAVERSITYReceiver.onNFTMETAVERSITYReceived.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("NFTMETAVERSITY: transfer to non NFTMETAVERSITYReceiver implementer");
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

    //internal functions
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal  {
        require(_exists(tokenId), "NFTMETAVERSITYURIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal  {
        _transfer(from, to, tokenId);
        require(_checkOnNFTMETAVERSITYReceived(from, to, tokenId, _data), "NFTMETAVERSITY: transfer to non NFTMETAVERSITYReceiver implementer");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal  {
        _mint(to, tokenId);
        require(
            _checkOnNFTMETAVERSITYReceived(address(0), to, tokenId, _data),
            "NFTMETAVERSITY: transfer to non NFTMETAVERSITYReceiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal  {
        require(to != address(0), "NFTMETAVERSITY: mint to the zero address");
        require(!_exists(tokenId), "NFTMETAVERSITY: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal  {
        address owner = NFTMETAVERSITY.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal  {
        require(NFTMETAVERSITY.ownerOf(tokenId) == from, "NFTMETAVERSITY: transfer of token that is not own");
        require(to != address(0), "NFTMETAVERSITY: transfer to the zero address");
        

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        
        if(_checkCommon(tokenId,from) != 0){
            require(_comonLength(to) < tokenPerTier, "NFTMETAVERSITY: you can't have more than tokenPerTier common tokens");
            _ownerId[from].common.pop();
            _ownerId[to].common.push(tokenId);
        }else if(_checkRare(tokenId,from) != 0){
            require(_rareLength(to) < tokenPerTier, "NFTMETAVERSITY: you can't have more than tokenPerTier rare tokens");
            _ownerId[from].rare.pop();
            _ownerId[to].rare.push(tokenId);
        }else if(_checkEpic(tokenId,from) != 0){
            require(_epicLength(to) < tokenPerTier, "NFTMETAVERSITY: you can't have more than tokenPerTier epic tokens");
            _ownerId[from].epic.pop();
            _ownerId[to].epic.push(tokenId);
        }else if(_checkLegendary(tokenId,from) != 0){
            require(_legendaryLength(to) < tokenPerTier, "NFTMETAVERSITY: you can't have more than tokenPerTier legendary tokens");
            _ownerId[from].legendary.pop();
            _ownerId[to].legendary.push(tokenId);
        }
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal  {
        _tokenApprovals[tokenId] = to;
        emit Approval(NFTMETAVERSITY.ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal  {
        require(owner != operator, "NFTMETAVERSITY: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal  {}
    // readable internal
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view  returns (bool) {
        require(_exists(tokenId), "NFTMETAVERSITY: operator query for nonexistent token");
        address owner = NFTMETAVERSITY.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    
    function _exists(uint256 tokenId) internal view  returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    function _baseURI() internal pure  returns (string memory) {
        return "";
    }
//    readable  external  
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) public view  returns (uint256) {
        require(index < NFTMETAVERSITY.totalSupply(), "NFTMETAVERSITY: global index out of bounds");
        return _allTokens[index];
    }
    function balanceOf(address owner) public view  returns (uint256) {
        require(owner != address(0), "NFTMETAVERSITY: balance query for the zero address");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view  returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "NFTMETAVERSITY: owner query for nonexistent token");
        return owner;
    }
    function name() public view  returns (string memory) {
        return _name;
    }
    function symbol() public view  returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view  returns (string memory) {
        require(_exists(tokenId), "NFTMETAVERSITYMetadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    
    function getApproved(uint256 tokenId) public view  returns (address) {
        require(_exists(tokenId), "NFTMETAVERSITY: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator) public view  returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function setStakeToken(address tokenadd) public onlyOwner {
        _stakeToken = IBEP20(tokenadd);
    }
    function userNFTDetails(address _user) external view returns(bool common, bool rare, bool epic, bool legendary){
        common = _comonLength(_user) > 0;
        rare = _rareLength(_user) > 0;
        epic = _epicLength(_user) > 0;
        legendary = _legendaryLength(_user) > 0;
    }
    function getStakeDetails(address _user, uint256 _tire) external view returns(uint256 _amount, uint256 _unlocktime){
        _amount = StakeDetails[_user][_tire].amount;
        _unlocktime = StakeDetails[_user][_tire].withdrawTime;
    }
    function setEthFee(uint256 commom,uint256 rare,uint256 epic,uint256 legendary) public onlyOwner {
        Common.ethFee = commom;
        Rare.ethFee = rare;
        Epic.ethFee = epic;
        Legendary.ethFee = legendary;
    }
    function setTokenFee(uint256 commom,uint256 rare,uint256 epic,uint256 legendary) public onlyOwner {
        Common.tokenFee = commom;
        Rare.tokenFee = rare;
        Epic.tokenFee = epic;
        Legendary.tokenFee = legendary;
    }
    function idsByOwner(address _user) external view returns(uint256[] memory Commonids, uint256[] memory Rareids, uint256[] memory Epicids, uint256[] memory Legendaryids){
        Commonids = _ownerId[_user].common;
        Rareids = _ownerId[_user].rare;
        Epicids = _ownerId[_user].epic;
        Legendaryids = _ownerId[_user].legendary;
    }

}