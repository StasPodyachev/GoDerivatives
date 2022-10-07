pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IOracle.sol";

import "./interfaces/IAmmDeployer.sol";
import "./interfaces/IMarketDeployer.sol";

import "./MarketDeployer.sol";
import "./AmmDeployer.sol";

contract Factory is IFactory, MarketDeployer, AmmDeployer, Ownable {
    address[] public allMarkets;
    mapping(address => bool) markets;

    address[] public allAmms;
    mapping(address => bool) amms;

    mapping(IOracle.Type => address) oracles;

    address public depositAddress;
    address public storageAddress;

    function setStorage(address storageAddress_) external onlyOwner {
        storageAddress = storageAddress_;
    }

    function setDeposit(address depositAddress_) external onlyOwner {
        depositAddress = depositAddress_;
    }

    function getOracleAddress(IOracle.Type oracleType)
        external
        onlyOwner
        returns (address)
    {
        return oracles[oracleType];
    }

    function addOracleAddress(address oracleAddress, IOracle.Type oracleType)
        external
        onlyOwner
    {
        oracles[oracleType] = oracleAddress;
    }

    function createMarket(IMarketDeployer.Parameters memory params)
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

     function createAmm(IAmmDeployer.Parameters memory params)
        external
        returns (address amm)
    {
        amm = deploy();

        allAmms.push(amm);
        amms[amm] = true;

        emit MarketCreated(allAmms.length);
    }

    function allMarketsLength() external view returns (uint256) {
        return allMarkets.length;
    }

    function allAmmsLength() external view returns (uint256) {
        return allAmms.length;
    }

    function isMarket(address marketAddress) external view returns (bool) {
        return markets[marketAddress];
    }

    function isAmm(address ammAddress) external view returns (bool) {
        return amms[marketAddress];
    }
}
