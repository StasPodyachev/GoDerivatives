import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { Address } from "hardhat-deploy/dist/types";

import {
  DealNFT,
  DealNFT__factory,
  Deposit,
  Deposit__factory,
  // DerivativeCFD,
  // DerivativeCFD__factory,
  Factory,
  Factory__factory,
  Keeper,
  Keeper__factory,
  Market,
  // Market__factory,
  MockV3Aggregator,
  MockV3Aggregator__factory,
  Oracle,
  Oracle__factory,
  SimpleToken,
  SimpleToken__factory,
  Storage,
  Storage__factory,
} from "../../typechain";

const DECIMALS = "18";
const INITIAL_PRICE = ethers.utils.parseUnits("1.57", DECIMALS);

async function deployMockV3Aggregator(
  owner: SignerWithAddress
): Promise<MockV3Aggregator> {
  // deploy Mock for Chainlink Oracle
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
  const sendMakerTx = await token.transfer(
    maker,
    ethers.utils.parseEther("10000")
  );

  await sendMakerTx.wait(1);

  const makerBalance = await token.balanceOf(maker);

  const sendTakerTx = await token.transfer(
    taker,
    ethers.utils.parseEther("10000")
  );

  await sendTakerTx.wait(1);

  const takerBalance = await token.balanceOf(maker);
}

async function deployOracle(owner: SignerWithAddress): Promise<Oracle> {
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

async function deployNFT(owner: SignerWithAddress): Promise<DealNFT> {
  let dealNFT: DealNFT;
  let dealNFTFactory: DealNFT__factory;
  dealNFTFactory = (await ethers.getContractFactory(
    "DealNFT"
  )) as DealNFT__factory;
  dealNFTFactory.connect(owner);
  dealNFT = await dealNFTFactory.deploy("");
  dealNFT.connect(owner);

  return dealNFT;
}

async function deployStorage(owner: SignerWithAddress): Promise<Storage> {
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

async function deployKeeper(owner: SignerWithAddress): Promise<Keeper> {
  let keeper: Keeper;
  let keeperFactory: Keeper__factory;
  keeperFactory = (await ethers.getContractFactory(
    "Keeper"
  )) as Keeper__factory;
  keeperFactory.connect(owner);
  keeper = await keeperFactory.deploy(owner.address);
  keeper.connect(owner);

  return keeper;
}

async function deployDeposit(owner: SignerWithAddress): Promise<Deposit> {
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
  // default hardhat accounts
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
  const oracle = await deployOracle(owner);

  // deploy all other core contracts
  const factory = await deployFactory(owner);
  const storage = await deployStorage(owner);
  // const marketDeployer = await deployMarketDeployer(owner);
  const deposit = await deployDeposit(owner);
  const dealNFT = await deployNFT(owner);

  // set reference dependencies
  await factory.setDeposit(deposit.address);
  await factory.setStorage(storage.address);
  await factory.addOracleAddress(oracle.address, "0");

  await storage.setFactory(factory.address);

  await deposit.setFactory(factory.address);

  // deploy WTI/USDC market
  const wtiMarketCreateTx = await factory.createMarket({
    underlyingAssetName: "WTI",
    coin: testUSDC.address,
    duration: 86400,
    oracleAggregatorAddress: mockV3Aggregator.address,
    nft: dealNFT.address,
    oracleType: 0,
    operatorFee: ethers.utils.parseEther("0.03"),
    serviceFee: ethers.utils.parseEther("0.03"),
  });

  await wtiMarketCreateTx.wait(1);

  const wtiMarketAddress = await factory.allMarkets(0);
  const wtiMarket = (await ethers.getContractAt(
    "Market",
    wtiMarketAddress,
    owner
  )) as Market;

  return {
    owner,
    maker,
    taker,
    factory,
    storage,
    deposit,
    dealNFT,
    mockV3Aggregator,
    oracle,
    testUSDC,
    wtiMarket,
  };
}
