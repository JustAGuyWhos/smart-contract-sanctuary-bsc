/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burnbyContract(uint256 _amount) external;
    function withdrawStakingReward(address _address,uint256 _amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {

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

contract Ownable {

    address private  _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Staking is Ownable{

    bool public locked;

    mapping(address => mapping(address => uint256[])) public Tokenid;
    mapping(address => mapping(address => uint256)) public totalStakedNft;


    function Stake(uint256[] memory tokenId, address _nftAddress)
    external
    {

       for(uint256 i=0;i<tokenId.length;i++)
       {
       require(IERC721(_nftAddress).ownerOf(tokenId[i]) == msg.sender,"Nft Not Found");
       IERC721(_nftAddress).transferFrom(msg.sender,address(this),tokenId[i]);
       Tokenid[msg.sender][_nftAddress].push(tokenId[i]);
       }
       totalStakedNft[msg.sender][_nftAddress]+=tokenId.length;
    }

    function userStakedNFT(address _staker, address _nftAddress) public view returns(uint256[] memory){
       return Tokenid[_staker][_nftAddress];
    }

    function find(uint value, address _nftAddress) public  view returns(uint){
        uint i = 0;
        while (Tokenid[msg.sender][_nftAddress][i] != value)
        {   i++;    }
        return i;
    }

    function unStake(uint256[] memory _tokenId, address _nftAddress)
    external
    {
        require(locked,"time not reached");
        for(uint256 i=0;i<_tokenId.length;i++)
        {
            uint256 _index=find(_tokenId[i], _nftAddress);
            require(Tokenid[msg.sender][_nftAddress][_index] ==_tokenId[i] ,"NFT with this _tokenId not found");
            IERC721(_nftAddress).transferFrom(address(this),msg.sender,_tokenId[i]);
            delete Tokenid[msg.sender][_nftAddress][_index];
            Tokenid[msg.sender][_nftAddress][_index]=Tokenid[msg.sender][_nftAddress][Tokenid[msg.sender][_nftAddress].length-1];
            Tokenid[msg.sender][_nftAddress].pop();
        }
        totalStakedNft[msg.sender][_nftAddress]>0?totalStakedNft[msg.sender][_nftAddress]-=_tokenId.length:totalStakedNft[msg.sender][_nftAddress]=0;        
    }

    function isStaked(address _stakeHolder, address _nftAddress) public view returns(bool){
        if(totalStakedNft[_stakeHolder][_nftAddress]>0)
        {return true;}
        else
        {return false;}
    }

    function updateLocked(bool _locked) public onlyOwner{
        locked = _locked;
    }

    function WithdrawToken(address _Token) public onlyOwner{
    require(IERC20(_Token).transfer(msg.sender,IERC20(_Token).balanceOf(address(this))),"Token transfer Error!");
    }

    function withdrawBNB() public onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }

}