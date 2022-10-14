// constants

import { BigDecimal, BigInt, Address } from "@graphprotocol/graph-ts";
import { Factory as FactoryContract } from "../../generated/Factory/Factory";

export let ZERO_BI = BigInt.fromI32(0);
export let ONE_BI = BigInt.fromI32(1);
export let ZERO_BD = BigDecimal.fromString("0");
export let ONE_BD = BigDecimal.fromString("1");
export let BI_18 = BigInt.fromI32(18);

export const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000";
export const FACTORY_ADDRESS = "0x41Da3dB5b9b846289f534D9B3b524d6B054fB26c";

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