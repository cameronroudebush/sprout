import { setupTests } from "@backend/test/helpers";
setupTests();

import { Category } from "@backend/category/model/category.model";
import { TestEntities } from "@backend/test/entities";

describe("Category Model", () => {
  const user = TestEntities.user;

  it("should create category instance with defaults", () => {
    const cat = new Category(user, "Dining Out");
    expect(cat.name).toBe("Dining Out");
    expect(cat.user).toBe(user);
    expect(cat.excludeFromCashFlow).toBe(false);
  });
});
