#!/bin/bash

docker-compose stop
docker-compose rm -f
docker-compose pull
docker-compose up -d

# docker exec -ti nvidia_base bash