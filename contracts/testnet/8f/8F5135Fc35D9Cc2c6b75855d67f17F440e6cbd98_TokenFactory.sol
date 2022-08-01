// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface ICommonTokenFactory {
    function CreateCommonToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 totalSupply_,
        address creator
    ) external returns (address);
}

interface IBurnableTokenFactory {
    function CreateBurnableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns (address);
}

interface IMintableTokenFactory {
    function CreateMintableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 totalSupply_,
        address creator
    ) external returns (address);
}

interface IStandardTokenFactory {
    function CreateStandardToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns (address);

    function CreateStandardTokenAntiBot(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator,
        address whaleAntiBotAddress,
        uint256 feeEnableAntiBot
    ) external returns (address);
}

interface IPerfectTokenFactory {
    function CreatePerfectToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns (address);
}

interface IUnlimitedTokenFactory {
    function CreateUnlimitedToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address creator
    ) external returns (address);
}

contract TokenFactory is Initializable {
    address payable private _owner;

    event TokenCreated(address TokenAddress);
    event TokenAntibotCreated(address TokenAddress, address AntibotAddress);

    //token address by name
    mapping(bytes32 => address) public addressToken;

    // fee create token
    mapping(bytes32 => uint256) private feeService;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    function initialize() public initializer {
        _owner = payable(msg.sender);
    }

    // Return owner address of contract
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // set _commonTokenContract address by owner
    function setCommonTokenContract(address commonTokenContract_)
        public
        onlyOwner
    {
        require(
            commonTokenContract_ != address(0),
            "Address can not be Adress(0)"
        );
        setAddressToken("CommonToken", commonTokenContract_);
    }

    // set _burnableTokenContract address by owner
    function setBurnableTokenContract(address burnableTokenContract_)
        public
        onlyOwner
    {
        require(
            burnableTokenContract_ != address(0),
            "Address can not be Adress(0)"
        );
        setAddressToken("BurnableToken", burnableTokenContract_);
    }

    // set _mintableTokenContract address by owner
    function setMintableTokenContract(address mintableTokenContract_)
        public
        onlyOwner
    {
        require(
            mintableTokenContract_ != address(0),
            "Address can not be Adress(0)"
        );
        setAddressToken("MintableToken", mintableTokenContract_);
    }

    // set _standardTokenContract address by owner
    function setStandardTokenContract(address standardTokenContract_)
        public
        onlyOwner
    {
        require(
            standardTokenContract_ != address(0),
            "Address can not be Adress(0)"
        );
        setAddressToken("StandardToken", standardTokenContract_);
    }

    // set _perfectTokenContract address by owner
    function setPerfectTokenContract(address perfectTokenContract_)
        public
        onlyOwner
    {
        require(
            perfectTokenContract_ != address(0),
            "Address can not be Adress(0)"
        );
        setAddressToken("PerfectToken", perfectTokenContract_);
    }

    // set _unlimitedTokenContract address by owner
    function setUnlimitedTokenContract(address unlimitedTokenContract_)
        public
        onlyOwner
    {
        require(
            unlimitedTokenContract_ != address(0),
            "Address can not be Adress(0)"
        );
        setAddressToken("UnlimitedToken", unlimitedTokenContract_);
    }

    function factoryCommonToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeCommonToken = getFee("CommonToken");

        require(feeCommonToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeCommonToken, "Fee Service incorrect");

        // Owner need set _commonTokenContract address first to user create common Token
        address _commonTokenContract = getAddressToken("CommonToken");

        require(
            _commonTokenContract != address(0),
            "Owner not set _commonTokenContract address yet"
        );

        ICommonTokenFactory commonToken = ICommonTokenFactory(
            _commonTokenContract
        );

        address commonTokenAdress = commonToken.CreateCommonToken(
            name_,
            symbol_,
            decimals_,
            initialSupply_,
            totalSupply_,
            msg.sender
        );

        emit TokenCreated(commonTokenAdress);
    }

    function factoryBurnableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeBurnableToken = getFee("BurnableToken");

        require(feeBurnableToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeBurnableToken, "Fee Service incorrect");

        // Owner need set _burnableTokenContract address first to user create burnable Token
        address _burnableTokenContract = getAddressToken("BurnableToken");

        require(
            _burnableTokenContract != address(0),
            "Owner not set _burnableTokenContract address yet"
        );

        IBurnableTokenFactory burnableToken = IBurnableTokenFactory(
            _burnableTokenContract
        );

        address burnableTokenAdress = burnableToken.CreateBurnableToken(
            name_,
            symbol_,
            decimals_,
            totalSupply_,
            msg.sender
        );

        emit TokenCreated(burnableTokenAdress);
    }

    function factoryMintableToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeMintableToken = getFee("MintableToken");

        require(feeMintableToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeMintableToken, "Fee Service incorrect");

        // Owner need set _mintableTokenContract address first to user create mintable Token
        address _mintableTokenContract = getAddressToken("MintableToken");

        require(
            _mintableTokenContract != address(0),
            "Owner not set _mintableTokenContract address yet"
        );

        IMintableTokenFactory mintableToken = IMintableTokenFactory(
            _mintableTokenContract
        );

        address mintableTokenAdress = mintableToken.CreateMintableToken(
            name_,
            symbol_,
            decimals_,
            initialSupply_,
            totalSupply_,
            msg.sender
        );

        emit TokenCreated(mintableTokenAdress);
    }

    function factoryStandardToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        bool implementAntiBot,
        address whaleAntiBotAddress
    ) public payable {
        uint256 feeStandardToken = getFee("StandardToken");

        require(feeStandardToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeStandardToken, "Fee Service incorrect");

        // Owner need set _standardTokenContract address first to user create standard Token
        address _standardTokenContract = getAddressToken("StandardToken");

        require(
            _standardTokenContract != address(0),
            "Owner not set _standardTokenContract address yet"
        );

        IStandardTokenFactory standardToken = IStandardTokenFactory(
            _standardTokenContract
        );

        if (implementAntiBot == true) {
            uint256 feeEnableAntiBot = getFee("EnableAntiBot");
            require(feeEnableAntiBot != 0, "Owner is not set FeeService yet");

            address standardTokenAdress = standardToken
                .CreateStandardTokenAntiBot(
                    name_,
                    symbol_,
                    decimals_,
                    totalSupply_,
                    msg.sender,
                    whaleAntiBotAddress,
                    feeEnableAntiBot
                );
            emit TokenAntibotCreated(standardTokenAdress, whaleAntiBotAddress);
        } else {
            address standardTokenAdress = standardToken.CreateStandardToken(
                name_,
                symbol_,
                decimals_,
                totalSupply_,
                msg.sender
            );

            emit TokenCreated(standardTokenAdress);
        }
    }

    function factoryPerfectToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feePerfectToken = getFee("PerfectToken");

        require(feePerfectToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feePerfectToken, "Fee Service incorrect");

        // Owner need set _perfectTokenContract address first to user create perfect Token
        address _perfectTokenContract = getAddressToken("PerfectToken");

        require(
            _perfectTokenContract != address(0),
            "Owner not set _perfectTokenContract address yet"
        );

        IPerfectTokenFactory perfectToken = IPerfectTokenFactory(
            _perfectTokenContract
        );

        address perfectTokenAdress = perfectToken.CreatePerfectToken(
            name_,
            symbol_,
            decimals_,
            totalSupply_,
            msg.sender
        );

        emit TokenCreated(perfectTokenAdress);
    }

    function factoryUnlimitedToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) public payable {
        uint256 feeUnlimitedToken = getFee("UnlimitedToken");

        require(feeUnlimitedToken != 0, "Owner is not set FeeService yet");
        require(msg.value == feeUnlimitedToken, "Fee Service incorrect");

        // Owner need set _unlimitedTokenContract address first to user create unlimited Token
        address _unlimitedTokenContract = getAddressToken("UnlimitedToken");

        require(
            _unlimitedTokenContract != address(0),
            "Owner not set _unlimitedTokenContract address yet"
        );

        IUnlimitedTokenFactory unlimitedToken = IUnlimitedTokenFactory(
            _unlimitedTokenContract
        );

        address unlimitedTokenAdress = unlimitedToken.CreateUnlimitedToken(
            name_,
            symbol_,
            decimals_,
            totalSupply_,
            msg.sender
        );

        emit TokenCreated(unlimitedTokenAdress);
    }

    function ownerWithdraw(uint256 amount) public onlyOwner {
        _owner.transfer(amount);
    }

    function setAddressToken(string memory tokenName, address tokenAddress)
        private
        onlyOwner
    {
        addressToken[_toBytes32(tokenName)] = tokenAddress;
    }

    function getAddressToken(string memory tokenName)
        public
        view
        returns (address)
    {
        address tokenAddress = addressToken[_toBytes32(tokenName)];
        require(
            tokenAddress != address(0),
            "Owner not set TokenContract address yet"
        );
        return tokenAddress;
    }

    function setFee(string memory serviceName, uint256 fee) public onlyOwner {
        feeService[_toBytes32(serviceName)] = fee;
    }

    function getFee(string memory serviceName) public view returns (uint256) {
        return feeService[_toBytes32(serviceName)];
    }

    function _toBytes32(string memory serviceName)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(serviceName));
    }
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