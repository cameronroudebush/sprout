import { Logger } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { SwaggerModule } from "@nestjs/swagger";
import * as fs from "fs";
import path from "path";
import { AppModule } from "../app.module";
import { SproutLogger } from "../core/logger";
import { createSwaggerDoc } from "../main";

/** A function that allows us to generate an openAPI spec file to the given path then exit. */
export async function generateOpenApiSpec(givenPath = process.argv[2] || "./openapi-spec.json") {
  // Create a "silent" app instance
  const app = await NestFactory.create(AppModule, {
    logger: new SproutLogger("Open API Spec Service"),
  });

  Logger.log("Generating open api spec...");
  const config = createSwaggerDoc(app)();
  const document = SwaggerModule.createDocument(app, config);
  const outputPath = path.resolve(givenPath);
  Logger.log(`Writing to ${outputPath}`);

  if (fs.statSync(outputPath).isDirectory()) throw new Error("Output path is a directory. Refusing to write.");

  // Write the OpenAPI spec to a JSON file
  fs.writeFileSync(outputPath, JSON.stringify(document, null, 2));

  // Close the app instance to exit the script
  await app.close();
}
