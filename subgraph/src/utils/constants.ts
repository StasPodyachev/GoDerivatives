// constants

import { BigDecimal, BigInt, Address } from "@graphprotocol/graph-ts";
import { Factory as FactoryContract } from "../../generated/Factory/Factory";

export let ZERO_BI = BigInt.fromI32(0);
export let ONE_BI = BigInt.fromI32(1);
export let ZERO_BD = BigDecimal.fromString("0");
export let ONE_BD = BigDecimal.fromString("1");
export let BI_18 = BigInt.fromI32(18);

export const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000";
export const FACTORY_ADDRESS = "0x01f6898EFB1fC1eA8FA7FC66D0202DC0133ed69f";

export let factoryContract: FactoryContract = FactoryContract.bind(
  Address.fromString(FACTORY_ADDRESS)
);

export enum DealStatus {
  CREATED,
  ACCEPTED,
  COMPLETED,
  CANCELED,
  EXPIRED
} 