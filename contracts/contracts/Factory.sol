pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IOracle.sol";

import "./interfaces/IAmmDeployer.sol";
import "./interfaces/IMarketDeployer.sol";

import "./Keeper.sol";
import "./AmmDeployer.sol";

contract Factory is Ownable, IFactory {
    address[] public allMarkets;
    mapping(address => bool) markets;

    address[] public allAmms;
    mapping(address => bool) amms;
    mapping(address => address) keepers;

    mapping(IOracle.Type => address) oracles;

    address public depositAddress;
    address public storageAddress;

    function getOwner() external view returns (address) {
        return owner();
    }

    function setStorage(address storageAddress_) external onlyOwner {
        storageAddress = storageAddress_;
    }

    function setDeposit(address depositAddress_) external onlyOwner {
        depositAddress = depositAddress_;
    }

    function getOracleAddress(IOracle.Type oracleType)
        external
        view
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

    function createMarket(MarketParams memory params)
        external
        returns (address marketAddress)
    {
        Keeper keeper;

        if (keepers[msg.sender] == address(0)) {
            keeper = new Keeper(msg.sender);

            keepers[msg.sender] = address(keeper);

            emit KeeperCreated(address(keeper));
        } else keeper = Keeper(keepers[msg.sender]);

        IMarketDeployer.Parameters memory parameters = IMarketDeployer
            .Parameters({
                factory: address(this),
                deposit: depositAddress,
                operator: msg.sender,
                underlyingAssetName: params.underlyingAssetName,
                coin: params.coin,
                duration: params.duration,
                oracleAggregatorAddress: params.oracleAggregatorAddress,
                storageAddress: storageAddress,
                oracleType: params.oracleType,
                operatorFee: params.operatorFee,
                serviceFee: params.serviceFee,
                amm: address(0)
            });

        marketAddress = address(new Market(parameters));
        keeper.addMarket(marketAddress);

        allMarkets.push(marketAddress);
        markets[marketAddress] = true;

        emit MarketCreated(marketAddress);
    }

    function createAmm(IAmmDeployer.Parameters memory params)
        external
        returns (address amm)
    {
        amm = new AmmDeployer().deploy(params);

        allAmms.push(amm);
        amms[amm] = true;

        // emit MarketCreated(allAmms.length);
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
        return amms[ammAddress];
    }
}
