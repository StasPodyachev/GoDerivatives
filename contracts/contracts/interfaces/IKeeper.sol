pragma solidity =0.8.9;

import "./IOracle.sol";

interface IKeeper {
    function setFactory(address factoryAddress) external;

    function setOperator(address operatorAddress) external;

    function removeOperator() external;

    function setMarket(
        string memory underlyingAssetName,
        address coin,
        uint256 duration,
        address oracleAggregatorAddress,
        IOracle.Type oracleType,
        uint256 operatorFee,
        uint256 serviceFee
    ) external;

    function freezeMarket(address marketAddress, bool freeze) external;

    function setAMM(address ammAddress) external;

    function freezeAMM(address ammAddress) external;

    function deleteAMM(address ammAddress) external;
}
