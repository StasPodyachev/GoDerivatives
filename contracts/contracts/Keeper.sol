pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IMarketDeployer.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IKeeper.sol";
import "./interfaces/IOracle.sol";
import "./Market.sol";

contract Keeper is IKeeper, Ownable {
    mapping(address => bool) markets;
    address operator;

    IFactory factory;
    IDeposit deposit;

    modifier onlyOperator() {
        require(msg.sender == operator, "Keeper: Caller is not an operator");
        _;
    }

    function setFactory(address factoryAddress) external onlyOwner {
        factory = IFactory(factoryAddress);
        deposit = IDeposit(factory.depositAddress());
    }

    function setOperator(address operatorAddress) external onlyOwner {
        operator = operatorAddress;
    }

    function removeOperator() external onlyOwner {
        operator = address(0);
    }

    function takeOperatorProfit(address coin) external onlyOperator {
        deposit.withdrawOperatorFee(operator, coin);
    }

    function setMarket(IMarketDeployer.Parameters memory parameters)
        external
        onlyOperator
    {
        parameters.operator = operator;

        address marketAddress = factory.createMarket(parameters);
        markets[marketAddress] = true;
    }

    function freezeMarket(address marketAddress, bool freeze)
        external
        onlyOperator
    {
        require(
            markets[marketAddress] == true,
            "Keeper: Market does not exist"
        );

        Market(marketAddress).freezeMarket(freeze);
    }

    function setOracle(address oracle, IOracle.Type oracleType)
        external
        onlyOperator
    {}

    function setAMM(address ammAddress) external onlyOperator {}

    function freezeAMM(address ammAddress) external onlyOperator {}

    function deleteAMM(address ammAddress) external onlyOperator {}
}
