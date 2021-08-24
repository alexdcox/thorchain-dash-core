#!/bin/bash

. /scripts/core.sh

genesis() {
  printthornodeconfig
  writedashdconfig

  dashd 1>$logPath &
  dashdpid="$!"

  waitforverificationprogresscomplete $NODE_IP

  while true; do
    nextBlockHash="$(dash-cli generate 1 &> /dev/null | jq -r '.[0]')"
    sleep $BLOCK_TIME
  done &

  echo "Generating $initialBlocks initial blocks..."
  dash-cli generate $initialBlocks

  waitforblock $NODE_IP $initialBlocks

  waitforblock dash2 $initialBlocks
  waitformasternodestatus dash2 READY
  waitformasternodesync dash2

  waitforblock dash3 $initialBlocks
  waitformasternodestatus dash3 READY
  waitformasternodesync dash3

  waitforblock dash4 $initialBlocks
  waitformasternodestatus dash4 READY
  waitformasternodesync dash4

  echo "Activating sporks..."
  dash-cli spork SPORK_2_INSTANTSEND_ENABLED 0
  dash-cli spork SPORK_3_INSTANTSEND_BLOCK_FILTERING 0
  dash-cli spork SPORK_9_SUPERBLOCKS_ENABLED 0
  dash-cli spork SPORK_17_QUORUM_DKG_ENABLED 0
  dash-cli spork SPORK_19_CHAINLOCKS_ENABLED 0
  dash-cli spork SPORK_21_QUORUM_ALL_CONNECTED 1

  printtimetostart

  echo "Following dashd log from start:"
  tail -f -n +1 $logPath
}

genesis &
exitonsigterm
