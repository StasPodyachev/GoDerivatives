import Image from 'next/image'
import { useState } from 'react'
import Select from '../DealContent/Select'
import Button from '../ui/Button'
import Input from './Input'
import styles from './KeeperContent.module.css'

const switchList = [
 {
   id: 0,
   title: 'Create Market'
 },
 {
   id: 1,
   title: 'Dashboard'
 }
]

const addresList = [
  {
    id: 0,
    title: "chainlink"
  },
  {
    id: 1,
    title: "oracle-defx"
  },
  {
    id: 2,
    title: "uniswap"
  }
]

const expList = [
  {
    id: 0,
    title: '3 days',
    value: 3
  },
  {
    id: 1,
    title: '10 days',
    value: 10
  },
  {
    id: 2,
    title: '15 days',
    value: 15
  },
  {
    id: 3,
    title: '30 days',
    value: 30
  }
]

const currencys = [
  {
    id: 0,
    title: 'tUSD',
    value: 3
  },
  {
    id: 1,
    title: 'tEUR',
    value: 10
  },
  {
    id: 2,
    title: 'KLAY',
    value: 15
  }
]

const orders = [
  {
    id: 0,
    icons: [
      {
        id: 1,
        icon: "/icons/iconsCurrency/wemix.svg"
      },
      {
        id: 2,
        icon: "/icons/iconsCurrency/Tether.svg"
      }
    ],
    name: "WEMIXtUSD",
    tvl: "100,000,000",
    info: {
      poll: '20xc3F...ED56',
      deals: "1257",
      ProfitLoss: "+ 78,000 tUSD"
    }
  },
  {
    id: 1,
    icons: [
      {
        id: 1,
        icon: "/icons/iconsCurrency/wti.svg"
      },
      {
        id: 2,
        icon: "/icons/iconsCurrency/Tether.svg"
      }
    ],
    name: "WEMIXtUSD",
    tvl: "100,000,000",
    info: {
      poll: '20xc3F...ED56',
      deals: "1257",
      ProfitLoss: "+ 78,000 tUSD"
    }
  }
]

const ItemDashboard = ({item}) => {
  const [ active, setActive ] = useState(false)
  return (
    <div onClick={() => setActive(!active)} className={styles.item}>
      <div className={styles.icons}>
        <div>
          <Image src={item.icons[0].icon} width={24} height={24} alt="icon" />
        </div>
        <div>
          <Image src={item.icons[1].icon} width={24} height={24} alt="icon" />
        </div>
      </div>
      <div className={styles.name}>{item.name}</div>
      <div className={styles.tvl}>TVL <span>{item.tvl}</span> USD</div>
    </div>
  )
}

const KeeperContent = () => {
 const [ active, setActive ] = useState(switchList[0])
 const [ name, setName ] = useState('')
 const [ address, setAddres ] = useState('')
 const [ currency, setCurrency ] = useState(currencys[0])
 const [ amount, setAmount ] = useState(10000)
 const [ activeAddress, setActiveAddress ] = useState(addresList[0])
 const [ activeExp, setActiveExp ] = useState(expList[0])

 return (
  <div className={styles.keeper}>
   <div className={styles.switchBtn}>
    {switchList.map(item => {
      return (
       <div
         onClick={() => setActive(item)}
         key={item.id}
         className={active?.id === item?.id ? styles.activeSwitch : styles.switchItem}>
         <span>{item.title}</span>
       </div>
      )
    })}
   </div>
   
   {
    active.id === 0 ?
    <>
    <div className={styles.label}>Underlying Asset Ticker</div>
      <Input value={name} setValue={setName} placeholder="Ticker" />

      <div className={styles.block}>
        <Input value={address} setValue={setAddres} placeholder="Oracle Address" select={true} />
        <Select arr={addresList} active={activeAddress} setActive={setActiveAddress} />
      </div>

      <div className={styles.block}>
        <span>Quote Asset</span>
        <Select arr={currencys} active={currency} setActive={setCurrency} />
      </div>
      
      <div className={styles.block}>
        <span>Duration of Deals</span>
        <Select arr={expList} active={activeExp} setActive={setActiveExp} />
      </div>

      <div className={styles.label}>AMM Pool amount</div>
      <Input title={currency.title} type="number" value={amount} setValue={setAmount} />

      <div className={styles.btn}>
        <Button
          title='Create Market'
          onClick={() => console.log('Create Market')
        }/>
    </div></> : 
    <div>
      {
        orders?.map(order => {
          return <ItemDashboard item={order} key={order.id} />
        })
      }
    </div>
   }
  </div>
 )
}

export default KeeperContent