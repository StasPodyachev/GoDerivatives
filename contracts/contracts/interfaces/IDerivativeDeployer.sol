pragma solidity =0.8.9;

interface IDerivativeDeployer
{
 function parameters()
        external
        view
        returns (
            address factory
        );
}