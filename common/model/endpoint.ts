import { CustomTypes } from "./custom.types";

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
  }

  /** Configuration endpoints */
  export class conf {
    static get = "/conf/get";
  }
}
