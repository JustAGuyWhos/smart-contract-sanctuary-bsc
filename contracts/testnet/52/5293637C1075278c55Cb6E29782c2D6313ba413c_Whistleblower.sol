// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Whistleblower is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _caseIdCounter;

    struct caseDetails {
        address _owner;
        string _uri;
    }

    uint256 public perPage = 20;

    string[] private casesUri;

    mapping(uint256 => caseDetails) public caseUrl;
    mapping(address => string[]) public userCases;

    mapping(string => string[]) comments;
    mapping(string => address[]) commentedUsers;
    mapping(address => mapping(string => bool)) public isUserCommented;

    event NewCaseCrated(address owner, uint256 caseId, string cid);

    constructor() {}

    function createCase(string memory _uri) public {
        uint256 tokenId = _caseIdCounter.current();
        _caseIdCounter.increment();

        caseUrl[tokenId]._owner = msg.sender;
        caseUrl[tokenId]._uri = _uri;

        userCases[msg.sender].push(_uri);

        casesUri.push(_uri);

        emit NewCaseCrated(msg.sender, tokenId, _uri);
    }

    function getCaseUri(uint256 _caseId) public view returns (string memory) {
        return caseUrl[_caseId]._uri;
    }

    function getUserCases(address _user) public view returns (string[] memory) {
        return userCases[_user];
    }

    function editCaseUri(uint256 _caseId, string memory _newUri) public {
        require(
            caseUrl[_caseId]._owner == msg.sender,
            "Only case owner can update the uri"
        );
        caseUrl[_caseId]._uri = _newUri;
    }

    function getAllCases(uint256 _page) public view returns (string[] memory) {
        uint256 from = ((_page - 1) * perPage);
        uint256 start = 0;
        if (from > 0) start = from - 1;
        uint256 to = (_page * perPage);

        if (to > casesUri.length) to == casesUri.length;

        uint256 length = (to - start) + 1;

        string[] memory _cases = new string[](length);

        for (uint256 i = 0; i < to; i++) {
            _cases[i] = casesUri[i + start];
        }

        return _cases;
    }

    function changePerPage(uint256 _value) external onlyOwner {
        perPage = _value;
    }

    function comment(string memory _cid, string memory _comment) public {
        require(!isUserCommented[msg.sender][_cid], "User already commented");

        comments[_cid].push(_comment);
        commentedUsers[_cid].push(msg.sender);
    }

    function getAllComments(string memory _cid)
        public
        view
        returns (string[] memory)
    {
        return comments[_cid];
    }

    function getAllCommentedUsers(string memory _cid)
        public
        view
        returns (address[] memory)
    {
        return commentedUsers[_cid];
    }
}