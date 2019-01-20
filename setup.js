const fs = require("fs");
const execSync = require("child_process").execSync;
const npm = cmd => {
  const result = execSync("npm " + cmd, { encoding: "utf8" });
  console.log(result);
};
const getVersions = filePath => {
  const version = JSON.parse(fs.readFileSync(filePath))["version"];
  const versions = version.split(".");
  return {
    dependency: versions[1],
    build: versions[2],
  };
};

const packageVersions = getVersions("./package.json");
let currentVersions;
try {
  fs.statSync("./lib/version");
  currentVersions = getVersions("./lib/version");
} catch (err) {
  npm("ci");
  npm("run build");
  return;
}

if (packageVersions.dependency !== currentVersions.dependency) {
  npm("ci");
  npm("run build");
} else if (packageVersions.build !== currentVersions.build) {
  npm("run build");
}
