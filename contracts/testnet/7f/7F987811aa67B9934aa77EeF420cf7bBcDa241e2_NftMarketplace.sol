// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NftMarketplace is IERC721Receiver, Ownable, ReentrancyGuard {

    struct OrderBook {
        uint256 orderId;    //AKA index that starts from 0
        bool isActive;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
        address buyer;
        address seller;
        uint256 listTimestamp;
        uint256 soldTimestamp;
    }
    OrderBook[] private orderBook;
    
    uint256 public fee = 5;
    address payable public feeReceiver;
    uint256 private totalSalesVolume;

    constructor(address _feeReceiver) {
        feeReceiver = payable(_feeReceiver);
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function listNft(address _nftAddress, uint256 _tokenId, uint256 _price) external nonReentrant {
        require(!isListed(_tokenId), "Item already listed");
        require(ownerOf(_nftAddress, _tokenId) == msg.sender, "Not Nft owner");
        require(_price > 0, "Price must be greater than zero");
        // require(IERC721(nftAddress).getApproved(tokenId) == address(this), "NFT not approved for marketplace");

        // Transfer NFT into the contract
        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        orderBook.push(OrderBook({
            orderId : orderBook.length,
            isActive : true,
            nftAddress : _nftAddress,
            tokenId : _tokenId,
            price : _price,
            buyer : address(0),
            seller : msg.sender,
            listTimestamp : block.timestamp,
            soldTimestamp : 0
        }));

        emit ListNft(msg.sender, orderBook.length, _nftAddress, _tokenId, _price);
    }

    function purchaseNft(uint256 _orderId) external payable nonReentrant {
        require(isListed(_orderId), "Item is not listed");
        
        OrderBook storage listedItem = orderBook[_orderId];
        require(msg.value == listedItem.price, "Invalid price");

        // Take fee and transfer fund to seller
        uint256 _fee = msg.value * fee / 100;
        takeFee(_fee);
        forwardFund(listedItem.seller, msg.value - _fee);

        // update OrderBook record
        listedItem.isActive = false;
        listedItem.buyer = msg.sender;
        listedItem.soldTimestamp = block.timestamp;

        // Update counter
        totalSalesVolume += listedItem.price;

        // Transfer NFT to buyer
        IERC721(listedItem.nftAddress).safeTransferFrom(address(this), msg.sender, listedItem.tokenId);

        emit PurchaseNft(msg.sender, _orderId, listedItem.price);
    }

    function updateListing(uint256 _orderId, uint256 _price) external nonReentrant {
        require(isListed(_orderId), "Item is not listed");
        
        OrderBook storage listedItem = orderBook[_orderId];
        require(orderBook[_orderId].seller == msg.sender, "Not Nft owner");
        require(_price > 0, "Price must be greater than zero");

        listedItem.price = _price;
        emit UpdateListing(msg.sender, _orderId, _price);
    }

    function cancelListing(uint256 _orderId) external nonReentrant {
        require(isListed(_orderId), "Item is not listed");

        OrderBook storage listedItem = orderBook[_orderId];
        require(listedItem.seller == msg.sender, "Not Nft owner");

        // update OrderBook record
        listedItem.isActive = false;

        IERC721(listedItem.nftAddress).safeTransferFrom(address(this), msg.sender, listedItem.tokenId);

        emit CancelListing(msg.sender, _orderId);
    }

    function takeFee(uint256 amount) internal {
        feeReceiver.transfer(amount);
    }

    function forwardFund(address sellerAddr, uint256 amount) internal {
        payable(sellerAddr).transfer(amount);
    }

    function ownerOf(address nftAddress, uint256 tokenId) public view returns (address) {
        return IERC721(nftAddress).ownerOf(tokenId);
    }

    function isListed(uint256 orderId) public view returns (bool) {
        uint256 orderBookLength = orderBook.length;
        if(orderBookLength == 0 || orderId >= orderBookLength)
            return false;

        OrderBook memory listedItem = orderBook[orderId];
        if(listedItem.isActive == true) 
            return true;
        else
            return false;
    }

    //=============================================================================================
    // SETTERS
    //=============================================================================================

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;

        emit SetFee(_fee);
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        require(_feeReceiver != address(0), "Zero address");
        feeReceiver = payable(_feeReceiver);

        emit SetFeeReceiver(_feeReceiver);
    }

    //=============================================================================================
    // GETTERS
    //=============================================================================================

    function getAllActiveOrdersCount() public view returns (uint256) {
        uint256 orderBookLength = orderBook.length;
        uint256 itemCount = 0;

        for (uint i = 0; i < orderBookLength; i++) {
            if (orderBook[i].isActive) {
                itemCount ++;
            }
        }

        return itemCount;
    }

    function getAllActiveOrderIds() external view returns (uint256[] memory) {
        uint itemCount = getAllActiveOrdersCount();
        uint256[] memory orderBookList = new uint256[](itemCount);

        uint index = 0;
        uint256 orderBookLength = orderBook.length;

        for (uint i = 0; i < orderBookLength; i++) {
            if (orderBook[i].isActive) {
                orderBookList[index] = i;
                index ++;
            }
        }
        
        return orderBookList;
    }

    function getAllActiveOrders() external view returns (OrderBook[] memory) {
        uint itemCount = getAllActiveOrdersCount();
        OrderBook[] memory orderBookList = new OrderBook[](itemCount);

        uint index = 0;
        uint256 orderBookLength = orderBook.length;

        for (uint i = 0; i < orderBookLength; i++) {
            if (orderBook[i].isActive) {
                orderBookList[index] = orderBook[i];
                index ++;
            }
        }
        
        require(orderBookList.length > 0, "Empty orderBookList");
        return orderBookList;
    }

    function getRecentActiveOrders(uint256 _recordCount) external view returns (OrderBook[] memory) {
        uint256 orderBookLength = orderBook.length;
        if(_recordCount > orderBookLength)
            _recordCount = orderBookLength;
            
        uint index = 0;
        OrderBook[] memory orderBookList = new OrderBook[](_recordCount);

        for (uint i = orderBookLength; i > 0; i--) {
            OrderBook storage _orderBook = orderBook[i-1];
            if (_orderBook.isActive) {
                orderBookList[index] = _orderBook;
                index ++;
                _recordCount--;
            }

            if(_recordCount == 0)
                break;
        }

        require(orderBookList.length > 0, "Empty orderBookList");
        return orderBookList;
    }

    function getRecentCompletedOrders(uint256 _recordCount) external view returns (OrderBook[] memory) {
        uint256 orderBookLength = orderBook.length;
        if(_recordCount > orderBookLength)
            _recordCount = orderBookLength;
            
        uint index = 0;
        OrderBook[] memory orderBookList = new OrderBook[](_recordCount);

        for (uint i = orderBookLength; i > 0; i--) {
            OrderBook storage _orderBook = orderBook[i-1];
            if (!_orderBook.isActive && _orderBook.buyer != address(0) && _orderBook.soldTimestamp != 0) {
                orderBookList[index] = _orderBook;
                index ++;
                _recordCount--;
            }

            if(_recordCount == 0)
                break;
        }

        require(orderBookList.length > 0, "Empty orderBookList");
        return orderBookList;
    }

    function getOrderDetailsByOrderId(uint256 orderId) external view returns (OrderBook memory) {
        return orderBook[orderId];
    }

    function getOrderBookLength() external view returns (uint256) {
        return orderBook.length;
    }

    function getTotalSalesVolume() external view returns (uint256) {
        return totalSalesVolume;
    }

    //=============================================================================================
    // EVENTS
    //=============================================================================================

    event ListNft(address seller, uint256 orderId, address nftAddress, uint256 tokenId, uint256 price);
    event PurchaseNft(address buyer, uint256 orderId, uint256 price);
    event UpdateListing(address seller, uint256 orderId, uint256 price);
    event CancelListing(address seller, uint256 orderId);
    event SetFee(uint256 fee);
    event SetFeeReceiver(address feeReceiver);
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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