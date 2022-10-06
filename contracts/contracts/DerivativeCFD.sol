pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IDeposit.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IAMM.sol";
import "./Factory.sol";
import "./Storage.sol";
import "./DealNFT.sol";

abstract contract DerivativeCFD is IDerivativeCFD, Ownable {
    address public factory;
    string public underlyingAssetName;
    address public coin;
    uint256 public duration;
    address public oracleAddress;
    IOracle.Type public oracleType;
    IDeposit public deposit;
    IOracle public oracle;
    IStorage public storage_;
    DealNFT public nft;
    uint256 public keepersFee; // 100% == 1e18
    uint256 public serviceFee;
    IAMM public amm;

    bool public isFreezed;

    mapping(uint256 => Deal) deals;

    constructor() {}

    function setOracle(IOracle oracle_) external onlyOwner {
        oracle = oracle_;
    }

    function freezeMarket(bool freeze) external {
        isFreezed = freeze;
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
            oracleRoundIDStart: 0,
            buyerTokenId: 0,
            sellerTokenId: 0,
            status: DealStatus.CREATED
        });

        uint256 dealId = storage_.addDealId();

        deals[dealId] = deal;

        params.makerPosition ? deal.buyer = msg.sender : deal.seller = msg
            .sender;

        emit DealCreated(dealId);

        if (address(amm) != address(0)) {
            amm.takeDeal(
                address(this),
                dealId,
                collateralAmountMaker,
                coin
            );
        }
    }

    function takeDeal(uint256 dealId, uint256 collatoralAmountTaker)
        external
        payable
    {
        Deal storage deal = deals[dealId];

        require(deal.collateralAmountMaker != 0, "DerivativeCFD: Wrong dealID");
        require(
            deal.status == DealStatus.CREATED,
            "DerivativeCFD: Deal is not created"
        );

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
                deal.collateralAmountMaker - collatoralAmount
            );
        } else {
            deposit.deposit(coin, collatoralAmount, msg.sender);
            deposit.refund(
                deal.maker,
                coin,
                deal.collateralAmountMaker - collatoralAmount
            );
        }

        deal.oracleRoundIDStart = roundId;
        deal.collateralAmountBuyer = collatoralAmount;
        deal.collateralAmountSeller = collatoralAmount;
        deal.rate = rateOracle;
        deal.dateStart = block.timestamp;
        deal.dateStop = deal.dateStart + duration;
        deal.status = DealStatus.ACCEPTED;

        deal.buyer == address(0) ? deal.buyer = msg.sender : deal.seller = msg
            .sender;

        DealNFT.MintParams memory mintParams = DealNFT.MintParams({
            dealId: dealId,
            deadline: block.timestamp,
            amount: collatoralAmount,
            market: address(this),
            recipient: deal.buyer,
            buyer: deal.buyer,
            seller: deal.seller
        });

        deal.buyerTokenId = nft.mint(mintParams);
        mintParams.recipient = deal.seller;
        deal.sellerTokenId = nft.mint(mintParams);

        emit DealAccepted(dealId);
    }

    function cancelDeal(uint256 dealId) external {
        Deal storage deal = deals[dealId];
        _cancel(deal, DealStatus.CANCELED);

        emit DealCanceled(dealId);
    }

    function _cancel(Deal storage deal, DealStatus status) internal {
        require(
            deal.maker == msg.sender,
            "DerivativeCFD: Only maker can cancel the deal"
        );

        require(
            deal.status == DealStatus.CREATED,
            "DerivativeCFD: Deal status is not created"
        );

        coin == address(0)
            ? deposit.refund(payable(deal.maker), deal.collateralAmountMaker)
            : deposit.refund(deal.maker, coin, deal.collateralAmountMaker);

        deal.status = status;
    }

    function processing(uint256 dealId) external {
        Deal storage deal = deals[dealId];

        require(deal.collateralAmountBuyer != 0, "DerivativeCFD: Wrong dealID");

        if (
            deal.status == DealStatus.CREATED &&
            deal.dateOrderExpiration <= block.timestamp
        ) {
            _cancel(deal, DealStatus.EXPIRED);
            emit DealExpired(dealId);

            return;
        }

        require(
            deal.status == DealStatus.ACCEPTED &&
                deal.dateStop <= block.timestamp
        );

        uint256 oracleAmount = oracle.getAmount(
            deal.dateStop,
            deal.oracleRoundIDStart
        ) * 1e10;

        require(
            oracleAmount > 0,
            "DerivativeCFD: Oracle cannot provide the value"
        );

        uint256 payoutBuyer = 0;
        uint256 payoutSeller = 0;

        if (oracleAmount <= deal.rate - deal.collateralAmountBuyer) {
            payoutSeller =
                deal.collateralAmountSeller +
                deal.collateralAmountBuyer;
        } else if (
            (oracleAmount > deal.rate - deal.collateralAmountBuyer) &&
            (oracleAmount < deal.rate + deal.collateralAmountSeller)
        ) {
            payoutBuyer = oracleAmount + deal.collateralAmountBuyer - deal.rate;
            payoutSeller =
                deal.rate +
                deal.collateralAmountSeller -
                oracleAmount;
        } else if (oracleAmount >= deal.rate + deal.collateralAmountSeller) {
            payoutBuyer =
                deal.collateralAmountSeller +
                deal.collateralAmountBuyer;
        }
        uint256 feeKeeper;
        if (payoutBuyer > 0) {
            feeKeeper = payoutBuyer > deal.collateralAmountBuyer
                ? ((payoutBuyer - deal.collateralAmountBuyer) * keepersFee) /
                    1e18
                : 0;

            coin == address(0)
                ? deposit.refund(payable(deal.buyer), payoutBuyer, feeKeeper)
                : deposit.refund(deal.buyer, coin, payoutBuyer, feeKeeper);
        }

        if (payoutSeller > 0) {
            feeKeeper = payoutSeller > deal.collateralAmountSeller
                ? ((payoutSeller - deal.collateralAmountSeller) * keepersFee) /
                    1e18
                : 0;

            coin == address(0)
                ? deposit.refund(payable(deal.seller), payoutSeller, feeKeeper)
                : deposit.refund(deal.seller, coin, payoutSeller, feeKeeper);
        }

        deal.status = DealStatus.COMPLETED;

        // get holders NFT
        // payout for holder if won
        // burn all tokens

        emit DealCompleted(dealId);
    }
}
