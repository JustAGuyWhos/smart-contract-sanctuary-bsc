// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";

contract EventEmitter {
    enum TYPE {
        NATIVE_COIN_NFT_721,
        NATIVE_COIN_NFT_1155,
        ERC_20_NFT_721,
        ERC_20_NFT_1155
    }

    event SporesNFTMint(
        address indexed _to,
        address indexed _nft,
        uint256 _id,
        uint256 _amount
    );

    event SporesNFTMarketTransaction(
        address indexed _buyer,
        address indexed _seller,
        address _paymentReceiver,
        address _contractNFT,
        address _paymentToken,
        uint256 indexed _tokenId,
        uint256 _price,
        uint256 _amount,
        uint256 _fee,
        uint256 _sellId,
        TYPE _tradeType
    );

    event NewCampaign(
        uint256 indexed campaignId,
        address indexed ino,
        uint256 start,
        uint256 end
    );

    event RedeemBulk(
        address indexed nft,
        address indexed buyer,
        uint256[] tokenIds,
        address paymentToken,
        uint256 price
    );

    event Redeemed(
        address indexed owner,
        uint256[] bHerotokenIds,
        uint256[] heroesIds
    );

    function emitRedeem(
        address owner,
        uint256[] calldata bheroIds,
        uint256[] calldata heroIds
    ) external {
        emit Redeemed(owner, bheroIds, heroIds);
    }

    function redeem(
        address nft,
        address buyer,
        uint256[] calldata tokenIds,
        address paymentToken,
        uint256 price
    ) external {
        emit RedeemBulk(nft, buyer, tokenIds, paymentToken, price);
    }

    constructor() {}

    function newCampaign(
        uint256 campaignId,
        address ino,
        uint256 start,
        uint256 end
    ) external {
        emit NewCampaign(campaignId, ino, start, end);
    }

    function emitEvent(
        address _to,
        address _nft,
        uint256 _id,
        uint256 _amount
    ) external {
        emit SporesNFTMint(_to, _nft, _id, _amount);
    }

    function recover(bytes32 hash, bytes memory signature)
        external
        pure
        returns (address)
    {
        return ECDSA.recover(hash, signature);
    }

    function emitEvent(
        address _buyer,
        address _seller,
        address _paymentReceiver,
        address _contractNFT,
        address _paymentToken,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount,
        uint256 _fee,
        uint256 _sellId,
        TYPE _tradeType
    ) external {
        emit SporesNFTMarketTransaction(
            _buyer,
            _seller,
            _paymentReceiver,
            _contractNFT,
            _paymentToken,
            _tokenId,
            _price,
            _amount,
            _fee,
            _sellId,
            _tradeType
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}