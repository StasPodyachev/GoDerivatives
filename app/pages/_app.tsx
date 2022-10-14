import '../styles/globals.css';
import type { AppProps } from 'next/app';
import { ApolloProvider } from '@apollo/client'
import { useApollo } from '../apolloClient'
import { WagmiConfig, createClient,  chain, Chain, configureChains } from "wagmi";
import { ConnectKitProvider, getDefaultClient } from "connectkit";

import { CoinbaseWalletConnector } from 'wagmi/connectors/coinbaseWallet'
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect'

import { alchemyProvider } from "wagmi/providers/alchemy";
import { jsonRpcProvider } from "wagmi/providers/jsonRpc";
import useWindowSize from '../hooks/useWindowSize';

  const KlaytnBaobab: Chain = {
    id: 1001,
    name: 'Klaytn Baobab',
    network: 'Klaytn Baobab',
    nativeCurrency: {
      decimals: 18,
      name: 'Klay',
      symbol: 'KLAY',
    },
    rpcUrls: {
      default: 'https://api.baobab.klaytn.net:8651',
    },
    blockExplorers: {
      default: { name: 'Klaytn', url: 'https://baobab.scope.klaytn.com/' },
    },
    testnet: true
  }
  const { chains, provider } = configureChains(
    [KlaytnBaobab],
    [
      alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_REACT_APP_ALCHEMY_KEY }),
      jsonRpcProvider({
        rpc: (chain) => {
          if (chain.id !== KlaytnBaobab.id) return null;
          return { http: chain.rpcUrls.default };
        },
      }),
    ],
  )
  const connectors = 
    [
      new CoinbaseWalletConnector({
        chains,
        options: {
          appName: 'Go-Derivatives',
        },
      }),
      new WalletConnectConnector({
        chains,
        options: {
          qrcode: true,
        },
      })
  ]
  const clientM = createClient({
    autoConnect: true,
    connectors: connectors,
    provider: provider,
  });

  const clientD = createClient(
    getDefaultClient({
      appName: 'Defx',
      autoConnect: true,
      infuraId: process.env.NEXT_PUBLIC_REACT_APP_INFURA_KEY,
      alchemyId: process.env.NEXT_PUBLIC_REACT_APP_ALCHEMY_KEY,
      chains: [ KlaytnBaobab ]
    }),
  );

function MyApp({ Component, pageProps }: AppProps) {
  const { width } = useWindowSize()
  const apolloClient = useApollo(pageProps)
  return (
    <WagmiConfig client={width > 520 ? clientD : clientM}>
      <ConnectKitProvider 
        customTheme={{
          "--ck-font-family": "'Source Code Pro','Poppins', 'sans-serif', 'monospace'"
        }}
      theme="midnight">
        <ApolloProvider client={apolloClient}>
          <Component {...pageProps} />
        </ApolloProvider>
      </ConnectKitProvider>
    </WagmiConfig>
  );
}

export default MyApp;