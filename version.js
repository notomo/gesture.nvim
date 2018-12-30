const fs = require("fs");

const readFileSync = fs.readFileSync;
const version = JSON.parse(readFileSync("./package.json"))["version"];

fs.writeFileSync("./lib/version", version);
