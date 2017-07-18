# Sire
#### Description
Sire is a currency that is designed to work for you. Sires value is designed to increase or decrease along side Ethereum. Sire provides users a steady investment vehicle with immediate returns.

Any Ether contributed to the Sire contract will become **locked** in the contract. Ether sent in exchange for Sire is permanently locked within the contract. Giving both Sire and its child currency relic value.

For each sire you own, you are entitled to "mint" a value of new relic per ethereum block. The value of relic rewarded deflates at a yearly rate **~4%**. relic can be minted at any date, as long as a user has sire. Once a user acquires sire, a user should mint relic immediately to establish a Last relic mint reward height. As the network progresses forward at anytime you can mint relic. Your relic mint value is equal to the: **(((relic_reward_rate * sire_owned) * blocks_elapsed_since_last_mint) / 100000)**.

A minting strategy that is optimal for Ether preservation would be to mint relic once you receive any new sire. Then wait until the day before the next difficulty increase and mint all the relic your entitled to between your inital mint and before the reward deflates.

##### sire website alpha

![Alt text](./docs/sire_alpha.png?raw=true "sire website alpha")

## About
##### relic Minting
```
1 sire
_______ = (1 * 1667) / 1000000 = 0.01667 relic
1 Block
```
**1 sire** with a **1 Block** change will yield a reward of **0.01667 relic**. 

If you had 1 sire, each day **(~6000 Blocks)**, it would generate initially: **100.02 relic** per day.
If you have more sire, it will multiply the amount of relic returned per block based on each sire owned. 


```
100 sire
_________ = ((10*100) * 1667) / 1000000 = 16.67 relic
10 Blocks
```
If you own **100 sire** and wait about **10 blocks** ~2 Minutes, then you will mint **16.67 relic**

##### Max Ether Cap and 
Approximately every **2,190,000 Blocks** (1 Year) the cap for ether accepted will increase by **1%**. Initially the contract starts out with a maxEther balance possible of **33,333 Ether**. Each year this will grow by itself **1%**.
 ```
 (33333 * 101) / 100 = 33666 maxEther
 ```
##### Exchange Rate
 After each maxEther increase, the exchange rate for Ether to sire is also affected
```
(1000 * 75) / 100 = 750 sire
```
During year two it would deflate from **1000 sire**, down **25%** to **750 sire**.

##### relic Reward Adjustments
The amount of relic rewarded per sire deflates at a yearly rate of **4%**:
 ```
 current_relic_reward = current_relic_reward * .96
```
Initially the relic reward starts at **0.01667 relic** per sire per block. After ~1 Year of blocks have elapsed, the reward will retarget to.

```
(1667 * 96) / 100 = 0.0160032 relic per sire per block
(1600.32 * 96) / 100 = 0.015363072 relic per sire per block
```

## Getting Started

To get started with sire check-out the official guide: https://sireli.cc/get-started

In short, Sire can be acquired by sending ether to the sire contract's address located at:
https://sireli.cc/address
The exchange rate for Ether to sire is: **1 Ether** to **1000 sire**. This rate deflates yearly by **25%** as the maxEther Cap grows by **1%**.

sire has a maximum cap of Ether that can be contributed yearly. If this cap has been filled then it will not be possible to acquire Sire by sending Ether to the contract.

If no sire is available via the contract it can be acquired via a currency Exchange.
Looking to get added too:
- https://Shapeshift.io/
- https://poloniex.com/
- https://bittrex.com/

In order to interact with the Sire contract you will need a wallet like the following:
- Metamask Extension - Chrome, Firefox -  https://metamask.io/
- Mist - Windows, Mac, Linux - https://github.com/ethereum/mist/
## Development
### Setup

```
git clone
npm install -g ethereumjs-testrpc
npm install -g truffle
```
### Deployment

```
testrpc
truffle migrate
```

### Running Automated tests

```
git clone 
testrpc
truffle test
```


## Built With
* [Truffle](http://truffleframework.com/) - Smart Contract Development Framework
* [Django](https://www.djangoproject.com/) - Web framework used
* [testrpc](https://github.com/ethereumjs/testrpc) - Test chain used
* [MetaMask](https://metamask.io/) - Test wallet used
* [Mist](https://github.com/ethereum/mist/)
* [Python](https://www.python.org/) - For Django Web-app

## Authors

* **Justin Chase** - *Idea + Contract Implementation + Web-app* - [JustinChase](https://github.com/jujum4n)

## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to anyone who's code was used
* Inspiration
* water

