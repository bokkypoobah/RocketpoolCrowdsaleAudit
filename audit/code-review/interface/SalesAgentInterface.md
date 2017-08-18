# SalesAgentInterface

Source file [../../../contracts/interface/SalesAgentInterface.sol](../../../contracts/interface/SalesAgentInterface.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.11;


/// @title An interface for token sales agent contracts (ie crowdsale, presale, quarterly sale etc)
/// @author David Rugendyke - http://www.rocketpool.net

// BK Ok
contract SalesAgentInterface {
     /**** Properties ***********/
    // Main contract token address
    // BK Ok
    address tokenContractAddress;
    // Contributions per address
    // BK Ok
    mapping (address => uint256) public contributions;    
    // Total ETH contributed
    // BK Ok     
    uint256 public contributedTotal;                       
    /// @dev Only allow access from the main token contract
    // BK NOTE - Check that this modifier is not used incorrectly
    modifier onlyTokenContract() {_;}
    /*** Events ****************/
    // BK Next 4 Ok
    event Contribute(address _agent, address _sender, uint256 _value);
    event FinaliseSale(address _agent, address _sender, uint256 _value);
    event Refund(address _agent, address _sender, uint256 _value);
    event ClaimTokens(address _agent, address _sender, uint256 _value);  
    /*** Methods ****************/
    /// @dev The address used for the depositAddress must checkin with the contract to verify it can interact with this contract, must happen or it won't accept funds
    // BK Ok - Not used
    function getDepositAddressVerify() public;
    /// @dev Get the contribution total of ETH from a contributor
    /// @param _owner The owners address
    // BK Ok
    function getContributionOf(address _owner) constant returns (uint256 balance);
}
```
