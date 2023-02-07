/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
	uint256 bountyAmount;
	uint256 availableClaims;
	uint256 daystoComplete; // after these day nobody can claim whatever the situation is
	uint256 alreadyClaimed; //how many claimed are done
	string proposedDaoName;
	string proposedPurpose;
	string[] links;
	string proposedCover;
	string proposedLogo;
	string proposedLegalStatus;
	string proposedLegalDocs;
	uint256 bountyId;
	// string bondsToCreateProposal;
	// string timeBeforeProposalExpires;
	// string bondsToClaimBounty;
	// string timeToUnclaimBounty;
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
	APPROVED,
	FAILED,
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
	// function createBounty(uint256 bountyAmount, uint256 availableClaims, uint256 daystoComplete, uint256 alreadyClaimed, uint256 commId) external returns (bool);
	function claimBounty(uint256 bountyAmount, address _targetAcc, uint256 commId) external returns (bool);
	function changeName(string memory name, uint256 commId) external returns (bool);
	function changePurpose(string memory purpose, uint256 commId) external returns (bool);
	function changelinks(string[] memory links, uint256 commId) external returns (bool);
	function changeLogoNCoverImage(string memory logoImage, string memory coverImage, uint256 commId) external returns (bool);
	function changeLegalStatusNDoc(string memory legalStatus, string memory legalDocuments, uint256 commId) external returns (bool);
	// function changeBondAndDeadline(string memory bond, string memory expiry, string memory bountyClaim, string memory timeToUnclaimFree, uint256 commId) external returns (bool);
	function createGroup(Group memory newGroup, uint256 commId) external returns (bool);
	function addMemberToGroup(address addr, uint256 groupId, uint256 commId) external returns (bool);
	function removeMemberToGroup(address addr, uint256 groupId, uint256 commId) external returns (bool);
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
		CommunityPoll memory poll = pollFetch(pollId);
		//check wheather a member have a voting rights or not voted before
		require(isAlreadyVoted(pollId) != true, "You already voted.");
		require(poll.endTimeStamps > block.timestamp, "You cant vote because proposal time is ended.");
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
	function pollFetch(uint256 id) public view returns ( CommunityPoll memory ){

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
		if(pollType == 8){
			CommunityPoll memory bountyPoll = pollFetch(proposedChanges.bountyId);
			require(bountyPoll.status == PollStatus.APPROVED, "Poll: Bounty failed, we can't move forward.");
		}
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
		
		CommunityPoll memory commPoll = pollFetch(pollId);
		
		require(commPoll.status != PollStatus.ENDED || commPoll.status != PollStatus.APPROVED || commPoll.status != PollStatus.FAILED, "Poll is already ended.");
		
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
			commPoll.status = PollStatus.FAILED;
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
			CommunityPoll memory commPoll = pollFetch(pollId);
			
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
				// res = community.createBounty(proposechanges.bountyAmount, proposechanges.availableClaims, proposechanges.daystoComplete, proposechanges.alreadyClaimed, commId);

			}
			else if(commPoll._type == 3){
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
				CommunityPoll memory bountyPoll = pollFetch(proposechanges.bountyId);
				ProposeChanges memory bountyProposedChanges = bountyPoll.proposedChanges;
				require(commPoll.status == PollStatus.APPROVED, "Poll: Bounty failed, we can't move forward.");
				if(bountyProposedChanges.alreadyClaimed < bountyProposedChanges.availableClaims){
					res = community.claimBounty(bountyProposedChanges.bountyAmount, msg.sender, commId );
					bountyProposedChanges.alreadyClaimed  = bountyProposedChanges.alreadyClaimed + 1;
				}
			}else if(commPoll._type == 9){
				res = community.createGroup(proposechanges.newGroup, commId);
	
			}else if(commPoll._type == 10){
				res = community.addMemberToGroup(proposechanges.memberToAdd, proposechanges.targetGroupId, commId);

			}else if(commPoll._type == 11){
				res = community.removeMemberToGroup(proposechanges.memberToRemove, proposechanges.targetGroupId, commId);

			}else if(commPoll._type == 12){
				// noting to do for this type of proposal

			}else if(commPoll._type == 13){
			}else {}
			commPoll.status = PollStatus.ENDED;
			return res;
		}
	}
}