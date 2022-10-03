pragma solidity =0.8.9;

interface IDerivativeCFD {
    struct Deal {
        address maker;
        address taker;
        uint256 balanceMaker;
        uint256 balanceTaker;
        uint256 lockMaker; // after new deal lock == balance
        uint256 lockTaker;
        address derivativeCoin; // address(0) == ETH
    }

    struct DealParams {
        uint256 derivativeSettingsID,
        uint256 price; //CFD_Hackathon: Основной параметр и определяется как текущая Цена на Undelying Asset в момент Take
        uint256 count; //CFD_Hackathon: Количество контрактов
        uint256 percent; // 100% = 1e18 //
        uint256 expiration;
        uint256 slippage;
        uint256 maxSlippageAmount;
    }

        struct Settings {
        string underlyingAsset; // not used //CFD_Hackathon: не понятно почему не используется - потом надо использовать
        string coinUnderlyingAssetAxis; // not used //CFD_Hackathon: не понятно почему не используется - заменяется coinPaymentL и coinPaymentS - потом надо использовать
        string coinOfContract; // not used //CFD_Hackathon: не понятно почему не используется - заменяется coinDepositL и coinDepositS - потом надо использовать
        string coinDepositL; //CFD_Hackathon: для хакатона USDT
        string coinDepositS; //CFD_Hackathon: для хакатона USDT
        string coinPaymentL; //CFD_Hackathon: для хакатона USDT - хотя может вообще не использоваться
        string coinPaymentS; //CFD_Hackathon: для хакатона USDT - хотя может вообще не использоваться
        uint256 period;
        uint256 periodDeliverySideL; //CFD_Hackathon: не нужен, так как нет доставки
        uint256 periodDeliverySideS; //CFD_Hackathon: не нужен, так как нет доставки
    }

    function factory() external view returns (address);

    function deposit() external view returns (address);
}
