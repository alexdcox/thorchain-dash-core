# Thorchain Dash Core - Docker Image

This repo repackages the official Dash Core docker image with scripts to setup a regtest masternode quorum for testing with Thorchain.

The llmq docker compose file will start 4 dash nodes: 1 genesis and 3 masternodes.

They are named `dash1` through to `dash4` and are networked together using private
docker networks not exposed on the host machine.

## Rebuild/Startup/Shutdown Loop

```
./llmq/llmq.sh
```

## Manually Build and Run

Build the dash container:
```
docker build -t dashpaytest .
```

Start the `docker-compose` stack:
```
docker-compose -f ./llmq/llmq-compose.yaml -p dash up
```

Stop and remove the `docker-compose` stack:
```
docker-compose -f ./llmq/llmq-compose.yaml -p dash down --volumes
```