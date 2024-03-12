import fs from "fs";
import path from "path";
import * as YAML from "yaml";
import { name, version } from "../../package.json";
import { Logger } from "../logger";
import { ConfigurationMetadata } from "./configuration.metadata";
import { Configuration } from "./core";

/** This class controls loading configuration options from the config file and handles some other functionality associated to it. */
export class ConfigurationController {
  constructor() {
    this.save();
  }

  /** Returns the header to display at the top of the config file */
  get configHeader() {
    return `# ${name} Configuration File ${version}\n` + `# Any changes to this file will require a restart of the backend!` + `\n\n`;
  }

  /** Returns the where we should place the config file, also utilizing the env variable override. */
  get configFileLocation() {
    return path.join(process.cwd(), `${name}.yml`);
  }

  /** Given the YAML path, converts it to an object and returns it */
  yamlToObject(path = this.configFileLocation) {}

  /** Converts the given object to a YAML string and returns it */
  objectToYaml(obj: Object, tabLevel = 0) {
    return Object.keys(obj)
      .map((key) => {
        const metadata = Reflect.getMetadata(ConfigurationMetadata.METADATA_KEY, obj, key) as ConfigurationMetadata | undefined;
        // Ignore disabled configuration values
        if (metadata == null || metadata?.externalControlDisabled) return;
        const value = (obj as any)[key]; // TODO: Typing
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

  /** Gets the {@link Configuration} object as a YAML string */
  get configAsYml() {
    return this.objectToYaml(Configuration);
    // for (let key of Object.keys(Configuration)) {
    //   const value = Configuration
    //   console.log(key);
    // }
    // return "";
  }

  /** Saves the configuration from {@link Configuration} to the file */
  save(path = this.configFileLocation) {
    Logger.log(`Writing config file to ${path}`);
    const output = this.configHeader + this.configAsYml + "\n";
    fs.writeFileSync(path, output);
  }
}
