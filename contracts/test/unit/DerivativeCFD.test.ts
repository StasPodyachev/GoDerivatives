import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { network, ethers } from "hardhat";
import { developmentChains } from "../../helper-hardhat-config";
import { DerivativeCFD, DerivativeCFD__factory } from "../../typechain";
import { setup } from "./deploy-unit";

describe("DerivativeCFD", () => {
  beforeEach(async () => {
    await setup();
  });
  it("sets the aggregator addresses correctly", async () => {});
});
