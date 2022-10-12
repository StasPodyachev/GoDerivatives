// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IDerivativeCFD.sol";

interface IMarket {
    function getDeal(uint256 dealId) external view returns (IDerivativeCFD.Deal memory);
}