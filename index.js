const verbose = false;
const queue = [];
const maxQueueLen = 50;
const memorySize = 500000;
const concurrency = 10;
let maxUsedMemory = 0;
let untilTime;

function delay(value) {
    return new Promise(function(resolve, reject){
        timeoutId = setTimeout(function() {
            resolve();
        }, value);
    });
}

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function enqueue(data) {
    queue.push(data);
    if (queue.length > maxQueueLen)
        queue.pop();
}

function displayMemoryStats() {
    const used = Math.round(process.memoryUsage().heapUsed / 1024 / 1024);
    if (used > maxUsedMemory)
        maxUsedMemory = used;
    const secsLeft = Math.round((untilTime.getTime() - Date.now()) / 1000);
    console.log(`-- The script uses approximately ${used} MB (${secsLeft}s to go)`);
}

async function task(id, memory) {
    if (verbose)
        console.log(`task #${id} starting...`);
    var buff = Array(memory).fill("some string");
    await delay(getRandomInt(500)+250);
    enqueue(buff);
    if (verbose)
        console.log(`task #${id} done.`);
}

async function main(duration) {
    untilTime = new Date(new Date().getTime() + duration*1000);
    let taskId = 0;
    while(Date.now() < untilTime.getTime()) {
        const tasks = [];
        for(var i = 0; i < concurrency; i++)
            tasks.push(task(++taskId, memorySize));
        await Promise.all(tasks);
        displayMemoryStats();
    }
    console.log(`-------> Max memory used: ${maxUsedMemory} MB`)
}

main(process.argv[2] || 30);
