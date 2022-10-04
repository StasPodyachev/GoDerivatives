// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IOracle {
    enum Type {
        Chainlink
    }

    function getAmount(uint256 timestamp, uint256 roundId)
        external
        view
        returns (uint256 amount);

    function getLatest()
        external
        view
        returns (uint256 amount, uint256 roundId);

    function getAmount(
        uint256 timestamp,
        uint8 decimals,
        bytes32 currency
    ) external view returns (uint256 amount);

    function getLatest(uint8 decimals, bytes32 currency)
        external
        view
        returns (uint256 amount, uint256 roundId);

    function getAmount(uint256 timestamp, bytes32 currency)
        external
        view
        returns (uint256 amount);

    function getLatest(uint256 timestamp, bytes32 currency)
        external
        view
        returns (uint256 amount, uint256 roundId);
}
