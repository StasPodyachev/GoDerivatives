pragma solidity =0.8.9;

import "./interfaces/IAmmDeployer.sol";
import "./TestAMM.sol";

contract AmmDeployer is IAmmDeployer {
    Parameters private parameters_;

    function deploy(Parameters memory params)
        external
        returns (address amm)
    {
        parameters_ = params;
        amm = address(new TestAMM());
        delete parameters_;
    }

    function parameters() external view returns (Parameters memory params) {
        return parameters_;
    }
}
