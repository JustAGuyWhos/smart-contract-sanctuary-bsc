/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC165 {
  
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract T_W_RewardDistributor {

    address[2] public RewardAddresses;
    uint[10] rewardAmounts;
    address owner ;
    address public distributor ;
    uint public lastDistributionTime;
    uint reAllocationTime;
    

      receive() external payable
    {
    }


    struct Record
    {
        uint[3] rewardAmount;
        bool[3] isClaimed;
        uint num;
    }

    modifier onlyOwner(){
        require(msg.sender== owner, "Only Owner Allowed");
          _;
    }

    mapping(address=>Record) public rewards;

    constructor(address _nft , address _token, address _distributor ) {
        owner = msg.sender;
         RewardAddresses[0] = _nft;
         RewardAddresses[1] = _token;
         rewardAmounts = [1,20,20,10,10,10,10,10,10,10];
         lastDistributionTime = block.timestamp;
         reAllocationTime = 7 days;
         distributor = _distributor;
    }


    function setRewards(address[] memory _users) external onlyOwner returns(bool){

        require(block.timestamp>lastDistributionTime + reAllocationTime,"Not setReward time reached");
        require(_users.length==10,"Top 10 winners are required");

        for(uint i ; i<_users.length ; i++){
            if(i==0){
           rewards[_users[i]].rewardAmount[0] += rewardAmounts[i];
           rewards[_users[i]].isClaimed[0]= false;
            }

            if(i==1 || i==2){
           rewards[_users[i]].rewardAmount[1] += rewardAmounts[i];
           rewards[_users[i]].isClaimed[1]= false;
            }

            if(i>=3 && i<=9){
           rewards[_users[i]].rewardAmount[2] += rewardAmounts[i];
           rewards[_users[i]].isClaimed[2]= false;
            }
        }
        lastDistributionTime = block.timestamp;
        return true;
    }



    function ClaimRewardNFT() external returns (bool){

        require(rewards[msg.sender].rewardAmount[0]>0,"You have nothing to claim");
        require(!rewards[msg.sender].isClaimed[0],"You have nothing to claim");
        for(uint i ; i<rewards[msg.sender].rewardAmount[0];i++){        
        IERC721(RewardAddresses[0]).safeTransferFrom(
        owner,
        msg.sender,
        IERC721(RewardAddresses[0]).tokenOfOwnerByIndex(distributor,0));

        }
        rewards[msg.sender].rewardAmount[0] =0;
        rewards[msg.sender].isClaimed[0] = true;
        return true;
    }

    function ClaimRewardTRX() external returns (bool){

        require(rewards[msg.sender].rewardAmount[1]>0,"You have nothing to claim");
        require(!rewards[msg.sender].isClaimed[1],"You have nothing to claim");
        payable(msg.sender).transfer(rewards[msg.sender].rewardAmount[1]*1e16);
        rewards[msg.sender].rewardAmount[1] =0;
        rewards[msg.sender].isClaimed[1] = true;
        return true;
    }

    function ClaimRewardToken() external returns (bool){
        require(rewards[msg.sender].rewardAmount[2]>0,"You have nothing to claim");
        require(!rewards[msg.sender].isClaimed[2],"You have Already claimed");
        IERC20(RewardAddresses[1]).transferFrom(distributor, msg.sender,rewards[msg.sender].rewardAmount[2]*(10**IERC20(RewardAddresses[1]).decimals()));
        rewards[msg.sender].rewardAmount[2] =0;
        rewards[msg.sender].isClaimed[2] = true;
        return true;
    }

    function updateRewardAmounts(uint[5] memory amounts) external onlyOwner returns (bool){
       rewardAmounts = amounts;
        return true;
    }

    function getTokenUrl(address _wallet) public view returns(string[] memory){

   string[] memory myArray = new string[](IERC721(RewardAddresses[0]).balanceOf(_wallet));
   for(uint256 i = 0; i < IERC721(RewardAddresses[0]).balanceOf(_wallet); i++){
   string memory url;
    uint b = IERC721(RewardAddresses[0]).tokenOfOwnerByIndex(_wallet, i);
    url = IERC721Metadata(RewardAddresses[0]).tokenURI(b);
    myArray[i] = url;

   }
   return myArray;
}

    
    function updateReallocationTime(uint _time) external onlyOwner returns (bool){
       reAllocationTime = _time;
       return true;
    }
    function updateOwner(address _newOwner) external onlyOwner returns (bool){
       owner = _newOwner;
       return true;
    }

    function updatedistributor(address _distributor) external onlyOwner returns (bool){
       distributor = _distributor;
       return true;
    }

    
   
    function updateNFTAddress(address _nft) external onlyOwner returns (bool){
       RewardAddresses[0] = _nft;
        return true;
    }
   

    function updateTokenAddress(address _token) external onlyOwner returns (bool){
       RewardAddresses[1] = _token;
        return true;
    }

    function getNFTClaimableAmount(address _user) public view returns(uint)
    {
        return rewards[_user].rewardAmount[0];
    }
    function getTokenClaimableAmount(address _user) public view returns(uint)
    {
        return rewards[_user].rewardAmount[2]*10**IERC20(RewardAddresses[1]).decimals();
    }
    function getTrxClaimableAmount(address _user) public view returns(uint)
    {
        return rewards[_user].rewardAmount[1]*1e18;
    }

}