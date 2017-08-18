# StandardToken

Source file [../../../contracts/base/StandardToken.sol](../../../contracts/base/StandardToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.11;

// BK Ok
contract Token {
    // BK Ok
    uint256 public totalSupply;
    // BK Ok
    function balanceOf(address _owner) constant returns (uint256 balance);
    // BK Ok
    function transfer(address _to, uint256 _value) returns (bool success);
    // BK Ok
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    // BK Ok
    function approve(address _spender, uint256 _value) returns (bool success);
    // BK Ok
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    // BK Ok
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // BK Ok
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
// BK Ok
contract StandardToken is Token {

    // BK Ok
    function transfer(address _to, uint256 _value) returns (bool success) {
      // BK Ok
      if (balances[msg.sender] >= _value && _value > 0) {
        // BK Ok
        balances[msg.sender] -= _value;
        // BK Ok
        balances[_to] += _value;
        // BK Ok - Log event
        Transfer(msg.sender, _to, _value);
        // BK Ok
        return true;
      // BK Ok
      } else {
        // BK Ok
        return false;
      }
    }

    // BK Ok
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      // BK Ok
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        // BK Ok
        balances[_to] += _value;
        // BK Ok
        balances[_from] -= _value;
        // BK Ok
        allowed[_from][msg.sender] -= _value;
        // BK Ok - Log event
        Transfer(_from, _to, _value);
        // BK Ok
        return true;
      // BK Ok
      } else {
        // BK Ok
        return false;
      }
    }

    // BK Ok - Constant function
    function balanceOf(address _owner) constant returns (uint256 balance) {
        // BK Ok
        return balances[_owner];
    }

    // BK Ok
    function approve(address _spender, uint256 _value) returns (bool success) {
        // BK Ok
        allowed[msg.sender][_spender] = _value;
        // BK Ok - Log event
        Approval(msg.sender, _spender, _value);
        // BK Ok
        return true;
    }

    // BK Ok - Constant function
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      // BK Ok
      return allowed[_owner][_spender];
    }

    // BK Ok
    mapping (address => uint256) balances;
    // BK Ok
    mapping (address => mapping (address => uint256)) allowed;
}


```
