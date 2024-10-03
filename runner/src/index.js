const http = require("http");
const express = require('express');
const {Server: SocketServer } = require('socket.io');
const os = require('os');
// require('dotenv').config();
const pty = require('node-pty');
const fileOperations = require("./fileOperations");
const path = require('path');
// const appRoot = require('app-root-path');
const fs = require("fs");

const shell = os.platform() === 'win32' ? 'powershell.exe' : 'bash';

const app = express();
const server = http.createServer(app);
const io = new SocketServer(server);


// const userFolder = process.env.USERNAME;
// console.log('userFolder', path.resolve('home', userFolder));
console.log('Current working directory:', process.cwd());
// if (!fs.existsSync(userFolder)) {
//     fs.mkdirSync(userFolder), { recursive: true };
//   }

const env = process.env;
console.log(env);
const ptyProcess = pty.spawn(shell, [], {
    name: 'xterm-color',
    cols: 80,
    rows: 30,
    cwd: process.cwd(),
    env: process.env

});


ptyProcess.onData((data) => {
        console.log("terminal data",data);
    io.emit("terminal:data", data);
})

io.on('connection', (socket) => {
    console.log("socket connected", socket.id);
    // ptyProcess.write('ls\r');
    // when terminal:write event
    socket.on("terminal:write", (data)=>{
        console.log("terminal write update",data);
        ptyProcess.write(`${data}\r`);
    });
});

// (()=>{
//     const templateName = 'nodejs';
// })();

// apis

// app.get('/getFiles', async (req, res, next) => {
//     const files = await fileOperations.getFiles(userFolder);
//     return res.json(files);
// });

console.log("app is reloading3");

const port = 8080;
server.listen(port, ()=>console.log("app is running on PORT", port));