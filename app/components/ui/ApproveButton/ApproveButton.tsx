import { ethers } from 'ethers'
import { useEffect } from 'react'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import styles from './Button.module.css'

const ApproveButton = 
  ({title, onClick, tokenAddres, abi, approveToken} : {approveToken: string, abi: any, title: string, onClick : (status: boolean) => void, tokenAddres: string} ) => {

  const { config } = usePrepareContractWrite({
    addressOrName: approveToken,
    contractInterface: abi,
    functionName: 'approve',
    args: [tokenAddres, ethers?.constants?.MaxUint256],
    onError(error) {
      console.log('Error', error)
    },
  })
  const { write: approve, isSuccess } = useContractWrite(config)
  
  useEffect(() => {
    onClick(isSuccess)
  }, [isSuccess, onClick])

  return (
    <div onClick={() => approve?.()} className={styles.btn } >
      {title}
    </div>
  )
}

export default ApproveButton