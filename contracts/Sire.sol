/**
 * @file Sire.sol
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
 *
 * Sire Ethereum Contract: Allows Ethereum user to invest Ether into sire currency.
 * sire generates the relic currency at a rate which deflates yearly. Amount of sire
 * available increases yearly by 1% and the amount of sire per ether rewarded
 * deflates yearly by 25%. The amount of relic generated deflates yearly by 4%.
 */
pragma solidity ^0.4.9;


/** @title Sire */
contract Sire {
    // Used to calculate relic rewards in the relicMint function
    struct RelicReward {
        uint256 amount; // Amount of sire you had at the time when you mint
        uint256 block; // The block height which you last minted
    }

    // Events for Transfer of sire and approving addresses to spend sire on behalf of an address
    event SireTransfer(address indexed _from, address indexed _to, uint256 _value);
    event SireApproval(address indexed _owner, address indexed _spender, uint256 _value);

    // Events for Transfer of relic and approving addresses to spend sire on behalf of an address, and relic minting
    event RelicTransfer(address indexed _from, address indexed _to, uint256 _value);
    event RelicApproval(address indexed _owner, address indexed _spender, uint256 _value);
    event RelicMint(address indexed _to, uint256 _value);

    /* Setup Public Constant Variables */

    string public constant SIRE_NAME = "Sire"; // Name of sire
    string public constant SIRE_SYMBOL = "sire"; // Symbol definition for sire
    uint8 public constant SIRE_DECIMALS = 18; // How many decimals for sire, keeping consistent with Ether

    string public constant RELIC_NAME = "Relic"; // Name of relic
    string public constant RELIC_SYMBOL = "relic"; // Symbol for relic
    uint8 public constant RELIC_DECIMALS = 18; // Decimal places used for sire, keeping consistent with Ether

    uint256 public constant REWARD_ADJUSTMENT = 2190000; // 1 Year worth of blocks, used for adjustments
    uint256 public constant ETH_INCR = 99; // 1 Percent deflation of eth available per year
    uint256 public constant TRANSFER_RATE_DEFLATION = 75; // Amount of Sire rewarded per Eth decreases by 25% every year
    uint256 public constant DEFLATION = 96; // Rate at which the number of y deflates

    /* Setup Public Non-Constant Variables */
    uint256 public maxEther = 33333000000000000000000; //1000000000000000000; 33,333 ether possible to collect initially increasing by 1% every year
    uint256 public etherCollected = 0; // Set ether we have collected to 0

    uint256 public transferRate = 1000; // Rate of transfer 1 Ether = 1000 sire goes down by 25% yearly
    uint256 public relicReward = 1667; // .01667 relic per sire per block reward for the first year,

    uint256 public lastAdjustmentBlock = block.number; // Block where the amount of maxEther increases so people can invest more increases
    uint256 public nextAdjustmentBlock = block.number + REWARD_ADJUSTMENT; // Happens every year, set to happen 1 year after contract deployed

    bool public sireAvailable = true; // If sire is available for exchange for ether
    uint256 public sireInCirculation = 0; // How much sire is currently circulating
    uint256 public relicInCirculation = 0; // How much relic is currently circulating

    // sire address mappings
    mapping (address => uint256) sireBalance; // Balance of x that a particular address has
    mapping (address => mapping (address => uint256)) sireAllowed; // Mapping of addresses to values, of what address is allowed to send how much sire
    mapping (address => uint256) sireLockBlock; // An integer holding the block number which the account is "locked" from sending sire

    // Relic address mappings
    mapping (address => uint256) relicBalance; // Balance of relic
    mapping (address => mapping (address => uint256)) relicAllowed; // Mapping of addresses to values, of what address is y_allowed to send how much
    mapping (address => RelicReward) relicRewardMap; // A mapping of a relic reward structure to each user

    /**@dev Contracts Constructor, called when deployed.
     */
    function Sire(){
        sireAvailable = true; // Set sire available
        // One time reward, paid to developer sire when the contract is initiated
        sireBalance[tx.origin] = maxEther; // 33,333.00 sire
        sireInCirculation += maxEther;
    }

    /**@dev Fallback function, If sire isAvailable, and the value they sent does not put over cap, then try to exchange it for rate.
     */
    function() payable {
        if (msg.value == 0) {
            throw;
        }
        adjust();
        // Sire is available and the balance of the contract is less or equal to max ether
        if (sireAvailable == true && etherCollected < maxEther) {
            uint256 sireToBeExchanged = msg.value * transferRate;
            // If the ether we have collected + the value sent to the contract is more than the max we can hold, return the money
            if (etherCollected + msg.value > maxEther){
                throw;
            }
            // If the contracts collected amount + the value sent is less than or equal maxEther it can collect
            if (etherCollected + msg.value <= maxEther) {
                // Increment the message senders sire balance by the calculated value
                sireInCirculation += sireToBeExchanged; // Pay the user out the amount of sire per the rate times the value they sent
                sireBalance[msg.sender] += sireToBeExchanged; // Increment the amount of sire in circulation
                // If they got the last sire and the contracts balance is == to our maxEther variable
                etherCollected += msg.value; // Update the amount of ether collected
                if (etherCollected == maxEther) {
                    sireAvailable = false; // No more sire available for 1 more year
                    // Reset the nextEthIncrBlock to be 1 year from when we just filled our ether balance
                    nextAdjustmentBlock = block.number + REWARD_ADJUSTMENT; // Set the next one to 1 year from now
                }
            }
        }
        else {
            throw;
        }
    }

    /**@dev Used to deflate the transfer rate, relic reward
     * @return boolean true or false if it adjusted or not
     */
    function adjust() returns (bool success){
        // If at the next block number we can increase the amount of ether the contract can hold or that block passed
        // Calculate how much more max ether, reset adjustment blocks, modify the transfer rate
        if (nextAdjustmentBlock <= block.number) {
            lastAdjustmentBlock = block.number; // Set the last eth increase to this block
            nextAdjustmentBlock = block.number + REWARD_ADJUSTMENT; // Set the next one to 1 year from now
            relicReward = (relicReward * DEFLATION) / 100; // Deflate the relic reward by 4%
            uint256 maxEtherSubValue = maxEther - ((maxEther * ETH_INCR) / 100); // Calculate the 1% subtraction value
            maxEther += maxEtherSubValue; // Increase the max ether we can collect by the difference of 1% increase
            transferRate = (transferRate * TRANSFER_RATE_DEFLATION) / 100; // Decrease the transfer rate which you get sire to ether by 25% every year
            sireAvailable = true; // More sire is now available it has been 1 year
            return true;
        }
        else{
            return false;
        }
    }

    /**@dev Used to mint relic, if a user has sire.
     * @param _to address to send the minted relic to, can be other than msg.sender.
     * @return boolean true or false if successfully minted relic.
     */
    function relicMint(address _to) returns (bool success) {
        // If someone with an empty account tries to spam the mint function
        if (sireBalance[msg.sender] == 0){
            return false;
        }
        uint256 lastRelicMintHeight = relicRewardMap[msg.sender].block; // Get the block which they last minted
        // If it is the first time someone tries to mint
        if (lastRelicMintHeight == 0 && sireBalance[msg.sender] > 0){
            relicRewardMap[msg.sender].amount = sireBalance[msg.sender]; // Set their relic value to the current balance
            relicRewardMap[msg.sender].block = block.number; // Set the block which they last minted rewards at this block
            uint256 relicAmount = (relicRewardMap[msg.sender].amount * relicReward) / 100000;
            relicInCirculation += relicAmount; // Update the amount of relics in circulation
            relicBalance[_to]+= relicAmount; // Update the msg senders balance of relics
            RelicMint(_to, relicAmount);  // Call the Mint relic event
            return true; // Exit function and do not continue to the next case
        }
        // If the users lastRelicMintHeight is less than the current block and they have a sire balance
        if (lastRelicMintHeight <= block.number && sireBalance[msg.sender] > 0){
            uint256 blockDiff = block.number - lastRelicMintHeight;
            // If the user sent some sire away before trying to mint and they have less than they did when they last minted
            if(sireBalance[msg.sender] < relicRewardMap[msg.sender].amount) {
                relicRewardMap[msg.sender].amount = relicBalance[msg.sender];
            }
            uint256 sireDiff = 0;
            // If the user got some sire since they last minted, give them 1 blocks worth of rewards for the new amount + the old over the time range
            if(sireBalance[msg.sender] > relicRewardMap[msg.sender].amount){
                sireDiff = sireBalance[msg.sender] - relicRewardMap[msg.sender].amount;
            }
            uint256 relicIncrease = (((relicRewardMap[msg.sender].amount * relicReward) * blockDiff) + sireDiff) / 100000;
            relicInCirculation += relicIncrease; // Update the amount of relics in circulation
            relicBalance[_to] += relicIncrease; // Update the msg senders balance of relics
            relicRewardMap[msg.sender].amount = sireBalance[msg.sender]; // Set their sire value to the current balance
            relicRewardMap[msg.sender].block = block.number; // Set the block which they last minted rewards at this block
            RelicMint(_to, relicIncrease); // Call the Mint relic event
            return true;
        }
        return false;
    }

    /**@dev Transfers sire from to an address given a value.
     * @param _to address to send sire to.
     * @param _value amount of sire to send.
     * @return boolean true or false if successfully sent sire.
     */
    function sireTransfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (sireBalance[msg.sender] >= _value && _value > 0) {
            sireBalance[msg.sender] -= _value;
            sireBalance[_to] += _value;
            SireTransfer(msg.sender, _to, _value);  // Call the Sire Transfer event
            return true;
        }
        else {
            return false;
        }
    }

    /**@dev Attempts to transfer sire on behalf of another address if allowed and if the value they are allowed is ok.
     * @param _from address to send sire from.
     * @param _to address to send sire to.
     * @param _value amount of sire to send.
     * @return boolean true or false if successfully sent sire.
     */
    function sireTransferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && x_allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (sireBalance[_from] >= _value && sireAllowed[_from][msg.sender] >= _value && _value > 0) {
            sireBalance[_to] += _value;
            sireBalance[_from] -= _value;
            sireAllowed[_from][msg.sender] -= _value;
            SireTransfer(_from, _to, _value); // Call the Sire Transfer event
            return true;
        }
        else {
            return false;
        }
    }

    /**@dev Returns the sire balance of an address.
     * @param _owner address to query sire balance of.
     * @return balance of address as uint256.
     */
    function sireBalanceOf(address _owner) constant returns (uint256 balance) {
        return sireBalance[_owner];
    }

    /**@dev Approves an address a given sire value to spend on its behalf.
     * @param _spender address to allow spending.
     * @param _value uint256 sire value to allow address to spend on its behalf.
     * @return boolean true.
     */
    function sireApprove(address _spender, uint256 _value) returns (bool success) {
        sireAllowed[msg.sender][_spender] = _value;
        SireApproval(msg.sender, _spender, _value); // Call Sire Approval event
        return true;
    }

    /**@dev Returns sire balance left that an address can spend on behalf of an owner.
     * @param _owner address to allow spending on behalf.
     * @param _spender address that can spend on behalf of the _owner address.
     * @return remaining uint256 sire value of sire that _spender can send on behalf of _owner.
     */
    function sireAllowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return sireAllowed[_owner][_spender];
    }

    /**@dev Transfers relic from to an address given a value.
     * @param _to address to send relic to.
     * @param _value amount of relic to send.
     * @return boolean true or false if successfully sent relic.
     */
    function relicTransfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (relicBalance[msg.sender] >= _value && _value > 0) {
            relicBalance[msg.sender] -= _value;
            relicBalance[_to] += _value;
            RelicTransfer(msg.sender, _to, _value); // Call Relic Transfer event
            return true;
        }
        else {
            return false;
        }
    }

    /**@dev Attempts to transfer relic on behalf of another address if allowed and if the value they are allowed is ok.
     * @param _from address to send relic from.
     * @param _to address to send relic to.
     * @param _value amount of relic to send.
     * @return boolean true or false if successfully sent relic.
     */
    function relicTransferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (relicBalance[_from] >= _value && relicAllowed[_from][msg.sender] >= _value && _value > 0) {
            relicBalance[_to] += _value;
            relicBalance[_from] -= _value;
            relicAllowed[_from][msg.sender] -= _value;
            RelicTransfer(_from, _to, _value); // Call Relic Transfer event
            return true;
        }
        else {
            return false;
        }
    }

    /**@dev Returns the relic balance of an address.
     * @param _owner address to query relic balance of.
     * @return balance of address as uint256.
     */
    function relicBalanceOf(address _owner) constant returns (uint256 balance) {
        return relicBalance[_owner];
    }

    /**@dev Approves an address a given sire relic to spend on its behalf.
     * @param _spender address to allow spending.
     * @param _value uint256 relic value to allow address to spend on its behalf.
     * @return boolean true.
     */
    function relicApprove(address _spender, uint256 _value) returns (bool success) {
        relicAllowed[msg.sender][_spender] = _value;
        RelicApproval(msg.sender, _spender, _value); // Call Relic Approval event
        return true;
    }

    /**@dev Returns relic balance left that an address can spend on behalf of an owner.
     * @param _owner address to allow spending on behalf.
     * @param _spender address that can spend on behalf of the _owner address.
     * @return remaining uint256 relic value of relic that _spender can send on behalf of _owner.
     */
    function relicAllowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return relicAllowed[_owner][_spender];
    }

    /**@dev Returns the amount of etherCollected by the contract
     * @return balance of etherCollected by the contract as uint256.
     */
    function etherCollectedBalance() constant returns (uint256 collectedEther) {
        return etherCollected;
    }

    /**@dev Returns the amount of maxEther the contract can possibly have
     * @return maxEther possible contract can collect at this time.
     */
    function maxEtherBalance() constant returns (uint256 maximumEtherBalance) {
        return maxEther;
    }

    /**@dev Returns whether or not sire is available for purchase by the contract
     * @return boolean whether or not sire is available
     */
    function sireAvailableBool() constant returns (bool isSireAvailable) {
        return sireAvailable;
    }

    /**@dev Returns the amount of sireInCirculation by the contract
     * @return amount of sire in circulation as uint256
     */
    function sireInCirculationAmount() constant returns (uint256 circulatingSire) {
        return sireInCirculation;
    }

    /**@dev Returns the amount of relicInCirculation by the contract
     * @return amount of relic in circulation as uint256
     */
    function relicInCirculationAmount() constant returns (uint256 circulatingRelic) {
        return relicInCirculation;
    }

    /**@dev Returns the amount of nextAdjustmentBlock by the contract
     * @return block number where the next adjustment of values will happen as uint256
     */
    function nextAdjustmentBlockNumber() constant returns (uint256 nextBlockAdjustment) {
        return nextAdjustmentBlock;
    }

    /**@dev Returns the last block height that relic was minted at
     * @return block number where the last block height that relic was minted as uint256
     */
    function lastRelicMintBlock(address _account) constant returns (uint256 lastBlockRelicMinted) {
        return relicRewardMap[_account].block;
    }

    /**@dev Returns the amount of relic that was used during the last mint block
     * @return amount of relic that was owned during last mint block uint256
     */
    function lastRelicMintAmount(address _account) constant returns (uint256 amountRelicLastMint) {
        return relicRewardMap[_account].amount;
    }

    /**@dev Returns the amount of sire that you get in exchange for 1 Ether
     * @return amount of relic that you get in exchange for 1 Ether
     */
    function sireTransferRate() constant returns (uint256 etherToSireRate) {
        return transferRate;
    }

    /**@dev Returns the amount of relic that you get for 1 sire/1 block
     * @return amount of relic that you get for 1 sire/1 block
     */
    function relicRewardRate() constant returns (uint256 rateOfRelicToSire) {
        return relicReward;
    }
}