import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { Category } from "@backend/model/category";
import { User } from "@backend/model/user";
import { RestMetadata } from "../metadata";
import { SSEAPI } from "./sse";

export class CategoryAPI {
  /** Returns the categories of the given user */
  @RestMetadata.register(new RestMetadata(RestEndpoints.category.get, "GET"))
  async getCategories(_request: RestBody, user: User) {
    return await Category.find({ where: { user: { id: user.id } }, relations: ["parentCategory"] });
  }

  /** Returns the category stats for this users transactions */
  @RestMetadata.register(new RestMetadata(RestEndpoints.category.stats, "GET"))
  async getCategoryStats(request: RestBody, user: User) {
    const requestedDays = request.payload["days"];
    if (requestedDays != null && isNaN(parseInt(requestedDays))) throw new Error("The number of days for category stats must be an integer.");
    const days = requestedDays ? parseInt(requestedDays) : undefined;
    return await Category.getStats(user, days);
  }

  /** Add's a new category to the database */
  @RestMetadata.register(new RestMetadata(RestEndpoints.category.add, "GET"))
  async add(request: RestBody<Category>, user: User) {
    const category = Category.fromPlain(request.payload);
    category.user = user;
    return await category.insert();
  }

  /** Delete's the given category from the database */
  @RestMetadata.register(new RestMetadata(RestEndpoints.category.delete, "GET"))
  async delete(request: RestBody<Category>, user: User) {
    const matchingCategory = await Category.findOne({ where: { id: request.payload.id, user: { id: user.id } }, relations: ["parentCategory"] });
    if (matchingCategory == null) throw new Error("Failed to find matching category to delete.");

    // If the deleted category has children, reassign them to the deleted category's parent
    if (matchingCategory.parentCategory)
      await Category.updateWhere({ parentCategory: { id: matchingCategory.id } }, { parentCategory: matchingCategory.parentCategory });

    await Category.deleteById(matchingCategory.id);
    SSEAPI.forceUpdate(user); // Tell clients of this user to update so that transactional data is refreshed
    return matchingCategory;
  }

  /** Edits's the given category from the database */
  @RestMetadata.register(new RestMetadata(RestEndpoints.category.edit, "GET"))
  async edit(request: RestBody<Category>, user: User) {
    const matchingCategory = await Category.findOne({ where: { id: request.payload.id, user: { id: user.id } } });
    if (matchingCategory == null) throw new Error("Failed to find matching category to edit.");
    // Update the category object
    const updatedCategory = Category.fromPlain({ ...request.payload, user: user, userId: user.id, id: matchingCategory.id });
    SSEAPI.forceUpdate(user); // Tell clients of this user to update so that transactional data is refreshed
    return await updatedCategory.update();
  }
}
