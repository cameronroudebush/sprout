import { Base } from "@backend/core/model/base";
import { ApiProperty } from "@nestjs/swagger";

/** Information regarding the categories and their use for a user  */
export class CategoryStats extends Base {
  /** The number of transactions matching to each category */
  @ApiProperty({
    type: "object",
    additionalProperties: { type: "number" },
  })
  categoryCount: Record<string, number>;

  constructor(categoryCount: CategoryStats["categoryCount"]) {
    super();
    this.categoryCount = categoryCount;
  }
}
