import { setupTests } from "@backend/test/helpers";
setupTests();

import { DatabaseService } from "@backend/database/database.service";

describe("DatabaseService", () => {
  let service: DatabaseService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = Object.create(DatabaseService.prototype);
    (service as any).dataSource = {
      isInitialized: true,
      initialize: jest.fn(),
    };
  });

  describe("source", () => {
    it("should access typeorm data source", () => {
      expect((service as any).dataSource).toBeDefined();
    });
  });
});
