import { setupTests } from "@backend/test/helpers";
setupTests();

import { ConfigurationService } from "@backend/config/config.service";
import { Configuration } from "@backend/config/core";
import { SproutLogger } from "@backend/core/logger";
import fs from "fs";

describe("ConfigurationService", () => {
  let service: ConfigurationService;
  let logger: Mocked<SproutLogger>;

  beforeEach(() => {
    vi.clearAllMocks();
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

  describe("convertCronToMilliseconds", () => {
    it("should calculate delay in ms until next cron run", async () => {
      const delay = await service.convertCronToMilliseconds("* * * * *", 100);
      expect(typeof delay).toBe("number");
      expect(delay).toBeGreaterThan(0);
    });
  });
});
