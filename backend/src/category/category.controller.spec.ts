import { setupTests } from "@backend/test/helpers";
setupTests();

import { CategoryController } from "@backend/category/category.controller";
import { CategoryService } from "@backend/category/category.service";
import { Category } from "@backend/category/model/category.model";
import { SSEEventType } from "@backend/sse/model/event.model";
import { SSEService } from "@backend/sse/sse.service";
import { TestEntities } from "@backend/test/entities";
import { Transaction } from "@backend/transaction/model/transaction.model";
import { ConflictException, NotFoundException } from "@nestjs/common";
import { IsNull } from "typeorm";

describe("CategoryController", () => {
  let controller: CategoryController;
  let categoryService: Mocked<CategoryService>;
  let sseService: Mocked<SSEService>;
  const user = TestEntities.user;

  beforeEach(() => {
    categoryService = {
      getStats: vi.fn(),
    } as any;

    sseService = {
      sendToUser: vi.fn(),
    } as any;

    controller = new CategoryController(categoryService, sseService);
  });

  describe("getCategories", () => {
    it("should return categories for user", async () => {
      const mockCategories = [TestEntities.category];
      vi.spyOn(Category, "find").mockResolvedValue(mockCategories);

      const res = await controller.getCategories(user);

      expect(Category.find).toHaveBeenCalledWith({
        where: { user: { id: user.id } },
        relations: { parentCategory: true },
      });
      expect(res).toBe(mockCategories);
    });
  });

  describe("getCategoryStats", () => {
    it("should call categoryService getStats", async () => {
      const mockStats = { categories: [] };
      categoryService.getStats.mockResolvedValue(mockStats as any);

      const res = await controller.getCategoryStats(user, 2026, 5, 12);

      expect(categoryService.getStats).toHaveBeenCalledWith(user, 2026, 5, 12);
      expect(res).toBe(mockStats);
    });
  });

  describe("getUnknownCategoryStats", () => {
    it("should count transactions with null category when accountId is provided", async () => {
      vi.spyOn(Transaction, "count").mockResolvedValue(7);

      const res = await controller.getUnknownCategoryStats(user, "acc-1");

      expect(Transaction.count).toHaveBeenCalledWith({
        where: { category: IsNull(), pending: false, account: { user: { id: user.id }, id: "acc-1" } },
      });
      expect(res).toBe(7);
    });

    it("should count transactions with null category when accountId is undefined", async () => {
      vi.spyOn(Transaction, "count").mockResolvedValue(3);

      const res = await controller.getUnknownCategoryStats(user);

      expect(Transaction.count).toHaveBeenCalledWith({
        where: { category: IsNull(), pending: false, account: { user: { id: user.id } } },
      });
      expect(res).toBe(3);
    });
  });

  describe("create", () => {
    it("should throw ConflictException if a similar category exists", async () => {
      vi.spyOn(Category, "find").mockResolvedValue([TestEntities.category]);

      const newCategory = Category.fromPlain({ name: "Groceries" });

      await expect(controller.create(newCategory, user)).rejects.toThrow(ConflictException);
    });

    it("should insert category if no conflict and handle parentCategoryId", async () => {
      vi.spyOn(Category, "find").mockResolvedValue([]);
      const insertSpy = vi.spyOn(Category.prototype, "insert").mockResolvedValue({} as any);

      const cat = Category.fromPlain({ name: "Dining Out", parentCategoryId: "parent-123" });

      await controller.create(cat, user);

      expect(Category.find).toHaveBeenCalledWith({
        where: {
          name: "Dining Out",
          user: { id: user.id },
          parentCategoryId: "parent-123",
        },
      });
      expect(insertSpy).toHaveBeenCalled();
    });

    it("should insert category using IsNull() when parentCategoryId is undefined", async () => {
      vi.spyOn(Category, "find").mockResolvedValue([]);
      const insertSpy = vi.spyOn(Category.prototype, "insert").mockResolvedValue({} as any);

      const cat = Category.fromPlain({ name: "Utilities" });

      await controller.create(cat, user);

      expect(Category.find).toHaveBeenCalledWith({
        where: {
          name: "Utilities",
          user: { id: user.id },
          parentCategoryId: IsNull(),
        },
      });
      expect(insertSpy).toHaveBeenCalled();
    });
  });

  describe("delete", () => {
    it("should throw NotFoundException if category does not exist", async () => {
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(controller.delete("invalid-id", user)).rejects.toThrow(NotFoundException);
    });

    it("should delete category, update children if parent exists, and send SSE", async () => {
      const parent = new Category(user, "Parent");
      parent.id = "parent-1";

      const cat = new Category(user, "Child");
      cat.id = "cat-1";
      cat.parentCategory = parent;

      vi.spyOn(Category, "findOne").mockResolvedValue(cat);
      const updateWhereSpy = vi.spyOn(Category, "updateWhere").mockResolvedValue({} as any);
      vi.spyOn(Category, "deleteById").mockResolvedValue({} as any);

      const msg = await controller.delete("cat-1", user);

      expect(updateWhereSpy).toHaveBeenCalledWith({ parentCategory: { id: "cat-1" } }, { parentCategory: parent });
      expect(Category.deleteById).toHaveBeenCalledWith("cat-1");
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(msg).toContain("cat-1");
    });

    it("should delete category without updating children if parentCategory is undefined", async () => {
      const cat = new Category(user, "Root Category");
      cat.id = "cat-1";

      vi.spyOn(Category, "findOne").mockResolvedValue(cat);
      vi.spyOn(Category, "deleteById").mockResolvedValue({} as any);

      const msg = await controller.delete("cat-1", user);

      expect(Category.deleteById).toHaveBeenCalledWith("cat-1");
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(msg).toContain("cat-1");
    });
  });

  describe("edit", () => {
    it("should throw NotFoundException if category to edit is not found", async () => {
      vi.spyOn(Category, "findOne").mockResolvedValue(null);

      await expect(controller.edit("invalid-id", user, Category.fromPlain({ name: "Test" }))).rejects.toThrow(NotFoundException);
    });

    it("should update category, trim name, set parentCategoryId null on 'unknown', and notify user", async () => {
      const cat = Category.fromPlain({ id: "cat-1", name: "Old Name", user });
      vi.spyOn(Category, "findOne").mockResolvedValue(cat);

      const updateData = Category.fromPlain({ name: "  Updated Name  ", parentCategoryId: "unknown" });
      const updateSpy = vi.spyOn(Category.prototype, "update").mockResolvedValue({} as any);

      const res = await controller.edit("cat-1", user, updateData);

      expect(updateSpy).toHaveBeenCalled();
      expect(sseService.sendToUser).toHaveBeenCalledWith(user, SSEEventType.FORCE_UPDATE);
      expect(res.name).toBe("Updated Name");
      expect(res.parentCategoryId).toBeNull();
    });

    it("should retain existing name if update.name is undefined and assign valid parentCategoryId", async () => {
      const cat = Category.fromPlain({ id: "cat-1", name: "Existing Name", user });
      vi.spyOn(Category, "findOne").mockResolvedValue(cat);

      const updateData = Category.fromPlain({ parentCategoryId: "parent-456" });
      const updateSpy = vi.spyOn(Category.prototype, "update").mockResolvedValue({} as any);

      const res = await controller.edit("cat-1", user, updateData);

      expect(updateSpy).toHaveBeenCalled();
      expect(res.name).toBe("Existing Name");
      expect(res.parentCategoryId).toBe("parent-456");
    });
  });
});
