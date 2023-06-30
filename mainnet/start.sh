#!/bin/bash

docker pull dashpay/dashd:latest
docker-compose -f ./mainnet/docker-compose.yaml up -d

echo ""
echo "So long as the volume is not deleted, you should be able to just keep"
echo "running start.sh to run the latest dashd without downloading the"
echo "entire blockchain again."
echo ""
echo "Follow logs with:"
echo "  docker logs -f dash_mainnet"
echo ""
echo "Open a shell with:"
echo "  docker exec -it dash_mainnet bash"
echo ""
echo ""