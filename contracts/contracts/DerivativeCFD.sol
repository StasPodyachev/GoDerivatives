pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IDeposit.sol";
import "./interfaces/IOracle.sol";
import "./Storage.sol";
import "./DealNFT.sol";

abstract contract DerivativeCFD is IDerivativeCFD, Ownable {
    address public factory;
    string public underlyingAssetName;
    address public coin;
    uint256 public duration;
    address public oracleAggregatorAddress;
    IOracle.Type public oracleType;
    IDeposit public deposit;
    IStorage public storage_;
    DealNFT public _nft;
    uint256 public operatorFee_; // 100% == 1e18
    uint256 public serviceFee_;
    address public operator;
    IOracle public oracle;

    bool public isFreezed_;

    mapping(uint256 => Deal) deals;

    constructor() {}

    modifier isFreezed() {
        require(isFreezed_ == false, "DerivativeCFD: Market is freezed");
        _;
    }

    function freezeMarket(bool freeze) external {
        isFreezed_ = freeze;
    }

    function createDeal(DealParams calldata params) external payable isFreezed {
        uint256 collateralAmountMaker = (params.count *
            params.rate *
            params.percent) /
            1e36 +
            params.slippage;

        require(
            msg.value > 0 ? collateralAmountMaker == msg.value : true,
            "DerivativeCFD: Collateral amount does not equal msg.value"
        );

        msg.value > 0
            ? deposit.deposit{value: msg.value}(msg.sender)
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
            tokenId: 0,
            status: DealStatus.CREATED
        });

        uint256 dealId = storage_.addDealId();

        deals[dealId] = deal;

        params.makerPosition ? deal.buyer = msg.sender : deal.seller = msg
            .sender;

        emit DealCreated(dealId);
    }

    function takeDeal(uint256 dealId, uint256 collatoralAmountTaker)
        external
        payable
        isFreezed
    {
        Deal storage deal = deals[dealId];

        require(deal.collateralAmountMaker != 0, "DerivativeCFD: Wrong dealID");
        require(
            deal.status == DealStatus.CREATED,
            "DerivativeCFD: Deal is not created"
        );

        (uint256 rateOracle, uint256 roundId) = oracle.getLatest(
            oracleAggregatorAddress
        );
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

        msg.value > 0
            ? deposit.deposit{value: msg.value}(msg.sender)
            : deposit.deposit(coin, collatoralAmount, msg.sender);

        deposit.refund(
            deal.maker,
            coin,
            deal.collateralAmountMaker - collatoralAmount,
            0
        );

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

        _nft.mint(mintParams);

        mintParams.recipient = deal.seller;

        _nft.mint(mintParams);

        emit DealAccepted(dealId);
    }

    function cancelDeal(uint256 dealId) external isFreezed {
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

        deposit.refund(deal.maker, coin, deal.collateralAmountMaker, 0);

        deal.status = status;
    }

    function processing(uint256 dealId) external isFreezed {
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
            oracleAggregatorAddress,
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

        uint256 operatorFee;
        uint256 serviceFee;

        if (payoutBuyer > 0) {
            if (payoutBuyer > deal.collateralAmountBuyer) {
                operatorFee =
                    ((payoutBuyer - deal.collateralAmountBuyer) *
                        operatorFee_) /
                    1e18;

                serviceFee =
                    ((payoutBuyer - deal.collateralAmountBuyer) * serviceFee_) /
                    1e18;

                payoutBuyer -= operatorFee;
                payoutBuyer -= serviceFee;
            }

            deposit.refund(
                deal.buyer,
                coin,
                payoutBuyer,
                operatorFee + serviceFee
            );
        }

        if (payoutSeller > 0) {
            if (payoutSeller > deal.collateralAmountSeller) {
                operatorFee =
                    ((payoutSeller - deal.collateralAmountSeller) *
                        operatorFee_) /
                    1e18;

                serviceFee =
                    ((payoutSeller - deal.collateralAmountSeller) *
                        serviceFee_) /
                    1e18;

                payoutSeller -= operatorFee;
                payoutSeller -= serviceFee;
            }

            deposit.refund(
                deal.seller,
                coin,
                payoutSeller,
                operatorFee + serviceFee
            );
        }

        deposit.collectOperatorFee(operator, coin, operatorFee);
        deposit.collectServiceFee(coin, serviceFee);

        deal.status = DealStatus.COMPLETED;

        // get holders NFT
        // payout for holder if won
        // burn all tokens

        emit DealCompleted(dealId);
    }
}
