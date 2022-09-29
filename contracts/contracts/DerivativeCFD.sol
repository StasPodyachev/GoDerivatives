pragma solidity =0.8.9;

import './interfaces/IDerivativeCFD.sol';
import './interfaces/IDerivativeCFDDeployer.sol';


contract DerivativeCFD is IDerivativeCFD
{
  address public immutable override factory;

  constructor() {
    (factory) = IDerivativeCFDDeployer(msg.sender).parameters();
  }
}