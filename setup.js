const fs = require("fs");
const execSync = require("child_process").execSync;
const npm = cmd => {
  const result = execSync("npm " + cmd, { encoding: "utf8" });
  console.log(result);
};
const getVersions = filePath => {
  const versions = JSON.parse(fs.readFileSync(filePath));
  return {
    dependency: versions["dependency"],
    build: versions["build"],
  };
};

const packageVersions = getVersions("./version.json");
let currentVersions;
try {
  fs.statSync("./lib/version.json");
  currentVersions = getVersions("./lib/version.json");
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
