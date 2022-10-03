pragma solidity =0.8.9;

interface IMarketDeployer {
    function parameters()
        external
        view
        returns (address factory, address deposit);
}
