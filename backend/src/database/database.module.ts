import { DatabaseService } from "@backend/database/database.service";
import { Module } from "@nestjs/common";

@Module({
  imports: [],
  controllers: [],
  providers: [DatabaseService],
  exports: [DatabaseService],
})
export class DatabaseModule {}
