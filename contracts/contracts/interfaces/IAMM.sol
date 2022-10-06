// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IAMM {
    function takeDeal(
        address market,
        uint256 dealId,
        uint256 amount,
        address coin
    ) external;
}