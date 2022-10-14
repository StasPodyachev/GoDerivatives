import styles from './Tab.module.css'
const Tab = ({tab, checked, setChecket} :
  {tab: {id: number, title: string, disabled: boolean}, checked : boolean, setChecket: () => void}) => {
  return (
    !tab?.disabled ?
    <div onClick={() => setChecket()} className={checked ? styles.activeTab : styles.tab}>
      <span>{tab?.title}</span>
    </div> :
    <div className={styles.disbled}>
      <span>{tab?.title}</span>
    </div>
  )
}

export default Tab