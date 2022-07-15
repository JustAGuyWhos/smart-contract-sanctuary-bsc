/**
 *Submitted for verification at BscScan.com on 2022-07-14
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

// File: PYEGovernance/contracts/Governor.sol



pragma solidity ^0.8.14;


interface IGov is IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function snapshot() external;

    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);

    function getCurrentSnapshotId() external view returns (uint256);

}

contract PYEGov{

    address public tokenaddress;

    //address factory = 0x2Ac164e7D2B38e4f853FEC79e2bFd453E1B3201C;

    struct Proposal{

        uint256 createdtime;

        uint256 endtime;

        uint256 votesreceived;

        uint256 votesfor;

        uint256 votesagainst;

        mapping(address => bool) voted; 

        string proposal;

        uint256 snapId;

    }

    mapping(uint256 => Proposal) public propID;

    struct Weights{

        mapping(address => uint256) delegated;

        address[] delegators;

        uint256 votes;
    } 

    mapping(address => Weights) public weight;

    bool snap;

    bool inited;

    uint256 currprop = 0;

    event initialize(address token);

    event newproposal(uint256, string);

    event Vote(bool, uint256);

    function getWeight(uint256 _prop) internal {

        if(snap){
        
            weight[msg.sender].votes = IGov(tokenaddress).balanceOfAt(msg.sender, propID[_prop].snapId);
        
        }
        else{
        
            weight[msg.sender].votes = IGov(tokenaddress).balanceOf(msg.sender);
        
        }
    }

    function getSupply(uint256 id) internal view returns (uint256){
        
        uint256 sup;
        
        if(snap){
        
            sup = IGov(tokenaddress).totalSupplyAt(id);
        
        }
        else{
        
            sup = IGov(tokenaddress).totalSupply();
        
        }

        return sup;
    }

    function issnap() external view returns(bool){
        return snap;
    }

    function vote(bool myvote, uint256 prop) public {
        require( propID[prop].endtime > block.timestamp, "Voting ended" );
        
        require( propID[prop].voted[msg.sender]!= true, "Already voted");

       if(weight[msg.sender].delegators.length > 0){

            removemydelegators();

        }

        getWeight(prop);

        if(myvote){
        
            propID[prop].votesfor = weight[msg.sender].votes;
        
            propID[prop].votesreceived = weight[msg.sender].votes;
        
        } else {
        
            propID[prop].votesagainst = weight[msg.sender].votes;

            propID[prop].votesreceived = weight[msg.sender].votes;
        
        }
        
        propID[prop].voted[msg.sender] = true;
        
        emit Vote(myvote, prop);
    }

    function initprop(string memory propmsg, uint256 _endtime) public {
        IGov(tokenaddress).snapshot();
    
        uint256 sessionSnap = IGov(tokenaddress).getCurrentSnapshotId();
        
        uint256 wt;

        if(weight[msg.sender].delegators.length > 0){

            combineWeight();

        } else {

            weight[msg.sender].votes = 0;

        }

        if(snap) {
    
            wt = IGov(tokenaddress).balanceOfAt(msg.sender, sessionSnap);
    
            weight[msg.sender].votes += wt;
    
        } else {
    
            wt = IGov(tokenaddress).balanceOf(msg.sender);
    
            weight[msg.sender].votes += wt;
        }

        uint256 ts = getSupply(sessionSnap);

        require(wt > (ts/100) , "Need 1% to submit prop");

        currprop++;

        propID[currprop].proposal = propmsg;

        propID[currprop].votesfor += weight[msg.sender].votes;

        propID[currprop].votesreceived += weight[msg.sender].votes;

        propID[currprop].voted[msg.sender] = true;

        propID[currprop].snapId = sessionSnap;

        propID[currprop].createdtime = block.timestamp;

        propID[currprop].endtime = block.timestamp + _endtime;
        
        if(weight[msg.sender].delegators.length > 0){

            removemydelegators();

        }

        emit newproposal(currprop , propmsg);
  
    }


    function init(address tokenaddr, bool selsnap)external{
        require( !inited , "only factory can initialize");
        
        currprop = 0;
        
        snap = selsnap;
        
        tokenaddress = tokenaddr;
        
        inited = true;
        
        emit initialize(tokenaddress);
    }

    function delWeight(address del)public{
    
        getWeight(currprop);

        weight[del].delegated[msg.sender] = weight[msg.sender].votes;

        weight[del].delegators[weight[msg.sender].delegators.length] = msg.sender;

        weight[msg.sender].votes = 0;
    }

    function combineWeight() internal {

        weight[msg.sender].votes = 0;

        uint i = 0;

        for(i = 0; i < weight[msg.sender].delegators.length ; i++){

            address del;

            del = weight[msg.sender].delegators[i];

            weight[msg.sender].votes += weight[msg.sender].delegated[del];
            
        }

    }
    
    function removemydelegators() internal {
        
        uint i = 0;
        
        for(i = 0; i < weight[msg.sender].delegators.length ; i++){

            address del;

            del = weight[msg.sender].delegators[i];

            weight[msg.sender].votes -= weight[msg.sender].delegated[del];

            weight[del].votes = weight[msg.sender].delegated[del];
            
            propID[currprop].voted[del] = true;
            
            weight[msg.sender].delegators[i] = address(0x0);
            
        }
    }

    function getstats(uint256 _prop) external view returns(uint256 ctime, uint256 etime, uint256 vfor, uint256 vagainst, uint256 vreceived){
        
        return(propID[_prop].createdtime , propID[_prop].endtime , propID[_prop].votesfor , propID[_prop].votesagainst , propID[_prop].votesreceived);
    
    }


}