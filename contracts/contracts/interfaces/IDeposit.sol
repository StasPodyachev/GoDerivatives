pragma solidity =0.8.9;

interface IDeposit {
    function setFactory(address factory_) external;

    function deposit(address recipient) external payable;

    function deposit(
        address token,
        uint256 val,
        address recipient
    ) external;

    function refund(
        address recipient,
        address coin,
        uint256 val
    ) external;

    function collectOperatorFee(
        address operator,
        address coin,
        uint256 val
    ) external;

    function withdrawOperatorFee(address operator, address coin) external;

    function collectServiceFee(address coin, uint256 val) external;

    function withdrawServiceFee(address coin) external;

    event Deposit(address indexed dst, uint256 wad);
    event Deposit(address indexed dst, address token, uint256 wad);

    event Withdrawal(address indexed src, address token, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}
