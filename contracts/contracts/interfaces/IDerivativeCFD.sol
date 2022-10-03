pragma solidity =0.8.9;

interface IDerivativeCFD {
    struct Deal {
        address maker;
        address taker;
        uint256 balanceMaker;
        uint256 balanceTaker;
        uint256 lockMaker; // after new deal lock == balance
        uint256 lockTaker;
        address derivativeCoin; // address(0) == ETH
    }

    function factory() external view returns (address);

    function deposit() external view returns (address);
}
