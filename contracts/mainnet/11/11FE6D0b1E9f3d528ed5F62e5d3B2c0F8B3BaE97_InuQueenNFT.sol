// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ERC721.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract InuQueenNFT is ERC721, Ownable, Pausable {
    string private baseURI = 'https://mypinata.cloud/ipfs/';
    uint private maxSupply = 365;
    uint private mintedSupply = 1;
    uint private basePrice = 0;
    uint private reservedTotal = 50;
    uint private reservedUsed = 0;
    mapping(address => bool) private reservedAccounts;
    bool private isUseAllowedList = true;
    uint private allowedListPerSupply = 365;
    mapping(address => bool) private allowedList;
    mapping(address => uint) private allowedListSupply;

    constructor() ERC721("Inu Queen NFT", "InQuNFT") {
        pause();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdraw(address addr) external onlyOwner {
        payable(addr).transfer(address(this).balance);
    }

    function mint(uint amount) public payable whenNotPaused {
        if (isUseAllowedList) {
            require(allowedList[msg.sender], "Not in allowed list");
            require(allowedListSupply[msg.sender] + amount <= allowedListPerSupply, "Exceeds allowed list max supply");
        }

        require(mintedSupply < maxSupply, "Max supply reached");
        require(mintedSupply + amount <= maxSupply, "Exceeds max supply");

        require(msg.value >= basePrice * amount, "Not enough BNB sent");
        require(mintedSupply + reservedTotal - reservedUsed < maxSupply, "Exceeds max supply, code: 1");

        mintInner(amount);
    }

    function mintReserved(uint amount) public payable {
        require(reservedAccounts[msg.sender], "Not reserved account");

        mintInner(amount);
    }

    function mintInner(uint amount) internal {
        for (uint i = 0; i < amount; i++) {
            _safeMint(msg.sender, mintedSupply);
            mintedSupply++;

            if (reservedAccounts[msg.sender] && reservedUsed < reservedTotal) {
                reservedUsed++;
            }
            if (isUseAllowedList && allowedList[msg.sender]) {
                allowedListSupply[msg.sender] += 1;
            }
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }

    function setBasePrice(uint price) external onlyOwner {
        basePrice = price;
    }

    function setReserved(uint256 n) external onlyOwner {
        reservedTotal = n;
    }

    function setUseAllowedList(bool bl) external onlyOwner {
        isUseAllowedList = bl;
    }

    function addAllowedList(address[] memory addr) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            allowedList[addr[i]] = true;
        }
    }

    function removeAllowedList(address[] memory addr) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            delete allowedList[addr[i]];
        }
    }

    function setAllowedListPerSupply(uint n) external onlyOwner {
        allowedListPerSupply = n;
    }

    function addReservedAccounts(address[] memory addr) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            reservedAccounts[addr[i]] = true;
        }
    }

    function getStatus() public view returns (uint[] memory) {
        uint[] memory arr = new uint[](8);
        arr[0] = paused() ? 0 : 1;
        arr[1] = isUseAllowedList ? 1 : 0;
        arr[2] = basePrice;
        arr[3] = maxSupply;
        arr[4] = mintedSupply;
        arr[5] = reservedTotal;
        arr[6] = reservedUsed;
        arr[7] = allowedListPerSupply;
        return arr;
    }

    function getAccount(address addr) public view returns (uint[] memory) {
        uint[] memory arr = new uint[](4);
        arr[0] = reservedAccounts[addr] ? 1 : 0;
        arr[1] = allowedList[addr] ? 1 : 0;
        arr[2] = allowedListSupply[addr];
        arr[3] = balanceOf(addr);
        return arr;
    }
}