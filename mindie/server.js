const http = require('http');
const fs = require('fs').promises;
const path = require('path');

const PORT = process.env.PORT || 3000;
const DIRECTORY = __dirname;

const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.txt': 'text/plain',
    '.pdf': 'application/pdf',
};

const log = (message) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${message}`);
};

const sendError = (res, statusCode, message) => {
    log(`Error: ${statusCode} - ${message}`);
    res.writeHead(statusCode, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: message }));
};

async function handleListFiles(res) {
    try {
        const files = await fs.readdir(DIRECTORY);
        const fileDetails = await Promise.all(
            files.map(async (file) => {
                const stats = await fs.stat(path.join(DIRECTORY, file));
                return {
                    name: file,
                    size: stats.size,
                    isDirectory: stats.isDirectory(),
                    modifiedAt: stats.mtime
                };
            })
        );
        log(`Listed ${files.length} files in directory`);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(fileDetails));
    } catch (err) {
        sendError(res, 500, 'Failed to list files');
    }
}

async function handleWildcardMatch(req, res) {
    try {
        const pattern = decodeURIComponent(req.url)
            .slice(1)
            .replace(/\*/g, '.*');
        const regex = new RegExp(`^${pattern}$`);

        const files = await fs.readdir(DIRECTORY);
        const matchedFiles = files.filter(file => regex.test(file));

        if (matchedFiles.length === 0) {
            log(`No files matched pattern: ${pattern}`);
            return sendError(res, 404, 'No matching files found');
        }

        const matchedFile = matchedFiles[0];
        log(`Wildcard match found: ${matchedFile} for pattern: ${pattern}`);
        await serveFile(path.join(DIRECTORY, matchedFile), res);
    } catch (err) {
        sendError(res, 500, 'Error processing wildcard request');
    }
}

function getMimeType(filePath) {
    const ext = path.extname(filePath).toLowerCase();
    return MIME_TYPES[ext] || 'application/octet-stream';
}

async function serveFile(filePath, res) {
    try {
        const stats = await fs.stat(filePath);

        if (!stats.isFile()) {
            log(`Attempted to access non-file: ${filePath}`);
            return sendError(res, 400, 'Not a file');
        }

        const fileName = path.basename(filePath);
        const fileSize = stats.size;
        const mimeType = getMimeType(filePath);

        const headers = {
            'Content-Type': mimeType,
            'Content-Length': fileSize,
            'Last-Modified': stats.mtime.toUTCString(),
            'Cache-Control': 'max-age=3600'
        };

        res.writeHead(200, headers);
        const fileStream = require('fs').createReadStream(filePath);

        fileStream.on('error', (error) => {
            log(`Error streaming file ${fileName}: ${error}`);
            sendError(res, 500, 'Error streaming file');
        });

        fileStream.on('end', () => {
            log(`Successfully served file: ${fileName} (${fileSize} bytes)`);
        });

        fileStream.pipe(res);
    } catch (err) {
        log(`File not found: ${filePath}`);
        sendError(res, 404, 'File not found');
    }
}

const server = http.createServer(async (req, res) => {
    const clientIP = req.socket.remoteAddress;
    log(`Incoming request: ${req.method} ${req.url} from ${clientIP}`);

    // 添加基本的安全头
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');

    // 处理路径遍历攻击
    const normalizedPath = path.normalize(req.url).replace(/^(\.\.[\/\\])+/, '');
    const filePath = path.join(DIRECTORY, normalizedPath);

    try {
        if (req.url === '/files') {
            await handleListFiles(res);
        } else if (req.url.includes('*')) {
            await handleWildcardMatch(req, res);
        } else {
            await serveFile(filePath, res);
        }
    } catch (err) {
        console.error('Server error:', err);
        sendError(res, 500, 'Internal server error');
    }
});

process.on('SIGTERM', () => {
    log('Received SIGTERM signal. Shutting down server...');
    server.close(() => {
        log('Server shutdown complete');
        process.exit(0);
    });
});

server.listen(PORT, () => {
    log(`Server started and listening at http://localhost:${PORT}`);
    log(`Serving files from directory: ${DIRECTORY}`);
});