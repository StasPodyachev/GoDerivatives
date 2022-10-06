pragma solidity =0.8.9;

import "./DerivativeCFD.sol";
import "./interfaces/IMarketDeployer.sol";
import "./interfaces/IStorage.sol";

contract Market is DerivativeCFD {
    constructor() {
        IMarketDeployer.Parameters memory params = IMarketDeployer(msg.sender)
            .parameters();

        factory = params.factory;
        deposit = IDeposit(params.deposit);
        coin = params.coin;
        underlyingAssetName = params.underlyingAssetName;
        duration = params.duration;
        oracleAddress = params.oracleAddress;
        oracleType = params.oracleType;
        storage_ = IStorage(params.storageAddress);
        keepersFee = params.keepersFee;
        serviceFee = params.serviceFee;
    }

    modifier onlyDeposit() {
        require(
            msg.sender == address(deposit),
            "Market: caller is not the deposit"
        );
        _;
    }

    function getDeal(uint256 dealId) external view returns (Deal memory) {
        return deals[dealId];
    }
}
