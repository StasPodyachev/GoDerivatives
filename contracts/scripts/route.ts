const hre = require("hardhat");

import { Market } from "../typechain";

import { deployNames } from "../tasks/constants";
import deployment from "../data/deployments.json";

const deployments: IDeployment = deployment;
// const hre: any = hardhat;

async function main() {
  const network = await hre.getChainId();

  const marketDeployed = deployments[network]["Market"];

  const market = (await hre.ethers.getContractAt(
    "Market",
    marketDeployed.address
  )) as Market;

  await market.processing(5, { gasLimit: 500000 });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
