// SPDX-License-Identifier: MIT

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "./interfaces/IDerivativeCFD.sol";

import "./interfaces/IAmmDeployer.sol";
import "./interfaces/IAMM.sol";


// import "hardhat/console.sol";

contract TestAMM is IAMM {

    uint256 MAX_UINT256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935; 
    string public name; 

    uint256 index = 0;

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
        index++;
        if(index%2 == 0) return;

        if(coin == address(0)){
            IDerivativeCFD(market).takeDeal{value: amount}(dealId, rateTaker, slippageTaker);
        }else {
            TransferHelper.safeApprove(coin, market, MAX_UINT256);
            IDerivativeCFD(market).takeDeal(dealId, rateTaker, slippageTaker);
        }
    }

    receive() external payable {}
}
