/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-17
*/

pragma solidity ^0.5.17;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}
interface ERC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
}

contract contract1 is Ownable {

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    using SafeMath for uint256;
    // buy NFT
    mapping(address => uint) public nonces;
    address public signAddress = 0x3872a1a80f783F37896f91209fe9387a2d2D0088;
    address public tokenNFT ; //NFT
    address public tokenUSDT = 0xB195C90253927B941A96B59a2E38ABfa1dC3F69a; //USDT
    mapping(uint256 => uint256 ) public id;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }

     constructor(address _tokenNFT) public {
         tokenNFT = _tokenNFT;
     }

    event DepositNFT(address indexed from, address tokenA, address buyAddr, uint256 tokenID, uint256 time); 
    event DepositUSDT(address indexed from, uint256 amount, address tokenA, uint256 time); 
    event EventWithdrawSingle(address indexed from, address token, uint256 amount, uint256 time, uint256 numID); 
    event SetToken(address indexed from, address indexed token, uint256 now);
    event SetSign(address indexed from, address indexed signAddress, uint256 now);
    event TransfetTOKEN(address indexed from, address indexed token, address recAddress, uint256 amount);

   //depositNFT function
   function permitNFT(string memory funType, address spender, address tokenA, address buyAddr, uint256 tokenID, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 n = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, buyAddr, tokenID, numID, funType, tokenA, deadline, n))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }

      function permitUSDT(string memory funType, address spender, address tokenA, uint256 amount, address _target, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) private {
        require(block.timestamp <= deadline, "EXPIRED"); 
        uint256 n = nonces[spender]; 
        nonces[spender] = nonces[spender].add(1); 
  
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(spender, _target, funType, tokenA, amount, numID, deadline, n))));

        address recoveredAddress = ecrecover(message, v, r, s);

        require(recoveredAddress != address(0) && recoveredAddress == signAddress, 'INVALID_SIGNATURE');
    }

    function depositNFT(  address buyAddr, uint256 tokenID, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public ensure(deadline) {
         require(id[numID] == 0,"id has been generated");
        permitNFT("depositSingleNFT", msg.sender, tokenNFT,  buyAddr,  tokenID, numID, deadline, v, r, s); 
        bool falge =  ERC721(tokenNFT).isApprovedForAll(msg.sender, address(this));
        require(falge, "without authorization"); 
        ERC721(tokenNFT).safeTransferFrom(address(this),buyAddr,tokenID); 
        id[numID] = 1;
        emit DepositNFT(msg.sender, tokenNFT, buyAddr, tokenID, block.timestamp); 
    }

    function depositUSDT(uint256 amount, uint256 numID, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public ensure(deadline) {
         require(id[numID] == 0,"id has been generated");
        permitUSDT("depositSingleUSDT", msg.sender, tokenUSDT, amount, address(this), numID, deadline, v, r, s); 
        safeTransferFrom(tokenUSDT, msg.sender, address(this), amount); 
        id[numID] = 1;
        emit DepositUSDT(msg.sender, amount, tokenUSDT, block.timestamp); 
    }

    //  function depositNFT( address buyAddr, uint256 tokenID) public { 
    //     bool falge =  ERC721(tokenNFT).isApprovedForAll(msg.sender, address(this));
    //     require(falge, "without authorization"); 
    //     ERC721(tokenNFT).safeTransferFrom(address(this),buyAddr,tokenID); 
    //     emit DepositNFT(msg.sender, tokenNFT, buyAddr, tokenID, block.timestamp); 
    // }

    // function depositUSDT(uint256 amount) public {
    //      safeTransferFrom(tokenUSDT, msg.sender, address(this), amount);  
    //     emit DepositUSDT(msg.sender, amount, tokenUSDT, block.timestamp); 
    // }

    //balanceOf NFT
    function getNFTbalanceOf() public view returns(uint256){
        uint256 curBalance = ERC721(tokenNFT).balanceOf(address(this));
        return curBalance;
    }

    //set tokenUSDT
     function setTokenUSDT(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero tokenAddress!");
        tokenUSDT = tokenAddress;
         emit SetToken(msg.sender,tokenUSDT, now);
    }

    //set tokenNFT
     function setTokenNFT(address tokenAddress) public onlyOwner{
        require(tokenAddress != address(0),"zero tokenAddress!");
        tokenNFT = tokenAddress;
         emit SetToken(msg.sender,tokenNFT, now);
    }

    //set signAddress
    function setSign(address signAddr) public onlyOwner{
         require(signAddr != address(0),"zero signAddr!");
        signAddress = signAddr;
         emit SetSign(msg.sender,signAddress, now);
    }

    //transfet token
    function transfetTOKEN(address tokenAddr, address recAddress) public onlyOwner{
        uint256 curBalance = IERC20(tokenAddr).balanceOf(address(this));
        safeTransfer(tokenAddr, recAddress, curBalance);
        emit TransfetTOKEN(msg.sender, tokenAddr, recAddress, curBalance);
    }

 



}