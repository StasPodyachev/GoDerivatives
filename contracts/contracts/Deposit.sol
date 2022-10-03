pragma solidity =0.8.9;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IDeposit.sol";
import "./Market.sol";

contract Deposit is IDeposit, Ownable {
    mapping(address => mapping(address => uint256)) public tokenBalances; // summ erc20 from all deals
    mapping(address => uint256) public balances; // ETH
    uint256 public fee; // maybe private

    IFactory public factory;

    mapping(address => Market[]) marketsByUser;

    mapping(address => mapping(address => Market[])) markets; // [client][token/ETH]

    constructor() {}

    modifier onlyMarket() {
        require(
            factory.isMarket(msg.sender),
            "Deposit: caller is not the market"
        );
        _;
    }

    function setFactory(address factory_) external {
        require(factory_ != address(0), "Deposit: Factory can not be empty");

        factory = IFactory(factory_);
    }

    function withdraw(
        Market market,
        uint256 dealID,
        uint256 amount
    ) external {
        market.withdraw(sender, dealID, amount);
        address coin = market.coin();

        if (coin == address(0)) {
            balances[msg.sender] -= amount;
            payable(msg.sender).transfer(amount);

            emit Withdrawal(msg.sender, amount);
        } else {
            tokenBalances[msg.sender][coin] -= amount;
            TransferHelper.safeTransfer(coin, msg.sender, amount);

            emit Withdrawal(msg.sender, coin, amount);
        }
    }

    function _deposit(address recipient) internal payable {
        // only from market or wallet ?
        balances[recipient] += msg.value;
        emit Deposit(recipient, msg.value);
    }

    function _deposit(
        address token,
        uint256 val,
        address recipient
    ) internal {
        // only from market or wallet ?
        TransferHelper.safeTransferFrom(token, recipient, address(this), val);
        tokenBalances[recipient][token] += val;

        emit Deposit(recipient, token, msg.value);
    }

    /// @dev deposit ETH to balance
    function deposit() payable {
        _deposit(msg.sender);
    }

    /// @dev deposit ETH to balance from market
    function deposit(address recipient) external payable onlyMarket {
        // only from market or wallet ?
        _deposit(recipient);
    }

    /// @dev deposit ERC20 to balance
    function deposit(address token, uint256 val) external {
        _deposit(token, val, msg.sender);
    }

    /// @dev need approve token before call
    function deposit(
        address token,
        uint256 val,
        address recipient
    ) external onlyMarket {
        // only from market or wallet ?
        _deposit(token, val, recipient);
    }

    function withdrawAll() external {
        withdrawAllEth();
        withdrawAllErc20();
    }

    // function withdraw(address[] calldata markets_, uint256[] calldata vals)
    //     external
    // {}

    /// @dev withdraw all free ETH msg.sender
    function withdrawAllEth() external {
        uint256 wad = 0;

        Market[] marketsArr = markets[msg.sender][address(0)];

        for (uint256 i = 0; i < marketsArr.length; i++) {
            wad += marketsArr[i].withdrawFree(msg.sender);
        }

        require(
            balances[msg.sender] >= wad,
            "Deposit: Insufficient balance to withdraw"
        );
        balances[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);

        emit Withdrawal(msg.sender, wad);
    }

    /// @dev withdraw target ERC20 to msg.sender
    function withdrawAllErc20(address token) external {
        Market[] marketsArr = markets[msg.sender][token];
        uint256 wad;

        for (uint256 i = 0; i < marketsArr.length; i++) {
            wad += marketsArr[i].withdrawFree(msg.sender);
        }

        require(
            tokenBalances[msg.sender][token] >= wad,
            "Deposit: Insufficient balance to withdraw"
        );
        tokenBalances[msg.sender][token] -= wad;
        TransferHelper.safeTransfer(token, msg.sender, wad);

        emit Withdrawal(msg.sender, token, wad);
    }

    /// @dev withdraw all free ERC20 to msg.sender
    function withdrawAllErc20() external {
        Market[] marketsArr = marketsByUser[msg.sender];

        address[] tokens;
        mapping(address => uint256) wads;

        for (uint256 i = 0; i < marketsArr.length; i++) {
            uint256 amount = marketsArr[i].withdrawFree(msg.sender);
            address token = marketsArr[i].coin();

            if (token == address(0)) continue;

            if (wads[token] == 0) {
                tokens.push(token);
            }

            wads[token] += amounts[i];
        }

        uint256 wad;

        for (uint256 i = 0; i < tokens.length; i++) {
            wad = wads[tokens[i]];
            require(
                tokenBalances[msg.sender][tokens[i]] >= wad,
                "Deposit: Insufficient balance to withdraw"
            );

            tokenBalances[msg.sender][tokens[i]] -= wad;
            TransferHelper.safeTransfer(tokens[i], msg.sender, wad);

            emit Withdrawal(msg.sender, tokens[i], wad);
        }
    }

    function refund(
        address recipient,
        address token,
        uint256 val,
        bool remove
    ) external onlyMarket {
        // only market
        require(
            balances[recipient] >= wad,
            "Deposit: Insufficient balance token to refund"
        );
        TransferHelper.safeTransfer(token, recipient, val);

        if (remove) {
            delete markets[recipient];
        }
    }

    function refund(
        address payable recipient,
        uint256 val,
        bool remove
    ) external onlyMarket {
        // only market
        require(
            balances[recipient] >= wad,
            "Deposit: Insufficient balance ETH to refund"
        );
        recipient.transfer(val);

        if (remove) {
            delete markets[recipient];
        }
    }

    function _remove(Market[] storage array, uint256 index) internal {
        require(index < array.length);
        array[index] = array[array.length - 1];
        array.pop();
    }
}
