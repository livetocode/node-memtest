#!/bin/sh

IMG_NAME=livetocode/node-memtest
MEM_LIMIT=260
NODE_MEM_LIMIT=240
NODE_MEM_LIMIT_LOW=200
DEFAULT_DURATION=30

echo "###################< 1 - Running in Docker with no memory limit >#########################"
echo
docker run $IMG_NAME
if [[ $? != 0 ]]; then
  echo "Expected docker to run correctly"
  exit 1
fi

echo
echo "###################< 2 - Running in Docker with no memory limit but with max_old_space_size = $NODE_MEM_LIMIT MB >#########################"
echo
docker run $IMG_NAME node --max_old_space_size=$NODE_MEM_LIMIT index.js $DEFAULT_DURATION
if [[ $? != 0 ]]; then
  echo "Expected docker to run correctly with the max_old_space_size argument"
  exit 1
fi

echo
echo "###################< 3 - Running in Docker with no memory limit but with max_old_space_size = $NODE_MEM_LIMIT_LOW MB >#########################"
echo
docker run $IMG_NAME node --max_old_space_size=$NODE_MEM_LIMIT_LOW index.js $DEFAULT_DURATION
if [[ $? == 0 ]]; then
  echo "Expected docker to crash because of an out of memory error"
  exit 1
fi

echo
echo "###################< 4 - Running in Docker with memory limit = ${MEM_LIMIT} MB >#########################"
echo
docker run -m ${MEM_LIMIT}m $IMG_NAME node index.js $DEFAULT_DURATION
if [[ $? == 137 ]]; then
  echo "docker exited abnormally because the container used too much memory"
else
  echo "Expected docker to die!"
  exit 1
fi

echo
echo "###################< 5 - Running in Docker with memory limit = $MEM_LIMIT MB and max_old_space_size=$NODE_MEM_LIMIT >#########################"
echo
docker run -m "${MEM_LIMIT}m" $IMG_NAME node --max_old_space_size=$NODE_MEM_LIMIT index.js $DEFAULT_DURATION
if [[ $? == 0 ]]; then
  echo "Success. Node was able to keep its memory within the specified limits"
else
  echo "Expected docker to run correctly with the max_old_space_sizes argument"
  exit 1
fi

echo
echo "DONE"