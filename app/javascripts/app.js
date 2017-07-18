/**
 * @file app.js
 * @author Justin Chase <jujowned@gmail.com>
 * @version 1.0
 * @date 06/21/2017
 * @website https://sireli.cc
 *
 * @section LICENSE
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details at
 * https://www.gnu.org/copyleft/gpl.html
 *
 * @section DESCRIPTION
 * Javascript that updates HTML elements in index.html
 */

// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/bootstrap.min.css";
import "../stylesheets/app.css";

// Import libraries we need.
import {default as Web3} from 'web3';
import {default as contract} from 'truffle-contract';

// Import our contract artifacts and turn them into usable abstractions.
import Sire_artifacts from '../../build/contracts/Sire.json';

// Sire is our usable abstraction, which we'll use through the code below.
var Sire = contract(Sire_artifacts);

// Holds all accounts, and currrent account
var accounts;
var account;

window.App = {
    /**@dev Updates all of the contract elements on the page, sets up web3 and gets eth accounts
     */
    start: function () {
        var self = this;

        // Bootstrap the Sire abstraction
        Sire.setProvider(web3.currentProvider);

        // Get the initial account balance so it can be displayed.
        web3.eth.getAccounts(function (err, accs) {
            if (err != null) {
                alert("Error fetching your Ethereum accounts.");
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
            self.refreshSireAvailable();
            self.refreshSireInCirculation();
            self.refreshRelicInCirculation();
            self.refreshCurrentBlock();
            self.refreshTransferRate();
            self.refreshNextAdjustmentBlock();
            self.refreshLastRelicMintBlock();
            self.refreshRelicRewardRate();
        });
    },

    /**@dev Sets the sire transfer status html element
     */
    setSireStatus: function (message) {
        var status = document.getElementById("sirestatus");
        status.innerHTML = message;
    },

    /**@dev Sets the relic transfer status html element
     */
    setRelicStatus: function (message) {
        var status = document.getElementById("relicstatus");
        status.innerHTML = message;
    },

    /**@dev Sets the relic mine status html element
     */
    setRelicMintStatus: function (message) {
        var status = document.getElementById("relicmintstatus");
        status.innerHTML = message;
    },

    /**@dev Sets the etherbalance HTML element to the current account's balance
     */
    refreshEtherBalance: function () {
        return web3.eth.getBalance(account, function (error, result) {
            var balance_element = document.getElementById("etherbalance");
            balance_element.innerHTML = web3.fromWei(result.valueOf());
            var address_element = document.getElementById("address");
            address_element.innerHTML = account;
        });
    },

    /**@dev Sets the current block HTML element to the networks block height
     */
    refreshCurrentBlock: function () {
        return web3.eth.getBlockNumber(function(error, result){
            var current_block_element = document.getElementById("currentblock");
            current_block_element.innerHTML = result.valueOf();
        });
    },

    /**@dev Sets the amount of ether collected html element to amount of ether contract has collected
     */
    refreshEtherCollected: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.etherCollectedBalance.call();
        }).then(function (ethCollected) {
            var collected_element = document.getElementById("ethercollected");
            collected_element.innerHTML = web3.fromWei(ethCollected.valueOf());
        });
    },

    /**@dev Sets the max ether html element to amount of ether can be collected at maximum
     */
    refreshMaxEther: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.maxEtherBalance.call();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("maxether");
            maxEther_element.innerHTML = web3.fromWei(maxEther.valueOf());
        });
    },

    /**@dev Sets the next adjustment block height html element to when the next adjustments will occur
     */
    refreshNextAdjustmentBlock: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.nextAdjustmentBlockNumber.call();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("nextadjustment");
            maxEther_element.innerHTML = maxEther.valueOf();
        });
    },

    /**@dev Sets the sire available html element to wether or not the contract has sire for exchange
     */
    refreshSireAvailable: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.sireAvailableBool.call();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("sireavailable");
            maxEther_element.innerHTML = maxEther.valueOf();
        });
    },

    /**@dev Sets the sire in circulation html element to amount of sire in circulation
     */
    refreshSireInCirculation: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.sireInCirculationAmount.call();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("sireincirculation");
            maxEther_element.innerHTML = Sire.web3.fromWei(maxEther.valueOf());
        });
    },

    /**@dev Sets the relic reward rate html element to reward rate of sire/relic
     */
    refreshRelicRewardRate: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicRewardRate.call();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("rewardrate");
            maxEther_element.innerHTML = maxEther.valueOf()/100000;
        });
    },

    /**@dev Sets the last relic mint block html element to when users last relic block was minted
     */
    refreshLastRelicMintBlock: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.lastRelicMintBlock.call(account, {from: account});
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("lastrelicmintblock");
            maxEther_element.innerHTML = maxEther.valueOf();
        });
    },

    /**@dev Sets the relic in circulation html element to amount of relic in circulation
     */
    refreshRelicInCirculation: function () {
        var sire;
        return Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.relicInCirculationAmount.call();
        }).then(function (maxEther) {
            var maxEther_element = document.getElementById("relicincirculation");
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
            var balance_element = document.getElementById("relicbalance");
            balance_element.innerHTML = web3.fromWei(value.valueOf());
        });
    },

    /**@dev Sets the transfer rate html element to the transfer rate value
     */
    refreshTransferRate: function () {

        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.sireTransferRate.call();
        }).then(function (value) {
            var transfer_rate_element = document.getElementById("transferrate");
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
            return sire.sireBalanceOf.call(account, {from: account});
        }).then(function (value) {
            var balance_element = document.getElementById("sirebalance");
            var balance_address = document.getElementById("address");
            balance_element.innerHTML = web3.fromWei(value.valueOf());
            balance_address.innerHTML = web3.eth.accounts[0];
            if(web3.fromWei(value.valueOf()) == 0){
                document.getElementById("relicmine").style.display = "none";
            }
        }).catch(function (e) {
            console.log(e);
            self.setSireStatus("Error getting sire balance; see log.");
        });
    },

    /**@dev Attempts to mint relic to the current user account if they have sire
     */
    mintRelic: function () {
        var self = this;

        this.setRelicMintStatus("Minting... (please wait)");
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

        var amount = parseFloat(document.getElementById("sireamount").value);
        var receiver = document.getElementById("sirereceiver").value;

        this.setSireStatus("Initiating transaction... (please wait)");
        var sire;
        Sire.deployed().then(function (instance) {
            sire = instance;
            return sire.sireTransfer(receiver, Sire.web3.toWei(amount, 'ether'), {from: account});
        }).then(function () {
            self.setSireStatus("Transaction complete!");
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


/**@dev Sets up web3 and starts App
 */
window.addEventListener('load', function () {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof web3 !== 'undefined') {
        //console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 Sire, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
        // Use Mist/MetaMask's provider
        window.web3 = new Web3(web3.currentProvider);
    } else {
        console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
        // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
        window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    }

    App.start();
});
