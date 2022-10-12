import {
  KeeperCreated as KeeperCreatedEvent,
  MarketCreated as MarketCreatedEvent,
} from "../../generated/Factory/Factory"
import { Keeper as KeeperEntity } from "../../generated/schema"
import { Keeper as KeeperTemplate } from "../../generated/templates"
import { Keeper as KeeperContract } from "../../generated/templates/Keeper/Keeper"

import { Market as MarketEntity } from "../../generated/schema"
import { Market as MarketTemplate } from "../../generated/templates"
import { Market as MarketContract } from "../../generated/templates/Market/Market"
import { BigInt } from "@graphprotocol/graph-ts"
import { fetchTokenSymbol} from '../utils/token'

export function handleKeeperCreated(event: KeeperCreatedEvent): void {
  let entity = new KeeperEntity(
      event.params.keeperAddress.toHex()
  )

  let keeperContract: KeeperContract = KeeperContract.bind(
    event.params.keeperAddress
  );

  entity.id = event.params.keeperAddress.toHex()
  entity.operator = keeperContract.operator()
  entity.markets = []
  entity.save()

  KeeperTemplate.create(event.params.keeperAddress)
}

export function handleMarketCreated(event: MarketCreatedEvent): void {
  let entity = new MarketEntity(
      event.params.marketAddress.toHex()
  )

  let keeperEntity: KeeperEntity | null = KeeperEntity.load(event.params.keeperAddress.toHex())
  if(keeperEntity == null) return;


  let marketContract: MarketContract = MarketContract.bind(
    event.params.marketAddress
  );

  let coin = marketContract.coin()
  let asset = marketContract.underlyingAssetName()
  let symbol = fetchTokenSymbol(coin)

  entity.id = event.params.marketAddress.toHex()
  entity.name = `${asset}/${symbol}`
  entity.coin = coin
  entity.underlyingAssetName= asset
  entity.duration = marketContract.duration()
  entity.oracleAggregatorAddress = marketContract.oracleAggregatorAddress()
  entity.operatorFee = marketContract.operatorFee_()
  entity.serviceFee = marketContract.serviceFee_()
  entity.operator = marketContract.operator()
  entity.oracleType = BigInt.fromI32(marketContract.oracleType())
  entity.keeper = event.params.keeperAddress.toHex()

  let markets = keeperEntity.markets
  markets?.push(event.params.marketAddress.toHex())
  keeperEntity.markets = markets;
  
  entity.save()

  MarketTemplate.create(event.params.marketAddress)
}
