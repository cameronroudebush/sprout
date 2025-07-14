import { Configuration } from "@backend/config/core";
import express from "express";
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
}
