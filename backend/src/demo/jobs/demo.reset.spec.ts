import { setupTests } from "@backend/test/helpers";
setupTests();

import { DemoDataResetJob } from "@backend/demo/jobs/demo.reset";
import { DemoDataService } from "@backend/demo/demo.data.service";

describe("DemoDataResetJob", () => {
  let job: DemoDataResetJob;
  let demoDataService: jest.Mocked<DemoDataService>;

  beforeEach(() => {
    demoDataService = {
      populateDemoData: jest.fn().mockResolvedValue(true),
    } as any;

    job = new DemoDataResetJob(demoDataService);
  });

  it("should call populateDemoData when job runs update", async () => {
    const result = await (job as any).update();
    expect(demoDataService.populateDemoData).toHaveBeenCalled();
    expect(result).toBe(true);
  });
});
