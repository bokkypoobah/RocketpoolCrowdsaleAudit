# RocketPool Presale And Crowdsale Contracts Audit

Commit [5af99719](https://github.com/darcius/rocketpool-crowdsale/tree/5af997191a939a5a3f9ea38a696da155e53455f6),
[8147b2f2](https://github.com/darcius/rocketpool-crowdsale/tree/8147b2f2f4c535777ab5750240709748dfee0377),
[19372b87](https://github.com/darcius/rocketpool-crowdsale/tree/19372b8736371810ed0e5268281dc7563127a269),
[270c5a09](https://github.com/darcius/rocketpool-crowdsale/tree/270c5a091444ed449d6dcf7cfffb85fabaaae64b),
[4a3d45af](https://github.com/darcius/rocketpool-crowdsale/tree/4a3d45afaf53229ec62cd5003b843ab63d6dddc1).

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
  * [x] Completed in [270c5a09](https://github.com/darcius/rocketpool-crowdsale/commit/270c5a091444ed449d6dcf7cfffb85fabaaae64b)

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

  Comparison of gas between RocketPool's original Arithmetic.sol and Solidity native uint256 divs shows a similar gas usage:
  
      pragma solidity ^0.4.11;
      
      // Arithmetic library borrowed from Gnosis, thanks guys!
      
      library Arithmetic {
      
          function mul256By256(uint a, uint b)
              constant
              returns (uint ab32, uint ab1, uint ab0)
          {
              uint ahi = a >> 128;
              uint alo = a & 2**128-1;
              uint bhi = b >> 128;
              uint blo = b & 2**128-1;
              ab0 = alo * blo;
              ab1 = (ab0 >> 128) + (ahi * blo & 2**128-1) + (alo * bhi & 2**128-1);
              ab32 = (ab1 >> 128) + ahi * bhi + (ahi * blo >> 128) + (alo * bhi >> 128);
              ab1 &= 2**128-1;
              ab0 &= 2**128-1;
          }
      
          // I adapted this from Fast Division of Large Integers by Karl Hasselström
          // Algorithm 3.4: Divide-and-conquer division (3 by 2)
          // Karl got it from Burnikel and Ziegler and the GMP lib implementation
          function div256_128By256(uint a21, uint a0, uint b)
              constant
              returns (uint q, uint r)
          {
              uint qhi = (a21 / b) << 128;
              a21 %= b;
      
              uint shift = 0;
              while(b >> shift > 0) shift++;
              shift = 256 - shift;
              a21 = (a21 << shift) + (shift > 128 ? a0 << (shift - 128) : a0 >> (128 - shift));
              a0 = (a0 << shift) & 2**128-1;
              b <<= shift;
              var (b1, b0) = (b >> 128, b & 2**128-1);
      
              uint rhi;
              q = a21 / b1;
              rhi = a21 % b1;
      
              uint rsub0 = (q & 2**128-1) * b0;
              uint rsub21 = (q >> 128) * b0 + (rsub0 >> 128);
              rsub0 &= 2**128-1;
      
              while(rsub21 > rhi || rsub21 == rhi && rsub0 > a0) {
                  q--;
                  a0 += b0;
                  rhi += b1 + (a0 >> 128);
                  a0 &= 2**128-1;
              }
      
              q += qhi;
              r = (((rhi - rsub21) << 128) + a0 - rsub0) >> shift;
          }
      
          function overflowResistantFraction(uint a, uint b, uint divisor)
              returns (uint)
          {
              uint ab32_q1; uint ab1_r1; uint ab0;
              if(b <= 1 || b != 0 && a * b / b == a) {
                  return a * b / divisor;
              } else {
                  (ab32_q1, ab1_r1, ab0) = mul256By256(a, b);
                  (ab32_q1, ab1_r1) = div256_128By256(ab32_q1, ab1_r1, divisor);
                  (a, b) = div256_128By256(ab1_r1, ab0, divisor);
                  return (ab32_q1 << 128) + a;
              }
          }
      }
      
      contract Test {
          uint256 n1 = 123;
          uint256 n2 = 345;
          uint256 d1 = 111;
      
          uint256 public resultNative;
          uint256 public resultArithmetic;
      
          function testNative() {
              resultNative = n1 * n2 / d1;
          }
      
          function testArithmetic() {
              resultArithmetic = Arithmetic.overflowResistantFraction(n1, n2, d1);
          }
      }

  Results using native:
  
    * Run 1 tx cost 42,066, exec cost 20,795
    * Run 2 tx cost 27,066, exec cost 5,794
    
  Results using Arithmetic:
    * Run 1 tx cost 44,014, exec cost 22,742
    * Run 2 tx cost 29,014, exec cost 7,742

  Result for Native 382, Arithmetic 382

* **LOW IMPORTANCE** Events are normally distinguished from functions by the first letter being capitalised (Upper Camel Case).
  For example `event mintToken(...);` -> `event MintToken(...);` and `event saleFinalised(...);` -> `event SaleFinalised(...);` in
  *RocketPoolToken*
  * [x] Completed in [4a3d45af](https://github.com/darcius/rocketpool-crowdsale/commit/4a3d45afaf53229ec62cd5003b843ab63d6dddc1)

* **MEDIUM IMPORTANCE** Events with the same name are defined with different number of parameters in *SalesAgent* and *SalesAgentInterface* 
  * [x] Completed in [4a3d45af](https://github.com/darcius/rocketpool-crowdsale/commit/4a3d45afaf53229ec62cd5003b843ab63d6dddc1)

<br />

<hr />

## TODO

* [ ] BK Work out a better way to use `modifier onlyTokenContract() {_;}` in *SalesAgentInterface*

<br />

<hr />

## Testing

* Testing script [test/01_test1.sh](test/01_test1.sh)
* Testing results [test/test1results.txt](test/test1results.txt)

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

* [ ] [code-review/lib/SafeMath.md](code-review/lib/SafeMath.md)

### ./sales
* [ ] [code-review/sales/RocketPoolCrowdsale.md](code-review/sales/RocketPoolCrowdsale.md)
  * [ ] contract RocketPoolCrowdsale is SalesAgent
* [ ] [code-review/sales/RocketPoolPresale.md](code-review/sales/RocketPoolPresale.md)
  * [ ] contract RocketPoolPresale is SalesAgent, Owned
* [ ] [code-review/sales/RocketPoolReserveFund.md](code-review/sales/RocketPoolReserveFund.md)
  * [ ] contract RocketPoolReserveFund is SalesAgent

### ./

* [ ] [code-review/Migrations.md](code-review/Migrations.md)
  * [ ] contract Migrations
* [ ] [code-review/RocketPoolToken.md](code-review/RocketPoolToken.md)
  * [ ] contract RocketPoolToken is StandardToken, Owned