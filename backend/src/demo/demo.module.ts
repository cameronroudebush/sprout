import { DatabaseModule } from "@backend/database/database.module";
import { DemoDataService } from "@backend/demo/demo.data.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [DatabaseModule],
  controllers: [],
  providers: [DemoDataService],
  exports: [DemoDataService],
})
export class DemoModule {}
