pragma solidity =0.8.9;

import "./DerivativeCFD.sol";
import "./interfaces/IMarketDeployer.sol";

contract Market is DerivativeCFD {
    constructor() {
        (factory, deposit) = IMarketDeployer(msg.sender).parameters();
    }

    modifier onlyDeposit() {
        require(msg.sender == deposit, "Market: caller is not the deposit");
        _;
    }

    function withdraw(
        address sender,
        uint256 dealID,
        uint256 amount
    ) external onlyDeposit {
        Deal storage deal = deals[dealID];
        uint256 free;

        if (sender == deal.maker) {
            free = deal.balanceMaker - deal.lockMaker;

            require(free >= amount, "Market: Insufficient balance");

            deal.balanceMaker = deal.lockMaker - amount;
        } else {
            free = deal.balanceTaker - deal.lockTaker;

            require(free >= amount, "Market: Insufficient balance");

            deal.balanceTaker = deal.lockTaker - amount;
        }
    }

    function withdrawFree(address sender)
        external
        onlyDeposit
        returns (uint256 amount)
    {
        uint256[] memory deals_ = makers[sender];

        for (uint256 i = 0; i < deals_.length; i++) {
            Deal storage deal = deals[deals_[i]];

            amount += deal.balanceMaker - deal.lockMaker;
            deal.balanceMaker = deal.lockMaker;
        }

        deals_ = takers[sender];

        for (uint256 i = 0; i < deals_.length; i++) {
            Deal storage deal = deals[deals_[i]];

            amount += deal.balanceTaker - deal.lockTaker;
            deal.balanceTaker = deal.lockTaker;
        }
    }
}
