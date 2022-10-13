pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "./interfaces/IAmmDeployer.sol";
import "./interfaces/IMarketDeployer.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IKeeper.sol";
import "./interfaces/IOracle.sol";
import "./Market.sol";

contract Keeper is IKeeper, Ownable {
    mapping(address => bool) public markets;
    address public operator;

    IFactory factory;
    IDeposit deposit;

    constructor(address operator_) {
        factory = IFactory(msg.sender);
        deposit = IDeposit(factory.depositAddress());
        operator = operator_;
        transferOwnership(factory.getOwner());
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Keeper: Caller is not an operator");
        _;
    }

    modifier onlyFactory() {
        require(
            msg.sender == address(factory),
            "Keeper: Caller is not a factory"
        );
        _;
    }

    function setFactory(address factoryAddress) external onlyOwner {
        factory = IFactory(factoryAddress);
    }

    function setDeposit(address depositAddress) external onlyOwner {
        deposit = IDeposit(depositAddress);
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

    function addMarket(address marketAddress) external onlyFactory {
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

    function createAmm(
        string calldata name,
        address market,
        address coin,
        uint256 amount
    ) external payable onlyOperator {
        
        require(markets[market]!=false, "Keeper: Access error for market");
        
        bool isToken = coin != address(0);

        if (isToken) {
            require(amount > 0, "Keeper: Incorrect amount token");
        } else {
            require(msg.value == amount, "Keeper: Incorrect amount coin");
        }

        IAmmDeployer.Parameters memory parameters = IAmmDeployer.Parameters({
            name: name
        });

        address ammAddress = factory.createAmm(parameters);

        if (isToken) {
            TransferHelper.safeTransfer(coin, ammAddress, amount);
        }else{
            payable(ammAddress).transfer(msg.value);
        }
    }

    function freezeAMM(address ammAddress) external onlyOperator {}

    function deleteAMM(address ammAddress) external onlyOperator {}
}
