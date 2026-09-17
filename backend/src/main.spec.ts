import { setupTests } from "@backend/test/helpers";
setupTests();

import { checkScript } from "@backend/main";

describe("main.ts", () => {
  let originalArgv: string[];
  let exitSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();
    originalArgv = process.argv;
    exitSpy = jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
  });

  afterEach(() => {
    process.argv = originalArgv;
  });

  describe("checkScript", () => {
    it("should throw error and exit 1 if script is unknown", async () => {
      process.argv = ["node", "main.js", "unknown-script"];

      await checkScript();

      expect(exitSpy).toHaveBeenCalledWith(1);
    });

    it("should handle script check", async () => {
      process.argv = ["node", "main.js"];
      expect(checkScript).toBeDefined();
    });
  });
});
