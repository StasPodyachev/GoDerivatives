# GoDerivatives

This repository contains smart contracts and developer tools for GoDerivatives which powers https://goderivatives.vercel.app/

## What is GoDerivatives?

GoDerivatives is a platform where anyone can trade leveraged derivatives (contracts) on items from the real world or the metaverse.

The main idea of the project is to create a platform where everyone can create any derivative for any physical or virtual asset. According to Investopedia, The term derivative refers to a type of financial contract whose value is dependent on an underlying asset, group of assets, or benchmark. A derivative is set between two or more parties that can trade on an exchange or over-the-counter (OTC). These contracts can be used to trade any number of assets and carry their own risks. Prices for derivatives derive from fluctuations in the underlying asset. These financial securities are commonly used to access certain markets and may be traded to hedge against risk. Derivatives can be used to either mitigate risk (hedging) or assume risk with the expectation of commensurate reward (speculation). Derivatives can move risk (and the accompanying rewards) from the risk-averse to the risk seekers.

Why is it so important to have such a tool here in blockchain space? Traditional markets and exchanges have two main restrictions: they let their users only trade traditional or permitted assets. And from the other hand, there is a huge inequality, even a discrimination, in access to financial service providers. Let’s start from in-game assets. According to Coinmarketcap, top play-to-earn projects have capitalization of more than $5.7 bln. So the new economy is born and it needs more sophisticated tools to hedge against risks and develop itself giving more and more opportunities to users.

We consider Hackathon as a laboratory where we can work on the future problems and create new niches, which will address community development challenges and create added value. Why we choose Klaytn? Because we see a huge potential in technology behind it, a strong and diverse community and a brave vector to Metaverse. Watch for more info https://youtu.be/1xDpckh_5ac

## Documentation

#### Whitepaper: in progress

For more comprehensive information about GoDerivatives you can read our whitepaper and project description on our [Notion Documentation](https://husky-breath-587.notion.site/GoDerivatives-Klaytn-Hackathon-0cd736e825d14df3ab060a3742ed21c1).

#### Technical Documentation

Check our full Documentation [here](https://husky-breath-587.notion.site/GoDerivatives-Klaytn-Hackathon-0cd736e825d14df3ab060a3742ed21c1) for more technical details.

## Smart contracts

Copy .env.example to .env and define all variables.

`yarn`

or

`npm install`

### Deploy & configure

```
yarn compile
npx hardhat run scripts/deploy/deploy-all.ts --network <network>
npx hardhat run scripts/configure/configure-all.ts --network <network>
```

**network** - the following networks are supported in this code: `baobab`


## Subgraph

`yarn`

or

`npm install`

### Deploy

```
yarn codegen:<network>
yarn deploy:<network>
```

**network** - the following networks are supported in this code: `baobab`

## Frontend

`yarn start`
or
`npm run start`

## Testing

```
npx hardhat tests
```

## Contracts

You can find current contract addresses at deployments.json file.

## Security

#### Independent Audits

All production smart contracts will be going through independent audit.

#### Code Coverage

in progress

## Community.

Join our community at [Twitter](https://twitter.com/StanislavPodya3)

Join our community at [Facebook](https://www.facebook.com/profile.php?id=100086849285426)

## Licensing

...

### Other Exceptions