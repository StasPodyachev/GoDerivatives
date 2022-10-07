pragma solidity =0.8.9;

import "./IOracle.sol";

interface IKeeper {
    function setFactory(address factoryAddress) external;

    function setOperator(address operatorAddress) external;

    function removeOperator() external;

    function createMarket(
        string memory underlyingAssetName,
        address coin,
        uint256 duration,
        address oracleAggregatorAddress,
        IOracle.Type oracleType,
        uint256 operatorFee,
        uint256 serviceFee
    ) external;

    function freezeMarket(address marketAddress, bool freeze) external;

    function createAmm(string calldata name, address market, address coin, uint256 amount) external payable;

    function freezeAMM(address ammAddress) external;

    function deleteAMM(address ammAddress) external;
}
