pragma solidity =0.8.9;

import './interfaces/IDeposit.sol';

contract Deposit is IDeposit
{
  mapping(address => mapping(address => uint)) public balances; // erc20
  mapping(address => uint) public balanceOf; // ETH

  address public immutable override factory;


  constructor() {

  }

  function deposit() payable external {
    balanceOf[msg.sender] += msg.value;
    emit Deposit(msg.sender, msg.value);
  }

  function deposit(address token, uint val) external {
    
  }

  function withdraw(address token, uint wad) external {
    
  }

  function withdraw(uint wad) external {
    require(balanceOf[msg.sender] >= wad);

    balanceOf[msg.sender] -= wad;
    msg.sender.transfer(wad);

    emit Withdrawal(msg.sender, wad);
  }
}