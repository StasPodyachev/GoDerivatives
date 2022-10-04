pragma solidity =0.8.9;

interface IFactory {
    event MarketCreated(uint256 id);

    function isMarket(address) external returns (bool);
}
