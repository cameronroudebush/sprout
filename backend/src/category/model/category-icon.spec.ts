import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CategoryIcon } from "@backend/category/model/category-icon.js";

describe("CategoryIcon", () => {
  it("resolves the same category keys used by the frontend to Material Symbols URLs", () => {
    expect(CategoryIcon.getKey("food_drink")).toBe("food_drink");
    expect(CategoryIcon.getName("food_drink")).toBe("fastfood");
    expect(CategoryIcon.getUrl("food_drink")).toBe("https://api.iconify.design/material-symbols/fastfood.svg?height=28&color=%23a0cafd");
  });

  it("uses a safe question mark icon for missing or unknown category keys", () => {
    expect(CategoryIcon.getUrl()).toContain("material-symbols/question-mark.svg");
    expect(CategoryIcon.getUrl("not-a-category")).toContain("material-symbols/question-mark.svg");
  });
});
