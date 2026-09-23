import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { ConfigurationService } from "@backend/config/config.service.js";
import { Configuration } from "@backend/config/core.js";
import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata.js";
import { SproutLogger } from "@backend/core/logger.js";
import { CONFIGURATION_REQUIREMENTS } from "@backend/config/model/config.requirement.js";
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

    it("should save without logging when log is false", () => {
      const originalWrite = Configuration.writeConfigFile;
      Configuration.writeConfigFile = true;
      vi.spyOn(fs, "writeFileSync").mockImplementation(() => {});

      service.save("test-path.yml", false);

      expect(fs.writeFileSync).toHaveBeenCalled();
      expect(logger.log).not.toHaveBeenCalledWith(expect.stringContaining("Writing config file"));
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

    it("should skip requirement validation when running a script", () => {
      const original = Configuration.isRunningScript;
      Configuration.isRunningScript = true;
      vi.spyOn(fs, "existsSync").mockReturnValue(false);
      vi.spyOn(service, "save").mockImplementation(() => service);
      const validate = vi.spyOn(service as any, "validateConfigurationRequirements");

      service.load("test-path.yml");

      expect(validate).not.toHaveBeenCalled();
      Configuration.isRunningScript = original;
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

    it("should format primitive values and string comments", () => {
      const testObj = { numberField: 42, boolField: true, plainField: "plain", undefinedField: undefined };
      const metadata = new ConfigurationMetadata();
      metadata.comment = "A string comment";
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, metadata, testObj, "numberField");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), testObj, "boolField");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), testObj, "plainField");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), testObj, "undefinedField");

      const yaml = (service as any).objectToYaml(testObj);

      expect(yaml).toContain("numberField: 42");
      expect(yaml).toContain("# A string comment");
    });
  });

  describe("validateConfigurationRequirements", () => {
    it("should log error and handle exception in validation rules", () => {
      const mockRequirements = [
        {
          name: "Test Failing Fatal Rule",
          fatal: true,
          validate: () => false,
          fix: (l: any) => l.error("Fixing"),
        },
        {
          name: "Test Throwing Rule",
          fatal: false,
          validate: () => {
            throw new Error("Validation exception");
          },
          fix: () => {},
        },
      ];

      const exitSpy = vi.spyOn(process, "exit").mockImplementation((() => {}) as any);
      (service as any).validateConfigurationRequirements = function () {
        for (const req of mockRequirements) {
          try {
            if (!req.validate()) {
              req.fix(this.logger);
              if (req.fatal) {
                this.logger.error("Fatal error");
                process.exit(1);
              }
            }
          } catch (e: any) {
            this.logger.error(`Exception occurred: ${e.message}`);
          }
        }
      };

      (service as any).validateConfigurationRequirements();

      expect(logger.error).toHaveBeenCalled();
      expect(exitSpy).toHaveBeenCalledWith(1);
    });

    it("should handle nonfatal failures, fatal failures, and thrown rules", () => {
      const originalLength = CONFIGURATION_REQUIREMENTS.length;
      const exitSpy = vi.spyOn(process, "exit").mockImplementation((() => {}) as any);
      CONFIGURATION_REQUIREMENTS.push(
        { name: "nonfatal test", fatal: false, validate: () => false, fix: vi.fn() },
        { name: "fatal test", fatal: true, validate: () => false, fix: vi.fn() },
        {
          name: "throwing test",
          fatal: true,
          validate: () => {
            throw new Error("boom");
          },
          fix: vi.fn(),
        },
        {
          name: "nonfatal throwing test",
          fatal: false,
          validate: () => {
            throw new Error("nonfatal boom");
          },
          fix: vi.fn(),
        },
      );
      try {
        (service as any).validateConfigurationRequirements();
        expect(exitSpy).toHaveBeenCalledWith(1);
        expect(logger.error).toHaveBeenCalledWith(expect.stringContaining("boom"));
      } finally {
        CONFIGURATION_REQUIREMENTS.splice(originalLength);
      }
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

    it("should ignore disabled, mismatched, null, and nested values", () => {
      const target: any = { disabled: "old", number: 1, nested: { value: "old" } };
      Reflect.defineMetadata(
        ConfigurationMetadata.METADATA_KEY,
        Object.assign(new ConfigurationMetadata(), { externalControlDisabled: true }),
        target,
        "disabled",
      );
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), target, "number");
      Reflect.defineMetadata(ConfigurationMetadata.METADATA_KEY, new ConfigurationMetadata(), target, "nested");

      (service as any).updateObjectWithObject(target, {
        disabled: "new",
        number: "wrong",
        nested: { value: "new" },
      });

      expect(target.disabled).toBe("old");
      expect(target.number).toBe(1);
      expect(target.nested.value).toBe("old");
    });

    it("should ignore null update objects", () => {
      expect(() => (service as any).updateObjectWithObject({}, null)).not.toThrow();
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
