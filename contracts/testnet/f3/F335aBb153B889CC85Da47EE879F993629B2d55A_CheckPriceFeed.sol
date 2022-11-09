// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

contract CheckPriceFeed {
  function getCurrentPrice(address _aggregator) public view returns (int256) {
    (, int256 basePrice, , , ) = AggregatorV3Interface(_aggregator).latestRoundData();
    return basePrice;
  }

  function getRoundData(address _aggregator, uint80 roundId) public view returns (int256) {
    (, int256 basePrice, , , ) = AggregatorV3Interface(_aggregator).getRoundData(roundId);
    return basePrice;
  }
}

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