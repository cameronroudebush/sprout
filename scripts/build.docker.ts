import { spawn } from "child_process";
import { gitDescribeSync } from "git-describe";
import path from "path";

/** Returns our version number based on git describe */
export function getGitVersion() {
  const gitInfo = gitDescribeSync();
  return gitInfo.distance! > 0 ? gitInfo.raw.replace("-dirty", "") : gitInfo.tag!;
}

/** Simple centralized spawn process function for a command so we can implement default capabilities */
export async function spawnProcess(command: string, cwd = path.join(__dirname)) {
  return new Promise((res, rej) => {
    const proc = spawn(command, { cwd, stdio: "inherit", shell: true });
    proc.on("close", res);
    proc.on("error", rej);
    proc.on("exit", (code) => {
      if (code !== 0) rej(code);
    });
  });
}

/**
 * This module contains automatic functionality to be able to produce docker contains properly tagged for the sprout ecosystem
 */
export module DockerBuilder {
  function log(...message: any[]) {
    console.log("[Sprout Docker Builder]", ...message);
  }

  /**
   * Executes the commands to build the docker container
   *
   * Additional tags can be added as arguments to this script.
   *
   * Like: `npm run build:docker -t croudebush/sprout:dev`
   */
  export async function build() {
    const additionalTags = process.argv.slice(2);
    const version = getGitVersion();
    const rootDir = path.join(__dirname, "..");
    log(`Building docker image for ${version}...`);
    if (additionalTags.length > 0) log(`Including additional tags ${additionalTags.join(", ")}`);
    const command = `docker build -f dockerfile -t sprout:${version}${additionalTags.map((x) => ` -t ${x}`)} .`;
    await spawnProcess(command, rootDir);
    log("Build complete!");
  }
}

// Run the "main"
DockerBuilder.build();
