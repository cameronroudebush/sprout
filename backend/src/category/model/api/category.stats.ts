import { Base } from "@backend/core/model/base";

/** Information regarding the categories and their use for a user  */
export class CategoryStats extends Base {
  /** The number of transactions matching to each category */
  categoryCount: { [name: string]: number };

  constructor(categoryCount: CategoryStats["categoryCount"]) {
    super();
    this.categoryCount = categoryCount;
  }
}
