// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/ICOW721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import  "../interface/IPlanet.sol";
import "../interface/ICattle1155.sol";
import "../interface/IMating.sol";
import "../interface/Iprofile_photo.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "../interface/ICompound.sol";
import "../interface/IMarket.sol";
import "../interface/IMail.sol";
import "../interface/ITec.sol";
contract Info is OwnableUpgradeable{

    using StringsUpgradeable for uint256;
    ICOW public cattle;
    IPlanet public planet;
    ICattle1155 public item;
    IStable public stable;
    IMating public mating;
    IProfilePhoto public avatar;
    //------------------------
    ICompound public compound;
    IMilk public milk;
    IMarket public market;
    IMail public mail;
    ITec public tec;
    function initialize() public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
    }
    
    function setCattle(address addr_) external onlyOwner{
        cattle = ICOW(addr_);
    }

    function setTec(address addr) external onlyOwner{
        tec = ITec(addr);
    }
    
    function setPlanet(address addr_) external onlyOwner {
        planet = IPlanet(addr_);
    }
    
    function setItem(address addr_) external onlyOwner {
        item = ICattle1155(addr_);
    }
    
    function setStable(address addr_) external onlyOwner {
        stable = IStable(addr_);
    }
    
    function setMating(address addr) external onlyOwner{
        mating = IMating(addr);
    }

    function setProfilePhoto(address addr) external onlyOwner{
        avatar = IProfilePhoto(addr);
    }
    
    function setCompound(address addr) external onlyOwner{
        compound = ICompound(addr);
    }
    
    function setMilk(address addr) external onlyOwner{
        milk = IMilk(addr);
    }
    
    function setMail(address addr) external onlyOwner{
        mail = IMail(addr);
    }
    
    function bullPenInfo(address addr_) external view returns(uint,uint,uint,uint[] memory) {
        (uint stableAmount ,uint exp) = stable.userInfo(addr_);
        return(stableAmount,exp,stable.getStableLevel(addr_),stable.checkUserCows(addr_));
    }
    
    function cowInfoes(uint tokenId) external view returns(uint[23] memory info1,bool[3] memory info2, uint[2] memory parents){
        info2[0] = cattle.isCreation(tokenId);
        info2[1] = stable.isUsing(tokenId);
        info2[2] = cattle.getAdult(tokenId);
        info1[0] = cattle.getGender(tokenId);
        info1[1] = cattle.getBronTime(tokenId);
        info1[2] = cattle.getEnergy(tokenId);
        info1[3] = cattle.getLife(tokenId);
        info1[4] = cattle.getGrowth(tokenId);
        info1[5] = 0;
        info1[6] = cattle.getAttack(tokenId);
        info1[7] = cattle.getStamina(tokenId);
        info1[8] = cattle.getDefense(tokenId);
        info1[9] = cattle.getMilk(tokenId);
        info1[10] = cattle.getMilkRate(tokenId);
        info1[11] = cattle.getStar(tokenId);
        info1[12] = cattle.deadTime(tokenId);
        info1[13] = stable.energy(tokenId);
        info1[14] = stable.grow(tokenId);
        info1[15] = stable.refreshTime();
        info1[16] = stable.growAmount(info1[15],tokenId);
        info1[17] = stable.feeding(tokenId);
        info1[18] = mating.matingTime(tokenId);
        info1[19] = mating.lastMatingTime(tokenId);
        info1[20] = compound.starExp(tokenId);
        info1[21] = cattle.creationIndex(tokenId);
        info1[22] = mating.checkMatingTime(tokenId);
        parents = cattle.getCowParents(tokenId);
    }
    
    function _checkUserCows(address player) internal view returns(uint male,uint female,uint creation){
        uint[] memory list1 = cattle.checkUserCowListType(player,true);
        uint[] memory list2 = cattle.checkUserCowList(player);
        creation = list1.length;
        for(uint i = 0; i < list2.length; i ++){
            if(cattle.getGender(list2[i]) == 1){
                male ++;
            }else{
                female ++;
            }
        }
        uint[] memory list3 = stable.checkUserCows(player);
        for(uint i = 0; i < list3.length; i ++){
            if(cattle.isCreation(list3[i])){
                creation ++;
            }
            if (cattle.getGender(list3[i]) == 1){
                male ++;
            }else{
                female ++;
            }
        }
    }
    
    function userCenter(address player) external view returns(uint[10] memory info){
        (info[0],info[1],info[2]) = _checkUserCows(player);
        info[3] = stable.getStableLevel(player);
        (,info[4]) = stable.userInfo(player);
        if(info[3] >= 5){
            info[5] = 0;
        }else{
            info[5] = stable.levelLimit(info[3]);
        }
        
        info[6] = mating.userMatingTimes(player);
        info[7] = planet.getUserPlanet(player);
        (info[9],info[8]) = coutingCoin(player);
    }
    
    function coutingCoin(address addr) internal view returns(uint bvg_, uint bvt_){
        bvg_ += mail.bvgClaimed(addr);
        bvt_ += mail.bvtClaimed(addr);
        (,uint temp) = milk.userInfo(addr);
        bvt_ += temp;
    }
    
    function compoundInfo(uint tokenId, uint[] memory targetId) external view returns(uint[5] memory info){
        info[0] = compound.upgradeLimit(cattle.getStar(tokenId));
        if(targetId.length == 0){
            return info;
        }
        uint star = cattle.getStar(tokenId);
        info[1] = cattle.starLimit(star);
        if (star <3){
            info[2] = cattle.starLimit(star +1);
        }
        for(uint i = 0 ;i < targetId.length; i ++){
            info[3] += cattle.deadTime(targetId[i]) - block.timestamp;
        }
        uint life = cattle.getLife(tokenId);
        uint newDeadTime = block.timestamp + (35 days * life / 10000);
        if (newDeadTime > cattle.deadTime(tokenId)){
            info[4] = newDeadTime - cattle.deadTime(tokenId);
        }else{
            info[4] = 0;
        }
        
        
    }


    function checkCreation(uint[] memory list) internal view returns(uint[] memory){
        uint amount;
        for(uint i = 0; i < list.length; i ++){
            if (cattle.isCreation(list[i])){
                amount++;
            }
        }
        uint[] memory list2 = new uint[](amount);
        amount = 0;
        for(uint i = 0; i < list.length; i ++){
            if (cattle.isCreation(list[i])){
                list2[amount] = list[i];
                amount++;
            }
        }
        return list2;
    }
    
    function compoundList(uint[] memory list1, uint[] memory list2) internal pure returns(uint[] memory){
        uint[] memory list = new uint[](list1.length + list2.length);
        for(uint i = 0; i < list1.length; i ++){
            list[i] = list1[i];
        }
        for(uint i = 0; i < list2.length; i ++){
            list[list1.length + i] = list2[i];
        }
        return list;
    }
    
    function battleInfo(uint tokenId)external view returns(uint[3] memory info,bool isDead, address owner_){
        owner_ = stable.CattleOwner(tokenId);
        info[0] = cattle.getAttack(tokenId) * tec.checkUserTecEffet(owner_,4002) / 1000;
        info[1] = cattle.getStamina(tokenId)* tec.checkUserTecEffet(owner_,4001) / 1000;
        info[2] = cattle.getDefense(tokenId)* tec.checkUserTecEffet(owner_,4003) / 1000;

        isDead = block.timestamp > cattle.deadTime(tokenId);

    }
    function getUserProfilePhoto(address addr_) public view returns(string[] memory) {
        uint l;
        uint index;
        // 1.bovine hero
        uint[] memory list1 = checkCreation(stable.checkUserCows(addr_));
        uint[] memory list2 = cattle.checkUserCowListType(addr_, true);

        uint []memory bovineHeroPhoto = compoundList(list1,list2);
        l += bovineHeroPhoto.length;

        // 2.profile photo
        uint []memory profilePhoto = avatar.getUserPhotos(addr_);
        l += profilePhoto.length;

        string[] memory profileIcons = new string[](l);
        for (uint i = 0;i < bovineHeroPhoto.length; i++) {
            profileIcons[index] = (string(abi.encodePacked("Bovine Hero #",bovineHeroPhoto[i].toString())));
            index++;
        }
        for (uint i = 0;i < profilePhoto.length; i++) {
            profileIcons[index] = (string(abi.encodePacked(profilePhoto[i].toString())));
            index++;
        }


        return profileIcons;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICOW {
    function getGender(uint tokenId_) external view returns (uint);

    function getEnergy(uint tokenId_) external view returns (uint);

    function getAdult(uint tokenId_) external view returns (bool);

    function getAttack(uint tokenId_) external view returns (uint);

    function getStamina(uint tokenId_) external view returns (uint);

    function getDefense(uint tokenId_) external view returns (uint);

    function getPower(uint tokenId_) external view returns (uint);

    function getLife(uint tokenId_) external view returns (uint);

    function getBronTime(uint tokenId_) external view returns (uint);

    function getGrowth(uint tokenId_) external view returns (uint);

    function getMilk(uint tokenId_) external view returns (uint);

    function getMilkRate(uint tokenId_) external view returns (uint);
    
    function getCowParents(uint tokenId_) external view returns(uint[2] memory);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function mintNormall(address player, uint[2] memory parents) external;

    function mint(address player) external;

    function setApprovalForAll(address operator, bool approved) external;

    function growUp(uint tokenId_) external;

    function isCreation(uint tokenId_) external view returns (bool);

    function burn(uint tokenId_) external returns (bool);

    function deadTime(uint tokenId_) external view returns (uint);

    function addDeadTime(uint tokenId, uint time_) external;

    function checkUserCowListType(address player,bool creation_) external view returns (uint[] memory);
    
    function checkUserCowList(address player) external view returns(uint[] memory);
    
    function getStar(uint tokenId_) external view returns(uint);
    
    function mintNormallWithParents(address player) external;
    
    function currentId() external view returns(uint);
    
    function upGradeStar(uint tokenId) external;
    
    function starLimit(uint stars) external view returns(uint);
    
    function creationIndex(uint tokenId) external view returns(uint);
    
    
}

interface IBOX {
    function mint(address player, uint[2] memory parents_) external;

    function burn(uint tokenId_) external returns (bool);

    function checkParents(uint tokenId_) external view returns (uint[2] memory);

    function checkGrow(uint tokenId_) external view returns (uint[2] memory);

    function checkLife(uint tokenId_) external view returns (uint[2] memory);
    
    function checkEnergy(uint tokenId_) external view returns (uint[2] memory);
}

interface IStable {
    function isStable(uint tokenId) external view returns (bool);
    
    function rewardRate(uint level) external view returns(uint);

    function isUsing(uint tokenId) external view returns (bool);

    function changeUsing(uint tokenId, bool com_) external;

    function CattleOwner(uint tokenId) external view returns (address);

    function getStableLevel(address addr_) external view returns (uint);

    function energy(uint tokenId) external view returns (uint);

    function grow(uint tokenId) external view returns (uint);

    function costEnergy(uint tokenId, uint amount) external;
    
    function addStableExp(address addr, uint amount) external;
    
    function userInfo(address addr) external view returns(uint,uint);
    
    function checkUserCows(address addr_) external view returns (uint[] memory);
    
    function growAmount(uint time_, uint tokenId) external view returns(uint);
    
    function refreshTime() external view returns(uint);
    
    function feeding(uint tokenId) external view returns(uint);
    
    function levelLimit(uint index) external view returns(uint);
    
    function compoundCattle(uint tokenId) external;

}

interface IMilk{
    function userInfo(address addr) external view returns(uint,uint);
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICattle1155 {
    function mintBatch(address to_, uint256[] memory ids_, uint256[] memory amounts_) external returns (bool);

    function mint(address to_, uint cardId_, uint amount_) external returns (bool);

    function safeTransferFrom(address from, address to, uint256 cardId, uint256 amount, bytes memory data_) external;

    function safeBatchTransferFrom(address from_, address to_, uint256[] memory ids_, uint256[] memory amounts_, bytes memory data_) external;

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function balanceOf(address account, uint256 tokenId) external view returns (uint);

    function burned(uint) external view returns (uint);

    function burn(address account, uint256 id, uint256 value) external;

    function checkItemEffect(uint id_) external view returns (uint[3] memory);
    
    function itemLevel(uint id_) external view returns (uint);
    
    function itemExp(uint id_) external view returns(uint);
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICompound{
    function starExp(uint tokenId) external view returns(uint);
    
    function upgradeLimit(uint star_) external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMail{
    function bvgClaimed(address addr)external view returns(uint);
    function bvtClaimed(address addr)external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket{
    function getSellingList(uint goodsType_, address addr_) external view returns (uint[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IMating {
    function matingTime(uint tokenId) external view returns(uint);
    
    function lastMatingTime(uint tokenId) external view returns(uint);
    
    function userMatingTimes(address addr) external view returns(uint);

    function checkMatingTime(uint tokenId) external view returns (uint);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IPlanet{
    
    function isBonding(address addr_) external view returns(bool);
    
    function addTaxAmount(address addr,uint amount) external;
    
    function getUserPlanet(address addr_) external view returns(uint);
    
    function findTax(address addr_) external view returns(uint);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface ITec{
    
    function getUserTecLevelBatch(address addr,uint[] memory list) external view returns(uint[] memory out);
    
    function getUserTecLevel(address addr,uint ID) external view returns(uint out);
    
    function checkUserExpBatch(address addr,uint[] memory list) external view returns(uint[] memory out);
    
    function checkUserTecEffet(address addr, uint ID) external view returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IProfilePhoto {
    function mintBabyBull(address addr_) external;

    function mintAdultBull(address addr_) external;

    function mintBabyCow(address addr_) external;

    function mintAdultCow(address addr_) external;

    function mintMysteryBox(address addr_) external;

    function getUserPhotos(address addr_) external view returns(uint[]memory);
}