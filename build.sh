#!/bin/sh

docker build -t livetocode/node-memtest .

docker push livetocode/node-memtest
