const fs = require("fs");
const readFileSync = fs.readFileSync;

const filePath = process.argv[2];
const version = JSON.parse(readFileSync(filePath))["version"];

const output = { version: version };
const outputJson = JSON.stringify(output);

console.log(outputJson);
