import { setupTests } from "@backend/test/helpers";
setupTests();

import { JobsConfig } from "@backend/core/jobs/model/jobs.config";

describe("JobsConfig model", () => {
  it("should instantiate JobsConfig", () => {
    const config = new JobsConfig();
    expect(config).toBeDefined();
  });
});
