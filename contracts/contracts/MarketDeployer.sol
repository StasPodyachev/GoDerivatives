pragma solidity =0.8.9;

import "./interfaces/IMarketDeployer.sol";
import "./Market.sol";

contract MarketDeployer is IMarketDeployer {
    Parameters public parameters_;

    function deploy(Parameters memory params)
        internal
        returns (address derivative)
    {
        parameters_ = params;
        derivative = address(new Market());
        delete parameters_;
    }

    function parameters() external view returns (Parameters memory params) {
        return parameters_;
    }
}
