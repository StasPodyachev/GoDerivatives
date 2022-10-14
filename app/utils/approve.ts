import { ethers } from "ethers";

export const approve  = async (contractAprove, spender : any) => {
  await contractAprove?.approve(spender, ethers?.constants?.MaxUint256).then((res) => {
    return res
  })
}

export const allowance  = async (contractAprove, addressWallet, contract : any) => {
  return await contractAprove?.allowance(contract, addressWallet).then((res) => {
    return res._hex !== "0x00" ? true : false
  })
}