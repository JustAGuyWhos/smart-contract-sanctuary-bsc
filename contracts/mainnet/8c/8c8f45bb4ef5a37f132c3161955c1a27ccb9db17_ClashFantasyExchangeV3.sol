// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IClashFantasyCards {
    function updateCardState(address _from, uint256 _tokenId, uint _state) external; 
    function getCardState(address _from, uint256 _tokenId) external view returns(uint);
    function getCard(uint256 _tokenId) external view returns(uint256, bool, address, uint, uint, uint256);
    function transferTo( address from, address to, uint256 id, uint256 amount) external;
    function balanceOf(address _address, uint256 _tokenId) external view returns (uint256);
}

contract ClashFantasyExchangeV3 is Initializable {
    IClashFantasyCards private contractCards;
    IERC20 private contractErc20;
    address private adminContract;
    
    address private walletPrimary;
    address private walletSecondary;

    uint percentage;
    
    struct HistoryCardExchange {
        address from;
        address to;
        uint256 price;
        uint percentage;
        uint256 timestamp;
        uint256 typeOf;
    }

    struct CardExchange {
        uint256 token;
        uint256 price;
        uint percentage;
        bool exists;
        uint256 timestamp;
    }

    mapping(uint256 => CardExchange) public cardExchanges;

    mapping(uint256 => HistoryCardExchange[]) public historyCardExchanges;

    CardExchange[] cardExchangeArr;

    modifier onlyAdminOwner() {
        require(
            adminContract == msg.sender,
            "Only the contract admin owner can call this function"
        );
        _;
    }

    modifier isOwnerCard(uint256 _tokenId) {
        uint256 _balanceOf = contractCards.balanceOf(msg.sender, _tokenId);
        require(_balanceOf >= 1, "Check balance token");
        _;
    }

    event HistoryCard(address from, address to, uint256 price, uint256 action );

    function initialize(IClashFantasyCards _contractCards, IERC20 _token) public initializer {
        contractCards = _contractCards;
        contractErc20 = _token;
        adminContract = msg.sender;
        walletPrimary = msg.sender;
        walletSecondary = msg.sender;
        percentage = 15;
    }

    function withdrawCard(uint256 _tokenId) 
        public
        isOwnerCard(_tokenId)
    {
        require(cardExchanges[_tokenId].exists == true, "Card Not In Sale");

        contractCards.updateCardState(msg.sender, _tokenId, 1);
        delete cardExchanges[_tokenId];
    
        removeByValue(_tokenId);
    }

    function transferCard(uint256 _tokenId, address _to) 
        public
        isOwnerCard(_tokenId)
    {
        require(cardExchanges[_tokenId].exists == false, "Card In Sale");
        (uint cardState) = contractCards.getCardState(msg.sender, _tokenId);
        require(cardState == 1, "Card Must Be In Inventory");
        
        contractCards.transferTo(msg.sender, _to, _tokenId, 1);
    }

    function sellCard(uint256 _tokenId) public {
        CardExchange storage card = cardExchanges[_tokenId];
        require(card.exists == true, "Card Not In Sale");

        (,, address wallet,,,) = contractCards.getCard(_tokenId);

        uint256 resultPrice = card.price * 10**18;
        checkBalanceAllowanceToken(resultPrice);

        transferAmount(resultPrice, card.percentage, wallet);
        
        contractCards.transferTo(wallet, msg.sender, _tokenId, 1);

        historyCardExchanges[_tokenId].push(
            HistoryCardExchange(
                wallet,
                msg.sender,
                card.price,
                card.percentage,
                block.timestamp,
                0
            )
        );

        delete cardExchanges[_tokenId];
        removeByValue(_tokenId);
    }
    
    function includeCard(uint256 _tokenId, uint256 _price)
        public
        isOwnerCard(_tokenId)
    {
        require(cardExchanges[_tokenId].exists == false, "Card Already In Sale");
        (uint cardState) = contractCards.getCardState(msg.sender, _tokenId);
        require(cardState == 1, "Card Must Be In Inventory");

        contractCards.updateCardState(msg.sender, _tokenId, 0);

        cardExchangeArr.push(
            CardExchange(
                _tokenId, _price, percentage, true, block.timestamp
            )
        );

        cardExchanges[_tokenId] = CardExchange(
            _tokenId, _price, percentage, true, block.timestamp
        );
    }

    function find(uint value) internal view returns(uint) {
        uint i = 0;
        while (cardExchangeArr[i].token != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint value) internal {
        uint i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint _index) internal {
        cardExchangeArr[_index] = cardExchangeArr[cardExchangeArr.length-1];
        cardExchangeArr.pop();
    }

    function checkBalanceAllowanceToken(uint256 _price) internal view{
        uint256 balance = contractErc20.balanceOf(msg.sender);
        require(balance >= _price, "Check the token balance");

        uint256 allowance = contractErc20.allowance(msg.sender, address(this));
        require(allowance == _price, "Check the token allowance");
    }

    function getHistoryCardByTokenId(uint256 _tokenId) 
        public view returns(HistoryCardExchange[] memory)
    {
        return historyCardExchanges[_tokenId];
    }

    function getCards()  public view returns(CardExchange[] memory) {
        return cardExchangeArr;
    }

    function getCardInfo(uint256 _tokenId) 
        public view 
        returns(CardExchange memory)
    {
        CardExchange storage card = cardExchanges[_tokenId];
        return card;
    }


    function updateContractCards(IClashFantasyCards _address) 
        public
    {
        contractCards = _address;
    }

    function transferAmount(uint256 _amount, uint _percentage , address wallet)
        internal
    {
        uint toSender = ( (100 - _percentage ) * 10 );
        uint toDivide = ( (_percentage ) * 10 ) / 2;

        uint256 normalTransfer = (_amount / uint256(1000)) * uint256(toSender);
        uint256 half = (_amount / uint256(1000)) * uint256(toDivide);
        
        contractErc20.transferFrom(msg.sender, wallet, normalTransfer);
        contractErc20.transferFrom(msg.sender, walletPrimary, half);
        contractErc20.transferFrom(msg.sender, walletSecondary, half);
    }

    function updateWalletPrimary(address _address) public onlyAdminOwner {
        walletPrimary = _address;
    }

    function updateWalletSecondary(address _address) public onlyAdminOwner {
        walletSecondary = _address;
    }

    function updatePercentage(uint _percentage) public onlyAdminOwner {
        percentage = _percentage;
    }

    function getAdmin() public view returns(address){
        return adminContract;
    }
    
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function version() public pure returns (string memory) {
        return "v3";
    }
    
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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