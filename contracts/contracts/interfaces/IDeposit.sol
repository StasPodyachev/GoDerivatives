pragma solidity =0.8.9;

interface IDeposit {
  function factory() external view returns (address);

  event Deposit(address indexed dst, uint wad);
  event Withdrawal(address indexed src, uint wad);
}