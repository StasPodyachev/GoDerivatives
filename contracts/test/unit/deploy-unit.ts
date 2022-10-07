import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
  Deposit,
  Deposit__factory,
  // DerivativeCFD,
  // DerivativeCFD__factory,
  Factory,
  Factory__factory,
  // Market,
  // Market__factory,
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
  IOracle,
} from "../../typechain";

const DECIMALS = "18";
const INITIAL_PRICE = "80000000000000000000"; // 80

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
  mockV3Aggregator.connect(owner);

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
  testUSDC.connect(owner);

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
  oracle.connect(owner);

  return oracle;
}

async function deployFactory(owner: SignerWithAddress): Promise<Factory> {
  console.log("Deploy factory...");
  let factory: Factory;
  let factoryFactory: Factory__factory;
  factoryFactory = (await ethers.getContractFactory(
    "Factory"
  )) as Factory__factory;
  factoryFactory.connect(owner);
  factory = await factoryFactory.deploy();
  factory.connect(owner);

  return factory;
}

async function deployStorage(owner: SignerWithAddress): Promise<Storage> {
  console.log("Deploy storage...");
  let storage: Storage;
  let storageFactory: Storage__factory;
  storageFactory = (await ethers.getContractFactory(
    "Storage"
  )) as Storage__factory;
  storageFactory.connect(owner);
  storage = await storageFactory.deploy();
  storage.connect(owner);

  return storage;
}

async function deployMarketDeployer(
  owner: SignerWithAddress
): Promise<MarketDeployer> {
  console.log("Deploy marketDeployer...");
  let marketDeployer: MarketDeployer;
  let marketDeployerFactory: MarketDeployer__factory;
  marketDeployerFactory = (await ethers.getContractFactory(
    "MarketDeployer"
  )) as MarketDeployer__factory;
  marketDeployerFactory.connect(owner);
  marketDeployer = await marketDeployerFactory.deploy();
  marketDeployer.connect(owner);

  return marketDeployer;
}

async function deployDeposit(owner: SignerWithAddress): Promise<Deposit> {
  console.log("Deploy deposit...");
  let deposit: Deposit;
  let depositFactory: Deposit__factory;
  depositFactory = (await ethers.getContractFactory(
    "Deposit"
  )) as Deposit__factory;
  depositFactory.connect(owner);
  deposit = await depositFactory.deploy();
  deposit.connect(owner);

  return deposit;
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
  await sendToTraders(testUSDC, owner.address, maker.address, taker.address);

  // deploy oracle and set aggregator
  const oracle = await deployOracle(owner, mockV3Aggregator.address);

  // deploy all other core contracts
  const factory = await deployFactory(owner);
  const storage = await deployStorage(owner);
  const marketDeployer = await deployMarketDeployer(owner);
  const deposit = await deployDeposit(owner);

  // set reference dependencies
  console.log("Setting dependencies...");
  await factory.setDeposit(deposit.address);
  await factory.setStorage(storage.address);

  await storage.setFactory(factory.address);

  await deposit.setFactory(factory.address);

  // set marketDeployer parameters
  let wtiMarketParameters = {
    factory: factory.address,
    deposit: deposit.address,
    operator: owner.address,
    underlyingAssetName: "WTI",
    coin: testUSDC.address,
    duration: 864000,
    oracleAggregatorAddress: mockV3Aggregator.address,
    storageAddress: storage.address,
    oracleType: 0,
    operatorFee: 3,
    serviceFee: 3,
  };

  // deploy WTI/USDC market
  const createMarketTx = await factory.createMarket(wtiMarketParameters);
  await createMarketTx.wait();

  // const wtiMarket = await factory.allMarkets(0);
  // console.log(`${wtiMarket}`);
}
