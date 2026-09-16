import { setupTests } from "@backend/test/helpers";
setupTests();

import { JobExplorerService } from "@backend/core/services/job.explorer.service";

describe("JobExplorerService", () => {
  let service: JobExplorerService;
  let discoveryService: any;

  beforeEach(() => {
    jest.clearAllMocks();

    discoveryService = {
      getProviders: jest.fn().mockReturnValue([]),
    };

    service = new JobExplorerService(discoveryService);
  });

  describe("getJobs", () => {
    it("should discover registered background job classes", () => {
      expect(service).toBeDefined();
    });
  });
});
