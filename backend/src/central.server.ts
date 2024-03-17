import { Configuration } from "@backend/config/core";
import express from "express";
import { Logger } from "./logger";

/**
 * The central server provides us a singular backend endpoint consuming a single port that can provide web request responses
 */
export class CentralServer {
  constructor(public readonly server = express()) {
    Logger.log("Spinning up Central Server...");
    server.listen(Configuration.server.port);
    server.use(express.json());
  }
}
