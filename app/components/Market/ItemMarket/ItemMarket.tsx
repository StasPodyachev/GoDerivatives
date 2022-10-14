
import Image from 'next/image'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import addresses from '../../../contracts/addresses'
import Button from '../../ui/Button'
import ChangePrice from '../../ui/ChangePrice'
import Coin from '../../ui/Coin'
import styles from './ItemMarket.module.css'
import ORACLE_ABI from "../../../contracts/abi/Oracle.json";
import BigDecimal from "decimal.js-light";
import { useContractRead } from 'wagmi'
interface OrderModel {
    id: number,
    currencyName: string,
    price: number,
    icon: string,
    description: string,
    duration: string,
    leverage: string,
    currency: string,
    orderLink: string,
    percent: string,
    derevativeName: string
}

const ItemMarket = ({order, coin} : {order: OrderModel, coin: any}) => {
  const { push } = useRouter()
  const [price, setPrice] = useState(1.61);

  const { data: rate } = useContractRead({
    addressOrName: addresses?.oracle?.address,
    contractInterface: ORACLE_ABI,
    functionName: "getLatest",
    args: ["0x76Aa17dCda9E8529149E76e9ffaE4aD1C4AD701B"],
  });
  useEffect(() => {
    if (rate) {
      const amount = new BigDecimal(rate?.amount.toString())
        .div(1e18)
        .toString();
      setPrice(+amount);
    }
  }, [rate]);

  return (
    <div className={styles.itemMarket}>
      <div className={styles.header}>
        <Image src={order?.icon} alt="currency" width={48} height={48} />
        <div className={styles?.title}>
          <span className={styles.price}><Coin coin={{price: price.toFixed(2)}} /></span>
          <span className={styles.currencyName}>{order?.derevativeName}</span>
        </div>
        <ChangePrice coin={coin}/>
      </div>
      <span className={styles.description}>{order?.description}</span>
      <div className={styles.options}>
        <div>
          <Image src="/icons/orderIcon/duration.svg" width={15} height={15} alt="duration" />
          <span>{order?.duration}</span>
        </div>
        <div>
          <Image src="/icons/orderIcon/leverage.svg" width={15} height={15} alt="leverage" />
          <span>{order?.leverage}</span>
        </div>
        <div>
          <Image src="/icons/orderIcon/wallets.svg" width={15} height={15} alt="currency"/>
          <span>{order?.currency}</span>
        </div>
      </div>

      <div className={styles.btn}>
        <Button onClick={() => push(`/order-book/${order?.currencyName}`)} title='Start traiding' />
      </div>
    </div>
  )
}

export default ItemMarket