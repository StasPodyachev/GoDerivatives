import Image from 'next/image'
import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import Button from '../ui/Button'
import Coin from '../ui/Coin'
import Tab from '../ui/Tab'
import styles from './Order.module.css'
import WidgetOrder from './WidgetOrder'
import { Book } from './Book'
import { markets } from '../../data/markets'
import { useContractRead } from 'wagmi'
import addresses from '../../contracts/addresses'
import ORACLE_ABI from "../../contracts/abi/Oracle.json";
import BigDecimal from "decimal.js-light";

const tabs = [
  {
    id: 0,
    title: '5%',
    disabled: false
  },
  {
    id: 1,
    title: '7%',
    disabled: false
  },
  {
    id: 2,
    title: '10%',
    disabled: false
  },
  {
    id: 3,
    title: '12%',
    disabled: false
  },
  {
    id: 4,
    title: '15%',
    disabled: false
  },
]
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
  percent: string
}
const Order = ({order, coin} : {order : OrderModel, coin: any}) => {
  const [ checked, setChecket ] = useState(tabs[0])
  const [ activeMarket, setActiveMarket ] = useState(markets[0])
  const [price, setPrice] = useState(1.61);
  const { push, query } = useRouter()

  useEffect(() => {
    if(query) {
      const market = markets?.find(item => item.currencyName === query.orderName) 
      setActiveMarket(market)
    }
  }, [query])

  const { data: rate } = useContractRead({
    addressOrName: addresses?.oracle?.address,
    contractInterface: ORACLE_ABI,
    functionName: "getLatest",
    args: ["0x76Aa17dCda9E8529149E76e9ffaE4aD1C4AD701B"],
  });
  useEffect(() => {
    if (rate) {
      const amount = new BigDecimal(rate?.amount.toString())
        .div(1e18).toString()
      setPrice(+amount);
    }
  }, [rate]);

  return (
    <div className={styles.order}>
      <div className={styles.token}>
        <div className={styles.icon}>
          <Image
            alt="currency"
            src={activeMarket.icon}
            width={70} height={70}/>
          <div className={styles.iconsSecond}>
            <Image
              alt="currency"
              src='/icons/iconsCurrency/Tether.svg'
              width={24} height={24}/> 
          </div>
        </div>

        <div className={styles.option}>
          <span>{activeMarket.currencyName}</span>
          <p>
            <span>{price.toFixed(2)} </span>
            <span style={{"color" : "#6FCF97"}}>+0,75 (+1%)</span>
          </p>
          <span>in USDT 
            <div className={styles.days}>
              <div className={styles.rateIcon}>
                <Image alt='icon' src="/icons/orderIcon/exchange.svg" width={18} height={18} />
              </div>
              <span>30 days</span>
            </div>
          </span>
          
        </div>
      </div>
      <div className={styles.tabs}>
        {
          tabs?.map(tab => {
            return <Tab
              setChecket={() => setChecket(tab)} key={tab?.id}
              tab={tab}
              checked={checked?.id === tab?.id} />
          })
        }
      </div>

      <div className={styles.content}>
        <div className={styles.buy}>
          <div className={styles.titleBuy}>Long orders</div>
          <Book rate={price.toFixed(2)} type="buy" coin={coin} checked={checked?.title} />
        </div>
      </div>
      <div className={styles.content}>
        <div className={styles.sell}>
          <div className={styles.titleSell}>Short orders</div>
          <Book rate={price.toFixed(2)} type='sell' coin={coin} checked={checked?.title} />
        </div>
      </div>
      <WidgetOrder />
      <div className={styles.btn}>
        <Button onClick={() => push(`/deal/${query?.orderName}`)} title="Create Order" />
      </div>
    </div>
  )
}
export default Order