pragma solidity =0.8.9;

interface IDeposit {
    function factory() external view returns (address);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, address token, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}
