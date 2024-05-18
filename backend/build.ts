import { spawn } from "child_process";
import fs from "fs";
import { gitDescribeSync } from "git-describe";
import nodemon from "nodemon";
import path from "path";
import { replaceInFileSync } from "replace-in-file";
import { replaceTscAliasPaths } from "tsc-alias";
import { CancellablePromise, Utility } from "../common/model/utility";
import { compilerOptions } from "./tsconfig.json";

/** This type helps provide metadata for variables we want to replace */
type VariableReplace = {
  /** The path to the file in dist, not including the backend directory within the distribution folder. You also should exclude extensions */
  path: string;
  /** Regex of what to replace */
  from: RegExp;
  /** A value to replace to */
  to: string;
};

/**
 * This file is used to help the build process of the backend by implementing some basic
 *  options and replacing args as needed. This works by compiling the typescript to javascript into a distribution
 *  directory, replacing some content in it, then either building it with pkg or running it with nodemon.
 *
 * You can pass `-m prod` or `-m dev` to switch between building prod or running a dev env. Not passing a `-m` value
 *  will cause this file to not execute.
 */
export module BackendBuilder {
  /** Tracks running build tasks. */
  const builds: CancellablePromise<void>[] = [];
  /** The secret key for development to replace the standard randomly generated secret key. */
  const developmentSecret = "DEV-KEY";
  /** The path to the src folder of the backend within the build output */
  const backendDistributionDir = path.join(__dirname, compilerOptions.outDir, "backend", "src");

  function log(...message: any[]) {
    console.log("[Backend Builder]", ...message);
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

  /** Returns our version number based on git describe */
  export function getGitVersion() {
    const gitInfo = gitDescribeSync();
    return gitInfo.distance! > 0 ? gitInfo.raw.replace("-dirty", "") : gitInfo.tag!;
  }

  async function main() {
    const mode = process.argv[3];
    const isProd = mode === "prod";
    log(`Starting for ${mode} mode...`);

    if (isProd) {
      await buildDist(isProd);
      log(`Building executable...`);
      await spawnProcess("pkg package.json");
      log(`Build complete!`);
    } else await spawnNodemon();
  }

  /** Spins up the nodemon handler to auto restart on file changes. */
  async function spawnNodemon(
    isProd = false,
    config: nodemon.Settings = {
      exec: `node "${path.join(backendDistributionDir, "main.js")}"`,
      ext: "ts",
      watch: ["../common/model", "./src"],
    },
  ) {
    // Monkey patch restart within nodemon so we can rebuild before we restart
    const runner = require("nodemon/lib/monitor/run");
    const killRef = runner.kill;
    const bus = require("nodemon/lib/utils/bus");
    runner.kill = async (...args: any[]) => {
      try {
        const shouldRebuild = args[0] == null;
        if (shouldRebuild) {
          // Kill execution before rebuilding so the backend actually stops. Nodemon internal call.
          killRef(true);
          // Cancel any running builds
          if (builds.length > 0) {
            log("Cancelling previous builds...");
            for (let build of builds) build.cancel();
          } else log("Rebuilding due to changes...");
          // Fire the actual build
          const called = buildDist(isProd);
          if (!called) return;
          else {
            await called;
            // Once the call is complete for the rebuild, start the process again using more nodemon internal calls.
            bus.once("start", () => {});
            runner.restart();
          }
        }
      } catch {}
    };
    await buildDist(isProd);
    nodemon(config);
  }

  /** Centralized function that builds the distribution to the output directory and handles other required functionality for the dist. */
  async function buildDist(isProd: boolean, version = getGitVersion()) {
    const promise = new CancellablePromise<void>(async function (this: CancellablePromise<void>, res, rej) {
      try {
        await Utility.delay(50); // Artificial wait for large number file changes. This allows multiple files being saved at once to not even start building as we'll get multiple build calls.
        this.check();
        log(`App version ${version}`);

        // Build app to distribution
        log(`Removing existing distribution directory at: ${compilerOptions.outDir}...`);
        fs.rmSync(compilerOptions.outDir, { recursive: true, force: true });
        this.check();
        log(`Compiling typescript to javascript...`);
        await spawnProcess("tsc --project tsconfig.build.json");
        this.check();
        log("Updating tsconfig paths...");
        await replaceTscAliasPaths();
        this.check();

        // Apply env variables we wish to replace
        const replace: VariableReplace[] = [
          { path: "config/core", from: /APP-VERSION/g, to: version },
          { path: "config/core", from: /isDevBuild\s=\s\w+;/g, to: `isDevBuild = ${!isProd};` },
        ];
        // Replace specifics during development mode
        if (!isProd) replace.push({ path: "config/core", from: /secretKey\s=\s(uuid.v4\(\));/g, to: `secretKey = "${developmentSecret}";` });

        replaceVars(replace);
        this.check();
        res();
      } catch (e) {
        rej(e);
      } finally {
        // Remove our tracked build
        const index = builds.findIndex((x) => x === promise);
        if (index !== -1) builds.splice(index, 1);
      }
    });
    // Push current build
    builds.push(promise);
    return promise;
  }

  /** Replaces variables in the built distribution with the given configurations */
  function replaceVars(varsToReplace: VariableReplace[]) {
    log(`Applying dynamic variables...`);
    for (let opt of varsToReplace) replaceInFileSync({ ...opt, files: path.join(backendDistributionDir, opt.path + ".js"), disableGlobs: true });
  }

  // Only execute main if this is ran with a -m command.
  if (process.argv[2] != null) main();
}
