const hre = require("hardhat");
import fs from "fs";
import { IDeployment, recordAllDeployments } from "../../tasks/utils";
import deployment from "../../deployment/deployments.json";

import { deployNames } from "../../tasks/constants";
import { Deposit, Factory, Keeper, Storage } from "../../typechain";
const deployments: IDeployment = deployment;

let accounts: any

// const hre: any = hardhat;

const contracts = [
    {
        contractName: deployNames.FACTORY,
        func: factory
    },
    {
        contractName: deployNames.DEPOSIT,
        func: deposit
    },
    {
        contractName: deployNames.KEEPER,
        func: keeper
    },
    {
        contractName: deployNames.STORAGE,
        func: storage
    },
]

async function main() {

    accounts = await hre.ethers.getSigners()

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

    const factory = await hre.ethers.getContractAt(
        deployNames.FACTORY,
        factoryDeployed.address
    ) as Factory

    await factory.setStorage(storageDeployed.address);
    await factory.setDeposit(depositDeployed.address);
}

async function keeper() {
    const network = await hre.getChainId();

    const factoryDeployed = deployments[network][deployNames.FACTORY];
    const keeperDeployed = deployments[network][deployNames.KEEPER];

    const keeper = await hre.ethers.getContractAt(
        deployNames.KEEPER,
        keeperDeployed.address
    ) as Keeper

    await keeper.setFactory(factoryDeployed.address);

    await keeper.setOperator(accounts[0].address);
}

async function storage() {
    const network = await hre.getChainId();

    const factoryDeployed = deployments[network][deployNames.FACTORY];
    const storageDeployed = deployments[network][deployNames.STORAGE];

    const storage = await hre.ethers.getContractAt(
        deployNames.STORAGE,
        storageDeployed.address
    ) as Storage

    await storage.setFactory(factoryDeployed.address);
}

async function deposit() {
    const network = await hre.getChainId();

    const factoryDeployed = deployments[network][deployNames.FACTORY];
    const depositDeployed = deployments[network][deployNames.DEPOSIT];

    const deposit = await hre.ethers.getContractAt(
        deployNames.DEPOSIT,
        depositDeployed.address
    ) as Deposit

    await deposit.setFactory(factoryDeployed.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });
