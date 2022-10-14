pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDerivativeCFD.sol";
import "./interfaces/IDeposit.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IAMM.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IStorage.sol";
import "./DealNFT.sol";

import "hardhat/console.sol";

abstract contract DerivativeCFD is IDerivativeCFD, Ownable {
    address public factory;
    string public underlyingAssetName;
    address public coin;
    uint256 public duration;
    address public oracleAggregatorAddress;
    IOracle.Type public oracleType;
    IDeposit public deposit;
    IStorage public storage_;
    DealNFT public nft;
    IAMM public amm;
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
        require(
            msg.sender == operator || msg.sender == this.owner(),
            "DerivativeCFD: Only keeper or owner can freeze market"
        );

        isFreezed_ = freeze;
    }

    function createDeal(DealParams calldata params) external payable isFreezed {
        uint256 slippageAmount = (params.count *
            params.rate *
            params.percent *
            params.slippage) / 1e54;

        uint256 collateralAmountMaker = (params.count *
            params.rate *
            params.percent) /
            1e36 +
            slippageAmount;

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
            rateMaker: params.rate,
            rate: 0,
            count: params.count,
            percent: params.percent,
            periodOrderExpiration: params.expiration,
            slippageMaker: params.slippage,
            slippageTaker: 0,
            collateralAmountMaker: collateralAmountMaker,
            collateralAmountBuyer: 0,
            collateralAmountSeller: 0,
            dateOrderCreation: block.timestamp,
            dateOrderExpiration: block.timestamp + params.expiration,
            dateStart: 0,
            dateStop: 0,
            oracleRoundIDStart: 0,
            buyerTokenId: 0,
            sellerTokenId: 0,
            status: DealStatus.CREATED
        });
        
        params.makerPosition ? deal.buyer = msg.sender : deal.seller = msg.sender;
        
        uint256 dealId = storage_.addDealId();
        
        deals[dealId] = deal;


        emit DealCreated(dealId);

        if (address(amm) != address(0)) {
            amm.takeDeal(address(this), dealId, params.rate, params.slippage, collateralAmountMaker, coin);
        }
    }

    function takeDeal(
        uint256 dealId,
        uint256 rateTaker,
        uint256 slippageTaker
    ) external payable isFreezed {
        Deal storage deal = deals[dealId];

        require(deal.maker != msg.sender, "DerivativeCFD: Taker shouldn't be maker");
        require(deal.collateralAmountMaker != 0, "DerivativeCFD: Wrong dealID");
        require(
            deal.status == DealStatus.CREATED,
            "DerivativeCFD: Deal is not created"
        );

        (uint256 rateOracle, uint256 roundId) = oracle.getLatest(
            oracleAggregatorAddress
        );

        uint256 collateralAmount = (deal.count * rateOracle * deal.percent) /
            1e36;

        uint256 slippageTakerAmount =
            (deal.count * rateTaker * deal.percent * slippageTaker) /
            1e54;

        uint256 collateralAmountTaker = (deal.count *
            rateTaker *
            deal.percent) /
            1e36 +
            slippageTakerAmount;

        require(
            collateralAmount <= collateralAmountTaker,
            "DerivativeCFD: Insufficient amount of deposit for the deal"
        );

        require(
            (rateOracle  > (deal.rateMaker - deal.rateMaker * deal.slippageMaker / 1e18)) &&
            (rateOracle <= (deal.rateMaker + deal.rateMaker * deal.slippageMaker / 1e18)) &&
            (rateOracle  > (rateTaker - rateTaker * slippageTaker / 1e18)) &&
            (rateOracle <= (rateTaker + rateTaker * slippageTaker / 1e18)),
            "DerivativeCFD: Deposit Out of range"
        );

        msg.value > 0
            ? deposit.deposit{value: msg.value}(msg.sender)
            : deposit.deposit(coin, collateralAmount, msg.sender);

        deposit.refund(
            deal.maker,
            coin,
            deal.collateralAmountMaker - collateralAmount,
            0
        );
        
        deal.slippageTaker = slippageTaker;
        deal.oracleRoundIDStart = roundId;
        deal.collateralAmountBuyer = collateralAmount;
        deal.collateralAmountSeller = collateralAmount;
        deal.rate = rateOracle;
        deal.dateStart = block.timestamp;
        deal.dateStop = deal.dateStart + duration;
        deal.status = DealStatus.ACCEPTED;


        deal.buyer == address(0) ? deal.buyer = msg.sender : deal.seller = msg.sender;

        DealNFT.MintParams memory mintParams = DealNFT.MintParams({
            dealId: dealId,
            deadline: block.timestamp,
            amount: collateralAmount,
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

        require(deal.collateralAmountMaker != 0, "DerivativeCFD: Wrong dealID");

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
                deal.dateStop <= block.timestamp, "DerivativeCFD: deal.dateStop <= block.timestamp"
        );

        uint256 oracleAmount = oracle.getAmount(
            oracleAggregatorAddress,
            deal.dateStop,
            deal.oracleRoundIDStart
        );

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
        (address[] memory nftHolders) = nft.getHolders(deal.buyerTokenId);

        uint balanceNft;
        uint ONE = nft.ONE();

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
            
            for(uint i=0; i<nftHolders.length; i++){
                balanceNft = nft.balanceOf(nftHolders[i], deal.buyerTokenId);

                if(balanceNft==0) continue;

                deposit.withdraw((
                    nftHolders[i],
                    coin,
                    payoutBuyer * balanceNft / ONE
                    // operatorFee + serviceFee
                );
            }
        }

        (nftHolders) = nft.getHolders(deal.sellerTokenId);

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

            for(uint i=0; i<nftHolders.length; i++){
                balanceNft = nft.balanceOf(nftHolders[i], deal.sellerTokenId);

                if(balanceNft==0) continue;

                deposit.withdraw(
                    nftHolders[i],
                    coin,
                    payoutSeller * balanceNft / ONE
                );
            }
        }

        deposit.collectOperatorFee(operator, coin, operatorFee);
        deposit.collectServiceFee(coin, serviceFee);

        deal.status = DealStatus.COMPLETED;

        emit DealCompleted(dealId);
    }
}
