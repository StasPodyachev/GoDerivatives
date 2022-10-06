pragma solidity =0.8.9;

interface IDerivativeCFD {
    enum DealStatus {
        CREATED,
        ACCEPTED,
        COMPLETED,
        CANCELED
    }

    struct Deal {
        address maker;
        address buyer;
        address seller;
        uint256 balanceBuyer;
        uint256 balanceSeller;
        uint256 lockBuyer; // after new deal lock == balance
        uint256 lockSeller;
        uint256 rate;
        uint256 count; //CFD_Hackathon: Количество контрактов 10^18 = 1
        uint256 percent; // 100% = 1e18 //
        uint256 periodOrderExpiration;
        uint256 slippage;
        uint256 collateralAmountMaker;
        uint256 collateralAmountBuyer;
        uint256 collateralAmountSeller;
        uint256 dateOrderCreation;
        uint256 dateOrderExpiration;
        uint256 dateStart;
        uint256 dateStop;
        uint256 oracleAmount;
        uint256 oracleRoundIDStart;
        uint256 tokenId;
        DealStatus status;
    }

    struct DealParams {
        bool makerPosition;
        uint256 rate; //CFD_Hackathon: Основной параметр и определяется как текущая Цена на Undelying Asset в момент Take
        uint256 count; //CFD_Hackathon: Количество контрактов 10^18 = 1
        uint256 percent; // 100% = 1e18 //
        uint256 expiration;
        uint256 slippage;
    }

    event MakeDeal(uint256 dealId);
    event TakeDeal(uint256 dealId);
    event CancelDeal(uint256 dealId);
    event CompleteDeal(uint256 dealId);
}
