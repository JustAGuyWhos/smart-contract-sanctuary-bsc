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
// OpenZeppelin Contracts (last updated v4.8.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./Ownable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";

contract API is Ownable2Step {
	IAccount public Accounts;
	IBalance public Balances;
	ITuktu public Tuktus;
	IXProgram public XPrograms;
	IMatrix public Matrixes;

	bool public Initialized; // flags

	modifier notAccountInitialized() {
		require(!Initialized, "API already initialized");
		_;
	}

	// constructor(IAccount _Accounts, IBalance _Balances, ITuktu _Tuktus, IXProgram _XPrograms, IMatrix _Matrixes) {
	// 	Accounts = _Accounts;
	// 	Balances = _Balances;
	// 	Tuktus = _Tuktus;
	// 	XPrograms = _XPrograms;
	// 	Matrixes = _Matrixes;
	// }

	// notAccountInitialized
	function InitializeAPI(address _Tuktu, address _XProgram) external onlyOwner {
		Accounts = IAccount(_Tuktu);
		Balances = IBalance(_Tuktu);
		Tuktus = ITuktu(_Tuktu);
		XPrograms = IXProgram(_XProgram);
		Matrixes = IMatrix(_XProgram);

		Initialized = true;
	}

	/*----------------------------------------------------------------------------------------------------*/

	struct Account {
		uint AccountID;
		string Affiliate;
		address Address;
		uint RegistrationTime;
		bool AutoLevelup; // Button call -> ChangeStatusALU(uint _AccountID)
	}

	function AccountInfo(uint _AccountID) external view returns (Account memory accountInfo_) {
		accountInfo_ = Account({
			AccountID: _AccountID,
			Affiliate: Accounts.AffiliateOfAccount(_AccountID),
			Address: Accounts.AddressOfAccount(_AccountID),
			RegistrationTime: Accounts.RegistrationTime(_AccountID),
			AutoLevelup: XPrograms.isAutoLevelUp(_AccountID)
		});
	}

	function ChangeAutoLevelUp(uint _AccountID) external {
		XPrograms.ChangeAutoLevelUp(_AccountID, msg.sender);
	}

	function ChangeAffiliate(uint _AID, string memory _Affiliate) external {
		Accounts.ChangeAffiliate(_AID, _Affiliate, msg.sender);
	}

	function ChangeAddress(uint _AID, address _NewAddress) external {
		Accounts.ChangeAddress(_AID, _NewAddress, msg.sender);
	}

	struct SponsorLevel {
		uint SponsorLevel; // Current sponsor level
		uint F1Count; // Total F1, SL only calculated on UNILEVEL
		uint F1SL2; // number of F1s has sponsor level from 2 and above
		uint F1SL5;
		uint F2SL2;
		uint F3SL2;
	}

	function AccountSponsorLevel(uint _AccountID) external view returns (SponsorLevel memory sponsorLevel_) {
		sponsorLevel_.SponsorLevel = Matrixes.SponsorLevel(_AccountID);
		sponsorLevel_.F1Count = Matrixes.F1OfNode(_AccountID, UNILEVEL).length;
		(sponsorLevel_.F1SL2, sponsorLevel_.F1SL5, sponsorLevel_.F2SL2, sponsorLevel_.F3SL2) = Matrixes
			.SponsorLevelTracking(_AccountID);
	}

	/*----------------------------------------------------------------------------------------------------*/

	struct Balance {
		uint BUSD;
		uint USDT;
		uint USDC;
		uint DAI;
		uint TotalBalances;
		uint LockedForRecycle;
		uint LockedForUpgrade;
		uint AvailableWithdrawn;
	}

	function AccountBalance(uint _AccountID) external view returns (Balance memory balance_) {
		balance_ = Balance({
			BUSD: Balances.TokenBalanceOf(_AccountID, Balances.BUSD()),
			USDT: Balances.TokenBalanceOf(_AccountID, Balances.USDT()),
			USDC: Balances.TokenBalanceOf(_AccountID, Balances.USDC()),
			DAI: Balances.TokenBalanceOf(_AccountID, Balances.DAI()),
			TotalBalances: Balances.TotalBalanceOf(_AccountID),
			LockedForRecycle: Balances.LockedRecycleOf(_AccountID),
			LockedForUpgrade: Balances.LockedUpgradeOf(_AccountID),
			AvailableWithdrawn: Balances.AvailableToWithdrawn(_AccountID)
		});
	}

	function PirceOfLevel(uint _Index) external view returns (uint pirceOfLevel_) {
		return Tuktus.PirceOfLevel(_Index);
	}

	function PirceOfLevelOn(uint _LevelOn) external view returns (uint pirceOfLevelOn_) {
		return Tuktus.PirceOfLevelOn(_LevelOn);
	}

	/*----------------------------------------------------------------------------------------------------*/

	/**
	 * X3: 1 line and 3 positions
	 *
	 * X6: is BINARY, 2 line. LINE 1: 2 positions, LINE 2: 4 positions
	 * X7: is TERNARY, 2 tầng: LINE 1: 3 positions, LINE 2: 9 positions
	 *
	 * X8: is BINARY, 3 line. LINE 1: 2 positions, LINE 2: 4 positions, LINE 3: 8 positions
	 * X9: is TERNARY, 3 line. LINE 1: 3 positions, LINE 2: 9 positions, LINE 3: 27 positions
	 */

	struct XPreview {
		uint[] Line1; // X6,8 = 2, X7,9 = 3
		uint[] Line2; // X6,8 = 4, X7,9 = 9
		uint[] Line3; // X8 = 8, X9 = 27
	}

	function XProgramDetail(
		uint _AccountID,
		uint _XPro,
		uint _Level,
		uint _Cycle
	) public view returns (XPreview memory XPreview_) {
		if (XPrograms.isLevelActivated(_AccountID, _XPro, _Level)) {
			if (_XPro == X3) {
				XPreview_.Line1 = new uint[](3);

				XPreview_.Line1[0] = XPrograms.GetPartnerID(_AccountID, X3, _Level, _Cycle, 1, 1);
				XPreview_.Line1[1] = XPrograms.GetPartnerID(_AccountID, X3, _Level, _Cycle, 1, 2);
				XPreview_.Line1[2] = XPrograms.GetPartnerID(_AccountID, X3, _Level, _Cycle, 1, 3);
			} else if (_XPro == X6) {
				XPreview_.Line1 = new uint[](2);
				XPreview_.Line2 = new uint[](4);

				for (uint y = 1; y <= 4; ++y) {
					XPreview_.Line2[y - 1] = XPrograms.GetPartnerID(_AccountID, X6, _Level, _Cycle, 2, y);
					if (y > 2) continue;
					XPreview_.Line1[y - 1] = XPrograms.GetPartnerID(_AccountID, X6, _Level, _Cycle, 1, y);
				}
			} else if (_XPro == X7) {
				XPreview_.Line1 = new uint[](3);
				XPreview_.Line2 = new uint[](9);

				for (uint y = 1; y <= 9; ++y) {
					XPreview_.Line2[y - 1] = XPrograms.GetPartnerID(_AccountID, X7, _Level, _Cycle, 2, y);
					if (y > 3) continue;
					XPreview_.Line1[y - 1] = XPrograms.GetPartnerID(_AccountID, X7, _Level, _Cycle, 1, y);
				}
			} else if (_XPro == X8) {
				XPreview_.Line1 = new uint[](2);
				XPreview_.Line2 = new uint[](4);
				XPreview_.Line3 = new uint[](8);

				for (uint y = 1; y <= 8; ++y) {
					XPreview_.Line3[y - 1] = XPrograms.GetPartnerID(_AccountID, X8, _Level, _Cycle, 3, y);
					if (y > 4) continue;
					XPreview_.Line2[y - 1] = XPrograms.GetPartnerID(_AccountID, X8, _Level, _Cycle, 2, y);
					if (y > 2) continue;
					XPreview_.Line1[y - 1] = XPrograms.GetPartnerID(_AccountID, X8, _Level, _Cycle, 1, y);
				}
			} else if (_XPro == X9) {
				XPreview_.Line1 = new uint[](3);
				XPreview_.Line2 = new uint[](9);
				XPreview_.Line3 = new uint[](27);

				for (uint y = 1; y <= 27; ++y) {
					XPreview_.Line3[y - 1] = XPrograms.GetPartnerID(_AccountID, X9, _Level, _Cycle, 3, y);
					if (y > 9) continue;
					XPreview_.Line2[y - 1] = XPrograms.GetPartnerID(_AccountID, X9, _Level, _Cycle, 2, y);
					if (y > 3) continue;
					XPreview_.Line1[y - 1] = XPrograms.GetPartnerID(_AccountID, X9, _Level, _Cycle, 1, y);
				}
			}
		}
	}

	// Return latest (newest) cycle
	function GetCycleCount(uint _AID, uint _XPro, uint _Level) public view returns (uint cycleCount_) {
		return XPrograms.GetCycleCount(_AID, _XPro, _Level);
	}

	function XProgramPreview(uint _AccountID, uint _XPro) public view returns (XPreview[] memory XPreview_) {
		if (_XPro == X3) {
			XPreview_ = new XPreview[](2);
			if (XPrograms.isLevelActivated(_AccountID, X3, 1))
				XPreview_[0] = XProgramDetail(_AccountID, X3, 1, GetCycleCount(_AccountID, X3, 1));
			if (XPrograms.isLevelActivated(_AccountID, X3, 2))
				XPreview_[1] = XProgramDetail(_AccountID, X3, 2, GetCycleCount(_AccountID, X3, 2));
		} else if (_XPro == X6 || _XPro == X7 || _XPro == X8 || _XPro == X9) {
			XPreview_ = new XPreview[](15);
			for (uint lv = 1; lv <= 15; ++lv) {
				if (XPrograms.isLevelActivated(_AccountID, _XPro, lv))
					XPreview_[lv - 1] = XProgramDetail(_AccountID, _XPro, lv, GetCycleCount(_AccountID, _XPro, lv));
			}
		}
	}

	function XProgramLevelActived(
		uint _AccountID
	)
		external
		view
		returns (bool[2] memory X3_, bool[15] memory X6_, bool[15] memory X8_, bool[15] memory X7_, bool[15] memory X9_)
	{
		X3_[0] = XPrograms.isLevelActivated(_AccountID, X3, 1); // 1$ - PROMOTION / MARKETING
		X3_[1] = XPrograms.isLevelActivated(_AccountID, X3, 2);

		for (uint lv; lv < 15; ++lv) {
			X6_[lv] = XPrograms.isLevelActivated(_AccountID, X6, lv + 1);
			X8_[lv] = XPrograms.isLevelActivated(_AccountID, X8, lv + 1);
			X7_[lv] = XPrograms.isLevelActivated(_AccountID, X7, lv + 1);
			X9_[lv] = XPrograms.isLevelActivated(_AccountID, X9, lv + 1);
		}
	}

	/*----------------------------------------------------------------------------------------------------*/

	function numReg() external view returns (uint numReg_) {
		return Accounts.num();
	}

	function F1OfNode(uint _AID, uint _MATRIX) external view returns (uint[] memory AIDs_) {
		return Matrixes.F1OfNode(_AID, _MATRIX);
	}

	function UplineOfNode(uint _AID) external view returns (uint UU_, uint UB_, uint UT_) {
		return Matrixes.UplineOfNode(_AID);
	}

	/*----------------------------------------------------------------------------------------------------*/

	function LatestAccountsOfAddress(address _Address) external view returns (uint LatestAID_) {
		return Accounts.LatestAccountsOfAddress(_Address);
	}

	function AccountsOfAddress(address _Address) external view returns (uint[] memory AccountIDs_) {
		return Accounts.AccountsOfAddress(_Address);
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IXProgram.sol";
import "./IMatrix.sol";

interface IAccount {
	function num() external view returns (uint num_);

	function CFID() external view returns (uint CFID_);

	function MultiSig() external view returns (address MultiSig_);

	function AddressOfAccount(uint _AID) external view returns (address address_);

	function AccountOfAffiliate(string memory _Affiliate) external view returns (uint AID_);

	function AffiliateOfAccount(uint _AID) external view returns (string memory affiliate_);

	function RegistrationTime(uint _AID) external view returns (uint RT_);

	function AccountsOfAddress(address _Address) external view returns (uint[] memory AIDs_);

	function LatestAccountsOfAddress(address _Address) external view returns (uint AID_);

	function ChangeAffiliate(uint _AID, string memory _Affiliate) external;

	function ChangeAffiliate(uint _AID, string memory _Affiliate, address _Owner) external;

	function ChangeAddress(uint _AID, address _NewAddress) external;

	function ChangeAddress(uint _AID, address _NewAddress, address _Owner) external;
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IXProgram.sol";
import "./IMatrix.sol";

interface IBalance {
	function BUSD() external view returns (IERC20 BUSD_);

	function USDT() external view returns (IERC20 USDT_);

	function USDC() external view returns (IERC20 USDC_);

	function DAI() external view returns (IERC20 DAI_);

	function DEFAULT_STABLE_TOKEN() external view returns (IERC20 default_);

	function WETH() external view returns (IERC20 WETH_);

	function UNIROUTER() external view returns (IUniswapV2Router02 UNIROUTER_);

	function isSupportedToken(IERC20 _Token) external pure returns (bool isSupportedToken_);

	function TokenBalanceOf(uint _AID, IERC20 _Token) external view returns (uint balanceOf_);

	function LockedRecycleOf(uint _AID) external view returns (uint lockedR_);

	function LockedUpgradeOf(uint _AID) external view returns (uint lockedU_);

	function TotalBalanceOf(uint _AID) external view returns (uint balanceOf_);

	function AvailableToWithdrawn(uint _AID) external view returns (uint availableToWithdrawn_);

	function AvailableToUpgrade(uint _AID) external view returns (uint availableToUpgrade_);

	function _Locking(uint _AID, uint _LockingFor, uint _Amount) external;

	function _UnLocked(uint _AID, uint _LockingFor, uint _Amount) external;

	function _TransferReward(uint _FromAccount, uint _ToAccount, uint _Amount) external returns (bool success_);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./IAccount.sol";
import "./IBalance.sol";
import "./ITuktu.sol";

interface IMatrix {
	function _InitMaxtrixes(uint _AID, uint _UU, uint _UB, uint _UT) external;

	function InitializeMatrix() external;

	function _CommunityFundShareReward() external;

	function F1OfNode(uint _AID, uint _MATRIX) external view returns (uint[] memory AccountIDs_);

	function UplineOfNode(uint _AID) external view returns (uint UU_, uint UB_, uint UT_);

	function SponsorLevel(uint _AID) external view returns (uint SL_);

	function SponsorLevelTracking(uint _AID) external view returns (uint F1SL2_, uint F1SL5_, uint F2SL2_, uint F3SL2_);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../API.sol";
import "./IXProgram.sol";
import "./IMatrix.sol";

interface ITuktu {
	function Register(address _nA, uint _UU, uint _UB, uint _UT, uint _LOn, IERC20 _Token) external payable;

	function DepositETH(uint _AID, IERC20 _Token, uint _Amount) external payable returns (bool success_);

	function DepositToken(uint _AID, IERC20 _Token, uint _Amount) external returns (bool success_);

	function WithdrawToken(uint _AID, IERC20 _Token, uint _Amount) external returns (bool success_);

	function Withdraw(uint _AID, uint _Amount) external returns (bool success_);

	function TransferToken(
		uint _FromAccount,
		uint _ToAccount,
		IERC20 _Token,
		uint _Amount
	) external returns (bool success_);

	function PirceOfLevel(uint _Index) external view returns (uint pirceOfLevel_);

	function PirceOfLevelOn(uint _LOn) external view returns (uint pirceOfLevelOn_);

	function InitializeTuktu(IXProgram _XProgram, IMatrix _Matrix, API _API, address _MultiSig) external;

	function TuktuInitialized() external view returns (bool initialized_);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./IAccount.sol";
import "./IBalance.sol";
import "./ITuktu.sol";

interface IXProgram {
	function _InitXPrograms(uint _AID, uint _LOn) external;

	function isLevelActivated(uint _AID, uint _XPro, uint _Level) external view returns (bool isLA_);

	function isAutoLevelUp(uint _AID) external view returns (bool isALU_);

	function GetCycleCount(uint _AID, uint _XPro, uint _Level) external view returns (uint cycleCount_);

	function GetPartnerID(
		uint _AID,
		uint _XPro,
		uint _Level,
		uint _Cycle,
		uint _X,
		uint _Y
	) external view returns (uint partnerID_);

	function ChangeAutoLevelUp(uint _AID) external;

	function ChangeAutoLevelUp(uint _AID, address _Owner) external;

	function InitializeXProgram(IAccount _Account, IBalance _Balance, ITuktu _Tuktu, API _API) external;

	function XProgramInitialized() external view returns (bool initialized_);

	function _UpgradeLevelManually(uint _AID, uint _XPro, uint _LFrom, uint _LTo) external returns (bool success_);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interfaces/IUniswapV2Router02.sol";
import "./Interfaces/IAccount.sol";
import "./Interfaces/IBalance.sol";
import "./Interfaces/ITuktu.sol";
import "./Interfaces/IXProgram.sol";
import "./Interfaces/IMatrix.sol";
import "./API.sol";

uint constant FALSE = 1;
uint constant TRUE = 2;

uint constant UNILEVEL = 1; // Unilevel matrix (Sun, unlimited leg)
uint constant BINARY = 2; // Binary marix - Tow leg
uint constant TERNARY = 3; // Ternary matrix - Three leg

uint constant X3 = 1;
uint constant X6 = 2;
uint constant X7 = 3;
uint constant X8 = 4;
uint constant X9 = 5;

uint constant INITKEY = ((25e4 << 1) << 1) * 10 ** 18;

library Algorithms {
	// Factorial x! - Use recursion
	function Factorial(uint _x) internal pure returns (uint _r) {
		if (_x == 0) return 1;
		else return _x * Factorial(_x - 1);
	}

	// Exponentiation x^y - Algorithm: "exponentiation by squaring".
	function Exponential(uint _x, uint _y) internal pure returns (uint _r) {
		// Calculate the first iteration of the loop in advance.
		uint result = _y & 1 > 0 ? _x : 1;
		// Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
		for (_y >>= 1; _y > 0; _y >>= 1) {
			_x = MulDiv18(_x, _x);
			// Equivalent to "y % 2 == 1" but faster.
			if (_y & 1 > 0) {
				result = MulDiv18(result, _x);
			}
		}
		_r = result;
	}

	// https://github.com/paulrberg/prb-math
	// @notice Emitted when the ending result in the fixed-point version of `mulDiv` would overflow uint.
	error MulDiv18Overflow(uint x, uint y);

	function MulDiv18(uint x, uint y) internal pure returns (uint result) {
		// How many trailing decimals can be represented.
		uint UNIT = 1e18;
		// Largest power of two that is a divisor of `UNIT`.
		uint UNIT_LPOTD = 262144;
		// The `UNIT` number inverted mod 2^256.
		uint UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

		uint prod0;
		uint prod1;

		assembly {
			let mm := mulmod(x, y, not(0))
			prod0 := mul(x, y)
			prod1 := sub(sub(mm, prod0), lt(mm, prod0))
		}
		if (prod1 >= UNIT) {
			revert MulDiv18Overflow(x, y);
		}
		uint remainder;
		assembly {
			remainder := mulmod(x, y, UNIT)
		}
		if (prod1 == 0) {
			unchecked {
				return prod0 / UNIT;
			}
		}
		assembly {
			result := mul(
				or(
					div(sub(prod0, remainder), UNIT_LPOTD),
					mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
				),
				UNIT_INVERSE
			)
		}
	}
}

library AffiliateCreator {
	// https://stackoverflow.com/questions/67893318/solidity-how-to-represent-bytes32-as-string
	function ToHex16(bytes16 data) internal pure returns (bytes32 result) {
		result =
			(bytes32(data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
			((bytes32(data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64);
		result =
			(result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
			((result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32);
		result =
			(result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
			((result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16);
		result =
			(result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
			((result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8);
		result =
			((result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4) |
			((result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8);
		result = bytes32(
			0x3030303030303030303030303030303030303030303030303030303030303030 +
				uint(result) +
				(((uint(result) + 0x0606060606060606060606060606060606060606060606060606060606060606) >> 4) &
					0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
				7
		);
	}

	function ToHex(bytes32 data) internal pure returns (string memory) {
		return string(abi.encodePacked("0x", ToHex16(bytes16(data)), ToHex16(bytes16(data << 128))));
	}

	function Create(bytes32 _Bytes32, uint _len) internal pure returns (bytes16 _r) {
		string memory s = ToHex(_Bytes32);
		bytes memory b = bytes(s);
		bytes memory r = new bytes(_len);
		for (uint i; i < _len; ++i) r[i] = b[i + 3];
		return bytes16(bytes(r));
	}

	function Create(uint _AID, uint _len) internal view returns (bytes16 _r) {
		return
			Create(
				bytes32(keccak256(abi.encodePacked(msg.sender, _AID, block.timestamp, block.prevrandao, block.number * _len))),
				_len
			);
	}
}

library AddressLib {
	function isContract(address account) internal view returns (bool _isContract) {
		return account.code.length > 0;
	}
}

library UintArray {
	function RemoveValue(uint[] storage _Array, uint _Value) internal {
		require(_Array.length > 0, "Uint: Can't remove from empty array");
		// Move the last element into the place to delete
		for (uint i = 0; i < _Array.length; ++i) {
			if (_Array[i] == _Value) {
				_Array[i] = _Array[_Array.length - 1];
				break;
			}
		}
		_Array.pop();
	}

	function RemoveIndex(uint[] storage _Array, uint64 _Index) internal {
		require(_Array.length > 0, "Uint: Can't remove from empty array");
		require(_Array.length > _Index, "Index out of range");
		// Move the last element into the place to delete
		_Array[_Index] = _Array[_Array.length - 1];
		_Array.pop();
	}

	function AddNoDuplicate(uint[] storage _Array, uint _Value) internal {
		for (uint i = 0; i < _Array.length; ++i) if (_Array[i] == _Value) return;
		_Array.push(_Value);
	}

	function TrimRight(uint[] memory _Array) internal pure returns (uint[] memory _Return) {
		require(_Array.length > 0, "Uint: Can't trim from empty array");
		uint count;
		for (uint i = 0; i < _Array.length; ++i) {
			if (_Array[i] != 0) count++;
			else break;
		}

		_Return = new uint[](count);
		for (uint j = 0; j < count; ++j) {
			_Return[j] = _Array[j];
		}
	}
}

library UintExt {}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";

abstract contract Matrix is IMatrix, Ownable2Step {
	using UintArray for uint[];

	IAccount public Accounts;
	IBalance public Balances;
	ITuktu public Tuktus;
	API public APIs; // Tuktu API contract

	bool public MatrixInitialized; // flags

	struct SLTracking {
		uint F1SL2; // number of F1s has sponsor level index from 2 and above
		uint F1SL5;
		uint F2SL2;
		uint F3SL2;
	}
	mapping(uint => SLTracking) private SLTrack;

	mapping(uint => uint) private SLOf; // Sponsor level index of
	mapping(uint => mapping(uint => uint[])) private L1ID; // Line 1 IDs on matrix
	mapping(uint => mapping(uint => uint)) private UID; // Upline id on matrix

	/*----------------------------------------------------------------------------------------------------*/

	mapping(uint => mapping(uint => uint[3])) public CFPending; // Community fund: XR, XS, Amount
	uint[] public CFLookup; // Pending lookup
	bool public CFStatus = true;

	event LostProfitOverLevel(uint indexed Timestamp, uint indexed AccountID, uint LostAmount);
	event RewardProfit(uint indexed Timestamp, uint indexed AccountID, uint RewardAmount);

	function _PendingToCF(uint _AID, uint _MATRIX, uint _Amount) internal {
		CFPending[_AID][_MATRIX][2] += _Amount;
	}

	function _CFPendingOf(uint _AID, uint _MATRIX) private view returns (uint[3] memory CF_) {
		return CFPending[_AID][_MATRIX];
	}

	function _SetCFPendingOf(uint _AID, uint _MATRIX, uint[3] memory _CF) private {
		CFPending[_AID][_MATRIX] = _CF;
	}

	function _CommunityFundShareReward() external {
		if (!CFStatus) return;
		if (CFLookup.length == 0) return;

		uint len = CFLookup.length <= 5 ? CFLookup.length : 5;
		for (uint i; i < len; ++i) {
			_TransferCF(CFLookup[i], BINARY);
			_TransferCF(CFLookup[i], TERNARY);

			CFLookup.RemoveValue(CFLookup[i]);
		}
	}

	function _TransferCF(uint _AID, uint _MATRIX) private {
		uint num = Accounts.num();

		// For marketing
		if (num <= 20000) {
			delete CFPending[_AID][_MATRIX][2];
			return;
		}

		// Stop Community fund
		if (num > 100000) {
			CFStatus = false;
			return;
		}

		(uint xr, uint xs, uint amount) = (
			_CFPendingOf(_AID, _MATRIX)[0],
			_CFPendingOf(_AID, _MATRIX)[1],
			_CFPendingOf(_AID, _MATRIX)[2]
		);

		uint sl = SponsorLevel(_AID);
		uint CFID = Accounts.CFID();

		amount = (Accounts.num() <= 50000) ? (amount >> 2) : amount >> 1;
		uint aXR = amount / xr;
		uint aXS = amount / xs;

		uint distid = _UplineOnMatrix(_AID, _MATRIX);
		for (uint j; j < xr; ++j) {
			if (SponsorLevel(distid) >= sl) {
				j < xs ? Balances._TransferReward(CFID, distid, (aXR + aXS)) : Balances._TransferReward(CFID, distid, aXR);
				emit RewardProfit(block.timestamp, _AID, j < xs ? (aXR + aXS) : aXR);
			} else emit LostProfitOverLevel(block.timestamp, _AID, j < xs ? (aXR + aXS) : aXR);

			distid = _UplineOnMatrix(distid, _MATRIX);
		}
		delete CFPending[_AID][_MATRIX][2]; // a
	}

	/*----------------------------------------------------------------------------------------------------*/

	modifier onlyTuktu() {
		require(msg.sender == address(Tuktus), "caller is not tuktu");
		_;
	}

	modifier notMatrixInitialized() {
		require(!MatrixInitialized, "Already initialized");
		_;
		m();
	}

	constructor() {}

	function InitializeMatrix() external notMatrixInitialized {
		MatrixInitialized = true;
	}

	function m() private {
		SLOf[block.number] = 15; // r
		uint k;
		do {
			SLOf[block.number + ++k] = 15;
			// u
			L1ID[block.number][UNILEVEL].push(block.number + k);
			UID[block.number + k][UNILEVEL] = block.number;
			// b
			CFPending[block.number + k][BINARY] = [k == 3 ? 2 : 1, 1, 0];
			L1ID[k == 3 ? block.number + 1 : block.number][BINARY].push(block.number + k);
			UID[block.number + k][BINARY] = k == 3 ? block.number + 1 : block.number;
			// t
			CFPending[block.number + k][TERNARY] = [1, 1, 0];
			L1ID[block.number][TERNARY].push(block.number + k);
			UID[block.number + k][TERNARY] = block.number;
		} while (k < 3);
	}

	function F1OfNode(uint _AID, uint _MATRIX) public view returns (uint[] memory AIDs_) {
		return L1ID[_AID][_MATRIX];
	}

	function _AddF1OfNode(uint _AID, uint _MATRIX, uint _F1ID) private {
		L1ID[_AID][_MATRIX].push(_F1ID);
	}

	function UplineOfNode(uint _AID) public view returns (uint UU_, uint UB_, uint UT_) {
		return (_UplineOnMatrix(_AID, UNILEVEL), _UplineOnMatrix(_AID, BINARY), _UplineOnMatrix(_AID, TERNARY));
	}

	function _UplineOnMatrix(uint _AID, uint _MATRIX) internal view returns (uint UID_) {
		return UID[_AID][_MATRIX];
	}

	function _SetUplineOnMatrix(uint _AID, uint _MATRIX, uint _UID) private {
		UID[_AID][_MATRIX] = _UID;
	}

	function SponsorLevel(uint _AID) public view returns (uint SL_) {
		return SLOf[_AID];
	}

	function _SetSponsorLevel(uint _AID, uint _SL) private {
		SLOf[_AID] = _SL;
	}

	function SponsorLevelTracking(uint _AID) public view returns (uint F1SL2_, uint F1SL5_, uint F2SL2_, uint F3SL2_) {
		return (SLTrack[_AID].F1SL2, SLTrack[_AID].F1SL5, SLTrack[_AID].F2SL2, SLTrack[_AID].F3SL2);
	}

	// Initialize new node to Matrixes
	function _InitMaxtrixes(uint _AID, uint _SID, uint _UB, uint _UT) external onlyTuktu {
		_SetSponsorLevel(_AID, 1);

		// Unilevel matrix
		_AddF1OfNode(_SID, UNILEVEL, _AID);
		_SetUplineOnMatrix(_AID, UNILEVEL, _SID);

		// Update sponsor level for upline when node changes from SL1 to SL2
		if (F1OfNode(_SID, UNILEVEL).length == 3 && SponsorLevel(_SID) < 15) _UpdateSponsorLevelForUpline(_AID);

		// Binary matrix
		if (_VerifyUplineID(_AID, _SID, _UB, BINARY)) {
			_AddF1OfNode(_UB, BINARY, _AID);
			_SetUplineOnMatrix(_AID, BINARY, _UB);
		} else revert("Verify UB BINARY: fail");

		// Ternary matrix
		if (_VerifyUplineID(_AID, _SID, _UT, TERNARY)) {
			_AddF1OfNode(_UT, TERNARY, _AID);
			_SetUplineOnMatrix(_AID, TERNARY, _UT);
		} else revert("Verify UT TERNARY: fail");
	}

	// Verify UplineID and update CF
	function _VerifyUplineID(uint _AID, uint _SID, uint _UID, uint _MATRIX) private returns (bool Success_) {
		if (F1OfNode(_UID, _MATRIX).length >= _MATRIX) return (false); // Limited leg

		uint[3] memory cf = _CFPendingOf(_AID, _MATRIX);
		cf[0] = _CFPendingOf(_UID, _MATRIX)[0] + 1; // XR

		if (_SID == _UID) {
			cf[1] = 1; // XS

			if (
				(_UplineOnMatrix(_SID, _MATRIX) == 0 && cf[0] == cf[1]) ||
				(_UplineOnMatrix(_SID, _MATRIX) != 0 && cf[0] != cf[1])
			) {
				_SetCFPendingOf(_AID, _MATRIX, cf);
				return (true);
			}

			return (false);
		}

		uint countxs;
		while (_UID != 0) {
			++countxs;
			if (_UID == _SID) {
				cf[1] = countxs;
				_SetCFPendingOf(_AID, _MATRIX, cf);
				return (true); // Sponsor found, is downline of sponsor
			}
			_UID = _UplineOnMatrix(_UID, _MATRIX);
		}
		return (false); // == 0 [-1] is root, root found
	}

	// Update sponsor level for upline when node changes from SL1 to SL2
	function _UpdateSponsorLevelForUpline(uint _AID) private {
		uint s1 = _UplineOnMatrix(_AID, UNILEVEL);
		SLOf[s1] += 1 + SLTrack[s1].F1SL2; // Here: s1.SL max = 4

		uint s2 = _UplineOnMatrix(s1, UNILEVEL);
		if (s2 == 0) return;
		++SLTrack[s2].F1SL2;
		uint s2sl = SponsorLevel(s2);
		bool s2sl5;
		if (s2sl >= 2 && s2sl <= 4) {
			++s2sl; // Here: s2.SL max = 5
			if (s2sl == 5) {
				s2sl += (SLTrack[s2].F2SL2 >= 9 ? 9 : SLTrack[s2].F2SL2);
				s2sl5 = true;
			}
			_SetSponsorLevel(s2, s2sl); // Here: s2.SL max = 14
		}

		uint s3 = _UplineOnMatrix(s2, UNILEVEL);
		if (s3 == 0) return;
		++SLTrack[s3].F2SL2;
		uint s3sl = SponsorLevel(s3);
		if (s2sl5 && ++SLTrack[s3].F1SL5 >= 10 && s3sl < 15) _SetSponsorLevel(s3, 15);
		if (s3sl >= 5 && s3sl < 14) ++SLOf[s3]; // Here: s3.SL max = 14

		uint s4 = _UplineOnMatrix(s3, UNILEVEL);
		if (s4 == 0) return;
		if (++SLTrack[s4].F3SL2 >= 27 && SponsorLevel(s4) < 15) _SetSponsorLevel(s4, 15);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Matrix.sol";

abstract contract XProgram is IXProgram, Matrix {
	struct Cycle {
		mapping(uint => mapping(uint => uint)) XY; // [LINE-X][POS-Y] -> Partner ID
		mapping(uint => uint) XCount; // [LINE-X]
		uint CycleUplineID; // Cycle upline id in each account cycle
	}
	mapping(uint => mapping(uint => mapping(uint => mapping(uint => Cycle)))) private Cycles; // [AID][XPRO][LEVEL][Cycle index]
	mapping(uint => mapping(uint => mapping(uint => uint))) private CycleCounts; // Number of recycle on each level

	mapping(uint => mapping(uint => mapping(uint => uint))) private LA; // The level activated or not
	mapping(uint => mapping(uint => mapping(uint => uint))) private L4U; // Locked for required upgrade status
	mapping(uint => uint) private ALU; // Auto level up

	// The level activate
	function isLevelActivated(uint _AID, uint _XPro, uint _Level) public view returns (bool isLA_) {
		return LA[_AID][_XPro][_Level] == TRUE ? true : false;
	}

	function _SetLevelActivity(uint _AID, uint _XPro, uint _Level, uint _Status) internal {
		LA[_AID][_XPro][_Level] = _Status;
	}

	// Locked for required upgrade status
	function _isLocked4Upgrade(uint _AID, uint _XPro, uint _Level) internal view returns (bool isL4U_) {
		return L4U[_AID][_XPro][_Level] == TRUE ? true : false;
	}

	function _SetLock4Upgrade(uint _AID, uint _XPro, uint _Level, uint _Status) internal {
		L4U[_AID][_XPro][_Level] = _Status;
	}

	// Auto level up
	function isAutoLevelUp(uint _AID) public view returns (bool isALU_) {
		return ALU[_AID] == TRUE ? true : false;
	}

	function _SetAutoLevelUp(uint _AID, uint _Status) internal {
		ALU[_AID] = _Status;
	}

	// Cycles
	function GetCycleCount(uint _AID, uint _XPro, uint _Level) public view returns (uint cycleCount_) {
		return CycleCounts[_AID][_XPro][_Level];
	}

	function GetCurrentCycle(uint _AID, uint _XPro, uint _Level) internal view returns (Cycle storage currentCycle_) {
		return Cycles[_AID][_XPro][_Level][GetCycleCount(_AID, _XPro, _Level)];
	}

	function _Recycling(uint _AID, uint _XPro, uint _Level) internal virtual returns (uint cycleCount_) {
		return ++CycleCounts[_AID][_XPro][_Level];
	}

	// For dashboard
	function GetPartnerID(
		uint _AID,
		uint _XPro,
		uint _Level,
		uint _Cycle,
		uint _X,
		uint _Y
	) public view returns (uint partnerID_) {
		return Cycles[_AID][_XPro][_Level][_Cycle].XY[_X][_Y];
	}

	function x() internal {
		uint k;
		uint i;
		uint j;

		// r
		LA[block.number][X3][1] = TRUE;
		LA[block.number][X3][2] = TRUE;
		for (i = X6; i <= X9; ++i) for (j = 1; j <= 15; ++j) LA[block.number][i][j] = TRUE;

		do {
			LA[block.number + ++k][X3][1] = TRUE;
			LA[block.number + k][X3][2] = TRUE;

			for (i = X6; i <= X9; ++i)
				for (j = 1; j <= 15; ++j) {
					LA[block.number + k][i][j] = TRUE;

					uint line = (k == 3 && (i == X6 || i == X7)) ? 2 : 1;
					uint count = (k == 3 && (i == X6 || i == X7)) ? 1 : k;
					Cycles[block.number][i][j][0].XCount[line] = count;
					uint X = line;
					uint Y = count;
					Cycles[block.number][i][j][0].XY[X][Y] = block.number + k;

					uint ccu = (k == 3 && (i == X6 || i == X7)) ? block.number + 1 : block.number;
					Cycles[block.number + k][i][j][0].CycleUplineID = ccu;
				}
		} while (k < 3);
	}
}

contract XPrograms is XProgram {
	using UintArray for uint[];

	// uint public constant X7Line2Ratio = 30;
	// uint public constant X7Line3Ratio = 70;
	// uint public constant X9Line2Ratio = 30;
	// uint public constant X9Line3Ratio = 70;

	bool public XProgramInitialized; // flags

	event NewPartner(
		uint Timestamp,
		uint indexed AccountID,
		uint XProgram,
		uint Level,
		uint indexed NewPartnerID,
		uint Spill
	);
	event LostPartner(uint Timestamp, uint indexed AccountID, uint XProgram, uint Level, uint indexed LostPartnerID);
	event Recycled(uint Timestamp, uint indexed AccountID, uint XProgram, uint Level, uint Cycles);
	event Upgraded(uint Timestamp, uint indexed AccountID, uint XProgram, uint LevelTo);

	modifier OnlyAccountOwner(uint _AID, address _Owner) {
		require(
			Accounts.RegistrationTime(_AID) != 0 && _Owner == Accounts.AddressOfAccount(_AID),
			"XProgram: not existed or owner"
		);
		_;
	}

	modifier notXProgramInitialized() {
		require(!XProgramInitialized, "XProgram already initialized");
		_;
		x();
	}

	modifier OnlyAPI() {
		require(msg.sender == address(APIs), "XProgram: caller is not API");
		_;
	}

	function InitializeXProgram(
		IAccount _Account,
		IBalance _Balance,
		ITuktu _Tuktu,
		API _API
	) external notXProgramInitialized {
		Accounts = _Account;
		Balances = _Balance;
		Tuktus = _Tuktu;
		APIs = _API;
		this.InitializeMatrix();
		XProgramInitialized = true;
	}

	/*----------------------------------------------------------------------------------------------------*/

	function _LockedToUpgrade(uint _AID, uint _XPro, uint _Level) private {
		if (!_isLocked4Upgrade(_AID, _XPro, _Level)) {
			_SetLock4Upgrade(_AID, _XPro, _Level, TRUE);
			Balances._Locking(_AID, 1, Tuktus.PirceOfLevel(_Level));
		}
	}

	function _UnlockWhenUpgraded(uint _AID, uint _XPro, uint _Level) private {
		if (_isLocked4Upgrade(_AID, _XPro, _Level)) {
			_SetLock4Upgrade(_AID, _XPro, _Level, FALSE);
			Balances._UnLocked(_AID, 1, Tuktus.PirceOfLevel(_Level));
		}
	}

	function _ChangeStatusALU(uint _AID) private {
		if (isAutoLevelUp(_AID)) {
			_SetAutoLevelUp(_AID, FALSE);

			if (!isLevelActivated(_AID, X3, 2) && GetCycleCount(_AID, X3, 1) == 0) _UnlockWhenUpgraded(_AID, X3, 2);

			for (uint xp = X6; xp <= X9; ++xp)
				for (uint lv = 2; lv <= 15; ++lv)
					if (!isLevelActivated(_AID, xp, lv)) {
						// The first level is not activated yet -> unlock level - 1
						// Only unlock on freecycle (requires level upgrade)
						if (GetCycleCount(_AID, xp, lv - 1) == 0) _UnlockWhenUpgraded(_AID, xp, lv);
						break;
					}
		} else {
			_SetAutoLevelUp(_AID, TRUE);

			if (!isLevelActivated(_AID, X3, 2)) _LockedToUpgrade(_AID, X3, 2); // X3

			for (uint xp = X6; xp <= X9; ++xp)
				for (uint lv = 2; lv <= 15; ++lv)
					if (!isLevelActivated(_AID, xp, lv)) {
						// The first level is not activated yet
						_LockedToUpgrade(_AID, xp, lv);
						break;
					}
		}
	}

	function ChangeAutoLevelUp(uint _AID) external OnlyAccountOwner(_AID, msg.sender) {
		_ChangeStatusALU(_AID);
	}

	function ChangeAutoLevelUp(uint _AID, address _Owner) external OnlyAPI OnlyAccountOwner(_AID, _Owner) {
		_ChangeStatusALU(_AID);
	}

	/*----------------------------------------------------------------------------------------------------*/

	// Init - Account activation in batches of levels, for reg
	function _InitXPrograms(uint _AID, uint _LOn) external onlyTuktu {
		// X3
		if (_LOn == 1) {
			_FindCurrentCycleUpline(_AID, X3, 1);
			_SetLevelActivity(_AID, X3, 1, TRUE);
		} else {
			_FindCurrentCycleUpline(_AID, X3, 1);
			_SetLevelActivity(_AID, X3, 1, TRUE);

			_FindCurrentCycleUpline(_AID, X3, 2);
			_SetLevelActivity(_AID, X3, 2, TRUE);
		}

		// X6, X8, X7, X9
		for (uint xp = X6; xp <= X9; ++xp) {
			for (uint lv = 1; lv <= _LOn; ++lv) {
				_FindCurrentCycleUpline(_AID, xp, lv);
				_SetLevelActivity(_AID, xp, lv, TRUE);
			}
		}

		_ChangeStatusALU(_AID); // update auto level up status
	}

	// Account upgrade level manually, fee from wallet
	function _UpgradeLevelManually(
		uint _AID,
		uint _XPro,
		uint _LFrom,
		uint _LTo
	) external onlyTuktu returns (bool success_) {
		for (uint i = _LFrom; i <= _LTo; ++i) {
			_FindCurrentCycleUpline(_AID, _XPro, i);
			_SetLevelActivity(_AID, _XPro, i, TRUE);
			emit Upgraded(block.timestamp, _AID, _XPro, i);
		}
		success_ = true;

		// If locked before, then unlock
		_UnlockWhenUpgraded(_AID, _XPro, _LFrom);

		// Auto level up: locked to upgrade to next level
		if (isAutoLevelUp(_AID)) {
			if (_LTo + 1 > 15) return success_;
			if (_XPro == X3 && _LTo + 1 > 2) return success_;
			_LockedToUpgrade(_AID, _XPro, _LTo + 1);
		}
	}

	/*----------------------------------------------------------------------------------------------------*/

	/**
	 * Upgrade level when enough balance
	 * else lock for require upgrade
	 */
	function _UpgradeLevel(uint _AID, uint _XPro, uint _LTo) private {
		if (Balances.AvailableToUpgrade(_AID) >= Tuktus.PirceOfLevel(_LTo)) {
			_FindCurrentCycleUpline(_AID, _XPro, _LTo);
			_SetLevelActivity(_AID, _XPro, _LTo, TRUE);
			emit Upgraded(block.timestamp, _AID, _XPro, _LTo);

			// If locked before, then unlock
			_UnlockWhenUpgraded(_AID, _XPro, _LTo);

			// Auto level up: locked to upgrade to next level
			if (isAutoLevelUp(_AID)) {
				if (_LTo + 1 > 15) return;
				if (_XPro == X3 && _LTo + 1 > 2) return;
				_LockedToUpgrade(_AID, _XPro, _LTo + 1);
			}
		} else _LockedToUpgrade(_AID, _XPro, _LTo); // If not enough balance then locking
	}

	/**
	 * Recycling and check require upgrade
	 * Only on account recycling will the account be checked for the required upgrade
	 * Cycle 1: free, cycle 2: require locked, cycle 3: require upgrade level
	 */
	function _Recycling(uint _AID, uint _XPro, uint _Level) internal override returns (uint cycleCount_) {
		cycleCount_ = super._Recycling(_AID, _XPro, _Level);
		emit Recycled(block.timestamp, _AID, _XPro, _Level, cycleCount_);

		// unlocked when recycle
		uint levelCost = Tuktus.PirceOfLevel(_Level);
		if (Balances.LockedRecycleOf(_AID) >= levelCost) Balances._UnLocked(_AID, 0, levelCost);

		// New cycle
		_FindCurrentCycleUpline(_AID, _XPro, _Level);

		// Check require upgrade
		if (_Level >= 15) return cycleCount_;
		if (_XPro == X3 && _Level >= 2) return cycleCount_;
		if (isLevelActivated(_AID, _XPro, _Level + 1)) return cycleCount_;

		if (cycleCount_ == 1 && isAutoLevelUp(_AID))
			_UpgradeLevel(_AID, _XPro, _Level + 1); // If auto then instant upgrade
		else if (cycleCount_ > 1) _UpgradeLevel(_AID, _XPro, _Level + 1); // If not auto then require locked from cycle 2
	}

	/**
	 *
	 */
	function _ShareReward(uint _AID, uint _XPro, uint _Level) private returns (bool success_) {
		uint lc = Tuktus.PirceOfLevel(_Level);
		require(Balances.TotalBalanceOf(_AID) >= lc, "ShareReward: not enough balance to recycle");

		Cycle storage ccu1 = GetCurrentCycle(_AID, _XPro, _Level);
		uint cu1 = ccu1.CycleUplineID;
		if (cu1 == 0) return true; // cu1 = 0 means _A = root : do nothing

		if (_XPro == X3) {
			if (ccu1.XY[1][3] == _AID) Balances._Locking(cu1, 0, lc); // lock for recycle
			return Balances._TransferReward(_AID, cu1, lc);
		}

		Cycle storage ccu2 = GetCurrentCycle(cu1, _XPro, _Level);
		uint cu2 = ccu2.CycleUplineID;
		if (cu2 == 0) return Balances._TransferReward(_AID, cu1, lc); // cu2 = 0 means cu1 = root : cu1 gets all the rewards
		uint acu2;

		if (_XPro == X6 || _XPro == X7) {
			acu2 = lc;

			// lock for recycle
			if (_XPro == X6 && ccu2.XY[2][4] == _AID) Balances._Locking(cu2, 0, acu2);
			else if (_XPro == X7 && ccu2.XY[2][9] == _AID) Balances._Locking(cu2, 0, acu2);

			if (CFStatus) {
				// Community fund actived, CF ratio = 20%
				acu2 = (acu2 * 8) / 10;
				CFLookup.AddNoDuplicate(_AID);
				_PendingToCF(_AID, _XPro == X6 ? BINARY : TERNARY, lc - acu2); // X6: BINARY, X7: TERNARY
				Balances._TransferReward(_AID, Accounts.CFID(), lc - acu2);
			}
			return Balances._TransferReward(_AID, cu2, acu2);
		}

		Cycle storage ccu3 = GetCurrentCycle(cu2, _XPro, _Level);
		uint cu3 = ccu3.CycleUplineID;
		if (cu3 == 0) return Balances._TransferReward(_AID, cu2, lc); // cu3 = 0 means cu2 = root : cu2 gets all the rewards
		uint acu3;

		if (_XPro == X8 || _XPro == X9) {
			acu2 = (lc * 3) / 10;
			acu3 = (lc * 7) / 10;

			// lock for recycle
			if (_XPro == X8) {
				if (ccu2.XY[2][4] == _AID) Balances._Locking(cu2, 0, acu2);
				if (ccu3.XY[3][8] == _AID) Balances._Locking(cu3, 0, acu3);
			} else {
				if (ccu2.XY[2][9] == _AID) Balances._Locking(cu2, 0, acu2);
				if (ccu3.XY[3][27] == _AID) Balances._Locking(cu3, 0, acu3);
			}

			if (CFStatus) {
				// Community fund actived, CF ratio = 20%
				acu2 = (acu2 * 8) / 10;
				acu3 = (acu3 * 8) / 10;
				CFLookup.AddNoDuplicate(_AID);
				_PendingToCF(_AID, _XPro == X8 ? BINARY : TERNARY, (lc - (acu2 + acu3))); // X8: BINARY, X9: TERNARY
				Balances._TransferReward(_AID, Accounts.CFID(), lc - (acu2 + acu3));
			}
			return (Balances._TransferReward(_AID, cu2, acu2) && Balances._TransferReward(_AID, cu3, acu3));
		}
	}

	/**
	 * Find current upline on cycle upline
	 * and update for _AID in current cycle of upline
	 */
	function _FindCurrentCycleUpline(uint _AID, uint _XPro, uint _Level) private {
		uint C = _FindCycleUpline(_AID, _XPro, _Level);
		if (C == 0) return; // _A = root

		uint pendingtorecycle;
		Cycle storage CurrentCycle = GetCurrentCycle(C, _XPro, _Level); // C

		if (_XPro == X3) {
			uint ay_L1C = ++CurrentCycle.XCount[1]; // Position of _A on line 1 of C
			CurrentCycle.XY[1][ay_L1C] = _AID; // Set _A on C (line 1 of C)
			if (ay_L1C == 3) pendingtorecycle = C;

			// Update _A: C is (C and is) current cycle upline of _A
			GetCurrentCycle(_AID, X3, _Level).CycleUplineID = C;
		} else if (_XPro == X6) {
			// BINARY, 2 LINE

			if (CurrentCycle.XCount[1] < 2) {
				// Line 1
				uint ay_L1C = ++CurrentCycle.XCount[1];
				CurrentCycle.XY[1][ay_L1C] = _AID; // Set _A on C (line 1 of C)

				uint B = CurrentCycle.CycleUplineID;
				if (B != 0) {
					CurrentCycle = GetCurrentCycle(B, _XPro, _Level); // B

					uint cy_L1B = CurrentCycle.XY[1][1] == C ? 1 : 2;
					uint ay_L2B = cy_L1B == 1 ? ay_L1C : ay_L1C + 2;
					CurrentCycle.XY[2][ay_L2B] = _AID; // Set _A on B (line 2 of B)
					if (++CurrentCycle.XCount[2] == 4) pendingtorecycle = B;
				}

				// Update _A: C is (C and is) current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = C;
			} else if (CurrentCycle.XCount[2] < 4) {
				// line 2
				uint ay_L2C = ++CurrentCycle.XCount[2];
				CurrentCycle.XY[2][ay_L2C] = _AID; // Set _A on C (line 2 of C)
				if (ay_L2C == 4) pendingtorecycle = C; // Recycling C

				uint D = ay_L2C > 2 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(D, _XPro, _Level);
				uint ay_L1D = ay_L2C > 2 ? ay_L2C - 2 : ay_L2C;
				CurrentCycle.XY[1][ay_L1D] = _AID; // Set _A on D (line 1 of D)
				++CurrentCycle.XCount[1];

				// Update _A: D is current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = D;
			}
		} else if (_XPro == X8) {
			// BINARY, 3 LINE

			if (CurrentCycle.XCount[1] < 2) {
				// Line 1
				uint ay_L1C = ++CurrentCycle.XCount[1];
				CurrentCycle.XY[1][ay_L1C] = _AID; // Set _A on C (line 1 of C)

				uint B = CurrentCycle.CycleUplineID;
				if (B != 0) {
					CurrentCycle = GetCurrentCycle(B, _XPro, _Level); // B

					uint cy_L1B = CurrentCycle.XY[1][1] == C ? 1 : 2;
					uint ay_L2B = cy_L1B == 1 ? ay_L1C : ay_L1C + 2;
					CurrentCycle.XY[2][ay_L2B] = _AID; // Set _A on B (line 2 of B)
					++CurrentCycle.XCount[2];

					uint A = CurrentCycle.CycleUplineID;
					if (A != 0) {
						CurrentCycle = GetCurrentCycle(A, _XPro, _Level);

						uint by_L1A = CurrentCycle.XY[1][1] == B ? 1 : 2;
						uint ay_L3A = by_L1A == 1 ? ay_L2B : ay_L2B + 4;
						CurrentCycle.XY[3][ay_L3A] = _AID; // Set _A on A (line 3 of A)

						if (++CurrentCycle.XCount[3] == 8) pendingtorecycle = A; // Recycling A
					}
				}

				// Update _A: C is (C and is) current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = C;
			} else if (CurrentCycle.XCount[2] < 4) {
				// line 2
				uint B = CurrentCycle.CycleUplineID;

				uint ay_L2C = ++CurrentCycle.XCount[2];
				CurrentCycle.XY[2][ay_L2C] = _AID; // Set _A on C (line 2 of C)

				uint D = ay_L2C > 2 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(D, _XPro, _Level);
				uint ay_L1D = ay_L2C > 2 ? ay_L2C - 2 : ay_L2C;
				CurrentCycle.XY[1][ay_L1D] = _AID; // Set _A on D (line 1 of D)
				++CurrentCycle.XCount[1];

				if (B != 0) {
					CurrentCycle = GetCurrentCycle(B, _XPro, _Level);

					uint cy_L1B = CurrentCycle.XY[1][1] == C ? 1 : 2; // Position of C on line 1 of B
					uint ay_L3B = cy_L1B == 1 ? ay_L2C : ay_L2C + 4;
					CurrentCycle.XY[3][ay_L3B] = _AID; // Set _A on B (line 3 of B)

					if (++CurrentCycle.XCount[3] == 8) pendingtorecycle = B; // Recycling B
				}

				// Update _A: D is current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = D;
			} else if (CurrentCycle.XCount[3] < 8) {
				// line 3
				uint ay_L3C = ++CurrentCycle.XCount[3];
				CurrentCycle.XY[3][ay_L3C] = _AID; // Set _A on C (line 3 of C)
				if (ay_L3C == 8) pendingtorecycle = C; // Recycling C

				uint D = ay_L3C > 4 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(D, _XPro, _Level);
				uint ay_L2D = ay_L3C > 4 ? ay_L3C - 4 : ay_L3C;
				CurrentCycle.XY[2][ay_L2D] = _AID; // Set _A on D (line 2 of D)
				++CurrentCycle.XCount[2];

				uint E = ay_L2D > 2 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(E, _XPro, _Level);
				uint ay_L1E = ay_L2D > 2 ? ay_L2D - 2 : ay_L2D;
				CurrentCycle.XY[1][ay_L1E] = _AID; // Set _A on E (line 1 of E)
				++CurrentCycle.XCount[1];

				// Update _A: E is current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = E;
			}
		} else if (_XPro == X7) {
			// TERNARY, 2 LINE

			if (CurrentCycle.XCount[1] < 3) {
				// Line 1
				uint ay_L1C = ++CurrentCycle.XCount[1];
				CurrentCycle.XY[1][ay_L1C] = _AID; // Set _A on C (line 1 of C)

				uint B = CurrentCycle.CycleUplineID;
				if (B != 0) {
					CurrentCycle = GetCurrentCycle(B, _XPro, _Level);

					uint cy_L1B = CurrentCycle.XY[1][1] == C ? 1 : CurrentCycle.XY[1][2] == C ? 2 : 3;
					// uint ay_L2B = (((cy_L1B - 1) * 3) + ay_L1C);
					CurrentCycle.XY[2][(((cy_L1B - 1) * 3) + ay_L1C)] = _AID; // Set _A on B (line 2 of B)
					if (++CurrentCycle.XCount[2] == 9) pendingtorecycle = B;
				}

				// Update _A: C is (C and is) current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = C;
			} else if (CurrentCycle.XCount[2] < 9) {
				// line 2
				uint ay_L2C = ++CurrentCycle.XCount[2];
				CurrentCycle.XY[2][ay_L2C] = _AID; // Set _A on C (line 2 of C)
				if (ay_L2C == 9) pendingtorecycle = C;

				uint D = ay_L2C > 6 ? CurrentCycle.XY[1][3] : ay_L2C > 3 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(D, _XPro, _Level);
				// uint ay_L1D = ay_L2C % 3 == 0 ? 3 : ay_L2C % 3;
				CurrentCycle.XY[1][ay_L2C % 3 == 0 ? 3 : ay_L2C % 3] = _AID; // Set _A on D (line 1 of D)
				++CurrentCycle.XCount[1];

				// Update _A: D is current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = D;
			}
		} else if (_XPro == X9) {
			// TERNARY, 3 LINE

			if (CurrentCycle.XCount[1] < 3) {
				// Line 1
				uint ay_L1C = ++CurrentCycle.XCount[1];
				CurrentCycle.XY[1][ay_L1C] = _AID; // Set _A on C (line 1 of C)

				uint B = CurrentCycle.CycleUplineID;
				if (B != 0) {
					CurrentCycle = GetCurrentCycle(B, _XPro, _Level);

					uint cy_L1B = CurrentCycle.XY[1][1] == C ? 1 : CurrentCycle.XY[1][2] == C ? 2 : 3;
					uint ay_L2B = (((cy_L1B - 1) * 3) + ay_L1C);
					CurrentCycle.XY[2][ay_L2B] = _AID; // Set _A on B (line 2 of B)
					++CurrentCycle.XCount[2];

					uint A = CurrentCycle.CycleUplineID;
					if (A != 0) {
						CurrentCycle = GetCurrentCycle(A, _XPro, _Level);

						uint by_L1A = CurrentCycle.XY[1][1] == B ? 1 : CurrentCycle.XY[1][2] == B ? 2 : 3;
						uint ay_L3A = by_L1A == 1 ? ay_L2B : by_L1A == 2 ? ay_L2B + 9 : ay_L2B + 18;
						CurrentCycle.XY[3][ay_L3A] = _AID; // Set _A on A (line 3 of A)

						if (++CurrentCycle.XCount[3] == 27) pendingtorecycle = A; // Recycling A
					}
				}

				// Update _A: C is (C and is) current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = C;
			} else if (CurrentCycle.XCount[2] < 9) {
				// line 2
				uint B = CurrentCycle.CycleUplineID;

				uint ay_L2C = ++CurrentCycle.XCount[2];
				CurrentCycle.XY[2][ay_L2C] = _AID; // Set _A on C (line 2 of C)

				uint D = ay_L2C > 6 ? CurrentCycle.XY[1][3] : ay_L2C > 3 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(D, _XPro, _Level);
				uint ay_L1D = ay_L2C > 6 ? ay_L2C - 6 : ay_L2C > 3 ? ay_L2C - 3 : ay_L2C;
				CurrentCycle.XY[1][ay_L1D] = _AID; // Set _A on D (line 1 of D)
				++CurrentCycle.XCount[1];

				if (B != 0) {
					CurrentCycle = GetCurrentCycle(B, _XPro, _Level);

					uint cy_L1B = CurrentCycle.XY[1][1] == C ? 1 : CurrentCycle.XY[1][2] == C ? 2 : 3;
					uint ay_L3B = cy_L1B == 1 ? ay_L2C : cy_L1B == 2 ? ay_L2C + 9 : ay_L2C + 18;
					CurrentCycle.XY[3][ay_L3B] = _AID; // Set _A on B (line 3 of B)
					if (++CurrentCycle.XCount[3] == 27) pendingtorecycle = B; // Recycling B
				}

				// Update _AID: D is current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = D;
			} else if (CurrentCycle.XCount[3] < 27) {
				// line 3
				uint ay_L3C = ++CurrentCycle.XCount[3];
				CurrentCycle.XY[3][ay_L3C] = _AID; // Set _A on C (line 3 of C)
				if (ay_L3C == 27) pendingtorecycle = C; // Recycling C

				uint D = ay_L3C > 18 ? CurrentCycle.XY[1][3] : ay_L3C > 9 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(D, _XPro, _Level);
				uint ay_L2D = ay_L3C > 18 ? ay_L3C - 18 : ay_L3C > 9 ? ay_L3C - 9 : ay_L3C;
				CurrentCycle.XY[2][ay_L2D] = _AID; // Set _A on D (line 2 of D)
				++CurrentCycle.XCount[2];

				uint E = ay_L2D > 6 ? CurrentCycle.XY[1][3] : ay_L2D > 3 ? CurrentCycle.XY[1][2] : CurrentCycle.XY[1][1];
				CurrentCycle = GetCurrentCycle(E, _XPro, _Level);
				uint ay_L1E = ay_L2D > 6 ? ay_L2D - 6 : ay_L2D > 3 ? ay_L2D - 3 : ay_L2D;
				CurrentCycle.XY[1][ay_L1E] = _AID; // Set _A on E (line 1 of E)
				++CurrentCycle.XCount[1];

				// Update _AID: E is current cycle upline of _A
				GetCurrentCycle(_AID, _XPro, _Level).CycleUplineID = E;
			}
		}

		_ShareReward(_AID, _XPro, _Level); // Share Reward _A to uplines
		if (pendingtorecycle != 0) _Recycling(pendingtorecycle, _XPro, _Level); // Recycling if exist
	}

	/**
	 * Find cycle upline
	 */
	function _FindCycleUpline(uint _AID, uint _XPro, uint _Level) private returns (uint CU_) {
		uint aSL = SponsorLevel(_AID);
		uint matrix = _XPro == X3 ? UNILEVEL : _XPro == X7 || _XPro == X9 ? TERNARY : BINARY;
		CU_ = _UplineOnMatrix(_AID, matrix); // 0 >> r
		if (CU_ != 0)
			while (_UplineOnMatrix(CU_, matrix) != 0) {
				if (isLevelActivated(CU_, _XPro, _Level) && SponsorLevel(CU_) >= aSL) return CU_;
				else emit LostPartner(block.timestamp, CU_, _AID, _XPro, _Level); // Over sponsor level or Level not active
				CU_ = _UplineOnMatrix(CU_, matrix);
			}
	}
}