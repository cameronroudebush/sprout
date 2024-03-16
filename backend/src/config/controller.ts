import fs from "fs";
import path from "path";
import * as YAML from "yaml";
import { name, version } from "../../package.json";
import { Logger } from "../logger";
import { ConfigurationMetadata } from "./configuration.metadata";
import { Configuration } from "./core";

/** This class controls loading configuration options from the config file and handles some other functionality associated to it. */
export class ConfigurationController {
  /** Separator used for env variable lookup */
  static readonly ENV_VARIABLE_SEPARATOR = "_";

  /** Returns the header to display at the top of the config file */
  private get configHeader() {
    return (
      `# ${name} Configuration File ${version}\n` +
      `# Any changes to this file will require a restart of the backend!\n` +
      `#\n` +
      `#\n` +
      `# You can also configure this application using environment variables. To do this, you can use the separator: '${ConfigurationController.ENV_VARIABLE_SEPARATOR}'\n` +
      `#  after the name of the application followed by the tree of the variable. So if you would want to change the plaid secret key, you would do something\n` +
      `#  like: '${name}${ConfigurationController.ENV_VARIABLE_SEPARATOR}plaid${ConfigurationController.ENV_VARIABLE_SEPARATOR}secret=foobar'\n` +
      `# Anything added to the environment variables will not cause any changes in the config file but will be loaded into memory.\n` +
      `\n\n`
    );
  }

  /** Returns the where we should place the config file. */
  private get configFileLocation() {
    return path.join(process.cwd(), `${name}.config.yml`);
  }

  /** Updates the static {@link Configuration} via the configuration file. */
  private updateConfigFromFile(path = this.configFileLocation) {
    // No available config file? Don't update anything then
    if (!fs.existsSync(path)) return;
    // Load yaml as JSON from config location
    const yamlObject = YAML.parse(fs.readFileSync(path).toString());
    // Callback function to recursively perform the update
    const update = (objToUpdate: any, objectToUpdateFrom: any) => {
      for (let key of Object.keys(objectToUpdateFrom)) {
        const value = objectToUpdateFrom[key];
        // Find metadata from parent
        const metadata = Reflect.getMetadata(ConfigurationMetadata.METADATA_KEY, objToUpdate, key) as ConfigurationMetadata | undefined;
        // Ignore non enabled keys
        if (metadata == null || metadata?.externalControlDisabled) continue;
        // Ignore non matching types
        else if (typeof value !== typeof objToUpdate[key]) continue;
        // Recursively call the update
        else if (typeof value === "object") update(objToUpdate[key], objectToUpdateFrom[key]);
        // Handle normal fields
        else objToUpdate[key] = value;
      }
    };
    update(Configuration, yamlObject);
  }

  /** Loads environment variables and overrides the {@link Configuration} object. Will not write these out to the file. */
  private loadEnvVariables() {
    const matchingAppKeys = Object.keys(process.env).filter((key) => key.includes(name));
    // Take the matching keys and assign them to the config object
    for (let key of matchingAppKeys) {
      const value = process.env[key as keyof Object];
      const adjustedKey = key.replace(name, "").replace(ConfigurationController.ENV_VARIABLE_SEPARATOR, "");
      const splitKeys = adjustedKey.split(ConfigurationController.ENV_VARIABLE_SEPARATOR);
      // Reduce the object down to find what needs updated
      let currentObj: Object = Configuration;
      for (let i = 0; i < splitKeys.length; i++) {
        const keyPart = splitKeys[i];
        if (i === splitKeys.length - 1) {
          // Null values aren't possible. All configuration values should have a value
          if (currentObj[keyPart as keyof Object] == null) break;
          else currentObj[keyPart as keyof Object] = value as any;
        } else currentObj = currentObj[keyPart as keyof Object];
      }
    }
  }

  /** Converts the given object to a YAML string and returns it */
  private objectToYaml(obj: Object, tabLevel = 0) {
    return Object.keys(obj)
      .map((key) => {
        const metadata = Reflect.getMetadata(ConfigurationMetadata.METADATA_KEY, obj, key) as ConfigurationMetadata | undefined;
        // Ignore disabled configuration values
        if (metadata == null || metadata?.externalControlDisabled) return;
        const value = obj[key as keyof Object];
        if (value == null) return; // Ignore bad values
        let shouldNewlineWrap = typeof value === "object" && !Array.isArray(value) && value != null; // If we should wrap our current content to a new line
        // The output value
        let outputString: string;
        // Normal Objects
        if (typeof value === "object" && !Array.isArray(value)) outputString = this.objectToYaml(value, tabLevel + 1);
        // Arrays
        else if (Array.isArray(value)) outputString = value.map((x) => `${Array(tabLevel + 2).join("  ")}- ${x}`).join("\n");
        // Everything else
        else {
          const stringVal = typeof value === "string" ? value : YAML.stringify(value);
          outputString = stringVal.replace(/\n(?!\s)/gm, "\n").trimEnd();
        }
        const paddingDepth = Array(tabLevel + 1).join("  ");
        const commentData = metadata.comment ? `${metadata.comment ? `${paddingDepth}# ${metadata.comment}` : ""} ` : "";
        const actualValue = `${paddingDepth}${key}:${shouldNewlineWrap ? "\n" : " "}${outputString}`;
        return `${commentData ? commentData + "\n" : ""}${actualValue}`;
      })
      .filter((x) => x != null)
      .join(tabLevel === 0 ? "\n\n" : "\n");
  }

  /** Loads the configuration file from {@link configFileLocation} */
  load(path = this.configFileLocation) {
    Logger.log(`Loading config file from ${path}`);
    this.updateConfigFromFile();
    // Save the changes so config file is kept up to date with changes.
    this.save();
    // Load any env variables
    this.loadEnvVariables();
    return this;
  }

  /** Saves the configuration from {@link Configuration} to the file */
  save(path = this.configFileLocation) {
    Logger.log(`Writing config file to ${path}`);
    const configObject = this.objectToYaml(Configuration);
    const output = this.configHeader + configObject + "\n";
    fs.writeFileSync(path, output);
    return this;
  }
}
