#!/bin/sh
# Inspired from https://www.fiznool.com/blog/2016/10/01/running-a-node-dot-js-app-in-a-low-memory-environment/

#
# This script supports the following environment vars:
#  - NODEJS_MEMORY_LIMIT: the maximum amount of memory a nodejs process can consume, in MB.
#  - NODEJS_V8_ARGS: any additional args to
#    pass to the v8 runtime.
node_args=""
ECHO_PREFIX="[NODEJS-OVERRIDE]"
SCRIPT=$0

# Detect the original nodejs executable
NODE_EXE=$0
if [ -f "$NODE_EXE.original" ]; then
  NODE_EXE="$NODE_EXE.original"
elif [ "$NODE_EXE" != "/usr/local/bin/node" ]; then
  NODE_EXE="/usr/local/bin/node"
else
  echo "$ECHO_PREFIX could not find original nodejs process!"
  exit 1
fi

if [ $( echo $@ | grep -c -i -e "--max_old_space_size=" ) -gt 0 ]; then
  echo "$ECHO_PREFIX max_old_space_size already provided"
else
  # Auto detect memory constraints from cgroup because env variable NODEJS_MEMORY_LIMIT was not provided
  if [ -z "$NODEJS_MEMORY_LIMIT" ]; then
    if [ -f "/sys/fs/cgroup/memory/memory.limit_in_bytes" ]; then
      MEM_LIMIT=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
      MEM_USAGE=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
      MEM_AVAIL=$(($MEM_LIMIT-$MEM_USAGE))
      # Apply limit only if we have at least 100Mb availabe, which will also make sure that we don't have a negative number for MEM_AVAIL.
      if [ "$MEM_AVAIL" -gt "$((100*1024*1024))" ]; then
        DEFAULT_NODEJS_MEM_LIMIT=$((2*1024*1024*1024))
        if [ "$MEM_LIMIT" -lt "$DEFAULT_NODEJS_MEM_LIMIT" ]; then
          NODEJS_MEMORY_LIMIT=$(($MEM_AVAIL/1024/1024))
          echo   "$ECHO_PREFIX cgroup stats:     Memory limit |     Memory Usage | Memory available"
          printf "$ECHO_PREFIX               %13s Mb | %13s Mb | %13s Mb\n" "$((($MEM_LIMIT/1024)/1024))" "$((($MEM_USAGE/1024)/1024))" "$((($MEM_AVAIL/1024)/1024))"
          echo   "$ECHO_PREFIX Auto-generate NODEJS_MEMORY_LIMIT variable from available memory ($((($MEM_AVAIL/1024)/1024)) Mb)"
        fi
      fi
    fi
  fi

  if [ -n "$NODEJS_MEMORY_LIMIT" ]; then
    # Apply the requested memory limit to the nodejs V8 options, adjusting it with a custom ratio.
    mem_ratio=90
    mem_node_old_space=$((($NODEJS_MEMORY_LIMIT*$mem_ratio)/100))
    echo "$ECHO_PREFIX Use $mem_ratio% of \$NODEJS_MEMORY_LIMIT: $NODEJS_MEMORY_LIMIT * $mem_ratio% = $mem_node_old_space Mb"
    node_args="--max_old_space_size=$mem_node_old_space $node_args"
  fi
fi

if [ -n "$NODEJS_V8_ARGS" ]; then
  # Pass any additional arguments to v8.
  node_args="$NODEJS_V8_ARGS $node_args"
fi

if [ -n "$node_args" ]; then
  echo "$ECHO_PREFIX node process was overridden by this script: $SCRIPT"
  echo "$ECHO_PREFIX Injecting nodejs options: $node_args"
  echo "$ECHO_PREFIX Execute real command: $NODE_EXE $node_args $@"
fi

# Start the process using `exec`.
# This ensures that when node exits,
# the exit code is passed up to the
# caller of this script.
exec $NODE_EXE $node_args $@