/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// Sources flattened with hardhat v2.10.2 https://hardhat.org

// File contracts/ISVC.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
interface ISavvyCoin{
    function transferFrom(address owner, address buyer, uint256 numTokens) external returns (bool);
}


// File contracts/IBirdNFT.sol


pragma solidity ^0.8.0;
interface IBirdNFT{
    function transferBatch1155NFT(
        address from,
        address to,
        uint256[] memory Ids,
        uint256[] memory amount
    ) external returns(bool);
    function NFTbalance(address[] memory account, uint256[] memory Ids)
        external
        returns (uint256[] memory);
    function approveAll1155NFT(
        address owner,
        address operator,
        bool approved
    ) external;
    function permit(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);
   function transferWithPermission(
        address from,
        address to,
        uint256 tokenId,
        uint256 deadline,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns(bool);
    event Transfer(
        address from,
        address to,
        uint256[] Ids,
        uint256[] amount);
}


// File contracts/MKP.sol


pragma solidity ^0.8.0;


contract Marketplace{
    
    mapping(uint256 => uint256) private IdstoPrice;
    address public SVC;
    address public FlappyNFT;
    mapping(uint256 => bool) private listed;
    constructor(address _SVC, address _FlappyNFT) {
        SVC = _SVC;
        FlappyNFT = _FlappyNFT;
        
    }
    event TokenChangeStatus(uint256 tokenId, bool listed, uint256 price);

    function buyNFT(
        address buyer, 
        address seller, 
        uint256 tokenId,
        uint256 deadline, 
        uint256 nonce, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
        ) external returns(bool){
        require(listed[tokenId],"NFT not listed");
        uint256[] memory id = new uint256[](1);
        id[0] = tokenId;
        uint256[] memory amount = new uint256[](1);
        amount[0] = 1;

        require(ISavvyCoin(SVC).transferFrom(buyer, seller, IdstoPrice[tokenId]),"insufficient balances for buy");
        
        require(IBirdNFT(FlappyNFT).transferWithPermission(seller, buyer, tokenId, deadline, nonce, v, r, s),"transfer NFT fail");
        //require(IBirdNFT(FlappyNFT).transferBatch1155NFT(seller, buyer, id, amount),"transfer NFT fail");
        listed[tokenId] = false;
        emit TokenChangeStatus(tokenId, true, IdstoPrice[tokenId]);
        return true;
    }

    function listingNFT(uint256 tokenId, uint256 price) external{
        require(listed[tokenId] == false, "token listed");
        IdstoPrice[tokenId] = price;
        listed[tokenId] = true;
        emit TokenChangeStatus(tokenId, true, price);
    }
    function viewPrice(uint256 tokenId) public view returns(uint) {
        require(listed[tokenId] == false, "token listed");
        return IdstoPrice[tokenId];
    }
    function cancelListing(uint256 tokenId) external {
        require(listed[tokenId] == true, "token not listed");
        listed[tokenId] = false;
        IdstoPrice[tokenId] = type(uint256).max;
        emit TokenChangeStatus(tokenId, false, IdstoPrice[tokenId]);
    }
    function checkListed(uint256 tokenId) public view returns(bool) {
        return listed[tokenId];
    }
   
}