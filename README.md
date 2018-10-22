# Purpose

Demonstrate the behaviour of a node application operating within Docker cgroup memory constraints.

Currently, the node process won't honour the cgroup limits and rely instead on the host's memory! (note that this is not the only runtime to do that).

Which means that if the node process comes near to the cgroup limit, it won't have the chance to kick off its GC and might go across the limit, which will force the OS to kill the process.

To avoid this issue, you can also specify how much memory your node app should use with the --max_old_space_sizes parameter.

Note that when your node process exceeds the allocated memory defined by the --max_old_space_sizes parameter, it will terminate with an out of memory error. This is more explicit that having the process killed and will be captured in the logs.

Finally, this memory setting is only useful if your process would cross the specified cgroup memory, otherwise the node process will
regularly start its GC and release memory. 
But if your process handles a heavy load, it might reach this constraint and be kilsled without the chance of exercizing its GC,
which might happen more frequently if you try to give the minimum required memory to a container, because you want to run 
as many containers as you can within a node (in a Kubernetes cluster for instance).

# Build

The build.sh script will rebuild the image and push it to my repo.

# Test

*Requirements*: Run this script in a Linux server with Docker installed (MacOS does not properly honour the cgroup memory limit).

Run the ./test.sh script

The script will run several scenarios:

| # | Max used memory | Docker memory limit | Node memory limit | Expected outcome |
|---|----------------:|---:|---:|---------|
| 1 |          386 MB | No | No | Success |
| 2 |          233 MB | No | 240 MB | Success |
| 3 |         >200 MB | No | 200 MB | We specified less memory than required and the process crashed with an out of memory error |
| 4 |         >260 MB | 260 MB | No | The process exceeded the cgroup memory limit and was killed |
| 5 |          233 MB | 260 MB | 240 MB | Success, the process stayed within the memory constraints |
| 6 |          233 MB | 280 MB | 251 MB | Success, the script interceptor automatically detected the memory constraints and enforced a 251MB node memory limit. |


# References

- https://www.fiznool.com/blog/2016/10/01/running-a-node-dot-js-app-in-a-low-memory-environment/
- https://www.valentinog.com/blog/memory-usage-node-js/

# Test output

Here are the versions used for this test:

|Name|Version|
|----|-------|
|OS|Ubuntu 16.04.5 LTS|
|Docker|17.03.2-ce|
|NodeJS|8.12|

Here's the output of the test.sh script:

```
vagrant ssh
vagrant@k8smaster:~$ sudo bash test.sh

###################< 1 - Running in Docker with no memory limit >#########################

-- The script uses approximately 42 MB (29s to go)
-- The script uses approximately 81 MB (28s to go)
-- The script uses approximately 119 MB (28s to go)
-- The script uses approximately 157 MB (27s to go)
-- The script uses approximately 195 MB (26s to go)
-- The script uses approximately 233 MB (25s to go)
-- The script uses approximately 271 MB (25s to go)
-- The script uses approximately 310 MB (24s to go)
-- The script uses approximately 348 MB (23s to go)
-- The script uses approximately 386 MB (22s to go)
-- The script uses approximately 233 MB (22s to go)
-- The script uses approximately 271 MB (21s to go)
-- The script uses approximately 309 MB (20s to go)
-- The script uses approximately 347 MB (20s to go)
-- The script uses approximately 386 MB (19s to go)
-- The script uses approximately 233 MB (18s to go)
-- The script uses approximately 271 MB (17s to go)
-- The script uses approximately 309 MB (17s to go)
-- The script uses approximately 347 MB (16s to go)
-- The script uses approximately 386 MB (15s to go)
-- The script uses approximately 233 MB (15s to go)
-- The script uses approximately 271 MB (14s to go)
-- The script uses approximately 309 MB (13s to go)
-- The script uses approximately 348 MB (12s to go)
-- The script uses approximately 386 MB (12s to go)
-- The script uses approximately 233 MB (11s to go)
-- The script uses approximately 271 MB (10s to go)
-- The script uses approximately 309 MB (9s to go)
-- The script uses approximately 233 MB (9s to go)
-- The script uses approximately 271 MB (8s to go)
-- The script uses approximately 309 MB (7s to go)
-- The script uses approximately 348 MB (7s to go)
-- The script uses approximately 233 MB (6s to go)
-- The script uses approximately 271 MB (5s to go)
-- The script uses approximately 309 MB (4s to go)
-- The script uses approximately 348 MB (4s to go)
-- The script uses approximately 386 MB (3s to go)
-- The script uses approximately 233 MB (2s to go)
-- The script uses approximately 271 MB (2s to go)
-- The script uses approximately 309 MB (1s to go)
-- The script uses approximately 348 MB (0s to go)
-------> Max memory used: 386 MB
[OK] Nodejs was able to run the script in Docker, without any memory constraint

###################< 2 - Running in Docker with no memory limit but with max_old_space_size = 240 MB >#########################

-- The script uses approximately 42 MB (29s to go)
-- The script uses approximately 80 MB (28s to go)
-- The script uses approximately 118 MB (28s to go)
-- The script uses approximately 156 MB (27s to go)
-- The script uses approximately 195 MB (26s to go)
-- The script uses approximately 233 MB (26s to go)
-- The script uses approximately 233 MB (25s to go)
-- The script uses approximately 233 MB (24s to go)
-- The script uses approximately 233 MB (23s to go)
-- The script uses approximately 233 MB (22s to go)
-- The script uses approximately 233 MB (21s to go)
-- The script uses approximately 233 MB (20s to go)
-- The script uses approximately 233 MB (19s to go)
-- The script uses approximately 233 MB (19s to go)
-- The script uses approximately 233 MB (18s to go)
-- The script uses approximately 233 MB (17s to go)
-- The script uses approximately 233 MB (16s to go)
-- The script uses approximately 233 MB (15s to go)
-- The script uses approximately 233 MB (14s to go)
-- The script uses approximately 233 MB (13s to go)
-- The script uses approximately 233 MB (12s to go)
-- The script uses approximately 233 MB (11s to go)
-- The script uses approximately 233 MB (10s to go)
-- The script uses approximately 233 MB (9s to go)
-- The script uses approximately 233 MB (9s to go)
-- The script uses approximately 233 MB (8s to go)
-- The script uses approximately 233 MB (7s to go)
-- The script uses approximately 233 MB (6s to go)
-- The script uses approximately 233 MB (5s to go)
-- The script uses approximately 233 MB (4s to go)
-- The script uses approximately 233 MB (3s to go)
-- The script uses approximately 233 MB (2s to go)
-- The script uses approximately 233 MB (1s to go)
-- The script uses approximately 233 MB (1s to go)
-- The script uses approximately 233 MB (0s to go)
-------> Max memory used: 233 MB
[OK] Nodejs was able to run within the allocated memory limit

###################< 3 - Running in Docker with no memory limit but with max_old_space_size = 200 MB >#########################

-- The script uses approximately 42 MB (29s to go)
-- The script uses approximately 80 MB (28s to go)
-- The script uses approximately 118 MB (28s to go)
-- The script uses approximately 156 MB (27s to go)
-- The script uses approximately 195 MB (26s to go)

<--- Last few GCs --->

[1:0x5630247a3000]     3876 ms: Mark-sweep 198.4 (205.9) -> 198.4 (205.9) MB, 87.4 / 0.0 ms  allocation failure GC in old space requested
[1:0x5630247a3000]     3940 ms: Mark-sweep 198.4 (205.9) -> 198.4 (202.9) MB, 64.6 / 0.0 ms  last resort GC in old space requested
[1:0x5630247a3000]     4005 ms: Mark-sweep 198.4 (202.9) -> 198.4 (202.9) MB, 64.8 / 0.0 ms  last resort GC in old space requested


<--- JS stacktrace --->

==== JS stack trace =========================================

Security context: 0x2a835eda5879 <JSObject>
    1: task [/src/index.js:38] [bytecode=0xdfaf7f600a9 offset=128](this=0x245df908c2f1 <JSGlobal Object>,id=52,memory=500000)
    2: main [/src/index.js:51] [bytecode=0xdfaf7f5f931 offset=240](this=0x245df908c2f1 <JSGlobal Object>,duration=0x30ac44382311 <the_hole>)
    3: /* anonymous */(this=0x245df908c2f1 <JSGlobal Object>,0x30ac443cea01 <JSArray[10]>)
    4: /* anonymous */(aka /* anonymous ...

FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory
[OK] Nodejs probably crashed with an out of memory error

###################< 4 - Running in Docker with memory limit = 260 MB >#########################

WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.
-- The script uses approximately 42 MB (29s to go)
-- The script uses approximately 81 MB (28s to go)
-- The script uses approximately 119 MB (28s to go)
-- The script uses approximately 157 MB (27s to go)
-- The script uses approximately 195 MB (26s to go)
-- The script uses approximately 233 MB (26s to go)
[OK] docker exited abnormally because the container used too much memory

###################< 5 - Running in Docker with memory limit = 260 MB and max_old_space_size=240 >#########################

WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.
-- The script uses approximately 42 MB (29s to go)
-- The script uses approximately 80 MB (28s to go)
-- The script uses approximately 118 MB (28s to go)
-- The script uses approximately 156 MB (27s to go)
-- The script uses approximately 195 MB (26s to go)
-- The script uses approximately 233 MB (25s to go)
-- The script uses approximately 233 MB (25s to go)
-- The script uses approximately 233 MB (24s to go)
-- The script uses approximately 233 MB (23s to go)
-- The script uses approximately 233 MB (22s to go)
-- The script uses approximately 233 MB (21s to go)
-- The script uses approximately 233 MB (20s to go)
-- The script uses approximately 233 MB (19s to go)
-- The script uses approximately 233 MB (18s to go)
-- The script uses approximately 233 MB (17s to go)
-- The script uses approximately 233 MB (17s to go)
-- The script uses approximately 233 MB (16s to go)
-- The script uses approximately 233 MB (15s to go)
-- The script uses approximately 233 MB (14s to go)
-- The script uses approximately 233 MB (13s to go)
-- The script uses approximately 233 MB (12s to go)
-- The script uses approximately 233 MB (12s to go)
-- The script uses approximately 233 MB (11s to go)
-- The script uses approximately 233 MB (10s to go)
-- The script uses approximately 233 MB (9s to go)
-- The script uses approximately 233 MB (8s to go)
-- The script uses approximately 233 MB (7s to go)
-- The script uses approximately 233 MB (6s to go)
-- The script uses approximately 233 MB (5s to go)
-- The script uses approximately 233 MB (4s to go)
-- The script uses approximately 233 MB (3s to go)
-- The script uses approximately 233 MB (2s to go)
-- The script uses approximately 233 MB (1s to go)
-- The script uses approximately 233 MB (1s to go)
-- The script uses approximately 233 MB (0s to go)
-------> Max memory used: 233 MB
[OK] Success. Node was able to keep its memory within the specified limits
###################< 6 - Running in Docker with memory limit = 260 MB and nodejs memory patch >#########################

WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.
sh: 30: unknown operand
[NODEJS-OVERRIDE] cgroup stats:     Memory limit |     Memory Usage | Memory available
[NODEJS-OVERRIDE]                         280 Mb |             0 Mb |           279 Mb
[NODEJS-OVERRIDE] Auto-generate NODEJS_MEMORY_LIMIT variable from available memory (279 Mb)
[NODEJS-OVERRIDE] Use 90% of $NODEJS_MEMORY_LIMIT: 279 * 90% = 251 Mb
[NODEJS-OVERRIDE] node process was overridden by this script: /usr/local/bin/node
[NODEJS-OVERRIDE] Injecting nodejs options: --max_old_space_size=251
[NODEJS-OVERRIDE] Execute real command: /usr/local/bin/node.original --max_old_space_size=251  index.js 30
-- The script uses approximately 42 MB (29s to go)
-- The script uses approximately 80 MB (28s to go)
-- The script uses approximately 118 MB (28s to go)
-- The script uses approximately 156 MB (27s to go)
-- The script uses approximately 195 MB (26s to go)
-- The script uses approximately 233 MB (25s to go)
-- The script uses approximately 233 MB (25s to go)
-- The script uses approximately 233 MB (24s to go)
-- The script uses approximately 233 MB (23s to go)
-- The script uses approximately 233 MB (22s to go)
-- The script uses approximately 233 MB (21s to go)
-- The script uses approximately 233 MB (20s to go)
-- The script uses approximately 233 MB (19s to go)
-- The script uses approximately 233 MB (18s to go)
-- The script uses approximately 233 MB (18s to go)
-- The script uses approximately 233 MB (17s to go)
-- The script uses approximately 233 MB (16s to go)
-- The script uses approximately 233 MB (15s to go)
-- The script uses approximately 233 MB (14s to go)
-- The script uses approximately 233 MB (14s to go)
-- The script uses approximately 233 MB (13s to go)
-- The script uses approximately 233 MB (12s to go)
-- The script uses approximately 233 MB (11s to go)
-- The script uses approximately 233 MB (10s to go)
-- The script uses approximately 233 MB (9s to go)
-- The script uses approximately 233 MB (9s to go)
-- The script uses approximately 233 MB (8s to go)
-- The script uses approximately 233 MB (7s to go)
-- The script uses approximately 233 MB (6s to go)
-- The script uses approximately 233 MB (5s to go)
-- The script uses approximately 233 MB (5s to go)
-- The script uses approximately 233 MB (4s to go)
-- The script uses approximately 233 MB (3s to go)
-- The script uses approximately 233 MB (2s to go)
-- The script uses approximately 233 MB (1s to go)
-- The script uses approximately 233 MB (0s to go)
-------> Max memory used: 233 MB
[OK] Success. Node was able to keep its memory within the specified limits

DONE
```


