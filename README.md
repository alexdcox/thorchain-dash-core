# Thorchain Dash Core - Docker Image

This repo repackages the official Dash Core docker image with scripts to setup a regtest masternode quorum for testing with Thorchain.

The llmq docker compose file will start 4 dash nodes: 1 genesis and 3 masternodes.

They are named `dash1` through to `dash4` and are networked together using private
docker networks not exposed on the host machine.

## Rebuild/Startup/Shutdown Loop

```
./llmq/llmq.sh
```

To see what's going on:
```
docker logs -f dash1
```

To send transactions and interact via the CLI:
```
docker exec -it dash1 bash
```

## Manually Build and Run

Build the dash container:
```
docker build -t github.com/alexdcox/dash .
```

Start the `docker-compose` stack:
```
docker-compose -f ./llmq/llmq-compose.yaml -p dash up
```

Attach to `dash1` genesis node logs:
```
docker logs -f dash1
```

Stop and remove the `docker-compose` stack:
```
docker-compose -f ./llmq/llmq-compose.yaml -p dash down --volumes
```
