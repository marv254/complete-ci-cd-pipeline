#!/usr/bin/bash
export IMAGE=$1
docker-compose -f java-compose.yaml up -d
echo "success"