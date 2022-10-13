// SPDX-License-Identifier: MIT

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "./interfaces/IDerivativeCFD.sol";

import "./interfaces/IAmmDeployer.sol";
import "./interfaces/IAMM.sol";


// import "hardhat/console.sol";

contract TestAMM is IAMM {

    string public name;

    constructor(IAmmDeployer.Parameters memory params){
        name = params.name;
    }

    function takeDeal(
        address market,
        uint256 dealId,
        uint256 rateTaker,
        uint256 slippageTaker,
        uint amount,
        address coin
    ) external {
        if(coin == address(0)){
            IDerivativeCFD(market).takeDeal{value: amount}(dealId, rateTaker, slippageTaker);
        }else {
            TransferHelper.safeApprove(coin, market, amount);
            IDerivativeCFD(market).takeDeal(dealId, rateTaker, slippageTaker);
        }
    }

    receive() external payable {}
}
