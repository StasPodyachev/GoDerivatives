pragma solidity =0.8.9;

interface IFactory{

  event MarketCreated(uint id);

  function isMarket(address) external returns(bool)

}