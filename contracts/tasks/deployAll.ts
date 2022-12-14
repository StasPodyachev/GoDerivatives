import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";
import { deployNames } from "./constants";

const contracts = [];

task("deploy:all").setAction(async function (
  _taskArguments: TaskArguments,
  hre
) {
  for (let i in contracts) {
    const contract = contracts[i];

    console.log(`deploying ${contract.contractName} started`);

    await hre.run("deploy:contract", contract);

    console.log(`${contract.contractName} deployed success`);
    console.log("-------------------------------------------");

    /*****************************************************************/
  }
});
