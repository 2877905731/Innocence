/* Local-only server for the two standalone UI references. No dependencies. */
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../docs/design/templates');
const allowed = new Set(['liquid-glass-preview.html', 'minimal-white-preview.html', 'ui-redesign-preview.css', 'ui-redesign-preview.js']);
const types = {'.html':'text/html; charset=utf-8','.css':'text/css; charset=utf-8','.js':'text/javascript; charset=utf-8'};
const port = Number(process.env.INNOCENCE_PREVIEW_PORT || 4179);
const server = http.createServer((req,res) => {
  const requested = new URL(req.url, 'http://127.0.0.1').pathname;
  const name = requested === '/' ? 'liquid-glass-preview.html' : requested.slice(1);
  if (!allowed.has(name)) { res.writeHead(404, {'Content-Type':'text/plain; charset=utf-8'}); res.end('Not found'); return; }
  fs.readFile(path.join(root,name),(error,content) => {
    if(error){res.writeHead(500);res.end('Unable to read preview');return;}
    res.writeHead(200, {'Content-Type':types[path.extname(name)],'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'});
    res.end(content);
  });
});
server.on('error',error=>{console.error(error.message);process.exitCode=1;});
server.listen(port,'127.0.0.1',()=>console.log(`Innocence UI reference: http://127.0.0.1:${port}/`));
