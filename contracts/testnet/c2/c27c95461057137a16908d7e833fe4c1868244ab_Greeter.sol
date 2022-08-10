/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// File: meta.sol


pragma solidity ^0.8.0;


contract Greeter {
    string public greeting;
     address public owner;

   


struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
}

struct MetaTransaction {
		uint256 nonce;
		address from;
}
   mapping(address => uint256) public nonces;

bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(bytes("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));
bytes32 internal constant META_TRANSACTION_TYPEHASH = keccak256(bytes("MetaTransaction(uint256 nonce,address from)"));
bytes32 internal DOMAIN_SEPARATOR = keccak256(abi.encode(
    EIP712_DOMAIN_TYPEHASH,
		keccak256(bytes("Greeter")),
		keccak256(bytes("1")),
		97, // Kovan
		address(this)
));  
function setGreetingMeta(address userAddress,string memory newQuote, bytes32 r, bytes32 s, uint8 v) public {
    
 MetaTransaction memory metaTx = MetaTransaction({
    nonce: nonces[userAddress],
    from: userAddress
   });
    
 bytes32 digest = keccak256(
    abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(META_TRANSACTION_TYPEHASH, metaTx.nonce, metaTx.from))
        )
    );

   require(userAddress != address(0), "invalid-address-0");
   require(userAddress == ecrecover(digest, v, r, s), "invalid-signatures");
   greeting = newQuote;
    owner  = userAddress;
   nonces[userAddress]++;
 } 
  function greet() public view returns (string memory currentQuote, address currentOwner) {
        currentQuote = greeting;
        currentOwner = owner;
    }
}