const fs = require("fs");
const readFileSync = fs.readFileSync;

const versions = JSON.stringify(JSON.parse(readFileSync("./version.json")));

console.log(versions);
