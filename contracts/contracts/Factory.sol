pragma solidity =0.8.9;

import "./interfaces/IFactory.sol";
import "./MarketDeployer.sol";

contract Factory is IFactory, MarketDeployer {
    address[] public allMarkets;
    address deposit;

    function allMarketsLength() external view returns (uint256) {
        return allMarkets.length;
    }

    function setDeposit(address deposit_) external {
        deposit = deposit_;
    }

    function createMarket() external returns (address market) {
        market = deploy(address(this), deposit);

        allMarkets.push(market);

        emit MarketCreated(allMarkets.length);
    }

    function isMarket(address) external returns (bool) {
        return true;
    }
}
