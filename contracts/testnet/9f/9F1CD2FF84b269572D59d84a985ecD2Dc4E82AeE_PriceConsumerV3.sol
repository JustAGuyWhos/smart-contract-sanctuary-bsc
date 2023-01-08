// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
  AggregatorV3Interface internal priceFeed;

  /**
   * Network: Goerli
   * Aggregator: ETH/USD
   * Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
   */
  constructor() {
    priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
  }

  /**
   * Returns the latest price
   */
  function getLatestPrice() public view returns (int) {
    (
      ,
      /*uint80 roundID*/
      int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
      ,
      ,

    ) = priceFeed.latestRoundData();
    return price;
  }
  // function getLatestPrice() public pure returns (int) {
  //   // (
  //   //   ,
  //   //   /*uint80 roundID*/
  //   //   int price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
  //   //   ,
  //   //   ,

  //   // ) = priceFeed.latestRoundData();
  //   return int(28400000000);
  // }
}