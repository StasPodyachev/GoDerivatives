import Image from "next/image"
import { useAccount, useContract, useContractRead, useSigner } from "wagmi"
import addresses from "../../../contracts/addresses"
import Button from "../../ui/Button"
import Coin from "../../ui/Coin"
import Modal from "../../ui/Modal"
import styles from './ModalOrder.module.css'
import ERC20_ABI from '../../../contracts/abi/ERC20.json'
import MARKET_ABI from '../../../contracts/abi/Market.json'
import { useEffect, useState } from "react"
import ApproveButton from "../../ui/ApproveButton"
import { useIsMounted } from "../../../hooks/useIsMounted"
import TakeBtn from "./TakeBtn"
interface OrderDetailsModel {
  type: string
  price: string
  rounded: string,
  leverageRate: string
}
interface ContractsModel {
  id: string
  rate: string
  available: number
  leverage: number
  date: string
}

const Contract = ({contract, leverageRate, type, coin, approveStatus, setApproveStatus} : {contract : ContractsModel, leverageRate: string, type: string, coin: any, approveStatus: boolean, setApproveStatus: (status: boolean) => void }) => {
  const isMounted  = useIsMounted()
  return (
    <div className={styles.contract}>
      <div className={styles.contractHeader}>
        <div className={styles.id}>Contract #{contract?.id}</div>
        <div className={styles.expires}><span>Expires at</span><span>{contract?.date}</span></div>
      </div>
      <div className={styles.contractBody}>
        <div className={type === "buy" ? styles.contractRateBuy : styles.contractRateSell }>
          <span>Rate</span>
          <div><Coin coin={coin}/></div>
        </div>
        <div className={type === "buy" ? styles.contractAvailableBuy : styles.contractAvailableSell }>
          <span>Available</span>
          <div>{contract.available}</div>
        </div>
        <div className={type === "buy" ? styles.contractLeverageBuy : styles.contractLeverageSell }>
          <span>Leverage</span>
          <div><p>{leverageRate}</p>{contract?.leverage}</div>
        </div>
      </div>
      <div className={styles.btn}>
        {
          approveStatus ?
          <TakeBtn title={type === "buy" ? "Take as Short" : "Take as Long"}
            token={addresses?.market?.address}
            abi={MARKET_ABI}
            dealId={4}
            rateTaker='1825000000000000000'
            slippageTaker='20000000000000000'
            />
          // <Button onClick={() => console.log(type)} />
          :
          <ApproveButton title="Approve Contract"
            onClick={(status) => setApproveStatus(status)}
            tokenAddres={addresses?.deposit?.address}
            approveToken={addresses?.tUSD?.address}
            abi={ERC20_ABI}
          />
        }
      </div>
    </div>
  )
}

const ModalOrder = ({contracts, orderDetails, show, close, coin}
    : {contracts: ContractsModel[], orderDetails: OrderDetailsModel, show: boolean, close: () => void, coin : any }) => {

  const [ approveStatus, setApproveStatus ] = useState(false)
  const { address } = useAccount()
  const { data: allowance } = useContractRead({
    addressOrName: addresses.tUSD.address,
    contractInterface: ERC20_ABI,
    functionName: 'allowance',
    args: [address, addresses?.deposit?.address]
  })

  const { data: signer } = useSigner()

  // const contractTake = useContract({
  //   address: ,
  //   abi: MARKET_ABI,
  //   signerOrProvider: signer,
  // })

  useEffect(() => {
    if (allowance) {
      const status = allowance._hex !== "0x00" ? true : false
      setApproveStatus(status)
    }
  }, [allowance])

  return (
    <Modal isShow={show}>
      <div className={styles.header}>
        <div onClick={() => close()} className={styles.arrow}>
          <Image src="/icons/orderIcon/arrow.svg" width={28} height={28} alt="close"/>
        </div>
        <div className={styles.title}>
          <span>Price</span>
          <p className={orderDetails?.type === "buy" ? styles.priceBuy : styles.priceSell }><Coin coin={coin}/></p>
          <div className={styles.rounded}>rounded {orderDetails?.rounded}</div>
        </div>
        <div onClick={() => close()} className={styles.close}>
          <Image src="/icons/orderIcon/close.svg" width={28} height={28} alt="close"/>
        </div>
      </div>
      {contracts?.map(contract =>
        <Contract approveStatus={approveStatus} setApproveStatus={setApproveStatus} coin={coin} type={orderDetails?.type} leverageRate={orderDetails?.leverageRate} contract={contract} key={contract?.id} />)}
    </Modal>
  )
}

export default ModalOrder