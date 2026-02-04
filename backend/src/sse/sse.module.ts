import { SSEController } from "@backend/sse/sse.controller";
import { SSEService } from "@backend/sse/sse.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [],
  controllers: [SSEController],
  providers: [SSEService],
  exports: [SSEService],
})
export class SSEModule {}
