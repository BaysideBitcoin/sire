![sire logo](./app/images/sire2.png)
# sire
#### Description
sire is a currency that is designed to work for you. sires value is designed to increase or decrease along side Ethereum. sire provides users a steady investment vehicle with immediate returns.

Any Ether contributed to the sire contract will become **locked** in the contract. Ether sent in exchange for Sire is permanently locked within the contract. Giving both Sire and its child currency relic value.
A maximum amount of 10,000,000 sire can possibly exist, users can burn sire which increases the value of sire overtime as the amount distributed will diminish overtime.
You can create "Mint's" that essentially lock a given amount of sire at a specific mint rate. Based on the amount of time you hold the Mint, the more relic you are rewarded.

The rate at which relics are given per sire deflates yearly at a rate of *15%*. Whenever a Mint is created, the rate at which it generates relics is locked at that time and is not affected by deflations. If the Mint is collected and the locked sire becomes used for a new Mint then the new deflated rate will be set with the new Mint.

sire can also be burned, giving users an immediate boost of relics equivalent too ~50% of 1 years worth of Minted relics.
A user burning 1 sire will be rewarded for half a years worth of blocks of relics for that one sire, destroying it in the process.

## About
##### relic Minting
```
1 sire
_______ = (1 * 1427) / 100000000 = 0.00001427 relic
1 Block
```
**1 sire** with a **1 Block** change will yield a reward of **0.00001427 relic**. 

If you had 1 sire, each day **(~5000 Blocks)**, it would generate initially: **0.07135 relic** per day.
If you had 10 sire in the above scenario you would have 10 * 0.07135 = .7135 relic per day generation.

```
100 sire
_________ = ((10*100) * 1427) / 100000000 = 0.01427 relic
10 Blocks
```
If you own **100 sire** and wait about **10 blocks** ~2 Minutes, then you will mint **0.01427 relic**

##### Rates and Details
- Max Ether = 100,000 Ether
- Max sire = 10,000,000 sire
- Relic Rate = 0.00001427 (Deflates by 15% yearly)
- Logo:

 sire ![sire logo](./app/images/sire2.png)
   relic
 ![relic logo](./app/images/relic2.png)

##### Exchange Rate
 The sire to Ether exchange rate is hardcoded at 100 sire to 1 Ether
```
1 Ether * 100 = 100 sire
```

## Getting Started

To get started with sire check-out the official getting-started guide: https://sireli.cc/get-started

In short, sire can be acquired by sending ether to the sire contract's address located at:
https://sireli.cc/address
The exchange rate for Ether to sire is: **1 Ether** to **100 sire**. 

sire has a maximum cap of Ether that can be contributed to only once.

If no sire is available via the contract it can be acquired via a currency Exchange.
Looking to get added too:
- https://Shapeshift.io/
- https://poloniex.com/
- https://bittrex.com/

In order to interact with the Sire contract you will need a wallet like the following:
- Metamask Extension - Chrome, Firefox -  https://metamask.io/
- Mist - Windows, Mac, Linux - https://github.com/ethereum/mist/

## Built With
* [Truffle](http://truffleframework.com/) - Smart Contract Development Framework
* [Open Zeppelin](https://github.com/OpenZeppelin/zeppelin-solidity) - SafeMath Libraries
* [testrpc](https://github.com/ethereumjs/testrpc) - Local test chain used
* [ERC20 EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
* [Ropsten Network](https://github.com/ethereum/ropsten) - Global test chain used
* [MetaMask](https://metamask.io/) - Test wallet used
* [NPM](https://www.npmjs.com/) - Web-App


## Authors

* **Justin Chase** - *Ideas + Contract Implementation + Web-app* - [Justin Chase](https://github.com/jujum4n)
* **Ben Christensen** - *Contract Auditing* - [Ben Christensen]()
## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
* Inspiration
* Water
* Coffee

I would like to take the opportunity to thank the standard: friends and family. Also much inspiration to many people in the crypto/cypherpunk community. Thanks to all the giants in the community: Wei Dai, Satoshi, Adam Back, Vitalik Buterin, Hal Finney. Huge thanks to the community and those working on creating standards for Ethereum Contracts. Thanks Truffle Framework for providing great tools! Thanks to Ben Christensen who helped audit the contract code and work on several aspects of the design of sire and its larger ecosystem. Thank-you to Reid Brown who helped proofread and help clarify several confusing portions of the sire verbage.

