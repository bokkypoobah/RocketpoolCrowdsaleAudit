# Migrations

Source file [../../contracts/Migrations.sol](../../contracts/Migrations.sol).

<br />

<hr />

```javascript
// Note: For some reason Migrations.sol needs to be in the root or they run everytime

pragma solidity ^0.4.11;

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function Migrations() {
    owner = msg.sender;
  }

  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}

```
