import Image from "next/image"
import { useState } from "react"
import styles from './Input.module.css'

const Select = ({arr, active, setActive} : any) => {
 const [ show, setShow ] = useState(false)
 return (
  <div className={styles.select}>
   <div className={styles.active} onClick={() => setShow(!show)}>
    <span>{active.title}</span>
    <div className={styles.arrow}
     style={!show ? {"transform": "rotate(-90deg)"}:{"transform": "rotate(90deg)"}}>
      <Image
       src='/icons/orderIcon/arrow.svg'
       width={24} height={24} alt="arrow" />
    </div>
   </div>
   {show ?
    <div className={styles.selectList}>
     {
       arr?.map(item => {
        return <div onClick={() => {
         setActive(item)
         setShow(false)
        }} key={item?.id}>
          <span>{item?.title}</span>
         </div>
       })
     }
    </div>
   : null}
  </div>
 )
}

export default Select