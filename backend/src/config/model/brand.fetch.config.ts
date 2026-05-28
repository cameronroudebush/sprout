import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Configuration options for image control (things like domain icons, ticket icons, etc.) */
export class BrandFetchConfig {
  @ConfigurationMetadata.assign({ comment: "The client ID from brandfetch. If not given, we fallback to not showing any images in the frontend." })
  clientId?: string;
}
