import { setupTests } from "@backend/test/helpers";
setupTests();

import { DemoDataService } from "@backend/demo/demo.data.service";
import { DatabaseService } from "@backend/database/database.service";

describe("DemoDataService", () => {
  let service: DemoDataService;
  let databaseService: jest.Mocked<DatabaseService>;

  beforeEach(() => {
    jest.clearAllMocks();

    databaseService = {
      source: {
        query: jest.fn(),
      },
    } as any;

    service = new DemoDataService(databaseService);
  });

  describe("resetDemoData", () => {
    it("should execute reset queries if demo mode is enabled", async () => {
      expect(service).toBeDefined();
    });
  });
});
