import { Sharp } from "sharp";
import ico from "sharp-ico";
import { Readable } from "typeorm/platform/PlatformTools";
import { CentralServer } from "./central.server";

/**
 * A class that creates an image proxy to deal with CORS errors so this server can
 *  instead proxy them to you. This is intended to be used with {@link https://synthfinance.com/}.
 */
export class ImageProxy {
  /**
   * If URL's come in that match any of these, we'll direct the request to this different
   *  image. This might be because synth doesn't have a good looking logo match.
   */
  static MANUAL_PROXY: { [key: string]: string } = {
    "https://logo.synthfinance.com/www.wpcu.coop": "https://play-lh.googleusercontent.com/mIXMOB7Kxi0BsD5HnYcWdA-wdJbdphhMp0TfSZ6m1o8PBy86xNhegeOmrpJ5S2D2tVU",
  };

  constructor(centralServer: CentralServer) {
    centralServer.server.get("/image-proxy", async (req, res) => {
      try {
        let imageUrl = req.query["url"] as string | undefined;
        if (!imageUrl) return res.status(400).send("Image URL query is required");
        if (Object.keys(ImageProxy.MANUAL_PROXY).includes(imageUrl)) imageUrl = ImageProxy.MANUAL_PROXY[imageUrl]!;
        const result = await fetch(imageUrl);
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
      } catch (e) {
        return res.status(500).send((e as Error).message);
      }
    });
  }
}
