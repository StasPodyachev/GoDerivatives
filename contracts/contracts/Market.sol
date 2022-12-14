pragma solidity =0.8.9;

import "./DerivativeCFD.sol";
import "./interfaces/IMarketDeployer.sol";
import "./interfaces/IStorage.sol";
import "./interfaces/IFactory.sol";

contract Market is DerivativeCFD {
    constructor(IMarketDeployer.Parameters memory params) {

        // TODO: maybe need required and security

        factory = params.factory;
        deposit = IDeposit(params.deposit);
        coin = params.coin;
        underlyingAssetName = params.underlyingAssetName;
        duration = params.duration;
        oracleAggregatorAddress = params.oracleAggregatorAddress;
        oracleType = params.oracleType;
        storage_ = IStorage(params.storageAddress);
        operatorFee_ = params.operatorFee;
        serviceFee_ = params.serviceFee;
        operator = params.operator;
        nft = DealNFT(params.nft);

        if(params.amm!=address(0)){
            amm = IAMM(params.amm);
        }

        address oracleAddress = IFactory(factory).getOracleAddress(oracleType);
        oracle = IOracle(oracleAddress);
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
