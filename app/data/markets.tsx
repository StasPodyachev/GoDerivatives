export interface MarketsModel {
 id: number
 currencyName: string
 derevativeName: string
 price: number
 icon: string
 description: string
 duration: string
 leverage: string
 currency: string
 orderLink: string
 percent: string
}

export const markets = [
{
  id: 2,
  currencyName: 'WEMIX',
  derevativeName: 'WEMIXtUSD',
  price: 1643.60,
  icon: '/icons/iconsCurrency/wemix.svg',
  description: 'Get profit from WEMIX price volatility with leverage.',
  duration: 'Duration 1 day - 30 days ',
  leverage: 'Leverage x2 - x30',
  currency: 'Currency USD, EUR',
  orderLink: '/WEMIX',
  percent: '0.34 (0.10%)'
  },
 {
  id: 1,
  currencyName: 'ETH',
  derevativeName: 'ETHtUSD',
  price: 1643.60,
  icon: '/icons/iconsCurrency/EthereumETH.svg',
  description: 'Get profit from ETH price volatility with leverage.',
  duration: 'Duration 1 day - 30 days ',
  leverage: 'Leverage x2 - x30',
  currency: 'Currency USD, EUR',
  orderLink: '/ETH',
  percent: '0.34 (0.10%)'
 },
 {
  id: 3,
  currencyName: 'WTI',
  derevativeName: 'WTItUSD',
  price: 1643.60,
  icon: '/icons/iconsCurrency/wti.svg',
  description: 'Get profit from WTI price volatility with leverage.',
  duration: 'Duration 1 day - 30 days ',
  leverage: 'Leverage x2 - x30',
  currency: 'Currency USD, EUR',
  orderLink: '/WTI',
  percent: '0.34 (0.10%)'
  },
]