// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import sire_artifacts from '../../build/contracts/Sire.json'

// Get the sire abstraction which we'll use through the code below
var Sire = contract(sire_artifacts);

var accounts;
var account;

window.App = {
  start: function() {
    var self = this;

    // Bootstrap the sire abstraction for usage
    Sire.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("Wew! There was an error fetching your account");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];

            // Refresh contract information
            self.refreshSireBalance();
            self.refreshRelicBalance();
            self.refreshEtherBalance();
            self.refreshEtherCollected();
            self.refreshMaxEther();
            self.refreshSireInCirculation();
            self.refreshRelicInCirculation();
            self.refreshCurrentBlock();
            self.refreshTransferRate();
            self.refreshNextAdjustmentBlock();
            self.refreshRelicRewardRate();
        });
    },

    /**@dev Sets the sire transfer status html element
     */
    setSireStatus: function (message) {
        var status = document.getElementById("sireStatus");
        status.innerHTML = message;
    },

    /**@dev Sets the relic transfer status html element
     */
    setRelicStatus: function (message) {
        var status = document.getElementById("relicStatus");
        status.innerHTML = message;
    },

    /**@dev Sets the relic mine status html element
     */
    setRelicMintStatus: function (message) {
        var status = document.getElementById("relicMintStatus");
        status.innerHTML = message;
    },

    /**@dev Sets the etherbalance HTML element to the current account's balance
     */
    refreshEtherBalance: function () {
        return web3.eth.getBalance(account, function (error, result) {
            var balance_element = document.getElementById("etherBalance");
            balance_element.innerHTML = web3.fromWei(result.valueOf());
            var address_element = document.getElementById("address");
            address_element.innerHTML = account;
        });
    },

    /**@dev Sets the current block HTML element to the networks block height
     */
    refreshCurrentBlock: function () {
        return web3.eth.getBlockNumber(function(error, result){
            var current_block_element = document.getElementById("currentBlock");
            current_block_element.innerHTML = result.valueOf();
        });
    },

    /**@dev Sets the amount of ether collected html element to amount of ether contract has collected
     */
    refreshEtherCollected: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.etherCollected();
        }).then(function (ethCollected) {
            var collected_element = document.getElementById("etherCollected");
            collected_element.innerHTML = web3.fromWei(ethCollected.valueOf());
        });
    },

    /**@dev Sets the max ether html element to amount of ether can be collected at maximum
     */
    refreshMaxEther: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.MAX_ETHER();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("maxEther");
            maxEther_element.innerHTML = web3.fromWei(maxEther.valueOf());
        });
    },

    /**@dev Sets the next adjustment block height html element to when the next adjustments will occur
     */
    refreshNextAdjustmentBlock: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.nextAdjustmentBlock();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("nextAdjustmentBlock");
            var aprox_days = maxEther.valueOf() / 5000;
            maxEther_element.innerHTML = maxEther.valueOf() + ' blocks (~' + Math.round(aprox_days, 0) + ' days)';
        });
    },

    /**@dev Sets the sire in circulation html element to amount of sire in circulation
     */
    refreshSireInCirculation: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.totalSupply();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("sireInCirculation");
            maxEther_element.innerHTML = Sire.web3.fromWei(maxEther.valueOf());
        });
    },

    /**@dev Sets the relic reward rate html element to reward rate of sire/relic
     */
    refreshRelicRewardRate: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicReward();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("relicRewardRate");
            maxEther_element.innerHTML = '.0000' + maxEther.valueOf();
        });
    },

    /**@dev Sets the relic in circulation html element to amount of relic in circulation
     */
    refreshRelicInCirculation: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicTotalSupply();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("relicInCirculation");
            maxEther_element.innerHTML = Sire.web3.fromWei(maxEther.valueOf());
        });
    },

    /**@dev Sets the relic balance html element to amount of relic current user has
     */
    refreshRelicBalance: function () {

        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicBalanceOf.call(account, {from: account});
        }).then(function (value) {
            var balance_element = document.getElementById("relicBalance");
            balance_element.innerHTML = web3.fromWei(value.valueOf());
        });
    },

    /**@dev Sets the transfer rate html element to the transfer rate value
     */
    refreshTransferRate: function () {

        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.EXCHANGE_RATE();
        }).then(function (value) {
            var transfer_rate_element = document.getElementById("sireTransferRate");
            transfer_rate_element.innerHTML = value.valueOf();
        });
    },

    /**@dev Sets the sire balance html element to amount of sire current user has
     */
    refreshSireBalance: function () {
        var self = this;
        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.balanceOf.call(account, {from: account});
        }).then(function (value) {
            var balance_element = document.getElementById("sireBalance");
            var balance_address = document.getElementById("address");
            balance_element.innerHTML = web3.fromWei(value.valueOf());
            balance_address.innerHTML = web3.eth.accounts[0];
            /*if(web3.fromWei(value.valueOf()) == 0){
                document.getElementById("relicmine").style.display = "none";
            }*/
        }).catch(function (e) {
            console.log(e);
            self.setSireStatus("Error getting sire balance; see log.");
        });
    },

    /**@dev Attempts to mint relic to the current user account if they have sire
     */
    mintRelic: function () {
        var self = this;

        this.setRelicMintStatus("Minting relic... (please wait)");
        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicMint(accounts[0], {from: account});
        }).then(function () {
            self.setRelicMintStatus("Minting relic completed!");
            self.refreshRelicBalance();
            self.refreshRelicInCirculation();
            window.location.reload();
        }).catch(function (e) {
            console.log(e);
            self.setRelicMintStatus("Error minting relic; see log.");
        });
    },

    /**@dev Attempts to transfer a sire value from current user account to an address
     */
    transferSire: function () {
        var self = this;

        var amount = parseFloat(document.getElementById("sireAmount").value);
        var receiver = document.getElementById("sireReceiver").value;

        this.setSireStatus("Initiating sire transaction... (please wait)");
        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.transfer(receiver, Sire.web3.toWei(amount, 'ether'), {from: account});
        }).then(function () {
            self.setSireStatus("sire Transaction complete!");
            self.refreshSireBalance();
        }).catch(function (e) {
            console.log(e);
            self.setSireStatus("Error sending sire; see log.");
        });
    },

    /**@dev Attempts to transfer a relic value from current user account to an address
     */
    transferRelic: function () {
        var self = this;

        var amount = parseFloat(document.getElementById("relicamount").value);
        var receiver = document.getElementById("relicreceiver").value;

        this.setRelicStatus("Initiating transaction... (please wait)");
        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicTransfer(receiver, Sire.web3.toWei(amount, 'ether'), {from: account});
        }).then(function () {
            self.setRelicStatus("Transaction complete!");
            self.refreshRelicBalance();
        }).catch(function (e) {
            console.log(e);
            self.setRelicStatus("Error sending relic; see console log.");
        });
    }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 sire, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:9545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
  }
  App.start();
});
