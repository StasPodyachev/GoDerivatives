const hre = require("hardhat");

import { Factory, Market } from "../typechain";

import { deployNames } from "../tasks/constants";
import deployment from "../data/deployments.json";
import { BigNumber } from "ethers";

const deployments: IDeployment = deployment;
// const hre: any = hardhat;

async function main() {
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

  let tx = await factory.addOracleAddress(oracleDeployed.address, 0); // Chainlink wrapper
  await tx.wait();

  tx = await factory.createMarket({
    coin: "0x0000000000000000000000000000000000000000",
    nft: nftDeployed.address,
    oracleAggregatorAddress: "0xf49f81b3d2F2a79b706621FA2D5934136352140c",
    underlyingAssetName: "LINK",
    duration: 300,
    oracleType: 0,
    operatorFee: BigNumber.from("5000000000000000"), // 0.5%
    serviceFee: BigNumber.from("10000000000000000"), // 1%
  });

  // await market.processing(5, { gasLimit: 500000 });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
