import { useEffect, useState } from 'react';
import { useContractRead } from 'wagmi';
import DealContent from '../../components/DealContent'
import Layout from '../../components/Layouts/Layout'
import addresses from '../../contracts/addresses';
import ORACLE_ABI from "../../contracts/abi/Oracle.json";
import BigDecimal from "decimal.js-light";

export default function Deal({coin} : any) {

  const [ price, setPrice ] = useState(0);
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
    <Layout title="Create Deal">
      {
        price ? <DealContent price={price} rate={rate?.amount} coin={coin} /> : null
      }
    </Layout>
  )
}

export const getServerSideProps = async () => {
  // const res = await fetch(`https://api.coingecko.com/api/v3/coins/ethereum`);
  // const data = await res.json();
  // const price = data?.market_data?.current_price?.usd
  // const percentChange = data?.market_data.price_change_24h_in_currency.usd.toFixed(2)
  // const priceChange = data?.market_data.price_change_percentage_24h_in_currency.usd.toFixed(2)
  const price = 1299.47
  const percentChange = 16.62
  const priceChange = 1.30
  return {
      props: {
        coin: {
          price,
          priceChange,
          percentChange
        }
      }
  };
}