import { setupTests } from "@backend/test/helpers.js";
setupTests();

import { Category } from "@backend/category/model/category.model.js";
import { TestEntities } from "@backend/test/entities.js";

describe("Category Model", () => {
  const user = TestEntities.user;

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("should create category instance with defaults", () => {
    const cat = new Category(user, "Dining Out");
    expect(cat.name).toBe("Dining Out");
    expect(cat.user).toBe(user);
    expect(cat.excludeFromCashFlow).toBe(false);
  });

  it("should return default categories for user", () => {
    const categories = Category.getDefaultCategoriesForUser(user);
    expect(categories.length).toBeGreaterThan(0);
    expect(categories[0].name).toBe("Food & Drink");
    expect(categories[1].name).toBe("Groceries");
  });

  it("should get unknown category", async () => {
    const unknownCategory = new Category(user, Category.UNKNOWN_NAME);
    vi.spyOn(Category, "findOne").mockResolvedValue(unknownCategory);

    const result = await Category.getUnknownCategory(user);
    expect(result).toBe(unknownCategory);
    expect(Category.findOne).toHaveBeenCalledWith({
      where: { user: { id: user.id }, name: "Unknown" },
    });
  });

  it("should get or create category", async () => {
    const unknownCategory = new Category(user, Category.UNKNOWN_NAME);
    vi.spyOn(Category, "getUnknownCategory").mockResolvedValue(unknownCategory);

    // 1. undefined category returns unknown category
    const res1 = await Category.getOrCreate(undefined, user);
    expect(res1).toBe(unknownCategory);

    // 2. existing category found
    const existingCategory = new Category(user, "Dining Out");
    vi.spyOn(Category, "findOne").mockResolvedValue(existingCategory);
    const res2 = await Category.getOrCreate("dining out", user);
    expect(res2).toBe(existingCategory);

    // 3. new category created
    vi.spyOn(Category, "findOne").mockResolvedValue(null);
    const createdCategory = new Category(user, "New Category");
    vi.spyOn(Category, "fromPlain").mockReturnValue({
      insert: vi.fn().mockResolvedValue(createdCategory),
    } as any);

    const res3 = await Category.getOrCreate("new category", user);
    expect(res3).toBe(createdCategory);
  });
});
