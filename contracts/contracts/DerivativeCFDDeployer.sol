pragma solidity =0.8.9;

import './interfaces/IDerivativeCFDDeployer.sol';
import './DerivativeCFD.sol';


contract DerivativeCFDDeployer is IDerivativeCFDDeployer {

struct Parameters{
  address factory;
}

Parameters public override parameters;

function deploy(address factory) internal returns (address derivative) {
  parameters = Parameters({factory: factory});
  derivative = address(new DerivativeCFD());
  delete parameters;
}
} 