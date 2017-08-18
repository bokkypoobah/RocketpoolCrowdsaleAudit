# Owned

Source file [../../../contracts/base/Owned.sol](../../../contracts/base/Owned.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
contract Owned {

    // BK Ok
    address public owner;
    // BK Ok
    address public newOwner;
    // BK Ok
    event OwnershipTransferred(address indexed _from, address indexed _to);

    // BK Ok - Constructor
    function Owned() {
        // BK Ok
        owner = msg.sender;
    }

    // BK Ok
    modifier onlyOwner {
        // BK Ok
        require(msg.sender == owner);
        // BK Ok
        _;
    }

    // BK Ok - Only owner can execute
    function transferOwnership(address _newOwner) onlyOwner {
        // BK Ok
        newOwner = _newOwner;
    }

    // BK Ok - Only new owner can execute
    function acceptOwnership() {
        // BK Ok
        require(msg.sender == newOwner);
        // BK Ok - Log event
        OwnershipTransferred(owner, newOwner);
        // BK Ok
        owner = newOwner;
    }
    
}
```
