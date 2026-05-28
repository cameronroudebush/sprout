import { InstitutionController } from "@backend/institution/institution.controller";
import { SSEModule } from "@backend/sse/sse.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [SSEModule],
  controllers: [InstitutionController],
  providers: [],
  exports: [],
})
export class InstitutionModule {}
