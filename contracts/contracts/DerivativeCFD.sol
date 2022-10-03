pragma solidity =0.8.9;

import "./interfaces/IDerivativeCFD.sol";

abstract contract DerivativeCFD is IDerivativeCFD {
    address public override factory;
    address public override deposit;

    mapping(uint256 => Deal) public deals;
    mapping(address => mapping(uint256 => bool)) clients;
    mapping(address => uint256[]) makers;
    mapping(address => uint256[]) takers;

    address public coin; // address(0) - ETH, else ERC20

    function newDeal(uint256 val) external {
        // deposit
    }

    function newDeal() external payable {
        // deposit
    }
}
