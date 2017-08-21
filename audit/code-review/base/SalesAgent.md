# SalesAgent

Source file [../../../contracts/base/SalesAgent.sol](../../../contracts/base/SalesAgent.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
import "../RocketPoolToken.sol";

/// @title An sales agent for token sales contracts (ie crowdsale, presale, quarterly sale etc)
/// @author David Rugendyke - http://www.rocketpool.net

// BK Ok
contract SalesAgent {

     /**** Properties ***********/

    // BK Ok
    address tokenContractAddress;                           // Main contract token address
    // BK Ok
    mapping (address => uint256) public contributions;      // Contributions per address  
    // BK Ok
    uint256 public contributedTotal;                        // Total ETH contributed                   

    /**** Modifiers ***********/

    /// @dev Only allow access from the main token contract
    // BK Ok
    modifier onlyTokenContract() {
        // BK Ok
        assert(tokenContractAddress != 0 && msg.sender == tokenContractAddress);
        // BK Ok
        _;
    }

    /*** Events ****************/

    // BK Next 5 Ok
    event Contribute(address _agent, address _sender, uint256 _value);
    event FinaliseSale(address _agent, address _sender, uint256 _value);
    event Refund(address _agent, address _sender, uint256 _value);
    event ClaimTokens(address _agent, address _sender, uint256 _value); 
    event TransferToDepositAddress(address _agent, address _sender, uint256 _value);

    /*** Tests *****************/

    // BK Next 3 Ok
    event FlagInt(int256 flag);
    event FlagUint(uint256 flag);
    event FlagAddress(address flag);

    /*** Methods ****************/
    
    /// @dev Get the contribution total of ETH from a contributor
    /// @param _owner The owners address
    // BK Ok - Constant function
    function getContributionOf(address _owner) constant returns (uint256 balance) {
        // BK Ok
        return contributions[_owner];
    }

    /// @dev The address used for the depositAddress must checkin with the contract to verify it can interact with this contract, must happen or it won't accept funds
    // BK Ok - Only the depositAddress account can call this function as the last statement below will reject any other accounts
    function setDepositAddressVerify() public {
        // Get the token contract
        // BK Ok
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Is it the right address? Will throw if incorrect
        // BK Only SalesAgents previously registered with the token contracts can execute the following function
        rocketPoolToken.setSaleContractDepositAddressVerified(msg.sender);
    }

}
```
