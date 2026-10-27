import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { CategoryIcon } from "@backend/category/model/category-icon.js";

describe("CategoryIcon", () => {
  it("resolves the same category keys used by the frontend to Material Icons URLs", () => {
    expect(CategoryIcon.getKey("food_drink")).toBe("food_drink");
    expect(CategoryIcon.getName("food_drink")).toBe("fastfood");
    expect(CategoryIcon.getUrl("food_drink")).toBe("https://fonts.gstatic.com/s/i/materialicons/fastfood/v1/24px.svg");
  });

  it("uses a safe question mark icon for missing or unknown category keys", () => {
    expect(CategoryIcon.getUrl()).toContain("materialiconsround/question_mark/v1/24px.svg");
    expect(CategoryIcon.getUrl("not-a-category")).toContain("materialiconsround/question_mark/v1/24px.svg");
  });
});
