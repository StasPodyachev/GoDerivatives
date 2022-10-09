import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { network, ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";
import { developmentChains } from "../../helper-hardhat-config";
import {
  Deposit,
  DerivativeCFD,
  DerivativeCFD__factory,
  Factory,
  Keeper,
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
let keeper: Keeper;
let wtiMarket: Market;

// instances of market wrt maker and taker
let wtiMarketMaker: Market;
let wtiMarketTaker: Market;

// instances of testUSDC wrt maker and taker
let testUSDCMaker: SimpleToken;
let testUSDCTaker: SimpleToken;

const dealParams = {
  makerPosition: true,
  rate: ethers.utils.parseEther("80.45"),
  count: ethers.utils.parseEther("1"),
  percent: ethers.utils.parseEther("0.1"),
  expiration: 86400, // 1 day
  slippage: ethers.utils.parseEther("0.02"),
};

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("DerivativeCFD Unit Tests", function () {
      beforeEach(async () => {
        // Deploy core contracts and
        const setupItems = await setup();
        owner = setupItems.owner;
        maker = setupItems.maker;
        taker = setupItems.taker;
        factory = setupItems.factory;
        storage = setupItems.storage;
        deposit = setupItems.deposit;
        mockV3Aggregator = setupItems.mockV3Aggregator;
        oracle = setupItems.oracle;
        testUSDC = setupItems.testUSDC;
        keeper = setupItems.keeper;
        wtiMarket = setupItems.wtiMarket;
      });

      describe("Create Deal", () => {
        beforeEach(async () => {
          wtiMarketMaker = wtiMarket.connect(maker);
          testUSDCMaker = testUSDC.connect(maker);
        });

        it("calculates collateralAmountMaker correctly", async () => {
          const correctCollateral = ethers.utils.parseEther("8.20590");
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

        it("doesn't revert when sending no collateral to subtract from balance automatically", async () => {
          await expect(
            wtiMarketMaker.callStatic.createDeal(dealParams)
          ).not.to.be.revertedWith(
            "DerivativeCFD: Collateral amount does not equal msg.value"
          );
        });

        it("subtracts deposit correctly when passing collateral explicitly", async () => {
          const correctCollateral = ethers.utils.parseEther("8.20590");
          const makerBalanceBefore = await testUSDC.balanceOf(maker.address);
          const makerDepositBefore = await deposit.balances(
            maker.address,
            ethers.constants.AddressZero
          );

          const approveTx = await testUSDCMaker.approve(
            wtiMarket.address,
            correctCollateral
          );
          await approveTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams, {
            value: correctCollateral,
          });
          await dealTx.wait(1);

          const makerBalanceAfter = await testUSDC.balanceOf(maker.address);
          const makerDepositAfter = await deposit.balances(
            maker.address,
            ethers.constants.AddressZero
          );

          assert.equal(
            correctCollateral.toString(),
            makerDepositAfter.toString()
          );

          // Market pays gas?
          // assert.equal(
          //   makerBalanceAfter.add(makerDepositAfter).toString(),
          //   makerBalanceBefore.toString()
          // );
        });

        it("subtracts deposit correctly when passing collateral implicitly", async () => {
          const correctCollateral = ethers.utils.parseEther("8.20590");
          const makerBalanceBefore = await testUSDC.balanceOf(maker.address);
          const makerDepositBefore = await deposit.balances(
            maker.address,
            ethers.constants.AddressZero
          );

          const approveTx = await testUSDCMaker.approve(
            deposit.address,
            correctCollateral
          );
          await approveTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams, {
            value: ethers.utils.parseEther("0"),
          });
          const dealTxReceipt = await dealTx.wait(1);

          const { gasUsed, effectiveGasPrice } = dealTxReceipt;
          const gasCost = gasUsed.mul(effectiveGasPrice);
          console.log(gasCost.toString());

          const makerBalanceAfter = await testUSDC.balanceOf(maker.address);
          const makerDepositAfter = await deposit.balances(
            maker.address,
            testUSDC.address
          );

          assert.equal(
            correctCollateral.toString(),
            makerDepositAfter.toString()
          );

          // Market pays gas?
          assert.equal(
            makerBalanceAfter.add(makerDepositAfter).toString(),
            makerBalanceBefore.toString()
          );
        });

        it("emits DealCreated event correctly when creating deal", async () => {
          const correctCollateral = ethers.utils.parseEther("8.20590");
          const approveTx = await testUSDCMaker.approve(
            deposit.address,
            correctCollateral
          );
          await approveTx.wait(1);

          const dealTx = await wtiMarketMaker.createDeal(dealParams, {
            value: ethers.utils.parseEther("0"),
          });
          const dealTxReceipt = await dealTx.wait(1);

          const dealId = dealTxReceipt!.events![3].args!.dealId;
          assert.equal(dealId.toString(), "1");
        });
      });
    });
