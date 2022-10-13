import { BigInt } from "@graphprotocol/graph-ts";
import { DealAccepted, Market as MarketContract } from "../../generated/templates/Market/Market"
import { Deal} from "../../generated/schema"
import { DealStatus } from "../utils/constants.template";


export function handleDealCreated(event: DealAccepted): void {
  let id: string = event.params.dealId.toHex()

  let marketContract: MarketContract = MarketContract.bind(
    event.address
  );

  let deal = marketContract.getDeal(event.params.dealId)

  let entity: Deal = new Deal(id)

  entity.maker = deal.maker
  entity.buyer = deal.buyer
  entity.seller = deal.seller
  entity.rate = deal.rate
  entity.rateMaker = deal.rateMaker
  entity.count = deal.count
  entity.percent = deal.percent
  entity.periodOrderExpiration = deal.periodOrderExpiration
  entity.slippageMaker = deal.slippageMaker
  entity.slippageTaker = deal.slippageTaker
  entity.collateralAmountBuyer = deal.collateralAmountBuyer
  entity.collateralAmountMaker = deal.collateralAmountMaker
  entity.collateralAmountSeller = deal.collateralAmountSeller
  entity.dateOrderCreation = deal.dateOrderCreation
  entity.dateStart = deal.dateStart
  entity.dateStop = deal.dateStop
  entity.oracleAmount = deal.oracleAmount
  entity.oracleRoundIDStart = deal.oracleRoundIDStart
  entity.buyerTokenId = deal.buyerTokenId
  entity.sellerTokenId = deal.sellerTokenId
  entity.status =  BigInt.fromI32(deal.status)

  entity.save()
}

export function handleDealCanceled(event: DealAccepted): void {
  let id: string = event.params.dealId.toHex()

  let entity: Deal | null = Deal.load(id)
  if(!entity) return

  entity.status = BigInt.fromI32(DealStatus.CANCELED)
  entity.save()
}

export function handleDealCompleted(event: DealAccepted): void {
  let id: string = event.params.dealId.toHex()
  let entity: Deal | null = Deal.load(id)
  if(!entity) return

  entity.status = BigInt.fromI32(DealStatus.COMPLETED)
  entity.save()
}

export function handleDealAccepted(event: DealAccepted): void {
  let id: string = event.params.dealId.toHex()

  let marketContract: MarketContract = MarketContract.bind(
    event.address
  );

  let entity: Deal | null = Deal.load(id)
  if(!entity) return

  let deal = marketContract.getDeal(event.params.dealId)

  entity.buyer = deal.buyer
  entity.seller = deal.seller
  entity.collateralAmountBuyer = deal.collateralAmountBuyer
  entity.collateralAmountSeller = deal.collateralAmountSeller
  entity.rate = deal.rate
  entity.oracleRoundIDStart = deal.oracleRoundIDStart
  entity.buyerTokenId = deal.buyerTokenId
  entity.sellerTokenId = deal.sellerTokenId
  entity.oracleAmount = deal.oracleAmount
  entity.status = BigInt.fromI32(deal.status)
  entity.save()
}

export function handleDealExpired(event: DealAccepted): void {
  let id: string = event.params.dealId.toHex()
  let entity: Deal | null = Deal.load(id)
  if(!entity) return

  entity.status = BigInt.fromI32(DealStatus.EXPIRED)
  entity.save()
}
