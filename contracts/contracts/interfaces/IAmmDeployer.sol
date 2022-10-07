pragma solidity =0.8.9;

import "./IOracle.sol";

interface IAmmDeployer {
  struct Parameters {
    string name;
  }

  function parameters() external view returns (Parameters memory params);
}
