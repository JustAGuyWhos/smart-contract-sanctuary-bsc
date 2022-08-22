/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: contracts/lib/IdoggyVilleNft.sol

pragma solidity ^0.8.0;



interface IdoggyVilleNft is IERC721{

    /// @notice Returns all the relevant information about a specific doggy.
    /// @param _id The ID of the doggy of interest.
   function getDoggy(uint256 _id)
        external
        view
        returns (
        bool isReady,
        uint256 birthTime,
        uint256 mareId,
        uint256 stallionId,
        uint256 generation,
        uint256 gender,
        uint256 totalOffSpring
    ) ;
  
}

// File: contracts/doggyVilleRace.sol

pragma solidity ^0.8.0;



contract doggyVilleRace is Ownable {

    enum RaceStatus { Begun, Ended, Canceled }
    // All the needed info about race
    struct race {
        uint256 cost; // Cost per member.0 means free race.
        uint256 totalAmount; // Total amount.
        uint256[12] contestant; // Total Participants.
        uint32[12] winners; // The winning doggyIds.
        uint8 count; // Total participants count
        RaceStatus status;  // Race status 
        uint256 level; // 6.(initial level) 5.class5 (0-20) 4.class4 (21-40) 3.class3 (41-60)
                        // 2.class2(61-80) 1.class1 (81 above)
    }
    // All the needed info about doggy
    struct doggy {
        uint256 rating;
        uint256 raceID; // After this doggy can participte in other race
        // initially 0
    }

    mapping(uint256 => race) public raceInfo;
    // doggyId => rating and time
    mapping(uint256 => doggy) public doggyInfo;
    // raceId => winnerof race
    mapping(uint256 => mapping(uint256 => bool)) public winnerInfo;
    // Instance of token (collateral currency for race)
    IERC20 public token;
    // Instance of token
    IdoggyVilleNft public nftToken;
    // Total race counter
    uint256 public totalRace;
    // Winning percentages
    uint32[3] public pcent = [60, 25, 15];
    // The gasFee amount receiving address
    address public organizer;
    uint256 public fee = 10; // 10%
    // responsible for announcing result
    address public operator;
    uint256 public points = 2; // negative points
    // Event details
    event Race(uint256 raceId, uint256 levelType, uint256 totalRaceAmount);
    event EnterRace(
        uint256 raceID,
        uint256 tokenId,
        uint256 index,
        address caller
    );
    event RaceResult(uint256 raceId, uint256 timestamp, uint32[3] winnerIndex);
    event SetOrganizer(address _newOrganizer);
    event SetOperator(address _addr);
    event SetPoints(uint256 newPoints);
    event CancelRace(uint256 _raceId);
    event ReFunded(uint256 raceId, uint256 doggyId, uint256 amount, address receiver);

    constructor(
        IERC20 _token,
        IdoggyVilleNft _nftToken,
        address _organizer,
        address _operator
    ) {
        token = _token;
        nftToken = _nftToken;
        organizer = _organizer;
        operator = _operator;
        emit SetOperator(_operator);
        emit SetOrganizer(_organizer);
    }

    modifier isRaceExist(uint256 _raceId) {
        require((_raceId > 0) && (_raceId <= totalRace), "Race is not exist");
        require( (raceInfo[_raceId].count < 12), "Race filled"  );

        require(
           raceInfo[_raceId].status ==  RaceStatus.Begun, "Race must be started"
        );
        _;
    }

    modifier isdoggyEligible(uint256 _tokenId) {
        require(nftToken.ownerOf(_tokenId) == msg.sender, "Invalid doggy");
        require(
            (doggyInfo[_tokenId].raceID == 0) ||
                (raceInfo[doggyInfo[_tokenId].raceID].status == RaceStatus.Ended
                    || raceInfo[doggyInfo[_tokenId].raceID].status == RaceStatus.Canceled
                ),
            "Already participated"
        );
        _;
    }

    modifier isOwnerOrOperator(){
        require( (owner() == msg.sender) || (operator == msg.sender) , "owner or operator");
        _;
    }

    function createNewRace(
        uint256 _cost,
        uint256 _totalAmount,
        uint256 _level
    ) external isOwnerOrOperator {
        require(
            (_totalAmount > 0),
            "Invalid amount"
        );
        require((_level <= 6), "Invalid level");

        totalRace++;
        uint256 raceId = totalRace;
        raceInfo[raceId].cost = _cost;
        raceInfo[raceId].totalAmount = _totalAmount;
        raceInfo[raceId].level = _level;
        raceInfo[raceId].status = RaceStatus.Begun; 

        emit Race(raceId, _level, _totalAmount);
    }

    function enterRace(
        uint256 _raceId,
        uint256 _index,
        uint256 _tokenId
    ) external isRaceExist(_raceId) isdoggyEligible(_tokenId) {
        require(isEligible(_tokenId, raceInfo[_raceId].level), "Not eligible");
        require(
            (_index < 12) && (raceInfo[_raceId].contestant[_index] == 0),
            "Invalid index"
        );

        _safeTransferFrom(msg.sender, address(this), raceInfo[_raceId].cost);

        raceInfo[_raceId].contestant[_index] = _tokenId;
        doggyInfo[_tokenId].raceID = _raceId;
        raceInfo[_raceId].count++;

        emit EnterRace(_raceId, _tokenId, _index, msg.sender);
    }
// 6.(initial level) 5.class5 (0-20) 4.class4 (21-40) 3.class3 (41-60)
                        // 2.class2(61-80) 1.class1 (81 above)
    function isEligible(uint256 _tokenId, uint256 _level)
        internal
        view
        returns (bool)
    {
        if (_level == 0) {
            return true;
        } else if (_level == 1) {
            if (doggyInfo[_tokenId].rating > 81) {
                return true; 
                
            } else {
                return false;
            }
        } else if (_level == 2) {
            if (
                (doggyInfo[_tokenId].rating >= 61) &&
                (doggyInfo[_tokenId].rating <= 80)
            ) {
                return true;
            } else {
                return false;
            }
        } else if (_level == 3) {
            if (
                (doggyInfo[_tokenId].rating >= 41) &&
                (doggyInfo[_tokenId].rating <= 60)
            ) {
                return true;
            } else {
                return false;
            }
        } else if (_level == 4) {
            if( (doggyInfo[_tokenId].rating >= 21) &&
                (doggyInfo[_tokenId].rating <= 40) ) {
                return true;
            } else {
                return false;
            }
        } else if (_level == 5) {
            if( (doggyInfo[_tokenId].rating > 0) &&
                (doggyInfo[_tokenId].rating <= 20) ) {
                return true;
            } else {
                return false;
            }
        } else if (_level == 6) {
            if(doggyInfo[_tokenId].rating == 0) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function announceRaceResult(uint256 _raceId,uint32[12] memory result) external isOwnerOrOperator {

        require(raceInfo[_raceId].status ==  RaceStatus.Begun, "Race  must be started");
        require(raceInfo[_raceId].count == 12, "race not filled yet");

        //uint32[12] memory result;
       
        raceInfo[_raceId].winners = result;
        uint256 totalAmount = raceInfo[_raceId].totalAmount;
        uint32[3] memory _pcent = pcent;

        if(fee > 0){           
            _safeTransfer(organizer, ((totalAmount * fee) / 100));
            totalAmount = totalAmount - ((totalAmount * fee) / 100);          
        }
        _safeTransfer(
            nftToken.ownerOf(result[0]),
            ((totalAmount * _pcent[0]) / 100)
        );
        _safeTransfer(
            nftToken.ownerOf(result[1]),
            ((totalAmount * _pcent[1]) / 100)
        );
        _safeTransfer(
            nftToken.ownerOf(result[2]),
            ((totalAmount * _pcent[2]) / 100)
        );

        setRating(_raceId);
        raceInfo[_raceId].status = RaceStatus.Ended;

        emit RaceResult(_raceId, block.timestamp, [result[0],result[1],result[2]]);
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(token.transferFrom(_from, _to, _value), "transferFrom failed");
    }

    function _safeTransfer(address _to, uint256 _value) private {
        require(token.transfer(_to, _value), "transferFrom failed");
    }

    function setRating(uint256 _raceId) internal {
        if (raceInfo[_raceId].level == 6) {
            initialLevel(_raceId);
        } else {
            updateRating(_raceId);
        }
    }

    function initialLevel(uint256 _raceId) internal {
        uint256 tokenId;
        for (uint256 i = 0; i < 12; i++) {
            tokenId = raceInfo[_raceId].contestant[i];
            doggyInfo[tokenId].rating = genRating(tokenId);
           
        }
       
        updateRating(_raceId);
    }

    function updateRating(uint256 _raceId) internal {
        uint32[12] memory result = raceInfo[_raceId].winners;
     

        doggyInfo[result[0]].rating = doggyInfo[result[0]].rating + 6;
        doggyInfo[result[1]].rating = doggyInfo[result[1]].rating + 4;
        doggyInfo[result[2]].rating = doggyInfo[result[2]].rating + 2;
       
        for(uint i=6; i<12; i++){
           
            if(doggyInfo[result[i]].rating < points){
              
                doggyInfo[result[i]].rating = 0;
            }else {
               
                doggyInfo[result[i]].rating = doggyInfo[result[i]].rating - points;
            }
        }
    }

    function genRating(uint256 tokenId) internal view returns (uint256) {
        if (getGen(tokenId) <= 4) {
           
            return 57;
        } else if (getGen(tokenId) <= 9) {
           
            return 37;
        } else {
            
            return 17;
        }
    }

    function getGen(uint256 _tokenId)
        internal
        view
        returns (uint256 generation)
    {
        (, , , , generation,,) = nftToken.getDoggy(_tokenId);
    }

    function raceDetaild(uint256 raceId) external view returns (race memory) {
        return raceInfo[raceId];
    }

    function setOrganizer(address _addr) external onlyOwner{
        organizer = _addr;
        emit SetOrganizer(_addr);
    }

    function setOperator(address _addr) external onlyOwner{
        operator = _addr;
        emit SetOperator(_addr);
    }

    function setPoints(uint256 _points) external onlyOwner{
        points = _points;
        emit SetPoints(_points);
    }

    function cancelRace(uint256 _raceId) external onlyOwner isRaceExist(_raceId){
        raceInfo[_raceId].status = RaceStatus.Canceled;
        emit CancelRace(_raceId);
    }

    function getReFund(uint256 _raceId, uint256 _participationIndex, uint256 _tokenId) external {
        require(
           raceInfo[_raceId].status ==  RaceStatus.Canceled, "Race not closed"
        );

        require( raceInfo[_raceId].contestant[_participationIndex] == _tokenId, "Not participated");

        require(nftToken.ownerOf(_tokenId) == msg.sender, "Invalid doggy owner");
        raceInfo[_raceId].contestant[_participationIndex] = 0;
        _safeTransfer(msg.sender, raceInfo[_raceId].cost);

        emit ReFunded(_raceId, _tokenId, raceInfo[_raceId].cost ,msg.sender);
    }


}