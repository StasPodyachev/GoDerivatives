pragma solidity =0.8.9;

interface IFactory{

  event DerivativeCreated(uint id);

  function factory() external view returns (address);

}