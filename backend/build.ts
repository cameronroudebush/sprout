/**
 * This file is used to help the build process of the backend by implementing some basic
 *  options and replacing args as needed.
 *
 * You can pass `-m prod` or `-m dev` to switch between building prod or running a dev env. Not passing a `-m` value
 *  will cause this file to not execute.
 */

import { spawn } from "child_process";
import fs from "fs";
import { gitDescribeSync } from "git-describe";
import path from "path";
import replace from "replace-in-file";
import { replaceTscAliasPaths } from "tsc-alias";
import { compilerOptions } from "./tsconfig.json";

export module BackendBuilder {
  function log(...message: any[]) {
    console.log("[Sprout Backend Builder]", ...message);
  }

  /** Simple centralized spawn process function for a command so we can implement default capabilities */
  export async function spawnProcess(command: string, cwd = path.join(__dirname)) {
    return new Promise((res, rej) => {
      const proc = spawn(command, { cwd, stdio: "inherit", shell: true });
      proc.on("close", res);
      proc.on("error", rej);
    });
  }

  /** Returns our version number based on git describe */
  export function getGitVersion() {
    const gitInfo = gitDescribeSync();
    let versionNumber = gitInfo.tag!;
    // Add hash if not clean
    if (gitInfo.dirty) versionNumber += `-${gitInfo.hash}`;
    return versionNumber;
  }

  async function main() {
    // Determine if this is a prod build
    const isProd = process.argv[2] === "-m" && process.argv[3] === "prod";
    log(`Starting for ${process.argv[3]} mode...`);
    const versionNumber = getGitVersion();
    log(`App version ${versionNumber}`);
    // Handle prod capabilities
    if (isProd) {
      process.env["NODE_ENV"] = "prod";
      // Remove tsconfig output directory
      fs.rmSync(compilerOptions.outDir, { recursive: true, force: true });
      // Use TSC to build
      log(`Building code...`);
      await spawnProcess("tsc");
      // Update alias paths
      log(`Updating TSC Paths...`);
      await replaceTscAliasPaths();
      // Update version in config file for distribution
      log(`Applying Version Number...`);
      replace({ files: "./dist/backend/src/config/core.js", from: /process.env\["APP_VERSION"\]/g, to: `\"${versionNumber}\"` });
      // Build executable with pkg
      log(`Building executable...`);
      await spawnProcess("pkg package.json");
    } else {
      // Handle dev capabilities
      process.env["NODE_ENV"] = "dev";
      process.env["APP_VERSION"] = versionNumber;
      // Start the app
      const extraFilesToWatch = "--watch=" + ["../common/*.ts", "../common/*.json"].join(",");
      await spawnProcess(`ts-node-dev -r tsconfig-paths/register --respawn --rs ${extraFilesToWatch} ./src/main.ts`);
    }
    log(`Process Complete!`);
  }

  // Only execute main if this is ran with a -m command.
  if (process.argv[2] != null) main();
}
