import { useRouter } from "next/router";
import { useEffect, useState } from "react";
import Button from "../ui/Button";
import Input from "./Input";
import Tab from "../ui/Tab";
import styles from "./DealContent.module.css";
import { markets } from "../../data/markets";
import Select from "./Select";
import Image from "next/image";
import addresses from "../../contracts/addresses";
import ORACLE_ABI from "../../contracts/abi/Oracle.json";
import ERC20_ABI from "../../contracts/abi/ERC20.json";
import MARKET_ABI from "../../contracts/abi/Market.json";
import { useAccount, useContractRead } from "wagmi";
import ApproveButton from "../ui/ApproveButton";
import { useIsMounted } from "../../hooks/useIsMounted";
import BigDecimal from "decimal.js-light";
import CreateDealBtn from "./CreateDealBtn";
const switchList = [
  {
    id: 0,
    title: "Long",
  },
  {
    id: 1,
    title: "Short",
  },
];
const tabs = [
  {
    id: 0,
    title: "5%",
    disabled: false,
    value: 5,
  },
  {
    id: 1,
    title: "7%",
    disabled: false,
    value: 7,
  },
  {
    id: 2,
    title: "10%",
    disabled: false,
    value: 10,
  },
  {
    id: 3,
    title: "12%",
    disabled: false,
    value: 12,
  },
  {
    id: 4,
    title: "15%",
    disabled: false,
    value: 15,
  },
];
const slippageList = [
  {
    id: 0,
    title: "0,5%",
    value: 0.5,
  },
  {
    id: 1,
    title: "1%",
    value: 1,
  },
  {
    id: 2,
    title: "1,5%",
    value: 1.5,
  },
  {
    id: 3,
    title: "2%",
    value: 2,
  },
];
const expList = [
  {
    id: 0,
    title: "3 days",
    value: 3,
  },
  {
    id: 1,
    title: "10 days",
    value: 10,
  },
  {
    id: 2,
    title: "15 days",
    value: 15,
  },
  {
    id: 3,
    title: "30 days",
    value: 30,
  },
];

const DealContent = ({ coin, price, rate }: any) => {
  const [active, setActive] = useState(switchList[0]);
  const [activeMarket, setActiveMarket] = useState(markets[0]);
  const [checked, setChecket] = useState(tabs[2]);
  const [valueUnit, setValueUnit] = useState(1);
  // const [price, setPrice] = useState(1.61);
  const [positionValue, setPositionValue] = useState(price);
  const [amount, setAmount] = useState(positionValue * (checked?.value / 100));
  const [activeSlippage, setActiveSlippage] = useState(slippageList[0]);
  const [activeExp, setActiveExp] = useState(expList[0]);
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [percent, setPercent] = useState(checked.value / 100);

  const [maxProfitPrice, setMaxProfitPrice] = useState(price * (1 + percent));
  const [maxProfit, setMaxProfit] = useState(positionValue * percent);

  const [maxLossPrice, setMaxLossPrice] = useState(price * (1 - percent));
  const [maxLoss, setMaxLoss] = useState(positionValue * percent);
  const [approveStatus, setApproveStatus] = useState(false);
  const { push, query } = useRouter();
  const isMounted = useIsMounted();
  const { address } = useAccount();

  const { data: allowance } = useContractRead({
    addressOrName: addresses?.tUSD?.address,
    contractInterface: ERC20_ABI,
    functionName: "allowance",
    args: [address, addresses?.deposit?.address],
  });

  const changeAmount = (amount) => {
    setValueUnit(amount / percent / price);
    setPositionValue(amount / percent);
  };

  const changeUnit = (valueUnit) => {
    setPositionValue(price * valueUnit);
    setAmount(+(price * valueUnit * percent).toFixed(2));
  };

  useEffect(() => {
    if (allowance) {
      const status = allowance._hex !== "0x00" ? true : false;
      setApproveStatus(status);
    }
  }, [allowance]);

  useEffect(() => {
    if (query?.orderName) {
      setActiveMarket(
        markets?.find((item) => item.currencyName === query?.orderName)
      );
    }
  }, [query]);

  useEffect(() => {
    setPercent(checked?.value / 100);
  }, [checked]);

  useEffect(() => {
    setAmount(+(price * valueUnit * percent).toFixed(2));
  }, [percent]);

  useEffect(() => {
    setMaxProfitPrice(+(price * (1 + percent)).toFixed(2));
    setMaxLossPrice(+(price * (1 - percent)).toFixed(2));
  }, [percent, price]);

  useEffect(() => {
    setMaxProfit(+(positionValue * percent).toFixed(2));
    setMaxLoss(+(positionValue * percent).toFixed(2));
  }, [positionValue, percent]);

  if (!isMounted) return;

  return (
    <div className={styles.deal}>
      <div className={styles.switchBtn}>
        {switchList.map((item) => {
          return (
            <div
              onClick={() => setActive(item)}
              key={item.id}
              className={
                active?.id === item?.id
                  ? styles.activeSwitch
                  : styles.switchItem
              }
            >
              <span>{item.title}</span>
            </div>
          );
        })}
      </div>

      <div className={styles.token}>
        <div className={styles.icon}>
          <Image
            alt="currency"
            src={activeMarket.icon}
            width={70}
            height={70}
          />
          <div className={styles.iconsSecond}>
            <Image
              alt="currency"
              src="/icons/iconsCurrency/Tether.svg"
              width={24}
              height={24}
            />
          </div>
        </div>

        <div className={styles.option}>
          <span>{activeMarket.currencyName}</span>
          <p>
            <span>{price.toFixed(2)}</span>
            <span style={{ color: "#6FCF97" }}>+0,75 (+1%)</span>
          </p>
          <span>in USDT</span>
        </div>
      </div>

      <div className={styles.tabs}>
        {tabs?.map((tab) => {
          return (
            <Tab
              setChecket={() => setChecket(tab)}
              key={tab?.id}
              tab={tab}
              checked={checked?.id === tab?.id}
            />
          );
        })}
      </div>

      <Input
        func={(value) => changeAmount(value)}
        value={amount}
        setValue={setAmount}
        title="amount USDT"
        icon="/icons/iconsCurrency/Tether.svg"
      />
      <Input
        func={(value) => changeUnit(value)}
        value={+valueUnit.toFixed(2)}
        setValue={setValueUnit}
        title={`unit ${activeMarket?.currencyName.toUpperCase()}`}
        icon={activeMarket?.icon}
      />
      <Input
        disabled={true}
        value={+positionValue.toFixed(2)}
        setValue={setPositionValue}
        title="position USDT"
        icon="/icons/iconsCurrency/Tether.svg"
      />

      <div className={styles.select}>
        <span style={{ color: "#A6A0BB" }}>Slippage</span>
        <Select
          arr={slippageList}
          active={activeSlippage}
          setActive={setActiveSlippage}
        />
      </div>
      <div className={styles.select}>
        <span style={{ color: "#A6A0BB" }}>Order Expiration</span>
        <Select arr={expList} active={activeExp} setActive={setActiveExp} />
      </div>
      <div
        onClick={() => setShowAdvanced(!showAdvanced)}
        className={styles.advanced}
      >
        <span>Advanced</span>
        <div className={showAdvanced ? styles.settingsActive : styles.settings}>
          <Image
            src="/icons/orderIcon/settings.svg"
            width={24}
            height={24}
            alt="settings"
          />
        </div>
      </div>

      {showAdvanced ? (
        <>
          <div className={styles.chart}>
            <Image
              src="/images/chart1.svg"
              layout="responsive"
              width={329}
              height={175}
              alt="chart"
            />
          </div>

          <div className={styles.advBlock}>
            <div className={styles.icons}>
              <div>
                <Image
                  src={activeMarket.icon}
                  width={28}
                  height={28}
                  alt="currency"
                />
              </div>
              <div>
                <Image
                  src="/icons/iconsCurrency/Tether.svg"
                  width={24}
                  height={24}
                  alt="currency"
                />
              </div>
            </div>
            <div style={{ color: "#9DE7BD" }} className={styles.advTitle}>
              {maxProfitPrice}
            </div>
            <div className={styles.advOption}>
              <span>max Profit price</span>
              <span style={{ color: "#9DE7BD" }}>
                +{checked.value.toFixed(2)}%, {maxProfit} USDT
              </span>
            </div>
          </div>

          <div className={styles.advBlock}>
            <div className={styles.icons}>
              <div>
                <Image
                  src={activeMarket.icon}
                  width={28}
                  height={28}
                  alt="currency"
                />
              </div>
              <div>
                <Image
                  src="/icons/iconsCurrency/Tether.svg"
                  width={24}
                  height={24}
                  alt="currency"
                />
              </div>
            </div>
            <div style={{ color: "#FF4E69" }} className={styles.advTitle}>
              {maxLossPrice}
            </div>
            <div className={styles.advOption}>
              <span>max Loss price</span>
              <span style={{ color: "#FF4E69" }}>
                -{checked.value.toFixed(2)}%, -{maxLoss} USDT
              </span>
            </div>
          </div>

          <div className={styles.chart}>
            <Image
              src="/images/chart2.svg"
              layout="responsive"
              width={329}
              height={225}
              alt="chart"
            />
          </div>
        </>
      ) : null}
      <div className={styles.payment}>
        Payment with Slippage{" "}
        <span>
          {(amount * (1 + activeSlippage.value / 100)).toFixed(2)} tUSD
        </span>
      </div>

      {approveStatus &&
      rate &&
      valueUnit &&
      percent &&
      activeExp &&
      activeSlippage ? (
        <div className={styles.btn}>
          <CreateDealBtn
            title={`Create ${active.title} Order`}
            token={addresses?.market?.address}
            abi={MARKET_ABI}
            makerPosition={active.id === 1}
            rate={rate}
            count={valueUnit}
            percent={percent}
            expiration={30000}
            slipagge={activeSlippage.value}
          />
        </div>
      ) : isMounted ? (
        <div className={styles.btn}>
          <ApproveButton
            title="Approve Contract"
            onClick={(status) => setApproveStatus(status)}
            tokenAddres={addresses?.deposit?.address}
            approveToken={addresses?.tUSD?.address}
            abi={ERC20_ABI}
          />
        </div>
      ) : null}
    </div>
  );
};

export default DealContent;
