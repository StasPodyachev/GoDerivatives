pragma solidity =0.8.9;

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IStorage.sol";
import "./Market.sol";

contract Storage is IStorage {
    mapping(uint256 => address) public deals;
    uint256 public dealId;

    function getDeal(uint256 id) external returns (IDerivativeCFD.Deal memory) {
        address marketAddress = deals[id];

        require(marketAddress != address(0), "Wrong dealId");
        return Market(marketAddress).getDeal(id);
    }

    function addDeal(address marketAddress) external returns (uint256) {
        deals[++dealId] = marketAddress;
        return dealId;
    }
}
