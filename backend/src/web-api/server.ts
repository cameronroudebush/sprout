import { RestBody } from "@backend/model/api/rest.request";
import { User } from "@backend/model/user";
import { Express, Response } from "express";
import { globSync } from "glob";
import path from "path";
import { Logger } from "../logger";
import { EndpointError } from "./error";
import { RestMetadata } from "./metadata";

/** This class specifies a REST API handling based on incoming messages */
export class RestAPIServer {
  /** The endpoint string that should prefix every request */
  static readonly ENDPOINT_HEADER = "/api";

  constructor(private server: Express) {}

  /** Handles loading all endpoints and adding handlers for those callbacks */
  async initialize() {
    await this.registerEndpoints(); // Check all files for endpoints
    await this.addListener(); // Add the overarching listener
  }

  /** Registers all endpoints dynamically from the endpoints folder */
  private async registerEndpoints(root = path.join(__dirname, "endpoints")) {
    Logger.info("Registering REST endpoints...");
    const endpoints = globSync("+(*.ts|*.js)", { cwd: root });
    return await Promise.all(
      endpoints.map(async (endpointFile) => {
        await import(path.join(root, endpointFile));
      }),
    );
  }

  /** Adds the overarching listener to handle REST requests */
  private async addListener() {
    this.server.all("*", async (req, res) => {
      this.setCORSHeaders(res);
      // Handle options requests
      if (req.method === "OPTIONS") return res.status(200).end();
      // Re useable functions
      const badRequest = (error: Error | EndpointError) => {
        let code = (error as EndpointError).code;
        if (typeof code === "string") code = 500;
        res.status(code ?? 400).end(error.message || undefined);
      };
      try {
        // If we have an API base, strip it because the endpoints will not know of it.
        const endpoint = RestMetadata.loadedEndpoints.find((x) => x.metadata.queue === req.url);
        if (endpoint == null) throw new EndpointError(`No matching endpoint: ${req.url}`, 400);
        // Validate authentication if required;
        let user: User | null;
        if (endpoint.metadata.requiresAuth) {
          const authorization = req.headers.authorization;
          if (authorization == null) throw new EndpointError("Unauthorized", 403);
          else if (!authorization.includes("Bearer")) throw new EndpointError("Malformed Bearer", 403);
          else
            try {
              const cleanJWT = authorization.replace("Bearer ", "");
              // While sessions aren't really RESTful, I don't care and need a way to authenticate users.
              const jwtResult = User.verifyJWT(cleanJWT);
              user = await User.findOne({ where: { username: jwtResult.username } });
              if (user == null) throw new Error("User could not be found");
            } catch (e) {
              throw new EndpointError("", 403);
            }
        } else if (req.method !== endpoint.metadata.type)
          throw new EndpointError("Bad Request Type"); // Make sure request types match
        else if (!req.body) throw new EndpointError("Empty body"); // Ignore empty requests
        // Grab data from body
        const data = req.body;
        // Try to parse as type
        const typedData = RestBody.fromPlain(data);
        const result = await (endpoint.fnc.call(this, typedData, user!) as Promise<void | RestBody<any>>);
        // Make sure response know's it's JSON
        res.setHeader("Content-Type", "application/json");
        if (endpoint.metadata.type === "POST" || endpoint.metadata.type === "GET")
          if (result == null) throw new EndpointError("Call didn't return any data.");
          else {
            // Create the rest request response message
            const resultMessage = RestBody.fromPlain({
              requestId: typedData.requestId, // Get the request id from the original so we can respond with it
              payload: result,
            });
            return res.status(200).end(resultMessage.toJSONString());
          }
        return res.status(200).end();
      } catch (e) {
        Logger.error(e as Error);
        return badRequest(e as any);
      }
    });
  }

  /** Sets CORS headers for the given response */
  private setCORSHeaders(res: Response) {
    // TODO
    res.header(`Access-Control-Allow-Origin`, `*`);
    res.header(`Access-Control-Allow-Methods`, `GET,PUT,POST,DELETE,OPTIONS`);
    res.header(`Access-Control-Allow-Headers`, `Content-Type,Authorization`);
  }
}
