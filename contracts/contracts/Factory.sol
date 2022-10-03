pragma solidity =0.8.9;

import "./interfaces/IFactory.sol";
import "./MarketDeployer.sol";

contract Factory is IFactory, MarketDeployer {
    address[] public allMarkets;

    function allMarketsLength() external view returns (uint256) {
        return allMarkets.length;
    }

    function createMarket() external returns (address market) {
        market = deploy(address(this));

        allMarkets.push(market);

        emit MarketCreated(allMarkets.length);
    }
}
