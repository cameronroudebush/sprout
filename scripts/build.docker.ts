import { exec } from "child_process";
import path from "path";
import { promisify } from "util";
const execPromise = promisify(exec);

/**
 * This module contains automatic functionality to be able to produce docker contains properly tagged for the sprout ecosystem
 */
export module DockerBuilder {
  /** Returns the version string to use to describe this build */
  export async function getVersion() {
    const { stdout, stderr } = await execPromise("git describe");
    if (stderr) throw new Error(stderr);
    else return stdout.replace(/\r?\n|\r/g, " ").trim();
  }

  /** Executes the commands to build the docker container */
  export async function build() {
    const version = await getVersion();
    const rootDir = path.join(__dirname, "..");
    console.log(`Building docker image for sprout ${version}...`);
    const command = `docker build -f dockerfile -t sprout:${version} .`;
    // console.log(version, rootDir, command, __filename);
    const dockerProcess = exec(command, { cwd: rootDir });
    dockerProcess.stdout?.pipe(process.stdout);
    dockerProcess.stderr?.pipe(process.stderr);
    dockerProcess.on("close", () => {
      console.log(`Build complete!`);
    });
  }
}

// Run the "main"
DockerBuilder.build();
