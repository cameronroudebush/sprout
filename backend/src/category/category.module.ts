import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { SSEModule } from "@backend/sse/sse.module";
import { Module } from "@nestjs/common";

@Module({
  imports: [SSEModule],
  controllers: [CategoryController],
  providers: [CategoryService],
  exports: [CategoryService],
})
export class CategoryModule {}
