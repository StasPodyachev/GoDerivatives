const hre = require("hardhat");
import fs from "fs";
import { IDeployment, recordAllDeployments } from "../tasks/utils";
import deployment from "../data/deployments.json";
import { deployNames } from "../tasks/constants";

const deployments: IDeployment = deployment;

// const hre: any = hardhat;

const contracts = [
  {
    contractName: deployNames.FACTORY,
  },
  {
    contractName: deployNames.DEPOSIT,
  },
  {
    contractName: deployNames.DEAL_NFT,
    args: ["https://cfd-app.vercel.app/nft/{id}"],
    ignore: false,
  },
  {
    contractName: deployNames.ORACLE,
  },
  {
    contractName: deployNames.STORAGE,
  },
  {
    contractName: deployNames.T_USD,
    nameFile: "SimpleToken",
    args: ["tUSD", "tUSD", "1000000000000000000000000000"],
    ignore: true,
  },
  {
    contractName: deployNames.T_EUR,
    nameFile: "SimpleToken",
    args: ["tEUR", "tEUR", "1000000000000000000000000000"],
    ignore: true,
  },
];

async function main() {
  // const network = await hre.getChainId();

  for (let i in contracts) {
    const contract = contracts[i];

    if (contract.ignore) continue;

    await contractDeploy(
      contract.contractName,
      contract.nameFile,
      contract.args
    );
  }
}

const contractDeploy = async (contractName: any, nameFile: any, args: any) => {
  const network = await hre.getChainId();

  const contractFactory = await hre.ethers.getContractFactory(
    nameFile ?? contractName
  );

  console.log(`Contract ${contractName} for deployment Started`);

  let contract;

  if (args) {
    contract = await contractFactory.deploy(...args);
  } else {
    contract = await contractFactory.deploy();
  }

  console.log("Contract deployment ended");
  console.log("***************************************");

  const writeData = await recordAllDeployments(
    network,
    contractName,
    "",
    contract.address
  );
  fs.writeFileSync("./data/deployments.json", JSON.stringify(writeData));
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
