# RocketPool Presale And Crowdsale Contracts Audit

Commit [5af99719](https://github.com/darcius/rocketpool-crowdsale/tree/5af997191a939a5a3f9ea38a696da155e53455f6),
[8147b2f2](https://github.com/darcius/rocketpool-crowdsale/tree/8147b2f2f4c535777ab5750240709748dfee0377),
[19372b87](https://github.com/darcius/rocketpool-crowdsale/tree/19372b8736371810ed0e5268281dc7563127a269)

<br />

<hr />

## Recommendations

* **MEDIUM IMPORTANCE** Upgrade minimum compiler version from `pragma solidity ^0.4.2;` to `pragma solidity ^0.4.13;` or `pragma solidity ^0.4.11;`.
  You may have to replace your `throw` code with `require(...)` or `assert(...)` if you upgrade to 0.4.13.
  * [x] Completed in [8147b2f2](https://github.com/darcius/rocketpool-crowdsale/commit/8147b2f2f4c535777ab5750240709748dfee0377)
* **LOW IMPORTANCE** Use the `acceptOwnership(...)` pattern in the *Owned* contracts for a much safer transfer of ownership.
  See the [example](https://github.com/openanx/OpenANXToken/blob/master/contracts/Owned.sol#L51-L55).
  * [x] Completed in [8147b2f2](https://github.com/darcius/rocketpool-crowdsale/commit/8147b2f2f4c535777ab5750240709748dfee0377)
* **LOW IMPORTANCE** Replace `uint256 public constant decimals = 18;` with `uint8 public constant decimals = 18;` in **RocketPoolToken** as `uint8`
  is meant to be the standard, although some token contracts use `uint256` and no side effects have been reported. If you use `uint8`, you will
  have to replace `10**decimals;` with `10**uint256(decimals);` in the next statement.
  * [x] Completed in [8147b2f2](https://github.com/darcius/rocketpool-crowdsale/commit/8147b2f2f4c535777ab5750240709748dfee0377)
* **LOW IMPORTANCE** Consider using a neater way for calling the SafeMath library - see
  [OpenANXToken.sol#L23](https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L23) and 
  [OpenANXToken.sol#L76-L77](https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L76-L77).
  * [x] Completed in [19372b87](https://github.com/darcius/rocketpool-crowdsale/commit/19372b8736371810ed0e5268281dc7563127a269)
* **LOW IMPORTANCE** Consider replacing the custom Arithmetic.sol library with the standard `uint` maths as the use cases in 
  *RocketPoolPresale* and *RocketPoolCrowdsale*  seems suitable for the standard `uint` maths.

  Example from David:

      User makes deposit of '1.3463233' ether when each token costs 0.00032 per ether.

      Excel = 4,207.260312500000000000
      Arithmetic Lib = 4207260312500000000000
      SafeMath = 4207000000000000000000
      calculated like this

      FlagUint(Arithmetic.overflowResistantFraction(allocations[msg.sender].amount, exponent, tokenPrice));
      FlagUint(SafeMath.div(allocations[msg.sender].amount, tokenPrice)*exponent);

  My testing using `geth console`:
  
      > new BigNumber("1.3463233").shift(18).mul(100000).div(32).shift(-18)
      4207.2603125
      
  My testing with further decimals using `geth console`:

      new BigNumber("1.3463233123456789").shift(18).mul(100000).div(32).shift(-18)
      4207.2603510802465625

  Sample Solidity code to test David's example:
  
      pragma solidity ^0.4.11;

      contract Test {
          uint256 public result;

          function Test() {
              uint256 ethers = 1346323300000000000; // new BigNumber("1.3463233").shift(18)
              result = ethers * 100000 / 32;
              // Result is 4207260312500000000000
              // new BigNumber("4207260312500000000000").shift(-18) => 4207.2603125
          }
      }

<br />

<hr />

## Code Review

### ./base
* [ ] [code-review/base/Owned.md](code-review/base/Owned.md)
  * [ ] contract Owned
* [ ] [code-review/base/SalesAgent.md](code-review/base/SalesAgent.md)
  * [ ] contract SalesAgent
* [ ] [code-review/base/StandardToken.md](code-review/base/StandardToken.md)
  * [ ] contract Token
  * [ ] contract StandardToken is Token

### ./interface

* [ ] [code-review/interface/SalesAgentInterface.md](code-review/interface/SalesAgentInterface.md)
  * [ ] contract SalesAgentInterface

### ./lib

* [ ] [code-review/lib/Arithmetic.md](code-review/lib/Arithmetic.md)
* [ ] [code-review/lib/SafeMath.md](code-review/lib/SafeMath.md)

### ./sales
* [ ] [code-review/RocketPoolCrowdsale.md](code-review/RocketPoolCrowdsale.md)
  * [ ] contract RocketPoolCrowdsale is SalesAgent
* [ ] [code-review/RocketPoolPresale.md](code-review/RocketPoolPresale.md)
  * [ ] contract RocketPoolPresale is SalesAgent, Owned
* [ ] [code-review/RocketPoolReserveFund.md](code-review/RocketPoolReserveFund.md)
  * [ ] contract RocketPoolReserveFund is SalesAgent

### ./

* [ ] [code-review/Migrations.md](code-review/Migrations.md)
  * [ ] contract Migrations
* [ ] [code-review/RocketPoolToken.md](code-review/RocketPoolToken.md)
  * [ ] contract RocketPoolToken is StandardToken, Owned