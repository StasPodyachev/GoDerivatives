import Image from 'next/image'
import styles from './Input.module.css'
interface InputModel {
  func?: any
  value: number
  icon: string
  setValue: (num: number) => void
  titleSmall?: string
  iconsSecond?: string
  title?: string
  disabled?: boolean 
}

const Input = ({func, value, setValue, icon, titleSmall, iconsSecond, title, disabled } : InputModel) => {
  const changeValue = (event: React.ChangeEvent<HTMLInputElement>) => {
    setValue(+event?.target?.value);
    func && func(+event?.target?.value)
  };
  
  return (
    <div className={styles.input}>
      <span className={styles.titleSmall}>{titleSmall}</span>
      <div className={styles.icon}>
       <Image
        alt="currency"
        src={icon}
        width={28} height={28}/>
        {
          iconsSecond ? 
          <div className={styles.iconsSecond}>
            <Image
              alt="currency"
              src={iconsSecond}
              width={12} height={12}/> 
          </div>
          : null
        }
      </div>
      <input style={!disabled ? {"color" : "#fff"} : {"color" : "#A6A0BB !important"}} value={value} disabled={disabled} type="number" onChange={changeValue} />
      {
        title ? <span className={styles.title}>{title}</span> : null
      }
    </div>
  )
}
export default Input