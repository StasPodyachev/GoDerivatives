pragma solidity =0.8.9;

import "./IMarketDeployer.sol";
import "./IAmmDeployer.sol";

interface IFactory {
    struct MarketParams {
        uint256 duration;
        uint256 operatorFee;
        uint256 serviceFee;
        address oracleAggregatorAddress;
        address nft;
        address coin;
        string underlyingAssetName;
        IOracle.Type oracleType;
    }

    event MarketCreated(address marketAddress, address keeperAddress);
    event KeeperCreated(address keeperAddress);
    event AmmCreated(address amm);

    function getOwner() external view returns (address);

    function setStorage(address storageAddress_) external;

    function setDeposit(address depositAddress_) external;

    function createMarket(MarketParams memory params)
        external
        returns (address market);

    function createAmm(IAmmDeployer.Parameters memory params)
        external
        returns (address amm);

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
