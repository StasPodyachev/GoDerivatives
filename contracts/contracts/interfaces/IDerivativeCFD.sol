pragma solidity =0.8.9;

interface IDerivativeCFD {
    enum DealStatus {
        CREATED,
        ACCEPTED,
        COMPLETED,
        CANCELED,
        EXPIRED
    }

    struct Deal {
        address maker;
        address buyer;
        address seller;
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
        uint256 buyerTokenId;
        uint256 sellerTokenId;
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

    event DealCreated(uint256 dealId);
    event DealAccepted(uint256 dealId);
    event DealCanceled(uint256 dealId);
    event DealCompleted(uint256 dealId);
    event DealExpired(uint256 dealId);

    function freezeMarket(bool freeze) external;

    function createDeal(DealParams calldata params) external payable;

    function takeDeal(uint256 dealId, uint256 collatoralAmountTaker)
        external
        payable;

    function cancelDeal(uint256 dealId) external;

    function processing(uint256 dealId) external;
}
