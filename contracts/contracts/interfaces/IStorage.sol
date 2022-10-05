// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./IDerivativeCFD.sol";

interface IStorage {
    function setFactory(address factoryAddress) external;

    function getDeal(uint256 id) external returns (IDerivativeCFD.Deal memory);

    function addDealId() external returns (uint256);
}
