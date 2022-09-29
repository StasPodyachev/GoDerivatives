pragma solidity =0.8.9;

import './interfaces/IFactory.sol';
import './DerivativeCFDDeployer.sol';

contract Factory is IFactory, DerivativeCFDDeployer {

  address[] public allDerivatives;

 function allDerivativesLength() external view returns (uint) {
    return allDerivatives.length;
  }


function createDerivative() external returns (address derivative) {
  derivative = deploy(address(this));

  allDerivatives.push(derivative);

  emit DerivativeCFDCreated(allDerivatives.length);
}
}