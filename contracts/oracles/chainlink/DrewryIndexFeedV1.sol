// SPDX-License-Identifier: SSPL-1.0
pragma solidity ^0.6.12;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract DrewryIndexFeedV1 {

    AggregatorV3Interface internal priceFeed;
    /**
     * Network Deployments: Rinkeby
     * Aggregator: Drewry Futures
     * Address: _CONTRACT_ADDRESS
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(_CONTRACT_ADDRESS);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}
