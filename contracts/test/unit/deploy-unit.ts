import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";

import {
  Deposit,
  Deposit__factory,
  DerivativeCFD,
  DerivativeCFD__factory,
  Factory,
  Factory__factory,
  Market,
  Market__factory,
  MockV3Aggregator,
  MockV3Aggregator__factory,
  MarketDeployer,
  MarketDeployer__factory,
  Storage,
  Storage__factory,
} from "../../typechain";

export function deployAll() {
  // deploy Mock for Chainlink Oracle
}
