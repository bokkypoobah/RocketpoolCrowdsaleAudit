#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSBASEDIR=`grep ^CONTRACTSBASEDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSINTERFACEDIR=`grep ^CONTRACTSINTERFACEDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSLIBDIR=`grep ^CONTRACTSLIBDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSSALESDIR=`grep ^CONTRACTSSALESDIR= settings.txt | sed "s/^.*=//"`

ARITHMETICSOL=`grep ^ARITHMETICSOL= settings.txt | sed "s/^.*=//"`
ARITHMETICTEMPSOL=`grep ^ARITHMETICTEMPSOL= settings.txt | sed "s/^.*=//"`
ARITHMETICJS=`grep ^ARITHMETICJS= settings.txt | sed "s/^.*=//"`

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
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

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

printf "MODE                       = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT            = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD                   = '$PASSWORD'\n" | tee -a $TEST1OUTPUT

printf "CONTRACTSDIR               = '$CONTRACTSDIR'\n" | tee -a $TEST1OUTPUT
printf "CONTRACTSBASEDIR           = '$CONTRACTSBASEDIR'\n" | tee -a $TEST1OUTPUT
printf "CONTRACTSINTERFACEDIR      = '$CONTRACTSINTERFACEDIR'\n" | tee -a $TEST1OUTPUT
printf "CONTRACTSLIBDIR            = '$CONTRACTSLIBDIR'\n" | tee -a $TEST1OUTPUT
printf "CONTRACTSSALESDIR          = '$CONTRACTSSALESDIR'\n" | tee -a $TEST1OUTPUT

printf "ARITHMETICSOL              = '$ARITHMETICSOL'\n" | tee -a $TEST1OUTPUT
printf "ARITHMETICTEMPSOL          = '$ARITHMETICTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "ARITHMETICJS               = '$ARITHMETICJS'\n" | tee -a $TEST1OUTPUT

printf "ROCKETPOOLTOKENSOL         = '$ROCKETPOOLTOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "ROCKETPOOLTOKENTEMPSOL     = '$ROCKETPOOLTOKENTEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "ROCKETPOOLTOKENJS          = '$ROCKETPOOLTOKENJS'\n" | tee -a $TEST1OUTPUT

printf "ROCKETPOOLCROWDSALESOL     = '$ROCKETPOOLCROWDSALESOL'\n" | tee -a $TEST1OUTPUT
printf "ROCKETPOOLCROWDSALETEMPSOL = '$ROCKETPOOLCROWDSALETEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "ROCKETPOOLCROWDSALEJS      = '$ROCKETPOOLCROWDSALEJS'\n" | tee -a $TEST1OUTPUT

printf "ROCKETPOOLPRESALESOL       = '$ROCKETPOOLPRESALESOL'\n" | tee -a $TEST1OUTPUT
printf "ROCKETPOOLPRESALETEMPSOL   = '$ROCKETPOOLPRESALETEMPSOL'\n" | tee -a $TEST1OUTPUT
printf "ROCKETPOOLPRESALEJS        = '$ROCKETPOOLPRESALEJS'\n" | tee -a $TEST1OUTPUT

printf "DEPLOYMENTDATA            = '$DEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS                 = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT               = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS              = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME               = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "STARTTIME                 = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST1OUTPUT
printf "ENDTIME                   = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST1OUTPUT

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
echo "--- Differences $CONTRACTSDIR/$ROCKETPOOLTOKENSOL $ROCKETPOOLTOKENTEMPSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

echo "var arithmeticOutput=`solc_4.1.11 --optimize --combined-json abi,bin,interface $ARITHMETICTEMPSOL`;" > $ARITHMETICJS
echo "var tokenOutput=`solc_4.1.11 --optimize --combined-json abi,bin,interface $ROCKETPOOLTOKENTEMPSOL`;" > $ROCKETPOOLTOKENJS
echo "var presaleOutput=`solc_4.1.11 --optimize --combined-json abi,bin,interface $ROCKETPOOLPRESALETEMPSOL`;" > $ROCKETPOOLPRESALEJS
echo "var crowdsaleOutput=`solc_4.1.11 --optimize --combined-json abi,bin,interface $ROCKETPOOLCROWDSALETEMPSOL`;" > $ROCKETPOOLCROWDSALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$ARITHMETICJS");
loadScript("$ROCKETPOOLTOKENJS");
loadScript("$ROCKETPOOLPRESALEJS");
loadScript("$ROCKETPOOLCROWDSALEJS");
loadScript("functions.js");

var arithmeticAbi = JSON.parse(arithmeticOutput.contracts["$ARITHMETICTEMPSOL:Arithmetic"].abi);
var arithmeticBin = "0x" + arithmeticOutput.contracts["$ARITHMETICTEMPSOL:Arithmetic"].bin;

var tokenAbi = JSON.parse(tokenOutput.contracts["$ROCKETPOOLTOKENTEMPSOL:RocketPoolToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$ROCKETPOOLTOKENTEMPSOL:RocketPoolToken"].bin;

var presaleAbi = JSON.parse(presaleOutput.contracts["$ROCKETPOOLPRESALETEMPSOL:RocketPoolPresale"].abi);
var presaleBin = "0x" + presaleOutput.contracts["$ROCKETPOOLPRESALETEMPSOL:RocketPoolPresale"].bin;

var crowdsaleAbi = JSON.parse(crowdsaleOutput.contracts["$ROCKETPOOLCROWDSALETEMPSOL:RocketPoolCrowdsale"].abi);
var crowdsaleBin = "0x" + crowdsaleOutput.contracts["$ROCKETPOOLCROWDSALETEMPSOL:RocketPoolCrowdsale"].bin;

console.log("DATA: arithmeticAbi=" + JSON.stringify(arithmeticAbi));
// console.log("DATA: arithmeticBin=" + arithmeticBin);
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
var arithmeticMessage = "Deploy Arithmetic Library";
// -----------------------------------------------------------------------------
console.log("RESULT: " + arithmeticMessage);
var arithmeticContract = web3.eth.contract(arithmeticAbi);
var arithmeticTx = null;
var arithmeticAddress = null;
var arithmetic = arithmeticContract.new({from: contractOwnerAccount, data: arithmeticBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        arithmeticTx = contract.transactionHash;
      } else {
        arithmeticAddress = contract.address;
        addAccount(arithmeticAddress, "Arithmetic Library");
        printTxData("arithmeticAddress=" + arithmeticAddress, arithmeticTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(arithmeticTx, arithmeticMessage);
// printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var replaceMessage = "Replace Library Placeholder With Deployed Address
// -----------------------------------------------------------------------------
var linkedPresaleBin = presaleBin.replace(/_+Arithmetic.sol:Arithmetic_+/g, arithmeticAddress.replace("0x", ""));
var linkedCrowdsaleBin = crowdsaleBin.replace(/_+Arithmetic.sol:Arithmetic_+/g, arithmeticAddress.replace("0x", ""));
// console.log("DATA: presaleBin=" + presaleBin);
// console.log("DATA: linkedPresaleBin=" + linkedPresaleBin);
// console.log("DATA: crowdsaleBin=" + crowdsaleBin);
// console.log("DATA: linkedCrowdsaleBin=" + linkedCrowdsaleBin);


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
failIfGasEqualsGasUsed(tokenTx, tokenMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var presaleMessage = "Deploy RocketPoolPresale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + presaleMessage);
var presaleContract = web3.eth.contract(presaleAbi);
var presaleTx = null;
var presaleAddress = null;
var presale = presaleContract.new(tokenAddress, {from: contractOwnerAccount, data: linkedPresaleBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        presaleTx = contract.transactionHash;
      } else {
        presaleAddress = contract.address;
        addAccount(presaleAddress, "RocketPoolPresale");
        // addCrowdsaleContractAddressAndAbi(presaleAddress, presaleAbi);
        printTxData("presaleAddress=" + presaleAddress, presaleTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(presaleTx, presaleMessage);
// printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var crowdsaleMessage = "Deploy RocketPoolCrowdsale (Should be after Presale completed)";
// -----------------------------------------------------------------------------
console.log("RESULT: " + crowdsaleMessage);
var crowdsaleContract = web3.eth.contract(crowdsaleAbi);
var crowdsaleTx = null;
var crowdsaleAddress = null;
var crowdsale = crowdsaleContract.new(tokenAddress, {from: contractOwnerAccount, data: linkedCrowdsaleBin, gas: 4000000},
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
failIfGasEqualsGasUsed(crowdsaleTx, crowdsaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var transferOwnershipMessage = "Transfer Ownership For Token To TokenSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferOwnershipMessage);
var transferOwnershipTx = token.transferOwnership(saleAddress, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("transferOwnershipTx", transferOwnershipTx);
printBalances();
failIfGasEqualsGasUsed(transferOwnershipTx, transferOwnershipMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var acceptTransferOwnershipMessage = "Accept Transfer Ownership For Token To TokenSale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + acceptTransferOwnershipMessage);
var acceptTransferOwnershipTx = sale.acceptSmartTokenOwnership({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("acceptTransferOwnershipTx", acceptTransferOwnershipTx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnershipTx, acceptTransferOwnershipMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var distributeMessage = "Distribute Partner Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + distributeMessage);
var distributeTx = sale.distributePartnerTokens({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("distributeTx", distributeTx);
printBalances();
failIfGasEqualsGasUsed(distributeTx, distributeMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = sale.startTime();
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = eth.sendTransaction({from: account3, to: saleAddress, gas: 400000, value: web3.toWei("30000.333333333333333333", "ether")});
var validContribution2Tx = eth.sendTransaction({from: account4, to: saleAddress, gas: 400000, value: web3.toWei("50000.123456789123456789", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message + " ac3 30,000.333333333333333333 ETH ~ 6,000,000 STX");
failIfGasEqualsGasUsed(validContribution2Tx, validContribution1Message + " ac4 50,000.123456789123456789 ETH ~ 10,000,000 STX");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale end
// -----------------------------------------------------------------------------
var endTime = sale.endTime();
var endTimeDate = new Date(endTime * 1000);
console.log("RESULT: Waiting until endTime at " + endTime + " " + endTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= endTimeDate.getTime()) {
}
console.log("RESULT: Waited until endTime at " + endTime + " " + endTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var finaliseMessage = "Finalise Crowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finaliseMessage);
var finaliseTx = sale.finalize({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
addAccount(sale.trustee(), "Trustee");
var trustee = eth.contract(trusteeAbi).at(sale.trustee());
addTrusteeContractAddressAndAbi(sale.trustee(), trusteeAbi);
printTxData("finaliseTx", finaliseTx);
printBalances();
failIfGasEqualsGasUsed(finaliseTx, finaliseMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var canTransferMessage = "Can Move Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + canTransferMessage);
var canTransfer1Tx = token.transfer(account5, "1000000000000000000", {from: account3, gas: 100000});
var canTransfer2Tx = token.approve(account6,  "3000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var canTransfer3Tx = token.transferFrom(account4, account7, "3000000000000000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("canTransfer1Tx", canTransfer1Tx);
printTxData("canTransfer2Tx", canTransfer2Tx);
printTxData("canTransfer3Tx", canTransfer3Tx);
printBalances();
failIfGasEqualsGasUsed(canTransfer1Tx, canTransferMessage + " - transfer 1 STX ac3 -> ac5. CHECK for movement");
failIfGasEqualsGasUsed(canTransfer2Tx, canTransferMessage + " - ac4 approve 3 STX ac6");
failIfGasEqualsGasUsed(canTransfer3Tx, canTransferMessage + " - ac6 transferFrom 3 STX ac4 -> ac7. CHECK for movement");
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferOwnership2Message = "Transfer Ownership For Token To ContractOwner";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferOwnership2Message);
var transferOwnership2Tx = sale.transferSmartTokenOwnership(contractOwnerAccount, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("transferOwnership2Tx", transferOwnershipTx);
printBalances();
failIfGasEqualsGasUsed(transferOwnership2Tx, transferOwnership2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var acceptTransferOwnership2Message = "Accept Transfer Ownership For Token To ContractOwner";
// -----------------------------------------------------------------------------
console.log("RESULT: " + acceptTransferOwnership2Message);
var acceptTransferOwnership2Tx = token.acceptOwnership({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("acceptTransferOwnership2Tx", acceptTransferOwnership2Tx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnership2Tx, acceptTransferOwnership2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var disableTransferMessage = "Disable Token Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + disableTransferMessage);
var disableTransferTx = token.disableTransfers(true, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("disableTransferTx", disableTransferTx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnership2Tx, disableTransferMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var cannotTransferMessage = "Cannot Move Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + cannotTransferMessage);
var cannotTransfer1Tx = token.transfer(account5, "10000000000000000000", {from: account3, gas: 100000});
var cannotTransfer2Tx = token.approve(account6,  "30000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var cannotTransfer3Tx = token.transferFrom(account4, account7, "30000000000000000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("cannotTransfer1Tx", cannotTransfer1Tx);
printTxData("cannotTransfer2Tx", cannotTransfer2Tx);
printTxData("cannotTransfer3Tx", cannotTransfer3Tx);
printBalances();
passIfGasEqualsGasUsed(cannotTransfer1Tx, cannotTransferMessage + " - transfer 10 STX ac3 -> ac5. CHECK for NO movement");
failIfGasEqualsGasUsed(cannotTransfer2Tx, cannotTransferMessage + " - ac4 approve 30 STX ac6");
passIfGasEqualsGasUsed(cannotTransfer3Tx, cannotTransferMessage + " - ac6 transferFrom 30 STX ac4 -> ac7. CHECK for NO movement");
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mintTokensMessage = "Mint Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + mintTokensMessage);
var mintTokensTx = token.issue(account8, "77700000000000000000000000000", {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("mintTokensTx", mintTokensTx);
printBalances();
failIfGasEqualsGasUsed(mintTokensTx, mintTokensMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var burnAnyonesTokensMessage = "Burn Anyone's Tokens";
// -----------------------------------------------------------------------------
console.log("RESULT: " + burnAnyonesTokensMessage);
var burnAnyonesTokensTx = token.destroy(account8, "77010000000000000000000000000", {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("burnAnyonesTokensTx", burnAnyonesTokensTx);
printBalances();
failIfGasEqualsGasUsed(burnAnyonesTokensTx, burnAnyonesTokensMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transferOwnership3Message = "Transfer Ownership For Trustee To ContractOwner";
// -----------------------------------------------------------------------------
console.log("RESULT: " + transferOwnership3Message);
var transferOwnership3Tx = sale.transferTrusteeOwnership(contractOwnerAccount, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("transferOwnership3Tx", transferOwnership3Tx);
printBalances();
failIfGasEqualsGasUsed(transferOwnership3Tx, transferOwnership3Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var acceptTransferOwnership3Message = "Accept Transfer Ownership For Trustee To ContractOwner";
// -----------------------------------------------------------------------------
var trustee = eth.contract(trusteeAbi).at(sale.trustee());
console.log("RESULT: " + acceptTransferOwnership3Message);
var acceptTransferOwnership3Tx = trustee.acceptOwnership({from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("acceptTransferOwnership3Tx", acceptTransferOwnership3Tx);
printBalances();
failIfGasEqualsGasUsed(acceptTransferOwnership3Tx, acceptTransferOwnership3Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var enableTransferMessage = "Enable Token Transfers";
// -----------------------------------------------------------------------------
console.log("RESULT: " + enableTransferMessage);
var enableTransferTx = token.disableTransfers(false, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("enableTransferTx", enableTransferTx);
printBalances();
failIfGasEqualsGasUsed(enableTransferTx, enableTransferMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var unlockTrusteeGrantMessage = "Unlock Trustee Grant";
// -----------------------------------------------------------------------------
console.log("RESULT: " + unlockTrusteeGrantMessage);
var unlockTrusteeGrantTx = trustee.unlockVestedTokens({from: trustee1, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("unlockTrusteeGrantTx", unlockTrusteeGrantTx);
printBalances();
failIfGasEqualsGasUsed(unlockTrusteeGrantTx, unlockTrusteeGrantMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var revokeTrusteeGrantMessage = "Revoke Trustee Grant";
// -----------------------------------------------------------------------------
console.log("RESULT: " + revokeTrusteeGrantMessage);
var revokeTrusteeGrantTx = trustee.revoke(trustee1, {from: contractOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("revokeTrusteeGrantTx", revokeTrusteeGrantTx);
printBalances();
failIfGasEqualsGasUsed(revokeTrusteeGrantTx, revokeTrusteeGrantMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
printTrusteeContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
