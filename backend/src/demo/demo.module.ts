import { DatabaseModule } from "@backend/database/database.module";
import { DemoDataService } from "@backend/demo/demo.data.service";
import { DemoDataResetJob } from "@backend/demo/jobs/demo.reset";
import { Module } from "@nestjs/common";

@Module({
  imports: [DatabaseModule],
  controllers: [],
  providers: [DemoDataService, DemoDataResetJob],
  exports: [DemoDataService],
})
export class DemoModule {}
