import { User } from "@backend/model/user";
import { Request, Response } from "express";
import { Sharp } from "sharp";
import ico from "sharp-ico";
import { Readable } from "typeorm/platform/PlatformTools";

/**
 * A class that creates an image proxy so that institution URL's can be easily turned into an image
 */
export class ImageProxy {
  /**
   * If google sucks at finding an icon for us to use, we can add manual mappings here to use instead.
   *
   * If you want a better looking icon for a site you use, open a PR and update this mapping.
   */
  static MANUAL_PROXY: { [key: string]: string } = {
    "www.wpcu.coop": "https://play-lh.googleusercontent.com/mIXMOB7Kxi0BsD5HnYcWdA-wdJbdphhMp0TfSZ6m1o8PBy86xNhegeOmrpJ5S2D2tVU",
    "www.discover.com": "https://companieslogo.com/img/orig/DFS-72325cfa.png?t=1720244491",
  };

  /** Handles the given request for the institution image proxy  */
  async handleImageProxy(req: Request, res: Response, _user: User) {
    {
      const imageUrl = req.query["url"] as string | undefined;
      if (!imageUrl) return res.status(400).send("Image URL query is required");
      // Cleanup the request url
      const cleanImageUrl = imageUrl.replace("https://", "");
      const manualMapping = ImageProxy.MANUAL_PROXY[cleanImageUrl];
      let imageRequestURL: string;
      if (manualMapping != null) imageRequestURL = manualMapping;
      else imageRequestURL = `https://www.google.com/s2/favicons?domain=${cleanImageUrl}&sz=128`;
      const result = await fetch(imageRequestURL);
      if (!result.ok) return res.status(result.status).send(res.statusMessage);

      const contentType = result.headers.get("content-type");
      // Handle some issues with content types
      if (contentType === "image/vnd.microsoft.icon" || contentType === "image/x-icon") {
        const buffer = await result.arrayBuffer();
        const icons = ico.sharpsFromIco(buffer as unknown as Buffer) as Sharp[];
        res.setHeader("Content-Type", "image/png");
        const png = icons[0]!.png();
        return png!.pipe(res);
      } else {
        res.setHeader("Content-Type", contentType!);
        return Readable.fromWeb(result.body as any).pipe(res);
      }
    }
  }
}
