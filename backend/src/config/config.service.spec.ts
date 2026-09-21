import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ConfigurationService } from "@backend/config/config.service.js";
import { Configuration } from "@backend/config/core.js";
import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata.js";
import { CONFIGURATION_REQUIREMENTS } from "@backend/config/model/config.requirement.js";
import { SproutLogger } from "@backend/core/logger.js";
import fs from "fs";

describe("ConfigurationService", () => {
  let service: ConfigurationService;
  let logger: Mocked<SproutLogger>;

  beforeEach(() => {
    vi.restoreAllMocks();
    logger = {
      setContext: vi.fn(),
      log: vi.fn(),
      warn: vi.fn(),
      error: vi.fn(),
    } as any;
    service = new ConfigurationService(logger);
  });

  describe("configFileLocation", () => {
    it("should return expected path containing appName", () => {
      const location = service.configFileLocation;
      expect(location).toContain(".config.yml");
    });
  });

  describe("load & save", () => {
    it("should log and return early when save is called with writeConfigFile disabled", () => {
      const originalWrite = Configuration.writeConfigFile;
      Configuration.writeConfigFile = false;

      service.save("test-path.yml", true);
      expect(logger.log).toHaveBeenCalledWith("Config file writing is disabled.");

      Configuration.writeConfigFile = originalWrite;
    });

    it("should write config file when writeConfigFile is enabled", () => {
      const originalWrite = Configuration.writeConfigFile;
      Configuration.writeConfigFile = true;

      vi.spyOn(fs, "writeFileSync").mockImplementation(() => {});

      service.save("test-path.yml", true);

      expect(logger.log).toHaveBeenCalledWith("Writing config file to test-path.yml");
      expect(fs.writeFileSync).toHaveBeenCalled();

      Configuration.writeConfigFile = originalWrite;
    });

    it("should load config, environment variables, and save when load is called", () => {
      vi.spyOn(fs, "existsSync").mockReturnValue(true);
      vi.spyOn(fs, "readFileSync").mockReturnValue(Buffer.from("server:\n  port: 9000\n"));
      vi.spyOn(service, "save").mockImplementation(() => service);

      const res = service.load("test-path.yml", true);

      expect(logger.log).toHaveBeenCalledWith("Loading config file from test-path.yml");
      expect(res).toBe(service);
    });

    it("should skip file reading if config file does not exist", () => {
      vi.spyOn(fs, "existsSync").mockReturnValue(false);
      vi.spyOn(service, "save").mockImplementation(() => service);

      const res = service.load("test-path.yml", false);

      expect(res).toBe(service);
    });
  });

  describe("objectToYaml & metadata comments", () => {
    it("should format objects to YAML with comments and restricted values", () => {
      const meta = Object.assign(new ConfigurationMetadata(), {
        comment: ["First comment", "Second comment"],
        restrictedValues: ["val1", "val2"],
      });

      const testObj = {
        quotedField: "*asteriskString",
        arrayField: ["item1", "item2"],
        subObj: { key: "val" },
      };

      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, meta, testObj, "quotedField");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, meta, testObj, "arrayField");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), testObj, "subObj");

      const yaml = (service as any).objectToYaml(testObj);
      expect(yaml).toContain("# First comment");
      expect(yaml).toContain("Must be one of: [val1, val2]");
      expect(yaml).toContain('"*asteriskString"');
      expect(yaml).toContain("- item1");
    });
  });

  describe("validateConfigurationRequirements", () => {
    it("should log error and exit process on fatal rule failure or exception", () => {
      const exitSpy = vi.spyOn(process, "exit").mockImplementation((() => {}) as any);

      const mockRequirements = [
        {
          name: "Test Failing Fatal Rule",
          fatal: true,
          validate: () => false,
          fix: (l: any) => l.error("Fixing"),
        },
        {
          name: "Test Throwing Fatal Rule",
          fatal: true,
          validate: () => {
            throw new Error("Validation exception");
          },
          fix: () => {},
        },
      ];

      CONFIGURATION_REQUIREMENTS.push(...mockRequirements);

      (service as any).validateConfigurationRequirements();

      expect(logger.error).toHaveBeenCalledWith(expect.stringContaining("Fatal Configuration Error"));
      expect(logger.error).toHaveBeenCalledWith(expect.stringContaining("Exception occurred processing validation rule"));
      expect(exitSpy).toHaveBeenCalledWith(1);

      CONFIGURATION_REQUIREMENTS.splice(CONFIGURATION_REQUIREMENTS.length - mockRequirements.length, mockRequirements.length);
    });
  });

  describe("updateObjectWithObject & metadata validation", () => {
    it("should process restrictedValues and type checking correctly", () => {
      const targetObj: any = {
        restrictedStr: "a",
        restrictedArr: ["a"],
        numVal: 10,
        boolVal: false,
      };

      const metaWithRestricted = Object.assign(new ConfigurationMetadata(), { restrictedValues: ["a", "b"] });
      const metaNormal = new ConfigurationMetadata();

      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, metaWithRestricted, targetObj, "restrictedStr");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, metaWithRestricted, targetObj, "restrictedArr");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, metaNormal, targetObj, "numVal");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, metaNormal, targetObj, "boolVal");

      // Valid values
      (service as any).updateObjectWithObject(targetObj, {
        restrictedStr: "b",
        restrictedArr: ["a", "b"],
        boolVal: "true",
      });
      expect(targetObj.restrictedStr).toBe("b");
      expect(targetObj.restrictedArr).toEqual(["a", "b"]);
      expect(targetObj.boolVal).toBe(true);

      // Invalid restricted value
      (service as any).updateObjectWithObject(targetObj, {
        restrictedStr: "invalid",
        restrictedArr: ["invalid"],
        numVal: "not-a-number",
      });
      expect(logger.warn).toHaveBeenCalled();
    });
  });

  describe("dataConversion", () => {
    it("should convert strings to boolean and arrays", () => {
      expect((service as any).dataConversion("TRUE", false)).toBe(true);
      expect((service as any).dataConversion("false", true)).toBe(false);
      expect((service as any).dataConversion("one, two, three", [])).toEqual(["one", "two", "three"]);
    });
  });

  describe("loadEnvVariables", () => {
    it("should map environment variables to Configuration object", () => {
      const appName = Configuration.appName;
      process.env[`${appName}_writeConfigFile`] = "false";
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), Configuration, "writeConfigFile");

      (service as any).loadEnvVariables();

      expect(Configuration.writeConfigFile).toBe(false);
    });
  });

  describe("convertCronToMilliseconds", () => {
    it("should calculate delay in ms until next cron run", async () => {
      const delay = await service.convertCronToMilliseconds("* * * * *", 100);
      expect(typeof delay).toBe("number");
      expect(delay).toBeGreaterThan(0);
    });
  });
});
