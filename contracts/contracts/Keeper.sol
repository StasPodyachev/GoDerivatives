pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IMarketDeployer.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IKeeper.sol";
import "./Market.sol";

contract Keeper is IKeeper, Ownable {
    mapping(address => mapping(address => bool)) operatorMarkets;
    mapping(address => bool) operators;

    IFactory factory;

    modifier onlyOperator() {
        require(
            operators[msg.sender] == true,
            "Keeper: Caller is not an operator"
        );
        _;
    }

    function setFactory(address factoryAddress) external onlyOwner {
        factory = IFactory(factoryAddress);
    }

    function setOperator(address operatorAddress) external onlyOwner {
        operators[operatorAddress] = true;
    }

    function removeOperator(address operatorAddress) external onlyOwner {
        delete operators[operatorAddress];
    }

    function takeOperatorProfit() external onlyOwner {
        operators[operatorAddress] = true;
    }

    function setMarket(IMarketDeployer.Parameters memory parameters)
        external
        onlyOperator
    {
        address marketAddress = factory.createMarket(parameters);
        operatorMarkets[msg.sender][marketAddress] = true;
    }

    function freezeMarket(address marketAddress, bool freeze) external {
        require(
            operatorMarkets[msg.sender][marketAddress] == true,
            "Keeper: Caller is not an operator"
        );

        Market(marketAddress).freezeMarket(freeze);
    }

    function setAMM(address ammAddress) external onlyOperator {}

    function freezeAMM(address ammAddress) external onlyOperator {}

    function deleteAMM(address ammAddress) external onlyOperator {}

    function setOracle(address operator) external onlyOperator {}
}
