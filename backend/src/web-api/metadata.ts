import { RestRequest, SupportedPayloadTypes } from "@common";

export type supportedRestTypes = "GET" | "POST";

export type RestMetadataFunctionTypes<PayloadType extends SupportedPayloadTypes, ReturnType extends void | RestRequest<PayloadType> = void> = (
  request: RestRequest<PayloadType>
) => Promise<ReturnType>;

/** Class used to decorate functions to automatically listen to rest requests and handle them */
export class RestMetadata {
  /** Key for reflect metadata */
  static readonly METADATA_KEY = "rest:api:metadata";

  /** All loaded endpoints from anything using this file */
  static loadedEndpoints: { metadata: RestMetadata; fnc: RestMetadataFunctionTypes<any> }[] = []; // TODO: This is inefficient

  /** Queue to listen on */
  queue: string;
  /** The type we expect for this rest request to know how to respond */
  type: supportedRestTypes;
  /** If this endpoint should require authentication */
  requiresAuth: boolean;

  constructor(queue: string, type: supportedRestTypes = "GET", requiresAuth = true) {
    this.queue = queue;
    this.type = type;
    this.requiresAuth = requiresAuth;
  }

  /** Assigns the given metadata to the property this value decorates. */
  static register<PayloadType extends SupportedPayloadTypes>(data: RestMetadata) {
    return function (target: any, key: string, _descriptor: TypedPropertyDescriptor<RestMetadataFunctionTypes<PayloadType>>) {
      RestMetadata.loadedEndpoints.push({ metadata: data, fnc: target[key] });
      Reflect.defineMetadata(RestMetadata.METADATA_KEY, data, target, key);
    };
  }
}
