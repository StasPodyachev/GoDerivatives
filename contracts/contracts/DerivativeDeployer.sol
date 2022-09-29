pragma solidity =0.8.9;

import './interfaces/IDerivativeDeployer.sol';
import './Derivative.sol';


contract DerivativeDeployer is IDerivativeDeployer {

struct Parameters{
  address factory;
}

Parameters public override parameters;

function deploy(address factory) internal returns (address derivative){
  parameters = Parameters({factory: factory});
  derivative = address(Derivative);
  delete parameters;
}

} 