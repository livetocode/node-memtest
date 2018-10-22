#!/bin/sh
set -e

docker build -t livetocode/node-memtest .
docker push livetocode/node-memtest

docker build -t livetocode/node-memtest:patched -f Dockerfile.patched .
docker push livetocode/node-memtest:patched
