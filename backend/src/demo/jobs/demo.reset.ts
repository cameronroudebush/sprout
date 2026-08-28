import { Configuration } from "@backend/config/core";
import { BackgroundJob } from "@backend/core/jobs/model/job-base";
import { DemoDataService } from "@backend/demo/demo.data.service";
import { Injectable } from "@nestjs/common";

/** A job that is only enabled during demo mode that will allow us to reset database data */
@Injectable()
export class DemoDataResetJob extends BackgroundJob {
  constructor(private readonly demoDataService: DemoDataService) {
    super(`demo:data:reset`, "0 0 * * *", Configuration.isDemoMode);
  }

  protected override async update() {
    return await this.demoDataService.populateDemoData();
  }
}
