/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

/**
 * @title Incomeisland interface
 */
interface IMiningCenter {
    /**
     * @notice transfer NFT to other user. The config also transfer.
     * @param _from nft owner address
     * @param _to nft receiver address
     * @param _type nft _type
     */
    function transferNFTByUser(
        address _from,
        uint256 _type,
        address _to
    ) external;

    /**
     * @notice transfer NFT to other user. The config also transfer.
     * @param _from nft owner address
     * @param _to nft receiver address
     * @param _type nft type
     * @param _nftId nft id
     */
    function updateNFTHistoryExternal(
        address _from,
        uint256 _type,
        uint256 _nftId,
        address _to
    ) external;

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getHistoryIndex(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) external view returns (uint256);
}

contract TradingCenter is Ownable {
    using Address for address;

    IMiningCenter public miningCenter;

    struct NftOffer {
        uint256 nftType;
        uint256 nftNum;
        uint256 offerAmountWithBNB;
        address owner;
    }

    // @notice NftHistory
    // owner address => No => nft offer
    mapping(address => mapping(uint256 => NftOffer)) public tradingOfferList;

    // @notice NftHistory
    // owner address => length
    mapping(address => uint256) public tradingOfferListLength;

    uint256 public tradingFee;

    /**
     * @notice TradingCenter Constructor
     * @param _miningCenter mining center interface address
     * @param _tradingFee _tradingFee
     */
    constructor(IMiningCenter _miningCenter, uint256 _tradingFee) {
        miningCenter = _miningCenter;
        tradingFee = _tradingFee;
    }

    /**
     * @notice set Miningcenter interface
     * @param _miningCenter Miningcenter address
     */
    function setIMiningCenter(IMiningCenter _miningCenter) external onlyOwner {
        miningCenter = _miningCenter;
    }

    /**
     * @notice set _tradingFee
     * @param _tradingFee trading address
     */
    function setTradingFee(uint256 _tradingFee) external onlyOwner {
        tradingFee = _tradingFee;
    }

    function createOffer(
        uint256 _nftType,
        uint256 _nftNum,
        uint256 _offerAmountWithBNB
    ) external {
        require(
            miningCenter.getHistoryIndex(msg.sender, _nftType, _nftNum) != 9999,
            "param err"
        );
        tradingOfferList[msg.sender][
            tradingOfferListLength[msg.sender]
        ] = NftOffer(_nftType, _nftNum, _offerAmountWithBNB, address(0));

        tradingOfferListLength[msg.sender] =
            tradingOfferListLength[msg.sender] +
            1;

        miningCenter.transferNFTByUser(msg.sender, _nftType, address(this));
    }

    function cancelOffer(uint256 _nftType, uint256 _nftNum) external {
        require(
            miningCenter.getHistoryIndex(msg.sender, _nftType, _nftNum) != 9999,
            "param err"
        );
        uint256 index = 9999;
        for (uint256 i = 0; i < tradingOfferListLength[msg.sender]; i++) {
            if (
                tradingOfferList[msg.sender][i].nftNum == _nftNum &&
                tradingOfferList[msg.sender][i].nftType == _nftType &&
                tradingOfferList[msg.sender][i].owner == msg.sender
            ) {
                index = i;
            }
        }

        require(index != 9999, "not matched params");
        tradingOfferList[msg.sender][index] = NftOffer(0, 0, 0, address(0));

        tradingOfferListLength[msg.sender] =
            tradingOfferListLength[msg.sender] -
            1;

        miningCenter.transferNFTByUser(address(this), _nftType, msg.sender);
    }

    function trade(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) external payable {
        require(
            miningCenter.getHistoryIndex(_owner, _nftType, _nftNum) != 9999,
            "param err"
        );
        uint256 index = 9999;
        for (uint256 i = 0; i < tradingOfferListLength[_owner]; i++) {
            if (
                tradingOfferList[_owner][i].nftNum == _nftNum &&
                tradingOfferList[_owner][i].nftType == _nftType &&
                tradingOfferList[_owner][i].owner == _owner
            ) {
                index = i;
            }
        }

        require(index != 9999, "not matched params");
        require(
            msg.value >= tradingOfferList[_owner][index].offerAmountWithBNB,
            "no enough bnb"
        );
        tradingOfferList[_owner][index] = NftOffer(0, 0, 0, address(0));

        tradingOfferListLength[_owner] = tradingOfferListLength[_owner] - 1;

        miningCenter.transferNFTByUser(address(this), _nftType, msg.sender);
        miningCenter.updateNFTHistoryExternal(
            _owner,
            _nftType,
            _nftNum,
            msg.sender
        );

        payable(address(uint160(owner()))).transfer(
            (msg.value / 100) * tradingFee
        );

        payable(address(uint160(_owner))).transfer(
            (msg.value / 100) * (100 - tradingFee)
        );
    }
}