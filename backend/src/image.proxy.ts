import { Sharp } from "sharp";
import ico from "sharp-ico";
import { Readable } from "typeorm/platform/PlatformTools";
import { CentralServer } from "./central.server";

/** A class that creates an image proxy to deal with CORS errors so this server can instead proxy them to you */
export class ImageProxy {
  constructor(centralServer: CentralServer) {
    centralServer.server.get("/image-proxy", async (req, res) => {
      try {
        const imageUrl = req.query["url"] as string | undefined;
        if (!imageUrl) return res.status(400).send("Image URL query is required");
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
