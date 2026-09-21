import { setupTests } from "@backend/test/helpers.js";
import { describe, expect, it } from "vitest";

setupTests();

import { PublicURL } from "./public.url.decorator.js";
import { ROUTE_ARGS_METADATA } from "@nestjs/common/constants.js";
import { Configuration } from "@backend/config/core.js";

describe("PublicURL Decorator", () => {
  it("should extract public URL from configuration or HTTP request headers", () => {
    class TestController {
      testMethod(@PublicURL() url: string) {
        return url;
      }
    }

    const metadata = Reflect.getMetadata(ROUTE_ARGS_METADATA, TestController, "testMethod");
    const key = Object.keys(metadata)[0];
    const factory = metadata[key!].factory;

    Configuration.server.publicUrl = "https://sprout.example.com";
    const mockCtx = {
      switchToHttp: () => ({
        getRequest: () => ({
          protocol: "http",
          headers: { host: "localhost:3000" },
          get: (h: string) => (h === "host" ? "localhost:3000" : null),
        }),
      }),
    };

    expect(factory(null, mockCtx)).toBe("https://sprout.example.com");

    Configuration.server.publicUrl = "";
    expect(factory(null, mockCtx)).toBe("http://localhost:3000");
  });
});
