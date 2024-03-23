import { Configuration } from "@backend/config/core";
import { RestRequest } from "@common";
import { Express } from "express";
import { globSync } from "glob";
import jwt from "jsonwebtoken";
import path from "path";
import { Logger } from "../logger";
import { RestMetadata } from "./metadata";

/** Extension upon the error class so we can add codes */
class EndpointError extends Error {
  /** Error code that occurred to help the developer find out what they did wrong. */
  code: number;

  constructor(message: string, code: number = 400) {
    super(message);
    this.code = code;
  }
}

/** This class specifies a REST API handling based on incoming messages */
export class RestAPIServer {
  /** The endpoint string that should prefix every request */
  static readonly ENDPOINT_HEADER = "/api";

  constructor(private server: Express) {}

  /** Handles loading all endpoints and adding handlers for those callbacks */
  async initialize() {
    await this.registerEndpoints();
    await this.registerEndpointsToServer();
  }

  /** Registers all endpoints dynamically from the endpoints folder */
  private async registerEndpoints(root = path.join(__dirname, "endpoints")) {
    Logger.log("Registering REST endpoints...");
    const endpoints = globSync("*.ts", { cwd: root });
    return await Promise.all(
      endpoints.map(async (endpointFile) => {
        await import(path.join(root, endpointFile));
      })
    );
  }

  /** Registers all endpoints from our endpoint files so we can track when messages come in */
  private async registerEndpointsToServer() {
    for (let endpoint of RestMetadata.loadedEndpoints)
      this.server.all(path.join(RestAPIServer.ENDPOINT_HEADER, ...endpoint.metadata.queue.split("/")).replaceAll("\\", "/"), async (req, res) => {
        // Re useable functions
        const badRequest = (error: Error | EndpointError) => res.status((error as any).code || 400).end(error.message || undefined);
        try {
          // Validate authentication if required
          if (endpoint.metadata.requiresAuth) {
            const authorization = req.headers.authorization;
            if (authorization == null) throw new EndpointError("", 403);
            else
              try {
                // TODO: Users need a way to authenticate. That means we need a user model in the backend to generate JWT's. Make sure to use ts-mixer.
                jwt.verify(Configuration.server.secretKey, "shhhhh");
              } catch {
                throw new EndpointError("", 403);
              }
          } else if (req.method !== endpoint.metadata.type) throw new EndpointError("Bad Request Type"); // Make sure request types match
          else if (!req.body) throw new EndpointError("Empty body"); // Ignore empty requests
          else {
            const data = req.body;
            // Try to parse as type
            const typedData = RestRequest.fromPlain(data);
            const result = await (endpoint.fnc.call(this, typedData) as Promise<void | RestRequest<any>>);
            res.setHeader("content-type", "application/json");
            if (endpoint.metadata.type === "POST")
              if (!result) throw new EndpointError("Post call didn't return any data.");
              else res.status(200).end(result.toJSONString());
            else res.status(200).end();
          }
        } catch (e) {
          badRequest(e as any);
        }
      });
  }
}
