pragma solidity =0.8.9;

contract Storage {
    mapping(uint256 => address) public deals;
    uint256 public dealId;

    function addDeal(address marketAddress) external returns (uint256) {
        deals[++dealId] = marketAddress;
        return dealId;
    }
}
