pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IMarketDeployer.sol";

import "./MarketDeployer.sol";

contract Factory is IFactory, MarketDeployer, Ownable {
    address[] public allMarkets;
    mapping(address => bool) markets;

    address public depositAddress;
    address public storageAddress;

    function setStorage(address storageAddress_) external onlyOwner {
        storageAddress = storageAddress_;
    }

    function setDeposit(address depositAddress_) external onlyOwner {
        depositAddress = depositAddress_;
    }

    function createMarket(Parameters memory params)
        external
        returns (address market)
    {
        params.factory = address(this);
        params.deposit = depositAddress;
        market = deploy(params);

        allMarkets.push(market);
        markets[market] = true;

        emit MarketCreated(allMarkets.length);
    }

    function allMarketsLength() external view returns (uint256) {
        return allMarkets.length;
    }

    function isMarket(address marketAddress) external view returns (bool) {
        return markets[marketAddress];
    }
}
