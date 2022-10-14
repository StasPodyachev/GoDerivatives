import { useEffect } from "react";
import { useContractWrite, usePrepareContractWrite } from "wagmi";
import styles from "./Button.module.css";
import { BIG_1E18 } from "./misc";
import BigDecimal from "decimal.js-light";
import { useRouter } from "next/router";
interface ButtonModel {
  abi: any;
  title: string;
  token: string;
  makerPosition: boolean;
  rate: any;
  count: number;
  percent: number;
  expiration: number;
  slipagge: number;
}

const CreateDealBtn = ({
  title,
  token,
  abi,
  makerPosition,
  rate,
  count,
  percent,
  expiration,
  slipagge,
}: ButtonModel) => {

  const { push } = useRouter()

  const newCount =
    BigInt(new BigDecimal(count).mul(BIG_1E18 + "").toFixed(0)) + "";
  const newPercent =
    BigInt(new BigDecimal(percent).mul(BIG_1E18 + "").toFixed(0)) + "";
  const newSlapagge =
    BigInt(new BigDecimal(slipagge).mul(BIG_1E18 + "").toFixed(0)) + "";


  const { config } = usePrepareContractWrite({
    addressOrName: token,
    contractInterface: abi,
    functionName: "createDeal",
    args: [
      [makerPosition, rate, newCount, newPercent, expiration, newSlapagge],
    ],
    onError(error) {
      console.log("Error", error);
    },
  });

  const { write: create, isLoading, isSuccess } = useContractWrite(config);
  // return <></>;
  if (isSuccess) {
    push('/dashboard')
  }
  return (
    <div onClick={() => {
      create?.()
    }} className={styles.btn}>
      {title}
    </div>
  );
};

export default CreateDealBtn;
