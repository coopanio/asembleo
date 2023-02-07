#!/usr/bin/env node

const path = require('path')
const http = require('http')

const watch = process.argv.includes('--watch')
const clients = []

const watchOptions = {
  onRebuild: (error, result) => {
    if (error) {
      console.error('Build failed:', error)
    } else {
      console.log('Build succeeded')
      clients.forEach((res) => res.write('data: update\n\n'))
      clients.length = 0
    }
  }
}

require("esbuild").build({
  entryPoints: ["application.js"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  watch: watch && watchOptions,
  banner: {
    js: ' (() => new EventSource("http://localhost:8082").onmessage = () => location.reload())();',
  },
}).catch(() => process.exit(1));

http.createServer((req, res) => {
  return clients.push(
    res.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Access-Control-Allow-Origin": "*",
      Connection: "keep-alive",
    }),
  );
}).listen(8082);