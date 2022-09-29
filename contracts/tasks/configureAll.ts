import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";
import { deployNames } from "./constants";

const contracts = [];

task("configure:all").setAction(async function (
  _taskArguments: TaskArguments,
  hre
) {
  for (let i in contracts) {
    const contract = contracts[i];

    console.log(`configuring ${contract.contractName} started`);

    await hre.run(`configure:${contract.name}`);

    console.log(`${contract.contractName} deployed success`);
    console.log("-------------------------------------------");

    /*****************************************************************/
  }
});
