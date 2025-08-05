import { RestEndpoints } from "@backend/model/api/endpoint";
import { RestBody } from "@backend/model/api/rest.request";
import { Holding } from "@backend/model/holding";
import { User } from "@backend/model/user";
import { RestMetadata } from "../metadata";

/** This class provides holding data via REST requests */
export class HoldingAPI {
  /** Returns the holdings for all accounts  */
  @RestMetadata.register(new RestMetadata(RestEndpoints.holding.get, "GET"))
  async getHoldings(_request: RestBody, user: User) {
    const holdings = await Holding.find({ where: { account: { user: { id: user.id } } } });
    return holdings;
  }
}
