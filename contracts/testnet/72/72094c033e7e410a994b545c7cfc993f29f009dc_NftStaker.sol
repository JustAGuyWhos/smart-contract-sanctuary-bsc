/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: aarma nft/staking.sol


pragma solidity ^0.8.7;






interface  pancake {
   function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}


contract NftStaker is Ownable {
    IERC721 private parentNFT;

    struct Stake {
        address _address;
        uint tokenId;
        uint starttime;
        uint endtime;
        bool isStacked;
        address nftaddress;
        uint price;
        uint nftId;
    }
   
    Stake[] public stakes;
    struct NftStructure{
        address nftaddress;
        uint price;
    }
    struct  PriceStruct {
        address nftaddress;
        uint nftId;
        uint tokenId;
        uint price;
    }
    PriceStruct[] public priceStruct;
    NftStructure[] public nftstruct;
    address public routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public baseToken = 0x1300221eD2Af06E1FB737FBC9aBE2A9466D6E4D4;
    address public aarma = 0xde6E2eBdf20dC8087Fd9287065B644298f2B24d8;
    address public ausd = 0x52a106763B860754DdEdC35075b8E917Fb1cFf29;

    constructor(address[] memory _address,uint[] memory price) {
        require (_address.length == price.length,"length of address and price should be same");
        for(uint i = 0; i < _address.length; i++){
             parentNFT = IERC721(_address[i]);
             nftstruct.push(NftStructure({
                 nftaddress : _address[i],
                price : price[i]
             }));
        }
    }

    function getTokenPrice(uint amount,address _token1,address _token2) private view returns(uint){
        address[] memory path = new address[](2);
        path[0] = _token1;
        path[1] = _token2;
        uint[] memory price = pancake(routerAddress).getAmountsOut(amount,path);
        return (price[0]*1e18)/(price[1]);
    }

    function stake(uint nftId,uint _tokenId) public {
        parentNFT = IERC721(nftstruct[nftId].nftaddress);
        uint price;
        if(priceStruct.length == 0){
             priceStruct.push(PriceStruct({
                    nftaddress : nftstruct[nftId].nftaddress,
                    nftId : nftId,
                    tokenId : _tokenId,
                    price : nftstruct[nftId].price
                }));
        }
        for(uint i = 0; i < priceStruct.length; i++){
            if(priceStruct[i].nftId == nftId && priceStruct[i].tokenId == _tokenId){
                price = priceStruct[i].price;   
            }else {
                price = nftstruct[nftId].price;
                priceStruct.push(PriceStruct({
                    nftaddress : nftstruct[nftId].nftaddress,
                    nftId : nftId,
                    tokenId : _tokenId,
                    price : price
                }));
            }
        }

        
        parentNFT.transferFrom(msg.sender, address(this), _tokenId);
        stakes.push(
            Stake({
                _address : msg.sender,
                tokenId: _tokenId,
                starttime: block.timestamp,
                isStacked: true,
                nftaddress:nftstruct[nftId].nftaddress,
                endtime : 0,
                price : price,
                nftId: nftId
            })
        );

    }

    function getPrice(uint nftId,uint _tokenId) public view returns(uint){
        uint price;
        for(uint i = 0; i < priceStruct.length; i++){
            if(priceStruct[i].nftId == nftId && priceStruct[i].tokenId == _tokenId){
                price = priceStruct[i].price;
            }
        }
        return price;
    }
    // function restake(uint nftId,uint _tokenId) public {
    //     address nftAddress = nftstruct[nftId].nftaddress;
    //     parentNFT = IERC721(nftAddress);
    //     address nftOwner = parentNFT.ownerOf(_tokenId);
    //     require(nftOwner == address(this),"Nft not available");
    //     uint price ;
    //     for(uint i = 0; i < stakes.length; i++){
    //         if(stakes[i].tokenId == _tokenId && stakes[i].nftaddress == nftAddress){
    //             require(stakes[i].isStacked == false,"tokeId already staked !!");
    //             price = stakes[i].price;
    //         }
    //     }
    //     uint getPriceArma = getTokenPrice(price,baseToken,aarma);
    //     uint totalAarma = ( getPriceArma * price ) / 1e18;
    //     IERC20 paytoken = IERC20(aarma);
    //     paytoken.transferFrom(msg.sender,address(this),totalAarma);
    //         stakes.push(
    //             Stake({
    //                 _address : msg.sender,
    //                 tokenId: _tokenId,
    //                 starttime: block.timestamp,
    //                 isStacked: true,
    //                 nftaddress:nftAddress,
    //                 endtime : 0,
    //                 price : price,
    //                 nftId: nftId
    //             })
    //         );
    // }

    function unstake(uint nftId,uint _tokenId) public onlyOwner {
        address nftAddress = nftstruct[nftId].nftaddress;
        uint price;
         for(uint i = 0; i < priceStruct.length; i++){
            if(priceStruct[i].nftId == nftId && priceStruct[i].tokenId == _tokenId){
                priceStruct[i].price = ((priceStruct[i].price * 5e18) / 100e18) + priceStruct[i].price; 
                price =   priceStruct[i].price;
            }
        }
        for(uint i=0; i < stakes.length; i++){
            if(stakes[i].tokenId == _tokenId && stakes[i].nftaddress == nftAddress && stakes[i].endtime == 0 ){
                require(stakes[i].isStacked == true,"tokeId not staked !!");
                stakes[i].isStacked = false;
                stakes[i].endtime = block.timestamp;
                stakes[i].price = price;
            }
        }
    }

    function withdrawToken(address token,uint256 amount) public onlyOwner {
        IERC20 paytoken = IERC20(token);
        paytoken.transferFrom(address(this),msg.sender,amount);
    }
    function withdrawCoin() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawERC721(uint nftId,uint _tokenId) public onlyOwner {
        address nftAddress = nftstruct[nftId].nftaddress;
        for(uint i = 0; i < stakes.length; i++){
            if(stakes[i].tokenId == _tokenId && stakes[i].nftaddress == nftAddress){
                require(stakes[i].isStacked == false,"tokeId staked !!");
            }
        }
        parentNFT = IERC721(nftAddress);
        parentNFT.transferFrom(address(this),msg.sender,_tokenId);
    }

    function buyNft(uint nftId,uint _tokenId) public {
        address nftAddress = nftstruct[nftId].nftaddress;
        for(uint i = 0; i < stakes.length; i++){
            if(stakes[i].tokenId == _tokenId && stakes[i].nftaddress == nftAddress){
                require(stakes[i].isStacked == false,"tokenId staked !!");
            }
        }
        uint price;
         for(uint i = 0; i < priceStruct.length; i++){
            if(priceStruct[i].nftId == nftId && priceStruct[i].tokenId == _tokenId){
                price =   priceStruct[i].price;
            }
        }
        parentNFT = IERC721(nftAddress);
        IERC20 paytoken = IERC20(aarma);
        uint getPriceArma = getTokenPrice(price,baseToken,aarma);
        uint totalAarma = ( getPriceArma * price ) / 1e18;
        paytoken.transferFrom(msg.sender,address(this),totalAarma);
        parentNFT.transferFrom(address(this),msg.sender,_tokenId);
    }

    function buyNftwithausd(uint nftId,uint _tokenId) public {
        address nftAddress = nftstruct[nftId].nftaddress;
        for(uint i = 0; i < stakes.length; i++){
            if(stakes[i].tokenId == _tokenId && stakes[i].nftaddress == nftAddress){
                require(stakes[i].isStacked == false,"tokenId staked !!");
            }
        }
        uint price;
         for(uint i = 0; i < priceStruct.length; i++){
            if(priceStruct[i].nftId == nftId && priceStruct[i].tokenId == _tokenId){
                price =   priceStruct[i].price;
            }
        }
        parentNFT = IERC721(nftAddress);
        IERC20 paytoken = IERC20(ausd);
        IERC20 paytoken1 = IERC20(aarma);
        uint getPriceArma = getTokenPrice(price,baseToken,aarma);
        uint totalAarma = ( getPriceArma * price ) / 1e18;
        paytoken1.transferFrom(msg.sender,address(this),totalAarma/2);
        paytoken.transferFrom(msg.sender,address(this),price / 2);
        parentNFT.transferFrom(address(this),msg.sender,_tokenId);
    }

    function balanceOfToken() public view returns(uint){
        IERC20 paytoken = IERC20(ausd);
        return paytoken.balanceOf(address(this));
    }


}