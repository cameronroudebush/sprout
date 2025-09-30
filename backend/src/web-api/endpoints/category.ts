import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { Category } from "@backend/model/category";
import { User } from "@backend/model/user";
import { RestMetadata } from "../metadata";

export class CategoryAPI {
  /** Returns the categories of the given user */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.categories, "GET"))
  async getCategories(_request: RestBody, user: User) {
    return await Category.find({ where: { user: { id: user.id } } });
  }

  /** Returns the category stats for this users transactions */
  @RestMetadata.register(new RestMetadata(RestEndpoints.transaction.categoryStats, "GET"))
  async getCategoryStats(request: RestBody, user: User) {
    const days = parseInt(request.payload["days"]);
    if (days == null || isNaN(days)) throw new Error("You must include the number of days to get stats from");
    return await Category.getStats(user, days);
  }
}
