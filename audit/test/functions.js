// Aug 01 2017
var ethPriceUSD = 264.5430;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Multisig");
addAccount(eth.accounts[3], "Account #3");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
addAccount(eth.accounts[8], "Account #8");

var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var multisig = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  var block = eth.getBlock(txReceipt.blockNumber);
  console.log("RESULT: " + name + " status=" + txReceipt.status + " gas=" + tx.gas +
    " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH + " costUSD=" + gasCostUSD +
    " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId +
    " @ " + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function failIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 0) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 1) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
//Wait until some unixTime + additional seconds
//-----------------------------------------------------------------------------
function waitUntil(message, unixTime, addSeconds) {
var t = parseInt(unixTime) + parseInt(addSeconds) + parseInt(1);
var time = new Date(t * 1000);
console.log("RESULT: Waiting until '" + message + "' at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
while ((new Date()).getTime() <= time.getTime()) {
}
console.log("RESULT: Waited until '" + message + "' at at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// Wait until some block
//-----------------------------------------------------------------------------
function waitUntilBlock(message, block, addBlocks) {
var b = parseInt(block) + parseInt(addBlocks);
console.log("RESULT: Waiting until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= b) {
}
console.log("RESULT: Waited until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// Crowdsale Contract
//-----------------------------------------------------------------------------
var crowdsaleContractAddress = null;
var crowdsaleContractAbi = null;

function addCrowdsaleContractAddressAndAbi(address, abi) {
  crowdsaleContractAddress = address;
  crowdsaleContractAbi = abi;
}

var crowdsaleFromBlock = 0;
function printCrowdsaleContractDetails() {
  console.log("RESULT: crowdsaleContractAddress=" + crowdsaleContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    console.log("RESULT: crowdsale.owner=" + contract.owner());
    console.log("RESULT: crowdsale.newOwner=" + contract.newOwner());
    console.log("RESULT: crowdsale.contributedTotal=" + contract.contributedTotal().shift(-18));
    console.log("RESULT: crowdsale.targetEthSent=" + contract.targetEthSent());
    console.log("RESULT: crowdsale.saleDepositsAllowed=" + contract.saleDepositsAllowed());
    console.log("RESULT: crowdsale.deployedTime=" + contract.deployedTime() + " " + new Date(contract.deployedTime() * 1000).toUTCString());

    var latestBlock = eth.blockNumber;
    var i;

    var flagIntEvents = contract.FlagInt({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    flagIntEvents.watch(function (error, result) {
      console.log("RESULT: FlagInt " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    flagIntEvents.stopWatching();

    var flagUintEvents = contract.FlagUint({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    flagUintEvents.watch(function (error, result) {
      console.log("RESULT: FlagUint " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    flagUintEvents.stopWatching();

    var flagAddressEvents = contract.FlagAddress({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    flagAddressEvents.watch(function (error, result) {
      console.log("RESULT: FlagAddress " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    flagAddressEvents.stopWatching();
    
    var contributeEvents = contract.Contribute({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    contributeEvents.watch(function (error, result) {
      console.log("RESULT: Contribute " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    contributeEvents.stopWatching();

    var finaliseSaleEvents = contract.FinaliseSale({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    finaliseSaleEvents.watch(function (error, result) {
      console.log("RESULT: FinaliseSale " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    finaliseSaleEvents.stopWatching();

    var refundEvents = contract.Refund({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    refundEvents.watch(function (error, result) {
      console.log("RESULT: Refund " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    refundEvents.stopWatching();

    var claimTokensEvents = contract.ClaimTokens({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    claimTokensEvents.watch(function (error, result) {
      console.log("RESULT: ClaimTokens " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    claimTokensEvents.stopWatching();

    var transferToDepositAddressEvents = contract.TransferToDepositAddress({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    transferToDepositAddressEvents.watch(function (error, result) {
      console.log("RESULT: TransferToDepositAddress " + i++ + " #" + result.blockNumber + ": " + JSON.stringify(result.args));
    });
    transferToDepositAddressEvents.stopWatching();

    crowdsaleFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  // console.log("RESULT: tokenContractAbi=" + JSON.stringify(tokenContractAbi));
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.newOwner=" + contract.newOwner());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: token.totalSupplyCap=" + contract.totalSupplyCap().shift(-decimals));
    console.log("RESULT: token.getSaleContractIsFinalised['sale']=" + contract.getSaleContractIsFinalised(crowdsaleContractAddress));
    console.log("RESULT: token.getSaleContractTargetEtherMin['sale']=" + contract.getSaleContractTargetEtherMin(crowdsaleContractAddress).shift(-18));
    console.log("RESULT: token.getSaleContractTargetEtherMax['sale']=" + contract.getSaleContractTargetEtherMax(crowdsaleContractAddress).shift(-18));
    console.log("RESULT: token.getSaleContractDepositEtherMin['sale']=" + contract.getSaleContractDepositEtherMin(crowdsaleContractAddress).shift(-18));
    console.log("RESULT: token.getSaleContractDepositEtherMax['sale']=" + contract.getSaleContractDepositEtherMax(crowdsaleContractAddress).shift(-18));
    console.log("RESULT: token.getSaleContractDepositAddress['sale']=" + contract.getSaleContractDepositAddress(crowdsaleContractAddress));
    console.log("RESULT: token.getSaleContractDepositAddressVerified['sale']=" + contract.getSaleContractDepositAddressVerified(crowdsaleContractAddress));
    console.log("RESULT: token.getSaleContractStartBlock['sale']=" + contract.getSaleContractStartBlock(crowdsaleContractAddress));
    console.log("RESULT: token.getSaleContractEndBlock['sale']=" + contract.getSaleContractEndBlock(crowdsaleContractAddress));
    console.log("RESULT: token.getSaleContractTokensLimit['sale']=" + contract.getSaleContractTokensLimit(crowdsaleContractAddress).shift(-decimals));
    console.log("RESULT: token.getSaleContractTokensMinted['sale']=" + contract.getSaleContractTokensMinted(crowdsaleContractAddress).shift(-decimals));

    var latestBlock = eth.blockNumber;
    var i;

    var mintTokenEvents = contract.MintToken({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    mintTokenEvents.watch(function (error, result) {
      console.log("RESULT: MintToken " + i++ + " #" + result.blockNumber + ": _agent=" + result.args._agent +
          " _address=" + result.args._address + " _value=" + result.args._value.shift(-decimals));
    });
    mintTokenEvents.stopWatching();

    var saleFinalisedEvents = contract.SaleFinalised({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    saleFinalisedEvents.watch(function (error, result) {
      console.log("RESULT: SaleFinalised " + i++ + " #" + result.blockNumber + ": _agent=" + result.args._agent +
          " _address=" + result.args._address + " _value=" + result.args._value.shift(-decimals));
    });
    saleFinalisedEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + ": _owner=" + result.args._owner + " _spender=" + result.args._spender + " _value=" +
        result.args._value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": _from=" + result.args._from + " _to=" + result.args._to +
        " _value=" + result.args._value.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = parseInt(latestBlock) + 1;
  }
}
