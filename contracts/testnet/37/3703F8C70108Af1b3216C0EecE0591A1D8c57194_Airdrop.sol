/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
contract Airdrop {
  address payable public admin;
  mapping(address => bool) public processedAirdrops;
  IERC20 public token;
  uint public currentAirdropAmount;
  uint public maxAirdropAmount = 100000000 * 10 ** 18;
  event AirdropProcessed(
    address recipient,
    uint amount,
    uint date
  );
   modifier onlyadmin() {
    if (msg.sender == admin) {}
    _;
  }
  constructor(address _token) {
    admin = payable(msg.sender); 
    token = IERC20(_token);
  }
  function updateAdmin(address payable newAdmin) external onlyadmin {
    require(payable(msg.sender) == admin, "only admin");
    admin = newAdmin;
  }
  function claimTokens(
    address recipient,
    uint amount,
    bytes calldata signature
  ) external onlyadmin {
    bytes32 message = prefixed(keccak256(abi.encodePacked(
      recipient, 
      amount
    )));
    require(recoverSigner(message, signature) == admin , 'wrong signature');
    require(processedAirdrops[recipient] == false, 'airdrop already processed');
    require(currentAirdropAmount + amount <= maxAirdropAmount, 'airdropped 100% of the tokens');
    processedAirdrops[recipient] = true;
    currentAirdropAmount += amount;
    token.transfer(recipient, amount);
    emit AirdropProcessed(
      recipient,
      amount,
      block.timestamp
    );
  }
  function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      '\x19Ethereum Signed Message:\n32', 
      hash
    ));
  }
  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
  {
    uint8 v;
    bytes32 r;
    bytes32 s;
    (v, r, s) = splitSignature(sig);
    return ecrecover(message, v, r, s);
  }
  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
  {
    require(sig.length == 65);
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }
    return (v, r, s);
  }
     function gettokenaddress() public view  returns (IERC20) {
        return IERC20(token);
    }
}