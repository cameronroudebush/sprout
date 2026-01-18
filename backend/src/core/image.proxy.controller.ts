import { AuthGuard } from "@backend/auth/guard/auth.guard";
import { Controller, Get, Query, Res, StreamableFile } from "@nestjs/common";
import { ApiBadRequestResponse, ApiInternalServerErrorResponse, ApiOkResponse, ApiOperation, ApiQuery, ApiTags } from "@nestjs/swagger";
import { Response } from "express";
import sharp, { Sharp } from "sharp";
import ico from "sharp-ico";
import { Readable } from "stream";

/**
 * This controller is used to proxy images from given requests with required user
 *  authentication. This allows us to deal with cors issues while still dynamically getting images.
 */
@Controller("image-proxy")
@ApiTags("Core")
@AuthGuard.attach()
export class ImageProxyController {
  /**
   * If google sucks at finding an icon for us to use, or they look bad, we can add manual mappings here to use instead.
   *
   * If you want a better looking icon for a site you use, open a PR and update this mapping.
   */
  static MANUAL_PROXY: { [key: string]: string } = {
    "www.wpcu.coop": "https://play-lh.googleusercontent.com/mIXMOB7Kxi0BsD5HnYcWdA-wdJbdphhMp0TfSZ6m1o8PBy86xNhegeOmrpJ5S2D2tVU",
    "www.discover.com": "https://companieslogo.com/img/orig/DFS-72325cfa.png?t=1720244491",
  };

  @Get()
  @ApiOperation({
    summary: "Proxy images for institutions.",
    description: "Proxies images from external URLs, handling CORS issues and dynamically fetching images. Supports full image URLs or favicon lookups.",
  })
  @ApiQuery({ name: "fullImageUrl", required: false, description: "A full URL to an image. If provided, faviconImageUrl will be ignored." })
  @ApiQuery({ name: "faviconImageUrl", required: false, description: "A base URL to fetch a favicon for. Used if fullImageUrl is not provided." })
  @ApiOkResponse({ description: "Image successfully proxied." })
  @ApiBadRequestResponse({ description: "Missing required query parameters." })
  @ApiInternalServerErrorResponse({ description: "Internal server error or upstream image fetch failed." })
  async handleImageProxy(
    @Res({ passthrough: true }) res: Response,
    @Query("fullImageUrl") fullImageUrl: string | undefined,
    @Query("faviconImageUrl") faviconImageUrl: string | undefined,
  ) {
    if (!fullImageUrl && !faviconImageUrl) {
      res.status(400).send("We require either a [fullImageUrl] or [faviconImageUrl] query.");
      return;
    }

    let result: globalThis.Response;
    // Determine how we should handle this
    if (fullImageUrl) {
      result = await fetch(fullImageUrl);
    } else {
      const cleanImageUrl = faviconImageUrl!.replace("https://", "");
      const manualMapping = ImageProxyController.MANUAL_PROXY[cleanImageUrl];
      let imageRequestURL: string;
      if (manualMapping != null) imageRequestURL = manualMapping;
      else imageRequestURL = `https://www.google.com/s2/favicons?domain=${cleanImageUrl}&sz=128`;
      result = await fetch(imageRequestURL);
    }

    if (result == null) {
      res.status(500).send();
      return;
    } else if (!result.ok) {
      res.status(result.status).send(result.statusText);
      return;
    }

    const contentType = result.headers.get("content-type");
    res.setHeader("Content-Type", contentType!);

    // Handle some issues with content types
    if (contentType === "image/vnd.microsoft.icon" || contentType === "image/x-icon") {
      const buffer = await result.arrayBuffer();
      const icons = ico.sharpsFromIco(Buffer.from(buffer)) as Sharp[];
      res.setHeader("Content-Type", "image/png");
      return new StreamableFile(icons[0]!.png());
    } else if (contentType === "image/svg+xml") {
      const buffer = await result.arrayBuffer();
      res.setHeader("Content-Type", "image/png");
      return new StreamableFile(sharp(Buffer.from(buffer)).png());
    }
    return new StreamableFile(Readable.fromWeb(result.body as any));
  }
}
