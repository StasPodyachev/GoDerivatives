pragma solidity =0.8.9;

import "./IMarketDeployer.sol";

interface IFactory {
    event MarketCreated(uint256 id);

    function setStorage(address storageAddress_) external;

    function setDeposit(address depositAddress_) external;

    function createMarket(IMarketDeployer.Parameters memory params)
        external
        returns (address market);

    function allMarketsLength() external view returns (uint256);

    function isMarket(address) external returns (bool);

    function depositAddress() external returns (address);

    function storageAddress() external returns (address);

    function getOracleAddress(IOracle.Type oracleType)
        external
        returns (address);

    function addOracleAddress(address oracleAddress, IOracle.Type oracleType)
        external;
}
