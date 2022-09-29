pragma solidity =0.8.9;

interface IDerivativeCFDDeployer
{
 function parameters()
        external
        view
        returns (
            address factory
        );
}