pragma solidity =0.8.9;

interface IDeposit {
    function setFactory(address factory_) external;

    function withdraw(
        address market,
        uint256 dealID,
        uint256 amount
    ) external;

    function deposit() external payable;

    function deposit(address recipient) external payable;

    function deposit(address token, uint256 val) external;

    function deposit(
        address token,
        uint256 val,
        address recipient
    ) external;

    function withdrawAll() external;

    function withdrawAllEth() external;

    function withdrawAllErc20(address token) external;

    function withdrawAllErc20() external;

    function refund(
        address recipient,
        address token,
        uint256 val,
        bool remove
    ) external;

    function refund(
        address payable recipient,
        uint256 val,
        bool remove
    ) external;

    event Deposit(address indexed dst, uint256 wad);
    event Deposit(address indexed dst, address token, uint256 wad);

    event Withdrawal(address indexed src, address token, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}
