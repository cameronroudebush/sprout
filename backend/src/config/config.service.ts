import { Injectable, Logger } from "@nestjs/common";
import fs from "fs";
import { set } from "lodash";
import path from "path";
import * as YAML from "yaml";
import { Configuration } from "./core";
import { ConfigurationMetadata } from "./model/configuration.metadata";

/** This class controls loading configuration options from the config file and handles some other functionality associated to it. */
@Injectable()
export class ConfigurationService {
  private readonly logger = new Logger(ConfigurationService.name);

  /** Separator used for env variable lookup */
  static readonly ENV_VARIABLE_SEPARATOR = "_";

  /** Returns the header to display at the top of the config file */
  private get configHeader() {
    return (
      `# ${Configuration.appName} Configuration File ${Configuration.version}\n` +
      `# Any changes to this file will require a restart of the backend!\n` +
      `#\n` +
      `# You can also configure this application using environment variables. To do this, you can use the separator: '${ConfigurationService.ENV_VARIABLE_SEPARATOR}'\n` +
      `#  after the name of the application followed by the tree of the variable. So if you would want to change the server port, you would do something\n` +
      `#  like: '${Configuration.appName}${ConfigurationService.ENV_VARIABLE_SEPARATOR}server${ConfigurationService.ENV_VARIABLE_SEPARATOR}port=9000'\n` +
      `# Anything added to the environment variables will not cause any changes in the config file but will be loaded into memory.\n` +
      `\n`
    );
  }

  /** Returns the where we should place the config file. */
  get configFileLocation() {
    return path.join(process.cwd(), `${Configuration.appName}.config.yml`);
  }

  /** Updates the given object with the object to update from. Allows recursive handling */
  private updateObjectWithObject(objToUpdate: any, objectToUpdateFrom: any) {
    if (objectToUpdateFrom == null) return;
    for (let key of Object.keys(objectToUpdateFrom)) {
      const value = this.dataConversion(objectToUpdateFrom[key], objToUpdate[key]);
      // Find metadata from parent
      const metadata = Reflect.getMetadata(ConfigurationMetadata.METADATA_KEY, objToUpdate, key) as ConfigurationMetadata | undefined;
      // Ignore non enabled keys
      if (metadata == null || metadata?.externalControlDisabled) continue;
      // Ignore non restricted values
      else if (metadata.restrictedValues != null && !metadata.restrictedValues.includes(value)) continue;
      // Ignore non matching types
      else if (objToUpdate[key] != null && typeof value !== typeof objToUpdate[key]) continue;
      // Recursively call the update
      else if (typeof value === "object") this.updateObjectWithObject(objToUpdate[key], objectToUpdateFrom[key]);
      // Handle normal fields
      else objToUpdate[key] = value;
    }
  }

  /** Updates the static {@link Configuration} via the configuration file. */
  private updateConfigFromFile(path = this.configFileLocation) {
    // No available config file? Don't update anything then
    if (!fs.existsSync(path)) return;
    // Load yaml as JSON from config location
    const yamlObject = YAML.parse(fs.readFileSync(path).toString());
    this.updateObjectWithObject(Configuration, yamlObject);
  }

  /** Loads environment variables and overrides the {@link Configuration} object. Will not write these out to the file. */
  private loadEnvVariables() {
    const matchingAppKeys = Object.keys(process.env).filter((key) => key.includes(Configuration.appName));
    // Flatten the object based on the path they've given in the env for each key
    const reducedObject = matchingAppKeys.reduce((obj, envKey) => {
      const value = process.env[envKey as keyof Object];
      const keyPath = envKey.replace(Configuration.appName, "").replace(ConfigurationService.ENV_VARIABLE_SEPARATOR, "");
      set(obj, keyPath.replaceAll(ConfigurationService.ENV_VARIABLE_SEPARATOR, "."), value);
      return obj;
    }, {});
    this.updateObjectWithObject(Configuration, reducedObject);
  }

  /** Converts the given object to a YAML string and returns it */
  private objectToYaml(obj: Object, tabLevel = 0) {
    return Object.keys(obj)
      .map((key) => {
        const metadata = Reflect.getMetadata(ConfigurationMetadata.METADATA_KEY, obj, key) as ConfigurationMetadata | undefined;
        // Ignore disabled configuration values
        if (metadata == null || metadata?.externalControlDisabled) return;
        const value = obj[key as keyof Object];
        let shouldNewlineWrap = typeof value === "object" && !Array.isArray(value) && value != null; // If we should wrap our current content to a new line
        // The output value
        let outputString: string;
        // Normal Objects
        if (typeof value === "object" && !Array.isArray(value)) outputString = this.objectToYaml(value, tabLevel + 1);
        // Arrays
        else if (Array.isArray(value)) outputString = value.map((x) => `\n${Array(tabLevel + 2).join("  ")}- ${x}`).join("");
        // Everything else
        else {
          const stringVal = typeof value === "string" ? value : YAML.stringify(value);
          outputString = stringVal?.replace(/\n(?!\s)/gm, "\n")?.trimEnd();
        }
        const paddingDepth = Array(tabLevel + 1).join("  ");
        let commentString = "";
        if (metadata.comment) {
          const commentAsArray = Array.isArray(metadata.comment) ? metadata.comment : [metadata.comment];
          // Add required values if specified
          if (metadata.restrictedValues) commentAsArray.push(`Must be one of: [${metadata.restrictedValues.join(", ")}]`);
          commentString = commentAsArray.map((x) => `${paddingDepth}# ${x}`).join("\n") + "\n";
        }
        const needsQuoted = outputString?.startsWith("*");
        const actualValue = `${paddingDepth}${key}:${shouldNewlineWrap ? "\n" : " "}${needsQuoted ? '"' : ""}${outputString == null ? "" : outputString}${needsQuoted ? '"' : ""}`;
        return `${commentString}${actualValue}`;
      })
      .filter((x) => x != null)
      .join(tabLevel === 0 ? "\n\n" : "\n");
  }

  /** Loads the configuration file from {@link configFileLocation} */
  load(path = this.configFileLocation, log = false) {
    if (log) this.logger.log(`Loading config file from ${path}`);
    this.updateConfigFromFile();
    // Save the changes so config file is kept up to date with changes.
    this.save(undefined, log);
    // Load any env variables
    this.loadEnvVariables();
    return this;
  }

  /** Saves the configuration from {@link Configuration} to the file */
  save(path = this.configFileLocation, log = false) {
    if (log) this.logger.log(`Writing config file to ${path}`);
    const configObject = this.objectToYaml(Configuration);
    const output = this.configHeader + configObject + "\n";
    fs.writeFileSync(path, output);
    return this;
  }

  /** Converts data to the requested type before trying to insert it into the config */
  private dataConversion(value: any, targetData: any) {
    if (typeof targetData === "boolean" && typeof value === "string") {
      const lower = value.toLowerCase();
      if (lower === "true") value = true;
      if (lower === "false") value = false;
    }
    return value;
  }
}
