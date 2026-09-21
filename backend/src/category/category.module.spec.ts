import { setupTests } from "@backend/test/helpers";
setupTests();

import { CategoryModule } from "@backend/category/category.module";

describe("CategoryModule", () => {
  it("should define CategoryModule class", () => {
    expect(CategoryModule).toBeDefined();
  });
});
