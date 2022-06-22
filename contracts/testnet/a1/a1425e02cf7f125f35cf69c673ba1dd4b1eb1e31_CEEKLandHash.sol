/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

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
        require(address(this).balance >= amount, "001");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "002");
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
        return functionCall(target, data, "003");
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
        return functionCallWithValue(target, data, value, "004");
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
        require(address(this).balance >= value, "005");
        require(isContract(target), "006");

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
        return functionStaticCall(target, data, "007");
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
        require(isContract(target), "008");

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
        return functionDelegateCall(target, data, "009");
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
        require(isContract(target), "010");

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
        require(_status != _ENTERED, "042");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract CEEKLandHash is ReentrancyGuard {
    using Address for address;

    bytes32 private _pK;
    uint private _randNonce = 0;
    address private _SCOwner;
    address[] private _allowedAddressesEncode;
    address[] private _allowedAddressesDecode;
    address[] private _allowedAddressesMark;

    mapping(bytes32 => string) private _ceekUserIdHash;
    mapping(bytes32 => bool) private _ceekUserIdHashUsed;

    event HashCreated(bytes32 hash);

    function checkEncodeAddress() private view returns(bool) {
        uint256 i;

        if (_allowedAddressesEncode.length == 0) {
            return true;
        }

        for (i=0; i<_allowedAddressesEncode.length; i++) {
            if (msg.sender == _allowedAddressesEncode[i]) {
                return true;
            }
        }

        return false;
    }

    function checkDecodeAddress() private view returns(bool) {
        uint256 i;

        if (_allowedAddressesDecode.length == 0) {
            return true;
        }

        for (i=0; i<_allowedAddressesDecode.length; i++) {
            if (msg.sender == _allowedAddressesDecode[i]) {
                return true;
            }
        }

        return false;
    }

    function checkMarkAddress() private view returns(bool) {
        uint256 i;

        if (_allowedAddressesMark.length == 0) {
            return true;
        }

        for (i=0; i<_allowedAddressesMark.length; i++) {
            if (msg.sender == _allowedAddressesMark[i]) {
                return true;
            }
        }

        return false;
    }

    /*function encode(string memory ceekUserId) public nonReentrant {
       require((msg.sender==_SCOwner || checkEncodeAddress()), "Only contract owner or allowed addresses can do this");

       if (_randNonce == (2**256 - 1)) {
           _randNonce = 0;
       }
       _randNonce++;

       bytes32 h = keccak256(abi.encodePacked(_pK, block.timestamp, ceekUserId, _randNonce));
        
       _ceekUserIdHash[h] = ceekUserId;
       _ceekUserIdHashUsed[h] = false;

       emit HashCreated(h);
   } */

   function convertBytesToBytes32(bytes memory bytesArr) public pure returns(bytes32) {
    bytes memory result = new bytes(32);
    for(uint i = 64; i < 96; i++) {
        result[i-64] = bytesArr[i];
    }
    return bytes32(result);

   }

   function encode(string memory ceekUserId) public view returns(bytes memory) {
       require((msg.sender==_SCOwner || checkEncodeAddress()), "Only contract owner or allowed addresses can do this");

       return abi.encode(ceekUserId);
   }

   function decode(bytes memory ceekUserHash) public view returns(string memory) {
       require((msg.sender==_SCOwner || checkDecodeAddress()), "Only contract owner or allowed addresses can do this");
       return abi.decode(ceekUserHash,(string));
   }

   function encode2(string memory ceekUserId) public view returns(bytes32) {
       require((msg.sender==_SCOwner || checkEncodeAddress()), "Only contract owner or allowed addresses can do this");

       bytes32 result;

       result = convertBytesToBytes32(abi.encode(ceekUserId)) ^ _pK;

       return result;
   }

   function decode2(bytes32 ceekUserHash) public view returns(string memory) {
       require((msg.sender==_SCOwner || checkDecodeAddress()), "Only contract owner or allowed addresses can do this");

       bytes32 result1 = 0x0000000000000000000000000000000000000000000000000000000000000020;
       bytes32 result2 = 0x0000000000000000000000000000000000000000000000000000000000000018;
       bytes32 result3 = ceekUserHash ^ _pK;

       bytes memory b = new bytes(96);
       assembly {
           mstore(add(b, 32), result1)
           mstore(add(b, 64), result2)
           mstore(add(b, 96), result3)
       }

       return abi.decode(b,(string));
   }

   /*function decode(bytes32 hash, bool _checkUsed) public view returns(string memory) {
       require((msg.sender==_SCOwner || checkDecodeAddress()), "Only contract owner or allowed addresses can do this");
       if (_checkUsed) {
           require(!(_ceekUserIdHashUsed[hash]), "error: hash used.");
       }
       return _ceekUserIdHash[hash];
   }*/

   function markAsUsed(bytes32 hash) public nonReentrant {
       require((msg.sender==_SCOwner || checkMarkAddress()), "Only contract owner or allowed addresses can do this");
       _ceekUserIdHashUsed[hash] = true;
   }

   constructor(address _owner, address[] memory _allowedAddressesEncodeParam, address[] memory _allowedAddressesDecodeParam, address[] memory _allowedAddressesMarkParam) {
      _pK = keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender));

      _SCOwner = _owner;
      _allowedAddressesEncode = _allowedAddressesEncodeParam;
      _allowedAddressesDecode = _allowedAddressesDecodeParam;
      _allowedAddressesMark = _allowedAddressesMarkParam;
   }

    function updateParams(address[] memory _allowedAddressesEncodeParam, address[] memory _allowedAddressesDecodeParam, address[] memory _allowedAddressesMarkParam) public {
       require(msg.sender==_SCOwner, "Only contract owner can do this");

      _allowedAddressesEncode = _allowedAddressesEncodeParam;
      _allowedAddressesDecode = _allowedAddressesDecodeParam;
      _allowedAddressesMark = _allowedAddressesMarkParam;
    }

    function getPK() public view returns(bytes32) {
        //require(msg.sender==_SCOwner, "Only contract owner can do this");

        return _pK;
    }

    function setPK(bytes32 _pKParam) public {
        require(msg.sender==_SCOwner, "Only contract owner can do this");
        _pK = _pKParam;
    }
}