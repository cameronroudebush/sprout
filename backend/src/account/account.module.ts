import { AccountController } from "@backend/account/account.controller";
import { DatabaseModule } from "@backend/database/database.module";
import { JobsModule } from "@backend/jobs/jobs.module";
import { SSEModule } from "@backend/sse/sse.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [SSEModule, JobsModule, DatabaseModule],
  controllers: [AccountController],
  providers: [],
  exports: [],
})
export class AccountModule {}
