import { CategoryService } from "@backend/category/category.service";
import { CategoryStats } from "@backend/category/model/api/category.stats.dto";
import { Category } from "@backend/category/model/category.model";
import { CurrentUser } from "@backend/core/decorator/current-user.decorator";
import { AuthGuard } from "@backend/core/guard/auth.guard";
import { SSEService } from "@backend/sse/sse.service";
import { User } from "@backend/user/model/user.model";
import { Body, ConflictException, Controller, Delete, Get, NotFoundException, Param, Patch, Post, Query } from "@nestjs/common";
import { ApiBody, ApiConflictResponse, ApiCreatedResponse, ApiNotFoundResponse, ApiOkResponse, ApiOperation, ApiTags } from "@nestjs/swagger";
import { IsNull } from "typeorm";

/** This controller contains endpoints for {@link Category} models which allow us to group transactions. */
@Controller("category")
@ApiTags("Category")
@AuthGuard.attach()
export class CategoryController {
  constructor(
    private readonly categoryService: CategoryService,
    private readonly sseService: SSEService,
  ) {}

  @Get()
  @ApiOperation({
    summary: "Get categories.",
    description: "Retrieves all categories for the authenticated user.",
  })
  @ApiOkResponse({ description: "Categories found successfully.", type: [Category] })
  async getCategories(@CurrentUser() user: User) {
    return await Category.find({ where: { user: { id: user.id } }, relations: ["parentCategory"] });
  }

  @Get("stats")
  @ApiOperation({
    summary: "Gets category stats.",
    description: "Retrieves all categories for the authenticated user with the total number of transactions per category.",
  })
  @ApiOkResponse({ description: "Categories found successfully.", type: CategoryStats })
  async getCategoryStats(@CurrentUser() user: User, @Query("days") days: number = 30) {
    if (isNaN(days)) throw new Error("The number of days for category stats must be an integer.");
    return await this.categoryService.getStats(user, days);
  }

  @Post()
  @ApiOperation({
    summary: "Creates a new category.",
    description: "Creates a new category that can be used for transactions to associate to.",
  })
  @ApiCreatedResponse({ description: "Category added successfully.", type: Category })
  @ApiConflictResponse({ description: "A similar category already exists." })
  @ApiBody({ type: Category })
  async create(data: Category, @CurrentUser() user: User) {
    const category = Category.fromPlain(data);
    category.user = user;

    const parentId = category.parentCategory?.id;

    // Make sure we don't have any overlaps for user, name, and parentCategoryId
    const similarCategories = await Category.find({
      where: {
        name: category.name,
        user: { id: user.id },
        parentCategoryId: parentId ? parentId : IsNull(),
      },
    });
    if (similarCategories.length > 0) throw new ConflictException("A similar category already exists.");

    return await category.insert();
  }

  @Delete(":id")
  @ApiOperation({
    summary: "Delete category by ID.",
    description: "Deletes a category by the given ID and updates references to it to reset them.",
  })
  @ApiOkResponse({ description: "Category deleted successfully." })
  @ApiNotFoundResponse({ description: "Category with the specified ID not found." })
  async delete(@Param("id") id: string, @CurrentUser() user: User) {
    const matchingCategory = await Category.findOne({ where: { id: id, user: { id: user.id } }, relations: ["parentCategory"] });
    if (matchingCategory == null) throw new NotFoundException("Failed to find matching category to delete.");

    // If the deleted category has children, reassign them to the deleted category's parent
    if (matchingCategory.parentCategory)
      await Category.updateWhere({ parentCategory: { id: matchingCategory.id } }, { parentCategory: matchingCategory.parentCategory });

    await Category.deleteById(matchingCategory.id);
    this.sseService.sendToUser(user, "force-update"); // Tell clients of this user to update so that transactional data is refreshed
    return `Category with ID ${id} deleted successfully.`;
  }

  @Patch(":id")
  @ApiOperation({
    summary: "Edit category.",
    description: "Edits a category by the given ID.",
  })
  @ApiOkResponse({ description: "Category updated successfully.", type: Category })
  @ApiNotFoundResponse({ description: "Category with the specified ID not found or does not belong to the user." })
  @ApiBody({ type: Category })
  async edit(@Param("id") id: string, @CurrentUser() user: User, @Body() update: Category) {
    const matchingCategory = await Category.findOne({ where: { id: id, user: { id: user.id } } });
    if (matchingCategory == null) throw new NotFoundException("Failed to find matching category to edit.");
    // Update the category object
    const updatedCategory = Category.fromPlain({ ...update, user: user, userId: user.id, id: matchingCategory.id });
    await updatedCategory.update();
    this.sseService.sendToUser(user, "force-update"); // Tell clients of this user to update so that transactional data is refreshed
    return updatedCategory;
  }
}
