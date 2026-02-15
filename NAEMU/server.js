const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const WORDS = (new Function(
  fs.readFileSync(path.join(__dirname, 'words.js'), 'utf8') + '; return WORDS;'
))();

const template = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');

const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://localhost');

  if (url.pathname === '/' || url.pathname === '/index.html') {
    const rand = crypto.randomBytes(4).readUInt32BE(0);
    const word = WORDS[rand % WORDS.length];
    const html = template.replace('%%WORD%%', word);
    res.writeHead(200, {
      'Content-Type': 'text/html',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
      'Pragma': 'no-cache'
    });
    res.end(html);
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log('Naemu running on http://localhost:' + PORT);
});
