# RocketPoolToken

Source file [../../contracts/RocketPoolToken.sol](../../contracts/RocketPoolToken.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.11;
import "./base/Owned.sol";
import "./base/StandardToken.sol";
import "./interface/SalesAgentInterface.sol";
import "./lib/SafeMath.sol";

/// @title The main Rocket Pool Token (RPL) contract
/// @author David Rugendyke - http://www.rocketpool.net

/*****************************************************************
*   This is the main Rocket Pool Token (RPL) contract. It features
*   Smart Agent compatibility. The Sale Agent is a new type of 
*   contract that can authorise the minting of tokens on behalf of
*   the traditional ERC20 token contract. This allows you to 
*   distribute your ICO tokens through multiple Sale Agents, 
*   at various times, of various token quantities and of varying
*   fund targets. Once you’ve written a new Sale Agent contract,
*   you can register him with the main ERC20 token contract, 
*   he’s then permitted to sell it’s tokens on your behalf using
*   guidelines such as the amount of tokens he’s allowed to sell, 
*   the maximum ether he’s allowed to raise, the start block and
*   end blocks he’s allowed to sell between and more.
/****************************************************************/

// BK Ok
contract RocketPoolToken is StandardToken, Owned {

     /**** Properties ***********/

    // BK Ok
    string public name = 'Rocket Pool';
    // BK Ok
    string public symbol = 'RPL';
    // BK Ok
    string public version = "1.0";
    // Set our token units
    // BK Ok - Using the correct `uint8` data type
    uint8 public constant decimals = 18;
    // BK Ok
    uint256 public exponent = 10**uint256(decimals);
    // BK Ok
    uint256 public totalSupply = 0;                             // The total of tokens currently minted by sales agent contracts
    // BK Ok    
    uint256 public totalSupplyCap = 50 * (10**6) * exponent;    // 50 Million tokens


    /**** Libs *****************/
    
    // BK Ok
    using SafeMath for uint;                           
    
    
    /*** Sale Addresses *********/
       
    // BK Ok
    mapping (address => salesAgent) private salesAgents;   // Our contract addresses of our sales contracts
    // BK Ok - Saved, but never used
    address[] private salesAgentsAddresses;                // Keep an array of all our sales agent addresses for iteration

    /*** Structs ***************/
             
    // BK Ok
    struct salesAgent {                     // These are contract addresses that are authorised to mint tokens
        // BK Ok
        address saleContractAddress;        // Address of the contract
        // BK Ok - Saved as `sha3(string)`
        bytes32 saleContractType;           // Type of the contract ie. presale, crowdsale
        // BK Next 7 Ok 
        uint256 targetEthMax;               // The max amount of ether the agent is allowed raise
        uint256 targetEthMin;               // The min amount of ether to raise to consider this contracts sales a success
        uint256 tokensLimit;                // The maximum amount of tokens this sale contract is allowed to distribute
        uint256 tokensMinted;               // The current amount of tokens minted by this agent
        uint256 minDeposit;                 // The minimum deposit amount allowed
        uint256 maxDeposit;                 // The maximum deposit amount allowed
        uint256 startBlock;                 // The start block when allowed to mint tokens
        // BK Ok - This can be set to 0 for no end block - sale ended by finalise
        uint256 endBlock;                   // The end block when to finish minting tokens
        // BK Ok
        address depositAddress;             // The address that receives the ether for that sale contract
        // BK Ok - Deposit address must call a function to register it is correct
        bool depositAddressCheckedIn;       // The address that receives the ether for that sale contract must check in with its sale contract to verify its a valid address that can interact
        // BK Ok
        bool finalised;                     // Has this sales contract been completed and the ether sent to the deposit address?
        // BK Ok
        bool exists;                        // Check to see if the mapping exists
    }

    /*** Events ****************/

    // BK Next 2 Ok
    event MintToken(address _agent, address _address, uint256 _value);
    event SaleFinalised(address _agent, address _address, uint256 _value);
  
    /*** Tests *****************/

    // BK Next 2 Ok - For debugging
    event FlagUint(uint256 flag);
    event FlagAddress(address flag);

    
    /*** Modifiers *************/

    /// @dev Only allow access from the latest version of a sales contract
    // BK Ok
    modifier isSalesContract(address _sender) {
        // Is this an authorised sale contract?
        // BK Ok
        assert(salesAgents[_sender].exists == true);
        // BK Ok
        _;
    }

    
    /**** Methods ***********/

    /// @dev RPL Token Init
    // BK Ok - Constructor
    function RocketPoolToken() {}


    // @dev General validation for a sales agent contract receiving a contribution, additional validation can be done in the sale contract if required
    // @param _value The value of the contribution in wei
    // @return A boolean that indicates if the operation was successful.
    // BK Ok
    function validateContribution(uint256 _value) isSalesContract(msg.sender) returns (bool) {
        // Get an instance of the sale agent contract
        // BK Ok
        SalesAgentInterface saleAgent = SalesAgentInterface(msg.sender);
        // Did they send anything from a proper address?
        // BK Ok
        assert(_value > 0);  
        // Check the depositAddress has been verified by the account holder
        // BK Ok
        assert(salesAgents[msg.sender].depositAddressCheckedIn == true);
        // Check if we're ok to receive contributions, have we started?
        // BK Ok
        assert(block.number > salesAgents[msg.sender].startBlock);       
        // Already ended? Or if the end block is 0, it's an open ended sale until finalised by the depositAddress
        // BK Ok
        assert(block.number < salesAgents[msg.sender].endBlock || salesAgents[msg.sender].endBlock == 0); 
        // Is it above the min deposit amount?
        // BK Ok
        assert(_value >= salesAgents[msg.sender].minDeposit); 
        // Is it below the max deposit allowed?
        // BK Ok
        assert(_value <= salesAgents[msg.sender].maxDeposit); 
        // No contributions if the sale contract has finalised
        // BK Ok
        assert(salesAgents[msg.sender].finalised == false);      
        // Does this deposit put it over the max target ether for the sale contract?
        // BK Ok
        assert(saleAgent.contributedTotal().add(_value) <= salesAgents[msg.sender].targetEthMax);       
        // All good
        // BK Ok
        return true;
    }


    // @dev General validation for a sales agent contract that requires the user claim the tokens after the sale has finished
    // @param _sender The address sent the request
    // @return A boolean that indicates if the operation was successful.
    // BK Ok
    function validateClaimTokens(address _sender) isSalesContract(msg.sender) returns (bool) {
        // Get an instance of the sale agent contract
        // BK Ok
        SalesAgentInterface saleAgent = SalesAgentInterface(msg.sender);
        // Must have previously contributed
        // BK Ok
        assert(saleAgent.getContributionOf(_sender) > 0); 
        // Sale contract completed
        // BK Ok - Note that endBlock can be set to 0 for an open ended sale
        assert(block.number > salesAgents[msg.sender].endBlock);  
        // All good
        // BK Ok
        return true;
    }
    

    // @dev Mint the Rocket Pool Tokens (RPL)
    // @param _to The address that will receive the minted tokens.
    // @param _amount The amount of tokens to mint.
    // @return A boolean that indicates if the operation was successful.
    // BK Ok
    function mint(address _to, uint _amount) isSalesContract(msg.sender) returns (bool) {
        // Check if we're ok to mint new tokens, have we started?
        // We dont check for the end block as some sale agents mint tokens during the sale, and some after its finished (proportional sales)
        // BK Ok
        assert(block.number > salesAgents[msg.sender].startBlock);   
        // Check the depositAddress has been verified by the designated account holder that will receive the funds from that agent
        // BK Ok
        assert(salesAgents[msg.sender].depositAddressCheckedIn == true);
        // No minting if the sale contract has finalised
        // BK Ok
        assert(salesAgents[msg.sender].finalised == false);
        // Check we don't exceed the assigned tokens of the sale agent
        // BK Ok
        assert(salesAgents[msg.sender].tokensLimit >= salesAgents[msg.sender].tokensMinted.add(_amount));
        // Verify ok balances and values
        // BK Ok
        assert(_amount > 0);
         // Check we don't exceed the supply limit
        // BK Ok
        assert(totalSupply.add(_amount) <= totalSupplyCap);
         // Ok all good, automatically checks for overflow with safeMath
        // BK Ok
        balances[_to] = balances[_to].add(_amount);
        // Add to the total minted for that agent, automatically checks for overflow with safeMath
        // BK Ok
        salesAgents[msg.sender].tokensMinted = salesAgents[msg.sender].tokensMinted.add(_amount);
        // Add to the overall total minted, automatically checks for overflow with safeMath
        // BK Ok
        totalSupply = totalSupply.add(_amount);
        // Fire the event
        // BK Ok
        MintToken(msg.sender, _to, _amount);
        // BK NOTE - Should also have a Transfer(0x0, _to, _amount) even so token explorers will pick up the transfer events
        // BK NOTE - and recognise this smart contract as a token contract during the crowdsale period
        // Completed
        // BK Ok
        return true; 
    }

    /// @dev Returns the amount of tokens that can still be minted
    // BK Ok - Constant function
    function getRemainingTokens() public constant returns(uint256)  {
        // BK Ok
        return totalSupplyCap.sub(totalSupply);
    }
    
    /// @dev Set the address of a new crowdsale/presale contract agent if needed, usefull for upgrading
    /// @param _saleAddress The address of the new token sale contract
    /// @param _saleContractType Type of the contract ie. presale, crowdsale, quarterly
    /// @param _targetEthMin The min amount of ether to raise to consider this contracts sales a success
    /// @param _targetEthMax The max amount of ether the agent is allowed raise
    /// @param _tokensLimit The maximum amount of tokens this sale contract is allowed to distribute
    /// @param _minDeposit The minimum deposit amount allowed
    /// @param _maxDeposit The maximum deposit amount allowed
    /// @param _startBlock The start block when allowed to mint tokens
    /// @param _endBlock The end block when to finish minting tokens
    /// @param _depositAddress The address that receives the ether for that sale contract
    // BK Ok - Only the owner can register a SaleAgent
    function setSaleAgentContract(
        address _saleAddress, 
         string _saleContractType, 
        uint256 _targetEthMin, 
        uint256 _targetEthMax, 
        uint256 _tokensLimit, 
        uint256 _minDeposit,
        uint256 _maxDeposit,
        uint256 _startBlock, 
        uint256 _endBlock, 
        address _depositAddress
    ) 
    // Only the owner can register a new sale agent
    public onlyOwner  
    {
        // Valid addresses?
        // BK Ok
        assert(_saleAddress != 0x0 && _depositAddress != 0x0);  
        // Must have some available tokens
        // BK Ok
        assert(_tokensLimit > 0 && _tokensLimit <= totalSupplyCap);
        // Make sure the min deposit is less than or equal to the max
        // BK Ok
        assert(_minDeposit <= _maxDeposit);
        // Add the new sales contract
        // BK Next block Ok
        salesAgents[_saleAddress] = salesAgent({
            saleContractAddress: _saleAddress,       
            saleContractType: sha3(_saleContractType), 
            targetEthMin: _targetEthMin,           
            targetEthMax: _targetEthMax,
            tokensLimit: _tokensLimit,  
            tokensMinted: 0,
            minDeposit: _minDeposit,
            maxDeposit: _maxDeposit,            
            startBlock: _startBlock,                 
            endBlock: _endBlock,              
            depositAddress: _depositAddress, 
            depositAddressCheckedIn: false,  
            finalised: false,     
            exists: true                      
        });
        // Store our agent address so we can iterate over it if needed
        // BK Ok
        salesAgentsAddresses.push(_saleAddress);
    }


    /// @dev Sets the contract sale agent process as completed, that sales agent is now retired
    // BK Ok
    function setSaleContractFinalised(address _sender) isSalesContract(msg.sender) public returns(bool)  {
        // Get an instance of the sale agent contract
        // BK Ok
        SalesAgentInterface saleAgent = SalesAgentInterface(msg.sender);
        // Finalise the crowdsale funds
        // BK Ok - Can only finalise once
        assert(!salesAgents[msg.sender].finalised);                       
        // The address that will receive this contracts deposit, should match the original senders
        // BK Ok
        assert(salesAgents[msg.sender].depositAddress == _sender);            
        // If the end block is 0, it means an open ended crowdsale, once it's finalised, the end block is set to the current one
        // BK Ok
        if(salesAgents[msg.sender].endBlock == 0) {
            // BK Ok
            salesAgents[msg.sender].endBlock = block.number;
        }
        // Not yet finished?
        // BK Ok
        assert(block.number >= salesAgents[msg.sender].endBlock);         
        // Not enough raised?
        // BK Ok
        assert(saleAgent.contributedTotal() >= salesAgents[msg.sender].targetEthMin);
        // We're done now
        // BK Ok
        salesAgents[msg.sender].finalised = true;
        // Fire the event
        // BK Ok - Log ecent
        SaleFinalised(msg.sender, _sender, salesAgents[msg.sender].tokensMinted);
        // All good
        // BK Ok
        return true;
    }


    /// @dev Verifies if the current address matches the depositAddress
    /// @param _verifyAddress The address to verify it matches the depositAddress given for the sales agent
    // BK Ok
    function setSaleContractDepositAddressVerified(address _verifyAddress) isSalesContract(msg.sender) public  {
        // Check its verified
        // BK Ok
        assert(salesAgents[msg.sender].depositAddress == _verifyAddress && _verifyAddress != 0x0);
        // Ok set it now
        salesAgents[msg.sender].depositAddressCheckedIn = true;
    }

    /// @dev Returns true if this sales contract has finalised
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractIsFinalised(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(bool)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].finalised;
    }

    /// @dev Returns the min target amount of ether the contract wants to raise
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractTargetEtherMin(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].targetEthMin;
    }

    /// @dev Returns the max target amount of ether the contract can raise
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractTargetEtherMax(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].targetEthMax;
    }

    /// @dev Returns the min deposit amount of ether
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractDepositEtherMin(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].minDeposit;
    }

    /// @dev Returns the max deposit amount of ether
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractDepositEtherMax(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].maxDeposit;
    }

    /// @dev Returns the address where the sale contracts ether will be deposited
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractDepositAddress(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(address)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].depositAddress;
    }

    /// @dev Returns the true if the sale agents deposit address has been verified
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractDepositAddressVerified(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(bool)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].depositAddressCheckedIn;
    }

    /// @dev Returns the start block for the sale agent
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractStartBlock(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].startBlock;
    }

    /// @dev Returns the start block for the sale agent
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractEndBlock(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].endBlock;
    }

    /// @dev Returns the max tokens for the sale agent
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractTokensLimit(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].tokensLimit;
    }

    /// @dev Returns the token total currently minted by the sale agent
    /// @param _salesAgentAddress The address of the token sale agent contract
    // BK Ok - Constant function
    function getSaleContractTokensMinted(address _salesAgentAddress) constant isSalesContract(_salesAgentAddress) public returns(uint256)  {
        // BK Ok
        return salesAgents[_salesAgentAddress].tokensMinted;
    }

    
}

```
