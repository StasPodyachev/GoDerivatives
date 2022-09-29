pragma solidity =0.8.9;

import './interfaces/IDerivative.sol';
import './interfaces/IDerivativeDeployer.sol';


contract Deriavative is IDerivative
{
  address public immutable override factory;

  constructor(){
    (factory) = IDerivativeDeployer(msg.sender).parameters();

  }
}