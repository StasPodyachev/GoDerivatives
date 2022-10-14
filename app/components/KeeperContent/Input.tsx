import styles from './KeeperContent.module.css'

const Input = ({value, setValue, placeholder, type, title, select} :
 {
  title?: string,
  value: any,
  setValue: (val: any) => void,
  placeholder?: string,
  select?: boolean,
  type?: string}) => {
 const changeValue = (event: React.ChangeEvent<HTMLInputElement>) => {
  setValue(event?.target?.value);
 };
 return (
  <div className={styles.input} style={select ? {"padding" : "0"} : {"padding" : "16px"}}>
    {
      !type ?
      <input
        type={type ? type : 'text'}
        placeholder={placeholder}
        value={value}
        onChange={changeValue}/> :
      <input
        min={10000}
        style={{"fontWeight" : "700", "fontSize" : "18px", "color" : "#fff"}}
        type={type ? type : 'text'}
        placeholder={placeholder}
        value={value}
        onChange={changeValue}/>
    }
    <span>{title}</span>
  </div>
 )
}

export default Input