// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 * Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/examples/SimpleToken.sol
 */
contract SimpleToken is ERC20 {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */

    mapping(address => uint256) internal _nextTime;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function sendTokens(address wallet) external {
        uint256 next = _nextTime[wallet];
        require(block.timestamp >= next, "Many request for last 24 hours");

        _mint(wallet, 5000 * 10**18);

        _nextTime[wallet] = block.timestamp + 86400;
    }
}
