#!/bin/zsh

while true; do
  docker build -t dashpaytest . --progress plain
  docker-compose -f ./llmq/llmq-compose.yaml -p dash up --remove-orphans -d
  echo -n "Press enter to STOP and remove dash nodes...";
  read ignored
  docker-compose -f ./llmq/llmq-compose.yaml -p dash down --volumes
  echo "Press ctrl+c to EXIT"
  echo -n "Press enter to RESTART dash nodes...";
  read ignored
done


