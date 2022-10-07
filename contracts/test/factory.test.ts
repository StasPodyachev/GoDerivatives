import { assert, expect } from "chai";
import { ethers, network, waffle } from "hardhat";
import { DerivativeCFD } from "../typechain";

let ownerAddress: any;
let depositUSD: any;
let depositEUR: any;
let depositEth: any;
let tUsdErc20: any;
let testAMM: any;
let cfdEth: DerivativeCFD;

export const BIG_1E8 = BigInt(100000000);
export const BIG_1E16 = BigInt(10000000000000000);
export const BIG_1E18 = BigInt("1000000000000000000");
export const BIG_1E20 = BigInt("100000000000000000000");

describe("DerivativeCFD", () => {
  beforeEach(async () => {
    const accounts = await ethers.getSigners();

    const factoryFactory = await ethers.getContractFactory("Factory");

    const factory = await factoryFactory.deploy();

    // deploy
  });
  it("factory", async () => {
    const price = BigInt(1000);
  });
});
