# RocketPoolPresale

Source file [../../../contracts/sales/RocketPoolPresale.sol](../../../contracts/sales/RocketPoolPresale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;
// BK Next 4 Ok
import "../RocketPoolToken.sol";
import "../base/SalesAgent.sol";
import "../base/Owned.sol";
import "../lib/SafeMath.sol";


/// @title The main Rocket Pool Token (RPL) presale contract
/// @author David Rugendyke - http://www.rocketpool.net

/*****************************************************************
*   This is the Rocket Pool presale sale agent contract. It mints
*   tokens from the main erc20 token instantly when payment is made
*   by a presale buyer. The value of each token is determined by
*   the sale agent parameters maxTargetEth / tokensLimit. If a 
*   buyer sends more ether than they are allocated, they receive
*   their tokens + a refund. The sale ends when the end block
*   is passed.
/****************************************************************/

// BK Ok
contract RocketPoolPresale is SalesAgent, Owned  {

    /**** Libs *****************/
    
    // BK Ok
    using SafeMath for uint;

    /**** Properties ***********/

    // Our rocket mini pools, should persist between any Rocket Pool contract upgrades
    // BK Ok
    mapping (address => Allocations) private allocations;
    // Keep an array of all our addresses for iteration
    // BK Ok
    address[] private reservedAllocations;
    // Reserved ether allocation total
    // BK Ok
    uint256 public totalReservedEther = 0;

    
    /**** Structs **************/

    // BK Next block Ok
    struct Allocations {
        uint256 amount;                 // Amount in Wei they have been assigned
        bool exists;                    // Does this entry exist? (whoa, deep)
    }


    /**** Modifiers ***********/

    /// @dev Only allow access from a presale user
    // BK Ok
    modifier onlyPresaleUser(address _address) {
        // BK Ok
        assert(allocations[_address].exists == true);
        // BK Ok
        _;
    }


    // Constructor
    /// @dev Sale Agent Init
    /// @param _tokenContractAddress The main token contract address
    // BK Ok
    function RocketPoolPresale(address _tokenContractAddress) {
        // Set the main token address
        // BK Ok
        tokenContractAddress = _tokenContractAddress;
    }

    // Default payable
    /// @dev Accepts ETH from a contributor, calls the parent token contract to mint tokens
    // BK Ok
    function() payable public onlyPresaleUser(msg.sender) { 
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Do some common contribution validation, will throw if an error occurs
        // BK Ok
        if(rocketPoolToken.validateContribution(msg.value)) {
            // Have they already collected their reserved amount?
            // BK Ok
            assert(contributions[msg.sender] == 0);
            // Have they deposited enough to cover their reserved amount?
            // BK Ok
            assert(msg.value >= allocations[msg.sender].amount);
            // Add to contributions, automatically checks for overflow with safeMath
            // BK Ok
            contributions[msg.sender] = contributions[msg.sender].add(msg.value);
            // BK Ok
            contributedTotal = contributedTotal.add(msg.value);
            // Fire event
            // BK Ok
            Contribute(this, msg.sender, msg.value); 
            // Mint the tokens now for that user instantly
            // BK Ok
            mintSendTokens();
        }
    }


    /// @dev Add a presale user - onlyOwner
    /// @param _address Address of the presale user
    /// @param _amount Amount allocated for the presale user
    // BK Ok - Only owner can execute
    function addPresaleAllocation(address _address, uint256 _amount) onlyOwner {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Do we have a valid amount and aren't exceeding the total ether allowed for this sale agent and the sale hasn't ended?
        // BK Ok
        if(_amount > 0 && rocketPoolToken.getSaleContractTargetEtherMax(this) >= _amount.add(totalReservedEther) && !rocketPoolToken.getSaleContractIsFinalised(this)) {
            // Does the user exist already?
            // BK Ok
            if(allocations[_address].exists == false) {
                // Add the user and their allocation amount in Wei
                // BK Next block Ok
                allocations[_address] = Allocations({
                    amount: _amount,
                    exists: true 
                }); 
                // Store our address so we can iterate over it if needed
                // BK Ok
                reservedAllocations.push(_address);
            // BK Ok
            }else{
                // Add to their reserved amount
                // BK Ok
                allocations[_address].amount = allocations[_address].amount.add(_amount);
            }
            // Add it to the total
            // BK Ok
            totalReservedEther = totalReservedEther.add(_amount);
        } 
    }
    

    /// @dev Get a presale users ether allocation
    // BK Ok
    function getPresaleAllocation(address _address) public constant onlyPresaleUser(_address) returns(uint256) {
        // Get the users assigned amount
        // BK Ok
        return allocations[_address].amount;
    }


    /// @dev Mint the tokens now for that user instantly
    // BK OK - Private function
    function mintSendTokens() private {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // If the user sent too much ether, calculate the refund
        // BK Ok
        uint256 refundAmount = contributions[msg.sender] > allocations[msg.sender].amount ? contributions[msg.sender].sub(allocations[msg.sender].amount) : 0;    
        // Send the refund, throw if it doesn't succeed
        // BK Ok
        if (refundAmount > 0) {
            // Avoid recursion calls and deduct now
            // BK Ok
            contributions[msg.sender] = contributions[msg.sender].sub(refundAmount);
            // BK Ok
            contributedTotal = contributedTotal.sub(refundAmount);
            // Send the refund, throw if it doesn't succeed
            // BK Ok
            assert(msg.sender.send(refundAmount) == true);
            // Fire event
            // BK Ok
            Refund(this, msg.sender, refundAmount); 
        } 
        // Max tokens allocated to this sale agent contract
        uint256 totalTokens = rocketPoolToken.getSaleContractTokensLimit(this);
        // Note: There's a bug in testrpc currently which will deduct the msg.value twice from the user when calling any library function such as below (https://github.com/ethereumjs/testrpc/issues/122)
        //       Testnet and mainnet work as expected
        // Calculate the ether price of each token using the target max Eth and total tokens available for this agent, so tokenPrice = totalTokens / maxTargetEth
        // BK Ok
        uint256 tokenPrice = totalTokens.div(rocketPoolToken.getSaleContractTargetEtherMax(this));
        // Total tokens they will receive
        // BK Ok
        uint256 tokenAmountToMint = tokenPrice * allocations[msg.sender].amount;
        // Mint the tokens and give them to the user now
        // BK Ok
        rocketPoolToken.mint(msg.sender, tokenAmountToMint);         
        // Send the current balance to the deposit address
        assert(rocketPoolToken.getSaleContractDepositAddress(this).send(allocations[msg.sender].amount) == true); 
        // Fire the event     
        TransferToDepositAddress(this, msg.sender, allocations[msg.sender].amount);
    }


    /// @dev Finalises the funding and sends the ETH to deposit address
    // BK Ok
    function finaliseFunding() external {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Do some common contribution validation, will throw if an error occurs - address calling this should match the deposit address
        // BK Ok
        if(rocketPoolToken.setSaleContractFinalised(msg.sender)) {
            // Send to deposit address - revert all state changes if it doesn't make it
            // BK Ok
            assert(rocketPoolToken.getSaleContractDepositAddress(this).send(this.balance) == true);
            // Fire event
            // BK Ok - Log event
            FinaliseSale(this, msg.sender, this.balance);
        }
    }



}

```
