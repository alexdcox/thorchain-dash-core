#!/bin/bash

dashdpid=""

exitonsigterm() {
  timeToExit=0
  trap "timeToExit=1" SIGINT SIGTERM
  while true; do
    sleep 1
    if [[ ${timeToExit} == 1 ]]; then
      echo "Caught sigint/sigterm, exiting."
      if [[ "$dashpid" != "" ]]; then
        kill -9 $dashdpid
      fi
      kill -9 0
      exit 0
    fi
  done
}

mainnet() {
  logPath="/home/dash/.dashcore/dash.log"

  dashd 1>$logPath &
  dashdpid="$!"

#  echo "Creating default wallet"
#  dash-cli createwallet ""

  echo "Following dashd log from start:"
  tail -f -n +1 $logPath
}

mainnet &
exitonsigterm
