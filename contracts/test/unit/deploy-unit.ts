import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";
import { ContractFunctionVisibility } from "hardhat/internal/hardhat-network/stack-traces/model";

import {
  Deposit,
  Deposit__factory,
  DerivativeCFD,
  DerivativeCFD__factory,
  Factory,
  Factory__factory,
  Market,
  Market__factory,
  MockV3Aggregator,
  MockV3Aggregator__factory,
  MarketDeployer,
  MarketDeployer__factory,
  Oracle,
  Oracle__factory,
  SimpleToken,
  SimpleToken__factory,
  Storage,
  Storage__factory,
} from "../../typechain";

const DECIMALS = "18";
const INITIAL_PRICE = "80000000000000000000"; // 100

async function deployMockV3Aggregator(
  owner: SignerWithAddress
): Promise<MockV3Aggregator> {
  // deploy Mock for Chainlink Oracle
  console.log("Deploy chainlink oracke mock...");
  let mockV3Aggregator: MockV3Aggregator;
  let mockV3AggregatorFactory: MockV3Aggregator__factory;
  mockV3AggregatorFactory = (await ethers.getContractFactory(
    "MockV3Aggregator"
  )) as MockV3Aggregator__factory;
  mockV3AggregatorFactory.connect(owner);
  mockV3Aggregator = await mockV3AggregatorFactory.deploy(
    DECIMALS,
    INITIAL_PRICE
  );

  return mockV3Aggregator;
}

async function deployTestUSDC(owner: SignerWithAddress): Promise<SimpleToken> {
  // deploy TestUSDC as quote asset and send to traders
  console.log("Deploy test usdc as collateral and quote asset...");
  let testUSDC: SimpleToken;
  let testUSDCFactory: SimpleToken__factory;
  testUSDCFactory = (await ethers.getContractFactory(
    "SimpleToken"
  )) as SimpleToken__factory;
  testUSDCFactory.connect(owner);
  testUSDC = await testUSDCFactory.deploy(
    "TestUSDC",
    "USDC",
    ethers.utils.parseEther("1000000000")
  );

  return testUSDC;
}

async function sendToTraders(
  token: SimpleToken,
  owner: Address,
  maker: Address,
  taker: Address
) {
  console.log("Send test tokens to traders...");
  const sendMakerTx = await token.transfer(
    maker,
    ethers.utils.parseEther("10000")
  );

  await sendMakerTx.wait(1);

  const makerBalance = await token.balanceOf(maker);
  console.log(`Maker Balance: ${makerBalance}`);

  const sendTakerTx = await token.transfer(
    taker,
    ethers.utils.parseEther("10000")
  );

  await sendTakerTx.wait(1);

  const takerBalance = await token.balanceOf(maker);
  console.log(`Taker Balance: ${takerBalance}`);
}

async function deployOracle(
  owner: SignerWithAddress,
  mockV3AggregatorAddress: Address
): Promise<Oracle> {
  console.log("Deploy oracle wrapper and set aggregator...");
  let oracle: Oracle;
  let oracleFactory: Oracle__factory;
  oracleFactory = (await ethers.getContractFactory(
    "Oracle"
  )) as Oracle__factory;
  oracleFactory.connect(owner);
  oracle = await oracleFactory.deploy();

  await oracle.setAggregator(mockV3AggregatorAddress);

  return oracle;
}

export async function setup() {
  console.log("Unit tests setup...");

  // default hardhat accounts
  console.log("Setting accounts...");
  const accounts = await ethers.getSigners();
  const owner = accounts[0]!;
  const maker = accounts[1]!;
  const taker = accounts[2]!;

  // deploy Mock for Chainlink Oracle
  const mockV3Aggregator = await deployMockV3Aggregator(owner);

  // deploy TestUSDC as quote asset and send to traders
  const testUSDC = await deployTestUSDC(owner);
  testUSDC.connect(owner);
  await sendToTraders(testUSDC, owner.address, maker.address, taker.address);

  // deploy oracle
  const oracle = await deployOracle(owner, mockV3Aggregator.address);

  // deploy factory
  // const deployFactory = await deployFactory;

  // const factory = await factoryFactory.deploy();
}
