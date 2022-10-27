// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./interfaces/IAccumulator.sol";
import "./interfaces/IDeaccumulator.sol";
import "./interfaces/IVerifier.sol";
import "./interfaces/IPlug.sol";
import "./interfaces/IHasher.sol";
import "./utils/ReentrancyGuard.sol";

import "./SocketConfig.sol";

contract Socket is SocketConfig, ReentrancyGuard {
    enum MessageStatus {
        NOT_EXECUTED,
        SUCCESS,
        FAILED
    }

    uint256 private immutable _chainSlug;

    bytes32 private constant EXECUTOR_ROLE = keccak256("EXECUTOR");

    // incrementing nonce, should be handled in next socket version.
    uint256 private _messageCount;

    // msgId => executorAddress
    mapping(uint256 => address) private executor;

    // msgId => message status
    mapping(uint256 => MessageStatus) private _messagesStatus;

    IHasher public hasher;
    IVault public override vault;

    /**
     * @param chainSlug_ socket chain slug (should not be more than uint32)
     */
    constructor(
        uint32 chainSlug_,
        address hasher_,
        address vault_
    ) {
        _setHasher(hasher_);
        _setVault(vault_);

        _chainSlug = chainSlug_;
    }

    function setHasher(address hasher_) external onlyOwner {
        _setHasher(hasher_);
    }

    function setVault(address vault_) external onlyOwner {
        _setVault(vault_);
    }

    /**
     * @notice registers a message
     * @dev Packs the message and includes it in a packet with accumulator
     * @param remoteChainSlug_ the remote chain id
     * @param msgGasLimit_ the gas limit needed to execute the payload on remote
     * @param payload_ the data which is needed by plug at inbound call on remote
     */
    function outbound(
        uint256 remoteChainSlug_,
        uint256 msgGasLimit_,
        bytes calldata payload_
    ) external payable override {
        PlugConfig memory plugConfig = plugConfigs[msg.sender][
            remoteChainSlug_
        ];

        // Packs the local plug, local chain id, remote chain id and nonce
        // _messageCount++ will take care of msg id overflow as well
        // msgId(256) = localChainSlug(32) | nonce(224)
        uint256 msgId = (uint256(uint32(_chainSlug)) << 224) | _messageCount++;

        vault.deductFee{value: msg.value}(
            remoteChainSlug_,
            plugConfig.integrationType
        );

        bytes32 packedMessage = hasher.packMessage(
            _chainSlug,
            msg.sender,
            remoteChainSlug_,
            plugConfig.remotePlug,
            msgId,
            msgGasLimit_,
            payload_
        );

        IAccumulator(plugConfig.accum).addPackedMessage(packedMessage);
        emit MessageTransmitted(
            _chainSlug,
            msg.sender,
            remoteChainSlug_,
            plugConfig.remotePlug,
            msgId,
            msgGasLimit_,
            msg.value,
            payload_
        );
    }

    /**
     * @notice executes a message
     * @param msgGasLimit gas limit needed to execute the inbound at remote
     * @param msgId message id packed with local plug, local chainSlug, remote ChainSlug and nonce
     * @param localPlug remote plug address
     * @param payload the data which is needed by plug at inbound call on remote
     * @param verifyParams_ the details needed for message verification
     */
    function execute(
        uint256 msgGasLimit,
        uint256 msgId,
        address localPlug,
        bytes calldata payload,
        ISocket.VerificationParams calldata verifyParams_
    ) external override nonReentrant {
        if (!_hasRole(EXECUTOR_ROLE, msg.sender)) revert ExecutorNotFound();
        if (executor[msgId] != address(0)) revert MessageAlreadyExecuted();
        executor[msgId] = msg.sender;

        PlugConfig memory plugConfig = plugConfigs[localPlug][
            verifyParams_.remoteChainSlug
        ];
        bytes32 packedMessage = hasher.packMessage(
            verifyParams_.remoteChainSlug,
            plugConfig.remotePlug,
            _chainSlug,
            localPlug,
            msgId,
            msgGasLimit,
            payload
        );

        _verify(packedMessage, plugConfig, verifyParams_);
        _execute(localPlug, msgGasLimit, msgId, payload);
    }

    function _verify(
        bytes32 packedMessage,
        PlugConfig memory plugConfig,
        ISocket.VerificationParams calldata verifyParams_
    ) internal view {
        (bool isVerified, bytes32 root) = IVerifier(plugConfig.verifier)
            .verifyPacket(verifyParams_.packetId, plugConfig.integrationType);

        if (!isVerified) revert VerificationFailed();

        if (
            !IDeaccumulator(plugConfig.deaccum).verifyMessageInclusion(
                root,
                packedMessage,
                verifyParams_.deaccumProof
            )
        ) revert InvalidProof();
    }

    function _execute(
        address localPlug,
        uint256 msgGasLimit,
        uint256 msgId,
        bytes calldata payload
    ) internal {
        try IPlug(localPlug).inbound{gas: msgGasLimit}(payload) {
            _messagesStatus[msgId] = MessageStatus.SUCCESS;
            emit ExecutionSuccess(msgId);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            _messagesStatus[msgId] = MessageStatus.FAILED;
            emit ExecutionFailed(msgId, reason);
        } catch (bytes memory reason) {
            // catch failing assert()
            _messagesStatus[msgId] = MessageStatus.FAILED;
            emit ExecutionFailedBytes(msgId, reason);
        }
    }

    /**
     * @notice adds an executor
     * @param executor_ executor address
     */
    function grantExecutorRole(address executor_) external onlyOwner {
        _grantRole(EXECUTOR_ROLE, executor_);
    }

    /**
     * @notice removes an executor from `remoteChainSlug_` chain list
     * @param executor_ executor address
     */
    function revokeExecutorRole(address executor_) external onlyOwner {
        _revokeRole(EXECUTOR_ROLE, executor_);
    }

    function _setHasher(address hasher_) private {
        hasher = IHasher(hasher_);
    }

    function _setVault(address vault_) private {
        vault = IVault(vault_);
    }

    function chainSlug() external view returns (uint256) {
        return _chainSlug;
    }

    function getMessageStatus(uint256 msgId_)
        external
        view
        returns (MessageStatus)
    {
        return _messagesStatus[msgId_];
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IAccumulator {
    /**
     * @notice emits the message details when it arrives
     * @param packedMessage the message packed with payload, fees and config
     * @param packetId an incremental id assigned to each new packet
     * @param newRootHash the packed message hash (to be replaced with the root hash of the merkle tree)
     */
    event MessageAdded(
        bytes32 packedMessage,
        uint256 packetId,
        bytes32 newRootHash
    );

    /**
     * @notice emits when the packet is sealed and indicates it can be send to remote
     * @param rootHash the packed message hash (to be replaced with the root hash of the merkle tree)
     * @param packetId an incremental id assigned to each new packet
     */
    event PacketComplete(bytes32 rootHash, uint256 packetId);

    /**
     * @notice adds the packed message to a packet
     * @dev this should be only executable by socket
     * @dev it will be later replaced with a function adding each message to a merkle tree
     * @param packedMessage the message packed with payload, fees and config
     */
    function addPackedMessage(bytes32 packedMessage) external;

    /**
     * @notice returns the latest packet details which needs to be sealed
     * @return root root hash of the latest packet which is not yet sealed
     * @return packetId latest packet id which is not yet sealed
     */
    function getNextPacketToBeSealed()
        external
        view
        returns (bytes32 root, uint256 packetId);

    /**
     * @notice returns the root of packet for given id
     * @param id the id assigned to packet
     * @return root root hash corresponding to given id
     */
    function getRootById(uint256 id) external view returns (bytes32 root);

    /**
     * @notice seals the packet
     * @dev also indicates the packet is ready to be shipped and no more messages can be added now.
     * @dev this should be executable by notary only
     * @return root root hash of the packet
     * @return packetId id of the packed sealed
     * @return remoteChainSlug remote chain id for the packet sealed
     */
    function sealPacket()
        external
        returns (
            bytes32 root,
            uint256 packetId,
            uint256 remoteChainSlug
        );
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IDeaccumulator {
    /**
     * @notice returns if the packed message is the part of a merkle tree or not
     * @param root_ root hash of the merkle tree
     * @param packedMessage_ packed message which needs to be verified
     * @param proof_ proof used to determine the inclusion
     */
    function verifyMessageInclusion(
        bytes32 root_,
        bytes32 packedMessage_,
        bytes calldata proof_
    ) external pure returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IVerifier {
    /**
     * @notice verifies if the packet satisfies needed checks before execution
     * @param packetId_ packet id
     */
    function verifyPacket(uint256 packetId_, bytes32 integrationType_)
        external
        view
        returns (bool, bytes32);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface IPlug {
    /**
     * @notice executes the message received from source chain
     * @dev this should be only executable by socket
     * @param payload_ the data which is needed by plug at inbound call on remote
     */
    function inbound(bytes calldata payload_) external payable;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface IHasher {
    /**
     * @notice returns the bytes32 hash of the message packed
     * @param srcChainSlug src chain id
     * @param srcPlug address of plug at source
     * @param dstChainSlug remote chain id
     * @param dstPlug address of plug at remote
     * @param msgId message id assigned at outbound
     * @param msgGasLimit gas limit which is expected to be consumed by the inbound transaction on plug
     * @param payload the data packed which is used by inbound for execution
     */
    function packMessage(
        uint256 srcChainSlug,
        address srcPlug,
        uint256 dstChainSlug,
        address dstPlug,
        uint256 msgId,
        uint256 msgGasLimit,
        bytes calldata payload
    ) external returns (bytes32);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.7;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./interfaces/ISocket.sol";
import "./utils/AccessControl.sol";

abstract contract SocketConfig is ISocket, AccessControl(msg.sender) {
    // integrationType => remoteChainSlug => address
    mapping(bytes32 => mapping(uint256 => address)) public verifiers;
    mapping(bytes32 => mapping(uint256 => address)) public accums;
    mapping(bytes32 => mapping(uint256 => address)) public deaccums;
    mapping(bytes32 => mapping(uint256 => bool)) public configExists;

    // plug => remoteChainSlug => config(verifiers, accums, deaccums, remotePlug)
    mapping(address => mapping(uint256 => PlugConfig)) public plugConfigs;

    function addConfig(
        uint256 remoteChainSlug_,
        address accum_,
        address deaccum_,
        address verifier_,
        string calldata integrationType_
    ) external returns (bytes32 integrationType) {
        integrationType = keccak256(abi.encode(integrationType_));
        if (configExists[integrationType][remoteChainSlug_])
            revert ConfigExists();

        verifiers[integrationType][remoteChainSlug_] = verifier_;
        accums[integrationType][remoteChainSlug_] = accum_;
        deaccums[integrationType][remoteChainSlug_] = deaccum_;
        configExists[integrationType][remoteChainSlug_] = true;

        emit ConfigAdded(
            accum_,
            deaccum_,
            verifier_,
            remoteChainSlug_,
            integrationType
        );
    }

    /// @inheritdoc ISocket
    function setPlugConfig(
        uint256 remoteChainSlug_,
        address remotePlug_,
        string memory integrationType_
    ) external override {
        bytes32 integrationType = keccak256(abi.encode(integrationType_));
        if (!configExists[integrationType][remoteChainSlug_])
            revert InvalidIntegrationType();

        PlugConfig storage plugConfig = plugConfigs[msg.sender][
            remoteChainSlug_
        ];

        plugConfig.remotePlug = remotePlug_;
        plugConfig.accum = accums[integrationType][remoteChainSlug_];
        plugConfig.deaccum = deaccums[integrationType][remoteChainSlug_];
        plugConfig.verifier = verifiers[integrationType][remoteChainSlug_];
        plugConfig.integrationType = integrationType;

        emit PlugConfigSet(remotePlug_, remoteChainSlug_, integrationType);
    }

    function getConfigs(
        uint256 remoteChainSlug_,
        string memory integrationType_
    )
        external
        view
        returns (
            address,
            address,
            address
        )
    {
        bytes32 integrationType = keccak256(abi.encode(integrationType_));
        return (
            accums[integrationType][remoteChainSlug_],
            deaccums[integrationType][remoteChainSlug_],
            verifiers[integrationType][remoteChainSlug_]
        );
    }

    function getPlugConfig(uint256 remoteChainSlug_, address plug_)
        external
        view
        returns (
            address accum,
            address deaccum,
            address verifier,
            address remotePlug
        )
    {
        PlugConfig memory plugConfig = plugConfigs[plug_][remoteChainSlug_];
        return (
            plugConfig.accum,
            plugConfig.deaccum,
            plugConfig.verifier,
            plugConfig.remotePlug
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./IVault.sol";

interface ISocket {
    // to handle stack too deep
    struct VerificationParams {
        uint256 remoteChainSlug;
        uint256 packetId;
        bytes deaccumProof;
    }

    // TODO: add confs and blocking/non-blocking
    struct PlugConfig {
        address remotePlug;
        address accum;
        address deaccum;
        address verifier;
        bytes32 integrationType;
    }

    /**
     * @notice emits the message details when a new message arrives at outbound
     * @param localChainSlug local chain id
     * @param localPlug local plug address
     * @param dstChainSlug remote chain id
     * @param dstPlug remote plug address
     * @param msgId message id packed with remoteChainSlug and nonce
     * @param msgGasLimit gas limit needed to execute the inbound at remote
     * @param fees fees provided by msg sender
     * @param payload the data which will be used by inbound at remote
     */
    event MessageTransmitted(
        uint256 localChainSlug,
        address localPlug,
        uint256 dstChainSlug,
        address dstPlug,
        uint256 msgId,
        uint256 msgGasLimit,
        uint256 fees,
        bytes payload
    );

    event ConfigAdded(
        address accum_,
        address deaccum_,
        address verifier_,
        uint256 remoteChainSlug_,
        bytes32 integrationType_
    );

    /**
     * @notice emits the status of message after inbound call
     * @param msgId msg id which is executed
     */
    event ExecutionSuccess(uint256 msgId);

    /**
     * @notice emits the status of message after inbound call
     * @param msgId msg id which is executed
     * @param result if message reverts, returns the revert message
     */
    event ExecutionFailed(uint256 msgId, string result);

    /**
     * @notice emits the error message in bytes after inbound call
     * @param msgId msg id which is executed
     * @param result if message reverts, returns the revert message in bytes
     */
    event ExecutionFailedBytes(uint256 msgId, bytes result);

    event PlugConfigSet(
        address remotePlug,
        uint256 remoteChainSlug,
        bytes32 integrationType
    );

    error InvalidProof();

    error VerificationFailed();

    error MessageAlreadyExecuted();

    error ExecutorNotFound();

    error ConfigExists();

    error InvalidIntegrationType();

    function vault() external view returns (IVault);

    /**
     * @notice registers a message
     * @dev Packs the message and includes it in a packet with accumulator
     * @param remoteChainSlug_ the remote chain id
     * @param msgGasLimit_ the gas limit needed to execute the payload on remote
     * @param payload_ the data which is needed by plug at inbound call on remote
     */
    function outbound(
        uint256 remoteChainSlug_,
        uint256 msgGasLimit_,
        bytes calldata payload_
    ) external payable;

    /**
     * @notice executes a message
     * @param msgGasLimit gas limit needed to execute the inbound at remote
     * @param msgId message id packed with remoteChainSlug and nonce
     * @param localPlug remote plug address
     * @param payload the data which is needed by plug at inbound call on remote
     * @param verifyParams_ the details needed for message verification
     */
    function execute(
        uint256 msgGasLimit,
        uint256 msgId,
        address localPlug,
        bytes calldata payload,
        ISocket.VerificationParams calldata verifyParams_
    ) external;

    /**
     * @notice sets the config specific to the plug
     * @param remoteChainSlug_ the remote chain id
     * @param remotePlug_ address of plug present at remote chain to call inbound
     * @param integrationType_ the name of accum to be used
     */
    function setPlugConfig(
        uint256 remoteChainSlug_,
        address remotePlug_,
        string memory integrationType_
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./Ownable.sol";

abstract contract AccessControl is Ownable {
    // role => address => permit
    mapping(bytes32 => mapping(address => bool)) private _permits;

    event RoleGranted(bytes32 indexed role, address indexed grantee);

    event RoleRevoked(bytes32 indexed role, address indexed revokee);

    error NoPermit(bytes32 role);

    constructor(address owner_) Ownable(owner_) {}

    modifier onlyRole(bytes32 role) {
        if (!_permits[role][msg.sender]) revert NoPermit(role);
        _;
    }

    function grantRole(bytes32 role, address grantee)
        external
        virtual
        onlyOwner
    {
        _grantRole(role, grantee);
    }

    function revokeRole(bytes32 role, address revokee)
        external
        virtual
        onlyOwner
    {
        _revokeRole(role, revokee);
    }

    function _grantRole(bytes32 role, address grantee) internal {
        _permits[role][grantee] = true;
        emit RoleGranted(role, grantee);
    }

    function _revokeRole(bytes32 role, address revokee) internal {
        _permits[role][revokee] = false;
        emit RoleRevoked(role, revokee);
    }

    function hasRole(bytes32 role, address _address)
        external
        view
        returns (bool)
    {
        return _hasRole(role, _address);
    }

    function _hasRole(bytes32 role, address _address)
        internal
        view
        returns (bool)
    {
        return _permits[role][_address];
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface IVault {
    /**
     * @notice deducts the fee required to bridge the packet using msgGasLimit
     * @param remoteChainSlug_ remote chain id
     * @param integrationType_ for the given message
     */
    function deductFee(uint256 remoteChainSlug_, bytes32 integrationType_)
        external
        payable;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

abstract contract Ownable {
    address private _owner;
    address private _nominee;

    event OwnerNominated(address indexed nominee);
    event OwnerClaimed(address indexed claimer);

    error OnlyOwner();
    error OnlyNominee();

    constructor(address owner_) {
        _claimOwner(owner_);
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) revert OnlyOwner();
        _;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function nominee() external view returns (address) {
        return _nominee;
    }

    function nominateOwner(address nominee_) external {
        if (msg.sender != _owner) revert OnlyOwner();
        _nominee = nominee_;
        emit OwnerNominated(_nominee);
    }

    function claimOwner() external {
        if (msg.sender != _nominee) revert OnlyNominee();
        _claimOwner(msg.sender);
    }

    function _claimOwner(address claimer_) internal {
        _owner = claimer_;
        _nominee = address(0);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IVerifier.sol";
import "../interfaces/INotary.sol";
import "../interfaces/ISocket.sol";

import "../utils/Ownable.sol";

contract Verifier is IVerifier, Ownable {
    INotary public notary;
    ISocket public socket;
    uint256 public immutable timeoutInSeconds;

    // this integration type is set for fast accum
    // it is compared against the passed accum type to decide packet verification mode
    bytes32 public immutable fastIntegrationType;

    event NotarySet(address notary_);
    event SocketSet(address socket_);

    constructor(
        address owner_,
        address notary_,
        address socket_,
        uint256 timeoutInSeconds_,
        bytes32 fastIntegrationType_
    ) Ownable(owner_) {
        notary = INotary(notary_);
        socket = ISocket(socket_);
        fastIntegrationType = fastIntegrationType_;

        // TODO: restrict the timeout durations to a few select options
        timeoutInSeconds = timeoutInSeconds_;
    }

    /**
     * @notice updates notary
     * @param notary_ address of Notary
     */
    function setNotary(address notary_) external onlyOwner {
        notary = INotary(notary_);
        emit NotarySet(notary_);
    }

    /**
     * @notice updates socket
     * @param socket_ address of Socket
     */
    function setSocket(address socket_) external onlyOwner {
        socket = ISocket(socket_);
        emit SocketSet(socket_);
    }

    /**
     * @notice verifies if the packet satisfies needed checks before execution
     * @param packetId_ packet id
     * @param fastIntegrationType_ integration type for plug
     */
    function verifyPacket(uint256 packetId_, bytes32 fastIntegrationType_)
        external
        view
        override
        returns (bool, bytes32)
    {
        bool isFast = fastIntegrationType == fastIntegrationType_
            ? true
            : false;

        (
            INotary.PacketStatus status,
            uint256 packetArrivedAt,
            uint256 pendingAttestations,
            bytes32 root
        ) = notary.getPacketDetails(packetId_);

        if (status != INotary.PacketStatus.PROPOSED) return (false, root);
        // if timed out, return true irrespective of fast or slow accum
        if (block.timestamp - packetArrivedAt > timeoutInSeconds)
            return (true, root);

        // if fast, check attestations
        if (isFast) {
            if (pendingAttestations == 0) return (true, root);
        }

        return (false, root);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface INotary {
    struct PacketDetails {
        bytes32 remoteRoots;
        uint256 attestations;
        uint256 timeRecord;
    }

    enum PacketStatus {
        NOT_PROPOSED,
        PROPOSED
    }

    /**
     * @notice emits when a new signature verifier contract is set
     * @param signatureVerifier_ address of new verifier contract
     */
    event SignatureVerifierSet(address signatureVerifier_);

    /**
     * @notice emits the verification and seal confirmation of a packet
     * @param attester address of attester
     * @param accumAddress address of accumulator at local
     * @param packetId packed id
     * @param signature signature of attester
     */
    event PacketVerifiedAndSealed(
        address indexed attester,
        address indexed accumAddress,
        uint256 indexed packetId,
        bytes signature
    );

    /**
     * @notice emits the packet details when proposed at remote
     * @param packetId packet id
     * @param root packet root
     */
    event PacketProposed(uint256 indexed packetId, bytes32 root);

    /**
     * @notice emits when a packet is attested by attester at remote
     * @param attester address of attester
     * @param packetId packet id
     */
    event PacketAttested(address indexed attester, uint256 indexed packetId);

    /**
     * @notice emits the root details when root is replaced by owner
     * @param packetId packet id
     * @param oldRoot old root
     * @param newRoot old root
     */
    event PacketRootUpdated(uint256 packetId, bytes32 oldRoot, bytes32 newRoot);

    error InvalidAttester();
    error AttesterExists();
    error AttesterNotFound();
    error AlreadyAttested();
    error RootNotFound();

    /**
     * @notice verifies the attester and seals a packet
     * @param accumAddress_ address of accumulator at local
     * @param signature_ signature of attester
     */
    function seal(address accumAddress_, bytes calldata signature_) external;

    /**
     * @notice to propose a new packet
     * @param packetId_ packet id
     * @param root_ root hash of packet
     * @param signature_ signature of proposer
     */
    function attest(
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external;

    /**
     * @notice returns the root of given packet
     * @param packetId_ packet id
     * @return root_ root hash
     */
    function getRemoteRoot(uint256 packetId_)
        external
        view
        returns (bytes32 root_);

    /**
     * @notice returns the packet status
     * @param packetId_ packet id
     * @return status_ status as enum PacketStatus
     */
    function getPacketStatus(uint256 packetId_)
        external
        view
        returns (PacketStatus status_);

    /**
     * @notice returns the packet details needed by verifier
     * @param packetId_ packet id
     * @return status packet status
     * @return packetArrivedAt time at which packet was proposed
     * @return pendingAttestations number of attestations remaining
     * @return root root hash
     */
    function getPacketDetails(uint256 packetId_)
        external
        view
        returns (
            PacketStatus status,
            uint256 packetArrivedAt,
            uint256 pendingAttestations,
            bytes32 root
        );
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../utils/Ownable.sol";
import "../interfaces/IVault.sol";

contract Vault is IVault, Ownable {
    // integration type from socket => remote chain slug => fees
    mapping(bytes32 => mapping(uint256 => uint256)) public minFees;

    error InsufficientFees();

    /**
     * @notice emits when fee is deducted at outbound
     * @param amount_ total fee amount
     */
    event FeeDeducted(uint256 amount_);
    event FeesSet(
        uint256 minFees_,
        uint256 remoteChainSlug_,
        bytes32 integrationType_
    );

    constructor(address owner_) Ownable(owner_) {}

    /// @inheritdoc IVault
    function deductFee(uint256 remoteChainSlug_, bytes32 integrationType_)
        external
        payable
        override
    {
        if (msg.value < minFees[integrationType_][remoteChainSlug_])
            revert InsufficientFees();
        emit FeeDeducted(msg.value);
    }

    /**
     * @notice updates the fee required to bridge a message for give chain and config
     * @param minFees_ fees
     * @param integrationType_ config for which fees is needed
     * @param integrationType_ config for which fees is needed
     */
    function setFees(
        uint256 minFees_,
        uint256 remoteChainSlug_,
        bytes32 integrationType_
    ) external onlyOwner {
        minFees[integrationType_][remoteChainSlug_] = minFees_;
        emit FeesSet(minFees_, remoteChainSlug_, integrationType_);
    }

    /**
     * @notice transfers the `amount_` ETH to `account_`
     * @param account_ address to transfer ETH
     * @param amount_ amount to transfer
     */
    function claimFee(address account_, uint256 amount_) external onlyOwner {
        require(account_ != address(0));
        (bool success, ) = account_.call{value: amount_}("");
        require(success, "Transfer failed.");
    }

    /**
     * @notice returns the fee required to bridge a message
     * @param integrationType_ config for which fees is needed
     */
    function getFees(bytes32 integrationType_, uint256 remoteChainSlug_)
        external
        view
        returns (uint256)
    {
        return minFees[integrationType_][remoteChainSlug_];
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IPlug.sol";
import "../interfaces/ISocket.sol";

contract Messenger is IPlug {
    // immutables
    address private immutable _socket;
    uint256 private immutable _chainSlug;

    address private _owner;
    bytes32 private _message;
    uint256 public msgGasLimit;

    bytes32 private constant _PING = keccak256("PING");
    bytes32 private constant _PONG = keccak256("PONG");

    constructor(
        address socket_,
        uint256 chainSlug_,
        uint256 msgGasLimit_
    ) {
        _socket = socket_;
        _chainSlug = chainSlug_;
        _owner = msg.sender;

        msgGasLimit = msgGasLimit_;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "can only be called by owner");
        _;
    }

    function sendLocalMessage(bytes32 message_) external {
        _updateMessage(message_);
    }

    function sendRemoteMessage(uint256 remoteChainSlug_, bytes32 message_)
        external
        payable
    {
        bytes memory payload = abi.encode(_chainSlug, message_);
        _outbound(remoteChainSlug_, payload);
    }

    function inbound(bytes calldata payload_) external payable override {
        require(msg.sender == _socket, "Counter: Invalid Socket");
        (uint256 localChainSlug, bytes32 msgDecoded) = abi.decode(
            payload_,
            (uint256, bytes32)
        );

        _updateMessage(msgDecoded);

        bytes memory newPayload = abi.encode(
            _chainSlug,
            msgDecoded == _PING ? _PONG : _PING
        );
        _outbound(localChainSlug, newPayload);
    }

    // settings
    function setSocketConfig(
        uint256 remoteChainSlug,
        address remotePlug,
        string calldata integrationType
    ) external onlyOwner {
        ISocket(_socket).setPlugConfig(
            remoteChainSlug,
            remotePlug,
            integrationType
        );
    }

    function message() external view returns (bytes32) {
        return _message;
    }

    function _updateMessage(bytes32 message_) private {
        _message = message_;
    }

    function _outbound(uint256 targetChain_, bytes memory payload_) private {
        ISocket(_socket).outbound{value: msg.value}(
            targetChain_,
            msgGasLimit,
            payload_
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IPlug.sol";
import "../interfaces/ISocket.sol";

contract Counter is IPlug {
    // immutables
    address public immutable socket;

    address public owner;

    // application state
    uint256 public counter;

    // application ops
    bytes32 constant OP_ADD = keccak256("OP_ADD");
    bytes32 constant OP_SUB = keccak256("OP_SUB");

    constructor(address _socket) {
        socket = _socket;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by owner");
        _;
    }

    function localAddOperation(uint256 amount) external {
        _addOperation(amount);
    }

    function localSubOperation(uint256 amount) external {
        _subOperation(amount);
    }

    function remoteAddOperation(
        uint256 chainSlug,
        uint256 amount,
        uint256 msgGasLimit
    ) external payable {
        bytes memory payload = abi.encode(OP_ADD, amount);
        _outbound(chainSlug, msgGasLimit, payload);
    }

    function remoteSubOperation(
        uint256 chainSlug,
        uint256 amount,
        uint256 msgGasLimit
    ) external payable {
        bytes memory payload = abi.encode(OP_SUB, amount);
        _outbound(chainSlug, msgGasLimit, payload);
    }

    function inbound(bytes calldata payload) external payable override {
        require(msg.sender == socket, "Counter: Invalid Socket");
        (bytes32 operationType, uint256 amount) = abi.decode(
            payload,
            (bytes32, uint256)
        );

        if (operationType == OP_ADD) {
            _addOperation(amount);
        } else if (operationType == OP_SUB) {
            _subOperation(amount);
        } else {
            revert("CounterMock: Invalid Operation");
        }
    }

    function _outbound(
        uint256 targetChain,
        uint256 msgGasLimit,
        bytes memory payload
    ) private {
        ISocket(socket).outbound{value: msg.value}(
            targetChain,
            msgGasLimit,
            payload
        );
    }

    //
    // base ops
    //
    function _addOperation(uint256 amount) private {
        counter += amount;
    }

    function _subOperation(uint256 amount) private {
        require(counter > amount, "CounterMock: Subtraction Overflow");
        counter -= amount;
    }

    // settings
    function setSocketConfig(
        uint256 remoteChainSlug,
        address remotePlug,
        string calldata integrationType
    ) external onlyOwner {
        ISocket(socket).setPlugConfig(
            remoteChainSlug,
            remotePlug,
            integrationType
        );
    }

    function setupComplete() external {
        owner = address(0);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

// deprecated
import "../interfaces/INotary.sol";
import "../utils/AccessControl.sol";
import "../interfaces/IAccumulator.sol";
import "../interfaces/ISignatureVerifier.sol";

// moved from interface
// function addBond() external payable;

//     function reduceBond(uint256 amount) external;

//     function unbondAttester() external;

//     function claimBond() external;

// contract BondedNotary is AccessControl(msg.sender) {
// event Unbonded(address indexed attester, uint256 amount, uint256 claimTime);

// event BondClaimed(address indexed attester, uint256 amount);

// event BondClaimDelaySet(uint256 delay);

// event MinBondAmountSet(uint256 amount);

//  error InvalidBondReduce();

// error UnbondInProgress();

// error ClaimTimeLeft();

// error InvalidBond();

//     uint256 private _minBondAmount;
//     uint256 private _bondClaimDelay;
//     uint256 private immutable _chainSlug;
//     ISignatureVerifier private _signatureVerifier;

//     // attester => bond amount
//     mapping(address => uint256) private _bonds;

//     struct UnbondData {
//         uint256 amount;
//         uint256 claimTime;
//     }
//     // attester => unbond data
//     mapping(address => UnbondData) private _unbonds;

//     // attester => accumAddress => packetId => sig hash
//     mapping(address => mapping(address => mapping(uint256 => bytes32)))
//         private _localSignatures;

//     // remoteChainSlug => accumAddress => packetId => root
//     mapping(uint256 => mapping(address => mapping(uint256 => bytes32)))
//         private _remoteRoots;

//     event BondAdded(
//          address indexed attester,
//          uint256 addAmount, // assuming native token
//          uint256 newBond
//     );

//     event BondReduced(
//          address indexed attester,
//          uint256 reduceAmount,
//          uint256 newBond
//     );

//     constructor(
//         uint256 minBondAmount_,
//         uint256 bondClaimDelay_,
//         uint256 chainSlug_,
//         address signatureVerifier_
//     ) {
//         _setMinBondAmount(minBondAmount_);
//         _setBondClaimDelay(bondClaimDelay_);
//         _setSignatureVerifier(signatureVerifier_);
//         _chainSlug = chainSlug_;
//     }

//     function addBond() external payable override {
//         _bonds[msg.sender] += msg.value;
//         emit BondAdded(msg.sender, msg.value, _bonds[msg.sender]);
//     }

//     function reduceBond(uint256 amount) external override {
//         uint256 newBond = _bonds[msg.sender] - amount;

//         if (newBond < _minBondAmount) revert InvalidBondReduce();

//         _bonds[msg.sender] = newBond;
//         emit BondReduced(msg.sender, amount, newBond);

//         payable(msg.sender).transfer(amount);
//     }

//     function unbondAttester() external override {
//         if (_unbonds[msg.sender].claimTime != 0) revert UnbondInProgress();

//         uint256 amount = _bonds[msg.sender];
//         uint256 claimTime = block.timestamp + _bondClaimDelay;

//         _bonds[msg.sender] = 0;
//         _unbonds[msg.sender] = UnbondData(amount, claimTime);

//         emit Unbonded(msg.sender, amount, claimTime);
//     }

//     function claimBond() external override {
//         if (_unbonds[msg.sender].claimTime > block.timestamp)
//             revert ClaimTimeLeft();

//         uint256 amount = _unbonds[msg.sender].amount;
//         _unbonds[msg.sender] = UnbondData(0, 0);
//         emit BondClaimed(msg.sender, amount);

//         payable(msg.sender).transfer(amount);
//     }

//     function minBondAmount() external view returns (uint256) {
//         return _minBondAmount;
//     }

//     function bondClaimDelay() external view returns (uint256) {
//         return _bondClaimDelay;
//     }

//     function signatureVerifier() external view returns (address) {
//         return address(_signatureVerifier);
//     }

//     function chainSlug() external view returns (uint256) {
//         return _chainSlug;
//     }

//     function getBond(address attester) external view returns (uint256) {
//         return _bonds[attester];
//     }

//     function isAttested(address, uint256) external view returns (bool) {
//         return true;
//     }

//     function getUnbondData(address attester)
//         external
//         view
//         returns (uint256, uint256)
//     {
//         return (_unbonds[attester].amount, _unbonds[attester].claimTime);
//     }

//     function setMinBondAmount(uint256 amount) external onlyOwner {
//         _setMinBondAmount(amount);
//     }

//     function setBondClaimDelay(uint256 delay) external onlyOwner {
//         _setBondClaimDelay(delay);
//     }

//     function setSignatureVerifier(address signatureVerifier_)
//         external
//         onlyOwner
//     {
//         _setSignatureVerifier(signatureVerifier_);
//     }

//     function seal(address accumAddress_, uint256 remoteChainSlug_, bytes calldata signature_)
//         external
//         override
//     {
//         (bytes32 root, uint256 packetId) = IAccumulator(accumAddress_)
//             .sealPacket();

//         bytes32 digest = keccak256(
//             abi.encode(_chainSlug, accumAddress_, packetId, root)
//         );
//         address attester = _signatureVerifier.recoverSigner(digest, signature_);

//         if (_bonds[attester] < _minBondAmount) revert InvalidBond();
//         _localSignatures[attester][accumAddress_][packetId] = keccak256(
//             signature_
//         );

//         emit PacketVerifiedAndSealed(attester, accumAddress_, packetId, signature_);
//     }

//     function challengeSignature(
//         address accumAddress_,
//         bytes32 root_,
//         uint256 packetId_,
//         bytes calldata signature_
//     ) external override {
//         bytes32 digest = keccak256(
//             abi.encode(_chainSlug, accumAddress_, packetId_, root_)
//         );
//         address attester = _signatureVerifier.recoverSigner(digest, signature_);
//         bytes32 oldSig = _localSignatures[attester][accumAddress_][packetId_];

//         if (oldSig != keccak256(signature_)) {
//             uint256 bond = _unbonds[attester].amount + _bonds[attester];
//             payable(msg.sender).transfer(bond);
//             emit ChallengedSuccessfully(
//                 attester,
//                 accumAddress_,
//                 packetId_,
//                 msg.sender,
//                 bond
//             );
//         }
//     }

//     function _setMinBondAmount(uint256 amount) private {
//         _minBondAmount = amount;
//         emit MinBondAmountSet(amount);
//     }

//     function _setBondClaimDelay(uint256 delay) private {
//         _bondClaimDelay = delay;
//         emit BondClaimDelaySet(delay);
//     }

//     function _setSignatureVerifier(address signatureVerifier_) private {
//         _signatureVerifier = ISignatureVerifier(signatureVerifier_);
//         emit SignatureVerifierSet(signatureVerifier_);
//     }

//     function propose(
//         uint256 remoteChainSlug_,
//         address accumAddress_,
//         uint256 packetId_,
//         bytes32 root_,
//         bytes calldata signature_
//     ) external override {
//         bytes32 digest = keccak256(
//             abi.encode(remoteChainSlug_, accumAddress_, packetId_, root_)
//         );
//         address attester = _signatureVerifier.recoverSigner(digest, signature_);

//         if (!_hasRole(_attesterRole(remoteChainSlug_), attester))
//             revert InvalidAttester();

//         if (_remoteRoots[remoteChainSlug_][accumAddress_][packetId_] != 0)
//             revert AlreadyProposed();

//         _remoteRoots[remoteChainSlug_][accumAddress_][packetId_] = root_;
//         emit Proposed(
//             remoteChainSlug_,
//             accumAddress_,
//             packetId_,
//             root_
//         );
//     }

//     function getRemoteRoot(
//         uint256 remoteChainSlug_,
//         address accumAddress_,
//         uint256 packetId_
//     ) external view override returns (bytes32) {
//         return _remoteRoots[remoteChainSlug_][accumAddress_][packetId_];
//     }

//     function grantAttesterRole(uint256 remoteChainSlug_, address attester_)
//         external
//         onlyOwner
//     {
//         _grantRole(_attesterRole(remoteChainSlug_), attester_);
//     }

//     function revokeAttesterRole(uint256 remoteChainSlug_, address attester_)
//         external
//         onlyOwner
//     {
//         _revokeRole(_attesterRole(remoteChainSlug_), attester_);
//     }

//     function _attesterRole(uint256 chainSlug_) internal pure returns (bytes32) {
//         return bytes32(chainSlug_);
//     }
// }

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

interface ISignatureVerifier {
    /**
     * @notice returns the address of signer recovered from input signature
     * @param dstChainSlug_ remote chain id
     * @param packetId_ packet id
     * @param root_ root hash of merkle tree
     * @param signature_ signature
     */
    function recoverSigner(
        uint256 dstChainSlug_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external pure returns (address signer);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;
import "../interfaces/ISignatureVerifier.sol";

contract SignatureVerifier is ISignatureVerifier {
    error InvalidSigLength();

    /// @inheritdoc ISignatureVerifier
    function recoverSigner(
        uint256 destChainSlug_,
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external pure override returns (address signer) {
        bytes32 digest = keccak256(
            abi.encode(destChainSlug_, packetId_, root_)
        );
        digest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", digest)
        );
        signer = _recoverSigner(digest, signature_);
    }

    /**
     * @notice returns the address of signer recovered from input signature
     */
    function _recoverSigner(bytes32 hash_, bytes memory signature_)
        private
        pure
        returns (address signer)
    {
        (bytes32 sigR, bytes32 sigS, uint8 sigV) = _splitSignature(signature_);

        // recovered signer is checked for the valid roles later
        signer = ecrecover(hash_, sigV, sigR, sigS);
    }

    /**
     * @notice splits the signature into v, r and s.
     */
    function _splitSignature(bytes memory signature_)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        if (signature_.length != 65) revert InvalidSigLength();
        assembly {
            r := mload(add(signature_, 0x20))
            s := mload(add(signature_, 0x40))
            v := byte(0, mload(add(signature_, 0x60)))
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/INotary.sol";
import "../interfaces/IAccumulator.sol";
import "../interfaces/ISignatureVerifier.sol";
import "../utils/AccessControl.sol";
import "../utils/ReentrancyGuard.sol";

contract AdminNotary is INotary, AccessControl(msg.sender), ReentrancyGuard {
    uint256 private immutable _chainSlug;
    ISignatureVerifier public signatureVerifier;

    // attester => accumAddr|chainSlug|packetId => is attested
    mapping(address => mapping(uint256 => bool)) public isAttested;

    // chainSlug => total attesters registered
    mapping(uint256 => uint256) public totalAttestors;

    // accumAddr|chainSlug|packetId
    mapping(uint256 => PacketDetails) private _packetDetails;

    constructor(address signatureVerifier_, uint32 chainSlug_) {
        _chainSlug = chainSlug_;
        signatureVerifier = ISignatureVerifier(signatureVerifier_);
    }

    /// @inheritdoc INotary
    function seal(address accumAddress_, bytes calldata signature_)
        external
        override
        nonReentrant
    {
        (
            bytes32 root,
            uint256 packetCount,
            uint256 remoteChainSlug
        ) = IAccumulator(accumAddress_).sealPacket();

        uint256 packetId = _getPacketId(accumAddress_, _chainSlug, packetCount);

        address attester = signatureVerifier.recoverSigner(
            remoteChainSlug,
            packetId,
            root,
            signature_
        );

        if (!_hasRole(_attesterRole(remoteChainSlug), attester))
            revert InvalidAttester();
        emit PacketVerifiedAndSealed(
            attester,
            accumAddress_,
            packetId,
            signature_
        );
    }

    /// @inheritdoc INotary
    function attest(
        uint256 packetId_,
        bytes32 root_,
        bytes calldata signature_
    ) external override {
        address attester = signatureVerifier.recoverSigner(
            _chainSlug,
            packetId_,
            root_,
            signature_
        );

        if (!_hasRole(_attesterRole(_getChainSlug(packetId_)), attester))
            revert InvalidAttester();

        _updatePacketDetails(attester, packetId_, root_);
        emit PacketAttested(attester, packetId_);
    }

    function _updatePacketDetails(
        address attester_,
        uint256 packetId_,
        bytes32 root_
    ) private {
        PacketDetails storage packedDetails = _packetDetails[packetId_];
        if (isAttested[attester_][packetId_]) revert AlreadyAttested();

        if (_packetDetails[packetId_].remoteRoots == bytes32(0)) {
            packedDetails.remoteRoots = root_;
            packedDetails.timeRecord = block.timestamp;

            emit PacketProposed(packetId_, root_);
        } else if (_packetDetails[packetId_].remoteRoots != root_)
            revert RootNotFound();

        isAttested[attester_][packetId_] = true;
        packedDetails.attestations++;
    }

    /**
     * @notice updates root for given packet id
     * @param packetId_ id of packet to be updated
     * @param newRoot_ new root
     */
    function updatePacketRoot(uint256 packetId_, bytes32 newRoot_)
        external
        onlyOwner
    {
        PacketDetails storage packedDetails = _packetDetails[packetId_];
        bytes32 oldRoot = packedDetails.remoteRoots;
        packedDetails.remoteRoots = newRoot_;

        emit PacketRootUpdated(packetId_, oldRoot, newRoot_);
    }

    /// @inheritdoc INotary
    function getPacketStatus(uint256 packetId_)
        public
        view
        override
        returns (PacketStatus status)
    {
        PacketDetails memory packet = _packetDetails[packetId_];
        uint256 packetArrivedAt = packet.timeRecord;

        if (packetArrivedAt == 0) return PacketStatus.NOT_PROPOSED;
        return PacketStatus.PROPOSED;
    }

    /// @inheritdoc INotary
    function getPacketDetails(uint256 packetId_)
        external
        view
        override
        returns (
            PacketStatus status,
            uint256 packetArrivedAt,
            uint256 pendingAttestations,
            bytes32 root
        )
    {
        status = getPacketStatus(packetId_);

        PacketDetails memory packet = _packetDetails[packetId_];
        root = packet.remoteRoots;
        packetArrivedAt = packet.timeRecord;
        pendingAttestations =
            totalAttestors[_getChainSlug(packetId_)] -
            packet.attestations;
    }

    /**
     * @notice adds an attester for `remoteChainSlug_` chain
     * @param remoteChainSlug_ remote chain id
     * @param attester_ attester address
     */
    function grantAttesterRole(uint256 remoteChainSlug_, address attester_)
        external
        onlyOwner
    {
        if (_hasRole(_attesterRole(remoteChainSlug_), attester_))
            revert AttesterExists();

        _grantRole(_attesterRole(remoteChainSlug_), attester_);
        totalAttestors[remoteChainSlug_]++;
    }

    /**
     * @notice removes an attester from `remoteChainSlug_` chain list
     * @param remoteChainSlug_ remote chain id
     * @param attester_ attester address
     */
    function revokeAttesterRole(uint256 remoteChainSlug_, address attester_)
        external
        onlyOwner
    {
        if (!_hasRole(_attesterRole(remoteChainSlug_), attester_))
            revert AttesterNotFound();

        _revokeRole(_attesterRole(remoteChainSlug_), attester_);
        totalAttestors[remoteChainSlug_]--;
    }

    function _attesterRole(uint256 chainSlug_) internal pure returns (bytes32) {
        return bytes32(chainSlug_);
    }

    /**
     * @notice returns the attestations received by a packet
     * @param packetId_ packed id
     */
    function getAttestationCount(uint256 packetId_)
        external
        view
        returns (uint256)
    {
        return _packetDetails[packetId_].attestations;
    }

    /**
     * @notice returns the remote root for given `packetId_`
     * @param packetId_ packed id
     */
    function getRemoteRoot(uint256 packetId_)
        external
        view
        override
        returns (bytes32)
    {
        return _packetDetails[packetId_].remoteRoots;
    }

    /**
     * @notice returns the current chain id
     */
    function chainSlug() external view returns (uint256) {
        return _chainSlug;
    }

    /**
     * @notice updates signatureVerifier_
     * @param signatureVerifier_ address of Signature Verifier
     */
    function setSignatureVerifier(address signatureVerifier_)
        external
        onlyOwner
    {
        signatureVerifier = ISignatureVerifier(signatureVerifier_);
        emit SignatureVerifierSet(signatureVerifier_);
    }

    function _getPacketId(
        address accumAddr_,
        uint256 chainSlug_,
        uint256 packetCount_
    ) internal pure returns (uint256 packetId) {
        packetId =
            (chainSlug_ << 224) |
            (uint256(uint160(accumAddr_)) << 64) |
            packetCount_;
    }

    function _getChainSlug(uint256 packetId_)
        internal
        pure
        returns (uint256 chainSlug_)
    {
        chainSlug_ = uint32(packetId_ >> 224);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IAccumulator.sol";
import "../utils/AccessControl.sol";

abstract contract BaseAccum is IAccumulator, AccessControl(msg.sender) {
    bytes32 public constant SOCKET_ROLE = keccak256("SOCKET_ROLE");
    bytes32 public constant NOTARY_ROLE = keccak256("NOTARY_ROLE");
    uint256 public immutable remoteChainSlug;

    /// an incrementing id for each new packet created
    uint256 internal _packets;
    uint256 internal _sealedPackets;

    /// maps the packet id with the root hash generated while adding message
    mapping(uint256 => bytes32) internal _roots;

    error NoPendingPacket();

    /**
     * @notice initialises the contract with socket and notary addresses
     */
    constructor(
        address socket_,
        address notary_,
        uint32 remoteChainSlug_
    ) {
        _setSocket(socket_);
        _setNotary(notary_);

        remoteChainSlug = remoteChainSlug_;
    }

    /// @inheritdoc IAccumulator
    function sealPacket()
        external
        virtual
        override
        onlyRole(NOTARY_ROLE)
        returns (
            bytes32,
            uint256,
            uint256
        )
    {
        uint256 packetId = _sealedPackets;

        if (_roots[packetId] == bytes32(0)) revert NoPendingPacket();
        bytes32 root = _roots[packetId];
        _sealedPackets++;

        emit PacketComplete(root, packetId);
        return (root, packetId, remoteChainSlug);
    }

    function setSocket(address socket_) external onlyOwner {
        _setSocket(socket_);
    }

    function setNotary(address notary_) external onlyOwner {
        _setNotary(notary_);
    }

    function _setSocket(address socket_) private {
        _grantRole(SOCKET_ROLE, socket_);
    }

    function _setNotary(address notary_) private {
        _grantRole(NOTARY_ROLE, notary_);
    }

    /// returns the latest packet details to be sealed
    /// @inheritdoc IAccumulator
    function getNextPacketToBeSealed()
        external
        view
        virtual
        override
        returns (bytes32, uint256)
    {
        uint256 toSeal = _sealedPackets;
        return (_roots[toSeal], toSeal);
    }

    /// returns the root of packet for given id
    /// @inheritdoc IAccumulator
    function getRootById(uint256 id)
        external
        view
        virtual
        override
        returns (bytes32)
    {
        return _roots[id];
    }

    function getLatestPacketId() external view returns (uint256) {
        return _packets == 0 ? 0 : _packets - 1;
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "./BaseAccum.sol";

contract SingleAccum is BaseAccum {
    /**
     * @notice initialises the contract with socket and notary addresses
     */
    constructor(
        address socket_,
        address notary_,
        uint32 remoteChainSlug_
    ) BaseAccum(socket_, notary_, remoteChainSlug_) {}

    /// adds the packed message to a packet
    /// @inheritdoc IAccumulator
    function addPackedMessage(bytes32 packedMessage)
        external
        override
        onlyRole(SOCKET_ROLE)
    {
        uint256 packetId = _packets;
        _roots[packetId] = packedMessage;
        _packets++;

        emit MessageAdded(packedMessage, packetId, packedMessage);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../utils/Ownable.sol";

contract MockOwnable is Ownable {
    constructor(address owner) Ownable(owner) {}

    function ownerFunction() external onlyOwner {}

    function publicFunction() external {}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../utils/AccessControl.sol";

contract MockAccessControl is AccessControl {
    bytes32 public constant ROLE_GIRAFFE = keccak256("ROLE_GIRAFFE");
    bytes32 public constant ROLE_HIPPO = keccak256("ROLE_HIPPO");

    constructor(address owner) AccessControl(owner) {}

    function giraffe() external onlyRole(ROLE_GIRAFFE) {}

    function hippo() external onlyRole(ROLE_HIPPO) {}

    function animal() external {}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IHasher.sol";

contract Hasher is IHasher {
    /// @inheritdoc IHasher
    function packMessage(
        uint256 srcChainSlug,
        address srcPlug,
        uint256 dstChainSlug,
        address dstPlug,
        uint256 msgId,
        uint256 msgGasLimit,
        bytes calldata payload
    ) external pure override returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    srcChainSlug,
                    srcPlug,
                    dstChainSlug,
                    dstPlug,
                    msgId,
                    msgGasLimit,
                    payload
                )
            );
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.7;

import "../interfaces/IDeaccumulator.sol";

contract SingleDeaccum is IDeaccumulator {
    /// returns if the packed message is the part of a merkle tree or not
    /// @inheritdoc IDeaccumulator
    function verifyMessageInclusion(
        bytes32 root_,
        bytes32 packedMessage_,
        bytes calldata
    ) external pure override returns (bool) {
        return root_ == packedMessage_;
    }
}