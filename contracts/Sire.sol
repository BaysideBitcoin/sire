/**
 * @file Sire.sol
 * @author Justin Chase <justin@baysidebitcoin.com>, Ben Christensen <ben@baysidebitcoin.com>
 * @version 2.1
 * @date 1/2/2017
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
 * A fixed maximum of sire that can possibly exist of 10,000,000
 * sire can Mint relic currency at a rate which deflates by 15% yearly.
 * sire has a Burn function which rewards users with ~50% of a years worth of rewards instantly destroying the sire.
 * sire Mint's can be traded to other accounts, rates and sire are locked in Mint Asset
 */
pragma solidity ^0.4.18;

import "./owned.sol";

contract Sire is owned {
    // Mint structure becomes a transferable asset that locks in a given amount of sire at a specific relicReward
    struct Mint {
        uint256 sireAmount; // Amount of sire you had at the time when you mint
        uint256 blockNumber; // The block height at which you created this mint
        uint256 relicRewardRate; // The relic reward rate at which the mint was created
        uint256 timestamp; // The time at which the Mint was created
    }

    /*sire erc20 events*/
    event Transfer(address indexed _from, address indexed _to, uint256 _value); // Triggered when a user transfers sire
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); // Triggered when a user does a sire Approval
    event Burn(address indexed _from, uint256 _value, uint256 _relicGained); // Triggered when a user does a Burn of sire

    /*relic erc20 events*/
    event RelicTransfer(address indexed _from, address indexed _to, uint256 _value); // Triggered when a user transfers relic
    event RelicApproval(address indexed _owner, address indexed _spender, uint256 _value); // Triggered when a user does a relic Approval

    /*Special Sire contract events*/
    event MintTransfer(address indexed _from, address indexed _to, uint256 _numberSire, uint256 _relicRate); // Triggered When someone transfers a Mint
    event CollectMint(address indexed _location, uint256 _numberSire, uint256 _relicRate, uint256 numberRelicsCreated, uint256 numberBlocksHeld); // Event triggered when user collects Mints
    event CreateMint(address indexed _location, uint256 _numberSire, uint256 _relicRate); // Event triggered when the user creates Mints
    event Adjusted(uint256 _oldRewardRate, uint256 _newRewardRate); // Triggered when relic reward rate decays
    event OneTimeWithdraw(address _owner, uint256 amount); // Triggered when the dev team takes its one time withdraw

    // Constant Public Variables
    uint256 public constant REWARD_ADJUSTMENT = 5000 * 365; // ~1 Year worth of blocks, used for adjustments
    uint256 public constant BURN_BLOCKS = 5000 * 182; // ~50% of a years worth of blocks
    uint256 public constant RELIC_DEFLATION = 85; // Equates to a 15% depreciation when used properly
    uint256 public constant EXCHANGE_RATE = 100; // ICO Exchange Rate: 1 Ether = 100 sire
    uint256 public constant MAX_ETHER = 100000000000000000000000; // Total 100,000 Ether max to ever be collected
    uint256 public constant SIRE_MAX = MAX_ETHER * EXCHANGE_RATE; // Total 10,000,000 sire possible max to ever exist

    // Constant Private Variables
    uint256 constant private MAX_UINT256 = 2**256 - 1;

    // sire's erc20 Variables
    string public constant name = "sire"; // Name of sire currency
    string public constant symbol = "sire"; // Symbol definition for sire
    uint8 public constant decimals = 18; // Keep decimal numbers consistent with Ether
    uint256 public totalSupply; // total active supply of sire in circulation
    mapping(address => uint256) public balances; // Mapping of addresses to uin256 of user sire balances
    mapping(address => mapping(address => uint256)) public allowed;



    // relic's erc20 Variables
    string public constant relicName = "relic"; // Name of relic currency
    string public constant relicSymbol = "relic"; // Symbol of relic currency
    uint8 public constant relicDecimals = 18; // Keep decimal numbers consistent with sire and Ether
    uint256 public relicTotalSupply;
    mapping(address => uint256) public relicBalances;
    mapping(address => mapping(address => uint256)) public relicAllowed;

    // Mint Variables
    mapping(address => Mint[]) public mintStorage; // Mapping of addresses to Arrays of Mint Structures
    uint256 public mintTotalSupply; // How many "Mints" exist currently minting overall at the time
    uint256 public mintLockedSire; // How much sire is locked is currently locked in mints overall


    /* Setup Public Non-Constant Variables */
    uint256 public etherCollected = 0; // Amount of Ether we have currently collected
    bool public maxEtherCapHit = false; // Check if maxEther Cap has been hit

    uint256 public relicReward = 1427; // Equates to ~ .00001427 relic, per sire, per block for the first year

    uint256 public nextAdjustmentBlock = block.number + REWARD_ADJUSTMENT; // Happens every ~year

    uint256 public sireInCirculation = 0; // How much sire is currently circulating
    uint256 public sireFlashedTotal = 0; // How many total sire have been flashed and are destroyed
    uint256 public relicInCirculation = 0; // How much relic is currently circulating

    address devTeamAddress = 0x0; // Where oneTimeWithdraw will be transferred to
    bool private oneTimeWithdrawl = false;

    /**@dev Contracts Constructor, called one time when sire is deployed
     */
    function Sire() public {
        maxEtherCapHit = false;
    }

    /**@dev Fallback function, If we have not collected max amount of ether allow users to convert ether for sire
     */
    function() public payable {
        if (msg.value == 0) {
            revert();
        }
        if(add(etherCollected, msg.value) > MAX_ETHER) {
            revert();
        }
        if(add(etherCollected, msg.value) <= MAX_ETHER){
            etherCollected += msg.value;
            // Increment our etherCollected Amount
            uint256 sireExchange = mul(msg.value, EXCHANGE_RATE);
            // Calculate how much sire to give out
            totalSupply += sireExchange;
            // Update our total sire totalSupply
            balances[msg.sender] += sireExchange;
        }
    }


    /*sire ERC20 functions - https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol*/
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance_value = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance_value >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance_value < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    /*------------------------------------------------------------------------------------------------*/

    /*relic ERC20 functions - https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol*/
    function relicTransfer(address _to, uint256 _value) public returns (bool success) {
        require(relicBalances[msg.sender] >= _value);
        relicBalances[msg.sender] -= _value;
        relicBalances[_to] += _value;
        RelicTransfer(msg.sender, _to, _value);
        return true;
    }
    function relicTransferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 relic_allowance = relicAllowed[_from][msg.sender];
        require(relicBalances[_from] >= _value && relic_allowance >= _value);
        relicBalances[_to] += _value;
        relicBalances[_from] -= _value;
        if (relic_allowance < MAX_UINT256) {
            relicAllowed[_from][msg.sender] -= _value;
        }
        RelicTransfer(_from, _to, _value);
        return true;
    }
    function relicBalanceOf(address _owner) public view returns (uint256 balance) {
        return relicBalances[_owner];
    }
    function relicApprove(address _spender, uint256 _value) public returns (bool success) {
        relicAllowed[msg.sender][_spender] = _value;
        RelicApproval(msg.sender, _spender, _value);
        return true;
    }
    function relicAllowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return relicAllowed[_owner][_spender];
    }
    /*------------------------------------------------------------------------------------------------*/

    /* "Special" sire functions*/

    /**@dev Used to deflate the relic reward value
     * @return bool true or false if it adjusted or not
     */
    function adjustRates() internal returns (bool) {
        if(block.number >= nextAdjustmentBlock){
            nextAdjustmentBlock = block.number + REWARD_ADJUSTMENT;
            uint256 oldRate = relicReward;
            relicReward = mul(relicReward, RELIC_DEFLATION);
            relicReward = div(relicReward, RELIC_DEFLATION);
            Adjusted(oldRate, relicReward);
            return true;
        }
        else{
            return false;
        }
    }

    /**@dev Used to pay dev team, can be called only one-time, can be called only by owner
     * @return bool true or false if successfully paid developers
     * This will be called when we get close to near maximum amount of sire distributed
     */
    function oneTimeWithdraw() onlyOwner returns (bool){
        //require that the Withdrawl has not taken place
        require(oneTimeWithdrawl == false);
        // Transfer 15% of collected Ether to hardcoded devTeamAddress
        uint256 devPayment = div(mul(etherCollected, RELIC_DEFLATION), RELIC_DEFLATION);
        devTeamAddress.transfer(devPayment);
        oneTimeWithdrawl = true;
        OneTimeWithdraw(devTeamAddress, devPayment);
        return true;
    }

    /**@dev Used to burn a sire token and create relic from it instantly
     * @return bool true or false if successfully burned sire and created relic
     */
    function burn(uint256 sireAmount) public returns (bool){
        require(balances[msg.sender] >= sireAmount);
        adjustRates(); // Checks to see if we need to adjust rates if 1 year has elapsed since last adjust
        balances[msg.sender] -= sireAmount; // Decrement the users sire balance by amount wanting to be burned
        totalSupply -= sireAmount; // Decrement the global total sire supply counter since the total was just decreased
        uint256 relicGained = mul(mul(sireAmount, relicReward), BURN_BLOCKS); // Calculate relic gained by burn
        relicBalances[msg.sender] += relicGained; // Increment the users relic balance
        relicTotalSupply += relicGained; // Increment the overall totalSupply of relic
        Burn(msg.sender, sireAmount, relicGained); // Call Burn Event
        return true;
    }

    /**@dev Used to create a Mint object, if a user has sire.
     * @return bool true or false if successfully created a Mint with given sire
     */
    function createMint(uint256 sireAmount) public returns (bool){
        require(balances[msg.sender] >= sireAmount); // User should have more or = amount of sire being requested for mint
        adjustRates(); // Checks to see if we need to adjust rates if 1 year has elapsed since last adjust
        balances[msg.sender] -= sireAmount; // Decrement the Users sire balance since it is now locked in the Mint
        Mint memory newMint; // Create a new mint to add to the users storage
        newMint.relicRewardRate = relicReward; // Set the current relic Reward rate for the Mint token
        newMint.sireAmount = sireAmount; // Set the sireAmount for the Mint Token
        newMint.blockNumber = block.number; // Set the block number for the Mint token
        newMint.timestamp = now; // Set the timestamp for the Mint token
        mintTotalSupply += 1; // Increment global counter of number of Mints currently existing
        mintLockedSire += sireAmount; // Increment Global counter keeping track of amount of sire locked for minting
        mintStorage[msg.sender].push(newMint); // Push the Mint onto the users mintStorage array
        return true;
    }

    /**@dev Used to collect a Mint
     * @return bool true or false if successfully collected mint
     */
    function collectMint(uint256 _index) public returns (bool){
        // Require the Mint someone is collecting has a sireAmount
        require(mintStorage[msg.sender][_index].sireAmount > 0);
        uint256 returnSire = mintStorage[msg.sender][_index].sireAmount;
        // Number relics = (# sire * relicRewardRate ) * # blocksElapsed since Mint Creation
        uint256 numRelics = mul(mintStorage[msg.sender][_index].sireAmount, mintStorage[msg.sender][_index].relicRewardRate);
        uint256 relRewardRate = mintStorage[msg.sender][_index].relicRewardRate;
        uint256 blockDifference = block.number - mintStorage[msg.sender][_index].blockNumber;
        numRelics = mul(numRelics, blockDifference); // Multiply the sire*reward by the amount of blocks elapsed
        delete mintStorage[msg.sender][_index]; // Delete the Mint from the users storage
        relicBalances[msg.sender] += numRelics; // Increment users relic total
        relicTotalSupply += numRelics; // Increment the relic total supply
        mintTotalSupply -= 1; // Decrement the mintTotalSupply since one Mint was just destroyed
        mintLockedSire -= returnSire; // Decrement the Global counter keeping track of amount of locked sire
        balances[msg.sender] += returnSire; // Give them back the sire that was locked in the Mint
        CollectMint(msg.sender, returnSire, relRewardRate, numRelics, blockDifference);
        return true;
    }

    /**@dev Used to transfer a Mint object
     * @return bool true or false if successfully sent the Mint
     */
    function mintTransfer(address _to, uint256 _index) public returns (bool success) {
        // Require that the index being sent actually has sire in it
        require(mintStorage[msg.sender][_index].sireAmount > 0);
        uint256 sireTransferTotal = mintStorage[msg.sender][_index].sireAmount; // Used for Event announcements
        uint256 rateTransferRate = mintStorage[msg.sender][_index].relicRewardRate; // Used for Event announcements
        mintStorage[_to].push(mintStorage[msg.sender][_index]); // Update _to's mintStorage to contain the Mint @ the senders location
        delete mintStorage[msg.sender][_index]; // Delete the mint structure at the given index from the sender's Mint Array
        MintTransfer(msg.sender, _to, sireTransferTotal, rateTransferRate); // Call MintTransfer Event
        return true;
    }
    /*------------------------------------------------------------------------------------------------*/

    /*SafeMath.sol functions - https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    /*------------------------------------------------------------------------------------------------*/
}
