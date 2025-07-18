import { Configuration } from "@backend/config/core";
import express, { Response } from "express";
import { rateLimit } from "express-rate-limit";
import { Logger } from "./logger";

/**
 * The central server provides us a singular backend endpoint consuming a single port that can provide web request responses
 */
export class CentralServer {
  constructor(public readonly server = express()) {
    Logger.info(`Spinning up Central Server on port ${Configuration.server.port}...`);
    server.listen(Configuration.server.port);
    server.use(this.rateLimiter);
    server.set("trust proxy", 1);
    server.use(express.json());
    server.all("*", (req, res, next) => {
      Logger.info(`Incoming request on ${req.url}`);
      this.setCORSHeaders(res);
      // Handle options requests
      if (req.method === "OPTIONS") return res.status(200).end();
      else return next();
    });
  }

  /** Returns the rate limiter for the express server to attempt to not overwhelm any endpoints */
  get rateLimiter() {
    return rateLimit({
      windowMs: 1 * 60000, // 1 minute
      limit: Configuration.isDevBuild ? Infinity : 1000, // 1000 requests per minute
      standardHeaders: "draft-7",
      legacyHeaders: false,
    });
  }

  /** Sets CORS headers for the given response */
  setCORSHeaders(res: Response) {
    // TODO
    res.header(`Access-Control-Allow-Origin`, `*`);
    res.header(`Access-Control-Allow-Methods`, `GET,PUT,POST,DELETE,OPTIONS`);
    res.header(`Access-Control-Allow-Headers`, `Content-Type,Authorization`);
  }
}
