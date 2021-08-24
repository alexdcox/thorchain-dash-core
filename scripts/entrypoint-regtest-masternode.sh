#!/bin/bash

. /scripts/core.sh

masternode() {
  printthornodeconfig
  writedashdconfig

  waitforblock $dash1Ip $initialBlocks

  dashd -connect=$dash1Ip 1>$logPath &
  dashdpid="$!"

  waitforblock $NODE_IP $initialBlocks

  ownerAddress=$(dash-cli getnewaddress)
  collateralAddress=$(dash-cli getnewaddress)
  collateralVout=1
  ipPort="$NODE_IP:19899"
  votingAddress=$(dash-cli getnewaddress)
  operatorBls=$(dash-cli bls generate)
  operatorPrivkey=$(echo $operatorBls | jq -r '.secret')
  operatorPubkey=$(echo $operatorBls | jq -r '.public')
  operatorReward=0
  payoutAddress=$(dash-cli getnewaddress)
  feeSourceAddress=$ownerAddress
  fundAddress=$(dash-cli getnewaddress)

  echo "Sending 1001 DASH to masternode fund address $fundAddress"
  fundHash=$(dash-cli -rpcconnect=$dash1Ip sendtoaddress $fundAddress 1001 2>&1)
  if [[ "$fundHash" == *"error code"* ]]; then
    echo "Fund transaction failed: $fundHash"
    sleep infinity
  else 
    echo "Fund tx hash: $fundHash"
  fi

  echo "Sending 1001 DASH to masternode collateral address $collateralAddress"
  collateralHash=$(dash-cli -rpcconnect=$dash1Ip sendtoaddress $collateralAddress 1001 2>&1)
  if [[ "$collateralHash" == *"error code"* ]]; then
    echo "Collateral transaction failed: $collateralHash"
    sleep infinity
  else 
    echo "Collateral tx hash: $collateralHash"
  fi

  echo "Generating confirmation blocks..."
  dash-cli -rpcconnect=$dash1Ip generate 20

  echo "Balance of fund address"
  dash-cli getaddressbalance \"$fundAddress\"

  echo "Balance of collateral address"
  dash-cli getaddressbalance \"$collateralAddress\"

  echo "Current addresses and balances:"
  dash-cli listaddressgroupings

  # echo "Generating confirmation blocks..."
  # dash-cli -rpcconnect=$dash1Ip generatetoaddress 10 $ownerAddress 1> /dev/null
  printmasternodeconfig

  echo "Sending protx register command"
  registerHash=$(dash-cli protx register_fund \
    $collateralAddress \
    $ipPort \
    $ownerAddress \
    $operatorPubkey \
    $votingAddress \
    $operatorReward \
    $payoutAddress \
    $fundAddress)

  echo "Protx registration tx hash: $registerHash"

  if [[ "$registerHash" == "" ]]; then
    echo "Protx register failed."
    sleep infinity
  fi

  while true; do
    output=$(dash-cli -rpcconnect=$dash1Ip getrawtransaction $registerHash true 2>&1)
    if [[ "$output" == *"No such mempool or blockchain transaction."* || "$output" == *"error code"* ]]; then
      echo "Protx tx not accepted by genesis node, re-sending..."
      rawtx=$(dash-cli getrawtransaction $registerHash 2>&1)
      dash-cli sendrawtransaction $rawtx &> /dev/null
      sleep 1
    else
      echo "Protx tx accepted by genesis node!"
      echo $output
      break
    fi
  done

  echo "Setting masternode operator bls key in dash.conf"
  echo "  masternodeblsprivkey=$operatorPrivkey" >>$configPath

  echo "Restarting dashd to initiate masternode sync"
  killpidandwait $dashdpid
  sleep 2
  dashd -connect=$dash1Ip 1>$logPath &
  dashdpid="$!"

  echo "Started new dashd process $dashdpid"
  waitforverificationprogresscomplete $NODE_IP
  waitformasternodestatus $NODE_IP READY
  waitformasternodesync $NODE_IP

  echo "Restarting dashd to force peers to consider this a masternode"
  killpidandwait $dashdpid
  sleep 2
  dashd -connect=$dash1Ip 1>$logPath &
  dashdpid="$!"

  printtimetostart

  echo "Following dashd log from start:"
  tail -f -n +1 $logPath
}

masternode &
exitonsigterm
