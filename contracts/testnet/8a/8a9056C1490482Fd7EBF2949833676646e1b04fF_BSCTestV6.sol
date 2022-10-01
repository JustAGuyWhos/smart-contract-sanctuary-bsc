// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./BSCTest.sol";

contract BSCTestV6 is BSCTest {
    function initializeV6() external reinitializer(6) {
        if (block.chainid != 97) revert ChainIdMismatch();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../common/Core.sol";
import "../common/IRAI20Factory.sol";
import "../common/IRAI721Factory.sol";
import "../common/IValidatorManager.sol";
import "../common/errors.sol";

contract BSCTest is Core {
    function initialize(
        IValidatorManager validatorManager,
        IRAI20Factory rai20Factory,
        IRAI721Factory rai721Factory
    ) external initializer {
        if (block.chainid != 97) revert ChainIdMismatch();
        __Core_init(validatorManager, rai20Factory, rai721Factory);
    }

    function normalizedChainId() public view virtual override returns (uint32) {
        return 10040;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "./CustomEIP712Upgradeable.sol";
import "./NonceManager.sol";
import "./Verifier.sol";
import "./CustomPauseable.sol";
import "./IRAI20Factory.sol";
import "./IRAI721Factory.sol";
import "./IValidatorManager.sol";
import "./errors.sol";

interface IDecimals {
    function decimals() external view returns (uint8);
}

abstract contract Core is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ERC721HolderUpgradeable,
    CustomEIP712Upgradeable,
    NonceManager,
    Verifier,
    CustomPausable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /*=========================== 1. STRUCTS =================================*/
    enum TokenType {
        INVALID,
        ERC20,
        ERC721
    }

    struct TokenInfo {
        uint256 reserve;
        TokenType tokenType;
        bool volatile; // the balance is subject to external changes, e.g. SafeMoon
        bool wrapped;
        bool initialized;
        uint8 decimals;
    }

    /*=========================== 2. CONSTANTS ===============================*/
    bytes32 private constant _UPGRADE_TYPEHASH =
        keccak256("Upgrade(address newImplementation,uint256 nonce)");
    bytes32 private constant _UNMAP_ERC20_TYPEHASH =
        keccak256(
            "UnmapERC20(address token,bytes32 sender,address recipient,bytes32 txnHash,uint64 txnHeight,uint256 share)"
        );
    bytes32 private constant _UNMAP_ETH_TYPEHASH =
        keccak256(
            "UnmapETH(bytes32 sender,address recipient,bytes32 txnHash,uint64 txnHeight,uint256 amount)"
        );
    bytes32 private constant _UNMAP_ERC721_TYPEHASH =
        keccak256(
            "UnmapERC721(address token,bytes32 sender,address recipient,bytes32 txnHash,uint64 txnHeight,uint256 tokenId)"
        );
    bytes32 private constant _CREATE_WRAPPED_ERC20_TOKEN_TYPEHASH =
        keccak256(
            "CreateWrappedERC20Token(string name,string symbol,string originalChain,uint32 originalChainId,bytes32 originalContract,uint8 decimals)"
        );
    bytes32 private constant _CREATE_WRAPPED_ERC721_TOKEN_TYPEHASH =
        keccak256(
            "CreateWrappedERC721Token(string name,string symbol,string originalChain,uint32 originalChainId,bytes32 originalContract)"
        );
    bytes32 private constant _WRAP_ERC20_TOKEN_TYPEHASH =
        keccak256(
            "WrapERC20Token(uint32 originalChainId,bytes32 originalContract,bytes32 sender,address recipient,bytes32 txnHash,uint64 txnHeight,uint256 amount)"
        );
    bytes32 private constant _WRAP_ERC721_TOKEN_TYPEHASH =
        keccak256(
            "WrapERC721Token(uint32 originalChainId,bytes32 originalContract,bytes32 sender,address recipient,bytes32 txnHash,uint64 txnHeight,uint256 tokenId)"
        );

    /*=========================== 3. STATE VARIABLES =========================*/
    IRAI20Factory private _rai20Factory;
    IRAI721Factory private _rai721Factory;
    address private _newImplementation;
    uint256 private _ethReserve;
    mapping(address => TokenInfo) private _tokenInfos;
    // mapping token ID to block height at which the token was received
    mapping(IERC721Upgradeable => mapping(uint256 => uint256)) private _tokenIdReserve;
    // mapping submitted transaction hash to block height at which the submission was executed
    // it is used to prevent double-spending of unmap transactions
    mapping(bytes32 => uint256) private _submittedTxns;
    // maping original (chain, token address) to wrapped token address
    mapping(uint32 => mapping(bytes32 => address)) private _wrappedTokens;

    /*=========================== 4. EVENTS ==================================*/
    event NewImplementationSet(address newImplementation);
    event TokenInfoInitialized(
        address indexed token,
        TokenType tokenType,
        bool wrapped,
        uint8 decimals,
        uint32 normalizedChainId
    );

    event ERC20TokenMapped(
        address indexed token,
        address indexed sender,
        bytes32 indexed recipient,
        uint256 amount,
        uint256 share,
        uint32 normalizedChainId
    );

    event ETHMapped(
        address indexed sender,
        bytes32 indexed recipient,
        uint256 amount,
        uint32 normalizedChainId
    );

    event ERC721TokenMapped(
        address indexed token,
        address indexed sender,
        bytes32 indexed recipient,
        uint256 tokenId,
        uint32 normalizedChainId
    );

    event ERC20TokenUnmapped(
        address indexed token,
        bytes32 indexed sender,
        address indexed recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 amount,
        uint256 share,
        uint32 normalizedChainId
    );

    event ETHUnmapped(
        bytes32 indexed sender,
        address indexed recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 amount,
        uint32 normalizedChainId
    );

    event ERC721TokenUnmapped(
        address indexed token,
        bytes32 indexed sender,
        address indexed recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 tokenId,
        uint32 normalizedChainId
    );

    event WrappedERC20TokenCreated(
        uint32 indexed originalChainId,
        bytes32 indexed originalContract,
        address indexed wrappedAddress,
        string name,
        string symbol,
        string originalChain,
        uint8 decimals,
        uint32 normalizedChainId
    );

    event WrappedERC721TokenCreated(
        uint32 indexed originalChainId,
        bytes32 indexed originalContract,
        address indexed wrappedAddress,
        string name,
        string symbol,
        string originalChain,
        uint32 normalizedChainId
    );

    event ERC20TokenWrapped(
        uint32 indexed originalChainId,
        bytes32 indexed originalContract,
        bytes32 indexed sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        address wrappedAddress,
        uint256 amount,
        uint32 normalizedChainId
    );

    event ERC721TokenWrapped(
        uint32 indexed originalChainId,
        bytes32 indexed originalContract,
        bytes32 indexed sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        address wrappedAddress,
        uint256 tokenId,
        uint32 normalizedChainId
    );

    event ERC20TokenUnwrapped(
        uint32 indexed originalChainId,
        bytes32 indexed originalContract,
        address indexed sender,
        bytes32 recipient,
        address wrappedAddress,
        uint256 amount,
        uint32 normalizedChainId
    );

    event ERC721TokenUnwrapped(
        uint32 indexed originalChainId,
        bytes32 indexed originalContract,
        address indexed sender,
        bytes32 recipient,
        address wrappedAddress,
        uint256 tokenId,
        uint32 normalizedChainId
    );

    /*=========================== 5. MODIFIERS ===============================*/

    /*=========================== 6. FUNCTIONS ===============================*/
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function __Core_init(
        IValidatorManager validatorManager,
        IRAI20Factory rai20Factory,
        IRAI721Factory rai721Factory
    ) internal onlyInitializing {
        // todo: unchain_init
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ERC721Holder_init();
        __EIP712_init();
        __Verifier_init(validatorManager);
        __Core_init_unchained(rai20Factory, rai721Factory);
    }

    function __Core_init_unchained(IRAI20Factory rai20Factory, IRAI721Factory rai721Factory)
        internal
        onlyInitializing
    {
        _rai20Factory = rai20Factory;
        _rai721Factory = rai721Factory;
        // todo:
    }

    function upgrade(
        address impl,
        uint256 nonce,
        bytes calldata signatures
    ) external nonReentrant whenNotPaused useNonce(nonce) {
        bytes32 structHash = keccak256(abi.encode(_UPGRADE_TYPEHASH, impl, nonce));
        if (!verify(structHash, signatures)) revert VerificationFailed();
        if (impl == address(0) || impl == _getImplementation()) revert InvalidImplementation();

        _newImplementation = impl;
        emit NewImplementationSet(impl);
    }

    /**
     * @dev As compatible with ERC165 is not required by ERC20, to eliminate the risk of
     * forging other tokens into ERC20, we enforce
     * 1）The token should support 'function decimals() external view returns (uint8)'
     * 2) The increasing amount of 'token.balanceOf[this]' should be greater than 1
     */
    function mapERC20(
        IERC20Upgradeable token,
        uint256 amount,
        bytes32 recipient
    ) external payable nonReentrant whenNotPaused chargeFee(msg.value) {
        if (address(token) <= address(1)) revert InvalidTokenAddress();
        if (amount <= 1) revert InvalidAmount();
        if (recipient == bytes32(0)) revert InvalidRecipient();

        TokenInfo memory info = _tokenInfos[address(token)];
        if (!info.initialized) {
            _initERC20(info, token, false);
        }
        if (info.tokenType != TokenType.ERC20) revert TokenTypeNotMatch();
        if (info.wrapped) revert CanNotMapWrappedToken();

        uint256 balance = token.balanceOf(address(this));
        token.safeTransferFrom(_msgSender(), address(this), amount);
        uint256 newBalance = token.balanceOf(address(this));
        if (newBalance <= balance + 1) revert InvalidBalance();

        if (info.reserve == 0 && balance > 0) {
            info.reserve = balance;
        }
        uint256 share = newBalance - balance;
        if ((balance > 0 && info.reserve > 0) && (balance < info.reserve || info.volatile)) {
            share = (share * info.reserve) / balance;
        }
        if (share == 0) revert InvalidShare();

        info.reserve += share;
        _tokenInfos[address(token)] = info;
        emit ERC20TokenMapped(
            address(token),
            _msgSender(),
            recipient,
            amount,
            share,
            normalizedChainId()
        );
    }

    function mapETH(
        uint256 amount,
        bytes32 recipient,
        uint256 fee
    ) external payable nonReentrant whenNotPaused chargeFee(fee) {
        if (amount == 0) revert InvalidAmount();
        if (recipient == bytes32(0)) revert InvalidRecipient();
        if (msg.value != (amount + fee)) revert InvalidValue();

        _ethReserve += amount;
        emit ETHMapped(_msgSender(), recipient, amount, normalizedChainId());
    }

    function mapERC721(
        IERC721Upgradeable token,
        uint256 tokenId,
        bytes32 recipient
    ) external payable nonReentrant whenNotPaused chargeFee(msg.value) {
        if (address(token) <= address(1)) revert InvalidTokenAddress();
        if (_tokenIdReserve[token][tokenId] != 0) revert TokenIdAlreadyMapped();
        if (recipient == bytes32(0)) revert InvalidRecipient();
        if (block.number == 0) revert ZeroBlockNumber();

        TokenInfo memory info = _tokenInfos[address(token)];
        if (!info.initialized) {
            _initERC721(info, token, false);
        }
        if (info.tokenType != TokenType.ERC721) revert TokenTypeNotMatch();
        if (info.wrapped) revert CanNotMapWrappedToken();

        if (token.ownerOf(tokenId) == address(this)) revert TokenIdAlreadyOwned();
        token.safeTransferFrom(_msgSender(), address(this), tokenId);
        if (token.ownerOf(tokenId) != address(this)) revert TransferFailed();

        _tokenIdReserve[token][tokenId] = block.number;
        info.reserve += 1;
        _tokenInfos[address(token)] = info;
        emit ERC721TokenMapped(
            address(token),
            _msgSender(),
            recipient,
            tokenId,
            normalizedChainId()
        );
    }

    function unmapERC20(
        IERC20Upgradeable token,
        bytes32 sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 share,
        bytes calldata signatures
    ) external payable nonReentrant whenNotPaused chargeFee(msg.value) {
        {
            bytes32 structHash = keccak256(
                abi.encode(
                    _UNMAP_ERC20_TYPEHASH,
                    token,
                    sender,
                    recipient,
                    txnHash,
                    txnHeight,
                    share
                )
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (sender == bytes32(0)) revert InvalidSender();
        if (recipient == address(0) || recipient == address(this)) revert InvalidRecipient();
        // address(1) represents ETH on Raicoin network
        if (address(token) <= address(1)) revert InvalidTokenAddress();
        if (share == 0) revert InvalidShare();
        if (_submittedTxns[txnHash] != 0) revert AlreadySubmitted();
        if (block.number == 0) revert ZeroBlockNumber();
        _submittedTxns[txnHash] = block.number;

        TokenInfo memory info = _tokenInfos[address(token)];
        if (!info.initialized) revert TokenNotInitialized();
        if (info.tokenType != TokenType.ERC20) revert TokenTypeNotMatch();
        if (info.wrapped) revert CanNotUnmapWrappedToken();

        uint256 amount = share;
        uint256 balance = token.balanceOf(address(this));
        if (balance < info.reserve || info.volatile) {
            amount = (share * balance) / info.reserve;
        }
        if (amount == 0) revert InvalidAmount();

        info.reserve -= share;
        _tokenInfos[address(token)] = info;
        token.safeTransfer(recipient, amount);
        emit ERC20TokenUnmapped(
            address(token),
            sender,
            recipient,
            txnHash,
            txnHeight,
            amount,
            share,
            normalizedChainId()
        );
    }

    function unmapETH(
        bytes32 sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 amount,
        bytes calldata signatures
    ) external payable nonReentrant whenNotPaused chargeFee(msg.value) {
        {
            bytes32 structHash = keccak256(
                abi.encode(_UNMAP_ETH_TYPEHASH, sender, recipient, txnHash, txnHeight, amount)
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (sender == bytes32(0)) revert InvalidSender();
        if (recipient == address(0) || recipient == address(this)) revert InvalidRecipient();
        if (amount == 0) revert InvalidAmount();
        if (_submittedTxns[txnHash] != 0) revert AlreadySubmitted();
        if (block.number == 0) revert ZeroBlockNumber();
        _submittedTxns[txnHash] = block.number;

        _ethReserve -= amount;

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit ETHUnmapped(sender, recipient, txnHash, txnHeight, amount, normalizedChainId());
    }

    function unmapERC721(
        IERC721Upgradeable token,
        bytes32 sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 tokenId,
        bytes calldata signatures
    ) external payable nonReentrant whenNotPaused chargeFee(msg.value) {
        {
            bytes32 structHash = keccak256(
                abi.encode(
                    _UNMAP_ERC721_TYPEHASH,
                    token,
                    sender,
                    recipient,
                    txnHash,
                    txnHeight,
                    tokenId
                )
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (sender == bytes32(0)) revert InvalidSender();
        if (recipient == address(0) || recipient == address(this)) revert InvalidRecipient();
        if (address(token) <= address(1)) revert InvalidTokenAddress();
        if (_tokenIdReserve[token][tokenId] == 0) revert TokenIdNotMapped();
        if (_submittedTxns[txnHash] != 0) revert AlreadySubmitted();
        if (block.number == 0) revert ZeroBlockNumber();
        _submittedTxns[txnHash] = block.number;

        TokenInfo memory info = _tokenInfos[address(token)];
        if (!info.initialized) revert TokenNotInitialized();
        if (info.tokenType != TokenType.ERC721) revert TokenTypeNotMatch();
        if (info.wrapped) revert CanNotUnmapWrappedToken();
        if (token.ownerOf(tokenId) != address(this)) revert TokenIdNotOwned();

        _tokenIdReserve[token][tokenId] = 0;
        info.reserve -= 1;
        _tokenInfos[address(token)] = info;
        token.safeTransferFrom(address(this), recipient, tokenId);
        if (token.ownerOf(tokenId) == address(this)) revert TransferFailed();

        emit ERC721TokenUnmapped(
            address(token),
            sender,
            recipient,
            txnHash,
            txnHeight,
            tokenId,
            normalizedChainId()
        );
    }

    function createWrappedERC20Token(
        string calldata name,
        string calldata symbol,
        string calldata originalChain,
        uint32 originalChainId,
        bytes32 originalContract,
        uint8 decimals,
        bytes calldata signatures
    ) external nonReentrant whenNotPaused {
        {
            bytes32 structHash = keccak256(
                abi.encode(
                    _CREATE_WRAPPED_ERC20_TOKEN_TYPEHASH,
                    keccak256(bytes(name)),
                    keccak256(bytes(symbol)),
                    keccak256(bytes(originalChain)),
                    originalChainId,
                    originalContract,
                    decimals
                )
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (originalChainId == normalizedChainId() || originalChainId == 0) {
            revert InvalidOriginalChainId();
        }
        if (originalContract == bytes32(0)) revert InvalidOriginalContract();

        if (_wrappedTokens[originalChainId][originalContract] != address(0)) {
            revert WrappedTokenAlreadyCreated();
        }

        address addr = _rai20Factory.create(
            name,
            symbol,
            originalChain,
            originalChainId,
            originalContract,
            decimals
        );
        if (addr == address(0)) revert CreateWrappedTokenFailed();

        {
            _wrappedTokens[originalChainId][originalContract] = addr;
            TokenInfo memory info;
            _initERC20(info, IERC20Upgradeable(addr), true);
        }

        emit WrappedERC20TokenCreated(
            originalChainId,
            originalContract,
            addr,
            name,
            symbol,
            originalChain,
            decimals,
            normalizedChainId()
        );
    }

    function createWrappedERC721Token(
        string calldata name,
        string calldata symbol,
        string calldata originalChain,
        uint32 originalChainId,
        bytes32 originalContract,
        bytes calldata signatures
    ) external nonReentrant whenNotPaused {
        {
            bytes32 structHash = keccak256(
                abi.encode(
                    _CREATE_WRAPPED_ERC721_TOKEN_TYPEHASH,
                    keccak256(bytes(name)),
                    keccak256(bytes(symbol)),
                    keccak256(bytes(originalChain)),
                    originalChainId,
                    originalContract
                )
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }

        if (originalChainId == normalizedChainId() || originalChainId == 0) {
            revert InvalidOriginalChainId();
        }
        if (originalContract == bytes32(0)) revert InvalidOriginalContract();

        if (_wrappedTokens[originalChainId][originalContract] != address(0)) {
            revert WrappedTokenAlreadyCreated();
        }

        address addr = _rai721Factory.create(
            name,
            symbol,
            originalChain,
            originalChainId,
            originalContract
        );
        if (addr == address(0)) revert CreateWrappedTokenFailed();

        {
            _wrappedTokens[originalChainId][originalContract] = addr;
            TokenInfo memory info;
            _initERC721(info, IERC721Upgradeable(addr), true);
        }

        emit WrappedERC721TokenCreated(
            originalChainId,
            originalContract,
            addr,
            name,
            symbol,
            originalChain,
            normalizedChainId()
        );
    }

    function wrapERC20Token(
        uint32 originalChainId,
        bytes32 originalContract,
        bytes32 sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 amount,
        bytes calldata signatures
    ) external payable chargeFee(msg.value) {
        {
            bytes32 structHash = keccak256(
                abi.encode(
                    _WRAP_ERC20_TOKEN_TYPEHASH,
                    originalChainId,
                    originalContract,
                    sender,
                    recipient,
                    txnHash,
                    txnHeight,
                    amount
                )
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (originalChainId == normalizedChainId() || originalChainId == 0) {
            revert InvalidOriginalChainId();
        }
        if (originalContract == bytes32(0)) revert InvalidOriginalContract();
        if (sender == bytes32(0)) revert InvalidSender();
        if (recipient == address(0) || recipient == address(this)) revert InvalidRecipient();
        if (amount == 0) revert InvalidAmount();
        if (_submittedTxns[txnHash] != 0) revert AlreadySubmitted();
        if (block.number == 0) revert ZeroBlockNumber();
        _submittedTxns[txnHash] = block.number;

        address addr = _wrappedTokens[originalChainId][originalContract];
        if (addr == address(0)) revert WrappedTokenNotCreated();

        {
            TokenInfo memory info = _tokenInfos[addr];
            if (!info.initialized) revert TokenNotInitialized();
            if (info.tokenType != TokenType.ERC20) revert TokenTypeNotMatch();
            if (!info.wrapped) revert NotWrappedToken();
        }

        IRAI20(addr).mint(recipient, amount);

        emit ERC20TokenWrapped(
            originalChainId,
            originalContract,
            sender,
            recipient,
            txnHash,
            txnHeight,
            addr,
            amount,
            normalizedChainId()
        );
    }

    function wrapERC721Token(
        uint32 originalChainId,
        bytes32 originalContract,
        bytes32 sender,
        address recipient,
        bytes32 txnHash,
        uint64 txnHeight,
        uint256 tokenId,
        bytes calldata signatures
    ) external payable chargeFee(msg.value) {
        {
            bytes32 structHash = keccak256(
                abi.encode(
                    _WRAP_ERC721_TOKEN_TYPEHASH,
                    originalChainId,
                    originalContract,
                    sender,
                    recipient,
                    txnHash,
                    txnHeight,
                    tokenId
                )
            );
            if (!verify(structHash, signatures)) revert VerificationFailed();
        }
        if (originalChainId == normalizedChainId() || originalChainId == 0) {
            revert InvalidOriginalChainId();
        }
        if (originalContract == bytes32(0)) revert InvalidOriginalContract();

        if (sender == bytes32(0)) revert InvalidSender();
        if (recipient == address(0) || recipient == address(this)) revert InvalidRecipient();

        if (_submittedTxns[txnHash] != 0) revert AlreadySubmitted();
        if (block.number == 0) revert ZeroBlockNumber();
        _submittedTxns[txnHash] = block.number;

        address addr = _wrappedTokens[originalChainId][originalContract];
        if (addr == address(0)) revert WrappedTokenNotCreated();

        {
            TokenInfo memory info = _tokenInfos[addr];
            if (!info.initialized) revert TokenNotInitialized();
            if (info.tokenType != TokenType.ERC721) revert TokenTypeNotMatch();
            if (!info.wrapped) revert NotWrappedToken();
        }

        IRAI721(addr).mint(recipient, tokenId);
        emit ERC721TokenWrapped(
            originalChainId,
            originalContract,
            sender,
            recipient,
            txnHash,
            txnHeight,
            addr,
            tokenId,
            normalizedChainId()
        );
    }

    function unwrapERC20Token(
        IERC20Upgradeable token,
        uint256 amount,
        bytes32 recipient
    ) external payable chargeFee(msg.value) {
        if (address(token) == address(0)) revert InvalidTokenAddress();
        if (recipient == bytes32(0)) revert InvalidRecipient();
        if (amount == 0) revert InvalidAmount();

        {
            TokenInfo memory info = _tokenInfos[address(token)];
            if (!info.initialized) revert TokenNotInitialized();
            if (info.tokenType != TokenType.ERC20) revert TokenTypeNotMatch();
            if (!info.wrapped) revert NotWrappedToken();
        }

        token.safeTransferFrom(_msgSender(), address(this), amount);
        IRAI20(address(token)).burn(amount);

        emit ERC20TokenUnwrapped(
            IRAI20(address(token)).originalChainId(),
            IRAI20(address(token)).originalContract(),
            _msgSender(),
            recipient,
            address(token),
            amount,
            normalizedChainId()
        );
    }

    function unwrapERC721Token(
        IERC721Upgradeable token,
        uint256 tokenId,
        bytes32 recipient
    ) external payable chargeFee(msg.value) {
        if (address(token) == address(0)) revert InvalidTokenAddress();
        if (recipient == bytes32(0)) revert InvalidRecipient();

        {
            TokenInfo memory info = _tokenInfos[address(token)];
            if (!info.initialized) revert TokenNotInitialized();
            if (info.tokenType != TokenType.ERC721) revert TokenTypeNotMatch();
            if (!info.wrapped) revert NotWrappedToken();
        }

        token.safeTransferFrom(_msgSender(), address(this), tokenId);
        IRAI721(address(token)).burn(tokenId);

        emit ERC721TokenUnwrapped(
            IRAI721(address(token)).originalChainId(),
            IRAI721(address(token)).originalContract(),
            _msgSender(),
            recipient,
            address(token),
            tokenId,
            normalizedChainId()
        );
    }

    function domainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function newImplementation() external view returns (address) {
        return _newImplementation;
    }

    function wrappedToken(uint32 originalChainId, bytes32 originalContract)
        external
        view
        returns (address)
    {
        return _wrappedTokens[originalChainId][originalContract];
    }

    function tokenInfo(address token) external view returns (TokenInfo memory) {
        return _tokenInfos[token];
    }

    function normalizedChainId() public view virtual returns (uint32);

    function _authorizeUpgrade(address impl) internal virtual override {
        if (impl == address(0) || impl != _newImplementation) revert InvalidImplementation();
        _newImplementation = address(0);
    }

    function _initERC20(
        TokenInfo memory info,
        IERC20Upgradeable token,
        bool wrapped
    ) private {
        if (info.initialized) revert TokenAlreadyInitialized();
        info.decimals = IDecimals(address(token)).decimals();
        info.tokenType = TokenType.ERC20;
        info.wrapped = wrapped;
        info.initialized = true;
        _tokenInfos[address(token)] = info;
        emit TokenInfoInitialized(
            address(token),
            info.tokenType,
            info.wrapped,
            info.decimals,
            normalizedChainId()
        );
    }

    function _initERC721(
        TokenInfo memory info,
        IERC721Upgradeable token,
        bool wrapped
    ) private {
        if (info.initialized) revert TokenAlreadyInitialized();
        if (
            !ERC165CheckerUpgradeable.supportsInterface(
                address(token),
                type(IERC721Upgradeable).interfaceId
            )
        ) {
            revert NotERC721Token();
        }

        info.decimals = 0;
        info.tokenType = TokenType.ERC721;
        info.wrapped = wrapped;
        info.initialized = true;
        _tokenInfos[address(token)] = info;
        emit TokenInfoInitialized(
            address(token),
            info.tokenType,
            info.wrapped,
            info.decimals,
            normalizedChainId()
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IRAI20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function originalChain() external view returns (string memory);

    function originalChainId() external view returns (uint32);

    function originalContract() external view returns (bytes32);

    function coreContract() external view returns (address);
}

interface IRAI20Factory {
    function create(
        string calldata name,
        string calldata symbol,
        string calldata originalChain,
        uint32 originalChainId,
        bytes32 originalContract,
        uint8 decimals
    ) external returns (address addr);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IRAI721 {
    function mint(address to, uint256 tokenId) external;

    function burn(uint256 tokenId) external;

    function originalChain() external view returns (string memory);

    function originalChainId() external view returns (uint32);

    function originalContract() external view returns (bytes32);

    function coreContract() external view returns (address);
}

interface IRAI721Factory {
    function create(
        string calldata name,
        string calldata symbol,
        string calldata originalChain,
        uint32 originalChainId,
        bytes32 originalContract
    ) external returns (address addr);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IValidatorManager {
    function verifyTypedData(bytes32 typedHash, bytes calldata signatures)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

error NotCalledByCoreContract();
error CoreContractNotSet();
error InvalidCoreContract();
error NotCalledByDeployer();
error CoreContractAreadySet();
error VerificationFailed();
error InvalidImplementation();
error InvalidTokenAddress();
error InvalidAmount();
error InvalidRecipient();
error TokenTypeNotMatch();
error CanNotMapWrappedToken();
error InvalidBalance();
error InvalidShare();
error InvalidValue();
error TokenIdAlreadyMapped();
error ZeroBlockNumber();
error TokenIdAlreadyOwned();
error TransferFailed();
error InvalidSender();
error AlreadySubmitted();
error TokenNotInitialized();
error CanNotUnmapWrappedToken();
error TokenIdNotMapped();
error TokenIdNotOwned();
error WrappedTokenAlreadyCreated();
error CreateWrappedTokenFailed();
error InvalidOriginalChainId();
error InvalidOriginalContract();
error WrappedTokenNotCreated();
error NotWrappedToken();
error TokenAlreadyInitialized();
error NotERC721Token();
error NonceMismatch();
error NotCalledBySigner();
error InvalidValidator();
error InvalidSigner();
error InvalidEpoch();
error SignerReferencedByOtherValidator();
error SignerWeightNotCleared();
error NotInPurgeTimeRange();
error InvalidSignatures();
error EcrecoverFailed();
error InvalidSignerOrder();
error NotCalledByValidatorManager();
error FeeTooLow();
error SendRewardFailed();
error ChainIdMismatch();

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165CheckerUpgradeable {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165Upgradeable).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: MIT

// This contract will be frequently called by user, custom it for gas saving

// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract CustomEIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private constant _HASHED_NAME = keccak256("Raicoin");
    bytes32 private constant _HASHED_VERSION = keccak256("1.0");
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    // solhint-disable-next-line no-empty-blocks
    function __EIP712_init() internal onlyInitializing {}

    function __EIP712_init_unchained(string memory name, string memory version)
        internal
        onlyInitializing
    // solhint-disable-next-line no-empty-blocks
    {

    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return
            keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal view virtual returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal view virtual returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./errors.sol";

contract NonceManager {
    uint256 private _nonce;

    modifier useNonce(uint256 nonce) {
        if (nonce != _nonce) revert NonceMismatch();
        _nonce++;
        _;
    }

    function getNonce() public view returns (uint256) {
        return _nonce;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./CustomEIP712Upgradeable.sol";
import "./IValidatorManager.sol";
import "./errors.sol";

abstract contract Verifier is Initializable, CustomEIP712Upgradeable {
    uint256 private constant _REWARD_FACTOR = 1e9;

    IValidatorManager private _validatorManager;
    uint256 private _fee;
    uint256 private _totalFee;

    event FeeCharged(address indexed sender, uint256 fee);
    event RewardSent(address indexed recipient, uint256 amount);

    modifier onlyValidatorManager() {
        if (msg.sender != address(_validatorManager)) revert NotCalledByValidatorManager();
        _;
    }

    modifier chargeFee(uint256 fee) {
        if (fee < _fee) revert FeeTooLow();
        if (fee > 0) {
            _totalFee += fee;
            emit FeeCharged(msg.sender, fee);
        }
        _;
    }

    function __Verifier_init(IValidatorManager validatorManager) internal onlyInitializing {
        __Verifier_init_unchained(validatorManager);
    }

    function __Verifier_init_unchained(IValidatorManager validatorManager)
        internal
        onlyInitializing
    {
        _validatorManager = validatorManager;
    }

    function setFee(uint256 fee) external onlyValidatorManager {
        _fee = fee;
    }

    function sendReward(address recipient, uint256 share) external onlyValidatorManager {
        uint256 total = _totalFee;
        uint256 amount = 0;
        if (share >= _REWARD_FACTOR) {
            amount = total;
        } else {
            amount = (total * share) / _REWARD_FACTOR;
        }

        if (amount == 0) {
            return;
        }
        _totalFee = total - amount;
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert SendRewardFailed();

        emit RewardSent(recipient, amount);
    }

    function getFee() public view returns (uint256) {
        return _fee;
    }

    function verify(bytes32 structHash, bytes calldata signatures) public view returns (bool) {
        bytes32 typedHash = _hashTypedDataV4(structHash);
        return _validatorManager.verifyTypedData(typedHash, signatures);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./CustomEIP712Upgradeable.sol";
import "./NonceManager.sol";
import "./Verifier.sol";
import "./errors.sol";

contract CustomPausable is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    CustomEIP712Upgradeable,
    NonceManager,
    Verifier
{
    bytes32 private constant _PAUSE_TYPEHASH = keccak256("Pause(uint256 nonce)");
    bytes32 private constant _UNPAUSE_TYPEHASH = keccak256("Unpause(uint256 nonce)");

    function pause(uint256 nonce, bytes calldata signatures)
        external
        nonReentrant
        whenNotPaused
        useNonce(nonce)
    {
        bytes32 structHash = keccak256(abi.encode(_PAUSE_TYPEHASH, nonce));
        if (!verify(structHash, signatures)) revert VerificationFailed();

        _pause();
    }

    function unpause(uint256 nonce, bytes calldata signatures)
        external
        nonReentrant
        whenPaused
        useNonce(nonce)
    {
        bytes32 structHash = keccak256(abi.encode(_UNPAUSE_TYPEHASH, nonce));
        if (!verify(structHash, signatures)) revert VerificationFailed();

        _unpause();
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

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
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}