import styles from './Layout.module.css'
import React, { ReactNode } from "react";
import Header from '../Header';

const Layout = ({children, title} : {children : ReactNode, title: string}) => {
 return (
  <div className={styles.layout}>
   <Header title={title} />
   {children}
  </div>
 )
}

export default Layout