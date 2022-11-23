/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";



interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface IERC721Metadata{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from,address to,uint tokenId) external;

    function safeTransferFrom(address from,address to,uint tokenId,bytes calldata data) external;

    function transferFrom(address from,address to,uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)external view returns (bool);
}


interface IERC721Receiver {
    function onERC721Received( address operator,address from,uint tokenId, bytes memory data) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed owner, address indexed spender, uint indexed id);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);

    // Mapping from token ID to owner address
    mapping(uint => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint => address) internal _approvals;
    mapping(uint=>bytes4) internal hash;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public override isApprovedForAll;
    function getInterfaceIdValue() public pure returns(bytes4){
        return bytes4(keccak256('supportsInterface(bytes4)'));
    }

    function supportsInterface(bytes4 interfaceId) external override pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint id) external override view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external override view returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external override {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint id) external override {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    function getApproved(uint id) external override view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    function _isApprovedOrOwner(address owner,address spender,uint id) internal view returns (bool) {
        return (spender == owner || isApprovedForAll[owner][spender] || spender == _approvals[id]);
    }

    function transferFrom(address from, address to,uint id) public  override{
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;
         delete _approvals[id];
        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
address from, address to,uint id ) external  override{
     transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function safeTransferFrom(address from,address to,uint id,bytes calldata data) external override {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    function _mint(address to, uint id ) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;
    //    bytes4 memory Hash=_hash;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
 
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
    return  _tokenUri[tokenId];
    }

    mapping(uint=>string) internal _tokenUri;
    function _safeMint(address to, uint256 id, string memory _uri) internal virtual {
      _tokenUri[id] = _uri ;
      _mint(to, id);
    }



}


contract MyNFT is ERC721 {
        function name() external view returns (string memory){
         return _name;
     }
    function symbol() external view returns (string memory){
          return _symbol;
    }
         string private  _name;
     string private  _symbol;

    // string[] random =["https://gateway.pinata.cloud/ipfs/QmdZHAN6zZpKwi6jxS1bGL9vq1R3Wux66PuocZA4PtK7hw?filename=1.json",
    // "https://gateway.pinata.cloud/ipfs/QmYoiP1dfrE11K5cfSJ4VqsjLFvDQni6Lh1PistiHLAPTA?filename=2.json",
    // "https://gateway.pinata.cloud/ipfs/QmV8sCoa65vGhvf99ch8QPj6KjS14Erzc5uzRqARyVTF7e?filename=3.json",
    // "https://gateway.pinata.cloud/ipfs/QmbPKMhUJhyS1b957BByR5oX6BwSeBjtKQ4qttCNg44Zv1?filename=4.json",
    // "https://gateway.pinata.cloud/ipfs/QmfUUBDkPHqMpGhsttxZjB5ZAVau2fobzFA6FMeKAZgn47?filename=5.json"];




    // function _random() public view returns(uint)
    // {
    //     return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,random.length)));  
    // }
    // function selcectRandom() public view returns(string memory) {
       
    //     uint256 index=_random() % random.length;
    //     return random[index];
    // }


   constructor(string memory name_,string memory symbol_){
    _name=name_;
    _symbol=symbol_;
    }

    function mint(address to, uint id) external {
        _mint(to, id);
    }
    //   uint256 increase=0;
    //   function safeMint(address to) external virtual  {
    //   increase++;
    //   _safeMint(to, increase, selcectRandom());

    // }
    
    //   function safeMint(address to, uint id,string memory _uri) external virtual  {
    //   _mint(to, id);
    //   _tokenUri[id]=_uri;

    // }

    function burn(uint id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}