const http = require('http');
const fs = require('fs');
const path = require('path');

const port = 3000;
const directory = __dirname;

const server = http.createServer((req, res) => {
    const filePath = path.join(directory, req.url);

    fs.stat(filePath, (err, stats) => {
        if (err || !stats.isFile()) {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Not Found\n');
            return;
        }

        fs.createReadStream(filePath).pipe(res);
    });
});

server.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});
