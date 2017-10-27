# RocketPoolCrowdsale

Source file [../../../contracts/sales/RocketPoolCrowdsale.sol](../../../contracts/sales/RocketPoolCrowdsale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.15;
// BK Next 4 Ok
import "../RocketPoolToken.sol";
import "../base/SalesAgent.sol";
import "../base/Owned.sol";
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


// BK Ok
contract RocketPoolCrowdsale is SalesAgent, Owned {

    /**** Libs *****************/
    
    // BK Ok
    using SafeMath for uint;

    /**** Properties ***********/

    // BK Ok
    bool public targetEthSent = false;
    // BK Ok
    bool public saleDepositsAllowed = false;
    // BK Ok 
    uint256 public deployedTime;


    /**** Methods ************ */

    // Constructor
    /// @dev Sale Agent Init
    /// @param _tokenContractAddress The main token contract address
    // BK Ok - Constructor
    function RocketPoolCrowdsale(address _tokenContractAddress) {
        // Set the main token address
        // BK Ok
        tokenContractAddress = _tokenContractAddress;
        // Set the time the contract was deployed
        // BK Ok
        deployedTime = now;
    }


    // Default payable
    /// @dev Accepts ETH from a contributor, calls the parent token contract to mint tokens
    // BK Ok - Users send ETH contribution here
    function() payable external { 
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // The target ether amount
        // BK Ok
        uint256 targetEth = rocketPoolToken.getSaleContractTargetEtherMin(this);
        // Only allow sales if set to true
        // BK Ok
        assert(saleDepositsAllowed == true);
        // Do some common contribution validation, will throw if an error occurs
        // BK  Ok
        assert(rocketPoolToken.validateContribution(msg.value));
        // Add to contributions, automatically checks for overflow with safeMath
        // BK Ok
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        // BK Ok
        contributedTotal = contributedTotal.add(msg.value);
        // Fire event
        // BK Ok - Log event
        Contribute(this, msg.sender, msg.value);
        // BK NOTE - Debugging event left if code?
        // BK Ok 
        FlagUint(contributedTotal);
        // Have we met the min required ether for this sale to be a success? Send to the deposit address now
        // BK Ok
        if (contributedTotal >= targetEth && targetEthSent == false) {
            // Send to deposit address - revert all state changes if it doesn't make it
            // BK Ok
            assert(rocketPoolToken.getSaleContractDepositAddress(this).send(targetEth) == true);
            // Fire the event
            // BK Ok - Log event     
            TransferToDepositAddress(this, msg.sender, targetEth);
            // Mark as true now
            // BK Ok
            targetEthSent = true;
        }
    }

    /// @dev Allows contributors to claim their tokens and/or a refund via a public facing method
    // BK Ok
    function claimTokensAndRefund() external {
        // Get the tokens and refund now
        // BK Ok
        sendTokensAndRefund(msg.sender);
    }

    /// @dev onlyOwner - Sends a users tokens to the user after the sale has finished, included incase some users cant figure out running the claimTokensAndRefund() method themselves
    /// @param _contributerAddress Address of the crowdsale user
    // BK Ok - Only owner can execute
    function ownerClaimTokensAndRefundForUser(address _contributerAddress) external onlyOwner {
        // The owner of the contract can trigger a users tokens to be sent to them if they can't do it themselves
        // BK Ok
       sendTokensAndRefund(_contributerAddress);
    }


    /// @dev Sends the contributors their tokens and/or a refund. If funding failed then they get back all their Ether, otherwise they get back any excess Ether
    // BK Ok
    function sendTokensAndRefund(address _contributerAddress) private {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Set the target ether amount locally
        // BK Ok
        uint256 targetEth = rocketPoolToken.getSaleContractTargetEtherMin(this);
        // Must have previously contributed
        // BK Ok
        assert(contributions[_contributerAddress] > 0); 
        // Deposits must no longer be allowed
        // BK Ok
        assert(saleDepositsAllowed == false); 
        // The users contribution
        // BK Ok
        uint256 userContributionTotal = contributions[_contributerAddress];
        // Deduct the contribution now to protect against recursive calls
        // BK Ok
        contributions[_contributerAddress] = 0; 
        // Has the contributed total not been reached, but the crowdsale is over?
        // BK Ok
        if (contributedTotal < targetEth) {
            // Target wasn't met, refund the user
            // BK Ok
            assert(_contributerAddress.send(userContributionTotal) == true);
            // Fire event
            // BK Ok - Log event
            Refund(this, _contributerAddress, userContributionTotal);
        } else {
            // Max tokens alloted to this sale agent contract
            // BK Ok
            uint256 totalTokens = rocketPoolToken.getSaleContractTokensLimit(this);
            // BK Ok
            uint256 totalRefund = (contributedTotal - targetEth).mul(userContributionTotal) / contributedTotal;
            // Calculate how many tokens the user gets
            // BK Ok
            rocketPoolToken.mint(_contributerAddress, totalTokens.mul(userContributionTotal) / contributedTotal);
            // Calculate the refund this user will receive
            // BK Ok
            assert(_contributerAddress.send(totalRefund) == true);
            // Fire events
            // BK Ok - Log event
            ClaimTokens(this, _contributerAddress, rocketPoolToken.balanceOf(_contributerAddress));
            // BK Ok - Log event
            Refund(this, _contributerAddress, totalRefund);
        }
    }


    /// @dev onlyOwner - When the sale is finished the owner can flag this and allow tokens + refunds to be collected
    // BK Ok - Only owner can execute
    function setSaleDepositsAllowed(bool _set) external onlyOwner {
        // BK Ok
        saleDepositsAllowed = _set;
    }

  
    /// @dev onlyOwner - Can kill the contract and claim any ether left in it, can only do this 6 months after it has been deployed, good as a backup
    // BK Ok - Only owner can execute
    function kill() external onlyOwner {
        // Only allow access after 6 months
        // BK NOTE - 26 weeks is closer to 6 months
        // BK Ok
        assert (now >= (deployedTime + 24 weeks));
        // Now self destruct and send any dust/ether left over
        // BK Ok
        selfdestruct(msg.sender);
    }


}

```
