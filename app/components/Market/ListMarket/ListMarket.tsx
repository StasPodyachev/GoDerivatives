
import ItemMarket from '../ItemMarket/ItemMarket'
import styles from './ListMarket.module.css'
import { markets } from '../../../data/markets'

const ListMarket = ({coin} : any) => {
  return (
    <div className={styles.listMarket}>
      {
        markets?.map(item => {
          return (
            <div key={item?.id}>
              <ItemMarket coin={coin} order={item} />
            </div>
          )
        })
      }
    </div>
  )
}

export default ListMarket