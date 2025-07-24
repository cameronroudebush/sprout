import { CustomTypes } from "../utility/custom.types";

/** Container class for different rest requests */
export module RestEndpoints {
  /** Type that defines every supported endpoint strings we have */
  export type supportedEndpoints = CustomTypes.PropertyPaths<typeof RestEndpoints>;

  /** Given the generic type supported endpoint, returns the actual URL for the endpoint */
  export function typeToActualQueue(type: supportedEndpoints): string {
    const splits = type.split(".");
    let obj: Object = RestEndpoints;
    for (let split of splits) obj = obj[split as keyof Object] as Object;
    if (obj == null || typeof obj !== "string") throw new Error("Failed to split REST API endpoint");
    return obj as string;
  }

  /** Endpoints supported for the user */
  export class user {
    static login = "/user/login";
    static loginJWT = "/user/login/jwt";
  }

  /** Configuration endpoints */
  export class conf {
    static get = "/conf/get";
    /** Additional configuration information that will be given even without authentication */
    static getUnsecure = "/conf/get/unsecure";
  }

  /** Transaction endpoints for finance data */
  export class transaction {
    static get = "/transaction/get";
    static count = "/transaction/count";
    static stats = "/transaction/stats";
  }

  /** Net worth endpoints for finance data */
  export class netWorth {
    static getNetWorth = "/transaction/net-worth/get";
    static getNetWorthOverTime = "/transaction/net-worth/get/ot";
    static getNetWorthByAccount = "/transaction/net-worth/get/by/accounts";
  }

  /** Account endpoints for for the users supported banks */
  export class account {
    static get = "/account/get";
    static delete = "/account/delete";
    static getAll = "/account/get/all";
    static getAllFromProvider = "/account/provider/get/all";
    static link = "/account/provider/link";
  }

  /** Endpoints for setup of application */
  export class setup {
    static createUser = "/setup/user";
  }

  /** Endpoints for the background sync */
  export class sync {
    static runManual = "/sync/manual";
  }
}
