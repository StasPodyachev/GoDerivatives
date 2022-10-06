pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IStorage.sol";
import "./interfaces/IFactory.sol";
import "./Market.sol";

contract Storage is IStorage, Ownable {
    mapping(uint256 => address) public deals;
    uint256 public dealId;
    IFactory factory;

    modifier onlyMarket() {
        require(
            factory.isMarket(msg.sender),
            "Storage: Caller is not the market"
        );
        _;
    }

    function setFactory(address factoryAddress) external onlyOwner {
        require(
            factoryAddress != address(0),
            "Storage: Factory can not be empty"
        );

        factory = IFactory(factoryAddress);
    }

    function getDeal(uint256 dealId_)
        external
        view
        returns (IDerivativeCFD.Deal memory)
    {
        address marketAddress = deals[dealId_];

        require(marketAddress != address(0), "Storage: Wrong dealId");
        return Market(marketAddress).getDeal(dealId_);
    }

    function addDealId() external onlyMarket returns (uint256) {
        deals[++dealId] = msg.sender;
        return dealId;
    }
}
