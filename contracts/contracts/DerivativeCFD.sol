pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IDeposit.sol";
import "./interfaces/IOracle.sol";

abstract contract DerivativeCFD is IDerivativeCFD, Ownable {
    address public factory;
    IDeposit deposit;
    IOracle oracle;

    mapping(uint256 => Deal) public deals;
    //mapping(address => mapping(uint256 => bool)) clients;
    mapping(address => uint256[]) buyers;
    mapping(address => uint256[]) sellers;

    address public coin; // address(0) - ETH, else ERC20
    uint256 internal dealId;

    function setOracle(IOracle oracle_) external onlyOwner {
        oracle = oracle_;
    }

    function newDeal(DealParams calldata params) external payable {
        (uint256 priceOracle, ) = oracle.getLatest();

        uint256 oracleAmount = (params.count * priceOracle * params.percent) /
            1e26;

        require(
            params.maxSlippageAmount >= oracleAmount,
            "DerivativeCFD: Not enough deposit"
        );

        msg.value > 0
            ? deposit.deposit(msg.sender)
            : deposit.deposit(coin, params.maxSlippageAmount, msg.sender);

        Deal memory deal = Deal({
            maker: msg.sender,
            buyer: address(0),
            seller: address(0),
            balanceBuyer: 0,
            balanceSeller: 0,
            lockBuyer: 0,
            lockSeller: 0,
            rate: 0,
            count: params.count,
            percent: params.percent,
            periodOrderExpiration: params.expiration,
            slippage: params.slippage,
            collateralAmountMaker: params.maxSlippageAmount,
            collateralAmountBuyer: 0,
            collateralAmountSeller: 0,
            dateOrderCreation: block.timestamp,
            dateOrderExpiration: block.timestamp + params.expiration,
            dateStart: 0,
            dateStop: 0,
            oracleAmount: 0,
            oracleRoundIDStart: 0,
            duration: params.duration
        });

        deals[++dealId] = deal;

        if (params.makerPosition) {
            deal.buyer = msg.sender;
            deal.balanceBuyer = deal.lockBuyer = params.maxSlippageAmount;

            buyers[msg.sender].push(dealId);
        } else {
            deal.seller = msg.sender;
            deal.balanceSeller = deal.lockSeller = params.maxSlippageAmount;

            sellers[msg.sender].push(dealId);
        }

        emit MakeDeal(dealId);
    }

    function takeDeal(uint256 id, uint256 maxslippageAmount) external payable {
        Deal storage deal = deals[id];

        require(deal.collateralAmountMaker != 0, "Derivative: Wrong dealID");

        (uint256 priceOracle, uint256 roundId) = oracle.getLatest();
        uint256 newAmount = (deal.count * priceOracle * deal.percent) / 1e26;

        require(
            newAmount <= maxslippageAmount,
            "DerivativeCFD: Insufficient amount of deposit for the deal"
        );

        require(
            newAmount > deal.collateralAmountMaker - 2 * deal.slippage &&
                deal.collateralAmountMaker >= newAmount,
            "DerivativeCFD: Deposit Out of range"
        );

        if (msg.value > 0) {
            deposit.deposit(msg.sender);
            deposit.refund(
                payable(deal.maker),
                deal.collateralAmountMaker - newAmount,
                false
            );
        } else {
            deposit.deposit(coin, newAmount, msg.sender);
            deposit.refund(
                deal.maker,
                coin,
                deal.collateralAmountMaker - newAmount,
                false
            );
        }

        deal.oracleRoundIDStart = roundId;
        deal.collateralAmountBuyer = newAmount;
        deal.collateralAmountSeller = newAmount;
        deal.rate = priceOracle;
        deal.balanceBuyer = newAmount;
        deal.balanceSeller = newAmount;
        deal.lockBuyer = newAmount;
        deal.lockSeller = newAmount;
        deal.dateStart = block.timestamp;
        deal.dateStop = deal.dateStart + deal.duration;

        if (deal.buyer == address(0)) {
            deal.buyer = msg.sender;
            buyers[msg.sender].push(dealId);
        } else {
            deal.seller = msg.sender;
            sellers[msg.sender].push(dealId);
        }

        emit TakeDeal(dealId);
    }
}

// 22/100 = 0.22

// 1e17 = 0.5

// 0.5 * 1500 * 0.1
// 5e17/1e18 * 1500 * 1e18 * 1e17/1e18
