

import os from 'os';
import cluster from 'cluster';
import express from 'express';

const numCPUs = os.cpus().length;
const port = process.env.PORT ? process.env.PORT : 3000;

if (cluster.isPrimary) {
console.log(`Master process ${process.pid} is running`);

for (let i = 0; i < numCPUs; i++) {
cluster.fork();
}

cluster.on('exit', (worker) => {
console.log(`Worker process ${worker.process.pid} died. Restarting...`);
cluster.fork();
});
} else {
const app = express();

// Configure your Express app

app.get('/', (req, res) => {
    res.send('Hello World!');
})

const server = app.listen(port, () => {
console.log(`Worker process ${process.pid} is listening on port 3000`);
});
}
