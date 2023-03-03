/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
                /// @solidity memory-safe-assembly
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

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)





/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}



/**
 * @notice Data structure for Community-based polls and proposals.
 */
struct CommunityPoll {
	uint256 id;
	address creator;
	PollStatus status;
	uint256 _type; //1- [amount, targetAcc], 2- [bountyAmount, availableClaims, daystoComplete], 3- [proposedDaoName], 4- [proposedPurpose], 5- [links], 6- [proposedCover, proposedLogo], 7- [proposedLegalStatus, proposedLegalDocs], 8- [bondsToCreateProposal, timeBeforeProposalExpires, bondsToClaimBounty, timeToUnclaimBounty] , 9- [newGroupName, intialMemberAccount], 10- [targetGroupName, memberToAdd], 11- [targetGroupName, memberToRemove], 12-[], 13- [contractAddrFnCall, fnCallName, fnCallAbi]
	ProposeChanges proposedChanges;
	uint256 startTimeStamps;
	uint256 endTimeStamps;
	bool result; // false - if proposal lose voting  && true - if proposal won voting 
}

// { value: 1, label: 'Propose a Transfer', fields: [{name: "Amount", val: "amount"}, {name: "Target Account", val: "targetAcc"},] }, //amount, targetAcc
// { value: 2, label: 'Propose to Create Bounty', fields: [{name: "Bounty Amount", val: "bountyAmount"}, {name: "Available Claim Amount", val: "availableClaims"}, {name: "Days to complete", val: "daystoComplete"}]}, // bountyAmount, availableClaims, daystoComplete,
// { value: 3, label: 'Propose to Change DAO Name', fields: [{name: "Proposed DAO Name", val: "proposedDaoName"}] }, // proposedDaoName,
// { value: 4, label: 'Propose to Change Dao Purpose', fields: [{name: "Proposed Purpose", val: "proposedPurpose"}] }, // proposedPurpose
// { value: 5, label: 'Propose to Change Dao Links', fields: [{name: "Proposed Links", val: "links"}] }, // links
// { value: 6, label: 'Propose to Change Dao Flag and Logo', fields: [{name: "Proposed Cover Image", val: "proposedCover"},{name: "Proposed Logo", val: "proposedLogo"}]}, // proposedCover, proposedLogo
// { value: 7, label: 'Propose to Change DAO Legal Status and Doc', fields: [{name: "Proposed Legal Status", val: "proposedLegalStatus"},{name: "Proposed Legal Docs", val: "proposedLegalDocs"}]  }, // proposedLegalStatus, proposedLegalDocs
// { value: 8, label: 'Propose to Change Bonds and Deadlines', fields: [{name: "Bonds", val: "bondsToCreateProposal"},{name: "Expiry", val: "timeBeforeProposalExpires"}, {name: "Bonds to claim bounty", val: "bondsToClaimBounty"}, {name: "Time to UnClaim Bounty", val: "timeToUnclaimBounty"}] }, // bondsToCreateProposal, timeBeforeProposalExpires, bondsToClaimBounty, timeToUnclaimBounty
// { value: 9, label: 'Propose to Create a Group', fields: [{name: "New Group Name", val: "newGroupName"}, {name: "Initial Member Account", val: "intialMemberAccount"},]  }, // newGroupName, intialMemberAccount,
// { value: 10, label: 'Propose to Add Member from Group', fields: [{name: "Target Group Name", val: "targetGroupName"}, {name: "Member To Add ", val: "memberToAdd"}]}, // targetGroupName, memberToAdd

// okay
// { value: 11, label: 'Propose to Remove Member from Group', fields: [{name: "Target Group Name", val: "targetGroupName"}, {name: "Member To Remove", val: "memberToRemove"}] }, // targetGroupName, memberToRemove
// { value: 12, label: 'Propose a Poll', fields: [] }, // with this type basic name and description would come
// { value: 13, label:  'Custom Function Call', fields: [{name: "Contract Address", val: "contractAddrFnCall"}, {name: "Function", val: "fnCallName"}, {name: "JSON ABI", val: "fnCallAbi"}]  } // contractAddrFnCall, fnCallName, fnCallAbi

// amount, targetAcc, bountyAmount, availableClaims, daystoComplete, proposedDaoName, proposedPurpose, links,proposedCover, proposedLogo, proposedLegalStatus, proposedLegalDocs, bondsToCreateProposal, timeBeforeProposalExpires, bondsToClaimBounty, timeToUnclaimBounty, newGroupName, intialMemberAccount, targetGroupName, memberToAdd, memberToRemove, contractAddrFnCall, fnCallName, fnCallAbi
struct ProposeChanges {
	uint256 amount;
	address targetAcc;
	string bountyAmount;
	string availableClaims;
	string daystoComplete;
	string proposedDaoName;
	string proposedPurpose;
	string[] links;
	string proposedCover;
	string proposedLogo;
	string proposedLegalStatus;
	string proposedLegalDocs;
	string bondsToCreateProposal;
	string timeBeforeProposalExpires;
	string bondsToClaimBounty;
	string timeToUnclaimBounty;
	Group newGroup;
	string targetGroupName;
	uint256 targetGroupId; //group Id  
	address memberToAdd;
	address memberToRemove;
	address contractAddrFnCall;
	string fnCallName;
	string fnCallAbi;
}

/**
 * @title Poll Status.
 * @notice
 */
enum PollStatus {
	ACTIVE,
	INACTIVE,
	ENDED
}

/**
 * @title Poll Vote.
 * @notice Poll vote struct for the community poll voting
 */
struct PollVote {
	address voter;
	bool vote;  //true-like, false-dislike
	uint256 pollId;
}

pragma experimental ABIEncoderV2;



library Counters {
    struct Counter {
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

interface COMMUNITY{

	function proposalCreationRight(uint256 _type, uint256 commId, address senderAddr) external view returns (bool);
	function votingRight(uint256 _type, uint256 commId, address senderAddr) external view returns (bool);

	// proposed functions
	function transferBounty(uint256 amount, address account, uint256 commId) external returns (bool);
	function createBounty(string memory bountyAmount, string memory availableClaims, string memory daystoComplete, uint256 commId) external returns (bool);
	function changeName(string memory name, uint256 commId) external returns (bool);
	function changePurpose(string memory purpose, uint256 commId) external returns (bool);
	function changelinks(string[] memory links, uint256 commId) external returns (bool);
	function changeLogoNCoverImage(string memory logoImage, string memory coverImage, uint256 commId) external returns (bool);
	function changeLegalStatusNDoc(string memory legalStatus, string memory legalDocuments, uint256 commId) external returns (bool);
	function changeBondAndDeadline(string memory bond, string memory expiry, string memory bountyClaim, string memory timeToUnclaimFree, uint256 commId) external returns (bool);
	function createGroup(Group memory newGroup, uint256 commId) external returns (bool);
	function addMemberToGroup(address addr, uint256 groupId, uint256 commId) external returns (bool);
	function removeMemberToGroup(address addr, uint256 groupId, uint256 commId) external returns (bool);
	function fnCall(address contractAddr, string memory name, string memory code, uint256 commId) external returns (bool);
}

/**
 * @title voting
 */
contract Voting {
	
	address communityContractAddress;
	COMMUNITY community; // community interface obj to call the community functions

	using Counters for Counters.Counter;
	Counters.Counter private _PollIds;
	Counters.Counter private _voteIds; 

	Counters.Counter private computeFlag;

	mapping(uint256 => CommunityPoll) private _pollData; //_PollIds -> poll
	mapping(uint256 => uint256[]) private _polls; //communityIds -> _PollIds
	 
	mapping(uint256 => PollVote) private _pollVotes; // _voteIds -> PollVote
	mapping(uint256 => uint256[]) private _votes; // _PollIds -> _voteIds

	event EvtCommunityPollCreate(uint256 pollId, uint256 startTimestamp, uint256 endTimestamp);
	event EvtCommunityPollDelete(uint256 pollId);
	event EvtCommunityPollVotes(uint256[] votesIds);
	event EvtCommunityPoll(CommunityPoll poll);

	/**contructor */
	constructor(address commAddr){
		communityContractAddress = commAddr;
		community = COMMUNITY(communityContractAddress); //to intialize the community contract
	}

	/**
	* @notice Cast vote for the community poll
	*/
	function communityVoteCast(uint256 commId, uint256 pollId, bool vote) external {
		CommunityPoll storage poll = pollFetch(pollId);
		//check wheather a member have a voting rights or not voted before
		require(isAlreadyVoted(pollId) != true, "You already voted.");
		// require(poll.endTimeStamps > getCurrentTime(), "You cant vote because proposal time is ended.");
		require(community.votingRight(poll._type, commId, msg.sender) != false, "You dont have voting right.");
		PollVote memory pollvote = PollVote(
			msg.sender, //voter 
			vote,
			pollId
		);

		_voteIds.increment();
		uint256 voteId = _voteIds.current();
		_pollVotes[voteId] = pollvote;
		uint256[] storage votesIds = _votes[pollId];
		votesIds.push(voteId);
		_votes[pollId] = votesIds;
	}

	/**
	 * @notice Check Voter already voted or not
	 */
	function isAlreadyVoted(uint256 pollId) internal view returns(bool){

	// mapping(uint256 => PollVote) private _pollVotes; // _voteIds -> PollVote
	// mapping(uint256 => uint256[]) private _votes; // _PollIds -> _voteIds

		uint256[] memory voteIds = _votes[pollId];
		bool isVoted = false;
		for (uint256 index = 0; index < voteIds.length ; index++) {
			PollVote memory vote = _pollVotes[voteIds[index]];
			if(vote.voter == msg.sender){
				isVoted = true;
			}
		}
		return isVoted;
	}
	
	function VotesInfo(uint256 pollId) external {
		uint256[] memory voteIds = _votes[pollId];
		emit EvtCommunityPollVotes(voteIds);
	}

	/**
	* @notice get the details for the community poll
	*/
	function pollFetch(uint256 id) internal returns ( CommunityPoll storage ){

	// mapping(uint256 => CommunityPoll) private _pollData; //pollId -> poll
	// mapping(uint256 => uint256[]) private _polls; //communityIds -> pollIds
		require(id > 0, "No poll found with provided pollId");
		CommunityPoll storage poll = _pollData[id];
		return poll;
	}

	// function pollDataFetch(uint256 commId) external view returns(CommunityPoll[] memory){
	// 	CommunityPoll[] memory pollArr = _polls[commId];
	// 	return pollArr; 
	// }
	// function pollDataFetchOk(uint256 commId, uint256 id) external view returns(CommunityPoll memory){
	// 	CommunityPoll[] memory pollArr = _polls[commId];
	// 	return pollArr[id]; 
	// }
	
	/**
	* @notice create poll for the community (DAO)
	*/
	function communityPollCreate(uint256 daoId, uint256 pollType, ProposeChanges memory proposedChanges
	) external returns(bool){
		require(community.proposalCreationRight(pollType, daoId, msg.sender) != false, "You dont have permission to create proposal"); //check wheather a member have a proposal creation rights
		_PollIds.increment();
		uint256 pollId = _PollIds.current();
		CommunityPoll memory poll = CommunityPoll(
			pollId,
			msg.sender, 
			PollStatus.ACTIVE,
			pollType,
			proposedChanges,
			block.timestamp,
			block.timestamp + 600,
			false
		);
		
		_pollData[pollId] = poll;
		uint256[] storage polls = _polls[daoId];
		polls.push(pollId);
		_polls[daoId] = polls;
		emit EvtCommunityPollCreate(pollId, block.timestamp, block.timestamp + 600);
		return true;
	}

	/**
	* @notice delete the community poll
	*/
	function communityPollDelete(uint256 pollId) external { 
		delete _polls[pollId];
		emit EvtCommunityPollDelete(pollId);
	}

	/**
	* @notice get votes details
	*/
	function getPollVotes(uint256 pollId) external view returns(uint256 agreed, uint256 reject){
		// PollVote[] memory pollVotes = _pollVotes[pollId];
		uint256[] memory voteIds = _votes[pollId];
		uint256 agreedVotesCount;
		uint256 rejectedVoteCount;
		for (uint256 index = 0; index < voteIds.length ; index++) {
			PollVote memory vote = _pollVotes[voteIds[index]];
			if(vote.vote){
				agreedVotesCount = agreedVotesCount + 1;
			}else {
				rejectedVoteCount = rejectedVoteCount + 1;
			}
		}
		return ( agreedVotesCount, rejectedVoteCount);
	}

	/**	
	* @notice compute poll result and return true or false
	*/
	function _computePollResult(uint256 communityId, uint256 pollId) internal returns(bool){
		
		CommunityPoll storage commPoll = pollFetch(pollId);
		
		require(commPoll.status != PollStatus.ENDED, "Poll is already ended.");
		
		uint256[] memory voteIds = _votes[pollId];
	
		uint256 agreedVotesCount;
		uint256 rejectedVoteCount;
		for (uint256 index = 0; index < voteIds.length ; index++) {
			PollVote memory vote = _pollVotes[voteIds[index]];
			if(vote.vote){
				agreedVotesCount = agreedVotesCount + 1;
			}else {
				rejectedVoteCount = rejectedVoteCount + 1;
			}
		}
		if(agreedVotesCount > rejectedVoteCount) { 
			commPoll.result = true;
			return true;
		}else {
			return false;
		}
	}

	/**
	* @notice proposed changes
	*/
	function _doProposedChanges(uint256 commId, uint256 pollId) external returns (bool) { 
		computeFlag.increment(); // change the state to put this function in writeable function list
		if(_computePollResult(commId, pollId)){
			// get the proposed changes and call
			CommunityPoll storage commPoll = pollFetch(pollId);
			
			// 1- [amount, targetAcc],
			// 2- [bountyAmount, availableClaims, daystoComplete]
			// 3- [proposedDaoName]
			// 4- [proposedPurpose]
			// 5- [links]
			// 6- [proposedCover, proposedLogo] 
			// 7- [proposedLegalStatus, proposedLegalDocs] 
			// 8- [bondsToCreateProposal, timeBeforeProposalExpires, bondsToClaimBounty, timeToUnclaimBounty] 
			// 9- [newGroupName, intialMemberAccount] 
			// 10- [targetGroupName, memberToAdd] 
			// 11- [targetGroupName, memberToRemove] 
			// 12-[] 
			// 13- [contractAddrFnCall, fnCallName, fnCallAbi]
			
			ProposeChanges memory proposechanges = commPoll.proposedChanges;
			bool res = false;
			
			if(commPoll._type == 1){
				res = community.transferBounty(proposechanges.amount, proposechanges.targetAcc, commId);

			}else if(commPoll._type == 2){
				res = community.createBounty(proposechanges.bountyAmount, proposechanges.availableClaims, proposechanges.daystoComplete, commId);

			}else if(commPoll._type == 3){
				res = community.changeName(proposechanges.proposedDaoName, commId);

			}else if(commPoll._type == 4){
				res = community.changePurpose(proposechanges.proposedPurpose, commId);

			}else if(commPoll._type == 5){
				res = community.changelinks(proposechanges.links, commId);

			}else if(commPoll._type == 6){
				res = community.changeLogoNCoverImage(proposechanges.proposedLogo, proposechanges.proposedCover, commId);

			}else if(commPoll._type == 7){
				res = community.changeLegalStatusNDoc(proposechanges.proposedLegalStatus, proposechanges.proposedLegalDocs, commId);
			
			}else if(commPoll._type == 8){
				res = community.changeBondAndDeadline(proposechanges.bondsToCreateProposal, proposechanges.timeBeforeProposalExpires, proposechanges.bondsToClaimBounty, proposechanges.timeToUnclaimBounty, commId);
		
			}else if(commPoll._type == 9){
				res = community.createGroup(proposechanges.newGroup, commId);
	
			}else if(commPoll._type == 10){
				res = community.addMemberToGroup(proposechanges.memberToAdd, proposechanges.targetGroupId, commId);

			}else if(commPoll._type == 11){
				res = community.removeMemberToGroup(proposechanges.memberToRemove, proposechanges.targetGroupId, commId);

			}else if(commPoll._type == 12){
				// noting to do for this type of proposal

			}else if(commPoll._type == 13){
				res = community.fnCall(proposechanges.contractAddrFnCall, proposechanges.fnCallName, proposechanges.fnCallAbi, commId);

			}else {}
			return res;
		}
	}

	function getCurrentTime() internal virtual view returns(uint256){
		return block.timestamp;
	}
}


/**
 * @title Status for community.
 * @notice Community Status for each community which limits available actions.
 */
enum CommunityStatus {
	ACTIVE,
	ABANDONED,
	SUSPENDED,
	INACTIVE,
	NOT_FOUND
}

/**
 * @title Community group - in which members will come
 * @notice
 */
struct Group { 
	uint256 id;
	string name;
	address[] members; //member address
	uint256[] proposalCreation;
	uint256[] voting;
}

/**
 * @title  
 * @notice is member of community of response 
 */
struct MemberOfCommRes {
	bool isMember;
	uint256 groupId;
	uint256[] proposalCreation;
	uint256[] voting;
}

/**
 * @title Community data format
 * @notice
 */
struct Community {
	uint256 id;
	CommunityStatus status;
	// uint256 [] GroupIds;
	uint256 createBlock;
	uint256 createTimestamp;
	address creator;

	// 	will add these later on
	string name;
	string purpose;
	string[] links;
	string cover;
	string logo;
	string legalStatus;
	string legalDocs;
	string bondsToCreateProposal;
	string timeBeforeProposalExpires;
	string bondsToClaimBounty;
	string timeToUnclaimBounty;
	uint balance;
}


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)




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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)




// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)



/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)




// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)



/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}




// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)



/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}



/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}



/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


/**
* @title polling and Voting interface 
*/
interface VotingPoll {
    function _computePollResult(uint256 communityId, uint256 pollId) external view returns(uint256 agreeVotes, uint256 rejectedVotes);
    // will add other function according to requirement
} 
/**
* @title erc20 token interface
*/
interface ERC20 {
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
} abstract contract Ownable is Context {
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

/** proposed changes 
1- [amount, targetAcc],
2- [bountyAmount, availableClaims, daystoComplete]
3- [proposedDaoName]
4- [proposedPurpose]
5- [links]
6- [proposedCover, proposedLogo] 
7- [proposedLegalStatus, proposedLegalDocs] 
8- [bondsToCreateProposal, timeBeforeProposalExpires, bondsToClaimBounty, timeToUnclaimBounty] 
9- [newGroupName, intialMemberAccount] 
10- [targetGroupName, memberToAdd] 
11- [targetGroupName, memberToRemove] 
12-[] 
13- [contractAddrFnCall, fnCallName, fnCallAbi] */

/**
 * @title DAO Controller
 * @author Michael Brich
 * @notice Primary controller handling DAO calls.
 */
contract ControllerMUTO is Initializable, UUPSUpgradeable, OwnableUpgradeable {

	using Counters for Counters.Counter;

    Counters.Counter private _CommunityIds;
    Counters.Counter private _Group;
    Counters.Counter private _MemberIds;

    address votingContractAddress;
    address tokenAddress;

    // Events to emit
	event EvtCommunityCreate( uint256 id, uint256[] groupIds);
	event EvtCommunitySuspend( string reason );
	event EvtCommunityUnsuspend( string reason );
	event EvtCreateGroup( uint256 groupId );

	mapping(uint256 => Community) private _communities; // _CommunityIds -> Community
    mapping(uint256 => Group[]) private _communityGroups; // _CommunityIds -> Group 
    
	/**
	 * @notice Address of the Proxy contract which delegates calls to this contract.
	 */
	address private _controllerProxy;
	/**
	 * @notice Flag indicating whether this contract is actively used by the Proxy Contract.
	 * Set to false after the Proxy Contract successfully completes an upgrade call and targets
	 * a new proxied contract.
	 */
	bool private _active;

	/**
	 * @notice Called once by the DAO Proxy contract to initialize contract values
	 * and properties. Only callable once during init.
	 */
	function initialize(address tokenAddr) public initializer {
		setControllerProxy(msg.sender);
        __Ownable_init();
        __UUPSUpgradeable_init();
        tokenAddress = tokenAddr;
	}

	function _authorizeUpgrade(address) internal override onlyOwner {}

	function activate() external onlyInitializing {
		_active = true;
	}

	function deactivate() external {
		_active = false;
	}

    /**
    * @notice set the voting contract address
    */
    function setVotingContractAddress(address votingContractAddr) external onlyOwner {
        votingContractAddress = votingContractAddr;
    }

    /**
    * @notice assert voting contract address 
    */
    function assertVotingContractAddr() internal returns(bool){
        if(msg.sender == votingContractAddress){
            return true;
        }else {
            return false;
        }
    }

	function fetchAssertCommunity(uint256 id, string memory errorMsg) internal view returns (Community storage) {
		Community storage comm = fetchCommunity(id);
		require(comm.id > 0, string(abi.encodePacked("Community Not Found - ", errorMsg)));

		return comm;
	}

	/**
	 * @notice Retrieve data for target community if it exists. Used internally by various calls to validate
	 * community status, permissions, etc.
	 */
	function fetchCommunity(uint256 id) internal view returns (Community storage) {
		Community storage comm = _communities[id];
		if (comm.createBlock < 1) {
			return comm;
		}

		return comm;
	}

	/**
	 * @notice Set the proxy contract address which will call this contract. Can only be
	 * set once during contract initialization.
	 * @param target	-	Address of proxy contract using this contract. Should only be set
	 *						once during contract init.
	 */
	function setControllerProxy(address target) internal initializer returns (bool) {
		_controllerProxy = target;

		return true;
	}

    /**
     * @notice check groups details of the particular dao
     */
    function communityGroupsDetail(uint256 daoId) public view returns(Group[] memory group) {
        Group[] storage groups = _communityGroups[daoId];
        return groups;
    }   

    /**
     * @notice check details of the dao
     */
    function communityDetail(uint256 daoId) public view returns(Community memory) {
		Community storage comm = _communities[daoId];
        return comm;
    }   


    /**
     * @notice create group of community and return array of id of the group
     */
    function createCommunityGroup(uint256 daoId, Group[] memory group) internal returns(uint256[] memory id) { 
        uint256[] memory groupIdsArr = new uint256[](group.length);
        for (uint256 index = 0; index < group.length; index++) {
            _Group.increment();
            uint256 groupId =  _Group.current();
            Group memory groupObj = Group(
                groupId,
                group[index].name,
                group[index].members, //this should be an array 
                group[index].proposalCreation, //permission
                group[index].voting //permission
            );
            Group[] storage groupArr = _communityGroups[daoId];
            groupArr.push(groupObj);
            groupIdsArr[index]= groupId;
        }           
        return groupIdsArr;
    }

	/**
	 * @notice Create a Freedom MetaDAO Community using the provided parameters. Caller becomes
	 * the first member and admin automatically if the action succeeds.
	 */
	 
	function communityCreate(string memory name, string memory purpose, string memory legalStatus, string memory legalDocuments, string[] memory links, Group[] memory group, string memory logoImage, string memory coverImage) external onlyProxy returns (bool) {
		_CommunityIds.increment();
        uint256 commId = _CommunityIds.current(); 
        uint256[] memory groupIdsArr;
        
        // if array of group is empty or not
        if(group.length >= 0){
            groupIdsArr = createCommunityGroup(commId, group);
        }

        // group ids for the community

		Community memory communityDetails = Community(
			commId,
			CommunityStatus.ACTIVE,
			// groupIdsArr,
			block.number,
			block.timestamp,
			msg.sender,
            name, // name 
            purpose, // purpose
            links, // links array
            coverImage, // coverImage
            logoImage, // logoImage
            legalStatus, // legalStatus
            legalDocuments, //legalDocuments
            "", // bonds to create proposal
            "", // timeBeforeProposalExpires
            "", // bondsToClaimBounty
            "",  // timeToUnclaimBounty
            0
		);
		_communities[commId] =  communityDetails;

		emit EvtCommunityCreate(commId, groupIdsArr);
        return true;
	}

    /**
     * @notice transfer a bounty
     */
    function transferBounty(uint256 _amount, address _targetAcc, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        require(comm.balance >= _amount, "Insufficient balance");
        ERC20(tokenAddress).transfer(_targetAcc, _amount);
        comm.balance = comm.balance - _amount;
        return true;
    }

    /**
     * @notice deposit amount to community 
     */
    function depositAmount(uint _amount, uint256 commId) external onlyProxy returns (bool) {
        // require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        // deposit amount
        ERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        comm.balance = comm.balance + _amount;
        return true;
    }

    /**
     * @notice create a bounty
     */
    function createBounty(string memory bountyAmount, uint256 availableClaims, uint256 daystoComplete, uint256 alreadyClaimed, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        // create bounty address 
        return true;
    }

    /**
     * @notice change the community name with proposed change
     */
    function changeName(string memory proposedDaoName, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        comm.name = proposedDaoName;
        return true;
    }

    /**
     * @notice change the community purpose description with proposed change
     */
    function changePurpose(string memory proposedPurpose, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        comm.purpose = proposedPurpose;
        return true;
    }

    /**
     * @notice change the community links with proposed change
     */
    function changelinks(string[] memory links, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        comm.links = links;
        return true;
    }

    /**
     * @notice change the community logo image with proposed change
     */
    function changeLogoNCoverImage(string memory logoImage, string memory coverImage, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        comm.logo = logoImage;
        comm.cover = coverImage;
        return true;
    }

    /**
     * @notice change the community legal status with proposed change
     */
    function changeLegalStatusNDoc(string memory legalStatus, string memory legalDocuments, uint256 commId) external onlyProxy returns (bool){
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        comm.legalStatus = legalStatus;
        comm.legalDocs = legalDocuments;
        return true;
    }
    
    /**
     * @notice add member to group - internal function
     */
    function addMemberToGroup(address addr, uint256 groupId, uint256 commId) external onlyProxy returns (bool){  
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Group[] storage group = _communityGroups[commId];
        for (uint256 index = 0; index < group.length; index++) {
            if(group[index].id == groupId){
                address[] storage members = group[index].members;
                 members.push(addr);   
            }
        }
        return true;
    }

    /**
     * @notice remove member from group - internal function
     */
    function removeMemberToGroup(address addr, uint256 groupId, uint256 commId) external onlyProxy returns (bool){  
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        bool isRemoved = false;
        Group[] storage group = _communityGroups[commId];

        for (uint256 index = 0; index < group.length; index++) {
            if(group[index].id == groupId){
                address[] storage members = group[index].members;
                for (uint256 j = 0; j < members.length; j++) {
                    if(members[j] == addr){
                        members[index] = address(0);
                        isRemoved = true; 
                    }
                }
            }
        }
        return isRemoved; 
    }

    /**
    * @notice claim bounty
     */
    //  bountyProposedChanges.bountyAmount, msg.sender, commId
    function claimBounty(uint256 bountyAmount, address _targetAcc, uint256 commId) external onlyProxy returns (bool) {
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        Community storage comm = fetchAssertCommunity(commId, "Comm: Doesn't exist");
        require(comm.balance >= bountyAmount, "Insufficient balance");
        ERC20(tokenAddress).transfer(_targetAcc, bountyAmount);
        comm.balance = comm.balance - bountyAmount;
        return true;
    }

    /* @notice create group
    */
    function createGroup(Group memory newGroup, uint256 commId) external onlyProxy returns (bool) {
        require(assertVotingContractAddr() == true, "Unauthorized user.");
        fetchAssertCommunity(commId, "Comm: Doesn't exist");
        // create group in particular community
        _Group.increment();
        uint256 groupId =  _Group.current();
        Group memory groupObj = Group(
            groupId,
            newGroup.name,
            newGroup.members, //this should be an array 
            newGroup.proposalCreation, //permission
            newGroup.voting //permission
        );
        Group[] storage groups = _communityGroups[commId];
        groups.push(groupObj);
        emit EvtCreateGroup(groupId);
        return true;
    }
    
	/**
	* @notice Is member of that community
	*/
	function isMemberOfCommunity(uint256 commId, address senderAddr) internal view returns (MemberOfCommRes memory){
        MemberOfCommRes memory res;
        res.isMember = false;
        res.groupId = 0; 
        Group[] memory groups = _communityGroups[commId];
        for (uint256 i = 0; i < groups.length; i++) {
            address[] memory memberAddr = groups[i].members;
            for (uint256 j = 0; j < memberAddr.length; j++) {
                if( memberAddr[j] == senderAddr ){
                    res.isMember = true;
                    res.groupId = groups[i].id;
                    res.proposalCreation = groups[i].proposalCreation;
                    res.voting = groups[i].voting;
                    return res;
                }
            }
        }
        return res;
	}

    /**
    * @notice Do member have proposal creation rights
    */
    function proposalCreationRight(uint256 _type, uint256 commId, address senderAddr) external view returns (bool) {        
        bool haveRights = false;
        Group[] memory groups = _communityGroups[commId];
        for (uint256 i = 0; i < groups.length; i++) {
            address[] memory memberAddr = groups[i].members;
            for (uint256 j = 0; j < memberAddr.length; j++) {
                if( memberAddr[j] == senderAddr ){
                    for (uint256 k = 0; k < groups[i].proposalCreation.length; k++) {
                        if(_type == groups[i].proposalCreation[k]){
                            haveRights = true;
                            return haveRights;
                        }
                    }
                }
            }
        }
        return haveRights;
    }

    /**
    * @notice Do member have voting rights on proposal
    */
    function votingRight(uint256 _type, uint256 commId, address senderAddr) external view returns (bool) {        
        bool haveRights = false;
        Group[] memory groups = _communityGroups[commId];
        for (uint256 i = 0; i < groups.length; i++) {
            address[] memory memberAddr = groups[i].members;
            for (uint256 j = 0; j < memberAddr.length; j++) {
                if( memberAddr[j] == senderAddr ){
                    for (uint256 k = 0; k < groups[i].voting.length; k++) {
                        if(_type == groups[i].voting[k]){
                            haveRights = true;
                            return haveRights;
                        }
                    }
                }
            }
        }
        return haveRights;
    }
}