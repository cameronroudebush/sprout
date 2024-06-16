import path from "path";
import { BackendBuilder } from "../backend/build";

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
    const version = BackendBuilder.getGitVersion();
    const rootDir = path.join(__dirname, "..");
    log(`Building docker image for ${version}...`);
    if (additionalTags.length > 0) log(`Including additional tags ${additionalTags.join(", ")}`);
    const command = `docker build -f dockerfile -t sprout:${version}${additionalTags.map((x) => ` -t ${x}`)} .`;
    await BackendBuilder.spawnProcess(command, rootDir);
    log("Build complete!");
  }
}

// Run the "main"
DockerBuilder.build();
