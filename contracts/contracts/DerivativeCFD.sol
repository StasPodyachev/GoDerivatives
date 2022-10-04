pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IDeposit.sol";
import "./interfaces/IOracle.sol";

abstract contract DerivativeCFD is IDerivativeCFD, Ownable {
    address public factory;
    string public underlyingAssetName;
    address public coin;
    uint256 public duration;
    address public oracleAddress;
    IOracle.Type public oracleType;
    IDeposit public deposit;
    IOracle public oracle;

    mapping(uint256 => Deal) public deals;
    mapping(address => uint256[]) buyers;
    mapping(address => uint256[]) sellers;

    uint256 internal dealId;

    constructor() {}

    function setOracle(IOracle oracle_) external onlyOwner {
        oracle = oracle_;
    }

    function createDeal(DealParams calldata params) external payable {
        uint256 collateralAmountMaker = (params.count *
            params.rate *
            params.percent) /
            1e36 +
            params.slippage; // slippage in percent or amount?

        msg.value > 0
            ? deposit.deposit(msg.sender)
            : deposit.deposit(coin, collateralAmountMaker, msg.sender);

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
            collateralAmountMaker: collateralAmountMaker,
            collateralAmountBuyer: 0,
            collateralAmountSeller: 0,
            dateOrderCreation: block.timestamp,
            dateOrderExpiration: block.timestamp + params.expiration,
            dateStart: 0,
            dateStop: 0,
            oracleAmount: 0,
            oracleRoundIDStart: 0
        });

        deals[++dealId] = deal;

        if (params.makerPosition) {
            deal.buyer = msg.sender;
            deal.balanceBuyer = deal.lockBuyer = collateralAmountMaker;

            buyers[msg.sender].push(dealId);
        } else {
            deal.seller = msg.sender;
            deal.balanceSeller = deal.lockSeller = collateralAmountMaker;

            sellers[msg.sender].push(dealId);
        }

        emit MakeDeal(dealId);
    }

    function takeDeal(uint256 id, uint256 collatoralAmountTaker)
        external
        payable
    {
        Deal storage deal = deals[id];

        require(deal.collateralAmountMaker != 0, "Derivative: Wrong dealID");

        (uint256 rateOracle, uint256 roundId) = oracle.getLatest();
        uint256 collatoralAmount = (deal.count * rateOracle * deal.percent) /
            1e26;

        require(
            collatoralAmount <= collatoralAmountTaker,
            "DerivativeCFD: Insufficient amount of deposit for the deal"
        );

        require(
            collatoralAmount > deal.collateralAmountMaker - 2 * deal.slippage &&
                deal.collateralAmountMaker >= collatoralAmount,
            "DerivativeCFD: Deposit Out of range"
        );

        if (msg.value > 0) {
            deposit.deposit(msg.sender);
            deposit.refund(
                payable(deal.maker),
                deal.collateralAmountMaker - collatoralAmount,
                false
            );
        } else {
            deposit.deposit(coin, collatoralAmount, msg.sender);
            deposit.refund(
                deal.maker,
                coin,
                deal.collateralAmountMaker - collatoralAmount,
                false
            );
        }

        deal.oracleRoundIDStart = roundId;
        deal.collateralAmountBuyer = collatoralAmount;
        deal.collateralAmountSeller = collatoralAmount;
        deal.rate = rateOracle;
        deal.balanceBuyer = collatoralAmount;
        deal.balanceSeller = collatoralAmount;
        deal.lockBuyer = collatoralAmount;
        deal.lockSeller = collatoralAmount;
        deal.dateStart = block.timestamp;
        deal.dateStop = deal.dateStart + duration;

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
