// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./IDerivativeCFD.sol";

interface IStorage {
    function getDeal(uint256 id) external returns (IDerivativeCFD.Deal memory);

    function addDeal(address marketAddress) external returns (uint256);
}
