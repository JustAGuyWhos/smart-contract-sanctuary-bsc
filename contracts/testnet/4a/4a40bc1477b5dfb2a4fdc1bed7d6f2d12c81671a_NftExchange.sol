// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NftExchange__PriceMustBeAboveZero();
error NftExchange__NotApprovedForExchange();
error NftExchange__AlreadyListed(address nftAddr, uint256 tokenId);
error NftExchange__NotListed(address nftAddr, uint256 tokenId);
error NftExchange__NotOwner();
error NftExchange__PriceNotMet(address nftAddr, uint256 tokenId, uint256 price);
error NftExchange__NoProceeds();
error NftExchange__WithdrawFailed();

contract NftExchange is ReentrancyGuard {
	struct Listing {
		uint256 price;
		address seller;
	}

	event ItemListed(
		address indexed seller,
		address indexed nftAddr,
		uint256 indexed tokenId,
		uint256 price
	);

	event ItemBought(
		address indexed buyer,
		address indexed nftAddr,
		uint256 indexed tokenId,
		uint256 price
	);

	event ListingCancelled(address indexed owner, address indexed nftAddr, uint256 indexed tokenId);

	// NFT contract address -> NFT Token ID -> Listing
	mapping(address => mapping(uint256 => Listing)) private s_listings;
	// Seller address -> Amount earned
	mapping(address => uint256) private s_proceeds;

	modifier notListed(
		address _nftAddr,
		uint256 _tokenId,
		address _owner
	) {
		Listing memory listing = s_listings[_nftAddr][_tokenId];
		if (listing.price > 0) revert NftExchange__AlreadyListed(_nftAddr, _tokenId);
		_;
	}

	modifier isOwner(
		address _nftAddr,
		uint256 _tokenId,
		address _seller
	) {
		IERC721 nft = IERC721(_nftAddr);
		address owner = nft.ownerOf(_tokenId);
		if (_seller != owner) revert NftExchange__NotOwner();
		_;
	}

	modifier isListed(address _nftAddr, uint256 _tokenId) {
		Listing memory listing = s_listings[_nftAddr][_tokenId];
		if (listing.price <= 0) revert NftExchange__NotListed(_nftAddr, _tokenId);
		_;
	}

	/**
	 * @notice Function for listing an NFT on the exchange
	 * @param _nftAddr: Address of the NFT
	 * @param _tokenId: Token ID of the NFT
	 * @param _price: Listing price of the NFT, set by the seller
	 * @dev Sellers would still be able to hold the NFT in their wallet while it is being listed
	 */
	function listNft(
		address _nftAddr,
		uint256 _tokenId,
		uint256 _price
	) external notListed(_nftAddr, _tokenId, msg.sender) isOwner(_nftAddr, _tokenId, msg.sender) {
		if (_price <= 0) revert NftExchange__PriceMustBeAboveZero();

		IERC721 nft = IERC721(_nftAddr);
		if (nft.getApproved(_tokenId) != address(this))
			revert NftExchange__NotApprovedForExchange();

		s_listings[_nftAddr][_tokenId] = Listing(_price, msg.sender);
		emit ItemListed(msg.sender, _nftAddr, _tokenId, _price);
	}

	function buyNft(address _nftAddr, uint256 _tokenId)
		external
		payable
		nonReentrant
		isListed(_nftAddr, _tokenId)
	{
		Listing memory listing = s_listings[_nftAddr][_tokenId];
		if (msg.value < listing.price)
			revert NftExchange__PriceNotMet(_nftAddr, _tokenId, listing.price);

		s_proceeds[listing.seller] += msg.value;
		delete s_listings[_nftAddr][_tokenId];
		IERC721(_nftAddr).safeTransferFrom(listing.seller, msg.sender, _tokenId);
		emit ItemBought(msg.sender, _nftAddr, _tokenId, msg.value);
	}

	function cancelListing(address _nftAddr, uint256 _tokenId)
		external
		isOwner(_nftAddr, _tokenId, msg.sender)
		isListed(_nftAddr, _tokenId)
	{
		delete s_listings[_nftAddr][_tokenId];
		emit ListingCancelled(msg.sender, _nftAddr, _tokenId);
	}

	function updateListing(
		address _nftAddr,
		uint256 _tokenId,
		uint256 _newPrice
	) external isListed(_nftAddr, _tokenId) isOwner(_nftAddr, _tokenId, msg.sender) {
		s_listings[_nftAddr][_tokenId].price = _newPrice;
		emit ItemListed(msg.sender, _nftAddr, _tokenId, _newPrice);
	}

	function withdrawProceeds() external {
		uint256 proceeds = s_proceeds[msg.sender];
		if (proceeds <= 0) revert NftExchange__NoProceeds();

		s_proceeds[msg.sender] = 0;
		(bool success, ) = payable(msg.sender).call{value: proceeds}("");
		if (!success) revert NftExchange__WithdrawFailed();
	}

	function getListing(address _nftAddr, uint256 _tokenId) external view returns (Listing memory) {
		return s_listings[_nftAddr][_tokenId];
	}

	function getProceeds(address _seller) external view returns (uint256) {
		return s_proceeds[_seller];
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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