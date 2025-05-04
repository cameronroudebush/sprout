import { Configuration } from "@backend/config/core";
import { Base, RestBody, User } from "@common";

/** Supported RESTful API req types we currently use */
export type SupportedRestTypes = "GET" | "POST";
export type SupportedReturnTypes = void | Base | Base[] | string | number;

/// Define our different styles of returns
type FunctionAuth<ReturnType extends SupportedReturnTypes = void> = (request: RestBody, user: User) => Promise<ReturnType>;
type FunctionStandard<ReturnType extends SupportedReturnTypes = void> = (request: RestBody) => Promise<ReturnType>;
type FunctionNoParam<ReturnType extends SupportedReturnTypes = void> = () => Promise<ReturnType>;
/** Defines the function styling for RESTful API functions */
export type RestMetadataFunctionTypes<ReturnType extends SupportedReturnTypes = void> =
  | FunctionStandard<ReturnType>
  | FunctionNoParam<ReturnType>
  | FunctionAuth<ReturnType>;

/** Class used to decorate functions to automatically listen to rest requests and handle them */
export class RestMetadata {
  /** Key for reflect metadata */
  static readonly METADATA_KEY = "rest:api:metadata";

  /** All loaded endpoints from anything using this file */
  static loadedEndpoints: { metadata: RestMetadata; fnc: RestMetadataFunctionTypes }[] = []; // TODO: This is inefficient

  /** Queue to listen on */
  queue: string;
  /** The type we expect for this rest request to know how to respond */
  type: SupportedRestTypes;
  /** If this endpoint should require authentication */
  requiresAuth: boolean;

  constructor(queue: string, type: SupportedRestTypes = "GET", requiresAuth = true) {
    this.queue = Configuration.server.apiBasePath + queue;
    this.type = type;
    this.requiresAuth = requiresAuth;
  }

  /** Assigns the given metadata to the property this value decorates. */
  static register(data: RestMetadata) {
    return function <ReturnType extends Base | Base[] | string | number | void>(
      target: any,
      key: string,
      _descriptor:
        | TypedPropertyDescriptor<FunctionStandard<ReturnType>>
        | TypedPropertyDescriptor<FunctionNoParam<ReturnType>>
        | TypedPropertyDescriptor<FunctionAuth<ReturnType>>,
    ) {
      if (RestMetadata.loadedEndpoints.find((x) => x.metadata.queue === data.queue)) throw new Error("Cannot have two functions for the same REST endpoints");
      RestMetadata.loadedEndpoints.push({ metadata: data, fnc: target[key] });
      Reflect.defineMetadata(RestMetadata.METADATA_KEY, data, target, key);
    };
  }
}
