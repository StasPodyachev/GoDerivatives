pragma solidity =0.8.9;

import "./interfaces/IMarketDeployer.sol";
import "./Market.sol";

contract MarketDeployer is IMarketDeployer {
    struct Parameters {
        address factory;
        address deposit;
    }

    Parameters public override parameters;

    function deploy(address factory, address deposit)
        internal
        returns (address derivative)
    {
        parameters = Parameters({factory: factory, deposit: deposit});
        derivative = address(new Market());
        delete parameters;
    }
}
