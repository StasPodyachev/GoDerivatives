pragma solidity =0.8.9;

import "./DerivativeCFD.sol";
import "./interfaces/IMarketDeployer.sol";

contract Market is DerivativeCFD {
    struct Settings {
        uint256 marketId;
        string underlyingAssetName;
        address coin;
        uint256 duration;
    }

    constructor() {
        (address factory_, address deposit_) = IMarketDeployer(msg.sender)
            .parameters();

        factory = factory_;
        deposit = IDeposit(deposit_);
    }

    modifier onlyDeposit() {
        require(
            msg.sender == address(deposit),
            "Market: caller is not the deposit"
        );
        _;
    }

    function withdraw(
        address sender,
        uint256 dealID,
        uint256 amount
    ) external onlyDeposit {
        Deal storage deal = deals[dealID];
        uint256 free;

        if (sender == deal.buyer) {
            free = deal.balanceBuyer - deal.lockBuyer;

            require(free >= amount, "Market: Insufficient balance");

            deal.balanceBuyer = deal.lockBuyer - amount;
        } else {
            free = deal.balanceSeller - deal.lockSeller;

            require(free >= amount, "Market: Insufficient balance");

            deal.balanceSeller = deal.lockSeller - amount;
        }
    }

    function withdrawFree(address sender)
        external
        onlyDeposit
        returns (uint256 amount)
    {
        uint256[] memory deals_ = buyers[sender];

        for (uint256 i = 0; i < deals_.length; i++) {
            Deal storage deal = deals[deals_[i]];

            amount += deal.balanceBuyer - deal.lockBuyer;
            deal.balanceBuyer = deal.lockBuyer;
        }

        deals_ = sellers[sender];

        for (uint256 i = 0; i < deals_.length; i++) {
            Deal storage deal = deals[deals_[i]];

            amount += deal.balanceSeller - deal.lockSeller;
            deal.balanceSeller = deal.lockSeller;
        }
    }
}
