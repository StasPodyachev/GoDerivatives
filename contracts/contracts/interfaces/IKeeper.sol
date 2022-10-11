pragma solidity =0.8.9;

import "./IOracle.sol";

interface IKeeper {
    function setFactory(address factoryAddress) external;

    function setOperator(address operatorAddress) external;

    function removeOperator() external;

    function addMarket(address marketAddress) external;

    function freezeMarket(address marketAddress, bool freeze) external;

    function createAmm(
        string calldata name,
        address market,
        address coin,
        uint256 amount
    ) external payable;

    function freezeAMM(address ammAddress) external;

    function deleteAMM(address ammAddress) external;
}
