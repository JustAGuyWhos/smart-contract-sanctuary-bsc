/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity >=0.8.0;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
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


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
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


// OpenZeppelin Contracts (last updated v4.6.0) (utils/cryptography/MerkleProof.sol)
/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

contract IDO is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private ids;

    struct Initialize {
        bool hasWhitelisting;
        uint256 tradeValue;
        uint256 startDate;
        uint256 endDate;
        uint256 individualMinimumAmount;
        uint256 individualMaximumAmount;
        uint256 minimumRaise;
        uint256 tokensForSale;
        bool isTokenSwapAtomic;
    }
 
    struct Purchase {
        address purchaser;
        uint256 amount;
        uint256 pamount;
        uint256 timestamp;
    }

    bool public unsoldTokensReedemed;

    Initialize public initialize;
    string public idoURI;
    IBEP20 public bep20;
    uint8 public decimals;
    IBEP20 public busd;
    bool public hasBusd;
 
    bool public isSaleFunded;
 
    bytes32 public merkleRootWhitelist;
    uint256 public tokensAllocated;
    address payable public FEE_ADDRESS;
    uint256 public feePercentage;
 
    mapping(uint256 => Purchase) public purchases;
    mapping(address => uint256) public redeemAmount;
    mapping(address => bool) public redeemStatus;
 
    event Fund(address indexed funder, uint256 indexed amount, uint256 indexed timestamp);
    event PurchaseEvent(address indexed purchaser, uint256 indexed purchaseId, uint256 indexed amount, uint256 timestamp);
    event Redeem(address indexed who, uint256 indexed amount, uint256 indexed timestamp);
    event Refund(address indexed who, uint256 indexed amount, uint256 indexed timestamp);
 
    constructor(Initialize memory _initialize, string memory  _uri, address _busdAddress, bool _hasBusd, address _tokenAddress, uint256 _feeAmount, address _FEE_ADDRESS) {
        uint256 timestamp = block.timestamp;
 
        require(timestamp < _initialize.startDate, "Start Date Date should be further than current date");
        require(timestamp < _initialize.endDate, "End Date should be further than current date");
        require(_initialize.startDate < _initialize.endDate, "End Date higher than Start Date");
        require(_initialize.tokensForSale > 0, "Tokens for Sale should be > 0");
        require(_initialize.tokensForSale > _initialize.individualMinimumAmount, "Tokens for Sale should be > Individual Minimum Amount");
        require(_initialize.individualMaximumAmount >= _initialize.individualMinimumAmount, "Individual Maximim AMount should be > Individual Minimum Amount");
        require(_initialize.minimumRaise <= _initialize.tokensForSale, "Minimum Raise should be < Tokens For Sale");
        require(_feeAmount > 0, "Fee Percentage has to be > 0");
        require(_feeAmount <= 10000, "Fee Percentage has to be < 10000");
 
        initialize = _initialize;
        busd = IBEP20(_busdAddress);
        hasBusd = _hasBusd;
        FEE_ADDRESS = payable(_FEE_ADDRESS);
        idoURI = _uri;
 
        initialize.minimumRaise = !_initialize.isTokenSwapAtomic  ? _initialize.minimumRaise : 0;

        bep20 = IBEP20(_tokenAddress);
        decimals = bep20.decimals();
        feePercentage = _feeAmount;
        unsoldTokensReedemed = false;
        isSaleFunded = false;
        ids.increment();
    }
 
    modifier isNotAtomicSwap() {
        require(!initialize.isTokenSwapAtomic, "Has to be non Atomic swap");
        _;
    }
 
    modifier isSaleFinalized() {
        require(block.timestamp > initialize.endDate, "Has to be finalized");
        _;
    }
 
    function setMerkleRoot(bytes32 _merkleRootWhitelist) external onlyOwner {
        merkleRootWhitelist = _merkleRootWhitelist;
    }
 
    function setTokenURI(string memory _idoURI) public onlyOwner {
        idoURI = _idoURI;
    }

    function lastId() external view returns(uint256) {
        return ids.current();
    }
 
    function fund(uint256 _amount) external nonReentrant {
        uint256 timestamp = block.timestamp;
        require(timestamp < initialize.startDate, "Has to be pre-started");
 
        uint256 availableTokens = bep20.balanceOf(address(this)) + _amount;
        require(availableTokens <= initialize.tokensForSale, "Transfered tokens have to be equal or less than proposed");
 
        address who = _msgSender();
        bep20.transferFrom(who, address(this), _amount);
 
        if(availableTokens == initialize.tokensForSale){
            isSaleFunded = true;
        }
        emit Fund(who, _amount, timestamp);
    }
 
    function swap(uint256 _amount) external payable {
        require(!initialize.hasWhitelisting, "IDO has whitelisting");
        swapint(_msgSender(), _amount);
    }
 
    function swap(bytes32[] calldata _merkleProof, uint256 _amount) external payable {
        require(initialize.hasWhitelisting, "IDO not has whitelisting");
        address who = _msgSender();
        require(MerkleProof.verify(_merkleProof, merkleRootWhitelist, keccak256(abi.encodePacked(who))), "Address not whitelist");
        swapint(who, _amount);
    }

    function swapint(address _who, uint256 _amount) internal nonReentrant {
        require(isSaleFunded, "Has to be funded");
        uint256 timestamp = block.timestamp;
        require(timestamp >= initialize.startDate && timestamp <= initialize.endDate, "Has to be open");
        require(_amount > 0, "Amount must be more than zero");
        require(_amount <= (initialize.tokensForSale - tokensAllocated), "Amount is less than tokens available");
        uint256 costAmount = _amount * initialize.tradeValue / (10 ** decimals);
        require(hasBusd || (!hasBusd && msg.value == costAmount), "User has to cover the cost of the swap in BNB, use the cost function to determine");
        require(_amount >= initialize.individualMinimumAmount, "Amount is smaller than minimum amount");
        require((redeemAmount[_who] + _amount) <= initialize.individualMaximumAmount, "Total amount is bigger than maximum amount");

        if (hasBusd) {
            busd.transferFrom(_who, address(this), costAmount);
        }
        if(initialize.isTokenSwapAtomic){
            bep20.transfer(_who, _amount);
        }
        uint256 purchaseId = ids.current();
        purchases[purchaseId] = Purchase(_who, _amount, costAmount, timestamp);
        tokensAllocated += _amount;
        redeemAmount[_who] += _amount;
        ids.increment();
        emit PurchaseEvent(_who, purchaseId, _amount, timestamp);
    }
 
    function redeemTokens() external isNotAtomicSwap isSaleFinalized nonReentrant {
        require(tokensAllocated >= initialize.minimumRaise, "Minimum raise has not been achieved");
        address who = _msgSender();
        require(!redeemStatus[who], "Already redeemed");
        uint256 amount = redeemAmount[who];
        require(amount > 0, "Purchase cannot be zero");
        redeemStatus[who] = true;
        bep20.transfer(who, amount);
        emit Redeem(who, amount, block.timestamp);
    }
 
    function redeemGivenMinimumGoalNotAchieved() external isNotAtomicSwap isSaleFinalized nonReentrant {
        require(tokensAllocated < initialize.minimumRaise, "Minimum raise has to be reached");
        address who = _msgSender();
        require(!redeemStatus[who], "Already redeemed");
        uint256 amount = redeemAmount[who] * initialize.tradeValue / (10 ** decimals);
        require(amount > 0, "Purchase cannot be zero");
        redeemStatus[who] = true;
        if (hasBusd) {
            busd.transfer(who, amount);
        } else {
            Address.sendValue(payable(who), amount);
        }
        emit Refund(who, amount, block.timestamp);
    }
 
    function withdrawFunds() external onlyOwner isSaleFinalized {
        require(tokensAllocated >= initialize.minimumRaise, "Minimum raise has to be reached");
        address who = _msgSender();
        uint256 amount = hasBusd ? busd.balanceOf(address(this)) : address(this).balance;
        uint256 amountFee = amount * feePercentage / 10000;
        if (hasBusd) {
            busd.transfer(FEE_ADDRESS, amountFee);
            busd.transfer(who, amount - amountFee);
        } else {
            Address.sendValue(FEE_ADDRESS, amountFee);
            Address.sendValue(payable(who), amount - amountFee);
        }
    }  
 
    function withdrawUnsoldTokens() external onlyOwner isSaleFinalized {
        require(!unsoldTokensReedemed, "Token already taken");
        uint256 unsoldTokens = tokensAllocated >= initialize.minimumRaise ? initialize.tokensForSale - tokensAllocated : initialize.tokensForSale;
        require(unsoldTokens > 0, "Unsold token cannot be zero");
        unsoldTokensReedemed = true;
        bep20.transfer(_msgSender(), unsoldTokens);
    }   
 
    function removeOtherbep20Tokens(address _tokenAddress, address _to) external onlyOwner isSaleFinalized {
        require(_tokenAddress != address(bep20) && _tokenAddress != address(busd), "Token Address has to be diff than the bep20 subject to sale and payment");
        IBEP20 bep20Token = IBEP20(_tokenAddress);
        bep20Token.transfer(_to, bep20Token.balanceOf(address(this)));
    } 
}

contract IDOFactory is Ownable {
    using Counters for Counters.Counter;

    struct StructIDO {
        address tokenAddress;
        string uri;
    }

    uint256 public totalIdos;
    address public busdAddress;
    address public feeAddress;
    address[] public idosAddress;

    mapping(address => StructIDO) public listIDOs;

    event IdoCreated(address indexed ido, address indexed tokenAddress, string uri);
    event onFeeAddressChanged(address indexed _feeAddress);
 
    constructor(address _busdAddress, address _feeAddress) {
        require(_busdAddress != address(0) && _feeAddress != address(0), "Address cannot be null");
        busdAddress = _busdAddress;
        feeAddress = _feeAddress;
    }
 
    function changeFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "Address cannot be null");
        feeAddress = _feeAddress;
        emit onFeeAddressChanged(feeAddress);
    }
 
    function createIDO(
        IDO.Initialize memory _initialize,
        string memory _uri,
        bool _hasBusd,
        address _tokenAddress,
        uint256 _feeAmount,
        address _newAddressOwner
    ) external onlyOwner {
        require(_newAddressOwner != address(0) && _tokenAddress != address(0), "Address cannot be null");
        IDO _ido = new IDO(
            _initialize,
            _uri,
            busdAddress,
            _hasBusd,
            _tokenAddress,
            _feeAmount,
            feeAddress
        );
        address idoAddress = address(_ido);
        _ido.transferOwnership(_newAddressOwner);
        listIDOs[idoAddress] = StructIDO(_tokenAddress, _uri);
        idosAddress.push(idoAddress);
        totalIdos++;
        emit IdoCreated(idoAddress, _tokenAddress, _uri);
    }
}