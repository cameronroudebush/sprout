import { ConfigurationMetadata } from "@backend/config/model/configuration.metadata";

/** Configuration options for image control (things like domain icons, ticket icons, etc.) */
export class BrandFetchConfig {
  @ConfigurationMetadata.assign({ comment: "The client ID from brandfetch. If not given, we fallback to not showing any images in the frontend." })
  clientId?: string;

  /** Helper to format a domain name from a raw URL or domain string */
  private cleanDomain(inputUrl: string): string {
    try {
      const uri = new URL(inputUrl.startsWith("http") ? inputUrl : `https://${inputUrl}`);
      const host = uri.hostname || inputUrl;
      return host.replace(/^www\./, "");
    } catch (_) {
      return inputUrl;
    }
  }

  /** Centralized helper to build the Brandfetch icon URL for a given website URL */
  getWebsiteIconUrl(websiteUrl: string | null | undefined, size: number = 64): string | null {
    if (!websiteUrl || !this.clientId) return null;
    const domain = this.cleanDomain(websiteUrl);
    return `https://cdn.brandfetch.io/domain/${domain}/fallback/404/h/${size}/w/${size}/icon?c=${this.clientId}`;
  }
}
