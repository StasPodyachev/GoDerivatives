pragma solidity =0.8.9;

import "./interfaces/IAmmDeployer.sol";
import "./TestAMM.sol";

contract AmmDeployer is IAmmDeployer {
    Parameters public parameters_;

    function deploy(Parameters calldata params)
        internal
        returns (address amm)
    {
        parameters_ = params;
        derivative = address(new TestAMM());
        delete parameters_;
    }
}
