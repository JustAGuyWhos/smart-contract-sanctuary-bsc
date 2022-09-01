pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace1155 is Ownable {
    IERC1155 private _token;
    IERC20 private token20;

    mapping(address => uint256[]) adrToSellTokens;
    uint256[] allSellTokens;
    mapping(uint256 => uint256) tokenIdToCost;
    mapping(uint256 => address) idToAdr;

    uint256 public totalSold;
    mapping(address => uint256[]) idToSold;
    uint256[] soldNFTIds;

    uint256 public sellFee;
    uint256 public buyFee;
    bool pause;

    mapping(address => bool) blacklist;
    mapping(address => wl) whitelist;
    struct wl {
        uint256 sell;
        uint256 buy;
    }

    uint256 public usersWhitelisted;
    uint256 public userBlacklisted;

    // admins
    mapping(uint256 => Admin) idToAdmin;
    mapping(address => uint256) adrToId;
    mapping(address => bool) isAdmin;
    uint256 public adminAmount;
    address[] private admins;

    struct Admin {
        uint256 id;
        address user;
        bool isAdmin;
    }

    address assetContract;
    string assetContractName;

    constructor(
        address LVadr,
        uint256 sellFee_,
        uint256 buyFee_,
        address payingContract,
        string memory assetName
    ) {
        _token = IERC1155(LVadr);
        token20 = IERC20(payingContract);
        assetContract = payingContract;
        assetContractName = assetName;
        sellFee = sellFee_;
        buyFee = buyFee_;
    }

    function sellToken(uint256[] memory tokenIds, uint256[] memory costs)
        external
    {
        require(!blacklist[msg.sender], "User blacklisted");
        require(tokenIds.length == costs.length, "Not the same length2");
        require(!pause, "Contract is on pause");
        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _token.balanceOf(msg.sender, tokenIds[i]) != 0,
                "you are not owner of the tokens"
            );
            require(
                !isInArray(allSellTokens, tokenIds[i]),
                "Already is being sold"
            );
            adrToSellTokens[msg.sender].push(tokenIds[i]);
            if (!isInArray(allSellTokens, tokenIds[i])) {
                allSellTokens.push(tokenIds[i]);
            }
            tokenIdToCost[tokenIds[i]] = costs[i];
            idToAdr[tokenIds[i]] = msg.sender;
        }
    }

    function setSellFee(uint256 newSellFee) external onlyOwner {
        sellFee = newSellFee;
    }

    function removeSellToken(address user, uint256[] memory tokenIds) external {
        require(
            user == msg.sender ||
                msg.sender == owner() ||
                idToAdmin[adrToId[msg.sender]].isAdmin,
            "not the owner"
        );
        require(!pause, "Contract is on pause");
        require(!blacklist[user], "User blacklisted");
        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _token.balanceOf(user, tokenIds[i]) != 0,
                "you are not owner of the tokens"
            );
            require(
                isInArray(adrToSellTokens[user], tokenIds[i]),
                "Not all tokens are in sell pool"
            );

            for (uint256 j; j < allSellTokens.length; j++) {
                if (tokenIds[i] == allSellTokens[j]) {
                    removeFromAllSellTokens(j);
                }
            }
            for (uint256 l; l < adrToSellTokens[user].length; l++) {
                if (tokenIds[i] == adrToSellTokens[user][l]) {
                    removeFromAdrToSellToken(user, l);
                }
            }

            tokenIdToCost[tokenIds[i]] = 0;
            idToAdr[tokenIds[i]] = address(0x0);
        }
    }

    function buyToken(uint256 tokenId) external payable {
        require(!pause, "Contract is on pause");
        require(!blacklist[msg.sender], "User blacklisted");

        require(
            isInArray(allSellTokens, tokenId),
            "Not all tokens are in sell pool"
        );

        if (assetContract == address(0x0)) {
            if (whitelist[idToAdr[tokenId]].sell > 0) {
                if (whitelist[msg.sender].buy > 0) {
                    require(
                        msg.value >=
                            tokenIdToCost[tokenId] +
                                (tokenIdToCost[tokenId] *
                                    whitelist[msg.sender].buy) /
                                100,
                        "Not enough money for the transferFee"
                    );

                    (bool success, ) = payable(idToAdr[tokenId]).call{
                        value: ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100) -
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100 -
                            (tokenIdToCost[tokenId] *
                                whitelist[idToAdr[tokenId]].sell) /
                            100)
                    }("");

                    require(success);
                } else {
                    require(
                        msg.value >=
                            tokenIdToCost[tokenId] +
                                (tokenIdToCost[tokenId] * buyFee) /
                                100,
                        "Not enough money for the transferFee"
                    );

                    (bool success, ) = payable(idToAdr[tokenId]).call{
                        value: ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] * buyFee) /
                            100) -
                            (tokenIdToCost[tokenId] * buyFee) /
                            100 -
                            (tokenIdToCost[tokenId] *
                                whitelist[idToAdr[tokenId]].sell) /
                            100)
                    }("");

                    require(success);
                }
            } else {
                if (whitelist[msg.sender].buy > 0) {
                    require(
                        msg.value >=
                            tokenIdToCost[tokenId] +
                                (tokenIdToCost[tokenId] *
                                    whitelist[msg.sender].buy) /
                                100,
                        "Not enough money for the transferFee"
                    );

                    (bool success, ) = payable(idToAdr[tokenId]).call{
                        value: ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100) -
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100 -
                            (tokenIdToCost[tokenId] * sellFee) /
                            100)
                    }("");

                    require(success);
                } else {
                    require(
                        msg.value >=
                            tokenIdToCost[tokenId] +
                                (tokenIdToCost[tokenId] * buyFee) /
                                100,
                        "Not enough money for the transferFee"
                    );

                    (bool success, ) = payable(idToAdr[tokenId]).call{
                        value: ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] * buyFee) /
                            100) -
                            (tokenIdToCost[tokenId] * buyFee) /
                            100 -
                            (tokenIdToCost[tokenId] * sellFee) /
                            100)
                    }("");

                    require(success);
                }
            }
        } else {
            if (whitelist[idToAdr[tokenId]].sell > 0) {
                if (whitelist[msg.sender].buy > 0) {
                    token20.transferFrom(
                        msg.sender,
                        idToAdr[tokenId],
                        ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100) -
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100 -
                            (tokenIdToCost[tokenId] *
                                whitelist[idToAdr[tokenId]].sell) /
                            100)
                    );

                    token20.transferFrom(
                        msg.sender,
                        address(this),
                        (tokenIdToCost[tokenId] * whitelist[msg.sender].buy) /
                            100 +
                            (tokenIdToCost[tokenId] *
                                whitelist[idToAdr[tokenId]].sell) /
                            100
                    );
                } else {
                    token20.transferFrom(
                        msg.sender,
                        idToAdr[tokenId],
                        ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] * buyFee) /
                            100) -
                            (tokenIdToCost[tokenId] * buyFee) /
                            100 -
                            (tokenIdToCost[tokenId] *
                                whitelist[idToAdr[tokenId]].sell) /
                            100)
                    );

                    token20.transferFrom(
                        msg.sender,
                        address(this),
                        (tokenIdToCost[tokenId] * buyFee) /
                            100 +
                            (tokenIdToCost[tokenId] *
                                whitelist[idToAdr[tokenId]].sell) /
                            100
                    );
                }
            } else {
                if (whitelist[msg.sender].buy > 0) {
                    token20.transferFrom(
                        msg.sender,
                        idToAdr[tokenId],
                        ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100) -
                            (tokenIdToCost[tokenId] *
                                whitelist[msg.sender].buy) /
                            100 -
                            (tokenIdToCost[tokenId] * sellFee) /
                            100)
                    );

                    token20.transferFrom(
                        msg.sender,
                        address(this),
                        (tokenIdToCost[tokenId] * whitelist[msg.sender].buy) /
                            100 +
                            (tokenIdToCost[tokenId] * sellFee) /
                            100
                    );
                } else {
                    token20.transferFrom(
                        msg.sender,
                        idToAdr[tokenId],
                        ((tokenIdToCost[tokenId] +
                            (tokenIdToCost[tokenId] * buyFee) /
                            100) -
                            (tokenIdToCost[tokenId] * buyFee) /
                            100 -
                            (tokenIdToCost[tokenId] * sellFee) /
                            100)
                    );

                    token20.transferFrom(
                        msg.sender,
                        address(this),
                        (tokenIdToCost[tokenId] * buyFee) /
                            100 +
                            (tokenIdToCost[tokenId] * sellFee) /
                            100
                    );
                }
            }
        }

        if (!isInArray(soldNFTIds, tokenId)) {
            totalSold++;
        }
        idToSold[idToAdr[tokenId]].push(tokenId);

        _token.safeTransferFrom(idToAdr[tokenId], msg.sender, tokenId, 1, "");
        /*
        (bool success, ) = payable(idToAdr[tokenId]).call{
            value: ((msg.value * (100 - sellFee)) / 100)
        }("");
        require(success);*/

        for (uint256 j; j < allSellTokens.length; j++) {
            if (tokenId == allSellTokens[j]) {
                removeFromAllSellTokens(j);
            }
        }
        for (uint256 l; l < adrToSellTokens[idToAdr[tokenId]].length; l++) {
            if (tokenId == adrToSellTokens[idToAdr[tokenId]][l]) {
                removeFromAdrToSellToken2(l, tokenId);
            }
        }

        tokenIdToCost[tokenId] = 0;
        idToAdr[tokenId] = address(0x0);
    }

    function removeFromAllSellTokens(uint256 index)
        internal
        returns (uint256[] memory)
    {
        for (uint256 i = index; i < allSellTokens.length - 1; i++) {
            allSellTokens[i] = allSellTokens[i + 1];
        }
        delete allSellTokens[allSellTokens.length - 1];
        allSellTokens.pop();
        return allSellTokens;
    }

    function removeFromAdrToSellToken(address user, uint256 index)
        internal
        returns (uint256[] memory)
    {
        for (uint256 i = index; i < adrToSellTokens[user].length - 1; i++) {
            adrToSellTokens[user][i] = adrToSellTokens[user][i + 1];
        }
        delete adrToSellTokens[user][adrToSellTokens[user].length - 1];
        adrToSellTokens[user].pop();
        return adrToSellTokens[user];
    }

    function removeFromAdrToSellToken2(uint256 index, uint256 tokenId)
        internal
        returns (uint256[] memory)
    {
        for (
            uint256 i = index;
            i < adrToSellTokens[idToAdr[tokenId]].length - 1;
            i++
        ) {
            adrToSellTokens[idToAdr[tokenId]][i] = adrToSellTokens[
                idToAdr[tokenId]
            ][i + 1];
        }
        delete adrToSellTokens[idToAdr[tokenId]][
            adrToSellTokens[idToAdr[tokenId]].length - 1
        ];
        adrToSellTokens[idToAdr[tokenId]].pop();
        return adrToSellTokens[idToAdr[tokenId]];
    }

    function changePauseStatus() external onlyOwner {
        pause = !pause;
    }

    function checkNFTsCost(uint256 id) external view returns (uint256) {
        require(tokenIdToCost[id] > 0, "NFT is not in sell pool");
        return tokenIdToCost[id];
    }

    function checkUserSellTokens(address user)
        external
        view
        returns (uint256[] memory)
    {
        return adrToSellTokens[user];
    }

    function checkBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function checkAllSellNFTs() external view returns (uint256[] memory) {
        return allSellTokens;
    }

    function isApproved(address from) external view returns (bool) {
        return _token.isApprovedForAll(from, address(this));
    }

    function isInArray(uint256[] memory Ids, uint256 id)
        internal
        pure
        returns (bool)
    {
        for (uint256 i; i < Ids.length; i++) {
            if (Ids[i] == id) {
                return true;
            }
        }
        return false;
    }

    function addToWhitelist(
        address user_,
        uint256 buyFee_,
        uint256 sellFee_
    ) external {
        if (isAdmin[user_]) {
            require(
                msg.sender == owner(),
                "only owner can add admin to whitelist"
            );
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can add to whitelist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user_ != owner(), "Not possible to add owner");
            }
        }
        require(
            whitelist[user_].buy == 0 && whitelist[user_].sell == 0,
            "Already in whitelist"
        );
        require(blacklist[msg.sender] == false, "Admin blacklisted");

        usersWhitelisted++;

        whitelist[user_].buy = buyFee_;
        whitelist[user_].sell = sellFee_;
    }

    function deleteFromWhitelist(address user) external {
        if (isAdmin[user]) {
            require(
                msg.sender == owner(),
                "only owner can delete admin from whitelist"
            );
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can delete from whitelist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user != owner(), "Not possible to add owner");
            }
        }
        require(blacklist[msg.sender] == false, "Admin blacklisted");

        require(
            whitelist[user].buy > 0 || whitelist[user].sell > 0,
            "User is not in whitelist"
        );
        whitelist[user].buy = 0;
        whitelist[user].sell = 0;

        usersWhitelisted--;
    }

    function addToBlacklist(address user) external {
        if (isAdmin[user]) {
            require(
                msg.sender == owner(),
                "only owner can add admin to blacklist"
            );
            idToAdmin[adrToId[user]].isAdmin = false;
            for (uint256 i; i < admins.length; i++) {
                if (admins[i] == idToAdmin[adrToId[user]].user) {
                    removeAdmin(i);
                    break;
                }
            }
            adminAmount--;
            isAdmin[user] = false;
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can add to blacklist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user != owner(), "Not possible to add owner");
            }
        }
        require(blacklist[msg.sender] == false, "Admin blacklisted");
        require(blacklist[user] == false, "User already blacklisted");
        blacklist[user] = true;
        userBlacklisted++;
    }

    function deleteFromBlacklist(address user) external {
        if (isAdmin[user]) {
            require(
                msg.sender == owner(),
                "only Owner can delete admin from blacklist"
            );
        } else {
            require(
                msg.sender == owner() || idToAdmin[adrToId[msg.sender]].isAdmin,
                "only owner or admin can delete from blacklist"
            );
            if (idToAdmin[adrToId[msg.sender]].isAdmin) {
                require(user != owner(), "Not possible to add owner");
            }
        }
        require(blacklist[user] == true, "Admin is not blacklisted");
        require(blacklist[msg.sender] == false, "Admin is not blacklisted");
        blacklist[user] = false;
        userBlacklisted--;
    }

    function isUserInBlacklist(address user) external view returns (bool) {
        require(
            msg.sender == owner() ||
                msg.sender == user ||
                idToAdmin[adrToId[msg.sender]].isAdmin
        );

        return blacklist[user];
    }

    function isUserInWhitelist(address user)
        external
        view
        returns (uint256 sellFee, uint256 buyFee)
    {
        require(
            msg.sender == owner() ||
                msg.sender == user ||
                idToAdmin[adrToId[msg.sender]].isAdmin
        );

        if (whitelist[user].buy == 0 && whitelist[user].buy == 0) {
            require(whitelist[user].buy != 0, "User is not whilelisted");
            return (0, 0);
        } else {
            return (whitelist[user].sell, whitelist[user].buy);
        }
    }

    function addAdmin(address admin) external onlyOwner {
        require(blacklist[msg.sender] == false, "User blacklisted");
        require(isAdmin[admin] != true, "Already admin");
        adminAmount++;
        idToAdmin[adminAmount] = Admin(adminAmount, admin, true);
        adrToId[admin] = adminAmount;
        admins.push(admin);
        isAdmin[admin] = true;
    }

    function showAdmins() external view returns (address[] memory) {
        return (admins);
    }

    function deleteAdmin(address admin) external onlyOwner {
        require(
            idToAdmin[adrToId[admin]].isAdmin == true,
            "User is not in admin list"
        );
        idToAdmin[adrToId[admin]].isAdmin = false;
        for (uint256 i; i < admins.length; i++) {
            if (admins[i] == idToAdmin[adrToId[admin]].user) {
                removeAdmin(i);
                break;
            }
        }
        adminAmount--;
        isAdmin[admin] = false;
    }

    function removeAdmin(uint256 index) internal returns (address[] memory) {
        for (uint256 i = index; i < admins.length - 1; i++) {
            admins[i] = admins[i + 1];
        }
        delete admins[admins.length - 1];
        admins.pop();
        return admins;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function checkTokenBalance() external view onlyOwner returns (uint256) {
        return token20.balanceOf(address(this));
    }

    function checkBNBBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdrawTokens() public onlyOwner {
        token20.transfer(msg.sender, token20.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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