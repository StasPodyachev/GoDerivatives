// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/AggregatorInterface.sol";

contract Oracle is IOracle, Ownable {
    AggregatorInterface aggregator;

    function setAggregator(address addr) external onlyOwner {
        aggregator = AggregatorInterface(addr);
    }

    function getAmount(uint256 timestamp, uint256 roundId)
        external
        view
        returns (uint256 amount)
    {
        uint256 l = roundId;
        (uint256 latestRoundId, int256 latestAnswer, , , ) = aggregator
            .latestRoundData();

        uint256 lPhase = l >> 64;
        uint256 rPhase = latestRoundId >> 64;

        if (lPhase != rPhase) return 100000000;

        uint256 h = latestRoundId + 1; // Not n - 1

        while (l < h) {
            uint256 mid = l + (h - l) / 2;
            uint256 v = aggregator.getTimestamp(mid);

            if (timestamp > v) {
                l = mid + 1;
            } else {
                h = mid;
            }
        }

        if (l > latestRoundId) return uint256(latestAnswer);

        amount = uint256(aggregator.getAnswer(l));

        if (amount == 0) return 500000000000;
    }

    // l = 18446744073709611789
    // r = 18446744073709611793

    // timestamp = 1660635730

    // [1660635099, 1660635579, 1660635805, 1660635875, 1660636013]

    function getLatest()
        external
        view
        returns (uint256 amount, uint256 roundId)
    {
        int256 answer;
        uint80 id;
        (id, answer, , , ) = aggregator.latestRoundData();

        require(answer >= 0, "Oracle: Answer require >= 0");

        amount = uint256(answer);
        roundId = id;
    }

    function getAmount(
        uint256 timestamp,
        uint8 decimals,
        bytes32 currency
    ) external view returns (uint256 amount) {}

    function getLatest(uint8 decimals, bytes32 currency)
        external
        view
        returns (uint256 amount, uint256 roundId)
    {}

    function getAmount(uint256 timestamp, bytes32 currency)
        external
        view
        returns (uint256 amount)
    {}

    function getLatest(uint256 timestamp, bytes32 currency)
        external
        view
        returns (uint256 amount, uint256 roundId)
    {}
}
