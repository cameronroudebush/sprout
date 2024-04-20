import path from "path";
import { BackendBuilder } from "../backend/build";

/**
 * This module contains automatic functionality to be able to produce docker contains properly tagged for the sprout ecosystem
 */
export module DockerBuilder {
  function log(...message: any[]) {
    console.log("[Sprout Docker Builder]", ...message);
  }

  /** Executes the commands to build the docker container */
  export async function build() {
    const version = BackendBuilder.getGitVersion();
    const rootDir = path.join(__dirname, "..");
    log(`Building docker image for ${version}...`);
    const command = `docker build -f dockerfile -t sprout:${version} .`;
    await BackendBuilder.spawnProcess(command, rootDir);
    log("Build complete!");
  }
}

// Run the "main"
DockerBuilder.build();
