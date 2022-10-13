const hre = require("hardhat");
import fs from "fs";
import { IDeployment, recordAllDeployments } from "../tasks/utils";
import deployment from "../data/deployments.json";

import { deployNames } from "../tasks/constants";
import { Deposit, Factory, Keeper, Storage } from "../typechain";
import { BigNumber } from "ethers";

const deployments: IDeployment = deployment;

let accounts: any;

// const hre: any = hardhat;

const contracts = [
  {
    contractName: deployNames.FACTORY,
    func: factory,
  },
  {
    contractName: deployNames.DEPOSIT,
    func: deposit,
  },
  {
    contractName: deployNames.STORAGE,
    func: storage,
  },
];

async function main() {
  accounts = await hre.ethers.getSigners();

  for (let i in contracts) {
    const contract = contracts[i];
    console.log(`Configure start ${contract.contractName}`);

    await contract.func();
  }
}

async function factory() {
  const network = await hre.getChainId();

  const factoryDeployed = deployments[network][deployNames.FACTORY];
  const depositDeployed = deployments[network][deployNames.DEPOSIT];
  const storageDeployed = deployments[network][deployNames.STORAGE];
  const tUsdDeployed = deployments[network][deployNames.T_USD];
  const oracleDeployed = deployments[network][deployNames.ORACLE];
  const nftDeployed = deployments[network][deployNames.DEAL_NFT];

  const factory = (await hre.ethers.getContractAt(
    deployNames.FACTORY,
    factoryDeployed.address
  )) as Factory;

  let tx = await factory.setStorage(storageDeployed.address);
  await tx.wait();

  tx = await factory.setDeposit(depositDeployed.address);
  await tx.wait();

  await factory.addOracleAddress(oracleDeployed.address, 0); // Chainlink wrapper

  tx = await factory.createMarket({
    coin: tUsdDeployed.address,
    nft: nftDeployed.address,
    oracleAggregatorAddress: "0x76Aa17dCda9E8529149E76e9ffaE4aD1C4AD701B",
    underlyingAssetName: "WEMIX",
    duration: 300,
    oracleType: 0,
    operatorFee: BigNumber.from("5000000000000000"), // 0.5%
    serviceFee: BigNumber.from("10000000000000000"), // 1%
  });

  const result = await tx.wait();

  const events =
    result.events?.filter((s) => s.address == factory.address) ?? [];

  const contractNames = events.length == 2 ? ["Keeper", "Market"] : ["Market"];

  for (let i = 0; i < events.length; i++) {
    const ev = events[i];
    const writeData = await recordAllDeployments(
      network,
      contractNames[i],
      "",
      ev.args ? ev.args[0] : ""
    );
    fs.writeFileSync("./data/deployments.json", JSON.stringify(writeData));
  }
}

async function storage() {
  const network = await hre.getChainId();

  const factoryDeployed = deployments[network][deployNames.FACTORY];
  const storageDeployed = deployments[network][deployNames.STORAGE];

  const storage = (await hre.ethers.getContractAt(
    deployNames.STORAGE,
    storageDeployed.address
  )) as Storage;

  await storage.setFactory(factoryDeployed.address);
}

async function deposit() {
  const network = await hre.getChainId();

  const factoryDeployed = deployments[network][deployNames.FACTORY];
  const depositDeployed = deployments[network][deployNames.DEPOSIT];

  const deposit = (await hre.ethers.getContractAt(
    deployNames.DEPOSIT,
    depositDeployed.address
  )) as Deposit;

  await deposit.setFactory(factoryDeployed.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
