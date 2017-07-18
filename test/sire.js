/**
 * @file Sire.js
 * @author Justin Chase <jujowned@gmail.com>
 * @version 1.0
 * @date 07/04/17
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
 *
 * Test suite for Sire Contract, exercises the functionality of the contract.
 * Creating Sire, Minting Relic, Sending Sire, Sending Relic
 */
var Sire = artifacts.require("./Sire.sol");

contract('Sire', function (accounts) {
    // Verifies that out first account starts with 33333 sire
    it("should put 33333 sire in the first account", function () {
        return Sire.deployed().then(function (instance) {
            return instance.sireBalanceOf.call(accounts[0]);
        }).then(function (balance) {
            assert.equal(Sire.web3.toWei(33333, 'ether'), balance.valueOf(), "33333 sire balance not in the first account");
        });
    });
    // Sends 1 ether to the contract, verifies it is rewarded 1000 sire
    it("should put 34333 sire in the first account after sending 1 ether to contract", function () {
        return Sire.deployed().then(function (instance) {
            return instance.sendTransaction({
                from: accounts[0],
                to: instance.address,
                value: Sire.web3.toWei(1, 'ether'),
                gasLimit: 42000,
                gasPrice: 20000000000
            })
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.sireBalanceOf.call(accounts[0]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(34333, balance.valueOf(), "34333 sire balance not in the first account");
            });
        });
    });
    // Sends 100 sire from the first account to the second, which is empty, verifies that the second has 100 sire
    it("should send 100 sire to the second account", function () {
        return Sire.deployed().then(function (instance) {
            return instance.sireTransfer(accounts[1], Sire.web3.toWei(100, 'ether'), {from: accounts[0]});
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.sireBalanceOf.call(accounts[1]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(100, balance.valueOf(), "100 sire balance not in the second account");
            });
        });
    });
    // Verifies that out first account now has 34233 sire
    it("should have 34233 sire in the first account after 100 sire send", function () {
        return Sire.deployed().then(function (instance) {
            return instance.sireBalanceOf.call(accounts[0]);
        }).then(function (balance) {
            new_bal = balance.valueOf()
            balance = Sire.web3.fromWei(new_bal)
            assert.equal(34233, balance.valueOf(), "34233 sire balance not in the first account");
        });
    });
    // Mints for the very first time should get 1 blocks worth of relics per sire * reward
    it("should have 1.667 relic in the second account after minting for first time ever with 100 sire", function () {
        return Sire.deployed().then(function (instance) {
            return instance.relicMint(accounts[1], {from: accounts[1]});
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.relicBalanceOf.call(accounts[1]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(1.667, balance.valueOf(), "1.667 relic balance not in the second account after first mint");
            });
        });
    });
    // Sends 1 relic from the second to the first, which is empty, verifies that the second has 100 sire
    it("should send 1 relic to the first account from the second", function () {
        return Sire.deployed().then(function (instance) {
            return instance.relicTransfer(accounts[0], Sire.web3.toWei(1, 'ether'), {from: accounts[1]});
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.relicBalanceOf.call(accounts[0]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(1, balance.valueOf(), "1 relic balance not in the first account");
            });
        });
    });
    // Verifies that our second account now has .667 relic
    it("should have .667 relic in the second account after sending 1 relic to account one", function () {
        return Sire.deployed().then(function (instance) {
            return instance.relicBalanceOf.call(accounts[1]);
        }).then(function (balance) {
            new_bal = balance.valueOf()
            balance = Sire.web3.fromWei(new_bal)
            assert.equal(.667, balance.valueOf(), ".667 relic balance not in the second account");
        });
    });
    // Verifies that our etherCollected variable has 1 Ether
    it("should have 1 Ether in our etherCollected variable", function () {
        return Sire.deployed().then(function (instance) {
            return instance.etherCollectedBalance.call({from: accounts[0]});
        }).then(function (balance) {
            new_bal = balance.valueOf()
            balance = Sire.web3.fromWei(new_bal)
            assert.equal(1, balance.valueOf(), "1 Ether not in our etherCollected variable");
        });
    });
    // Mints second time should get 2 blocks worth of relics per sire * reward + .667 that is already in the account
    it("should have 4.001 relic in the second account after minting for second time ever with 100 sire", function () {
        return Sire.deployed().then(function (instance) {
            return instance.relicMint(accounts[1], {from: accounts[1]});
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.relicBalanceOf.call(accounts[1]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(4.001, balance.valueOf(), "4.001 relic balance not in the second account after second mint");
            });
        });
    });
    // Mints second time should get 1 blocks worth of relics per sire * reward + 4.001 that is already in the account
    it("should have 5.668 relic in the second account after minting for third time with 100 sire", function () {
        return Sire.deployed().then(function (instance) {
            return instance.relicMint(accounts[1], {from: accounts[1]});
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.relicBalanceOf.call(accounts[1]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(5.668, balance.valueOf(), "5.668 relic balance not in the second account after third mint");
            });
        });
    });
    // Mints for the very first time should get 1 blocks worth of relics per sire * reward
    it("should have 571.66411 relic in the first account after minting for first time ever with 34233 sire and already having 1 relic sent to it", function () {
        return Sire.deployed().then(function (instance) {
            return instance.relicMint(accounts[0], {from: accounts[0]});
        }).then(function () {
            return Sire.deployed().then(function (instance) {
                return instance.relicBalanceOf.call(accounts[0]);
            }).then(function (balance) {
                new_bal = balance.valueOf()
                balance = Sire.web3.fromWei(new_bal)
                assert.equal(571.66411, balance.valueOf(), "571.66411 relic balance not in the first account after first mint");
            });
        });
    });
});
