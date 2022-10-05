pragma solidity =0.8.9;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IDeposit.sol";
import "./Market.sol";

contract Deposit is IDeposit, Ownable {
    mapping(address => mapping(address => uint256)) public tokenBalances;
    mapping(address => uint256) public balances;
    uint256 public fee;

    IFactory public factory;

    constructor() {}

    modifier onlyMarket() {
        require(
            factory.isMarket(msg.sender),
            "Deposit: Caller is not the market"
        );
        _;
    }

    function setFactory(address factory_) external {
        require(factory_ != address(0), "Deposit: Factory can not be empty");

        factory = IFactory(factory_);
    }

    /// @dev deposit ETH to balance from market
    function deposit(address recipient) external payable onlyMarket {
        balances[recipient] += msg.value;

        emit Deposit(recipient, msg.value);
    }

    /// @dev need approve token before call
    function deposit(
        address token,
        uint256 val,
        address recipient
    ) external onlyMarket {
        TransferHelper.safeTransferFrom(token, recipient, address(this), val);
        tokenBalances[recipient][token] += val;

        emit Deposit(recipient, token, val);
    }

    function refund(
        address recipient,
        address token,
        uint256 val
    ) external onlyMarket {
        require(
            tokenBalances[recipient][token] >= val,
            "Deposit: Insufficient balance token to refund"
        );

        TransferHelper.safeTransfer(token, recipient, val);
        tokenBalances[recipient][token] -= val;
    }

    function refund(address payable recipient, uint256 val)
        external
        onlyMarket
    {
        require(
            balances[recipient] >= val,
            "Deposit: Insufficient balance ETH to refund"
        );

        recipient.transfer(val);
        balances[recipient] -= val;
    }
}
