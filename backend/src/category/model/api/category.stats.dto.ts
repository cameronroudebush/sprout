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

  /** Color information for each category, in hex codes */
  @ApiProperty({
    type: "object",
    additionalProperties: { type: "string" },
  })
  colorMapping: Record<string, string>;

  constructor(categoryCount: CategoryStats["categoryCount"], colorMapping: CategoryStats["colorMapping"]) {
    super();
    this.categoryCount = categoryCount;
    this.colorMapping = colorMapping;
  }
}
