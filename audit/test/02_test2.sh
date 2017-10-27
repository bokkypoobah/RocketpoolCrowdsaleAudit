#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# First parameter "presale" (default) or "crowdsale"
# SALETYPE=${1:-presale}
# Second parameter "success" (default) or "failure"
# FUNDING=${1:-success}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSBASEDIR=`grep ^CONTRACTSBASEDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSINTERFACEDIR=`grep ^CONTRACTSINTERFACEDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSLIBDIR=`grep ^CONTRACTSLIBDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSSALESDIR=`grep ^CONTRACTSSALESDIR= settings.txt | sed "s/^.*=//"`

ROCKETPOOLTOKENSOL=`grep ^ROCKETPOOLTOKENSOL= settings.txt | sed "s/^.*=//"`
ROCKETPOOLTOKENTEMPSOL=`grep ^ROCKETPOOLTOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
ROCKETPOOLTOKENJS=`grep ^ROCKETPOOLTOKENJS= settings.txt | sed "s/^.*=//"`

ROCKETPOOLCROWDSALESOL=`grep ^ROCKETPOOLCROWDSALESOL= settings.txt | sed "s/^.*=//"`
ROCKETPOOLCROWDSALETEMPSOL=`grep ^ROCKETPOOLCROWDSALETEMPSOL= settings.txt | sed "s/^.*=//"`
ROCKETPOOLCROWDSALEJS=`grep ^ROCKETPOOLCROWDSALEJS= settings.txt | sed "s/^.*=//"`

ROCKETPOOLPRESALESOL=`grep ^ROCKETPOOLPRESALESOL= settings.txt | sed "s/^.*=//"`
ROCKETPOOLPRESALETEMPSOL=`grep ^ROCKETPOOLPRESALETEMPSOL= settings.txt | sed "s/^.*=//"`
ROCKETPOOLPRESALEJS=`grep ^ROCKETPOOLPRESALEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+60" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*2" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

# TEST2OUTPUT=`basename -s ".txt" ${TEST2OUTPUT}`_${SALETYPE}_${FUNDING}.txt
# TEST2RESULTS=`basename -s ".txt" ${TEST2RESULTS}`_${SALETYPE}_${FUNDING}.txt

# printf "SALETYPE                   = '$SALETYPE'. Options 'presale' (default) or 'crowdsale'\n" | tee $TEST2OUTPUT
# printf "FUNDING                    = '$FUNDING'. Options 'success' (default) or 'failure'\n" | tee -a $TEST2OUTPUT

printf "GETHATTACHPOINT            = '$GETHATTACHPOINT'\n" | tee $TEST2OUTPUT
printf "PASSWORD                   = '$PASSWORD'\n" | tee -a $TEST2OUTPUT

printf "CONTRACTSDIR               = '$CONTRACTSDIR'\n" | tee -a $TEST2OUTPUT
printf "CONTRACTSBASEDIR           = '$CONTRACTSBASEDIR'\n" | tee -a $TEST2OUTPUT
printf "CONTRACTSINTERFACEDIR      = '$CONTRACTSINTERFACEDIR'\n" | tee -a $TEST2OUTPUT
printf "CONTRACTSLIBDIR            = '$CONTRACTSLIBDIR'\n" | tee -a $TEST2OUTPUT
printf "CONTRACTSSALESDIR          = '$CONTRACTSSALESDIR'\n" | tee -a $TEST2OUTPUT

printf "ROCKETPOOLTOKENSOL         = '$ROCKETPOOLTOKENSOL'\n" | tee -a $TEST2OUTPUT
printf "ROCKETPOOLTOKENTEMPSOL     = '$ROCKETPOOLTOKENTEMPSOL'\n" | tee -a $TEST2OUTPUT
printf "ROCKETPOOLTOKENJS          = '$ROCKETPOOLTOKENJS'\n" | tee -a $TEST2OUTPUT

printf "ROCKETPOOLCROWDSALESOL     = '$ROCKETPOOLCROWDSALESOL'\n" | tee -a $TEST2OUTPUT
printf "ROCKETPOOLCROWDSALETEMPSOL = '$ROCKETPOOLCROWDSALETEMPSOL'\n" | tee -a $TEST2OUTPUT
printf "ROCKETPOOLCROWDSALEJS      = '$ROCKETPOOLCROWDSALEJS'\n" | tee -a $TEST2OUTPUT

printf "ROCKETPOOLPRESALESOL       = '$ROCKETPOOLPRESALESOL'\n" | tee -a $TEST2OUTPUT
printf "ROCKETPOOLPRESALETEMPSOL   = '$ROCKETPOOLPRESALETEMPSOL'\n" | tee -a $TEST2OUTPUT
printf "ROCKETPOOLPRESALEJS        = '$ROCKETPOOLPRESALEJS'\n" | tee -a $TEST2OUTPUT

printf "DEPLOYMENTDATA            = '$DEPLOYMENTDATA'\n" | tee -a $TEST2OUTPUT
printf "INCLUDEJS                 = '$INCLUDEJS'\n" | tee -a $TEST2OUTPUT
printf "TEST2OUTPUT               = '$TEST2OUTPUT'\n" | tee -a $TEST2OUTPUT
printf "TEST2RESULTS              = '$TEST2RESULTS'\n" | tee -a $TEST2OUTPUT
printf "CURRENTTIME               = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST2OUTPUT
printf "STARTTIME                 = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST2OUTPUT
printf "ENDTIME                   = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST2OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp -rp $CONTRACTSBASEDIR/* .`
`cp -rp $CONTRACTSINTERFACEDIR/* .`
`cp -rp $CONTRACTSLIBDIR/* .`
`cp -rp $CONTRACTSSALESDIR/* .`
`cp $CONTRACTSDIR/$ROCKETPOOLTOKENSOL $ROCKETPOOLTOKENTEMPSOL`

# --- Modify parameters ---
`perl -pi -e "s/\.+\/base\///" *.sol`
`perl -pi -e "s/\.+\/interface\///" *.sol`
`perl -pi -e "s/\.+\/lib\///" *.sol`
`perl -pi -e "s/\.+\/sales\///" *.sol`
`perl -pi -e "s/\.\.\///" *.sol`
#`perl -pi -e "s/DURATION \= 14 days/DURATION \= 4 minutes/" $STOXSMARTTOKENSALETEMPSOL`
#`perl -pi -e "s/now\.add\(1 years\)/now\.add\(5 minutes\)/" $STOXSMARTTOKENSALETEMPSOL`
#`perl -pi -e "s/0xb54c6a870d4aD65e23d471Fb7941aD271D323f5E/0xa99A0Ae3354c06B1459fd441a32a3F71005D7Da0/" $STOXSMARTTOKENSALETEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103123/0xacca534c9f62ab495bd986e002ddf0f054caae4f/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103124/0xadda9b762a00ff12711113bfdc36958b73d7f915/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103125/0xaeea63b5479b50f79583ec49dacdcf86ddeff392/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/0x0010230123012010312300102301230120103129/0xaffa4d3a80add8ce4018540e056dacb649589394/" $STOXSMARTTOKENTEMPSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$ROCKETPOOLTOKENSOL $ROCKETPOOLTOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$ROCKETPOOLTOKENSOL $ROCKETPOOLTOKENTEMPSOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

solc_0.4.16 --version | tee -a $TEST2OUTPUT
echo "var tokenOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $ROCKETPOOLTOKENTEMPSOL`;" > $ROCKETPOOLTOKENJS
echo "var presaleOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $ROCKETPOOLPRESALETEMPSOL`;" > $ROCKETPOOLPRESALEJS
echo "var crowdsaleOutput=`solc_0.4.16 --optimize --combined-json abi,bin,interface $ROCKETPOOLCROWDSALETEMPSOL`;" > $ROCKETPOOLCROWDSALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST2OUTPUT
loadScript("$ROCKETPOOLTOKENJS");
loadScript("$ROCKETPOOLPRESALEJS");
loadScript("$ROCKETPOOLCROWDSALEJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$ROCKETPOOLTOKENTEMPSOL:RocketPoolToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$ROCKETPOOLTOKENTEMPSOL:RocketPoolToken"].bin;

var presaleAbi = JSON.parse(presaleOutput.contracts["$ROCKETPOOLPRESALETEMPSOL:RocketPoolPresale"].abi);
var presaleBin = "0x" + presaleOutput.contracts["$ROCKETPOOLPRESALETEMPSOL:RocketPoolPresale"].bin;

var crowdsaleAbi = JSON.parse(crowdsaleOutput.contracts["$ROCKETPOOLCROWDSALETEMPSOL:RocketPoolCrowdsale"].abi);
var crowdsaleBin = "0x" + crowdsaleOutput.contracts["$ROCKETPOOLCROWDSALETEMPSOL:RocketPoolCrowdsale"].bin;

console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + tokenBin);
console.log("DATA: presaleAbi=" + JSON.stringify(presaleAbi));
// console.log("DATA: presaleBin=" + presaleBin);
console.log("DATA: crowdsaleAbi=" + JSON.stringify(crowdsaleAbi));
// console.log("DATA: crowdsaleBin=" + crowdsaleBin);

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy RocketPoolToken";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        printTxData("tokenAddress=" + tokenAddress, tokenTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, tokenMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var crowdsaleMessage = "Deploy RocketPoolCrowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + crowdsaleMessage);
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
var crowdsaleTx = null;
var crowdsaleAddress = null;
var crowdsale = crowdsaleContract.new(tokenAddress, {from: contractOwnerAccount, data: crowdsaleBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        crowdsaleTx = contract.transactionHash;
      } else {
        crowdsaleAddress = contract.address;
        addAccount(crowdsaleAddress, "RocketPoolCrowdsale");
        addCrowdsaleContractAddressAndAbi(crowdsaleAddress, crowdsaleAbi);
        printTxData("crowdsaleAddress=" + crowdsaleAddress, crowdsaleTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(crowdsaleTx, crowdsaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var configCrowdsaleMessage = "Configure Crowdsale";
// totalSupply = 36 million RPL
// cap USD 3.5 million = 11895 ETH @ 294.23 ETH/USD
// Round to 12k ETH
// 25% to 30 in presale, so 3k ETH for 9m tokens
// -----------------------------------------------------------------------------
console.log("RESULT: " + configCrowdsaleMessage);

var targetEthMin = web3.toWei("100", "ether");
var targetEthMax = web3.toWei("3000", "ether");
var tokensLimit = new BigNumber("9000000").shift(18);
var minDeposit = web3.toWei("0.1", "ether");
var maxDeposit = web3.toWei("20100", "ether");
var startBlock = eth.blockNumber + 5;
var endBlock = eth.blockNumber + 20;

var configCrowdsaleTx = token.setSaleAgentContract(crowdsaleAddress, "Crowdsale", targetEthMin, targetEthMax, tokensLimit,
  minDeposit, maxDeposit, startBlock, endBlock, multisig, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("configCrowdsaleTx", configCrowdsaleTx);
printBalances();
failIfTxStatusError(configCrowdsaleTx, configCrowdsaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var verifyCrowdsaleDepositAddressMessage = "Verify Crowdsale Deposit Address";
// -----------------------------------------------------------------------------
console.log("RESULT: " + verifyCrowdsaleDepositAddressMessage);
var verifyCrowdsaleDepositAddressTx = crowdsale.setDepositAddressVerify({from: multisig, gas: 4000000});
var satSaleDepositAllowedTx = crowdsale.setSaleDepositsAllowed(true, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("verifyCrowdsaleDepositAddressTx", verifyCrowdsaleDepositAddressTx);
printTxData("satSaleDepositAllowedTx", satSaleDepositAllowedTx);
printBalances();
failIfTxStatusError(verifyCrowdsaleDepositAddressTx, verifyCrowdsaleDepositAddressMessage);
failIfTxStatusError(satSaleDepositAllowedTx, verifyCrowdsaleDepositAddressMessage + " - setSaleDepositsAllowed(true)");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntilBlock("startBlock", startBlock, 0);


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = eth.sendTransaction({from: account3, to: crowdsaleAddress, gas: 400000, value: web3.toWei("10.1", "ether")});
while (txpool.status.pending > 0) {
}
var validContribution2Tx = eth.sendTransaction({from: account4, to: crowdsaleAddress, gas: 400000, value: web3.toWei("20.2", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfTxStatusError(validContribution1Tx, validContribution1Message + " ac3 10.1 ETH");
failIfTxStatusError(validContribution2Tx, validContribution1Message + " ac4 20.2 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


waitUntilBlock("endBlock", endBlock, 0);


// -----------------------------------------------------------------------------
var setSaleDepositAllowedMessage = "Set Sale Deposit Allowed";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setSaleDepositAllowedMessage);
var setSaleDepositAllowedTx = crowdsale.setSaleDepositsAllowed(false, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("setSaleDepositAllowedTx", setSaleDepositAllowedTx);
printBalances();
failIfTxStatusError(setSaleDepositAllowedTx, setSaleDepositAllowedMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var claimTokens1Message = "Claim Tokens And Refunds";
// -----------------------------------------------------------------------------
console.log("RESULT: " + claimTokens1Message);
var claimTokens1Tx = crowdsale.claimTokensAndRefund({from: account3, to: crowdsaleAddress, gas: 400000});
var claimTokens2Tx = crowdsale.claimTokensAndRefund({from: account4, to: crowdsaleAddress, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("claimTokens1Tx", claimTokens1Tx);
printTxData("claimTokens2Tx", claimTokens2Tx);
printBalances();
failIfTxStatusError(claimTokens1Tx, claimTokens1Message + " ac3");
failIfTxStatusError(claimTokens2Tx, claimTokens1Message + " ac4");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
