// SPDX-License-Identifier: MIT
import "./DerivativeCFD.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

// import "hardhat/console.sol";

contract TestAMM {
    function takeDeal(
        address market,
        uint256 dealId,
        uint256 amount,
        address coin
    ) external {
        // console.log("takeDeal TestAMM");
        
        if(coin == address(0)){
            IDerivativeCFD(market).takeDeal{value: amount}(dealId, amount);  

        }else {
            TransferHelper.safeApprove(coin, market, amount);
            IDerivativeCFD(market).takeDeal(dealId, amount);   
        }
    }

    receive() external payable {}
}
