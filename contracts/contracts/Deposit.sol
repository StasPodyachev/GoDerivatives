pragma solidity =0.8.9;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IDeposit.sol";
import "./Market.sol";

contract Deposit is IDeposit, Ownable {
    struct Fee {
        uint256 val;
        address coin;
    }

    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => mapping(address => uint256)) public operatorFees;
    mapping(address => uint256) public serviceFees;

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
        balances[recipient][address(0)] += msg.value;

        emit Deposit(recipient, msg.value);
    }

    /// @dev need approve token before call
    function deposit(
        address token,
        uint256 val,
        address recipient
    ) external onlyMarket {
        TransferHelper.safeTransferFrom(token, recipient, address(this), val);
        balances[recipient][token] += val;

        emit Deposit(recipient, token, val);
    }

    function refund(
        address recipient,
        address coin,
        uint256 val,
        uint256 fee
    ) external onlyMarket {
        require(
            balances[recipient][coin] >= val,
            "Deposit: Insufficient balance coin to refund"
        );

        coin == address(0)
            ? payable(recipient).transfer(val)
            : TransferHelper.safeTransfer(coin, recipient, val);

        balances[recipient][coin] -= val + fee;
    }
// 100
// 100

    function withdraw(address recipient, address coin, uint val) external onlyMarket{
        coin == address(0)
            ? payable(recipient).transfer(val)
            : TransferHelper.safeTransfer(coin, recipient, val);
    }


    function collectOperatorFee(
        address operator,
        address coin,
        uint256 val
    ) external onlyMarket {
        operatorFees[operator][coin] += val;
    }

    function withdrawOperatorFee(address operator, address coin) external {
        uint256 val = operatorFees[operator][coin];

        coin == address(0)
            ? payable(operator).transfer(val)
            : TransferHelper.safeTransfer(coin, operator, val);

        operatorFees[operator][coin] = 0;
    }

    function collectServiceFee(address coin, uint256 val) external onlyMarket {
        serviceFees[coin] += val;
    }

    function withdrawServiceFee(address coin) external onlyOwner {
        uint256 val = serviceFees[coin];

        coin == address(0)
            ? payable(msg.sender).transfer(val)
            : TransferHelper.safeTransfer(coin, msg.sender, val);

        serviceFees[coin] = 0;
    }
}
