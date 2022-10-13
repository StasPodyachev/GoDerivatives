import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { parseAmount } from "@uniswap/smart-order-router";
import { assert, expect } from "chai";
import { BigNumberish } from "ethers";
import { network, ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";
import { developmentChains } from "../../helper-hardhat-config";
import {
  DealNFT,
  Deposit,
  Factory,
  Market,
  MockV3Aggregator,
  Oracle,
  SimpleToken,
  Storage,
} from "../../typechain";
import { setup } from "./deploy-unit";

let owner: SignerWithAddress;
let maker: SignerWithAddress;
let taker: SignerWithAddress;
let mockV3Aggregator: MockV3Aggregator;
let oracle: Oracle;
let testUSDC: SimpleToken;
let factory: Factory;
let storage: Storage;
let deposit: Deposit;
let dealNFT: DealNFT;
let wtiMarket: Market;

// instances of market wrt maker and taker
let wtiMarketMaker: Market;
let wtiMarketTaker: Market;

// instances of testUSDC wrt maker and taker
let testUSDCMaker: SimpleToken;
let testUSDCTaker: SimpleToken;

const dealParams = {
  makerPosition: true,
  rate: ethers.utils.parseEther("1.58"),
  count: ethers.utils.parseEther("1"),
  percent: ethers.utils.parseEther("0.1"),
  expiration: 86400, // 1 day
  slippage: ethers.utils.parseEther("0.02"),
};

const correctCollateral = ethers.utils.parseEther("0.16116");

let dealId: BigNumberish;

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("DerivativeCFD Unit Tests", () => {
      beforeEach(async () => {
        // Deploy core contracts and
        const setupItems = await setup();
        owner = setupItems.owner;
        maker = setupItems.maker;
        taker = setupItems.taker;
        factory = setupItems.factory;
        storage = setupItems.storage;
        deposit = setupItems.deposit;
        dealNFT = setupItems.dealNFT;
        mockV3Aggregator = setupItems.mockV3Aggregator;
        oracle = setupItems.oracle;
        testUSDC = setupItems.testUSDC;
        wtiMarket = setupItems.wtiMarket;
      });

      describe("Create Deal", () => {
        beforeEach(async () => {
          wtiMarketMaker = wtiMarket.connect(maker);
          testUSDCMaker = testUSDC.connect(maker);
        });

        it("calculates collateralAmountMaker correctly", async () => {
          await expect(
            wtiMarketMaker.callStatic.createDeal(dealParams, {
              value: correctCollateral,
            })
          ).to.not.be.revertedWith(
            "DerivativeCFD: Collateral amount does not equal msg.value"
          );
        });

        it("reverts when passing incorrect collateral amount", async () => {
          const incorrectCollateral = ethers.utils.parseEther("8.2590");
          await expect(
            wtiMarketMaker.callStatic.createDeal(dealParams, {
              value: incorrectCollateral,
            })
          ).to.be.revertedWith(
            "DerivativeCFD: Collateral amount does not equal msg.value"
          );
        });

        it("subtracts deposit correctly when passing collateral explicitly", async () => {
          const makerETHBalanceBefore = await maker.getBalance();

          const dealTx = await wtiMarketMaker.createDeal(dealParams, {
            value: correctCollateral,
          });
          const dealTxReceipt = await dealTx.wait();

          const makerETHBalanceAfter = await maker.getBalance();
          const makerETHDepositAfter = await deposit.balances(
            maker.address,
            ethers.constants.AddressZero
          );

          assert.equal(
            correctCollateral.toString(),
            makerETHDepositAfter.toString()
          );

          const { gasUsed, effectiveGasPrice } = dealTxReceipt;
          const gasCost = gasUsed.mul(effectiveGasPrice);

          assert.equal(
            makerETHBalanceBefore
              .sub(makerETHDepositAfter)
              .sub(gasCost)
              .toString(),
            makerETHBalanceAfter.toString()
          );
        });

        it("subtracts deposit correctly when passing collateral implicitly", async () => {
          const makerBalanceBefore = await testUSDC.balanceOf(maker.address);
          // const makerDepositBefore = await deposit.balances(
          //   maker.address,
          //   ethers.constants.AddressZero
          // );

          const approveTx = await testUSDCMaker.approve(
            deposit.address,
            correctCollateral
          );
          await approveTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams);
          await dealTx.wait(1);

          const makerBalanceAfter = await testUSDC.balanceOf(maker.address);
          const makerDepositAfter = await deposit.balances(
            maker.address,
            testUSDC.address
          );

          assert.equal(
            correctCollateral.toString(),
            makerDepositAfter.toString()
          );

          assert.equal(
            makerBalanceAfter.add(makerDepositAfter).toString(),
            makerBalanceBefore.toString()
          );
        });

        it("emits DealCreated event correctly when creating deal", async () => {
          const approveTx = await testUSDCMaker.approve(
            deposit.address,
            correctCollateral
          );
          await approveTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams);
          const dealTxReceipt = await dealTx.wait(1);

          const dealId = dealTxReceipt!.events![3].args!.dealId;
          assert.equal(dealId.toString(), "1");
        });
      });

      describe("Take deal", () => {
        beforeEach(async () => {
          wtiMarketMaker = wtiMarket.connect(maker);
          testUSDCMaker = testUSDC.connect(maker);
          wtiMarketTaker = wtiMarket.connect(taker);
          testUSDCTaker = testUSDC.connect(taker);

          const approveMakerTx = await testUSDCMaker.approve(
            deposit.address,
            correctCollateral
          );
          await approveMakerTx.wait(1);

          const approveTakerTx = await testUSDCTaker.approve(
            deposit.address,
            ethers.utils.parseEther("100")
          );
          await approveTakerTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams);
          const dealTxReceipt = await dealTx.wait(1);

          dealId = dealTxReceipt!.events![3].args!.dealId;
        });

        it("reverts when deal status is not created", async () => {
          // cancelling deal to change status to CANCELLED
          const cancelTx = await wtiMarketMaker.cancelDeal(dealId);
          // verifying that transaction is cancelled
          await cancelTx.wait();
          const dealParams = await wtiMarketMaker.getDeal(dealId);
          assert.equal(dealParams.status, 3);

          // expect revert because deal status is not CREATED
          await expect(
            wtiMarketTaker.callStatic.takeDeal(
              dealId,
              ethers.utils.parseEther("1.5710"),
              ethers.utils.parseEther("0.02")
            )
          ).to.be.revertedWith("DerivativeCFD: Deal is not created");
        });

        // it("reverts when rateOracle does not fit makers or takers requirements", async () => {
        //   // 1. rateOracle > rateTaker + slippage > rateMaker + slippage

        //   await (
        //     await mockV3Aggregator.updateAnswer(
        //       ethers.utils.parseUnits("82.27", "8")
        //     )
        //   ).wait();

        //   await expect(
        //     wtiMarketTaker.callStatic.takeDeal(
        //       dealId,
        //       ethers.utils.parseEther("80.64"),
        //       ethers.utils.parseEther("0.02")
        //     )
        //   ).to.be.revertedWith("DerivativeCFD: Deposit Out of range");

        //   // 2. rateOracle > rateTaker + slippage < rateMaker + slippage
        //   await (
        //     await mockV3Aggregator.updateAnswer(
        //       ethers.utils.parseUnits("82.10", "8")
        //     )
        //   ).wait();

        //   await expect(
        //     wtiMarketTaker.callStatic.takeDeal(
        //       dealId,
        //       ethers.utils.parseEther("80.64"),
        //       ethers.utils.parseEther("0.02")
        //     )
        //   ).to.be.revertedWith("DerivativeCFD: Deposit Out of range");

        //   // 3. rateOracle < rateMaker - slippage < rateTaker - slippage
        //   await (
        //     await mockV3Aggregator.updateAnswer(
        //       ethers.utils.parseUnits("78.80", "8")
        //     )
        //   ).wait();

        //   await expect(
        //     wtiMarketTaker.callStatic.takeDeal(
        //       dealId,
        //       ethers.utils.parseEther("80.64"),
        //       ethers.utils.parseEther("0.02")
        //     )
        //   ).to.be.revertedWith("DerivativeCFD: Deposit Out of range");

        //   // 4. rateMaker - slippage < rateOracle < rateTaker - slippage
        //   await (
        //     await mockV3Aggregator.updateAnswer(
        //       ethers.utils.parseUnits("78.95", "8")
        //     )
        //   ).wait();

        //   await expect(
        //     wtiMarketTaker.callStatic.takeDeal(
        //       dealId,
        //       ethers.utils.parseEther("80.64"),
        //       ethers.utils.parseEther("0.02")
        //     )
        //   ).to.be.revertedWith("DerivativeCFD: Deposit Out of range");
        // });

        it("doesn't revert when rateOracle fits makers or takers requirements", async () => {
          // const takeDealTx = await wtiMarketTaker.takeDeal(
          //   dealId,
          //   ethers.utils.parseEther("1.5710"),
          //   ethers.utils.parseEther("0.02")
          // );

          // await takeDealTx.wait();

          await expect(
            wtiMarketTaker.callStatic.takeDeal(
              dealId,
              ethers.utils.parseEther("1.5710"),
              ethers.utils.parseEther("0.02")
            )
          ).not.to.be.revertedWith("DerivativeCFD: Deposit Out of range");
        });

        it("makes refund to maker correctly", async () => {
          const dealParams = await wtiMarketMaker.getDeal(dealId);
          const collateralAmountMaker = dealParams.collateralAmountMaker;
          const collateralAmountBuyer = dealParams.collateralAmountBuyer;
          const makerBalanceBefore = await testUSDC.balanceOf(maker.address);
          const takeDealTx = await wtiMarketTaker.takeDeal(
            dealId,
            ethers.utils.parseEther("1.5710"),
            ethers.utils.parseEther("0.02")
          );
          await takeDealTx.wait();

          const makerBalanceAfter = await testUSDC.balanceOf(maker.address);

          const amountToRefund = collateralAmountMaker.sub(
            collateralAmountBuyer
          );

          assert.equal(
            makerBalanceBefore.add(amountToRefund),
            makerBalanceAfter
          );
        });

        it("mints NFT and assigns ownership to buyer and seller correctly", async () => {
          const takeDealTx = await wtiMarketTaker.takeDeal(
            dealId,
            ethers.utils.parseEther("1.5710"),
            ethers.utils.parseEther("0.02")
          );
          await takeDealTx.wait();

          const dealParams = await wtiMarketMaker.getDeal(dealId);

          const buyerTokenId = dealParams.buyerTokenId;
          const sellerTokenId = dealParams.sellerTokenId;

          assert.equal(buyerTokenId.toString(), "1");
          assert.equal(sellerTokenId.toString(), "2");

          // const tokenHolders = await wtiMarketTaker.nft .getHolders("1");
          // const firstHolder = tokenHolders[0];
          // const secondHolder = tokenHolders[1];

          // assert.equal(firstHolder, maker.address);
          // assert.equal(secondHolder, taker.address);
        });
      });

      describe("Processing", async () => {
        beforeEach(async () => {
          wtiMarketMaker = wtiMarket.connect(maker);
          testUSDCMaker = testUSDC.connect(maker);
          wtiMarketTaker = wtiMarket.connect(taker);
          testUSDCTaker = testUSDC.connect(taker);

          const correctCollateral = ethers.utils.parseEther("8.20590");
          const approveMakerTx = await testUSDCMaker.approve(
            deposit.address,
            correctCollateral
          );
          await approveMakerTx.wait(1);

          const approveTakerTx = await testUSDCTaker.approve(
            deposit.address,
            ethers.utils.parseEther("100")
          );
          await approveTakerTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams);
          const dealTxReceipt = await dealTx.wait(1);

          dealId = dealTxReceipt!.events![3].args!.dealId;
        });

        it("cancels expired deal and sets status to expired", async () => {
          // simulating getting blockchain time on expiration date
          let dealParams = await wtiMarketMaker.getDeal(dealId);
          const expiration = dealParams.periodOrderExpiration.toNumber();
          await network.provider.send("evm_increaseTime", [expiration + 1]);
          await network.provider.request({ method: "evm_mine", params: [] });
          await wtiMarketMaker.processing(dealId);

          dealParams = await wtiMarketMaker.getDeal(dealId);
          let dealStatus = dealParams.status;
          assert.equal(dealStatus, 4);
        });

        it("test for untaken unexpired deal", async () => {
          // simulating getting blockchain time on expiration date
          console.log("test for untaken unexpired deal");
          let dealParams = await wtiMarketMaker.getDeal(dealId);

          // await wtiMarketMaker.processing(dealId);

          await expect(wtiMarketMaker.processing(dealId)).to.be.reverted;

          dealParams = await wtiMarketMaker.getDeal(dealId);
          let dealStatus = dealParams.status;
          console.log(`Deal status: ${dealStatus}`);
        });

        it("test for taken unexpired deal", async () => {
          // simulating getting blockchain time on expiration date
          console.log("test for taken unexpired deal");
          let dealParams = await wtiMarketMaker.getDeal(dealId);

          const takeDealTx = await wtiMarketTaker.takeDeal(
            dealId,
            ethers.utils.parseEther("1.5710"),
            ethers.utils.parseEther("0.02")
          );
          await takeDealTx.wait();

          // await wtiMarketMaker.processing(dealId);

          await expect(wtiMarketMaker.processing(dealId)).to.be.reverted;

          dealParams = await wtiMarketMaker.getDeal(dealId);
          let dealStatus = dealParams.status;
          console.log(`Deal status: ${dealStatus}`);
        });

        it("test for taken expired deal", async () => {
          // simulating getting blockchain time on expiration date
          console.log("test for taken expired deal");
          let dealParams = await wtiMarketMaker.getDeal(dealId);

          const takeDealTx = await wtiMarketTaker.takeDeal(
            dealId,
            ethers.utils.parseEther("1.5710"),
            ethers.utils.parseEther("0.02")
          );
          await takeDealTx.wait();

          const expiration = dealParams.periodOrderExpiration.toNumber();
          await network.provider.send("evm_increaseTime", [expiration + 1]);
          await network.provider.request({ method: "evm_mine", params: [] });

          await wtiMarketMaker.processing(dealId);

          dealParams = await wtiMarketMaker.getDeal(dealId);
          let dealStatus = dealParams.status;
          console.log(`Deal status: ${dealStatus}`);
        });
      });
    });
