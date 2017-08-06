# Owned

Source file [../../../contracts/base/Owned.sol](../../../contracts/base/Owned.sol).

<br />

<hr />

```javascript
pragma solidity ^0.4.2;

contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}
```
