pragma solidity =0.8.9;

import "./IOracle.sol";

interface IMarketDeployer {
    struct Parameters {
        address factory;
        address deposit;
        address operator;
        string underlyingAssetName;
        address coin;
        uint256 duration;
        address oracleAggregatorAddress;
        address storageAddress;
        IOracle.Type oracleType;
        uint256 operatorFee;
        uint256 serviceFee;
    }

    function parameters() external view returns (Parameters memory params);
}
