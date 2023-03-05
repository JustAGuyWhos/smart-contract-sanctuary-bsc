/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Erc20_SD {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
contract Presale {
    AggregatorV3Interface public TOKENPRICE;
    Erc20_SD buytoken;
    Erc20_SD selltoken;
    uint256 public tokenprice;
    uint256 public priceinusd=1;
   
    constructor(address _buytoken, address _selltoken) {
        TOKENPRICE=AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        buytoken = Erc20_SD(_buytoken);
        selltoken = Erc20_SD(_selltoken);
        tokenprice=100;
        }
    // address public oracle = address(TOKENPRICE);
    function buy(uint256 _amount) public {
      uint256 value=_amount*tokenprice;
      buytoken.transferFrom(msg.sender,address(this),_amount);
      selltoken.transfer(msg.sender,value);
    }
      function buyTokenswitheth() public payable {
        uint256 Value = (msg.value *priceinusd*getLatestPrice()*1e8)/1e27;
       selltoken.transfer(msg.sender,Value);
      
    }
    function sell(uint256 amu) public {
      uint256 Val=amu*priceinusd/getLatestPrice();
      selltoken.transferFrom(msg.sender,address(this),amu);
      payable(msg.sender).transfer(Val);
    }
      function getLatestPrice() public view returns(uint){
        (,int price,,,) = TOKENPRICE.latestRoundData();
        return uint (price * 10);
    }
}