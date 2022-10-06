// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IOracle {
    enum Type {
        Chainlink
    }

    function getAmount(
        address aggregatorAddress,
        uint256 timestamp,
        uint256 roundId
    ) external view returns (uint256 amount);

    function getLatest(address aggregatorAddress)
        external
        view
        returns (uint256 amount, uint256 roundId);
}
