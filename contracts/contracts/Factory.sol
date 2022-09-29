pragma solidity =0.8.9;

import './interfaces/IFactory.sol';
import './DerivativeDeployer.sol';

contract Factory is IFactory, DerivativeDeployer {

  address[] public allDerivatives;


 function allDerivativesLength() external view returns (uint) {
    return allDerivatives.length;
  }


function createDerivative() external returns (address derivative) {
  derivative = deploy(address(this));

  allDerivatives.push(derivative);

  emit DerivativeCreated(allDerivativesLength.length);
}
}