# RocketPool Presale And Crowdsale Contracts Audit

Commit [5af99719](https://github.com/darcius/rocketpool-crowdsale/tree/5af997191a939a5a3f9ea38a696da155e53455f6), [8147b2f2](https://github.com/darcius/rocketpool-crowdsale/tree/8147b2f2f4c535777ab5750240709748dfee0377).

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
* **LOW IMPORTANCE** Consider replacing the custom Arithmetic.sol library with the standard `uint` maths as the use cases in 
  *RocketPoolPresale* and *RocketPoolCrowdsale*  seems suitable for the standard `uint` maths.

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