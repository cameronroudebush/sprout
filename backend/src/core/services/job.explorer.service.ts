import { Configuration } from "@backend/config/core";
import { BackgroundJob } from "@backend/core/jobs/model/job-base";
import { Injectable, OnApplicationBootstrap } from "@nestjs/common";
import { DiscoveryService } from "@nestjs/core";

/** This core services auto starts our jobs by locating them across all the modules */
@Injectable()
export class JobExplorerService implements OnApplicationBootstrap {
  constructor(private readonly discoveryService: DiscoveryService) {}

  async onApplicationBootstrap() {
    if (Configuration.isRunningScript) return;
    const providers = this.discoveryService.getProviders();
    for (const wrapper of providers) {
      const { instance } = wrapper;
      if (!instance) continue;
      const jobInstances = Array.isArray(instance) ? instance : [instance];
      for (const job of jobInstances) if (job && job instanceof BackgroundJob && typeof job.start === "function") await job.start();
    }
  }
}
