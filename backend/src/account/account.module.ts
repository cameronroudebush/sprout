import { AccountController } from "@backend/account/account.controller";
import { DatabaseModule } from "@backend/database/database.module";
import { ProviderModule } from "@backend/providers/provider.module";
import { SSEModule } from "@backend/sse/sse.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [SSEModule, DatabaseModule, ProviderModule],
  controllers: [AccountController],
  providers: [],
  exports: [],
})
export class AccountModule {}
