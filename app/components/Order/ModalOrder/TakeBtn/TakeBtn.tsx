import { useEffect } from 'react'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import styles from './Button.module.css'
import { BIG_1E18, BIG_1E20 } from './misc'
import BigDecimal from 'decimal.js-light'
interface ButtonModel {
  abi: any
  title: string
  token: string
  dealId: any
  rateTaker: any
  slippageTaker: any
}

const TakeBtn =  ({title, token, abi, dealId, rateTaker, slippageTaker} : ButtonModel ) => {
  
  const { config } = usePrepareContractWrite({
    addressOrName: token,
    contractInterface: abi,
    functionName: 'takeDeal',
    args: [dealId, rateTaker, slippageTaker],
    onError(error) {
      console.log('Error', error)
    },
  })  
  const { write: create, isLoading, isSuccess } = useContractWrite(config)

  return (
    <div onClick={() => create?.()} className={styles.btn }>
      {title}
    </div>
  )
}

export default TakeBtn