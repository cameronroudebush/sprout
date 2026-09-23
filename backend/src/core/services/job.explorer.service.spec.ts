import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it, vi } from "vitest";

setupTests();

import { JobExplorerService } from "./job.explorer.service.js";
import { BackgroundJob } from "@backend/core/jobs/model/job-base.js";
import { Configuration } from "@backend/config/core.js";

class DummyJob extends BackgroundJob<any> {
  constructor() {
    super("dummy-job", "0 * * * *", false, false);
  }
  protected async update() {}
}

describe("JobExplorerService", () => {
  it("should discover and start background jobs when not running script", async () => {
    Configuration.isRunningScript = false;

    const dummyJob = new DummyJob();
    vi.spyOn(dummyJob, "start").mockResolvedValue(undefined as any);

    const discoveryService = {
      getProviders: () => [{ instance: null }, { instance: dummyJob }, { instance: [dummyJob] }],
    } as any;

    const service = new JobExplorerService(discoveryService);
    await service.onApplicationBootstrap();

    expect(dummyJob.start).toHaveBeenCalled();
  });

  it("should skip providers that are not valid background jobs", async () => {
    Configuration.isRunningScript = false;

    const dummyJob = new DummyJob();
    const startSpy = vi.spyOn(dummyJob, "start").mockResolvedValue(undefined as any);

    // instanceof BackgroundJob but missing a callable `start`
    const brokenJob = Object.assign(new DummyJob(), { start: undefined });

    const discoveryService = {
      getProviders: () => [{ instance: {} as any }, { instance: [null, {} as any] }, { instance: [brokenJob] }, { instance: dummyJob }],
    } as any;

    const service = new JobExplorerService(discoveryService);
    await service.onApplicationBootstrap();

    expect(startSpy).toHaveBeenCalledTimes(1);
  });

  it("should skip background job startup when running script", async () => {
    Configuration.isRunningScript = true;

    const discoveryService = {
      getProviders: vi.fn(),
    } as any;

    const service = new JobExplorerService(discoveryService);
    await service.onApplicationBootstrap();

    expect(discoveryService.getProviders).not.toHaveBeenCalled();
  });
});
