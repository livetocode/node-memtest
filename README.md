# Purpose

Demonstrate the behaviour of a node application operating within Docker cgroup memory constraints.

Currently, the node process won't honour the cgroup limits and rely instead on the host's memory! (note that this is not the only runtime to do that).

Which means that if the node process comes near to the cgroup limit, it won't have the chance to kick off its GC and might go across the limit, which will force the OS to kill the process.

To avoid this issue, you can also specify how much memory your node app should use with the --max_old_space_sizes parameter.

Note that when your node process exceeds the allocated memory by the --max_old_space_sizes parameter, it will terminate with an out of memory error. This is more explicit that having the process killed and will be captured in the logs.

Finally, this memory setting is only useful if your process would cross the specified cgroup memory, otherwise the node process will
regularly start its GC and release memory. 
But if your process handles a heavy load, it might reach this constraint and be killed without the chance of exercizing its GC.

# Build

The build.sh script will rebuild the image and push it to my repo.

# Test

*Requirements*: Run this script in a Linux server with Docker installed (MacOS does not properly honour the cgroup memory limit).

Run the ./test.sh script

The script will run several scenarios:

| # | Max used memory | Docker memory limit | Node memory limit | Expected outcome |
|---|-----------------|----|----|---------|
| 1 |          386 MB | No | No | Success |
| 2 |          233 MB | No | 240 MB | Success |
| 3 |         >200 MB | No | 200 MB | We specified less memory than required and the process crashed with an out of memory error |
| 4 |         >260 MB | 260 MB | No | The process exceeded the cgroup memory limit and was killed |
| 5 |          233 MB | 260 MB | 240 MB | Success, the process stayed within the memory constraints |



