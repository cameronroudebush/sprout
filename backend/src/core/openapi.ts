import { Configuration } from "@backend/config/core";
import { INestApplication } from "@nestjs/common";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { apiReference } from "@scalar/nestjs-api-reference";
import { Request, Response } from "express";
import { startCase } from "lodash";
import { name } from "../../package.json";

const projName = startCase(name);
const title = `${projName} API`;

/**
 * Creates the API document requirements for OpenAPI usage
 * @param name The name of the app
 * @param app The reference to the NestJS app to attach our endpoint to
 */
export function configureApiDocument(app: INestApplication) {
  const description = `Welcome to the ${projName} API documentation. This document provides a comprehensive guide to all available endpoints. Use the sections below to explore different parts of the API.`;
  const version = Configuration.version;
  const config = new DocumentBuilder()
    .setTitle(title)
    .setDescription(description)
    .setVersion(version)
    .addBearerAuth({ type: "http", description: "This authentication utilizes the JWT given during user login." })
    .addTag("Core", `Provides essential application functionalities, including some proxying, the Server Sent Events (SSE) endpoints and other utility.`)
    .addTag("Config", `Manages application-wide settings and configurations.`)
    .addTag("Auth", "Manage user authentication.")
    .addTag("User", "Manage user creation, and profile information.")
    .addTag("User Config", "Manage user-specific application settings and configurations.")
    .addTag("Notification", "Retrieve notification information intended for a specific user.")
    .addTag("Account", "Manage financial accounts, including retrieval, editing, and linking with financial providers.")
    .addTag("Transaction", "Access and manage financial transactions, including searching, editing, and analyzing spending patterns.")
    .addTag("Transaction Rule", "Define and manage rules for automatic transaction categorization during synchronization.")
    .addTag("Category", "Define and manage categories which assist in grouping transactions.")
    .addTag("Holding", "Define and manage holdings which tracks stock information.")
    .addTag("Net Worth", "Provides endpoints to track and visualize a user's net worth over time.")
    .addTag("Cash Flow", "Provides endpoints to analyze and visualize cash flow, showing how money moves between income and expenses using categories.")
    .addTag("Chat", "Provides endpoints to allow querying an LLM with your account data.")
    .addTag("Provider", "Provides endpoints for the various sources that can provide data to Sprout.")
    .build();
  const document = SwaggerModule.createDocument(app, config);

  // Add a global 429 response to all endpoints since we use a global ThrottlerGuard.
  for (const path of Object.values(document.paths))
    for (const method of Object.values(path))
      method.responses["429"] = {
        description: "Too Many Requests. The user has sent too many requests in a given amount of time.",
      };
  return document;
}

/** Creates the api endpoints that shows a nice interface for interacting with the API. */
export function setupOpenApiHelp(app: INestApplication) {
  const document = configureApiDocument(app);
  app.use(Configuration.server.basePath, (req: Request, res: Response, next: Function) => {
    if (req.path === "/" || req.path === "") {
      return apiReference({
        content: document,
        servers: [
          {
            url: "http://localhost:8001",
            description: "Local Environment",
          },
        ],
        documentDownloadType: "none",
        hideClientButton: true,
        authentication: {
          preferredSecurityScheme: "bearer",
        },
        metaData: {
          title: title,
        },
        showDeveloperTools: "never",
        favicon: "https://sprout.croudebush.net/assets/favicon-bg.svg",
        agent: {
          disabled: true,
        },
        mcp: {
          disabled: true,
        },
      })(req, res);
    }
    next();
  });
}
