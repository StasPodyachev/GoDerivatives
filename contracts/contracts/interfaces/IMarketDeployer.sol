pragma solidity =0.8.9;

import "./IOracle.sol";

interface IMarketDeployer {
    struct Parameters {
        address factory;
        address deposit;
        string underlyingAssetName;
        address coin;
        uint256 duration;
        address oracleAddress;
        address storageAddress;
        IOracle.Type oracleType;
        uint256 feeKeeper;
        uint256 feeService;
    }

    function parameters() external view returns (Parameters memory params);
}
