pragma solidity =0.8.9;

import "./IMarketDeployer.sol";

interface IKeeper {
    function setFactory(address factoryAddress) external;

    function setOperator(address operatorAddress) external;

    function removeOperator(address operatorAddress) external;

    function setMarket(IMarketDeployer.Parameters memory parameters) external;

    function freezeMarket(address marketAddress, bool freeze) external;

    function setAMM(address ammAddress) external;

    function freezeAMM(address ammAddress) external;

    function deleteAMM(address ammAddress) external;

    function setOracle(address operator) external;
}
