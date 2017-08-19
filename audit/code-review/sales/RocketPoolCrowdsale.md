# RocketPoolCrowdsale

Source file [../../../contracts/sales/RocketPoolCrowdsale.sol](../../../contracts/sales/RocketPoolCrowdsale.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.11;
import "../RocketPoolToken.sol";
import "../base/SalesAgent.sol";
import "../lib/SafeMath.sol";


/// @title The main Rocket Pool Token (RPL) crowdsale contract
/// @author David Rugendyke - http://www.rocketpool.net

/*****************************************************************
*   This is the Rocket Pool crowdsale sale agent contract. It allows
*   deposits from the public for RPL tokens. Tokens are distributed
*   when the end date for the sale passes and uses collect their
*   tokens + any refund applicable. Tokens are distributed in a
*   proportional method that avoids the ‘rush’ associated with current
*   ICOs by allocating tokens based on the amount of ether deposited over time,
*   rather than selling to whomever gets there first.
/****************************************************************/

 // Tokens allocated proportionately to each sender according to amount of ETH contributed as a fraction of the total amount of ETH contributed by all senders.
 // credit for original distribution idea goes to hiddentao - https://github.com/hiddentao/ethereum-token-sales


contract RocketPoolCrowdsale is SalesAgent  {

    /**** Libs *****************/
    
    using SafeMath for uint;

    // Constructor
    /// @dev Sale Agent Init
    /// @param _tokenContractAddress The main token contract address
    function RocketPoolCrowdsale(address _tokenContractAddress) {
        // Set the main token address
        tokenContractAddress = _tokenContractAddress;
    }


    // Default payable
    /// @dev Accepts ETH from a contributor, calls the parent token contract to mint tokens
    function() payable external { 
        // Get the token contract
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Do some common contribution validation, will throw if an error occurs
        if(rocketPoolToken.validateContribution(msg.value)) {
            // Add to contributions, automatically checks for overflow with safeMath
            contributions[msg.sender] = contributions[msg.sender].add(msg.value);
            contributedTotal = contributedTotal.add(msg.value);
            // Fire event
            Contribute(this, msg.sender, msg.value); 
        }
    }


    /// @dev Finalises the funding and sends the ETH to deposit address
    // BK Ok
    function finaliseFunding() external {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Set the target ether amount locally
        // BK Ok
        uint256 targetEth = rocketPoolToken.getSaleContractTargetEtherMin(this);
        // Do some common contribution validation, will throw if an error occurs - address calling this should match the deposit address
        // BK Ok
        if(rocketPoolToken.setSaleContractFinalised(msg.sender)) {
            // Send to deposit address - revert all state changes if it doesn't make it
            assert(rocketPoolToken.getSaleContractDepositAddress(this).send(targetEth) == true);
            // Fire event
            FinaliseSale(this, msg.sender, targetEth);
        }
    }

    /// @dev Allows contributors to claim their tokens and/or a refund. If funding failed then they get back all their Ether, otherwise they get back any excess Ether
    // BK Ok
    function claimTokensAndRefund() external {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Set the target ether amount locally
        // BK Ok
        uint256 targetEth = rocketPoolToken.getSaleContractTargetEtherMin(this);
        // Do some common contribution validation, will throw if an error occurs
        // Checks to see if this user has actually contributed anything and if the sale end block has passed
        // BK Ok
        if(rocketPoolToken.validateClaimTokens(msg.sender)) {
            // The users contribution
            // BK Ok
            uint256 userContributionTotal = contributions[msg.sender];
            // Deduct the contribution now to protect against recursive calls
            // BK Ok
            contributions[msg.sender] = 0; 
            // Has the contributed total not been reached, but the crowdsale is over?
            // BK Ok - Refunds
            if (contributedTotal < targetEth) {
                // Target wasn't met, refund the user
                // BK Ok
                assert(msg.sender.send(userContributionTotal) == true);
                // Fire event
                // BK Ok - Log event
                Refund(this, msg.sender, userContributionTotal);
            } else {
                // Max tokens alloted to this sale agent contract
                // BK Ok
                uint256 totalTokens = rocketPoolToken.getSaleContractTokensLimit(this);
                // Calculate how many tokens the user gets
                // BK Ok
                rocketPoolToken.mint(msg.sender, totalTokens.mul(userContributionTotal) / contributedTotal);
                // Calculate the refund this user will receive
                // BK Ok - Excess ethers over the target is proportionally refunded to the user
                assert(msg.sender.send((contributedTotal - targetEth).mul(userContributionTotal) / contributedTotal) == true);
                // Fire event
                // BK Ok - Log event
                ClaimTokens(this, msg.sender, rocketPoolToken.balanceOf(msg.sender));
            }
        }
    }


}

```
